class CreateCalls < ActiveRecord::Migration[6.0]
  def change
    create_table :calls do |t|
      t.jsonb :body, null: false, default: '{}'
      t.timestamps
    end
  end
end
