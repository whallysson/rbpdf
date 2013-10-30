require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase

  test "bookmark test" do
    pdf = TCPDF.new
    pdf.SetPrintHeader(false)
    pdf.AddPage()

    book = pdf.Bookmark('Chapter 1', 0, 0)
    assert_equal book, [{:l=>0, :y=>0, :t=>"Chapter 1", :p=>1}]

    book = pdf.Bookmark('Paragraph 1.1', 1, 0)
    assert_equal book, [{:y=>0, :l=>0, :t=>"Chapter 1", :p=>1},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.1", :p=>1}]

    pdf.SetPrintFooter(false)
    pdf.AddPage()

    book = pdf.Bookmark('Paragraph 1.2', 1, 0)
    assert_equal book, [{:y=>0, :l=>0, :t=>"Chapter 1", :p=>1},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.1", :p=>1},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.2", :p=>2}]

    book = pdf.Bookmark('Sub-Paragraph 1.2.1', 2, 10)
    assert_equal book, [{:y=>0, :l=>0, :t=>"Chapter 1", :p=>1},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.1", :p=>1},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.2", :p=>2},
                        {:y=>10, :l=>2, :t=>"Sub-Paragraph 1.2.1", :p=>2}]

    pdf.SetPrintFooter(false)
    pdf.AddPage()

    book = pdf.Bookmark('Paragraph 1.3', 1, 0)
    assert_equal book, [{:y=>0, :l=>0, :t=>"Chapter 1", :p=>1},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.1", :p=>1},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.2", :p=>2},
                        {:y=>10, :l=>2, :t=>"Sub-Paragraph 1.2.1", :p=>2},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.3", :p=>3}]

    book = pdf.Bookmark('Sub-Paragraph 1.1.1', 2, 0, 2)
    assert_equal book, [{:y=>0, :l=>0, :t=>"Chapter 1", :p=>1},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.1", :p=>1},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.2", :p=>2},
                        {:y=>10, :l=>2, :t=>"Sub-Paragraph 1.2.1", :p=>2},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.3", :p=>3},
                        {:y=>0, :l=>2, :t=>"Sub-Paragraph 1.1.1", :p=>2}]

    pdf.SetPrintFooter(false)
    pdf.AddPage()

    book = pdf.Bookmark('Paragraph 1.4', 1, 20)
    assert_equal book, [{:y=>0, :l=>0, :t=>"Chapter 1", :p=>1},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.1", :p=>1},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.2", :p=>2},
                        {:y=>10, :l=>2, :t=>"Sub-Paragraph 1.2.1", :p=>2},
                        {:y=>0, :l=>1, :t=>"Paragraph 1.3", :p=>3},
                        {:y=>0, :l=>2, :t=>"Sub-Paragraph 1.1.1", :p=>2},
                        {:y=>20, :l=>1, :t=>"Paragraph 1.4", :p=>4}]
  end
end
