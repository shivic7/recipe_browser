class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  private

  def pantry_ingredient_ids
    session[:pantry_ingredient_ids] ||= []
  end

end
