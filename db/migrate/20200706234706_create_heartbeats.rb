class CreateHeartbeats < ActiveRecord::Migration[6.0]
  def change
    create_table :heartbeats do |t|
      t.string :uuid
      t.text :url
      t.text :current_calls
      t.datetime :sent_at
      t.integer :capacity
      t.string :provider
      t.string :heartbeat_type
      t.timestamps
    end
  end
end
