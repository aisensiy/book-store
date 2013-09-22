#= require 'services'
#= require 'directives'
#= require 'filters'
#= require 'angular-sanitize'
#= require 'angular-resource'
#= require_self
#= require_tree './controllers'

@GlobalTags = I18n.t('categories')

@App = angular.module('App', ['Services', 'ngUpload', 'App.directives', 'App.filters', 'ui.bootstrap', 'ngSanitize', 'ngResource'])

App.factory 'Image', ($resource) ->
  $resource '/api/1/images/:id/:verb', {'id': '@objectId'},
    own: { method: 'GET', params: {verb: 'own'}, isArray: false },
    send_to_device: { method: 'POST', params: {verb: 'send_to_device'}}
    query: { method: 'GET', params: {}, isArray: false }
    tag: { method: 'GET', params: {verb: 'tag'}, isArray: false }
    week_top: { method: 'GET', params: {verb: 'week_top'}, isArray: true }
    month_top: { method: 'GET', params: {verb: 'month_top'}, isArray: true }
    recommend: { method: 'GET', params: {verb: 'recommend'}, isArray: true }
    search: { method: 'GET', params: {verb: 'search'}, isArray: false }
    update: { method: 'PUT' }

App.factory 'Book', ($resource) ->
  $resource '/api/1/books/:id/:verb', {'id': '@objectId'},
    own: { method: 'GET', params: {verb: 'own'}, isArray: false },
    send_to_device: { method: 'POST', params: {verb: 'send_to_device'}}
    query: { method: 'GET', params: {}, isArray: false }
    tag: { method: 'GET', params: {verb: 'tag'}, isArray: false }
    week_top: { method: 'GET', params: {verb: 'week_top'}, isArray: true }
    month_top: { method: 'GET', params: {verb: 'month_top'}, isArray: true }
    recommend: { method: 'GET', params: {verb: 'recommend'}, isArray: true }
    search: { method: 'GET', params: {verb: 'search'}, isArray: false }
    update: { method: 'PUT' }

App.factory 'Upload', ($resource) ->
  $resource '/api/1/upload/:verb', {},
    upload_token: { method: 'GET', params: {verb: 'token'} }
    download_token: { method: 'GET', params: {verb: 'download_token'} }

App.factory 'Comment', ($resource) ->
  $resource '/api/1/:model/:model_id/comments/:id', {},
    query: { method: 'GET', isArray: true }

