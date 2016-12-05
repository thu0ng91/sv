class RecommendCategoryNovelShip < ActiveRecord::Base
  # attr_accessible :recommend_category_id, :novel_id

  belongs_to :novel
  belongs_to :recommend_category
end
