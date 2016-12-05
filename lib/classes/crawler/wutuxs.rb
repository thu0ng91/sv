# encoding: utf-8
class Crawler::Wutuxs
  include Crawler

  def crawl_articles novel_id

    nodes = @page_html.css("td.L a")
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node| 
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link

      if novel_id == 23179
        do_not_crawl = false if node[:href] == '/html/0/804/1465434.html'
        next if do_not_crawl
      end
      if novel_id == 20355
        do_not_crawl = false if node[:href] == '/html/2/2871/2990495.html'
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
        if novel_id == 23179
          article.num = novel.num + 1 + 6228294
        elsif novel_id == 20355
          article.num = novel.num + 1 + 7694084
        else
          article.num = novel.num + 1
        end
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
    node = @page_html.css("#contents")
    node.css("center").remove
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip, false)
    if text.length < 100
      imgs = @page_html.css("#contents .divimage img")
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