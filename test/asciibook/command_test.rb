require 'test_helper'
require 'asciibook/command'

class Asciibook::CommandTest < Asciibook::Test
  def setup
    FileUtils.rm_rf fixture_path('example/build')
  end

  def test_build_format
    Asciibook::Command.execute %W(build #{fixture_path('example/source.adoc')} --format html)
    assert Dir.exist?(fixture_path('example/build/html'))
    assert !Dir.exist?(fixture_path('example/build/pdf'))
  end

  def test_build_with_custom_theme
    Asciibook::Command.execute %W(build #{fixture_path('example/source.adoc')} --format html --theme-dir #{fixture_path('theme')})
    assert Dir.exist?(fixture_path('example/build'))
    assert File.read(fixture_path('example/build/html/index.html')).include?('Custom Theme')
  end

  def test_build_with_custom_dest
    Asciibook::Command.execute %W(build #{fixture_path('example/source.adoc')} --format html --dest-dir #{fixture_path('example/tmp/build')})
    assert Dir.exist?(fixture_path('example/tmp/build'))
  end

  def test_build_with_page_level
    Asciibook::Command.execute %W(build #{fixture_path('example/source.adoc')} --format html --page-level 0)
    assert_equal 1, Dir.glob('*.html', base: fixture_path('example/build/html')).count
  end
end
