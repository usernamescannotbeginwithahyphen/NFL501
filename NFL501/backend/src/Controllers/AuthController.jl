module AuthController
using Genie, Genie.Requests, Genie.Renderer.Json
using JSON3, Dates, SHA, Bcrypt
using ..Models.User

function _hash_password(p::String)
  Bcrypt.hash(p)
end
function _verify(p::String, h::String)
  Bcrypt.verify(p, h)
end

function register!()
  body = String(Genie.Requests.body()); j = JSON3.read(body)
  username = String(get(j, "username", "")); password = String(get(j, "password", ""))
  if length(username) < 3 || length(password) < 8
    return json((:ok => false, :error => "Invalid username or password"), status=400)
  end
  exists = SearchLight.find(User; where="username = ?", values=[username])
  if !isempty(exists)
    return json((:ok => false, :error => "Username taken"), status=409)
  end
  rec = User(username=username, password_hash=_hash_password(password))
  SearchLight.save(rec)
  Genie.Sessions.set!(:uid, Int(rec.id))
  return json((:ok => true, :user => Dict(:id=>Int(rec.id), :username=>username)))
end

function login!()
  body = String(Genie.Requests.body()); j = JSON3.read(body)
  username = String(get(j, "username", "")); password = String(get(j, "password", ""))
  rows = SearchLight.find(User; where="username = ?", values=[username])
  if isempty(rows)
    return json((:ok => false, :error => "Invalid credentials"), status=401)
  end
  u = first(rows)
  if !_verify(password, u.password_hash)
    return json((:ok => false, :error => "Invalid credentials"), status=401)
  end
  Genie.Sessions.set!(:uid, Int(u.id))
  return json((:ok => true, :user => Dict(:id=>Int(u.id), :username=>u.username)))
end

function me!()
  uid = Genie.Sessions.get(:uid, nothing)
  if uid === nothing
    return json((:ok => true, :user => nothing))
  end
  u = SearchLight.findone(User, Int(uid))
  return json((:ok => true, :user => Dict(:id=>Int(u.id), :username=>u.username)))
end

function logout!()
  Genie.Sessions.set!(:uid, nothing)
  return json((:ok => true))
end

end
