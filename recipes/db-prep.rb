#
# Cookbook Name:: ohmage
# Recipe:: db-prep
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

include_recipe "git"

git "/usr/src/ohmage-#{node['ohmage']['version']}" do
  repository "https://github.com/ohmage/server.git"
  reference "master"
  action :sync
end

execute "prep-ohmage-db" do
  command "mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u#{node['ohmage']['db']['user']} -p\"#{node['ohmage']['db']['password']}\" #{node['ohmage']['db']['name']} < /usr/src/ohmage-#{node['ohmage']['version']}/db/sql/base/ohmage-ddl.sql"
  action :run
  only_if { `/usr/bin/mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u root -p#{node['mysql']['server_root_password']} -D mysql -r -B -N -e \"SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '#{node['ohmage']['db']['name']}'\"`.to_i < 48 }
  notifies :run, "execute[insert-defaults-ohmage-db]", :immediately
end

execute 'insert-defaults-ohmage-db' do
  cwd "/usr/src/ohmage-#{node['ohmage']['version']}/db/sql/settings/"
  command "for i in `ls -1 .`; do mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u#{node['ohmage']['db']['user']} -p\"#{node['ohmage']['db']['password']}\" #{node['ohmage']['db']['name']} < $i; done"
  action :nothing
end

execute "insert-preferences-ohmage-db" do
  command "mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u#{node['ohmage']['db']['user']} -p\"#{node['ohmage']['db']['password']}\" #{node['ohmage']['db']['name']} < /usr/src/ohmage-#{node['ohmage']['version']}/db/sql/preferences/default_preferences.sql"
  action :run
  only_if { `/usr/bin/mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u root -p#{node['mysql']['server_root_password']} -D mysql -r -B -N -e \"SELECT COUNT(*) FROM #{node['ohmage']['db']['name']}.preference where p_key = 'default_can_create_privilege'\"`.to_i == 0 }
end

preferences = {'fully_qualified_domain_name' => "#{node['fdqn']}", 
               'audio_directory' => "#{node['ohmage']['data_dir']}/audio", 
               'image_directory' => "#{node['ohmage']['data_dir']}/images", 
               'document_directory' => "#{node['ohmage']['data_dir']}/documents",
               'video_directory' => "#{node['ohmage']['data_dir']}/videos",
               'audit_log_location' => "#{node['ohmage']['data_dir']}/audits"
              }

preferences.each do |key, value|
 execute "ohmage-db-pref-#{key}" do
   command "mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u#{node['ohmage']['db']['user']} -p\"#{node['ohmage']['db']['password']}\" #{node['ohmage']['db']['name']} -r -B -N -e \"UPDATE preference set p_value = '#{value}' WHERE p_key = '#{key}'\""
   action :run
   only_if { `/usr/bin/mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u root -p#{node['mysql']['server_root_password']} -D mysql -r -B -N -e \"SELECT COUNT(*) FROM #{node['ohmage']['db']['name']}.preference where p_value = '#{value}' AND p_key = '#{key}'\"`.to_i == 0 }
 end
end