class Heartbeat < ApplicationRecord
  serialize :current_calls, Array
end
