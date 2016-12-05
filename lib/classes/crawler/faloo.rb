# encoding: utf-8
class Crawler::Faloo
  include Crawler

  def crawl_articles novel_id
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    nodes = @page_html.css(".centent").children
    do_not_crawl = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|

      if(node[:class]=="list")
        subject = ZhConv.convert("zh-tw",node.text.strip.gsub(".",""),false)
      else
        a_nodes = node.css("a")
        a_nodes.each do |a_node|
          url = a_node[:href]
          do_not_crawl = false if crawl_this_article(from_link,a_node[:href])
          next if do_not_crawl

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
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#content")
    node.css(".p_gonggao").remove
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip, false)
    if text.length < 80
      imgs = @page_html.css("#content img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版"
      text = text_img
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end