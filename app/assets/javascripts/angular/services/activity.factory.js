app.factory('Activity', ['$resource', function($resource) {
  return $resource('/activities.json', {}, {});
}]);
