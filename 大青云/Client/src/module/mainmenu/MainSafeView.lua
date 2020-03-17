--[[
	安全区提示
	2015年5月7日, PM 10:03:32
	wangyanwei
]]

_G.UISafe = BaseUI:new('UISafe');

function UISafe:Create()
	self:AddSWF("safePanel.swf", true, "center");	
end

function UISafe:OnLoaded(objSwf)
	
end

function UISafe:NeverDeleteWhenHide()
	return true;
end

function UISafe:OnShow()
	self:OnChangeTime();
	self:OnShowSafeState();
end

function UISafe:OnShowSafeState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.safe._visible = self.state;
	objSwf.notsafe._visible = not self.state;
end	

function UISafe:OnChangeTime()
	local func = function ()
		self:Hide();
	end
	self.timeKey = TimerManager:RegisterTimer(func,2000,1);
end

UISafe.state = nil;
function UISafe:Open(state)
	if self.state == (state == 1) then
		return
	end
	self.state = state == 1;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UISafe:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end