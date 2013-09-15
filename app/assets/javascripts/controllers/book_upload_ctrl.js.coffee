App = angular.module('App')

BookUploadCtrl = App.controller 'BookUploadCtrl', ($scope, $location, token, BooksService, $filter, books, Image) ->
  $scope.books = books
  $scope.images = Image.own({limit: 8, skip: 0})
  # $scope.paging = books.data.paging

  $scope.langs = [ {name: "中文简体", value: 'zh-CN'}, {name: "中文繁体", value: 'zh-TW'}, {name: "英文", value: 'en'}, {name: "俄文", value: 'ru'} ]
  $scope.token = token.token

  $scope.book =
    is_public: true

  $scope.percentage = ''
  $scope.is_book = true

  $scope.$watch 'book.content_type', (value) ->
    console.log value
    if value && /^image/.test(value)
      $scope.is_book = false
    else
      $scope.is_book = true

  upload_progress = (evt) ->
    if (evt.lengthComputable)
      $scope.percentage = Math.round(evt.loaded * 100 / evt.total)
      $('.progress .bar').width($scope.percentage + '%')
    else
      alert 'unable to get progress bar'

  upload_complete = (evt) ->
    data = JSON.parse evt.target.responseText
    $scope.book.file_key = data.file_key
    $scope.book.content_type = data.content_type
    $scope.book.size = data.size
    $scope.book.file_name = data.file_name

    if /^image/.test(data.content_type)
      image = new Image($scope.book)
      image.$save (data) ->
        $location.path("/images/#{data.objectId}/edit")
    else
      BooksService.create_book($scope.book,
        (data) ->
          console.log data.objectId
          $location.path("/books/#{data.objectId}/edit")
          $scope.is_loading = false
        ,
        (data) ->
          $scope.fail_msg = data.error
          $scope.is_loading = false
      )

    $scope.xhr = null if $scope.xhr

  upload_failed = (evt) ->
    console.log 'failed upload'
    $scope.fail_msg = 'failed upload'
    $scope.is_loading = false
    $scope.xhr = null if $scope.xhr

  $scope.submit_form = () ->
    $scope.is_loading = true

    # make form
    fd  = new FormData()
    fd.append('file', book_form.file.files[0])
    fd.append('token', book_form.token.value)

    console.log fd

    # make xhr
    xhr = new XMLHttpRequest()
    xhr.upload.addEventListener('progress', upload_progress)
    xhr.addEventListener('load', upload_complete)
    xhr.addEventListener('error', upload_failed)

    xhr.open('POST', 'http://up.qiniu.com/')
    xhr.send(fd)
    $scope.xhr = xhr

  $scope.cancel = () ->
    if $scope.xhr
      $scope.xhr.abort()
    $('.progress .bar').width('0')

BookUploadCtrl.$inject = ['$scope', '$location', 'token', 'BooksService', '$filter', 'books', 'Image']

UploadCtrl = App.controller 'UploadCtrl', ($scope) ->



UploadCtrl.$inject = ['$scope']
