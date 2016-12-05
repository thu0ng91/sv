class Novel < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # attr_accessible :name, :author, :description, :pic, :category_id, :article_num, :last_update, :is_serializing, :is_category_recommend, :is_category_hot, :is_category_this_week_hot, :is_classic, :is_classic_action, :is_show, :link
  belongs_to :category
  has_many :articles

  scope :show, -> { where(:is_show => true)}

  mapping do
    indexes :name, type: 'string'
    indexes :author, type: 'string'
  end

  def as_indexed_json(options={})
    self.as_json(only: [:name,:author])
  end

  after_create :create_index
  after_update :update_index
  after_destroy :delete_index

  def recrawl_articles_text
    Article.where("novel_id = #{id} and is_show = true").select("id").find_in_batches(:batch_size => 100) do |articles|
      articles.each do |article|
        texts = ArticleText.select("id").where("article_id = #{article.id}")
        unless texts.present?
          if link.index('33yq')
            YqArticleWorker.perform_async(article.id)
          else
            ArticleWorker.perform_async(article.id)
          end
        end 
      end 
    end
  end

  def update_num
    self.article_num = articles.show.size.to_s + "篇"
    self.save
  end

  def create_index
    __elasticsearch__.index_document
  end

  def update_index
    __elasticsearch__.update_document
  end

  def delete_index
    __elasticsearch__.delete_document
  end
end
