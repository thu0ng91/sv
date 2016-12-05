# encoding: utf-8
class Crawler::Linovel
  include Crawler
  include Capybara::DSL

  def crawl_articles novel_id
    nodes = @page_html.css(".volume")
    do_not_crawl = true
    nodes.each do |node|
      subject = ZhConv.convert("zh-tw",node.css("h3").text.gsub("\n","").gsub("\r","").gsub("\t",""),false)
      a_nodes = node.css(".chaps a")
      a_nodes.each do |a_node|
        next unless a_node[:href]

        if novel_id == 20207
          do_not_crawl = false if a_node[:href] == "/book/read?chapterId=46318&volId=5839&bookId=1461"
          next if do_not_crawl
        end

        if novel_id == 6874
          do_not_crawl = false if a_node[:href] == "/book/read?chapterId=53077&volId=6609&bookId=332"
          next if do_not_crawl
        end

        if novel_id == 7074
          do_not_crawl = false if a_node[:href] == "/book/read?chapterId=34469&volId=4422&bookId=594"
          next if do_not_crawl
        end

        if novel_id == 7383
          do_not_crawl = false if a_node[:href] == "/book/read?chapterId=34763&volId=4459&bookId=213"
          next if do_not_crawl
        end

        if novel_id == 11882
          do_not_crawl = false if a_node[:href] == "/book/read?chapterId=26595&volId=3414&bookId=946"
          next if do_not_crawl
        end

        if novel_id == 22355
          do_not_crawl = false if a_node[:href] == "/book/read?chapterId=55631&volId=6874&bookId=1607"
          next if do_not_crawl
        end

        if novel_id == 22543
          do_not_crawl = false if a_node[:href] == "/book/read?chapterId=55836&volId=6899&bookId=1777"
          next if do_not_crawl
        end

        if novel_id == 22583
          do_not_crawl = false if a_node[:href] == "/book/read?chapterId=33510&volId=4308&bookId=1150"
          next if do_not_crawl
        end

        if novel_id == 22605
          do_not_crawl = false if a_node[:href] == "/book/read?chapterId=38551&volId=4923&bookId=1326"
          next if do_not_crawl
        end

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

    node = @page_html.css(".content")
    node.css("script,a").remove
    text = change_node_br_to_newline(node).strip
    text = ZhConv.convert("zh-tw", text.strip, false)

    if text.length < 100
      imgs = @page_html.css(".content img")
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