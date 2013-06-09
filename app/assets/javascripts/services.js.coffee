@Services = angular.module 'Services', []
Services.factory 'UserService', ['$rootScope', '$location', ($rootScope, $location) ->
  service = {}

  service.signin = (email, password) ->
    console.log 'service.signin'
    if email == 'admin@gmail.com'
      console.log 'signin ok'
      service.user = {email: email}
      $rootScope.$broadcast('user:signin')
      $location.path('/')
    else
      console.log 'sigin error'
      service.signin_err_msg = 'bla'

  service.signup = (user) ->
    if user.email == 'admin@gmail.com'
      console.log 'signup ok'
      service.user = {email: user.email}
      $rootScope.$broadcast('user:signin')
      $location.path('/')
    else
      service.signup_err_msg = 'bla'

  service.current_user = () ->
    service.user

  service.signout = () ->
    service.user = undefined
    $rootScope.$broadcast('user:logout')

  return service
]

Services.factory 'BooksService', ['$location', ($location) ->
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
  service = {}

  service.books_popular = (page) ->
    console.log 'load popular'
    books

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

  service.book = (id) ->
    console.log 'load book ' + id
    books[0]

  return service
]
