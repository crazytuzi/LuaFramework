PrivilegeDialogView = PrivilegeDialogView or BaseClass(XuiBaseView)

function PrivilegeDialogView:__init()
	self.texture_path_list[1] = 'res/xui/privilege.png'
	--self.is_async_load = false	
	self.is_any_click_close = true
	self.is_modal = true
	self.config_tab = {
		{"privilege_ui_cfg",1, {0}},
	}

	self.cur_diadata = nil
end

function PrivilegeDialogView:__delete()
	
end

function PrivilegeDialogView:ReleaseCallBack()
	if nil ~= self.alert_dialog_privilege then
		self.alert_dialog_privilege:DeleteMe()
  		self.alert_dialog_privilege = nil
	end	
end

function PrivilegeDialogView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_close_diawindow.node, BindTool.Bind1(self.OnClose, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_diasuperbuy.node, BindTool.Bind1(self.OnDiaSuperbuy, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_diaOK.node, BindTool.Bind1(self.OpPrivilege, self), true)
		self.alert_dialog_privilege = Alert.New()
	end
end

function PrivilegeDialogView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function PrivilegeDialogView:ShowIndexCallBack(index)
	self:Flush(index)
end

function PrivilegeDialogView:OnFlush()
	if  self.cur_diadata.state == 0 then
		local money_pri = self.cur_diadata.buyNeedYB	
		RichTextUtil.ParseRichText(self.node_t_list.rich_dialog.node,string.format(Language.Role.PrivilegeBuyAlert,money_pri),26,cc.c3b(0x9c, 0x8b, 0x6f))
	else
		local pri_discount = self.cur_diadata.renewalNeedYB	
		RichTextUtil.ParseRichText(self.node_t_list.rich_dialog.node,string.format(Language.Role.PrivilegeDisAlert,pri_discount),26,cc.c3b(0x9c, 0x8b, 0x6f))
	end
	self.node_t_list.rich_dialog.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
end
function PrivilegeDialogView:SetData(data)
	local index_data = PrivilegeData.Instance:GetData()
	self.cur_diadata= index_data[data]	 
	self:Open()
end

function PrivilegeDialogView:OnDiaSuperbuy()
	local superbuy = PrivilegeData.Instance:GetSuperBuy()
	self.alert_dialog_privilege:SetLableString(string.format(Language.Role.PrivilegeSuperAlert,superbuy))
	self.alert_dialog_privilege:SetShowCheckBox(false)
	self.alert_dialog_privilege:Open()
	self.alert_dialog_privilege:SetOkFunc(function ()
  		PrivilegeCtrl.SendBuyPrivilegeReq(0, 0)
  	end)
  	self:OnClose()
  	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function PrivilegeDialogView:OpPrivilege()
	self.buy_type = self.cur_diadata.state == 0 and 1 or 2
	PrivilegeCtrl.SendBuyPrivilegeReq(self.buy_type, self.cur_diadata.vipType)
	self:OnClose()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end
function PrivilegeDialogView:OnClose()
	self:Close()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end
