
BagCkTempUnlockView = BagCkTempUnlockView or BaseClass(BaseView)
function BagCkTempUnlockView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.config_tab = {
		{"storage_ui_cfg", 3, {0}},
		{"storage_ui_cfg", 7, {0}},
	}
end

function BagCkTempUnlockView:__delete()
	
end

function BagCkTempUnlockView:ReleaseCallBack()

end

function BagCkTempUnlockView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_OK.node:addClickEventListener(BindTool.Bind1(self.OnClickOK, self))
		self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind1(self.OnClickCancel, self))
	end
end

function BagCkTempUnlockView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function BagCkTempUnlockView:OpenCallBack()

end

function BagCkTempUnlockView:CloseCallBack()

end

function BagCkTempUnlockView:OnFlush(param_t, index)
	
end

function BagCkTempUnlockView:OnClickOK()
	local text = self.node_t_list.edit_password_0_0.node:getText()
	BagCtrl.Instance:SendStorageTempUnlockReq(text)
	self:Close()
end

function BagCkTempUnlockView:OnClickCancel()
	self:Close()
end
