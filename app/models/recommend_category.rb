class RecommendCategory < ActiveRecord::Base
  # attr_accessible :name

  has_many :recommend_category_novel_ships
  has_many :novels, :through => :recommend_category_novel_ships
  
end
