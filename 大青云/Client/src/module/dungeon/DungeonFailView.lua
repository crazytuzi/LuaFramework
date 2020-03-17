--[[
副本结算界面(失败)
2015年6月3日15:57:17
haohu
]]

_G.UIDungeonFail = BaseUI:new("UIDungeonFail");

function UIDungeonFail:Create()
	self:AddSWF("dungeonFail.swf", true, "center");
end

function UIDungeonFail:OnLoaded(objSwf)
	objSwf.btnQuit.label  = StrConfig['dungeon304']
	objSwf.btnQuit.click  = function() self:OnBtnQuitClick() end
	--objSwf.btnClose.click = function() self:OnBtnQuitClick() end
end

function UIDungeonFail:OnShow()
	self:UpdateShow()
	self:StartTimer()
end

function UIDungeonFail:OnHide()
	self:StopTimer()
end

function UIDungeonFail:UpdateShow()

end

function UIDungeonFail:OnBtnQuitClick()
	self:QuitDungeon()
end

--领奖退出
function UIDungeonFail:QuitDungeon()
	DungeonController:ReqGetAward()
	self:Hide()
end

-------------------------------------倒计时处理------------------------------------------

local timerKey
local time
function UIDungeonFail:StartTimer()
	local func = function() self:OnTimer() end
	time = DungeonConsts.AutoQuitDelay
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
	self:UpdateTimeShow()
end

function UIDungeonFail:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
	self:UpdateTimeShow()
end

function UIDungeonFail:OnTimeUp()
	self:QuitDungeon()
end

function UIDungeonFail:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
		self:UpdateTimeShow()
	end
end

function UIDungeonFail:UpdateTimeShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local textField = objSwf.txtTime
	textField._visible = timerKey ~= nil
	textField.htmlText = string.format( StrConfig['dungeon306'], time )
end