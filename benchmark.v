module main

import html
import benchmark

fn main() {
	mut parser_average := i64(0)
	mut dom_average := i64(0)
	mut total := 0
	for counter := 0; counter < 100; counter++ {
		mut parser := html.Parser{}
		parser.add_code_tag('')
		mut b := benchmark.start()
		parser.parse_html('khwiki_test.html', true)
		parser_average += b.measure('parse file') // mut
		dom := parser.get_dom()
		for s_tag in dom.get_by_tag('script') {
			if s_tag.get_name() != 'script' {
				return
			}
		}
		dom_average += b.measure('generate dom')
		total++
	}
	println('Parse file - ${parser_average/(total)} ms')
	println('Generate DOM and print `<script>` tag names - ${dom_average/(total)} ms')
}
