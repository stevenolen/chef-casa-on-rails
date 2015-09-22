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
  # revision '1.1.12'
  # port 3000
  # db_host '127.0.0.1'
  # db_port 3306
  # db_name 'casa' # set to name attr?
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
end
```

You can start/stop the resulting rails app using `service casa-default` (the name of the resource is used in the service name)

## Assumptions
Just like the casa-on-rails app, it's still early days.  I've made a few assumptions here to simplify the process:

  * You will resolve `mysql` and `elasticsearch` dependencies yourself. Take a look in `fixtures/cookbooks/casa_on_rails_test` for some hints on how I'd do that.
  * You will pass the path to your `bundle` bin file. `sysvinit` on centos is extremely minimal in it's path, so if you don't give me your path, the service is probably not going to start! :). Additionally, I have no interest in controlling how you deploy ruby, so casa_on_rails wont configure a ruby for itself!
  * Although plans are there to define `:create`, `:upgrade`, and `:delete` resources, only `:create` has been created. Additionally, create will likely be used in the future to guard against deploying the code a second time (so you can be free to deploy via capistrano or other means). You would use `:upgrade` to stick to "master", or if you'd like to use a tag/revision and swap to a new one!

## License and Authors

License:: All rights reserved?
Author:: Steve Nolen (<technolengy@gmail.com>)
