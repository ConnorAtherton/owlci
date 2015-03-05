angular.module('controllers')

.config(function($stateProvider) {

  $stateProvider
    .state('docs', {
      url: "/docs",
      controller: 'DocsController',
      templateUrl: "docs.html",
    });
})

.controller('DocsController', function($scope) {

});
