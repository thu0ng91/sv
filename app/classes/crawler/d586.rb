# encoding: utf-8
class Crawler::D586
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".ml_main dd a")

    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name

    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      url = node[:href]
      url = @page_url + url unless node[:href].include?("d586")

      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url)
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
        article.subject = subject
        article.num = novel.num + 1
        novel.update_column(:num,novel.num + 1)
        article.save
      end
      # novel.num = article.num + 1
      # novel.save
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css(".content")
    node = @page_html.css(".yd_text2") unless node.present?
    node.css("a").remove
    node.css("script").remove
    text = change_node_br_to_newline(node)
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end