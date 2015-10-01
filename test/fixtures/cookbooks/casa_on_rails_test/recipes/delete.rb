# sets up casa on rails before running this integration which tears it back down.
include_recipe 'casa_on_rail_test::default'

casa_on_rails 'default' do
  deploy_path '/var/casa'
  secret '0d7e46be6a8fd3a1e4cc3b11d8a09a03d7c948f3dc772119cce2'
  uuid '988ab9d1-6e7c-44b1-9273-65d378941f54'
  contact_name 'Steve Nolen'
  contact_email 'technolengy@gmail.com'
  bundler_path '/usr/local/rbenv/shims'
  action :delete
end