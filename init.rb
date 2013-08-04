begin
  require('htmlentities') 
rescue LoadError
  # This gem is not required - just nice to have.
end
require('cgi')
require 'rfpdf'

begin
  require 'RMagick' unless Object.const_defined?(:Magick)
rescue LoadError
  # RMagick is not available
end

Mime::Type.register "application/pdf", :pdf unless defined? Mime::PDF
ActionView::Template::register_template_handler 'rfpdf', RFPDF::TemplateHandlers::Base
