app.controller('UsersController', ['$scope', 'User', function($scope, User) {
  $scope.reset_data = function() {
    $scope.login_data = {password: ""};
    $scope.register_data = {password: ""};
    $scope.error = "";
  };
  $scope.reset_data();
  $scope.reload = function(v) {
    location.reload(true);
  };
  $scope.login = function() {
    User.get($scope.login_data)
    .$promise
    .then($scope.reload)
    .catch(
      function(e) {
        $scope.reset_data();

        if (401 == e.status) {
          $scope.error = "Username or password incorrect.";
        } else {
          $scope.error = "Sorry, something went wrong...";
        }
      }
    );
  };
  $scope.build_registration_error_message = function(e) {
    $scope.error = "";
    angular.forEach(e.data, function(e, k) {
        if ("" !== $scope.error) {
          $scope.error += " AND ";
        }
        $scope.error += k + " " + e[0];
      }
    );
  };
  $scope.register = function() {
    User.save($scope.register_data)
    .$promise
    .then($scope.reload)
    .catch(
      function(e) {
        $scope.reset_data();
        if (422 == e.status) {
          $scope.build_registration_error_message(e);
        } else {
          $scope.error = "Sorry, something went awry...";
        }
      }
    )
  };
}]);
