# encoding: utf-8
class Crawler::Yinyangdailiren
  include Crawler

  def crawl_articles novel_id
    subject = ""
    nodes = @page_html.css(".page-content")
    nodes.css("center, script").remove
    h2_nodes = nodes.css("h2")
    ul_nodes = nodes.css("ul")
    
    ul_nodes.each_with_index do |ul_node,i|
      subject = ZhConv.convert("zh-tw",h2_nodes[i].text.strip,false)
      ul_node.css("a").each do |a_node|
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(a_node[:href])
        next if article
        unless article 
          article = Article.new
          article.novel_id = novel_id
          article.link = a_node[:href]
          article.title = ZhConv.convert("zh-tw",a_node.text.strip,false)
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
    node = @page_html.css(".grid-12")
    node.css("script, a").remove
    text = node.text
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end