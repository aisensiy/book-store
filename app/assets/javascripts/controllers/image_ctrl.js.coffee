App = angular.module('App')

controller = App.controller 'ImageCtrl', ($scope, image, $rootScope, BooksService, UserService, $sanitize, $location, Upload, Comment, Image) ->
  $scope.image = image

  $scope.comments = Comment.query {model: 'images', model_id: image.objectId}
  $scope.week_top = Image.week_top({limit: 5})

  Upload.download_token {item_id: $scope.image.objectId, object_type: 'image'}, (data) ->
    $scope.download_link = data.link

  $scope.get_download_url = () ->
    popup_download = (url) ->
      link = document.createElement('a')
      link.href = $scope.download_link
      link.click()
      link = null

    if $scope.download_link
      popup_download($scope.download_link)
    else
      Upload.download_token {item_id: $scope.image.objectId, object_type: 'image'}, (data) ->
        $scope.download_link = data.link
        popup_download($scope.download_link)


  $scope.delete_image = (image) ->
    return if !confirm('Are you sure to delete the image')
    Image.delete
      id: image.objectId
      file_key: image.file_key
    , () ->
      $scope.succ_msg = 'delete image successfully'
      $scope.fail_msg = null
      $location.path('/images')
    , () ->
      $scope.fail_msg = 'delete image failed'
      $scope.succ_msg = null

  $scope.send_to_device = (image) ->
    image = new Image(image)
    image.$send_to_device () ->
      $scope.succ_msg = 'send this image to your device successfully'
      $scope.fail_msg = null
    , () ->
      $scope.succ_msg = null
      $scope.fail_msg = 'failed to send image to your device'

  $scope.create_comment = (new_comment) ->
    comment = new Comment(new_comment)
    comment.$save {model: 'images', model_id: $scope.image.objectId}, (data) ->
      data.user = $rootScope.user
      data.write = true
      $scope.comments.push data
      $scope.new_comment = {}

  $scope.delete_comment = (comment, index) ->
    c = new Comment(comment)
    c.$remove {model: 'images', id: c.objectId, model_id: $scope.image.objectId}, (data) ->
      $scope.comments.splice(index, 1)


controller.$inject = ['$scope', 'image', '$rootScope', 'BooksService', 'UserService', '$sanitize', '$location', 'Upload', 'Comment', 'Image']
