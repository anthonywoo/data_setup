lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'version'

Gem::Specification.new do |s|

  s.name    = "zd_data"
  s.version = ZdRequester::VERSION
  s.date    = ZdRequester::VERSION_DATE
  s.summary = "Quickly setup data into your Zd account"
  s.description = "Quickly setup data into your Zd account"
  s.authors = ["Anthony Woo"]

  s.add_dependency('faraday')
  s.add_dependency('typhoeus')
  s.add_dependency('json')
  s.add_dependency('activesupport')

  s.require_paths = ["lib"]
  s.files = `git ls-files`.split("\n")

end