#= require 'services'
#= require 'directives'
#= require 'filters'
#= require 'angular-sanitize'

@GlobalTags = ["经济", "武侠", "小说", "经典", "人文", "科技"]

@App = angular.module('App', ['Services', 'ngUpload', 'App.directives', 'App.filters', 'ui.bootstrap', 'ngSanitize'])

App.config ['$routeProvider', ($routeProvider) ->
  $routeProvider
    .when '/books',
      template: $('#books_html').html(),
      controller: 'BooksCtrl',
      resolve:
        books: ['BooksService', '$routeParams', (BooksService, $routeParams) ->
          BooksService.books_popular(1)
        ]
    .when '/books/:id',
      template: $('#book_html').html(),
      controller: 'BookCtrl',
      resolve:
        book: ['BooksService', '$route', (BooksService, $route) ->
          BooksService.book($route.current.params.id)
        ]
    .when '/users/password_modify',
      template: $('#password_modify_html').html()
      controller: 'PasswordModifyCtrl'
      require_auth: true
    .when '/book-upload',
      template: $('#book_new_html').html()
      controller: 'BookUploadCtrl'
      resolve: {
        token: ['BooksService', (BooksService) ->
          BooksService.get_token()
        ]
        books: ['BooksService', '$routeParams', (BooksService, $routeParams) ->
          console.log 'load books won'
          BooksService.books_own(1)
        ]
      }
      require_auth: true
    .when '/books/:id/edit',
      template: $('#book_edit_html').html()
      controller: 'BookEditCtrl'
      resolve:
        book: ['BooksService', '$route', (BooksService, $route) ->
          BooksService.book($route.current.params.id)
        ]
      require_auth: true
      require_write: true
    .otherwise({redirectTo: '/books'})
]

App.run ['$rootScope', 'UserService', '$location', ($rootScope, UserService, $location) ->
  UserService.current_user()
  $rootScope.$on '$routeChangeStart', (event, next, current) ->
    console.log 'route change'
    console.log arguments
    if next.require_auth && !$rootScope.user
      $location.path('/')
]


user_control = ($scope, $rootScope, UserService) ->
  $scope.$on 'user:signin', () ->
    $scope.user = $rootScope.user

  $scope.$on 'user:signout', () ->
    $scope.user = undefined

  $scope.signout = () ->
    UserService.signout()

App.controller 'NaviBarCtrl', ['$scope', 'UserService', '$rootScope', 'Captcha', 'Panel', ($scope, UserService, $rootScope, Captcha, Panel) ->
  $scope.Panel = Panel
  user_control($scope, $rootScope, UserService)
  open_modal = () ->
    $scope.shouldBeOpen = true

  $scope.close_modal = () ->
    $scope.shouldBeOpen = false

  $scope.sign_in_popup = () ->
    Panel.set_panel 'signin'
    open_modal()

  $scope.sign_up_popup = () ->
    Panel.set_panel 'signup'
    open_modal()

  $scope.reset_password_popup = () ->
    Panel.set_panel 'reset'
    open_modal()

  $scope.opts = {
    backdropFade: true,
    dialogFade:true
  }
]

SignInCtrl = App.controller 'SignInCtrl', ($scope, UserService, $location, Captcha, Panel) ->
  $scope.Panel = Panel
  $scope.user = {}
  $scope.UserService = UserService

  $scope.$watch 'UserService.signin_err_msg', (val) ->
    $scope.error_msg = val

  $scope.get_captcha_src = Captcha.get_captcha_src

  $scope.submit_form = () ->
    UserService.signin $scope.user.username, $scope.user.password,  $scope.user.captcha

SignInCtrl.$inject = ['$scope', 'UserService', '$location', 'Captcha', 'Panel']

