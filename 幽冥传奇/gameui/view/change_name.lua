--更名弹窗
ChangeNameView = ChangeNameView or BaseClass(BaseView)

function ChangeNameView:__init()
	self:SetIsAnyClickClose(true)
	self:SetModal(true)
	self.config_tab = {{"change_name_ui_cfg", 1, {0}}}
	self.used_item_series = nil
end

function ChangeNameView:__delete()

end

function ChangeNameView:LoadCallBack(index, loaded_times)
	-- override
	if loaded_times <= 1 then
		self.node_t_list.edit_player_name.node:setPlaceHolder(Language.Common.InputNameTips[1])
		self.node_t_list.edit_player_name.node:setFontSize(22)
		self.node_t_list.edit_player_name.node:setFontColor(COLOR3B.WHITE)
		self.node_t_list.edit_player_name.node:registerScriptEditBoxHandler(BindTool.Bind(ChatData.ExamineEditNameNum, self.node_t_list.edit_player_name.node, 12))
		XUI.AddClickEventListener(self.node_t_list.btn_OK.node, BindTool.Bind(self.OnOkClicked, self))
		XUI.AddClickEventListener(self.node_t_list.btn_cancel.node, BindTool.Bind(self.OnCancelClicked, self))
	end
end

function ChangeNameView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChangeNameView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ChangeNameView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChangeNameView:ReleaseCallBack()
	self.used_item_series = nil
end

function ChangeNameView:OnFlush(param_list, index)
	for k,v in pairs(param_list) do
		if k == "Open" then
			self.used_item_series = v[1]
		end
	end
end

function ChangeNameView:OnOkClicked()
	local name = self.node_t_list.edit_player_name.node:getText()
	if name ~= "" then
		if self.used_item_series then
			local len = string.len(name)
			if len <= 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Login.EditName, true)
				return
			end

			if AdapterToLua:utf8FontCount(name) > 12 or AdapterToLua:utf8CharCount(name) > 6 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Login.NameToLong, true)
				return
			end
			
			if ChatFilter.Instance:IsIllegal(name, true) then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent, true)
				return
			end

			local i, j = string.find(name, "*")
			if i ~= nil and j ~= nil then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent, true)
				return
			end
			local qukong_text = string.gsub(name, "%s", "")
			local qukong_text_len = string.len(qukong_text)  
			--判断输入的名字是否带空格	
			if qukong_text_len ~= len then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent, true)
				return 
			end

			local user_vo = GameVoManager.Instance:GetUserVo()
			local namePrefix = string.format(Language.Common.NamePrefix, user_vo.merge_id or 1)
			name = namePrefix .. name
			OtherCtrl.RenameReq(self.used_item_series, name)
			self:Close()

			GlobalEventSystem:Fire(OtherEventType.MAIN_ROLE_CHANGE_NAME, {change_name = name})
		else
			OtherCtrl.RenameGuildReq(name)
		end
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.InputNameTips[2])
	end
end

function ChangeNameView:OnCancelClicked()
	self:Close()
end