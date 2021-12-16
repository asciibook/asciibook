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
    assert File.read(fixture_path('example/build/html/index.html')).include?('Custom Theme')
  end

  def test_build_with_custom_template
    Asciibook::Command.execute %W(build #{fixture_path('example/source.adoc')} --format html --template-dir #{fixture_path('templates')})
    assert File.read(fixture_path('example/build/html/index.html')).include?('overwrite')
  end

  def test_build_with_custom_dest
    Asciibook::Command.execute %W(build #{fixture_path('example/source.adoc')} --format html --dest-dir #{fixture_path('example/tmp/build')})
    assert Dir.exist?(fixture_path('example/tmp/build'))
  end

  def test_build_with_page_level
    Asciibook::Command.execute %W(build #{fixture_path('example/source.adoc')} --format html --page-level 0)
    assert_equal 1, Dir.glob('*.html', base: fixture_path('example/build/html')).count
  end

  def test_build_with_config_file
    Dir.mktmpdir do |dir|
      FileUtils.touch File.join(dir, 'test.adoc')
      File.open(File.join(dir, 'asciibook.yml'), 'w') do |file|
        file.write <<~EOF
          source: test.adoc
          formats: ['html']
        EOF
      end
      Asciibook::Command.execute %W(build #{dir})
      assert Dir.exist?(File.join(dir, 'build/html'))
      assert !Dir.exist?(File.join(dir, 'build/pdf'))
    end
  end

  def test_init_config
    Dir.mktmpdir do |dir|
      FileUtils.touch File.join(dir, 'test.adoc')
      Asciibook::Command.execute %W(init #{File.join(dir, 'test.adoc')})
      assert File.exist?(File.join(dir, 'asciibook.yml'))
      assert_equal <<~EOF, File.read(File.join(dir, 'asciibook.yml'))
        source: test.adoc
        #formats: ['html', 'pdf', 'epub', 'mobi']
        #theme_dir:
        #template_dir:
        #page_level: 1
      EOF
    end
  end

  def test_new_book
    Dir.mktmpdir do |dir|
      Asciibook::Command.execute %W(new #{dir})
      assert File.exist?(File.join(dir, 'book.adoc'))
      assert File.exist?(File.join(dir, 'asciibook.yml'))
    end
  end
end
