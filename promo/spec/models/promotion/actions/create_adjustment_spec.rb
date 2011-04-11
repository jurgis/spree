require 'spec_helper'

describe Promotion::Actions::CreateAdjustment do
  let(:order) { mock_model(Order, :user => nil) }

  # From promotion spec:
  context "#perform" do
    let(:order) { Order.new }
    let(:promotion) { Promotion.new }
    let(:action) { Promotion::Actions::CreateAdjustment.new }

    before do
      action.calculator = Calculator::FreeShipping.new
      promotion.promotion_actions = [action]
      action.stub(:promotion => promotion)
    end


    it "should not create a discount when order is not eligible" do
      promotion.stub(:eligible? => false)
      order.stub(:promotion_credit_exists? => nil)
      action.perform(:order => order)
      action.promotion_credits.should have(0).item
    end

    it "should create a discount when order is eligible" do
      order.stub(:promotion_credit_exists? => nil)
      order.stub(:ship_total => 5, :item_total => 50, :reload => nil)
      promotion.stub(:eligible? => true)
      promotion.code = 'PROMO'
      action.calculator.stub(:compute => 1000000)

      attrs = {
        :amount => -50,
        :label => "#{I18n.t(:coupon)} (PROMO)",
        :source => promotion,
        :order => order
      }

      PromotionCredit.should_receive(:create!).with(attrs)
      action.perform(:order => order)
    end

  end

end

