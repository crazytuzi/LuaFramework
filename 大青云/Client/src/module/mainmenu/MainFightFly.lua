

--[[
主界面战斗力漂浮
]]

_G.UIMainFightFly = BaseUI:new("UIMainFightFly");

--等待飘 下次战斗力
UIMainFightFly.nextFight = 0;

function UIMainFightFly:Create()
	self:AddSWF("fightFlyV.swf",true,"effect");
end

function UIMainFightFly:OnLoaded(objSwf)
	objSwf.hitTestDisable = true
end

function UIMainFightFly:NeverDeleteWhenHide()
	-- return true;
end

function UIMainFightFly:Open(addFight, cur, old)
	if CPlayerMap.bChangeMaping == true then
		UIMainHead:SetFight()
		return
	end
	self.nextFight = math.ceil(addFight);
	self.cur = math.ceil(cur)
	self.old = math.ceil(old)
	if self:IsShow() then
		self:ResetPfx()
		self:ShowNext()
		UIMainHead:SetFight(false, self.old)
		return;
	end
	self:Show();
end

function UIMainFightFly:ResetPfx()
	local objSwf = self.objSwf
	if not objSwf then return end
end

function UIMainFightFly:OnShow()
	self:ResetPfx()
	self:ShowNext()
	self:SetPos()
end

function UIMainFightFly:SetPos()
	local objSwf = self.objSwf
	if not objSwf then return end

	local winW,winH = UIManager:GetWinSize();
	objSwf.pfx._width = winW*1720/1920
	objSwf.pfx._height = winH*1030/1080
	objSwf.fight._x = (winW-200)*425/1720+ 200
	objSwf.fight._y = (winH-50)*640/1080 + 50
end

function UIMainFightFly:ShowNext()
	if self.nextFight == 0 then
		self:Hide()
		return;
	end

	local fight = self.objSwf.pfx.fight
	PublicUtil.SetNumberValue(self.objSwf.fight.fight, self.nextFight, false, 26, 7)
	self.nextFight = 0
	fight:gotoAndPlay(1)
	self.objSwf.fight:gotoAndPlay(1)
	if self.timeKey then
		self:UnRegisterTimer()
	end
	self.timeKey = TimerManager:RegisterTimer(function()
		self:Hide()
	end,2000,1);
end

function UIMainFightFly:UnRegisterTimer()
	TimerManager:UnRegisterTimer(self.timeKey)
	self.timeKey = nil
end

function UIMainFightFly:OnHide()
	self:UnRegisterTimer()
	if UIMainHead:IsShow() then
		UIMainHead:SetFight(true)
	end
end