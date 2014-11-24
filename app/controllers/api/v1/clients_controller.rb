class Api::V1::ClientsController < Api::ApplicationController
  
  def index
    @clients = Client.all
  end
  
  def show
    @client = Client.find(params[:id])
  end
  
  def update
    
  end
  
end