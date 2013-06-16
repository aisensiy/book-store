require 'test_helper'

class BookTest < ActiveSupport::TestCase
  setup do
    @book = {
      title: 'test',
      author: 'aisensiy',
      summary: 'this is a test summary',
      file: {
        name: '4eacc26f-0f76-4db9-9d28-f3c3f99c5acc-QQ20130601-3.png',
        __type: 'File'
      }
    }
  end

  test "should create a new book" do
    resp = Book.create_book(@book)

    assert_equal 201, resp.code
    assert resp.body['objectId']
  end
end
