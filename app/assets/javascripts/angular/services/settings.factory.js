app.factory('Settings', ['$resource', function($resource) {
  return $resource('/settings.json', {}, {});
}]);