SignUpCtrl = App.controller 'SignUpCtrl', ($scope, UserService, $location, Captcha) ->

  $scope.UserService = UserService
  $scope.get_captcha_src = Captcha.get_captcha_src
  $scope.error_msg = null

  $scope.$watch 'UserService.signup_err_msg', (val) ->
    $scope.error_msg = val

  $scope.submit_form = () ->
    UserService.signup
      username: $scope.user.username
      email: $scope.user.email
      password: $scope.user.password
      captcha: $scope.user.captcha

SignUpCtrl.$inject = ['$scope', 'UserService', '$location', 'Captcha']

BooksCtrl = App.controller 'BooksCtrl', ($scope, books, BooksService) ->
  $scope.books = books.data.results
  $scope.paging = books.data.paging

  $scope.pageChanged = (page) ->
    BooksService.books_popular page, (data) ->
      $scope.books = data.results
      $scope.paging = data.paging

BooksCtrl.$inject = ['$scope', 'books', 'BooksService']

App.controller 'BookCtrl', ['$scope', 'book', '$rootScope', 'BooksService', 'UserService', '$sanitize', '$location', ($scope, book, $rootScope, BooksService, UserService, $sanitize, $location) ->
  $scope.book = book.data
  $scope.book_summary = $sanitize($scope.book.summary)
  user_control($scope, $rootScope, UserService)
  if $scope.user
    BooksService.get_download_token $scope.book.file_key, $scope.book.file_name, (data) ->
      $scope.download_link = data.link

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

  console.log book
]

App.controller 'BookEditCtrl', ['$scope', 'book', '$rootScope', 'BooksService', 'UserService', '$location', ($scope, book, $rootScope, BooksService, UserService, $location) ->
  $scope.book = book.data
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
    BooksService.update_book(
      book_id,
      $scope.book,
      () ->
        $scope.succ_msg = "updated successfully"
        $scope.fail_msg = null
        $location.path('/book-upload')
      ,
      (data) ->
        $scope.succ_msg = null
        $scope.fail_msg = data.error
    )
]

App.controller 'PasswordResetCtrl', ['$scope', 'UserService', 'Captcha', ($scope, UserService, Captcha) ->
  $scope.succ_msg = null
  $scope.fail_msg = null
  $scope.model = {}
  $scope.get_captcha_src = Captcha.get_captcha_src
  $scope.submit_form = () ->
    UserService.password_reset(
      $scope.model.email,
      $scope.model.captcha,
      () ->
        $scope.succ_msg = "success"
        $scope.fail_msg = null
      ,
      (data) ->
        $scope.succ_msg = null
        $scope.fail_msg = data.error
        Captcha.refresh_captcha()
    )
]

PasswordModifyCtrl = App.controller 'PasswordModifyCtrl', ($scope, UserService) ->
  $scope.succ_msg = null
  $scope.fail_msg = null
  $scope.model = {}
  $scope.submit_form = () ->
    console.log $scope.model
    UserService.password_modify(
      $scope.model.oldpassword,
      $scope.model.password,
      () ->
        $scope.succ_msg = '修改成功'
        $scope.fail_msg = null
      ,
      () ->
        $scope.succ_msg = null
        $scope.fail_msg = '修改失败'
    )

PasswordModifyCtrl.$inject = ['$scope', 'UserService']

BookUploadCtrl = App.controller 'BookUploadCtrl', ($scope, $location, token, BooksService, $filter, books) ->
  $scope.books = books.data.results
  $scope.paging = books.data.paging

  $scope.langs = [ {name: "中文简体", value: 'zh-CN'}, {name: "中文繁体", value: 'zh-TW'}, {name: "英文", value: 'en'}, {name: "俄文", value: 'ru'} ]
  $scope.token = token.data.token

  $scope.book =
    is_public: true

  $scope.percentage = ''

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

  upload_failed = (evt) ->
    console.log 'failed upload'
    $scope.fail_msg = 'failed upload'
    $scope.is_loading = false

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

BookUploadCtrl.$inject = ['$scope', '$location', 'token', 'BooksService', '$filter', 'books']

UploadCtrl = App.controller 'UploadCtrl', ($scope) ->



UploadCtrl.$inject = ['$scope']
