module ApplicationHelper

  def current_css(controller)
    controller_name.eql?(controller.to_s) ? "active" : ""
  end

end
