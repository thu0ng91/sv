# encoding: utf-8
class Crawler::Piaotiancc
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".novel_list a")
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      if novel_id == 22869
        do_not_crawl = false if node[:href] == "/read/3220/10627169.html"
        next if do_not_crawl
      end
      if novel_id == 23315
        do_not_crawl = false if node[:href] == "/read/32574/10737785.html"
        next if do_not_crawl
      end
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(node[:href]))
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = get_article_url(node[:href])
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
    @page_html.css(".novel_content div, .novel_content script, .novel_content iframe").remove
    text = change_node_br_to_newline(@page_html.css(".novel_content")).strip
    if text.length < 100
      begin
        text = @page_html.css(".divimage img")[0][:src]
        text = text + "*&&$$*" + "如果看不到圖片, 請更新至新版"
      rescue Exception => e      
      end
    else
      text = ZhConv.convert("zh-tw", text,false)
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end