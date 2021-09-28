local operate = {
	getConfig = function (key)
		if not operate[key] then
			operate[key] = parseJson("config/" .. key .. ".json")
		end

		return operate[key]
	end,
	init = function ()
		operate.hotKey = def.operate.getConfig("hotKey")
		operate.hotKeySet = def.operate.getConfig("hotKeySet")

		return 
	end
}

return operate
