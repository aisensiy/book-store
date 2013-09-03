ImagesCtrl = App.controller 'ImagesCtrl', ($scope, images, Image, recommends) ->
  $scope.images = images.results
  $scope.recommends = recommends
  $scope.week_top = Image.week_top({limit: 5})
  $scope.month_top = Image.month_top {limit: 8}

ImagesCtrl.$inject = ['$scope', 'images', 'Image', 'recommends']
