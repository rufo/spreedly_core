$LOAD_PATH.unshift 'lib'
require "spreedly_core/version"

Gem::Specification.new do |s|
  s.name              = "spreedly_core"
  s.version           = SpreedlyCore::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Ruby API for Spreedly Core"
  s.homepage          = "http://github.com/403labs/spreedly_core"
  s.email             = "github@403labs.com"
  s.authors           = [ "403 Labs" ]

  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("man/**/*")
  s.files            += Dir.glob("test/**/*")

  s.add_runtime_dependency     'httparty'
  s.add_runtime_dependency     'activesupport'

  s.add_development_dependency 'ruby-debug'
  s.add_development_dependency 'rake', '0.8.7'

end
