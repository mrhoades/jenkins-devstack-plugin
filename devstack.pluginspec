Jenkins::Plugin::Specification.new do |plugin|

  plugin.name = 'boot_hpcloud_vm'
  plugin.display_name = 'Boot HP Cloud VM'
  plugin.version = '0.0.8'
  plugin.description = 'Boot an HP Cloud VM and run scripts'

  # You should create a wiki-page for your plugin when you publish it, see
  # https://wiki.jenkins-ci.org/display/JENKINS/Hosting+Plugins#HostingPlugins-AddingaWikipage
  # This line makes sure it's listed in your POM.
  plugin.url = 'https://wiki.jenkins-ci.org/display/JENKINS/Boot+HPCloud+VM'

  # The first argument is your user name for jenkins-ci.org.
  plugin.developed_by 'tim.miller', 'Tim Miller <tim.miller.0@gmail.com>'
  plugin.developed_by 'matty.rhoades', 'Matty Rhoades <rocketboyjive@gmail.com>'


  # This specifies where your code is hosted.
  plugin.uses_repository :github => 'todo'

  # This is a required dependency for every ruby plugin.
  plugin.depends_on 'ruby-runtime', '0.10'
  plugin.depends_on 'token-macro', '1.5.1'
end
