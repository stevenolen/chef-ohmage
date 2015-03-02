#
# Cookbook Name:: ohmage
# Recipe:: nginx
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

#add nginx maintainer repo. bug in nginx::repo
include_recipe 'apt::default'
apt_repository 'nginx' do
  uri          node['nginx']['upstream_repository']
  distribution node['lsb']['codename']
  components   %w(nginx)
  deb_src      true
  key          'http://nginx.org/keys/nginx_signing.key'
end

node.override['nginx']['default_site_enabled'] = false
node.default['nginx']['base_dir'] = '/var/www'

include_recipe "nginx"
include_recipe "git"

directory node['nginx']['base_dir'] do
 mode 0755
 owner node['nginx']['user']
 group node['nginx']['group']
 action :create
end

if node['ohmage']['navbar']
 node.set['ohmage']['navbar']['webclients_dir'] = "#{node['nginx']['base_dir']}/webapps"
 directory node['ohmage']['navbar']['webclients_dir'] do
  mode 0755
  owner node['nginx']['user']
  group node['nginx']['group']
  action :create
 end
end 

#enabled ohmage site
template "#{node['nginx']['dir']}/sites-available/ohmage" do
  source "ohmage_nginx.conf.erb"
  mode 0644
end

file "#{node['nginx']['dir']}/conf.d/default.conf" do
  action :delete
end

nginx_site "ohmage" do
  action :enable
end

#git "#{node['nginx']['base_dir']}" do
git "/usr/src/navbar" do
  repository "https://github.com/mobilizingcs/navbar.git"
  revision "generic"
  action :sync
  notifies :run, "execute[copy-navbar]", :immediately
end

execute "copy-navbar" do
  command 'cp -r /usr/src/navbar/* /var/www'
  action :nothing
end