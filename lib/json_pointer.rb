# frozen_string_literal: true

require_relative "json_pointer/version"

class JSONPointer
  PATTERN = /\/([^\/]*)/.freeze

  class SyntaxError < StandardError; end
  class ReferenceError < StandardError
    alias reference_token to_s
  end

  attr_reader :reference_tokens

  def initialize(str)
    if str.start_with? '/'
      @reference_tokens = str.scan(PATTERN).map! { |(reference_token)|
        decode!(reference_token)
      }
    elsif str.empty?
      @reference_tokens = []
    else
      raise SyntaxError.new(str)
    end
    @str = str
  end

  def evaluate(document)
    @reference_tokens.reduce(document) do |value, reference_token|
      case value
      when Hash
        value.fetch(reference_token) {
          raise ReferenceError.new(reference_token)
        }
      when Array
        if reference_token.length > 1 &&
           reference_token.start_with?('0')
          raise ReferenceError.new(reference_token)
        end
        array_index = begin
          Integer(reference_token, 10)
        rescue
          raise ReferenceError.new(reference_token)
        end
        value.fetch(array_index) {
          raise ReferenceError.new(reference_token)
        }
      else
        # There's a reference token for something other
        # than an array or an object.
        raise ReferenceError.new(reference_token)
      end
    end
  end
  
  def to_s
    @str
  end

  def ==(other)
    self.class === other && @str == other.to_s
  end

  alias eql? ==

  def hash
    @str.hash
  end

  protected

  def decode!(reference_token)
    reference_token.gsub!('~1', '/')
    reference_token.gsub!('~0', '~')
    reference_token
  end
end
