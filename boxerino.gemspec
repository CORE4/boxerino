# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','boxerino','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'boxerino'
  s.version = Boxerino::VERSION
  s.author = 'Gerrit Visscher'
  s.email = 'g.visscher@core4.de'
  s.homepage = 'https://core4.de'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Vagrant box management tool'
  s.files = `git ls-files`.split("\n")
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'boxerino'
  s.add_development_dependency('rake')
  s.add_development_dependency('aruba')

  s.add_runtime_dependency('gli','2.16.0')
  s.add_runtime_dependency('fulmar-shell','~> 1.8')
end
