# encoding: utf-8
class Crawler::Ttzw
  include Crawler

  def crawl_articles novel_id
    url = @page_url
    nodes = @page_html.css("#chapter_list").children
    novel = Novel.find(novel_id)
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node| 
      if(node[:class]=="chapter_list_chapter_title")
        subject = ZhConv.convert("zh-tw",node.text.strip,false)
      elsif(node[:class]=="chapter_list_chapter")
        a_node = node.css("a")[0]
        do_not_crawl_from_link = false if crawl_this_article(from_link,a_node[:href])
        next if do_not_crawl_from_link
        url = @page_url.gsub("index.html","") + a_node[:href]
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
    text = @page_html.css("#chapter_content script").text
    if text.index('outputImg')
      /\"(.*)\"/ =~ text
      text_img = "http://r.xsjob.net:88/novel" + $1 + "*&&$$*"
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    else
      /\"(.*)\"/ =~ text
      url = "http://r.xsjob.net:88/novel" + $1
      c = CrawlerAdapter.get_instance url
      c.fetch url
      text = c.change_node_br_to_newline(c.page_html).strip
      text = text.gsub("document.write(","")
      text = text.gsub("document.writeln('","")
      text = text.gsub("');","")
      text = ZhConv.convert("zh-tw", text.strip, false)
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
    sleep(10)
  end

end