# encoding: utf-8
class Crawler::Tianshi7
  include Crawler

  def crawl_articles novel_id
    url = @page_url.gsub("index.html","")
    subject = ""
    nodes = @page_html.css(".zhangjie").children
    nodes.each do |node|
      if node.name == "h3"
        subject = ZhConv.convert("zh-tw",node.text.strip,false)
      elsif (node[:href] != nil)
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(node[:href])
        if article
          article.is_show = true
          article.save
        end
        next if article

        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = node[:href]
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
    text = change_node_br_to_newline(@page_html.css(".article_content")).strip
    text.gsub!("\n \n ","\n")
    article_text = ZhConv.convert("zh-tw",text,false)
    text = article_text
    if text.length < 100
      imgs = @page_html.css(".article_content img")
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