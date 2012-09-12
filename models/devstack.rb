require 'novawhiz'
require 'net/http'
require 'uri'
require_relative 'buffered_io_patch'

class Devstack < Jenkins::Tasks::Builder

  attr_reader :os_username, :os_password, :os_tenant_name, :os_auth_url

  display_name 'Devstack Deploy'

  def initialize(attrs)
    attrs.each { |k, v| instance_variable_set "@#{k}", v }
  end

  def install_devstack_cmd
    <<-eos
      sudo echo "ClientAliveInterval 600" >> sudo /etc/ssh/sshd_config &&
      sudo echo "ClientAliveCountMax 5"   >> sudo /etc/ssh/sshd_config &&
      sudo service ssh restart &&
      sudo apt-get install --yes git &&
      git clone git://github.com/openstack-dev/devstack.git &&
      cd devstack &&
      echo ADMIN_PASSWORD=pass      >  localrc &&
      echo MYSQL_PASSWORD=pass      >> localrc &&
      echo RABBIT_PASSWORD=pass     >> localrc &&
      echo SERVICE_PASSWORD=pass    >> localrc &&
      echo SERVICE_TOKEN=tokentoken >> localrc &&
      echo FLAT_INTERFACE=br100     >> localrc &&
      ./stack.sh
    eos
  end

  def perform(build, launcher, listener)
    nw = NovaWhiz.new(
      :username => os_username,
      :password => os_password,
      :authtenant => os_tenant_name,
      :auth_url => os_auth_url,
      :service_type => "compute")

    listener.info 'booting an instance on which to run devstack.'

    creds = nw.boot :name => 'jenkins-devstack', :flavor => 'standard.xsmall', :image => /Ubuntu Precise/, :key_name => 'jenkins-devstack'

    listener.info 'VM booted.  installing devstack.'

    nw.run_command creds, install_devstack_cmd do |output|
      listener.info output
    end

    response = Net::HTTP.get URI.parse("http://#{creds[:ip]}:80")
    raise "horizon dashboard does not appear to be running on #{creds[:ip]}" unless response =~ /Log In/

    listener.info 'devstack is running.'
  end

end
