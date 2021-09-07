BackFlowersView = BackFlowersView or BaseClass(BaseView)

function BackFlowersView:__init()
	self.ui_config = {"uis/views/flowersview","BackFlowers"}
	self:SetMaskBg(true)
	self.full_screen = false
	self.play_audio = true
	self.role_infotable = {}
	self.item = {}
end

function BackFlowersView:__delete()

end

function BackFlowersView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.CloseView,self))
	self:ListenEvent("chosen_chat", BindTool.Bind(self.ChosenChat,self))
	self:ListenEvent("chosen_backflower", BindTool.Bind(self.ChosenBackFlower,self))
	self:ListenEvent("tips_click", BindTool.Bind(self.OnTipsClick,self))

	self.backFlowersInfo = self:FindVariable("backFlowersInfo")

	self.tips_toggle = self:FindObj("tips_toggle")

	local flow_role_info = FlowersData.Instance:GetFlowersInfo()
	local item = ItemCell.New()
	item:SetInstanceParent(self:FindObj("show_item"))
	item:ListenClick(BindTool.Bind(self.ItemClick, self))
	item:SetData(flow_role_info)
	item:ShowHighLight(false)
	self.item = item
end

function BackFlowersView:ReleaseCallBack()
	self.item = {}
	self.backFlowersInfo = nil
	self.tips_toggle = nil
end

function BackFlowersView:OpenCallBack()
	self:Flush()
	self.tips_toggle.toggle.isOn = true
end

function BackFlowersView:CloseCallBack()
end



function BackFlowersView:OnFlush()
	self.backFlowersInfo:SetValue(string.format(Language.Flower.ReceiveFlowerTxt,self.target_name,ToColorStr(self.flower_name, TEXT_COLOR.PURPLE)))
end

function BackFlowersView:CloseView()
	self:Close()
end

function BackFlowersView:ChosenChat()
	local limit_level = COMMON_CONSTS.PRIVATE_CHAT_LEVEL_LIMIT
	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").chat_limit
	if agent_cfg ~= nil then
		for k,v in pairs(agent_cfg) do
			if v.spid == spid then
				if v["day_" .. open_day] ~= nil then
					limit_level = v["day_" .. open_day]
				else
					if v.def_day then
						limit_level = v.def_day
					end
				end

				break
			end
		end
	end

	if GameVoManager.Instance:GetMainRoleVo().level < limit_level and PlayerData.Instance:GetTotalChongZhi() < COMMON_CONSTS.PRIVATE_CHAT_CHONGZHI then
		local level_str = PlayerData.GetLevelString(limit_level)
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
		return
	end
	local private_obj = {}
	if nil == ChatData.Instance:GetPrivateObjByRoleId(self.role_infotable.role_id) then
			private_obj = ChatData.CreatePrivateObj()
			private_obj.role_id = self.role_infotable.role_id
			private_obj.username = self.role_infotable.role_name
			private_obj.sex = self.role_infotable.sex
			private_obj.camp = self.role_infotable.camp
			private_obj.guildname = self.role_infotable.guildname
			private_obj.prof = self.role_infotable.prof
			private_obj.avatar_key_small = self.role_infotable.avatar_key_small
			private_obj.level = self.role_infotable.level
			ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
	end
	ChatData.Instance:SetCurrentRoleId(self.role_infotable.role_id)

	-- if ViewManager.Instance:IsOpen(ViewName.ChatGuild) then
		-- ChatCtrl.Instance.view:ChangeToIndex(TabIndex.chat_private)
	-- else
		ViewManager.Instance:Open(ViewName.ChatGuild)
	-- end

	self:Close()
end

function BackFlowersView:SetRoleInfotable(info)
	self.role_infotable.role_id = info.role_id
	self.role_infotable.role_name = info.role_name
	self.role_infotable.guildname = info.guild_name
	self.role_infotable.sex = info.sex
	self.role_infotable.camp = info.camp
	self.role_infotable.prof = info.prof
	self.role_infotable.avatar_key_small = info.avatar_key_small
	self.role_infotable.avatar_key_big = info.avatar_key_big
	self.role_infotable.level = info.level
end

function BackFlowersView:OnTipsClick()
	FlowersData.Instance:SetIsNotTips(self.tips_toggle.toggle.isOn)
	if self.tips_toggle.toggle.isOn then
		FlowersData.Instance:RegisterFromUid(self.from_uid)
	else
		FlowersData.Instance:UnRegisterFromUid(self.from_uid)
	end
end

function BackFlowersView:ChosenBackFlower()
	FlowersData.Instance:SetIsNotTips(self.tips_toggle.toggle.isOn)
	if self.tips_toggle.toggle.isOn then
		FlowersData.Instance:RegisterFromUid(self.from_uid)
		local flow_role_info = FlowersData.Instance:GetFlowersInfo()
		local grid_index = ItemData.Instance:GetItemIndex(flow_role_info.item_id)
		FlowersCtrl.Instance:SendFlowersReq(grid_index, flow_role_info.item_id, flow_role_info.from_uid, 0, 0)
	else
		FlowersCtrl.Instance:SetFriendInfo(self.role_infotable)
		ViewManager.Instance:Open(ViewName.Flowers)
		FlowersData.Instance:UnRegisterFromUid(self.from_uid)
	end
	
	self:Close()
end

function BackFlowersView:SetInfo(backflowersinfo)
	self.from_uid = backflowersinfo.from_uid
	self.target_name = backflowersinfo.from_name
	self.item_cfg = ItemData.Instance:GetItemConfig(backflowersinfo.item_id)

	self.flower_name = self.item_cfg.name
	self.flower_num = backflowersinfo.flower_num
end

function BackFlowersView:ItemClick()
	local flow_role_info = FlowersData.Instance:GetFlowersInfo()
	TipsCtrl.Instance:OpenItem(flow_role_info)
end

