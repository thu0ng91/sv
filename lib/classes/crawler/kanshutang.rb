# encoding: utf-8
class Crawler::Kanshutang
  include Crawler

  def crawl_article article

    node = @page_html.css("#table_container")
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text,false)

    if text.size < 100
      imgs = @page_html.css("#table_container .divimage img")
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

  def crawl_articles novel_id

    url = @page_url.gsub("index.html","")
    nodes = @page_html.css(".dirbox a")
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name

    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      next unless node[:href]
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      if novel_id == 21845
        do_not_crawl = false if node[:href] == '4326921.html'
        next if do_not_crawl
      end
      if novel_id == 22925
        do_not_crawl = false if node[:href] == '4329865.html'
        next if do_not_crawl
      end
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + node[:href])
      next if article

      unless article 
      article = Article.new
      article.novel_id = novel_id
      article.link = url + node[:href]
      article.title = ZhConv.convert("zh-tw",node.text.strip,false)
      article.subject = subject
      /(\d+)\.html/ =~ node[:href]
      next if $1.nil?
      article.num = $1.to_i + novel.num
      # puts node.text
      article.save
      end
      # novel.num = article.num + 1
      # novel.save
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

end