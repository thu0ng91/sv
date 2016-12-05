# encoding: utf-8
class Crawler::Qizi
  include Crawler

  def crawl_articles novel_id
    url = @page_url.sub("index.html","")
    @page_html.css(".ListRow a").last
    @page_html.css(".ListRow a").last
    nodes = @page_html.css(".ListRow a")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link

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
        article.num = $1.to_i + novel.num
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end 
    set_novel_last_update_and_num(novel_id)     
  end

  def crawl_article article
    node = @page_html.css(".txt")
    node.css("a").remove
    node.css("script").remove
    text = change_node_br_to_newline(node)
    text = text.gsub("朋友..!","")
    text = text.gsub("www.qizi.cc","")
    text = text.gsub("棋子小说网","")
    text = text.gsub("据说时常阅读本站,可增加艳遇哦","")
    text = text.gsub("欢迎你","")
    text = text.gsub("最快更新","")
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end