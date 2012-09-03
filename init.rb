begin
  require('htmlentities') 
rescue LoadError
  # This gem is not required - just nice to have.
end
require('cgi')
require 'rfpdf'

Mime::Type.register "application/pdf", :pdf unless defined? Mime::PDF
ActionView::Template::register_template_handler 'rfpdf', RFPDF::TemplateHandlers::Base
