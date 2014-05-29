app.factory('User', ['$resource', function($resource) {
  return $resource('/:action.json',
                   {action:'@action'},
                   {
                     register: { method: 'POST', params: {action: 'register'} }
                     ,login: { method: 'POST', params: {action: 'login'} }
                   }
                  );
}]);
