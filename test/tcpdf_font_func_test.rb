require 'test_helper'

class TcpdfFontFuncTest < ActiveSupport::TestCase
  test "Font get_font_descent function test 1" do
    pdf = TCPDF.new
    fontdescent = pdf.get_font_descent('times', '', 18)
    assert_in_delta 0.95, fontdescent, 0.01
  end

  test "Font get_font_descent function test 2" do
    pdf = TCPDF.new
    fontdescent = pdf.get_font_descent('freesans', '', 18)
    assert_in_delta 1.91, fontdescent, 0.01
  end

  test "Font get_font_ascent function test 1" do
    pdf = TCPDF.new
    fontascent = pdf.get_font_ascent('times', '', 18)
    assert_in_delta 5.39, fontascent, 0.01
  end

  test "Font get_font_ascent function test 2" do
    pdf = TCPDF.new
    fontascent = pdf.get_font_ascent('freesans', '', 18)
    assert_in_delta 6.35, fontascent, 0.01
  end
end
