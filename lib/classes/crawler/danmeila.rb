# encoding: utf-8
class Crawler::Danmeila
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".catalog_list a")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
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
    @page_html.css("a,script").remove
    text = @page_html.css(".article_con").text.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8').strip
    article_text = ZhConv.convert("zh-tw",text,false)
    text = article_text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

  def crawl_novel(category_id)
    is_serializing = true
    is_serializing = false if @page_html.css(".cont h3")[0].text.include?("完本")
    @page_html.css(".cont h3")[0].css("span").remove
    img_link = get_article_url(@page_html.css(".titlepic img")[0][:src])
    name = @page_html.css(".cont h3")[0].text
    author = @page_html.css(".info dd a")[0].text
    description = change_node_br_to_newline(@page_html.css("#xs-text p")[1]).strip
    link = get_article_url(@page_html.css("a.btnHook")[1][:href])
    
    novel = Novel.new
    novel.link = link
    novel.name = ZhConv.convert("zh-tw",name,false)
    novel.author = ZhConv.convert("zh-tw",author,false)
    novel.category_id = category_id
    novel.is_show = true
    novel.is_serializing = is_serializing
    novel.last_update = Time.now.strftime("%m/%d/%Y")
    novel.article_num = "?"
    novel.description = description
    novel.pic = img_link
    novel.save
    CrawlWorker.perform_async(novel.id)
    novel.id
  end

end