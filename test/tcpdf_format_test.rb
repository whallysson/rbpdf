require 'test_helper'

class TcpdfFormatTest < ActiveSupport::TestCase

  test "setPageOrientation" do
    pdf = TCPDF.new

    pagedim = pdf.setPageOrientation('')
    assert_equal pagedim['or'], 'P'
    assert_equal pagedim['pb'], true
    assert_equal pagedim['olm'], nil
    assert_equal pagedim['orm'], nil
    assert_in_delta pagedim['bm'], 20, 0.1

    pagedim = pdf.setPageOrientation('P')
    assert_equal pagedim['or'], 'P'

    pagedim = pdf.setPageOrientation('L', false)
    assert_equal pagedim['or'], 'L'
    assert_equal pagedim['pb'], false

    pagedim = pdf.setPageOrientation('P', true, 5)
    assert_equal pagedim['or'], 'P'
    assert_equal pagedim['pb'], true
    assert_equal pagedim['bm'], 5
  end
end
