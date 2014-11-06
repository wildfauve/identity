json.sub @user.id.to_s
json.email_verifier @user.email
json.preferred_username @user.name
json.metadata @user.metadata do |meta|
  json.set! meta.name, meta.typed_value
end
