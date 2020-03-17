--[[
	PK切换善恶
	2015年2月5日, PM 03:40:20
	wangyanwei
]]

_G.UIMainPKSuspend = BaseUI:new("UIMainPKSuspend");

function UIMainPKSuspend:Create()
	self:AddSWF("MainPKSuspendPanel.swf", true, "top");
end
	
function UIMainPKSuspend:OnLoaded(objSwf)
	objSwf.btn_setState.click = function () self:OnSetStateClick() end
	objSwf.btn_close.click = function () self:Hide() end
end

function UIMainPKSuspend:OnShow()
	local objSwf = self.objSwf;
	if self.stateType == 1 then
		objSwf.small.txt.text = '您被恶意攻击，请更换PK模式反击';
		objSwf.btn_setState.visible = true;
	elseif self.stateType == 2 then
		objSwf.small.txt.text = '善恶模式开启';
		objSwf.btn_setState.visible = false;
	end
	self:OnTimePanel();
end

UIMainPKSuspend.timeNum = 60;
function UIMainPKSuspend:OnTimePanel()
	local func = function ()
		if self.timeNum < 1 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			self:Hide();
		end
		self.timeNum = self.timeNum - 1;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

function UIMainPKSuspend:UpDataTime()
	self.timeNum = 60;
end

function UIMainPKSuspend:OnHide()
	self.timeNum = 60;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

UIMainPKSuspend.stateType = nil;
function UIMainPKSuspend:Open(state)
	self.stateType = state;
	self:Show();
end

function UIMainPKSuspend:OnSetStateClick()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	local pkSelectCfg = split(mapCfg.can_changePK,',');
	for i , v in pairs (pkSelectCfg) do
		if toint(v) == MainMenuConsts.PKConsts.PK_GoodBad then
			MainMenuController:OnSendPkState(MainMenuConsts.PKConsts.PK_GoodBad);
			self:Hide();
			return
		end
	end
	MainMenuController:OnSendPkState(MainMenuConsts.PKConsts.PK_All);
	self:Hide();
end