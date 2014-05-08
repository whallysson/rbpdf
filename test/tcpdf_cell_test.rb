require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase

  test "getCellCode" do
    pdf = TCPDF.new('P', 'mm', 'A4', true, "UTF-8", true)
    pdf.add_page()
    code = pdf.getCellCode(10)
    assert_equal code, " 0 J 0 j [] 0 d 0 G 0 g\n"
    # 0 J 0 j [] 0 d 0 G 0 rg       # getCellCode

  end

  test "getCellCode link url align test" do
    pdf = TCPDF.new('P', 'mm', 'A4', true, "UTF-8", true)
    pdf.add_page()
    content = []
    contents = pdf.getCellCode(10, 10, 'abc', 'LTRB', 0, '', 0, 'http://example.com')
    contents.each_line {|line| content.push line.chomp }

    assert_equal content.length,  2
    assert_equal content[1], "28.35 813.82 m 28.35 784.91 l S 28.07 813.54 m 56.98 813.54 l S 56.70 813.82 m 56.70 784.91 l S 28.07 785.19 m 56.98 785.19 l S BT 31.19 795.17 Td 0 Tr 0.00 w [(abc)] TJ ET"
    # 28.35 813.82 m 28.35 784.91 l S
    # 28.07 813.54 m 56.98 813.54 l S
    # 56.70 813.82 m 56.70 784.91 l S
    # 28.07 785.19 m 56.98 785.19 l S
    # BT
    #   31.19 795.17 Td
    #   0 Tr 0.00 w 
    #   [(abc)] TJ
    # ET
  end

  test "getCellCode link page test" do
    pdf = TCPDF.new('P', 'mm', 'A4', true, "UTF-8", true)
    pdf.add_page()
    content = []
    contents = pdf.getCellCode(10, 10, 'abc', 0, 0, '', 0, 1)
    contents.each_line {|line| content.push line.chomp }

    assert_equal content.length,  2
    assert_equal content[1], "BT 31.19 795.17 Td 0 Tr 0.00 w [(abc)] TJ ET"
    # BT
    #    31.19 795.17 Td
    #    0 Tr 0.00 w
    #    [(abc)] TJ
    # ET
  end
end
