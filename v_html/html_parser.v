module v_html

import os

enum TokenType {
	html_string tag open_tag close_tag open_comment close_comment
}

struct Tag {
	pub mut:
		name string = ""
		attributes map[string]string /*attributes will be like map[name]value*/
		last_attribute string = ""
		content string = ""
		children []Tag
}

struct LexycalAttributes {
	mut:
		current_tag Tag
		open_tag bool = false
		open_code bool = false
		open_string int = 0
		open_comment bool = false
		is_attribute bool = false
		opened_code_type string = ""
		line_count int = 0
		lexeme_builder string
		code_tags map[string]bool = {"script": true, "style": true}
}

fn (lxa mut LexycalAttributes) write_lexeme(data string) {
	mut temp := lxa.lexeme_builder
	temp += data
	lxa.lexeme_builder = temp
}

pub struct Parser {
	mut:
		close_tags []string = ["/!document"]
		lexycal_attributes LexycalAttributes = LexycalAttributes{}
		filename string = "direct-parse"
		tags []Tag
		debug_file os.File
}

fn (parser Parser) builder_str() string {
	return parser.lexycal_attributes.lexeme_builder
}

pub fn (parser mut Parser) verify_end_comment(remove bool) bool {
	lexeme := parser.builder_str()
    last := lexeme[lexeme.len - 1]
    penultimate := lexeme[lexeme.len - 2]
    mut is_end_comment := false
    if last.str() == "-" && penultimate.str() == "-" {
        is_end_comment = true
    }
    if is_end_comment && remove {
        temp := parser.lexycal_attributes.lexeme_builder
		parser.lexycal_attributes.lexeme_builder = temp[0 .. temp.len - 2]
    }
    return is_end_comment
}

pub fn (parser mut Parser) split_parse(data string) {
	for word in data {
		parser.lexycal_attributes.line_count += 1
		mut is_quotation := false
		if word == 34 || word == 39 {is_quotation = true} // " or '
		string_code := match word {
			34 { 1 } //"
			39 { 2 } //'
			else { 0 }
		}
		if parser.lexycal_attributes.open_code {
			//here will verify all needed to know if open_code finishes and string in code
		} else if parser.lexycal_attributes.open_comment {
			if word == 62 { //close tag '>
				if parser.lexycal_attributes.open_comment && parser.verify_end_comment(true) {
					parser.lexycal_attributes.lexeme_builder = "" //strings.Builder{}
					parser.lexycal_attributes.open_comment = false
					parser.lexycal_attributes.open_tag = false
				} else {
					parser.lexycal_attributes.write_lexeme(word.str())
				}
			}
		} else if parser.lexycal_attributes.open_string > 0 {
			if parser.lexycal_attributes.open_string == string_code {
				parser.lexycal_attributes.open_string = 0
				temp_lexeme := parser.builder_str()
				if parser.lexycal_attributes.current_tag.last_attribute != "" {
					parser.lexycal_attributes.current_tag.attributes[parser.lexycal_attributes.current_tag.last_attribute] = temp_lexeme
					parser.lexycal_attributes.current_tag.last_attribute = ""
				}
				parser.lexycal_attributes.lexeme_builder = ""
			} else {
				parser.lexycal_attributes.write_lexeme(word.str())
			}
		} else if parser.lexycal_attributes.open_tag {
			if parser.lexycal_attributes.lexeme_builder.len == 0 && is_quotation {
				parser.lexycal_attributes.open_string = string_code
			} else if word == 62 { // close tag >
				parser.debug_file.writeln(parser.builder_str())
				assert parser.builder_str() == parser.builder_str()
				parser.lexycal_attributes.current_tag.attributes[parser.builder_str()] = ""
				parser.lexycal_attributes.open_tag = false
				parser.lexycal_attributes.lexeme_builder = ""
			} else if word != 9 && word != 32 && word != 61 { // Tab, space and =
				parser.lexycal_attributes.write_lexeme(word.str())
			} else {
				if parser.lexycal_attributes.current_tag.name == "" {
					parser.lexycal_attributes.current_tag.name = parser.builder_str()
					if parser.lexycal_attributes.code_tags[parser.lexycal_attributes.current_tag.name] {
						parser.lexycal_attributes.open_code = true
						parser.lexycal_attributes.opened_code_type = parser.lexycal_attributes.current_tag.name
					} 
				} else {
					parser.lexycal_attributes.current_tag.attributes[parser.builder_str()] = ""
					parser.lexycal_attributes.current_tag.last_attribute = "" 
					if word == 61 { // if was a =
						parser.lexycal_attributes.current_tag.last_attribute = parser.builder_str()
					}
				}
				parser.lexycal_attributes.lexeme_builder = "" //strings.Builder{}
			}
			if parser.builder_str() == "!--" { parser.lexycal_attributes.open_comment = true }
		} else if word == 60 { //open tag '<'
			mut tags := parser.tags //[]Tag//
			if parser.lexycal_attributes.lexeme_builder.len >= 1 {
				tags << Tag{content: parser.builder_str()} //verify later who has this content
			}
			parser.lexycal_attributes.lexeme_builder = ""
			parser.lexycal_attributes.current_tag = Tag{}
			tags << parser.lexycal_attributes.current_tag
			parser.tags = tags
			parser.lexycal_attributes.open_tag = true
		} else {
			parser.lexycal_attributes.write_lexeme(word.str())
		}
	}
}

pub fn (parser mut Parser) parse_html(data string, is_file bool) {
	if is_file {
		lines := os.read_lines(data) or {
			eprintln('failed to read the file $data')
			return
		}
		for line in lines {
			parser.split_parse(line)
		}
	} else {
		parser.split_parse(data)
	}
}
