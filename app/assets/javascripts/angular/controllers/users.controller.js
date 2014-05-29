app.controller('UsersController', ['$scope', '$http', 'User', function($scope, $http, User) {
  $scope.crypt       = new JSEncrypt();
  $http.get('/key.json').then(function(result) {$scope.crypt.setKey(result.data);});
  $scope.reset_data = function() {
    $scope.login_data = {password: ""};
    $scope.register_data = {password: ""};
    $scope.error = "";
  };
  $scope.reset_data();
  $scope.login = function() {
    var user = new User($scope.login_data);
    user.$login({password: $scope.crypt.encrypt(user.password)}, function(v){location.reload(true);}, function(v){$scope.reset_data();$scope.error = "Username or password incorrect.";});
  };
  $scope.register = function() {
    var user = new User($scope.register_data);
    user.$register(
      {password: $scope.crypt.encrypt(user.password)},
      function(v){location.reload(true);},
      function(v){
        $scope.reset_data();
        angular.forEach(v.data, function(v, k) {
            if ("" !== $scope.error) {
              $scope.error += " AND ";
            }
            $scope.error += k + " " + v[0];
          }
        );
      }
    );
  };
}]);
