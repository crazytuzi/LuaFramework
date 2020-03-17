--[[
	2015年10月8日, PM 12:26:16
	wangyanwei
	流水副本普通经验领取确认框
]]

_G.WaterDungeonEnterTip = BaseUI:new('WaterDungeonEnterTip');

function WaterDungeonEnterTip:Create()
	self:AddSWF('waterExpEnterTip.swf',true,'center');
end

function WaterDungeonEnterTip:OnLoaded(objSwf)
	objSwf.btn_no.click = function () self:Hide(); end
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.btn_enter.click = function () self:OnEnterClick(); end
end

function WaterDungeonEnterTip:OnShow()
	self:Top();
	self:OnShowTxt();
end

function WaterDungeonEnterTip:OnShowTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.txt_info.htmlText = StrConfig['waterDungeon500'];
end

WaterDungeonEnterTip.func = nil;
function WaterDungeonEnterTip:Open(func)
	if not func then return end
	self.func = func;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function WaterDungeonEnterTip:OnEnterClick()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if not self.func then self:Hide();return end
	self.func();
	self:Hide();
end

function WaterDungeonEnterTip:OnHide()
	self.func = nil;
end