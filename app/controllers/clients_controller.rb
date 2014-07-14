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
  end
  
  def edit
    @client = Client.find(params[:id])
  end
  
  def update
    client = Client.find(params[:id])
    client.subscribe(self)    
    client.update_me(params[:client])
  end
  
  def success_client_save_event(client)
    respond_to do |f|
      f.html { redirect_to clients_path}
    end
  end
  
  def failed_client_save_event(client)
    @client = client
    respond_to do |f|
      f.html { render '_form'}
    end

  end
  
end