module v_html

import os
import strings

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
		line_count int = 0
		lexeme_builder strings.Builder
		code_tags map[string]bool = {"script": true, "style": true}
}

pub struct Parser {
	mut:
		close_tags []string = ["/!document"]
		lexycal_attributes LexycalAttributes = LexycalAttributes{lexeme_builder: strings.new_builder(1)}
		filename string = "direct-parse"
		tags []Tag
}

pub fn (parser mut Parser) verify_end_comment(remove bool) bool {
	mut lexeme_builder := parser.lexycal_attributes.lexeme_builder
	lexeme := lexeme_builder.str()
    last := lexeme[lexeme.len - 1]
    penultimate := lexeme[lexeme.len - 2]
    mut is_end_comment := false
    if last.str() == "-" && penultimate.str() == "-" {
        is_end_comment = true
    }
    if is_end_comment && remove {
        lexeme_builder.len -= 2
    }
    return is_end_comment
}

pub fn (parser mut Parser) split_parse(data string) {
	for word in data {
		//println("Current word: " + parser.lexycal_attributes.line_count.str())
		parser.lexycal_attributes.line_count += 1
		mut is_quotation := false
		if word == 34 || word == 39 {is_quotation = true} // " or '
		string_code := match word {
			34 { 1 } //"
			39 { 2 } //'
			else { 0 }
		}
		if parser.lexycal_attributes.open_comment {
			if word == 62 { //close tag '>
				if parser.lexycal_attributes.open_comment && parser.verify_end_comment(true) {
					//println(parser.lexycal_attributes.lexeme_builder.str())
					parser.lexycal_attributes.lexeme_builder = strings.new_builder(1) //strings.Builder{}
					parser.lexycal_attributes.open_comment = false
					parser.lexycal_attributes.open_tag = false
				} else {
					parser.lexycal_attributes.lexeme_builder.write(word.str())
				}
			}
		} else if parser.lexycal_attributes.open_string > 0 {
			if parser.lexycal_attributes.open_string == string_code {
				parser.lexycal_attributes.open_string = 0
				temp_lexeme := parser.lexycal_attributes.lexeme_builder.str()
				if parser.lexycal_attributes.current_tag.last_attribute != "" {
					parser.lexycal_attributes.current_tag.attributes[parser.lexycal_attributes.current_tag.last_attribute] = temp_lexeme
				}
				parser.lexycal_attributes.lexeme_builder = strings.new_builder(1)
			} else {
				parser.lexycal_attributes.lexeme_builder.write(word.str())
			}
		} else if parser.lexycal_attributes.open_tag {
			if parser.lexycal_attributes.lexeme_builder.len == 0 && is_quotation {
				parser.lexycal_attributes.open_string = string_code
			} else if word == 62 { // close tag >
				parser.lexycal_attributes.current_tag.attributes[parser.lexycal_attributes.lexeme_builder.str()] = ""
				parser.lexycal_attributes.open_tag = false
				parser.lexycal_attributes.lexeme_builder = strings.new_builder(1)
			} else if word != 9 && word != 32 && word != 61 { // Tab, space and =
				parser.lexycal_attributes.lexeme_builder.write(word.str())
				//println(parser.lexycal_attributes.lexeme_builder.str() + " - " + parser.lexycal_attributes.lexeme_builder.len.str())
			} else {
				if parser.lexycal_attributes.current_tag.name == "" {
					parser.lexycal_attributes.current_tag.name = parser.lexycal_attributes.lexeme_builder.str()
				} else {
					parser.lexycal_attributes.current_tag.attributes[parser.lexycal_attributes.lexeme_builder.str()] = ""
					parser.lexycal_attributes.current_tag.last_attribute = "" 
					if word == 61 { // if was a =
						parser.lexycal_attributes.current_tag.last_attribute = parser.lexycal_attributes.lexeme_builder.str()
					}
				}
				parser.lexycal_attributes.lexeme_builder = strings.new_builder(1) //strings.Builder{}
			}
			if parser.lexycal_attributes.lexeme_builder.str() == "!--" { parser.lexycal_attributes.open_comment = true }
		} else if word == 60 { //open tag '<'
			mut tags := []Tag//parser.tags
			if parser.lexycal_attributes.lexeme_builder.len > 1 {
				tags << Tag{content: parser.lexycal_attributes.lexeme_builder.str()}
			}
			parser.lexycal_attributes.lexeme_builder = strings.new_builder(1)
			parser.lexycal_attributes.current_tag = Tag{}
			tags << parser.lexycal_attributes.current_tag
			parser.lexycal_attributes.open_tag = true
		} else {
			parser.lexycal_attributes.lexeme_builder.write(word.str())
		}
	}
}

pub fn (parser mut Parser) parse_html(data string, is_file bool) {
	if is_file {
		text := os.read_file(data) or {
			eprintln('failed to read the file $data')
			return
		}
		lines := text.split_into_lines()
		for line in lines {
			parser.split_parse(line)
		}
	} else {
		parser.split_parse(data)
	}
}
