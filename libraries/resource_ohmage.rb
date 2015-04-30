require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class Ohmage < Chef::Resource::LWRPBase
      self.resource_name = :ohmage
      actions :create, :delete
      default_action :create

      attribute :instance, kind_of: String, name_attribute: true
      attribute :endpoint, kind_of: String, required: true
      attribute :db_host, kind_of: String, default: '127.0.0.1'
      attribute :db_port, kind_of: Integer, default: 3306
      attribute :db_name, kind_of: String, required: true
      attribute :db_user, kind_of: String, required: true
      attribute :db_password, kind_of: String, required: true
      attribute :tomcat_server, kind_of: String, default: 'tomcat7'
      attribute :tomcat_webapp_dir, kind_of: String, default: '/var/lib/tomcat7/webapps'
      attribute :version, kind_of: String, default: '2.16'
    end
  end
end
