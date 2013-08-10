App = angular.module('App')

controller = App.controller 'BookCtrl', ($scope, book, $rootScope, BooksService, UserService, $sanitize, $location, Upload, Comment, Book) ->
  $scope.book = book
  description_process = (text) ->
    ps = text.split(/\n/)
    outputs = ("<p>#{p}</p>" for p in ps)
    return outputs.join(' ')

  $scope.book_summary = $sanitize(description_process($scope.book.summary))
  $scope.comments = Comment.query {book_id: book.objectId}
  $scope.week_top = Book.week_top({limit: 5})

  $scope.get_download_url = () ->
    popup_download = (url) ->
      link = document.createElement('a')
      link.href = $scope.download_link
      link.click()
      link = null

    if $scope.download_link
      popup_download($scope.download_link)
    else
      Upload.download_token {item_id: $scope.book.objectId}, (data) ->
        $scope.download_link = data.link
        popup_download($scope.download_link)


  $scope.delete_book = (book) ->
    return if !confirm('Are you sure to delete the book')
    BooksService.delete_book(
      book.objectId,
      book.file_key,
      () ->
        $scope.succ_msg = 'delete book successfully'
        $scope.fail_msg = null
        $location.path('/')
      ,
      () ->
        $scope.fail_msg = 'delete book failed'
        $scope.succ_msg = null
    )

  $scope.send_to_device = (book) ->
    BooksService.send_to_device(
      book.objectId,
      () ->
        $scope.succ_msg = 'send this book to your device successfully'
        $scope.fail_msg = null
      ,
      () ->
        $scope.succ_msg = null
        $scope.fail_msg = 'failed to send book to your device'
    )

  $scope.create_comment = (new_comment) ->
    comment = new Comment(new_comment)
    comment.$save {book_id: $scope.book.objectId}, (data) ->
      data.user = $rootScope.user
      data.write = true
      $scope.comments.push data
      $scope.new_comment = {}

  $scope.delete_comment = (comment, index) ->
    c = new Comment(comment)
    c.$remove {id: c.objectId, book_id: $scope.book.objectId}, (data) ->
      $scope.comments.splice(index, 1)


controller.$inject = ['$scope', 'book', '$rootScope', 'BooksService', 'UserService', '$sanitize', '$location', 'Upload', 'Comment', 'Book']
