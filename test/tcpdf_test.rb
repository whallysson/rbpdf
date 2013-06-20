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

    assert_raise(RuntimeError) {pdf.SetPage(0)} # Page under size

    pdf.SetPage(1)
    page = pdf.GetPage
    assert_equal 1, page

    assert_raise(RuntimeError) {pdf.SetPage(3)} # Page over size

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

  test "Bidi" do
    pdf = TCPDF.new

    # UCS4 charactor -> UTF-8 charactor
    utf8_chr = pdf.unichr(0x61)
    assert_equal "a", utf8_chr
    utf8_chr = pdf.unichr(0x5e2)
    assert_equal "\xd7\xa2", utf8_chr

    # UTF-8 string -> array of UCS4 charactor
    ary_ucs4 = pdf.UTF8StringToArray("abc")
    assert_equal [0x61, 0x62, 0x63], ary_ucs4
    ary_ucs4 = pdf.UTF8StringToArray("\xd7\xa2\xd7\x91\xd7\xa8\xd7\x99\xd7\xaa")
    assert_equal [0x5e2, 0x5d1, 0x5e8, 0x5d9, 0x5ea], ary_ucs4

    # Bidirectional Algorithm
    ascii_str   = "abc"
    utf8_str_1  = "\xd7\xa2"
    utf8_str_2  = "\xd7\xa2\xd7\x91\xd7\xa8\xd7\x99\xd7\xaa"

    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(ascii_str))
    assert_equal [0x61, 0x62, 0x63], ary_ucs4
    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(ascii_str), ascii_str, 'R')
    assert_equal [0x61, 0x62, 0x63], ary_ucs4

    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_str_1))
    assert_equal [0x5e2], ary_ucs4
    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_str_1), utf8_str_1, 'R')
    assert_equal [0x5e2], ary_ucs4

    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_str_2))
    assert_equal [0x5ea, 0x5d9, 0x5e8, 0x5d1, 0x5e2], ary_ucs4
    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_str_2), utf8_str_2, 'R')
    assert_equal [0x5ea, 0x5d9, 0x5e8, 0x5d1, 0x5e2], ary_ucs4 ##

    ary_str = pdf.utf8Bidi(pdf.UTF8StringToArray(ascii_str + utf8_str_2), ascii_str + utf8_str_2, 'L')
    assert_equal [0x61, 0x62, 0x63, 0x5ea, 0x5d9, 0x5e8, 0x5d1, 0x5e2], ary_str
    ary_str = pdf.utf8Bidi(pdf.UTF8StringToArray(ascii_str + utf8_str_2))        # LTR
    assert_equal [0x61, 0x62, 0x63, 0x5ea, 0x5d9, 0x5e8, 0x5d1, 0x5e2], ary_str
    ary_str = pdf.utf8Bidi(pdf.UTF8StringToArray(ascii_str + utf8_str_2), ascii_str + utf8_str_2, 'R')

    assert_equal [0x5ea, 0x5d9, 0x5e8, 0x5d1, 0x5e2, 0x61, 0x62, 0x63], ary_str

    ary_str = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_str_2 + ascii_str), utf8_str_2 + ascii_str, 'L')
    assert_equal [0x5ea, 0x5d9, 0x5e8, 0x5d1, 0x5e2, 0x61, 0x62, 0x63], ary_str
    ary_str = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_str_2 + ascii_str))        # RTL
    assert_equal [0x61, 0x62, 0x63, 0x5ea, 0x5d9, 0x5e8, 0x5d1, 0x5e2], ary_str
    ary_str = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_str_2 + ascii_str), utf8_str_2 + ascii_str, 'R')
    assert_equal [0x61, 0x62, 0x63, 0x5ea, 0x5d9, 0x5e8, 0x5d1, 0x5e2], ary_str
  end
end
