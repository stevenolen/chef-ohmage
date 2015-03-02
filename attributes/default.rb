default['ohmage']['version'] = '2.16'
default['ohmage']['user_setup'] = false
default['ohmage']['install_method'] = 'download'
default['ohmage']['data_dir'] = '/var/lib/ohmage'
default['ohmage']['log_dir'] = '/var/log/ohmage'
default['ohmage']['navbar'] = true
default['ohmage']['log_level'] = 'DEBUG'

default['ohmage']['db']['host'] = 'localhost'
default['ohmage']['db']['port'] = 3306
default['ohmage']['db']['name'] = 'ohmage'
default['ohmage']['db']['user'] = 'ohmage'
default['ohmage']['db']['password'] = 'pleasechangeme'

default['ohmage']['survey_tool_server'] = node['ipaddress']