



local _M = {}
_M.__index = _M
local role_bag
function _M.SetRoleBag(bag)
  role_bag = bag 
end

function _M.GetRoleBag(bag)
   return role_bag
end
return _M
