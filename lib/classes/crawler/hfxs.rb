# encoding: utf-8
class Crawler::Hfxs
  include Crawler

  def crawl_articles novel_id
    url = @page_url.gsub("index.html","")

    subject = ""
    nodes = @page_html.css("div.List").children
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|
      if node.name == "dt"
        subject = ZhConv.convert("zh-tw",node.text.strip,false)
      elsif (node.name == "dd" && node.children.size() == 1 && node.children[0][:href] != nil)
        do_not_crawl_from_link = false if crawl_this_article(from_link,node.children[0][:href])
        next if do_not_crawl_from_link

        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + node.children[0][:href])
        next if article

        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node.children[0][:href]
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
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
    @page_html.css("div.width script").remove
    text = @page_html.css("div.width").text.strip
    text = ZhConv.convert("zh-tw", text,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end