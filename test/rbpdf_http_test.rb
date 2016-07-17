require 'test_helper'

class RbpdfHttpTest < Test::Unit::TestCase
  class MYPDF < RBPDF
    def get_image_file(uri)
      super
    end
  end

  def setup
    require 'webrick'
    @port = 51234

    dir = File.dirname(__FILE__)
    @s = WEBrick::HTTPServer.new(:Port => @port, :DocumentRoot => dir, :BindAddress => "0.0.0.0", :DoNotReverseLookup => true)
    @t = Thread.new { @s.start }
  end

  test "Image get image file test" do
    pdf = MYPDF.new
    pdf.add_page
    tmpFile = pdf.get_image_file('http://127.0.0.1:' + @port.to_s + '/logo_rbpdf_8bit.png')
    img_file = tmpFile.path
    assert_not_equal "", img_file
    unless File.exists?(img_file)
      assert false, "file not found. :" + img_file
    end

    result_img = pdf.image(img_file, 50, 0, 0, '', '', '', '', false, 300, '', true)
    no = pdf.get_num_pages
    assert_equal 1, no

    # remove temp files
    tmpFile.delete unless tmpFile.nil?

    if File.exists?(img_file)
      assert false, "file found. :" + img_file
    end
  end

  def teardown
    @s.shutdown
    @t.join
  end
end
