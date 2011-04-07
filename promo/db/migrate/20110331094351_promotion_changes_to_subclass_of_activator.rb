class PromotionChangesToSubclassOfActivator < ActiveRecord::Migration
  def self.up
    drop_table :activators

    rename_table :promotions, :activators

    add_column :activators, :event_name, :string
    add_column :activators, :type, :string

    remove_column :activators, :code
    remove_column :activators, :usage_limit
    remove_column :activators, :combine
    remove_column :activators, :match_policy

    rename_column :promotion_rules, :promotion_id, :activator_id
  end

  def self.down
    rename_table :activators, :promotions

    create_table "activators", :force => true do |t|
      t.integer "promotion_id"
      t.string  "event_name"
    end

    remove_column :promotions, :event_name
    remove_column :promotions, :type


    add_column :promotions, :code, :string
    add_column :promotions, :usage_limit, :integer
    add_column :promotions, :combine, :boolean
    add_column :promotions, :match_policy

    rename_column :promotion_rules, :activator_id, :promotion_id
  end
end
