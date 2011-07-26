require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "puppet-rundeck"
    gem.summary = %Q{Integrates Puppet with RunDeck}
    gem.description = %Q{Provides a resource endpoint for RunDeck from a Puppet Server}
    gem.files        = Dir["{lib,test}/**/*"] + Dir["[A-Z]*"]
    gem.require_path = "lib"
    gem.email = "james@puppetlabs.com"
    gem.homepage = "http://github.com/jamtur01/puppet-rundeck"
    gem.authors = ["James Turnbull"]
    gem.add_dependency "sinatra"
    gem.add_dependency "builder", ">= 2.0.0"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new(:spec) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.spec_files = FileList['spec/**/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:rcov) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rcov = true
  end
rescue LoadError
  puts "RSpec not available. Install it with: gem install rspec"
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
