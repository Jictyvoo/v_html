import v_html

fn test_split_parse() {
	mut parser := v_html.Parser{}
	parser.add_code_tag("")
	parser.split_parse("<!doctype htm")
	parser.split_parse("l public")
	parser.split_parse("><html><he")
	parser.split_parse("ad><t")
	parser.split_parse("itle> Hum... ")
	parser.split_parse("A Tit")
	parser.split_parse("\nle</ti\ntle>")
	parser.split_parse("</\nhead><body>\t\t\t<h3>")
	parser.split_parse("Nice Test!</h3>")
	parser.split_parse("</bo\n\n\ndy></html>")
	parser.finalize()
}
