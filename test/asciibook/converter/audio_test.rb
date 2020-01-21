require 'test_helper'

class Asciibook::Converter::AudioTest < Asciibook::Test
  def test_convert_audio
    doc = <<~EOF
      audio::audio_file.mp3[]
    EOF

    html = <<~EOF
      <audio src="audio_file.mp3" controls="controls">
        <em>Sorry, the &lt;auido&gt; element not supported in your reading system.</em>
      </audio>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_audio_with_options
    doc = <<~EOF
      audio::audio_file.mp3[options="autoplay,loop"]
    EOF

    html = <<~EOF
      <audio src="audio_file.mp3" controls="controls" autoplay="autoplay" loop="loop">
        <em>Sorry, the &lt;auido&gt; element not supported in your reading system.</em>
      </audio>
    EOF

    assert_convert_body html, doc
  end
end
