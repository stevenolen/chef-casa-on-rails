require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class CasaOnRails < Chef::Resource::LWRPBase
      self.resource_name = :casa_on_rails
      actions :create, :delete
      default_action :create

      attribute :name, kind_of: String, name_attribute: true
      attribute :repo, kind_of: String, default: 'https://github.com/ucla/casa-on-rails.git'
      attribute :revision, kind_of: String, default: '1.2.0'
      attribute :port, kind_of: Integer, default: 3000
      attribute :run_user, kind_of: String, default: 'casa'
      attribute :run_group, kind_of: String, default: 'casa'
      attribute :db_host, kind_of: String, default: '127.0.0.1'
      attribute :db_port, kind_of: Integer, default: 3306
      attribute :db_name, kind_of: String, default: 'casa' # set to name attr?
      attribute :db_user, kind_of: String, default: 'casa'
      attribute :db_password, kind_of: String, default: 'tsktsk'
      attribute :es_host, kind_of: String, default: '127.0.0.1'
      attribute :es_port, kind_of: Integer, default: 9200
      attribute :es_index, kind_of: String, default: 'casa'
      attribute :deploy_path, kind_of: String, required: true
      attribute :bundler_path, kind_of: String, default: nil
      attribute :rails_env, kind_of: String, default: 'production'
      attribute :uuid, kind_of: String, required: true, regex: [/[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}/i]
      attribute :secret, kind_of: String, required: true
      attribute :contact_name, kind_of: String, required: true
      attribute :contact_email, kind_of: String, required: true
      attribute :shib_secret, kind_of: String, default: nil
      attribute :shib_client_name, kind_of: String, default: nil
      attribute :shib_site, kind_of: String, default: nil
      attribute :shib_restrict_edupersonprincipalname, kind_of: [String, Array], default: nil
      attribute :shib_restrict_edupersonscopedaffiliation, kind_of: [String, Array], default: nil
      attribute :caliper_url, kind_of: String, default: nil
      attribute :caliper_api_key, kind_of: String, default: nil
      attribute :caliper_sensor_id, kind_of: String, default: nil
    end
  end
end
