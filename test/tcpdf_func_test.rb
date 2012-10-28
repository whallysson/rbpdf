require 'test_helper'

class TcpdfPageTest < ActiveSupport::TestCase

  test "Basic Page content test" do
    pdf = TCPDF.new

    def pdf.GetPages(page)
        @pages[page]
    end

    width = pdf.GetPageWidth

    pdf.AddPage
    page = pdf.GetPage

    content = pdf.GetPages(page)
    assert_equal "2 J\n0.57 w\n0.784 0.784 0.784 rg\n", content
    ########################
    # 2 J                  # Set line cap style to square.
    # 0.57 w               # Set line width.
    # 0.784 0.784 0.784 rg # Set colors (200/256 200/256 200/256).
    ########################

    pdf.SetFont('freesans', 'BI', 18)
    content = pdf.GetPages(page)
    assert_equal "2 J\n0.57 w\n0.784 0.784 0.784 rg\nBT /F1 18.00 Tf ET\n", content
    ########################
    # BT                   # Begin Text.
    #   /F1 18.00 Tf       # 18.00 point size font.
    # ET                   # End Text.
    ########################
    pdf.SetFont('freesans', 'B', 20)
    content = pdf.GetPages(page)
    assert_equal "2 J\n0.57 w\n0.784 0.784 0.784 rg\nBT /F1 18.00 Tf ET\nBT /F2 20.00 Tf ET\n", content

    pdf.Cell(0, 10, 'Chapter', 0, 1, 'L')
    content = pdf.GetPages(page)
    assert_equal "2 J\n0.57 w\n0.784 0.784 0.784 rg\nBT /F1 18.00 Tf ET\nBT /F2 20.00 Tf ET\nq 0.000 0.000 0.000 rg BT 31.19 793.37 Td [(\000C\000h\000a\000p\000t\000e\000r)] TJ ET Q\n", content
    #################################################
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
