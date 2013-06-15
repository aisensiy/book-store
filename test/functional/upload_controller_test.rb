require 'test_helper'

class UploadControllerTest < ActionController::TestCase
  test "should upload a file" do
    post :post, upload: fixture_file_upload(Rails.root.join("/app/assets/images/rails.png"), "image/png")

    assert_response 201
  end
end
