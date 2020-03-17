--[[
	PK警告
	2015年2月5日, PM 03:39:55
	wangyawnei
]]

_G.UIMainPKCaution = BaseUI:new("UIMainPKCaution");

function UIMainPKCaution:Create()
	self:AddSWF("MainPKCautionPanel.swf", true, "top");
end
	
function UIMainPKCaution:OnLoaded(objSwf)
	objSwf.btn_pkCaution.tf1.text = UIStrConfig['mainmenuPK501'];
	objSwf.btn_pkCaution.tf3.text = UIStrConfig['mainmenuPK502'];
	-- objSwf.tipsPanel._visible = false;
	objSwf.btn_pkCaution.rollOver = function() TipsManager:Hide(); end
	objSwf.btn_pkCaution.click = function() self:OnSelectPlayer(); end
	objSwf.btn_pkCaution.btnSet.click = function() self:Hide(); end
end

function UIMainPKCaution:OnSelectPlayer()
	local player = CPlayerMap:GetPlayer(self.playerID);
	if not player then return end
	SkillController:ClickLockChar(self.playerID);
end

function UIMainPKCaution:OnShow()
	self:OnShowPalyerInfo();
	self:OnShowTip();
end

function UIMainPKCaution:OnShowTip()
	local objSwf = self.objSwf;
	objSwf.btn_pkCaution.txt_name.text = self.playerName;
end

function  UIMainPKCaution:OnShowPalyerInfo()
	local objSwf = self.objSwf;
	objSwf.btn_pkCaution.iconLoader.source = ResUtil:GetHeadIcon(self.playerIcon);
	self:TimeChange();
end

function UIMainPKCaution:TimeChange()
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

UIMainPKCaution.playerName = nil;
UIMainPKCaution.playerIcon = nil;
UIMainPKCaution.playerLevel = nil;
UIMainPKCaution.playerID = nil;
UIMainPKCaution.timeNum = 60;
function UIMainPKCaution:Open(name,icon,level,id)
	self.playerName = name;
	self.playerIcon = icon;
	self.playerLevel = level;
	self.playerID = id;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
	self.timeNum = 60;
end

function UIMainPKCaution:OnHide()
	self.timeNum = 60;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

function UIMainPKCaution:HandleNotification(body)
	if name == NotifyConsts.NowPlayerFuckME then
		self.playerIcon = body.icon;
		self.playerName = body.name;
		self:OnShowPalyerInfo();
	end
end
function UIMainPKCaution:ListNotificationInterests()
	return {
		NotifyConsts.NowPlayerFuckME
	}
end

function UIMainPKCaution:GetWidth()
	return 292;
end

function UIMainPKCaution:GetHeight()
	return 130
end