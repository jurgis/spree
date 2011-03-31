# A rule to limit a promotion to a specific user.
class Promotion::Rules::LandingPage < PromotionRule

  preference :path, :string

  def eligible?(order, options)
    if options.has_key?(:visited_paths)
      options[:visited_paths].include?(preferred_path)
    else
      true
    end
  end

end

