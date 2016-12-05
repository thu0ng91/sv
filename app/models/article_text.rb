class ArticleText < ActiveRecord::Base
  # attr_accessible :article_id, :text
  belongs_to :article

  def self.update_or_create opts
    at = ArticleText.find_or_initialize_by_article_id(opts[:article_id])
    at.text = opts[:text]
    at.save

    article = Article.find(opts[:article_id])
    article.touch
  end
end
