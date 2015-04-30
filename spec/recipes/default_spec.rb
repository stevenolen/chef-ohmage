require 'spec_helper'

describe 'ohmage_test::default' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new(step_into: 'ohmage', file_cache_path: '/var/chef/cache')
      .converge(described_recipe)
  end

  context 'compiling the test recipe' do
    it 'installs java' do
      expect(chef_run).to install_apt_package('openjdk-7-jre-headless')
    end

    it 'sets up mysql service' do
      expect(chef_run).to create_mysql_service('default')
    end

    it 'hack starts mysql service' do
      expect(chef_run).to run_execute('hack-start mysql on debian in docker')
    end

    it 'adds test db info' do
      expect(chef_run).to run_execute('add ohmage db')
    end

    it 'creates ohmage[default]' do
      expect(chef_run).to create_ohmage('default')
    end
  end

  context 'stepping into ohmage[default] resource' do
    it 'creates ohmage.conf' do
      expect(chef_run).to create_template('/etc/ohmage.conf')
    end
  end
end
