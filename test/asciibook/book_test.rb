require 'test_helper'

class Asciibook::BookTest < Asciibook::Test
  def test_build
    FileUtils.rm_rf fixture_path('example/build')
    Asciibook::Book.load_file(fixture_path('example/source.adoc')).build
    assert Dir.exist?(fixture_path('example/build'))
    assert Dir.exist?(fixture_path('example/build/html'))
    assert Dir.exist?(fixture_path('example/build/pdf'))
    assert File.exist?(fixture_path('example/build/pdf/source.pdf'))
    assert Dir.exist?(fixture_path('example/build/epub'))
    assert File.exist?(fixture_path('example/build/epub/source.epub'))
    assert Dir.exist?(fixture_path('example/build/mobi'))
    assert File.exist?(fixture_path('example/build/mobi/source.mobi'))
  end

  def test_build_only_html
    FileUtils.rm_rf fixture_path('example/build')
    Asciibook::Book.load_file(fixture_path('example/source.adoc'), formats: ['html']).build
    assert Dir.exist?(fixture_path('example/build'))
    assert Dir.exist?(fixture_path('example/build/html'))
    assert !Dir.exist?(fixture_path('example/build/pdf'))
    assert !Dir.exist?(fixture_path('example/build/epub'))
    assert !Dir.exist?(fixture_path('example/build/mobi'))
  end

  def test_build_with_custom_theme
    FileUtils.rm_rf fixture_path('example/build')
    Asciibook::Book.load_file(fixture_path('example/source.adoc'), formats: ['html'], theme_dir: fixture_path('theme')).build
    assert Dir.exist?(fixture_path('example/build'))
    assert File.read(fixture_path('example/build/html/index.html')).include?('Custom Theme')
  end

  def test_build_with_custom_dest
    FileUtils.rm_rf fixture_path('example/tmp/build')
    Asciibook::Book.load_file(fixture_path('example/source.adoc'), formats: ['html'], dest_dir: fixture_path('example/tmp/build')).build
    assert Dir.exist?(fixture_path('example/tmp/build'))
  end

  def test_that_it_has_a_version_number
    refute_nil ::Asciibook::VERSION
  end

  def test_pages_default
    adoc = <<~EOF
      = Book Name

      == Chapter 1

      === Chapter 1.1

      == Chapter 2
    EOF

    book = Asciibook::Book.new adoc
    book.process
    assert_equal 3, book.pages.count
    assert_equal 'Book Name', book.pages[0].title
    assert_equal 'Chapter 1', book.pages[1].title
    assert_equal 'Chapter 2', book.pages[2].title
  end

  def test_pages_level_2
    adoc = <<~EOF
      = Book Name

      == Chapter 1

      === Chapter 1.1

      == Chapter 2
    EOF

    book = Asciibook::Book.new(adoc, page_level: 2)
    book.process
    assert_equal 4, book.pages.count
    assert_equal 'Book Name', book.pages[0].title
    assert_equal 'Chapter 1', book.pages[1].title
    assert_equal 'Chapter 1.1', book.pages[2].title
    assert_equal 'Chapter 2', book.pages[3].title
  end

  def test_toc
    adoc = <<~EOF
      = Book Name

      == Chapter 1

      === Chapter 1.1

      == Chapter 2
    EOF

    book = Asciibook::Book.new(adoc)
    book.process
    assert_equal [
      {
        "title" => "Chapter 1",
        "path" => "_chapter_1.html",
        "items" => [
          {
            "title" => "Chapter 1.1",
            "path"=>"_chapter_1.html#_chapter_1_1"
          }
        ]
      },
      {
        "title" => "Chapter 2",
        "path" => "_chapter_2.html",
      }
    ], book.toc
  end

  def test_page_path
    adoc = <<~EOF
      = Book Name

      == Preface

      == Chapter

      [[afterward]]
      == Afterward
    EOF

    book = Asciibook::Book.new(adoc)
    book.process
    assert_equal %w(index.html _preface.html _chapter.html afterward.html), book.pages.map(&:path)
  end
end
