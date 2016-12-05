# encoding: utf-8
class Crawler::Qidian
  include Crawler

  def crawl_articles novel_id
    novel = Novel.select("id,num,name").find(novel_id)
    subject = novel.name
    subject_nodes = @page_html.css("#content .title b")
    nodes = @page_html.css("#content .box_cont .list")
    nodes.each_with_index do |node,i|
      subject = ZhConv.convert("zh-tw",subject_nodes[i].text.strip,false)
      a_nodes = node.css("a")
      a_nodes.each do |a_node|
        url = "http://read.qidian.com/" + a_node[:href]
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
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("#content")

    if @page_url.index('big5')
      node.css("a,script").remove
    else
      nodes = @page_html.css("script")
      url = ""
      nodes.each do |node|
        url = node[:src] if (node[:src].index('txt')) if node[:src]
      end
      text = ''
      begin
        open(url){ |io|
            text = io.read
        }
      rescue
      end
      text.force_encoding("gbk")
      text.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
      text = text.gsub("document.write(","")
      text = text.gsub("<a href=http://www.qidian.com>起点中文网 www.qidian.com 欢迎广大书友光临阅读，最新、最快、最火的连载作品尽在起点原创！</a>');","")
      node = Nokogiri::HTML.parse text
    end

    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end