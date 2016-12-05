# encoding: utf-8
class Crawler::Akxs6
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css("#readerlist a")
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      if novel_id == 23243
        do_not_crawl = false if node[:href] == '/2/2293/2964884.html'
        next if do_not_crawl
      end
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(node[:href]))
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = get_article_url(node[:href])
        article.title = ZhConv.convert("zh-tw",node.text.strip,false)
        novel = Novel.select("id,num,name").find(novel_id)
        article.subject = novel.name
        article.num = novel.num + 1
        novel.num = novel.num + 1
        novel.save
        article.save
      end
      ArticleWorker.perform_async(article.id)          
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    /www.akxs6.com\/\d*\/(\d*)\/(\d*)\.html/ =~ @page_url

    url = URI.parse("http://www.akxs6.com/akxs.php")
    option = {
              'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.84 Safari/537.36',
              'Cookie' => 'jieqiVisitId=article_articleviews%3D4835; JXM703301=1; JXD703301=1; showother=3; JXS703301=1; CNZZDATA1254121877=140561776-1465879430-%7C1465879430',
              'X-Requested-With' => 'XMLHttpRequest',
              'aid'=> $1,
              'cid' => $2
            }
    resp, data = Net::HTTP.post_form(url, option)
    text = resp.body.force_encoding("gbk")
    text.encode!("utf-8", :undef => :replace, :replace => "", :invalid => :replace)
    resp_page = Nokogiri::HTML(text)

    text = change_node_br_to_newline(resp_page).strip
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end