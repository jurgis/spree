class Activator < ActiveRecord::Base

  scope :event_name_starts_with, lambda{|name| where('event_name like ?', "#{name}%") }

  def activate(payload)
  end

  def expired?
    starts_at && Time.now < starts_at ||
    expires_at && Time.now > expires_at ||
    usage_limit && credits_count >= usage_limit
  end

end
