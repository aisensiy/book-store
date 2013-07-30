#= require 'http_wrapper'

Services = angular.module 'Services', ['HttpServices']

Services.factory 'Panel', [() ->
  panel = 'signin'

  set_panel = (val) ->
    panel = val

  get_panel = () ->
    panel

  {
    set_panel: set_panel,
    get_panel: get_panel
  }
]

Services.factory 'Captcha', [() ->
  service = {}

  captcha_src = null

  service.get_captcha_src = () ->
    if not captcha_src
      service.refresh_captcha()
    captcha_src

  service.refresh_captcha = () ->
    captcha_src = "/captcha?action=captcha&i=" + new Date()

  service
]

Services.factory 'UserService', ['$rootScope', '$location', '$q', '$timeout', 'HttpWrapper', 'Captcha', ($rootScope, $location, $q, $timeout, $http, Captcha) ->
  service = {}

  service.signin = (username, password, captcha) ->
    console.log 'service.signin'

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
      Captcha.refresh_captcha()

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
      Captcha.refresh_captcha()


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

  rate_process = (books) ->
    for book in books
      book.rate = book.rate || book.rating && book.rating.average / 2 || 0

    books

  service.books_own = (page_no, succ, fail) ->
    page_no = page_no || 1
    per_page = 40
    $http
      url: "/api/1/books/own"
      method: 'GET'
      params: {
        limit: per_page,
        skip: (page_no - 1) * per_page
      }
    .success (data) ->
      data.results = rate_process(data.results)
      data.paging =
        current_page: page_no
        total_page: Math.ceil(data.count / per_page)
        max_size: 10
      succ && succ(data) || data
    .error (data) ->
      fail && fail(data) || data

  service.books_popular = (page_no, succ, fail) ->
    page_no = page_no || 1
    per_page = 40
    console.log page_no, per_page
    $http
      url: "/api/1/books"
      method: 'GET'
      params: {
        limit: per_page,
        skip: (page_no - 1) * per_page
      }
    .success (data) ->
      data.results = rate_process(data.results)
      data.paging =
        current_page: page_no
        total_page: Math.ceil(data.count / per_page)
        max_size: 10
      succ && succ(data) || data
    .error (data) ->
      fail && fail(data) || data

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

  service.create_book = (book_data, succ, fail) ->
    $http(
      url: "/api/1/books"
      method: 'POST'
      data: book_data
    ).success(succ).error(fail)

  service.book = (id, succ, fail) ->
    $http
      url: "/api/1/books/#{id}"
      method: 'GET'
      cache: true
    .success (data) ->
      data.rate = data.rate || data.rating && data.rating.average / 2 || 0
      data
    .error (data) ->
      data

  service.get_token = () ->
    $http
      url: "/api/1/upload/token"
      method: 'GET'
      data: {ts: +new Date}
    .success (data) ->
      data
    .error (data) ->
      data

  service.get_download_token = (key, file_name, succ, fail) ->
    $http
      url: "/api/1/upload/download_token"
      method: "GET"
      params:
        ts: +new Date
        file_key: key
        file_name: file_name
    .success (data) ->
      succ && succ(data) || data
    .error (data) ->
      fail && fail(data) || data

  service.update_book = (id, book_data, succ, fail) ->
    $http(
      url: "/api/1/books/#{id}"
      method: "PUT"
      data: book_data
    ).success(succ).error(fail)

  service.delete_book = (id, file_key, succ, fail) ->
    $http(
      url: "/api/1/books/#{id}"
      method: "DELETE"
      params:
        file_key: file_key
    ).success(succ).error(fail)

  service.send_to_device =  (book_id, succ, fail) ->
    $http(
      url: "/api/1/books/#{book_id}/send_to_device"
      method: "POST"
    ).success(succ).error(fail)

  return service
]
