# encoding: utf-8
class Crawler::Lightnovel
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("dd.mg-15")
    nodes.each do |node|
      subject = ZhConv.convert("zh-tw",node.css(".ft-24").text.gsub("\n","").gsub("\r","").gsub("\t",""),false)
      a_nodes = node.css(".inline a")
      a_nodes.each do |a_node|
        next unless a_node[:href]
        article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(a_node[:href] + "?charset=big5")
        next if article

        unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = a_node[:href] + "?charset=big5"
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
    node = @page_html.css("#J_view")
    text = change_node_br_to_newline(node)
    text = ZhConv.convert("zh-tw", text.strip, false)

    if text.length < 100
      imgs = @page_html.css(".lk-view-img img")
      text_img = ""
      imgs.each do |img|
        text_img = text_img + "http://lknovel.lightnovel.cn" + img["data-cover"] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end

    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end