# encoding: utf-8
class Crawler::Oursogo
  include Crawler

  def crawl_articles novel_id
    last_node = @page_html.css("#pgt .pg  a.last")[0]
    /thread-(\d*)-(\d*)-(\d*)/ =~ last_node[:href]
    (1..$2.to_i).each do |i|
      url = "http://oursogo.com/thread-" + $1 + "-" + i.to_s + "-" +$3 + ".html"
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url)
      next if article
      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url
        article.title = i.to_s
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        article.num = novel.num + 1
        novel.update_column(:num,novel.num + 1)
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css(".t_f")
    text = node.text.strip
    text = text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end