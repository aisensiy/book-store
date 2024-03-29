App = angular.module('App')

controller = App.controller 'BookCtrl', ($scope, book, $rootScope, BooksService, UserService, $sanitize, $location, Upload, Comment, Book) ->
  $scope.book = book
  description_process = (text) ->
    return '' if not text
    ps = text.split(/\n/)
    outputs = ("<p>#{p}</p>" for p in ps)
    return outputs.join(' ')

  $scope.book_summary = $sanitize(description_process($scope.book.summary))
  $scope.comments = Comment.query {model: 'books', model_id: book.objectId}
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
      Upload.download_token {item_id: $scope.book.objectId, object_type: 'book'}, (data) ->
        $scope.download_link = data.link
        popup_download($scope.download_link)


  $scope.delete_book = (book) ->
    return if !confirm(I18n.t('delete_confirm'))
    BooksService.delete_book(
      book.objectId,
      book.file_key,
      () ->
        $scope.succ_msg = I18n.t('book_delete_succ_message')
        $scope.fail_msg = null
        $location.path('/')
      ,
      () ->
        $scope.fail_msg = I18n.t('book_delete_fail_message')
        $scope.succ_msg = null
    )

  $scope.send_to_device = (book) ->
    BooksService.send_to_device(
      book.objectId,
      () ->
        $scope.succ_msg = I18n.t 'book_send_succ_message'
        $scope.fail_msg = null
      ,
      () ->
        $scope.succ_msg = null
        $scope.fail_msg = I18n.t 'book_send_fail_message'
    )

  $scope.create_comment = (new_comment) ->
    comment = new Comment(new_comment)
    Comment.save
      model: 'books'
      model_id: $scope.book.objectId
    , comment: new_comment
    , (data) ->
      data.user = $rootScope.user
      data.write = true
      $scope.comments.push data
      $scope.new_comment = {}

  $scope.delete_comment = (comment, index) ->
    c = new Comment(comment)
    c.$remove {model: 'books', id: c.objectId, model_id: $scope.book.objectId}, (data) ->
      $scope.comments.splice(index, 1)


controller.$inject = ['$scope', 'book', '$rootScope', 'BooksService', 'UserService', '$sanitize', '$location', 'Upload', 'Comment', 'Book']
