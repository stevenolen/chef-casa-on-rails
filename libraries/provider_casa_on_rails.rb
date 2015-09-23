require 'chef/provider/lwrp_base'
require_relative 'helpers'

class Chef
  class Provider
    class CasaOnRails < Chef::Provider::LWRPBase
      # Chef 11 LWRP DSL Methods
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      # Mix in helpers from libraries/helpers.rb
      include CasaOnRailsCookbook::Helpers

      action :create do
        # init file for service, abstract to support deb and rhel7
        template "/etc/init.d/casa-#{new_resource.name}" do
          owner 'root'
          group 'root'
          mode '0755'
          source 'sysvinit.erb'
          cookbook 'casa-on-rails'
          variables(
            name: new_resource.name,
            app_path: "#{new_resource.deploy_path}/current",
            port: new_resource.port,
            rails_env: new_resource.rails_env,
            ruby_exec_path: new_resource.bundler_path
          )
        end

        # add shared dirs for chef deploy
        %w(config/environments config/initializers pids log).each do |d|
          directory "#{new_resource.deploy_path}/shared/#{d}" do
            recursive true
          end
        end

        # database.yml
        template "#{new_resource.deploy_path}/shared/config/database.yml" do
          source 'database.yml.erb'
          cookbook 'casa-on-rails'
          variables(
            casa_db_password: new_resource.db_password,
            casa_db_user: new_resource.db_user,
            casa_db_name: new_resource.db_name,
            casa_db_host: new_resource.db_host,
            casa_db_port: new_resource.db_port
          )
          notifies :restart, "service[casa-#{new_resource.name}]", :delayed
        end

        # secrets
        template "#{new_resource.deploy_path}/shared/config/secrets.yml" do
          source 'secrets.yml.erb'
          cookbook 'casa-on-rails'
          variables(
            casa_secret: new_resource.secret
          )
          notifies :restart, "service[casa-#{new_resource.name}]", :delayed
        end

        # generate environment file.
        template "#{new_resource.deploy_path}/shared/config/environments/#{new_resource.rails_env}.rb" do
          source 'environment.rb.erb'
          cookbook 'casa-on-rails'
          variables(
            casa_uuid: new_resource.uuid,
            casa_contact_name: new_resource.contact_name,
            casa_contact_email: new_resource.contact_email
          )
          notifies :restart, "service[casa-#{new_resource.name}]", :delayed
        end

        # generate ES config file, only supports one instance currently.
        template "#{new_resource.deploy_path}/shared/config/initializers/elasticsearch.rb" do
          source 'elasticsearch.rb.erb'
          cookbook 'casa-on-rails'
          variables(
            casa_es_host: new_resource.es_host,
            casa_es_port: new_resource.es_port,
            casa_es_index: new_resource.es_index
          )
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
          symlink_before_migrate(
            'config/database.yml' => 'config/database.yml',
            "config/environments/#{casa_resource.rails_env}.rb" => "config/environments/#{casa_resource.rails_env}.rb",
            'config/initializers/elasticsearch.rb' => 'config/initializers/elasticsearch.rb',
            'config/secrets.yml' => 'config/secrets.yml',
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
          purge_before_symlink %w(log tmp/pids public/system config/database.yml config/secrets.yml config/environments/#{casa_resource.rails_env}.rb config/initializers/elasticsearch.rb)
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
    end
  end
end
