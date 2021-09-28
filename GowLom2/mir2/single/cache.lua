local current = ...
local cache = {
	verifyKey = "fgcq_version_check_key",
	safeKey = "fgcq_account_safe_key",
	serializeCaches = {}
}
local map_version = "0.0.1"
local minimap_version = "0.0.1"
local bigmap_version = "0.0.1"
local setting_version = "0.0.1"
local diy_version = "0.0.1"
local debug_version = "0.0.1"
local helper_version = "0.0.1"
local cg_version = "0.0.1"
local relation_version = "0.0.1"
local smelting_version = "0.0.1"
local firstopen_version = "0.0.1"
local serialize = require("mir2.data.serialize")
cache.checkAll = function ()
	print("checkAll")

	local tasks = {
		"cache",
		"verify",
		"history",
		"res",
		"data",
		"setting",
		"map",
		"minimap",
		"bigmap",
		"chat",
		"diy",
		"debug",
		"helper",
		"relation",
		"smelting"
	}

	local function check()
		if 0 < #tasks then
			cache["check_" .. tasks[1]](function ()
				table.remove(tasks, 1)
				check()

				return 
			end)
		end

		return 
	end

	slot1()

	return 
end
cache.check_verify = function (func)
	func()

	return 
end
cache.check_history = function (func)
	func()

	return 
end
cache.check_res = function (func)
	if not io.exists(device.writablePath .. "res") then
		ycFunction:mkdir(device.writablePath .. "res")
	end

	func()

	return 
end
cache.check_data = function (func)
	func()

	return 
end
cache.check_cache = function (func)
	if not io.exists(device.writablePath .. "cache") then
		ycFunction:mkdir(device.writablePath .. "cache")
	end

	func()

	return 
end
cache.getSerialize = function (filename)
	local ser = cache.serializeCaches[filename]

	if not ser then
		ser = serialize.new()

		ser.open(ser, filename, true)

		cache.serializeCaches[filename] = ser
	end

	local data = ser.data

	return data
end
cache.getAccount = function ()
	local data = io.readfile(device.writablePath .. "cache/ac")

	if data then
		return json.decode(crypto.decryptXXTEA(data, cache.safeKey))
	end

	return 
end
cache.saveAccount = function (ac, pw)
	if not pw then
		local account = cache.getAccount()

		if account and account.ac == ac then
			pw = account.pw
		end

		pw = pw or ""
	end

	io.writefile(device.writablePath .. "cache/ac", crypto.encryptXXTEA(json.encode({
		ac = ac,
		pw = pw
	}), cache.safeKey))

	return 
end
cache.saveLastPlayerName = function (name)
	name = name or ""

	io.writefile(device.writablePath .. "cache/lastPlayer", json.encode({
		lastPlayer = name
	}))

	return 
end
cache.getLastPlayerName = function ()
	local data = io.readfile(device.writablePath .. "cache/lastPlayer")

	if data then
		data = json.decode(data)

		if data then
			return data.lastPlayer
		end
	end

	return 
end
cache.saveLastServerId = function (serverIds)
	serverIds = serverIds or {}

	io.writefile(device.writablePath .. "cache/lastServers", json.encode(serverIds))

	return 
end
cache.getLastServerId = function ()
	local data = io.readfile(device.writablePath .. "cache/lastServers")

	if data then
		data = json.decode(data)

		return data
	else
		return {}
	end

	return 
end
cache.saveNewUpt = function (isNewUptFirstLogin)
	isNewUptFirstLogin = isNewUptFirstLogin or false

	io.writefile(device.writablePath .. "cache/lastUpt", json.encode({
		newUpt = isNewUptFirstLogin
	}))

	return 
end
cache.getNewUpt = function ()
	local data = io.readfile(device.writablePath .. "cache/lastUpt")

	if data then
		data = json.decode(data)

		return data.newUpt
	else
		return false
	end

	return 
end
cache.check_setting = function (func)
	if not io.exists(device.writablePath .. "cache/setting" .. setting_version) then
		ycFunction:mkdir(device.writablePath .. "cache/setting" .. setting_version)
	end

	func()

	return 
