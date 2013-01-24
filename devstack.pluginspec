Jenkins::Plugin::Specification.new do |plugin|

  plugin.name = 'devstack'
  plugin.display_name = 'DevStack Plugin'
  plugin.version = '0.0.6'
  plugin.description = 'Deploys Devstack Onto OpenStack'

  # You should create a wiki-page for your plugin when you publish it, see
  # https://wiki.jenkins-ci.org/display/JENKINS/Hosting+Plugins#HostingPlugins-AddingaWikipage
  # This line makes sure it's listed in your POM.
  plugin.url = 'https://wiki.jenkins-ci.org/display/JENKINS/Devstack+Plugin'

  # The first argument is your user name for jenkins-ci.org.
  plugin.developed_by 'tim.miller', 'Tim Miller <tim.miller.0@gmail.com>'

  # This specifies where your code is hosted.
  plugin.uses_repository :github => 'todo'

  # This is a required dependency for every ruby plugin.
  plugin.depends_on 'ruby-runtime', '0.10'
  plugin.depends_on 'token-macro', '1.5.1'
end
