# encoding: utf-8
class Crawler::Ranwen
  include Crawler

  def fetch url
    @fake_browser_urls = ['www.akxs6.com','www.365xs.org','www.yqhhy.me','www.uukanshu.com','www.123yq.org','00xs.com','www.7788xiaoshuo.com',"book.rijigu.com","yueduxs.com","b.faloo.com","www.ttzw.com","www.8535.org","6ycn.net","www.readnovel.com","www.d586.com","www.fftxt.com","www.bixiage.com"]
    @do_not_encode_urls = ['ranwen.org','read.jd.com','feizw.com','nch.com.tw','www.feisuzw.com','aiweicn.com','ixs.cc','quledu.com','tw.xiaoshuokan.com','7788xiaoshuo.com','wcxiaoshuo.com','2dollars.com.tw','dushi800','59to.org','book.sfacg','ranwenba','shushu5','kushuku','feiku.com','daomubiji','luoqiu.com','kxwxw','txtbbs.com','tw.57book','b.faloo.com/p/','9pwx.com']
    @page_url = url.gsub(".net",".org")
    get_page(@page_url)  
  end

  def crawl_articles novel_id
    url = @page_url.gsub("index.html","")
    nodes = @page_html.css("div#list a")
    do_not_crawl = true
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      if novel_id == 5984
        do_not_crawl = false if node[:href] == '3639736.html'
        next if do_not_crawl
      end
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(node[:href]))
      next if article
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link(get_article_url(node[:href]).gsub(".org",
        ".net"))
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
        # puts node.text
        article.save
      end
      ArticleWorker.perform_async(article.id)
    end
    set_novel_last_update_and_num(novel_id)
  end

  def crawl_article article
    node = @page_html.css("div#content")
    node.css('script,#fenye,div[align=center],.ads,style').remove
    text = change_node_br_to_newline(node).strip
    if text.length < 150
      imgs = @page_html.css(".divimage img")
      text_img = ""
      imgs.each do |img|
          text_img = text_img + img[:src].gsub(".net",".org") + "*&&$$*"
      end
      text_img = text_img + "如果看不到圖片, 請更新至新版"
      text = text_img
    else
      text = ZhConv.convert("zh-tw", text,false)
    end
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

  def crawl_novel category_id
    link = @page_html.css("b a#m_reader")[0][:href]
    author = @page_html.css("td[height='20'][align='center'] a b").text.strip
    name = @page_html.css("b a#m_reader")[0][:alt]
    description = @page_html.css("#CrbsSum").text.strip
    pic = @page_html.css("img.picborder")[0][:src]
    is_serializing = (@page_html.css("td[height='20'][align='center'][width='19%']").text.strip == "连载中")
    novel =  Novel.find_by_link link
    unless novel
      novel = Novel.new
      novel.link = link
      novel.name = ZhConv.convert("zh-tw",name)
      novel.author = ZhConv.convert("zh-tw",author)
      novel.description = ZhConv.convert("zh-tw",description)
      novel.category_id = category_id
      novel.is_show = true
      novel.is_serializing = is_serializing
      novel.pic = pic
      novel.article_num = "?"
      novel.last_update = Time.now.strftime("%y-%m-%d")
      novel.save
      CrawlWorker.perform_async(novel.id)
    end
    novel
  end
# 1(魔法異界),2(仙武異能),3(言情敘事),4(時光穿越),5(科幻太空),6(靈異軍事),7(游戲體育),8(動漫日輕),9(曆史紀實),10(名著古典),11(科普其它),12(原創) 
  def crawl_hot_rank relation

    cs = Category.all.map(&:name)
    hash = Hash[cs.map.with_index.to_a]

    nodes = @page_html.css(".sf-grid tbody tr")
    nodes.each do |node|
      td_nodes = node.css("td")
      /\[(.*)\]/ =~ td_nodes[0].text
      category_name = ZhConv.convert("zh-tw",$1)
      category_id = hash[category_name] + 1
      novel_name = ZhConv.convert("zh-tw",td_nodes[1].text.strip)
      novel_link = td_nodes[1].css("a")[0][:href]
      novel =  Novel.find_by_link(novel_link)
      novel =  Novel.find_by_name(novel_name) unless novel
      begin
        unless novel
          crawler = CrawlerAdapter.get_instance novel_link
          crawler.fetch novel_link
          novel = crawler.crawl_novel category_id
        end

        if relation == "ThisWeekHotShip"
          novel.is_category_this_week_hot = true
          novel.save
        end

        if relation == "HotShip"
          novel.is_category_hot = true
          novel.save
        end

        ship = eval "#{relation}.new"
        ship.novel_id = novel.id
        ship.save
      rescue
      end
    end
  end

  def crawl_category_recommend_rank
    cs = Category.all.map(&:name)
    hash = Hash[cs.map.with_index.to_a]

    nodes = @page_html.css(".sf-grid tbody tr")
    nodes.each do |node|
      td_nodes = node.css("td")
      /\[(.*)\]/ =~ td_nodes[0].text
      category_name = ZhConv.convert("zh-tw",$1)
      category_id = hash[category_name]
      novel_name = ZhConv.convert("zh-tw",td_nodes[1].text.strip)
      novel_link = td_nodes[1].css("a")[0][:href]
      novel =  Novel.find_by_link(novel_link)
      novel =  Novel.find_by_name(novel_name) unless novel
      begin
        unless novel
          crawler = CrawlerAdapter.get_instance novel_link
          crawler.fetch novel_link
          novel = crawler.crawl_novel category_id
        end
        novel.is_category_recommend = true
        novel.save
      rescue
      end
    end
  end


end