$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "canvas_oauth/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "qalam_oauth_engine"
  s.version     = CanvasOauth::VERSION
  s.authors     = ["Dave Donahue", "Adam Anderson", "Simon Williams", "Ahmed Abdelhamid"]
  s.email       = ["adam.anderson@12spokes.com", "simon@instructure.com", "a.hamid@nezam.io"]
  s.homepage    = "https://github.com/ahmeddhamid13/qalam_oauth_engine"
  s.summary     = <<-SUM
CanvasOauth is a mountable engine for handling the oauth workflow with
canvas and making api calls from your rails app.
SUM

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = s.homepage

  s.add_dependency 'httparty', '>= 0.17.0'
  s.add_dependency 'link_header', '0.0.8'
  s.add_dependency "rails", ">= 4.2", "< 5.3"

  s.add_development_dependency "byebug"
  s.add_development_dependency "guard-rspec", '4.6.4'
  s.add_development_dependency "listen", '~> 3.0.6'
  s.add_development_dependency "rb-fsevent"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-its"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rspec-rails-mocha"
  s.add_development_dependency "shoulda-matchers", '~> 3.0.6'
  s.add_development_dependency "sprockets", '~> 3.0'
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "webmock"
end
