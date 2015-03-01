angular.module('controllers')

.controller('RepoController', ['$scope', 'RepoService', function($scope, RepoService) {

  $scope.requestInProgress = false;

  $scope.invertWebhook = function() {
    !!$scope.repo.active ? deleteHook() : createHook();
    $scope.requestInProgress = true;
  };

  function createHook() {
    RepoService.createHook($scope.repo).then(function(data) {
      $scope.repo.active = true;
      $scope.repo.id = data.id;
    }, function(err) {
      console.log('Err bro,', err);
    }, function() {
      $scope.requestInProgress = false;
    });
  }

  function deleteHook() {
    RepoService.deleteHook($scope.repo).then(function(data) {
      $scope.repo.active = false;
    }, function(err) {
      console.log('Err bro,', err);
    }, function() {
      $scope.requestInProgress = false;
    });
  }
}]);
