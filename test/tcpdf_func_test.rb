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

    unit = pdf.getHTMLUnitToUnits(100.0, 1, 'pt', false)
    assert_in_delta unit, 35.27, 0.01

    unit = pdf.getHTMLUnitToUnits("200", 1, '%', false)
    assert_equal unit, 2.0

    unit = pdf.getHTMLUnitToUnits("400%", 1, '%', false)
    assert_equal unit, 4.0
  end

  test "getSpaceString test" do
    pdf = TCPDF.new
    spacestr = pdf.getSpaceString()
    assert_equal spacestr, 32.chr

    pdf.SetFont('freesans', '', 18)
    spacestr = pdf.getSpaceString()
    assert_equal spacestr, 0.chr + 32.chr
  end

  test "revstrpos test" do
    pdf = TCPDF.new
    pos = pdf.revstrpos('abcd efgh ', 'cd')
    assert_equal pos, 2

    pos = pdf.revstrpos('abcd efgh ', 'cd ')
    assert_equal pos, 2

    pos = pdf.revstrpos('abcd efgh abcd efg', 'cd')
    assert_equal pos, 12

    pos = pdf.revstrpos('abcd efgh abcd efg', 'zy')
    assert_equal pos, nil
  end

  test "revstrpos offset test 1" do
    pdf = TCPDF.new

    pos = pdf.revstrpos('abcd efgh ', 'cd', 3)          # 'abc'
    assert_equal pos, nil

    pos = pdf.revstrpos('abcd efgh ', 'cd', 4)          # 'abcd'
    assert_equal pos, 2

    pos = pdf.revstrpos('abcd efgh abcd efg', 'cd', 3)  # 'abc'
    assert_equal pos, nil

    pos = pdf.revstrpos('abcd efgh abcd efg', 'cd', 4)  # 'abcd'
    assert_equal pos, 2

    pos = pdf.revstrpos('abcd efgh abcd efg', 'cd', 13) # 'abcd efgh abc'
    assert_equal pos, 2 

    pos = pdf.revstrpos('abcd efgh abcd efg', 'cd', 14) # 'abcd efgh abcd'
    assert_equal pos, 12
  end

  test "revstrpos offset test 2" do
    pdf = TCPDF.new

    pos = pdf.revstrpos('abcd efgh ', 'cd', -6)         # 'abcd'
    assert_equal pos, 2

    pos = pdf.revstrpos('abcd efgh ', 'cd', -7)         # 'abc'
    assert_equal pos, nil

    pos = pdf.revstrpos('abcd efgh abcd efg', 'cd', -4) # 'abcd efgh abcd'
    assert_equal pos, 12

    pos = pdf.revstrpos('abcd efgh abcd efg', 'cd', -5) # 'abcd efgh abc'
    assert_equal pos, 2
  end

  test "SetLineStyle Basic test" do
    pdf = TCPDF.new

    pdf.SetLineStyle({'width' => 0.1, 'cap' => 'butt', 'join' => 'miter', 'dash' => 0, 'color' => [0, 0, 0]})
    pdf.SetLineStyle({'width' => 0.1, 'cap' => 'butt', 'join' => 'miter', 'dash' => '', 'phase' => 0, 'color' => [255, 0, 0]})
    pdf.SetLineStyle({'width' => 0.1, 'cap' => 'butt', 'join' => 'miter', 'dash' => '1,2,3,4', 'phase' => 0, 'color' => [255, 0, 0]})
    pdf.SetLineStyle({'width' => 0.1, 'cap' => 'butt', 'join' => 'miter', 'dash' => 'a', 'phase' => 0, 'color' => [255, 0, 0]}) # Invalid
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
