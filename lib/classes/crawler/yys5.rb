# encoding: utf-8
class Crawler::Yys5
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".f_title > a")
    url = "http://bbs.yys5.com/"
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + node[:href])
      next if article
      next if node[:style]
      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node[:href]
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

    nodes = page_html.css("a.p_redirect")
    if nodes[1] && nodes[1].text == "››"
      url = "http://bbs.yys5.com/" + nodes[1][:href]
      crawler = CrawlerAdapter.get_instance url
      crawler.fetch url
      crawler.crawl_articles novel_id
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css(".t_msgfont")
    node.css("span").remove
    node.css("font[style='font-size:0px;color:#FAFAFA']").remove
    text = change_node_br_to_newline(node)
    text = ZhConv.convert("zh-tw", text.strip, false)

    if text.size < 100
      imgs = page.all('.t_attachlist img')
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end
    
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end