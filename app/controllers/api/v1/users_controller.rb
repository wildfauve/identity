class Api::V1::UsersController < Api::ApplicationController
  
  def index
    @users = User.all
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def update
    
  end
  
end