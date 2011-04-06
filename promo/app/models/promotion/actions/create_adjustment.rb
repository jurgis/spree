class Promotion::Actions::CreateAdjustment < PromotionAction
  has_many  :promotion_credits, :as => :source
  calculated_adjustments
  alias credits promotion_credits

end
