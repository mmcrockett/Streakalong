json.array!(@items) do |item|
  json.extract! item, :id, :name, :kcal
  json.image_src(asset_path("items/#{item[:name]}.png"))
end
