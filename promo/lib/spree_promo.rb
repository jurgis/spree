require 'spree_core'
require 'spree_promo_hooks'

module SpreePromo
  class Engine < Rails::Engine

    def self.activate

      Adjustment.class_eval do
        scope :promotion, lambda { where('label LIKE ?', "#{I18n.t(:promotion)}%") }
      end

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

        attr_accessible :coupon_code
        attr_accessor :coupon_code

        def promotion_credit_exists?(promotion)
          !! adjustments.promotion.reload.detect { |credit| credit.originator.promotion.id == promotion.id }
        end

        def products
          line_items.map {|li| li.variant.product}
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
          {:user => current_user, :order => current_order, :visited_paths => session[:visited_paths]}
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
