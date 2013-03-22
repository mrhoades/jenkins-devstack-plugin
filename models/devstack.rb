require 'novawhiz'
require_relative 'buffered_io_patch'

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
               :key => nw.get_key(vm_name, File.expand_path("~/.ssh/hpcloud-keys/" + os_region_name))}

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


      # bugbugbug - race condition exists between boot of node which reports status "active"
      #             and when the node is actually active and ssh'able. hack to retry ssh.
      for i in 1..19
          begin
              nw.run_command(creds, exec_cmd_on_vm('whoami')) do |output|
                listener.info output
              end
              break
          rescue
              listener.info "wait ten seconds and retry ssh connect..."       
              sleep(10)      
              next
          end
      end

      #if vm_floating_ip != ''
      #  nw.assign_floating_ip(vm_name,vm_floating_ip)
      #end
    end

    listener.info "SSH to #{creds[:ip]} and run commands on node:"
    listener.info vm_shell_commands
    nw.run_command(creds, exec_cmd_on_vm(vm_shell_commands)) do |output|
      listener.info output
    end

    if res_val_url != ''

      sleep(20) # sleep for now, until polling and retry lives

      addy = res_val_url.sub( "<server-ip>",creds[:ip])
      fulladdy = addy + ":" + res_val_port

      listener.info "Check for text #{res_val_text} at URL #{addy}"# Full

      uri = URI.parse(addy)
      http = Net::HTTP.new(uri.host, res_val_port)
      http.read_timeout = 10000

      response = http.request(Net::HTTP::Get.new(uri.request_uri))

      #todo: bugbug - check should use regex and poll for an ammount of time if match is not found
      # currently jenkins shows startup page to user, which doesn't have whatch looking for
      # write a "waitfortext()" fuktion.

      raise "Cannot find text '#{res_val_text}' at #{fulladdy}: " + response.body unless response.body =~ /#{res_val_text}/
      listener.info "Found text '#{res_val_text}' at #{fulladdy}"
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
