require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase

  test "getCellCode" do
    pdf = TCPDF.new('P', 'mm', 'A4', true, "UTF-8", true)
    pdf.AddPage()
    code = pdf.getCellCode(10)
    assert_equal code, " 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\n"
    # 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg       # getCellCode

  end

  test "getCellCode link url align test" do
    pdf = TCPDF.new('P', 'mm', 'A4', true, "UTF-8", true)
    pdf.AddPage()
    content = []
    contents = pdf.getCellCode(10, 10, 'abc', 'LTRB', 0, '', 0, 'http://example.com')
    contents.each_line {|line| content.push line.chomp }

    assert_equal content.length,  2
    assert_equal content[1], "28.35 813.82 m 28.35 784.91 l S 28.07 813.54 m 56.98 813.54 l S 56.70 813.82 m 56.70 784.91 l S 28.07 785.19 m 56.98 785.19 l S q 0.000 0.000 0.000 rg BT 31.19 795.17 Td [(abc)] TJ ET Q"
    # 28.35 813.82 m 28.35 784.91 l S
    # 28.07 813.54 m 56.98 813.54 l S
    # 56.70 813.82 m 56.70 784.91 l S
    # 28.07 785.19 m 56.98 785.19 l S
    # q
    # 0.000 0.000 0.000 rg
    # BT
    #   31.19 795.17 Td
    #   [(abc)] TJ
    # ET
    # Q
  end

  test "getCellCode link page test" do
    pdf = TCPDF.new('P', 'mm', 'A4', true, "UTF-8", true)
    pdf.AddPage()
    content = []
    contents = pdf.getCellCode(10, 10, 'abc', 0, 0, '', 0, 1)
    contents.each_line {|line| content.push line.chomp }

    assert_equal content.length,  2
    assert_equal content[1], "q 0.000 0.000 0.000 rg BT 31.19 795.17 Td [(abc)] TJ ET Q"
    # q
    # 0.000 0.000 0.000 rg
    # BT
    #    31.19 795.17 Td
    #    [(abc)] TJ
    # ET
    # Q

    # q                                             # Save current graphic state.
    # 0.000 0.000 0.000 rg                          # Set colors.
    # BT
    #   31.19 792.70 Td                             # Set text offset.
    #   [(\000C\000h\000a\000p\000t\000e\000r)] TJ  # Write array of characters.
    # ET
    # Q                                             # Restore previous graphic state.
  end
end
