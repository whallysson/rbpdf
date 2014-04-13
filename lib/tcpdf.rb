# coding: ASCII-8BIT
#============================================================+
# File name   : tcpdf.rb
# Begin       : 2002-08-03
# Last Update : 2007-03-20
# Author      : Nicola Asuni
# Version     : 1.53.0.TC031
# License     : GNU LGPL (http://www.gnu.org/copyleft/lesser.html)
#  ----------------------------------------------------------------------------
#      This program is free software: you can redistribute it and/or modify
#      it under the terms of the GNU Lesser General Public License as published by
#      the Free Software Foundation, either version 2.1 of the License, or
#      (at your option) any later version.
#      
#      This program is distributed in the hope that it will be useful,
#      but WITHOUT ANY WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#      GNU Lesser General Public License for more details.
#      
#      You should have received a copy of the GNU Lesser General Public License
#      along with this program.  If not, see <http://www.gnu.org/licenses/>.
#  ----------------------------------------------------------------------------
#
# Description : This is a Ruby class for generating PDF files 
#               on-the-fly without requiring external 
#               extensions.
#
# IMPORTANT:
# This class is an extension and improvement of the Public Domain 
# FPDF class by Olivier Plathey (http://www.fpdf.org).
#
# Main changes by Nicola Asuni:
#    Ruby porting;
#    UTF-8 Unicode support;
#    code refactoring;
#    source code clean up;
#    code style and formatting;
#    source code documentation using phpDocumentor (www.phpdoc.org);
#    All ISO page formats were included;
#    image scale factor;
#    includes methods to parse and printsome XHTML code, supporting the following elements: h1, h2, h3, h4, h5, h6, b, u, i, a, img, p, br, strong, em, font, blockquote, li, ul, ol, hr, td, th, tr, table, sup, sub, small;
#    includes a method to print various barcode formats using an improved version of "Generic Barcode Render Class" by Karim Mribti (http://www.mribti.com/barcode/) (require GD library: http://www.boutell.com/gd/);
#    defines standard Header() and Footer() methods.
#
#   Ported to Ruby by Ed Moss 2007-08-06
#
#============================================================+

require 'core/rmagick'

#
# TCPDF Class.
# @package com.tecnick.tcpdf
#
 
PDF_PRODUCER = 'TCPDF via RFPDF 1.53.0.TC031 (http://tcpdf.sourceforge.net)'

module TCPDFFontDescriptor
  @@descriptors = { 'freesans' => {} }
  @@font_name = 'freesans'

  def self.font(font_name)
    @@descriptors[font_name.gsub(".rb", "")]
  end

  def self.define(font_name = 'freesans')
    @@descriptors[font_name] ||= {}
    yield @@descriptors[font_name]
  end
end

# This is a Ruby class for generating PDF files on-the-fly without requiring external extensions.<br>
# This class is an extension and improvement of the FPDF class by Olivier Plathey (http://www.fpdf.org).<br>
# This version contains some changes: [porting to Ruby, support for UTF-8 Unicode, code style and formatting, php documentation (www.phpdoc.org), ISO page formats, minor improvements, image scale factor]<br>
# TCPDF project (http://tcpdf.sourceforge.net) is based on the Public Domain FPDF class by Olivier Plathey (http://www.fpdf.org).<br>
# To add your own TTF fonts please read /fonts/README.TXT
# @name TCPDF
# @package com.tecnick.tcpdf
# @@version 1.53.0.TC031
# @author Nicola Asuni
# @link http://tcpdf.sourceforge.net
# @license http://www.gnu.org/copyleft/lesser.html LGPL
#
class TCPDF
	include ActionView::Helpers
	include RFPDF
	include Core::RFPDF
	include RFPDF::Math
	require 'unicode_data.rb'
	require 'htmlcolors.rb'
	include Unicode_data
	include Html_colors

	def logger
		Rails.logger
	end

	@@version = "1.53.0.TC031"
	@@fpdf_charwidths = {}

	cattr_accessor :k_cell_height_ratio
	@@k_cell_height_ratio = 1.25

	cattr_accessor :k_blank_image
	@@k_blank_image = ""

	cattr_accessor :k_small_ratio  
	@@k_small_ratio = 2/3.0

	cattr_accessor :k_path_cache
	@@k_path_cache = Rails.root.join('tmp').to_s

	cattr_accessor :k_path_main
	@@k_path_main = Rails.root.join('tmp').to_s
  
	cattr_accessor :k_path_url
	@@k_path_url = Rails.root.join('tmp').to_s

	@@k_path_images = ""

	cattr_accessor :decoder

	attr_accessor :barcode
	
	attr_accessor :buffer
	
	attr_accessor :diffs
	
	attr_accessor :color_flag
	
	attr_accessor :default_table_columns
	
	attr_accessor :default_font

	attr_accessor :draw_color
	
	attr_accessor :encoding
	
	attr_accessor :fill_color
	
	attr_accessor :fonts
	
	attr_accessor :font_family
	
	attr_accessor :font_files
	
	cattr_accessor :font_path
	
	attr_accessor :font_style
	
	attr_accessor :font_size_pt
	
	attr_accessor :header_width
	
	attr_accessor :header_logo
	
	attr_accessor :header_logo_width
	
	attr_accessor :header_title
	
	attr_accessor :header_string
	
	attr_accessor :images
	
	attr_accessor :img_scale
	
	attr_accessor :in_footer
	
	attr_accessor :is_unicode

	attr_accessor :lasth
	
	attr_accessor :links
	
	attr_accessor :listordered
	
	attr_accessor :listcount
	
	attr_accessor :lispacer
	
	attr_accessor :n
	
	attr_accessor :offsets
	
	attr_accessor :orientation_changes
	
	attr_accessor :page
	
	attr_accessor :pages
	
	attr_accessor :pdf_version
	
	attr_accessor :print_header
	
	attr_accessor :print_footer
	
	attr_accessor :state
	
	attr_accessor :tableborder
	
	attr_accessor :tdbegin
	
	attr_accessor :tdwidth
	
	attr_accessor :tdheight
	
	attr_accessor :tdalign
	
	attr_accessor :tdfill
	
	attr_accessor :tempfontsize
	
	attr_accessor :text_color
	
	attr_accessor :underline
	
	attr_accessor :ws

	attr_accessor :diskcache

	attr_accessor :cache_file_length
	attr_accessor :prev_cache_file_length
	
	#
	# This is the class constructor. 
	# It allows to set up the page format, the orientation and 
	# the measure unit used in all the methods (except for the font sizes).
	# @since 1.0
	# @param string :orientation page orientation. Possible values are (case insensitive):<ul><li>P or Portrait (default)</li><li>L or Landscape</li></ul>
	# @param string :unit User measure unit. Possible values are:<ul><li>pt: point</li><li>mm: millimeter (default)</li><li>cm: centimeter</li><li>in: inch</li></ul><br />A point equals 1/72 of inch, that is to say about 0.35 mm (an inch being 2.54 cm). This is a very common unit in typography; font sizes are expressed in that unit.
	# @param mixed :format The format used for pages. It can be either one of the following values (case insensitive) or a custom format in the form of a two-element array containing the width and the height (expressed in the unit given by unit).<ul><li>4A0</li><li>2A0</li><li>A0</li><li>A1</li><li>A2</li><li>A3</li><li>A4 (default)</li><li>A5</li><li>A6</li><li>A7</li><li>A8</li><li>A9</li><li>A10</li><li>B0</li><li>B1</li><li>B2</li><li>B3</li><li>B4</li><li>B5</li><li>B6</li><li>B7</li><li>B8</li><li>B9</li><li>B10</li><li>C0</li><li>C1</li><li>C2</li><li>C3</li><li>C4</li><li>C5</li><li>C6</li><li>C7</li><li>C8</li><li>C9</li><li>C10</li><li>RA0</li><li>RA1</li><li>RA2</li><li>RA3</li><li>RA4</li><li>SRA0</li><li>SRA1</li><li>SRA2</li><li>SRA3</li><li>SRA4</li><li>LETTER</li><li>LEGAL</li><li>EXECUTIVE</li><li>FOLIO</li></ul>
	# @param boolean :unicode TRUE means that the input text is unicode (default = true)
	# @param String :encoding charset encoding; default is UTF-8
	# @param boolean :diskcache if TRUE reduce the RAM memory usage by caching temporary data on filesystem (slower).
	# @access public
	#
	def initialize(orientation = 'P',  unit = 'mm', format = 'A4', unicode = true, encoding = "UTF-8", diskcache = false)
		
		# Set internal character encoding to ASCII#
		#FIXME 2007-05-25 (EJM) Level=0 - 
		# if (respond_to?("mb_internal_encoding") and mb_internal_encoding())
		# 	@internal_encoding = mb_internal_encoding();
		# 	mb_internal_encoding("ASCII");
		# }

		# set disk caching
		@diskcache = diskcache

		# set language direction
		@rtl = false
		@tmprtl = false

		@x ||= 0 
		@y ||= 0 

		# bookmark
		@outlines ||= []

		#Some checks
		dochecks();
		
		begin	  
		  @@decoder = HTMLEntities.new 
		rescue
		  @@decoder = nil
		end
		
		#Initialization of properties
  	@barcode ||= false
		if @diskcache
			@buffer ||= nil
		else
			@buffer ||= ''
		end
		@diffs ||= []
		@color_flag ||= false
  	@default_table_columns ||= 4
  	@default_font ||= "FreeSans" if unicode
  	@default_font ||= "Helvetica"
		@draw_color ||= '0 G'
  	@encoding ||= "UTF-8"
		@fill_color ||= '0 g'
		@fonts ||= {}
		@font_family ||= 'helvetica'
		@font_files ||= {}
		@font_style ||= ''
		@font_ascent ||= ''
		@font_descent ||= ''
		@font_size ||= 12
		@font_size_pt ||= 12
  	@header_width ||= 0
  	@header_logo ||= ""
  	@header_logo_width ||= 30
  	@header_title ||= ""
  	@header_string ||= ""
		@images ||= {}
  	@img_scale ||= 1
		@in_footer ||= false
		@in_thead ||= false
		@alias_nb_pages = '{nb}'
		@alias_num_page = '{pnb}'
		@is_unicode = unicode
		@lasth ||= 0
		@links ||= []
  	@listordered ||= []
  	@listcount ||= []
  	@lispacer ||= ""
		@n ||= 2
		@offsets ||= []
		@orientation_changes ||= []
		@page ||= 0
		@htmlvspace ||= 0
		@lisymbol ||= ''
		@epsmarker ||= 'x#!#EPS#!#x'
		@transfmatrix ||= []
		@transfmatrix_key ||= 0
		@booklet ||= false
		@feps ||= 0.005
		@tagvspaces ||= []
		@customlistindent ||= -1
		@opencell = true
		@embeddedfiles ||= {}
		@transfmrk ||= []
		@html_link_color_array ||= [0, 0, 255]
		@html_link_font_style ||= 'U'
		@pagedim ||= []
		@page_annots ||= []
		@pages ||= []
  	@pdf_version ||= "1.3"
	@header_margin ||= 10
	@footer_margin ||= 10
	@r_margin ||= 0
	@l_margin ||= 0
	@header_font ||= ['', '', 10]
	@footer_font ||= ['', '', 8]
  	@print_header ||= true
  	@print_footer ||= true
		@state ||= 0
  	@tdfill ||= 0
  	@tempfontsize ||= 10
		@text_color ||= '0 g'
		@underline ||= false
		@ws ||= 0
		@dpi = 72
		@pagegroups ||= {}
		@intmrk ||= []
		@cntmrk ||= []
		@footerpos ||= []
		@footerlen ||= []
		@newline ||= true
		@endlinex ||= 0
		@newpagegroup ||= []
		@linestyle_width ||= ''
		@linestyle_cap ||= '0 J'
		@linestyle_join ||= '0 j'
		@linestyle_dash ||= '[] 0 d'
		@numpages ||= 0
		@pagelen ||= []
		@numimages ||= 0
		@imagekeys ||= []
		@bufferlen ||= 0
		@numfonts ||= 0
		@fontkeys ||= []
		@font_obj_ids ||= {}
		@pageopen ||= []
		@cell_height_ratio = @@k_cell_height_ratio
		@cache_file_length = {}
		@prev_cache_file_length = {}
		@thead ||= ''
		@thead_margins ||= {}
		@cache_utf8_string_to_array = {}
		@cache_maxsize_utf8_string_to_array = 8
		@cache_size_utf8_string_to_array = 0
		
		#Standard Unicode fonts
		@core_fonts = {
		'courier'=>'Courier',
		'courierB'=>'Courier-Bold',
		'courierI'=>'Courier-Oblique',
		'courierBI'=>'Courier-BoldOblique',
		'helvetica'=>'Helvetica',
		'helveticaB'=>'Helvetica-Bold',
		'helveticaI'=>'Helvetica-Oblique',
		'helveticaBI'=>'Helvetica-BoldOblique',
		'times'=>'Times-Roman',
		'timesB'=>'Times-Bold',
		'timesI'=>'Times-Italic',
		'timesBI'=>'Times-BoldItalic',
		'symbol'=>'Symbol',
		'zapfdingbats'=>'ZapfDingbats'}

		#Scale factor
		# Set scale factor
		setPageUnit(unit)

		# set page format and orientation
		setPageFormat(format, orientation)

		#Page margins (1 cm)
		margin = 28.35/@k
		SetMargins(margin, margin)
		#Interior cell margin (1 mm)
		@c_margin = margin / 10
		#Line width (0.2 mm)
		@line_width = 0.567 / @k
		#Automatic page break
		SetAutoPageBreak(true, 2 * margin)
		#Full width display mode
		SetDisplayMode('fullwidth')
		#Compression
		SetCompression(true)
		#Set default PDF version number
		@pdf_version = "1.3"
		
		@encoding = encoding
		@b = 0
		@i = 0
		@u = 0
		@href ||= {}
		@fontlist = ["arial", "times", "courier", "helvetica", "symbol"]
		@default_monospaced_font = 'courier'
		@issetfont = false
		@fgcolor = ActiveSupport::OrderedHash.new
		@bgcolor = ActiveSupport::OrderedHash.new
#		@extgstates ||= []
		@bgtag ||= []
		@tableborder ||= 0
		@tdbegin ||= false
		@tdwidth ||=  0
		@tdheight ||= 0
		if @rtl
			@tdalign ||= "R"
		else
			@tdalign ||= "L"
		end
		SetFillColor(200, 200, 200)
		SetTextColor(0, 0, 0)

		@sign ||= false
		@signature_data ||= {}
		@sig_annot_ref ||= '***SIGANNREF*** 0 R'
		@page_obj_id ||= []
		@embedded_start_obj_id ||= 100000
		@annots_start_obj_id ||= 200000
		@annot_obj_id ||= 200000
		@curr_annot_obj_id ||= 200000
		@form_obj_id ||= []
		@apxo_start_obj_id ||= 400000
		@apxo_obj_id ||= 400000
		@annotation_fonts ||= {}
		@radiobutton_groups ||= []
		@radio_groups ||= []
		@textindent ||= 0

		# user's rights
		@ur = false;
		@ur_document = "/FullSave";
		@ur_annots = "/Create/Delete/Modify/Copy/Import/Export";
		@ur_form = "/Add/Delete/FillIn/Import/Export/SubmitStandalone/SpawnTemplate";
		@ur_signature = "/Modify";

		# set default JPEG quality
		@jpeg_quality ||= 75

		# initialize some settings
#		utf8Bidi([''], '');
		# set default font
		SetFont(@font_family, @font_style, @font_size_pt)

		@annot_obj_id = @annots_start_obj_id
		@curr_annot_obj_id = @annots_start_obj_id
		@apxo_obj_id = @apxo_start_obj_id
	end
	
	#
	# Set the units of measure for the document.
	# @param string :unit User measure unit. Possible values are:<ul><li>pt: point</li><li>mm: millimeter (default)</li><li>cm: centimeter</li><li>in: inch</li></ul><br />A point equals 1/72 of inch, that is to say about 0.35 mm (an inch being 2.54 cm). This is a very common unit in typography; font sizes are expressed in that unit.
	# @access public
	# @since 3.0.015 (2008-06-06)
	#
	def setPageUnit(unit)
		# Set scale factor
		case unit.downcase
		when 'px', 'pt'; @k=1       # points
		when 'mm'; @k = @dpi / 25.4 # millimeters
		when 'cm'; @k = @dpi / 2.54 # centimeters
		when 'in'; @k = @dpi        # inches
		# unsupported unit
		else Error("Incorrect unit: #{unit}")
		end
		unless @cur_orientation.nil?
			setPageOrientation(@cur_orientation)
		end
	end

	#
	# Set the page format
	# @param mixed :format The format used for pages. It can be either one of the following values (case insensitive) or a custom format in the form of a two-element array containing the width and the height (expressed in the unit given by unit).<ul><li>4A0</li><li>2A0</li><li>A0</li><li>A1</li><li>A2</li><li>A3</li><li>A4 (default)</li><li>A5</li><li>A6</li><li>A7</li><li>A8</li><li>A9</li><li>A10</li><li>B0</li><li>B1</li><li>B2</li><li>B3</li><li>B4</li><li>B5</li><li>B6</li><li>B7</li><li>B8</li><li>B9</li><li>B10</li><li>C0</li><li>C1</li><li>C2</li><li>C3</li><li>C4</li><li>C5</li><li>C6</li><li>C7</li><li>C8</li><li>C9</li><li>C10</li><li>RA0</li><li>RA1</li><li>RA2</li><li>RA3</li><li>RA4</li><li>SRA0</li><li>SRA1</li><li>SRA2</li><li>SRA3</li><li>SRA4</li><li>LETTER</li><li>LEGAL</li><li>EXECUTIVE</li><li>FOLIO</li></ul>
	# @param string :orientation page orientation. Possible values are (case insensitive):<ul><li>P or PORTRAIT (default)</li><li>L or LANDSCAPE</li></ul>
	# @access public
	# @since 3.0.015 (2008-06-06)
	#
	def setPageFormat(format, orientation="P")
		# Page format
		if format.is_a?(String)
			# Page formats (45 standard ISO paper formats and 4 american common formats).
			# Paper cordinates are calculated in this way: (inches * 72) where (1 inch = 2.54 cm)
			case format.upcase
			when '4A0'; format = [4767.87,6740.79]
			when '2A0'; format = [3370.39,4767.87]
			when 'A0'; format = [2383.94,3370.39]
			when 'A1'; format = [1683.78,2383.94]
			when 'A2'; format = [1190.55,1683.78]
			when 'A3'; format = [841.89,1190.55]
			when 'A4'; format = [595.28,841.89] # default
			when 'A5'; format = [419.53,595.28]
			when 'A6'; format = [297.64,419.53]
			when 'A7'; format = [209.76,297.64]
			when 'A8'; format = [147.40,209.76]
			when 'A9'; format = [104.88,147.40]
			when 'A10'; format = [73.70,104.88]
			when 'B0'; format = [2834.65,4008.19]
			when 'B1'; format = [2004.09,2834.65]
			when 'B2'; format = [1417.32,2004.09]
			when 'B3'; format = [1000.63,1417.32]
			when 'B4'; format = [708.66,1000.63]
			when 'B5'; format = [498.90,708.66]
			when 'B6'; format = [354.33,498.90]
			when 'B7'; format = [249.45,354.33]
			when 'B8'; format = [175.75,249.45]
			when 'B9'; format = [124.72,175.75]
			when 'B10'; format = [87.87,124.72]
			when 'C0'; format = [2599.37,3676.54]
			when 'C1'; format = [1836.85,2599.37]
			when 'C2'; format = [1298.27,1836.85]
			when 'C3'; format = [918.43,1298.27]
			when 'C4'; format = [649.13,918.43]
			when 'C5'; format = [459.21,649.13]
			when 'C6'; format = [323.15,459.21]
			when 'C7'; format = [229.61,323.15]
			when 'C8'; format = [161.57,229.61]
			when 'C9'; format = [113.39,161.57]
			when 'C10'; format = [79.37,113.39]
			when 'RA0'; format = [2437.80,3458.27]
			when 'RA1'; format = [1729.13,2437.80]
			when 'RA2'; format = [1218.90,1729.13]
			when 'RA3'; format = [864.57,1218.90]
			when 'RA4'; format = [609.45,864.57]
			when 'SRA0'; format = [2551.18,3628.35]
			when 'SRA1'; format = [1814.17,2551.18]
			when 'SRA2'; format = [1275.59,1814.17]
			when 'SRA3'; format = [907.09,1275.59]
			when 'SRA4'; format = [637.80,907.09]
			when 'LETTER'; format = [612.00,792.00]
			when 'LEGAL'; format = [612.00,1008.00]
			when 'EXECUTIVE'; format = [521.86,756.00]
			when 'FOLIO'; format = [612.00,936.00]
			end
			@fw_pt = format[0]
			@fh_pt = format[1]
		else
			@fw_pt = format[0] * @k
			@fh_pt = format[1] * @k
		end
		setPageOrientation(orientation)
	end

	#
	# Set page orientation.
	# @param string :orientation page orientation. Possible values are (case insensitive):<ul><li>P or PORTRAIT (default)</li><li>L or LANDSCAPE</li></ul>
	# @param boolean :autopagebreak Boolean indicating if auto-page-break mode should be on or off.
	# @param float :bottommargin bottom margin of the page.
	# @access public
	# @since 3.0.015 (2008-06-06)
	#
	def setPageOrientation(orientation, autopagebreak='', bottommargin='')
		orientation = orientation.upcase
		if (orientation == 'P') or (orientation == 'PORTRAIT')
			@cur_orientation = 'P'
			@w_pt = @fw_pt
			@h_pt = @fh_pt
		elsif (orientation == 'L') or (orientation == 'LANDSCAPE')
			@cur_orientation = 'L'
			@w_pt = @fh_pt
			@h_pt = @fw_pt
		else
			Error("Incorrect orientation: #{orientation}")
		end
		@w = @w_pt / @k
		@h = @h_pt / @k
		if empty_string(autopagebreak)
			unless @auto_page_break.nil?
				autopagebreak = @auto_page_break
			else
				autopagebreak = true
			end
		end
		if empty_string(bottommargin)
			unless @b_margin.nil?
				bottommargin = @b_margin
			else
				# default value = 2 cm
				bottommargin = 2 * 28.35 / @k
			end
		end
		SetAutoPageBreak(autopagebreak, bottommargin)
		# store page dimensions
		@pagedim[@page] = {'w' => @w_pt, 'h' => @h_pt, 'wk' => @w, 'hk' => @h, 'tm' => @t_margin, 'bm' => bottommargin, 'lm' => @l_margin, 'rm' => @r_margin, 'pb' => autopagebreak, 'or' => @cur_orientation, 'olm' => @original_l_margin, 'orm' => @original_r_margin}
	end

	#
	# Enable or disable Right-To-Left language mode
	# @param Boolean :enable if true enable Right-To-Left language mode.
	# @param Boolean :resetx if true reset the X position on direction change.
	# @access public
	# @since 2.0.000 (2008-01-03)
	#
	def SetRTL(enable, resetx=true)
		enable = enable ? true : false
		resetx = resetx and (enable != @rtl)
		@rtl = enable
		@tmprtl = false
		Ln(0) if resetx
	end
  alias_method :set_rtl, :SetRTL

	#
	# Return the RTL status
	# @return boolean
	# @access public
	# @since 4.0.012 (2008-07-24)
	#
	def GetRTL()
		return @rtl
	end
  alias_method :get_rtl, :GetRTL

	#
	# Force temporary RTL language direction
	# @param mixed :mode can be false, 'L' for LTR or 'R' for RTL
	# @access public
	# @since 2.1.000 (2008-01-09)
	#
	def SetTempRTL(mode)
		newmode = false
		case mode
		when 'ltr', 'LTR', 'L'
			newmode = 'L' if @rtl
		when 'rtl', 'RTL', 'R'
			newmode = 'R' if !@rtl
		end
		@tmprtl = newmode
	end
  alias_method :set_temp_rtl, :SetTempRTL

	#
	# Return the current temporary RTL status
	# @return boolean
	# @access public
	# @since 4.8.014 (2009-11-04)
	#
	def isRTLTextDir()
		return (@rtl or (@tmprtl == 'R'))
	end

	#
	# Set the last cell height.
	# @param float :h cell height.
	# @author Nicola Asuni
	# @access public
	# @since 1.53.0.TC034
	#
	def SetLastH(h)
		@lasth = h
	end
  alias_method :set_last_h, :SetLastH

	#
	# Get the last cell height.
	# @return last cell height
	# @access public
	# @since 4.0.017 (2008-08-05)
	#
	def GetLastH()
		return @lasth
	end
  alias_method :get_last_h, :GetLastH

	#
	# Set the adjusting factor to convert pixels to user units.
	# @param float :scale adjusting factor to convert pixels to user units.
	# @author Nicola Asuni
	# @since 1.5.2
	#
	def SetImageScale(scale)
		@img_scale = scale;
	end
  alias_method :set_image_scale, :SetImageScale
	
	#
	# Returns the adjusting factor to convert pixels to user units.
	# @return float adjusting factor to convert pixels to user units.
	# @author Nicola Asuni
	# @since 1.5.2
	#
	def GetImageScale()
		return @img_scale;
	end
  alias_method :get_image_scale, :GetImageScale
  
	#
	# Returns the page width in units.
	# @return int page width.
	# @author Nicola Asuni
	# @since 1.5.2
	#
	def GetPageWidth()
		return @w;
	end
  alias_method :get_page_width, :GetPageWidth
  
	#
	# Returns the page height in units.
	# @return int page height.
	# @author Nicola Asuni
	# @since 1.5.2
	#
	def GetPageHeight()
		return @h;
	end
  alias_method :get_page_height, :GetPageHeight
  
	#
	# Returns the page break margin.
	# @param int :pagenum page number (empty = current page)
	# @return int page break margin.
	# @author Nicola Asuni
	# @access public
	# @since 1.5.2
	# @see getPageDimensions()
	#
	def GetBreakMargin(pagenum='')
		if pagenum.empty?
			return @b_margin
		end
		return @pagedim[pagenum]['bm']
	end
  alias_method :get_break_margin, :GetBreakMargin

	#
	# Returns the scale factor (number of points in user unit).
	# @return int scale factor.
	# @author Nicola Asuni
	# @since 1.5.2
	#
	def GetScaleFactor()
		return @k;
	end
  alias_method :get_scale_factor, :GetScaleFactor

	#
	# Defines the left, top and right margins.
	# @param float :left Left margin.
	# @param float :top Top margin.
	# @param float :right Right margin. Default value is the left one.
	# @param boolean $keepmargins if true overwrites the default page margins
	# @access public
	# @since 1.0
	# @see SetLeftMargin(), SetTopMargin(), SetRightMargin(), SetAutoPageBreak()
	#
	def SetMargins(left, top, right=-1, keepmargins=false)
		#Set left, top and right margins
		@l_margin = left
		@t_margin = top
		if (right == -1)
			right = left
		end
		@r_margin = right
		if keepmargins
			# overwrite original values
			@original_l_margin = @l_margin
			@original_r_margin = @r_margin
		end
	end
  alias_method :set_margins, :SetMargins

	#
	# Defines the left margin. The method can be called before creating the first page. If the current abscissa gets out of page, it is brought back to the margin.
	# @param float :margin The margin.
	# @since 1.4
	# @see SetTopMargin(), SetRightMargin(), SetAutoPageBreak(), SetMargins()
	#
	def SetLeftMargin(margin)
		#Set left margin
		@l_margin = margin
		if (@page > 0) and (@x < margin)
			@x = margin
		end
	end
  alias_method :set_left_margin, :SetLeftMargin

	#
	# Defines the top margin. The method can be called before creating the first page.
	# @param float :margin The margin.
	# @since 1.5
	# @see SetLeftMargin(), SetRightMargin(), SetAutoPageBreak(), SetMargins()
	#
	def SetTopMargin(margin)
		#Set top margin
		@t_margin = margin
		if (@page > 0) and (@y < margin)
			@y = margin
		end
	end
  alias_method :set_top_margin, :SetTopMargin

	#
	# Defines the right margin. The method can be called before creating the first page.
	# @param float :margin The margin.
	# @since 1.5
	# @see SetLeftMargin(), SetTopMargin(), SetAutoPageBreak(), SetMargins()
	#
	def SetRightMargin(margin)
		@r_margin = margin
		if (@page > 0) and (@x > (@w - margin))
			@x = @w - margin
		end
	end
  alias_method :set_right_margin, :SetRightMargin

	#
	# Set the internal Cell padding.
	# @param float :pad internal padding.
	# @since 2.1.000 (2008-01-09)
	# @see Cell(), SetLeftMargin(), SetTopMargin(), SetAutoPageBreak(), SetMargins()
	#
	def SetCellPadding(pad)
		@c_margin = pad
	end
  alias_method :set_cell_padding, :SetCellPadding

	#
	# Enables or disables the automatic page breaking mode. When enabling, the second parameter is the distance from the bottom of the page that defines the triggering limit. By default, the mode is on and the margin is 2 cm.
	# @param boolean :auto Boolean indicating if mode should be on or off.
	# @param float :margin Distance from the bottom of the page.
	# @since 1.0
	# @see Cell(), MultiCell(), AcceptPageBreak()
	#
	def SetAutoPageBreak(auto, margin=0)
		#Set auto page break mode and triggering margin
		@auto_page_break = auto
		@b_margin = margin
		@page_break_trigger = @h - margin
	end
  alias_method :set_auto_page_break, :SetAutoPageBreak

	#
	# Defines the way the document is to be displayed by the viewer.
	# @param mixed :zoom The zoom to use. It can be one of the following string values or a number indicating the zooming factor to use. <ul><li>fullpage: displays the entire page on screen </li><li>fullwidth: uses maximum width of window</li><li>real: uses real size (equivalent to 100% zoom)</li><li>default: uses viewer default mode</li></ul>
	# @param string :layout The page layout. Possible values are:<ul><li>SinglePage Display one page at a time</li><li>OneColumn Display the pages in one column</li><li>TwoColumnLeft Display the pages in two columns, with odd-numbered pages on the left</li><li>TwoColumnRight Display the pages in two columns, with odd-numbered pages on the right</li><li>TwoPageLeft (PDF 1.5) Display the pages two at a time, with odd-numbered pages on the left</li><li>TwoPageRight (PDF 1.5) Display the pages two at a time, with odd-numbered pages on the right</li></ul>
	# @param string :mode A name object specifying how the document should be displayed when opened:<ul><li>UseNone Neither document outline nor thumbnail images visible</li><li>UseOutlines Document outline visible</li><li>UseThumbs Thumbnail images visible</li><li>FullScreen Full-screen mode, with no menu bar, window controls, or any other window visible</li><li>UseOC (PDF 1.5) Optional content group panel visible</li><li>UseAttachments (PDF 1.6) Attachments panel visible</li></ul>
	# @access public
	# @since 1.2
	#
	def SetDisplayMode(zoom, layout='SinglePage', mode='UseNone')
		#Set display mode in viewer
		if (zoom == 'fullpage' or zoom == 'fullwidth' or zoom == 'real' or zoom == 'default' or !zoom.is_a?(String))
			@zoom_mode = zoom
		else
			Error('Incorrect zoom display mode: ' + zoom)
		end

		case layout
		when 'default', 'single', 'SinglePage'
			@layout_mode = 'SinglePage'
		when 'continuous', 'OneColumn'
			@layout_mode = 'OneColumn'
		when 'two', 'TwoColumnLeft'
			@layout_mode = 'TwoColumnLeft'
		when 'TwoColumnRight'
			@layout_mode = 'TwoColumnRight'
		when 'TwoPageLeft'
			@layout_mode = 'TwoPageLeft'
		when 'TwoPageRight'
			@layout_mode = 'TwoPageRight'
		else
			@layout_mode = 'SinglePage'
		end

		case mode
		when 'UseNone'
			@page_mode = 'UseNone'
		when 'UseOutlines'
			@page_mode = 'UseOutlines'
		when 'UseThumbs'
			@page_mode = 'UseThumbs'
		when 'FullScreen'
			@page_mode = 'FullScreen'
		when 'UseOC'
			@page_mode = 'UseOC'
		when ''
			@page_mode = 'UseAttachments'
		else
			@page_mode = 'UseNone'
		end
	end
  alias_method :set_display_mode, :SetDisplayMode

	#
	# Activates or deactivates page compression. When activated, the internal representation of each page is compressed, which leads to a compression ratio of about 2 for the resulting document. Compression is on by default.
	# Note: the Zlib extension is required for this feature. If not present, compression will be turned off.
	# @param boolean :compress Boolean indicating if compression must be enabled.
	# @since 1.4
	#
	def SetCompression(compress)
		#Set page compression
		if (respond_to?('gzcompress'))
			@compress = compress
		else
			@compress = false
		end
	end
  alias_method :set_compression, :SetCompression

	#
	# Defines the title of the document.
	# @param string :title The title.
	# @since 1.2
	# @see SetAuthor(), SetCreator(), SetKeywords(), SetSubject()
	#
	def SetTitle(title)
		#Title of document
		@title = title
	end
  alias_method :set_title, :SetTitle

	#
	# Defines the subject of the document.
	# @param string :subject The subject.
	# @since 1.2
	# @see SetAuthor(), SetCreator(), SetKeywords(), SetTitle()
	#
	def SetSubject(subject)
		#Subject of document
		@subject = subject
	end
  alias_method :set_subject, :SetSubject

	#
	# Defines the author of the document.
	# @param string :author The name of the author.
	# @since 1.2
	# @see SetCreator(), SetKeywords(), SetSubject(), SetTitle()
	#
	def SetAuthor(author)
		#Author of document
		@author = author
	end
  alias_method :set_author, :SetAuthor

	#
	# Associates keywords with the document, generally in the form 'keyword1 keyword2 ...'.
	# @param string :keywords The list of keywords.
	# @since 1.2
	# @see SetAuthor(), SetCreator(), SetSubject(), SetTitle()
	#
	def SetKeywords(keywords)
		#Keywords of document
		@keywords = keywords
	end
  alias_method :set_keywords, :SetKeywords

	#
	# Defines the creator of the document. This is typically the name of the application that generates the PDF.
	# @param string :creator The name of the creator.
	# @since 1.2
	# @see SetAuthor(), SetKeywords(), SetSubject(), SetTitle()
	#
	def SetCreator(creator)
		#Creator of document
		@creator = creator
	end
  alias_method :set_creator, :SetCreator

	#
	# Defines an alias for the total number of pages.
	# It will be substituted as the document is closed.
	# @param string :alias The alias.
	# @access public
	# @since 1.4
	# @see GetAliasNbPages(), PageNo(), Footer()
	#
	def AliasNbPages(alias_nb ='{nb}')
		@alias_nb_pages = alias_nb
	end
  alias_method :alias_nb_pages, :AliasNbPages

	#
	# Returns the string alias used for the total number of pages.
	# If the current font is unicode type, the returned string is surrounded by additional curly braces.
	# @return string
	# @access public
	# @since 4.0.018 (2008-08-08)
	# @see AliasNbPages(), PageNo(), Footer()
	#
	def GetAliasNbPages()
		if (@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont0')
			return '{' + @alias_nb_pages + '}'
		end
		return @alias_nb_pages
	end

	#
	# Defines an alias for the page number.
	# It will be substituted as the document is closed.
	# @param string :alias The alias.
	# @access public
	# @since 4.5.000 (2009-01-02)
	# @see getAliasNbPages(), PageNo(), Footer()
	#
	def AliasNumPage(alias_num='{pnb}')
		# Define an alias for total number of pages
		@alias_num_page = alias_num
	end
                
	#
	# Returns the string alias used for the page number.
	# If the current font is unicode type, the returned string is surrounded by additional curly braces.
	# @return string
	# @access public
	# @since 4.5.000 (2009-01-02)
	# @see AliasNbPages(), PageNo(), Footer()
	#
	def GetAliasNumPage()
			if (@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont0')
			return '{' + @alias_num_page + '}'
		end
		return @alias_num_page
	end

	#
	# Return the alias of the current page group
	# If the current font is unicode type, the returned string is surrounded by additional curly braces.
	# (will be replaced by the total number of pages in this group).
	# @return alias of the current page group
	# @access public
	# @since 3.0.000 (2008-03-27)
	#
	def GetPageGroupAlias()
		if (@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont1')
			return '{' + @currpagegroup + '}'
		end
		return @currpagegroup
	end

	#
	# Return the alias for the page number on the current page group
	# If the current font is unicode type, the returned string is surrounded by additional curly braces.
	# (will be replaced by the total number of pages in this group).
	# @return alias of the current page group
	# @access public
	# @since 4.5.000 (2009-01-02)
	#
	def GetPageNumGroupAlias()
		if (@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont0')
			return '{' + @currpagegroup.gsub('{nb', '{pnb') +'}'
		end
		return @currpagegroup.gsub('{nb', '{pnb')
	end

	#
	# This method is automatically called in case of fatal error; it simply outputs the message and halts the execution. An inherited class may override it to customize the error handling but should always halt the script, or the resulting document would probably be invalid.
	# 2004-06-11 :: Nicola Asuni : changed bold tag with strong
	# @param string :msg The error message
	# @access public
	# @since 1.0
	#
	def Error(msg)
		destroy(true)
		#Fatal error
		raise ("TCPDF error: #{msg}")
	end
  alias_method :error, :Error

	#
	# This method begins the generation of the PDF document. It is not necessary to call it explicitly because AddPage() does it automatically.
	# Note: no page is created by this method
	# @since 1.0
	# @see AddPage(), Close()
	#
	def Open()
		#Begin document
		@state = 1
	end
  # alias_method :open, :Open

	#
	# Terminates the PDF document. It is not necessary to call this method explicitly because Output() does it automatically. If the document contains no page, AddPage() is called to prevent from getting an invalid document.
	# @since 1.0
	# @see Open(), Output()
	#
	def Close()
		#Terminate document
		if (@state==3)
			return;
		end
		if (@page==0)
			AddPage();
		end
		# close page
		endPage()
		# close document
		enddoc();
	end
  # alias_method :close, :Close

	#
	# Move pointer at the specified document page and update page dimensions.
	# @param int :pnum page number
	# @param boolean :resetmargins if true reset left, right, top margins and Y position.
	# @access public
	# @since 2.1.000 (2008-01-07)
	# @see GetPage(), LastPage(), GetNumPages()
	#
	def SetPage(pnum, resetmargins=false)
		if pnum == @page
			return
		end
		if (pnum > 0) and (pnum <= @numpages)
			@state = 2
			# save current graphic settings
			# gvars = getGraphicVars()
			oldpage = @page
			@page = pnum
			@w_pt = @pagedim[@page]['w']
			@h_pt = @pagedim[@page]['h']
			@w = @w_pt / @k
			@h = @h_pt / @k
			@t_margin = @pagedim[@page]['tm']
			@b_margin = @pagedim[@page]['bm']
			@original_l_margin = @pagedim[@page]['olm']
			@original_r_margin = @pagedim[@page]['orm']
			@auto_page_break = @pagedim[@page]['pb']
			@cur_orientation = @pagedim[@page]['or']
			SetAutoPageBreak(@auto_page_break, @b_margin)
			# restore graphic settings
			# setGraphicVars(gvars)
			if resetmargins
				@l_margin = @pagedim[@page]['olm']
				@r_margin = @pagedim[@page]['orm']
				SetY(@t_margin)
			else
				# account for booklet mode
				if @pagedim[@page]['olm'] != @pagedim[oldpage]['olm']
					deltam = @pagedim[@page]['olm'] - @pagedim[@page]['orm']
					@l_margin += deltam
					@r_margin -= deltam
				end
			end
		else
			Error('Wrong page number on setPage() function.')
		end
	end

	#
	# Reset pointer to the last document page.
	# @param boolean :resetmargins if true reset left, right, top margins and Y position.
	# @access public
	# @since 2.0.000 (2008-01-04)
	# @see SetPage(), GetPage(), GetNumPages()
	#
	def LastPage(resetmargins=false)
		SetPage(GetNumPages(), resetmargins)
	end

	#
	# Get current document page number.
	# @return int page number
	# @access public
	# @since 2.1.000 (2008-01-07)
	# @see SetPage(), LastPage(), GetNumPages()
	#
	def GetPage()
		return @page
	end

	#
	# Get the total number of insered pages.
	# @return int number of pages
	# @access public
	# @since 2.1.000 (2008-01-07)
	# @see SetPage(), GetPage(), LastPage()
	#
	def GetNumPages()
		return @numpages
	end

	#
	# Adds a new page to the document. If a page is already present, the Footer() method is called first to output the footer (if enabled). Then the page is added, the current position set to the top-left corner according to the left and top margins (or top-right if in RTL mode), and Header() is called to display the header (if enabled).
	# The origin of the coordinate system is at the top-left corner (or top-right for RTL) and increasing ordinates go downwards.
	# @param string :orientation page orientation. Possible values are (case insensitive):<ul><li>P or PORTRAIT (default)</li><li>L or LANDSCAPE</li></ul>
	# @param mixed :format The format used for pages. It can be either one of the following values (case insensitive) or a custom format in the form of a two-element array containing the width and the height (expressed in the unit given by unit).<ul><li>4A0</li><li>2A0</li><li>A0</li><li>A1</li><li>A2</li><li>A3</li><li>A4 (default)</li><li>A5</li><li>A6</li><li>A7</li><li>A8</li><li>A9</li><li>A10</li><li>B0</li><li>B1</li><li>B2</li><li>B3</li><li>B4</li><li>B5</li><li>B6</li><li>B7</li><li>B8</li><li>B9</li><li>B10</li><li>C0</li><li>C1</li><li>C2</li><li>C3</li><li>C4</li><li>C5</li><li>C6</li><li>C7</li><li>C8</li><li>C9</li><li>C10</li><li>RA0</li><li>RA1</li><li>RA2</li><li>RA3</li><li>RA4</li><li>SRA0</li><li>SRA1</li><li>SRA2</li><li>SRA3</li><li>SRA4</li><li>LETTER</li><li>LEGAL</li><li>EXECUTIVE</li><li>FOLIO</li></ul>
	# @param boolean :keepmargins if true overwrites the default page margins with the current margin
	# @access public
	# @since 1.0
	# @see startPage(), endPage()
	#
	def AddPage(orientation='', format='', keepmargins=false)
		if @original_l_margin.nil? or keepmargins
			@original_l_margin = @l_margin
		end
		if @original_r_margin.nil? or keepmargins
			@original_r_margin = @r_margin
		end
		# terminate previous page
		endPage()
		# start new page
		startPage(orientation, format)
	end
	  alias_method :add_page, :AddPage

	#
	# Terminate the current page
	# @access protected
	# @since 4.2.010 (2008-11-14)
	# @see startPage(), AddPage()
	#
	def endPage()
		# check if page is already closed
		if (@page == 0) or (@numpages > @page) or !@pageopen[@page]
			return
		end
		@in_footer = true
		# print page footer
		setFooter()
		# close page
		endpage()
		# mark page as closed
		@pageopen[@page] = false
		@in_footer = false
	end
	
	#
	# Starts a new page to the document. The page must be closed using the endPage() function.
	# The origin of the coordinate system is at the top-left corner and increasing ordinates go downwards.
	# @param string :orientation page orientation. Possible values are (case insensitive):<ul><li>P or PORTRAIT (default)</li><li>L or LANDSCAPE</li></ul>
	# @param mixed :format The format used for pages. It can be either one of the following values (case insensitive) or a custom format in the form of a two-element array containing the width and the height (expressed in the unit given by unit).<ul><li>4A0</li><li>2A0</li><li>A0</li><li>A1</li><li>A2</li><li>A3</li><li>A4 (default)</li><li>A5</li><li>A6</li><li>A7</li><li>A8</li><li>A9</li><li>A10</li><li>B0</li><li>B1</li><li>B2</li><li>B3</li><li>B4</li><li>B5</li><li>B6</li><li>B7</li><li>B8</li><li>B9</li><li>B10</li><li>C0</li><li>C1</li><li>C2</li><li>C3</li><li>C4</li><li>C5</li><li>C6</li><li>C7</li><li>C8</li><li>C9</li><li>C10</li><li>RA0</li><li>RA1</li><li>RA2</li><li>RA3</li><li>RA4</li><li>SRA0</li><li>SRA1</li><li>SRA2</li><li>SRA3</li><li>SRA4</li><li>LETTER</li><li>LEGAL</li><li>EXECUTIVE</li><li>FOLIO</li></ul>
	# @access protected
	# @since 4.2.010 (2008-11-14)
	# @see endPage(), AddPage()
	#
	def startPage(orientation='', format='')
		if @numpages > @page
			# this page has been already added
			SetPage(@page + 1)
			SetY(@t_margin)
			return
		end
		# start a new page
		if @state == 0
			Open()
		end
		@numpages += 1
		swapMargins(@booklet)
		# save current graphic settings
		gvars = getGraphicVars()
		# start new page
		beginpage(orientation, format)
		# mark page as open
		@pageopen[@page] = true
		# restore graphic settings
		setGraphicVars(gvars)
		# mark this point
		SetPageMark()
		# print page header
		setHeader()
		# restore graphic settings
		setGraphicVars(gvars)
		# mark this point
		SetPageMark()
		# print table header (if any)
		setTableHeader()
	end

	#
	# Set start-writing mark on current page for multicell borders and fills.
	# This function must be called after calling Image() function for a background image.
	# Background images must be always inserted before calling Multicell() or WriteHTMLCell() or WriteHTML() functions.
	# @access public
	# @since 4.0.016 (2008-07-30)
	#
	def SetPageMark()
		@intmrk[@page] = @pagelen[@page]
		setContentMark()
	end

	#
	# Set start-writing mark on selected page.
	# @param int :page page number (default is the current page)
	# @access protected
	# @since 4.6.021 (2009-07-20)
	#
	def setContentMark(page=0)
		if page <= 0
			page = @page
		end
		if @footerlen[page]
			@cntmrk[page] = @pagelen[page] - @footerlen[page]
		else
			@cntmrk[page] = @pagelen[page]
		end
	end

	#
	# Rotate object.
	# @param float :angle angle in degrees for counter-clockwise rotation
	# @param int :x abscissa of the rotation center. Default is current x position
	# @param int :y ordinate of the rotation center. Default is current y position
	# @access public
	# @since 2.1.000 (2008-01-07)
	# @see StartTransform(), StopTransform()
	#
	def Rotate(angle, x="", y="")
		if (x == '')
			x = @x
		end
  	
		if (y == '')
			y = @y
		end
  	
		if @rtl
			x = @w - x
			angle = -@angle
		end

		y = (@h - y) * @k
		x *= @k

		# calculate elements of transformation matrix
		tm = []
		tm[0] = ::Math::cos(deg2rad(angle))
		tm[1] = ::Math::sin(deg2rad(angle))
		tm[2] = -tm[1]
		tm[3] = tm[0]
		tm[4] = x + tm[1] * y - tm[0] * x
		tm[5] = y - tm[0] * y - tm[1] * x

		# generate the transformation matrix
		Transform(tm)
	end
    alias_method :rotate, :Rotate
  
	#
	# Starts a 2D tranformation saving current graphic state.
	# This function must be called before scaling, mirroring, translation, rotation and skewing.
	# Use StartTransform() before, and StopTransform() after the transformations to restore the normal behavior.
	# @access public
	# @since 2.1.000 (2008-01-07)
	# @see StartTransform(), StopTransform()
	#
	def StartTransform
		out('q');
		@transfmrk[@page] = @pagelen[@page]
		@transfmatrix_key += 1
		@transfmatrix[@transfmatrix_key] = []
	end
	  alias_method :start_transform, :StartTransform
	
	#
	# Stops a 2D tranformation restoring previous graphic state.
	# This function must be called after scaling, mirroring, translation, rotation and skewing.
	# Use StartTransform() before, and StopTransform() after the transformations to restore the normal behavior.
	# @access public
	# @since 2.1.000 (2008-01-07)
	# @see StartTransform(), StopTransform()
	#
	def StopTransform
		out('Q');
		if @transfmatrix[@transfmatrix_key]
			@transfmatrix[@transfmatrix_key].pop
			@transfmatrix_key -= 1
		end
		@transfmrk[@page] = nil
	end
	  alias_method :stop_transform, :StopTransform
	
	#
	# Apply graphic transformations.
	# @access protected
	# @since 2.1.000 (2008-01-07)
	# @see StartTransform(), StopTransform()
	#
	def Transform(tm)
		out(sprintf('%.3f %.3f %.3f %.3f %.3f %.3f cm', tm[0], tm[1], tm[2], tm[3], tm[4], tm[5]))
		# add tranformation matrix
		@transfmatrix[@transfmatrix_key].push 'a' => tm[0], 'b' => tm[1], 'c' => tm[2], 'd' => tm[3], 'e' => tm[4], 'f' => tm[5]
		# update tranformation mark
		if !@transfmrk[@page].nil?
			@transfmrk[@page] = @pagelen[@page]
		end
	end
	  alias_method :transform, :Transform
		
	#
 	# Set header data.
	# @param string :ln header image logo
	# @param string :lw header image logo width in mm
	# @param string :ht string to print as title on document header
	# @param string :hs string to print on document header
	#
	def SetHeaderData(ln="", lw=0, ht="", hs="")
		@header_logo = ln || ""
		@header_logo_width = lw || 0
		@header_title = ht || ""
		@header_string = hs || ""
	end
	  alias_method :set_header_data, :SetHeaderData
	
	#
	# Returns header data:
	# <ul><li>:ret['logo'] = logo image</li><li>:ret['logo_width'] = width of the image logo in user units</li><li>:ret['title'] = header title</li><li>:ret['string'] = header description string</li></ul>
	# @return hash
	# @access public
	# @since 4.0.012 (2008-07-24)
	#
	def GetHeaderData()
		ret = {}
		ret['logo'] = @header_logo
		ret['logo_width'] = @header_logo_width
		ret['title'] = @header_title
		ret['string'] = @header_string
		return ret
	end
	  alias_method :get_header_data, :GetHeaderData

	#
 	# Set header margin.
	# (minimum distance between header and top page margin)
	# @param int :hm distance in user units
	# @access public
	#
	def SetHeaderMargin(hm=10)
		@header_margin = hm;
	end
	  alias_method :set_header_margin, :SetHeaderMargin
	
	#
	# Returns header margin in user units.
	# @return float
	# @since 4.0.012 (2008-07-24)
	# @access public
	#
	def GetHeaderMargin()
		return @header_margin
	end
	  alias_method :get_header_margin, :GetHeaderMargin

	#
 	# Set footer margin.
	# (minimum distance between footer and bottom page margin)
	# @param int :fm distance in millimeters
	# @access public
	#
	def SetFooterMargin(fm=10)
		@footer_margin = fm;
	end
	  alias_method :set_footer_margin, :SetFooterMargin
	
	#
	# Returns footer margin in user units.
	# @return float
	# @since 4.0.012 (2008-07-24)
	# @access public
	#
	def GetFooterMargin()
		return @footer_margin
	end
	  alias_method :get_footer_margin, :GetFooterMargin

	#
 	# Set a flag to print page header.
	# @param boolean :val set to true to print the page header (default), false otherwise. 
	#
	def SetPrintHeader(val=true)
		@print_header = val;
	end
	  alias_method :set_print_header, :SetPrintHeader
	
	#
 	# Set a flag to print page footer.
	# @param boolean :value set to true to print the page footer (default), false otherwise. 
	#
	def SetPrintFooter(val=true)
		@print_footer = val;
	end
	  alias_method :set_print_footer, :SetPrintFooter
	
	#
	# Return the right-bottom (or left-bottom for RTL) corner X coordinate of last inserted image
	# @return float 
	# @access public
	#
	def GetImageRBX()
		return @img_rb_x
	end

	#
	# Return the right-bottom (or left-bottom for RTL) corner Y coordinate of last inserted image
	# @return float 
	# @access public
	#
	def GetImageRBY()
		return @img_rb_y
	end

	#
 	# This method is used to render the page header.
 	# It is automatically called by AddPage() and could be overwritten in your own inherited class.
	# @access public
	#
	def Header()
		ormargins = GetOriginalMargins()
		headerfont = GetHeaderFont()
		headerdata = GetHeaderData()
		if headerdata['logo'] and (headerdata['logo'] != @@k_blank_image)
			result_img = Image(@@k_path_images + headerdata['logo'], GetX(), GetHeaderMargin(), headerdata['logo_width'])
			if result_img != false
				imgy = GetImageRBY()
			else
				Write(@lasth, File.basename(headerdata['logo']), '', false, '', false, 0, false)
				imgy = GetY()
			end
		else
			imgy = GetY()
		end
		cell_height = ((GetCellHeightRatio() * headerfont[2]) / GetScaleFactor()).round(2)

		# set starting margin for text data cell
		if GetRTL()
			header_x = ormargins['right'] + (headerdata['logo_width'] * 1.1)
		else
			header_x = ormargins['left'] + (headerdata['logo_width'] * 1.1)
		end
		SetTextColor(0, 0, 0)
		# header title
		SetFont(headerfont[0], 'B', headerfont[2] + 1)
		SetX(header_x)
		Cell(0, cell_height, headerdata['title'], 0, 1, '', 0, '', 0)
		# header string
		SetFont(headerfont[0], headerfont[1], headerfont[2])
		SetX(header_x)
		MultiCell(0, cell_height, headerdata['string'], 0, '', 0, 1, '', '', true, 0, false)

		# print an ending header line
		SetLineStyle({'width' => 0.85 / GetScaleFactor(), 'cap' => 'butt', 'join' => 'miter', 'dash' => 0, 'color' => [0, 0, 0]})
		SetY((2.835 / GetScaleFactor()) + (imgy > GetY() ? imgy : GetY()))

		if GetRTL()
			SetX(ormargins['right'])
		else
			SetX(ormargins['left'])
		end
		Cell(0, 0, '', 'T', 0, 'C')
	end
	  alias_method :header, :Header
	
	#
 	# This method is used to render the page footer. 
 	# It is automatically called by AddPage() and could be overwritten in your own inherited class.
	#
	def Footer()
		cur_y = GetY()
		ormargins = GetOriginalMargins()
		SetTextColor(0, 0, 0)
		# set style for cell border
		line_width = 0.85 / GetScaleFactor()
		SetLineStyle({'width' => line_width, 'cap' => 'butt', 'join' => 'miter', 'dash' => 0, 'color' => [0, 0, 0]})
		# print document barcode
		#barcode = GetBarcode()
		#if !barcode.empty?
		#	Ln(line_width)
		#	barcode_width = ((GetPageWidth() - ormargins['left'] - ormargins['right']) / 3).round
		#	write1DBarcode(barcode, 'C128B', GetX(), cur_y + line_width, barcode_width, ((GetFooterMargin() / 3) - line_width), 0.3, '', '')
		#end
		w_page = (@l.nil? or @l['w_page'].nil?) ? '' : @l['w_page']
		if @pagegroups.empty?
			pagenumtxt = w_page + ' ' + GetAliasNumPage() + ' / ' + GetAliasNbPages()
		else
			pagenumtxt = w_page + ' ' + GetPageNumGroupAlias() + ' / ' + GetPageGroupAlias()
		end
		SetY(cur_y)
		# Print page number
		if GetRTL()
			SetX(ormargins['right'])
			Cell(0, 0, pagenumtxt, 'T', 0, 'L')
		else
			SetX(ormargins['left'])
			Cell(0, 0, pagenumtxt, 'T', 0, 'R')
		end
	end
	  alias_method :footer, :Footer
	
	#
	# This method is used to render the page header. 
	# @access protected
	# @since 4.0.012 (2008-07-24)
	#
	def setHeader()
		if @print_header
			temp_thead = @thead
			temp_theadMargins = @thead_margins
			lasth = @lasth
			out('q')
			@r_margin = @original_r_margin
			@l_margin = @original_l_margin
			@c_margin = 0
			# set current position
			if @rtl
				SetXY(@original_r_margin, @header_margin)
			else
				SetXY(@original_l_margin, @header_margin)
			end
			SetFont(@header_font[0], @header_font[1], @header_font[2])
			Header()
			# restore position
			if @rtl
				SetXY(@original_r_margin, @t_margin)
			else
				SetXY(@original_l_margin, @t_margin)
			end
			out('Q')
			@lasth = lasth
			@thead = temp_thead
			@thead_margins = temp_theadMargins
			@newline = false
		end
	end

	#
	# This method is used to render the page footer. 
	# @access protected
	# @since 4.0.012 (2008-07-24)
	#
	def setFooter()
		# Page footer
		# save current graphic settings
		gvars = getGraphicVars()
		# mark this point
		@footerpos[@page] = @pagelen[@page]
		out("\n")
		if @print_footer
			temp_thead = @thead
			temp_theadMargins = @thead_margins
			lasth = @lasth
			out('q')
			@r_margin = @original_r_margin
			@l_margin = @original_l_margin
			@c_margin = 0
			# set current position
			footer_y = @h - @footer_margin
			if @rtl
				SetXY(@original_r_margin, footer_y)
			else
				SetXY(@original_l_margin, footer_y)
			end
			SetFont(@footer_font[0], @footer_font[1] , @footer_font[2])
			Footer()
			# restore position
			if @rtl
				SetXY(@original_r_margin, @t_margin)
			else
				SetXY(@original_l_margin, @t_margin)
			end
			out('Q')
			@lasth = lasth
			@thead = temp_thead
			@thead_margins = temp_theadMargins
		end
		# restore graphic settings
		setGraphicVars(gvars)
		# calculate footer length
		@footerlen[@page] = @pagelen[@page] - @footerpos[@page] + 1
	end

	#
	# This method is used to render the table header on new page (if any). 
	# @access protected
	# @since 4.5.030 (2009-03-25)
	#
	def setTableHeader()
		if !@thead_margins['top'].nil?
			# restore the original top-margin
			@t_margin = @thead_margins['top']
			@pagedim[@page]['tm'] = @t_margin
			@y = @t_margin
		end
		if !empty_string(@thead) and !@in_thead
			# set margins
			prev_lMargin = @l_margin
			prev_rMargin = @r_margin
			@l_margin = @pagedim[@page]['olm']
			@r_margin = @pagedim[@page]['orm']
			@c_margin = @thead_margins['cmargin']
			# print table header
			writeHTML(@thead, false, false, false, false, '')
			# set new top margin to skip the table headers
			if @thead_margins['top'].nil?
				@thead_margins['top'] = @t_margin
			end
			@t_margin = @y
			@pagedim[@page]['tm'] = @t_margin
			@lasth = 0
			@l_margin = prev_lMargin
			@r_margin = prev_rMargin
		end
	end

	#
	# Returns the current page number.
	# @return int page number
	# @since 1.0
	# @see alias_nb_pages()
	#
	def PageNo()
		#Get current page number
		return @page;
	end
  alias_method :page_no, :PageNo

	#
	# Defines the color used for all drawing operations (lines, rectangles and cell borders). 
	# It can be expressed in RGB components or gray scale. 
	# The method can be called before the first page is created and the value is retained from page to page.
	# @param array or ordered hash :color array(or ordered hash) of colors
	# @since 3.1.000 (2008-6-11)
	# @see SetDrawColor()
	#
	def SetDrawColorArray(color)
		if !color.nil?
			color = color.values if color.is_a? Hash
			r = !color[0].nil? ? color[0] : -1
			g = !color[1].nil? ? color[1] : -1
			b = !color[2].nil? ? color[2] : -1
			k = !color[3].nil? ? color[3] : -1
			if r >= 0
				SetDrawColor(r, g, b, k)
			end
		end
	end

	#
	# Defines the color used for all drawing operations (lines, rectangles and cell borders). It can be expressed in RGB components or gray scale. The method can be called before the first page is created and the value is retained from page to page.
	# @param int :col1 Gray level for single color, or Red color for RGB, or Cyan color for CMYK. Value between 0 and 255
	# @param int :col2 Green color for RGB, or Magenta color for CMYK. Value between 0 and 255
	# @param int :col3 Blue color for RGB, or Yellow color for CMYK. Value between 0 and 255
	# @param int :col4 Key (Black) color for CMYK. Value between 0 and 255
	# @since 1.3
	# @see SetFillColor(), SetTextColor(), Line(), Rect(), Cell(), MultiCell()
	#
	def SetDrawColor(col1=0, col2=-1, col3=-1, col4=-1)
		# set default values
		unless col1.is_a? Integer
			col1 = 0
		end
		unless col2.is_a? Integer
			col2 = 0
		end
		unless col3.is_a? Integer
			col3 = 0
		end
		unless col4.is_a? Integer
			col4 = 0
		end
		#Set color for all stroking operations
		if (col2 == -1) and (col3 == -1) and (col4 == -1)
			# Grey scale
			@draw_color = sprintf('%.3f G', col1 / 255)
		elsif col4 == -1
			# RGB
			@draw_color = sprintf('%.3f %.3f %.3f RG', col1 / 255, col2 / 255, col3 / 255)
		else
			# CMYK
			@draw_color = sprintf('%.3f %.3f %.3f %.3f K', col1 / 100, col2 / 100, col3 / 100, col4 / 100)
		end
		if (@page>0)
			out(@draw_color);
		end
	end
  alias_method :set_draw_color, :SetDrawColor

	#
	# Defines the color used for all filling operations (filled rectangles and cell backgrounds). 
	# It can be expressed in RGB components or gray scale. 
	# The method can be called before the first page is created and the value is retained from page to page.
	# @param array :color array of colors
	# @access public
	# @since 3.1.000 (2008-6-11)
	# @see SetFillColor()
	#
	def SetFillColorArray(color)
		if !color.nil?
			color = color.values if color.is_a? Hash
			r = !color[0].nil? ? color[0] : -1
			g = !color[1].nil? ? color[1] : -1
			b = !color[2].nil? ? color[2] : -1
			k = !color[3].nil? ? color[3] : -1
			if r >= 0
				SetFillColor(r, g, b, k)
			end
		end
	end

	#
	# Defines the color used for all filling operations (filled rectangles and cell backgrounds). It can be expressed in RGB components or gray scale. The method can be called before the first page is created and the value is retained from page to page.
	# @param int :col1 Gray level for single color, or Red color for RGB, or Cyan color for CMYK. Value between 0 and 255
	# @param int :col2 Green color for RGB, or Magenta color for CMYK. Value between 0 and 255
	# @param int :col3 Blue color for RGB, or Yellow color for CMYK. Value between 0 and 255
	# @param int :col4 Key (Black) color for CMYK. Value between 0 and 255
	# @since 1.3
	# @see SetDrawColor(), SetTextColor(), Rect(), Cell(), MultiCell()
	#
	def SetFillColor(col1=0, col2=-1, col3=-1, col4=-1)
		# set default values
		unless col1.is_a? Integer
			col1 = 0
		end
		unless col2.is_a? Integer
			col2 = -1
		end
		unless col3.is_a? Integer
			col3 = -1
		end
		unless col4.is_a? Integer
			col4 = -1
		end

		# Set color for all filling operations
		if (col2 == -1) and (col3 == -1) and (col4 == -1)
			# Grey scale
			@fill_color = sprintf('%.3f g', col1 / 255.0)
			@bgcolor['G'] = col1
		elsif col4 == -1
			# RGB
			@fill_color = sprintf('%.3f %.3f %.3f rg', col1 / 255.0, col2 / 255.0, col3 / 255.0)
			@bgcolor['R'] = col1
			@bgcolor['G'] = col2
			@bgcolor['B'] = col3
		else
			# CMYK
			@fill_color = sprintf('%.3f %.3f %.3f %.3f k', col1 / 100.0, col2 / 100.0, col3 / 100.0, col4 / 100.0)
			@bgcolor['C'] = col1
			@bgcolor['M'] = col2
			@bgcolor['Y'] = col3
			@bgcolor['K'] = col4
		end

		@color_flag = @fill_color != @text_color
		if @page > 0
			out(@fill_color)
		end
	end
  alias_method :set_fill_color, :SetFillColor

=begin
  # This hasn't been ported from tcpdf, it's a variation on SetTextColor for setting cmyk colors
	def SetCmykFillColor(c, m, y, k, storeprev=false)
		#Set color for all filling operations
		@fill_color=sprintf('%.3f %.3f %.3f %.3f k', c, m, y, k);
		@color_flag=(@fill_color!=@text_color);
		if (storeprev)
			# store color as previous value
			@prevtext_color = [c, m, y, k]
		end
		if (@page>0)
			out(@fill_color);
		end
	end
  alias_method :set_cmyk_fill_color, :SetCmykFillColor
=end
	#
	# Defines the color used for text. It can be expressed in RGB components or gray scale. 
	# The method can be called before the first page is created and the value is retained from page to page.
	# @param array :color array of colors
	# @access public
	# @since 3.1.000 (2008-6-11)
	# @see SetFillColor()
	#
	def SetTextColorArray(color)
		unless color.nil?
			color = color.values if color.is_a? Hash
			r = !color[0].nil? ? color[0] : -1
			g = !color[1].nil? ? color[1] : -1
			b = !color[2].nil? ? color[2] : -1
			k = !color[3].nil? ? color[3] : -1
			if r >= 0
				SetTextColor(r, g, b, k)
			end
		end
	end

	#
	# Defines the color used for text. It can be expressed in RGB components or gray scale. The method can be called before the first page is created and the value is retained from page to page.
	# @param int :col1 Gray level for single color, or Red color for RGB, or Cyan color for CMYK. Value between 0 and 255
	# @param int :col2 Green color for RGB, or Magenta color for CMYK. Value between 0 and 255
	# @param int :col3 Blue color for RGB, or Yellow color for CMYK. Value between 0 and 255
	# @param int :col4 Key (Black) color for CMYK. Value between 0 and 255
	# @since 1.3
	# @see SetDrawColor(), SetFillColor(), Text(), Cell(), MultiCell()
	#
	def SetTextColor(col1=0, col2=-1, col3=-1, col4=-1)
		# set default values
		unless col1.is_a? Integer
			col1 = 0
		end
		unless col2.is_a? Integer
			col2 = -1
		end
		unless col3.is_a? Integer
			col3 = -1
		end
		unless col4.is_a? Integer
			col4 = -1
		end

		# Set color for text
		if (col2 == -1) and (col3 == -1) and (col4 == -1)
			# Grey scale
			@text_color = sprintf('%.3f g', col1 / 255.0)
			@fgcolor['G'] = col1
		elsif col4 == -1
			# RGB
			@text_color = sprintf('%.3f %.3f %.3f rg', col1 / 255.0, col2 / 255.0, col3 / 255.0)
			@fgcolor['R'] = col1
			@fgcolor['G'] = col2
			@fgcolor['B'] = col3
		else
			# CMYK
			@text_color = sprintf('%.3f %.3f %.3f %.3f k', col1 / 100.0, col2 / 100.0, col3 / 100.0, col4 / 100.0)
			@fgcolor['C'] = col1
			@fgcolor['M'] = col2
			@fgcolor['Y'] = col3
			@fgcolor['K'] = col4
		end
		@color_flag = @fill_color != @text_color
	end
  alias_method :set_text_color, :SetTextColor

=begin
  # This hasn't been ported from tcpdf, it's a variation on SetTextColor for setting cmyk colors
	def SetCmykTextColor(c, m, y, k, storeprev=false)
		#Set color for text
		@text_color=sprintf('%.3f %.3f %.3f %.3f k', c, m, y, k);
		@color_flag=(@fill_color!=@text_color);
		if (storeprev)
			# store color as previous value
			@prevtext_color = [c, m, y, k]
		end
	end
  alias_method :set_cmyk_text_color, :SetCmykTextColor
=end
  
	#
	# Returns the length of a string in user unit. A font must be selected.<br>
	# @param string :s The string whose length is to be computed
	# @param string :fontname Family font. It can be either a name defined by AddFont() or one of the standard families. It is also possible to pass an empty string, in that case, the current family is retained.
	# @param string :fontstyle Font style. Possible values are (case insensitive):<ul><li>empty string: regular</li><li>B: bold</li><li>I: italic</li><li>U: underline</li><li>D: line trough</li></ul> or any combination. The default value is regular.
	# @param float :fontsize Font size in points. The default value is the current size.
	# @param boolean :getarray if true returns an array of characters widths, if false returns the total length.
	# @return mixed int total string length or array of characted widths
	# @author Nicola Asuni
	# @access public
	# @since 1.2
	#
	def GetStringWidth(s, fontname='', fontstyle='', fontsize=0, getarray=false)
		return GetArrStringWidth(utf8Bidi(UTF8StringToArray(s), s, @tmprtl), fontname, fontstyle, fontsize, getarray)
	end
  alias_method :get_string_width, :GetStringWidth

	#
	# Returns the string length of an array of chars in user unit or an array of characters widths. A font must be selected.<br>
	# @param string :sa The array of chars whose total length is to be computed
	# @param string :fontname Family font. It can be either a name defined by AddFont() or one of the standard families. It is also possible to pass an empty string, in that case, the current family is retained.
	# @param string :fontstyle Font style. Possible values are (case insensitive):<ul><li>empty string: regular</li><li>B: bold</li><li>I: italic</li><li>U: underline</li><li>D: line trough</li></ul> or any combination. The default value is regular.
	# @param float :fontsize Font size in points. The default value is the current size.
	# @param boolean :getarray if true returns an array of characters widths, if false returns the total length.
	# @return mixed int total string length or array of characted widths
	# @author Nicola Asuni
	# @access public
	# @since 2.4.000 (2008-03-06)
	#
	def GetArrStringWidth(sa, fontname='', fontstyle='', fontsize=0, getarray=false)
		# store current values
		if !empty_string(fontname)
			prev_FontFamily = @font_family
			prev_FontStyle = @font_style
			prev_FontSizePt = @font_size_pt
			SetFont(fontname, fontstyle, fontsize)
		end
		# convert UTF-8 array to Latin1 if required
		sa = UTF8ArrToLatin1(sa)
		w = 0 # total width
		wa = [] # array of characters widths
		sa.each do |char|
			# character width
			cw = GetCharWidth(char)
			wa.push cw
			w += cw
		end
		# restore previous values
		if !empty_string(fontname)
			SetFont(prev_FontFamily, prev_FontStyle, prev_FontSizePt)
		end
		if getarray
			return wa
		end
		return w
	end

	#
	# Returns the length of the char in user unit for the current font.
	# @param int :char The char code whose length is to be returned
	# @return int char width
	# @author Nicola Asuni
	# @access public
	# @since 2.4.000 (2008-03-06)
	#
	def GetCharWidth(char)
		if char == 173
			# SHY character will not be printed
			return 0
		end
		cw = @current_font['cw']
		if !cw[char].nil?
			w = cw[char]
		elsif !@current_font['dw'].nil?
			# default width
			w = @current_font['dw']
		elsif !cw[32].nil?
			# default width
			w = cw[32]
		else
			w = 600
		end
		return (w * @font_size / 1000.0)
	end

	#
	# Returns the numbero of characters in a string.
	# @param string :s The input string.
	# @return int number of characters
	# @access public
	# @since 2.0.0001 (2008-01-07)
	#
	def GetNumChars(s)
		if (@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont0')
			return UTF8StringToArray(s).length
		end 
		return s.length
	end

	#
	# Defines the line width. By default, the value equals 0.2 mm. The method can be called before the first page is created and the value is retained from page to page.
	# @param float :width The width.
	# @since 1.0
	# @see Line(), Rect(), Cell(), MultiCell()
	#
	def SetLineWidth(width)
		#Set line width
		@line_width = width;
		if (@page>0)
			out(sprintf('%.2f w', width*@k));
		end
	end
  alias_method :set_line_width, :SetLineWidth

	#
	# Returns the current the line width.
	# @return int Line width
	# @access public
	# @since 2.1.000 (2008-01-07)
	# @see Line(), SetLineWidth()
	#
	def GetLineWidth()
		return @line_width
	end
  alias_method :get_line_width, :GetLineWidth

	#
	# Set line style.
	# @param array :style Line style. Array with keys among the following:
	# <ul>
	#        <li>width (float): Width of the line in user units.</li>
	#        <li>cap (string): Type of cap to put on the line. Possible values are: butt, round, square. The difference between "square" and "butt" is that "square" projects a flat end past the end of the line.</li>
	#        <li>join (string): Type of join. Possible values are: miter, round, bevel.</li>
	#        <li>dash (mixed): Dash pattern. Is 0 (without dash) or string with series of length values, which are the lengths of the on and off dashes. For example: "2" represents 2 on, 2 off, 2 on, 2 off, ...; "2,1" is 2 on, 1 off, 2 on, 1 off, ...</li>
	#        <li>phase (integer): Modifier on the dash pattern which is used to shift the point at which the pattern starts.</li>
	#        <li>color (array): Draw color. Format: array(GREY) or array(R,G,B) or array(C,M,Y,K).</li>
	# </ul>
	# @access public
	# @since 2.1.000 (2008-01-08)
	#
	def SetLineStyle(style)
		if !style['width'].nil?
			width = style['width']
			width_prev = @line_width
			SetLineWidth(width)
			@line_width = width_prev
		end
		if !style['cap'].nil?
			cap = style['cap']
			ca = {'butt' => 0, 'round'=> 1, 'square' => 2}
			if !ca[cap].nil?
				@linestyle_cap = ca[cap].to_s + ' J'
				out(@linestyle_cap)
			end
		end
		if !style['join'].nil?
			join = style['join']
			ja = {'miter' => 0, 'round' => 1, 'bevel' => 2}
			if !ja[join].nil?
				@linestyle_join = ja[join].to_s + ' j'
				out(@linestyle_join);
			end
		end
		if !style['dash'].nil?
			dash = style['dash']
			dash_string = ''
			if dash != 0
				if dash =~ /^.+,/
					tab = dash.split(',')
				else
					tab = [dash]
				end
				dash_string = ''
				tab.each_with_index { |v, i|
					if i != 0
						dash_string << ' '
					end
					dash_string << sprintf("%.2f", v)
				}
			end
			phase = 0
			@linestyle_dash = sprintf("[%s] %.2f d", dash_string, phase)
			out(@linestyle_dash)
		end
		if !style['color'].nil?
			color = style['color']
			SetDrawColorArray(color)
		end
	end

	#
	# Draws a line between two points.
	# @param float :x1 Abscissa of first point
	# @param float :y1 Ordinate of first point
	# @param float :x2 Abscissa of second point
	# @param float :y2 Ordinate of second point
	# @param array :style Line style. Array like for {@link SetLineStyle SetLineStyle}. Default value: default line style (empty array).
	# @access public
	# @since 1.0
	# @see SetLineWidth(), SetDrawColor(), SetLineStyle()
	#
	def Line(x1, y1, x2, y2, style=nil)
		if style
			SetLineStyle(style)
		end
		outPoint(x1, y1)
		outLine(x2, y2)
		out(' S')
	end
  alias_method :line, :Line
                
	#
	# Set a draw point.
	# @param float :x Abscissa of point.
	# @param float :y Ordinate of point.
	# @access protected
	# @since 2.1.000 (2008-01-08)
	#
	def outPoint(x, y)
		if @rtl
			x = @w - x
		end
		out(sprintf("%.2f %.2f m", x * @k, (@h - y) * @k))
	end

	#
	# Draws a line from last draw point.
	# @param float :x Abscissa of end point.
	# @param float :y Ordinate of end point.
	# @access protected
	# @since 2.1.000 (2008-01-08)
	#
	def outLine(x, y)
		if @rtl
			x = @w - x
		end
		out(sprintf("%.2f %.2f l", x * @k, (@h - y) * @k))
	end

	#
	# Draws a rectangle.
	# @param float :x Abscissa of upper-left corner (or upper-right corner for RTL language).
	# @param float :y Ordinate of upper-left corner (or upper-right corner for RTL language).
	# @param float :w Width.
	# @param float :h Height.
	# @param string :op options
	# @access protected
	# @since 2.1.000 (2008-01-08)
	#
	def outRect(x, y, w, h, op)
		if @rtl
			x = @w - x - w
		end
		out(sprintf('%.2f %.2f %.2f %.2f re %s', x * @k, (@h - y) * @k, w * @k, -h * @k, op))
	end

	#
	# Draws a Bezier curve from last draw point.
	# The Bezier curve is a tangent to the line between the control points at either end of the curve.
	# @param float :x1 Abscissa of control point 1.
	# @param float :y1 Ordinate of control point 1.
	# @param float :x2 Abscissa of control point 2.
	# @param float :y2 Ordinate of control point 2.
	# @param float :x3 Abscissa of end point.
	# @param float :y3 Ordinate of end point.
	# @access protected
	# @since 2.1.000 (2008-01-08)
	#
	def outCurve(x1, y1, x2, y2, x3, y3)
		if @rtl
			x1 = @w - x1
			x2 = @w - x2
			x3 = @w - x3
		end
		out(sprintf("%.2f %.2f %.2f %.2f %.2f %.2f c", x1 * @k, (@h - y1) * @k, x2 * @k, (@h - y2) * @k, x3 * @k, (@h - y3) * @k))
	end

	#
	# Draws a rectangle.
	# @param float :x Abscissa of upper-left corner (or upper-right corner for RTL language).
	# @param float :y Ordinate of upper-left corner (or upper-right corner for RTL language).
	# @param float :w Width.
	# @param float :h Height.
	# @param string :style Style of rendering. Possible values are:
	# <ul>
	#        <li>D or empty string: Draw (default).</li>
	#        <li>F: Fill.</li>
	#        <li>DF or FD: Draw and fill.</li>
	#        <li>CNZ: Clipping mode (using the even-odd rule to determine which regions lie inside the clipping path).</li>
	#        <li>CEO: Clipping mode (using the nonzero winding number rule to determine which regions lie inside the clipping path).</li>
	# </ul>
	# @param array :border_style Border style of rectangle. Array with keys among the following:
	# <ul>
	#        <li>all: Line style of all borders. Array like for {@link SetLineStyle SetLineStyle}.</li>
	#        <li>L, T, R, B or combinations: Line style of left, top, right or bottom border. Array like for {@link SetLineStyle SetLineStyle}.</li>
	# </ul>
	# If a key is not present or is null, not draws the border. Default value: default line style (empty array).
	# @param array :border_style Border style of rectangle. Array like for {@link SetLineStyle SetLineStyle}. Default value: default line style (empty array).
	# @param array :fill_color Fill color. Format: array(GREY) or array(R,G,B) or array(C,M,Y,K). Default value: default color (empty array).
	# @access public
	# @since 1.0
	# @see SetLineStyle()
	#
	def Rect(x, y, w, h, style='', border_style={}, fill_color={})
		if style.index('F') != nil and !fill_color.nil?
			SetFillColorArray(fill_color)
		end
		case style
		when 'F'
			op = 'f'
			border_style = {}
			outRect(x, y, w, h, op)
		when 'DF', 'FD'
			if !border_style or !border_style['all'].nil?
				op = 'B'
				if !border_style['all'].nil?
					SetLineStyle(border_style['all'])
					border_style = {}
				end
			else
				op = 'f'
			end
			outRect(x, y, w, h, op)
		when 'CNZ'
			op = 'W n'
			outRect(x, y, w, h, op)
		when 'CEO'
			op = 'W* n'
			outRect(x, y, w, h, op)
		else
			op = 'S'
			if !border_style or !border_style['all'].nil?
				if !border_style['all'].nil? and border_style['all']
					SetLineStyle(border_style['all'])
					border_style = {}
				end
				outRect(x, y, w, h, op)
			end
		end
		if border_style
			border_style2 = {}
			border_style.each_with_index { |value, line|
				length = line.length
				0.upto(length - 1) do |i|
					border_style2[line[i]] = value
				end
			}
			border_style = border_style2
			if !border_style['L'].nil? and border_style['L']
				Line(x, y, x, y + h, border_style['L'])
			end
			if !border_style['T'].nil? and border_style['T']
				Line(x, y, x + w, y, border_style['T'])
			end
			if !border_style['R'].nil? and border_style['R']
				Line(x + w, y, x + w, y + h, border_style['R'])
			end
			if !border_style['B'].nil? and border_style['B']
				Line(x, y + h, x + w, y + h, border_style['B'])
			end
		end
	end
  alias_method :rect, :Rect

	#
	# Draws an ellipse.
	# An ellipse is formed from n Bezier curves.
	# @param float :x0 Abscissa of center point.
	# @param float :y0 Ordinate of center point.
	# @param float :rx Horizontal radius.
	# @param float :ry Vertical radius (if ry = 0 then is a circle, see {@link Circle Circle}). Default value: 0.
	# @param float :angle: Angle oriented (anti-clockwise). Default value: 0.
	# @param float :astart: Angle start of draw line. Default value: 0.
	# @param float :afinish: Angle finish of draw line. Default value: 360.
	# @param string :style Style of rendering. Possible values are:
	# <ul>
	#   <li>D or empty string: Draw (default).</li>
	#   <li>F: Fill.</li>
	#   <li>DF or FD: Draw and fill.</li>
	#   <li>C: Draw close.</li>
	#   <li>CNZ: Clipping mode (using the even-odd rule to determine which regions lie inside the clipping path).</li>
	#   <li>CEO: Clipping mode (using the nonzero winding number rule to determine which regions lie inside the clipping path).</li>
	# </ul>
	# @param array :line_style Line style of ellipse. Array like for {@link SetLineStyle SetLineStyle}. Default value: default line style (empty array).
	# @param array :fill_color Fill color. Format: array(GREY) or array(R,G,B) or array(C,M,Y,K). Default value: default color (empty array).
	# @param integer :nc Number of curves used in ellipse. Default value: 8.
	# @access public
	# @since 2.1.000 (2008-01-08)
	#
	def Ellipse(x0, y0, rx, ry=0, angle=0, astart=0, afinish=360, style='', line_style=nil, fill_color=nil, nc=8)
		if angle != 0
			StartTransform()
			Rotate(angle, x0, y0)
			Ellipse(x0, y0, rx, ry, 0, astart, afinish, style, line_style, fill_color, nc)
			StopTransform()
			return
		end
		if rx
			if (nil != style.index('F')) and fill_color
				SetFillColorArray(fill_color)
			end
			case style
			when 'F'
				op = 'f'
				line_style = nil
			when 'FD', 'DF'
				op = 'B'
			when 'C'
				op = 's' # Small 's' signifies closing the path as well
			when 'CNZ'
				op = 'W n'
			when 'CEO'
				op = 'W* n'
			else
				op = 'S'
			end

			if line_style
				SetLineStyle(line_style)
			end

			if ry == 0
				ry = rx
			end
			rx *= @k
			ry *= @k
			if nc < 2
				nc = 2
			end
			astart *= ::Math::PI / 180 
			afinish *= ::Math::PI / 180
			total_angle = afinish - astart
			dt = total_angle / nc
			dtm = dt / 3
			x0 *= @k
			y0 = (@h - y0) * @k
			t1 = astart
			a0 = x0 + rx * ::Math.cos(t1)
			b0 = y0 + ry * ::Math.sin(t1)
			c0 = -rx * ::Math.sin(t1)
			d0 = ry * ::Math.cos(t1)
			outPoint(a0 / @k, @h - (b0 / @k))
			1.upto(nc) do |i|
				# Draw this bit of the total curve
				t1 = i * dt + astart
				a1 = x0 + rx * ::Math.cos(t1)
				b1 = y0 + ry * ::Math.sin(t1)
				c1 = -rx * ::Math.sin(t1)
				d1 = ry * ::Math.cos(t1)
				outCurve((a0 + c0 * dtm) / @k, @h - ((b0 + d0 * dtm) / @k), (a1 - c1 * dtm) / @k, @h - ((b1 - d1 * dtm) / @k), a1 / @k, @h - (b1 / @k))
				a0 = a1
				b0 = b1
				c0 = c1
				d0 = d1
			end
			out(op)
		end
	end

	#
	# Draws a circle.
	# A circle is formed from n Bezier curves.
	# @param float :x0 Abscissa of center point.
	# @param float :y0 Ordinate of center point.
	# @param float :r Radius.
	# @param float :astart: Angle start of draw line. Default value: 0.
	# @param float :afinish: Angle finish of draw line. Default value: 360.
	# @param string :style Style of rendering. Possible values are:
	# <ul>
	#   <li>D or empty string: Draw (default).</li>
	#   <li>F: Fill.</li>
	#   <li>DF or FD: Draw and fill.</li>
	#   <li>C: Draw close.</li>
	#   <li>CNZ: Clipping mode (using the even-odd rule to determine which regions lie inside the clipping path).</li>
	#   <li>CEO: Clipping mode (using the nonzero winding number rule to determine which regions lie inside the clipping path).</li>
	# </ul>
	# @param array :line_style Line style of circle. Array like for {@link SetLineStyle SetLineStyle}. Default value: default line style (empty array).
	# @param array :fill_color Fill color. Format: array(red, green, blue). Default value: default color (empty array).
	# @param integer :nc Number of curves used in circle. Default value: 8.
	# @access public
	# @since 2.1.000 (2008-01-08)
	#
	def Circle(x0, y0, r, astart=0, afinish=360, style='', line_style=nil, fill_color=nil, nc=8)
		Ellipse(x0, y0, r, 0, 0, astart, afinish, style, line_style, fill_color, nc)
	end
	alias_method :circle, :Circle

	#
	# Imports a TrueType, Type1, core, or CID0 font and makes it available.
	# It is necessary to generate a font definition file first with the makefont.rb utility.
	# The definition file (and the font file itself when embedding) must be present either in the current directory or in the one indicated by FPDF_FONTPATH if the constant is defined. If it could not be found, the error "Could not include font definition file" is generated.
	# <b>Example</b>:<br />
	# <pre>
	# :pdf->AddFont('Comic','I');
	# # is equivalent to:
	# :pdf->AddFont('Comic','I','comici.rb');
	# </pre>
	# @param string :family Font family. The name can be chosen arbitrarily. If it is a standard family name, it will override the corresponding font.
	# @param string :style Font style. Possible values are (case insensitive):<ul><li>empty string: regular (default)</li><li>B: bold</li><li>I: italic</li><li>BI or IB: bold italic</li></ul>
	# @param string :fontfile The font definition file. By default, the name is built from the family and style, in lower case with no space.
	# @return array containing the font data, or false in case of error.
	# @access public
	# @since 1.5
	# @see SetFont()
	#
	def AddFont(family, style='', fontfile='')
		if empty_string(family)
			if !empty_string(@font_family)
				family = @font_family
			else
				Error('Empty font family')
			end
		end

		family = family.downcase
		if ((!@is_unicode) and (family == 'arial'))
			family = 'helvetica';
		end
		if (family == "symbol") or (family == "zapfdingbats")
			style = ''
		end

		tempstyle = style.upcase
		style = ''
		# underline
		if tempstyle.index('U') != nil
			@underline = true
		else
			@underline = false
		end
		# line through (deleted)
		if tempstyle.index('D') != nil
			@linethrough = true
		else
			@linethrough = false
		end
		# bold
		if tempstyle.index('B') != nil
			style << 'B';
		end
		# oblique
		if tempstyle.index('I') != nil
			style << 'I';
		end
		bistyle = style
		fontkey = family + style;
		font_style = style + (@underline ? 'U' : '') + (@linethrough ? 'D' : '')
		fontdata = {'fontkey' => fontkey, 'family' => family, 'style' => font_style}
		# check if the font has been already added
		if getFontBuffer(fontkey) != false
			return fontdata
		end

		# get specified font directory (if any)
		fontdir = '';
		if !empty_string(fontfile)
			fontdir = File.dirname(fontfile)
			if empty_string(fontdir) or (fontdir == '.')
				fontdir = ''
			else
				fontdir << '/'
			end
		end

		# search and include font file
		if empty_string(fontfile)
			# build a standard filenames for specified font
			fontfile1 = family.gsub(' ', '') + style.downcase + '.rb'
			fontfile2 = family.gsub(' ', '') + '.rb'
			# search files on various directories
			if File.exists?(fontdir + fontfile1)
				fontfile = fontdir + fontfile1
				fontname = fontfile1
			elsif fontfile = getfontpath(fontfile1)
				fontname = fontfile1
			elsif File.exists?(fontfile1)
				fontfile = fontfile1
				fontname = fontfile1
			elsif File.exists?(fontdir + fontfile2)
				fontfile = fontdir + fontfile2
				fontname = fontfile2
			elsif fontfile = getfontpath(fontfile2)
				fontname = fontfile2
			else
				fontfile = fontfile2
				fontname = fontfile2
			end
		end

		# include font file
		if File.exists?(fontfile)
			require(fontfile)
		else
			Error('Could not include font definition file: ' + family + '')
		end

		font_desc = TCPDFFontDescriptor.font(fontname)

		# check font parameters
		if font_desc[:type].nil? or font_desc[:cw].nil?
			Error('The font definition file has a bad format: ' + fontfile + '')
		end

		# SET default parameters
		font_desc[:file] ||= ''
		font_desc[:enc] ||= ''
		if font_desc[:cidinfo].nil?
			font_desc[:cidinfo] = {'Registry'=>'Adobe', 'Ordering'=>'Identity', 'Supplement'=>0}
			font_desc[:cidinfo]['uni2cid'] = {}
		end
		font_desc[:ctg] ||= ''
		font_desc[:desc] ||= {}
		font_desc[:up] ||= -100
		font_desc[:ut] ||= 50
		font_desc[:cw] ||= {}
		if empty_string(font_desc[:dw])
			# set default width
			if !font_desc[:desc]['MissingWidth'].nil? and (font_desc[:desc]['MissingWidth'] > 0)
				font_desc[:dw] = font_desc[:desc]['MissingWidth']
			elsif font_desc[:cw][32]
				font_desc[:dw] = font_desc[:cw][32]
			else
				font_desc[:dw] = 600
			end
		end

		@numfonts += 1
		if font_desc[:type] == 'cidfont0'
			#  register CID font (all styles at once)
			styles = {'' => '', 'B' => ',Bold', 'I' => ',Italic', 'BI' => ',BoldItalic'}
			sname = font_desc[:name] + styles[bistyle]
			if (bistyle.index('B') != nil) and font_desc[:desc]['StemV'] and (font_desc[:desc]['StemV'] == 70)
				font_desc[:desc]['StemV'] = 120
			end
			setFontBuffer(fontkey, {'i' => @numfonts, 'type' => font_desc[:type], 'name' => sname, 'desc' => font_desc[:desc], 'cidinfo' => font_desc[:cidinfo], 'up' => font_desc[:up], 'ut' => font_desc[:ut], 'cw' => font_desc[:cw], 'dw' => font_desc[:dw], 'enc' => font_desc[:enc]})
		elsif font_desc[:type] == 'core'
			font_desc[:name] = @core_fonts[fontkey]
		elsif (font_desc[:type] == 'TrueType') or (font_desc[:type] == 'Type1')
			# ...
		elsif font_desc[:type] == 'TrueTypeUnicode'
			font_desc[:enc] = 'Identity-H'
		else
			Error('Unknow font type: ' + type + '')
		end
		setFontBuffer(fontkey, {'i' => @numfonts, 'type' => font_desc[:type], 'name' => font_desc[:name], 'desc' => font_desc[:desc], 'up' => font_desc[:up], 'ut' => font_desc[:ut], 'cw' => font_desc[:cw], 'dw' => font_desc[:dw], 'enc' => font_desc[:enc], 'cidinfo' => font_desc[:cidinfo], 'file' => font_desc[:file], 'ctg' => font_desc[:ctg]})

		if (!font_desc[:diff].nil? and (!font_desc[:diff].empty?))
			#Search existing encodings
			d=0;
			nb=@diffs.length;
			1.upto(nb) do |i|
				if (@diffs[i]== font_desc[:diff])
					d = i;
					break;
				end
			end
			if (d==0)
				d = nb+1;
				@diffs[d] = font_desc[:diff];
			end
			setFontSubBuffer(fontkey, 'diff', d)
		end
		if !empty_string(font_desc[:file])
			if (font_desc[:type] == 'TrueType') or (font_desc[:type] == 'TrueTypeUnicode')
				@font_files[font_desc[:file]] = {'length1' => font_desc[:originalsize], 'fontdir' => fontdir}
			elsif font_desc[:type] != 'core'
				@font_files[font_desc[:file]] = {'length1' => font_desc[:size1], 'length2' => font_desc[:size2], 'fontdir' => fontdir}
			end
		end
		return fontdata
	end
  alias_method :add_font, :AddFont

	#
	# Sets the font used to print character strings.
	# The font can be either a standard one or a font added via the AddFont() method. Standard fonts use Windows encoding cp1252 (Western Europe).
	# The method can be called before the first page is created and the font is retained from page to page.
	# If you just wish to change the current font size, it is simpler to call SetFontSize().
	# Note: for the standard fonts, the font metric files must be accessible. There are three possibilities for this:<ul><li>They are in the current directory (the one where the running script lies)</li><li>They are in one of the directories defined by the include_path parameter</li><li>They are in the directory defined by the FPDF_FONTPATH constant</li></ul><br />
	# @param string :family Family font. It can be either a name defined by AddFont() or one of the standard Type1 families (case insensitive):<ul><li>times (Times-Roman)</li><li>timesb (Times-Bold)</li><li>timesi (Times-Italic)</li><li>timesbi (Times-BoldItalic)</li><li>helvetica (Helvetica)</li><li>helveticab (Helvetica-Bold)</li><li>helveticai (Helvetica-Oblique)</li><li>helveticabi (Helvetica-BoldOblique)</li><li>courier (Courier)</li><li>courierb (Courier-Bold)</li><li>courieri (Courier-Oblique)</li><li>courierbi (Courier-BoldOblique)</li><li>symbol (Symbol)</li><li>zapfdingbats (ZapfDingbats)</li></ul> It is also possible to pass an empty string. In that case, the current family is retained.
	# @param string :style Font style. Possible values are (case insensitive):<ul><li>empty string: regular</li><li>B: bold</li><li>I: italic</li><li>U: underline</li><li>D: line trough</li></ul> or any combination. The default value is regular. Bold and italic styles do not apply to Symbol and ZapfDingbats basic fonts or other fonts when not defined.
	# @param float :size Font size in points. The default value is the current size. If no size has been specified since the beginning of the document, the value taken is 12
	# @param string :fontfile The font definition file. By default, the name is built from the family and style, in lower case with no spaces.
	# @access public
	# @since 1.0
	# @see AddFont(), SetFontSize()
	#
	def SetFont(family, style='', size=0, fontfile='')
		# Select a font; size given in points
		if size == 0
			size = @font_size_pt
		end
		# try to add font (if not already added)
		fontdata =  AddFont(family, style, fontfile)
		@font_family = fontdata['family']
		@font_style = fontdata['style']
		@current_font = getFontBuffer(fontdata['fontkey'])
		SetFontSize(size)
	end
  alias_method :set_font, :SetFont

	#
	# Defines the size of the current font.
	# @param float :size The size (in points)
	# @access public
	# @since 1.0
	# @see SetFont()
	#
	def SetFontSize(size)
		#Set font size in points
		@font_size_pt = size;
		@font_size = size.to_f / @k;
		if !@current_font['desc'].nil? and !@current_font['desc']['Ascent'].nil? and (@current_font['desc']['Ascent'] > 0)
			@font_ascent = @current_font['desc']['Ascent'] * @font_size / 1000
		else
			@font_ascent = 0.8 * @font_size
		end
		if !@current_font['desc'].nil? and !@current_font['desc']['Descent'].nil? and (@current_font['desc']['Descent'] > 0)
			@font_descent = - @current_font['desc']['Descent'] * @font_size / 1000
		else
			@font_descent = 0.2 * @font_size
		end
		if (@page > 0) and !@current_font['i'].nil?
			out(sprintf('BT /F%d %.2f Tf ET ', @current_font['i'], @font_size_pt));
		end
	end
  alias_method :set_font_size, :SetFontSize

	#
	# Defines the default monospaced font.
	# @param string :font Font name.
	# @access public
	# @since 4.5.025
	#
	def SetDefaultMonospacedFont(font)
		@default_monospaced_font = font
	end

	#
	# Creates a new internal link and returns its identifier. An internal link is a clickable area which directs to another place within the document.<br />
	# The identifier can then be passed to Cell(), Write(), Image() or Link(). The destination is defined with SetLink().
	# @since 1.5
	# @see Cell(), Write(), Image(), Link(), SetLink()
	#
	def AddLink()
		#Create a new internal link
		n=@links.length+1;
		@links[n]=[0,0];
		return n;
	end
  alias_method :add_link, :AddLink

	#
	# Defines the page and position a link points to
	# @param int :link The link identifier returned by AddLink()
	# @param float :y Ordinate of target position; -1 indicates the current position. The default value is 0 (top of page)
	# @param int :page Number of target page; -1 indicates the current page. This is the default value
	# @since 1.5
	# @see AddLink()
	#
	def SetLink(link, y=0, page=-1)
		#Set destination of internal link
		if (y==-1)
			y=@y;
		end
		if (page==-1)
			page=@page;
		end
		@links[link] = [page, y]
	end
  alias_method :set_link, :SetLink

	#
	# Puts a link on a rectangular area of the page.
	# Text or image links are generally put via Cell(), Write() or Image(), but this method can be useful for instance to define a clickable area inside an image.
	# @param float :x Abscissa of the upper-left corner of the rectangle
	# @param float :y Ordinate of the upper-left corner of the rectangle
	# @param float :w Width of the rectangle
	# @param float :h Height of the rectangle
	# @param mixed :link URL or identifier returned by AddLink()
	# @param int :spaces number of spaces on the text to link
	# @access public
	# @since 1.5
	# @see AddLink(), Annotation(), Cell(), Write(), Image()
	#
	def Link(x, y, w, h, link, spaces=0)
		Annotation(x, y, w, h, link, {'Subtype'=>'Link'}, spaces)
	end
  alias_method :link, :Link

	#
	# Puts a markup annotation on a rectangular area of the page.
	# !!!!THE ANNOTATION SUPPORT IS NOT YET FULLY IMPLEMENTED !!!!
	# @param float :x Abscissa of the upper-left corner of the rectangle
	# @param float :y Ordinate of the upper-left corner of the rectangle
	# @param float :w Width of the rectangle
	# @param float :h Height of the rectangle
	# @param string :text annotation text or alternate content
	# @param array :opt array of options (see section 8.4 of PDF reference 1.7).
	# @param int :spaces number of spaces on the text to link
	# @access public
	# @since 4.0.018 (2008-08-06)
	#
	def Annotation(x, y, w, h, text, opt={'Subtype'=>'Text'}, spaces=0)
		x = @x if x == ''
		y = @y if y == ''

		# recalculate coordinates to account for graphic transformations
		if !@transfmatrix.nil?
			@transfmatrix_key.downto(1) do |i|
				maxid = @transfmatrix[i].length - 1
				maxid.downto(0) do |j|
					ctm = @transfmatrix[i][j]
					if !ctm['a'].nil?
						x = x * @k
						y = (@h - y) * @k
						w = w * @k
						h = h * @k
						# top left
						xt = x
						yt = y
						x1 = (ctm['a'] * xt) + (ctm['c'] * yt) + ctm['e']
						y1 = (ctm['b'] * xt) + (ctm['d'] * yt) + ctm['f']
						# top right
						xt = x + w
						yt = y
						x2 = (ctm['a'] * xt) + (ctm['c'] * yt) + ctm['e']
						y2 = (ctm['b'] * xt) + (ctm['d'] * yt) + ctm['f']
						# bottom left
						xt = x
						yt = y - h
						x3 = (ctm['a'] * xt) + (ctm['c'] * yt) + ctm['e']
						y3 = (ctm['b'] * xt) + (ctm['d'] * yt) + ctm['f']
						# bottom right
						xt = x + w
						yt = y - h
						x4 = (ctm['a'] * xt) + (ctm['c'] * yt) + ctm['e']
						y4 = (ctm['b'] * xt) + (ctm['d'] * yt) + ctm['f']
						# new coordinates (rectangle area)
						x = [x1, x2, x3, x4].min
						y = [y1, y2, y3, y4].max
						w = ([x1, x2, x3, x4].max - x) / @k
						h = (y - [y1, y2, y3, y4].min) / @k
						x = x / @k
						y = @h - (y / @k)
					end
				end
			end
		end
		if @page <= 0
			page = 1
		else
			page = @page
		end
		@page_annots[page] ||= []
		@page_annots[page].push 'x' => x, 'y' => y, 'w' => w, 'h' => h, 'txt' => text, 'opt' => opt, 'numspaces' => spaces
		if ((opt['Subtype'] == 'FileAttachment') or (opt['Subtype'] == 'Sound')) and !empty_string(opt['FS']) and File.exist?(opt['FS']) and @embeddedfiles[File.basename(opt['FS'])].nil?
			@embeddedfiles[File.basename(opt['FS'])] = {'file' => opt['FS'], 'n' => (@embeddedfiles.length + @embedded_start_obj_id)}
		end
		# Add widgets annotation's icons
		if opt['mk'] and opt['mk']['i'] and File.exist?(opt['mk']['i'])
			Image(opt['mk']['i'], '', '', 10, 10, '', '', '', false, 300, '', false, false, 0, false, true)
		end
		if opt['mk'] and opt['mk']['ri'] and File.exist?(opt['mk']['ri'])
			Image(opt['mk']['ri'], '', '', 0, 0, '', '', '', false, 300, '', false, false, 0, false, true)
		end
		if opt['mk'] and opt['mk']['ix'] and File.exist?(opt['mk']['ix'])
			Image(opt['mk']['ix'], '', '', 0, 0, '', '', '', false, 300, '', false, false, 0, false, true)
		end
		@annot_obj_id += 1
	end

	#
	# Embedd the attached files.
	# @since 4.4.000 (2008-12-07)
	# @access protected
	# @see Annotation()
	#
	def putEmbeddedFiles()
		# reset(@embeddedfiles)
		@embeddedfiles.each { |filename, filedata|
			data = ''
			open(filedata['file'],'rb') do |f|
				data = f.read()
			end
			filter = ''
			if @compress
				data = gzcompress(data)
				filter = ' /Filter /FlateDecode'
			end
			@offsets[filedata['n']] = @bufferlen
			out(filedata['n'].to_s + ' 0 obj')
			out('<</Type /EmbeddedFile' + filter + ' /Length ' + data.length.to_s + ' >>')
			putstream(data)
			out('endobj')
		}
	end

	#
	# Prints a character string. The origin is on the left of the first charcter, on the baseline. This method allows to place a string precisely on the page, but it is usually easier to use Cell(), MultiCell() or Write() which are the standard methods to print text.
	# @param float :x Abscissa of the origin
	# @param float :y Ordinate of the origin
	# @param string :txt String to print
	# @param int :stroke outline size in points (0 = disable)
	# @param boolean :clip if true activate clipping mode (you must call StartTransform() before this function and StopTransform() to stop the clipping tranformation).
	# @since 1.0
	# @see SetFont(), SetTextColor(), Cell(), MultiCell(), Write()
	#
	def Text(x, y, txt, stroke=0, clip=false)
		#Output a string
		if @rtl
			# bidirectional algorithm (some chars may be changed affecting the line length)
			s = utf8Bidi(UTF8StringToArray(txt), txt, @tmprtl)
			l = GetArrStringWidth(s)
			xr = @w - x - l
		else
			xr = x
		end
		opt = ""
		if (stroke > 0) and !clip
			opt << "1 Tr " + stroke.to_i + " w "
		elsif (stroke > 0) and clip
			opt << "5 Tr " + stroke.to_i + " w "
		elsif clip
			opt << "7 Tr "
		end
		s = sprintf('BT %.2f %.2f Td %s(%s) Tj ET', xr * @k, (@h - y) * @k, opt, escapetext(txt))
		if @underline and (txt != '')
			s << ' ' + dounderline(xr, y, txt)
		end
		if @linethrough and (txt != '') 
			s << ' ' + dolinethrough(xr, y, txt) 
		end
		if @color_flag and !clip
			s = 'q ' + @text_color + ' ' + s + ' Q'
		end
		out(s);
	end
  alias_method :text, :Text

	#
	# Whenever a page break condition is met, the method is called, and the break is issued or not depending on the returned value. The default implementation returns a value according to the mode selected by SetAutoPageBreak().<br />
	# This method is called automatically and should not be called directly by the application.<br />
	# <b>Example:</b><br />
	# The method is overriden in an inherited class in order to obtain a 3 column layout:<br />
	# <pre>
	# class PDF extends TCPDF {
	# 	var :col=0;
	#
	# 	def SetCol(col)
	# 		#Move position to a column
	# 		@col = col;
	# 		:x=10+:col*65;
	# 		SetLeftMargin(x);
	# 		SetX(x);
	# 	end
	#
	# 	def AcceptPageBreak()
	# 		if (@col<2)
	# 			#Go to next column
	# 			SetCol(@col+1);
	# 			SetY(10);
	# 			return false;
	# 		end
	# 		else
	# 			#Go back to first column and issue page break
	# 			SetCol(0);
	# 			return true;
	# 		end
	# 	end
	# }
	#
	# :pdf=new PDF();
	# :pdf->Open();
	# :pdf->AddPage();
	# :pdf->SetFont('Arial','',12);
	# for(i=1;:i<=300;:i++)
	#     :pdf->Cell(0,5,"Line :i",0,1);
	# }
	# :pdf->Output();
	# </pre>
	# @return boolean
	# @since 1.4
	# @see SetAutoPageBreak()
	#
	def AcceptPageBreak()
		#Accept automatic page break or not
		return @auto_page_break;
	end
  alias_method :accept_page_break, :AcceptPageBreak

	#
	# Add page if needed.
	# @param float :h Cell height. Default value: 0.
	# @param mixed :y starting y position, leave empty for current position.
	# @param boolean :addpage if true add a page, otherwise only return the true/false state
	# @return boolean true in case of page break, false otherwise.
	# @since 3.2.000 (2008-07-01)
	# @access protected
	#
	def checkPageBreak(h=0, y='', addpage=true)
		if empty_string(y)
			y = @y
		end

		if (y + h > @page_break_trigger) and !@in_footer and AcceptPageBreak()
			if addpage
				# Automatic page break
				x = @x
				AddPage(@cur_orientation)
				@y = @t_margin
				oldpage = @page - 1
				if @rtl
					if @pagedim[@page]['orm'] != @pagedim[oldpage]['orm']
						@x = x - (@pagedim[@page]['orm'] - @pagedim[oldpage]['orm'])
					else
						@x = x
					end
				else
					if @pagedim[@page]['olm'] != @pagedim[oldpage]['olm']
						@x = x + (@pagedim[@page]['olm'] - @pagedim[oldpage]['olm'])
					else
						@x = x
					end
				end
			end
			return true
		end
		return false
	end

  def BreakThePage?(h)
		if ((@y + h) > @page_break_trigger and !@in_footer and AcceptPageBreak())
      true
    else
      false
    end
  end
  alias_method :break_the_page?, :BreakThePage?
	#
	# Prints a cell (rectangular area) with optional borders, background color and character string. The upper-left corner of the cell corresponds to the current position. The text can be aligned or centered. After the call, the current position moves to the right or to the next line. It is possible to put a link on the text.<br />
	# If automatic page breaking is enabled and the cell goes beyond the limit, a page break is done before outputting.
	# @param float :w Cell width. If 0, the cell extends up to the right margin.
	# @param float :h Cell height. Default value: 0.
	# @param string :txt String to print. Default value: empty string.
	# @param mixed :border Indicates if borders must be drawn around the cell. The value can be either a number:<ul><li>0: no border (default)</li><li>1: frame</li></ul>or a string containing some or all of the following characters (in any order):<ul><li>L: left</li><li>T: top</li><li>R: right</li><li>B: bottom</li></ul>
	# @param int :ln Indicates where the current position should go after the call. Possible values are:<ul><li>0: to the right</li><li>1: to the beginning of the next line</li><li>2: below</li></ul>
	# Putting 1 is equivalent to putting 0 and calling Ln() just after. Default value: 0.
	# @param string :align Allows to center or align the text. Possible values are:<ul><li>L or empty string: left align (default value)</li><li>C: center</li><li>R: right align</li></ul>
	# @param int :fill Indicates if the cell background must be painted (1) or transparent (0). Default value: 0.
	# @param mixed :link URL or identifier returned by AddLink().
	# @param int :stretch stretch carachter mode: <ul><li>0 = disabled</li><li>1 = horizontal scaling only if necessary</li><li>2 = forced horizontal scaling</li><li>3 = character spacing only if necessary</li><li>4 = forced character spacing</li></ul>
	# @param boolean :ignore_min_height if true ignore automatic minimum height value.
	# @since 1.0
	# @see SetFont(), SetDrawColor(), SetFillColor(), SetTextColor(), SetLineWidth(), AddLink(), Ln(), MultiCell(), Write(), SetAutoPageBreak()
	#
	def Cell(w, h=0, txt='', border=0, ln=0, align='', fill=0, link=nil, stretch=0, ignore_min_height=false)
		min_cell_height = @font_size * @@k_cell_height_ratio
		if h < min_cell_height
			h = min_cell_height
		end
		checkPageBreak(h)
		out(getCellCode(w, h, txt, border, ln, align, fill, link, stretch, ignore_min_height) + ' ')
	end
  alias_method :cell, :Cell

	#
	# Removes SHY characters from text.
	# @param string :txt input string
	# @return string without SHY characters.
	# @access public
	# @since (4.5.019) 2009-02-28
	#
	def removeSHY(txt='')
		# Unicode Data
		# Name : SOFT HYPHEN, commonly abbreviated as SHY
		# HTML Entity (decimal): &#173;
		# HTML Entity (hex): &#xad;
		# HTML Entity (named): &shy;
		# How to type in Microsoft Windows: [Alt +00AD] or [Alt 0173]
		# UTF-8 (hex): 0xC2 0xAD (c2ad)
		# UTF-8 character: chr(194).chr(173)

		txt.force_encoding('ASCII-8BIT') if txt.respond_to?(:force_encoding)
		txt.gsub!(/([\xc2]{1}[\xad]{1})/, '')
		if !@is_unicode
			txt.gsub!(/([\xad]{1})/, '')
			return txt
		end
		txt.force_encoding('UTF-8') if txt.respond_to?(:force_encoding)
		return txt
	end

	#
	# Returns the PDF string code to print a cell (rectangular area) with optional borders, background color and character string. The upper-left corner of the cell corresponds to the current position. The text can be aligned or centered. After the call, the current position moves to the right or to the next line. It is possible to put a link on the text.<br />
	# If automatic page breaking is enabled and the cell goes beyond the limit, a page break is done before outputting.
	# @param float :w Cell width. If 0, the cell extends up to the right margin.
	# @param float :h Cell height. Default value: 0.
	# @param string :txt String to print. Default value: empty string.
	# @param mixed :border Indicates if borders must be drawn around the cell. The value can be either a number:<ul><li>0: no border (default)</li><li>1: frame</li></ul>or a string containing some or all of the following characters (in any order):<ul><li>L: left</li><li>T: top</li><li>R: right</li><li>B: bottom</li></ul>
	# @param int :ln Indicates where the current position should go after the call. Possible values are:<ul><li>0: to the right (or left for RTL languages)</li><li>1: to the beginning of the next line</li><li>2: below</li></ul>Putting 1 is equivalent to putting 0 and calling Ln() just after. Default value: 0.
	# @param string :align Allows to center or align the text. Possible values are:<ul><li>L or empty string: left align (default value)</li><li>C: center</li><li>R: right align</li><li>J: justify</li></ul>
	# @param int :fill Indicates if the cell background must be painted (1) or transparent (0). Default value: 0.
	# @param mixed :link URL or identifier returned by AddLink().
	# @param int :stretch stretch carachter mode: <ul><li>0 = disabled</li><li>1 = horizontal scaling only if necessary</li><li>2 = forced horizontal scaling</li><li>3 = character spacing only if necessary</li><li>4 = forced character spacing</li></ul>
	# @param boolean :ignore_min_height if true ignore automatic minimum height value.
	# @access protected
	# @since 1.0
	# @see Cell()
	#
	def getCellCode(w, h=0, txt='', border=0, ln=0, align='', fill=0, link=nil, stretch=0, ignore_min_height=false)
		rs = "" # string to be returned
		txt = removeSHY(txt)
		if !ignore_min_height
			min_cell_height = @font_size * @@k_cell_height_ratio
			if h < min_cell_height
				h = min_cell_height
			end
		end
		k = @k
		if empty_string(w) or (w <= 0)
			if @rtl
				w = @x - @l_margin
			else
				w = @w - @r_margin - @x
			end
		end
		s = '';
		# fill and borders
		if (fill == 1) or (border.to_i == 1)
			if (fill == 1)
				op = (border.to_i == 1) ? 'B' : 'f';
			else
				op = 'S';
			end

			if @rtl
				xk = (@x - w) * k
			else
				xk = @x * k
			end
			s << sprintf('%.2f %.2f %.2f %.2f re %s ', xk, (@h - @y) * k, w * k, -h * k, op)
		end
		if (border.is_a?(String))
			lm = @line_width / 2
			x=@x;
			y=@y;
			if (border.include?('L'))
				if @rtl
					xk = (x - w) * k
				else
					xk = x * k
				end
				s << sprintf('%.2f %.2f m %.2f %.2f l S ', xk, (@h - y + lm) * k, xk, (@h - (y + h + lm)) * k)
			end
			if (border.include?('T'))
				if @rtl
					xk = (x - w + lm) * k
					xwk = (x - lm) * k
				else
					xk = (x - lm) * k
					xwk = (x + w + lm) * k
				end
				s << sprintf('%.2f %.2f m %.2f %.2f l S ', xk,(@h-y)*k,xwk,(@h-y)*k)
			end
			if (border.include?('R'))
				if @rtl
					xk = x * k
				else
					xk = (x + w) * k
				end
				s << sprintf('%.2f %.2f m %.2f %.2f l S ', xk, (@h - y + lm) * k, xk, (@h - (y + h + lm)) * k)
			end
			if (border.include?('B'))
				if @rtl
					xk = (x - w + lm) * k
					xwk = (x - lm) * k
				else
					xk = (x - lm) * k
					xwk = (x + w + lm) * k
				end
				s << sprintf('%.2f %.2f m %.2f %.2f l S ', xk,(@h-(y+h))*k,xwk,(@h-(y+h))*k)
			end
		end
		if (txt != '')
			txt2 = escapetext(txt)
			# text length
			width = txwidth = GetStringWidth(txt)
			# ratio between cell length and text length
			if width <= 0
				ratio = 1
			else
				ratio = (w - (2 * @c_margin)) / width
			end
			# stretch text if required
			if (stretch > 0) and ((ratio < 1) or ((ratio > 1) and ((stretch % 2) == 0)))
				if stretch > 2
					# spacing
					# Calculate character spacing in points
					txt_length =  GetNumChars(txt) - 1
					char_space = ((w - width - (2 * @c_margin)) * @k) / (txt_length > 1 ? txt_length : 1)
					# Set character spacing
					rs << sprintf('BT %.2f Tc ET ', char_space)
				else
					# scaling
					# Calculate horizontal scaling
					horiz_scale = ratio * 100.0
					# Set horizontal scaling
					rs << sprintf('BT %.2f Tz ET ', horiz_scale)
				end
				align = ''
				width = w - (2 * @c_margin)
			else
				stretch == 0
			end

			if (@color_flag)
				s << 'q ' + @text_color + ' ';
			end
			# count number of spaces
			ns = txt.count(' ')
			# Justification
			if (align == 'J') and (ns > 0)
				if (@current_font['type'] == "TrueTypeUnicode") or (@current_font['type'] == "cidfont0")
					# get string width without spaces
					width = GetStringWidth(txt.gsub(' ', ''))
					# calculate average space width
					spacewidth = -1000 * (w - width - (2 * @c_margin)) / (ns ? ns : 1) / @font_size
					# set word position to be used with TJ operator
					txt2 = txt2.gsub(0.chr + ' ', ') ' + sprintf('%.3f', spacewidth) + ' (')
				else
					# get string width
					width = txwidth
					spacewidth = ((w - width - (2 * @c_margin)) / (ns ? ns : 1)) * @k
					# set word spacing
					rs << sprintf('BT %.3f Tw ET ', spacewidth)
				end
				width = w - (2 * @c_margin)
			end
			case align
			when 'C'
				dx = (w - width) / 2
			when 'R'
				if @rtl
					dx = @c_margin
				else
					dx = w - width - @c_margin
				end
			when 'L'
				if @rtl
					dx = w - width - @c_margin
				else
					dx = @c_margin
				end
			else # 'J'
				dx = @c_margin
			end

			if @rtl
				xdx = @x - dx - width
			else
				xdx = @x + dx
			end
			xdk = xdx * k
			# calculate approximate position of the font base line
			basefonty = @y + (h / 2) + (@font_size / 3)

			# print text
			s << sprintf('BT %.2f %.2f Td [(%s)] TJ ET', xdk, (@h - basefonty) * k, txt2)

			if @underline
				s << ' ' + dounderlinew(xdx, basefonty, width)
			end
			if @linethrough
				s << ' ' + dolinethroughw(xdx, basefonty, width)
			end
			if (@color_flag)
				s<<' Q';
			end
			if link && ((link.is_a?(String) and !link.empty?) or link.is_a? Fixnum)
				Link(xdx, @y + ((h - @font_size) / 2), width, @font_size, link, ns)
			end
		end

		# output cell
		if (s)
			# output cell
			rs << s
			# reset text stretching
			if stretch > 2
				# Reset character horizontal spacing
				rs << ' BT 0 Tc ET'
			elsif stretch > 0
				# Reset character horizontal scaling
				rs << ' BT 100 Tz ET'
			end
		end

		# reset word spacing
		if !((@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont0')) and (align == 'J')
			rs << ' BT 0 Tw ET'
		end

		@lasth = h;

		if (ln.to_i>0)
			# Go to the beginning of the next line
			@y += h;
			if (ln == 1)
				if @rtl
					@x = @w - @r_margin
				else
					@x = @l_margin
				end
			end
		else
			# go left or right by case
			if @rtl
				@x -= w
			else
				@x += w
			end
		end
		gstyles = '' + @linestyle_width + ' ' + @linestyle_cap + ' ' + @linestyle_join + ' ' + @linestyle_dash + ' ' + @draw_color + ' ' + @fill_color + "\n"
		rs = gstyles + rs
		return rs
	end

	#
	# This method allows printing text with line breaks.
	# They can be automatic (as soon as the text reaches the right border of the cell) or explicit (via the \n character). As many cells as necessary are output, one below the other.<br />
	# Text can be aligned, centered or justified. The cell block can be framed and the background painted.
	# @param float :w Width of cells. If 0, they extend up to the right margin of the page.
	# @param float :h Cell minimum height. The cell extends automatically if needed.
	# @param string :txt String to print
	# @param mixed :border Indicates if borders must be drawn around the cell block. The value can be either a number:<ul><li>0: no border (default)</li><li>1: frame</li></ul>or a string containing some or all of the following characters (in any order):<ul><li>L: left</li><li>T: top</li><li>R: right</li><li>B: bottom</li></ul>
	# @param string :align Allows to center or align the text. Possible values are:<ul><li>L or empty string: left align</li><li>C: center</li><li>R: right align</li><li>J: justification (default value when :ishtml=false)</li></ul>
	# @param int :fill Indicates if the cell background must be painted (1) or transparent (0). Default value: 0.
	# @param int :ln Indicates where the current position should go after the call. Possible values are:<ul><li>0: to the right</li><li>1: to the beginning of the next line [DEFAULT]</li><li>2: below</li></ul>
	# @param float :x x position in user units
	# @param float :y y position in user units
	# @param boolean :reseth if true reset the last cell height (default true).
	# @param int :stretch stretch carachter mode: <ul><li>0 = disabled</li><li>1 = horizontal scaling only if necessary</li><li>2 = forced horizontal scaling</li><li>3 = character spacing only if necessary</li><li>4 = forced character spacing</li></ul>
	# @param boolean :ishtml set to true if :txt is HTML content (default = false).
	# @param boolean :autopadding if true, uses internal padding and automatically adjust it to account for line width.
	# @param float :maxh maximum height. It should be >= :h and less then remaining space to the bottom of the page, or 0 for disable this feature. This feature works only when :ishtml=false.
	# @return int Rerurn the number of cells or 1 for html mode.
	# @access public
	# @since 1.3
	# @see SetFont(), SetDrawColor(), SetFillColor(), SetTextColor(), SetLineWidth(), Cell(), Write(), SetAutoPageBreak()
	#
	def MultiCell(w, h, txt, border=0, align='J', fill=0, ln=1, x='', y='', reseth=true, stretch=0, ishtml=false, autopadding=true, maxh=0)
		if empty_string(@lasth) or reseth
			# set row height
			@lasth = @font_size * @@k_cell_height_ratio
		end
		 
		if !empty_string(y)
			SetY(y)
		else
			y = GetY()
		end
		# check for page break
		checkPageBreak(h)
		y = GetY()
		# get current page number
		startpage = @page

		if !empty_string(x)
			SetX(x)
		else
			x = GetX()
		end

		if empty_string(w) or (w <= 0)
			if @rtl
				w = @x - @l_margin
			else
				w = @w - @r_margin - @x
			end
		end

		# store original margin values
		l_margin = @l_margin
		r_margin = @r_margin

		if @rtl
			SetRightMargin(@w - @x)
			SetLeftMargin(@x - w)
		else
			SetLeftMargin(@x)
			SetRightMargin(@w - @x - w)
		end

		starty = @y
		if autopadding
			# Adjust internal padding
			if @c_margin < (@line_width / 2)
				@c_margin = @line_width / 2
			end
			# Add top space if needed
			if (@lasth - @font_size) < @line_width
				@y += @line_width / 2
			end
			# add top padding
			@y += @c_margin
		end

		if ishtml
			# ******* Write HTML text
			writeHTML(txt, true, 0, reseth, true, align)
			nl = 1
		else
			# ******* Write text
			nl = Write(@lasth, txt, '', 0, align, true, stretch, false, true, maxh)
		end

		if autopadding
			# add bottom padding
			@y += @c_margin
			# Add bottom space if needed
			if (@lasth - @font_size) < @line_width
				@y += @line_width / 2
			end
		end

		# Get end-of-text Y position
		currentY = @y
		# get latest page number
		end_page = @page

		# check if a new page has been created
		if end_page > startpage
			# design borders around HTML cells.
			for page in startpage..end_page
				SetPage(page)
				if page == startpage
					@y = starty # put cursor at the beginning of cell on the first page
					h = GetPageHeight() - starty - GetBreakMargin()
					cborder = getBorderMode(border, position='start')
				elsif page == end_page
					@y = @t_margin # put cursor at the beginning of last page
					h = currentY - @t_margin
					cborder = getBorderMode(border, position='end')
				else
					@y = @t_margin # put cursor at the beginning of the current page
					h = GetPageHeight() - @t_margin - GetBreakMargin()
					cborder = getBorderMode(border, position='middle')
				end
				nx = x
				# account for margin changes
				if page > startpage
					if @rtl and (@pagedim[page]['orm'] != @pagedim[startpage]['orm'])
						nx = x + (@pagedim[page]['orm'] - @pagedim[startpage]['orm'])
					elsif !@rtl and (@pagedim[page]['olm'] != @pagedim[startpage]['olm'])
						nx = x + (@pagedim[page]['olm'] - @pagedim[startpage]['olm'])
					end
				end
				SetX(nx)
				ccode = getCellCode(w, h, '', cborder, 1, '', fill, '', 0, false)
				if (cborder != 0) or (fill == 1)
					pagebuff = getPageBuffer(@page)
					pstart = pagebuff[0, @intmrk[@page]]
					pend = pagebuff[@intmrk[@page]..-1]
					setPageBuffer(@page, pstart + ccode + "\n" + pend)
					@intmrk[@page] += (ccode + "\n").length
				end
			end
		else
			h = h > currentY - y ? h : currentY - y
			# put cursor at the beginning of text
			SetY(y)
			SetX(x)
			# design a cell around the text
			ccode = getCellCode(w, h, '', border, 1, '', fill, '', 0, true)
			if (border != 0) or (fill == 1)
				if !@transfmrk[@page].nil?
					pagemark = @transfmrk[@page]
					@transfmrk[@page] += (ccode + "\n").length
				elsif @in_footer
					pagemark = @footerpos[@page]
					@footerpos[@page] += (ccode + "\n").length
				else
					pagemark = @intmrk[@page]
					@intmrk[@page] += (ccode + "\n").length
				end
				pagebuff = getPageBuffer(@page)
				pstart = pagebuff[0, pagemark]
				pend = pagebuff[pagemark..-1]
				setPageBuffer(@page, pstart + ccode + "\n" + pend)
			end
		end
		
		# Get end-of-cell Y position
		currentY = GetY()

		# restore original margin values
		SetLeftMargin(l_margin)
		SetRightMargin(r_margin)

		if ln > 0
			# Go to the beginning of the next line
			SetY(currentY)
			if ln == 2
				SetX(x + w)
			end
		else
			# go left or right by case
			SetPage(startpage)
			@y = y
			SetX(x + w)
		end

		setContentMark()
		return nl
	end
  alias_method :multi_cell, :MultiCell

	#
	# Get the border mode accounting for multicell position (opens bottom side of multicell crossing pages)
	# @param mixed :border Indicates if borders must be drawn around the cell block. The value can be either a number:<ul><li>0: no border (default)</li><li>1: frame</li></ul>or a string containing some or all of the following characters (in any order):<ul><li>L: left</li><li>T: top</li><li>R: right</li><li>B: bottom</li></ul>
	# @param string multicell position: 'start', 'middle', 'end'
	# @return border mode
	# @access protected
	# @since 4.4.002 (2008-12-09)
	#
	def getBorderMode(border, position='start')
		if !@opencell and (border == 1)
			return 1
		end
		return 0 if border == 0
		cborder = ''
		case position
		when 'start'
			if border == 1
				cborder = 'LTR'
			else
				if nil != border.index('L')
					cborder << 'L'
				end
				if nil != border.index('T')
					cborder << 'T'
				end
				if nil != border.index('R')
					cborder << 'R'
				end
				if !@opencell and (nil != border.index('B'))
					cborder << 'B'
				end
			end
		when 'middle'
			if border == 1
				cborder = 'LR'
			else
				if nil != border.index('L')
					cborder << 'L'
				end
				if !@opencell and (nil != border.index('T'))
					cborder << 'T'
				end
				if nil != border.index('R')
					cborder << 'R'
				end
				if !@opencell and (nil != border.index('B'))
					cborder << 'B'
				end
			end
		when 'end'
			if border == 1
				cborder = 'LRB'
			else
				if nil != border.index('L')
					cborder << 'L'
				end
				if !@opencell and (nil != border.index('T'))
					cborder << 'T'
				end
				if nil != border.index('R')
					cborder << 'R'
				end
				if nil != border.index('B')
					cborder << 'B'
				end
			end
		else
			cborder = border
		end
		return cborder
	end

	#
	# This method prints text from the current position.<br />
	# @param float :h Line height
	# @param string :txt String to print
	# @param mixed :link URL or identifier returned by AddLink()
	# @param int :fill Indicates if the background must be painted (1) or transparent (0). Default value: 0.
	# @param string :align Allows to center or align the text. Possible values are:<ul><li>L or empty string: left align (default value)</li><li>C: center</li><li>R: right align</li><li>J: justify</li></ul>
	# @param boolean :ln if true set cursor at the bottom of the line, otherwise set cursor at the top of the line.
	# @param int :stretch stretch carachter mode: <ul><li>0 = disabled</li><li>1 = horizontal scaling only if necessary</li><li>2 = forced horizontal scaling</li><li>3 = character spacing only if necessary</li><li>4 = forced character spacing</li></ul>
	# @param boolean :firstline if true prints only the first line and return the remaining string.
	# @param boolean :firstblock if true the string is the starting of a line.
	# @param float :maxh maximum height. The remaining unprinted text will be returned. It should be >= :h and less then remaining space to the bottom of the page, or 0 for disable this feature.
	# @return mixed Return the number of cells or the remaining string if :firstline = true.
	# @since 1.5
	#
	def Write(h, txt, link=nil, fill=0, align='', ln=false, stretch=0, firstline=false, firstblock=false, maxh=0)
		txt.force_encoding('ASCII-8BIT') if txt.respond_to?(:force_encoding)
		if txt.length == 0
			txt = ' '
		end

		# remove carriage returns
		s = txt.gsub("\r", '');

		# check if string contains arabic text
		if s =~ @@k_re_pattern_arabic
			arabic = true
		else
			arabic = false
		end

		# check if string contains RTL text
		if arabic or (@tmprtl == 'R') or (txt =~ @@k_re_pattern_rtl)
			rtlmode = true
		else
			rtlmode = false
		end

		# get a char width
		chrwidth = GetCharWidth('.')
		# get array of unicode values
		chars = UTF8StringToArray(s)
		# get array of chars
		uchars = UTF8ArrayToUniArray(chars)

		# get the number of characters
		nb = chars.size

		# replacement for SHY character (minus symbol)
		shy_replacement = 45
		shy_replacement_char = unichr(shy_replacement)
		# widht for SHY replacement
		shy_replacement_width = GetCharWidth(shy_replacement)

		# store current position
		prevx = @x
		prevy = @y

		# max Y
		maxy = @y + maxh - h - (2 * @c_margin)

		# calculating remaining line width (w)
		if @rtl
			w = @x - @l_margin
		else
			w = @w - @r_margin - @x
		end
    
		# max column width
		wmax = w - (2 * @c_margin)
		if !firstline and (chrwidth > wmax or (GetCharWidth(chars[0]) > wmax))
			# a single character do not fit on column
			return ''
		end

		i = 0    # character position
		j = 0    # current starting position
		sep = -1 # position of the last blank space
		shy = false # true if the last blank is a soft hypen (SHY)
		l = 0    # current string length
		nl = 0   # number of lines
		linebreak = false

		pc = 0 # previous character
		# for each character
		while(i<nb)
			if (maxh > 0) and (@y >= maxy)
				break
			end
			# Get the current character
			c = chars[i]
			if (c == 10) # 10 = "\n" = new line
				#Explicit line break
				if align == 'J'
					if @rtl
						talign = 'R'
					else
						talign = 'L'
					end
				else
					talign = align
				end
				tmpstr = UniArrSubString(uchars, j, i)
				if firstline
					startx = @x
					tmparr = chars[j..i-1]
					if rtlmode
						tmparr = utf8Bidi(tmparr, tmpstr, @tmprtl)
					end
					linew = GetArrStringWidth(tmparr)
					if @rtl
						@endlinex = startx - linew
					else
						@endlinex = startx + linew
					end
					w = linew
					tmpcmargin = @c_margin
					if maxh == 0
						@c_margin = 0
					end
				end
				if firstblock and isRTLTextDir()
					tmpstr = tmpstr.rstrip
				end
				Cell(w, h, tmpstr, 0, 1, talign, fill, link, stretch)
				tmpstr = ''
				if firstline
					@c_margin = tmpcmargin
					return UniArrSubString(uchars, i)
				end
				nl += 1
				j = i + 1
				l = 0
				sep = -1
				shy = false;
				# account for margin changes
				if ((@y + @lasth) > @page_break_trigger) and !@in_footer
					# AcceptPageBreak() may be overriden on extended classed to include margin changes
					AcceptPageBreak()
				end
				w = getRemainingWidth()
				wmax = w - (2 * @c_margin)
			else 
				# 160 is the non-breaking space, 173 is SHY (Soft Hypen)
				if (c != 160) and ((unichr(c) =~ /\s/) or (c == 173))
					# update last blank space position
					sep = i
					# check if is a SHY
					if c == 173
						shy = true
						if pc == 45
							tmp_shy_replacement_width = 0
							tmp_shy_replacement_char = ''
						else
							tmp_shy_replacement_width = shy_replacement_width
							tmp_shy_replacement_char = shy_replacement_char
						end
					else 
						shy = false
					end
				end

				# update string length
				if ((@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont0')) and arabic
					# with bidirectional algorithm some chars may be changed affecting the line length
					# *** very slow ***
					l = GetArrStringWidth(utf8Bidi(chars[j..i-1], '', @tmprtl))
				else
					l += GetCharWidth(c)
				end

				if (l > wmax) or (shy and ((l + tmp_shy_replacement_width) > wmax))
					# we have reached the end of column
					if (sep == -1)
						# check if the line was already started
						if (@rtl and (@x <= @w - @r_margin - chrwidth)) or (!@rtl and (@x >= @l_margin + chrwidth))
							# print a void cell and go to next line
							Cell(w, h, '', 0, 1)
							linebreak = true
							if firstline
								return UniArrSubString(uchars, j)
							end
						else
							# truncate the word because do not fit on column
							tmpstr = UniArrSubString(uchars, j, i)
							if firstline
								startx = @x
								tmparr = chars[j..i-1]
								if rtlmode
									tmparr = utf8Bidi(tmparr, tmpstr, @tmprtl)
								end
								linew = GetArrStringWidth(tmparr)
								tmparr = ''
								if @rtl
									@endlinex = startx - linew
								else
									@endlinex = startx + linew
								end
								w = linew
								tmpcmargin = @c_margin
								if maxh == 0
									@c_margin = 0
								end
							end
							if firstblock and isRTLTextDir()
								tmpstr = tmpstr.rstrip
							end
							Cell(w, h, tmpstr, 0, 1, align, fill, link, stretch)
							tmpstr = ''
							if firstline
								@c_margin = tmpcmargin
								return UniArrSubString(uchars, i)
							end
							j = i
							i -= 1
						end
					else
						# word wrapping
						if @rtl and !firstblock
							endspace = 1
						else
							endspace = 0
						end
						if shy
							# add hypen (minus symbol) at the end of the line
							shy_width = tmp_shy_replacement_width
							if @rtl
								shy_char_left = tmp_shy_replacement_char
								shy_char_right = ''
							else
								shy_char_left = ''
								shy_char_right = tmp_shy_replacement_char
							end
						else
							shy_width = 0
							shy_char_left = ''
							shy_char_right = ''
						end
						tmpstr = UniArrSubString(uchars, j, sep + endspace)
						if firstline
							startx = @x
							tmparr = chars[j..sep+endspace-1]
							if rtlmode
								tmparr = utf8Bidi(tmparr, tmpstr, @tmprtl)
							end
							linew = GetArrStringWidth(tmparr)
							tmparr = ''
							if @rtl
								@endlinex = startx - linew - shy_width
							else
								@endlinex = startx + linew + shy_width
							end
							w = linew
							tmpcmargin = @c_margin
							if maxh == 0
								@c_margin = 0
							end
						end
						# print the line
						if firstblock and isRTLTextDir()
							tmpstr = tmpstr.rstrip
						end
						Cell(w, h, shy_char_left + tmpstr + shy_char_right, 0, 1, align, fill, link, stretch)
						tmpstr = ''
						if firstline
							# return the remaining text
							@c_margin = tmpcmargin
							return UniArrSubString(uchars, sep + endspace)
						end
						i = sep
						sep = -1
						shy = false
						j = i + 1
					end
					# account for margin changes
					if (@y + @lasth > @page_break_trigger) and !@in_footer
						# AcceptPageBreak() may be overriden on extended classed to include margin changes
						AcceptPageBreak()
					end
					w = getRemainingWidth()
					wmax = w - (2 * @c_margin)
					if linebreak
						linebreak = false
					else
						nl += 1
						l = 0
					end
				end
			end
			# save last character
			pc = c
			i +=1
		end # end while i < nb

		# print last substring (if any)
		if l > 0
			case align
			when 'J' , 'C'
				w = w
			when 'L'
				if @rtl
					w = w
				else
					w = l
				end
			when 'R'
				if @rtl
					w = l
				else
					w = w
				end
			else
				w = l
			end
			tmpstr = UniArrSubString(uchars, j, nb)
			if firstline
				startx = @x
				tmparr = chars[j..nb-1]
				if rtlmode
					tmparr = utf8Bidi(tmparr, tmpstr, @tmprtl)
				end
				linew = GetArrStringWidth(tmparr)
				tmparr = ''
				if @rtl
					@endlinex = startx - linew
				else
					@endlinex = startx + linew
				end
				w = linew
				tmpcmargin = @c_margin
				if maxh == 0
					@c_margin = 0
				end
			end
			if firstblock and isRTLTextDir()
				tmpstr = tmpstr.rstrip
			end
			Cell(w, h, tmpstr, 0, (ln ? 1 : 0), align, fill, link, stretch)
			tmpstr = ''
			if firstline
				@c_margin = tmpcmargin
				return UniArrSubString(uchars, nb)
			end
			nl += 1
		end

		if firstline
			return ''
		end
		return nl
	end
  alias_method :write, :Write

	#
	# Returns the remaining width between the current position and margins.
	# @return int Return the remaining width
	# @access protected
	#
	def getRemainingWidth()
		if @rtl
			return @x - @l_margin
		else
			return @w - @r_margin - @x
		end
	end

	#
	# Extract a slice of the :strarr array and return it as string.
	# @param string :strarr The input array of characters. (UCS4)
	# @param int :start the starting element of :strarr.
	# @param int :last first element that will not be returned.
	# @return Return part of a string (UTF-8)
	#
	def UTF8ArrSubString(strarr, start=0, last=strarr.size)
		string = ""
		start.upto(last - 1) do |i|
			string << unichr(strarr[i])
		end
		return string
	end

	#
	# Extract a slice of the :uniarr array and return it as string.
	# @param string :uniarr The input array of characters. (UTF-8)
	# @param int :start the starting element of :strarr.
	# @param int :last first element that will not be returned.
	# @return Return part of a string (UTF-8)
	# @access public
	# @since 4.5.037 (2009-04-07)
	#
	def UniArrSubString(uniarr, start=0, last=uniarr.length)
		string = ''
		start.upto(last - 1) do |i|
			string << uniarr[i]
		end
		return string
	end

	#
	# Convert an array of UTF8 values to array of unicode characters
	# @param string :ta The input array of UTF8 values. (UCS4)
	# @return Return array of unicode characters (UTF-8)
	# @access public
	# @since 4.5.037 (2009-04-07)
	#
	def UTF8ArrayToUniArray(ta)
		string = []
		ta.each do |i|
			string << unichr(i)
		end
		return string
	end

	#
	# Returns the unicode caracter specified by UTF-8 code
	# @param int :c UTF-8 code (UCS4)
	# @return Returns the specified character. (UTF-8)
	# @author Miguel Perez, Nicola Asuni
	# @since 2.3.000 (2008-03-05)
	#
	def unichr(c)
		if !@is_unicode
			return c.chr
		elsif c <= 0x7F
			# one byte
			return c.chr
		elsif c <= 0x7FF
			# two bytes
			return (0xC0 | c >> 6).chr + (0x80 | c & 0x3F).chr
		elsif c <= 0xFFFF
			# three bytes
			return (0xE0 | c >> 12).chr + (0x80 | c >> 6 & 0x3F).chr + (0x80 | c & 0x3F).chr
		elsif c <= 0x10FFFF
			# four bytes
			return (0xF0 | c >> 18).chr + (0x80 | c >> 12 & 0x3F).chr + (0x80 | c >> 6 & 0x3F).chr + (0x80 | c & 0x3F).chr
		else
			return ""
		end
	end

	#
	# Return the image type given the file name and path
	# @param string :imgfile image file name
	# @return string image type
	# @since 4.8.017 (2009-11-27)
	#
	def getImageFileType(imgfile)
		type = '' # default type
		return type if imgfile.nil?

		fileinfo = File::extname(imgfile)
		type = fileinfo.sub(/^\./, '').downcase if fileinfo != ''
		if type == 'jpg'
			type = 'jpeg'
		end
		return type
	end

	#
	# Puts an image in the page. 
	# The upper-left corner must be given. 
	# The dimensions can be specified in different ways:<ul>
	# <li>explicit width and height (expressed in user unit)</li>
	# <li>one explicit dimension, the other being calculated automatically in order to keep the original proportions</li>
	# <li>no explicit dimension, in which case the image is put at 72 dpi</li></ul>
	# Supported formats are PNG images whitout RMagick library and JPEG and GIF images supported by RMagick.
	# For JPEG, all flavors are allowed:<ul><li>gray scales</li><li>true colors (24 bits)</li><li>CMYK (32 bits)</li></ul>
	# For PNG, are allowed:<ul><li>gray scales on at most 8 bits (256 levels)</li><li>indexed colors</li><li>true colors (24 bits)</li></ul>
	# If a transparent color is defined, it will be taken into account (but will be only interpreted by Acrobat 4 and above).<br />
	# The format can be specified explicitly or inferred from the file extension.<br />
	# It is possible to put a link on the image.<br />
	# Remark: if an image is used several times, only one copy will be embedded in the file.<br />
	# @param string :file Name of the file containing the image.
	# @param float :x Abscissa of the upper-left corner.
	# @param float :y Ordinate of the upper-left corner.
	# @param float :w Width of the image in the page. If not specified or equal to zero, it is automatically calculated.
	# @param float :h Height of the image in the page. If not specified or equal to zero, it is automatically calculated.
	# @param string :type Image format. Possible values are (case insensitive): JPG, JPEG, PNG. If not specified, the type is inferred from the file extension.
	# @param mixed :link URL or identifier returned by AddLink().
	# @param string :align Indicates the alignment of the pointer next to image insertion relative to image height. The value can be:<ul><li>T: top-right for LTR or top-left for RTL</li><li>M: middle-right for LTR or middle-left for RTL</li><li>B: bottom-right for LTR or bottom-left for RTL</li><li>N: next line</li></ul>
	# @param mixed :resize If true resize (reduce) the image to fit :w and :h (requires RMagick library); if false do not resize; if 2 force resize in all cases (upscaling and downscaling).
	# @param int :dpi dot-per-inch resolution used on resize
	# @param string :palign Allows to center or align the image on the current line. Possible values are:<ul><li>L : left align</li><li>C : center</li><li>R : right align</li><li>'' : empty string : left for LTR or right for RTL</li></ul>
	# @param boolean :ismask true if this image is a mask, false otherwise
	# @param mixed :imgmask image object returned by this function or false
	# @param mixed :border Indicates if borders must be drawn around the image. The value can be either a number:<ul><li>0: no border (default)</li><li>1: frame</li></ul>or a string containing some or all of the following characters (in any order):<ul><li>L: left</li><li>T: top</li><li>R: right</li><li>B: bottom</li></ul>
	# @param boolean :fitbox If true scale image dimensions proportionally to fit within the (:w, :h) box.
	# @param boolean :hidden if true do not display the image.
	# @return image information
	# @access public
	# @since 1.1
	#
	def Image(file, x='', y='', w=0, h=0, type='', link=nil, align='', resize=false, dpi=300, palign='', ismask=false, imgmask=false, border=0, fitbox=false, hidden=false)
		x = @x if x == ''
		y = @y if y == ''

		# set bottomcoordinates
		@img_rb_y = y + h

		# get image dimensions
		size_info = getimagesize(file)
		return false if size_info == false

                pixw = size_info[0]
                pixh = size_info[1]

		# calculate image width and height on document
		if (w <= 0) and (h <= 0)
			# convert image size to document unit
			w = pixelsToUnits(pixw)
			h = pixelsToUnits(pixh)
		elsif w <= 0
			w = h * pixw / pixh
		elsif h <= 0
			h = w * pixh / pixw
		elsif fitbox and (w > 0) and (h > 0)
			# scale image dimensions proportionally to fit within the (:w, :h) box
			if ((w * pixh) / (h * pixw)) < 1
				h = w * pixh / pixw
			else
				w = h * pixw / pixh
			end
		end
		# resize image proportionally to be contained on a single page
		if h > @h
			h = @h
			w = h * pixw / pixh
		end
		if w > @w
			w = @w
			h = w * pixh / pixw
		end
		# Check whether we need a new page first as this does not fit
		prev_x = @x
		if checkPageBreak(h, y)
			# resize image to vertically fit the available space
			h = @page_break_trigger - y
			w = h * pixw / pixh
			y = GetY() # + @c_margin
			if @rtl
				x += prev_x - @x
			else
				x += @x - prev_x
			end
		end
		# resize image proportionally to be contained on a single page
		if x + w > @w
			w = @w - x
			h = w * pixh / pixw
		end
		# calculate new minimum dimensions in pixels
		neww = (w * @k * dpi / @dpi).round
		newh = (h * @k * dpi / @dpi).round
		# check if resize is necessary (resize is used only to reduce the image)
		newsize = neww * newh
		pixsize = pixw * pixh
		if resize == 2
			resize = true
		elsif newsize >= pixsize
			resize = false
		end

		# check if image has been already added on document
		newimage = true
		if @imagekeys.include?(file)
			newimage = false;
			# get existing image data
			info = getImageBuffer(file)
			# check if the newer image is larger
			oldsize = info['w'] * info['h']
			if ((oldsize < newsize) and resize) or ((oldsize < pixsize) and !resize)
				newimage = true
			end
		end
		if newimage
			#First use of image, get info
			if (type == '')
				type = getImageFileType(file)
			end

			info = false
			if !resize or !Object.const_defined?(:Magick)
				if (type == 'jpeg')
					info=parsejpeg(file)
				elsif (type == 'png')
					info=parsepng(file);
				elsif (type == 'gif')
					tmpFile = imageToPNG(file)
					info=parsepng(tmpFile.path)
					tmpFile.delete
				else
					#Allow for additional formats
					mtd='parse' + type;
					if (!self.respond_to?(mtd))
						Error('Unsupported image type: ' + type);
					end
					info=send(mtd, file);
				end
				# not use
				#if info == 'pngalpha'
				#	return ImagePngAlpha(file, x, y, w, h, 'PNG', link, align, resize, dpi, palign)
				#end
			end
			if !info
				if Object.const_defined?(:Magick)
					# RMagick library
					img = Magick::ImageList.new(file)
					if resize
						img.resize(neww,newh)
					end
					img.format = 'JPEG'
					tmpname = Tempfile.new(File::basename(file), @@k_path_cache)
					tmpname.binmode
					jpeg_quality = @jpeg_quality
					tmpname.print img.to_blob { self.quality = jpeg_quality }
                			tmpname.close

					info = parsejpeg(tmpname.path)
					tmpname.delete
				else
					return false
				end
			end

			if info == false
				# If false, we cannot process image
				return false
			end
			if ismask
				# force grayscale
				info['cs'] = 'DeviceGray'
			end
			info['i'] = @numimages
			if !@imagekeys.include?(file)
				info['i'] += 1
			end
			if imgmask != false
				info['masked'] = imgmask
			end
			# add image to document
			setImageBuffer(file, info)
		end

		# set bottomcoordinates
		@img_rb_y = y + h
		# set alignment
		if @rtl
			if palign == 'L'
				ximg = @l_margin
				# set right side coordinate
				@img_rb_x = ximg + w
			elsif palign == 'C'
				ximg = (@w - x - w) / 2
				# set right side coordinate
				@img_rb_x = ximg + w
			else
				ximg = @w - x - w
				# set left side coordinate
				@img_rb_x = ximg
			end
		else
			if palign == 'R'
				ximg = @w - @r_margin - w
				# set left side coordinate
				@img_rb_x = ximg
			elsif palign == 'C'
				ximg = (@w - x - w) / 2
				# set right side coordinate
				@img_rb_x = ximg + w
			else
				ximg = x
				# set right side coordinate
				@img_rb_x = ximg + w
			end
		end
		if ismask or hidden
			# image is not displayed
			return info['i']
		end
		xkimg = ximg * @k
		out(sprintf('q %.2f 0 0 %.2f %.2f %.2f cm /I%d Do Q', w * @k, h * @k, xkimg, (@h -(y + h)) * @k, info['i']))

		if border != 0
			bx = x
			by = y
			@x = ximg
			if @rtl
				@x += w
			end
			@y = y
			Cell(w, h, '', border, 0, '', 0, '', 0)
			@x = bx
			@y = by
		end

		if link and !link.empty?
			Link(ximg, y, w, h, link)
		end

		# set pointer to align the successive text/objects
		case align
		when 'T'
			@y = y
			@x = @img_rb_x
		when 'M'
			@y = y + (h/2).round
			@x = @img_rb_x
		when 'B'
			@y = @img_rb_y
			@x = @img_rb_x
		when 'N'
			SetY(@img_rb_y)
		end
		@endlinex = @img_rb_x
		return info['i']
	end
  alias_method :image, :Image

	#
	# Performs a line break. 
	# The current abscissa goes back to the left margin and the ordinate increases by the amount passed in parameter.
	# @param float :h The height of the break. By default, the value equals the height of the last printed cell.
	# @param boolean :cell if true add a cMargin to the x coordinate
	# @since 1.0
	# @see Cell()
	#
	def Ln(h='', cell=false)
		# Line feed; default value is last cell height
		cellmargin = 0
		if cell
			cellmargin = @c_margin
		end
		if @rtl
			@x = @w - @r_margin - cellmargin
		else
			@x = @l_margin + cellmargin
		end
		if h.is_a?(String)
			@y += @lasth
		else
			@y += h
		end
		@newline = true
	end
  alias_method :ln, :Ln

	#
	# Returns the relative X value of current position.
	# The value is relative to the left border for LTR languages and to the right border for RTL languages.
	# @return float
	# @since 1.2
	# @see SetX(), GetY(), SetY()
	#
	def GetX()
		#Get x position
		if @rtl
			return @w - @x
		else
			return @x
		end
	end
  alias_method :get_x, :GetX

	#
	# Defines the abscissa of the current position.
	# If the passed value is negative, it is relative to the right of the page (or left if language is RTL).
	# @param float :x The value of the abscissa.
	# @access public
	# @since 1.2
	# @see GetX(), GetY(), SetY(), SetXY()
	#
	def SetX(x)
		#Set x position
		if @rtl
			if x >= 0
				@x = @w - x
			else
				@x = x.abs
			end
		else
			if x >= 0
				@x = x
			else
				@x = @w + x
			end
		end
	end
  alias_method :set_x, :SetX

	#
	# Returns the ordinate of the current position.
	# @return float
	# @since 1.0
	# @see SetY(), GetX(), SetX()
	#
	def GetY()
		#Get y position
		return @y;
	end
  alias_method :get_y, :GetY

	#
	# Returns the absolute X value of current position.
	# @return float
	# @since 1.2
	# @see SetY(), GetX(), SetX()
	#
	def GetAbsX()
		return @x
	end
  alias_method :get_abs_x, :GetAbsX

	#
	# Moves the current abscissa back to the left margin and sets the ordinate.
	# If the passed value is negative, it is relative to the bottom of the page.
	# @param float :y The value of the ordinate.
	# @since 1.0
	# @see GetX(), GetY(), SetY(), SetXY()
	#
	def SetY(y)
		#Set y position and reset x
		if @rtl
			@x = @w - @r_margin
		else
			@x = @l_margin
		end
		if (y>=0)
			@y = y;
		else
			@y=@h+y;
		end
	end
  alias_method :set_y, :SetY

	#
	# Defines the abscissa and ordinate of the current position. If the passed values are negative, they are relative respectively to the right and bottom of the page.
	# @param float :x The value of the abscissa
	# @param float :y The value of the ordinate
	# @since 1.2
	# @see SetX(), SetY()
	#
	def SetXY(x, y)
		#Set x and y positions
		SetY(y);
		SetX(x);
	end
  alias_method :set_xy, :SetXY

	#
	# Send the document to a given destination: string, local file or browser.
	# In the last case, the plug-in may be used (if present) or a download ("Save as" dialog box) may be forced.<br />
	# The method first calls Close() if necessary to terminate the document.
	# @param string :name The name of the file when saved. Note that special characters are removed and blanks characters are replaced with the underscore character.
	# @param string :dest Destination where to send the document. It can take one of the following values:<ul><li>I: send the file inline to the browser (default). The plug-in is used if available. The name given by name is used when one selects the "Save as" option on the link generating the PDF.</li><li>D: send to the browser and force a file download with the name given by name.</li><li>F: save to a local file with the name given by name.</li><li>S: return the document as a string. name is ignored.</li></ul>
	# @access public
	# @since 1.0
	# @see Close()
	#
	def Output(name='', dest='')
		#Output PDF to some destination
		#Finish document if necessary
		LastPage()
		if (@state < 3)
			Close();
		end
		#Normalize parameters
		# Boolean no longer supported
		# if (dest.is_a?(Boolean))
		# 	dest = dest ? 'D' : 'F';
		# end
		dest = dest.upcase
		if (dest=='')
			if (name=='')
				name='doc.pdf';
				dest='I';
			else
				dest='F';
			end
		end
		case (dest)
			when 'I'
			  # This is PHP specific code
				##Send to standard output
				# if (ob_get_contents())
				# 	Error('Some data has already been output, can\'t send PDF file');
				# end
				# if (php_sapi_name()!='cli')
				# 	#We send to a browser
				# 	header('Content-Type: application/pdf');
				# 	if (headers_sent())
				# 		Error('Some data has already been output to browser, can\'t send PDF file');
				# 	end
				# 	header('Content-Length: ' + @buffer.length);
				# 	header('Content-disposition: inline; filename="' + name + '"');
				# end
				return getBuffer
			when 'D'
			  # PHP specific
				#Download file
				# if (ob_get_contents())
				# 	Error('Some data has already been output, can\'t send PDF file');
				# end
				# if (!_SERVER['HTTP_USER_AGENT'].nil? && SERVER['HTTP_USER_AGENT'].include?('MSIE'))
				# 	header('Content-Type: application/force-download');
				# else
				# 	header('Content-Type: application/octet-stream');
				# end
				# if (headers_sent())
				# 	Error('Some data has already been output to browser, can\'t send PDF file');
				# end
				# header('Content-Length: '+ @buffer.length);
				# header('Content-disposition: attachment; filename="' + name + '"');
				return getBuffer
			when 'F'
				# Save PDF to a local file
				if @diskcache
					FileUtils.copy(@buffer.path, name)
				else
					open(name,'wb') do |f|
						f.write(@buffer)
					end
				end
			when 'S'
				# Returns PDF as a string
				return getBuffer
			else
				Error('Incorrect output destination: ' + dest);
			
		end
		return '';
	ensure
		destroy(true)
	end
  alias_method :output, :Output

	#
	# Unset all class variables except the following critical variables: internal_encoding, state, bufferlen, buffer and diskcache.
	# @param boolean :destroyall if true destroys all class variables, otherwise preserves critical variables.
	# @param boolean :preserve_objcopy if true preserves the objcopy variable
	# @access public
	#
	def destroy(destroyall=false, preserve_objcopy=false)
		if destroyall and @diskcache and !preserve_objcopy and !empty_string(@buffer.path)
			# remove buffer file from cache
			File.delete(@buffer.path)
		end
		self.instance_variables.each { |val|
			if destroyall or ((val != '@internal_encoding') and (val != '@state') and (val != '@bufferlen') and (val != '@buffer') and (val != '@diskcache') and (val != '@sign') and (val != '@signature_data') and (val != '@signature_max_length') and (val != '@byterange_string'))
				if !preserve_objcopy or (val.to_s != '@objcopy')
					eval("#{val} = nil")
				end
			end
		}
	end

	# Protected methods

	#
	# Check for locale-related bug
	# @access protected
	#
	def dochecks()
		#Check for locale-related bug
		if (1.1==1)
			Error('Don\'t alter the locale before including class file');
		end
		#Check for decimal separator
		if (sprintf('%.1f',1.0)!='1.0')
			setlocale(LC_NUMERIC,'C');
		end
	end

	#
	# Return fonts path
	# @access protected
	#
	def getfontpath(file)
		# Is it in the @@font_path?
		if @@font_path
			fpath = File.join @@font_path, file
			if File.exists?(fpath)
				return fpath
			end
		end
		# Is it in this plugin's font folder?
		fpath = File.join File.dirname(__FILE__), 'fonts', file
		if File.exists?(fpath)
			return fpath
		end
		# Could not find it.
		nil
	end

	#
	# Start document
	# @access protected
	#
	def begindoc()
		#Start document
		@state=1;
		out('%PDF-' + @pdf_version)
	end

	#
	# putpages
	# @access protected
	#
	def putpages()
		nb = @numpages
		if @alias_nb_pages
			nbs = formatPageNumber(nb)
			nbu = UTF8ToUTF16BE(nbs, false) # replacement for unicode font
			alias_a = escape(@alias_nb_pages)
			alias_au = escape('{' + @alias_nb_pages + '}')
			if @is_unicode
				alias_b = escape(UTF8ToLatin1(@alias_nb_pages))
				alias_bu = escape(UTF8ToLatin1('{' + @alias_nb_pages + '}'))
				alias_c = escape(utf8StrRev(@alias_nb_pages, false, @tmprtl))
				alias_cu = escape(utf8StrRev('{' + @alias_nb_pages + '}', false, @tmprtl))
			end
		end
		if @alias_num_page
			alias_pa = escape(@alias_num_page)
			alias_pau = escape('{' + @alias_num_page + '}')
			if @is_unicode
				alias_pb = escape(UTF8ToLatin1(@alias_num_page))
				alias_pbu = escape(UTF8ToLatin1('{' + @alias_num_page + '}'))
				alias_pc = escape(utf8StrRev(@alias_num_page, false, @tmprtl))
				alias_pcu = escape(utf8StrRev('{' + @alias_num_page + '}', false, @tmprtl))
			end
		end
		pagegroupnum = 0
		filter=(@compress) ? '/Filter /FlateDecode ' : ''
		1.upto(nb) do |n|
			temppage = getPageBuffer(n)
			if !@pagegroups.empty?
				if !@newpagegroup[n].nil?
					pagegroupnum = 0
				end
				pagegroupnum += 1
				@pagegroups.each_with_index { |v, k|
					# replace total pages group numbers
					vs = formatPageNumber(v)
					vu = UTF8ToUTF16BE(vs, false)
					alias_ga = escape(k)
					alias_gau = escape('{' + k + '}')
					if @is_unicode
						alias_gb = escape(UTF8ToLatin1(k))
						alias_gbu = escape(UTF8ToLatin1('{' + k + '}'))
						alias_gc = escape(utf8StrRev(k, false, @tmprtl))
						alias_gcu = escape(utf8StrRev('{' + k + '}', false, @tmprtl))
					end
					temppage = temppage.gsub(alias_gau, vu)
					if @is_unicode
						temppage = temppage.gsub(alias_gbu, vu)
						temppage = temppage.gsub(alias_gcu, vu)
						temppage = temppage.gsub(alias_gb, vs)
						temppage = temppage.gsub(alias_gc, vs)
					end
					temppage = temppage.gsub(alias_ga, vs)
					# replace page group numbers
					pvs = formatPageNumber(pagegroupnum)
					pvu = UTF8ToUTF16BE(pvs, false)
					pk = k.gsub('{nb', '{pnb')
					alias_pga = escape(pk)
					alias_pgau = escape('{' + pk + '}')
					if @is_unicode
						alias_pgb = escape(UTF8ToLatin1(pk))
						alias_pgbu = escape(UTF8ToLatin1('{' + pk + '}'))
						alias_pgc = escape(utf8StrRev(pk, false, @tmprtl))
						alias_pgcu = escape(utf8StrRev('{' + pk + '}', false, @tmprtl))
					end
					temppage = temppage.gsub(alias_pgau, pvu)
					if @is_unicode
						temppage = temppage.gsub(alias_pgbu, pvu)
						temppage = temppage.gsub(alias_pgcu, pvu)
						temppage = temppage.gsub(alias_pgb, pvs)
						temppage = temppage.gsub(alias_pgc, pvs)
					end
					temppage = temppage.gsub(alias_pga, pvs)
				}
			end
			if @alias_nb_pages
				# replace total pages number
				temppage = temppage.gsub(alias_au, nbu)
				if @is_unicode
					temppage = temppage.gsub(alias_bu, nbu)
					temppage = temppage.gsub(alias_cu, nbu)
					temppage = temppage.gsub(alias_b, nbs)
					temppage = temppage.gsub(alias_c, nbs)
				end
				temppage = temppage.gsub(alias_a, nbs)
			end
			if @alias_num_page
				# replace page number
				pnbs = formatPageNumber(n)
				pnbu = UTF8ToUTF16BE(pnbs, false) # replacement for unicode font
				temppage = temppage.gsub(alias_pau, pnbu)
				if @is_unicode
					temppage = temppage.gsub(alias_pbu, pnbu)
					temppage = temppage.gsub(alias_pcu, pnbu)
					temppage = temppage.gsub(alias_pb, pnbs)
					temppage = temppage.gsub(alias_pc, pnbs)
				end
				temppage = temppage.gsub(alias_pa, pnbs)
			end
			temppage = temppage.gsub(@epsmarker, '')
			#Page
			@page_obj_id[n] = newobj()
			out('<</Type /Page')
			out('/Parent 1 0 R')
			out(sprintf('/MediaBox [0 0 %.2f %.2f]', @pagedim[n]['w'], @pagedim[n]['h']))
			out('/Resources 2 0 R')
			putannotsrefs(n)
			out('/Contents ' + (@n+1).to_s + ' 0 R>>');
			out('endobj');
			#Page content
			p=(@compress) ? gzcompress(temppage) : temppage
			newobj();
			out('<<' + filter + '/Length '+ p.length.to_s + '>>');
			putstream(p);
			out('endobj');
			if @diskcache
				# remove temporary files
				File.delete(@pages[n].path)
			end
		end
		#Pages root
		@offsets[1]=@bufferlen
		out('1 0 obj');
		out('<</Type /Pages');
		out('/Kids [')
		@page_obj_id.each { |page_obj|
			out(page_obj.to_s + ' 0 R') unless page_obj.nil?
		}
		out(']')
		out('/Count ' + nb.to_s);
		out('>>');
		out('endobj');
	end

	#
	# Output referencees to page annotations
	# @param int :n page number
	# @access protected
	# @author Nicola Asuni
	# @since 4.7.000 (2008-08-29)
	#
	def putannotsrefs(n)
		unless @page_annots[n] or (@sign and @signature_data['cert_type'])
			return
		end
		out('/Annots [')
		if @page_annots[n]
			num_annots = @page_annots[n].length
			0.upto(num_annots - 1) do |i|
				@curr_annot_obj_id += 1
				if !@radio_groups.include?(@curr_annot_obj_id)
					out(@curr_annot_obj_id.to_s + ' 0 R')
				else
					num_annots += 1
				end
			end
		end

		if (n == 1) and @sign and @signature_data['cert_type']
			# set reference for signature object
			out(@sig_annot_ref)
		end
		out(']')
	end

	#
	# Output annotations objects for all pages.
	# !!! THIS METHOD IS NOT YET COMPLETED !!!
	# See section 12.5 of PDF 32000_2008 reference.
	# @access protected
	# @author Nicola Asuni
	# @since 4.0.018 (2008-08-06)
	#
	def putannotsobjs()
		# reset object counter
		@annot_obj_id = @annots_start_obj_id
		1.upto(@numpages) do |n|
			if !@page_annots[n].nil?
				# set page annotations
				@page_annots[n].each_with_index { |pl, key|
					# create annotation object for grouping radiobuttons
					if @radiobutton_groups[n] and @radiobutton_groups[n][pl['txt']] and @radiobutton_groups[n][pl['txt']].is_a?(Array)
						annots = '<<'
						annots << ' /Type /Annot'
						annots << ' /Subtype /Widget'
						annots << ' /T ' + dataannobjstring(pl['txt'])
						annots << ' /FT /Btn'
						annots << ' /Ff 49152'
						annots << ' /Kids ['
						@radiobutton_groups[n][pl['txt']].each {|data|
							annots << ' ' + data['kid'] + ' 0 R'
							if data['def'] != 'Off'
								defval = data['def']
							end
						}
						annots << ' ]'
						if defval
							annots << ' /V /' + defval
						end
						annots << ' >>'
						@annot_obj_id += 1
						@offsets[@annot_obj_id] = @bufferlen
						out(@annot_obj_id + ' 0 obj')
						out(annots)
						out('endobj')
						@form_obj_id.push = @annot_obj_id
						# store object id to be used on Parent entry of Kids
						@radiobutton_groups[n][pl['txt']] = @annot_obj_id
					end

					formfield = false
					pl['opt'] = pl['opt'].inject({}) do |pl_opt, keys|
						pl_opt[keys[0].downcase] = keys[1]
						pl_opt
					end
					a = pl['x'] * @k
					b = @pagedim[n]['h'] - ((pl['y'] + pl['h'])  * @k)
					c = pl['w'] * @k
					d = pl['h'] * @k
					rect = sprintf('%.2f %.2f %.2f %.2f', a, b, a + c, b + d)
					# create new annotation object
					annots = '<</Type /Annot'
					annots << ' /Subtype /' + pl['opt']['subtype']
					annots << ' /Rect [' + rect + ']'
					ft = ['Btn', 'Tx', 'Ch', 'Sig']
					if pl['opt']['ft'] and ft.include?(pl['opt']['ft'])
						annots << ' /FT /' + pl['opt']['ft']
						formfield = true
					end
					annots << ' /Contents ' + textstring(pl['txt'])
					annots << ' /P ' + @page_obj_id[n].to_s + ' 0 R'
					annots << ' /NM ' + dataannobjstring(sprintf('%04u-%04u', n, key))
					annots << ' /M ' + datestring()
					if !pl['opt']['f'].nil?
						val = 0
						if pl['opt']['f'].is_a?(Array)
							pl['opt']['f'].each {|f|
								case f.downcase
								when 'invisible'
									val += 1 << 0
								when 'hidden'
									val += 1 << 1
								when 'print'
									val += 1 << 2
								when 'nozoom'
									val += 1 << 3
								when 'norotate'
									val += 1 << 4
								when 'noview'
									val += 1 << 5
								when 'readonly'
									val += 1 << 6
								when 'locked'
									val += 1 << 8
								when 'togglenoview'
									val += 1 << 9
								when 'lockedcontents'
									val += 1 << 10
								end
							}
						else
							val = pl['opt']['f'].to_i
						end
						annots << ' /F ' + val.to_i
					end
					# annots << ' /AP '
					# annots << ' /AS '
					if pl['opt']['as'] and pl['opt']['as'].is_a?(String)
						annots << ' /AS /' + pl['opt']['as']
					end
					if pl['opt']['ap']
						# appearance stream
						annots << ' /AP << ' + pl['opt']['ap'] + ' >>'
						annots << ' /AP <<'
						if pl['opt']['ap'].is_a?(Hash)
							pl['opt']['ap'].each {|apmode, apdef|
								# apmode can be: n = normal; r = rollover; d = down
								annots << ' /' + apmode.upcase
								if apdef.is_a?(Array)
									annots << ' <<'
									apdef.each {|apstate, stream|
										# reference to XObject that define the appearance for this mode-state
										apsobjid = putAPXObject(c, d, stream)
										annots << ' /' + apstate + ' ' + apsobjid + ' 0 R'
									}
									annots << ' >>'
								else
									# reference to XObject that define the appearance for this mode
									apsobjid = putAPXObject(c, d, apdef)
									annots << ' ' + apsobjid + ' 0 R'
								end
							}
						else
							annots << pl['opt']['ap']
						end
						annots << ' >>'
					end
					if !pl['opt']['bs'].nil? and pl['opt']['bs'].is_a?(Hash)
						annots << ' /BS <<'
						annots << ' /Type /Border'
						if !pl['opt']['bs']['w'].nil?
							annots << ' /W ' + pl['opt']['bs']['w'].to_i
						end
						bstyles = ['S', 'D', 'B', 'I', 'U']
						if !pl['opt']['bs']['s'].nil? and bstyles.include?(pl['opt']['bs']['s'])
							annots << ' /S /' + pl['opt']['bs']['s']
						end
						if !pl['opt']['bs']['d'].nil? and pl['opt']['bs']['d'].is_a?(Array)
							annots << ' /D ['
							pl['opt']['bs']['d'].each {|cord|
								annots << ' ' + cord.to_i.to_s
							}
							annots << ']'
						end
						annots << ' >>'
					else
						annots << ' /Border ['
						if !pl['opt']['border'].nil? and (pl['opt']['border'].length >= 3)
							annots << pl['opt']['border'][0].to_i + ' '
							annots << pl['opt']['border'][1].to_i + ' '
							annots << pl['opt']['border'][2].to_i
							if pl['opt']['border'][3].nil? and pl['opt']['border'][3].is_a?(Array)
								annots << ' ['
								pl['opt']['border'][3].each {|dash|
									annots << dash.to_i + ' '
								}
								annots << ']'
							end
						else
							annots << '0 0 0'
						end
						annots << ']'
					end
					if !pl['opt']['be'].nil? and pl['opt']['be'].is_a?(Hash)
						annots << ' /BE <<'
						bstyles = ['S', 'C']
						if !pl['opt']['be']['s'].nil? and markups.include?(pl['opt']['be']['s'])
							annots << ' /S /' + pl['opt']['bs']['s']
						else
							annots << ' /S /S'
						end
						if !pl['opt']['be']['i'].nil? and (pl['opt']['be']['i'] >= 0) and (pl['opt']['be']['i'] <= 2)
							annots << ' /I ' + sprintf(" %.4f", pl['opt']['be']['i'])
						end
						annots << '>>'
					end
					if !pl['opt']['c'].nil? and pl['opt']['c'].is_a?(Array) and !pl['opt']['c'].empty?
						annots << ' /C ['
						pl['opt']['c'].each {|col|
							col = col.to_i
							color = col <= 0 ? 0 : (col >= 255 ? 1 : col / 255)
							annots << sprintf(" %.4f", color)
						}
						annots << ']'
					end
					# annots << ' /StructParent '
					# annots << ' /OC '
					markups = ['text', 'freetext', 'line', 'square', 'circle', 'polygon', 'polyline', 'highlight',  'underline', 'squiggly', 'strikeout', 'stamp', 'caret', 'ink', 'fileattachment', 'sound']
					if markups.include?(pl['opt']['subtype'].downcase)
						# this is a markup type
						if !pl['opt']['t'].nil? and pl['opt']['t'].is_a?(String)
							annots << ' /T ' + textstring(pl['opt']['t'])
						end
						# annots .= ' /Popup '
						if !pl['opt']['ca'].nil?
							annots << ' /CA ' + sprintf("%.4f", pl['opt']['ca'].to_f)
						end
						if !pl['opt']['rc'].nil?
							annots << ' /RC ' + textstring(pl['opt']['rc'])
						end
						annots << ' /CreationDate ' + datestring()
						# annots << ' /IRT '
						if !pl['opt']['subj'].nil?
							annots << ' /Subj ' + textstring(pl['opt']['subj'])
						end
						# annots << ' /RT '
						# annots << ' /IT '
						# annots << ' /ExData '
					end

					lineendings = ['Square', 'Circle', 'Diamond', 'OpenArrow', 'ClosedArrow', 'None', 'Butt', 'ROpenArrow', 'RClosedArrow', 'Slash']
					case pl['opt']['subtype'].downcase
					when 'text'
						if !pl['opt']['open'].nil?
							annots << ' /Open ' + (pl['opt']['open'].downcase == 'true' ? 'true' : 'false')
						end
						iconsapp = ['Comment', 'Help', 'Insert', 'Key', 'NewParagraph', 'Note', 'Paragraph']
						if !pl['opt']['name'].nil? and iconsapp.include?(pl['opt']['name'])
							annots << ' /Name /' + pl['opt']['name']
						else
							annots << ' /Name /Note'
						end
						statemodels = ['Marked', 'Review']
						if !pl['opt']['statemodel'].nil? and statemodels.include?(pl['opt']['statemodel'])
							annots << ' /StateModel /' + pl['opt']['statemodel']
						else
							pl['opt']['statemodel'] = 'Marked'
							annots << ' /StateModel /' + pl['opt']['statemodel']
						end
						if pl['opt']['statemodel'] == 'Marked'
							states = ['Accepted', 'Unmarked']
						else
							states = ['Accepted', 'Rejected', 'Cancelled', 'Completed', 'None']
						end
						if !pl['opt']['state'].nil? and states.include?(pl['opt']['state'])
							annots << ' /State /' + pl['opt']['state']
						else
							if pl['opt']['statemodel'] == 'Marked'
								annots << ' /State /Unmarked'
							else
								annots << ' /State /None'
							end
						end
					when 'link'
						if pl['txt'].is_a?(String)
							# external URI link
							annots << ' /A <</S /URI /URI ' + dataannobjstring(unhtmlentities(pl['txt'])) + '>>'
						else
							# internal link
							l = @links[pl['txt']]
							annots << sprintf(' /Dest [%d 0 R /XYZ 0 %.2f null]', 1 + (2 * l[0]), @pagedim[l[0]]['h'] - (l[1] * @k))
						end
						hmodes = ['N', 'I', 'O', 'P']
						if !pl['opt']['h'].nil? and hmodes.include?(pl['opt']['h'])
							annots << ' /H /' + pl['opt']['h']
						else
							annots << ' /H /I'
						end
						# annots << ' /PA '
						# annots << ' /Quadpoints '
					when 'freetext'
						if pl['opt']['da'] and !pl['opt']['da'].empty?
							annots << ' /DA (' + pl['opt']['da'] + ')'
						end
						if !pl['opt']['q'].nil? and (pl['opt']['q'] >= 0) and (pl['opt']['q'] <= 2)
							annots << ' /Q ' + pl['opt']['q'].to_i
						end
						if !pl['opt']['rc'].nil?
							annots << ' /RC ' + textstring(pl['opt']['rc'])
						end
						if !pl['opt']['ds'].nil?
							annots << ' /DS ' + textstring(pl['opt']['ds'])
						end
						if !['opt']['cl'].nil? and pl['opt']['cl'].is_a?(Array)
							annots << ' /CL ['
							pl['opt']['cl'].each {|cl|
								annots << sprintf("%.4f ", cl * @k)
							}
							annots << ']'
						end
						tfit = ['FreeText', 'FreeTextCallout', 'FreeTextTypeWriter']
						if !pl['opt']['it'].nil? and tfit.include?(pl['opt']['it'])
							annots << ' /IT ' + pl['opt']['it']
						end
						if !pl['opt']['rd'].nil? and pl['opt']['rd'].is_a?(Array)
							l = pl['opt']['rd'][0] * @k
							r = pl['opt']['rd'][1] * @k
							t = pl['opt']['rd'][2] * @k
							b = pl['opt']['rd'][3] * @k
							annots << ' /RD [' + sprintf('%.2f %.2f %.2f %.2f', l, r, t, b) + ']'
						end
						if pl['opt']['le'] and lineendings.include?(pl['opt']['le'])
							annots << ' /LE /' + pl['opt']['le']
						end
					# ... to be completed ...
					when 'fileattachment'
						if pl['opt']['fs'].nil?
							break
						end
						filename = File.basename(pl['opt']['fs'])
						if !@embeddedfiles[filename]['n'].nil?
							annots << ' /FS <</Type /Filespec /F ' + dataannobjstring(filename) + ' /EF <</F ' + @embeddedfiles[filename]['n'].to_s + ' 0 R>> >>'
							iconsapp = ['Graph', 'Paperclip', 'PushPin', 'Tag']
							if !pl['opt']['name'].nil? and iconsapp.include?(pl['opt']['name'])
								annots << ' /Name /' + pl['opt']['name']
							else
								annots << ' /Name /PushPin'
							end	
						end	
					when 'sound'
						if pl['opt']['fs'].nil?
							break
						end
						filename = File.basename(pl['opt']['fs'])
						if !@embeddedfiles[filename]['n'].nil?
							# ... TO BE COMPLETED ...
							# /R /C /B /E /CO /CP
							annots << ' /Sound <</Type /Filespec /F ' + dataannobjstring(filename) + ' /EF <</F ' + @embeddedfiles[filename]['n'] + ' 0 R>> >>'
							iconsapp = ['Speaker', 'Mic']
							if !pl['opt']['name'].nil? and iconsapp.include?(pl['opt']['name'])
								annots << ' /Name /' + pl['opt']['name']
							else
								annots << ' /Name /Speaker'
							end
						end
					when 'widget'
						hmode = ['N', 'I', 'O', 'P', 'T']
						if pl['opt']['h'] and hmode.include?(pl['opt']['h'])
							annots << ' /H /' + pl['opt']['h']
						end
						if pl['opt']['mk'] and pl['opt']['mk'].is_a?(Hash) and !pl['opt']['mk'].empty?
							annots << ' /MK <<'
							if pl['opt']['mk']['r']
								annots << ' /R ' + pl['opt']['mk']['r']
							end
							if pl['opt']['mk']['bc'] and (pl['opt']['mk']['bc'] != false)
								annots << ' /BC ['
								pl['opt']['mk']['bc'].each {|col|
									col = col.to_i
									color = col <= 0 ? 0 : (col >= 255 ? 1 : col / 255)
									annots << sprintf(' %.2f', color)
								}
								annots << ']'
							end
							if pl['opt']['mk']['bg'] and (pl['opt']['mk']['bg'] != false)
								annots << ' /BG ['
								pl['opt']['mk']['bg'].each {|col|
									col = col.to_i
									color = col <= 0 ? 0 : (col >= 255 ? 1 : col / 255)
									annots << sprintf(' %.2f', color)
								}
								annots << ']'
							end
							if pl['opt']['mk']['ca']
								annots << ' /CA ' + pl['opt']['mk']['ca'] + ''
							end
							if pl['opt']['mk']['rc']
								annots << ' /RC ' + pl['opt']['mk']['ca'] + ''
							end
							if pl['opt']['mk']['ac']
								annots << ' /AC ' + pl['opt']['mk']['ca'] + ''
							end
							if pl['opt']['mk']['i']
								info = getImageBuffer(pl['opt']['mk']['i'])
								if info != false
									annots << ' /I ' + info['n'] + ' 0 R'
								end
							end
							if pl['opt']['mk']['ri']
								info = getImageBuffer(pl['opt']['mk']['ri'])
								if info != false
									annots << ' /RI ' + info['n'] + ' 0 R'
								end
							end
							if pl['opt']['mk']['ix']
								info = getImageBuffer(pl['opt']['mk']['ix'])
								if info != false
									annots << ' /IX ' + info['n'] + ' 0 R'
								end
							end
							if pl['opt']['mk']['if'] and pl['opt']['mk']['if'].is_a?(Hash) and !pl['opt']['mk']['if'].empty?
								annots << ' /IF <<'
								if_sw = ['A', 'B', 'S', 'N']
								if pl['opt']['mk']['if']['sw'] and if_sw.include?(pl['opt']['mk']['if']['sw'])
									annots << ' /SW /' + pl['opt']['mk']['if']['sw']
								end
								if_s = ['A', 'P']
								if pl['opt']['mk']['if']['s'] and if_s.include?(pl['opt']['mk']['if']['s']) 
									annots << ' /S /' + pl['opt']['mk']['if']['s']
								end
								if pl['opt']['mk']['if']['a'] and pl['opt']['mk']['if']['a'].is_a?(Array) and !pl['opt']['mk']['if']['a'].empty?
									annots << sprintf(' /A [%.2f  %.2f]', pl['opt']['mk']['if']['a'][0], pl['opt']['mk']['if']['a'][1])
								end
								if pl['opt']['mk']['if']['fb'] and pl['opt']['mk']['if']['fb']
									annots << ' /FB true'
								end
								annots << '>>'
							end
							if pl['opt']['mk']['tp'] and (pl['opt']['mk']['tp'] >= 0) and (pl['opt']['mk']['tp'] <= 6)
								annots << ' /TP ' + pl['opt']['mk']['tp']
							else
								annots << ' /TP 0'
							end
							annots << '>>'
						end # end MK

						# --- Entries for field dictionaries ---
						if @radiobutton_groups[n][pl['txt']]
							# set parent
							annots << ' /Parent ' + @radiobutton_groups[n][pl['txt']] + ' 0 R'
						end
						if pl['opt']['t'] and pl['opt']['t'].is_a?(String)
							annots << ' /T ' + dataannobjstring(pl['opt']['t'])
						end
						if pl['opt']['tu'] and pl['opt']['tu'].is_a?(String)
							annots << ' /TU ' + dataannobjstring(pl['opt']['tu'])
						end
						if pl['opt']['tm'] and pl['opt']['tm'].is_a?(String)
							annots << ' /TM ' + dataannobjstring(pl['opt']['tm'])
						end
						if pl['opt']['ff']
							if pl['opt']['ff'].is_a?(Array)
								# array of bit settings
								flag = 0
								pl['opt']['ff'].each {|val|
									flag += 1 << (val - 1)
								}
							else
								flag = pl['opt']['ff'].to_i
							end
							annots << ' /Ff ' + flag
						end
						if pl['opt']['maxlen']
							annots << ' /MaxLen ' + pl['opt']['maxlen'].to_i.to_s
						end
						if pl['opt']['v']
							annots << ' /V'
							if pl['opt']['v'].is_a?(Array)
								pl['opt']['v'].each { |optval|
									if optval.is_a? Float
										optval = sprintf('%.2f', optval)
									end
									annots << ' ' + optval
								}
							else
								annots << ' ' + textstring(pl['opt']['v'])
							end
						end
						if pl['opt']['dv']
							annots << ' /DV'
							if pl['opt']['dv'].is_a?(Array)
								pl['opt']['dv'].eath {|optval|
									if optval.is_a? Float
										optval = sprintf('%.2f', optval)
									end
									annots << ' ' + optval
								}
							else
								annots << ' ' + textstring(pl['opt']['dv'])
							end
						end
						if pl['opt']['rv']
							annots << ' /RV'
							if pl['opt']['rv'].is_a?(Array)
								pl['opt']['rv'].eath {|optval|
									if optval.is_a? Float
										optval = sprintf('%.2f', optval)
									end
									annots << ' ' + optval
								}
							else
								annots << ' ' + textstring(pl['opt']['rv'])
							end
						end
						if pl['opt']['a'] and !pl['opt']['a'].empty?
							annots << ' /A << ' + pl['opt']['a'] + ' >>'
						end
						if pl['opt']['aa'] and !pl['opt']['aa'].empty?
							annots << ' /AA << ' + pl['opt']['aa'] + ' >>'
						end
						if pl['opt']['da'] and !pl['opt']['da'].empty?
							annots << ' /DA (' + pl['opt']['da'] + ')'
						end
						if pl['opt']['q'] and (pl['opt']['q'] >= 0) and (pl['opt']['q'] <= 2)
							annots << ' /Q ' + pl['opt']['q'].to_i.to_s
						end
						if pl['opt']['opt'] and pl['opt']['opt'].is_a?(Array) and !pl['opt']['opt'].empty?
							annots << ' /Opt ['
							pl['opt']['opt'].each {|copt|
								if copt.is_a?(Array)
									annots << ' [' + textstring(copt[0]) + ' ' + textstring(copt[1]) + ']'
								else
									annots << ' ' + textstring(copt)
								end
							}
							annots << ']'
						end
						if pl['opt']['ti']
							annots << ' /TI ' + pl['opt']['ti'].to_i.to_s
						end
						if pl['opt']['i'] and pl['opt']['i'].is_a?(Array) and !pl['opt']['i'].empty?
							annots << ' /I ['
							pl['opt']['i'].each {|copt|
								annots << copt.to_i.to_s + ' '
							}
							annots << ']'
						end
					else
					end

					annots << '>>'
					# create new annotation object
					@annot_obj_id += 1
					@offsets[@annot_obj_id] = @bufferlen
					out(@annot_obj_id.to_s + ' 0 obj')
					out(annots)
					out('endobj')

					if formfield and ! @radiobutton_groups[n][pl['txt']]
						# store reference of form object
						@form_obj_id.push = @annot_obj_id
					end
				}
			end # end for each page
		end
	end

	#
	# Put appearance streams XObject used to define annotation's appearance states
	# @param int :w annotation width
	# @param int :h annotation height
	# @param string :stream appearance stream
	# @return int object ID
	# @access protected
	# @since 4.8.001 (2009-09-09)
	#
	def putAPXObject(w=0, h=0, stream='')
		stream = stream.strip
		@apxo_obj_id += 1
		@offsets[@apxo_obj_id] = @bufferlen
		out(@apxo_obj_id + ' 0 obj')
		out('<<')
		out('/Type /XObject')
		out('/Subtype /Form')
		out('/FormType 1')
		if @compress
			stream = gzcompress(stream)
			out('/Filter /FlateDecode')
		end
		rect = sprintf('%.2f %.2f', w, h)
		out('/BBox [0 0 ' + rect + ']')
		out('/Matrix [1 0 0 1 0 0]')
		out('/Resources <</ProcSet [/PDF]>>')
		out('/Length ' + stream.length.to_s)
		out('>>')
		putstream(stream)
		out('endobj')
		return @apxo_obj_id
	end

	#
	# Output fonts.
	# @access protected
	#
	def putfonts()
		nf=@n;
		@diffs.each do |diff|
			#Encodings
			newobj();
			out('<</Type /Encoding /BaseEncoding /WinAnsiEncoding /Differences [' + diff + ']>>');
			out('endobj');
		end
		@font_files.each do |file, info|
			# search and get font file to embedd
			fontdir = info['fontdir']

			file = file.downcase
			fontfile = ''
			# search files on various directories
			if File.exist?(fontdir + file)
				fontfile = fontdir + file
			elsif fontfile = getfontpath(file)
			elsif File.exist?(file)
				fontfile = file
			end

			if !empty_string(fontfile)
				font = ''
				open(fontfile,'rb') do |f|
					font = f.read()
				end
				compressed = (file[-2,2] == '.z')
				if !compressed && !info['length2'].nil?
					header = (font[0][0] == 128)
					if header
						# Strip first binary header
						font = font[6]
					end
					if header && (font[info['length1']][0] == 128)
						# Strip second binary header
						font = font[0..info['length1']] + font[info['length1'] + 6]
					end
				end
				newobj()
				@font_files[file]['n'] = @n
				out('<</Length '+ font.length.to_s)
				if compressed
					out('/Filter /FlateDecode')
				end
				out('/Length1 ' + info['length1'].to_s)
				if !info['length2'].nil?
					out('/Length2 ' + info['length2'].to_s + ' /Length3 0')
				end
				out('>>')
				putstream(font)
				out('endobj')
			end
		end
		@fontkeys.each do |k|
			#Font objects
			setFontSubBuffer(k, 'n', @n + 1)
			font = getFontBuffer(k)
			type = font['type'];
			name = font['name'];
			if (type=='core')
				#Standard font
				obj_id = newobj()
				out('<</Type /Font');
				out('/Subtype /Type1');
				out('/BaseFont /' + name)
				out('/Name /F' + font['i'].to_s)
				if (name.downcase != 'symbol' && name.downcase != 'zapfdingbats')
					out('/Encoding /WinAnsiEncoding');
				end
				if name.downcase == 'helvetica'
					# add default font for annotations
					@annotation_fonts['helvetica'] = k
				end
				out('>>');
				out('endobj');
			elsif type == 'Type0'
				putType0(font)
			elsif (type=='Type1' || type=='TrueType')
				#Additional Type1 or TrueType font
				obj_id = newobj()
				out('<</Type /Font');
				out('/Subtype /' + type);
				out('/BaseFont /' + name)
				out('/Name /F' + font['i'].to_s)
				out('/FirstChar 32 /LastChar 255');
				out('/Widths ' + (@n+1).to_s + ' 0 R');
				out('/FontDescriptor ' + (@n+2).to_s + ' 0 R');
				if (font['enc'])
					if (!font['diff'].nil?)
						out('/Encoding ' + (nf+font['diff']).to_s + ' 0 R');
					else
						out('/Encoding /WinAnsiEncoding');
					end
				end
				out('>>');
				out('endobj');
				#Widths
				newobj();
				cw=font['cw']; # &
				s='[';
				32.upto(255) do |i|
					s << cw[i.chr] + ' ';
				end
				out(s + ']');
				out('endobj');
				#Descriptor
				newobj();
				s='<</Type /FontDescriptor /FontName /' + name;
				font['desc'].each do |fdk, fdv|
					if fdv.is_a? Float
						fdv = sprintf('%.3f', fdv)
					end
					s << ' /' + fdk + ' ' + fdv + ''
				end
				if !empty_string(font['file'])
					s << ' /FontFile' + (type=='Type1' ? '' : '2') + ' ' + @font_files[font['file']]['n'] + ' 0 R'
				end
				out(s + '>>');
				out('endobj');
			else
				#Allow for additional types
				mtd='put' + type.downcase;
				if (!self.respond_to?(mtd))
					Error('Unsupported font type: ' + type)
				end
				obj_id = self.send(mtd,font)
				# store object ID for current font
				@font_obj_ids[k] = obj_id
			end
		end
	end

	#
	# Outputs font widths
	# @parameter array :font font data
	# @parameter int :cidoffset offset for CID values
	# @author Nicola Asuni
	# @access protected
	# @since 4.4.000 (2008-12-07)
	#
	def putfontwidths(font, cidoffset=0)
		font_cw = font['cw'].sort
		rangeid = 0
		range = []
		prevcid = -2
		prevwidth = -1
		interval = false
		range_interval = []
		# for each character
		font_cw.each {|cid, width|
			cid -= cidoffset
			if width != font['dw']
				if cid == prevcid + 1
					# consecutive CID
					if width == prevwidth
						if width == range[rangeid][0]
							range[rangeid].push width
						else
							range[rangeid].pop
							# new range
							rangeid = prevcid
							range[rangeid] = []
							range[rangeid].push prevwidth
							range[rangeid].push width
						end
						interval = true
						range_interval[rangeid] = true
					else
						if interval
							# new range
							rangeid = cid
							range[rangeid] = []
							range[rangeid].push width
						else
							range[rangeid].push width
						end
						interval = false
					end
				else
					# new range
					rangeid = cid
					range[rangeid] = []
					range[rangeid].push width
					interval = false
				end
				prevcid = cid
				prevwidth = width
			end
		}
		# optimize ranges
		prevk = -1
		nextk = -1
		prevint = false
		range.each_with_index {|ws, k|
			cws = ws ? ws.length : 0
			if (k == nextk) and !prevint and (range_interval[k].nil? or (cws < 4))
				if !range_interval[k].nil?
					range_interval[k] = nil
				end
				range[prevk] = range[prevk].concat(range[k]) if range[k]
				range[k] = nil
			else
				prevk = k
			end
			nextk = k + cws
			if !range_interval[k].nil?
				if cws > 3
					prevint = true
				else
					prevint = false
				end
				range_interval[k] = nil
				nextk -= 1
			else
				prevint = false
			end
		}
		# output data
		w = ''
		range.each_with_index {|ws, k|
			if ws and ws.uniq.length == 1
				# interval mode is more compact
				w << ' ' + k.to_s + ' ' + (k + ws.length - 1).to_s + ' ' + ws[0].to_s
			elsif ws
				# range mode
				w << ' ' + k.to_s + ' [ ' + ws.join(' ') + ' ]'
			end
		}
		out('/W [' + w + ' ]')
	end

	def putType0(font)
		# Type0
		newobj()
		out('<</Type /Font')
		out('/Subtype /Type0')
		out('/BaseFont /'+font['name']+'-'+font['cMap'])
		out('/Encoding /'+font['cMap'])
		out('/DescendantFonts ['+(@n+1).to_s+' 0 R]')
		out('>>')
		out('endobj')
		# CIDFont
		newobj()
		out('<</Type /Font')
		out('/Subtype /CIDFontType0')
		out('/BaseFont /'+font['name'])
		out('/CIDSystemInfo <</Registry (Adobe) /Ordering ('+font['registry']['ordering']+') /Supplement '+font['registry']['supplement'].to_s+'>>')
		out('/FontDescriptor '+(@n+1).to_s+' 0 R')
		w='/W [1 ['
		font['cw'].keys.sort.each {|key|
			w+=font['cw'][key].to_s + " "
		}
		out(w+'] 231 325 500 631 [500] 326 389 500]')
		out('>>')
		out('endobj')
		# Font descriptor
		newobj()
		out('<</Type /FontDescriptor')
		out('/FontName /'+font['name'])
		out('/Flags 6')
		out('/FontBBox [0 -200 1000 900]')
		out('/ItalicAngle 0')
		out('/Ascent 800')
		out('/Descent -200')
		out('/CapHeight 800')
		out('/StemV 60')
		out('>>')
		out('endobj')
	end

	#
	# Output images.
	# @access protected
	#
	def putimages()
		filter=(@compress) ? '/Filter /FlateDecode ' : '';
		@imagekeys.each do |file|
			info = getImageBuffer(file)
			newobj();
			setImageSubBuffer(file, 'n', @n)
			out('<</Type /XObject');
			out('/Subtype /Image');
			out('/Width ' + info['w'].to_s);
			out('/Height ' + info['h'].to_s);
			if info.key?('masked')
				out('/SMask ' + (@n - 1).to_s + ' 0 R')
			end
			if (info['cs']=='Indexed')
				out('/ColorSpace [/Indexed /DeviceRGB ' + (info['pal'].length / 3 - 1).to_s + ' ' + (@n + 1).to_s + ' 0 R]')
			else
				out('/ColorSpace /' + info['cs']);
				if (info['cs']=='DeviceCMYK')
					out('/Decode [1 0 1 0 1 0 1 0]');
				end
			end
			out('/BitsPerComponent ' + info['bpc'].to_s);
			if (!info['f'].nil?)
				out('/Filter /' + info['f']);
			end
			if (!info['parms'].nil?)
				out(info['parms']);
			end
			if (!info['trns'].nil? and info['trns'].kind_of?(Array))
				trns='';
				count_info = info['trns'].length
				0.upto(count_info) do |i|
					trns << info['trns'][i] + ' ' + info['trns'][i] + ' ';
				end
				out('/Mask [' + trns + ']');
			end
			out('/Length ' + info['data'].length.to_s + '>>');
			putstream(info['data']);
			out('endobj');
			#Palette
			if (info['cs']=='Indexed')
				newobj();
				pal = @compress ? gzcompress(info['pal']) : info['pal']
				out('<<' + filter + '/Length ' + pal.length.to_s + '>>');
				putstream(pal);
				out('endobj');
			end
		end
	end

	#
	# Output object dictionary for images.
	# @access protected
	#
	def putxobjectdict()
		@imagekeys.each do |file|
			info = getImageBuffer(file)
			out('/I' + info['i'].to_s + ' ' + info['n'].to_s + ' 0 R')
		end
	end

	#
	# putresourcedict
	# @access protected
	#
	def putresourcedict()
		out('/ProcSet [/PDF /Text /ImageB /ImageC /ImageI]');
		out('/Font <<');
		@fontkeys.each do |fontkey|
			font = getFontBuffer(fontkey)
			out('/F' + font['i'].to_s + ' ' + font['n'].to_s + ' 0 R');
		end
		out('>>');
		out('/XObject <<');
		putxobjectdict();
		out('>>');
	end

	#
	# Output Resources.
	# @access protected
	#
	def putresources()
		putfonts();
		putimages();
		#Resource dictionary
		@offsets[2]=@bufferlen
		out('2 0 obj');
		out('<<');
		putresourcedict();
		out('>>');
		out('endobj');
		putbookmarks()
		putEmbeddedFiles()
		putannotsobjs()
	end
	
	#
	# Adds some Metadata information (Document Information Dictionary)
	# (see Chapter 14.3.3 Document Information Dictionary of PDF32000_2008.pdf Reference)
	# @access protected
	#
	def putinfo()
		if !empty_string(@title)
			# The document's title.
			out('/Title ' + textstring(@title));
		end
		if !empty_string(@author)
			# The name of the person who created the document.
			out('/Author ' + textstring(@author));
		end
		if !empty_string(@subject)
			# The subject of the document.
			out('/Subject ' + textstring(@subject))
		end
		if !empty_string(@keywords)
			# Keywords associated with the document.
			out('/Keywords ' + textstring(@keywords));
		end
		if !empty_string(@creator)
			# If the document was converted to PDF from another format, the name of the conforming product that created the original document from which it was converted.
			out('/Creator ' + textstring(@creator));
		end
		if defined?(PDF_PRODUCER)
			# If the document was converted to PDF from another format, the name of the conforming product that converted it to PDF.
			out('/Producer ' + textstring(PDF_PRODUCER))
		else
			# default producer
			out('/Producer ' + textstring('TCPDF'))
		end
		# The date and time the document was created, in human-readable form
		out('/CreationDate ' + datestring())
		# The date and time the document was most recently modified, in human-readable form
		out('/ModDate ' + datestring())
		# A name object indicating whether the document has been modified to include trapping information
		# out('/Trapped /False')
	end

	#
	# putcatalog
	# @access protected
	#
	def putcatalog()
		out('/Type /Catalog');
		out('/Pages 1 0 R');
		if (@zoom_mode=='fullpage')
			out('/OpenAction [3 0 R /Fit]');
		elsif (@zoom_mode=='fullwidth')
			out('/OpenAction [3 0 R /FitH null]');
		elsif (@zoom_mode=='real')
			out('/OpenAction [3 0 R /XYZ null null 1]');
		elsif (!@zoom_mode.is_a?(String))
			out('/OpenAction [3 0 R /XYZ null null ' + (@zoom_mode/100) + ']');
		end
		if @layout_mode and !empty_string(@layout_mode)
			out('/PageLayout /' + @layout_mode + '')
		end
		if @page_mode and !empty_string(@page_mode)
			out('/PageMode /' + @page_mode)
		end
		if @outlines.size > 0
			out('/Outlines ' + @outline_root.to_s + ' 0 R')
			out('/PageMode /UseOutlines')
		end
		if @rtl
			out('/ViewerPreferences << /Direction /R2L >>')
		end
	end

	#
	# puttrailer
	# @access protected
	#
	def puttrailer()
		out('/Size ' + (@n+1).to_s);
		out('/Root ' + @n.to_s + ' 0 R');
		out('/Info ' + (@n-1).to_s + ' 0 R');
	end

	#
	# putheader
	# @access protected
	#
	def putheader()
		out('%PDF-' + @pdf_version);
	end

	#
	# Output end of document (EOF).
	# @access protected
	#
	def enddoc()
		@state = 1
		putheader();
		putpages();
		putresources();
		#Info
		newobj();
		out('<<');
		putinfo();
		out('>>');
		out('endobj');
		#Catalog
		newobj();
		out('<<');
		putcatalog();
		out('>>');
		out('endobj');
		#Cross-ref
		o=@bufferlen
		out('xref');
		out('0 ' + (@n+1).to_s);
		out('0000000000 65535 f ');
		1.upto(@n) do |i|
			out(sprintf('%010d 00000 n ',@offsets[i]));
		end
		# Embedded Files
		if !@embeddedfiles.nil? and (@embeddedfiles.length > 0)
			out(@embedded_start_obj_id.to_s + ' ' + @embeddedfiles.length.to_s)
			@embeddedfiles.each { |filename, filedata|
				out(sprintf('%010d 00000 n ', @offsets[filedata['n']]))
			}
		end
		# Annotation Objects
		if @annot_obj_id > @annots_start_obj_id
			out((@annots_start_obj_id + 1).to_s + ' ' + (@annot_obj_id - @annots_start_obj_id).to_s)
			(@annots_start_obj_id + 1).upto(@annot_obj_id) do |i|
				out(sprintf('%010d 00000 n ', @offsets[i]))
			end
		end
		#Trailer
		out('trailer');
		out('<<');
		puttrailer();
		out('>>');
		out('startxref');
		out(o);
		out('%%EOF');
		@state=3 # end-of-doc
		if @diskcache
			# remove temporary files used for images
			@imagekeys.each do |key|
				# remove temporary files
				File.delete(@images[key].path)
			end
			@fontkeys.each do |key|
				# remove temporary files
				File.delete(@fonts[key].path)
			end
		end
	end

	#
	# beginpage
	# @param string :orientation page orientation. Possible values are (case insensitive):<ul><li>P or PORTRAIT (default)</li><li>L or LANDSCAPE</li></ul>
	# @param mixed :format The format used for pages. It can be either one of the following values (case insensitive) or a custom format in the form of a two-element array containing the width and the height (expressed in the unit given by unit).<ul><li>4A0</li><li>2A0</li><li>A0</li><li>A1</li><li>A2</li><li>A3</li><li>A4 (default)</li><li>A5</li><li>A6</li><li>A7</li><li>A8</li><li>A9</li><li>A10</li><li>B0</li><li>B1</li><li>B2</li><li>B3</li><li>B4</li><li>B5</li><li>B6</li><li>B7</li><li>B8</li><li>B9</li><li>B10</li><li>C0</li><li>C1</li><li>C2</li><li>C3</li><li>C4</li><li>C5</li><li>C6</li><li>C7</li><li>C8</li><li>C9</li><li>C10</li><li>RA0</li><li>RA1</li><li>RA2</li><li>RA3</li><li>RA4</li><li>SRA0</li><li>SRA1</li><li>SRA2</li><li>SRA3</li><li>SRA4</li><li>LETTER</li><li>LEGAL</li><li>EXECUTIVE</li><li>FOLIO</li></ul>
	# @access protected
	#
	def beginpage(orientation='', format='')
		@page += 1;
		setPageBuffer(@page, '')
		# initialize array for graphics tranformation positions inside a page buffer
		@state=2;
		if empty_string(orientation)
			unless @cur_orientation.nil?
				orientation = @cur_orientation
			else
				orientation = 'P'
			end
		end
		if empty_string(format)
			setPageOrientation(orientation)
		else
			setPageFormat(format, orientation)
		end
		if @rtl
			@x = @w - @r_margin
		else
			@x = @l_margin
		end
		@y=@t_margin;
		if !@newpagegroup[@page].nil?
			# start a new group
			n = @pagegroups.size + 1
			alias_nb = '{nb' + n.to_s + '}'
			@pagegroups[alias_nb] = 1
			@currpagegroup = alias_nb
		elsif @currpagegroup
			@pagegroups[@currpagegroup] += 1
		end
	end

	#
	# End of page contents
	# @access protected
	#
	def endpage()
		@state=1;
	end

	#
	# Begin a new object and return the object number
	# @return int object number
	# @access protected
	#
	def newobj()
		@n += 1;
		@offsets[@n]=@bufferlen
		out(@n.to_s + ' 0 obj');

		return @n
	end

	#
	# Underline text
	# @param int :x X coordinate
	# @param int :y Y coordinate
	# @param string :txt text to underline
	# @access protected
	#
	def dounderline(x, y, txt)
		w = GetStringWidth(txt)
		return dounderlinew(x, y, w)
	end

	#
	# Line through text
	# @param int :x X coordinate
	# @param int :y Y coordinate
	# @param string :txt text to underline
	# @access protected
	#
	def dolinethrough(x, y, txt)
		w = GetStringWidth(txt)
		return dolinethroughw(x, y, w)
	end

	#
	# Underline for rectangular text area.
	# @param int :x X coordinate
	# @param int :y Y coordinate
	# @param int :w width to underline
	# @access protected
	# @since 4.8.008 (2009-09-29)
	#
	def dounderlinew(x, y, w)
		up = @current_font['up']
		ut = @current_font['ut']
		return sprintf('%.2f %.2f %.2f %.2f re f', x * @k, (@h - (y - up / 1000.0 * @font_size)) * @k, w * @k, -ut / 1000.0 * @font_size_pt)
	end

	#
	# Line through for rectangular text area.
	# @param int :x X coordinate
	# @param int :y Y coordinate
	# @param string :txt text to linethrough
	# @access protected
	# @since 4.8.008 (2009-09-29)
	#
	def dolinethroughw(x, y, w)
		up = @current_font['up']
		ut = @current_font['ut']
		sprintf('%.2f %.2f %.2f %.2f re f', x * @k, (@h - (y - (@font_size/2) - up / 1000.0 * @font_size)) * @k, w * @k, -ut / 1000.0 * @font_size_pt)
	end

	#
	# Extract info from a JPEG file
	# @access protected
	#
	def parsejpeg(file)
		a=getimagesize(file);
		if (a.empty?)
			Error('Missing or incorrect image file: ' + file);
		end
		if (a[2]!='JPEG')
			Error('Not a JPEG file: ' + file);
		end
		if (a['channels'].nil? or a['channels']==3)
			colspace='DeviceRGB';
		elsif (a['channels']==4)
			colspace='DeviceCMYK';
		else
			colspace='DeviceGray';
		end
		bpc=!a['bits'].nil? ? a['bits'] : 8;
		#Read whole file
		data='';
	  open(file,'rb') do |f|
			data<<f.read();
		end
		return {'w' => a[0],'h' => a[1],'cs' => colspace,'bpc' => bpc,'f'=>'DCTDecode','data' => data}
	end

	def imageToPNG(file)
		img = Magick::ImageList.new(file)
		img.format = 'PNG'       # convert to PNG from gif 
		img.opacity = 0          # PNG alpha channel delete

		#use a temporary file....
		tmpFile = Tempfile.new(['', '_' + File::basename(file) + '.png'], @@k_path_cache);
		tmpFile.binmode
		tmpFile.print img.to_blob
		tmpFile
	ensure
		tmpFile.close
	end

	#
	# Extract info from a PNG file
	# @access protected
	#
	def parsepng(file)
		f=open(file,'rb');
		#Check signature
		if (f.read(8)!=137.chr + 'PNG' + 13.chr + 10.chr + 26.chr + 10.chr)
			Error('Not a PNG file: ' + file);
		end
		#Read header chunk
		f.read(4);
		if (f.read(4)!='IHDR')
			Error('Incorrect PNG file: ' + file);
		end
		w=freadint(f);
		h=freadint(f);
		bpc=f.read(1).unpack('C')[0]
		if (bpc>8)
			# Error('16-bit depth not supported: ' + file)
			return false
		end
		ct=f.read(1).unpack('C')[0]
		if (ct==0)
			colspace='DeviceGray';
		elsif (ct==2)
			colspace='DeviceRGB';
		elsif (ct==3)
			colspace='Indexed';
		else
			# Error('Alpha channel not supported: ' + file)
			return false
		end
		if (f.read(1).unpack('C')[0] != 0)
			# Error('Unknown compression method: ' + file)
			return false
		end
		if (f.read(1).unpack('C')[0]!=0)
			# Error('Unknown filter method: ' + file)
			return false
		end
		if (f.read(1).unpack('C')[0]!=0)
			# Error('Interlacing not supported: ' + file)
			return false
		end
		f.read(4);
		parms='/DecodeParms <</Predictor 15 /Colors ' + (ct==2 ? 3 : 1).to_s + ' /BitsPerComponent ' + bpc.to_s + ' /Columns ' + w.to_s + '>>';
		#Scan chunks looking for palette, transparency and image data
		pal='';
		trns='';
		data='';
		begin
			n=freadint(f);
			type=f.read(4);
			if (type=='PLTE')
				#Read palette
				pal=f.read( n);
				f.read(4);
			elsif (type=='tRNS')
				#Read transparency info
				t=f.read( n);
				if (ct==0)
					trns = t[1].unpack('C')[0]
				elsif (ct==2)
					trns = t[[1].unpack('C')[0], t[3].unpack('C')[0], t[5].unpack('C')[0]]
				else
					pos=t.include?(0.chr);
					if (pos!=false)
						trns = [pos]
					end
				end
				f.read(4);
			elsif (type=='IDAT')
				#Read image data block
				data<<f.read( n);
				f.read(4);
			elsif (type=='IEND')
				break;
			else
				f.read( n+4);
			end
		end while(n)
		if (colspace=='Indexed' and pal.empty?)
			# Error('Missing palette in ' + file)
			return false
		end
		return {'w' => w, 'h' => h, 'cs' => colspace, 'bpc' => bpc, 'f'=>'FlateDecode', 'parms' => parms, 'pal' => pal, 'trns' => trns, 'data' => data}
	ensure
		f.close
	end

	#
	# Read a 4-byte integer from file
	# @param string :f file name.
	# @return 4-byte integer
	# @access protected
	#
	def freadint(f)
		# Read a 4-byte integer from file
		a = f.read(4).unpack('N')
		return a[0]
	end

 	#
	# Format a data string for meta information
	# @param string :s data string to escape.
	# @return string escaped string.
	# @access protected
	#
	def datastring(s)
		#if @encrypted
		#	s = RC4(@objectkey(@n), s)
		#end
		return '(' + escape(s) + ')'
	end

	#
	# Format a data string for annotation objects
	# @param string :s data string to escape.
	# @return string escaped string.
	# @access protected
	#
	def dataannobjstring(s)
		#if @encrypted
		#	s = RC4(@objectkey(@annot_obj_id + 1), s)
		#end
		return '(' + escape(s) + ')'
	end
	#
	# Returns a formatted date for meta information
	# @return string escaped date string.
	# @access protected
	# @since 4.6.028 (2009-08-25)
	#
	def datestring()
		current_time = Time.now.strftime('%Y%m%d%H%M%S%z').insert(-3, '\'') + '\''
		return datastring('D:' + current_time)
	end

	#
	# Format a text string for meta information
	# @param string :s string to escape.
	# @return string escaped string.
	# @access protected
	#
	def textstring(s)
		if (@is_unicode)
			#Convert string to UTF-16BE
			s = UTF8ToUTF16BE(s, true);
		end
		return datastring(s)
	end

	#
	# Format a text string
	# @param string :s string to escape.
	# @return string escaped string.
	# @access protected
	#
	def escapetext(s)
		if (@is_unicode)
			if (@current_font['type'] == 'core') or (@current_font['type'] == 'TrueType') or (@current_font['type'] == 'Type1')
				s = UTF8ToLatin1(s)
			else
				# Convert string to UTF-16BE and reverse RTL language
				s = utf8StrRev(s, false, @tmprtl)
			end
		end
		return escape(s);
	end

	#
	# Add \ before \, ( and )
	# @access protected
	#
	def escape(s)
		# Add \ before \, ( and )
		s.gsub('\\','\\\\\\').gsub('(','\\(').gsub(')','\\)').gsub(13.chr, '\r')
	end

	#
	#
	# @access protected
	#
	def putstream(s)
		out('stream');
		out(s);
		out('endstream');
	end

	#
	# Output a string to the document.
	# @param string :s string to output.
	# @access protected
	#
	def out(s)
		s.force_encoding('ASCII-8BIT') if s.respond_to?(:force_encoding)
		if (@state==2)
			if !@in_footer and !@footerlen[@page].nil? and (@footerlen[@page] > 0)
				# puts data before page footer
				pagebuff = getPageBuffer(@page)
				page = pagebuff[0..(-@footerlen[@page]-1)]
				footer = pagebuff[-@footerlen[@page]..-1]
				setPageBuffer(@page, page + s.to_s + "\n" + footer)
				# update footer position
				@footerpos[@page] += (s.to_s + "\n").length
			else
				setPageBuffer(@page, s.to_s + "\n", true)
			end
		else
			setBuffer(s.to_s + "\n")
		end
	end

	#
	# Adds unicode fonts.<br>
	# Based on PDF Reference 1.3 (section 5)
	# @parameter array :font font data
	# @return int font object ID
	# @access protected
	# @author Nicola Asuni
	# @since 1.52.0.TC005 (2005-01-05)
	#
	def puttruetypeunicode(font)
		# Type0 Font
		# A composite font composed of other fonts, organized hierarchically
		obj_id = newobj()
		out('<</Type /Font');
		out('/Subtype /Type0');
		out('/BaseFont /' + font['name'] + '');
		out('/Name /F' + font['i'].to_s)
		out('/Encoding /' + font['enc'])
		out('/ToUnicode /Identity-H')
		out('/DescendantFonts [' + (@n + 1).to_s + ' 0 R]');
		out('>>');
		out('endobj');
		
		# CIDFontType2
		# A CIDFont whose glyph descriptions are based on TrueType font technology
		newobj();
		out('<</Type /Font');
		out('/Subtype /CIDFontType2');
		out('/BaseFont /' + font['name'] + '');
		
		# A dictionary containing entries that define the character collection of the CIDFont.

		cidinfo = '/Registry ' + datastring(font['cidinfo']['Registry'])
		cidinfo << ' /Ordering ' + datastring(font['cidinfo']['Ordering'])
		cidinfo << ' /Supplement ' + font['cidinfo']['Supplement'].to_s

		out('/CIDSystemInfo <<' + cidinfo + '>>')
		out('/FontDescriptor ' + (@n + 1).to_s + ' 0 R')
		out('/DW ' + font['dw'].to_s + '') # default width
		putfontwidths(font, 0)
		out('/CIDToGIDMap ' + (@n + 2).to_s + ' 0 R')

		out('>>');
		out('endobj');
		
		# Font descriptor
		# A font descriptor describing the CIDFont default metrics other than its glyph widths
		newobj();
		out('<</Type /FontDescriptor');
		out('/FontName /' + font['name']);
		font['desc'].each do |key, value|
			if value.is_a? Float
				value = sprintf('%.3f', value)
			end
			out('/' + key.to_s + ' ' + value.to_s + '')
		end
		fontdir = ''
		if !empty_string(font['file'])
			# A stream containing a TrueType font
			out('/FontFile2 ' + @font_files[font['file']]['n'].to_s + ' 0 R');
			fontdir = @font_files[font['file']]['fontdir']
		end
		out('>>');
		out('endobj');
		newobj();

		if font['ctg'] and !empty_string(font['ctg'])
			# Embed CIDToGIDMap
			# A specification of the mapping from CIDs to glyph indices
			# search and get CTG font file to embedd
			ctgfile = font['ctg'].downcase

			# search and get ctg font file to embedd
			fontfile = ''
			# search files on various directories
			if File.exists?(fontdir + ctgfile)
				fontfile = fontdir + ctgfile
			elsif fontfile = getfontpath(ctgfile)
			elsif File.exists?(ctgfile)
				fontfile = ctgfile
			end

			if empty_string(fontfile)
				Error('Font file not found: ' + ctgfile)
			end
			size = File.size(fontfile)
			out('<</Length ' + size.to_s + '')
			if (fontfile[-2,2] == '.z') # check file extension
				# Decompresses data encoded using the public-domain 
				# zlib/deflate compression method, reproducing the 
				# original text or binary data
				out('/Filter /FlateDecode')
			end
			out('>>')
			open(fontfile, 'rb') do |f|
				putstream(f.read())
			end
		end
		out('endobj');

		return obj_id
	end

	#
	# Output CID-0 fonts.
	# A Type 0 CIDFont contains glyph descriptions based on the Adobe Type 1 font format
	# @param array :font font data
	# @return int font object ID
	# @access protected
	# @author Andrew Whitehead, Nicola Asuni, Yukihiro Nakadaira
	# @since 3.2.000 (2008-06-23)
	#
	def putcidfont0(font)
		cidoffset = 0
		if font['cw'][1].nil?
			cidoffset = 31
		end
		if font['cidinfo']['uni2cid']
			# convert unicode to cid.
			uni2cid = font['cidinfo']['uni2cid']
			cw = {}
			font['cw'].each { |uni, width|
				if uni2cid[uni]
					cw[(uni2cid[uni] + cidoffset)] = width
				elsif uni < 256
					cw[uni] = width
				end # else unknown character
			}
			font = font.merge({'cw' => cw})
		end
		name = font['name']
		enc = font['enc']
		if enc
			longname = name + '-' + enc
		else
			longname = name
		end
		obj_id = newobj()
		out('<</Type /Font')
		out('/Subtype /Type0')
		out('/BaseFont /' + longname)
		out('/Name /F' + font['i'].to_s)
		if enc
			out('/Encoding /' + enc)
		end
		out('/DescendantFonts [' + (@n + 1).to_s + ' 0 R]')
		out('>>')
		out('endobj')
		newobj()
		out('<</Type /Font')
		out('/Subtype /CIDFontType0')
		out('/BaseFont /' + name)
		cidinfo = '/Registry ' + datastring(font['cidinfo']['Registry'])
		cidinfo << ' /Ordering ' + datastring(font['cidinfo']['Ordering'])
		cidinfo << ' /Supplement ' + font['cidinfo']['Supplement'].to_s
		out('/CIDSystemInfo <<' + cidinfo + '>>')
		out('/FontDescriptor ' + (@n + 1).to_s + ' 0 R')
		out('/DW ' + font['dw'].to_s)
		putfontwidths(font, cidoffset)
		out('>>')
		out('endobj')
		newobj()
		s = '<</Type /FontDescriptor /FontName /' + name
		font['desc'].each {|k, v|
			if k != 'Style'
				if fdv.is_a? Float
					fdv = sprintf('%.3f', fdv)
				end
				s << ' /' + k + ' ' + v.to_s + ''
			end
		}
		out(s + '>>')
		out('endobj')

		return obj_id
	end

	#
	# Converts UTF-8 strings to codepoints array.<br>
	# Invalid byte sequences will be replaced with 0xFFFD (replacement character)<br>
	# Based on: http://www.faqs.org/rfcs/rfc3629.html
	# <pre>
	# 	  Char. number range  |        UTF-8 octet sequence
	#       (hexadecimal)    |              (binary)
	#    --------------------+-----------------------------------------------
	#    0000 0000-0000 007F | 0xxxxxxx
	#    0000 0080-0000 07FF | 110xxxxx 10xxxxxx
	#    0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
	#    0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
	#    ---------------------------------------------------------------------
	#
	#   ABFN notation:
	#   ---------------------------------------------------------------------
	#   UTF8-octets =#( UTF8-char )
	#   UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
	#   UTF8-1      = %x00-7F
	#   UTF8-2      = %xC2-DF UTF8-tail
	#
	#   UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
	#                 %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
	#   UTF8-4      = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
	#                 %xF4 %x80-8F 2( UTF8-tail )
	#   UTF8-tail   = %x80-BF
	#   ---------------------------------------------------------------------
	# </pre>
	# @param string :str string to process. (UTF-8)
	# @return array containing codepoints (UTF-8 characters values) (UCS4)
	# @access protected
	# @author Nicola Asuni
	# @since 1.53.0.TC005 (2005-01-05)
	#
	def UTF8StringToArray(str)
		if @cache_utf8_string_to_array[str]
			# return cached value
			return @cache_utf8_string_to_array[str]
		end
		# check cache size
		if @cache_size_utf8_string_to_array >= @cache_maxsize_utf8_string_to_array
			# remove first element
			@cache_utf8_string_to_array.shift
		end
		@cache_size_utf8_string_to_array += 1
		if !@is_unicode
			# split string into array of chars
			strarr = str.split(//)
			# convert chars to equivalent code
			strarr.each_with_index do |char, pos| # was while(list(pos,char)=each(strarr))
				strarr[pos] = char.unpack('C')[0]
			end
			# insert new value on cache
			@cache_utf8_string_to_array[str] = strarr
			return strarr
		end

		unicode = [] # array containing unicode values
		bytes  = [] # array containing single character byte sequences
		numbytes  = 1; # number of octetc needed to represent the UTF-8 character

		str = str.to_s; # force :str to be a string
		
		str.each_byte do |char|
			if (bytes.length == 0) # get starting octect
				if (char <= 0x7F)
					unicode << char # use the character "as is" because is ASCII
					numbytes = 1
				elsif ((char >> 0x05) == 0x06) # 2 bytes character (0x06 = 110 BIN)
					bytes << ((char - 0xC0) << 0x06) 
					numbytes = 2
				elsif ((char >> 0x04) == 0x0E) # 3 bytes character (0x0E = 1110 BIN)
					bytes << ((char - 0xE0) << 0x0C) 
					numbytes = 3
				elsif ((char >> 0x03) == 0x1E) # 4 bytes character (0x1E = 11110 BIN)
					bytes << ((char - 0xF0) << 0x12)
					numbytes = 4
				else
					# use replacement character for other invalid sequences
					unicode << 0xFFFD
					bytes = []
					numbytes = 1
				end
			elsif ((char >> 0x06) == 0x02) # bytes 2, 3 and 4 must start with 0x02 = 10 BIN
				bytes << (char - 0x80)
				if (bytes.length == numbytes)
					# compose UTF-8 bytes to a single unicode value
					char = bytes[0]
					1.upto(numbytes-1) do |j|
						char += (bytes[j] << ((numbytes - j - 1) * 0x06))
					end
					if (((char >= 0xD800) and (char <= 0xDFFF)) or (char >= 0x10FFFF))
						# The definition of UTF-8 prohibits encoding character numbers between
						# U+D800 and U+DFFF, which are reserved for use with the UTF-16
						# encoding form (as surrogate pairs) and do not directly represent
						# characters
						unicode << 0xFFFD; # use replacement character
					else
						unicode << char # add char to array
					end
					# reset data for next char
					bytes = []
					numbytes = 1
				end
			else
				# use replacement character for other invalid sequences
				unicode << 0xFFFD;
				bytes = []
				numbytes = 1;
			end
		end
		# insert new value on cache
		@cache_utf8_string_to_array[str] = unicode
		return unicode;
	end
	
	#
	# Converts UTF-8 strings to UTF16-BE.<br>
	# @param string :str string to process.
	# @param boolean :setbom if true set the Byte Order Mark (BOM = 0xFEFF)
	# @return string
	# @access protected
	# @author Nicola Asuni
	# @since 1.53.0.TC005 (2005-01-05)
	# @uses UTF8StringToArray(), arrUTF8ToUTF16BE()
	#
	def UTF8ToUTF16BE(str, setbom=true)
		if !@is_unicode
			return str # string is not in unicode
		end
		unicode = UTF8StringToArray(str) # array containing UTF-8 unicode values (UCS4)
		return arrUTF8ToUTF16BE(unicode, setbom)
	end

	#
	# Converts UTF-8 strings to Latin1 when using the standard 14 core fonts.<br>
	# @param string :str string to process.
	# @return string
	# @author Andrew Whitehead, Nicola Asuni
	# @access protected
	# @since 3.2.000 (2008-06-23)
	#
	def UTF8ToLatin1(str)
		if !@is_unicode
			return str # string is not in unicode
		end
		outstr = '' # string to be returned
		unicode = UTF8StringToArray(str) # array containing UTF-8 unicode values
		unicode.each {|char|
			if char < 256
				outstr << char.chr
			elsif @@utf8tolatin.key?(char)
				# map from UTF-8
				outstr << @@utf8tolatin[char].chr
			elsif char == 0xFFFD
				# skip
			else
				outstr << '?'
			end
		}
		return outstr
	end

	#
	# Converts UTF-8 characters array to Latin1<br>
	# @param array :unicode array containing UTF-8 unicode values
	# @return array
	# @author Nicola Asuni
	# @access protected
	# @since 4.8.023 (2010-01-15)
	#
	def UTF8ArrToLatin1(unicode)
		if !@is_unicode or (@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont0')
			return unicode # string is not in unicode
		end
		outarr = [] # array to be returned
		unicode.each {|char|
			if char < 256
				outarr.push char
			elsif @@utf8tolatin.key?(char)
				# map from UTF-8
				outarr.push @@utf8tolatin[char]
			elsif char == 0xFFFD
				# skip
			else
				outarr.push 63 # '?' character
			end
		}
		return outarr
	end

	#
	# Converts array of UTF-8 characters to UTF16-BE string.<br>
	# Based on: http://www.faqs.org/rfcs/rfc2781.html
 	# <pre>
	#   Encoding UTF-16:
	# 
		#   Encoding of a single character from an ISO 10646 character value to
	#    UTF-16 proceeds as follows. Let U be the character number, no greater
	#    than 0x10FFFF.
	# 
	#    1) If U < 0x10000, encode U as a 16-bit unsigned integer and
	#       terminate.
	# 
	#    2) Let U' = U - 0x10000. Because U is less than or equal to 0x10FFFF,
	#       U' must be less than or equal to 0xFFFFF. That is, U' can be
	#       represented in 20 bits.
	# 
	#    3) Initialize two 16-bit unsigned integers, W1 and W2, to 0xD800 and
	#       0xDC00, respectively. These integers each have 10 bits free to
	#       encode the character value, for a total of 20 bits.
	# 
	#    4) Assign the 10 high-order bits of the 20-bit U' to the 10 low-order
	#       bits of W1 and the 10 low-order bits of U' to the 10 low-order
	#       bits of W2. Terminate.
	# 
	#    Graphically, steps 2 through 4 look like:
	#    U' = yyyyyyyyyyxxxxxxxxxx
	#    W1 = 110110yyyyyyyyyy
	#    W2 = 110111xxxxxxxxxx
	# </pre>
	# @param array :unicode array containing UTF-8 unicode values (UCS4)
	# @param boolean :setbom if true set the Byte Order Mark (BOM = 0xFEFF)
	# @return string (UTF-16BE)
	# @access protected
	# @author Nicola Asuni
	# @since 2.1.000 (2008-01-08)
	# @see UTF8ToUTF16BE()
	#
	def arrUTF8ToUTF16BE(unicode, setbom=true)
		outstr = ""; # string to be returned
		if (setbom)
			outstr << "\xFE\xFF"; # Byte Order Mark (BOM)
		end
		unicode.each do |char|
			if (char == 0xFFFD)
				outstr << "\xFF\xFD"; # replacement character
			elsif (char < 0x10000)
				outstr << (char >> 0x08).chr;
				outstr << (char & 0xFF).chr;
			else
				char -= 0x10000;
				w1 = 0xD800 | (char >> 0x10);
				w2 = 0xDC00 | (char & 0x3FF);	
				outstr << (w1 >> 0x08).chr;
				outstr << (w1 & 0xFF).chr;
				outstr << (w2 >> 0x08).chr;
				outstr << (w2 & 0xFF).chr;
			end
		end
		return outstr;
	end
	
	# ====================================================
	
	#
 	# Set header font.
	# @param array :font font
	# @access public
	# @since 1.1
	#
	def SetHeaderFont(font)
		@header_font = font;
	end
	alias_method :set_header_font, :SetHeaderFont
	
	#
	# Get header font.
	# @return array()
	# @access public
	# @since 4.0.012 (2008-07-24)
	#
	def GetHeaderFont()
		return @header_font
	end
	alias_method :get_header_font, :GetHeaderFont

	#
 	# Set footer font.
	# @param array :font font
	# @access public
	# @since 1.1
	#
	def SetFooterFont(font)
		@footer_font = font;
	end
	alias_method :set_footer_font, :SetFooterFont
	
	#
	# Get Footer font.
	# @return array()
	# @access public
	# @since 4.0.012 (2008-07-24)
	#
	def GetFooterFont(font)
		return @footer_font
	end
	alias_method :get_footer_font, :GetFooterFont

	#
 	# Set language array.
	# @param array :language
	# @since 1.1
	#
	def SetLanguageArray(language)
		@l = language;
		if @l['a_meta_dir']
			@rtl = (@l['a_meta_dir'] == 'rtl') ? true : false
		else
			@rtl = false
		end
	end
	alias_method :set_language_array, :SetLanguageArray

	#
	# Set the default JPEG compression quality (1-100)
	# @param int :quality JPEG quality, integer between 1 and 100
	# @access public
	# @since 3.0.000 (2008-03-27)
	#
	def SetJPEGQuality(quality)
		if (quality < 1) or (quality > 100)
			quality = 75
		end
		@jpeg_quality = quality
	end

	#
	# Set the height of cell repect font height.
	# @param int :h cell proportion respect font height (typical value = 1.25).
	# @access public
	# @since 3.0.014 (2008-06-04)
	#
	def SetCellHeightRatio(h) 
		@cell_height_ratio = h 
	end

	#
	# return the height of cell repect font height.
	# @access public
	# @since 4.0.012 (2008-07-24)
	#
	def GetCellHeightRatio()
		return @cell_height_ratio
	end

	#
 	# Set document barcode.
	# @param string :bc barcode
	# @access public
	#
	def SetBarcode(bc="")
		@barcode = bc;
	end
	
	#
	# Get current barcode.
	# @return string
	# @access public
	# @since 4.0.012 (2008-07-24)
	#
	def GetBarcode()
		return @barcode
	end
	
	#
 	# Print Barcode.
	# @param int :x x position in user units
	# @param int :y y position in user units
	# @param int :w width in user units
	# @param int :h height position in user units
	# @param string :type type of barcode (I25, C128A, C128B, C128C, C39)
	# @param string :style barcode style
	# @param string :font font for text
	# @param int :xres x resolution
	# @param string :code code to print
	#
	def writeBarcode(x, y, w, h, type, style, font, xres, code)
		require(File.dirname(__FILE__) + "/barcode/barcode.rb");
		require(File.dirname(__FILE__) + "/barcode/i25object.rb");
		require(File.dirname(__FILE__) + "/barcode/c39object.rb");
		require(File.dirname(__FILE__) + "/barcode/c128aobject.rb");
		require(File.dirname(__FILE__) + "/barcode/c128bobject.rb");
		require(File.dirname(__FILE__) + "/barcode/c128cobject.rb");
		
		if (code.empty?)
			return;
		end
		
		if (style.empty?)
			style  = BCS_ALIGN_LEFT;
			style |= BCS_IMAGE_PNG;
			style |= BCS_TRANSPARENT;
			#:style |= BCS_BORDER;
			#:style |= BCS_DRAW_TEXT;
			#:style |= BCS_STRETCH_TEXT;
			#:style |= BCS_REVERSE_COLOR;
		end
		if (font.empty?) then font = BCD_DEFAULT_FONT; end
		if (xres.empty?) then xres = BCD_DEFAULT_XRES; end
		
		scale_factor = 1.5 * xres * @k;
		bc_w = (w * scale_factor).round #width in points
		bc_h = (h * scale_factor).round #height in points
		
		case (type.upcase)
			when "I25"
				obj = I25Object.new(bc_w, bc_h, style, code);
			when "C128A"
				obj = C128AObject.new(bc_w, bc_h, style, code);
			when "C128B"
				obj = C128BObject.new(bc_w, bc_h, style, code);
			when "C128C"
				obj = C128CObject.new(bc_w, bc_h, style, code);
			when "C39"
				obj = C39Object.new(bc_w, bc_h, style, code);
		end
		
		obj.SetFont(font);   
		obj.DrawObject(xres);
		
		#use a temporary file....
		tmpName = tempnam(@@k_path_cache,'img');
		imagepng(obj.getImage(), tmpName);
		Image(tmpName, x, y, w, h, 'png');
		obj.DestroyObject();
		obj = nil
		unlink(tmpName);
	end
	
	#
	# Returns an array containing original margins:
	# <ul>
	#   <li>:ret['left'] = left  margin</li>
	#   <li>:ret['right'] = right margin</li>
	# </ul>
	# @return array containing all margins measures 
	# @access public
	# @since 4.0.012 (2008-07-24)
	#
	def GetOriginalMargins()
		ret = { 'left' => @original_l_margin, 'right' => @original_r_margin }
		return ret
	end

	#
 	# Returns the PDF data.
	#
	def GetPDFData()
		if (@state < 3)
			Close();
		end
		return @buffer;
	end
	
	# --- HTML PARSER FUNCTIONS ---
	
	#
	# Returns the string used to find spaces
	# @return string
	# @access protected
	# @author Nicola Asuni
	# @since 4.8.024 (2010-01-15)
	#
	def getSpaceString()
		spacestr = 32.chr
		if (@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont0')
			spacestr = 0.chr + 32.chr
		end
		return spacestr
	end

	#
	# Allows to preserve some HTML formatting (limited support).<br />
	# IMPORTANT: The HTML must be well formatted - try to clean-up it using an application like HTML-Tidy before submitting.
	# Supported tags are: a, b, blockquote, br, dd, del, div, dl, dt, em, font, h1, h2, h3, h4, h5, h6, hr, i, img, li, ol, p, pre, small, span, strong, sub, sup, table, td, th, thead, tr, tt, u, ul
	# @param string :html text to display
	# @param boolean :ln if true add a new line after text (default = true)
	# @param int :fill Indicates if the background must be painted (1:true) or transparent (0:false).
	# @param boolean :reseth if true reset the last cell height (default false).
	# @param boolean :cell if true add the default c_margin space to each Write (default false).
	# @param string :align Allows to center or align the text. Possible values are:<ul><li>L : left align</li><li>C : center</li><li>R : right align</li><li>'' : empty string : left for LTR or right for RTL</li></ul>
	# @access public
	#
	def writeHTML(html, ln=true, fill=0, reseth=false, cell=false, align='')
		gvars = getGraphicVars()
		# store current values
		prevPage = @page
		prevlMargin = @l_margin
		prevrMargin = @r_margin
		curfontname = @font_family
		curfontstyle = @font_style
		curfontsize = @font_size_pt
		@newline = true
		startlinepage = @page
		minstartliney = @y
		startlinex = @x
		startliney = @y
		yshift = 0
		newline = true
		loop = 0
		curpos = 0
		opentagpos = nil
		this_method_vars = {}
		undo = false
		fontaligned = false
		blocktags = ['blockquote','br','dd','div','dt','h1','h2','h3','h4','h5','h6','hr','li','ol','p','ul']
		@premode = false
		if !@page_annots[@page].nil?
			pask = @page_annots[@page].length
		else
			pask = 0
		end
		if !@in_footer
			if !@footerlen[@page].nil?
				@footerpos[@page] = @pagelen[@page] - @footerlen[@page]
			else
				@footerpos[@page] = @pagelen[@page]
			end
		else
			startlinepos = @pagelen[@page]
		end
		startlinepos = @footerpos[@page]
		lalign = align
		plalign = align
		if @rtl
			w = @x - @l_margin
		else
			w = @w - @r_margin - @x
		end
		w -= 2 * @c_margin

		if cell
			if @rtl
				@x -= @c_margin
			else
				@x += @c_margin
			end
		end
		if @customlistindent >= 0
			@listindent = @customlistindent
		else
			@listindent = GetStringWidth('0000')
		end
		# save previous states
		prev_listnum = @listnum
		prev_listordered = @listordered
		prev_listcount = @listcount
		prev_lispacer = @lispacer
		@listnum = 0
		@listordered = []
		@listcount = []
		@lispacer = ''
		if empty_string(@lasth) or reseth
			#set row height
			@lasth = @font_size * @@k_cell_height_ratio
		end
		dom = getHtmlDomArray(html)
		maxel = dom.size
		key = 0
		while key < maxel
			if dom[key]['tag'] and dom[key]['attribute'] and dom[key]['attribute']['pagebreak']
				# check for pagebreak 
				if (dom[key]['attribute']['pagebreak'] == 'true') or (dom[key]['attribute']['pagebreak'] == 'left') or (dom[key]['attribute']['pagebreak'] == 'right')
					AddPage()
				end
				if ((dom[key]['attribute']['pagebreak'] == 'left') and ((!@rtl and (@page % 2 == 0)) or (@rtl and (@page % 2 != 0)))) or ((dom[key]['attribute']['pagebreak'] == 'right') and ((!@rtl and (@page % 2 != 0)) or (@rtl and (@page % 2 == 0))))
					AddPage()
				end
			end
			if dom[key]['tag'] and dom[key]['opening'] and dom[key]['attribute']['nobr'] and (dom[key]['attribute']['nobr'] == 'true')
				if dom[(dom[key]['parent'])]['attribute']['nobr'] and (dom[(dom[key]['parent'])]['attribute']['nobr'] == 'true')
					dom[key]['attribute']['nobr'] = false
				else
					# store current object
					startTransaction()
					# save this method vars
					this_method_vars['html'] = html
					this_method_vars['ln'] = ln
					this_method_vars['fill'] = fill
					this_method_vars['reseth'] = reseth
					this_method_vars['cell'] = cell
					this_method_vars['align'] = align
					this_method_vars['gvars'] = gvars
					this_method_vars['prevPage'] = prevPage
					this_method_vars['prevlMargin'] = prevlMargin
					this_method_vars['prevrMargin'] = prevrMargin
					this_method_vars['curfontname'] = curfontname
					this_method_vars['curfontstyle'] = curfontstyle
					this_method_vars['curfontsize'] = curfontsize
					this_method_vars['minstartliney'] = minstartliney
					this_method_vars['yshift'] = yshift
					this_method_vars['startlinepage'] = startlinepage
					this_method_vars['startlinepos'] = startlinepos
					this_method_vars['startlinex'] = startlinex
					this_method_vars['startliney'] = startliney
					this_method_vars['newline'] = newline
					this_method_vars['loop'] = loop
					this_method_vars['curpos'] = curpos
					this_method_vars['pask'] = pask
					this_method_vars['lalign'] = lalign
					this_method_vars['plalign'] = plalign
					this_method_vars['w'] = w
					this_method_vars['prev_listnum'] = prev_listnum
					this_method_vars['prev_listordered'] = prev_listordered
					this_method_vars['prev_listcount'] = prev_listcount
					this_method_vars['prev_lispacer'] = prev_lispacer
					this_method_vars['fontaligned'] = fontaligned
					this_method_vars['key'] = key
					this_method_vars['dom'] = dom
				end
			end
			# print THEAD block
			if (dom[key]['value'] == 'tr') and dom[key]['thead'] and dom[key]['thead']
				if dom[key]['parent'] and dom[(dom[key]['parent'])]['thead'] and !empty_string(dom[(dom[key]['parent'])]['thead'])
					@in_thead = true
					# print table header (thead)
					writeHTML(@thead, false, false, false, false, '')
					if (@start_transaction_page == (@numpages - 1)) or checkPageBreak(@lasth, '', false)
						# restore previous object
						rollbackTransaction(true)
						# restore previous values
						this_method_vars.each {|vkey , vval|
							eval("#{vkey} = vval") 
						}
						# add a page
						AddPage()
						@start_transaction_page = @page
					end
				end
				# move :key index forward to skip THEAD block
				while (key < maxel) and !((dom[key]['tag'] and dom[key]['opening'] and (dom[key]['value'] == 'tr') and (dom[key]['thead'].nil? or !dom[key]['thead'])) or (dom[key]['tag'] and !dom[key]['opening'] and (dom[key]['value'] == 'table')))
					key += 1
				end
			end
			if dom[key]['tag'] or (key == 0)
				if ((dom[key]['value'] == 'table') or (dom[key]['value'] == 'tr')) and !dom[key]['align'].nil?
					dom[key]['align'] = @rtl ? 'R' : 'L'
				end
				# vertically align image in line
				if !@newline and (dom[key]['value'] == 'img') and !dom[key]['attribute']['height'].nil? and (dom[key]['attribute']['height'].to_i > 0)
					# get image height
					imgh = getHTMLUnitToUnits(dom[key]['attribute']['height'], @lasth, 'px')
					# check for automatic line break
					autolinebreak = false
					if dom[key]['attribute']['width'] and (dom[key]['attribute']['width'].to_i > 0)
						imgw = getHTMLUnitToUnits(dom[key]['attribute']['width'], 1, 'px', false)
						if (@rtl and (@x - imgw < @l_margin + @c_margin)) or (!@rtl and (@x + imgw > @w - @r_margin - @c_margin))
							# add automatic line break
							autolinebreak = true
							Ln('', cell)
							# go back to evaluate this line break
							key -= 1
						end
					end
					if !autolinebreak
						if !@in_footer
							pre_y = @y
							# check for page break
							if !checkPageBreak(imgh) and (@y < pre_y)
								# fix for multicolumn mode
								startliney = @y
							end
						end
						if @page > startlinepage
							# fix line splitted over two pages
							if !@footerlen[startlinepage].nil?
								curpos = @pagelen[startlinepage] - @footerlen[startlinepage]
							end
							# line to be moved one page forward
							pagebuff = getPageBuffer(startlinepage)
							linebeg = pagebuff[startlinepos, curpos - startlinepos]
							tstart = pagebuff[0, startlinepos]
							tend = pagebuff[curpos..-1]
							# remove line from previous page
							setPageBuffer(startlinepage, tstart + '' + tend)
							pagebuff = getPageBuffer(@page)
							tstart = pagebuff[0, @cntmrk[@page]]
							tend = pagebuff[@cntmrk[@page]..-1]
							# add line start to current page
							yshift = minstartliney - @y
							if fontaligned
								yshift += curfontsize / @k
							end
							try = sprintf('1 0 0 1 0 %.3f cm', (yshift * @k))
							setPageBuffer(@page, tstart + "\nq\n" + try + "\n" + linebeg + "\nQ\n" + tend)
							# shift the annotations and links
							if @page_annots[@page]
								next_pask = @page_annots[@page].length
							else
								next_pask = 0
							end
							if !@page_annots[startlinepage].nil?
								@page_annots[startlinepage].each_with_index { |pac, pak|
									if pak >= pask
										@page_annots[@page].push pac
										@page_annots[startlinepage].delete_at(pak)
										npak = @page_annots[@page].length - 1
										@page_annots[@page][npak]['y'] -= yshift
									end
								}
							end
							pask = next_pask
							startlinepos = @cntmrk[@page]
							startlinepage = @page
							startliney = @y
						end
						@y += (curfontsize / @k) - imgh
						minstartliney = [@y, minstartliney].min
					end
	 			elsif !dom[key]['fontname'].nil? or !dom[key]['fontstyle'].nil? or !dom[key]['fontsize'].nil?
					# account for different font size
					pfontname = curfontname
					pfontstyle = curfontstyle
					pfontsize = curfontsize
					fontname  = !dom[key]['fontname'].nil?  ? dom[key]['fontname']  : curfontname
					fontstyle = !dom[key]['fontstyle'].nil? ? dom[key]['fontstyle'] : curfontstyle
					fontsize  = !dom[key]['fontsize'].nil?  ? dom[key]['fontsize']  : curfontsize
					if (fontname != curfontname) or (fontstyle != curfontstyle) or (fontsize != curfontsize)
						SetFont(fontname, fontstyle, fontsize)
						@lasth = @font_size * @@k_cell_height_ratio
						if (fontsize.is_a? Integer) and (fontsize > 0) and (curfontsize.is_a? Integer) and (curfontsize > 0) and (fontsize != curfontsize) and !@newline and (key < maxel - 1)
							if !@newline and (@page > startlinepage)
								# fix lines splitted over two pages
								if !@footerlen[startlinepage].nil?
									curpos = @pagelen[startlinepage] - @footerlen[startlinepage]
								end
								# line to be moved one page forward
								pagebuff = getPageBuffer(startlinepage)
								linebeg = pagebuff[startlinepos, curpos - startlinepos]
								tstart = pagebuff[0, startlinepos]
								tend = pagebuff[curpos..-1]
								# remove line from previous page
								setPageBuffer(startlinepage, tstart + '' + tend)
								pagebuff = getPageBuffer(@page)
								tstart = pagebuff[0, @cntmrk[@page]]
								tend = pagebuff[@cntmrk[@page]..-1]
								# add line start to current page
								yshift = minstartliney - @y
								try = sprintf('1 0 0 1 0 %.3f cm', yshift * @k)
								setPageBuffer(@page, tstart + "\nq\n" + try + "\n" + linebeg + "\nQ\n" + tend)
								# shift the annotations and links
								if @page_annots[@page]
									next_pask = @page_annots[@page].length
								else
									next_pask = 0
								end
								if !@page_annots[startlinepage].nil?
									@page_annots[startlinepage].each_with_index { |pac, pak|
										if pak >= pask
											@page_annots[@page].push = pac
											@page_annots[startlinepage].delete_at(pak)
											npak = @page_annots[@page].length - 1
											@page_annots[@page][npak]['y'] -= yshift
										end
									}
								end
								pask = next_pask
								startlinepos = @cntmrk[@page]
								startlinepage = @page
								startliney = @y
							end
							if (dom[key]['value'] != 'tr') and (dom[key]['value'] != 'td') and (dom[key]['value'] != 'th')
								@y += (curfontsize - fontsize) / @k
							end
							minstartliney = [@y, minstartliney].min
							fontaligned = true
						end
						SetFont(fontname, fontstyle, fontsize)
						@lasth = @font_size * @cell_height_ratio
						curfontname = fontname
						curfontstyle = fontstyle
						curfontsize = fontsize
					end
				end
				if (plalign == 'J') and blocktags.include?(dom[key]['value'])
					plalign = ''
				end
				# get current position on page buffer
				curpos = @pagelen[startlinepage]
				if !dom[key]['bgcolor'].nil? and (dom[key]['bgcolor'].length > 0)
					SetFillColorArray(dom[key]['bgcolor'])
					wfill = 1
				else
					wfill = fill || 0
				end
				if !dom[key]['fgcolor'].nil? and (dom[key]['fgcolor'].length > 0)
					SetTextColorArray(dom[key]['fgcolor'])
				end
				if !dom[key]['align'].nil?
					lalign = dom[key]['align']
				end
				if empty_string(lalign)
					lalign = align
				end
			end
			# align lines
			if @newline and (dom[key]['value'].length > 0) and (dom[key]['value'] != 'td') and (dom[key]['value'] != 'th')
				newline = true
				fontaligned = false
				# we are at the beginning of a new line
				if !startlinex.nil?
					yshift = minstartliney - startliney
					if (yshift > 0) or (@page > startlinepage)
						yshift = 0
					end
					t_x = 0
						# the last line must be shifted to be aligned as requested
						linew = (@endlinex - startlinex).abs
						pstart = getPageBuffer(startlinepage)[0, startlinepos]
						if !opentagpos.nil? and !@footerlen[startlinepage].nil? and !@in_footer
							@footerpos[startlinepage] = @pagelen[startlinepage] - @footerlen[startlinepage]
							midpos = [opentagpos, @footerpos[startlinepage]].min
						elsif !opentagpos.nil?
							midpos = opentagpos
						elsif !@footerlen[startlinepage].nil? and !@in_footer
							@footerpos[startlinepage] = @pagelen[startlinepage] - @footerlen[startlinepage]
							midpos = @footerpos[startlinepage]
						else
							midpos = 0
						end
						if midpos > 0
							pmid = getPageBuffer(startlinepage)[startlinepos, midpos - startlinepos]
							pend = getPageBuffer(startlinepage)[midpos..-1]
						else
							pmid = getPageBuffer(startlinepage)[startlinepos..-1]
							pend = ''
						end
					if (!plalign.nil? and ((plalign == 'C') or (plalign == 'J') or ((plalign == 'R') and !@rtl) or ((plalign == 'L') and @rtl))) or (yshift < 0)
						# calculate shifting amount
						tw = w
						if @l_margin != prevlMargin
							tw += prevlMargin - @l_margin
						end
						if @r_margin != prevrMargin
							tw += prevrMargin - @r_margin
						end
						one_space_width = GetStringWidth(32.chr)
						mdiff = (tw - linew).abs
						if plalign == 'C'
							if @rtl
								t_x = -(mdiff / 2)
							else
								t_x = (mdiff / 2)
							end
						elsif (plalign == 'R') and !@rtl
							# right alignment on LTR document
							if revstrpos(pmid, ')]').to_i == revstrpos(pmid, ' )]').to_i + 1
								# remove last space (if any)
								linew -= one_space_width
								mdiff = (tw - linew).abs
							end
							t_x = mdiff
						elsif (plalign == 'L') and @rtl
							# left alignment on RTL document
							if (revstrpos(pmid, '[( ').to_i == revstrpos(pmid, '[(').to_i) or (revstrpos(pmid, '[(' + 0.chr + 32.chr).to_i == revstrpos(pmid, '[(').to_i)
								# remove first space (if any)
								linew -= one_space_width
							end
							if pmid.index('[(').to_i == revstrpos(pmid, '[(').to_i
								# remove last space (if any)
								linew -= one_space_width
								if (@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont0')
									linew -= one_space_width
								end
							end
							mdiff = (tw - linew).abs
							t_x = -mdiff
						elsif (plalign == 'J') and (plalign == lalign)
							# Justification
							if isRTLTextDir()
								t_x = @l_margin - @endlinex + @c_margin
							end
							no = 0 # spaces without trim
							ns = 0 # spaces with trim

							pmidtemp = pmid
							# escape special characters
							pmidtemp.gsub!(/[\\][\(]/x, '\\#!#OP#!#')
							pmidtemp.gsub!(/[\\][\)]/x, '\\#!#CP#!#')
							# search spaces
							lnstring = pmidtemp.scan(/\[\(([^\)]*)\)\]/x)
							if !lnstring.empty?
								spacestr = getSpaceString()
								maxkk = lnstring.length - 1
								0.upto(maxkk) do |kk|
									# restore special characters
									lnstring[kk][0].gsub!('#!#OP#!#', '(')
									lnstring[kk][0].gsub!('#!#CP#!#', ')')
									if kk == maxkk
										if isRTLTextDir()
											tvalue = lnstring[kk][0].lstrip
										else
											tvalue = lnstring[kk][0].rstrip
										end
									else
										tvalue = lnstring[kk][0]
									end
									# store number of spaces on the strings
									lnstring[kk][1] = lnstring[kk][0].count(spacestr)
									lnstring[kk][2] = tvalue.count(spacestr)
									# count total spaces on line
									no += lnstring[kk][1]
									ns += lnstring[kk][2]
									lnstring[kk][3] = no
									lnstring[kk][4] = ns
								end
								if isRTLTextDir()
									t_x = @l_margin - @endlinex + @c_margin - ((no - ns) * one_space_width)
								end
								# calculate additional space to add to each space
								spacelen = one_space_width
								spacewidth = (((tw - linew) + ((no - ns) * spacelen)) / (ns ? ns : 1)) * @k
						 		spacewidthu = -1000 * ((tw - linew) + (no * spacelen)) / (ns ? ns : 1) / @font_size
								nsmax = ns
								ns = 0
								# reset(lnstring)
								offset = 0
								strcount = 0
								prev_epsposbeg = 0
								textpos = 0;
								if isRTLTextDir()
									textpos = @w_pt
								end
								while pmid_offset = pmid.index(/([0-9\.\+\-]*)[\s](Td|cm|m|l|c|re)[\s]/x, offset)
									pmid_data = $1
									pmid_mark = $2
									# check if we are inside a string section '[( ... )]'
									stroffset = pmid.index('[(', offset)
									if (stroffset != nil) and (stroffset <= pmid_offset)
										# set offset to the end of string section 
										offset = pmid.index(')]', stroffset)
										while (offset != nil) and (pmid[offset - 1, 1] == '\\')
											offset = pmid.index(')]', offset + 1)
										end
										if offset == false
											Error('HTML Justification: malformed PDF code.')
										end
										next
									end
									if isRTLTextDir()
										spacew = spacewidth * (nsmax - ns)
									else
										spacew = spacewidth * ns
									end
									offset = pmid_offset + $&.length
									epsposbeg = pmid.index('q' + @epsmarker, offset)
									epsposbeg = 0 if epsposbeg.nil?
									epsposend = pmid.index(@epsmarker + 'Q', offset)
									epsposend = 0 if epsposend.nil?
									epsposend += (@epsmarker + 'Q').length
									if ((epsposbeg > 0) and (epsposend > 0) and (offset > epsposbeg) and (offset < epsposend)) or ((epsposbeg === false) and (epsposend > 0) and (offset < epsposend))
										# shift EPS images
										trx = sprintf('1 0 0 1 %.3f 0 cm', spacew)
										epsposbeg = pmid.index('q' + @epsmarker, prev_epsposbeg - 6)
										epsposbeg = 0 if epsposbeg.nil?
										pmid_b = pmid[0, epsposbeg]
										pmid_m = pmid[epsposbeg, epsposend - epsposbeg]
										pmid_e = pmid[epsposend..-1]
										pmid = pmid_b + "\nq\n" + trx + "\n" + pmid_m + "\nQ\n" + pmid_e
										offset = epsposend
										next
									end
									prev_epsposbeg = epsposbeg
									currentxpos = 0
									# shift blocks of code
									case pmid_mark
									when 'Td', 'cm', 'm', 'l'
										# get current X position
										pmid =~ /([0-9\.\+\-]*)[\s](#{pmid_data})[\s](#{pmid_mark})([\s]*)/x
										currentxpos = $1.to_i
										textpos = currentxpos
										if (strcount <= maxkk) and (pmid_mark == 'Td')
											if strcount == maxkk
												if isRTLTextDir()
													tvalue = lnstring[strcount][0]
												else
													tvalue = lnstring[strcount][0].strip
												end
											else
												tvalue = lnstring[strcount][0]
											end
											ns += tvalue.count(spacestr)
											strcount += 1
										end
										if isRTLTextDir()
											spacew = spacewidth * (nsmax - ns)
										end
										# justify block
										pmid.sub!(/([0-9\.\+\-]*)[\s](#{pmid_data})[\s](#{pmid_mark})([\s]*)/x, "" + sprintf("%.2f", $1.to_f + spacew) + " " + $2 + " x*#!#*x" + $3 + $4)
									when 're'
										# justify block
										pmid =~ /([0-9\.\+\-]*)[\s]([0-9\.\+\-]*)[\s]([0-9\.\+\-]*)[\s](#{pmid_data})[\s](re)([\s]*)/x
										currentxpos = $1.to_i
										x_diff = 0
										w_diff = 0
										if isRTLTextDir() # RTL
											if currentxpos < textpos
												x_diff = spacewidth * (nsmax - lnstring[strcount][4])
												w_diff = spacewidth * lnstring[strcount][2]
											else
												if strcount > 0
													x_diff = spacewidth * (nsmax - lnstring[strcount - 1][4])
													w_diff = spacewidth * lnstring[strcount - 1][2]
												end
											end
										else # LTR
											if currentxpos > textpos
												if strcount > 0
													x_diff = spacewidth * lnstring[strcount - 1][3]
												end
												w_diff = spacewidth * lnstring[strcount][2]
											else
												if strcount > 1
													x_diff = spacewidth * lnstring[strcount - 2][3]
												end
												if strcount > 0
													w_diff = spacewidth * lnstring[strcount - 1][2]
												end
											end
										end
										pmid.sub!(/(#{$1})[\s](#{$2})[\s](#{$3})[\s](#{pmid_data})[\s](re)([\s]*)/x, "" + sprintf("%.2f", $1.to_f + x_diff) + " " + $2 + " " + sprintf("%.2f", $3.to_f + w_diff) + " " + $4 + " x*#!#*x" + $5 + $6)
									when 'c'
										# get current X position
										pmid =~ /([0-9\.\+\-]*)[\s]([0-9\.\+\-]*)[\s]([0-9\.\+\-]*)[\s]([0-9\.\+\-]*)[\s]([0-9\.\+\-]*)[\s](#{pmid_data})[\s](c)([\s]*)/x
										currentxpos = $1.to_i
										# justify block
										pmid.sub!(/(#{$1})[\s](#{$2})[\s](#{$3})[\s](#{$4})[\s](${5})[\s](#{pmid_data})[\s](c)([\s]*)/x, "" + sprintf("%.3f", $1.to_f + spacew) + " " + $2 + " " +  sprintf("%.3f", $3.to_f + spacew) + " " + $4 + " " + sprintf("%.3f", $5.to_f + spacew) + " " + $6 + " x*#!#*x" + $7 + $8)
									end
									# shift the annotations and links
									if !@page_annots[@page].nil?
										cxpos = currentxpos / @k
										lmpos = @l_margin + @c_margin + @feps

										@page_annots[@page].each_with_index { |pac, pak|
											if (pac['y'] >= minstartliney) and (pac['x'] * @k >= currentxpos - @feps) and (pac['x'] * @k <= currentxpos + @feps)
												if cxpos > lmpos
													@page_annots[@page][pak]['x'] += (spacew - one_space_width) / @k
													@page_annots[@page][pak]['w'] += (spacewidth * pac['numspaces']) / @k
												else
													@page_annots[@page][pak]['w'] += ((spacewidth * pac['numspaces']) - one_space_width) / @k
												end
												break
											end
										}
									end
								end # end of while
								# remove markers
								pmid.gsub!('x*#!#*x', '')
								if (@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont0')
									# multibyte characters
									spacew = spacewidthu
									pmidtemp = pmid
									# escape special characters
									pmidtemp.gsub!(/[\\][\(]/x, '\\#!#OP#!#')
									pmidtemp.gsub!(/[\\][\)]/x, '\\#!#CP#!#')
									pmidtemp =~ /\[\(([^\)]*)\)\]/x
									matches1 = $1.gsub("#!#OP#!#", "(")
									matches1.gsub!("#!#CP#!#", ")")
									pmid = pmidtemp.sub(/\[\(([^\)]*)\)\]/x,  "[(" + matches1.gsub(0.chr + 32.chr, ") " + sprintf("%.3f", spacew) + " (") + ")]")
									setPageBuffer(startlinepage, pstart + "\n" + pmid + "\n" + pend)
									endlinepos = (pstart + "\n" + pmid + "\n").length
								else
									# non-unicode (single-byte characters)
									rs = sprintf("%.3f Tw", spacewidth)
									pmid.gsub!(/\[\(/x, "#{rs} [(")
									setPageBuffer(startlinepage, pstart + "\n" + pmid + "\nBT 0 Tw ET\n" + pend)
									endlinepos = (pstart + "\n" + pmid + "\nBT 0 Tw ET\n").length
								end
							end
						end # end of J
					end # end if $startlinex
					if (t_x != 0) or (yshift < 0)
						# shift the line
						trx = sprintf('1 0 0 1 %.3f %.3f cm', t_x * @k, yshift * @k)
						setPageBuffer(startlinepage, pstart + "\nq\n" + trx + "\n" + pmid + "\nQ\n" + pend)
						endlinepos = (pstart + "\nq\n" + trx + "\n" + pmid + "\nQ\n").length
						# shift the annotations and links
						if !@page_annots[@page].nil?
							@page_annots[@page].each_with_index { |pac, pak|
								if pak >= pask
									@page_annots[@page][pak]['x'] += t_x
									@page_annots[@page][pak]['y'] -= yshift
								end
							}
						end
						@y -= yshift
					end
				end
				@newline = false
				pbrk = checkPageBreak(@lasth)
				startlinex = @x
				startliney = @y
				minstartliney = startliney
				startlinepage = @page
				if !endlinepos.nil? and !pbrk
					startlinepos = endlinepos
				else
					if !@in_footer
						if !@footerlen[@page].nil?
							@footerpos[@page] = @pagelen[@page] - @footerlen[@page]
						else
							@footerpos[@page] = @pagelen[@page]
						end
						startlinepos = @footerpos[@page]
					else
						startlinepos = @pagelen[@page]
					end
				end
				endlinepos = nil
				plalign = lalign
				if !@page_annots[@page].nil?
					pask = @page_annots[@page].length
				else
					pask = 0
				end
				SetFont(fontname, fontstyle, fontsize)
				if wfill  == 1
					SetFillColorArray(@bgcolor)
				end
			end # end newline
			if !opentagpos.nil?
				opentagpos = nil
			end
			if dom[key]['tag']
				if dom[key]['opening']    
					# get text indentation (if any)
					if dom[key]['text-indent'] and ['blockquote','dd','div','dt','h1','h2','h3','h4','h5','h6','li','ol','p','ul','table','tr','td'].include?(dom[key]['value'])
						@textindent = dom[key]['text-indent']
					end
					if dom[key]['value'] == 'table'
						# available page width
						if @rtl
							wtmp = @x - @l_margin
						else
							wtmp = @w - @r_margin - @x
						end
						if dom[key]['attribute']['nested'] and (dom[key]['attribute']['nested'] == 'true')
							# add margin for nested tables
							wtmp -= @c_margin
						end
						# table width
						if !dom[key]['width'].nil?
							table_width = getHTMLUnitToUnits(dom[key]['width'], wtmp, 'px')
						else
							table_width = wtmp
						end
					end
					if (dom[key]['value'] == 'td') or (dom[key]['value'] == 'th')
						trid = dom[key]['parent']
						table_el = dom[trid]['parent']
						if dom[table_el]['cols'].nil?
							dom[table_el]['cols'] = dom[trid]['cols']
						end
						oldmargin = @c_margin
						if !dom[(dom[trid]['parent'])]['attribute']['cellpadding'].nil?
							currentcmargin = getHTMLUnitToUnits(dom[(dom[trid]['parent'])]['attribute']['cellpadding'], 1, 'px')
						else
							currentcmargin = 0
						end
						@c_margin = currentcmargin
						if !dom[(dom[trid]['parent'])]['attribute']['cellspacing'].nil?
							cellspacing = getHTMLUnitToUnits(dom[(dom[trid]['parent'])]['attribute']['cellspacing'], 1, 'px')
						else
							cellspacing = 0
						end
						if @rtl
							cellspacingx = -cellspacing
						else
							cellspacingx = cellspacing
						end
						colspan = dom[key]['attribute']['colspan']
						table_columns_width = table_width - (cellspacing * (dom[table_el]['cols'] - 1))
						wtmp = colspan * (table_columns_width / dom[table_el]['cols']) + (colspan - 1) * cellspacing
						if !dom[key]['width'].nil?
							cellw = getHTMLUnitToUnits(dom[key]['width'], table_columns_width, 'px')
						else
							cellw = wtmp
						end
						if !dom[key]['height'].nil?
							# minimum cell height
							cellh = getHTMLUnitToUnits(dom[key]['height'], 0, 'px')
						else
							cellh = 0
						end
						if !dom[key]['content'].nil?
							cell_content = dom[key]['content']
						else
							cell_content = '&nbsp;'
						end
						tagtype = dom[key]['value']
						parentid = key
						while (key < maxel) and !(dom[key]['tag'] and !dom[key]['opening'] and (dom[key]['value'] == tagtype) and (dom[key]['parent'] == parentid))
							# move :key index forward
							key += 1
						end
						if dom[trid]['startpage'].nil?
							dom[trid]['startpage'] = @page
						else
							@page = dom[trid]['startpage']
						end
						if dom[trid]['starty'].nil?
							dom[trid]['starty'] = @y
						else
							@y = dom[trid]['starty']
						end
						if dom[trid]['startx'].nil?
							dom[trid]['startx'] = @x
						else
							@x += (cellspacingx / 2)
						end
						if !dom[parentid]['attribute']['rowspan'].nil?
							rowspan = dom[parentid]['attribute']['rowspan'].to_i
						else
							rowspan = 1
						end
						# skip row-spanned cells started on the previous rows
						if !dom[table_el]['rowspans'].nil?
							rsk = 0
							rskmax = dom[table_el]['rowspans'].length
							while rsk < rskmax
								trwsp = dom[table_el]['rowspans'][rsk]
								rsstartx = trwsp['startx']
								rsendx = trwsp['endx']
								# account for margin changes
								if trwsp['startpage'] < @page
									if @rtl and (@pagedim[@page]['orm'] != @pagedim[trwsp['startpage']]['orm'])
										dl = @pagedim[@page]['orm'] - @pagedim[trwsp['startpage']]['orm']
										rsstartx -= dl
										rsendx -= dl
									elsif !@rtl and (@pagedim[@page]['olm'] != @pagedim[trwsp['startpage']]['olm'])
										dl = @pagedim[@page]['olm'] - @pagedim[trwsp['startpage']]['olm']
										rsstartx += dl
										rsendx += dl
									end
								end
								if  (trwsp['rowspan'] > 0) and (rsstartx > @x - cellspacing - currentcmargin - @feps) and (rsstartx < @x + cellspacing + currentcmargin + @feps) and ((trwsp['starty'] < @y - @feps) or (trwsp['startpage'] < @page))
									# set the starting X position of the current cell
									@x = rsendx + cellspacingx
									if (trwsp['rowspan'] == 1) and !dom[trid]['endy'].nil? and !dom[trid]['endpage'].nil? and (trwsp['endpage'] == dom[trid]['endpage'])
										# set ending Y position for row
										dom[table_el]['rowspans'][rsk]['endy'] = [dom[trid]['endy'], trwsp['endy']].max
										dom[trid]['endy'] = dom[table_el]['rowspans'][rsk]['endy']
									end
									rsk = 0
								else
									rsk += 1
								end
							end
						end
						# add rowspan information to table element
						if rowspan > 1
							dom[table_el]['rowspans'].push({'trid' => trid, 'rowspan' => rowspan, 'mrowspan' => rowspan, 'colspan' => colspan, 'startpage' => @page, 'startx' => @x, 'starty' => @y})
							trsid = dom[table_el]['rowspans'].size
						end
						dom[trid]['cellpos'].push({'startx' => @x})
						cellid = dom[trid]['cellpos'].size
						if rowspan > 1
							dom[trid]['cellpos'][cellid - 1]['rowspanid'] = trsid - 1
						end
						# push background colors
						if !dom[parentid]['bgcolor'].nil? and (dom[parentid]['bgcolor'].length > 0)
							dom[trid]['cellpos'][cellid - 1]['bgcolor'] = dom[parentid]['bgcolor'].dup
						end
						prevLastH = @lasth
						# ****** write the cell content ******
						MultiCell(cellw, cellh, cell_content, 0, lalign, 0, 2, '', '', true, 0, true)
						@lasth = prevLastH
						@c_margin = oldmargin
						dom[trid]['cellpos'][cellid - 1]['endx'] = @x
						# update the end of row position
						if rowspan <= 1
							if !dom[trid]['endy'].nil?
								if @page == dom[trid]['endpage']
									dom[trid]['endy'] = [@y, dom[trid]['endy']].max
								elsif @page > dom[trid]['endpage']
									dom[trid]['endy'] = @y
								end
							else
								dom[trid]['endy'] = @y
							end
							if !dom[trid]['endpage'].nil?
								dom[trid]['endpage'] = [@page, dom[trid]['endpage']].max
							else
								dom[trid]['endpage'] = @page
							end
						else
							# account for row-spanned cells
							dom[table_el]['rowspans'][trsid - 1]['endx'] = @x
							dom[table_el]['rowspans'][trsid - 1]['endy'] = @y
							dom[table_el]['rowspans'][trsid - 1]['endpage'] = @page                             
						end
						if !dom[table_el]['rowspans'].nil?
							# update endy and endpage on rowspanned cells
							dom[table_el]['rowspans'].each_with_index { |trwsp, k|
								if trwsp['rowspan'] > 0
									if !dom[trid]['endpage'].nil?
										if trwsp['endpage'] == dom[trid]['endpage']
											dom[table_el]['rowspans'][k]['endy'] = [dom[trid]['endy'], trwsp['endy']].max
										elsif trwsp['endpage'] < dom[trid]['endpage']
											dom[table_el]['rowspans'][k]['endy'] = dom[trid]['endy']
											dom[table_el]['rowspans'][k]['endpage'] = dom[trid]['endpage']
										else
											dom[trid]['endy'] = @pagedim[dom[trid]['endpage']]['hk'] - @pagedim[dom[trid]['endpage']]['bm']
										end
									end
								end
							}
						end
						@x += (cellspacingx / 2)
					else
						# opening tag (or self-closing tag)
						if opentagpos.nil?
							if !@in_footer
								if !@footerlen[@page].nil?
									@footerpos[@page] = @pagelen[@page] - @footerlen[@page]
								else
									@footerpos[@page] = @pagelen[@page]
								end
								opentagpos = @footerpos[@page]
							end
						end
						openHTMLTagHandler(dom, key, cell)
					end
				else
					# closing tag
					closeHTMLTagHandler(dom, key, cell)
				end
			elsif dom[key]['value'].length > 0
				# print list-item
				if !empty_string(@lispacer)
					SetFont(pfontname, pfontstyle, pfontsize)
					@lasth = @font_size * @cell_height_ratio
					minstartliney = @y
					putHtmlListBullet(@listnum, @lispacer, pfontsize)
					if (pfontsize.is_a? Integer) and (pfontsize > 0) and (curfontsize.is_a? Integer) and (curfontsize > 0) and (pfontsize != curfontsize)
						@y += (pfontsize - curfontsize) / @k
						minstartliney = [@y, minstartliney].min
					end
				end
				# text
				@htmlvspace = 0
				if !@premode and isRTLTextDir()
					# reverse spaces order
					len1 = dom[key]['value'].length
					lsp = len1 - dom[key]['value'].lstrip.length
					rsp = len1 - dom[key]['value'].rstrip.length
					tmpstr = ''
					if rsp > 0
						tmpstr << dom[key]['value'][-rsp..-1]
					end
					tmpstr << (dom[key]['value']).strip
					if lsp > 0
						tmpstr << dom[key]['value'][0, lsp]
					end
					dom[key]['value'] = tmpstr
				end
				if newline
					if !@premode
						prelen = dom[key]['value'].length
						if isRTLTextDir()
							dom[key]['value'] = dom[key]['value'].rstrip + 0.chr
						else
							dom[key]['value'] = dom[key]['value'].lstrip
						end
						postlen = dom[key]['value'].length
						if (postlen == 0) and (prelen > 0)
							dom[key]['trimmed_space'] = true
						end
					end
					newline = false
					firstblock = true
				else
					firstblock = false
				end
				strrest = ''
				if @rtl
					@x -= @textindent
				else
					@x += @textindent
				end
				if !@href.empty? and @href['url']
					# HTML <a> Link
					strrest = addHtmlLink(@href['url'], dom[key]['value'].strip, wfill, true, @href['color'], @href['style'], true)
				else
					# ****** write only until the end of the line and get the rest ******
					strrest = Write(@lasth, dom[key]['value'], '', wfill, '', false, 0, true, firstblock, 0)
				end
				@textindent = 0

				if !strrest.nil? and strrest.length > 0
					# store the remaining string on the previous :key position
					@newline = true
					if cell
						if @rtl
							@x -= @c_margin
						else
							@x += @c_margin
						end
					end
					if strrest == dom[key]['value']
						# used to avoid infinite loop
						loop += 1
					else
						loop = 0
					end
					if !@href.empty? and @href['url']
						dom[key]['value'] = strrest.strip
					elsif @premode
						dom[key]['value'] = strrest
					elsif isRTLTextDir()
						dom[key]['value'] = strrest.rstrip
					else
						dom[key]['value'] = strrest.lstrip
					end
					if loop < 3
						key -= 1
					end
				else
					loop = 0
				end
			end
			key += 1
			if dom[key] and dom[key]['tag'] and (dom[key]['opening'].nil? or !dom[key]['opening']) and dom[(dom[key]['parent'])]['attribute']['nobr'] and (dom[(dom[key]['parent'])]['attribute']['nobr'] == 'true')
				if !undo and (@start_transaction_page == (@numpages - 1))
					# restore previous object
					rollbackTransaction(true)
					# restore previous values
					this_method_vars.each {|vkey , vval|
						eval("#{vkey} = vval") 
					}
					# add a page
					AddPage()
					undo = true # avoid infinite loop
				else
					undo = false
				end
			end
		end # end for each :key
		# align the last line
		if !startlinex.nil?
			yshift = minstartliney - startliney
			if (yshift > 0) or (@page > startlinepage)
				yshift = 0
			end
			t_x = 0
			# the last line must be shifted to be aligned as requested
			linew = (@endlinex - startlinex).abs
			pstart = getPageBuffer(startlinepage)[0, startlinepos]
			if !opentagpos.nil? and !@footerlen[startlinepage].nil? and !@in_footer
				@footerpos[startlinepage] = @pagelen[startlinepage] - @footerlen[startlinepage]
				midpos = [opentagpos, @footerpos[startlinepage]].min
			elsif !opentagpos.nil?
				midpos = opentagpos
			elsif !@footerlen[startlinepage].nil? and !@in_footer
				@footerpos[startlinepage] = @pagelen[startlinepage] - @footerlen[startlinepage]
				midpos = @footerpos[startlinepage]
			else
				midpos = 0
			end
			if midpos > 0
				pmid = getPageBuffer(startlinepage)[startlinepos, midpos - startlinepos]
				pend = getPageBuffer(startlinepage)[midpos..-1]
			else
				pmid = getPageBuffer(startlinepage)[startlinepos..-1]
				pend = ""
			end
			if (!plalign.nil? and (((plalign == 'C') or (plalign == 'J') or ((plalign == 'R') and !@rtl) or ((plalign == 'L') and @rtl)))) or (yshift < 0)
				# calculate shifting amount
				tw = w
				if @l_margin != prevlMargin
					tw += prevlMargin - @l_margin
				end
				if @r_margin != prevrMargin
					tw += prevrMargin - @r_margin
				end
				one_space_width = GetStringWidth(32.chr)
				mdiff = (tw - linew).abs
				if plalign == 'C'
					if @rtl
						t_x = -(mdiff / 2)
					else
						t_x = (mdiff / 2)
					end
				elsif (plalign == 'R') and !@rtl
					# right alignment on LTR document
					if revstrpos(pmid, ')]').to_i == revstrpos(pmid, ' )]').to_i + 1
						# remove last space (if any)
						linew -= one_space_width
						mdiff = (tw - linew).abs
					end
					t_x = mdiff
				elsif (plalign == 'L') and @rtl
					# left alignment on RTL document
					if (revstrpos(pmid, '[( ').to_i == revstrpos(pmid, '[(').to_i) or (revstrpos(pmid, '[(' + 0.chr + 32.chr).to_i == revstrpos(pmid, '[(').to_i)
						# remove first space (if any)
						linew -= one_space_width
					end
					if pmid.index('[(').to_i == revstrpos(pmid, '[(').to_i
						# remove last space (if any)
						linew -= one_space_width
						if (@current_font['type'] == 'TrueTypeUnicode') or (@current_font['type'] == 'cidfont0')
							linew -= one_space_width
						end
					end
					mdiff = (tw - linew).abs
					t_x = -mdiff
				end
			end # end if startlinex
			if (t_x != 0) or (yshift < 0)
				# shift the line
				trx = sprintf('1 0 0 1 %.3f %.3f cm', t_x * @k, yshift * @k)
				setPageBuffer(startlinepage, pstart + "\nq\n" + trx + "\n" + pmid + "\nQ\n" + pend)
				endlinepos = (pstart + "\nq\n" + trx + "\n" + pmid + "\nQ\n").length

				# shift the annotations and links
				if !@page_annots[@page].nil?
					@page_annots[@page].each_with_index { |pac, pak|
						if pak >= pask
							@page_annots[@page][pak]['x'] += t_x
							@page_annots[@page][pak]['y'] -= yshift
						end
					}
				end
				@y -= yshift
			end
		end
		if ln and !(cell and (dom[key-1]['value'] == 'table'))
			Ln(@lasth)
		end
		# restore previous values
		setGraphicVars(gvars)
		if @page > prevPage
			@l_margin = @pagedim[@page]['olm']
			@r_margin = @pagedim[@page]['orm']
		end
		# restore previous list state
		@listnum = prev_listnum
		@listordered = prev_listordered
		@listcount = prev_listcount
		@lispacer = prev_lispacer
		dom = nil
	end
  alias_method :write_html, :writeHTML

	#
	# Returns the current font size.
	# @return current font size
	# @access public
	# @since 3.2.000 (2008-06-23)
	#
	def GetFontSize()
		return @font_size
	end

	#
	# Returns the current font size in points unit.
	# @return current font size in points unit
	# @access public
	# @since 3.2.000 (2008-06-23)
	#
	def GetFontSizePt()
		return @font_size_pt
	end

	#
	# Returns the current font family name.
	# @return string current font family name
	# @access public
	# @since 4.3.008 (2008-12-05)
	#
	def GetFontFamily()
		return @font_family
	end

	#
	# Returns the current font style.
	# @return string current font style
	# @access public
	# @since 4.3.008 (2008-12-05)
	#
	def GetFontStyle()
		return @font_style
	end

	#
	# Prints a cell (rectangular area) with optional borders, background color and html text string. The upper-left corner of the cell corresponds to the current position. After the call, the current position moves to the right or to the next line.<br />
	# If automatic page breaking is enabled and the cell goes beyond the limit, a page break is done before outputting.
	# @param float :w Cell width. If 0, the cell extends up to the right margin.
	# @param float :h Cell minimum height. The cell extends automatically if needed.
	# @param float :x upper-left corner X coordinate
	# @param float :y upper-left corner Y coordinate
	# @param string :html html text to print. Default value: empty string.
	# @param mixed :border Indicates if borders must be drawn around the cell. The value can be either a number:<ul><li>0: no border (default)</li><li>1: frame</li></ul>or a string containing some or all of the following characters (in any order):<ul><li>L: left</li><li>T: top</li><li>R: right</li><li>B: bottom</li></ul>
	# @param int :ln Indicates where the current position should go after the call. Possible values are:<ul><li>0: to the right (or left for RTL language)</li><li>1: to the beginning of the next line</li><li>2: below</li></ul>
	# Putting 1 is equivalent to putting 0 and calling Ln() just after. Default value: 0.
	# @param int :fill Indicates if the cell background must be painted (1) or transparent (0). Default value: 0.
	# @param boolean :reseth if true reset the last cell height (default true).
	# @param string :align Allows to center or align the text. Possible values are:<ul><li>L : left align</li><li>C : center</li><li>R : right align</li><li>'' : empty string : left for LTR or right for RTL</li></ul>
	# @param boolean :autopadding if true, uses internal padding and automatically adjust it to account for line width.
	# @access public
	# @uses MultiCell()
	# @see Multicell(), writeHTML(), Cell()
	#
	def writeHTMLCell(w, h, x, y, html='', border=0, ln=0, fill=0, reseth=true, align='', autopadding=true)
		return MultiCell(w, h, html, border, align, fill, ln, x, y, reseth, 0, true, autopadding, 0)
	end
  alias_method :write_html_cell, :writeHTMLCell

	#
	# Extracts the CSS properties from a CSS string.
	# @param string :cssdata string containing CSS definitions.
	# @return A hash where the keys are the CSS selectors and the values are the CSS properties.
	# @author Nicola Asuni
	# @since 5.1.000 (2010-05-25)
	# @access protected
	#
	def extractCSSproperties(cssdata)
		if cssdata.empty?
			return {}
		end
		# remove comments
		cssdata.gsub!(/\/\*[^\*]*\*\//, '')
		# remove newlines and multiple spaces
		cssdata.gsub!(/[\s]+/, ' ')
		# remove some spaces
		cssdata.gsub!(/[\s]*([;:\{\}]{1})[\s]*/, '\\1')
		# remove empty blocks
		cssdata.gsub!(/([^\}\{]+)\{\}/, '')
		# replace media type parenthesis
		cssdata.gsub!(/@media[\s]+([^\{]*)\{/i, "@media \\1\t")
		cssdata.gsub!(/\}\}/mi, "}\t")
		# trim string
		cssdata = cssdata.lstrip
		# find media blocks (all, braille, embossed, handheld, print, projection, screen, speech, tty, tv)
		cssblocks = {}
		matches = cssdata.scan(/@media +([^\t]*)\t([^\t]*)\t/i)
		unless matches.empty?
			matches.each { |type|
				cssblocks[type[0]] = type[1]
			}
			# remove media blocks
			cssdata.gsub!(/@media +([^\t]*)\t([^\t]*)\t/i, '')
		end
		# keep 'all' and 'print' media, other media types are discarded
		if cssblocks['all'] and !cssblocks['all'].empty?
			cssdata << cssblocks['all']
		end
		if cssblocks['print'] and !cssblocks['print'].empty?
			cssdata << cssblocks['print']
		end
		# reset css blocks array
		cssblocks = []
		# explode css data string into array
		if cssdata[-1, 1] == '}'
			# remove last parethesis
			cssdata = cssdata.chop
		end
		matches = cssdata.split('}')
		matches.each_with_index { |block, key|
			# index 0 contains the CSS selector, index 1 contains CSS properties
			cssblocks[key] = block.split('{')
		}
		# split groups of selectors (comma-separated list of selectors)
		cssblocks.each_with_index { |block, key|
			# index 0 contains the CSS selector, index 1 contains CSS properties
			if block[0].index(',')
				selectors = block[0].split(',')
				selectors.each {|sel|
					cssblocks.push [sel.strip, block[1]]
				}
				cssblocks.delete_at(key)
			end
		}
		# covert array to selector => properties
		cssdata = {}
		cssblocks.each { |block|
			selector = block[0]
			# calculate selector's specificity
			a = 0 # the declaration is not from is a 'style' attribute
			b = selector.scan(/[\#]/).size # number of ID attributes
			c = selector.scan(/[\[\.]/).size # number of other attributes
			c += selector.scan(/[\:]link|visited|hover|active|focus|target|lang|enabled|disabled|checked|indeterminate|root|nth|first|last|only|empty|contains|not/i).size # number of pseudo-classes
			d = (' ' + selector).scan(/[\>\+\~\s]{1}[a-zA-Z0-9\*]+/).size # number of element names
			d += selector.scan(/[\:][\:]/).size # number of pseudo-elements
			specificity = a.to_s + b.to_s + c.to_s + d.to_s
			# add specificity to the beginning of the selector
			cssdata[specificity + ' ' + selector] = block[1]
		}
		# sort selectors alphabetically to account for specificity
		# ksort(cssdata, SORT_STRING)
		# return array
		return cssdata
	end

	#
	# Returns true if the CSS selector is valid for the selected HTML tag
	# @param array :dom array of HTML tags and properties
	# @param int :key key of the current HTML tag
	# @param string :selector CSS selector string
	# @return true if the selector is valid, false otherwise
	# @access protected
	# @since 5.1.000 (2010-05-25)
	#
	def isValidCSSSelectorForTag(dom, key, selector)
		valid = false; # value to be returned
		tag = dom[key]['value']
		selector_class = ''
		if dom[key]['attribute']['class'] and !dom[key]['attribute']['class'].empty?
			selector_class = dom[key]['attribute']['class'].downcase
		end
		id = ''
		if dom[key]['attribute']['id'] and !dom[key]['attribute']['id'].empty?
			selector_id = dom[key]['attribute']['id'].downcase
		end

		selector_offset = 0
		offset = nil
		operator = ''
		lasttag = ''
		attrib = ''
		while selector_offset = selector.index(/([\>\+\~\s]{1})([a-zA-Z0-9\*]+)([^\>\+\~\s]*)/mi, selector_offset)
			offset = selector_offset
			selector_offset += $&.length
			operator = $1
			lasttag = $2.strip.downcase
			attrib = $3.strip.downcase
		end
		if offset
			if (lasttag == '*') or (lasttag == tag)
				# the last element on selector is our tag or 'any tag'
				if !attrib.empty?
					# check if matches class, id, attribute, pseudo-class or pseudo-element
					case attrib[0, 1]
					when '.'  # class
						valid = true  if attrib.sub(/^./, "") == selector_class
					when '#'  # ID
						valid = true  if attrib.sub(/^#/, "") == selector_id
					when '['  # attribute
						attrmatch = attrib.scan(/\[([a-zA-Z0-9]*)[\s]*([\~\^\$\*\|\=]*)[\s]*["]?([^"\]]*)["]?\]/i)
						if !attrmatch.empty?
							att = attrmatch[0].downcase
							val = attrmatch[2]
							if dom[key]['attribute'][att]
								case attrmatch[1]
								when '='
									valid = true  if dom[key]['attribute'][att] == val
								when '~='
									valid = true  if dom[key]['attribute'][att].split(' ').include?(val)
								when '^='
									valid = true  if val == substr(dom[key]['attribute'][att], 0, val.length)
								when '$='
									valid = true  if val == substr(dom[key]['attribute'][att], -val.length)
								when '*='
									valid = true  if dom[key]['attribute'][att].index(val) != nil
								when '|='
									if dom[key]['attribute'][att] == val
										valid = true
									elsif ! dom[key]['attribute'][att].scan(/#{val}[\-]{1}/i).empty?
										valid = true
									end
								else
									valid = true
								end
							end
						end
					when ':'  # pseudo-class or pseudo-element
						if attrib{1} == ':'  # pseudo-element
							# pseudo-elements are not supported!
							# (::first-line, ::first-letter, ::before, ::after)
						else # pseudo-class
							# pseudo-classes are not supported!
							# (:root, :nth-child(n), :nth-last-child(n), :nth-of-type(n), :nth-last-of-type(n), :first-child, :last-child, :first-of-type, :last-of-type, :only-child, :only-of-type, :empty, :link, :visited, :active, :hover, :focus, :target, :lang(fr), :enabled, :disabled, :checked)
						end
					end # end of switch
				else
					valid = true
				end

				if valid and (offset > 0)
					valid = false
					# check remaining selector part
					selector = selector[0, offset]
					case operator
					when ' '  # descendant of an element
						while dom[key]['parent'] > 0
							if isValidCSSSelectorForTag(dom, dom[key]['parent'], selector)
								valid = true
								break
							else
								key = dom[key]['parent']
							end
						end
					when '>'  # child of an element
						valid = isValidCSSSelectorForTag(dom, dom[key]['parent'], selector)
					when '+'  # immediately preceded by an element
						(key - 1).downto(dom[key]['parent'] + 1) do |i|
							if dom[i]['tag'] and dom[i]['opening']
								valid = isValidCSSSelectorForTag(dom, i, selector)
								break
							end
						end
					when '~'  # preceded by an element
						(key - 1).downto(dom[key]['parent'] + 1) do |i|
							if dom[i]['tag'] and dom[i]['opening']
								if isValidCSSSelectorForTag(dom, i, selector)
									break
								end
							end
						end
					end
				end
			end
		end
		return valid
	end

	#
	# Returns the styles that apply for the selected HTML tag.
	# @param array :dom array of HTML tags and properties
	# @param int :key key of the current HTML tag
	# @param hash :css array of CSS properties
	# @return string containing CSS properties
	# @access protected
	# @since 5.1.000 (2010-05-25)
	#
	def getTagStyleFromCSS(dom, key, css)
		tagstyle = '' # style to be returned
		# get all styles that apply
		css.each { |selector, style|
			# remove specificity
			selector = selector[selector.index(' ')..-1] if selector.index(' ')
			# check if this selector apply to current tag
			if isValidCSSSelectorForTag(dom, key, selector)
				# apply style
				tagstyle << ';' + style
			end
		}
		if dom[key]['attribute']['style']
			# attach inline style (latest properties have high priority)
			tagstyle << ';' + dom[key]['attribute']['style']
		end
		# remove multiple semicolons
		tagstyle.gsub!(/[;]+/, ';')
		return tagstyle
	end

	#
	# Returns the HTML DOM array.
	# <ul><li>dom[key]['tag'] = true if tag, false otherwise;</li><li>dom[key]['value'] = tag name or text;</li><li>dom[key]['opening'] = true if opening tag, false otherwise;</li><li>dom[key]['attribute'] = array of attributes (attribute name is the key);</li><li>dom[key]['style'] = array of style attributes (attribute name is the key);</li><li>dom[key]['parent'] = id of parent element;</li><li>dom[key]['fontname'] = font family name;</li><li>dom[key]['fontstyle'] = font style;</li><li>dom[key]['fontsize'] = font size in points;</li><li>dom[key]['bgcolor'] = RGB array of background color;</li><li>dom[key]['fgcolor'] = RGB array of foreground color;</li><li>dom[key]['width'] = width in pixels;</li><li>dom[key]['height'] = height in pixels;</li><li>dom[key]['align'] = text alignment;</li><li>dom[key]['cols'] = number of colums in table;</li><li>dom[key]['rows'] = number of rows in table;</li></ul>
	# @param string :html html code
	# @return array
	# @since 3.2.000 (2008-06-20)
	#
	def getHtmlDomArray(html)
		# array of CSS styles ( selector => properties).
		css = {}
		# extract external CSS files
		matches = html.scan(/<link([^\>]*?)>/mi)
		unless matches.empty?
			matches.each { |link|
				type = link[0].scan(/type[\s]*=[\s]*"text\/css"/)
				next if type.empty?

				type = link[0].scan(/media[\s]*=[\s]*"([^"]*)"/)
				# get 'all' and 'print' media, other media types are discarded
				# (all, braille, embossed, handheld, print, projection, screen, speech, tty, tv)
				if type.empty? or (type[0][0] and ((type[0][0] == 'all') or (type[0][0] == 'print')))
					type = link[0].scan(/href[\s]*=[\s]*"([^"]*)"/)
					next if type.empty?

					# read CSS data file
					uri = type[0][0].strip
					if uri =~ %r{^/}
						uri_path = Rails.root.join('public')
						uri.sub!(%r{^/}, '')
						uri.split('/').each {|path|
							uri_path = uri_path.join(path)
						}
						cssdata = ''
						next unless File.exists?(uri_path)

						open(uri_path) do |f|
							cssdata << f.read
						end
					else
						uri = URI(uri)
						next if !uri.scheme or !uri.host

						res = Net::HTTP.get_response(uri)
						cssdata = res.body
					end
					css = css.merge(extractCSSproperties(cssdata))
				end
			}
		end
		# extract style tags
		matches = html.scan(/<style([^\>]*?)>([^\<]*?)<\/style>/mi)
		unless matches.empty?
			matches.each { |media|
				type = media[0].scan(/media[\s]*=[\s]*"([^"]*)"/)
				# get 'all' and 'print' media, other media types are discarded
				# (all, braille, embossed, handheld, print, projection, screen, speech, tty, tv)
				if type.empty? or (type[0] and ((type[0] == 'all') or (type[0] == 'print')))
					cssdata = media[1]
					css = css.merge(extractCSSproperties(cssdata))
				end
			}
		end
		# remove heade and style blocks
		html.gsub!(/<head([^\>]*?)>(.*)<\/head>/mi, '')
		html.gsub!(/<style([^\>]*?)>([^\<]*?)<\/style>/mi, '')
		# remove comments
		html.gsub!(/<!--(.|\s)*?-->/m, '')

		# remove all unsupported tags (the line below lists all supported tags)
		::ActionView::Base.sanitized_allowed_css_properties = ["page-break-before", "page-break-after", "page-break-inside"]
		html = "%s" % sanitize(html, :tags=> %w(marker a b blockquote body br dd del div dl dt em font h1 h2 h3 h4 h5 h6 hr i img li ol p pre small span strong sub sup table tablehead td th thead tr tt u ins ul), :attributes => %w(cellspacing cellpadding bgcolor color value width height src size colspan rowspan style align border face href dir class id nobr))
		html.force_encoding('UTF-8') if @is_unicode and html.respond_to?(:force_encoding)
		# replace some blank characters
		html.gsub!(/<br>/, '<br/>')
		html.gsub!(/<pre/, '<xre') # preserve pre tag
		html.gsub!(/<(table|tr|td|th|blockquote|dd|div|dt|h1|h2|h3|h4|h5|h6|br|hr|li|ol|ul|p)([^\>]*)>[\n\r\t]+/, '<\\1\\2>')
		html.gsub!(/@(\r\n|\r)@/, "\n")
		html.gsub!(/[\t\0\x0B]/, " ")
		html.gsub!(/\\/, "\\\\\\")

		offset = 0
		while (offset < html.length) and ((pos = html.index('</pre>', offset)) != nil)
			html_a = html[0, offset]
			html_b = html[offset, pos - offset + 6]
			while html_b =~ /<xre([^\>]*)>(.*?)\n(.*?)<\/pre>/mi
				# preserve newlines on <pre> tag
				html_b = html_b.gsub(/<xre([^\>]*)>(.*?)\n(.*?)<\/pre>/mi, "<xre\\1>\\2<br />\\3</pre>")
			end
			html = html_a + html_b + html[(pos + 6)..-1]
			offset = (html_a + html_b).length
		end
		html.gsub!(/[\n]/, " ")
		# remove extra spaces from code
		html.gsub!(/[\s]+<\/(table|tr|td|th|ul|ol|li)>/, '</\\1>')
		html.gsub!(/[\s]+<(tr|td|th|ul|ol|li|br)/, '<\\1')
		html.gsub!(/<\/(table|tr|td|th|blockquote|dd|div|dt|h1|h2|h3|h4|h5|h6|hr|li|ol|ul|p)>[\s]+</, '</\\1><')

		html.gsub!(/<\/(td|th)>/, '<marker style="font-size:0"/></\\1>')
		html.gsub!(/<\/table>([\s]*)<marker style="font-size:0"\/>/, '</table>')
		html.gsub!(/<img/, ' <img')
		html.gsub!(/<img([^\>]*)>/xi, '<img\\1><span><marker style="font-size:0"/></span>')
		html.gsub!(/<xre/, '<pre') # restore pre tag

		# trim string
		html.gsub!(/^[\s]+/, '')
		html.gsub!(/[\s]+$/, '')

		# pattern for generic tag
		tagpattern = /(<[^>]+>)/
		# explodes the string
		a = html.split(tagpattern)
		# count elements
		maxel = a.size
		elkey = 0
		key = 0
		# create an array of elements
		dom = []
		dom[key] = {}
		# set first void element
		dom[key]['tag'] = false
		dom[key]['value'] = ''
		dom[key]['parent'] = 0
		dom[key]['fontname'] = @font_family.dup
		dom[key]['fontstyle'] = @font_style.dup
		dom[key]['fontsize'] = @font_size_pt
		dom[key]['bgcolor'] = ActiveSupport::OrderedHash.new
		dom[key]['fgcolor'] = @fgcolor.dup

		dom[key]['align'] = ''
		dom[key]['listtype'] = ''
		dom[key]['text-indent'] = 0
		dom[key]['attribute'] = {} # reset attribute array
		thead = false # true when we are inside the THEAD tag
		key += 1
		level = []
		level.push(0) # root
		while elkey < maxel
			dom[key] = {}
			element = a[elkey]
			dom[key]['elkey'] = elkey
			if element =~ tagpattern
				# html tag
				element = element[1..-2]
				# get tag name
				tag = element.scan(/[\/]?([a-zA-Z0-9]*)/).flatten.delete_if {|x| x.length == 0}
				tagname = tag[0].downcase
				# check if we are inside a table header
				if tagname == 'thead'
					if element[0,1] == '/'
						thead = false
					else
						thead = true
					end
					elkey += 1
					next
				end
				dom[key]['tag'] = true
				dom[key]['value'] = tagname
				if element[0,1] == '/'
					# *** closing html tag
					dom[key]['opening'] = false
					dom[key]['parent'] = level[-1]
					level.pop if level.length > 1

					grandparent = dom[(dom[key]['parent'])]['parent']
					dom[key]['fontname'] = dom[grandparent]['fontname'].dup
					dom[key]['fontstyle'] = dom[grandparent]['fontstyle'].dup
					dom[key]['fontsize'] = dom[grandparent]['fontsize']
					dom[key]['bgcolor'] = dom[grandparent]['bgcolor'].dup
					dom[key]['fgcolor'] = dom[grandparent]['fgcolor'].dup
					dom[key]['align'] = dom[grandparent]['align'].dup
					if !dom[grandparent]['listtype'].nil?
						dom[key]['listtype'] = dom[grandparent]['listtype'].dup
					end
					# set the number of columns in table tag
					if (dom[key]['value'] == 'tr') and dom[grandparent]['cols'].nil?
						dom[grandparent]['cols'] = dom[(dom[key]['parent'])]['cols']
					end
					if (dom[key]['value'] == 'td') or (dom[key]['value'] == 'th')
						dom[(dom[key]['parent'])]['content'] = ''
						(dom[key]['parent'] + 1).upto(key - 1) do |i|
							dom[(dom[key]['parent'])]['content'] << a[dom[i]['elkey']]
						end
						# mark nested tables
						dom[(dom[key]['parent'])]['content'] = dom[(dom[key]['parent'])]['content'].gsub('<table', '<table nested="true"')
						# remove thead sections from nested tables
						dom[(dom[key]['parent'])]['content'] = dom[(dom[key]['parent'])]['content'].gsub('<thead>', '')
						dom[(dom[key]['parent'])]['content'] = dom[(dom[key]['parent'])]['content'].gsub('</thead>', '')
					end
					# store header rows on a new table
					if (dom[key]['value'] == 'tr') and (dom[(dom[key]['parent'])]['thead'] == true)
						if empty_string(dom[grandparent]['thead'])
							dom[grandparent]['thead'] = a[dom[grandparent]['elkey']].dup
						end
						dom[key]['parent'].upto(key) do |i|
							dom[grandparent]['thead'] << a[dom[i]['elkey']]
						end
						if dom[(dom[key]['parent'])]['attribute'].nil?
							dom[(dom[key]['parent'])]['attribute'] = {}
						end
						# header elements must be always contained in a single page
						dom[(dom[key]['parent'])]['attribute']['nobr'] = 'true'
					end
					if (dom[key]['value'] == 'table') and !empty_string(dom[(dom[key]['parent'])]['thead'])
						# remove the nobr attributes from the table header
						dom[(dom[key]['parent'])]['thead'] = dom[(dom[key]['parent'])]['thead'].gsub(' nobr="true"', '')
						dom[(dom[key]['parent'])]['thead'] << '</tablehead>'
					end
				else
					# *** opening html tag
					dom[key]['opening'] = true
					dom[key]['parent'] = level[-1]
					if element[-1, 1] != '/'
						# not self-closing tag
						level.push(key)
						dom[key]['self'] = false
					else
						dom[key]['self'] = true
					end
					# copy some values from parent
					parentkey = 0
					if key > 0
						parentkey = dom[key]['parent']
						dom[key]['fontname'] = dom[parentkey]['fontname'].dup
						dom[key]['fontstyle'] = dom[parentkey]['fontstyle'].dup
						dom[key]['fontsize'] = dom[parentkey]['fontsize']
						dom[key]['bgcolor'] = dom[parentkey]['bgcolor'].dup
						dom[key]['fgcolor'] = dom[parentkey]['fgcolor'].dup
						dom[key]['align'] = dom[parentkey]['align'].dup
						dom[key]['listtype'] = dom[parentkey]['listtype'].dup
						dom[key]['text-indent'] = dom[parentkey]['text-indent']
					end
					# get attributes
					attr_array = element.scan(/([^=\s]*)[\s]*=[\s]*"([^"]*)"/)
					dom[key]['attribute'] = {} # reset attribute array
					attr_array.each do |name, value|
						dom[key]['attribute'][name.downcase] = value
					end
					if !css.empty?
						# merge eternal CSS style to current style
						dom[key]['attribute']['style'] = getTagStyleFromCSS(dom, key, css)
					end
					# split style attributes
					if !dom[key]['attribute']['style'].nil?
						# get style attributes
						style_array = dom[key]['attribute']['style'].scan(/([^;:\s]*):([^;]*)/)
						dom[key]['style'] = {} # reset style attribute array
						style_array.each do |name, value|
							# in case of duplicate attribute the last replace the previous
							dom[key]['style'][name.downcase] = value.strip
						end
						# --- get some style attributes ---
						if !dom[key]['style']['font-family'].nil?
							# font family
							if !dom[key]['style']['font-family'].nil?
								fontslist = dom[key]['style']['font-family'].downcase.split(',')
								fontslist.each {|font|
									font = font.downcase.strip
									if @fontlist.include?(font) or @fontkeys.include?(font)
										dom[key]['fontname'] = font
										break
									end
								}
							end
						end
						# list-style-type
						if !dom[key]['style']['list-style-type'].nil?
							dom[key]['listtype'] = dom[key]['style']['list-style-type'].downcase.strip
							if dom[key]['listtype'] == 'inherit'
								dom[key]['listtype'] = dom[parentkey]['listtype']
							end
						end
						# text-indent
						if dom[key]['style']['text-indent']
							dom[key]['text-indent'] = getHTMLUnitToUnits(dom[key]['style']['text-indent'])
							if dom[key]['text-indent'] == 'inherit'
								dom[key]['text-indent'] = dom[parentkey]['text-indent']
							end
						end
						# font size
						if !dom[key]['style']['font-size'].nil?
							fsize = dom[key]['style']['font-size'].strip
							case fsize
								# absolute-size
							when 'xx-small'
								dom[key]['fontsize'] = dom[0]['fontsize'] - 4
							when 'x-small'
								dom[key]['fontsize'] = dom[0]['fontsize'] - 3
							when 'small'
								dom[key]['fontsize'] = dom[0]['fontsize'] - 2
							when 'medium'
								dom[key]['fontsize'] = dom[0]['fontsize']
							when 'large'
								dom[key]['fontsize'] = dom[0]['fontsize'] + 2
							when 'x-large'
								dom[key]['fontsize'] = dom[0]['fontsize'] + 4
							when 'xx-large'
								dom[key]['fontsize'] = dom[0]['fontsize'] + 6
								# relative-size
							when 'smaller'
								dom[key]['fontsize'] = dom[parentkey]['fontsize'] - 3
							when 'larger'
								dom[key]['fontsize'] = dom[parentkey]['fontsize'] + 3
							else
								dom[key]['fontsize'] = getHTMLUnitToUnits(fsize, dom[parentkey]['fontsize'], 'pt', true)
							end
						end
						# font style
						dom[key]['fontstyle'] ||= ""
						if !dom[key]['style']['font-weight'].nil? and (dom[key]['style']['font-weight'][0,1].downcase == 'b')
							dom[key]['fontstyle'] << 'B'
						end
						if !dom[key]['style']['font-style'].nil? and (dom[key]['style']['font-style'][0,1].downcase == 'i')
							dom[key]['fontstyle'] << 'I'
						end
						# font color
						if !empty_string(dom[key]['style']['color'])
							dom[key]['fgcolor'] = convertHTMLColorToDec(dom[key]['style']['color'])
						end
						# background color
						if !empty_string(dom[key]['style']['background-color'])
							dom[key]['bgcolor'] = convertHTMLColorToDec(dom[key]['style']['background-color'])
						end
						# text-decoration
						if !dom[key]['style']['text-decoration'].nil?
							decors = dom[key]['style']['text-decoration'].downcase.split(' ')
							decors.each {|dec|
								dec = dec.strip
								unless empty_string(dec)
									if dec[0,1] == 'u'
										dom[key]['fontstyle'] << 'U'
									elsif dec[0,1] == 'l'
										dom[key]['fontstyle'] << 'D'
									end
								end
							}
						end
						# check for width attribute
						if !dom[key]['style']['width'].nil?
							dom[key]['width'] = dom[key]['style']['width'].to_i
						end
						# check for height attribute
						if !dom[key]['style']['height'].nil?
							dom[key]['height'] = dom[key]['style']['height']
						end
						# check for text alignment
						if !dom[key]['style']['text-align'].nil?
							dom[key]['align'] = dom[key]['style']['text-align'][0,1].upcase
						end
						# check for border attribute
						if !dom[key]['style']['border'].nil?
							dom[key]['attribute']['border'] = dom[key]['style']['border']
						end

						# page-break-inside
						if dom[key]['style']['page-break-inside'] and (dom[key]['style']['page-break-inside'] == 'avoid')
							dom[key]['attribute']['nobr'] = 'true'
						end
						# page-break-before
						if dom[key]['style']['page-break-before']
							if dom[key]['style']['page-break-before'] == 'always'
								dom[key]['attribute']['pagebreak'] = 'true'
							elsif dom[key]['style']['page-break-before'] == 'left'
								dom[key]['attribute']['pagebreak'] = 'left'
							elsif dom[key]['style']['page-break-before'] == 'right'
								dom[key]['attribute']['pagebreak'] = 'right'
							end
						end
						# page-break-after
						if dom[key]['style']['page-break-after']
							if dom[key]['style']['page-break-after'] == 'always'
								dom[key]['attribute']['pagebreakafter'] = 'true'
							elsif dom[key]['style']['page-break-after'] == 'left'
								dom[key]['attribute']['pagebreakafter'] = 'left'
							elsif dom[key]['style']['page-break-after'] == 'right'
								dom[key]['attribute']['pagebreakafter'] = 'right'
							end
						end
					end
					# check for font tag
					if dom[key]['value'] == 'font'
						# font family
						if !dom[key]['attribute']['face'].nil?
							fontslist = dom[key]['attribute']['face'].downcase.split(',')
							fontslist.each { |font|
								font = font.downcase.strip
								if @fontlist.include?(font) or @fontkeys.include?(font)
									dom[key]['fontname'] = font
									break
								end
							}
						end
						# font size
						if !dom[key]['attribute']['size'].nil?
							if key > 0
								if dom[key]['attribute']['size'][0,1] == '+'
									dom[key]['fontsize'] = dom[(dom[key]['parent'])]['fontsize'] + dom[key]['attribute']['size'][1..-1].to_i
								elsif dom[key]['attribute']['size'][0,1] == '-'
									dom[key]['fontsize'] = dom[(dom[key]['parent'])]['fontsize'] - dom[key]['attribute']['size'][1..-1].to_i
								else
									dom[key]['fontsize'] = dom[key]['attribute']['size'].to_i
								end
							else
								dom[key]['fontsize'] = dom[key]['attribute']['size'].to_i
							end
						end
					end
					# force natural alignment for lists
					if (dom[key]['value'] == 'ul') or (dom[key]['value'] == 'ol') or (dom[key]['value'] == 'dl') and (empty_string(dom[key]['align']) or (dom[key]['align'] != 'J'))
						if @rtl
							dom[key]['align'] = 'R'
						else
							dom[key]['align'] = 'L'
						end
					end
					if (dom[key]['value'] == 'small') or (dom[key]['value'] == 'sup') or (dom[key]['value'] == 'sub')
						dom[key]['fontsize'] = dom[key]['fontsize'] * @@k_small_ratio
					end
					if (dom[key]['value'] == 'strong') or (dom[key]['value'] == 'b')
						dom[key]['fontstyle'] << 'B'
					end
					if (dom[key]['value'] == 'em') or (dom[key]['value'] == 'i')
						dom[key]['fontstyle'] << 'I'
					end
					if dom[key]['value'] == 'u' or dom[key]['value'] == 'ins'
						dom[key]['fontstyle'] << 'U'
					end
					if dom[key]['value'] == 'del'
						dom[key]['fontstyle'] << 'D'
					end
					if (dom[key]['value'] == 'pre') or (dom[key]['value'] == 'tt')
						dom[key]['fontname'] = @default_monospaced_font
					end
					if (dom[key]['value'][0,1] == 'h') and (dom[key]['value'][1,1].to_i > 0) and (dom[key]['value'][1,1].to_i < 7)
						headsize = (4 - dom[key]['value'][1,1].to_i) * 2
						dom[key]['fontsize'] = dom[0]['fontsize'] + headsize
						dom[key]['fontstyle'] << 'B'
					end
					if dom[key]['value'] == 'table'
						dom[key]['rows'] = 0 # number of rows
						dom[key]['trids'] = [] # IDs of TR elements
						dom[key]['thead'] = '' # table header rows
					end
					if dom[key]['value'] == 'tr'
						dom[key]['cols'] = 0
						if thead
							dom[key]['thead'] = true
							# rows on thead block are printed as a separate table
						else
							dom[key]['thead'] = false
							# store the number of rows on table element
							dom[(dom[key]['parent'])]['rows'] += 1
							# store the TR elements IDs on table element
							dom[(dom[key]['parent'])]['trids'].push(key)
						end
					end
					if (dom[key]['value'] == 'th') or (dom[key]['value'] == 'td')
						if !dom[key]['attribute']['colspan'].nil?
							colspan = dom[key]['attribute']['colspan'].to_i
						else
							colspan = 1
						end
						dom[key]['attribute']['colspan'] = colspan
						dom[(dom[key]['parent'])]['cols'] += colspan
					end
					# set foreground color attribute
					if !empty_string(dom[key]['attribute']['color'])
						dom[key]['fgcolor'] = convertHTMLColorToDec(dom[key]['attribute']['color'])
					end
					# set background color attribute
					if !empty_string(dom[key]['attribute']['bgcolor'])
						dom[key]['bgcolor'] = convertHTMLColorToDec(dom[key]['attribute']['bgcolor'])
					end
					# check for width attribute
					if !dom[key]['attribute']['width'].nil?
						dom[key]['width'] = dom[key]['attribute']['width'].to_i
					end
					# check for height attribute
					if !dom[key]['attribute']['height'].nil?
						dom[key]['height'] = dom[key]['attribute']['height']
					end
					# check for text alignment
					if !empty_string(dom[key]['attribute']['align']) and (dom[key]['value'] != 'img')
						dom[key]['align'] = dom[key]['attribute']['align'][0,1].upcase
					end
				end # end opening tag
			else
				# text
				dom[key]['tag'] = false
				dom[key]['value'] = unhtmlentities(element).gsub(/\\\\/, "\\")
				dom[key]['parent'] = level[-1]
			end
			elkey += 1
			key += 1
		end
		return dom
	end

	#
	# Convert to accessible file path
	# @param string :attrname image file name
	#
	def getImageFilename( attrname )
		attrname = attrname.gsub(@@k_path_url, @@k_path_main)
	end

	#
	# Process opening tags.
	# @param array :dom html dom array 
	# @param int :key current element id
	# @param boolean :cell if true add the default c_margin space to each new line (default false).
	# @access protected
	#
	def openHTMLTagHandler(dom, key, cell=false)
		tag = dom[key]
		parent = dom[(dom[key]['parent'])]
		firstorlast = (key == 1)
		# check for text direction attribute
		if !tag['attribute']['dir'].nil?
			SetTempRTL(tag['attribute']['dir'])
		else
			@tmprtl = false
		end

		#Opening tag
		case tag['value']
		when 'table'
			cp = 0
			cs = 0
			dom[key]['rowspans'] = []
			if dom[key]['attribute']['nested'].nil? or (dom[key]['attribute']['nested'] != 'true')
				# set table header
				if !empty_string(dom[key]['thead'])
					# set table header
					@thead = dom[key]['thead']
					if @thead_margins.nil? or @thead_margins.empty?
						@thead_margins ||= {}
						@thead_margins['cmargin'] = @c_margin
					end
				end
			end
			if !tag['attribute']['cellpadding'].nil?
				cp = getHTMLUnitToUnits(tag['attribute']['cellpadding'], 1, 'px')
				@old_c_margin = @c_margin
				@c_margin = cp
			end
			if !tag['attribute']['cellspacing'].nil?
				cs = getHTMLUnitToUnits(tag['attribute']['cellspacing'], 1, 'px')
			end
			if checkPageBreak(((2 * cp) + (2 * cs) + @lasth), '', false)
				@in_thead = true
				AddPage()
			end
		when 'tr'
			# array of columns positions
			dom[key]['cellpos'] = []
		when 'hr'
			Ln('', cell)
			addHTMLVertSpace(1, cell, '', firstorlast, tag['value'], false)
			@htmlvspace = 0
			wtmp = @w - @l_margin - @r_margin
			if !tag['attribute']['width'].nil? and (tag['attribute']['width'] != '')
				hrWidth = getHTMLUnitToUnits(tag['attribute']['width'], wtmp, 'px')
			else
				hrWidth = wtmp
			end
			x = GetX()
			y = GetY()
			prevlinewidth = GetLineWidth()
			Line(x, y, x + hrWidth, y)
			SetLineWidth(prevlinewidth)
			Ln('', cell)
			addHTMLVertSpace(1, cell, '', dom[key + 1].nil?, tag['value'], false)
		when 'a'
			if tag['attribute'].key?('href')
				@href['url'] = tag['attribute']['href']
			end
			@href['color'] = @html_link_color_array
			@href['style'] = @html_link_font_style
			if tag['attribute'].key?('style')
				# get style attributes
				style_array = tag['attribute']['style'].scan(/([^;:\s]*):([^;]*)/)
				astyle = {}
				style_array.each do |name, id|
					name = name.downcase
					astyle[name] = id.strip
				end
				if !astyle['color'].nil?
					@href['color'] = convertHTMLColorToDec(astyle['color'])
				end
				if !astyle['text-decoration'].nil?
					@href['style'] = ''
					decors = astyle['text-decoration'].downcase.split(' ') 
					decors.each {|dec|
						dec = dec.strip
						if !empty_string(dec)
							if dec[0, 1] == 'u'
								@href['style'] << 'U'
							elsif dec[0, 1] == 'l'
								@href['style'] << 'D'
							end
						end
					}
				end
			end
		when 'img'
			if !tag['attribute']['src'].nil?
				# replace relative path with real server path
				#if tag['attribute']['src'][0] == '/'
				#	tag['attribute']['src'] = Rails.root.join('public') + tag['attribute']['src']
				#end
				img_name = tag['attribute']['src']
				tag['attribute']['src'] = getImageFilename(tag['attribute']['src'])
				if tag['attribute']['width'].nil?
					tag['attribute']['width'] = 0
				end
				if tag['attribute']['height'].nil?
					tag['attribute']['height'] = 0
				end
				#if tag['attribute']['align'].nil?
					# the only alignment supported is "bottom"
					# further development is required for other modes.
					tag['attribute']['align'] = 'bottom'
				#end
				case tag['attribute']['align']
				when 'top'
					align = 'T'
				when 'middle'
					align = 'M'
				when 'bottom'
					align = 'B'
				else
					align = 'B'
				end
				type = getImageFileType(tag['attribute']['src'])
				prevy = @y
				xpos = GetX()
				# eliminate marker spaces
				if !dom[key - 1].nil?
					if (dom[key - 1]['value'] == ' ') or !dom[key - 1]['trimmed_space'].nil?
						xpos -= GetStringWidth(32.chr)
					elsif @rtl and (dom[key - 1]['value'] == '  ')
						xpos -= 2 * GetStringWidth(32.chr)
					end
				end
				imglink = ''
				if !@href['url'].nil? and !empty_string(@href['url'])
					imglink = @href['url']
					if imglink[0, 1] == '#'
						# convert url to internal link
						page = imglink.sub(/^#/, "").to_i
						imglink = AddLink()
						SetLink(imglink, 0, page)
					end
				end
				border = 0
				if !tag['attribute']['border'].nil? and !tag['attribute']['border'].empty?
					# currently only support 1 (frame) or a combination of 'LTRB'
					border = tag['attribute']['border']
					case tag['attribute']['border']
					when '0'
						border = 0
					when '1'
						border = 1
					else
						border = tag['attribute']['border']
					end
				end
				iw = 0
				if !tag['attribute']['width'].nil?
					iw = getHTMLUnitToUnits(tag['attribute']['width'], 1, 'px', false)
				end
				ih = 0
				if !tag['attribute']['height'].nil?
					ih = getHTMLUnitToUnits(tag['attribute']['height'], 1, 'px', false)
				end

				begin
#				if (type == 'eps') or (type == 'ai')
#					ImageEps(tag['attribute']['src'], xpos, GetY(), iw, ih, imglink, true, align, '', border)
#				else
					result_img = Image(tag['attribute']['src'], xpos, GetY(), iw, ih, '', imglink, align, false, 300, '', false, false, border, false, false)
#				end
				rescue => err
					logger.error "pdf: Image: error: #{err.message}"
					result_img = false
				end
				case align
				when 'T'
					@y = prevy
				when 'M'
					@y = (@img_rb_y + prevy - (tag['fontsize'] / @k)) / 2
				when 'B'
					@y = @img_rb_y - (tag['fontsize'] / @k)
				end
				if result_img == false
					Write(@lasth, File::basename(img_name), '', false, '', false, 0, false)
				end
			end
		when 'dl'
			@listnum += 1
			addHTMLVertSpace(0, cell, '', firstorlast, tag['value'], false)
		when 'dt'
			Ln('', cell)
			addHTMLVertSpace(1, cell, '', firstorlast, tag['value'], false)
		when 'dd'
			if @rtl
				@r_margin += @listindent
			else
				@l_margin += @listindent
			end
			addHTMLVertSpace(1, cell, '', firstorlast, tag['value'], false)
		when 'ul', 'ol'
			addHTMLVertSpace(0, cell, '', firstorlast, tag['value'], false)
			@htmlvspace = 0
			@listnum += 1
			if tag['value'] == "ol"
				@listordered[@listnum] = true
			else
				@listordered[@listnum] = false
			end
			if !tag['attribute']['start'].nil?
				@listcount[@listnum] = tag['attribute']['start'].to_i - 1
			else 
				@listcount[@listnum] = 0
			end
			if @rtl
				@r_margin += @listindent
			else
				@l_margin += @listindent
			end
		when 'li'
			addHTMLVertSpace(1, cell, '', firstorlast, tag['value'], false)
			if @listordered[@listnum]
				# ordered item
				if !empty_string(parent['attribute']['type'])
					@lispacer = parent['attribute']['type']
				elsif !empty_string(parent['listtype'])
					@lispacer = parent['listtype']
				elsif !empty_string(@lisymbol)
					@lispacer = @lisymbol
				else
					@lispacer = '#'
				end
				@listcount[@listnum] += 1
				if !tag['attribute']['value'].nil?
					@listcount[@listnum] = tag['attribute']['value'].to_i
				end
			else
				# unordered item
				if !empty_string(parent['attribute']['type'])
					@lispacer = parent['attribute']['type']
				elsif !empty_string(parent['listtype'])
					@lispacer = parent['listtype']
				elsif !empty_string(@lisymbol)
					@lispacer = @lisymbol
				else
					@lispacer = '!'
				end
			end
		when 'blockquote'
			if @rtl
				@r_margin += @listindent
			else
				@l_margin += @listindent
			end
			addHTMLVertSpace(2, cell, '', firstorlast, tag['value'], false)
		when 'br'
			Ln('', cell)
		when 'div'
			addHTMLVertSpace(1, cell, '', firstorlast, tag['value'], false)
		when 'p'
			addHTMLVertSpace(2, cell, '', firstorlast, tag['value'], false)
		when 'pre'
			addHTMLVertSpace(1, cell, '', firstorlast, tag['value'], false)
			@premode = true
		when 'sup'
			SetXY(GetX(), GetY() - ((0.7 * @font_size_pt) / @k))
		when 'sub'
			SetXY(GetX(), GetY() + ((0.3 * @font_size_pt) / @k))
		when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
			addHTMLVertSpace(1, cell, (tag['fontsize'] * 1.5) / @k, firstorlast, tag['value'], false)
		end

		if dom[key]['self'] and dom[key]['attribute']['pagebreakafter']
			pba = dom[key]['attribute']['pagebreakafter']
			# check for pagebreak 
			if (pba == 'true') or (pba == 'left') or (pba == 'right')
				AddPage()
			end
			if ((pba == 'left') and ((!@rtl and (@page % 2 == 0)) or (@rtl and (@page % 2 != 0)))) or ((pba == 'right') and ((!@rtl and (@page % 2 != 0)) or (@rtl and (@page % 2 == 0))))
				AddPage()
			end
		end
	end
  
	#
	# Process closing tags.
	# @param array :dom html dom array 
	# @param int :key current element id
	# @param boolean :cell if true add the default c_margin space to each new line (default false).
	# @access protected
	#
	def closeHTMLTagHandler(dom, key, cell=false)
		tag = dom[key].dup
		parent = dom[(dom[key]['parent'])].dup
		firstorlast = dom[key + 1].nil? or (dom[key + 2].nil? and (dom[key + 1]['value'] == 'marker'))
		in_table_head = false
		# Closing tag
		case (tag['value'])
			when 'tr'
				table_el = dom[(dom[key]['parent'])]['parent']
				if parent['endy'].nil?
					dom[(dom[key]['parent'])]['endy'] = @y
					parent['endy'] = @y
				end
				if parent['endpage'].nil?
					dom[(dom[key]['parent'])]['endpage'] = @page
					parent['endpage'] = @page
				end
				# update row-spanned cells
				if !dom[table_el]['rowspans'].nil?
					dom[table_el]['rowspans'].each_with_index { |trwsp, k|
						dom[table_el]['rowspans'][k]['rowspan'] -= 1
						if dom[table_el]['rowspans'][k]['rowspan'] == 0
							if dom[table_el]['rowspans'][k]['endpage'] == parent['endpage']
								dom[(dom[key]['parent'])]['endy'] = [dom[table_el]['rowspans'][k]['endy'], parent['endy']].max
							elsif dom[table_el]['rowspans'][k]['endpage'] > parent['endpage']
								dom[(dom[key]['parent'])]['endy'] = dom[table_el]['rowspans'][k]['endy']
								dom[(dom[key]['parent'])]['endpage'] = dom[table_el]['rowspans'][k]['endpage']
							end
						end
					}
					# report new endy and endpage to the rowspanned cells
					dom[table_el]['rowspans'].each_with_index { |trwsp, k|
						if dom[table_el]['rowspans'][k]['rowspan'] == 0
							dom[table_el]['rowspans'][k]['endpage'] = [dom[table_el]['rowspans'][k]['endpage'], dom[(dom[key]['parent'])]['endpage']].max
							dom[(dom[key]['parent'])]['endpage'] = dom[table_el]['rowspans'][k]['endpage']
							dom[table_el]['rowspans'][k]['endy'] = [dom[table_el]['rowspans'][k]['endy'], dom[(dom[key]['parent'])]['endy']].max
							dom[(dom[key]['parent'])]['endy'] = dom[table_el]['rowspans'][k]['endy']
						end
					}
					# update remaining rowspanned cells
					dom[table_el]['rowspans'].each_with_index { |trwsp, k|
						if dom[table_el]['rowspans'][k]['rowspan'] == 0
							dom[table_el]['rowspans'][k]['endpage'] = dom[(dom[key]['parent'])]['endpage']
							dom[table_el]['rowspans'][k]['endy'] = dom[(dom[key]['parent'])]['endy']
						end
					}
				end
				SetPage(dom[(dom[key]['parent'])]['endpage']);
				@y = dom[(dom[key]['parent'])]['endy']
				if !dom[table_el]['attribute']['cellspacing'].nil?
					cellspacing = getHTMLUnitToUnits(dom[table_el]['attribute']['cellspacing'], 1, 'px')
					@y += cellspacing
				end
				Ln(0, cell)
				@x = parent['startx']
				# account for booklet mode
				if @page > parent['startpage']
					if @rtl and (@pagedim[@page]['orm'] != @pagedim[parent['startpage']]['orm'])
						@x -= @pagedim[@page]['orm'] - @pagedim[parent['startpage']]['orm']
					elsif !@rtl and (@pagedim[@page]['olm'] != @pagedim[parent['startpage']]['olm'])
						@x += @pagedim[@page]['olm'] - @pagedim[parent['startpage']]['olm']
					end
				end
			when 'table', 'tablehead'
				if tag['value'] == 'tablehead'
					# closing tag used for the thead part
					in_table_head = true
					@in_thead = false
				end

				table_el = parent
				# draw borders
				if (!table_el['attribute']['border'].nil? and (table_el['attribute']['border'].to_i > 0)) or (!table_el['style'].nil? and !table_el['style']['border'].nil? and (table_el['style']['border'].to_i > 0))
					border = 1
				else
					border = 0
				end

				startpage = 0
				end_page = 0
				# fix bottom line alignment of last line before page break
				dom[(dom[key]['parent'])]['trids'].each_with_index { |trkey, j|
					# update row-spanned cells
					if !dom[(dom[key]['parent'])]['rowspans'].nil?
						dom[(dom[key]['parent'])]['rowspans'].each_with_index { |trwsp, k|
							if trwsp['trid'] == trkey
								dom[(dom[key]['parent'])]['rowspans'][k]['mrowspan'] -= 1
							end
							if defined?(prevtrkey) and (trwsp['trid'] == prevtrkey) and (trwsp['mrowspan'] >= 0)
								dom[(dom[key]['parent'])]['rowspans'][k]['trid'] = trkey
							end
						}
					end
					if defined?(prevtrkey) and (dom[trkey]['startpage'] > dom[prevtrkey]['endpage'])
						pgendy = @pagedim[dom[prevtrkey]['endpage']]['hk'] - @pagedim[dom[prevtrkey]['endpage']]['bm']
						dom[prevtrkey]['endy'] = pgendy
						# update row-spanned cells
						if !dom[(dom[key]['parent'])]['rowspans'].nil?
							dom[(dom[key]['parent'])]['rowspans'].each_with_index { |trwsp, k|
								if (trwsp['trid'] == trkey) and (trwsp['mrowspan'] > 1) and (trwsp['endpage'] == dom[prevtrkey]['endpage'])
									dom[(dom[key]['parent'])]['rowspans'][k]['endy'] = pgendy
									dom[(dom[key]['parent'])]['rowspans'][k]['mrowspan'] = -1
								end
							}
						end
					end
					prevtrkey = trkey
					table_el = dom[(dom[key]['parent'])].dup
				}
				# for each row
				table_el['trids'].each_with_index { |trkey, j|
					parent = dom[trkey]
					# for each cell on the row
					parent['cellpos'].each_with_index { |cellpos, k|
						if !cellpos['rowspanid'].nil? and (cellpos['rowspanid'] >= 0)
							cellpos['startx'] = table_el['rowspans'][(cellpos['rowspanid'])]['startx']
							cellpos['endx'] = table_el['rowspans'][(cellpos['rowspanid'])]['endx']
							endy = table_el['rowspans'][(cellpos['rowspanid'])]['endy']
							startpage = table_el['rowspans'][(cellpos['rowspanid'])]['startpage']
							end_page = table_el['rowspans'][(cellpos['rowspanid'])]['endpage']
						else
							endy = parent['endy']
							startpage = parent['startpage']
							end_page = parent['endpage']
						end
						if end_page > startpage
							# design borders around HTML cells.
							startpage.upto(end_page) do |page|
								SetPage(page)
								if page == startpage
									@y = parent['starty'] # put cursor at the beginning of row on the first page
									ch = GetPageHeight() - parent['starty'] - GetBreakMargin()
									cborder = getBorderMode(border, position='start')
								elsif page == end_page
									@y = @t_margin # put cursor at the beginning of last page
									ch = endy - @t_margin
									cborder = getBorderMode(border, position='end')
								else
									@y = @t_margin # put cursor at the beginning of the current page
									ch = GetPageHeight() - @t_margin - GetBreakMargin()
									cborder = getBorderMode(border, position='middle')
								end
								if !cellpos['bgcolor'].nil? and (cellpos['bgcolor'] != false)
									SetFillColorArray(cellpos['bgcolor'])
									fill = 1
								else
									fill = 0
								end
								cw = (cellpos['endx'] - cellpos['startx']).abs
								@x = cellpos['startx']
								# account for margin changes
								if page > startpage
									if @rtl and (@pagedim[page]['orm'] != @pagedim[startpage]['orm'])
										@x -= @pagedim[page]['orm'] - @pagedim[startpage]['orm']
									elsif !@rtl and (@pagedim[page]['lm'] != @pagedim[startpage]['olm'])
										@x += @pagedim[page]['olm'] - @pagedim[startpage]['olm']
									end
								end
								# design a cell around the text
								ccode = @fill_color + "\n" + getCellCode(cw, ch, '', cborder, 1, '', fill, '', 0, true)
								if (cborder != 0) or (fill == 1)
									pagebuff = getPageBuffer(@page)
									pstart = pagebuff[0, @intmrk[@page]]
									pend = pagebuff[@intmrk[@page]..-1]
									setPageBuffer(@page, pstart + ccode + "\n" + pend)
									@intmrk[@page] += (ccode + "\n").length
								end
							end
						else
							SetPage(startpage)
							if !cellpos['bgcolor'].nil? and (cellpos['bgcolor'] != false)
								SetFillColorArray(cellpos['bgcolor'])
								fill = 1
							else
								fill = 0
							end
							@x = cellpos['startx']
							@y = parent['starty']
							cw = (cellpos['endx'] - cellpos['startx']).abs
							ch = endy - parent['starty']
							# design a cell around the text
							ccode = @fill_color + "\n" + getCellCode(cw, ch, '', border, 1, '', fill, '', 0, true)
							if (border != 0) or (fill == 1)
								if !@transfmrk[@page].nil?
									pagemark = @transfmrk[@page]
									@transfmrk[@page] += (ccode + "\n").length
								elsif @in_footer
									pagemark = @footerpos[@page]
									@footerpos[@page] += (ccode + "\n").length
								else
									pagemark = @intmrk[@page]
									@intmrk[@page] += (ccode + "\n").length
								end
								pagebuff = getPageBuffer(@page)
								pstart = pagebuff[0, pagemark]
								pend = pagebuff[pagemark..-1]
								setPageBuffer(@page, pstart + ccode + "\n" + pend)
							end
						end
					}                                       
					if !table_el['attribute']['cellspacing'].nil?
						cellspacing = getHTMLUnitToUnits(table_el['attribute']['cellspacing'], 1, 'px')
						@y += cellspacing
					end
					Ln(0, cell)
					@x = parent['startx']
					if end_page > startpage
						if @rtl and (@pagedim[end_page]['orm'] != @pagedim[startpage]['orm'])
							@x += @pagedim[end_page]['orm'] - @pagedim[startpage]['orm']
						elsif !@rtl and (@pagedim[end_page]['olm'] != @pagedim[startpage]['olm'])
							@x += @pagedim[end_page]['olm'] - @pagedim[startpage]['olm']
						end
					end
				}
				if !in_table_head
					# we are not inside a thead section
					if !parent['cellpadding'].nil?
						@c_margin = @old_c_margin
					end
					@lasth = @font_size * @cell_height_ratio
					if !@thead_margins['top'].nil?
						if (@thead_margins['top'] == @t_margin) and (@page == (@numpages - 1))
							# remove last page containing only THEAD
							deletePage(@numpages)
						end
						# restore top margin
						@t_margin = @thead_margins['top']
						@pagedim[@page]['tm'] = @t_margin
					end
					if table_el['attribute']['nested'].nil? or (table_el['attribute']['nested'] != 'true')
						# reset main table header
						@thead = ''
						@thead_margins = {}
					end
				end
			when 'a'
				@href = {}
			when 'sup'
				SetXY(GetX(), GetY() + (0.7 * parent['fontsize'] / @k))
			when 'sub'
				SetXY(GetX(), GetY() - (0.3 * parent['fontsize'] / @k))
			when 'div'
				addHTMLVertSpace(1, cell, '', firstorlast, tag['value'], true)
			when 'blockquote'
				if @rtl
					@r_margin -= @listindent
				else
					@l_margin -= @listindent
				end
				addHTMLVertSpace(2, cell, '', firstorlast, tag['value'], true)
			when 'p'
				addHTMLVertSpace(2, cell, '', firstorlast, tag['value'], true)
			when 'pre'
				addHTMLVertSpace(1, cell, '', firstorlast, tag['value'], true)
				@premode = false
			when 'dl'
				@listnum -= 1
				if @listnum <= 0
					@listnum = 0
					addHTMLVertSpace(2, cell, '', firstorlast, tag['value'], true)
				end
			when 'dt'
				@lispacer = ''
				addHTMLVertSpace(0, cell, '', firstorlast, tag['value'], true)
			when 'dd'
				@lispacer = ''
				if @rtl
					@r_margin -= @listindent
				else
					@l_margin -= @listindent
				end
				addHTMLVertSpace(0, cell, '', firstorlast, tag['value'], true)
			when 'ul', 'ol'
				@listnum -= 1
				@lispacer = ''
				if @rtl
					@r_margin -= @listindent
				else
					@l_margin -= @listindent
				end
				if @listnum <= 0
					@listnum = 0
					addHTMLVertSpace(2, cell, '', firstorlast, tag['value'], true)
				end
				@lasth = @font_size * @cell_height_ratio
			when 'li'
				@lispacer = ''
				addHTMLVertSpace(0, cell, '', firstorlast, tag['value'], true)
			when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
				addHTMLVertSpace(1, cell, (parent['fontsize'] * 1.5) / @k, firstorlast, tag['value'], true)
		end
		if dom[(dom[key]['parent'])]['attribute']['pagebreakafter']
			pba = dom[(dom[key]['parent'])]['attribute']['pagebreakafter']
			# check for pagebreak 
			if (pba == 'true') or (pba == 'left') or (pba == 'right')
				AddPage()
			end
			if ((pba == 'left') and ((!@rtl and (@page % 2 == 0)) or (@rtl and (@page % 2 != 0)))) or ((pba == 'right') and ((!@rtl and (@page % 2 != 0)) or (@rtl and (@page % 2 == 0))))
				AddPage()
			end
		end
		@tmprtl = false
	end
	
	#
	# Add vertical spaces if needed.
	# @param int :n number of spaces to add
	# @param boolean :cell if true add the default cMargin space to each new line (default false).
	# @param string :h The height of the break. By default, the value equals the height of the last printed cell.
	# @param boolean :firstorlast if true do not print additional empty lines.
	# @param string :tag HTML tag to which this space will be applied
	# @param boolean :closing true if this space will be applied to a closing tag, false otherwise
	# @access protected
	#
	def addHTMLVertSpace(n, cell=false, h='', firstorlast=false, tag='', closing=false)
		if firstorlast
			Ln(0, cell)
			@htmlvspace = 0
			return
		end
		#### no use ###
		#closing = closing ? 1 : 0
		#if !@tagvspaces[tag][closing]['n'].nil?
		#	n = @tagvspaces[tag][closing]['n']
		#end
		#if !@tagvspaces[tag][closing]['h'].nil?
		#	h = @tagvspaces[tag][closing]['h']
		#end
		if h.is_a?(String)
			vsize = n * @lasth
		else
			vsize = n * h
		end
		if vsize > @htmlvspace
			Ln(vsize - @htmlvspace, cell)
			@htmlvspace = vsize
		end
	end

	#
	# Set the booklet mode for double-sided pages.
	# @param boolean :booklet true set the booklet mode on, fals eotherwise.
	# @param float :inner Inner page margin.
	# @param float :outer Outer page margin.
	# @access public
	# @since 4.2.000 (2008-10-29)
	#
	def SetBooklet(booklet=true, inner=-1, outer=-1)
		@booklet = booklet
		if inner >= 0
			@l_margin = inner
		end
		if outer >= 0
			@r_margin = outer
		end
	end

	#
	# Swap the left and right margins.
	# @param boolean :reverse if true swap left and right margins.
	# @access protected
	# @since 4.2.000 (2008-10-29)
	#
	def swapMargins(reverse=true)
		if reverse
			# swap left and right margins
			mtemp = @original_l_margin
			@original_l_margin = @original_r_margin
			@original_r_margin = mtemp
			deltam = @original_l_margin - @original_r_margin
			@l_margin += deltam
			@r_margin -= deltam
		end
	end

	#
	# Set the vertical spaces for HTML tags.
	# The array must have the following structure (example):
	# :tagvs = {'h1' => {0 => {'h' => '', 'n' => 2}, 1 => {'h' => 1.3, 'n' => 1}}}
	# The first array level contains the tag names,
	# the second level contains 0 for opening tags or 1 for closing tags,
	# the third level contains the vertical space unit (h) and the number spaces to add (n).
	# If the h parameter is not specified, default values are used.
	# @param array :tagvs array of tags and relative vertical spaces.
	# @access public
	# @since 4.2.001 (2008-10-30)
	#
	def setHtmlVSpace(tagvs)
		@tagvspaces = tagvs
	end

	#
	# convert html string containing value and unit of measure to user's units or points.
	# @param string :htmlval string containing values and unit
	# @param string :refsize reference value in points
	# @param string :defaultunit default unit (can be one of the following: %, em, ex, px, in, mm, pc, pt).
	# @param boolean :point if true returns points, otherwise returns value in user's units
	# @return float value in user's unit or point if :points=true
	# @access public
	# @since 4.4.004 (2008-12-10)
	#
	def getHTMLUnitToUnits(htmlval, refsize=1, defaultunit='px', points=false)
		supportedunits = ['%', 'em', 'ex', 'px', 'in', 'cm', 'mm', 'pc', 'pt']
		retval = 0
		value = 0
		unit = 'px'
		k = @k
		if points
			k = 1
		end
		if supportedunits.include?(defaultunit)
			unit = defaultunit
		end
		if htmlval.is_a? Integer
			value = htmlval.to_f
		else
			mnum = htmlval.scan(/[0-9\.]+/)
			unless mnum.empty?
				value = mnum[0].to_f
				munit = htmlval.scan(/([a-z%]+)/)
				unless munit.empty?
					if supportedunits.include?(munit[0])
						unit = munit[0]
					end
				end
			end
		end
		case unit
			# percentage
		when '%'
			retval = ((value * refsize) / 100)
			# relative-size
		when 'em'
			retval = (value * refsize)
		when 'ex'
			retval = value * (refsize / 2)
			# absolute-size
		when 'in'
			retval = (value * @dpi) / k
		when 'cm'
			retval = (value / 2.54 * @dpi) / k
		when 'mm'
			retval = (value / 25.4 * @dpi) / k
		when 'pc'
			# one pica is 12 points
			retval = (value * 12) / k
		when 'pt'
			retval = value / k
		when 'px'
			retval = pixelsToUnits(value)
		end
		return retval
	end

	#
	# Returns the Roman representation of an integer number
	# @param int :number to convert
	# @return string roman representation of the specified number
	# @access public
	# @since 4.4.004 (2008-12-10)
	#
	def intToRoman(number)
		roman = ''
		while number >= 1000
			roman << 'M'
			number -= 1000
		end
		while number >= 900
			roman << 'CM'
			number -= 900
		end
		while number >= 500
			roman << 'D'
			number -= 500
		end
		while number >= 400
			roman << 'CD'
			number -= 400
		end
		while number >= 100
			roman << 'C'
			number -= 100
		end
		while number >= 90
			roman << 'XC'
			number -= 90
		end
		while number >= 50
			roman << 'L'
			number -= 50
		end
		while number >= 40
			roman << 'XL'
			number -= 40
		end
		while number >= 10
			roman << 'X'
			number -= 10
		end
		while number >= 9
			roman << 'IX'
			number -= 9
		end
		while number >= 5
			roman << 'V'
			number -= 5
		end
		while number >= 4
			roman << 'IV'
			number -= 4
		end
		while number >= 1
			roman << 'I'
			number -= 1
		end
		return roman
	end

	#
	# Output an HTML list bullet or ordered item symbol
	# @param int :listdepth list nesting level
	# @param string :listtype type of list
	# @param float :size current font size
	# @access protected
	# @since 4.4.004 (2008-12-10)
	#
	def putHtmlListBullet(listdepth, listtype='', size=10)
		size /= @k
		fill = ''
		color = @fgcolor
		width = 0
		textitem = ''
		tmpx = @x           
		lspace = GetStringWidth('  ')
		if listtype == '!'
			# set default list type for unordered list
			deftypes = ['disc', 'circle', 'square']
			listtype = deftypes[(listdepth - 1) % 3]
		elsif listtype == '#'
			# set default list type for ordered list
			listtype = 'decimal'
		end
		case listtype
			# unordered types
		when 'none'
		when 'disc', 'circle'
			fill = 'F' if listtype == 'disc'
			fill << 'D'
			r = size / 6
			lspace += 2 * r
			if @rtl
				@x = @w - @x - lspace
			else
				@x -= lspace
			end
			Circle(@x + r, @y + @lasth / 2, r, 0, 360, fill, {'color'=>color}, color, 8)
		when 'square'
			l = size / 3
			lspace += l
			if @rtl
				@x = @w - @x - lspace
			else
				@x -= lspace
			end
			Rect(@x, @y + (@lasth - l)/ 2, l, l, 'F', {}, color)

		# ordered types
                                
		# listcount[@listnum]
		# textitem
		when '1', 'decimal'
			textitem = @listcount[@listnum].to_s
		when 'decimal-leading-zero'
			textitem = sprintf("%02d", @listcount[@listnum])
		when 'i', 'lower-roman'
			textitem = (intToRoman(@listcount[@listnum])).downcase
		when 'I', 'upper-roman'
			textitem = intToRoman(@listcount[@listnum])
		when 'a', 'lower-alpha', 'lower-latin'
			textitem = (97 + @listcount[@listnum] - 1).chr
		when 'A', 'upper-alpha', 'upper-latin'
			textitem = (65 + @listcount[@listnum] - 1).chr
		when 'lower-greek'
			textitem = unichr(945 + @listcount[@listnum] - 1)
		else
			textitem = @listcount[@listnum].to_s
		end

		if !empty_string(textitem)
			# print ordered item
			if @rtl
				textitem = '.' + textitem
			else
				textitem = textitem + '.'
			end
			lspace += GetStringWidth(textitem)
			if @rtl
				@x += lspace
			else
				@x -= lspace
			end
			Write(@lasth, textitem, '', false, '', false, 0, false)
		end
		@x = tmpx
		@lispacer = ''
	end

	#
	# Returns current graphic variables as array.
	# @return array graphic variables
	# @access protected
	# @since 4.2.010 (2008-11-14)
	#
	def getGraphicVars()
		grapvars = {
			'FontFamily' => @font_family,
			'FontStyle' => @font_style,
			'FontSizePt' => @font_size_pt,
			'rMargin' => @r_margin,
			'lMargin' => @l_margin,
			'cMargin' => @c_margin,
			'LineWidth' => @line_width,
			'linestyleWidth' => @linestyle_width,
			'linestyleCap' => @linestyle_cap,
			'linestyleJoin' => @linestyle_join,
			'linestyleDash' => @linestyle_dash,
			'DrawColor' => @draw_color,
			'FillColor' => @fill_color,
			'TextColor' => @text_color,
			'ColorFlag' => @color_flag,
			'bgcolor' => @bgcolor,
			'fgcolor' => @fgcolor,
			'htmlvspace' => @htmlvspace,
			'lasth' => @lasth
		}
		return grapvars
	end

	#
	# Set graphic variables.
	# @param :gvars array graphic variables
	# @access protected
	# @since 4.2.010 (2008-11-14)
	#
	def setGraphicVars(gvars)
		@font_family = gvars['FontFamily']
		@font_style = gvars['FontStyle']
		@font_size_pt = gvars['FontSizePt']
		@r_margin = gvars['rMargin']
		@l_margin = gvars['lMargin']
		@c_margin = gvars['cMargin']
		@line_width = gvars['LineWidth']
		@linestyle_width = gvars['linestyleWidth']
		@linestyle_cap = gvars['linestyleCap']
		@linestyle_join = gvars['linestyleJoin']
		@linestyle_dash = gvars['linestyleDash']
		@draw_color = gvars['DrawColor']
		@fill_color = gvars['FillColor']
		@text_color = gvars['TextColor']
		@color_flag = gvars['ColorFlag']
		@bgcolor = gvars['bgcolor']
		@fgcolor = gvars['fgcolor']
		@htmlvspace = gvars['htmlvspace']
		#@lasth = gvars['lasth']
		out('' + @linestyle_width + ' ' + @linestyle_cap + ' ' + @linestyle_join + ' ' + @linestyle_dash + ' ' + @draw_color + ' ' + @fill_color + '')
		unless empty_string(@font_family)
			SetFont(@font_family, @font_style, @font_size_pt)
		end
	end

	#
	# Returns a temporary filename for caching object on filesystem.
	# @param string :name prefix to add to filename
	# return string filename.
	# @access protected
	# @since 4.5.000 (2008-12-31)
	#
	def getObjFilename(name)
                tmpFile = Tempfile.new(name + '_', @@k_path_cache)
                tmpFile.binmode
		tmpFile
	ensure
		tmpFile.close
	end

	#
	# Writes data to a temporary file on filesystem.
	# @param string :filename file name
	# @param mixed :data data to write on file
	# @param boolean :append if true append data, false replace.
	# @access protected
	# @since 4.5.000 (2008-12-31)
	#
	def writeDiskCache(filename, data, append=false)
		filename = filename.path
		if append
			fmode = 'a+b'
		else
			fmode = 'w+b'
		end
		f = open(filename, fmode)
		if !f
			Error('Unable to write cache file: ' + filename)
		else
			f.write(data)
			f.close
		end

		# update file length (needed for transactions)
		if @cache_file_length[filename].nil?
			@cache_file_length[filename] = data.length
		else
			@cache_file_length[filename] += data.length
		end
	end

	#
	# Read data from a temporary file on filesystem.
	# @param string :filename file name
	# @return mixed retrieved data
	# @access protected
	# @since 4.5.000 (2008-12-31)
	#
	def readDiskCache(filename)
		filename = filename.path
		data = ''
		open( filename,'rb') do |f|
			data << f.read()
		end
		return data
	end

	#
	# Set buffer content (always append data).
	# @param string :data data
	# @access protected
	# @since 4.5.000 (2009-01-02)
	#
	def setBuffer(data)
		@bufferlen += data.length
		if @diskcache
			if @buffer.nil? or empty_string(@buffer.path)
				@buffer = getObjFilename('buffer')
			end
			writeDiskCache(@buffer, data, true)
		else
			@buffer << data
		end
	end

	#
	# Get buffer content.
	# @return string buffer content
	# @access protected
	# @since 4.5.000 (2009-01-02)
	#
	def getBuffer
		if @diskcache
			return readDiskCache(@buffer)
		else
			return @buffer
		end
	end

	#
	# Set page buffer content.
	# @param int :page page number
	# @param string :data page data
	# @param boolean :append if true append data, false replace.
	# @access protected
	# @since 4.5.000 (2008-12-31)
	#
	def setPageBuffer(page, data, append=false)
		if @diskcache
			if @pages[page].nil?
				@pages[page] = getObjFilename('page' + page.to_s)
			end
			writeDiskCache(@pages[page], data, append)
		else
			if append
				@pages[page] << data
			else
				@pages[page] = data
			end
		end
		if append and !@pagelen[page].nil?
			@pagelen[page] += data.length
		else
			@pagelen[page] = data.length
		end
	end

	#
	# Get page buffer content.
	# @param int :page page number
	# @return string page buffer content or false in case of error
	# @access protected
	# @since 4.5.000 (2008-12-31)
	#
	def getPageBuffer(page)
		if @diskcache
			return readDiskCache(@pages[page])
		elsif !@pages[page].nil?
			return @pages[page]
		end
		return false
	end

	#
	# Set image buffer content.
	# @param string :image image key
	# @param array :data image data
	# @access protected
	# @since 4.5.000 (2008-12-31)
	#
	def setImageBuffer(image, data)
		if @diskcache
			if @images[image].nil?
				@images[image] = getObjFilename('image' + File::basename(image))
			end
			writeDiskCache(@images[image], Marshal.dump(data))
		else
			@images[image] = data
		end
		if !@imagekeys.include?(image)
			@imagekeys.push image
			@numimages += 1
		end
	end

	#
	# Set image buffer content for a specified sub-key.
	# @param string :image image key
	# @param string :key image sub-key
	# @param hash :data image data
	# @access protected
	# @since 4.5.000 (2008-12-31)
	#
	def setImageSubBuffer(image, key, data)
		if @images[image].nil?
				setImageBuffer(image, {})
		end
		if @diskcache
			tmpimg = getImageBuffer(image)
			tmpimg[key] = data
			writeDiskCache(@images[image], Marshal.dump(tmpimg))
		else
			@images[image][key] = data
		end
	end
                
	#
	# Get image buffer content.
	# @param string :image image key
	# @return string image buffer content or false in case of error
	# @access protected
	# @since 4.5.000 (2008-12-31)
	#
	def getImageBuffer(image)
		if @diskcache and !@images[image].nil?
			return Marshal.load(readDiskCache(@images[image]))
		elsif !@images[image].nil?
			return @images[image]
		end
		return false
	end

	#
	# Set font buffer content.
	# @param string :font font key
	# @param hash :data font data
	# @access protected
	# @since 4.5.000 (2009-01-02)
	#
	def setFontBuffer(font, data)
		if @diskcache
			if @fonts[font].nil?
				@fonts[font] = getObjFilename('font')
			end
			writeDiskCache(@fonts[font], Marshal.dump(data))
		else
			@fonts[font] = data
		end
		if !@fontkeys.include?(font)
			@fontkeys.push font
		end
	end

	#
	# Set font buffer content.
	# @param string :font font key
	# @param string :key font sub-key
	# @param array :data font data
	# @access protected
	# @since 4.5.000 (2009-01-02)
	#
	def setFontSubBuffer(font, key, data)
		if @fonts[font].nil?
			setFontBuffer(font, {})
		end
		if @diskcache
			tmpfont = getFontBuffer(font)
			tmpfont[key] = data
			writeDiskCache(@fonts[font], Marshal.dump(tmpfont))
		else
			@fonts[font][key] = data
		end
	end

	#
	# Get font buffer content.
	# @param string :font font key
	# @return string font buffer content or false in case of error
	# @access protected
	# @since 4.5.000 (2009-01-02)
	#
	def getFontBuffer(font)
		if @diskcache and !@fonts[font].nil?
			return Marshal.load(readDiskCache(@fonts[font]))
		elsif !@fonts[font].nil?
			return @fonts[font]
		end
		return false
	end

 	# Determine whether a string is empty.
 	# @param string :str string to be checked
 	# @return boolean true if string is empty
 	# @access public
 	# @since 4.5.044 (2009-04-16)
 	#
 	def empty_string(str)
 		return (str.nil? or (str.is_a?(String) and (str.length == 0)))
 	end

 	#
	# Find position of last occurrence of a substring in a string
	# @param string :haystack The string to search in.
	# @param string :needle substring to search.
	# @param int :offset May be specified to begin searching an arbitrary number of characters into the string.
	# @return Returns the position where the needle exists. Returns FALSE if the needle was not found. 
	# @access public
	# @since 4.8.038 (2010-03-13)
 	#
	def revstrpos(haystack, needle, offset = 0)
		length = haystack.length
		offset = (offset > 0) ? (length - offset) : offset.abs
		pos = haystack.reverse.index(needle.reverse, offset)

		return (pos.nil? ? nil : length - pos - needle.length)
 	end

	#
	# Output anchor link.
	# @param string :url link URL or internal link (i.e.: <a href="#23">link to page 23</a>)
	# @param string :name link name
	# @param int :fill Indicates if the cell background must be painted (1) or transparent (0). Default value: 0.
	# @param boolean :firstline if true prints only the first line and return the remaining string.
	# @param array :color array of RGB text color
	# @param string :style font style (U, D, B, I)
	# @param boolean :firstblock if true the string is the starting of a line.
	# @return the number of cells used or the remaining text if :firstline = true
	# @access public
	#
	def addHtmlLink(url, name, fill=0, firstline=false, color='', style=-1, firstblock=false)
		if !empty_string(url) and (url[0, 1] == '#')
			# convert url to internal link
			page = url.sub(/^#/, "").to_i
			url = AddLink()
			SetLink(url, 0, page)
		end
		# store current settings
		prevcolor = @fgcolor
		prevstyle = @font_style
		if color.empty?
			SetTextColorArray(@html_link_color_array)
		else
			SetTextColorArray(color)
		end
		if style == -1
			SetFont('', @font_style + @html_link_font_style)
		else
			SetFont('', @font_style + style)
		end
		ret = Write(@lasth, name, url, fill, '', false, 0, firstline, firstblock, 0)
		# restore settings
		SetFont('', prevstyle)
		SetTextColorArray(prevcolor)
		return ret
	end
	
	#
	# Returns an associative array (keys: R,G,B) from an html color name or a six-digit or three-digit hexadecimal color representation (i.e. #3FE5AA or #7FF).
	# @param string :color html color 
	# @return array RGB color or false in case of error.
	# @access public
	#
	def convertHTMLColorToDec(color = "#FFFFFF")
		color = color.gsub(/[\s]*/, '') # remove extra spaces
		color = color.downcase
		if !(dotpos = color.index('.')).nil?
			# remove class parent (i.e.: color.red)
			color = color[(dotpos + 1)..-1]
		end
		if color.length == 0
			return false
		end
		returncolor = ActiveSupport::OrderedHash.new
		if color[0,3] == 'rgb' 
			codes = color.sub(/^rgb\(/, "")
			codes = codes.gsub(')', '')
			returncolor = codes.split(',', 3)
			returncolor[0] = returncolor[0].to_i
			returncolor[1] = returncolor[1].to_i
			returncolor[2] = returncolor[2].to_i
			return returncolor
		end
		if color[0].chr != "#"
			# decode color name
			if @@webcolor[color]
				color_code = @@webcolor[color]
			else
				return false
			end
		else
			color_code = color.sub(/^#/, "")
		end
		case color_code.length
		when 3
			# three-digit hexadecimal representation
			r = color_code[0]
			g = color_code[1]
			b = color_code[2]
			returncolor['R'] = (r + r).hex
			returncolor['G'] = (g + g).hex
			returncolor['B'] = (b + b).hex
		when 6
			# six-digit hexadecimal representation
			returncolor['R'] = color_code[0,2].hex
			returncolor['G'] = color_code[2,2].hex
			returncolor['B'] = color_code[4,2].hex
		else
			returncolor = false
		end
		return returncolor
	end
	
	#
	# Converts pixels to Units.
	# @param int :px pixels
	# @return float millimeters
	# @access public
	# @see setImageScale(), getImageScale()
	#
	def pixelsToUnits(px)
		return (px.to_f / (@img_scale * @k))
	end
		
	#
	# Reverse function for htmlentities.
	# Convert entities in UTF-8.
	#
	# @param :text_to_convert Text to convert.
	# @return string converted
	#
	def unhtmlentities(string)
		if @@decoder.nil?
			CGI.unescapeHTML(string)
		else
			@@decoder.decode(string)
		end
	end

	# BIDIRECTIONAL TEXT SECTION --------------------------

	#
	# Reverse the RLT substrings using the Bidirectional Algorithm (http://unicode.org/reports/tr9/).
	# @param string :str string to manipulate. (UTF-8)
	# @param bool :forcertl if 'R' forces RTL, if 'L' forces LTR
	# @return string (UTF-16BE)
	# @author Nicola Asuni
	# @since 2.1.000 (2008-01-08)
	def utf8StrRev(str, setbom=false, forcertl=false)
		return arrUTF8ToUTF16BE(utf8Bidi(UTF8StringToArray(str), str, forcertl), setbom)
	end

	#
	# Reverse the RLT substrings using the Bidirectional Algorithm (http://unicode.org/reports/tr9/).
	# @param array :ta array of characters composing the string. (UCS4)
	# @param string :str string to process
	# @param bool :forcertl if 'R' forces RTL, if 'L' forces LTR
	# @return array of unicode chars (UCS4)
	# @author Nicola Asuni
	# @since 2.4.000 (2008-03-06)
	#
	def utf8Bidi(ta, str='', forcertl=false)
		# paragraph embedding level
		pel = 0
		# max level
		maxlevel = 0

		if empty_string(str)
			# create string from array
			str = UTF8ArrSubString(ta)
		end
			
		# check if string contains arabic text
		str.force_encoding('ASCII-8BIT') if str.respond_to?(:force_encoding)
		if str =~ @@k_re_pattern_arabic
			arabic = true
		else
			arabic = false
		end

		# check if string contains RTL text
		unless forcertl or arabic or (str =~ @@k_re_pattern_rtl)
			return ta
		end
			
		# get number of chars
		numchars = ta.length
			
		if forcertl == 'R'
			pel = 1
		elsif forcertl == 'L'
			pel = 0
		else
			# P2. In each paragraph, find the first character of type L, AL, or R.
			# P3. If a character is found in P2 and it is of type AL or R, then set the paragraph embedding level to one; otherwise, set it to zero.
			0.upto(numchars -1) do |i|
				type = @@unicode[ta[i]]
				if type == 'L'
					pel = 0
					break
				elsif (type == 'AL') or (type == 'R')
					pel = 1
					break
				end
			end
		end
			
		# Current Embedding Level
		cel = pel
		# directional override status
		dos = 'N'
		remember = []
		# start-of-level-run
		sor = (pel % 2 == 1) ? 'R' : 'L'
		eor = sor
			
		# Array of characters data
		chardata = []
			
		# X1. Begin by setting the current embedding level to the paragraph embedding level. Set the directional override status to neutral. Process each character iteratively, applying rules X2 through X9. Only embedding levels from 0 to 61 are valid in this phase.
		# 	In the resolution of levels in rules I1 and I2, the maximum embedding level of 62 can be reached.
		0.upto(numchars-1) do |i|
			if ta[i] == @@k_rle
				# X2. With each RLE, compute the least greater odd embedding level.
				#	a. If this new level would be valid, then this embedding code is valid. Remember (push) the current embedding level and override status. Reset the current level to this new level, and reset the override status to neutral.
				#	b. If the new level would not be valid, then this code is invalid. Do not change the current level or override status.
				next_level = cel + (cel % 2) + 1
				if next_level < 62
					remember.push :num => @@k_rle, :cel => cel, :dos => dos
					cel = next_level
					dos = 'N'
					sor = eor
					eor = (cel % 2 == 1) ? 'R' : 'L'
				end
			elsif ta[i] == @@k_lre
				# X3. With each LRE, compute the least greater even embedding level.
				#	a. If this new level would be valid, then this embedding code is valid. Remember (push) the current embedding level and override status. Reset the current level to this new level, and reset the override status to neutral.
				#	b. If the new level would not be valid, then this code is invalid. Do not change the current level or override status.
				next_level = cel + 2 - (cel % 2)
				if next_level < 62
					remember.push :num => @@k_lre, :cel => cel, :dos => dos
					cel = next_level
					dos = 'N'
					sor = eor
					eor = (cel % 2 == 1) ? 'R' : 'L'
				end
			elsif ta[i] == @@k_rlo
				# X4. With each RLO, compute the least greater odd embedding level.
				#	a. If this new level would be valid, then this embedding code is valid. Remember (push) the current embedding level and override status. Reset the current level to this new level, and reset the override status to right-to-left.
				#	b. If the new level would not be valid, then this code is invalid. Do not change the current level or override status.
				next_level = cel + (cel % 2) + 1
				if next_level < 62
					remember.push :num => @@k_rlo, :cel => cel, :dos => dos
					cel = next_level
					dos = 'R'
					sor = eor
					eor = (cel % 2 == 1) ? 'R' : 'L'
				end
			elsif ta[i] == @@k_lro
				# X5. With each LRO, compute the least greater even embedding level.
				#	a. If this new level would be valid, then this embedding code is valid. Remember (push) the current embedding level and override status. Reset the current level to this new level, and reset the override status to left-to-right.
				#	b. If the new level would not be valid, then this code is invalid. Do not change the current level or override status.
				next_level = cel + 2 - (cel % 2)
				if next_level < 62
					remember.push :num => @@k_lro, :cel => cel, :dos => dos
					cel = next_level
					dos = 'L'
					sor = eor
					eor = (cel % 2 == 1) ? 'R' : 'L'
				end
			elsif ta[i] == @@k_pdf
				# X7. With each PDF, determine the matching embedding or override code. If there was a valid matching code, restore (pop) the last remembered (pushed) embedding level and directional override.
				if remember.length
					last = remember.length - 1
					if (remember[last][:num] == @@k_rle) or 
						  (remember[last][:num] == @@k_lre) or 
						  (remember[last][:num] == @@k_rlo) or 
						  (remember[last][:num] == @@k_lro)
						match = remember.pop
						cel = match[:cel]
						dos = match[:dos]
						sor = eor
						eor = ((cel > match[:cel] ? cel : match[:cel]) % 2 == 1) ? 'R' : 'L'
					end
				end
			elsif (ta[i] != @@k_rle) and
					 (ta[i] != @@k_lre) and
					 (ta[i] != @@k_rlo) and
					 (ta[i] != @@k_lro) and
					 (ta[i] != @@k_pdf)
				# X6. For all types besides RLE, LRE, RLO, LRO, and PDF:
				#	a. Set the level of the current character to the current embedding level.
				#	b. Whenever the directional override status is not neutral, reset the current character type to the directional override status.
				if dos != 'N'
					chardir = dos
				else
					if !@@unicode[ta[i]].nil?
						chardir = @@unicode[ta[i]]
					else
						chardir = 'L'
					end
				end
				# stores string characters and other information
				chardata.push :char => ta[i], :level => cel, :type => chardir, :sor => sor, :eor => eor
			end
		end # end for each char
			
		# X8. All explicit directional embeddings and overrides are completely terminated at the end of each paragraph. Paragraph separators are not included in the embedding.
		# X9. Remove all RLE, LRE, RLO, LRO, PDF, and BN codes.
		# X10. The remaining rules are applied to each run of characters at the same level. For each run, determine the start-of-level-run (sor) and end-of-level-run (eor) type, either L or R. This depends on the higher of the two levels on either side of the boundary (at the start or end of the paragraph, the level of the 'other' run is the base embedding level). If the higher level is odd, the type is R; otherwise, it is L.
		
		# 3.3.3 Resolving Weak Types
		# Weak types are now resolved one level run at a time. At level run boundaries where the type of the character on the other side of the boundary is required, the type assigned to sor or eor is used.
		# Nonspacing marks are now resolved based on the previous characters.
		numchars = chardata.length
			
		# W1. Examine each nonspacing mark (NSM) in the level run, and change the type of the NSM to the type of the previous character. If the NSM is at the start of the level run, it will get the type of sor.
		prevlevel = -1 # track level changes
		levcount = 0 # counts consecutive chars at the same level
		0.upto(numchars-1) do |i|
			if chardata[i][:type] == 'NSM'
				if levcount
					chardata[i][:type] = chardata[i][:sor]
				elsif i > 0
					chardata[i][:type] = chardata[i-1][:type]
				end
			end
			if chardata[i][:level] != prevlevel
				levcount = 0
			else
				levcount += 1
			end
			prevlevel = chardata[i][:level]
		end
			
		# W2. Search backward from each instance of a European number until the first strong type (R, L, AL, or sor) is found. If an AL is found, change the type of the European number to Arabic number.
		prevlevel = -1
		levcount = 0
		0.upto(numchars-1) do |i|
			if chardata[i][:char] == 'EN'
				levcount.downto(0) do |j|
					if chardata[j][:type] == 'AL'
						chardata[i][:type] = 'AN'
					elsif (chardata[j][:type] == 'L') or (chardata[j][:type] == 'R')
						break
					end
				end
			end
			if chardata[i][:level] != prevlevel
				levcount = 0
			else
				levcount +=1
			end
			prevlevel = chardata[i][:level]
		end
		
		# W3. Change all ALs to R.
		0.upto(numchars-1) do |i|
			if chardata[i][:type] == 'AL'
				chardata[i][:type] = 'R'
			end
		end
		
		# W4. A single European separator between two European numbers changes to a European number. A single common separator between two numbers of the same type changes to that type.
		prevlevel = -1
		levcount = 0
		0.upto(numchars-1) do |i|
			if (levcount > 0) and (i+1 < numchars) and (chardata[i+1][:level] == prevlevel)
				if (chardata[i][:type] == 'ES') and (chardata[i-1][:type] == 'EN') and (chardata[i+1][:type] == 'EN')
					chardata[i][:type] = 'EN'
				elsif (chardata[i][:type] == 'CS') and (chardata[i-1][:type] == 'EN') and (chardata[i+1][:type] == 'EN')
					chardata[i][:type] = 'EN'
				elsif (chardata[i][:type] == 'CS') and (chardata[i-1][:type] == 'AN') and (chardata[i+1][:type] == 'AN')
					chardata[i][:type] = 'AN'
				end
			end
			if chardata[i][:level] != prevlevel
				levcount = 0
			else
				levcount += 1
			end
			prevlevel = chardata[i][:level]
		end
		
		# W5. A sequence of European terminators adjacent to European numbers changes to all European numbers.
		prevlevel = -1
		levcount = 0
		0.upto(numchars-1) do |i|
			if chardata[i][:type] == 'ET'
				if (levcount > 0) and (chardata[i-1][:type] == 'EN')
					chardata[i][:type] = 'EN'
				else
					j = i+1
					while (j < numchars) and (chardata[j][:level] == prevlevel)
						if chardata[j][:type] == 'EN'
							chardata[i][:type] = 'EN'
							break
						elsif chardata[j][:type] != 'ET'
							break
						end
						j += 1
					end
				end
			end
			if chardata[i][:level] != prevlevel
				levcount = 0
			else
				levcount += 1
			end
			prevlevel = chardata[i][:level]
		end
		
		# W6. Otherwise, separators and terminators change to Other Neutral.
		prevlevel = -1
		levcount = 0
		0.upto(numchars-1) do |i|
			if (chardata[i][:type] == 'ET') or (chardata[i][:type] == 'ES') or (chardata[i][:type] == 'CS')
				chardata[i][:type] = 'ON'
			end
			if chardata[i][:level] != prevlevel
				levcount = 0
			else
				levcount += 1
			end
			prevlevel = chardata[i][:level]
		end
		
		# W7. Search backward from each instance of a European number until the first strong type (R, L, or sor) is found. If an L is found, then change the type of the European number to L.
		prevlevel = -1
		levcount = 0
		0.upto(numchars-1) do |i|
			if chardata[i][:char] == 'EN'
				levcount.downto(0) do |j|
					if chardata[j][:type] == 'L'
						chardata[i][:type] = 'L'
					elsif chardata[j][:type] == 'R'
						break
					end
				end
			end
			if chardata[i][:level] != prevlevel
				levcount = 0
			else
				levcount += 1
			end
			prevlevel = chardata[i][:level]
		end
		
		# N1. A sequence of neutrals takes the direction of the surrounding strong text if the text on both sides has the same direction. European and Arabic numbers act as if they were R in terms of their influence on neutrals. Start-of-level-run (sor) and end-of-level-run (eor) are used at level run boundaries.
		prevlevel = -1
		levcount = 0
		0.upto(numchars-1) do |i|
			if (levcount > 0) and (i+1 < numchars) and (chardata[i+1][:level] == prevlevel)
				if (chardata[i][:type] == 'N') and (chardata[i-1][:type] == 'L') and (chardata[i+1][:type] == 'L')
					chardata[i][:type] = 'L'
				elsif (chardata[i][:type] == 'N') and
				 ((chardata[i-1][:type] == 'R') or (chardata[i-1][:type] == 'EN') or (chardata[i-1][:type] == 'AN')) and
				 ((chardata[i+1][:type] == 'R') or (chardata[i+1][:type] == 'EN') or (chardata[i+1][:type] == 'AN'))
					chardata[i][:type] = 'R'
				elsif chardata[i][:type] == 'N'
					# N2. Any remaining neutrals take the embedding direction
					chardata[i][:type] = chardata[i][:sor]
				end
			elsif (levcount == 0) and (i+1 < numchars) and (chardata[i+1][:level] == prevlevel)
				# first char
				if (chardata[i][:type] == 'N') and (chardata[i][:sor] == 'L') and (chardata[i+1][:type] == 'L')
					chardata[i][:type] = 'L'
				elsif (chardata[i][:type] == 'N') and
				 ((chardata[i][:sor] == 'R') or (chardata[i][:sor] == 'EN') or (chardata[i][:sor] == 'AN')) and
				 ((chardata[i+1][:type] == 'R') or (chardata[i+1][:type] == 'EN') or (chardata[i+1][:type] == 'AN'))
					chardata[i][:type] = 'R'
				elsif chardata[i][:type] == 'N'
					# N2. Any remaining neutrals take the embedding direction
					chardata[i][:type] = chardata[i][:sor]
				end
			elsif (levcount > 0) and ((i+1 == numchars) or ((i+1 < numchars) and (chardata[i+1][:level] != prevlevel)))
				# last char
				if (chardata[i][:type] == 'N') and (chardata[i-1][:type] == 'L') and (chardata[i][:eor] == 'L')
					chardata[i][:type] = 'L'
				elsif (chardata[i][:type] == 'N') and
				 ((chardata[i-1][:type] == 'R') or (chardata[i-1][:type] == 'EN') or (chardata[i-1][:type] == 'AN')) and
				 ((chardata[i][:eor] == 'R') or (chardata[i][:eor] == 'EN') or (chardata[i][:eor] == 'AN'))
					chardata[i][:type] = 'R'
				elsif chardata[i][:type] == 'N'
					# N2. Any remaining neutrals take the embedding direction
					chardata[i][:type] = chardata[i][:sor]
				end
			elsif chardata[i][:type] == 'N'
				# N2. Any remaining neutrals take the embedding direction
				chardata[i][:type] = chardata[i][:sor]
			end
			if chardata[i][:level] != prevlevel
				levcount = 0
			else
				levcount += 1
			end
			prevlevel = chardata[i][:level]
		end
		
		# I1. For all characters with an even (left-to-right) embedding direction, those of type R go up one level and those of type AN or EN go up two levels.
		# I2. For all characters with an odd (right-to-left) embedding direction, those of type L, EN or AN go up one level.
		0.upto(numchars-1) do |i|
			odd = chardata[i][:level] % 2
			if odd == 1
				if (chardata[i][:type] == 'L') or (chardata[i][:type] == 'AN') or (chardata[i][:type] == 'EN')
					chardata[i][:level] += 1
				end
			else
				if chardata[i][:type] == 'R'
					chardata[i][:level] += 1
				elsif (chardata[i][:type] == 'AN') or (chardata[i][:type] == 'EN')
					chardata[i][:level] += 2
				end
			end
			maxlevel = [chardata[i][:level],maxlevel].max
		end
		
		# L1. On each line, reset the embedding level of the following characters to the paragraph embedding level:
		#	1. Segment separators,
		#	2. Paragraph separators,
		#	3. Any sequence of whitespace characters preceding a segment separator or paragraph separator, and
		#	4. Any sequence of white space characters at the end of the line.
		0.upto(numchars-1) do |i|
			if (chardata[i][:type] == 'B') or (chardata[i][:type] == 'S')
				chardata[i][:level] = pel
			elsif chardata[i][:type] == 'WS'
				j = i+1
				while j < numchars
					if ((chardata[j][:type] == 'B') or (chardata[j][:type] == 'S')) or
						((j == numchars-1) and (chardata[j][:type] == 'WS'))
						chardata[i][:level] = pel
						break
					elsif chardata[j][:type] != 'WS'
						break
					end
					j += 1
				end
			end
		end
		
		# Arabic Shaping
		# Cursively connected scripts, such as Arabic or Syriac, require the selection of positional character shapes that depend on adjacent characters. Shaping is logically applied after the Bidirectional Algorithm is used and is limited to characters within the same directional run. 
		if arabic
			endedletter = [1569,1570,1571,1572,1573,1575,1577,1583,1584,1585,1586,1608,1688]
			alfletter = [1570,1571,1573,1575]
			chardata2 = chardata
			laaletter = false
			charAL = []
			x = 0
			0.upto(numchars-1) do |i|
				if (@@unicode[chardata[i][:char]] == 'AL') or (chardata[i][:char] == 32) or (chardata[i]['char'] == 8204) # 4.0.008 - Arabic shaping for "Zero-Width Non-Joiner" character (U+200C) was fixed.
					charAL[x] = chardata[i]
					charAL[x][:i] = i
					chardata[i][:x] = x
					x += 1
				end
			end
			numAL = x
			0.upto(numchars-1) do |i|
				thischar = chardata[i]
				if i > 0
					prevchar = chardata[i-1]
				else
					prevchar = false
				end
				if i+1 < numchars
					nextchar = chardata[i+1]
				else
					nextchar = false
				end
				if @@unicode[thischar[:char]] == 'AL'
					x = thischar[:x]
					if x > 0
						prevchar = charAL[x-1]
					else
						prevchar = false
					end
					if x+1 < numAL
						nextchar = charAL[x+1]
					else
						nextchar = false
					end
					# if laa letter
					if (prevchar != false) and (prevchar[:char] == 1604) and alfletter.include?(thischar[:char])
						arabicarr = @@laa_array
						laaletter = true
						if x > 1
							prevchar = charAL[x-2]
						else
							prevchar = false
						end
					else
						arabicarr = @@unicode_arlet
						laaletter = false
					end	
					if (prevchar != false) and (nextchar != false) and
						((@@unicode[prevchar[:char]] == 'AL') or (@@unicode[prevchar[:char]] == 'NSM')) and
						((@@unicode[nextchar[:char]] == 'AL') or (@@unicode[nextchar[:char]] == 'NSM')) and
						(nextchar[:type] == thischar[:type]) and
						(nextchar[:char] != 1567)
						# medial
						if endedletter.include?(prevchar[:char])
							if !arabicarr[thischar[:char]].nil? and !arabicarr[thischar[:char]][2].nil?
								# initial
								chardata2[i][:char] = arabicarr[thischar[:char]][2]
							end
						else
							if !arabicarr[thischar[:char]].nil? and !arabicarr[thischar[:char]][3].nil?
								# medial
								chardata2[i][:char] = arabicarr[thischar[:char]][3]
							end
						end
					elsif (nextchar != false) and
						((@@unicode[nextchar[:char]] == 'AL') or (@@unicode[nextchar[:char]] == 'NSM')) and
						(nextchar[:type] == thischar[:type]) and
						(nextchar[:char] != 1567)
						if !arabicarr[thischar[:char]].nil? and !arabicarr[thischar[:char]][2].nil?
							# initial
							chardata2[i][:char] = arabicarr[thischar[:char]][2]
						end
					elsif ((prevchar != false) and
						((@@unicode[prevchar[:char]] == 'AL') or (@@unicode[prevchar[:char]] == 'NSM')) and
						(prevchar[:type] == thischar[:type])) or
						((nextchar != false) and (nextchar[:char] == 1567))
						# final
						if (i > 1) and (thischar[:char] == 1607) and
							(chardata[i-1][:char] == 1604) and
							(chardata[i-2][:char] == 1604)
							# Allah Word
							# mark characters to delete with false
							chardata2[i-2][:char] = false
							chardata2[i-1][:char] = false 
							chardata2[i][:char] = 65010
						else
							if (prevchar != false) and endedletter.include?(prevchar[:char])
								if !arabicarr[thischar[:char]].nil? and !arabicarr[thischar[:char]][0].nil?
									# isolated
									chardata2[i][:char] = arabicarr[thischar[:char]][0]
								end
							else
								if !arabicarr[thischar[:char]].nil? and !arabicarr[thischar[:char]][1].nil?
									# final
									chardata2[i][:char] = arabicarr[thischar[:char]][1]
								end
							end
						end
					elsif !arabicarr[thischar[:char]].nil? and !arabicarr[thischar[:char]][0].nil?
						# isolated
						chardata2[i][:char] = arabicarr[thischar[:char]][0]
					end
					# if laa letter
					if laaletter
						# mark characters to delete with false
						chardata2[charAL[x-1][:i]][:char] = false
					end
				end # end if AL (Arabic Letter)
			end # end for each char

			# 
			# Combining characters that can occur with Arabic Shadda (0651 HEX, 1617 DEC) are replaced.
			# Putting the combining mark and shadda in the same glyph allows us to avoid the two marks overlapping each other in an illegible manner.
			#
			cw = @current_font['cw']
                        0.upto(numchars-2) do |i|
				if (chardata2[i][:char] == 1617) and !@@diacritics[chardata2[i+1][:char]].nil?
					# check if the subtitution font is defined on current font
					unless cw[@@diacritics[chardata2[i+1][:char]]].nil?
						chardata2[i][:char] = false
						chardata2[i+1][:char] = @@diacritics[chardata2[i+1][:char]]
					end
				end
			end
			# remove marked characters
			chardata2.each_with_index do |value, key|
				if value[:char] == false
					chardata2.delete_at(key)
				end
			end
			chardata = chardata2
			numchars = chardata.size
			chardata2 = nil
			arabicarr = nil
			laaletter = nil
			charAL = nil
		end
		
		# L2. From the highest level found in the text to the lowest odd level on each line, including intermediate levels not actually present in the text, reverse any contiguous sequence of characters that are at that level or higher.
		maxlevel.downto(1) do |j|
			ordarray = []
			revarr = []
			onlevel = false
			0.upto(numchars-1) do |i|
				if chardata[i][:level] >= j
					onlevel = true
					unless @@unicode_mirror[chardata[i][:char]].nil?
						# L4. A character is depicted by a mirrored glyph if and only if (a) the resolved directionality of that character is R, and (b) the Bidi_Mirrored property value of that character is true.
						chardata[i][:char] = @@unicode_mirror[chardata[i][:char]]
					end
					revarr.push chardata[i]
				else
					if onlevel
						revarr.reverse!
						ordarray.concat(revarr)
						revarr = []
						onlevel = false
					end
					ordarray.push chardata[i]
				end
			end
			if onlevel
				revarr.reverse!
				ordarray.concat(revarr)
			end
			chardata = ordarray
		end
		
		ordarray = []
		0.upto(numchars-1) do |i|
			chardata[i][:char]
			ordarray.push chardata[i][:char]
		end
		
		return ordarray
	end
		
	# END OF BIDIRECTIONAL TEXT SECTION -------------------

	#
	# Adds a bookmark.
	# @param string :txt bookmark description.
	# @param int :level bookmark level.
	# @param float :y Ordinate of the boorkmark position (default = -1 = current position).
	# @param int :page target page number (leave empty for current page).
	# @access public
	# @author Olivier Plathey, Nicola Asuni
	# @since 2.1.002 (2008-02-12)
	#
	def Bookmark(txt, level=0, y=-1, page=nil)
		if level < 0
			level = 0
		end
		if @outlines[0]
			lastoutline = @outlines[-1]
			maxlevel = lastoutline[:l] + 1
		else
			maxlevel = 0
		end
		if level > maxlevel
			level = maxlevel
		end
		if y == -1
			y = GetY()
		end
		if page.nil?
			page = PageNo()
		end
		@outlines.push :t => txt, :l => level, :y => y, :p => page
	end

	#
	# Create a bookmark PDF string.
	# @access private
	# @author Olivier Plathey, Nicola Asuni
	# @since 2.1.002 (2008-02-12)
	#
	def putbookmarks()
		nb = @outlines.size
		if nb == 0
			return
		end
		# sort outlines by page and original position
		@outlines = @outlines.sort_by {|x| x[:p]}
		lru = []
		level = 0
		@outlines.each_with_index do |o, i|
			if o[:l] > 0
				parent = lru[o[:l] - 1]
				# Set parent and last pointers
				@outlines[i][:parent] = parent
				@outlines[parent][:last] = i
				if o[:l] > level
					# Level increasing: set first pointer
					@outlines[parent][:first] = i
				end
			else
				@outlines[i][:parent] = nb
			end
			if o[:l] <= level and i > 0
				# Set prev and next pointers
				prev = lru[o[:l]]
				@outlines[prev][:next] = i
				@outlines[i][:prev] = prev
			end
			lru[o[:l]] = i
			level = o[:l]
		end
		# Outline items
		n = @n + 1
		@outlines.each_with_index do |o, i|
			newobj()
			out('<</Title ' + textstring(o[:t]))
			out('/Parent ' + (n + o[:parent]).to_s + ' 0 R')
			out('/Prev ' + (n + o[:prev]).to_s + ' 0 R') if !o[:prev].nil?
			out('/Next ' + (n + o[:next]).to_s + ' 0 R') if !o[:next].nil?
			out('/First ' + (n + o[:first]).to_s + ' 0 R') if !o[:first].nil?
			out('/Last ' + (n + o[:last]).to_s + ' 0 R') if !o[:last].nil?
			out('/Dest [%d 0 R /XYZ 0 %.2f null]' % [1 + 2 * o[:p], @pagedim[o[:p]]['h'] - o[:y] * @k])
			out('/Count 0>>')
			out('endobj')
		end
		# Outline root
		newobj()
		@outline_root = @n
		out('<</Type /Outlines /First ' + n.to_s + ' 0 R')
		out('/Last ' + (n + lru[0]).to_s + ' 0 R>>')
		out('endobj')
	end

	#
	# Return the current page in the group.
	# @return current page in the group
	# @access public
	# @since 3.0.000 (2008-03-27)
	#
	def getGroupPageNo()
		return @pagegroups[@currpagegroup]
	end

	#
	# Returns the current group page number formatted as a string.
	# @access public
	# @since 4.3.003 (2008-11-18)
	# @see PaneNo(), formatPageNumber()
	#
	def getGroupPageNoFormatted()
		return formatPageNumber(getGroupPageNo())
	end

	#
	# Format the page numbers.
	# This method can be overriden for custom formats.
	# @param int :num page number
	# @access protected
	# @since 4.2.005 (2008-11-06)
	#
	def formatPageNumber(num)
		return number_with_delimiter(num, :delimiter => ",")
	end

	#
	# Remove the specified page.
	# @param int :page page to remove
	# @return true in case of success, false in case of error.
	# @access public
	# @since 4.6.004 (2009-04-23)
	#
	def deletePage(page)
		if page > @numpages
			return false
		end
		# delete current page
		@pages[page] = nil
		@pagedim[page] = nil
		@pagelen[page] = nil
		@intmrk[page] = nil
		if @footerpos[page]
			@footerpos[page] = nil
		end
		if @footerlen[page]
			@footerlen[page] = nil
		end
		if @transfmrk[page]
			@transfmrk[page] = nil
		end
		if @page_annots[page]
			@page_annots[page] = nil
		end
		if @newpagegroup[page]
			@newpagegroup[page] = nil
		end
		if @pageopen[page]
			@pageopen[page] = nil
		end
		# update remaining pages
		page.upto(@numpages - 1) do |i|
			j = i + 1
			# shift pages
			@pages[i] = @pages[j]
			@pagedim[i] = @pagedim[j]
			@pagelen[i] = @pagelen[j]
			@intmrk[i] = @intmrk[j]
			if @footerpos[j]
				@footerpos[i] = @footerpos[j]
			elsif @footerpos[i]
				@footerpos[i] = nil
			end
			if @footerlen[j]
				@footerlen[i] = @footerlen[j]
			elsif @footerlen[i]
				@footerlen[i] = nil
			end
			if @transfmrk[j]
				@transfmrk[i] = @transfmrk[j]
			elsif @transfmrk[i]
				@transfmrk[i] = nil
			end
			if @page_annots[j]
				@page_annots[i] = page_annots[j]
			elsif @page_annots[i]
				@page_annots[i] = nil
			end
			if @newpagegroup[j]
				@newpagegroup[i] = @newpagegroup[j]
			elsif @newpagegroup[i]
				@newpagegroup[i] = nil
			end
			if @pageopen[j]
				@pageopen[i] = @pageopen[j]
			elsif @pageopen[i]
				@pageopen[i] = nil
			end
		end
		# remove last page
		@pages[@numpages] = nil
		@pagedim[@numpages] = nil
		@pagelen[@numpages] = nil
		@intmrk[@numpages] = nil
		if @footerpos[@numpages]
			@footerpos[@numpages] = nil
		end
		if @footerlen[@numpages]
			@footerlen[@numpages] = nil
		end
		if @transfmrk[@numpages]
			@transfmrk[@numpages] = nil
		end
		if @page_annots[@numpages]
			@page_annots[@numpages] = nil
		end
		if @newpagegroup[@numpages]
			@newpagegroup[@numpages] = nil
		end
		if @pageopen[@numpages]
			@pageopen[@numpages] = nil
		end
		@numpages -= 1
		@page = @numpages
		# adjust outlines
		tmpoutlines = @outlines
		tmpoutlines.each_with_index do |outline, key|
			if outline[:p] > page
				@outlines[key][:p] = outline[:p] - 1
			elsif outline[:p] == page
				@outlines[key] = nil
			end
		end
		# adjust links
		tmplinks = @links
		tmplinks.each_with_index do |link, key|
			if link[0] > page
				@links[key][0] = link[0] - 1
			elsif link[0] == page
				@links[key] = nil
			end
		end

		#### PDF javascript code does not implement, yet. ###
		# adjust javascript
		#tmpjavascript = @javascript
		#jpage = page
		#tmpjavascript =~ /this\.addField\(\'([^\']*)\',\'([^\']*)\',([0-9]+)/
		#pagenum = $3.to_i + 1
		#if pagenum >= jpage
		#	newpage = pagenum - 1
		#elsif pagenum == jpage
		#	newpage = 1
		#else
		#	newpage = pagenum
		#end
		#newpage -= 1
		#@javascript = "this.addField(\'" + $1 + "\',\'" + $2 + "\'," + newpage + ""

		# return to last page
		LastPage(true)
		return true
	end

	#
	# Stores a copy of the current TCPDF object used for undo operation.
	# @access public
	# @since 4.5.029 (2009-03-19)
	#
	def startTransaction()
		if @objcopy
			# remove previous copy
			commitTransaction()
		end
		# record current page number
		@start_transaction_page = @page
		# clone current object
		@objcopy = objclone(self)
	end

	#
	# Delete the copy of the current TCPDF object used for undo operation.
	# @access public
	# @since 4.5.029 (2009-03-19)
	#
	def commitTransaction()
		if @objcopy
			@objcopy.destroy(true, true)
			@objcopy = nil
		end
	end

	#
	# This method allows to undo the latest transaction by returning the latest saved TCPDF object with startTransaction().
	# @param boolean :this_self if true restores current class object to previous state without the need of reassignment via the returned value.
	# @return TCPDF object.
	# @access public
	# @since 4.5.029 (2009-03-19)
	#
	def rollbackTransaction(this_self=false)
		if @objcopy
			if @objcopy.diskcache
				# truncate files to previous values
				@objcopy.prev_cache_file_length.each { |file, length|
					open(file , "r+") do |f|
						f.flock(File::LOCK_EX)
						f.truncate(length)
					end
				}
			end
			destroy(true, true)
			if this_self
				objvars = @objcopy.instance_variables
				objvars.each {|key|
					eval("#{key} = @objcopy.instance_variable_get(key)") if key.to_s != '@objcopy'
				}
			end
			return @objcopy
		end
		return self
	end

	#
	# Creates a copy of a class object
	# @param object :object class object to be cloned
	# @return cloned object
	# @access public
	# @since 4.5.029 (2009-03-19)
	#
	def objclone(object)
                if @diskcache
			@prev_cache_file_length = object.cache_file_length.dup
			return object.dup
		else
			return Marshal.load(Marshal.dump(object))
		end
	end

end # END OF TCPDF CLASS

#TODO 2007-05-25 (EJM) Level=0 - 
#Handle special IE contype request
# if (!_SERVER['HTTP_USER_AGENT'].nil? and (_SERVER['HTTP_USER_AGENT']=='contype'))
# 	header('Content-Type: application/pdf');
# 	exit;
# }
