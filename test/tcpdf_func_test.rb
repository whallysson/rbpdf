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

  test "Transaction test without diskcache" do
    pdf = TCPDF.new
    pdf.AddPage()
    page = pdf.GetPage

    contents01 = pdf.getPageBuffer(page).dup

    pdf.startTransaction()

    pdf.Write(0, "LINE 1\n")
    pdf.Write(0, "LINE 2\n")
    contents02 = pdf.getPageBuffer(page).dup
    assert_not_equal contents01, contents02

    # rolls back to the last (re)start
    pdf = pdf.rollbackTransaction()
    contents03 = pdf.getPageBuffer(page).dup
    assert_equal contents01, contents03
  end

  test "Transaction test with diskcache" do
    pdf = TCPDF.new('P', 'mm', 'A4', true, "UTF-8", true)
    pdf.AddPage()
    page = pdf.GetPage

    contents01 = pdf.getPageBuffer(page).dup

    pdf.startTransaction()

    pdf.Write(0, "LINE 1\n")
    pdf.Write(0, "LINE 2\n")
    contents02 = pdf.getPageBuffer(page).dup
    assert_not_equal contents01, contents02

    # rolls back to the last (re)start
    pdf = pdf.rollbackTransaction()
    contents03 = pdf.getPageBuffer(page).dup
    assert_equal contents01, contents03
  end
end
