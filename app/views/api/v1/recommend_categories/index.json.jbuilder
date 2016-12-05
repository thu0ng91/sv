json.array!(@categories) do |category|
  json.id category.id
  json.name category.name
  json.novels category.novels.sample(6), :id, :name, :author, :pic, :article_num, :last_update, :is_serializing

end