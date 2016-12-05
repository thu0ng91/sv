# encoding: utf-8
class Crawler::Suixw
  include Crawler

  def crawl_articles novel_id
    subject = ""
    nodes = @page_html.css(".acss tr td")
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|
      if node[:class] == "vcss"
        subject = ZhConv.convert("zh-tw",node.text.strip,false)
      else
        a_node = node.css("a")[0]
        next if a_node.nil?
        do_not_crawl_from_link = false if crawl_this_article(from_link,a_node[:href])
        next if do_not_crawl_from_link

        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(a_node[:href]))
        next if article
        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = get_article_url(a_node[:href])
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
    @page_html.css("#content a").remove
    @page_html.css("#content script").remove
    node = @page_html.css("#content")
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text,false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end