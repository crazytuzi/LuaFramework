
BagCkEncryptionView = BagCkEncryptionView or BaseClass(BaseView)
function BagCkEncryptionView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.config_tab = {
		{"storage_ui_cfg", 1, {0}},
		{"storage_ui_cfg", 7, {0}},
	}
end

function BagCkEncryptionView:__delete()
	
end

function BagCkEncryptionView:ReleaseCallBack()

end

function BagCkEncryptionView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_OK.node:addClickEventListener(BindTool.Bind(self.OnClickOK, self))
		self.node_t_list.btn_OK.node:setTitleText("确定")
		self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind(self.OnClickCancel, self))
		EventProxy.New(BagData.Instance, self):AddEventListener(BagData.STORAGE_LOCK_TYPE_CHANGE, BindTool.Bind(self.OnStorageLockTypeChange, self))
	end
end

function BagCkEncryptionView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function BagCkEncryptionView:OpenCallBack()

end

function BagCkEncryptionView:CloseCallBack()

end


function BagCkEncryptionView:OnFlush(param_t, index)
	local lock_type = BagData.Instance:GetStorageLockType()
	if lock_type ~= LOCKSTATEID.NOT_LOCKED then
		self:CloseHelper()
	end
end

function BagCkEncryptionView:OnClickOK()
	local text = self.node_t_list.edit_password_0_0.node:getText()
	local text2 = self.node_t_list.edit_passwordconfirm_0_0.node:getText()
	if text == text2 then
		BagCtrl.Instance:SendStorageSetLockReq(text)
	else
		SysMsgCtrl.Instance:ErrorRemind("两次输入的密码不一致")
	end
end

function BagCkEncryptionView:OnStorageLockTypeChange()
	self:Flush()
end

function BagCkEncryptionView:OnClickCancel()
	self:CloseHelper()
end