class Api::V1::UsersController < Api::ApplicationController
  
  def index
    @users = User.all
  end
  
  def update
    
  end
  
end