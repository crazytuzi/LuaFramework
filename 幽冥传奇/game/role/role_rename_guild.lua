RoleRenameGuildView = RoleRenameGuildView or BaseClass(RoleRename)

function RoleRenameGuildView:LoadCallBack()
	RoleRename.LoadCallBack(self)
	self.node_t_list.label_rename.node:setString(Language.Role.RenameGuildTxt)
end

-- 发送改名申请
function RoleRenameGuildView:OnConfirmRenameHandler()
	if nil ~= self.edit_node then
		local name = self.edit_node.node:getText()
		if "" == name then			
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NeedInputGuildName)
			return
		end
		-- 增加敏感词过滤
		-- name = ChatFilter.Instance:Filter(name)

		if AdapterToLua:utf8CharCount(name) > GuildDataConst.MAX_LEN then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GuildNameMaxLen)
			return
		end
		if ChatFilter.Instance:IsIllegal(name, true) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent)
			return
		end
		if nil == self.alert_window then
			self.alert_window = Alert.New()
		end
		local des = string.format(Language.Role.ReNameGuildConfirm, name)
		self.alert_window:SetLableString(des)
		self.alert_window:SetOkFunc(BindTool.Bind2(self.SendRenameHandler, self, name))
		self.alert_window:Open()				
		self.edit_node.node:setText('')
		self:Close()
	end
end


function RoleRenameGuildView:SendRenameHandler(text)
	if text and text ~= "" then
		RoleCtrl.Instance.SendGuildResetName(text)
	end
end