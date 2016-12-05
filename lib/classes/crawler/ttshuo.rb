# encoding: utf-8
class Crawler::Ttshuo
  include Crawler

  def crawl_articles novel_id
    nodes = @page_html.css(".ChapterList_Item a")
    do_not_crawl_from_link = true
    from_link = (FromLink.find_by_novel_id(novel_id).nil?) ? nil : FromLink.find_by_novel_id(novel_id).link
    nodes.each do |node|      
      next unless node[:href]
      do_not_crawl_from_link = false if crawl_this_article(from_link,node[:href])
      next if do_not_crawl_from_link
      
      article = Article.select("articles.id, is_show, title, link, novel_id, subject, num").find_by_link("http://www.ttshuo.com" + node[:href])
      next if article

      unless article 
        article = Article.new
        article.novel_id = novel_id
        article.link = "http://www.ttshuo.com" + node[:href]
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
    node = @page_html.css(".detailcontent")
    node_name = node[0][:classname] if node.present?
    if node.blank?
      node = @page_html.css(".NovelTxt")
      node_name = node[0][:pageid]
    end
    node = @page_html.css("#NovelTxt .tb") if node.empty?
    node.css("a").remove
    node.css("script,.tb#{node_name},span").remove
    text = change_node_br_to_newline(node)
    text = text.gsub("本作品来自天天小说网(www.ttshuo.com)","")
    text = text.gsub("大量精品小说","")
    text = text.gsub("永久免费阅读","")
    text = text.gsub("敬请收藏关注","")
    text = text.gsub("∥wwW。tTsHUO。coM #天#天！小#说#网?","")
    text = ZhConv.convert("zh-tw", text.strip, false)
    raise 'Do not crawl the article text ' unless isArticleTextOK(article,text)
    ArticleText.update_or_create(article_id: article.id, text: text)
  end

end