require 'rubygems'
require 'rubygems/specification'
require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rspec'
require 'rspec/core'
require 'rspec/core/rake_task'
require File.expand_path('lib/restfulie')

GEM = "restfulie"
GEM_VERSION = Restfulie::VERSION
SUMMARY  = "Hypermedia aware resource based library in ruby (client side) and ruby on rails (server side)."
AUTHOR   = "Guilherme Silveira, Caue Guerra, Luis Cipriani, Everton Ribeiro, George Guimaraes, Paulo Ahagon"
EMAIL    = "guilherme.silveira@caelum.com.br"
HOMEPAGE = "http://restfulie.caelumobjects.com"

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = SUMMARY
  s.require_paths = ['lib']
  s.files = FileList['lib/**/*.rb', '[A-Z]*', 'lib/**/*.rng'].to_a
  s.add_dependency("nokogiri", [">= 1.4.2"])
  s.add_dependency("actionpack", [">= 2.3.2"])
  s.add_dependency("activesupport", [">= 2.3.2"])
  s.add_dependency("responders_backport", ["~> 0.1.0"])
  s.add_dependency("json_pure", [">= 1.2.4"])

  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
end

module FakeServer
  def self.wait_server(port=3000)
    (1..15).each do 
      begin
        Net::HTTP.get(URI.parse("http://localhost:#{port}/"))
        return
      rescue
        sleep 1
      end
    end
    raise "Waited for the server but it did not finish"
  end
  
  def self.start_server_and_invoke_test(task_name)
    IO.popen("ruby ./spec/requests/fake_server.rb") do |pipe|
      wait_server 4567
      Rake::Task[task_name].invoke
      Process.kill 'INT', pipe.pid
    end
  end
  
  def self.start_server_and_run_spec(target_dir)
    Dir.chdir(File.join(File.dirname(__FILE__), target_dir)) do
      system('rake db:drop db:create db:migrate')
      IO.popen("rails server") do |pipe|
        wait_server
        system "rake spec"
        Process.kill 'INT', pipe.pid
      end
    end
  end
  
end

# optionally loads a task if the required gems exist
def optionally
  begin
    yield
  rescue LoadError; end
end

namespace :test do
  
  desc "Execute integration Order tests"
  task :integration do
    integration_path = "full-examples/rest_from_scratch/part_3"

    Dir.chdir(File.join(File.dirname(__FILE__), integration_path)) do
      system('rake db:drop db:create db:migrate')
      system('rake')
    end
  end
  
  task :spec do
    FakeServer.start_server_and_run_spec "full-examples/rest_from_scratch/part_3"
  end
  
  # namespace :rcov do
  #   Spec::Rake::SpecTask.new('rcov') do |t|
  #       t.spec_opts = %w(-fs --color)
  #       t.spec_files = FileList['spec/units/**/*_spec.rb']
  #       t.rcov = true
  #       t.rcov_opts = ["-e", "/Library*", "-e", "~/.rvm", "-e", "spec", "-i", "bin"]
  #     end
  #     desc 'Run coverage test with fake server'
  #     task :run do
  #       start_server_and_invoke_test('test:rcov:rcov')
  #     end
  # end
  
  namespace :run do
    task :all do
      start_server_and_invoke_test('test:spec:all')
      puts "Execution integration tests... (task test:integration)"
      Rake::Task["test:integration"].invoke()
      Rake::Task["test:examples"].invoke()
    end
    task :rcov do
      start_server_and_invoke_test('test:rcov:rcov')
    end
  end

  desc "runs all example tests"
  task :examples do
    Rake::Task["install"].invoke()

    target_dir = "full-examples/rest_from_scratch/part_3"
    system "cd #{target_dir} && rake db:reset db:seed"

    FakeServer.start_server_and_run_spec target_dir

  end

end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

Rake::RDocTask.new("rdoc") do |rdoc|
   rdoc.options << '--line-numbers' << '--inline-source'
end

optionally do
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/restfulie/**/*.rb', 'README.textile']
  end
end

desc "Install the gem locally"
task :install => [:package] do
  sh %{gem install pkg/#{GEM}-#{GEM_VERSION} -l}
end

desc "Create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "Builds the project"
task :build => :spec

desc "Default build will run specs"
task :default => ['test:run:all']

