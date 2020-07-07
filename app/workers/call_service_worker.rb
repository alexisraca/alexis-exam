class CallServiceWorker
  include Sidekiq::Worker

  def perform(call_id)
    call = Call.find(call_id)
    begin
      CallService.new(call).call
    rescue => exception
      # Notify an external service
    end
  end
end