end
cache.genSettingPath = function (playerName, key)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")
	key = crypto.encodeBase64(key)
	local dirPath = device.writablePath .. "cache/setting" .. setting_version

	return string.format("%s/%s/%s", dirPath, playerName, key), playerName, key, dirPath
end
cache.getSetting = function (playerName, key)
	local data = io.readfile(cache.genSettingPath(playerName, key))

	if data then
		return json.decode(data)
	end

	return 
end
cache.saveSetting = function (playerName, key)
	local settingPath, playerName, _, dirPath = cache.genSettingPath(playerName, key)
	local path = string.format("%s/%s", dirPath, playerName)

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	io.writefile(settingPath, json.encode(g_data.setting[key]))

	return 
end
cache.removeSetting = function (playerName, key)
	os.remove(cache.genSettingPath(playerName, key))

	return 
end
cache.getCustoms = function (playerName)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")
	local dirPath = device.writablePath .. "cache/customItem"
	local data = io.readfile(string.format("%s/%s", dirPath, playerName))

	if data then
		return json.decode(data)
	end

	return 
end
cache.saveCustoms = function (playerName)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")
	local dirPath = device.writablePath .. "cache/customItem"

	if not io.exists(dirPath) then
		ycFunction:mkdir(dirPath)
	end

	local path = string.format("%s/%s", dirPath, playerName)

	io.writefile(path, json.encode(g_data.bag.customs))

	return 
end
cache.getHotKey = function (playerName)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")
	local dirPath = device.writablePath .. "cache/hotKey"
	local data = io.readfile(string.format("%s/%s", dirPath, playerName))

	if data then
		return json.decode(data)
	end

	return 
end
cache.saveHotKey = function (playerName)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")
	local dirPath = device.writablePath .. "cache/hotKey"

	if not io.exists(dirPath) then
		ycFunction:mkdir(dirPath)
	end

	local path = string.format("%s/%s", dirPath, playerName)

	io.writefile(path, json.encode(g_data.hotKey.keyInfos))

	return 
end
cache.copy_map = function ()
	if device.platform == "android" then
		local mapVersionPath = device.writablePath .. "res/map" .. map_version .. "/version"
		local mapZipPath = device.writablePath .. "res/map.zip"

		if io.exists(mapVersionPath) and io.exists(mapZipPath) then
			return 
		end

		local data, md5 = ycFunction:getFileData("map.zip", true)

		if data and md5 then
			io.writefile(mapZipPath, data)

			if crypto.md5file(mapZipPath) == md5 then
				io.writefile(mapVersionPath, "")
			end
		end

		cc.FileUtils:getInstance():purgeCachedEntries()
	end

	return 
end
cache.check_map = function (func)
	if not io.exists(device.writablePath .. "res/map" .. map_version) then
		ycFunction:mkdir(device.writablePath .. "res/map" .. map_version)
	end

	cache.copy_map()
	func()

	return 
end
cache.getMapFilePath = function (mapid)
	return device.writablePath .. "res/map" .. map_version .. "/" .. string.lower(mapid) .. ".map"
end
cache.unzipMapFile = function (mapid)
	local path = cache.getMapFilePath(mapid)

	if io.exists(path) then
		return 
	end

	cache.copy_map()

	local zipPath = cc.FileUtils:getInstance():fullPathForFilename("map.zip")

	return ycFunction:unzipWithFilename(zipPath, string.lower(mapid) .. ".map", path, true)
end
cache.minimapPath = function ()
	return device.writablePath .. "cache/minimap" .. minimap_version .. "/"
end
cache.check_minimap = function (func)
	local path = cache.minimapPath()

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	func()

	return 
end
cache.minimapFullPath = function (minimapID)
	return cache.minimapPath() .. minimapID .. ".png"
end
cache.getMinimap = function (minimapID)
	local path = cache.minimapFullPath(minimapID)

	if io.exists(path) then
		cc.Director:getInstance():getTextureCache():removeTextureForKey(path)

		return cc.Director:getInstance():getTextureCache():addImage(path)
	end

	return 
end
cache.check_bigmap = function (func)
	if not io.exists(device.writablePath .. "cache/bigmap" .. bigmap_version) then
		ycFunction:mkdir(device.writablePath .. "cache/bigmap" .. bigmap_version)
	end

	func()

	return 
