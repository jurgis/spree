Factory.define :promotion, :class => Promotion, :parent => :activator do |f|
  f.name 'Promo'
  # f.after_create do |p|
  #   p.set_preference(:combine, false)
  #   p.set_preference(:usage_limit, 10)
  #   p.set_preference(:code, 'PROMO')
  # end
end
