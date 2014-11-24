json.kind "clients"
json.clients @clients do |client|
  json.name client.name
  json.client_id client.client_id
  json._links do
    json.self do
      json.href api_v1_client_url(client)
    end
  end
end