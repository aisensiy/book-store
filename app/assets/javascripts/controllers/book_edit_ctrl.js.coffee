App = angular.module('App')

App.controller 'BookEditCtrl', ['$scope', 'book', '$rootScope', 'Book', 'UserService', '$location', ($scope, book, $rootScope, Book, UserService, $location) ->
  $scope.book = book
  $scope.book.rate ||= 0
  $location.path("/books/#{$scope.book.objectId}") if !$scope.book.write

  # concat global tags and douban tags
  $scope.tags = if $scope.book.douban_tags then (elem.name for elem in $scope.book.douban_tags) else []
  $scope.tags = $scope.tags.concat(GlobalTags).uniq()

  $scope.tags_input_value = if $scope.book.tags then $scope.book.tags.join(" ") else ""
  $scope.$watch(
    'book.tags',
    (newValue, oldValue, scope) ->
      scope.tags_input_value = if newValue then newValue.join(' ') else ''
    ,
    true
  )

  $scope.$watch(
    'tags_input_value',
    (newValue, oldValue, scope) ->
      $scope.book.tags = if newValue && newValue.length then newValue.split(/\s+/) else []
    ,
    true
  )

  $scope.toggle_tag = (tag) ->
    index = $scope.book.tags.indexOf(tag)
    console.log "click #{tag}"
    if index == -1
      if $scope.book.tags.length then $scope.book.tags.push(tag) else $scope.book.tags = [tag]
    else
      $scope.book.tags.splice(index, 1)

    console.log $scope.book.tags


  $scope.rate_readonly = false
  $scope.submit_form = () ->
    book_id = $scope.book.objectId
    delete $scope.book.objectId
    Book.update
      id: book_id
    , book: $scope.book
    , () ->
      $scope.succ_msg = I18n.t('update_succ_message')
      $scope.fail_msg = null
      $location.path('/books/' + book_id)
    , (data) ->
      $scope.succ_msg = null
      $scope.fail_msg = data.error
]
