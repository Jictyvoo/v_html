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

### Q: Why when printing a tag that doesn't have it's version closed the close tag appear in print? like </!DOCTYPE>

    A: Because tag itself doesn't know if it need to have a close tag or not, so every tag has it (only during print)

### Q: Why don't have a defined test file yet?

    A: Because all tests are done in debug file and code still have some bugs to be solved until test files start to be created

## To-do

* Finish open_code verification
* Verify if code blocks are being verified and read all script and style code
* Add closed_tag verification to dom generator again
* Discover why tag.add_children(tag) doesn't work normally
* Improve default search in dom
* Add test file to test all public functions
* Test parser with github html (have some weird things)
* Maybe more
