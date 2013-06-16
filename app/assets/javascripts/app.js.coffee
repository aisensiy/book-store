#= require 'services'
#= require 'http_wrapper'

@App = angular.module('App', ['Services', 'SharedServices', 'ngUpload'])

App.config ['$routeProvider', ($routeProvider) ->
  $routeProvider
    .when '/sign_in',
      templateUrl: 'sign_in.html'
      controller: 'SignInCtrl'
    .when '/sign_up',
      templateUrl: 'sign_up.html',
      controller: 'SignUpCtrl'
    .when '/books',
      templateUrl: 'books.html',
      controller: 'BooksCtrl',
      resolve:
        books: ['$q', 'BooksService', '$timeout', ($q, BooksService, $timeout) ->
          deferred = $q.defer()
          deferred.resolve(BooksService.books_popular())
          return deferred.promise
        ]
    .when '/books/:id',
      templateUrl: 'book.html',
      controller: 'BookCtrl',
      resolve:
        book: ['$q', 'BooksService', '$route', ($q, BooksService, $route) ->
          deferred = $q.defer()
          deferred.resolve(BooksService.book($route.current.params.id))
          return deferred.promise
        ]
    .when '/users/password_reset',
      templateUrl: 'password_reset.html'
      controller: 'PasswordResetCtrl',
    .when '/users/password_modify',
      templateUrl: 'password_modify.html'
      controller: 'PasswordModifyCtrl',
    .when '/book-upload',
      templateUrl: 'book_new.html'
      controller: 'BookUploadCtrl'
    .otherwise({redirectTo: '/books'})
]

App.run ['$rootScope', 'UserService', ($rootScope, UserService) ->
  UserService.current_user()
]

# App.directive 'ngUpload', () ->
#   return {
#     restrict: 'AC',
#     link: (scope, element, attrs) ->
#       element.attr("target", "upload_iframe")
#       element.attr("method", "post")
#       separator = (element.attr("action").indexOf('?') == -1 ? '?' : '&')
#       element.attr("action", element.attr("action") + separator + "_t=" + new Date().getTime())
#       element.attr("enctype", "multipart/form-data")
#       element.attr("encoding", "multipart/form-data")
#
#   }

App.directive('validFile', () ->
  return {
    require: 'ngModel',
    link: (scope, el, attrs, ngModel) ->
      el.bind 'change', () ->
        scope.$apply () ->
          ngModel.$setViewValue(el.val())
          return

      return
  }
)
App.directive 'passwordconfirm', () ->
  return {
    require: 'ngModel',
    link: (scope, elem, attrs, ctrl) ->
      ctrl.$parsers.unshift (value) ->
        password = elem.closest('form').find(attrs.passwordconfirm)
        if password.val() == value
          ctrl.$setValidity('password', true)
          value
        else
          ctrl.$setValidity('password', false)
          undefined
  }


# App.controller 'FileUploadCtrl', ['$scope', ($scope) ->

  # console.log upload_form.upload.$valid
  # $scope.un_changed = () ->
  #   console.log $scope.model
  #   angular.equals({}, $scope.model)

  # $scope.submit_form = () ->
  #   alert 123

  # $scope.submit_complete = (content) ->
  #   resp = JSON.parse(content.match(/\{.*\}/))
  #   console.log resp
# ]

App.controller 'NaviBarCtrl', ['$scope', 'UserService', '$rootScope', ($scope, UserService, $rootScope) ->

  $scope.$on 'user:signin', () ->
    $scope.user = $rootScope.user

  $scope.$on 'user:signout', () ->
    $scope.user = undefined

  $scope.signout = () ->
    UserService.signout()
]

SignInCtrl = App.controller 'SignInCtrl', ($scope, UserService, $location) ->
  $scope.user = {}
  $scope.UserService = UserService
  $scope.$watch 'UserService.signin_err_msg', (val) ->
    $scope.error_msg = val

  $scope.submit_form = () ->
    UserService.signin $scope.user.username, $scope.user.password,  $scope.user.captcha

SignInCtrl.$inject = ['$scope', 'UserService', '$location']

SignUpCtrl = App.controller 'SignUpCtrl', ($scope, UserService, $location) ->

  $scope.UserService = UserService

  $scope.$watch 'UserService.signup_err_msg', (val) ->
    $scope.error_msg = val

  $scope.submit_form = () ->
    UserService.signup
      username: $scope.user.username
      email: $scope.user.email
      password: $scope.user.password
      captcha: $scope.user.captcha

SignUpCtrl.$inject = ['$scope', 'UserService', '$location']

BooksCtrl = App.controller 'BooksCtrl', ($scope, books) ->
  $scope.books = books

BooksCtrl.$inject = ['$scope', 'books']

App.controller 'BookCtrl', ['$scope', 'book', ($scope, book) ->
  $scope.book = book
]

App.controller 'PasswordResetCtrl', ['$scope', 'UserService', ($scope, UserService) ->
  $scope.succ_msg = null
  $scope.fail_msg = null
  $scope.model = {}
  console.log $scope.model
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

App.controller 'BookUploadCtrl', ['$scope', '$location', ($scope, $location) ->
  $scope.langs = [ {name: "中文简体", value: 'zh-CN'}, {name: "中文繁体", value: 'zh-TW'}, {name: "英文", value: 'en'}, {name: "俄文", value: 'ru'} ]
  $scope.book =
    is_public: true
    tags: []

  $scope.show_loading = () ->
    $('#loading').toggle()

  tags = () ->
    $scope.tags = []
    angular.forEach $scope.langs, (lang) ->
      $scope.tags.push(lang.value) if lang.checked

  $scope.submit_complete = (content, success) ->
    resp = JSON.parse(content.match(/\{.*\}/))
    $('#loading').toggle()
    if success
      $location.path("/books/#{resp.objectId}")
    else
      $scope.fail_msg = resp.error
]
