--[[
 主角升级特效
]]

_G.UIMainPlayerLevelUp = BaseUI:new("UIMainPlayerLevelUp");

function UIMainPlayerLevelUp:Create()
	self:AddSWF("levelPfx.swf",true,"effect");
end

function UIMainPlayerLevelUp:OnLoaded(objSwf)
	
end

function UIMainPlayerLevelUp:OnShow()
	self.objSwf:gotoAndPlay(1)
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil
	end
	local level = MainPlayerModel.humanDetailInfo.eaLevel
	self.objSwf.levelLoader.fightLoader.num = level
	if level < 10 then
		self.objSwf.levelLoader.fightLoader._x = 0
	elseif level < 100 then
		self.objSwf.levelLoader.fightLoader._x = -15
	else
		self.objSwf.levelLoader.fightLoader._x = -25
	end
	self.timeKey = TimerManager:RegisterTimer(function()
		self:Hide()
	end,1500,1)
end

function UIMainPlayerLevelUp:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil
	end
end