--[[
提示:进入/离开打坐区
2015年6月25日21:13:27
haohu
]]

_G.UISitAreaIndicator = BaseUI:new("UISitAreaIndicator")

function UISitAreaIndicator:Create()
	self:AddSWF( 'sitAreaIndicator.swf', true, "bottom" )
end

function UISitAreaIndicator:OnShow()
	self:InitShow()
end

function UISitAreaIndicator:InitShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf:gotoAndPlay( self.state and "enter" or "exit" )
	self:StartTimer()
end

function UISitAreaIndicator:OnHide()
	self.state = nil
	self:StopTimer()
end

-- state -> true:enter false:exit
function UISitAreaIndicator:Open(state)
	self.state = state
	if not self:IsShow() then
		self:Show()
	else
		self:InitShow()
	end
end

-------------------------------------倒计时处理------------------------------------------

local timerKey
local time
function UISitAreaIndicator:StartTimer()
	self:StopTimer()
	local func = function() self:OnTimer() end
	time = 2
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
end

function UISitAreaIndicator:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
end

function UISitAreaIndicator:OnTimeUp()
	self:Hide()
end

function UISitAreaIndicator:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
	end
end