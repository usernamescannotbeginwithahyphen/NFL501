module User
using SearchLight

@kwdef mutable struct User <: SearchLight.AbstractModel
  id::DbId = DbId()
  username::String = ""
  password_hash::String = ""
end

end
