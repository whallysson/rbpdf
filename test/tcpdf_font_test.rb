require 'test_helper'

class TcpdfFontTest < ActiveSupport::TestCase
  test "core Font test" do
    pdf = TCPDF.new

    pdf.SetFont('helvetica', '', 18)
    pdf.SetFont('helvetica', 'B', 18)
    pdf.SetFont('helvetica', 'I', 18)
    pdf.SetFont('helvetica', 'BI', 18)

    pdf.SetFont('times', '', 18)
    pdf.SetFont('times', 'B', 18)
    pdf.SetFont('times', 'I', 18)
    pdf.SetFont('times', 'BI', 18)

    pdf.SetFont('courier', '', 18)
    pdf.SetFont('courier', 'B', 18)
    pdf.SetFont('courier', 'I', 18)
    pdf.SetFont('courier', 'BI', 18)

    pdf.SetFont('symbol', '', 18)
    pdf.SetFont('zapfdingbats', '', 18)
  end

  test "TrueTypeUnicode Font test" do
    pdf = TCPDF.new

    pdf.SetFont('freesans', '', 18)
    pdf.SetFont('freesans', 'B', 18)
    pdf.SetFont('freesans', 'I', 18)
    pdf.SetFont('freesans', 'BI', 18)

    pdf.SetFont('freemono', '', 18)
    pdf.SetFont('freemono', 'B', 18)
    pdf.SetFont('freemono', 'I', 18)
    pdf.SetFont('freemono', 'BI', 18)

    pdf.SetFont('dejavusans', '', 18)
    pdf.SetFont('dejavusans', 'B', 18)
    pdf.SetFont('dejavusans', 'I', 18)
    pdf.SetFont('dejavusans', 'BI', 18)

  end

  test "cidfont0 Font test" do
    pdf = TCPDF.new

    pdf.SetFont('cid0cs', '', 18)
    pdf.SetFont('cid0cs', 'B', 18)
    pdf.SetFont('cid0cs', 'I', 18)
    pdf.SetFont('cid0cs', 'BI', 18)

    pdf.SetFont('cid0ct', '', 18)
    pdf.SetFont('cid0ct', 'B', 18)
    pdf.SetFont('cid0ct', 'I', 18)
    pdf.SetFont('cid0ct', 'BI', 18)

    pdf.SetFont('cid0jp', '', 18)
    pdf.SetFont('cid0jp', 'B', 18)
    pdf.SetFont('cid0jp', 'I', 18)
    pdf.SetFont('cid0jp', 'BI', 18)

    pdf.SetFont('cid0kr', '', 18)
    pdf.SetFont('cid0kr', 'B', 18)
    pdf.SetFont('cid0kr', 'I', 18)
    pdf.SetFont('cid0kr', 'BI', 18)

    pdf.SetFont('kozgopromedium', '', 18)
    pdf.SetFont('kozgopromedium', 'B', 18)
    pdf.SetFont('kozgopromedium', 'I', 18)
    pdf.SetFont('kozgopromedium', 'BI', 18)

    pdf.SetFont('kozminproregular', '', 18)
    pdf.SetFont('kozminproregular', 'B', 18)
    pdf.SetFont('kozminproregular', 'I', 18)
    pdf.SetFont('kozminproregular', 'BI', 18)

    pdf.SetFont('msungstdlight', '', 18)
    pdf.SetFont('msungstdlight', 'B', 18)
    pdf.SetFont('msungstdlight', 'I', 18)
    pdf.SetFont('msungstdlight', 'BI', 18)

    pdf.SetFont('stsongstdlight', '', 18)
    pdf.SetFont('stsongstdlight', 'B', 18)
    pdf.SetFont('stsongstdlight', 'I', 18)
    pdf.SetFont('stsongstdlight', 'BI', 18)

    pdf.SetFont('hysmyeongjostdmedium', '', 18)
    pdf.SetFont('hysmyeongjostdmedium', 'B', 18)
    pdf.SetFont('hysmyeongjostdmedium', 'I', 18)
    pdf.SetFont('hysmyeongjostdmedium', 'BI', 18)
  end
end
