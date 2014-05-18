# coding: ASCII-8BIT
require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase
  class MYPDF < TCPDF
    def UTF8StringToArray(str)
      super
    end
    def utf8Bidi(ta, str='', forcertl=false)
      super
    end
  end

  test "Bidi" do
    pdf = MYPDF.new

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
