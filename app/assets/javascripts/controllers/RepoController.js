angular.module('controllers')

.controller('RepoController', ['$scope', 'RepoService', function($scope, RepoService) {

  $scope.invertWebhook = function() {
    console.log('should be inverting the status of,', $scope.repo.name);
    $scope.repo.status = 'tracking';
  };

}]);
