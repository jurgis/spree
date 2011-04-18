class Promotion::Actions::CreateAdjustment < PromotionAction

  calculated_adjustments

  before_create do |a|
    c = a.build_calculator
    c.type = Promotion::Actions::CreateAdjustment.calculators.first.to_s
  end

  def perform(options = {})
    return unless order = options[:order]
    return if order.promotion_credit_exists?(promotion)
    if amount = calculator.compute(order)
      amount = order.item_total if amount > order.item_total
      order.adjustments.promotion.reload.clear unless promotion.combine? and order.adjustments.promotion.all? { |credit| credit.originator.promotion.combine? }
      order.update!
      create_adjustment("#{I18n.t(:promotion)} (#{promotion.code})", order, order)
    end
  end

  delegate :eligible?, :to => :promotion

end
