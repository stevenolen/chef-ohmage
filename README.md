# ohmage-cookbook

LWRP for installing an ohmage server instance.

## Supported Platforms

TODO: List your supported platforms.

## Usage

### ohmage LWRP

Include an ohmage block in your wrapper cookbook. It should be noted that ohmage **requires** tomcat to run, but this cookbook makes no claim on
installing tomcat (since maybe you really want to rely on the existing tomcat cookbook). Additionally, this cookbook will not maintain mysql (which is
again, required for use). Take a look at the fixtures cookbook for clean-system deployment example.

```ruby
ohmage 'default' do
  endpoint 'app' # defaults to app
  db_host '127.0.0.1'
  db_name 'ohmage'
  db_user 'ohmage'
  db_password 'ohmagepassword'
  tomcat_webapps_dir '/var/lib/tomcat7/webapps'
end
```

## License and Authors

Author:: Steve Nolen (<technolengy@gmail.com>)
