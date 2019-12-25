module v_html

const (
	test_xml = '<?xml version="1.0" encoding="ISO-8859-1"?>
  <catalog>
    <cd country="USA"><title>Empire Burlesque</title><artist>Bob Dylan</artist><price>10.90</price></cd>
    <cd country="UK"><title>Hide your heart</title><artist>Bonnie Tyler</artist><price>9.90</price></cd>
    <cd country="USA"><title>Greatest Hits</title><artist>Dolly Parton</artist><price>9.90</price></cd>
  </catalog>'
)

fn create_xpath() v_html.XPath {
	mut parser := v_html.Parser{}
	parser.parse_html(test_xml, false)
	dom := parser.get_dom()
	mut xpath := XPath{}
	xpath.set_dom(dom)
	return xpath
}

fn test_subelement_search() {
	xpath := create_xpath()
	xpath.search("/catalog/cd/price")
}
