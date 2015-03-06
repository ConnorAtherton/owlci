angular.module('directives')

.directive('repo', function() {
  return {
    restrict: 'E',
    templateUrl: 'repo.html',
    scope: {
      repo: '=repo'
    },
    controller: 'RepoController',
    link: function($scope, $element, $attrs) {
      // $scope.invertWebhook = function() {
      //   console.log('button clicked', repo.name);
      // }
    }
  };
});
