class HeartbeatBuilderService
  include ActiveModel::Model

  attr_accessor :id, :url, :sent_at, :capacity, :provider, :type, :current_calls

  validates :id, :url, :sent_at, :capacity, :provider, :type, presence: true
  validates :current_calls, presence: true, allow_blank: false

  def call
    begin
      (valid? && save!) || raise(ActiveRecord::RecordInvalid.new(self))
    rescue ActiveRecord::RecordInvalid => exception
      @errors = exception.record.errors
    end
  end

  private

  def save!
    Heartbeat.transaction do
      Heartbeat.create!(
        uuid: id,
        url: url,
        current_calls: current_calls,
        sent_at: sent_at,
        capacity: capacity,
        provider: provider,
        heartbeat_type: type
      )
    end
  end
end
