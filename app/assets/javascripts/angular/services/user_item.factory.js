app.factory('UserItem', ['$resource', function($resource) {
  return $resource('/user_items/:id.json', {id:'@id'}, {update: {method: 'PUT'}});
  //return $resource('/issues/:id', {id:'@id'}, {update: { method: 'PUT' }});
}]);
