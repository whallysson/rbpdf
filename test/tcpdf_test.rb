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

  test "Dom Basic" do
    pdf = TCPDF.new

    # Simple Text
    dom = pdf.getHtmlDomArray('abc')
    assert_equal 0, dom[0]['parent']  # Root
    assert_equal false, dom[0]['tag']
    assert_equal({'tag'=>false, 'value'=>'abc', 'elkey'=>0, 'parent'=>0}, dom[1])

    # Simple Tag
    dom = pdf.getHtmlDomArray('<b>abc</b>')
    assert_equal 0, dom[0]['parent']  # Root
    assert_equal false, dom[0]['tag']
    assert_equal({}, dom[0]['attribute'])

    assert_equal({'tag' => false, 'value'=>'', 'elkey'=>0, 'parent'=>0}, dom[1])

    assert_equal 0, dom[2]['parent']   # parent -> parent tag key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal true, dom[2]['opening']
    assert_equal 'b', dom[2]['value']
    assert_equal({}, dom[2]['attribute'])

    assert_equal({'tag' => false, 'value'=>'abc', 'elkey'=>2, 'parent'=>2}, dom[3])  # parent -> open tag key

    assert_equal 2, dom[4]['parent']   # parent -> open tag key
    assert_equal 3, dom[4]['elkey']
    assert_equal true, dom[4]['tag']
    assert_equal false, dom[4]['opening']
    assert_equal 'b', dom[4]['value']

    # Error Tag (doble colse tag)
    dom = pdf.getHtmlDomArray('</ul></div>')
    assert_equal 0, dom[0]['parent']  # Root
    assert_equal false, dom[0]['tag']
    assert_equal({}, dom[0]['attribute'])

    assert_equal({'tag' => false, 'value'=>'', 'elkey'=>0, 'parent'=>0}, dom[1])

    assert_equal 0, dom[2]['parent']   # parent -> Root key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal false, dom[2]['opening']
    assert_equal 'ul', dom[2]['value']

    assert_equal({'tag' => false, 'value'=>'', 'elkey'=>2, 'parent'=>0}, dom[3])  # parent -> open tag key

    assert_equal 0, dom[4]['parent']   # parent -> Root key
    assert_equal 3, dom[4]['elkey']
    assert_equal true, dom[4]['tag']
    assert_equal false, dom[4]['opening']
    assert_equal 'div', dom[4]['value']

    # Attribute
    dom = pdf.getHtmlDomArray('<p style="text-align:justify">abc</p>')
    assert_equal 0, dom[0]['parent']  # Root
    assert_equal false, dom[0]['tag']
    assert_equal({}, dom[0]['attribute'])

    assert_equal({'tag' => false, 'value'=>'', 'elkey'=>0, 'parent'=>0}, dom[1])

    assert_equal 0, dom[2]['parent']   # parent -> parent tag key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal true, dom[2]['opening']
    assert_equal 'p', dom[2]['value']
    assert_equal({'style'=>'text-align: justify;'}, dom[2]['attribute'])
    assert_equal('text-align: justify;', dom[2]['attribute']['style'])
    assert_equal('J', dom[2]['align'])

    # Table border
    dom = pdf.getHtmlDomArray('<table border="1"><tr><td>abc</td></tr></table>')
    assert_equal 0, dom[2]['parent']   # parent -> parent tag key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal true, dom[2]['opening']
    assert_equal 'table', dom[2]['value']
    assert_equal('1', dom[2]['attribute']['border'])

    # Table td Width
    dom = pdf.getHtmlDomArray('<table><tr><td width="10">abc</td></tr></table>')
    assert_equal 4, dom[6]['parent']   # parent -> parent tag key
    assert_equal 5, dom[6]['elkey']
    assert_equal true, dom[6]['tag']
    assert_equal true, dom[6]['opening']
    assert_equal 'td', dom[6]['value']
    assert_equal 10, dom[6]['width']

  end
end
