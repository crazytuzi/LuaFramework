--[[
	2015年10月11日, PM 12:40:34
	wangyanwei
	自动挂机文字提示
]]

_G.UIAutoBattleTxt = BaseUI:new('UIAutoBattleTxt');

function UIAutoBattleTxt:Create()
	self:AddSWF('autoBattleTxt.swf',true,'bottom');
end

function UIAutoBattleTxt:OnLoaded(objSwf)
	objSwf.bg.click = function () self:Hide(); end
end

function UIAutoBattleTxt:OnShow()
	self:InitDate();
	self:ShowTxt();
	self:OnTimeChange();
end

function UIAutoBattleTxt:Open()
	local autoMapCfg = t_consts[112];
	if not autoMapCfg then return end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	if level >= autoMapCfg.val1 then return end
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end
	if self:IsShow() then self:Hide(); end
	local mapList = split(autoMapCfg.param,'#');
	for index, mapID in pairs(mapList) do
		if toint(mapID) == mapCfg.id then
			self:Show();
			break
		end
	end
	return
end

function UIAutoBattleTxt:ShowTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.bg.txt_info.htmlText = StrConfig['autoBattleTxt001'];
end

function UIAutoBattleTxt:OnHide()
	-- self:InitDate();
	if self.timeKey then 
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

function UIAutoBattleTxt:InitDate()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf._alpha = 100;
end

function UIAutoBattleTxt:OnTimeChange()
	local func = function()
		UIAutoBattleTxt:HideAlph();
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	if self.timeKey then 
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,5000,1);
end

function UIAutoBattleTxt:HideAlph()
	local objSwf = self.objSwf;
	if not objSwf then return end
	Tween:To(self.objSwf,1,{_alpha = 0,},{onComplete = function()self:Hide()end})
end

--切换挂机
function UIAutoBattleTxt:OhChangeIsAutoHang(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if state then
		self:Hide();
	end
end

function UIAutoBattleTxt:HandleNotification(name,body)
	if name == NotifyConsts.AutoHangStateChange then
		self:OhChangeIsAutoHang(body.state);
	end
end

function UIAutoBattleTxt:ListNotificationInterests()
	return {
		NotifyConsts.AutoHangStateChange,
	}
end