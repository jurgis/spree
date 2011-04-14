require 'spec_helper'

describe Promotion::Actions::CreateAdjustment do
  let(:order) { mock_model(Order, :user => nil) }

  # From promotion spec:
  context "#perform" do
    let(:order) { Factory(:order) }
    let(:promotion) { Factory(:promotion) }
    let(:action) { Promotion::Actions::CreateAdjustment.new }

    before do
      action.calculator = Calculator::FreeShipping.new
      promotion.promotion_actions = [action]
      action.stub(:promotion => promotion)
    end


    it "should not create a discount when order is not eligible" do
      promotion.stub(:eligible? => false)
      action.perform(:order => order)
      promotion.credits_count.should == 0
    end

    it "should create a discount when order is eligible" do
      order.stub(:ship_total => 5, :item_total => 50, :reload => nil)
      promotion.stub(:eligible? => true)
      action.calculator.stub(:compute => 1000000)

      action.perform(:order => order)
      promotion.credits_count.should == 1
    end

    it "should not create a discount when order already has one from this promotion" do
      order.stub(:ship_total => 5, :item_total => 50, :reload => nil)
      promotion.stub(:eligible? => true)
      action.calculator.stub(:compute => 1000000)

      action.perform(:order => order)
      action.perform(:order => order)
      promotion.credits_count.should == 1
    end

  end

end

