class Promotion::Actions::CreateAdjustment < PromotionAction
  has_many  :promotion_credits, :as => :source
  calculated_adjustments
  alias credits promotion_credits

  before_create do |a|
    c = a.build_calculator
    c.type = Promotion.calculators.first.to_s
  end

  def perform(options = {})
    return unless order = options[:order]
    return if order.promotion_credit_exists?(promotion)
    if promotion.eligible?(order) and amount = calculator.compute(order)
      amount = order.item_total if amount > order.item_total
      order.adjustments.promotion.reload.clear unless promotion.combine? and order.adjustments.promotion.all? { |credit| credit.source.combine? }
      order.update!
      Adjustment.create!({
          :label => "#{I18n.t(:promotion)} (#{promotion.code})",
          :source => promotion,
          :amount => -amount.abs,
          :order => order
        }).inspect
    end
  end

  def credits_count
    credits.with_order.count
  end


end
