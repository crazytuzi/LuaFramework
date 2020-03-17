--[[
改名
liyuan
2014年11月20日16:22:09
]]


_G.UIPlayerNameEditPanel = BaseUI:new("UIPlayerNameEditPanel")
UIPlayerNameEditPanel.itemId = 0

function UIPlayerNameEditPanel:Create()
	self:AddSWF("playerNameEditPanel.swf", true, "top");
end

function UIPlayerNameEditPanel:OnLoaded(objSwf, name)
	objSwf.btnOK.click = function() 
		self:OnBtnCreateClick()
	end
	objSwf.btnCancel.click = function() self:Hide() end
	objSwf.btnClose.click = function() self:Hide() end
	
	objSwf.inputName.textChange = function()
								local name = objSwf.inputName.text;
								if string.getLen(name) > UICreateRole.maxNameLength then
									FloatManager:AddCenter(StrConfig['login1']);
									objSwf.inputName.text = string.sub(name,1,-2)
								end
	end
end

function UIPlayerNameEditPanel:OnBtnCreateClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local name = objSwf.inputName.text;
	if name == "" then
		UIConfirm:Open(StrConfig['login3']);
		return;
	end
	if string.getLen(name) > UICreateRole.maxNameLength then
		UIConfirm:Open(StrConfig['login1']);
		return;
	end
	if name:find('[%p*%s*]')==1 then
		UIConfirm:Open(StrConfig['login2']);
		return;
	end
	local filterName = ChatUtil.filter:filter(name);
	if filterName:find("*") then
		UIConfirm:Open(StrConfig['login2']);
		return;
	end
	objSwf.btnOK.disabled = true
	MainPlayerController:ReqChangePlayerName(name, self.itemId)
	self:Hide()
 end

function UIPlayerNameEditPanel:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	if self.args and self.args[1] then
		self.itemId = self.args[1]
	end
	objSwf.btnOK.disabled = false
	local playerName = MainPlayerModel.humanDetailInfo.eaName
	objSwf.inputName.text = RoleUtil:TailorName(playerName)
end

--消息处理
function UIPlayerNameEditPanel:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	if name == NotifyConsts.ChangePlayerName then
		objSwf.btnOK.disabled = false
	end
end

-- 消息监听
function UIPlayerNameEditPanel:ListNotificationInterests()
	return {NotifyConsts.ChangePlayerName};
end

function UIPlayerNameEditPanel:IsShowSound()
	return true;
end

function UIPlayerNameEditPanel:IsShowLoading()
	return true;
end