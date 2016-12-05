# encoding: utf-8
class Crawler::Yawen8
  include Crawler

  def crawl_articles novel_id
    url = @page_url
    nodes = @page_html.css("#list a")
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node| 
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      if novel_id == 24071
        do_not_crawl = false if node[:href] == '/dushi/32815/927973.html'
        next if do_not_crawl
      end
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(node[:href]))
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = get_article_url(node[:href])
        title = node.text.strip
        title = title.gsub("www.yawen8.com","")
        title = title.gsub("雅文言情小说","")
        title = title.gsub("()","")
        article.title = ZhConv.convert("zh-tw",title,false)
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
    node = @page_html.css("#content")
    node.css("script").remove
    article_text = ZhConv.convert("zh-tw",node.text.strip,false)

    if article_text.index('本章未完')
      nodes = @page_html.css("#pagelink a")
      nodes.each do |page_node|
        c = Crawler::NovelCrawler.new
        c.fetch @page_url.sub(/\d*\.html/,"")+page_node[:href]
        text = ZhConv.convert("zh-tw",c.page_html.css("div.txtc").text.strip)
        article_text += text
      end
    end

    article_text = article_text.gsub("［本章未完，請點擊下一頁繼續閱讀！］","")
    article_text = article_text.gsub("...   ","")
    text = article_text

    if (text.length < 150 )
      imgs = @page_html.css(".piccontent img")
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