require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase

  test "Write Basic test" do
    pdf = TCPDF.new

    line = pdf.Write(0, "LINE 1")
    assert_equal line,  1

    line = pdf.Write(0, "LINE 1\n")
    assert_equal line,  1

    line = pdf.Write(0, "LINE 1\n2\n")
    assert_equal line,  2

    line = pdf.Write(0, "")
    assert_equal line,  1

    line = pdf.Write(0, "\n")
    assert_equal line,  1

    line = pdf.Write(0, "abcdefghijklmnopgrstuvwxyz01234567890")
    assert_equal line,  1
    line = pdf.Write(0, "abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890")
    assert_equal line,  2
    line = pdf.Write(0, "abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890")
    assert_equal line,  3
  end

  test "Write Break test single line 1" do
    pdf = TCPDF.new
    pdf.AddPage()

    cell_hight = pdf.GetCellHeightRatio()
    fontsize = pdf.GetFontSize()
    break_hight = pdf.SetAutoPageBreak(true)

    pno = pdf.GetPage
    assert_equal pno, 1

    0.upto(60) do |i|
      y = pdf.GetY()
      old_pno = pno

      line = pdf.Write(0, "LINE 1\n")
      assert_equal line,  1

      pno = pdf.GetPage

      if y + fontsize * cell_hight < break_hight
        assert_equal pno, old_pno
      else
        assert_equal pno, old_pno + 1
      end
    end
  end

  test "Write Break test single line 2" do
    pdf = TCPDF.new
    pdf.AddPage()

    0.upto(49) do |i|
      line = pdf.Write(0, "LINE 1\n")
      assert_equal line,  1

      pno = pdf.GetPage
      assert_equal pno, 1
    end

    line = pdf.Write(0, "abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890")
    assert_equal line,  2
    pno = pdf.GetPage
    assert_equal pno, 2
  end

  test "Write Break test multi line 1" do
    pdf = TCPDF.new
    pdf.AddPage()
    pno = pdf.GetPage
    assert_equal pno, 1

    line = pdf.Write(0, "1\n\n\n\n\n\n\n\n\n\n 2\n\n\n\n\n\n\n\n\n\n 3\n\n\n\n\n\n\n\n\n\n 4\n\n\n\n\n\n\n\n\n\n")
    assert_equal line, 40 
    pno = pdf.GetPage
    assert_equal pno, 1

    line = pdf.Write(0, "1\n\n\n\n\n\n\n\n\n\n 2\n\n\n\n\n\n\n\n\n\n 3\n\n\n\n\n\n\n\n\n\n 4\n\n\n\n\n\n\n\n\n\n")
    assert_equal line, 40 
    pno = pdf.GetPage
    assert_equal pno, 2
  end

  test "Write Break test multi line 2" do
    pdf = TCPDF.new
    pdf.AddPage()
    pno = pdf.GetPage
    assert_equal pno, 1

    line = pdf.Write(0, "1\n\n\n\n\n\n\n\n\n\n 2\n\n\n\n\n\n\n\n\n\n 3\n\n\n\n\n\n\n\n\n\n 4\n\n\n\n\n\n\n\n\n\n 5\n\n\n\n\n\n\n\n\n\n 6\n\n\n\n\n\n\n\n\n\n 7\n\n\n\n\n\n\n\n\n\n 8\n\n\n\n\n\n\n\n\n\n 9\n\n\n\n\n\n\n\n\n\n 10\n\n\n\n\n\n\n\n\n\n 11\n\n\n\n\n\n\n\n\n\n")
    assert_equal line, 110 
    pno = pdf.GetPage
    assert_equal pno, 3
  end

  test "Write firstline test" do
    pdf = TCPDF.new
    pdf.AddPage()
    pno = pdf.GetPage
    assert_equal pno, 1

    line = pdf.Write(0, "\n", nil, 0, '', false, 0, true)
    assert_equal line,  "\n"

    line = pdf.Write(0, "\n", nil, 0, '', false, 0, true)
    assert_equal line,  "\n"

    line = pdf.Write(0, "12345\n", nil, 0, '', false, 0, true)
    assert_equal line,  "\n"

    line = pdf.Write(0, "12345\nabcde", nil, 0, '', false, 0, true)
    assert_equal line,  "\nabcde"

    line = pdf.Write(0, "12345\nabcde\n", nil, 0, '', false, 0, true)
    assert_equal line,  "\nabcde\n"

    line = pdf.Write(0, "12345\nabcde\nefgh", nil, 0, '', false, 0, true)
    assert_equal line,  "\nabcde\nefgh"
   end
end
