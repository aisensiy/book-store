App = angular.module('App')

App.controller 'ImageEditCtrl', ['$scope', 'image', '$rootScope', 'UserService', '$location', 'Image', ($scope, image, $rootScope, UserService, $location, Image) ->
  $scope.image = image
  $scope.image.rate ||= 0
  $location.path("/images/#{$scope.image.objectId}") if !$scope.image.write

  # concat global tags and douban tags
  $scope.tags = if $scope.image.douban_tags then (elem.name for elem in $scope.image.douban_tags) else []
  $scope.tags = $scope.tags.concat(GlobalTags).uniq()

  $scope.tags_input_value = if $scope.image.tags then $scope.image.tags.join(" ") else ""
  $scope.$watch(
    'image.tags',
    (newValue, oldValue, scope) ->
      scope.tags_input_value = if newValue then newValue.join(' ') else ''
    ,
    true
  )

  $scope.$watch(
    'tags_input_value',
    (newValue, oldValue, scope) ->
      $scope.image.tags = if newValue && newValue.length then newValue.split(/\s+/) else []
    ,
    true
  )

  $scope.toggle_tag = (tag) ->
    index = $scope.image.tags.indexOf(tag)
    console.log "click #{tag}"
    if index == -1
      if $scope.image.tags.length then $scope.image.tags.push(tag) else $scope.image.tags = [tag]
    else
      $scope.image.tags.splice(index, 1)

    console.log $scope.image.tags


  $scope.rate_readonly = false
  $scope.submit_form = () ->
    image_id = $scope.image.objectId
    delete $scope.image.objectId
    Image.update
      id: image_id
    , image: $scope.image
    , (response) ->
      $scope.succ_msg = I18n.t('update_succ_message')
      $scope.fail_msg = null
      $location.path('/images/' + image_id)
]
