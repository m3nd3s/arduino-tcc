module ApplicationHelper

  def current_css(controller)
    controller_name.eql?(controller.to_s) ? "active" : ""
  end

  def meta_refresh_tag
    sc = SystemConfiguration.first
    time = sc.refresh_interval if sc
    time ||= 1
    content_tag :meta, :'http-equiv' => "refresh", :content => time
  end

end
