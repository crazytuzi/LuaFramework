local m = {}

setmetatable(m, {__index=
function (t, k)
	local v = rawget(t, k)
	if not v then 
		v = rawget(t, k)
		if not v then
			v = require("logic.data."..k)
			if v then
				rawset(t, k, v)
			else
				error(string.format("not find %sdata.lua", k))
			end
		end
	end
	return v
end})

return m

