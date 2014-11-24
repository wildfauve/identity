json.users @users do |user|
  json.name user.name
  json.email user.email
  json.metadata user.metadata do |meta|
    json.set! meta.name, meta.typed_value
  end
  json.id_references user.id_references do |idr|
    json.ref idr.ref
    json.link idr.link
    json.identifier idr.identifier
  end
  json._links do
    json.self do
      json.href api_v1_user_url user
    end
  end
end