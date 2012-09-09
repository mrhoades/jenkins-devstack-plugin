
class Devstack < Jenkins::Tasks::Builder

  attr_reader :os_username, :os_password, :os_tenant_name

  display_name 'Devstack Deploy'

  def initialize(attrs)
    attrs.each { |k, v| instance_variable_set "@#{k}", v }
  end

  def perform(build, launcher, listener)
    listener.info 'hello, ' + os_username
    # do stuff
  end

end
