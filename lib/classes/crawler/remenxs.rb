# encoding: utf-8
class Crawler::Remenxs
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".novel_list a")
    next_article = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      if novel_id == 18000
        next_article = false if node.text.strip.index("5037")
        next if next_article
      end
      if novel_id == 20344
        next_article = false if node.text.strip.index("4085")
        next if next_article
      end

      if novel_id == 20703
        next_article = false if node.text.strip.index("798")
        next if next_article
      end

      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(node[:href])
      next if article
      next unless /du_\d*/ =~ node[:href]

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save

        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css(".content")
    node.css("a,script").remove
    text = change_node_br_to_newline(node).strip
    text = text.gsub("本章由热门小说网(www.remenxs.com)","")
    text = text.gsub("提供免费阅读！","")
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end