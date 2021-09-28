local JSON = require"JSON"
local cjson = {
	encode = function (t) return JSON:encode(t) end,
	decode = function (s) return JSON:decode(s) end,
}

return cjson
