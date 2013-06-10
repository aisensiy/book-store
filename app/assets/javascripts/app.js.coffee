#= require 'services'
Parse.initialize("r1AGhZH6QjWaMVsXtOm5pvjAWJhOQtVaExxIuZ3y", "drjVTIqOvdqBF2ohTGfT8e7K48sqpUKAWHrWkTfH")

@App = angular.module('App', ['Services'])

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

App.directive 'passwordconfirm', () ->
  return {
    require: 'ngModel',
    link: (scope, elem, attrs, ctrl) ->
      console.log 'link'
      ctrl.$parsers.unshift (value) ->
        password = elem.closest('form').find(attrs.passwordconfirm)
        if password.val() == value
          ctrl.$setValidity('password', true)
          value
        else
          ctrl.$setValidity('password', false)
          undefined

  }



App.controller 'NaviBarCtrl', ['$scope', 'UserService', ($scope, UserService) ->

  $scope.$on 'user:signin', () ->
    console.log UserService.user
    $scope.user = UserService.user

  $scope.$on 'user:signout', () ->
    $scope.user = undefined
]

SignInCtrl = App.controller 'SignInCtrl', ($scope, UserService, $location) ->
  $scope.user = {}
  $scope.UserService = UserService
  $scope.$watch 'UserService.signin_err_msg', (val) ->
    $scope.error_msg = val

  $scope.submit_form = () ->
    UserService.signin($scope.user.email, $scope.user.password)

SignInCtrl.$inject = ['$scope', 'UserService', '$location']

SignUpCtrl = App.controller 'SignUpCtrl', ($scope, UserService, $location) ->
  $scope.user = {
    'email': 'ai@sina.com',
    'username': 'ai',
    'password': '123'
  }

  $scope.UserService = UserService

  $scope.$watch 'UserService.signup_err_msg', (val) ->
    $scope.error_msg = val

  $scope.submit_form = () ->
    console.log $scope.user
    UserService.signup($scope.user)

SignUpCtrl.$inject = ['$scope', 'UserService', '$location']

BooksCtrl = App.controller 'BooksCtrl', ($scope, books) ->
  $scope.books = books

BooksCtrl.$inject = ['$scope', 'books']

App.controller 'BookCtrl', ['$scope', 'book', ($scope, book) ->
  $scope.book = book
]

App.controller 'PasswordResetCtrl', ['$scope', ($scope) ->
]

App.controller 'PasswordModifyCtrl', ['$scope', ($scope) ->
]

App.controller 'BookUploadCtrl', ['$scope', ($scope) ->
]

user_sign_up = ($scope) ->
  console.log $scope.user
  user = new Parse.User()
  user.set 'username', $scope.user.username
  user.set 'email', $scope.user.email
  user.set 'password', $scope.user.password

  user.signUp null, {
    success: (user) ->
      console.log('signup success', arguments)

    error: (user, error) ->
      console.log('signup error', arguments)
  }
