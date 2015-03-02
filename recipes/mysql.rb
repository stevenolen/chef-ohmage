include_recipe "mysql::server"
include_recipe "mysql::client"

node.default['ohmage']['db']['host'] = 'localhost'
node.default['ohmage']['db']['port'] = node['mysql']['port']

#right now, I really hate the database cookbook since the stupid mysql_chef_gem wont install without a headache and a half
execute "add-mysql-ohmage-db" do
  command "/usr/bin/mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u root -p#{node['mysql']['server_root_password']} -D mysql -r -B -N -e \"CREATE DATABASE #{node['ohmage']['db']['name']}\""
  action :run
  only_if { `/usr/bin/mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u root -p#{node['mysql']['server_root_password']} -D mysql -r -B -N -e \"SELECT COUNT(*) FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '#{node['ohmage']['db']['name']}'\"`.to_i == 0 }
end

execute "add-mysql-user-ohmage" do
  command "/usr/bin/mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u root -p#{node['mysql']['server_root_password']} -D mysql -r -B -N -e \"CREATE USER '#{node['ohmage']['db']['name']}'@'#{node['ohmage']['db']['host']}' IDENTIFIED BY '#{node['ohmage']['db']['password']}'\""
  action :run
  notifies :run, "execute[grant-mysql-user-ohmage]", :immediately
  only_if { `/usr/bin/mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u root -p#{node['mysql']['server_root_password']} -D mysql -r -B -N -e \"SELECT COUNT(*) FROM user where User='#{node['ohmage']['db']['user']}' and Host = '#{node['ohmage']['db']['host']}'\"`.to_i == 0 }
end

execute "grant-mysql-user-ohmage" do
  command "/usr/bin/mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u root -p#{node['mysql']['server_root_password']} -D mysql -r -B -N -e \"GRANT ALL on #{node['ohmage']['db']['name']}.* to '#{node['ohmage']['db']['user']}'@'#{node['ohmage']['db']['host']}'\""
  action :nothing
  notifies :run, "execute[mysql-flush-privileges]", :immediately
end

execute "mysql-flush-privileges" do
  command "/usr/bin/mysql --host=#{node['ohmage']['db']['host']} --port=#{node['ohmage']['db']['port']} -u root -p\"#{node['mysql']['server_root_password']}\" -D mysql -r -B -N -e \"FLUSH PRIVILEGES\""
  action :nothing
end