--[[
奇遇副本提示面板
2015年8月6日15:41:04
haohu
]]
------------------------------------------------------------

_G.UIRandomDungeonPrompt = BaseUI:new("UIRandomDungeonPrompt")

function UIRandomDungeonPrompt:Create()
	self:AddSWF("randomDungeonPrompt.swf", true, "top")
end

function UIRandomDungeonPrompt:OnLoaded( objSwf )
	objSwf._visible = false
	objSwf.hitTestDisable = true
	objSwf.textField.htmlText = ""
end

function UIRandomDungeonPrompt:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.textField.htmlText = ""
end

function UIRandomDungeonPrompt:Prompt(str)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.textField.htmlText = str
	self:StartTimer()
end

-------------------------------------倒计时处理------------------------------------------

local timerKey
local time
function UIRandomDungeonPrompt:StartTimer()
	self:StopTimer()
	local func = function() self:OnTimer() end
	time = 5
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf._visible = true
end

function UIRandomDungeonPrompt:OnTimer()
	time = time - 1;
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
end

function UIRandomDungeonPrompt:OnTimeUp()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf._visible = false
end

function UIRandomDungeonPrompt:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
	end
end