app.factory('User', ['$resource', function($resource) {
  return $resource('/users.json', {}, {});
}]);
