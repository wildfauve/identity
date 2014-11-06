class Api::V1::MetadataController < Api::ApplicationController  
  
  def update
    meta_req = AuthorisationHandler.new
    meta_req.subscribe(self)
    meta_params = params.except(*request.path_parameters.keys, :metadatum)
    meta_req.update_meta(params: meta_params, access_code: request.headers['Authorization'])  
  end
  
  def failed_meta_request(auth)
    raise
  end
  
  def successful_meta_request(auth)
    render nothing: true
  end
  
end