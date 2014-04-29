require 'test_helper'

class TcpdfCssTest < ActiveSupport::TestCase

  test "CSS Basic" do
    pdf = TCPDF.new

    # empty
    css = pdf.extractCSSproperties('')
    assert_equal({}, css)
    # empty blocks
    css = pdf.extractCSSproperties('h1 {}')
    assert_equal({}, css)
    # comment
    css = pdf.extractCSSproperties('/* comment */')
    assert_equal({}, css)

    css = pdf.extractCSSproperties('h1 { color: navy; font-family: times; }')
    assert_equal({"0001 h1"=>"color:navy;font-family:times;"}, css)

    css = pdf.extractCSSproperties('h1 { color: navy; font-family: times; } p.first { color: #003300; font-family: helvetica; font-size: 12pt; }')
    assert_equal({"0001 h1"=>"color:navy;font-family:times;", "0021 p.first"=>"color:#003300;font-family:helvetica;font-size:12pt;"}, css)

    css = pdf.extractCSSproperties('h1,h2,h3{background-color:#e0e0e0}')
    assert_equal({"0001 h1"=>"background-color:#e0e0e0", "0001 h2"=>"background-color:#e0e0e0", "0001 h3"=>"background-color:#e0e0e0"}, css)

    css = pdf.extractCSSproperties('p#second { color: rgb(00,63,127); font-family: times; font-size: 12pt; text-align: justify; }')
    assert_equal({"0101 p#second"=>"color:rgb(00,63,127);font-family:times;font-size:12pt;text-align:justify;"}, css)

    # media
    css = pdf.extractCSSproperties('@media print { body { font: 10pt serif } }')
    assert_equal({"0001 body"=>"font:10pt serif"}, css)
    css = pdf.extractCSSproperties('@media screen { body { font: 12pt sans-serif } }')
    assert_equal({}, css)
    css = pdf.extractCSSproperties('@media all { body { line-height: 1.2 } }')
    assert_equal({"0001 body"=>"line-height:1.2"}, css)

    css = pdf.extractCSSproperties('@media print {
                   #top-menu, #header, #main-menu, #sidebar, #footer, .contextual, .other-formats { display:none; }
                   #main { background: #fff; }
                   #content { width: 99%; margin: 0; padding: 0; border: 0; background: #fff; overflow: visible !important;}
                   #wiki_add_attachment { display:none; }
                   .hide-when-print { display: none; }
                   .autoscroll {overflow-x: visible;}
                   table.list {margin-top:0.5em;}
                   table.list th, table.list td {border: 1px solid #aaa;}
                 } @media all { body { line-height: 1.2 } }')
    assert_equal({"0100 #top-menu"=>"display:none;",
                  "0100 #header"=>"display:none;",
                  "0100 #main-menu"=>"display:none;",
                  "0100 #sidebar"=>"display:none;",
                  "0100 #footer"=>"display:none;",
                  "0010 .contextual"=>"display:none;",
                  "0010 .other-formats"=>"display:none;",
                  "0100 #main"=>"background:#fff;",
                  "0100 #content"=>"width:99%;margin:0;padding:0;border:0;background:#fff;overflow:visible !important;",
                  "0100 #wiki_add_attachment"=>"display:none;",
                  "0010 .hide-when-print"=>"display:none;",
                  "0010 .autoscroll"=>"overflow-x:visible;",
                  "0011 table.list"=>"margin-top:0.5em;",
                  "0012 table.list th"=>"border:1px solid #aaa;",
                  "0012 table.list td"=>"border:1px solid #aaa;",
                  "0001 body"=>"line-height:1.2" }, css)

  end

  test "CSS Selector Valid test" do
    pdf = TCPDF.new

    # Simple CSS
    dom = pdf.getHtmlDomArray('<p>abc</p>')
    valid = pdf.isValidCSSSelectorForTag(dom, 2, ' p') # dom, key, css selector
    assert_equal(true, valid)
    dom = pdf.getHtmlDomArray('<h1>abc</h1>')
    valid = pdf.isValidCSSSelectorForTag(dom, 2, ' h1') # dom, key, css selector
    assert_equal(true, valid)
    dom = pdf.getHtmlDomArray('<p class="first">abc</p>')
    valid = pdf.isValidCSSSelectorForTag(dom, 2, ' p.first') # dom, key, css selector
    assert_equal(true, valid)
    dom = pdf.getHtmlDomArray('<p class="first">abc<span>def</span></p>')
    valid = pdf.isValidCSSSelectorForTag(dom, 4, ' p.first span') # dom, key, css selector
    assert_equal(true, valid)
    dom = pdf.getHtmlDomArray('<p id="second">abc</p>')
    valid = pdf.isValidCSSSelectorForTag(dom, 2, ' p#second') # dom, key, css selector
    assert_equal(true, valid)
    dom = pdf.getHtmlDomArray('<p id="second">abc<span>def</span></p>')
    valid = pdf.isValidCSSSelectorForTag(dom, 4, ' p#second > span') # dom, key, css selector
    assert_equal(true, valid)
  end

  test "CSS Tag Sytle test" do
    pdf = TCPDF.new

    # Simple CSS
    dom = pdf.getHtmlDomArray('<h1>abc</h1>')
    tag = pdf.getTagStyleFromCSS(dom, 2, {"0001 h1"=>"color:navy;font-family:times;"}) # dom, key, css selector
    assert_equal(";color:navy;font-family:times;", tag)

    tag = pdf.getTagStyleFromCSS(dom, 2, {"0001h1"=>"color:navy;font-family:times;"}) # dom, key, css selector
    assert_equal("", tag)

    tag = pdf.getTagStyleFromCSS(dom, 2, {"0001 h2"=>"color:navy;font-family:times;"}) # dom, key, css selector
    assert_equal("", tag)
  end

  test "CSS Dom test" do
    pdf = TCPDF.new

    html = '<style> table, td { border: 2px #ff0000 solid; } </style>
            <h2>HTML TABLE:</h2>
            <table> <tr> <th>abc</th> </tr>
                    <tr> <td>def</td> </tr> </table>'
    dom = pdf.getHtmlDomArray(html)
    assert_equal 29, dom.length
    assert_equal 0, dom[0]['parent']  # Root
    assert_equal false, dom[0]['tag']
    assert_equal({}, dom[0]['attribute'])

    assert_equal 0, dom[2]['parent']   # parent -> parent tag key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal true, dom[2]['opening']
    assert_equal "h2", dom[2]['value']

    assert_equal "table", dom[6]['value']
    assert_equal({'border'=>'2px #ff0000 solid', 'style'=>';border:2px #ff0000 solid;'}, dom[6]['attribute'])
    assert_equal '2px #ff0000 solid', dom[6]['style']['border']
    assert_equal '2px #ff0000 solid', dom[6]['attribute']['border']
  end

  test "CSS Dom line-height test normal" do
    pdf = TCPDF.new

    html = '<style>  h2 { line-height: normal; } </style>
            <h2>HTML TEST</h2>'
    dom = pdf.getHtmlDomArray(html)
    assert_equal 5, dom.length
    assert_equal 0, dom[2]['parent']   # parent -> parent tag key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal true, dom[2]['opening']
    assert_equal 'h2', dom[2]['value']
    assert_equal 1.25, dom[2]['line-height']
  end

  test "CSS Dom line-height test numeric" do
    pdf = TCPDF.new

    html = '<style>  h2 { line-height: 1.4; } </style>
            <h2>HTML TEST</h2>'
    dom = pdf.getHtmlDomArray(html)
    assert_equal 5, dom.length
    assert_equal 0, dom[2]['parent']   # parent -> parent tag key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal true, dom[2]['opening']
    assert_equal 'h2', dom[2]['value']
    assert_equal 1.4, dom[2]['line-height']
  end

  test "CSS Dom line-height test percentage" do
    pdf = TCPDF.new

    html = '<style>  h2 { line-height: 10%; } </style>
            <h2>HTML TEST</h2>'
    dom = pdf.getHtmlDomArray(html)
    assert_equal 5, dom.length
    assert_equal 0, dom[2]['parent']   # parent -> parent tag key
    assert_equal 1, dom[2]['elkey']
    assert_equal true, dom[2]['tag']
    assert_equal true, dom[2]['opening']
    assert_equal 'h2', dom[2]['value']
    assert_equal 0.1, dom[2]['line-height']
  end
end
