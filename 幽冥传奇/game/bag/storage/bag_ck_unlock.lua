
BagCkUnlockView = BagCkUnlockView or BaseClass(BaseView)
function BagCkUnlockView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.config_tab = {
		{"storage_ui_cfg", 4, {0}},
		{"storage_ui_cfg", 7, {0}},
	}
end

function BagCkUnlockView:__delete()
	
end

function BagCkUnlockView:ReleaseCallBack()

end

function BagCkUnlockView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_OK.node:addClickEventListener(BindTool.Bind1(self.OnClickOK, self))
		self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind1(self.OnClickCancel, self))
	end
end

function BagCkUnlockView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function BagCkUnlockView:OpenCallBack()

end

function BagCkUnlockView:CloseCallBack()

end

function BagCkUnlockView:OnFlush(param_t, index)
	
end

function BagCkUnlockView:OnClickOK()
	local text = self.node_t_list.edit_password_0_0.node:getText()
	BagCtrl.Instance:SendStorageDelLockReq(text)
	self:Close()
end

function BagCkUnlockView:OnClickCancel()
	self:Close()
end