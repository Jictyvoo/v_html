module v_html

#include <limits.h>
struct Stack {
	null_element int=C.INT_MIN
mut:
	elements     []int
	size         int=0
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
	}
	else {
		stack.elements << item
	}
	stack.size++
}

struct BTree {
mut:
	all_tags     []Tag
	node_pointer int=0
	childrens    [][]int
}

fn (btree mut BTree) add_children(tag Tag) int {
	btree.all_tags << tag
	if btree.all_tags.len > 1 {
		for btree.childrens.len <= btree.node_pointer {
			btree.childrens << []int
		}
		btree.childrens[btree.node_pointer] << btree.all_tags.len - 1
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
