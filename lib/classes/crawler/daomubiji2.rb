# encoding: utf-8
class Crawler::Daomubiji2
  include Crawler

  def crawl_articles novel_id
    subject = ""
    nodes = @page_html.css(".bg .mulu")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|
      subject = ZhConv.convert("zh-tw",node.css(".mulu-title").text.strip,false) 
      child_nodes = node.css(".box li a")
      child_nodes.each_with_index do |a_node,i|
        do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
        next if do_not_crawl_from_link

        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(@page_url + a_node[:href])
        next if article
        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = @page_url + a_node[:href]
          article.title = ZhConv.convert("zh-tw",a_node.text.strip,false)
          novel = Novel.select("id,num,name").find(novel_id)
          article.subject = subject
          article.num = novel.num + 1
          novel.num = novel.num + 1
          novel.save
          # puts node.text
          article.save
        end
        ArticleWorker.perform_async(article.id) 
      end
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css(".content-body")
    node.css("a").remove
    node.css(".shangxia").remove
    node.css(".cmt").remove
    node.css("script").remove
    node.css("span").remove
    text = node.text
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end