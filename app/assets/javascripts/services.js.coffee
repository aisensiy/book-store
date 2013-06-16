#= require 'http_wrapper'

Services = angular.module 'Services', ['HttpServices']
Services.factory 'UserService', ['$rootScope', '$location', '$q', '$timeout', 'HttpWrapper', ($rootScope, $location, $q, $timeout, $http) ->
  service = {}

  service.signin = (username, password, captcha) ->
    console.log 'service.signin'
    user_wrapper =
      'user[username]': username
      'user[password]': password
    console.log user_wrapper

    $http
      url: '/api/1/users/signin'
      method: 'POST'
      data:
        username: username
        password: password
        captcha: captcha
    .success (data) ->
        console.log 'signin ok'
        $rootScope.user = {username: username}
        $rootScope.$broadcast('user:signin')
        $location.path('/')
    .error (data) ->
        service.signin_err_msg = data.error


  service.signup = (user) ->
    console.log user
    $http
      url: '/api/1/users'
      method: 'POST'
      data: user
      dataType: 'json'
    .success (data) ->
        console.log 'signup ok'
        $rootScope.user = {username: user.username}
        $rootScope.$broadcast('user:signin')
        $location.path('/')
    .error (data) ->
        service.signup_err_msg = data.error


  service.current_user = () ->
    return $rootScope.user if $rootScope.user
    console.log 'load user'

    $http
      url: '/api/1/users/current_user'
      method: 'GET'
      data: {}
    .success (data) ->
      console.log 'do sth'
      $rootScope.user = {username: data.username}
      $rootScope.$broadcast('user:signin')


  service.signout = () ->
    $http
      url: '/api/1/users/signout'
      method: 'DELETE'
    .success () ->
      $rootScope.user = undefined
      $rootScope.$broadcast('user:signout')


  service.password_modify = (oldpassword, newpassword, succ, error) ->
    $http
      url: '/api/1/users'
      method: 'PUT'
      data: {password: newpassword}
    .success(succ)
    .error(error)

  service.password_reset = (email, captcha, succ, error) ->
    $http
      url: '/api/1/users/password_reset',
      method: 'POST'
      data:
        email: email,
        captcha: captcha
    .success(succ)
    .error(error)

  return service
]

Services.factory 'BooksService', ['$rootScope', '$location', '$q', '$timeout', '$http', ($rootScope, $location, $q, $timeout, $http) ->
  service = {}
  books = [
    {
      id: '1',
      title: '麦田守望者',
      author: '马丁 安东尼等',
      image_url: '/assets/book-cover.png',
      private: true,
      user: 'aisensiy'
    },
    {
      id: '4',
      title: '麦田守望者',
      author: '马丁 安东尼等',
      image_url: '/assets/book-cover.png',
      private: true,
      user: 'aisensiy'
    },
    {
      id: '5',
      title: '麦田守望者',
      author: '马丁 安东尼等',
      image_url: '/assets/book-cover.png',
      private: true,
      user: 'aisensiy'
    },
    {
      id: '6',
      title: '麦田守望者',
      author: '马丁 安东尼等',
      image_url: '/assets/book-cover.png',
      private: true,
      user: 'aisensiy'
    },
    {
      id: '7',
      title: '麦田守望者',
      author: '马丁 安东尼等',
      image_url: '/assets/book-cover.png',
      private: true,
      user: 'aisensiy'
    },
    {
      id: '8',
      title: '麦田守望者',
      author: '马丁 安东尼等',
      image_url: '/assets/book-cover.png',
      private: true,
      user: 'aisensiy'
    },
    {
      id: '9',
      title: '麦田守望者',
      author: '马丁 安东尼等',
      image_url: '/assets/book-cover.png',
      private: false,
      user: 'ranhui'
    }
  ]

  service.books_popular = (succ, fail) ->
    $http
      url: '/api/1/books'
      method: 'GET'
    .success (data) ->
      data
    .error (data) ->
      data

  service.books_newest = (page) ->
    books

  service.books_by_category = (category, page) ->
    books

  service.books_by_lang = (lang, page) ->
    books

  service.books_private = (page) ->
    books

  service.books_by_user = (user_id, page) ->
    books

  service.book = (id, succ, fail) ->
    $http
      url: "/api/1/books/#{id}"
      method: 'GET'
    .success (data) ->
      data
    .error (data) ->
      data

  return service
]
