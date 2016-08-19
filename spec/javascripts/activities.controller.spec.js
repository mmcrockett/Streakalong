describe('ActivitiesController', function() {
  beforeEach(angular.mock.module('Streakalong'));

  var $controller = null;
  var $scope      = null;

  beforeEach(angular.mock.inject(function(_$controller_, _$rootScope_){
    $scope = _$rootScope_.$new();
    $controller = _$controller_('ActivitiesController', { $scope: $scope });
  }));
  describe('parse_statement', function() {
    it('takes numbers and makes them the value', function() {
      expect($scope.parse_statement("0", 100)).toEqual(0);
      expect($scope.error).toEqual("");
      expect($scope.parse_statement("400", 100)).toEqual(400);
      expect($scope.error).toEqual("");
    });
    it('ignores leading whitespace', function() {
      expect($scope.parse_statement("  126", 100)).toEqual(126);
      expect($scope.error).toEqual("");
    });
    it('reverts with error on trailing whitespace', function() {
      expect($scope.parse_statement("126  ", 100)).toEqual(100);
      expect($scope.error).toEqual($scope.INVALID_STATEMENT());
    });
    it('ignores statements that are too long', function() {
      var statement = "1";

      _.times($scope.MAX_STATEMENT_SIZE(), function(i) {statement += (i % 10);});

      expect($scope.parse_statement(statement, 100)).toEqual(100);
      expect($scope.error).toEqual($scope.TOO_LONG_STATEMENT());
    });
    it('parses leading - as subtraction', function() {
      expect($scope.parse_statement("-11", 100)).toEqual(100-11);
      expect($scope.error).toEqual("");
    });
    it('parses leading + as addition', function() {
      expect($scope.parse_statement("+11", 100)).toEqual(100+11);
      expect($scope.error).toEqual("");
    });
    it('parses a succession of + and - as if last takes precedence', function() {
      expect($scope.parse_statement("11+2-3-4+8", 100)).toEqual(11+2-3-4+8);
      expect($scope.error).toEqual("");
      expect($scope.parse_statement("+11+2-3-4+8", 100)).toEqual(100+11+2-3-4+8);
      expect($scope.error).toEqual("");
      expect($scope.parse_statement("11-+-+-2-3--4++8", 100)).toEqual(11-2-3-4+8);
      expect($scope.error).toEqual("");
    });
    it('rounds numbers after addition', function() {
      expect($scope.parse_statement("1.444+1.444", 100)).toEqual(3);
      expect($scope.error).toEqual("");
      expect($scope.parse_statement("1.50001", 100)).toEqual(2);
      expect($scope.error).toEqual("");
      expect($scope.parse_statement("1.49999", 100)).toEqual(1);
      expect($scope.error).toEqual("");
    });
  });
});