end
cache.getBigmap = function (key)
	local data = io.readfile(device.writablePath .. "cache/bigmap" .. bigmap_version .. "/" .. key)

	if data then
		return json.decode(data)
	end

	return 
end
cache.saveBigmap = function (key)
	io.writefile(device.writablePath .. "cache/bigmap" .. bigmap_version .. "/" .. key, json.encode(g_data.bigmap.maps[key]))

	return 
end
cache.check_chat = function (func)
	local path = device.writablePath .. "cache/chat/"

	if io.exists(path) then
		rmdir(path)
	end

	ycFunction:mkdir(path)
	ycFunction:mkdir(path .. "wav")
	ycFunction:mkdir(path .. "amr")
	ycFunction:mkdir(path .. "pic")
	func()

	return 
end
cache.getVoiceWav = function ()
	return device.writablePath .. "cache/chat/wav/"
end
cache.getVoiceAmr = function ()
	return device.writablePath .. "cache/chat/amr/"
end
cache.getPicPathFull = function ()
	return device.writablePath .. "cache/chat/pic/"
end
cache.removePicTmp = function ()
	local path = cache.getPicTmp()

	if io.exists(path) then
		os.remove(path)
	end

	return 
end
cache.getPicTmp = function ()
	return device.writablePath .. "cache/chat/pic/tmp.png"
end
cache.diyPath = function ()
	return device.writablePath .. "cache/diy" .. diy_version .. "/"
end
cache.check_diy = function (func)
	local path = cache.diyPath()

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	func()

	return 
end

local function cryptoencodeBase64(k)
	if DEBUG ~= 0 then
		return k
	else
		return crypto.encodeBase64(k)
	end

	return 
end

local function cryptodecodeBase64(k)
	if DEBUG ~= 0 then
		return k
	else
		return crypto.decodeBase64(k)
	end

	return 
end

cache.removeDiy = function (playerName, key)
	playerName = crypto.encodeBase64(playerName .. g_data.select:getCurUserId())
	playerName = string.gsub(playerName, "/", "#")
	key = cryptoencodeBase64(key)
	local path = string.format("%s/%s/%s", cache.diyPath(), playerName, key)

	if io.exists(path) then
		os.remove(path)
	end

	return 
end
cache.getDiy = function (playerName, key)
	playerName = crypto.encodeBase64(playerName .. g_data.select:getCurUserId())
	playerName = string.gsub(playerName, "/", "#")
	key = cryptoencodeBase64(key)
	local path = string.format("%s/%s/%s", cache.diyPath(), playerName, key)
	local data = io.readfile(path)

	if data then
		return json.decode(cryptodecodeBase64(data))
	end

	return 
end
cache.saveDiy = function (playerName, key, value)
	playerName = crypto.encodeBase64(playerName .. g_data.select:getCurUserId())
	playerName = string.gsub(playerName, "/", "#")
	key = cryptoencodeBase64(key)
	local path = string.format("%s/%s", cache.diyPath(), playerName)

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	path = string.format("%s/%s", path, key)

	io.writefile(path, cryptoencodeBase64(json.encode(value)))

	return 
end
cache.check_helper = function (func)
	if not io.exists(device.writablePath .. "cache/helper" .. helper_version) then
		ycFunction:mkdir(device.writablePath .. "cache/helper" .. helper_version)
	end

	func()

	return 
end
cache.getHelper = function (key)
	local data = io.readfile(device.writablePath .. "cache/helper" .. helper_version .. "/" .. key)

	if data then
		return json.decode(data)
	end

	return 
end
cache.getHelperSerialize = function (key)
	local filename = device.writablePath .. "cache/helper" .. helper_version .. "/" .. key

	return cache.getSerialize(filename)
end
cache.saveHelper = function (key, data)
	io.writefile(device.writablePath .. "cache/helper" .. helper_version .. "/" .. key, json.encode(data))

	return 
end
cache.removeHelper = function (key)
	os.remove(device.writablePath .. "cache/helper" .. helper_version .. "/" .. key)

	return 
end
cache.debugPath = function ()
	return device.writablePath .. "cache/debug" .. debug_version .. "/"
