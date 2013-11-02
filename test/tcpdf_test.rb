require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase

  test "SetX potision" do
    pdf = TCPDF.new
    width = pdf.GetPageWidth

    pdf.SetX(5)
    x     = pdf.GetX
    abs_x = pdf.GetAbsX
    assert_equal 5, x
    assert_equal 5, abs_x

    pdf.SetX(-4)
    x     = pdf.GetX
    abs_x = pdf.GetAbsX
    assert_equal width - 4, x
    assert_equal width - 4, abs_x

    pdf.SetRTL(true) # Right to Left

    pdf.SetX(5)
    x     = pdf.GetX
    abs_x = pdf.GetAbsX
    assert_equal 5, x
    assert_equal width - 5, abs_x

    pdf.SetX(-4)
    x     = pdf.GetX
    abs_x = pdf.GetAbsX
    assert_equal width - 4, x
    assert_equal 4, abs_x
  end

  test "SetY potision" do
    pdf = TCPDF.new
    width = pdf.GetPageWidth

    pdf.SetLeftMargin(10)
    pdf.SetY(20)
    x     = pdf.GetX
    abs_x = pdf.GetAbsX
    y     = pdf.GetY
    assert_equal 10, x
    assert_equal 10, abs_x
    assert_equal 20, y

    pdf.SetLeftMargin(30)
    pdf.SetY(20)
    x     = pdf.GetX
    abs_x = pdf.GetAbsX
    y     = pdf.GetY
    assert_equal 30, x
    assert_equal 30, abs_x
    assert_equal 20, y

    pdf.SetRTL(true) # Right to Left

    pdf.SetRightMargin(10)
    pdf.SetY(20)
    x     = pdf.GetX
    abs_x = pdf.GetAbsX
    y     = pdf.GetY
    assert_equal 10, x
    assert_equal width - 10, abs_x
    assert_equal 20, y

    pdf.SetRightMargin(30)
    pdf.SetY(20)
    x     = pdf.GetX
    abs_x = pdf.GetAbsX
    y     = pdf.GetY
    assert_equal 30, x
    assert_equal width - 30, abs_x
    assert_equal 20, y
  end

  test "AddPage potision" do
    pdf = TCPDF.new
    width = pdf.GetPageWidth

    pdf.AddPage
    x     = pdf.GetX
    abs_x = pdf.GetAbsX
    y     = pdf.GetY
    assert_in_delta 10.00125, x, 0.00001
    assert_in_delta 10.00125, abs_x, 0.00001
    assert_in_delta 10.00125, y, 0.00001

    pdf.SetRTL(true) # Right to Left

    pdf.AddPage
    x     = pdf.GetX
    abs_x = pdf.GetAbsX
    y     = pdf.GetY
    assert_in_delta 10.00125, x, 0.00001
    assert_in_delta width - 10.00125, abs_x, 0.00001
    assert_in_delta 10.00125, y, 0.00001

    pdf.SetPage(1)
    page = pdf.GetPage
    assert_equal 1, page
    pdf.SetY(20)
    y     = pdf.GetY
    assert_equal 20, y
    pdf.AddPage
    y     = pdf.GetY
    assert_in_delta 10.00125, y, 0.00001

  end

  test "AddPage" do
    pdf = TCPDF.new

    page = pdf.GetPage
    assert_equal 0, page
    pages = pdf.GetNumPages
    assert_equal 0, pages

    pdf.AddPage
    page = pdf.GetPage
    assert_equal 1, page
    pages = pdf.GetNumPages
    assert_equal 1, pages

    pdf.AddPage
    page = pdf.GetPage
    assert_equal 2, page
    pages = pdf.GetNumPages
    assert_equal 2, pages

    pdf.SetPage(1)
    page = pdf.GetPage
    assert_equal 1, page

    pdf.AddPage
    page = pdf.GetPage
    assert_equal 2, page
    pages = pdf.GetNumPages
    assert_equal 2, pages

    pdf.AddPage
    page = pdf.GetPage
    assert_equal 3, page
    pages = pdf.GetNumPages
    assert_equal 3, pages

    pdf.SetPage(1)
    page = pdf.GetPage
    assert_equal 1, page

    pdf.LastPage
    page = pdf.GetPage
    assert_equal 3, page
    pages = pdf.GetNumPages
    assert_equal 3, pages
  end

  test "AddPage SetPage Under Error" do
    pdf = TCPDF.new

    page = pdf.GetPage
    assert_equal 0, page
    pages = pdf.GetNumPages
    assert_equal 0, pages

    pdf.AddPage
    page = pdf.GetPage
    assert_equal 1, page
    pages = pdf.GetNumPages
    assert_equal 1, pages

    assert_raise(RuntimeError) {pdf.SetPage(0)} # Page under size
  end

  test "AddPage SetPage Over Error" do
    pdf = TCPDF.new

    page = pdf.GetPage
    assert_equal 0, page
    pages = pdf.GetNumPages
    assert_equal 0, pages

    pdf.AddPage
    page = pdf.GetPage
    assert_equal 1, page
    pages = pdf.GetNumPages
    assert_equal 1, pages

    pdf.AddPage
    page = pdf.GetPage
    assert_equal 2, page
    pages = pdf.GetNumPages
    assert_equal 2, pages

    pdf.SetPage(1)
    page = pdf.GetPage
    assert_equal 1, page

    assert_raise(RuntimeError) {pdf.SetPage(3)} # Page over size
  end
end
