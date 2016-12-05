# encoding: utf-8
class Crawler::Bookbao
  include Crawler

  def crawl_articles novel_id
    novel = Novel.select("id,num,name").find(novel_id)
    last_node_url = @page_html.css("div[style='color:#FF00FF; font-size:14px; font-weight:bold;'] a").last[:href]
    /(.*&)yeshu=(\d*)/ =~ last_node_url
    node_num = $2
    /(.*&)yeshu=(\d*)/ =~ @page_url
    (0..node_num.to_i).each do |page|
      url = $1 + "yeshu=#{page}"
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url)
      if (novel_id == 1680 || 172) && article
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
        novel.update_column(:num,novel.num + 1)
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css(".ddd")
    node.css("script,a").remove
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end