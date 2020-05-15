module html

struct Tag {
mut:
	name           string = ""
	attributes     map[string]string // attributes will be like map[name]value
	last_attribute string = ""
	content        string = ""
	children       []&Tag
	closed         bool = false
}

fn (mut tag Tag) add_child(t &Tag) {
	mut children := tag.children
	children << t
	tag.children = children
}

pub fn (tag Tag) get_children() []Tag_ptr {
	return tag.children
}

pub fn (tag Tag) get_content() string {
	return tag.content
}

pub fn (tag Tag) str() string {
	mut to_return := '<${tag.name}'
	for key in tag.attributes.keys() {
		to_return += ' $key'
		value := tag.attributes[key]
		if value.len > 0 {
			to_return += '=' + '"${tag.attributes[key]}"'
		}
	}
	to_return += if tag.closed {
		'/>'
	} else {
		'>'
	}
	to_return += '${tag.content}'
	if tag.children.len > 0 {
		// println('${tag.name} have ${tag.children.len} childrens')
		for index := 0; index < tag.children.len; index++ {
			to_return += tag.get_children()[index].str()
		}
	}
	if !tag.closed {
		to_return += '</${tag.name}>'
	}
	return to_return
}
