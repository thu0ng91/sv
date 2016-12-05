# encoding: utf-8
class Crawler::Zwwx
  include Crawler

  def crawl_articles novel_id
    subject = ""
    nodes = @page_html.css(".book_article_texttable div")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node| 
      if node[:class] == "book_article_texttitle"
        subject = ZhConv.convert("zh-tw",node.text.strip,false)
      else
        inside_nodes = node.css("a")
        inside_nodes.each do |in_node|
          do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
          next if do_not_crawl_from_link
          article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(in_node[:href])

          next if article

          unless article 
            article = Article.new
            article.novel_id = novel_id
            article.link = in_node[:href]
            article.title = ZhConv.convert("zh-tw",in_node.text.strip,false)
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
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#content")
    text = node.text.strip
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end