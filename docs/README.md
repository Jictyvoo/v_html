# V HTML

A HTML parser made in V

## Usage

If description below isn't enought, see test files

### Parser

**split_parse(data string)**
This functions is the main function called by parse method to fragment parse your HTML

**parse_html(data string, is_file bool)**
This function is called passing a filename or a complete html data string to it

### DocumentObjectModel

**get_by_attribute_value(name string, value string) []Tag**
This function retuns a Tag array with all tags in document that have a attribute with given name and given value

**get_by_tag(name string) []Tag**
This function retuns a Tag array with all tags in document that have a name with the given value

**get_by_attribute(name string) []Tag**
This function retuns a Tag array with all tags in document that have a attribute with given name

**get_root() Tag**
This function returns the root Tag

**get_all_tags() []Tag**
This function returns all important tags, removing close tags

**get_xpath() XPath**
This function returns a xpath based on it internal tree

### XPath

**search(queue string) []Tag**
returns a tag array based on queue string given to function (it searchs the elements in dom and it's btree)

## Some question that can appear

**Q: Why in parser have a `builder_str() string` method that returns only the lexeme string?**
    
A: Because in early stages of the project, strings.Builder are used, but for some bug existing somewhere, it was necessary to use string directly. Later, it's planned to use strings.Builder again

**Q: Why have a `compare_string(a string, b string) bool` method?**

A: For some reason when using != and == in strings directly, it not working. So, this method is a workaround

**Q: Why still have a defined main.v file?**

A: For debuging purposes

**Q: Why using a btree to store tags index in dom instead of adding childs directly in tags?**

A: Is a workaround, because to make it to be finish fast, use this method, to not worry with address manipulation and addresses. Maybe in future child tag arrays ([]&Tag) will be added again to be more easily to use

**Q: Will be something like `XPath`?**

A: Like XPath yes. Exactly equal to it, no.

## Roadmap
- [x] Parser
  - [x] `<!-- Comments -->` detection
  - [x] `Open Generic tags` detection
  - [x] `Close Generic tags` detection
  - [x] `verify string` detection
  - [x] `tag attributes` detection
  - [x] `attributes values` detection
  - [x] `tag text` (on tag it is declared as content, maybe change for text in the future)
  - [x] `text file for parse` support (open local files for parsing)
  - [x] `open_code` verification
  - [ ] fix parser with github html (have some weird things, dom is incorrect while removing things from it)
- [x] DocumentObjectModel
  - [x] push elements that have a close tag into stack
  - [x] remove elements from stack
  - [ ] add in btree info about who's the parent of the current node
  - [x] ~~create a new document root if have some syntax error (deleted)~~
  - [x] search tags in `DOM` by attributes
  - [x] search tags in `DOM` by tag type
  - [x] finish dom test
- [x] XPath
  - [ ] receive search string and identify what to search and when
  - [x] start search by root
  - [x] start search by tag name
  - [x] start search by attribute name
  - [x] get all tags from document
- [ ] Finish XPath search
- [ ] Maybe more

## License
[GPL3](LICENSE)
