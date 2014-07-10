class UsersController < ApplicationController
  
  def index
  end
  
  def new 
    @user = User.new 
    respond_to do |format| 
      format.html 
    end 
  end
  
  def create
    @user = User.create_it(params)
    respond_to do |format|
      if @user.valid?
        format.html { redirect_to root_url, notice: "Signed Up" }
        format.json
      else
        format.html { render action: "new" }
        format.json
      end
    end
    
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])    
    @user.update_it(params)
    respond_to do |format|
      if @user.valid?
        format.html { redirect_to users_path }
        format.json
      else
        format.html { render action: "edit" }
        format.json
      end
    end
  end
  
  def me
    authenticate_with_http_basic do |u, p|
      client = AuthorisationHandler.new.valid_client(client_credentials: {client_id: u, client_secret: p})
      @user = client.get_user(access_code: params[:access_code])
      render 'me'
    end

  end
  
end