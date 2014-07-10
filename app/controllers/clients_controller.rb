class ClientsController < ApplicationController
  
  def index
    @clients = Client.all
  end
  
  def new
    @client = Client.new
  end
  
  def create
    client = Client.new
    client.subscribe(self)    
    client.create_me(params[:client])
    respond_to do |format|
      if @client.valid?
        format.html { redirect_to clients_path }
      else
        format.html { render action: "new" }
      end
    end      
    
  end
  
  def success_client_save_event(client)
    @client = client
    respond_to do |f|
      f.html { render 'index'}
    end
    
  end
  
end