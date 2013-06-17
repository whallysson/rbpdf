require 'test_helper'

class TcpdfPageTest < ActiveSupport::TestCase

  test "Basic Page content test" do
    pdf = TCPDF.new

    page = pdf.GetPage
    assert_equal 0, page

    width = pdf.GetPageWidth

    pdf.AddPage
    page = pdf.GetPage
    assert_equal 1, page

    content = pdf.getPageBuffer(page)
    assert_equal " 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\n 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\n", content
    ############################################
    #  0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg # AddPage,startPage,setGraphicVars(SetFillColor)
    #  0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg #
    ############################################
    # ''                   # @linestyle_width    : Line width.
    # 0 J                  # @linestyle_cap      : Type of cap to put on the line. [butt:0, round:1, square:2]
    # 0 j                  # @linestyle_join     : Type of join. [miter:0, round:1, bevel:2]
    # [] 0 d               # @linestyle_dash     : Line dash pattern. (see SetLineStyle)
    # 0 G                  # @draw_color         : Drawing color. (see SetDrawColor)
    # 0.784 0.784 0.784 rg # Set colors (200/256 200/256 200/256).
    ########################

    pdf.SetFont('freesans', 'BI', 18)
    content = pdf.getPageBuffer(page)
    assert_equal " 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\n 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\nBT /F1 18.00 Tf ET\n", content
    ########################
    # BT                   # Begin Text.
    #   /F1 18.00 Tf       # 18.00 point size font.
    # ET                   # End Text.
    ########################
    pdf.SetFont('freesans', 'B', 20)
    content = pdf.getPageBuffer(page)
    assert_equal " 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\n 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\nBT /F1 18.00 Tf ET\nBT /F2 20.00 Tf ET\n", content

    pdf.Cell(0, 10, 'Chapter', 0, 1, 'L')
    content = pdf.getPageBuffer(page)
    assert_equal " 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\n 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\nBT /F1 18.00 Tf ET\nBT /F2 20.00 Tf ET\n 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\nq 0.000 0.000 0.000 rg BT 31.19 792.70 Td [(\000C\000h\000a\000p\000t\000e\000r)] TJ ET Q\n", content
    #################################################
    # 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg       # getCellCode
    # q                                             # Save current graphic state.
    # 0.000 0.000 0.000 rg                          # Set colors.
    # BT
    #   31.19 793.37 Td                             # Set text offset.
    #   [(\000C\000h\000a\000p\000t\000e\000r)] TJ  # Write array of characters.
    # ET
    # Q                                             # Restore previous graphic state.
    #################################################
  end
end
