# encoding: utf-8
class Crawler::Sj131
  include Crawler

  def crawl_articles novel_id
    url = @page_url.gsub("index.html","")
    subject = ""
    nodes = @page_html.css(".booklist dl").children
    nodes = @page_html.css(".dirbox dl").children unless nodes.present?
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|
      if node.name == "dt"
        subject = ZhConv.convert("zh-tw",node.text.strip,false)
      elsif (node.name == "dd" && node.css("a").present?)
        do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
        next if do_not_crawl_from_link

        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + node.children[0][:href])
        next if article

        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + node.children[0][:href]
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


    unless nodes.present?
      nodes = @page_html.css(".zjbox")
      nodes.each do |node|
        sub_nodes = node.children
        sub_nodes.each do |sub_node|
          if sub_node[:class] == "tt gtt"
            subject = ZhConv.convert("zh-tw",sub_node.text.strip,false)
          elsif (sub_node[:class] == "zjlist4" && sub_node.css("a").present?)
            a_nodes = sub_node.css("a")
            a_nodes.each do|a_node|
              article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + a_node[:href])
              next if article

              unless article 
              article = Article.new
              article.novel_id = novel_id
              article.link = url + a_node[:href]
              article.title = ZhConv.convert("zh-tw",a_node.text.strip,false)
              novel = Novel.select("id,num,name").find(novel_id)
              article.subject = subject
              article.num = novel.num + 1
              novel.num = novel.num + 1
              novel.save
              article.save
              end
              ArticleWorker.perform_async(article.id)
            end
          end
        end
      end
    end

    unless nodes.present?
      nodes = @page_html.css(".zjlist4 a")
      nodes.each do |node|
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url+ node[:href])
        next if article

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url+ node[:href]
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
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    if @page_html.css("#content").text != ""
      @page_html.css("#content a").remove
      article_text = ZhConv.convert("zh-tw",@page_html.css("#content").text.strip,false)
      article_text = article_text.gsub("如果您喜歡這個章節","")
      article_text = article_text.gsub("精品小說推薦","")
      text = article_text
    elsif @page_html.css(".contentbox").text != ""
      @page_html.css(".contentbox a").remove
      article_text = ZhConv.convert("zh-tw",@page_html.css(".contentbox").text.strip,false)
      article_text = article_text.gsub("如果您喜歡這個章節","")
      article_text = article_text.gsub("精品小說推薦","")
      text = article_text
    else
      @page_html.css("#table_container a").remove
      @page_html.css("#table_container span").remove
      article_text = ZhConv.convert("zh-tw",@page_html.css("#table_container").text.strip,false)
      article_text = article_text.gsub("如果您喜歡這個章節","")
      article_text = article_text.gsub("精品小說推薦","")
      text = article_text
    end
    if (text.length < 80 )
      imgs = @page_html.css("img.imagecontent")
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