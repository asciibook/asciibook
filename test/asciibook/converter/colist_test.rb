require 'test_helper'

class Asciibook::Converter::DlistTest < Asciibook::Test
  def test_convert_dlist
    doc = <<~EOF
      [source,ruby]
      ----
      require 'sinatra' <1>

      get '/hi' do <2> <3>
        "Hello World!"
      end
      ----
      <1> Library import
      <2> URL mapping
      <3> Response block
    EOF

    html = <<~EOF
    EOF

    assert_convert_body html, doc
  end
end
