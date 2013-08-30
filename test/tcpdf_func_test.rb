require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase

  test "getHTMLUnitToUnits test" do
    pdf = TCPDF.new
    unit = pdf.getHTMLUnitToUnits("100", 1)
    assert_in_delta unit, 35.27, 0.01

    unit = pdf.getHTMLUnitToUnits("100px", 1, 'px', false)
    assert_in_delta unit, 35.27, 0.01

    unit = pdf.getHTMLUnitToUnits(100, 1, 'pt', false)
    assert_in_delta unit, 35.27, 0.01

    unit = pdf.getHTMLUnitToUnits("200", 1, '%', false)
    assert_equal unit, 2.0

    unit = pdf.getHTMLUnitToUnits("400%", 1, '%', false)
    assert_equal unit, 4.0
  end

end
