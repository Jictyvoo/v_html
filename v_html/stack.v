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
	return stack.null_element
}

fn (stack mut Stack) push(item int) {
	if stack.elements.len > stack.size {
		stack.elements[stack.size] = item
	} else {
		stack.elements << item
	}
	stack.size++
}
