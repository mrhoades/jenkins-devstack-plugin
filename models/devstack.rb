require 'novawhiz'
require 'net/http'
require 'uri'
require_relative 'buffered_io_patch'


# TODO: write a script that boots a vm, install jenkins, then installs this plugin


# TODO: USE CASES: i want to spin up a brand new vm (destroy existing) and then run some chit on it, capturing the output
# TODO: USE CASES: i want to reuse an existing vm and run scripts, capturing the output
# TODO: USE CASES: provide multiple ways to validate the results of vm boot and subsequent script execution
# TODO: USE CASES: i want flexibility with the sizing, flavors, and os's that are booted
# TODO: USE CASES: i want to use floating ips, so other environments and systems be setup to depend on a DNS name or static IP


# TODO: how do i set and get the floating ip through ruby openstack? hpfog maybe?

# TODO: code in handling for hp cloud bug where keypairs can't be deleted when they contain two "."

# TODO: try using java script to hide inputs when using various modes
# TODO: try using java script for client side form validation (when filling out plugin params)

# TODO: provide validation through a url check
# TODO: provide validation via regex that requires something to be found
# TODO: provide validation via regex that requires something NOT to appear
# TODO: provide validation via script execution that must return some defined result

# TODO: allow setting multiple security groups
# TODO: allow user to provide a floating ip for the instance, automagically set it (so DNS can used effectively)
# TODO: how to allow IP passthrough or port forwarding to devstack vm? so user can hit VMs running on devstack instance from outside

# TODO: LOWPRI - allow user to provide an existing key to use

# TODO: should i write a regex to peek at script to make sure it has && between steps, and can actually be run?

# TODO: DONE - move devstack install script to a job input parameter (textarea - execution script). making plugin generic and reusable.
# TODO: DONE - provide a selector to user that allows them to configure a verification script
# TODO: DONE - tweak step info and logging to be generic
# TODO: SKIP install tempest template on devstack node (devstack already does all the magix)
# TODO: DONE - do I weave tempest execution into this plugin or create another plugin?
# TODO: DONE - add custom FIXED_RANGE option to localrc, so devstack setup doesn't barf when it conflicts with hp cloud rage
# TODO: DONE - run tempest tests
# TODO: DONE - replace hardcoded parameters for vm creation with plugin input attrs


class Devstack < Jenkins::Tasks::Builder

  display_name 'Boot HP Cloud VM'

  attr_reader :os_username,
              :os_password,
              :os_tenant_name,
              :os_auth_url,
              :os_region_name,
              :vm_name,
              :vm_reuse_existing,
              :vm_image_name,
              :vm_flavor_name,
              :vm_security_groups,
              :vm_shell_commands,
              :res_val_type,
              :res_val_url,
              :res_val_port,
              :res_val_text


  def initialize(attrs)
    attrs.each { |k, v| instance_variable_set "@#{k}", v}
  end

  def perform(build, launcher, listener)

    nw = NovaWhiz.new(:username => os_username,
                      :password => os_password,
                      :authtenant => os_tenant_name,
                      :auth_url => os_auth_url,
                      :region => os_region_name,
                      :service_type => "compute")

    server_exists = nw.server_exists(vm_name)

    if vm_reuse_existing && server_exists

      creds = {:ip => nw.server_by_name(vm_name).accessipv4,
               :user => 'ubuntu',
               :key => nw.get_key(vm_name)}

    else

      if server_exists
        listener.info "Delete cloud vm and key with name '#{vm_name}'..."
        nw.cleanup(vm_name)
      end

      listener.info "Booting a new cloud VM with name '#{vm_name}'..."
      creds = nw.boot :name => vm_name,
                      :flavor => vm_flavor_name,
                      :image => /#{vm_image_name}/,
                      :key_name => vm_name,
                      :region => os_region_name,
                      :sec_groups => [vm_security_groups]

      listener.info 'VM booted with IP Address: ' + creds[:ip]
      listener.info creds[:key]

      #if vm_floating_ip != ''
      #  nw.assign_floating_ip(vm_name,vm_floating_ip)
      #end
    end

    listener.info "SSH to #{creds[:ip]} Commands on node:"
    listener.info vm_shell_commands
    nw.run_command(creds, exec_cmd_on_vm(vm_shell_commands)) do |output|
      listener.info output
    end

    if res_val_url != ''

      addy = res_val_url.sub( "<server-ip>",creds[:ip])

      listener.info "Check for text #{res_val_text} at URL #{addy}"# Full

      uri = URI.parse(addy)
      http = Net::HTTP.new(uri.host, res_val_port)
      http.read_timeout = 10000

      response = http.request(Net::HTTP::Get.new(uri.request_uri))



      raise "Cannot find text '#{res_val_text}' at #{addy}: " + response.body unless response.body =~ /#{res_val_text}/
      listener.info "Found text '#{res_val_text}' at #{addy}"
    end

  end #perform

  def exec_cmd_on_vm(cmd)
    cmd
  end

  def testConnection(opts)
    print opts
  end

  #def creds_local(vm_name,nw)
  #  {
  #      :ip => nw.server_by_name(vm_name).accessipv4,
  #      :user => 'ubuntu',
  #      :key => nw.get_key(vm_name)
  #  }
  #end

  #def run_tempest
  #  <<-eos
  #    cd /opt/stack/tempest/ &&
  #    nosetests tempest/tests
  #  eos
  #end
  #

end #class
