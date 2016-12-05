# encoding: utf-8
class Crawler::Ck101
  include Crawler

  def crawl_articles novel_id
    novel = Novel.select("id,num,name").find(novel_id)
    if @page_html.css(".pg a").last.nil?
      article = Article.new
      article.novel_id = novel_id
      article.link = @page_url
      article.title = '全'
      novel = Novel.select("id,num,name").find(novel_id)
      article.subject = novel.name
      article.save
      ArticleWorker.perform_async(article.id)
      return
    end
    last_node_url = @page_html.css(".pg a").last.previous[:href]
    /thread-(\d*)-(\d*)-\d*/ =~ last_node_url
    if $2!= nil
      (0..$2.to_i).each do |page|
        if (page == 0)
          url = @page_url
        elsif (page == 1)
          url = "http://ck101.com/forum.php?mod=threadlazydata&tid=" + $1
        else
          url = "http://ck101.com/" + "thread-#{$1}-#{page}-2.html"
        end
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url)
        if (novel_id == 172) && article
          ArticleWorker.perform_async(article.id)
        end
        next if article

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url
          article.title = "#{page}"
          article.subject = novel.name
          article.num = novel.num + 1
          novel.num = novel.num + 1
          novel.save
          # puts node.text
          article.save
        end
        ArticleWorker.perform_async(article.id)
      end
    else
      url = "http://ck101.com/" + last_node_url.gsub(/&page=\d*/,'&page=')
      /&page=(\d*)/ =~ last_node_url
      (0..$1.to_i).each do |page|
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + page.to_s)
        if (novel_id == 1680 || 172) && article
          ArticleWorker.perform_async(article.id)
        end
        next if article

        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = url + page.to_s
          article.title = "#{page}"
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
    node = @page_html.css(".t_f")
    text = node.text.strip
    text = text
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end