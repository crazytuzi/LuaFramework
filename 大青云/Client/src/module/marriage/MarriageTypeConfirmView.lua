--[[选中婚礼提示界面
zhangshuhui
]]

_G.UIMarriageTypeConfirmView = BaseUI:new("UIMarriageTypeConfirmView")
UIMarriageTypeConfirmView.type = 0;
function UIMarriageTypeConfirmView:Create()
	self:AddSWF("marryTypeconfirmPanel.swf", true, "center")
end

function UIMarriageTypeConfirmView:OnLoaded(objSwf,name)
	objSwf.btnClose.click   = function() self:OnBtnCloseClick() end 
	objSwf.btnCancel.click  = function() self:OnBtnCancelClick() end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick() end
end

function UIMarriageTypeConfirmView:OnShow()
	self:ShowInfo();
end

function UIMarriageTypeConfirmView:OpenPanel(type)
	self.type = type;
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
end

function UIMarriageTypeConfirmView:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if self.type == 1 then
		objSwf.tfContent.htmlText = StrConfig["marriage908"];
		objSwf.btnConfirm.htmlLabel = StrConfig["marriage910"];
		objSwf.btnCancel.htmlLabel = StrConfig["marriage911"];
	else
		objSwf.tfContent.htmlText = StrConfig["marriage909"];
		objSwf.btnConfirm.htmlLabel = StrConfig["marriage912"];
		objSwf.btnCancel.htmlLabel = StrConfig["marriage913"];
	end
	
	self:Top();
end

function UIMarriageTypeConfirmView:OnBtnConfirmClick()
	--去看看
	if self.type == 1 then
		UIMarryTypeSelect:OnMarryTypeClick(2);
	--确认选择
	else
		MarriagController:ReqMarryType(self.type);
	end
	self:Hide();
end

function UIMarriageTypeConfirmView:OnBtnCancelClick()
	--就选普通
	if self.type == 1 then
		MarriagController:ReqMarryType(self.type);
	end
	self:Hide();
end

function UIMarriageTypeConfirmView:OnBtnCloseClick()
	self:Hide();
end