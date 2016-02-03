# casa-on-rails-cookbook

offers an `lwrp` for setting up a casa-on-rails instance.

## Supported Platforms

CentOS 6

## Attributes

## Usage

Instantiate a casa on rails instance with this resource.  Note the defaults are commented. 

```ruby
casa_on_rails 'default' do
  # repo 'https://github.com/ucla/casa-on-rails.git'
  # revision 'master'
  # port 3000
  # run_user 'casa' # if != 'casa', will not be added to run_group on creation.
  # run_group 'casa'
  # db_host '127.0.0.1'
  # db_port 3306
  # db_name 'casa'
  # db_user 'casa'
  # db_password 'tsktsk'
  # es_host '127.0.0.1'
  # es_port 9200
  # es_index 'casa'
  deploy_path '/var/casa'
  # bundler_path nil
  # rails_env 'production'
  uuid  'de6edba2-c398-44bd-8438-9df2aa70a5b7'
  secret 'cookiesecretusesomethingrandom'
  contact_name 'Joe Schmoe'
  contact_email 'joe@schmoe.edu'
  # shib_client_name nil
  # shib_secret nil
  # shib_restrict_edupersonprincipalname nil
  # shib_restrcit_edupersonscopedaffiliation nil
  # action :create
end
```

You can start/stop the resulting rails app using `service casa-default` (the name of the resource is used in the service name)

## Assumptions
Just like the casa-on-rails app, it's still early days.  I've made a few assumptions here to simplify the process:

  * You will resolve `mysql` and `elasticsearch` dependencies yourself. Take a look in `fixtures/cookbooks/casa_on_rails_test` for some hints on how I'd do that.
  * You will pass the path to your `bundle` bin file. `sysvinit` on centos is extremely minimal in it's path, so if you don't give me your path, the service is probably not going to start! :). Additionally, I have no interest in controlling how you deploy ruby, so casa_on_rails wont configure a ruby for itself!
  * If you want to use the shib bridge configured for other rails apps in this domain, take a look at the attributes commented above. Note the `restrict` attributes accept either a string or array.

## License and Authors

License:: Apache 2.0, see `LICENSE` file for text.
Author:: Steve Nolen (<technolengy@gmail.com>)
