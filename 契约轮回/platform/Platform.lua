--
-- @Author: LaoY
-- @Date:   2018-11-09 20:08:55
--

Platform = Platform or class("Platform")

function Platform:ctor()
end

function Platform:Reset()
end

function Platform:SetClipString(str)
end

function Platform:GetClipString()
	return ""
end

--[[
	@author LaoY
	@des	
	@return int 电量百分比（0-100
			int 电池状态（1.放电、2.充电）
--]]
function Platform:GetBatteryState()
	return 100,1
end
--[[
--]]
function Platform:GetRootSize()
	return 1024*1024*4
end

function Platform:GetAvailableSize()
	return 1024*1024*4
end

function Platform:SetBrightness(brightness)
end

function Platform:GetDeviceID()
	return ""
end


function Platform:CallVoid(func_name,param)
	SDKManager.CallVoid(func_name,param)
end

function Platform:CallString(func_name,param)
	return SDKManager.CallString(func_name,param)
end

function Platform:CallInt(func_name,param)
	return SDKManager.CallInt(func_name,param)
end

function Platform:CallBool(func_name,param)
	return SDKManager.CallBool(func_name,param)
end