end
cache.check_debug = function (func)
	local path = cache.debugPath()

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	func()

	return 
end
cache.getDebug = function (key)
	local path = cache.debugPath()
	local data = io.readfile(path .. key)

	if data then
		return json.decode(data)
	end

	return 
end
cache.saveDebug = function (key, value)
	local path = cache.debugPath()

	io.writefile(path .. key, json.encode(value))

	return 
end
cache.saveDebugLog = function (folder, key, value)
	local path = cache.debugPath() .. folder .. "/"

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	local file = io.open(path .. key, "w+b")

	for i, v in ipairs(value) do
		file.write(file, v .. "\r\n")
	end

	io.close(file)

	return 
end
cache.cgPath = function ()
	return device.writablePath .. "cache/cg" .. cg_version
end
cache.cgCheckFirstIn = function ()
	if not ALWAYS_PLAY_CG then
		return 
	end

	local path = cache.cgPath()

	print("cache.cgCheckFirstIn", path, io.exists(path))

	if not io.exists(path) then
		io.writefile(path, cg_version)

		return true
	end

	return 
end
cache.cgClear = function ()
	if 0 < DEBUG then
		local path = cache.cgPath()

		os.remove(path)
	end

	return 
end
cache.check_relation = function (func)
	if not io.exists(device.writablePath .. "cache/relation" .. relation_version) then
		ycFunction:mkdir(device.writablePath .. "cache/relation" .. relation_version)
	end

	func()

	return 
end
cache.getFriendChatRecord = function (playerName, target)
	print(playerName, target, "123")

	local f = crypto.encodeBase64(playerName .. target)
	f = string.gsub(f, "/", "#")
	local filename = device.writablePath .. "cache/relation" .. relation_version .. "/" .. f

	return cache.getSerialize(filename)
end
cache.check_smelting = function (func)
	if not io.exists(device.writablePath .. "cache/smelting" .. smelting_version) then
		ycFunction:mkdir(device.writablePath .. "cache/smelting" .. smelting_version)
	end

	func()

	return 
end
cache.getSmelting = function (roleid)
	local data = io.readfile(device.writablePath .. "cache/smelting" .. smelting_version .. "/" .. roleid)

	if data then
		return json.decode(data)
	end

	return {}
end
cache.saveSmelting = function (roleid, data)
	local filename = device.writablePath .. "cache/smelting" .. smelting_version .. "/" .. roleid

	io.writefile(filename, json.encode(data))

	return 
end
cache.getExchangeLog = function (roleid)
	local data = io.readfile(device.writablePath .. "cache/smelting" .. smelting_version .. "/" .. "excahge" .. roleid)

	if data then
		return json.decode(data)
	end

	return {}
end
cache.saveExchangeLog = function (roleid, data)
	local filename = device.writablePath .. "cache/smelting" .. smelting_version .. "/" .. "excahge" .. roleid

	io.writefile(filename, json.encode(data))

	return 
end
cache.getFirstOpen = function (playerName)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")
	local dirPath = device.writablePath .. "cache/firstOpen" .. firstopen_version
	local data = io.readfile(string.format("%s/%s", dirPath, playerName))

	if data then
		return json.decode(data)
	end

	return 
end
cache.saveFirstOpen = function (playerName)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")
	local dirPath = device.writablePath .. "cache/firstOpen" .. firstopen_version

	if not io.exists(dirPath) then
		ycFunction:mkdir(dirPath)
	end

	local path = string.format("%s/%s", dirPath, playerName)

	io.writefile(path, json.encode(g_data.firstOpen.data))

	return 
end
cache.getTestCommond = function ()
	local dirPath = device.writablePath .. "cache/testCommond"
	local data = io.readfile(string.format("%s/%s", dirPath, "testCommond"))

	if data then
		return json.decode(data)
	end

	return 
end
cache.saveTestCommond = function (testCom)
	local dirPath = device.writablePath .. "cache/testCommond"

	if not io.exists(dirPath) then
		ycFunction:mkdir(dirPath)
	end

	local path = string.format("%s/%s", dirPath, "testCommond")

	io.writefile(path, json.encode(testCom))

	return 
end

return cache
