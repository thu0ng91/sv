class RecommendCategoryNovelShipsController < ApplicationController  
  def destroy
    ship = RecommendCategoryNovelShip.find(params[:id])
    ship.destroy
    redirect_to :controller => 'recommend_categories', :action => 'show', id: ship.recommend_category_id
  end

  def new
    @ship = RecommendCategoryNovelShip.new
  end

  def create
    ship = RecommendCategoryNovelShip.new(params[:recommend_category_novel_ship])
    ship.save if ship.novel
    redirect_to :controller => 'recommend_categories', :action => 'show', id: ship.recommend_category_id
  end
end
