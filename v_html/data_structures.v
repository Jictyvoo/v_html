module v_html

struct Stack {
	null_element int = C.NULL
	mut:
		elements []int
		size int = 0
}

fn (stack Stack) is_null(data int) bool {
	return data == stack.null_element
}

fn (stack Stack) is_empty() bool {
	return stack.size <= 0
}

fn (stack Stack) peek() int {
	if !stack.is_empty() {
		return stack.elements[stack.size - 1]
	}
	return stack.null_element
}

fn (stack mut Stack) pop() int {
	mut to_return := stack.null_element
	if !stack.is_empty() {
		to_return = stack.elements[stack.size - 1]
		stack.size--
	}
	return to_return
}

fn (stack mut Stack) push(item int) {
	if stack.elements.len > stack.size {
		stack.elements[stack.size] = item
	} else {
		stack.elements << item
	}
	stack.size++
}

struct BTree {
	mut:
		all_tags []Tag
		node_pointer int = 0
		childrens [][]int
}

fn (btree mut BTree) add_children(tag Tag) int {
	println("OK_1")
	btree.all_tags << tag
	println("OK_2")
	if btree.all_tags.len > 1 {
		println("OK_3")
		for btree.childrens.len <= btree.node_pointer {		
			println("OK_4")
			btree.childrens << []int
			println("OK_5 >> " + btree.childrens.len.str())
		}
		println("OK_6")
		mut temp_array := btree.childrens[btree.node_pointer]
		temp_array << btree.all_tags.len - 1
		println("OK_7")
	}
	return btree.all_tags.len - 1
}

fn (btree BTree) get_children() []int {
	return btree.childrens[btree.node_pointer]
}

fn (btree BTree) get_stored() Tag {
	return btree.all_tags[btree.node_pointer]
}

fn (btree mut BTree) move_pointer(to int) {
	if to < btree.all_tags.len {
		btree.node_pointer = to
	}
}
