# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "css_browser_selector/version"

Gem::Specification.new do |s|
  s.name        = "css_browser_selector"
  s.version     = CssBrowserSelector::VERSION
  s.authors     = ["Reid MacDonald", "John Dewey", "Mani Tadayon", "Sandy Vanderbleek"]
  s.email       = ["bowsersenior@gmail.com"]
  s.homepage    = "https://github.com/attinteractive/css_browser_selector"
  s.summary     = %q{Gives the ability to write specific CSS code for each operating system and each browser from the backend or through JS. }
  s.description = %q{A plugin based on the css_browser_selector to add the browser type and os to either the body and/or html elements within a document. The full usage on how to use these css selectors can be understood at: http://rafael.adm.br/css_browser_selector/}

  s.add_development_dependency "rails", ">= 3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
