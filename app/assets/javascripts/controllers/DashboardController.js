angular.module('controllers')

.controller('DashboardController', ['$scope', 'RepoService', function($scope, RepoService) {
  $scope.repos = undefined;

  $scope.loadingMessage = (function() {
    var messages = ['Hey, we are just loading your github information',
                    'Just fetching data, we\'ll be with you asap',
                    ' Ooo look, pretty circles']

    return messages[Math.floor(Math.random() * messages.length)];
  })();

  RepoService.all().then(function(data) {
    $scope.repos = data;
    $scope.styleClass = "reposLoaded";
  });

}]);
