--输入角色名字追踪位置
RoleTrace = RoleTrace or BaseClass(XuiBaseView)

function RoleTrace:__init()
	self.is_modal = true
	self.config_tab  = {
		{"rename_ui_cfg", 1 , {0}},
	}
end

function RoleTrace:__delete()
	if nil ~= self.alert_window then
		self.alert_window:DeleteMe()
		self.alert_window = nil
	end
end

function RoleTrace:LoadCallBack()
	self.edit_node = self.node_t_list.edit_input_4_4
	XUI.AddClickEventListener(self.node_t_list.btn_windows_close.node, (BindTool.Bind1(self.Close, self)))
	XUI.AddClickEventListener(self.node_t_list.btn_rename_confirm.node, BindTool.Bind1(self.OnConfirmRenameHandler, self))
	XUI.AddClickEventListener(self.node_t_list.btn_rename_cancel.node, BindTool.Bind1(self.OnCancelRenameHandler, self))
	self.edit_node.node:registerScriptEditBoxHandler(BindTool.Bind2(ChatData.ExamineEditNameNum, self.edit_node.node, 12))
	self.node_t_list.label_rename.node:setString(Language.Role.TraceTxt)
end

function RoleTrace:OnConfirmRenameHandler()
	if nil ~= self.edit_node then
		if nil == self.alert_window then
			self.alert_window = Alert.New()
		end
		local text = self.edit_node.node:getText()
		local des = string.format(Language.Role.TraceConfirm, text)
		self.alert_window:SetLableString(des)
		self.alert_window:SetOkFunc(BindTool.Bind2(self.SendRenameHandler, self, text))
		self.alert_window:Open()				
		self.edit_node.node:setText("")
		self:Close()
	end
end

function RoleTrace:SendRenameHandler(text)
	if text and text ~= "" then
		RoleCtrl.Instance:SendSeekRoleWhere(text)
	end
end

function RoleTrace:OnCancelRenameHandler()
	if nil ~= self.edit_node then
		self.edit_node.node:setText("")
		self:Close()
	end
end