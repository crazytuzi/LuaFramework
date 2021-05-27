AddBlacklistView = AddBlacklistView or BaseClass(XuiBaseView)

function AddBlacklistView:__init()
	self.data = GuildData.Instance
	self:SetModal(true)
	self.config_tab = {	
		{"chat_ui_cfg", 8, {0}},
	}
end

function AddBlacklistView:__delete()
	
end

function AddBlacklistView:LoadCallBack()
	self.node_t_list.btn_addbl_ok.node:addClickEventListener(BindTool.Bind1(self.OnAddBlacklist, self))
end

-- 添加黑名单
function AddBlacklistView:OnAddBlacklist()
	if nil ~= self.node_t_list.edit_name then
		local game_name = self.node_t_list.edit_name.node:getText()
		self.node_t_list.edit_name.node:setText("")
		local msg_ctrl = SysMsgCtrl.Instance
		if nil ~= game_name and "" ~= game_name then
			if ChatData.Instance:InBlacklist(nil, game_name) then
				if nil ~= Language.Chat["AlreadyYouFriend"] then
					msg_ctrl:ErrorRemind(Language.Chat["AlreadyYouFriend"])
				end
				return
			end

			SocietyCtrl.Instance:GetUserInfoByName(2151,game_name,function (flag, user_info)
				--找不到角色的时候
				if 0 == flag or nil == user_info then
					if nil ~= Language.Chat["UserNotExist"] then
						msg_ctrl:ErrorRemind(Language.Chat["UserNotExist"])
					end
					return
				end

				--添加的人为自己的时候
				if user_info.role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
					if nil ~= Language.Chat["NotAddSelf"] then
						msg_ctrl:ErrorRemind(Language.Chat["NotAddSelf"])
					end
					return
				end
					
				ChatCtrl.Instance:SendAddBlackReq(user_info.role_id)
			end)
		end
	end
end