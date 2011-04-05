# Base class for all types of promotion action.
# PromotionActions perform the necessary tasks when a promotion is activated by an event and determined to be eligible.
class PromotionAction < ActiveRecord::Base

  belongs_to :promotion, :foreign_key => 'activator_id'

  scope :of_type, lambda {|t| {:conditions => {:type => t}}}

  # This method should be overriden in subclass
  # Updates the state of the order or performs some other action depending on the subclass
  # options will contain the payload from the event that activated the promotion. This will include
  # the key :user which allows user based actions to be performed in addition to actions on the order
  def do(order, options = {})
    raise 'do should be implemented in a sub-class of Promotion::PromotionAction'
  end

  @action_classes = nil
  @@action_classes = Set.new
  def self.register
    @@action_classes.add(self)
  end

  def self.action_classes
    @@action_classes.to_a
  end

  def self.action_class_names
    PromotionAction.action_classes.map(&:name)
  end

end

