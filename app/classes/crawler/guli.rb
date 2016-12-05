# encoding: utf-8
class Crawler::Guli
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#detaillist a")
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      next unless node[:href]
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link("http://www.guli.cc" + node[:href])
      next if article

      unless article 
      article = Article.new
      article.novel_id = novel_id
      article.link = "http://www.guli.cc" + node[:href]
      article.title = ZhConv.convert("zh-tw",node.text.strip,false)
      article.subject = subject
      /\d+\/(\d+)\// =~ node[:href]
      next if $1.nil?
      article.num = $1.to_i + novel.num
      # puts node.text
      article.save
      end
      # novel.num = article.num + 1
      # novel.save
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end
  
  def crawl_article article
    text = change_node_br_to_newline(@page_html.css("div#content")).strip
    text = text.gsub("txtrightshow();","").strip
    text = ZhConv.convert("zh-tw", text,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
    sleep(5)
  end

end