#= require 'services'
#= require 'directives'
#= require 'filters'

@App = angular.module('App', ['Services', 'ngUpload', 'App.directives', 'App.filters'])

App.config ['$routeProvider', ($routeProvider) ->
  $routeProvider
    .when '/sign_in',
      template: $('#sign_in_html').html()
      controller: 'SignInCtrl'
    .when '/sign_up',
      template: $('#sign_up_html').html(),
      controller: 'SignUpCtrl'
    .when '/books',
      template: $('#books_html').html(),
      controller: 'BooksCtrl',
      resolve:
        books: ['BooksService', (BooksService) ->
          BooksService.books_popular()
        ]
    .when '/books/:id',
      template: $('#book_html').html(),
      controller: 'BookCtrl',
      resolve:
        book: ['BooksService', '$route', (BooksService, $route) ->
          BooksService.book($route.current.params.id)
        ]
    .when '/users/password_reset',
      template: $('#password_reset_html').html()
      controller: 'PasswordResetCtrl',
    .when '/users/password_modify',
      template: $('#password_modify_html').html()
      controller: 'PasswordModifyCtrl',
    .when '/book-upload',
      template: $('#book_new_html').html()
      controller: 'BookUploadCtrl'
      resolve: {
        token: ['BooksService', (BooksService) ->
          BooksService.get_token()
        ]
      }
    .otherwise({redirectTo: '/books'})
]

App.run ['$rootScope', 'UserService', ($rootScope, UserService) ->
  UserService.current_user()
]


App.controller 'NaviBarCtrl', ['$scope', 'UserService', '$rootScope', ($scope, UserService, $rootScope) ->

  $scope.$on 'user:signin', () ->
    $scope.user = $rootScope.user

  $scope.$on 'user:signout', () ->
    $scope.user = undefined

  $scope.signout = () ->
    UserService.signout()
]

SignInCtrl = App.controller 'SignInCtrl', ($scope, UserService, $location, Captcha) ->
  $scope.user = {}
  $scope.UserService = UserService

  $scope.$watch 'UserService.signin_err_msg', (val) ->
    $scope.error_msg = val

  $scope.get_captcha_src = Captcha.get_captcha_src

  $scope.submit_form = () ->
    UserService.signin $scope.user.username, $scope.user.password,  $scope.user.captcha

SignInCtrl.$inject = ['$scope', 'UserService', '$location', 'Captcha']

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

BooksCtrl = App.controller 'BooksCtrl', ($scope, books) ->
  $scope.books = books.data

BooksCtrl.$inject = ['$scope', 'books']

App.controller 'BookCtrl', ['$scope', 'book', ($scope, book) ->
  $scope.book = book.data
  console.log book
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

App.controller 'BookUploadCtrl', ['$scope', '$location', 'token', 'BooksService', ($scope, $location, token, BooksService) ->
  $scope.langs = [ {name: "中文简体", value: 'zh-CN'}, {name: "中文繁体", value: 'zh-TW'}, {name: "英文", value: 'en'}, {name: "俄文", value: 'ru'} ]
  $scope.token = token.data.token
  $scope.book =
    is_public: true
    tags: []

  $scope.show_loading = () ->
    $('#loading').toggle()

  tags = () ->
    $scope.tags = []
    angular.forEach $scope.langs, (lang) ->
      $scope.tags.push(lang.value) if lang.checked

  $scope.submit_complete = (content, completed) ->
    console.log arguments
    return if not completed or content.length <= 0
    json = content.match(/\{.*\}/)[0]
    console.log json
    resp = JSON.parse json
    $('#loading').toggle()
    if resp.error
      $scope.fail_msg = resp.error
    else
      BooksService.create_book(resp,
        (data) ->
          console.log data.objectId
          $location.path("/books/#{data.objectId}")
        ,
        (data) ->
          $scope.fail_msg = data.error
      )
]
