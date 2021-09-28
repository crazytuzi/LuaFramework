local UICommon = {}

function UICommon.getColorC4BByStr(color)
	local a = string.sub(color, 1, 2)
	local r = string.sub(color, 3, 4)
	local g = string.sub(color, 5, 6)
	local b = string.sub(color, 7, 8)
	return cc.c4b(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16), tonumber(a, 16))
end

function UICommon.getColorC3BByStr(color)
	local a = string.sub(color, 1, 2)
	local r = string.sub(color, 3, 4)
	local g = string.sub(color, 5, 6)
	local b = string.sub(color, 7, 8)
	return cc.c3b(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
end


return UICommon