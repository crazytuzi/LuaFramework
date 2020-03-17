--[[
	2015年12月25日14:43:20
	wangyanwei
	祝福值警告
]]

_G.UIBlessingWarning = BaseUI:new('UIBlessingWarning');

function UIBlessingWarning:Create()
	self:AddSWF('blessingWarningPanel.swf',true,'top');
end

function UIBlessingWarning:OnLoaded(objSwf)
	objSwf.btn_cancel.click = function () self:Hide(); end
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.btn_confirm.click = function () local func = self.func; self:Hide(); func();  end
	
	objSwf.tf.text = UIStrConfig['charges101'];
end

function UIBlessingWarning:OnShow()
	
end

function UIBlessingWarning:OnHide()
	self.func = nil;
end

UIBlessingWarning.isFirsWarning = true;
UIBlessingWarning.func = nil;
function UIBlessingWarning:Open(func)
	if self:IsShow() then
		self:Top();
		return true
	end
	if self:Interval() and func then
		if self.func then self.func = nil; end
		self.func = func ;
		self:Show();
		return true
	end
	return false
end

UIBlessingWarning.renovateTime = 0;
function UIBlessingWarning:Interval()
	if self.isFirsWarning then
		self.isFirsWarning = false;
		self.renovateTime = GetServerTime();
		return true
	end
	if GetServerTime() - self.renovateTime >= ChargesConsts.RenovateWarningNum then
		self.renovateTime = GetServerTime();
		return true
	end
	return false;
end