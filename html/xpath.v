module html

/*
absolute_path '/'
	all_document '//'
	unknown '*'
	position  '[number]'
	last  '[last()]'
	has  '[identifier]' OR 'name' - @attribute | element
	has_compare  '[element_name=value]'
	multiple_path  '|'
	attribute '@attribute'
	element 'element_name'
	has_attribute  '[@*]'
*/
enum SearchType {
	absolute_path
	all_document
	unknown
	position
	last
	has
	has_compare
	multiple_path
	attribute
	element
	has_attribute
}

struct Token {
	lexeme string
	class  SearchType
}

pub fn (token Token) str() string {
	return '${token.lexeme}: ${token.class}'
}

pub struct XPath {
mut:
	dom          DocumentObjectModel
	found_tags   []&Tag
	search_order []Token
}

pub fn (mut xpath XPath) set_dom(dom DocumentObjectModel) {
	xpath.dom = dom
}

fn classify_has(value string) SearchType {
	if value.len > 0 {
		if value[0] >= 48 && value[0] <= 57 {
			return .position
		} else if value == 'last()' {
			return .last
		} else if value == '@*' {
			return .has_attribute
		} else {
			operators := ['>', '<', '>=', '<=', '=', '!=']
			for operator in operators {
				if value.contains(operator) {
					return .has_compare
				}
			}
		}
	}
	return .has
}

fn classify_identifier(value string) SearchType {
	if value.len > 0 && value[0] == 42 { // '*'
		return .unknown
	} else if value.len > 0 && value[0] == 64 { // @
		return .attribute
	}
	return .element
}

fn (mut xpath XPath) add_search(lexeme string, search_type int) {
	if lexeme.len > 0 {
		search_enum := match search_type {
			1 { html.SearchType.absolute_path }
			else { html.SearchType.all_document }
		}
		xpath.search_order << Token{
			lexeme: '/'
			class: search_enum
		}
		xpath.search_order << Token{
			lexeme: lexeme
			class: classify_identifier(lexeme)
		}
	}
}

fn (mut xpath XPath) how_search(queue string) {
	xpath.search_order = []Token{}
	mut search_type := 0
	mut opened_has := false
	mut lexeme := ''
	for word in queue {
		if opened_has && word == 93 {
			if lexeme.len > 0 {
				xpath.search_order << Token{
					lexeme: lexeme
					class: classify_has(lexeme)
				}
			}
			opened_has = false
			lexeme = '' // 47 - '/'  91 - '['  32 - ' '
		} else if word != 47 && word != 91 && word != 32 {
			lexeme += word.str()
		} else if word != 32 {
			if word == 91 {
				opened_has = true
			}
			if lexeme.len > 0 && search_type >= 0 && search_type <= 2 {
				xpath.add_search(lexeme, search_type)
				search_type = 0
			}
			if word == 47 {
				search_type++
			}
			lexeme = ''
		}
	}
	xpath.add_search(lexeme, search_type)
}

fn (xpath XPath) search_childrens(name string, class SearchType) {
	println('Searching for childrens with name $name')
}

pub fn (mut xpath XPath) search(queue string) []&Tag {
	xpath.how_search(queue)
	xpath.found_tags = []&Tag{}
	if xpath.search_order.len >= 2 {
		if xpath.search_order[0].class == .all_document {
			if xpath.search_order[1].class == .unknown {
				xpath.found_tags = xpath.dom.get_all_tags()
			} else if xpath.search_order[1].class == .element {
				xpath.found_tags = xpath.dom.get_by_tag(xpath.search_order[1].lexeme)
			} else if xpath.search_order[1].class == .attribute {
				xpath.found_tags = xpath.dom.get_by_attribute(xpath.search_order[1].lexeme)
			}
		} else {
			xpath.found_tags << xpath.dom.get_root()
			xpath.search_childrens(xpath.search_order[1].lexeme, xpath.search_order[1].class)
		}
		for index := 3; index < xpath.search_order.len; index += 2 {
			if xpath.search_order[index - 1].class == .absolute_path {
				println('Search by absolute path')
			}
		}
	}
	for item in xpath.search_order {
		println(item)
	}
	return xpath.found_tags
}
