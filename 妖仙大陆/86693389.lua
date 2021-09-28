

local _M = {}
_M.__index = _M



local function Create()
	local ret = {}
  setmetatable(ret, _M)
  return ret
end

return {Create = Create}
