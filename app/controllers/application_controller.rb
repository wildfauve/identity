class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception
  
  helper_method :current_user
  
  before_filter :current_user
  
  rescue_from Exceptions::ClientIdInvalid, with: :invalid_client_id
  
  def invaid_client_id
    raise
  end
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]["$oid"]) if session[:user_id]    
  end
    
end

