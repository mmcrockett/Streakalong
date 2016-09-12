class V1Item < ActiveRecord::Base
  has_one :user_item
  belongs_to :item_type

  WEIGHT_ID      = 18
  WEIGHT_ID_STR  = "#{WEIGHT_ID}"
  MAX_NAV_ITEMS  = 20
  HEALTH_TYPE_0_IDS = {"18" => true, "21" => true, "22" => true, "23" => true, "26" => true}
  HEALTHSCORE_ID_STR = "0"

  def self.setup_item_nav(offset, filter, recent)
    offset *= MAX_NAV_ITEMS

    if (1 == filter)
      items  = V1Item.find(:all, :offset => offset, :limit => MAX_NAV_ITEMS, :order => 'item_type_id')
      count  = V1Item.count
    elsif (2 == filter)
      items  = V1Item.find(:all, :conditions => {:id => recent}, :limit => MAX_NAV_ITEMS, :order => 'id')
      count  = items.size
    else
      items  = V1Item.find(:all, :conditions => {:item_type_id => filter}, :offset => offset, :limit => MAX_NAV_ITEMS, :order => 'item_type_id, id')
      count  = items.size
    end

    return items, count
  end

  def self.containsWeightId(ids)
    return (true == ids.include?(V1Item::WEIGHT_ID_STR))
  end
end
