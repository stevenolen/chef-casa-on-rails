if defined?(ChefSpec)
  def create_casa_on_rails(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:casa_on_rails, :create, resource_name)
  end

  def upgrade_casa_on_rails(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:casa_on_rails, :upgrade, resource_name)
  end

  def delete_casa_on_rails(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:casa_on_rails, :delete, resource_name)
  end
end
