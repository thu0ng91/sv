# encoding: utf-8
class Crawler::Zizaidu
  include Crawler

  def crawl_articles novel_id
    url = @page_url.sub("index.html","")
    nodes = @page_html.css("div.uclist a")
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      if novel_id == 23463
        do_not_crawl = false if node[:href] == '14091296.html'
        next if do_not_crawl
      end
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + node[:href])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node[:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        /(\d*)/ =~ node[:href]
        article.num = $1.to_i
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    nodes = @page_html.css("#content")
    text  = change_node_br_to_newline(nodes).strip
    article_text = text.gsub("（最好的全文字小說網︰自在讀小說網 www.zizaidu.com）","")
    text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end