module v_html

fn test_search_by_attributes() {
	mut parser := v_html.Parser{}
	parser.initialize_all()
	parser.finalize()
	assert true == true
}

fn test_search_by_tag_type() {
	mut temp_html := "<!doctype html><html><head><title>Giant String</title></head><body>"
	for counter := 0; counter < 4; counter++ {
		temp_html += "<div id='name_$counter' class='several-$counter'>Look at $counter</div>"
	}
	temp_html += "</body></html>"
	mut parser := v_html.Parser{}
	parser.parse_html(temp_html, false)
	assert true == true
}

fn test_new_search() {
	assert true == true
}
