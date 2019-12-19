# V HTML

A HTML parser made in V

## Usage

If description below isn't enought, see test files

### split_parse(data string)

This functions is the main function called by parse method to fragment parse your HTML

### parse_html(data string, is_file bool)

This function is called passing a filename or a complete html data string to it

## Some question that can appear

**Q: Why in parser have a `builder_str() string` method that returns only the lexeme string?**
    
A: Because in early stages of the project, strings.Builder are used, but for some bug existing somewhere, it was necessary to use string directly. Later, it's planned to use strings.Builder again

**Q: Why have a `compare_string(a string, b string) bool` method?**

A: For some reason when using != and == in strings directly, it not working. So, this method is a workaround

**Q: Why still have a defined main.v file?**

A: For debuging purposes

**Q: Why using a btree to store tags index in dom instead of adding childs directly in tags?**

A: Is a workaround, because to make it to be finish fast, use this method, to not worry with address manipulation and addresses. Maybe in future child tag arrays ([]&Tag) will be added again to be more easily to use

**Q: Will be like `XPath` in future?**

A: Maybe... But before that, the basic dom search need to be finished and improved

## To-do

* Improve default search in dom
* Finish dom test
* Fix parser with github html (have some weird things, dom is incorrect while removing things from it)
* In other branch, try to use add_child with tag address
* Maybe more

### Need verification

* None for now

## Done

### Parser

* Comments
* Open Generic tags
* Close Generic tags
* verify string
* tag attributes
* attributes values
* tag text (on tag it is declared as content, maybe change for text in the future)
* text file for parse
* open_code verification

### DocumentObjectModel

* push elements that have a close tag into stack
* remove elements from stack
* create a new document root if have some syntax error
* search tags in B-tree by attributes
* search tags in B-tree by tag type
