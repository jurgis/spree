class Activator < ActiveRecord::Base

  EVENT_NAMES = [
    'spree.cart.add',
    'spree.order.contents_changed',
    'spree.user.signup'
  ]

  scope :event_name_starts_with, lambda{|name| where('event_name like ?', "#{name}%") }

  def activate(payload)
  end

  def expired?
    starts_at && Time.now < starts_at ||
    expires_at && Time.now > expires_at
  end

end
