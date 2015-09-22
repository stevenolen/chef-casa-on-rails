source 'https://supermarket.chef.io'

metadata

group :integration do
  cookbook 'mysql', '~> 6.0'
  cookbook 'rbenv', git: 'git://github.com/chef-rbenv/chef-rbenv.git'
  cookbook 'ruby_build'
  cookbook 'nodejs'
  cookbook 'casa_on_rails_test', path: 'test/fixtures/cookbooks/casa_on_rails_test'
end
