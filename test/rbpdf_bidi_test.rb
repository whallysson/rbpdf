# coding: ASCII-8BIT
require 'test_helper'

class RbpdfTest < ActiveSupport::TestCase
  class MYPDF < RBPDF
    def UTF8StringToArray(str)
      super
    end
    def utf8Bidi(ta, str='', forcertl=false)
      super
    end
    def cache_utf8_string_to_array(str)
      @cache_utf8_string_to_array[str]
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

  test "Bidi arabic test" do
    pdf = MYPDF.new

    # Bidirectional Algorithm
    ascii_str   = "role"
    utf8_arabic_str_1  = "\xd8\xaf\xd9\x88\xd8\xb1"
    utf8_arabic_char_1  = "\xd8\xaf"

    # UCS4 charactor -> UTF-8 charactor
    utf8_chr = pdf.unichr(0x62f)
    assert_equal "\xd8\xaf", utf8_chr

    # UTF-8 string -> array of UCS4 charactor
    ary_ucs4 = pdf.UTF8StringToArray(ascii_str)
    assert_equal [0x72, 0x6f, 0x6c, 0x65], ary_ucs4
    ary_ucs4 = pdf.UTF8StringToArray(utf8_arabic_str_1)
    assert_equal [0x62f, 0x648, 0x631], ary_ucs4
    ary_ucs4 = pdf.UTF8StringToArray(utf8_arabic_char_1)
    assert_equal [0x62f], ary_ucs4


    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(ascii_str))
    assert_equal [0x72, 0x6f, 0x6c, 0x65], ary_ucs4

    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(ascii_str), ascii_str, 'R')
    assert_equal [0x72, 0x6f, 0x6c, 0x65], ary_ucs4

    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_arabic_char_1))
    assert_equal [0xfea9], ary_ucs4
    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_arabic_char_1), utf8_arabic_char_1, 'R')
    assert_equal [0xfea9], ary_ucs4

    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_arabic_str_1))
    assert_equal [0xfeae, 0xfeee, 0xfea9], ary_ucs4
  end

  test "Bidi date test" do
    pdf = MYPDF.new

    utf8_date_str_1  = '12/01/2014'

    pdf.set_rtl(true)
    pdf.set_temp_rtl('rtl')
    # UTF-8 string -> array of UCS4 charactor
    ary_ucs4 = pdf.UTF8StringToArray(utf8_date_str_1)
    assert_equal [0x31, 0x32, 0x2f, 0x30, 0x31, 0x2f, 0x32, 0x30, 0x31, 0x34], ary_ucs4  # 12/01/2014

    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_date_str_1))
    assert_equal [0x31, 0x32, 0x2f, 0x30, 0x31, 0x2f, 0x32, 0x30, 0x31, 0x34], ary_ucs4  # 12/01/2014

    ary_ucs4 = pdf.utf8Bidi(pdf.UTF8StringToArray(utf8_date_str_1), utf8_date_str_1, 'R')
    assert_equal [0x31, 0x32, 0x2f, 0x30, 0x31, 0x2f, 0x32, 0x30, 0x31, 0x34], ary_ucs4  # 12/01/2014
  end

  test "UTF8StringToArray cache_utf8_string_to_array test" do
    pdf = MYPDF.new

    chars = pdf.UTF8StringToArray('1234')
    chars.reverse!

    rtn = pdf.cache_utf8_string_to_array('1234')
    assert_equal rtn, [0x31, 0x32, 0x33, 0x34]
  end
end
