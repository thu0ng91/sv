# encoding: utf-8
class Crawler::Sfacg
  include Crawler

  def crawl_articles novel_id
    @page_html.css("div.list_menu_title .Download_box").remove
    @page_html.css("div.list_menu_title a").remove
    subjects = @page_html.css("div.list_menu_title")
    subject_titles = []

    subjects.each do |subject|
      text = subject.text
      text = text.gsub("【】","")
      text = text.gsub("下载本卷","")
      subject_titles << ZhConv.convert("zh-tw",text.strip,false)
    end

    num = @page_html.css(".list_Content").size()
    index = 0
    do_not_crawl_from_link = true
    while index < num do
      nodes = @page_html.css(".list_Content")[index].css("a")
      from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
      nodes.each do |node|   
        next unless node[:href]
        
        do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
        next if do_not_crawl_from_link
        break if node[:href].include? "vip"
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link("http://book.sfacg.com" + node[:href])
        next if article

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = "http://book.sfacg.com" + node[:href]
          article.title = ZhConv.convert("zh-tw",node.text.strip,false)
          novel = Novel.select("id,num,name").find(novel_id)
          article.subject = subject_titles[index]
          article.num = novel.num + 1
          novel.num = novel.num + 1
          novel.save
            # puts node.text
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end
      index = index +1        
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#ChapterBody")
    text = change_node_br_to_newline(node).strip
    
    if text.gsub("\n","").gsub(" ","").length < 50
      url = "http://book.sfacg.com"
      imgs = @page_html.css("#ChapterBody img")
      text_img = ""
      imgs.each do |img|
        if img[:src].index("ttp://")
          text_img = text_img + img[:src] + "*&&$$*"
        else
          text_img = text_img + url + img[:src] + "*&&$$*"
        end
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版"
      text = text_img
    else
      text = ZhConv.convert("zh-tw", text,false)
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

  def crawl_novel(category_id)
    img_link = @page_html.css("li.cover img")[0][:src]
    name = @page_html.css("li.cover img")[0][:title]
    is_serializing = false
    is_serializing = true if @page_html.css(".synopsises_font").text.index("连载中")
    author = @page_html.css(".synopsises_font a")[1].text
    des_node = @page_html.css(".synopsises_font li")[1]
    des_node.css("img,span,script,a").remove
    description = change_node_br_to_newline(des_node).strip
    link = @page_url + "MainIndex/"
    
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