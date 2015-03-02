#
# Cookbook Name:: ohmage
# Recipe:: default
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

#even though i'm not using the tomcat cookbook, set these!
node.override['tomcat']['base_version'] = 7
node.override['tomcat']['user'] = "tomcat7"
node.override['tomcat']['group'] = "tomcat7"
node.override['tomcat']['webapp_dir'] = "/var/lib/tomcat7/webapps"

package "openjdk-7-jre-headless"
package "tomcat7"

service 'tomcat7' do
  action [:start, :enable]
  supports :status => true, :restart => true
end

#add ohmage.conf
template '/etc/ohmage.conf' do
  source 'ohmage.conf.erb'
  action :create
end

directory node['ohmage']['log_dir'] do
  mode 0755
  owner    node["tomcat"]["user"]
  group    node["tomcat"]["group"]
  action :create
end

directory node['ohmage']['data_dir'] do
  mode 0755
  owner    node["tomcat"]["user"]
  group    node["tomcat"]["group"]
  action :create
end

for dir in ["audits", "audio", "images", "documents", "videos"]
 directory dir do
  mode 0755
  owner    node["tomcat"]["user"]
  group    node["tomcat"]["group"]
  action :create
 end
end

include_recipe "ohmage::db-prep"

if node['ohmage']['user_setup']
 war_url = "https://web.ohmage.org/ohmage/packages/#{node['ohmage']['version']}/server/app-user_setup.war"
else
 war_url = "https://web.ohmage.org/ohmage/packages/#{node['ohmage']['version']}/server/app.war"
end

remote_file war_url do
  source   war_url
  path     "#{node['tomcat']['webapp_dir']}/app.war"
  owner    node["tomcat"]["user"]
  group    node["tomcat"]["group"]
  backup   false
  action :create_if_missing
  notifies :restart, "service[tomcat7]"
end