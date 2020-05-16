module html

const (
	test_xml = '<?xml version="1.0" encoding="ISO-8859-1"?><catalog><cd country="USA"><title>Empire Burlesque</title><artist>Bob Dylan</artist><price>10.90</price></cd><cd country="UK"><title>Hide your heart</title><artist>Bonnie Tyler</artist><price>9.90</price></cd><cd country="USA"><title>Greatest Hits</title><artist>Dolly Parton</artist><price>9.90</price></cd></catalog>'
)

fn create_xpath() XPath {
	mut parser := Parser{}
	parser.parse_html(test_xml, false)
	dom := parser.get_dom()
	mut xpath := XPath{}
	xpath.set_dom(dom)
	return xpath
}

fn assert_search_order(queue string, expected []Token) {
	xpath := create_xpath()
	xpath.how_search(queue)
	for index := 0; index < xpath.search_order.len; index++ {
		assert xpath.search_order[index].eq(expected[index])
	}
}

fn test_search_order() {
	xpath := create_xpath()
	mut result := xpath.search('//cd') //testing entire_document
	
	result = xpath.search('/catalog/cd/price') //testing subelement
	result = xpath.search('/catalog/cd/*') //testing unknown
	result = xpath.search('/catalog/*/price') //testing unknown_parent
	result = xpath.search('/catalog/cd/price[last = 0]') //testing entire_document
}

fn test_entire_document_search() {
	xpath := create_xpath()
	xpath.search('//cd')
}

fn test_subelement_search() {
	xpath := create_xpath()
	xpath.search('/catalog/cd/price')
}

fn test_subelement_unknown_search() {
	xpath := create_xpath()
	xpath.search('/catalog/cd/*')
}

fn test_unknown_parent_search() {
	xpath := create_xpath()
	xpath.search('/catalog/*/price')
}

fn test_two_ancients_search() {
	xpath := create_xpath()
	xpath.search('/*/*/price')
}

fn test_all_document_search() {
	xpath := create_xpath()
	xpath.search('//*')
}

fn test_single_element_search() {
	xpath := create_xpath()
	xpath.search('/catalog/cd[1]')
}

fn test_last_element_search() {
	xpath := create_xpath()
	xpath.search('/catalog/cd[last()]')
}

fn test_have_subelement_search() {
	xpath := create_xpath()
	xpath.search('/catalog/cd[price]')
}

fn test_have_subelement_value_search() {
	xpath := create_xpath()
	xpath.search('/catalog/cd[price=10.90]')
}

fn test_attribute_search() {
	xpath := create_xpath()
	xpath.search('//@country')
}

fn test_have_attribute_named_search() {
	xpath := create_xpath()
	xpath.search('//cd[@country]')
}

fn test_subelement_have_attribute_search() {
	xpath := create_xpath()
	xpath.search('//cd[@*]')
}
