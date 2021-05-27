RoleRename = RoleRename or BaseClass(XuiBaseView)

function RoleRename:__init()
	self.is_modal = true
	self.config_tab  = {
		{"rename_ui_cfg", 1 , {0}},
	}
end

function RoleRename:__delete()
	if nil ~= self.alert_window then
		self.alert_window:DeleteMe()
		self.alert_window = nil
	end
end

function RoleRename:LoadCallBack()
	self.edit_node = self.node_t_list.edit_input_4_4
	XUI.AddClickEventListener(self.node_t_list.btn_rename_confirm.node, BindTool.Bind1(self.OnConfirmRenameHandler, self))
	XUI.AddClickEventListener(self.node_t_list.btn_rename_cancel.node, BindTool.Bind1(self.OnCancelRenameHandler, self))
	self.edit_node.node:registerScriptEditBoxHandler(BindTool.Bind2(ChatData.ExamineEditNameNum, self.edit_node.node, 12))
end

-- 发送改名申请
function RoleRename:OnConfirmRenameHandler()
	if nil ~= self.edit_node then
		local text = self.edit_node.node:getText()
		local len = string.len(text)
		if len <= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Login.EditName, true)
			return
		end

		if AdapterToLua:utf8FontCount(text) > 12 or AdapterToLua:utf8CharCount(text) > 6 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Login.NameToLong, true)
			return
		end
		
		if ChatFilter.Instance:IsIllegal(text, true) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent, true)
			return
		end

		local i, j = string.find(text, "*")
		if i ~= nil and j ~= nil then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent, true)
			return
		end

		local qukong_text = string.gsub(text, "%s", "")
		local qukong_text_len = string.len(qukong_text)  
		--判断输入的名字是否带空格	
		if qukong_text_len ~= len then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent, true)
			return 
		end	
		if nil == self.alert_window then
			self.alert_window = Alert.New()
		end
		local des = string.format(Language.Role.ReNameConfirm, text)
		self.alert_window:SetLableString(des)
		self.alert_window:SetOkFunc(BindTool.Bind2(self.SendRenameHandler, self, text))
		self.alert_window:Open()				
		self.edit_node.node:setText('')
		self:Close()
	end
end

function RoleRename:SendRenameHandler(text)
	if text and text ~= "" then
		RoleCtrl.Instance.SendRoleResetName(text, 1)
	end
end

-- 取消改名申请 edit_input_4_4
function RoleRename:OnCancelRenameHandler()
	if nil ~= self.edit_node then
		self.edit_node.node:setText('')
		self:Close()
	end
end