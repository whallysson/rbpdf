require 'test_helper'

class TcpdfFontStyleTest < ActiveSupport::TestCase
  test "Font dounderline function test 1" do
    pdf = TCPDF.new
    line = pdf.dounderline(10, 10, "test")
    assert_equal line, '28.35 812.94 19.34 -0.60 re f'
  end

  test "Font dolinethrough function test 1" do
    pdf = TCPDF.new
    line = pdf.dolinethrough(10, 10, "test")
    assert_equal line, '28.35 816.94 19.34 -0.60 re f'
  end

  test "Font dooverline function test 1" do
    pdf = TCPDF.new
    line = pdf.dooverline(10, 10, "test")
    assert_equal line, '28.35 824.34 19.34 -0.60 re f'
  end
end
