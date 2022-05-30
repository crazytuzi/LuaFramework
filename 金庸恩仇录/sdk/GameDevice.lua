local GameDevice = {}
local SDK_GLOBAL_NAME = "sdk.GameDevice"
local SDK_CLASS_NAME = "GameDevice"
local sdk = "" .. SDK_GLOBAL_NAME

GameDevice.DEVICE_CAPACITY_LOW = 1
GameDevice.DEVICE_CAPACITY_MEDIUM = 2
GameDevice.DEVICE_CAPACITY_HIGH = 3
local deviceCapacity = DEVICE_CAPACITY_MEDIUM

function GameDevice.GetDeviceInfo()
	return ""
	--[[
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "GetDeviceInfo")
		if ret ~= nil then
			ret.deviceType = string.gsub(tostring(ret.deviceType), ",", "_")
			if ret.deviceUUID == "0" then
				ret.deviceUUID = device.getOpenUDID()
			end
		end
		return ret
	end
	]]
end

function GameDevice.GetDeviceType(...)
	return GameDevice.DEVICE_CAPACITY_LOW
	--[[
	if device.platform == "ios" then
		local info = GameDevice.GetDeviceInfo()
		if string.find(info.deviceType, "iPhone3") ~= nil then
			deviceCapacity = GameDevice.DEVICE_CAPACITY_LOW
		end
		return deviceCapacity
	end
	]]
end

function GameDevice.GetBoundleID()
	return "ios"
	--[[
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "GetBoundleID")
		local boundleID = ret.boundleID
		local channelName = ret.channelName or ""
		dump(ret)
		return boundleID, channelName
	end
	]]
end

function GameDevice.isContainsEmoji(str)
	return false
	--[[
	if device.platform == "ios" then
		local args = {str = str}
		local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "isContainsEmoji", args)
		return ret
	end
	]]
end

function GameDevice.AddNotification(param)
	--[[
	if device.platform == "ios" then
		local args = {
		dt = param.dt,
		cont = param.cont,
		bt_txt = param.bt_txt
		}
		luaoc.callStaticMethod(SDK_CLASS_NAME, "AddNotification", args)
	end
	]]
end

function GameDevice.CancelAllNotifications()
	--[[
	if device.platform == "ios" then
		luaoc.callStaticMethod(SDK_CLASS_NAME, "CancelAllNotifications")
	end
	]]
end

return GameDevice