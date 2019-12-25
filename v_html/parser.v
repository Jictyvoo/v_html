module v_html

import os

struct LexycalAttributes {
mut:
	current_tag      Tag
	open_tag         bool=false
	open_code        bool=false
	open_string      int=0
	open_comment     bool=false
	is_attribute     bool=false
	opened_code_type string=''
	line_count       int=0
	lexeme_builder   string
	code_tags        map[string]bool={
		'script': true,
		'style': true
	}
}

fn (lxa mut LexycalAttributes) write_lexeme(data string) {
	mut temp := lxa.lexeme_builder
	temp += data
	lxa.lexeme_builder = temp
}

pub struct Parser {
mut:
	dom                DocumentObjectModel
	lexycal_attributes LexycalAttributes=LexycalAttributes{
	}
	filename           string='direct-parse'
	initialized        bool=false
	tags               []Tag
	debug_file         os.File
}

pub fn (parser mut Parser) add_code_tag(name string) {
	if parser.lexycal_attributes.code_tags.keys().len <= 0 {
		parser.lexycal_attributes.code_tags = map[string]bool
		parser.lexycal_attributes.code_tags['script'] = true
		parser.lexycal_attributes.code_tags['style'] = true
	}
	if name.len > 0 {
		parser.lexycal_attributes.code_tags[name] = true
	}
}

fn (parser Parser) builder_str() string {
	return parser.lexycal_attributes.lexeme_builder.to_lower()
}

fn (parser mut Parser) print_debug(data string) {
	$if debug {
		if data.len > 0 {
			parser.debug_file.writeln(data)
		}
	}
}

fn (parser mut Parser) verify_end_comment(remove bool) bool {
	lexeme := parser.builder_str()
	last := lexeme[lexeme.len - 1]
	penultimate := lexeme[lexeme.len - 2]
	mut is_end_comment := false
	if last.str() == '-' && penultimate.str() == '-' {
		is_end_comment = true
	}
	if is_end_comment && remove {
		temp := parser.lexycal_attributes.lexeme_builder
		parser.lexycal_attributes.lexeme_builder = temp[0..temp.len - 2]
	}
	return is_end_comment
}

fn compare_end_string(first string, second string) bool {
	mut big := first
	mut small := second
	if second.len > big.len {
		big = second
		small = first
	}
	for index := 0; index < small.len; index++ {
		if small[index] != big[big.len - small.len + index] {
			return false
		}
	}
	return true
}

fn blank_string(data string) bool {
	mut count := 0
	for word in data {
		if word == 9 || word == 32 {
			count++
		}
	}
	return count == data.len
}

fn (parser mut Parser) initialize_all() {
	parser.dom = DocumentObjectModel{
	}
	parser.add_code_tag('')
	parser.dom.close_tags['/!document'] = true
	parser.lexycal_attributes.current_tag = Tag{
	}
	parser.initialized = true
}

fn (parser mut Parser) generate_tag() {
	if !parser.lexycal_attributes.open_tag {
		if parser.lexycal_attributes.current_tag.name.len > 0 || parser.lexycal_attributes.current_tag.content.len > 0 {
			parser.tags << parser.lexycal_attributes.current_tag
		}
		parser.lexycal_attributes.current_tag = Tag{}
	}
}

