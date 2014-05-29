app.factory('UserItems', ['$resource', function($resource) {
  return $resource('/useritems.json', {}, {});
}]);
