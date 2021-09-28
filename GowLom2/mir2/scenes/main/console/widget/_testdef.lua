local deviceFix = 0

if game.deviceFix then
	deviceFix = game.deviceFix
end

local function getConfig(key)
	local configpath = "chkRandomUI/"

	if g_data.login:isChangeSkinCheckServer() then
		configpath = g_data.login:getChkConfigPath()
		local file = io.readfile(cc.FileUtils:getInstance():fullPathForFilename(configpath .. key .. ".json"))
		local config = json.decode(file)

		return config
	end

	return parseJson(configpath .. key .. ".json")
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

local default_pc = {
	{
		key = "btnCustom1",
		y = 200,
		x = (display.cx + 50) - 150
	},
	{
		key = "btnCustom2",
		y = 200,
		x = (display.cx + 50) - 90
	},
	{
		key = "btnCustom3",
		y = 200,
		x = (display.cx + 50) - 30
	},
	{
		key = "btnCustom4",
		y = 200,
		x = display.cx + 50 + 30
	},
	{
		key = "btnCustom5",
		y = 200,
		x = display.cx + 50 + 90
	},
	{
		key = "btnCustom6",
		y = 200,
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
