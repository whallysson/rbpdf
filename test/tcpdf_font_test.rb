require 'test_helper'

class TcpdfFontTest < ActiveSupport::TestCase
  class MYPDF < TCPDF
    def putfonts()
      super
    end
  end

  test "core Font test" do
    pdf = MYPDF.new

    pdf.set_font('helvetica', '', 18)
    pdf.set_font('helvetica', 'B', 18)
    pdf.set_font('helvetica', 'I', 18)
    pdf.set_font('helvetica', 'BI', 18)

    pdf.set_font('times', '', 18)
    pdf.set_font('times', 'B', 18)
    pdf.set_font('times', 'I', 18)
    pdf.set_font('times', 'BI', 18)

    pdf.set_font('courier', '', 18)
    pdf.set_font('courier', 'B', 18)
    pdf.set_font('courier', 'I', 18)
    pdf.set_font('courier', 'BI', 18)

    pdf.set_font('symbol', '', 18)
    pdf.set_font('zapfdingbats', '', 18)

    pdf.putfonts()
  end

  test "TrueTypeUnicode Font test" do
    pdf = MYPDF.new

    pdf.set_font('freesans', '', 18)
    pdf.set_font('freesans', 'B', 18)
    pdf.set_font('freesans', 'I', 18)
    pdf.set_font('freesans', 'BI', 18)

    pdf.set_font('freemono', '', 18)
    pdf.set_font('freemono', 'B', 18)
    pdf.set_font('freemono', 'I', 18)
    pdf.set_font('freemono', 'BI', 18)

    pdf.set_font('dejavusans', '', 18)
    pdf.set_font('dejavusans', 'B', 18)
    pdf.set_font('dejavusans', 'I', 18)
    pdf.set_font('dejavusans', 'BI', 18)

    pdf.putfonts()
  end

  test "cidfont0 Font test" do
    pdf = MYPDF.new

    pdf.set_font('cid0cs', '', 18)
    pdf.set_font('cid0cs', 'B', 18)
    pdf.set_font('cid0cs', 'I', 18)
    pdf.set_font('cid0cs', 'BI', 18)

    pdf.set_font('cid0ct', '', 18)
    pdf.set_font('cid0ct', 'B', 18)
    pdf.set_font('cid0ct', 'I', 18)
    pdf.set_font('cid0ct', 'BI', 18)

    pdf.set_font('cid0jp', '', 18)
    pdf.set_font('cid0jp', 'B', 18)
    pdf.set_font('cid0jp', 'I', 18)
    pdf.set_font('cid0jp', 'BI', 18)

    pdf.set_font('cid0kr', '', 18)
    pdf.set_font('cid0kr', 'B', 18)
    pdf.set_font('cid0kr', 'I', 18)
    pdf.set_font('cid0kr', 'BI', 18)

    pdf.set_font('kozgopromedium', '', 18)
    pdf.set_font('kozgopromedium', 'B', 18)
    pdf.set_font('kozgopromedium', 'I', 18)
    pdf.set_font('kozgopromedium', 'BI', 18)

    pdf.set_font('kozminproregular', '', 18)
    pdf.set_font('kozminproregular', 'B', 18)
    pdf.set_font('kozminproregular', 'I', 18)
    pdf.set_font('kozminproregular', 'BI', 18)

    pdf.set_font('msungstdlight', '', 18)
    pdf.set_font('msungstdlight', 'B', 18)
    pdf.set_font('msungstdlight', 'I', 18)
    pdf.set_font('msungstdlight', 'BI', 18)

    pdf.set_font('stsongstdlight', '', 18)
    pdf.set_font('stsongstdlight', 'B', 18)
    pdf.set_font('stsongstdlight', 'I', 18)
    pdf.set_font('stsongstdlight', 'BI', 18)

    pdf.set_font('hysmyeongjostdmedium', '', 18)
    pdf.set_font('hysmyeongjostdmedium', 'B', 18)
    pdf.set_font('hysmyeongjostdmedium', 'I', 18)
    pdf.set_font('hysmyeongjostdmedium', 'BI', 18)

    pdf.putfonts()
  end
end
