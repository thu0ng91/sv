# encoding: utf-8
class Crawler::Dushi800
  include Crawler
  include Capybara::DSL

  def crawl_articles novel_id

    url = @page_url
    nodes = @page_html.css(".booklist span a")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:onclick])
      next if do_not_crawl_from_link
      
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(url + "**" +node[:onclick])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = url + "**" +node[:onclick]
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
    
    onclick = article.link.split("**")[1]
    /gotochap\((\d*),(\d*)\)/ =~ onclick
    chapid=($2.to_i-9)/2;
    url="http://www.dushi800.com" + '/view/'+$1+'/'+chapid.to_s+'.html';

    crawler = CrawlerAdapter.get_instance url
    crawler.fetch url

    text = crawler.change_node_br_to_newline (crawler.page_html.css('.bookcontent'))
    text = ZhConv.convert("zh-tw", text,false)
    
    if text.size < 100
      imgs = page.all('.divimage img')
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src] + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版APP"
      text = text_img
    end

    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end