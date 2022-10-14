# json_pointer
A Ruby implementation of RFC 6901: JavaScript Object Notation (JSON) Pointer

# Usage
## Evaluate
The `JSONPointer` class represents a JSON pointer that can be evaluated against any *parsed* JSON document (a Ruby `Hash`, `Array`, `String`, etc):
```ruby
foo = JSONPointer.new("/foo")
object = {
  "foo" => "Hello, world!"
}
object2 = {
  "foo" => 3.14
}

assert_equal "Hello, world!", foo.evaluate(object)
assert_equal 3.14, foo.evaluate(object2)
```
