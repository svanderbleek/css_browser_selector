require 'css_browser_selector/version'
require 'css_browser_selector/javascript'

require 'action_view/helpers/css_browser_selector'
ActionView::Base.send(:include, ActionView::Helpers::CssBrowserSelector)

require 'action_controller/caching_tracker'
ActionController::Base.send(:include, ActionController::CachingTracker)


