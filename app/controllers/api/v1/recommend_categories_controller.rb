class Api::V1::RecommendCategoriesController < Api::ApiController

  def index
    @categories = RecommendCategory.select("id, name").all
  end
end
