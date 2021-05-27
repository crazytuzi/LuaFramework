
BagCkProtectView = BagCkProtectView or BaseClass(BaseView)
function BagCkProtectView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.config_tab = {
		{"storage_ui_cfg", 2, {0}},
		{"storage_ui_cfg", 7, {0}},
	}
end

function BagCkProtectView:__delete()
	
end

function BagCkProtectView:ReleaseCallBack()

end

function BagCkProtectView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_qxbh.node:addClickEventListener(BindTool.Bind(self.OnClickUnlock, self))
		self.node_t_list.btn_lsjs.node:addClickEventListener(BindTool.Bind(self.OnClickTempUnlock, self))
		self.node_t_list.btn_xgmm.node:addClickEventListener(BindTool.Bind(self.OnClickChangePassword, self))
		EventProxy.New(BagData.Instance, self):AddEventListener(BagData.STORAGE_LOCK_TYPE_CHANGE, BindTool.Bind(self.OnStorageLockTypeChange, self))
	end
end

function BagCkProtectView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function BagCkProtectView:OpenCallBack()

end

function BagCkProtectView:CloseCallBack()

end

function BagCkProtectView:OnFlush(param_t, index)
	local lock_type = BagData.Instance:GetStorageLockType()
	self.node_t_list.lbl_type.node:setString(Language.Bag.StroageLockType[lock_type])
	self.node_t_list.lbl_type.node:setColor(lock_type == LOCKSTATEID.LOCKED and COLOR3B.RED or COLOR3B.GREEN)
	if lock_type == LOCKSTATEID.LOCKED then
		self.node_t_list.btn_lsjs.node:setTitleText(Language.Bag.LSJS)
	elseif lock_type == LOCKSTATEID.UNLOCKED then
		self.node_t_list.btn_lsjs.node:setTitleText(Language.Bag.HFBH)
	elseif lock_type == LOCKSTATEID.NOT_LOCKED then
		ViewManager.Instance:OpenViewByDef(ViewDef.StorageEncryption)
		self:CloseHelper()
	end
end

function BagCkProtectView:OnClickUnlock()
	ViewManager.Instance:OpenViewByDef(ViewDef.StorageUnlock)
end

function BagCkProtectView:OnClickTempUnlock()
	local lock_type = BagData.Instance:GetStorageLockType()
	if lock_type == LOCKSTATEID.LOCKED then 
		ViewManager.Instance:OpenViewByDef(ViewDef.StorageTempUnlock)
	elseif lock_type == LOCKSTATEID.UNLOCKED then
		BagCtrl.Instance:SendStorageRecoveryLockReq()
	end
end

function BagCkProtectView:OnClickChangePassword()
	ViewManager.Instance:OpenViewByDef(ViewDef.StorageResetPassword)
end

function BagCkProtectView:OnStorageLockTypeChange()
	self:Flush()
end
