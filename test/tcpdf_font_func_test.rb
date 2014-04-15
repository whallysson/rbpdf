require 'test_helper'

class TcpdfFontFuncTest < ActiveSupport::TestCase
  test "Font pdfgetFontDescent function test 1" do
    pdf = TCPDF.new
    fontdescent = pdf.getFontDescent('times', '', 18)
    assert_in_delta 0.95, fontdescent, 0.01
  end

  test "Font pdfgetFontDescent function test 2" do
    pdf = TCPDF.new
    fontdescent = pdf.getFontDescent('freesans', '', 18)
    assert_in_delta 1.91, fontdescent, 0.01
  end

  test "Font getFontAscent function test 1" do
    pdf = TCPDF.new
    fontascent = pdf.getFontAscent('times', '', 18)
    assert_in_delta 5.39, fontascent, 0.01
  end

  test "Font getFontAscent function test 2" do
    pdf = TCPDF.new
    fontascent = pdf.getFontAscent('freesans', '', 18)
    assert_in_delta 6.35, fontascent, 0.01
  end
end
