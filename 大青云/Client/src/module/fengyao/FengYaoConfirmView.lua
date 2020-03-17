--[[封妖提示界面
zhangshuhui
2015年6月16日14:20:20
]]

_G.UIFengYaoConfirmView = BaseUI:new("UIFengYaoConfirmView")

UIFengYaoConfirmView.fengyaolist = {};

function UIFengYaoConfirmView:Create()
	self:AddSWF("fengyaoconfirmPanel.swf", true, "center")
end

function UIFengYaoConfirmView:OnLoaded(objSwf,name)
	objSwf.btnClose.click   = function() self:OnBtnCloseClick() end 
	objSwf.btnCancel.click  = function() self:OnBtnCancelClick() end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick() end
end

function UIFengYaoConfirmView:OnShow()
	self:ShowInfo();
end

function UIFengYaoConfirmView:OpenPanel(fengyaoid)
	if self:IsHaveFengYaoId(fengyaoid) == false then
		if self:IsShow() then
			self:ShowInfo();
		else
			self:Show();
		end
	end
end

function UIFengYaoConfirmView:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.tfContent.htmlText = StrConfig["fengyao36"];
	
	self:Top();
end

function UIFengYaoConfirmView:OnBtnConfirmClick()
	UIFengYao:OnbtnyaoqingClick();
	self:Hide();
end

function UIFengYaoConfirmView:OnBtnCancelClick()
	self:Hide();
end

function UIFengYaoConfirmView:OnBtnCloseClick()
	self:Hide();
end

function UIFengYaoConfirmView:IsHaveFengYaoId(fengyaoid)
	if not self.fengyaolist[fengyaoid] then
		self.fengyaolist[fengyaoid] = fengyaoid;
		return false;
	else
		return true;
	end
end