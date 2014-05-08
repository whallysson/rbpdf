require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase

  test "set_x potision" do
    pdf = TCPDF.new
    width = pdf.get_page_width

    pdf.set_x(5)
    x     = pdf.get_x
    abs_x = pdf.get_abs_x
    assert_equal 5, x
    assert_equal 5, abs_x

    pdf.set_x(-4)
    x     = pdf.get_x
    abs_x = pdf.get_abs_x
    assert_equal width - 4, x
    assert_equal width - 4, abs_x

    pdf.set_rtl(true) # Right to Left

    pdf.set_x(5)
    x     = pdf.get_x
    abs_x = pdf.get_abs_x
    assert_equal 5, x
    assert_equal width - 5, abs_x

    pdf.set_x(-4)
    x     = pdf.get_x
    abs_x = pdf.get_abs_x
    assert_equal width - 4, x
    assert_equal 4, abs_x
  end

  test "set_y potision" do
    pdf = TCPDF.new
    width = pdf.get_page_width

    pdf.set_left_margin(10)
    pdf.set_y(20)
    x     = pdf.get_x
    abs_x = pdf.get_abs_x
    y     = pdf.get_y
    assert_equal 10, x
    assert_equal 10, abs_x
    assert_equal 20, y

    pdf.set_left_margin(30)
    pdf.set_y(20)
    x     = pdf.get_x
    abs_x = pdf.get_abs_x
    y     = pdf.get_y
    assert_equal 30, x
    assert_equal 30, abs_x
    assert_equal 20, y

    pdf.set_rtl(true) # Right to Left

    pdf.set_right_margin(10)
    pdf.set_y(20)
    x     = pdf.get_x
    abs_x = pdf.get_abs_x
    y     = pdf.get_y
    assert_equal 10, x
    assert_equal width - 10, abs_x
    assert_equal 20, y

    pdf.set_right_margin(30)
    pdf.set_y(20)
    x     = pdf.get_x
    abs_x = pdf.get_abs_x
    y     = pdf.get_y
    assert_equal 30, x
    assert_equal width - 30, abs_x
    assert_equal 20, y
  end

  test "add_page potision" do
    pdf = TCPDF.new
    width = pdf.get_page_width

    pdf.add_page
    x     = pdf.get_x
    abs_x = pdf.get_abs_x
    y     = pdf.get_y
    assert_in_delta 10.00125, x, 0.00001
    assert_in_delta 10.00125, abs_x, 0.00001
    assert_in_delta 10.00125, y, 0.00001

    pdf.set_rtl(true) # Right to Left

    pdf.add_page
    x     = pdf.get_x
    abs_x = pdf.get_abs_x
    y     = pdf.get_y
    assert_in_delta 10.00125, x, 0.00001
    assert_in_delta width - 10.00125, abs_x, 0.00001
    assert_in_delta 10.00125, y, 0.00001

    pdf.set_page(1)
    page = pdf.get_page
    assert_equal 1, page
    pdf.set_y(20)
    y     = pdf.get_y
    assert_equal 20, y
    pdf.add_page
    y     = pdf.get_y
    assert_in_delta 10.00125, y, 0.00001

  end

  test "add_page" do
    pdf = TCPDF.new

    page = pdf.get_page
    assert_equal 0, page
    pages = pdf.get_num_pages
    assert_equal 0, pages

    pdf.add_page
    page = pdf.get_page
    assert_equal 1, page
    pages = pdf.get_num_pages
    assert_equal 1, pages

    pdf.add_page
    page = pdf.get_page
    assert_equal 2, page
    pages = pdf.get_num_pages
    assert_equal 2, pages

    pdf.set_page(1)
    page = pdf.get_page
    assert_equal 1, page

    pdf.add_page
    page = pdf.get_page
    assert_equal 2, page
    pages = pdf.get_num_pages
    assert_equal 2, pages

    pdf.add_page
    page = pdf.get_page
    assert_equal 3, page
    pages = pdf.get_num_pages
    assert_equal 3, pages

    pdf.set_page(1)
    page = pdf.get_page
    assert_equal 1, page

    pdf.last_page
    page = pdf.get_page
    assert_equal 3, page
    pages = pdf.get_num_pages
    assert_equal 3, pages
  end

  test "add_page set_page Under Error" do
    pdf = TCPDF.new

    page = pdf.get_page
    assert_equal 0, page
    pages = pdf.get_num_pages
    assert_equal 0, pages

    pdf.add_page
    page = pdf.get_page
    assert_equal 1, page
    pages = pdf.get_num_pages
    assert_equal 1, pages

    assert_raise(RuntimeError) {pdf.set_page(0)} # Page under size
  end

  test "add_page set_page Over Error" do
    pdf = TCPDF.new

    page = pdf.get_page
    assert_equal 0, page
    pages = pdf.get_num_pages
    assert_equal 0, pages

    pdf.add_page
    page = pdf.get_page
    assert_equal 1, page
    pages = pdf.get_num_pages
    assert_equal 1, pages

    pdf.add_page
    page = pdf.get_page
    assert_equal 2, page
    pages = pdf.get_num_pages
    assert_equal 2, pages

    pdf.set_page(1)
    page = pdf.get_page
    assert_equal 1, page

    assert_raise(RuntimeError) {pdf.set_page(3)} # Page over size
  end

  test "deletePage test" do
    pdf = TCPDF.new

    pdf.add_page
    pdf.write(0, "Page 1")

    page = pdf.get_page
    assert_equal 1, page
    pages = pdf.get_num_pages
    assert_equal 1, pages

    contents1 = pdf.getPageBuffer(1)

    pdf.add_page
    pdf.write(0, "Page 2")

    page = pdf.get_page
    assert_equal 2, page
    pages = pdf.get_num_pages
    assert_equal 2, pages

    contents2 = pdf.getPageBuffer(2)

    pdf.deletePage(1)
    page = pdf.get_page
    assert_equal 1, page
    pages = pdf.get_num_pages
    assert_equal 1, pages

    contents3 = pdf.getPageBuffer(1)
    assert_not_equal contents3, contents1
    assert_equal contents3, contents2

    contents4 = pdf.getPageBuffer(2)
    assert_equal contents4, false
  end
end
