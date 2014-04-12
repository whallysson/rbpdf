require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase

  test "WriteHTML Basic test" do
    pdf = TCPDF.new
    pdf.AddPage()


    htmlcontent = '<h1>HTML Example</h1>'
    pdf.writeHTML(htmlcontent, true, 0, true, 0)

    htmlcontent = 'abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890 abcdefghijklmnopgrstuvwxyz01234567890'
    pdf.writeHTML(htmlcontent, true, 0, true, 0)

    htmlcontent = '1<br><br><br><br><br><br><br><br><br><br> 2<br><br><br><br><br><br><br><br><br><br> 3<br><br><br><br><br><br><br><br><br><br> 4<br><br><br><br><br><br><br><br><br><br> 5<br><br><br><br><br><br><br><br><br><br> 6<br><br><br><br><br><br><br><br><br><br> 7<br><br><br><br><br><br><br><br><br><br> 8<br><br><br><br><br><br><br><br><br><br> 9<br><br><br><br><br><br><br><br><br><br> 10<br><br><br><br><br><br><br><br><br><br> 11<br><br><br><br><br><br><br><br><br><br>'
    pdf.writeHTML(htmlcontent, true, 0, true, 0)

    pno = pdf.GetPage
    assert_equal pno, 3
  end

  test "WriteHTML Table test" do
    pdf = TCPDF.new
    pdf.AddPage()

    tablehtml = '<table border="1" cellspacing="1" cellpadding="1"><tr><td>a</td><td>b</td></tr><tr><td>c</td><td>d</td></tr></table>'
    pdf.writeHTML(tablehtml, true, 0, true, 0)

    htmlcontent = '1<br><br><br><br><br><br><br><br><br><br> 2<br><br><br><br><br><br><br><br><br><br> 3<br><br><br><br><br><br><br><br><br><br> 4<br><br><br><br><br><br><br><br><br><br> 5<br><br><br><br><br><br><br><br><br><br> 6<br><br><br><br><br><br><br><br><br><br> 7<br><br><br><br><br><br><br><br><br><br> 8<br><br><br><br><br><br><br><br><br><br> 9<br><br><br><br><br><br><br><br><br><br> 10<br><br><br><br><br><br><br><br><br><br> 11<br><br><br><br><br><br><br><br><br><br>'

    tablehtml = '<table border="1" cellspacing="1" cellpadding="1"><tr><td>a</td><td>b</td></tr><tr><td>c</td><td>' + htmlcontent + '</td></tr></table>'
    pdf.writeHTML(tablehtml, true, 0, true, 0)

    pno = pdf.GetPage
    assert_equal pno, 3
  end

  test "WriteHTML Table thead tag test 1" do
    pdf = TCPDF.new
    pdf.AddPage()

    tablehtml = '<table border="1" cellpadding="1" cellspacing="1">
    <thead><tr><td>ABCD</td><td>EFGH</td><td>IJKL</td></tr></thead>
    <tr><td>abcd</td><td>efgh</td><td>ijkl</td></tr>
    </table>'

    pdf.writeHTML(tablehtml, true, 0, true, 0)
    page = pdf.GetPage
    assert_equal 1, page

    content = []
    contents = pdf.getPageBuffer(page)
    contents.each_line {|line| content.push line.chomp }

    count = 0
    content.each do |line|
      count += 1 if line =~ /ABCD/
    end
    assert_equal count, 1
  end

  test "WriteHTML Table thead tag test 2" do
    pdf = TCPDF.new
    pdf.AddPage()

    htmlcontent = '1<br><br><br><br><br><br><br><br><br><br> 2<br><br><br><br><br><br><br><br><br><br> 3<br><br><br><br><br><br><br><br><br><br> 4<br><br><br><br><br><br><br><br><br><br> 5<br><br><br><br><br><br><br><br><br><br> 6<br><br><br><br><br><br><br><br><br><br> 7<br><br><br><br><br><br><br><br><br><br> 8<br><br><br><br><br><br><br><br><br><br> 9<br><br><br><br><br><br><br><br><br><br> 10<br><br><br><br><br><br><br><br><br><br> 11<br><br><br><br><br><br><br><br><br><br>'

    tablehtml = '<table border="1" cellpadding="1" cellspacing="1"><thead><tr><td>ABCD</td><td>EFGH</td><td>IJKL</td></tr></thead>
                 <tr><td>abcd</td><td>efgh</td><td>ijkl</td></tr>
                 <tr><td>' + htmlcontent + '</td></tr></table>'

    pdf.writeHTML(tablehtml, true, 0, true, 0)
    page = pdf.GetPage
    assert_equal 3, page

    content = []
    contents = pdf.getPageBuffer(1)
    contents.each_line {|line| content.push line.chomp }
    count_head = 0
    count = 0
    content.each do |line|
      count_head += 1 if line =~ /ABCD/
      count += 1 if line =~ /abcd/
    end
    assert_equal count_head, 1
    assert_equal count, 1

    content = []
    contents = pdf.getPageBuffer(2)
    contents.each_line {|line| content.push line.chomp }
    count_head = 0
    count = 0
    content.each do |line|
      count_head += 1 if line =~ /ABCD/
      count += 1 if line =~ /abcd/
    end
    assert_equal count_head, 1
    assert_equal count, 0

    content = []
    contents = pdf.getPageBuffer(3)
    contents.each_line {|line| content.push line.chomp }
    count_head = 0
    count = 0
    content.each do |line|
      count_head += 1 if line =~ /ABCD/
      count += 1 if line =~ /abcd/
    end
    assert_equal count_head, 1
    assert_equal count, 0
  end
end
