require 'serverspec'

set :backend, :exec

describe file('/etc/ohmage.conf') do
  it { should be_file }
end
