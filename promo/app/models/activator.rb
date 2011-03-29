class Activator < ActiveRecord::Base

  belongs_to :promotion

  scope :event_name_starts_with, lambda{|name| where('event_name like ?', "#{name}%") }

  def activate(payload)
  end

end
