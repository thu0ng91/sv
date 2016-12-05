# encoding: UTF-8
class Api::ApiController  < ActionController::Base
  respond_to :json
  before_filter :check_format_json
  
  def check_format_json
    if request.format != :json
        render :status=>406, :json=>{:message=>"The request must be json"}
        return
    end
  end

  def promotion
    promotion = {:picture_link => nil, 
                 :link => nil,
                 :tilte => nil,
                 :description => nil,
                 :version => 1
    }

    render :json => promotion.to_json
  end

  def movieinfo_promotion
    promotion = {:picture_link => "http://ext.pimg.tw/jumplives/1352973893-4060856514.png?v=1352973903", 
                 :link => "http://goo.gl/zsybo",
                 :tilte => "幫電影時刻表評分",
                 :description => "歡迎到 Google Play 給電影時刻表中肯的建議與評價, 謝謝！",
                 :version => 1
    }

    render :json => promotion.to_json
  end

  def status_check
    render :status=>200, :json=>{:message=>"The request ok "}
  end

  def version_check
    render :status=>200, :json=>{ version: 63, update_link: "https://play.google.com/store/apps/details?id=com.novel.reader"}
  end

end