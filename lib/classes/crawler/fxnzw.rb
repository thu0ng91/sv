# encoding: utf-8
class Crawler::Fxnzw
  include Crawler

  def crawl_articles novel_id
    url = "http://tw.fxnzw.com/"
    @page_html.css("#BookText ul li").last.remove
    @page_html.css("#BookText ul li").last.remove
    @page_html.css("#BookText ul li").last.remove
    nodes = @page_html.css("#BookText ul li a")
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      if novel_id == 20344
        do_not_crawl = false if node[:href] == "/fxnread/28485_8465360.html"
        next if do_not_crawl
      end
      if novel_id == 21685
        do_not_crawl = false if node[:href] == "/fxnread/42702_8494564.html"
        next if do_not_crawl
      end
      if novel_id == 478
        do_not_crawl = false if node[:href] == "/fxnread/14361_3967105.html"
        next if do_not_crawl
      end
      if novel_id == 23219
        do_not_crawl = false if node[:href] == "/fxnread/44891_8516619.html"
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
    text = @page_html.css("div[style=\"font-size: 20px; text-indent: 30px; line-height: 40px; width: 770px; margin: 0 auto;\"]").text.strip
    text = text.gsub("請記住:飛翔鳥中文小說網 www.fxnzw.com 沒有彈窗,更新及時 !","")
    text = text.gsub("()","")
    text = ZhConv.convert("zh-tw", text,false)

    if text.length < 100
      imgs = @page_html.css("div[style=\"font-size: 20px; text-indent: 30px; line-height: 40px; width: 770px; margin: 0 auto;\"] img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + get_article_url(img[:src]) + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end