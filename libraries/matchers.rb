if defined?(ChefSpec)
  # config
  def create_ohmage(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ohmage, :create, resource_name)
  end
end
