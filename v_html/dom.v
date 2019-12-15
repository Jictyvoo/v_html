module v_html

import os

pub struct DocumentObjectModel {
	mut:
		root Tag
		constructed bool = false
		close_tags map[string]bool = {"/!document": true}
		attributes map[string][]string
		tag_attributes [][]Tag
		tag_type map[string][]Tag
		debug_file os.File
}

fn (dom mut DocumentObjectModel) print_debug(data string) {
	if data.len > 0 {
		dom.debug_file.writeln(data)
	}
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

fn compare_string(a string, b string) bool { // for some reason == doesn't work
	if a.len != b.len {return false}
	for i := 0; i < a.len; i++ {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

fn (dom mut DocumentObjectModel) construct(tag_list mut []Tag) {
	dom.constructed = true
	mut stack := Stack{}
	dom.root = tag_list[1]
	stack.push(1)
	mut root_index := 1
	mut temp_tag := tag_list[0]
	mut temp_int := C.NULL
	mut temp_string := ""
	for index := 2; index < tag_list.len; index++ {
		tag := tag_list[index]
		dom.print_debug(tag.str())
		if is_close_tag(tag) {
			temp_int = stack.peek()
			if !stack.is_null(temp_int) {temp_tag = tag_list[temp_int]}
			temp_string = tag.name[1 .. tag.name.len]
			
			//print(temp_string + " != " + temp_tag.name + " >> ")
			//println(temp_string != temp_tag.name)
			for !stack.is_null(temp_int) && !compare_string(temp_string, temp_tag.name) && !temp_tag.closed {
				dom.print_debug(temp_string + " >> " + temp_tag.name + " " + compare_string(temp_string, temp_tag.name).str())
				stack.pop()
				temp_int = stack.peek()
				if !stack.is_null(temp_int) {temp_tag = tag_list[temp_int]}
			}
			temp_int = stack.peek()
			if !stack.is_null(temp_int) { temp_tag = tag_list[temp_int] stack.pop() }
			dom.print_debug("Removed " + temp_string + " -- " + temp_tag.name)
		} else if tag.name.len > 0 {
			dom.add_tag_attribute(tag)
			dom.add_tag_by_type(tag)
			temp_int = stack.peek()
			if !stack.is_null(temp_int) {
				tag_list[temp_int].add_child(tag)
				dom.print_debug("Added ${tag.name} as child of '" + tag_list[temp_int].name + "' which now has ${tag_list[temp_int].children.len} childrens")
			} else {
				dom.new_root(tag)
				stack.push(root_index)
				root_index = index
			}
			temp_string = "/" + tag.name
			if temp_string in dom.close_tags && !tag.closed { //if tag ends with />
				dom.print_debug("Pushed " + temp_string)
				stack.push(index)
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
