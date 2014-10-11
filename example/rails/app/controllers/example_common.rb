# coding: UTF-8
#============================================================+
# Begin       : 2004-06-11
# Last Update : 2010-04-28
#
# Description : Configuration file for TCPDF.
#
# Author: Jun NAITOH
# License: LGPL 2.1 or later
#============================================================+

PDF_PAGE_ORIENTATION='P'
PDF_UNIT='mm'
PDF_PAGE_FORMAT='A4'
PDF_CREATOR='RBPDF'
PDF_AUTHOR='Jun NAITOH'
PDF_HEADER_TITLE='RBPDF Example'
PDF_HEADER_LOGO="#{File.join(Rails.root, 'public')}/logo_rbpdf_8bit.png"

PDF_HEADER_LOGO_WIDTH=30
PDF_HEADER_STRING="by Jun NAITOH - @naitoh"

PDF_FONT_NAME_MAIN='helvetica'
PDF_FONT_SIZE_MAIN=10
PDF_FONT_NAME_DATA='helvetica'
PDF_FONT_SIZE_DATA=8
PDF_FONT_MONOSPACED='courier'

PDF_MARGIN_HEADER=5
PDF_MARGIN_FOOTER=10
PDF_MARGIN_TOP=27
PDF_MARGIN_BOTTOM=25
PDF_MARGIN_LEFT=15
PDF_MARGIN_RIGHT=15
PDF_IMAGE_SCALE_RATIO=1.25

$l = {}
$l['a_meta_charset'] = 'UTF-8'
$l['a_meta_dir'] = 'ltr'
$l['a_meta_language'] = 'en'
