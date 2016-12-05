# encoding: utf-8
class Crawler::Cc5800
  include Crawler

  def crawl_articles novel_id

    @page_url = @page_url.gsub("index.html","")
    nodes = @page_html.css(".TabCss a")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(@page_url+ node[:href])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = @page_url+ node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    @page_html.css("#content a").remove
    text = @page_html.css("#content").text.strip
    text = text.gsub("*** 即刻参加58小说，和广大书友共享阅读乐趣！58小说永久地址：www.5800.cc ***","")
    text = ZhConv.convert("zh-tw", text,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end