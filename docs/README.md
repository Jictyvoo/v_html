# V HTML

A HTML parser made in V

## Usage

### split_parse(data string)

This functions is the main function called by parse method to fragment parse your HTML

### parse_html(data string, is_file bool)

This function is called passing a filename or a complete html data string to it

## Some question that can appear

### Q: Why in parser have a `builder_str() string` method that returns only the lexeme string?
    
    A: Because in early stages of the project, strings.Builder are used, but for some bug existing somewhere, it was necessary to use string directly. Later, it's planned to use strings.Builder again

### Q: Why have a `compare_string(a string, b string) bool` method?

    A: For some reason when using != and == in strings directly, it not working. So, this method is a workaround

### Q: Why when printing a tag that doesn't have it's version closed the close tag appear in print? like </!DOCTYPE>

    A: Because tag itself doesn't know if it need to have a close tag or not, so every tag has it (only during print)

### Q: Why don't have a defined test file yet?

    A: Because all tests are done in debug file and code still have some bugs to be solved until test files start to be created

## To-do

* Remove `temp_tag` from dom.v, currently only is used for debug purposes
* Improve default search in dom
* Add test file to test all public functions
* Test parser with github html (have some weird things, dom is incorrect while removing things from it)
* Maybe more

### Need verification

* Finish open_code verification
* Verify if code blocks are being verified and read all script and style code
* Add closed_tag verification to dom generator again (Doesn't need, because all tags are classified as closed)
* Discover why tag.add_children(tag) doesn't work normally (Now works in debug file, but get_dom still doesn't. Problem was array must to be mut)

## Done

### Parser

* Comments
* Open Generic tags
* Close Generic tags
* verify string
* tag attributes
* attributes values
* tag text (on tag it is declared as content, maybe change for text in the future)

### DocumentObjectModel

* push elements that have a close tag into stack
* remove elements from stack
* create a new document root if have some syntax error
* search tags in B-tree by attributes
* search tags in B-tree by tag type
