require 'chef/provider/lwrp_base'
#require_relative 'helpers'

class Chef
  class Provider
    class Ohmage < Chef::Provider::LWRPBase
      # Chef 11 LWRP DSL Methods
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      # Mix in helpers from libraries/helpers.rb
      #include OhmageCookbook::Helpers

      action :create do
        # nil
      end
    end
  end
end