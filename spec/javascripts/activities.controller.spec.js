describe('ActivitiesController', function() {
  beforeEach(angular.mock.module('Streakalong'));

  var $controller = null;
  var $scope      = null;
  var items = [{"id":0,"name":"fruit","kcal":100},{"id":1,"name":"vegetable","kcal":50},{"id":2,"name":"dairy","kcal":150},{"id":3,"name":"grain","kcal":200},{"id":4,"name":"protein","kcal":150},{"id":5,"name":"fried","kcal":150},{"id":6,"name":"sweet","kcal":250},{"id":7,"name":"snack","kcal":150},{"id":8,"name":"condiment","kcal":50},{"id":9,"name":"soda","kcal":150},{"id":10,"name":"diet_soda","kcal":0},{"id":11,"name":"sports_drink","kcal":125},{"id":12,"name":"coffee","kcal":50},{"id":13,"name":"tea","kcal":25},{"id":14,"name":"juice","kcal":100},{"id":15,"name":"water","kcal":0},{"id":16,"name":"alcohol","kcal":150},{"id":17,"name":"walk","kcal":-100},{"id":18,"name":"run","kcal":-200},{"id":19,"name":"workout","kcal":-150},{"id":20,"name":"bicycle","kcal":-200},{"id":21,"name":"swim","kcal":-200},{"id":22,"name":"weight","kcal":0},{"id":23,"name":"tobacco","kcal":0},{"id":24,"name":"toothbrush","kcal":0},{"id":25,"name":"floss","kcal":0},{"id":26,"name":"mouthwash","kcal":0}];

  beforeEach(angular.mock.inject(function(_$controller_, _$rootScope_){
    $scope = _$rootScope_.$new();
    $controller = _$controller_('ActivitiesController', { $scope: $scope });
    $scope.items = items;
    $scope.calorie_base[2000] = -1000;
    $scope.calorie_base[1000] = -2000;
    $scope.activities[1000] = [{"id":21942,"amount":5,"item_id":13,"item_name":"tea","date":"2016-08-31"},{"id":21943,"amount":2,"item_id":14,"item_name":"juice","date":"2016-08-31"},{"id":21945,"amount":1,"item_id":19,"item_name":"workout","date":"2016-08-31"},{"id":21943,"amount":2,"item_id":99,"item_name":"not valid","date":"2016-08-31"},];
  }));
  describe('item find returns item with id', function() {
    it('returns the first item with corresponding id', function() {
      expect($scope.find_item(22).name).toEqual("weight");
    });
  });
  describe('calories calculation', function() {
    it('returns base if there are no activities', function() {
      expect($scope.calories(2000)).toEqual(-1000);
    });
    it('returns null if there is no calorie base', function() {
      expect($scope.calories(999)).toEqual(null);
    });
    it('returns calculation if there is base and activities and ignore bad data', function() {
      expect($scope.calories(1000)).toEqual(-2000+5*25+2*100-150);
    });
  });
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
  describe('process_amount', function() {
    it("creates a new object with that value if one doesn't exist", function() {
      var date = 1111;
      var item_id = 20;
      $scope.activities[date] = [];
      $scope.process_amount('+1', item_id, date);
      expect($scope.activities[date][0].id).toEqual(undefined);
      expect($scope.activities[date][0].date).toEqual(date);
      expect($scope.activities[date][0].item_id).toEqual(item_id);
      expect($scope.activities[date][0].amount).toEqual(1);
    });
    it("modifies existing object if it exists", function() {
      var activity = {date:1111,item_id:20,id:99,amount:70};
      $scope.activities[activity.date] = [activity];
      $scope.process_amount('20', activity.item_id, activity.date);
      var newactivity = $scope.activities[activity.date][0];
      expect(newactivity.id).toEqual(activity.id);
      expect(newactivity.date).toEqual(activity.date);
      expect(newactivity.item_id).toEqual(activity.item_id);
      expect(newactivity.amount).toEqual(20);
      expect(newactivity.previous_amount).toEqual(70);
    });
    it('queues if a save is in progress', function() {
      var activity = {date:1111,item_id:20,id:99,amount:70};
      $scope.activities[activity.date] = [activity];
      $scope.thinking = 1;
      $scope.process_amount('+1', activity.item_id, activity.date);
      // Server would return the saved value.
      activity.amount = 70;
      $scope.activity_success(activity);
      expect($scope.activities[activity.date][0].amount).toEqual(71);
    });
  });
  describe('activity_failure', function() {
    it("resets the data and creates an error message", function() {
      var activity = {date:1111,item_id:20,id:99,amount:70};
      $scope.activities[activity.date] = [activity];
      $scope.process_amount('+1', activity.item_id, activity.date);
      expect(activity.amount).toEqual(71);
      var response = {config:{data:activity}};
      $scope.activity_failure(response);
      expect(activity.amount).toEqual(70);
      expect($scope.error).toEqual("Sorry, there was an issue saving data for 'bicycle' on '1111'.");
    });
  });
});
