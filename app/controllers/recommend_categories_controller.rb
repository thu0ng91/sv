class RecommendCategoriesController < ApplicationController  
  
  def index
    @categories = RecommendCategory.paginate(:page => params[:page], :per_page => 20)
  end

  def destroy
    @category = RecommendCategory.find(params[:id])
    RecommendCategoryNovelShip.delete_all("recommend_category_id = #{@category.id}")
    @category.destroy
    redirect_to :controller => 'recommend_categories', :action => 'index'
  end

  def edit
    @category = RecommendCategory.find(params[:id])
  end

  def update
    @category = RecommendCategory.find(params[:id])
    if @category.update_attributes(params[:recommend_category])
      redirect_to :action => 'index'
    else
      render :action => "edit" 
    end
  end

  def show
    @category = RecommendCategory.find(params[:id])
  end

  def new
    @category = RecommendCategory.new
  end

  def create
    category = RecommendCategory.new(params[:recommend_category])
    category.save
    redirect_to :controller => 'recommend_categories', :action => 'index'
  end
end
