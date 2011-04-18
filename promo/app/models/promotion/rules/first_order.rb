class Promotion::Rules::FirstOrder < PromotionRule

  def eligible?(order, options = {})
    order.user && order.user.orders.checkout_complete.count == 0
  end

end
