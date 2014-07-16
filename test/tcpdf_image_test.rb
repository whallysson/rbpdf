require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase

  test "Image basic func extension test" do
    pdf = TCPDF.new

    type = pdf.get_image_file_type("/tmp/tcpdf_logo.gif")
    assert_equal type, "gif"

    type = pdf.get_image_file_type("/tmp/tcpdf_logo.PNG")
    assert_equal type, "png"

    type = pdf.get_image_file_type("/tmp/tcpdf_logo.jpg")
    assert_equal type, "jpeg"

    type = pdf.get_image_file_type("/tmp/tcpdf_logo.jpeg")
    assert_equal type, "jpeg"

    type = pdf.get_image_file_type("/tmp/tcpdf_logo")
    assert_equal type, ""

    type = pdf.get_image_file_type("")
    assert_equal type, ""

    type = pdf.get_image_file_type(nil)
    assert_equal type, ""
  end

  test "Image basic func mime type test" do
    pdf = TCPDF.new

    type = pdf.get_image_file_type(nil, {})
    assert_equal type, ''

    type = pdf.get_image_file_type(nil, {'mime' => 'image/gif'})
    assert_equal type, 'gif'

    type = pdf.get_image_file_type(nil, {'mime' => 'image/jpeg'})
    assert_equal type, 'jpeg'

    type = pdf.get_image_file_type('/tmp/tcpdf_logo.gif', {'mime' => 'image/png'})
    assert_equal type, 'png'

    type = pdf.get_image_file_type('/tmp/tcpdf_logo.gif', {})
    assert_equal type, 'gif'

    type = pdf.get_image_file_type(nil, {'mime' => 'text/html'})
    assert_equal type, ''

    type = pdf.get_image_file_type(nil, [])
    assert_equal type, ''
  end

  test "Image basic filename test" do
    pdf = TCPDF.new
    err = assert_raises(RuntimeError) { 
      pdf.image(nil)
    }
    assert_equal( err.message, 'TCPDF error: Image filename is empty.')

    err = assert_raises(RuntimeError) { 
      pdf.image('')
    }
    assert_equal( err.message, 'TCPDF error: Image filename is empty.')

    err = assert_raises(RuntimeError) { 
      pdf.image('foo.png')
    }
    assert_equal( err.message, 'TCPDF error: Missing image file: foo.png')
  end
end
