class Promotion::Actions::CreateAdjustment < PromotionAction
  has_many  :promotion_credits, :as => :source
  calculated_adjustments
  alias credits promotion_credits

  before_create do |a|
    c = a.build_calculator
    c.type = Promotion.calculators.first.to_s
  end

end
