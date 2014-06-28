require "rfpdf/version"

begin
  require('htmlentities') 
rescue LoadError
  # This gem is not required - just nice to have.
end
begin
  require 'RMagick' unless Object.const_defined?(:Magick)
rescue LoadError
  # RMagick is not available
end

module Rfpdf
  require "tcpdf.rb"
end
