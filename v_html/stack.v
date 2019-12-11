module v_html

struct Stack {
	null_tag Tag
	mut:
		elements []Tag
		size int = 0
}

fn (stack Stack) is_null(verify Tag) bool {
	return verify.name == stack.null_tag.name
}

fn (stack Stack) is_empty() bool {
	return stack.size <= 0
}

fn (stack Stack) peek() Tag {
	if !stack.is_empty() {
		return stack.elements[stack.size - 1]
	}
	return stack.null_tag
}

fn (stack mut Stack) pop() Tag {
	mut to_return := stack.null_tag
	if !stack.is_empty() {
		to_return = stack.elements[stack.size - 1]
		stack.size--
	}
	return stack.null_tag
}

fn (stack mut Stack) push(item Tag) {
	if stack.elements.len > stack.size {
		stack.elements[stack.size] = item
	} else {
		stack.elements << item
	}
	stack.size++
}
