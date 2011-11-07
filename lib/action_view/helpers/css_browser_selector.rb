require 'action_view/helpers/tag_helper'
require 'action_view/helpers/text_helper'
require 'action_view/helpers/capture_helper'

module ActionView
  module Helpers
    module CssBrowserSelector
      include TagHelper
      include TextHelper
      include CaptureHelper

      # Javascript version of the CSS Browser Selector, can be put inline into the page / layout
      # by <%= javascript_tag css_browser_selector %>
      #
      # Can pass in an tag name in which the script will place the css browser selectors:
      # <%= javascript_tag css_browser_selector('body')
      #
      # To turn off comments for the smallest javascript possible, pass false as a second parameter:
      # <%= javascript_tag css_browser_selector('body', false)
      #
      # This file is originally read off of disk from within the plugin's lib at javascripts/css_browser_selector.js
      def css_browser_selector(tag = 'html', show_comments = true)
        @javascript ||= ::CssBrowserSelector::Javascript.contents(show_comments)
        @javascript.gsub('html', tag)
      end

      # Inline javascript to creates an addLoadEvent method on Window to allow onload functions to
      # be chained together without clobbering any prior onloads that may have been attached. This
      # can be added inline, standalone like so:
      #   <%= javascript_tag window_add_load_event %>
      def window_add_load_event
        %(window.addLoadEvent = function(f){var oldf=window.onload; window.onload=(typeof window.onload!='function')?f:function(){oldf();f();}})
      end

      # Combines the window_add_load_event and window_add_js_to_tag methods to be run within one
      # script element:
      #   <%= javascript_tag window_on_load_add_js_to_tag(:body) %>
      def window_on_load_add_js_to_tag(tagname)
        "#{window_add_load_event}\n#{window_add_js_to_tag(tagname)}"
      end

      # Page cached aware helper method that is equivalent to:
      #   <%= javascript_tag window_on_load_add_js_to_tag(tag) unless controller.page_cached? %>
      #
      # Example: if you are using the body content element:
      #   <%= javascript_to_add_js_to :body %>
      def javascript_to_add_js_to(tag)
        javascript_tag window_on_load_add_js_to_tag(tag) unless controller.page_cached?
      end

      # Creates the html content element with css_browser_selectors added to its class attribute.
      # Includes by default the following attributes (which can be overridden):
      #   <html xmlns="http://www.w3.org/1999/xhtml" xml:lang=>"en" lang=>"en">
      def html(html_options = {}, &block)
        html_options.reverse_merge!(:xmlns=>"http://www.w3.org/1999/xhtml", :"xml:lang"=>"en", :lang=>"en")
        add_css_browser_selectors_to_tag(:html, html_options, &block)
      end

      # Creates the body content element with css_browser_selectors added to its class attribute.
      def body(html_options = {}, &block)
        add_css_browser_selectors_to_tag(:body, html_options, &block).html_safe
      end

      # # arguments: name, content options, escape = true
      # # will dry up once I get working
      # def content_tag_string_with_css_browser_selector(*args)
      #   if args[0] == :html or args[0] == :body
      #     html_options = args[2]||{}
      #     exclude_browser_and_os = html_options.delete(:exclude_browser_and_os)
      #     unless exclude_browser_and_os or (bros = determine_browser_and_os).empty?
      #       html_options[:class] = html_options[:class] ? "#{html_options[:class]} #{bros}" : bros
      #     end
      #     args[2] = html_options if html_options
      #   end
      #   content_tag_string_without_css_browser_selector(*args)
      # end
      # alias_method_chain :content_tag_string, :css_browser_selector

      private
      # Inline javascript to add the 'js' class to the supplied tag.  Adds the 'js' css_browser_selector
      # class, which must rely on javascript to be enabled to run.  Relies on
      # +Window.addLoadEvent+ method to be added (with the window_add_load_event method)
      #   <%= javascript_tag window_add_js_to_tag(:body)
      def window_add_js_to_tag(tagname)
        %(window.addLoadEvent(function(){e=document.getElementsByTagName('#{tagname}')[0];e.className+=e.className?' js':'js'}))
      end

      # Underlying content builder for both the +html+ and +body+ functions
      def add_css_browser_selectors_to_tag(tag, html_options = {}, &block)
        html_options ||= {}
        exclude_browser_and_os = html_options.delete(:exclude_browser_and_os)
        unless exclude_browser_and_os or (bros = determine_browser_and_os).empty? or controller.page_cached?
          html_options[:class] = html_options[:class] ? "#{html_options[:class]} #{bros}" : bros
        end

        open_tag, close_tag = content_tag(tag, "<>", html_options).split("&lt;&gt;")
        
        content = String.new
        content << open_tag
        content << "\n#{javascript_tag(css_browser_selector(tag, false))}" if controller.page_cached?
        content << capture(&block) if block_given?
        content << close_tag
        self.output_buffer = content
        output_buffer
      end

      # The ruby version of the CSS Browser Selector with some additions
      # TODO: This should be moved to a parser.
      def determine_browser_and_os(ua = request.env["HTTP_USER_AGENT"])
        ua = (ua||"").downcase
        br = case ua
          when /opera[\/,\s+](\d+)/
            o = %W(opera opera#{$1})
            o << "mobile" if ua.include?('mini')
            o.join(" ")
          when /webtv/ ;              "gecko"
          when /msie (\d)/ ;          "ie ie#{$1}"
          when %r{firefox/2} ;        "gecko ff2"
          when %r{firefox/3.5} ;      "gecko ff3 ff3_5"
          when %r{firefox/3} ;        "gecko ff3"
          when /konqueror/ ;          "konqueror"
          when /applewebkit\/([\d.]+).? \([^)]*\) ?(?:version\/(\d+))?.*$/
            o = %W(webkit)
            if ua.include?('iron')
              o << 'iron'
            elsif ua.include?('chrome')
              o << 'chrome'
            else
              o << "safari safari"+ ($2 || (($1.to_i >= 400) ? '2' : '1'))
            end
            o.join(" ")
          when /gecko/, /mozilla/ ;   "gecko"
        end
        os = ua.include?('mac') || ua.include?('darwin') ? ua.include?('iphone') ? 'iphone' : ua.include?('ipod') ? 'ipod' : 'mac' :
             ua.include?('x11') || ua.include?('linux') ? 'linux' :
             ua.include?('win') ? 'win' : nil
        "#{br}#{" " unless br.nil? or os.nil?}#{os}"
      end
    end
  end
end
