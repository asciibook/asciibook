require 'test_helper'

class Asciibook::BookTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Asciibook::VERSION
  end
end
