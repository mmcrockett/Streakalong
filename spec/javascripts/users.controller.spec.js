describe('UsersController', function() {
  beforeEach(angular.mock.module('Streakalong'));

  var $controller = null;
  var $scope      = null;

  beforeEach(angular.mock.inject(function(_$controller_, _$rootScope_){
    $scope = _$rootScope_.$new();
    $controller = _$controller_('UsersController', { $scope: $scope });
  }));

  describe('build_registration_error_message', function() {
    it('creates an error message from returned data', function() {
      var multi_e  = {data: {username: ["is bad"], password: ["is worse"]}};
      var single_e = {data: {username: ["is wrong"]}};
      expect($scope.error).toEqual("");
      $scope.build_registration_error_message(multi_e);
      expect($scope.error).toEqual("username is bad AND password is worse");
      $scope.build_registration_error_message(single_e);
      expect($scope.error).toEqual("username is wrong");
    });
  });
});
