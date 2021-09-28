
local GameDevice = {}

local SDK_GLOBAL_NAME = "sdk.GameDevice"
local SDK_CLASS_NAME = "GameDevice"

local sdk = "".. SDK_GLOBAL_NAME --cc.PACKAGE_NAME[SDK_GLOBAL_NAME]


-- 设备性能 分类
GameDevice.DEVICE_CAPACITY_LOW    = 1
GameDevice.DEVICE_CAPACITY_MEDIUM = 2
GameDevice.DEVICE_CAPACITY_HIGH   = 3

local deviceCapacity = DEVICE_CAPACITY_MEDIUM



--[[--

	获取设备信息

	初始化完成后，可以使用：

]]
function GameDevice.GetDeviceInfo()
	if(device.platform == "ios") then
		local ok , ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "GetDeviceInfo")		
		if(ret ~= nil) then
			ret.deviceType = string.gsub(tostring(ret.deviceType), ",", "_")
			if(ret.deviceUUID == "0") then
				ret.deviceUUID = device.getOpenUDID()
			end
		end

		return ret
	end
end

--[[

	根据设备性能，进行分类，只针对最差机型做特别处理

]]
function GameDevice.GetDeviceType( ... )
	
	if(device.platform == "ios") then
		local info = GameDevice.GetDeviceInfo()

		if( string.find(info.deviceType,"iPhone3") ~= nil) then
			deviceCapacity = GameDevice.DEVICE_CAPACITY_LOW
		end

		return deviceCapacity
	end
end

--[[

	获取boundle id
]]
function GameDevice.GetBoundleID( ... )
	if(device.platform == "ios") then
		local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "GetBoundleID")

		local boundleID = ret.boundleID
		dump(boundleID)
		return boundleID
	end
end


function GameDevice.isContainsEmoji( str )	
	if(device.platform == "ios") then
		local args = {str = str}
		local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "isContainsEmoji", args)

		return ret
	end
end


--[[
	增加 notification
]]
function GameDevice.AddNotification( param )
	if(device.platform == "ios") then
		local args = {dt=param.dt, cont=param.cont, bt_txt=param.bt_txt}
		luaoc.callStaticMethod(SDK_CLASS_NAME, "AddNotification", args)
	end
end

--[[
	cancel 所有的notification
]]
function GameDevice.CancelAllNotifications( )
	if(device.platform == "ios") then		
		luaoc.callStaticMethod(SDK_CLASS_NAME, "CancelAllNotifications")
	end
end

return GameDevice
