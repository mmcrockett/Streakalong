Date.prototype.ago = function(days)
{
  return new Date(this.valueOf() + (24 * 60 * 60 * 1000) * -days);
};
