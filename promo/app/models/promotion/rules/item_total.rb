# A rule to limit a promotion to a specific user.
class Promotion::Rules::ItemTotal < PromotionRule

  preference :amount, :decimal, :default => 100.00
  preference :operator, :string, :default => '>'

  OPERATORS = ['gt', 'gte']

  def eligible?(order, options = {})
    puts '  eligible? in item total rule'
    puts "   order.item_total: #{order.item_total}"
    puts "   order.item_total: #{order.reload.item_total}"

    # order.item_total.send(preferred_operator == 'gte' ? :>= : :>, preferred_amount)
    item_total = order.line_items.map(&:amount).sum
    item_total.send(preferred_operator == 'gte' ? :>= : :>, preferred_amount)
  end
end
