module main

// import net.http
import os
import html
import benchmark

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
	mut b := benchmark.start()
	parser.parse_html('github_test.html', true)
	b.measure('parse file')
	/*mut dom := */parser.get_dom()
	b.measure('generate dom')
	/*for s_tag in dom.get_by_tag("script") {
		println(s_tag)
	}*/
	//println(dom.get_by_attribute_value("id", "doenca_abc")[0].text())
	
	mut xpath := parser.get_xpath()
	found_search := xpath.search('/catalog/cd/price[last = 0]')
	for found in found_search {
		println(found)
	}
}
