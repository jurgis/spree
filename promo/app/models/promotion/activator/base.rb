class Promotion::Activator::Base < ActiveRecord::Base
  set_table_name 'activators'

  belongs_to :promotion

  scope :event_name_starts_with, lambda{|name| where('event_name like ?', "#{name}%") }

  def activate(payload)
  end

end

