class NovelsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :require_admin, only: [:new, :create, :edit, :update, :index, :show, :destroy]

  def index
    @novels = Novel.select("id,name,author,is_show,category_id").includes(:category).paginate(:page => params[:page], :per_page => 20)
  end

  def search
    keyword = params[:search].strip
    keyword_cn = keyword.clone
    keyword_cn = ZhConv.convert("zh-tw",keyword_cn,false)
    @novels = Novel.search(keyword_cn).per_page(100).records.includes(:category).select("id,name,author,pic,article_num,last_update,is_serializing,is_show,category_id")
  end

  def update_novel
    novel = Novel.find(params[:novel_id])
    redirect_to :action => 'show', :id => novel.id, :page => 1
  end

  def show
    @novel = Novel.find(params[:id])
    @articles = Article.select("articles.id,title,subject,num,is_show, novel_id").where("novel_id = #{params[:id]} and is_show = true").order(sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 50).order("num ASC")
    @websites = CrawlerAdapter.adapter_map
  end

  def invisiable_articles
    @novel = Novel.find(params[:id])
    @articles = Article.select("articles.id,title,subject,num,is_show, novel_id").where("novel_id = #{params[:id]} and is_show = false").order(sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 50).order("num ASC")
    @websites = CrawlerAdapter.adapter_map
  end

  def edit
    @novel = Novel.find(params[:id])
  end

  def destroy
    @novel = Novel.find(params[:id])
    Article.delete_all("novel_id = #{@novel.id}")
    @novel.destroy
    redirect_to :controller => 'novels', :action => 'index'
  end

  def new
    @novel = Novel.new
    @websites = CrawlerAdapter.adapter_map
  end

  def create
    @novel = Novel.new(params[:novel])
    @websites = CrawlerAdapter.adapter_map
    if @novel.save
      redirect_to :action => 'show', :id => @novel.id, :page => 1
    else
      render :action => "new"
    end
  end

  def update
    @novel = Novel.find(params[:id])
    if @novel.update_attributes(params[:novel])
      redirect_to :action => 'show', :page => 1
    else
      render :action => "edit" 
    end
  end

  def set_all_articles_to_invisiable
    Article.update_all("is_show = false", "novel_id = #{params[:id]}")
    novel = Novel.find(params[:id])
    novel.update_num
    redirect_to novel_path(params[:id])
  end

  def set_artlcles_to_invisiable
    Article.update_all("is_show = false","novel_id = #{params[:id]} and num >= #{params[:num_from]} and num <= #{params[:num_to]}")
    novel = Novel.find(params[:id])
    novel.update_num
    redirect_to novel_path(params[:id],page: params[:page])
  end

  def change
    novel = Novel.find(params[:id])
    novel.link = params[:link][:new_link]
    novel.num = params[:link][:num]
    novel.save
    f = FromLink.find_or_initialize_by_novel_id(params[:id])
    f.link = params[:link][:from_link]
    f.save

    CrawlWorker.perform_async(params[:id])

    # CrawlWorker.perform_async(params[:id])
    redirect_to novel_path(params[:id],page: 1)
  end

  def recrawl_all_articles
    CrawlWorker.perform_async(params[:id])
    redirect_to novel_path(params[:id],page: 1)
  end

  def recrawl_blank_articles
    novel = Novel.find(params[:id])
    novel.recrawl_articles_text
    redirect_to novel_path(params[:id])
  end

  def auto_crawl
    novel_link = params[:novel_link]
    crawler = CrawlerAdapter.get_instance novel_link
    crawler.fetch novel_link
    novel_id = crawler.crawl_novel(params[:category_id])
    redirect_to novel_path(novel_id)
  end

  private

  def sort_column
    Article.column_names.include?(params[:sort]) ? params[:sort] : "is_show"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
