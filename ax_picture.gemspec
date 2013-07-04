$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ax_picture/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ax_picture"
  s.version     = AxPicture::VERSION
  s.authors     = ['azimux']
  s.email       = ['azimux@gmail.com']
  s.homepage    = 'http://github.com/azimux/ax_picture'
  s.summary     = 'Engine for image list creation/management'
  s.description = 'Engine for image list creation/management'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT_LICENSE.txt"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"

  s.add_development_dependency "sqlite3"
end
