describe('date_extension', function() {
  describe('timezone changes', function() {
    it('springs forward correctly', function() {
      monday   = new Date(2017, 2, 13, 0, 0, 0, 0);
      sunday   = new Date(2017, 2, 12, 0, 0, 0, 0);
      saturday = new Date(2017, 2, 11, 0, 0, 0, 0);
      expect(monday.ago(1)).toEqual(sunday);
      expect(sunday.ago(1)).toEqual(saturday);
      expect(saturday.ago(-1)).toEqual(sunday);
      expect(saturday.ago(-2)).toEqual(monday);
    });
    it('falls back correctly', function() {
      monday   = new Date(2017, 8, 6, 0, 0, 0, 0);
      sunday   = new Date(2017, 8, 5, 0, 0, 0, 0);
      saturday = new Date(2017, 8, 4, 0, 0, 0, 0);
      expect(monday.ago(1)).toEqual(sunday);
      expect(sunday.ago(1)).toEqual(saturday);
      expect(saturday.ago(-1)).toEqual(sunday);
      expect(saturday.ago(-2)).toEqual(monday);
    });
  });
});
