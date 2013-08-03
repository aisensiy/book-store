App = angular.module('App')

App.controller 'BookCtrl', ['$scope', 'book', '$rootScope', 'BooksService', 'UserService', '$sanitize', '$location', 'Upload', ($scope, book, $rootScope, BooksService, UserService, $sanitize, $location, Upload) ->
  $scope.book = book
  $scope.book_summary = $sanitize($scope.book.summary)

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

  console.log book
]
