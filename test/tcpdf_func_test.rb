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

  test "Circle content" do
    pdf = TCPDF.new

    pdf.AddPage
    pdf.Circle(100, 200, 50)
    content = pdf.getPageBuffer(1)
    assert_equal " 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\n 0 J 0 j [] 0 d 0 G 0.784 0.784 0.784 rg\n425.20 274.96 m\n425.20 312.07 409.92 348.94 383.68 375.18 c\n357.45 401.42 320.57 416.69 283.46 416.69 c\n246.36 416.69 209.48 401.42 183.24 375.18 c\n157.01 348.94 141.73 312.07 141.73 274.96 c\n141.73 237.86 157.01 200.98 183.24 174.74 c\n209.48 148.50 246.36 133.23 283.46 133.23 c\n320.57 133.23 357.45 148.50 383.68 174.74 c\n409.92 200.98 425.20 237.86 425.20 274.96 c\nS\n", content
    #################################################
    # 425.20 274.96 m                               # start point : x0, y0
    # 425.20 312.07 409.92 348.94 383.68 375.18 c   # 1/8 circle  : x1, y1(control point 1), x2, y2(control point 2), x3, y3(end point and next start point)
    # 357.45 401.42 320.57 416.69 283.46 416.69 c   # 2/8 circle
    # 246.36 416.69 209.48 401.42 183.24 375.18 c   # 3/8 circle
    # 157.01 348.94 141.73 312.07 141.73 274.96 c   # 4/8 circle
    # 141.73 237.86 157.01 200.98 183.24 174.74 c   # 5/8 circle
    # 209.48 148.50 246.36 133.23 283.46 133.23 c   # 6/8 circle
    # 320.57 133.23 357.45 148.50 383.68 174.74 c   # 7/8 circle
    # 409.92 200.98 425.20 237.86 425.20 274.96 c   # 8/8 circle
    # S
    #################################################
  end
end
