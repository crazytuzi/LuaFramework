--[[
带有复选框的确定面板
2015年5月19日10:38:15
]]

_G.UIConfirmWithNoTip = UIConfirm:new("UIConfirmWithNoTip");

function UIConfirmWithNoTip:Create()
	self:AddSWF("confirmPanelWithCheckBox.swf", true, "highTop" );
end

function UIConfirmWithNoTip:GetSelected()
	local objSwf = self.objSwf
	if not objSwf then return false end
	return objSwf.cbNoTip.selected
end

function UIConfirmWithNoTip:ShowExtendInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.cbNoTip.selected = false
	objSwf.cbNoTip.htmlLabel = self.currVO.noRemindLabel
end

function UIConfirmWithNoTip:Confirm()
	if self.currVO and self.currVO.confirmFunc then
		self.currVO.confirmFunc( self:GetSelected() )
	end 
	self:ShowNext();
end

function UIConfirmWithNoTip:Cancel()
	if self.currVO and self.currVO.cancelFunc then
		self.currVO.cancelFunc( self:GetSelected() )
	end 
	self:ShowNext()
end