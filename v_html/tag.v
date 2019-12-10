module v_html

struct Tag {
	mut:
		name string = ""
		attributes map[string]string /*attributes will be like map[name]value*/
		last_attribute string = ""
		content string = ""
		children []Tag
		closed bool = false
}

fn (tag mut Tag) add_child(t Tag) {
	tag.children << t
}

pub fn (tag Tag) get_children() []Tag {
	return tag.children
}

pub fn (tag Tag) str() string {
	mut to_return := "< ${tag.name} "
	for key in tag.attributes.keys() {
		to_return += "$key=" + "'" + "${tag.attributes[key]}" + "'"
	}
	to_return += ">"
	for child in tag.children { to_return += child.str() }
	return to_return + "</${tag.name}>"
}
