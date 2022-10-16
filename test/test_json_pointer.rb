require "minitest/autorun"
require "json_pointer"

class JSONPointerTest < Minitest::Test
  def test_equality
    foo = JSONPointer.new("/foo")
    foo2 = JSONPointer.new("/foo")

    assert_equal foo, foo2
    assert_equal foo.hash, foo2.hash

    refute_equal foo, "/foo"
    refute_equal foo, ["foo"]
    refute_equal foo.hash, "/foo".hash
    refute_equal foo.hash, ["foo"].hash
  end

  def test_to_s
    assert_equal "/foo", JSONPointer.new("/foo").to_s
  end

  def test_reference_tokens
    assert_equal ["foo", "0", "bar", "-"], JSONPointer.new("/foo/0/bar/-").reference_tokens
    assert_equal [""], JSONPointer.new("/").reference_tokens
    assert_equal [], JSONPointer.new("").reference_tokens
  end

  def test_rfc6901
    # decoding substitution order
    assert_equal ["~1/0"], JSONPointer.new("/~01~10").reference_tokens

    # section 5
    document = {
      "foo" => ["bar", "baz"],
      "" => 0,
      "a/b" => 1,
      "c%d" => 2,
      "e^f" => 3,
      "g|h" => 4,
      "i\\j" => 5,
      "k\"l" => 6,
      " " => 7,
      "m~n" => 8
    }

    assert_equal document, JSONPointer.new("").evaluate(document)
    assert_equal ["bar", "baz"], JSONPointer.new("/foo").evaluate(document)
    assert_equal "bar", JSONPointer.new("/foo/0").evaluate(document)
    assert_equal 0, JSONPointer.new("/").evaluate(document)
    assert_equal 1, JSONPointer.new("/a~1b").evaluate(document)
    assert_equal 2, JSONPointer.new("/c%d").evaluate(document)
    assert_equal 3, JSONPointer.new("/e^f").evaluate(document)
    assert_equal 4, JSONPointer.new("/g|h").evaluate(document)
    assert_equal 5, JSONPointer.new("/i\\j").evaluate(document)
    assert_equal 6, JSONPointer.new("/k\"l").evaluate(document)
    assert_equal 7, JSONPointer.new("/ ").evaluate(document)
    assert_equal 8, JSONPointer.new("/m~0n").evaluate(document)
  end

  def test_values
    assert_equal({}, JSONPointer.new("/foo").evaluate({ "foo" => {} }))
    assert_equal [], JSONPointer.new("/foo").evaluate({ "foo" => [] })
    assert_equal "bar", JSONPointer.new("/foo").evaluate({ "foo" => "bar" })
    assert_equal 3.14, JSONPointer.new("/foo").evaluate({ "foo" => 3.14 })
    assert_equal true, JSONPointer.new("/foo").evaluate({ "foo" => true })
    assert_equal false, JSONPointer.new("/foo").evaluate({ "foo" => false })
    assert_nil JSONPointer.new("/foo").evaluate({ "foo" => nil })
  end

  def test_reuse
    json_pointer = JSONPointer.new("/foo")

    assert_equal 1, json_pointer.evaluate({ "foo" => 1 })
    assert_equal 2, json_pointer.evaluate({ "foo" => 2 })
  end

  def test_array_root
    document = [nil, "Hello, world!"]

    assert_equal "Hello, world!", JSONPointer.new("/1").evaluate(document)
  end

  def test_object_numeric_names
    document = {
      "0" => 1,
      "00" => 2,
      "01" => 3,
      "99999999999999999999999999999999999999999999999999999999999999" => 4
    }
    assert_equal 1, JSONPointer.new("/0").evaluate(document)
    assert_equal 2, JSONPointer.new("/00").evaluate(document)
    assert_equal 3, JSONPointer.new("/01").evaluate(document)
    assert_equal 4, JSONPointer.new("/99999999999999999999999999999999999999999999999999999999999999").evaluate(document)
  end

  def test_deeply_nested
    document = {
      "foo" => {
        "bar/" => [
          {
            "~baz" => "Hello, world!"
          }
        ]
      }
    }

    assert_equal "Hello, world!", JSONPointer.new("/foo/bar~1/0/~0baz").evaluate(document)
  end

  def test_repeat_empty_names
    document = {
      "" => {
        "" => {
         "" => "Hello, world!"
        }
      }
    }

    assert_equal "Hello, world!", JSONPointer.new("///").evaluate(document)
  end

  def test_syntax_errors
    assert_raises(JSONPointer::SyntaxError) { JSONPointer.new(" ") }
    assert_raises(JSONPointer::SyntaxError) { JSONPointer.new(" /") }
    assert_raises(JSONPointer::SyntaxError) { JSONPointer.new("0") }
    assert_raises(JSONPointer::SyntaxError) { JSONPointer.new("asdf/") }
  end

  def test_reference_errors
    document = {
      "foo" => "Hello, world!",
      "bar" => ["something something", "blah"]
    }

    # non-existent object name
    e = assert_raises(JSONPointer::ReferenceError) { JSONPointer.new("/asdf").evaluate(document) }
    assert_equal "asdf", e.reference_token

    # name reference on a string
    e = assert_raises(JSONPointer::ReferenceError) { JSONPointer.new("/foo/asdf").evaluate(document) }
    assert_equal "asdf", e.reference_token

    # name reference in array
    e = assert_raises(JSONPointer::ReferenceError) { JSONPointer.new("/bar/asdf").evaluate(document) }
    assert_equal "asdf", e.reference_token

    # malformed array index (zero)
    e = assert_raises(JSONPointer::ReferenceError) { JSONPointer.new("/bar/00").evaluate(document) }
    assert_equal "00", e.reference_token

    # malformed array index (non-zero)
    e = assert_raises(JSONPointer::ReferenceError) { JSONPointer.new("/bar/01").evaluate(document) }
    assert_equal "01", e.reference_token

    # non-existent array member
    e = assert_raises(JSONPointer::ReferenceError) { JSONPointer.new("/bar/2").evaluate(document) }
    assert_equal "2", e.reference_token
  end
end

