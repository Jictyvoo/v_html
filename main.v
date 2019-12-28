module main

//import http
import os
import v_html
fn main() {
	/*println("Fetching myanimelist data")
	resp := http.get('https://myanimelist.net/manga.php') or {
		println('failed to fetch data from the server')
		return
	}
	println("Finalized fetching, start parsing")*/
	d_file := os.create("debug.log") or {eprintln('failed to read the file') return}
	mut parser := v_html.Parser{debug_file: d_file}
	parser.add_code_tag("")
	parser.parse_html("github_test.html", true)
	mut xpath := v_html.XPath{}
	xpath.set_dom(parser.get_dom())
	xpath.search("/catalog/cd/price")
}
