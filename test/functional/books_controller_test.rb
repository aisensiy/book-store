require 'test_helper'

class BooksControllerTest < ActionController::TestCase
  setup do
    @book_params = {
      url: 'http://book.douban.com/subject/24706877/',
      upload: fixture_file_upload("rails.png", "image/png"),
      is_public: true
    }
  end

  test "should get create" do
    post :create, book: @book_params
    body = JSON.parse @response.body
    assert_equal 201, @response.status
    assert body['objectId']
  end
=begin
  test "should get index" do
    get :index
    assert_response :success
  end


  test "should get update" do
    get :update
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end
=end

end
