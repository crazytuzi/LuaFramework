--
-- @Author: LaoY
-- @Date:   2018-11-09 20:15:59
--

AndroidPlatform = AndroidPlatform or class("AndroidPlatform",Platform)

function AndroidPlatform:ctor()
end

function AndroidPlatform:dctor()
end

function AndroidPlatform:SetClipString(str)
	self:CallVoid("CopyTextToClipboard",str)
end

function AndroidPlatform:GetClipString()
	return self:CallString("GetClipboardText")
end

--[[
	@author LaoY
	@des	
	@return int 电量百分比（0-100
			int 电池状态（1.放点、2.充电）
--]]
function AndroidPlatform:GetBatteryState()
	local str = self:CallString("GetBatteryState")
	local state_list = string.split(str,"|")
	local level = 100
	local state = 1
	if table.isempty(state_list) then
		return level,state
	end
	level = tonumber(state_list[1]) or level
	state = tonumber(state_list[2]) or state
	return level,state
end

function AndroidPlatform:GetRootSize()
	local size = self:CallInt("GetRootSize")
	if size and size ~= 0 then
		return size
	end
	return 1024*1024*4
end

function AndroidPlatform:GetAvailableSize()
	local size = self:CallInt("GetAvailableSize")
	if size and size ~= 0 then
		return size
	end
	return 1024*1024*4
end

function AndroidPlatform:SetBrightness(brightness)
	self:CallVoid("SetBrightness",tostring(brightness))
end

function AndroidPlatform:GetDeviceID()
	
	return self:CallString("GetDeviceID")
end