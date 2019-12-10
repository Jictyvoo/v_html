module v_html

pub struct DocumentObjectModel {
	mut:
		tags []Tag
		stack Stack
		root Tag
		close_tags map[string]bool = {"/!document": true}
		attributes map[string][]string
		tag_attributes [][]Tag
		tag_type map[string][]Tag
}

fn (dom mut DocumentObjectModel) new_root(tag Tag) {
	mut new_tag := Tag{} new_tag.name = "div"
	new_tag.add_child(dom.root) new_tag.add_child(tag)
	dom.root = new_tag
}

fn is_close_tag(tag Tag) bool {
	if tag.name.len > 0 {
    	return tag.name[0] == 47 // return if equals to /
	}
	return false
}

fn (dom mut DocumentObjectModel) where_is(item_name string, attribute_name string) int {
	if !attribute_name in dom.attributes {
		dom.attributes[attribute_name] = []
	}
	mut string_array := dom.attributes[attribute_name]
	mut counter := 0
	for value in string_array {
		if value == item_name {return counter}
		counter++
	}
	string_array << item_name
	dom.attributes[attribute_name] = string_array
	return string_array.len - 1
}

fn (dom mut DocumentObjectModel) add_tag_attribute(tag Tag) {
	for attribute_name in tag.attributes.keys() {
		temp_string := tag.attributes[attribute_name]
		location := dom.where_is(temp_string, attribute_name)
		for dom.tag_attributes.len <= location { dom.tag_attributes << []Tag }
		mut temp_array := dom.tag_attributes[location]
		temp_array << tag
		dom.tag_attributes[location] = temp_array
	}
}

fn (dom mut DocumentObjectModel) add_tag_by_type(tag Tag) {
	tag_name := tag.name
	if !tag_name in dom.tag_type { dom.tag_type[tag_name] = [] }
	dom.tag_type[tag_name] << tag
}

fn (dom mut DocumentObjectModel) construct(tag_list []Tag) {
	dom.tags = tag_list
	dom.root = tag_list[0]
	mut temp_tag := dom.stack.null_tag
	mut temp_string := ""
	for tag in tag_list {
		if is_close_tag(tag) {
			temp_tag = dom.stack.peek()
			for !dom.stack.is_null(temp_tag) && (tag.name[1 .. tag.name.len] != dom.stack.peek().name) {
				temp_tag = dom.stack.peek()
				dom.stack.pop()
			}
			temp_tag = dom.stack.peek()
			if !dom.stack.is_null(temp_tag) { dom.stack.pop() }
		} else {
			dom.add_tag_attribute(tag) dom.add_tag_by_type(tag)
			temp_string = "/" + tag.name
			if dom.close_tags[temp_string] || !tag.closed { //if tag ends with />
				dom.stack.push(tag)
			} else {
				temp_tag = dom.stack.peek()
				if !dom.stack.is_null(temp_tag) {
					temp_tag.add_child(tag)
				} else {
					dom.new_root(tag)
				}
			}
		}
	}
}

pub fn (dom mut DocumentObjectModel) get_by_attributes(name string, value string) []Tag {
	location := dom.where_is(name, value)
	return dom.tag_attributes[location]
}

pub fn (dom DocumentObjectModel) get_by_tag(name string) []Tag {
	if name in dom.tag_type {
		return dom.tag_type[name]
	}
	return []
}

pub fn (dom DocumentObjectModel) get_root() Tag {
	return dom.root
}
