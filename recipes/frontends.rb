#
# Cookbook Name:: ohmage
# Recipe:: frontends
#
# Author: Steve Nolen <technolengy@gmail.com>
#
# Copyright (c) 2014, UC Regents.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "ohmage::nginx"

link "/var/www/navbar" do
  to "/var/www/webapps"
end

directory "/usr/src/ohmage-#{node['ohmage']['version']}-frontends/" do
  mode 0755
  action :create
end

node.set['ohmage']['frontends']['precompiled'] = [
                                                    {"client" => "gwt-front-end", "location" => "web"},
                                                    {"client" => "survey", "location" => "survey"},
                                                    {"client" => "dashboard", "location" => "dashboard"},
                                                    {"client" => "publicdashboard", "location" => "publicdashboard"}                                                    
                                                  ]

node['ohmage']['frontends']['precompiled'].each do |frontend|
  client = frontend.client
  location = frontend.location

 directory "#{node['ohmage']['navbar']['webclients_dir']}/#{location}" do
  mode 0755
  owner node['nginx']['user']
  group node['nginx']['group']
  action :create
 end
 
 remote_file "https://web.ohmage.org/ohmage/packages/#{node['ohmage']['version']}/#{client}.tar.gz" do
   source "https://web.ohmage.org/ohmage/packages/#{node['ohmage']['version']}/#{client}.tar.gz"
   path     "/usr/src/ohmage-#{node['ohmage']['version']}-frontends/#{client}.tar.gz"
   backup   false
   notifies :run, "execute[extract-#{client}]", :immediately 
 end
 
 execute "extract-#{client}" do
   cwd "#{node['ohmage']['navbar']['webclients_dir']}/#{location}"
   command "tar zxvf /usr/src/ohmage-#{node['ohmage']['version']}-frontends/#{client}.tar.gz"
   action :nothing
 end

end

template "#{node['ohmage']['navbar']['webclients_dir']}/survey/js/config/ConfigManager.js" do
  source "survey_conf.erb"
  mode 0755
  owner node['nginx']['user']
  group node['nginx']['group']
  variables 
end

#campaign authoring tool
directory "#{node['ohmage']['navbar']['webclients_dir']}/authoring" do
  mode 0755
  owner node['nginx']['user']
  group node['nginx']['group']
  action :create
 end

git "#{node['ohmage']['navbar']['webclients_dir']}/authoring" do
  repository "https://github.com/mobilizingcs/campaignAuthoringTool.git"
  revision "master"
  action :sync
end

#campaign_monitor
directory "#{node['ohmage']['navbar']['webclients_dir']}/monitor" do
  mode 0755
  owner node['nginx']['user']
  group node['nginx']['group']
  action :create
 end

git "#{node['ohmage']['navbar']['webclients_dir']}/monitor" do
  repository "https://github.com/mobilizingcs/campaign_monitor.git"
  revision "master"
  action :sync
end