json.users @users do |user|
  json.name user.name
  json.email user.email
  json.metadata user.metadata do |meta|
    json.set! meta.name, meta.typed_value
  end
  json._links do
    json.self do
      json.href api_v1_user_url user
    end
  end
end