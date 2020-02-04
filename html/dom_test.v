module html

fn generate_temp_html() string {
	mut temp_html := "<!doctype html><html><head><title>Giant String</title></head><body>"
	for counter := 0; counter < 4; counter++ {
		temp_html += "<div id='name_$counter' "
		temp_html += "class='several-${counter}'>Look at ${counter}</div>"
	}
	temp_html += "</body></html>"
	return temp_html
}

fn generate_dom(temp_html string) html.DocumentObjectModel {
	mut parser := html.Parser{}
	parser.parse_html(temp_html, false)
	dom := parser.get_dom()
	return dom
}

fn test_search_by_tag_type() {
	dom := generate_dom(generate_temp_html())
	assert dom.get_by_tag("div").len == 4
	assert dom.get_by_tag("head").len == 1
	assert dom.get_by_tag("body").len == 1
}

fn test_search_by_attribute_value() {
	mut dom := generate_dom(generate_temp_html())
	//println(temp_html)
	print("Amount ")
	println(dom.get_by_attribute_value("id", "name_0"))
	assert dom.get_by_attribute_value("id", "name_0").len == 1
}

fn test_search_by_attributes() {
	dom := generate_dom(generate_temp_html())
	assert dom.get_by_attribute("id").len == 4
}

fn test_tags_used() {
	dom := generate_dom(generate_temp_html())
	assert dom.get_all_tags().len == 9
}
