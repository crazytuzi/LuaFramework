--[[
添加好友面板
lizhuangzhuang
2014年10月17日22:53:28
]]

_G.UIFriendAdd = BaseUI:new("UIFriendAdd");

function UIFriendAdd:Create()
	self:AddSWF("friendAddPanel.swf",true,"center");
end

function UIFriendAdd:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.btnCancel.click = function() self:OnBtnCancelClick(); end
end

function UIFriendAdd:OnShow()
	local objSwf = self:GetSWF("UIFriendAdd");
	if not objSwf then return; end
	objSwf.input.text = "";
end

function UIFriendAdd:OnBtnConfirmClick()
	local objSwf = self:GetSWF("UIFriendAdd");
	if not objSwf then return; end
	local name = objSwf.input.text;
	if name == "" then
		FloatManager:AddCenter(StrConfig["friend110"]);
		return;
	end
	FriendController:AddFriendByName(name);
	self:Hide();
end

function UIFriendAdd:OnBtnCancelClick()
	self:Hide();
end

function UIFriendAdd:OnBtnCloseClick()
	self:Hide();
end