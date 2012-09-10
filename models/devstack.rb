require 'openstack'

class Devstack < Jenkins::Tasks::Builder

  attr_reader :os_username, :os_password, :os_tenant_name, :os_auth_url

  display_name 'Devstack Deploy'

  def initialize(attrs)
    attrs.each { |k, v| instance_variable_set "@#{k}", v }
  end

  def perform(build, launcher, listener)
    listener.info 'hello, ' + os_username

    os = OpenStack::Connection.create(
      :username => os_username,
      :api_key => os_password,
      :authtenant => os_tenant_name,
      :auth_url => os_auth_url,
      :service_type => "compute")

    listener.info os.servers.inspect
  end

end
