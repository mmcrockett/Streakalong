app.factory('Item', ['$resource', function($resource) {
  return $resource('/items.json', {}, {});
}]);