App.config ['$routeProvider', ($routeProvider) ->
  $routeProvider
    .when '/books',
      template: $('#books_html').html(),
      controller: 'BooksCtrl',
      resolve:
        books: ['$q', 'Book', ($q, Book) ->
          deferred = $q.defer()
          Book.query({skip: 0, limit: 8}, (data) ->
            deferred.resolve(data)
          )
          deferred.promise
        ]
        recommends: ['$q', 'Book', ($q, Book) ->
          deferred = $q.defer()
          Book.recommend({limit: 8}, (data) ->
            deferred.resolve(data)
          )
          deferred.promise
        ]
    .when '/images',
      template: $('#images_html').html(),
      controller: 'ImagesCtrl',
      resolve:
        images: ['$q', 'Image', ($q, Image) ->
          deferred = $q.defer()
          Image.query({skip: 0, limit: 8}, (data) ->
            deferred.resolve(data)
          )
          deferred.promise
        ]
        recommends: ['$q', 'Image', ($q, Image) ->
          deferred = $q.defer()
          Image.recommend({limit: 8}, (data) ->
            deferred.resolve(data)
          )
          deferred.promise
        ]
    .when '/books/newest',
      template: $('#books_list_html').html(),
      controller: 'BooksListCtrl'
    .when '/books/search/:q',
      template: $('#books_list_html').html(),
      controller: 'BooksSearchListCtrl'
    .when '/books/tag/:q',
      template: $('#books_list_html').html(),
      controller: 'BooksTagListCtrl',
    .when '/books/:id',
      template: $('#book_html').html(),
      controller: 'BookCtrl',
      resolve:
        book: ['Book', '$route', '$q', (Book, $route, $q) ->
          deferred = $q.defer()
          Book.get({id: $route.current.params.id}, (data) ->
            deferred.resolve(data)
          )
          deferred.promise
        ]
    .when '/images/:id',
      template: $('#image_html').html(),
      controller: 'ImageCtrl',
      resolve:
        image: ['Image', '$route', '$q', (Image, $route, $q) ->
          deferred = $q.defer()
          Image.get({id: $route.current.params.id}, (data) ->
            deferred.resolve(data)
          )
          deferred.promise
        ]
    .when '/images/search/:q',
      template: $('#images_list_html').html(),
      controller: 'ImageSearchListCtrl'
    .when '/images/tag/:q',
      template: $('#images_list_html').html(),
      controller: 'ImageTagListCtrl'
    .when '/users/password_modify',
      template: $('#password_modify_html').html()
      controller: 'PasswordModifyCtrl'
      require_auth: true
    .when '/book-upload',
      template: $('#book_new_html').html()
      controller: 'BookUploadCtrl'
      resolve: {
        token: ['Upload', '$q', (Upload, $q) ->
          deferred = $q.defer()
          Upload.upload_token({ts: +new Date}, (data) ->
            deferred.resolve(data)
          )
          deferred.promise
        ]
        books: ['Book', '$q', (Book, $q) ->
          deferred = $q.defer()
          Book.own({skip: 0, limit: 8}, (data) ->
            deferred.resolve(data)
          )
          deferred.promise
        ]
      }
      require_auth: true
    .when '/images/:id/edit',
      template: $('#image_edit_html').html()
      controller: 'ImageEditCtrl'
      resolve:
        image: ['Image', '$route', '$q', (Image, $route, $q) ->
          deferred = $q.defer()
          Image.get({id: $route.current.params.id}, (data) ->
            deferred.resolve(data)
          )
          deferred.promise
        ]
      require_auth: true
      require_write: true
    .when '/books/:id/edit',
      template: $('#book_edit_html').html()
      controller: 'BookEditCtrl'
      resolve:
        book: ['Book', '$route', '$q', (Book, $route, $q) ->
          deferred = $q.defer()
          Book.get({id: $route.current.params.id}, (data) ->
            deferred.resolve(data)
          )
          deferred.promise
        ]
      require_auth: true
      require_write: true
    .otherwise { redirectTo: '/books' }
]

App.run ['$rootScope', 'UserService', '$location', ($rootScope, UserService, $location) ->
  UserService.current_user()
  $rootScope.$on '$routeChangeStart', (event, next, current) ->
    console.log 'route change'
    console.log arguments
    if next && next.require_auth && !$rootScope.user
      $location.path('/')
]

@user_control = ($scope, $rootScope, UserService) ->
  $scope.$on 'user:signin', () ->
    $scope.user = $rootScope.user

  $scope.$on 'user:signout', () ->
    $scope.user = undefined

  $scope.signout = () ->
    UserService.signout()

App.controller 'NaviBarCtrl', ['$scope', 'UserService', '$rootScope', 'Captcha', 'Panel', '$location', ($scope, UserService, $rootScope, Captcha, Panel, $location) ->
  $scope.Panel = Panel
  user_control($scope, $rootScope, UserService)
  open_modal = () ->
    $scope.shouldBeOpen = true

  $scope.submit_form = () ->
    $location.path("/books/search/#{$scope.q}")

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

BooksCtrl = App.controller 'BooksCtrl', ($scope, books, BooksService, Book, recommends) ->
  $scope.books = books.results
  $scope.recommends = recommends
  $scope.week_top = Book.week_top({limit: 5})
  $scope.month_top = Book.month_top {limit: 8}
  # $scope.paging = books.data.paging

  # $scope.pageChanged = (page) ->
  #   BooksService.books_popular page, (data) ->
  #     $scope.books = data.results
  #     $scope.paging = data.paging

BooksCtrl.$inject = ['$scope', 'books', 'BooksService', 'Book', 'recommends']


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
        $scope.succ_msg = I18n.t('update_succ_message')
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
        $scope.succ_msg = I18n.t('update_succ_message')
        $scope.fail_msg = null
      ,
      () ->
        $scope.succ_msg = null
        $scope.fail_msg = I18n.t('update_fail_message')
    )

PasswordModifyCtrl.$inject = ['$scope', 'UserService']