pub fn (parser mut Parser) split_parse(data string) {
	if !parser.initialized {
		parser.initialize_all()
	}
	for word in data {
		mut is_quotation := false
		/* " or ' */
		if word == 34 || word == 39 {
			is_quotation = true
		}

		string_code := match word {
			34{
				1
			}/*"*/

			39{
				2
			}/*'*/

			else {
				0}}
		if parser.lexycal_attributes.open_code {
			/*here will verify all needed to know if open_code finishes and string in code*/
			parser.lexycal_attributes.write_lexeme(word.str())
			if parser.lexycal_attributes.open_string > 0 {
				if parser.lexycal_attributes.open_string == string_code {
					parser.lexycal_attributes.open_string = 0
				}
			}
			else if is_quotation {
				parser.lexycal_attributes.open_string = string_code
			}
			else if word == 62 {
				/*only execute verification if is a >*/

				/* here will verify < to know if code tag is finished*/
				name_close_tag := '</' + parser.lexycal_attributes.opened_code_type + '>'
				temp_string := parser.builder_str()
				if compare_end_string(temp_string, name_close_tag) {
					parser.lexycal_attributes.open_code = false
					/* need to modify lexeme_builder to add script text as a content in next loop (not gave error in dom)*/

					parser.lexycal_attributes.lexeme_builder = temp_string[0..temp_string.len - name_close_tag.len]
					parser.lexycal_attributes.current_tag.closed = true
				}
			}
		}
		else if parser.lexycal_attributes.open_comment {
			/*close tag '>*/
			if word == 62 && parser.verify_end_comment(false) {
				/*parser.print_debug(parser.builder_str() + " >> " + parser.lexycal_attributes.line_count.str())*/
				parser.lexycal_attributes.lexeme_builder = ''/*strings.Builder{}*/

				parser.lexycal_attributes.open_comment = false
				parser.lexycal_attributes.open_tag = false
			}
			else {
				parser.lexycal_attributes.write_lexeme(word.str())
			}
		}
		else if parser.lexycal_attributes.open_string > 0 {
			if parser.lexycal_attributes.open_string == string_code {
				parser.lexycal_attributes.open_string = 0
				parser.lexycal_attributes.write_lexeme(word.str())
				temp_lexeme := parser.builder_str()
				if parser.lexycal_attributes.current_tag.last_attribute != '' {
					parser.lexycal_attributes.current_tag.attributes[parser.lexycal_attributes.current_tag.last_attribute] = temp_lexeme
					/*parser.print_debug(parser.lexycal_attributes.current_tag.last_attribute + " = " + temp_lexeme)*/

					parser.lexycal_attributes.current_tag.last_attribute = ''
				}
				else {
					parser.lexycal_attributes.current_tag.attributes[temp_lexeme] = ''
					/*parser.print_debug(temp_lexeme)*/

				}
				parser.lexycal_attributes.lexeme_builder = ''
			}
			else {
				parser.lexycal_attributes.write_lexeme(word.str())
			}
		}
		else if parser.lexycal_attributes.open_tag {
			if parser.lexycal_attributes.lexeme_builder.len == 0 && is_quotation {
				parser.lexycal_attributes.open_string = string_code
				parser.lexycal_attributes.write_lexeme(word.str())
			}
			/* close tag > */
			else if word == 62 {
				complete_lexeme := parser.builder_str()
				parser.lexycal_attributes.current_tag.closed = (complete_lexeme.len > 0 && complete_lexeme[complete_lexeme.len - 1] == 47)
				/* if equals to / */
				if complete_lexeme.len > 0 && complete_lexeme[0] == 47 {
					parser.dom.close_tags[complete_lexeme] = true
				}
				/*else if complete_lexeme.len > 0 && complete_lexeme[complete_lexeme.len - 1] == 47 { // if end tag like "/>"
					parser.lexycal_attributes.current_tag.closed = true
				}*/

				if parser.lexycal_attributes.current_tag.name == '' {
					parser.lexycal_attributes.current_tag.name = complete_lexeme
				}
				else if complete_lexeme != '/' {
					parser.lexycal_attributes.current_tag.attributes[complete_lexeme] = ''
				}
				parser.lexycal_attributes.open_tag = false
				parser.lexycal_attributes.lexeme_builder = ''
				/* if tag name is code*/
				if parser.lexycal_attributes.current_tag.name in parser.lexycal_attributes.code_tags {
					parser.lexycal_attributes.open_code = true
					parser.lexycal_attributes.opened_code_type = parser.lexycal_attributes.current_tag.name
				}
				/*parser.print_debug(parser.lexycal_attributes.current_tag.name)*/

			}
			/* Tab, space, = and \n */
			else if word != 9 && word != 32 && word != 61 && word != 10 {
				parser.lexycal_attributes.write_lexeme(word.str())
			}
			else if word != 10 {
				complete_lexeme := parser.builder_str()
				if parser.lexycal_attributes.current_tag.name == '' {
					parser.lexycal_attributes.current_tag.name = complete_lexeme
				}
				else {
					parser.lexycal_attributes.current_tag.attributes[complete_lexeme] = ''
					parser.lexycal_attributes.current_tag.last_attribute = ''
					if word == 61 {
						/* if was a = */
						parser.lexycal_attributes.current_tag.last_attribute = complete_lexeme
					}
				}
				parser.lexycal_attributes.lexeme_builder = ''/*strings.Builder{}*/

			}
			if parser.builder_str() == '!--' {
				parser.lexycal_attributes.open_comment = true
			}
		}
		else if word == 60 {
			/*open tag '<'*/
			temp_string := parser.builder_str()
			if parser.lexycal_attributes.lexeme_builder.len >= 1 {
				if parser.lexycal_attributes.current_tag.name.len > 1 && parser.lexycal_attributes.current_tag.name[0] == 47 && !blank_string(temp_string) {
					parser.tags << Tag{
						name: 'text'
						content: temp_string
					}
				}
				else {
					parser.lexycal_attributes.current_tag.content = temp_string/*verify later who has this content*/

				}
			}
			/*parser.print_debug(parser.lexycal_attributes.current_tag.str())*/

			parser.lexycal_attributes.lexeme_builder = ''
			parser.generate_tag()
			parser.lexycal_attributes.open_tag = true
		}
		else {
			parser.lexycal_attributes.write_lexeme(word.str())
		}
	}
}

pub fn (parser mut Parser) parse_html(data string, is_file bool) {
	if !parser.initialized {
		parser.initialize_all()
	}
	mut lines := []string
	if is_file {
		file_lines := os.read_lines(data) or {
			eprintln('failed to read the file $data')
			return
		}
		lines = file_lines
	}
	else {
		lines = data.split_into_lines()
	}
	for line in lines {
		parser.lexycal_attributes.line_count++
		parser.split_parse(line)
	}
	parser.generate_tag()
	parser.dom.debug_file = parser.debug_file
	parser.dom.construct(parser.tags)
	/*println(parser.close_tags.keys())*/

}

pub fn (parser mut Parser) finalize() {
	parser.generate_tag()
}

pub fn (parser Parser) get_tags() []Tag {
	return parser.tags
}

pub fn (parser mut Parser) get_dom() DocumentObjectModel {
	if !parser.dom.constructed {
		parser.generate_tag()
		parser.dom.construct(parser.tags)
	}
	return parser.dom
}
