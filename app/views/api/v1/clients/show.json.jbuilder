json.kind 'client'
json.name @client.name
json.client_id @client.client_id
json.secret @client.secret
json.direct_uri @client.redirect_uri
json.post_logout_redirect_uri @client.post_logout_redirect_uri
json.authorisations @client.authorisations do |auth|
  json.auth_code auth.auth_code
  json.access_code auth.access_code 
  json.state auth.state
  json.expires_in auth.expires_in
  json.time_created auth.time_created
  json.id_token auth.id_token
  json._links do 
    json.user do
      json.href api_v1_user_url(auth.user)
    end
  end  
end
json._links do
  json.self do
    json.href api_v1_client_url(@client)
  end
end