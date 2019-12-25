module v_html

enum SearchType {
	absolute_path /* '/' */
	all_document /* '/ /' */
	unknown /* '*' */
	position  /* '[number]' */
	last  /* '[last()]' */
	has  /* '[identifier]' */ /* 'name' - @attribute | element */
	has_compare  /* '[element_name=value]' */
	multiple_path  /* '|' */
	attribute /* '@attribute' */
	element /* 'element_name' */
	has_attribute  /* '[@*]' */
}

struct Token {
	lexeme string
	class SearchType
}

struct XPath {
mut:
	dom DocumentObjectModel
	search_order []Token
}

fn (xpath mut XPath) set_dom(dom DocumentObjectModel) {
	xpath.dom = dom
}

fn classify_has(value string) SearchType {
	if value.len > 0 && value[0] >= 48 && value[0] <= 57 {
		return .position
	} else if value.len > 0 && value == "last()" {
		return .last
	} else if value.len > 0 && value == "@*" {
		return .has_attribute
	} else if value.len > 0 && value[0] == 64 /*@*/ {
		return .attribute
	} // now verify if has = and return element or has_compare
	return .element
}

fn classify_identifier(value string) SearchType {
	if value.len > 0 && value[0] == 42/*'*'*/ {
		return .unknown
	} else if value.len > 0 && value[0] == 64 /*@*/ {
		return .attribute
	}
	return .element
}

fn (xpath mut XPath) how_search(queue string) {
	xpath.search_order = []
	mut search_type := 0
	mut opened_has := false
	mut lexeme := ""
	for word in queue {
		if opened_has && word == 93 {
			if lexeme.len > 0 { xpath.search_order << Token{lexeme: lexeme, class: classify_has(lexeme)} }
			opened_has = false
			lexeme = ""
		/* 47 - '/'  91 - '['  32 - ' ' */
		} else if word != 47 && word != 91 && word != 32 {
			lexeme += word.str()
		} else {
			if word == 47 {
				search_type++
			}
			if lexeme.len > 0 && search_type > 0 && search_type <= 2 {
				search_enum := match search_type {
					1 { SearchType.absolute_path }
					else { .all_document }
				}
				xpath.search_order << Token{lexeme: "/", class: search_enum}
				xpath.search_order << Token{lexeme: lexeme, class: classify_identifier(lexeme)}
			}

			if word != 91 { opened_has = true }
			lexeme = ""
		}
	}
}

fn (xpath mut XPath) search(queue string) []Tag {
	xpath.how_search(queue)
	return []
}
