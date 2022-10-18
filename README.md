# json\_pointer
A Ruby implementation of RFC 6901: JavaScript Object Notation (JSON) Pointer

## Usage
The `JSONPointer` class represents a JSON pointer that can be evaluated against any *parsed* JSON document (a Ruby `Hash`, `Array`, `String`, etc):

```ruby
foo = JSONPointer.new("/foo")
object = {
  "foo" => "Hello, world!"
}
object2 = {
  "foo" => 3.14
}
string = "something"

assert_equal "Hello, world!", foo.evaluate(object)
assert_equal 3.14, foo.evaluate(object2)
assert_same string, JSONPointer.new("").evaluate(string)
```

The decoded reference tokens can be accessed as an array:

```ruby
json_pointer = JSONPointer.new("/foo/0/~0/~1")
assert_equal ["foo", "0", "~",  "/"], json_pointer.reference_tokens
```

Unlike other JSON pointer gems, reference errors are raised to distinguish between actual null values and non-existent/bad references:

```ruby
object = {
  "foo" => nil
}

assert_nil JSONPointer.new("/foo").evaluate(object)

e = assert_raises(JSONPointer::ReferenceError) {
  JSONPointer.new("/bar").evaluate(object)
}
assert_equal "bar", e.reference_token
```
