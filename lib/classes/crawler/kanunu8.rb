# encoding: utf-8
class Crawler::Kanunu8
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.xpath("//tr[@bgcolor='#ffffff']//a")
    # url = @page_url.gsub("index.html","")
    # url = url.gsub(/\d*\.html/,"")
    
    nodes.each do |node|
      url = @page_url
      unless node[:href].index('book') || node[:href].index('files')
        url = @page_url.gsub("index.html","")
        url = url.gsub(/\d*\.html/,"")
      end

      unless (/^\// =~ node[:href]).nil?
        url = "http://www.kanunu8.com"
      end

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
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    text = @page_html.css("#content").text.strip
    unless text.size > 100
      text = @page_html.css("td[width='820']").text
    end
    text = ZhConv.convert("zh-tw", text,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

  def crawl_novels category_id
    
    nodes = @page_html.css("tr[bgcolor='#fff7e7'] a")
    nodes.each_with_index do |node,i|
      # next if i > 5
      # node = node.parent
      link = "http://www.kanunu8.com" + node[:href]
      author = @page_html.css("h2").text.strip.sub("作品集","")
      name = node.text.strip
      novel = Novel.find_by_link link
      if novel && novel.pic.blank?
        novel.pic = "http://www.kanunu8.com" + node.css("img")[0][:src] if node.css("img")[0]
        novel.save
      end
      if novel && novel.name.blank?
        novel.name = name if name.present?
        novel.save
      end
      unless novel
        novel = Novel.new
        novel.link = link
        novel.name = ZhConv.convert("zh-tw",name,false)
        novel.author = ZhConv.convert("zh-tw",author,false)
        novel.category_id = category_id
        novel.is_show = true
        novel.is_serializing = 0
        novel.last_update = Time.now.strftime("%m/%d/%Y")
        novel.article_num = "?"
        crawl_novel_description link,novel
        novel.save
        CrawlWorker.perform_async(novel.id)
      end
    end
  end

  def crawl_novel_description link, novel
    c = Crawler::Kanunu8.new
    c.fetch link
    novel.description = ZhConv.convert("zh-tw",c.page_html.css(".p10-24").text.strip,false)
  end

end