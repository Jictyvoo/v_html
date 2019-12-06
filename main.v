module main
//import http
import v_html
fn main() {
	/*println("Fetching myanimelist data")
	resp := http.get('https://myanimelist.net/manga.php') or {
		println('failed to fetch data from the server')
		return
	}
	
	println("Finalized fetching, start parsing")
	parser.parse_html(resp.text, false)*/
	mut parser := v_html.Parser{}
	parser.parse_html("myanime_test.html", true)
	
}
//AnotherOne{builder:One{}}
