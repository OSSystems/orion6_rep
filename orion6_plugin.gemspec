$:.push File.expand_path("../lib", __FILE__)
require "orion6_plugin/version"

Gem::Specification.new do |gem|
  gem.name        = "orion6_plugin"
  gem.version     = Orion6Plugin::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ["O.S. Systems Softwares Ltda."]
  gem.email       = "contato@ossystems.com.br"
  gem.homepage    = "http://www.ossystems.com.br/"
  gem.summary     = "Plugin to manage Henry Orion 6 eletronic timeclocks"
  gem.description = "Use this plugin to manage several features of the Henry Orion 6 eletronic timeclocks, like report creation, user management, configuration etc."

  gem.files         = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*"]
  gem.test_files    = Dir['{test}/**/*']
  gem.require_paths = ["lib"]

  gem.add_dependency('rake', '>= 0.8.7')
  gem.add_dependency('afd_parser')
end
