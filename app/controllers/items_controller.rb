class ItemsController < ApplicationController
  def index
    @items = []

    Item::ALL.each do |item|
      @items << {:name => item, :id => Item.id(item), :kcal => Item.kcal(item)}
    end
  end
end
