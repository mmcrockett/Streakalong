describe('SettingsController', function() {
  beforeEach(angular.mock.module('Streakalong'));

  var $controller = null;
  var $scope      = null;
  var Settings    = null;

  beforeEach(angular.mock.inject(function(_$controller_, _$rootScope_, _Settings_){
    $scope = _$rootScope_.$new();
    Settings = _Settings_;
    $controller = _$controller_('SettingsController', { $scope: $scope });
  }));

  describe('save', function() {
    it('calculates metric if settings are imperial', function() {
      $scope.settings = new Settings({height: 180});
      $scope.initialize('imperial');
      $scope.preferences = {};
      $scope.height_ft = 6;
      $scope.height_in = 5;
      $scope.save();
      expect($scope.settings.height).toEqual(180);
      $scope.preferences = {units:'imperial'};
      $scope.save();
      expect($scope.settings.height).toEqual(196);
    });
  });
  describe('calculate imperial height', function() {
    it('correctly sets height_in and height_ft from height in cm', function() {
      $scope.settings = {height: 180};
      $scope.set_imperial_height();
      expect($scope.height_ft).toEqual(5);
      expect($scope.height_in).toEqual(11);
      $scope.settings = {height: 183};
      $scope.set_imperial_height();
      expect($scope.height_ft).toEqual(6);
      expect($scope.height_in).toEqual(0);
    });
    it('leaves as null if no height exists', function() {
      $scope.settings = {};
      $scope.set_imperial_height();
      expect($scope.height_ft).toEqual(null);
      expect($scope.height_in).toEqual(null);
    });
  });
  describe('calculate metric height', function() {
    it('correctly sets height from height in ft and in as strings', function() {
      $scope.settings = {height: 165};
      $scope.height_ft = "5";
      $scope.height_in = "11";
      $scope.set_metric_height();
      expect($scope.settings.height).toEqual(180);
    });
    it('correctly sets height from height in ft and in', function() {
      $scope.settings = {height: 165};
      $scope.height_ft = 5;
      $scope.height_in = 11;
      $scope.set_metric_height();
      expect($scope.settings.height).toEqual(180);
      $scope.height_ft = 6;
      $scope.height_in = 0;
      $scope.set_metric_height();
      expect($scope.settings.height).toEqual(183);
    });
    it('leaves as null if no settings exist', function() {
      $scope.height_ft = 6;
      $scope.height_in = 0;
      $scope.set_metric_height();
      expect($scope.settings).toEqual(undefined);
    });
  });
  describe('height', function() {
    it('is consistently converted to metric for storage and back to imperial', function() {
      $scope.height_ft = 4;
      $scope.height_in = 10;
      $scope.settings = {height: null};

      _.times(20, function(i) {
        var starting_ft = $scope.height_ft;
        var starting_in = $scope.height_in;

        $scope.set_metric_height();
        $scope.set_imperial_height();

        expect($scope.height_ft).toEqual(starting_ft);
        expect($scope.height_in).toEqual(starting_in);

        $scope.height_in += 1;
        if ($scope.height_in >= $scope.IN_IN_FT()) {
          $scope.height_ft += 1;
          $scope.height_in  = 0;
        }
      });
    });
  });
});
