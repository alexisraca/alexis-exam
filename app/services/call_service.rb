class CallService
  attr_reader :call, :body

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
    @nexmo ||= Nexmo::Client.new(api_key: ENV['NEXMO_API_KEY'], api_secret: ENV['NEXMO_API_SECRET'])
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