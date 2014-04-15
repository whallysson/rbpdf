require 'test_helper'

class TcpdfTest < ActiveSupport::TestCase

  test "Dom Basic" do
    pdf = TCPDF.new

    # Simple Text
    dom = pdf.getHtmlDomArray('abc')
    assert_equal 0, dom[0]['parent']  # Root
    assert_equal false, dom[0]['tag']
    assert_equal({'tag'=>false, 'value'=>'abc', 'elkey'=>0, 'parent'=>0, 'block'=>false}, dom[1])

    # Simple Tag
    dom = pdf.getHtmlDomArray('<b>abc</b>')
    assert_equal 0, dom[0]['parent']  # Root
    assert_equal false, dom[0]['tag']
    assert_equal({}, dom[0]['attribute'])

    assert_equal({'tag' => false, 'value'=>'', 'elkey'=>0, 'parent'=>0, 'block'=>false}, dom[1])

    assert_equal 0, dom[2]['parent']   # parent -> parent tag key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal true, dom[2]['opening']
    assert_equal 'b', dom[2]['value']
    assert_equal({}, dom[2]['attribute'])

    assert_equal({'tag' => false, 'value'=>'abc', 'elkey'=>2, 'parent'=>2, 'block'=>false}, dom[3])  # parent -> open tag key

    assert_equal 2, dom[4]['parent']   # parent -> open tag key
    assert_equal 3, dom[4]['elkey']
    assert_equal true, dom[4]['tag']
    assert_equal false, dom[4]['opening']
    assert_equal 'b', dom[4]['value']

    # Error Tag (doble colse tag)
    dom = pdf.getHtmlDomArray('</ul></div>')
    assert_equal 0, dom[0]['parent']  # Root
    assert_equal false, dom[0]['tag']
    assert_equal({}, dom[0]['attribute'])

    assert_equal({'tag' => false, 'value'=>'', 'elkey'=>0, 'parent'=>0, 'block'=>false}, dom[1])

    assert_equal 0, dom[2]['parent']   # parent -> Root key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal false, dom[2]['opening']
    assert_equal 'ul', dom[2]['value']

    assert_equal({'tag' => false, 'value'=>'', 'elkey'=>2, 'parent'=>0, 'block'=>false}, dom[3])  # parent -> open tag key

    assert_equal 0, dom[4]['parent']   # parent -> Root key
    assert_equal 3, dom[4]['elkey']
    assert_equal true, dom[4]['tag']
    assert_equal false, dom[4]['opening']
    assert_equal 'div', dom[4]['value']

    # Attribute
    dom = pdf.getHtmlDomArray('<p style="text-align:justify">abc</p>')
    assert_equal 0, dom[0]['parent']  # Root
    assert_equal false, dom[0]['tag']
    assert_equal({}, dom[0]['attribute'])

    assert_equal({'tag' => false, 'value'=>'', 'elkey'=>0, 'parent'=>0, 'block'=>false}, dom[1])

    assert_equal 0, dom[2]['parent']   # parent -> parent tag key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal true, dom[2]['opening']
    assert_equal 'p', dom[2]['value']
    assert_equal({'style'=>'text-align: justify;'}, dom[2]['attribute'])
    assert_equal('text-align: justify;', dom[2]['attribute']['style'])
    assert_equal('J', dom[2]['align'])

    # Table border
    dom = pdf.getHtmlDomArray('<table border="1"><tr><td>abc</td></tr></table>')
    assert_equal 0, dom[2]['parent']   # parent -> parent tag key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal true, dom[2]['opening']
    assert_equal 'table', dom[2]['value']
    assert_equal('1', dom[2]['attribute']['border'])

    # Table td Width
    dom = pdf.getHtmlDomArray('<table><tr><td width="10">abc</td></tr></table>')
    assert_equal 4, dom[6]['parent']   # parent -> parent tag key
    assert_equal 5, dom[6]['elkey']
    assert_equal true, dom[6]['tag']
    assert_equal true, dom[6]['opening']
    assert_equal 'td', dom[6]['value']
    assert_equal 10, dom[6]['width']

  end
end
