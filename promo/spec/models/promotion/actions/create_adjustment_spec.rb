require 'spec_helper'

describe Promotion::Actions::CreateAdjustment do
  let(:order) { mock_model(Order, :user => nil) }

  # From promotion spec:
  # context "creating discounts" do
  #   let(:order) { Order.new }

  #   before do
  #     promotion.calculator = Calculator::FreeShipping.new
  #   end

  #   it "should not create a discount when order is not eligible" do
  #     promotion.stub(:eligible? => false)
  #     order.stub(:promotion_credit_exists? => nil)

  #     promotion.create_discount(order)
  #     order.promotion_credits.should have(0).item
  #   end

  #   it "should be able to create a discount on order" do
  #     order.stub(:promotion_credit_exists? => nil)
  #     order.stub(:ship_total => 5, :item_total => 50, :reload => nil)
  #     promotion.stub(:code => "PROMO", :eligible? => true)
  #     promotion.calculator.stub(:compute => 1000000)


  #     attrs = {:amount => -50, :label => "#{I18n.t(:coupon)} (PROMO)", :source => promotion, :order => order }
  #     PromotionCredit.should_receive(:create!).with(attrs)

  #     promotion.create_discount(order)
  #   end
  # end

end

