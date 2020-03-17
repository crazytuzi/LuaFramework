--[[
死亡遗迹提醒
lizhuangzhuang
2015年11月24日22:38:03
]]

_G.UISWYJRemind = BaseUI:new("UISWYJRemind");

function UISWYJRemind:Create()
	self:AddSWF("swyjRemind.swf",true,"top");
end

function UISWYJRemind:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:Hide(); end
	objSwf.btnCancel.click = function() self:Hide(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
end

function UISWYJRemind:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfContent.htmlText = StrConfig["activityswyj023"];
	objSwf.btnConfirm.label = StrConfig["activityswyj024"];
	objSwf.btnCancel.label = StrConfig["activityswyj025"];
end

function UISWYJRemind:OnBtnConfirmClick()
	if not self.args then return; end
	if not self.args[1] then return; end
	local id = self.args[1];
	ActivityController:EnterActivity(id,{param1=1});
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if objSwf.cbNoTip.selected then
		local remind = RemindModel:GetQueue(RemindConsts.Type_SWYJ);
		if remind then
			remind.isNoRemind = true;
		end
	end
	self:Hide();
end