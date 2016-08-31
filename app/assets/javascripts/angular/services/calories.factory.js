app.factory('Calories', ['$resource', function($resource) {
  return $resource('/calories.json', {}, {});
}]);
