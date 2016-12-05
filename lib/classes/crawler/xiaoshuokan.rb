# encoding: utf-8
class Crawler::Xiaoshuokan
  include Crawler

  def crawl_articles novel_id
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    nodes = @page_html.css(".booklist span")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node| 
      if(node[:class]=="v")
        subject = ZhConv.convert("zh-tw",node.text.gsub(".",""),false)
      else
        a_node = node.css("a")[0]
        do_not_crawl_from_link = false if crawl_this_article(from_link,a_node[:href])
        next if do_not_crawl_from_link

        url = "http://tw.xiaoshuokan.com" + a_node[:href]
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url)
        next if article
        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url
          article.title = ZhConv.convert("zh-tw",a_node.text.strip,false) 
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
    node = @page_html.css(".bookcontent")
    node.css("script").remove
    text = change_node_br_to_newline(node).strip
    text = text.gsub(/&(.*)WWW.3Zcn.net/,"")
    text = text.gsub(/&(.*)WWW.3Zcn.net/,"")
    text = text.gsub("三藏中文","")
    text = text.gsub("bsp","")
    text = text.gsub("Www.Xiaoshuokan.com","")
    text = text.gsub("好看小說網","")
    text = text.gsub("(本章免費)","")
    text = text.gsub("&n8","")
    text = text.gsub("ｏ","")
    text = text.gsub("&nWww.xiaoｓhuoｋａn.Com","")
    text = text.gsub("WWW.ｘｉａｏｓｈｕｏｋａｎ.ｃｏｍ","")

    if text.length < 250 || article.title.index("T")
      imgs = @page_html.css(".bookcontent .divimage img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + get_article_url(img[:src]) + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end

    unless isArticleTextOK(article,text)
      s = @page_html.css('script').text
      /data: {"bid":"(.*)","cid":"(.*)",c:"(.*)"}/ =~ s
      url = "http://soso2.xiaoshuokan.com/call/chapreadajax.ashx?bid=#{$1}&cid=#{$2}&c=big5"
      crawler = CrawlerAdapter.get_instance url
      crawler.fetch url
      text = change_node_br_to_newline(crawler.page_html).strip
    end

    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end