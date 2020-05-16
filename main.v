module main

// import net.http
import os
import html

/*
#flag -O3
#flag --save-temps
*/
fn main() {
	/*
	println("Fetching myanimelist data")
        resp := http.get('https://myanimelist.net/manga.php') or {
                println('failed to fetch data from the server')
                return
        }
        println("Finalized fetching, start parsing")
	*/
	d_file := os.create('debug.log') or {
		eprintln('failed to read the file')
		return
	}
	mut parser := html.Parser{
		debug_file: d_file
	}
	parser.add_code_tag('')
	parser.parse_html('github_test.html', true)
	mut dom := parser.get_dom()
	mut result := dom.get_by_attribute_value('class', 'select-menu-item width-full')
	/*for index := 0; index < result.len; index++ {
		println(result[index])
	}
	result = dom.get_by_tag('form')
	for index := 0; index < result.len; index++ {
		println(result[index])
	}*/
	mut xpath := parser.get_xpath()
	found_search := xpath.search('/catalog/cd/price[last = 0]')
	for found in found_search {
		println(found)
	}
}
