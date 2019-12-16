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

struct BTreeNode {
	element Tag
	mut:
		childrens []BTreeNode
}

struct BTree {
	mut:
		all_nodes []BTreeNode
		node_pointer int = 0
}

fn (btree mut BTree) add_children(tag Tag) int {
	btree.all_nodes << BTreeNode{element: tag}
	if btree.all_nodes.len > 1 {
		btree.all_nodes[btree.node_pointer].childrens << btree.all_nodes[btree.all_nodes.len - 1] //segfault
	}
	return btree.all_nodes.len - 1
}

fn (btree BTree) get_children() []BTreeNode {
	return btree.all_nodes[btree.node_pointer].childrens
}

fn (btree mut BTree) move_pointer(to int) {
	if to < btree.all_nodes.len {
		btree.node_pointer = to
	}
}
