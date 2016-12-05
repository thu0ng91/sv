# encoding: utf-8
class Crawler::Wenxiu
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".chapter_list .con li a")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(node[:href])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = node[:href]
        article.title = node.text.strip
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        article.num = novel.num + 1
        novel.update_column(:num,novel.num + 1)

        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#readcontent")
    node.css(".ad,.prevue,#adtxt0,script").remove
    text = change_node_br_to_newline(node).strip
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end