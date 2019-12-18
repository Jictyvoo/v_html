module v_html

struct Tag {
	mut:
		name string = ""
		attributes map[string]string /*attributes will be like map[name]value*/
		last_attribute string = ""
		content string = ""
		closed bool = false
}

pub fn (tag Tag) get_content() string {
	return tag.content
}

pub fn (tag Tag) str() string {
	mut to_return := "<${tag.name}"
	for key in tag.attributes.keys() {
		to_return += " $key"
		value := tag.attributes[key]
		if value.len > 0 { to_return += "=" + "${tag.attributes[key]}" }
	}
	to_return += if tag.closed { "/>" } else {">"}
	to_return += "${tag.content}"
	if !tag.closed { to_return += "</${tag.name}>"}
	return to_return
}
