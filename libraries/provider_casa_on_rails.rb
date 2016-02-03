require 'chef/provider/lwrp_base'
require_relative 'helpers'

class Chef
  class Provider
    class CasaOnRails < Chef::Provider::LWRPBase # rubocop:disable ClassLength
      # Chef 11 LWRP DSL Methods
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      # Mix in helpers from libraries/helpers.rb
      include CasaOnRailsCookbook::Helpers

      action :create do
        # casa user
        group "#{new_resource.name} :create casa" do
          group_name new_resource.run_group
          action :create
        end

        user "#{new_resource.name} :create casa" do
          username new_resource.run_user
          gid 'casa' if new_resource.run_user == 'casa'
          action :create
        end

        # init file for service, abstract to support deb and rhel7
        template "/etc/init.d/casa-#{new_resource.name}" do
          owner 'root'
          group 'root'
          mode '0755'
          source 'sysvinit.erb'
          cookbook 'casa-on-rails'
          variables(config: new_resource)
        end

        # add shared dirs for chef deploy
        directory "#{new_resource.deploy_path}/shared" do
          recursive true
          owner new_resource.run_user
          group new_resource.run_group
        end

        %w(config pids log).each do |d|
          directory "#{new_resource.deploy_path}/shared/#{d}" do
            recursive true
            owner new_resource.run_user
            group new_resource.run_group
          end
        end

        # database.yml
        template "#{new_resource.deploy_path}/shared/config/database.yml" do
          source 'database.yml.erb'
          owner new_resource.run_user
          group new_resource.run_group
          cookbook 'casa-on-rails'
          variables(config: new_resource)
          notifies :restart, "service[casa-#{new_resource.name}]", :delayed
        end

        # secrets
        template "#{new_resource.deploy_path}/shared/config/secrets.yml" do
          source 'secrets.yml.erb'
          owner new_resource.run_user
          group new_resource.run_group
          cookbook 'casa-on-rails'
          variables(config: new_resource)
          notifies :restart, "service[casa-#{new_resource.name}]", :delayed
        end

        # generate casa config.
        template "#{new_resource.deploy_path}/shared/config/casa.yml" do
          source 'casa.yml.erb'
          owner new_resource.run_user
          group new_resource.run_group
          cookbook 'casa-on-rails'
          variables(config: new_resource)
          notifies :restart, "service[casa-#{new_resource.name}]", :delayed
        end

        # generate ES config file, only supports one instance currently.
        template "#{new_resource.deploy_path}/shared/config/elasticsearch.yml" do
          source 'elasticsearch.yml.erb'
          owner new_resource.run_user
          group new_resource.run_group
          cookbook 'casa-on-rails'
          variables(config: new_resource)
          notifies :restart, "service[casa-#{new_resource.name}]", :delayed
        end

        # generate shib config file.
        template "#{new_resource.deploy_path}/shared/config/auth.yml" do
          source 'auth.yml.erb'
          owner new_resource.run_user
          group new_resource.run_group
          cookbook 'casa-on-rails'
          variables(config: new_resource)
          notifies :restart, "service[casa-#{new_resource.name}]", :delayed
        end

        # required headers for mysql2 gem (which gets installed with bundler below)
        package 'mysql-devel'

        # farm out to chef deploy. TODO: make an attribute that only does this once.
        # note namespace "new resource" causes some weird stuff here.
        computed_path = path_plus_bundler
        casa_resource = new_resource
        deploy_branch casa_resource.name do
          deploy_to casa_resource.deploy_path
          repo casa_resource.repo
          revision casa_resource.revision
          user casa_resource.run_user
          group casa_resource.run_group
          symlink_before_migrate(
            'config/database.yml' => 'config/database.yml',
            'config/casa.yml' => 'config/casa.yml',
            'config/elasticsearch.yml' => 'config/elasticsearch.yml',
            'config/secrets.yml' => 'config/secrets.yml',
            'config/auth.yml' => 'config/auth.yml',
            'bundle' => '.bundle'
          )
          before_migrate do
            execute 'bundle install' do
              environment 'PATH' => computed_path
              cwd release_path
              command "bundle install --path #{casa_resource.deploy_path}/shared/bundle"
            end
            execute 'npm install' do
              cwd release_path
            end
            execute 'block build' do
              environment 'PATH' => computed_path
              cwd release_path
              command 'bundle exec blocks build'
            end
          end
          migrate true
          migration_command "RAILS_ENV=#{casa_resource.rails_env} bundle exec rake db:migrate"
          purge_before_symlink %w(log tmp/pids public/system config/database.yml config/secrets.yml)
          before_symlink do
            execute 'db:seed' do
              environment 'PATH' => computed_path
              cwd release_path
              command "RAILS_ENV=#{casa_resource.rails_env} bundle exec rake db:seed; touch #{casa_resource.deploy_path}/shared/.seeded"
              not_if { ::File.exist?("#{casa_resource.deploy_path}/shared/.seeded") }
            end
          end
          restart_command "service casa-#{casa_resource.name} restart"
        end

        service "casa-#{new_resource.name}" do
          supports restart: true, status: true
          action [:enable, :start]
        end
      end

      action :delete do
        # stop service
        service "casa-#{new_resource.name}" do
          supports restart: true, status: true
          action [:disable, :stop]
        end
        
        # delete deploy path and remove init script.
        directory "#{new_resource.deploy_path}" do
          action :delete
        end
        
        file "/etc/init.d/casa-#{new_resource.name}" do
          action :delete
        end
      end
    end
  end
end
