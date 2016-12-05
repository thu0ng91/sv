class Article < ActiveRecord::Base
  # attr_accessible :novel_id, :text, :link, :title, :subject, :num, :is_show
  belongs_to :novel
  scope :by_id_desc, -> {order('id DESC')}
  scope :by_num_desc, -> {order('num DESC')}
  scope :by_num_asc, -> {order('num ASC')}
  scope :show, -> {where(:is_show => true)}
  has_one :article_text
  delegate :text, to: :article_text, prefix: "article_all", :allow_nil => true

  scope :novel_articles, lambda { |novel_id| where('novel_id = (?)', novel_id).select('id') }

  def self.find_next_article (origin_article_id, origin_novel_id)
    articles = novel_articles(origin_novel_id).show
    (0..articles.length-2).each do |i|
      if(articles[i].id == origin_article_id)
        return Article.joins(:article_text).select('articles.id, novel_id, text, title,num').find(articles[i+1].id)
      end
    end
    return nil
  end

  def self.find_previous_article (origin_article_id, origin_novel_id)
    articles = novel_articles(origin_novel_id).show
    (1..articles.length-1).each do |i|
      if(articles[i].id == origin_article_id)
        return Article.joins(:article_text).select('articles.id, novel_id, text, title,num').find(articles[i-1].id)
      end
    end
    return nil
  end
end
