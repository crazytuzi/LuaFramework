local deviceFix = 0

if game.deviceFix then
	deviceFix = game.deviceFix
end

local function getConfig(key)
	return parseJson("config/" .. key .. ".json")
end

local config = slot1("ui")

for i, v in pairs(config) do
	if v.fixedX and v.xori then
		v.fixedX = v.fixedX + v.xori*display.cx
	end

	if v.fixedY and v.yori then
		v.fixedY = v.fixedY + v.yori*display.cy
	end

	if v.fixedX and v.xFix then
		v.fixedX = v.fixedX + v.xFix*deviceFix
	end
end

local default = getConfig("ui_default")

for i, v in pairs(default) do
	if v.x and v.xori then
		v.x = v.x + v.xori*display.cx
	end

	if v.y and v.yori then
		v.y = v.y + v.yori*display.cy
	end

	if v.x and v.xFix then
		v.x = v.x + v.xFix*deviceFix
	end
end

if VERSION_REVIEW then
	for i = #default, 1, -1 do
		if checkExist(default[i].key, "btnHelper", "btnGroup", "btnPanelStall") then
			table.remove(default, i)
		end
	end
end

for i = #default, 1, -1 do
	if checkExist(default[i].key, "btnGameCenter") and not MirSDKAgent:canOpenGameCenter() then
		table.remove(default, i)
	end
end

local default_pc = {
	{
		key = "btnFlyShoe",
		x = display.width - 360 - deviceFix,
		y = display.height - 64
	},
	{
		key = "btnPicIdentify",
		x = display.width - 280 - deviceFix,
		y = display.height - 64
	},
	{
		key = "btnChargeGift",
		x = display.width - 200 - deviceFix,
		y = display.height - 64
	},
	{
		key = "btnCustom1",
		y = 217,
		x = (display.cx + 50) - 150
	},
	{
		key = "btnCustom2",
		y = 217,
		x = (display.cx + 50) - 90
	},
	{
		key = "btnCustom3",
		y = 217,
		x = (display.cx + 50) - 30
	},
	{
		key = "btnCustom4",
		y = 217,
		x = display.cx + 50 + 30
	},
	{
		key = "btnCustom5",
		y = 217,
		x = display.cx + 50 + 90
	},
	{
		key = "btnCustom6",
		y = 217,
		x = display.cx + 50 + 150
	}
}

local function getData(key)
	for i, v in ipairs(default) do
		if v.key == key then
			return v
		end
	end

	return 
end

local function getConfig(data)
	local key = data.key2 or data.key

	for i, v in ipairs(config) do
		if v.key == key then
			if g_data.player.job == 0 and v.key == "btnPet" then
				return 
			end

			return v
		end
	end

	return 
end

return {
	config = config,
	default = default,
	getData = getData,
	getConfig = getConfig,
	default_pc = default_pc
}
