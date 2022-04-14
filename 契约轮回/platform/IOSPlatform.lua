--
-- @Author: LaoY
-- @Date:   2018-11-09 20:16:28
--
IOSPlatform = IOSPlatform or class("IOSPlatform", Platform)

function IOSPlatform:ctor()
end

function IOSPlatform:dctor()
end


function IOSPlatform:SetClipString(str)
    self:CallVoid("CopyTextToClipboard",str)
end

function IOSPlatform:GetClipString()
    return self:CallString("GetClipboardText")
end

--[[
	@return int 电量百分比（0-100
			int 电池状态（1.放电、2.充电）
--]]
function IOSPlatform:GetBatteryState()
    level = self:CallInt("GetBatteryLevel") or 100
    state = self:CallInt("GetBatteryChargingState") or 1
    return level, state
end

--[[
    设备总容量
--]]
function IOSPlatform:GetRootSize()
    return self:CallInt("GetRootSize")
end

--[[
    设备可用容量
--]]
function IOSPlatform:GetAvailableSize()
    return  self:CallInt("GetAvailableSize")
end


--[[
    brightness 0-100
--]]
function IOSPlatform:SetBrightness(brightness)
    --self:CallVoid("SetBrightness", tostring(brightness))
end

function IOSPlatform:GetDeviceID()
    return self:CallString("GetDeviceID")
end
