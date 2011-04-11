require 'spree_core'
require 'spree_promo_hooks'

module SpreePromo
  class Engine < Rails::Engine

    def self.activate
      # put class_eval and other logic that depends on classes outside of the engine inside this block
      Product.class_eval do
        has_and_belongs_to_many :promotion_rules

        def possible_promotions
          rules_with_matching_product_groups = product_groups.map(&:promotion_rules).flatten
          all_rules = promotion_rules + rules_with_matching_product_groups
          promotion_ids = all_rules.map(&:promotion_id).uniq
          Promotion.automatic.scoped(:conditions => {:id => promotion_ids})
        end
      end

      ProductGroup.class_eval do
        has_many :promotion_rules
      end

      Order.class_eval do

        has_many :promotion_credits, :conditions => "source_type='Promotion'", :dependent => :destroy

        attr_accessible :coupon_code
        attr_accessor :coupon_code

        # before_save :process_coupon_code, :if => "@coupon_code"

        def promotion_credit_exists?(promotion)
          promotion_credits.reload.detect { |c| c.source_id == promotion.id }
        end

        # def process_coupon_code
        #   coupon = Promotion.find(:first, :conditions => ["UPPER(code) = ?", @coupon_code.upcase])
        #   if coupon
        #     coupon.create_discount(self)
        #   end
        # end

        def products
          line_items.map {|li| li.variant.product}
        end

        def update_totals(force_adjustment_recalculation=false)
          self.payment_total = payments.completed.map(&:amount).sum
          self.item_total = line_items.map(&:amount).sum

          check_promotion_eligibility
          # process_automatic_promotions

          if force_adjustment_recalculation
            applicable_adjustments, adjustments_to_destroy = adjustments.partition{|a| a.applicable?}
            self.adjustments = applicable_adjustments
            adjustments_to_destroy.each(&:destroy)
          end

          self.adjustment_total = self.adjustments.map(&:amount).sum
          self.total            = self.item_total   + self.adjustment_total
        end

        # TODO: Remove promotions that are no longer eligible
        def check_promotion_eligibility
        end

        # def process_automatic_promotions
        #   #promotion_credits.reload.clear
        #   eligible_automatic_promotions.each do |coupon|
        #     # can't use coupon.create_discount as it re-saves the order causing an infinite loop
        #     if amount = coupon.calculator.compute(line_items)
        #       amount = item_total if amount > item_total
        #       promotion_credits.reload.clear unless coupon.combine? and promotion_credits.all? { |credit| credit.adjustment_source.combine? }
        #       promotion_credits.create!({
        #           :source => coupon,
        #           :amount => -amount.abs,
        #           :label => coupon.description
        #         })
        #     end
        #   end.compact
        # end

        def eligible_automatic_promotions
          @eligible_automatic_coupons ||= Promotion.automatic.select{|c| c.eligible?(self)}
        end
      end



      # Keep a record ot all static page paths visited for promotions that require them
      ContentController.class_eval do
        after_filter :store_visited_path
        def store_visited_path
          session[:visited_paths] ||= []
          session[:visited_paths] = (session[:visited_paths]  + [params[:path]]).uniq
        end
      end

      # Include list of visited paths in notification payload hash
      SpreeBase::InstanceMethods.class_eval do
        def default_notification_payload
          {:current_user => current_user, :visited_paths => session[:visited_paths]}
        end
      end





      if File.basename( $0 ) != "rake"
        # register promotion rules and actions
        [Promotion::Rules::ItemTotal,
         Promotion::Rules::Product,
         Promotion::Rules::User,
         Promotion::Rules::FirstOrder,
         Promotion::Rules::LandingPage,
         Promotion::Actions::CreateAdjustment,
         Promotion::Actions::CreateLineItems
        ].each &:register

        # register default promotion calculators
        [
          Calculator::FlatPercentItemTotal,
          Calculator::FlatRate,
          Calculator::FlexiRate,
          Calculator::PerItem,
          Calculator::FreeShipping
        ].each{|c_model|
          begin
            Promotion::Actions::CreateAdjustment.register_calculator(c_model) if c_model.table_exists?
          rescue Exception => e
            $stderr.puts "Error registering promotion calculator #{c_model}"
          end
        }
      end

    end

    config.autoload_paths += %W(#{config.root}/lib)
    config.to_prepare &method(:activate).to_proc
  end
end
