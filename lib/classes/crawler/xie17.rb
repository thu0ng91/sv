# encoding: utf-8
class Crawler::Xie17
  include Crawler
  include Capybara::DSL

  def crawl_articles novel_id
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    nodes = @page_html.css(".content").children
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node| 
      if(node[:class]=="juan")
        subject = ZhConv.convert("zh-tw",node.text.strip.gsub(".",""),false)
      elsif(node.name == "table")
        a_nodes = node.css("a")
        a_nodes.each do |a_node|
          do_not_crawl_from_link = false if crawl_this_article(from_link,a_node[:href])
          next if do_not_crawl_from_link
          url = "http://xiaoshuo.17xie.com" + a_node[:href]
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
    require 'capybara'
    require 'capybara/dsl'

    Capybara.current_driver = :selenium
    Capybara.app_host = "http://xiaoshuo.17xie.com"
    page.visit(article.link.gsub("http://xiaoshuo.17xie.com",""))
    text = page.find('.content').native.text
    text = ZhConv.convert("zh-tw", text,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end