class CallService
  attr_reader :call, :body
#   // sample body
#   // {
#   //   "contexts": [
#   //     {
#   //       "attribute": "name"
#   //     },
#   //     {
#   //       "attribute": "address"
#   //     }
#   //   ],
#   //   "domain": "https://api.dataplor.com",
#   //   "number_attribute": "phone",
#   //   "number": "528343160366",
#   //   "data": {
#   //     "name": "Restaurante Don Jorge",
#   //     "phone": "+528343160366",
#   //     "address": "Av Tamaulipas 1100"
#   //   },
#   //   "formatted_number": "+528343160366",
#   //   "observation_id": "1626a2c4-ab0d-4f52-8420-851c171e78ec",
#   //   "caller_id": "525588969150",
#   //   "voice": {
#   //     "voice": "Lupe",
#   //     "locale": "es-US",
#   //     "provider": "aws"
#   //   },
#   //   "endpoint": "https://dataplor-lite-bot-prod.azurewebsites.net/outbound/makecall",
#   //   "bot_env": "production"
#   // }
  def initialize(call)
    @call = call
    @body = call.body.with_indifferent_access
  end

  def call
    bot_server_address = find_bot_server
    call = nexmo_connection.calls.create(
                                    to: [{ type: 'phone', number: @body[:caller_id] }],
                                    from: [{ type: 'phone', number: @body[:number] }],
                                    answer_url: [bot_server_address]
                                  )
    audio_files.each do |audio_file|
      call.stream(@body[:caller_id], audio_file)
    end
  end

  private

  def find_bot_server
    BotFinder.find_bot_server
  end

  def nexmo_connection
    @nexmo ||= Nexmo::Client.new(api_key: ENV.fetch('NEXMO_API_KEY'), api_secret: ENV.fetch('NEXMO_API_SECRET'))
  end

  def audio_files
    @audio_files ||= syntetizable_attributes.inject({}) do |hash, attribute|
                       hash[attribute] = find_or_syntetize(attribute)
                     end
  end

  def syntetizable_attributes
    @syntetizable_attributes ||= body[:contexts].map { |context| context[:attribute] }
  end

  def find_or_syntetize(attribute)
    fetch_from_s3(attribute) || syntetize_and_upload(attribute)
  end

  def fetch_from_s3(attribute)
    S3.find("#{@body[:number]}-#{@body[:bot_env]}-#{attribute}")
  end

  def syntetize_and_upload(attribute)
    begin
      retries ||= 0
      audio_file = Syntetizer.syntetize(@body[:data][attribute.to_sym])
      audio_file = S3.upload("#{@body[:number]}-#{@body[:bot_env]}-#{attribute}", audio_file)
    rescue => exception
      retry if (retries += 1 < 3)
    end
    audio_file
  end
end

#   // we can call this endpoint to initiate a call
#   // calls are actually performed by different servers, but this server needs to do 3 functions:
#   // 1. presynthesize the audios to s3
#   // 2. load balance the bot call servers so we dont overload one while others are idle
#   // 3. initiate the call by calling nexmo

#   // sample body
#   // {
#   //   "contexts": [
#   //     {
#   //       "attribute": "name"
#   //     },
#   //     {
#   //       "attribute": "address"
#   //     }
#   //   ],
#   //   "domain": "https://api.dataplor.com",
#   //   "number_attribute": "phone",
#   //   "number": "528343160366",
#   //   "data": {
#   //     "name": "Restaurante Don Jorge",
#   //     "phone": "+528343160366",
#   //     "address": "Av Tamaulipas 1100"
#   //   },
#   //   "formatted_number": "+528343160366",
#   //   "observation_id": "1626a2c4-ab0d-4f52-8420-851c171e78ec",
#   //   "caller_id": "525588969150",
#   //   "voice": {
#   //     "voice": "Lupe",
#   //     "locale": "es-US",
#   //     "provider": "aws"
#   //   },
#   //   "endpoint": "https://dataplor-lite-bot-prod.azurewebsites.net/outbound/makecall",
#   //   "bot_env": "production"
#   // }