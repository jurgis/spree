class CreateActivators < ActiveRecord::Migration
  def self.up
    create_table :activators do |t|
      t.integer :promotion_id
      t.string :event_name
    end
  end

  def self.down
    drop_table :activators
  end
end
