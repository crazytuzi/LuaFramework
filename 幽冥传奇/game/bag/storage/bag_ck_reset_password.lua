
BagCkResetPasswordView = BagCkResetPasswordView or BaseClass(BaseView)
function BagCkResetPasswordView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.config_tab = {
		{"storage_ui_cfg", 5, {0}},
		{"storage_ui_cfg", 7, {0}},
	}
end

function BagCkResetPasswordView:__delete()
	
end

function BagCkResetPasswordView:ReleaseCallBack()

end

function BagCkResetPasswordView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_OK.node:addClickEventListener(BindTool.Bind1(self.OnClickOK, self))
		self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind1(self.OnClickCancel, self))
	end
end

function BagCkResetPasswordView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function BagCkResetPasswordView:OpenCallBack()

end

function BagCkResetPasswordView:CloseCallBack()

end

function BagCkResetPasswordView:OnFlush(param_t, index)
	
end

function BagCkResetPasswordView:OnClickOK()
	local text = self.node_t_list.edit_password_0_0.node:getText()
	local text2 = self.node_t_list.edit_npassword_0_0.node:getText()
	local text3 = self.node_t_list.edit_npassword2_0_0.node:getText()
	if text2 == text3 then
		BagCtrl.Instance:SendStorageChangeLockReq(text, text2)
		self:Close()
	else
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Setting.SendSucc)
	end
end

function BagCkResetPasswordView:OnClickCancel()
	self:Close()
end