
CrossServerMatchResultPage = CrossServerMatchResultPage or BaseClass(XuiBaseView)

function CrossServerMatchResultPage:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self:SetIsAnyClickClose(true)
	self.texture_path_list[1] = "res/xui/strength_fb.png"
	self.texture_path_list[2] = "res/xui/fuben.png"
	self.config_tab  = {
							{"fuben_child_view_ui_cfg", 10, {0},},
						}
end

function CrossServerMatchResultPage:__delete()
	
end

function CrossServerMatchResultPage:ReleaseCallBack()
	if self.scene_event then
		 GlobalEventSystem:UnBind(self.scene_event)
		 self.scene_event = nil
	end
end

function CrossServerMatchResultPage:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCell()
		self.scene_event = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.ChangeScene, self))
	end
end

function CrossServerMatchResultPage:OnFlush(paramt, index)
	local get_score = ""
	local cfg_data = CrossLeagueMatchesCfg.AddScore
	local get_match = 1
	for k, v in pairs(paramt) do
		if k == "success" then
			get_score = v.key_1
			get_match = cfg_data[v.match_1].winAward or {}
		elseif k == "lose" then
			self.node_t_list.img_bg_3.node:loadTexture(ResPath.GetStrenfthFb("bg_14"))
			get_score = v.key_2
			get_match = cfg_data[v.match_2].loseAward or {}
		elseif k == "tie" then
			self.node_t_list.img_bg_3.node:loadTexture(ResPath.GetStrenfthFb("bg_15"))
			get_score = v.key_3
			get_match = cfg_data[v.match_3].drawAward or {}
		end
	end
	self.node_t_list.txt_jifen.node:setString(get_score)
	self:SetRewardShow(get_match)
end

function CrossServerMatchResultPage:CreateCell()
	self.reward_cell = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_rew_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_cross_server_match.node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end

function CrossServerMatchResultPage:SetRewardShow(data)
	local cur_data = {}
	if data ~= nil then
		for k_1, v_1 in pairs(data) do
			if v_1.id == 0 then
				local virtual_item_id = ItemData.Instance:GetVirtualItemId(v_1.type)
				if virtual_item_id then
					cur_data[k_1] = {["item_id"] = virtual_item_id, ["num"] = v_1.count, is_bind = 0}
				end
			else
				cur_data[k_1] = {item_id = v_1.id, num = v_1.count, is_bind = 0}
			end
		end
			
		for k2, v2 in pairs(self.reward_cell) do
			v2:GetView():setVisible(false)
		end
		for i3, v3 in ipairs(self.reward_cell) do
			if #cur_data >= i3 then
				v3:GetView():setVisible(true)
				self.node_t_list["rew_val_"..i3].node:setVisible(true)
			end
		end
		for i4, v4 in ipairs(cur_data) do
			self.node_t_list["rew_val_"..i4].node:setString("x".. v4.num)
		end
		
		for i5, v5 in ipairs(cur_data) do
			self.reward_cell[i5]:SetData({item_id = v5.item_id, num = 1, is_bind = 0})
		end

		for i6, v6 in ipairs(self.reward_cell) do
			local ph = self.ph_list["ph_rew_"..i6]
			if #cur_data == 1 then
				self.node_t_list["rew_val_"..i6].node:setPositionX(ph.x + 105)
				v6:GetView():setPositionX(ph.x + 105)
			elseif #cur_data == 2 then
				self.node_t_list["rew_val_"..i6].node:setPositionX(ph.x + 45)
				v6:GetView():setPositionX(ph.x + 45)
			end
		end
	end
end

function CrossServerMatchResultPage:OpenCallBack()
end

function CrossServerMatchResultPage:CloseCallBack()
	local enroll_state = CrossServerMatchData.Instance:GetMyEnrollState()
	local is_tips = CrossServerMatchData.Instance:GetIsEnrollTips()
	if is_tips == 1 and enroll_state == 1 then
		if nil == self.alert_guild_view then
			self.alert_guild_view = Alert.New()
		end
		self.alert_guild_view:SetShowCheckBox(true)
		self.alert_guild_view:SetLableString(Language.CrossServerMatch.IsEnroll)
		if self.alert_guild_view:GetIsNolongerTips() == false then
			self.alert_guild_view:Open()
			self.alert_guild_view:SetOkFunc(BindTool.Bind2(self.EnrollMatch, self))
		else
			self.alert_guild_view:SetOkFunc(BindTool.Bind2(self.CloseWindow, self))
		end
		-- self.alert_guild_view:SetCancelFunc(BindTool.Bind2(self.CloseWindow, self))
	end
end

function CrossServerMatchResultPage:EnrollMatch()
	CrossServerMatchCtrl.Instance:CrossServerEnrollReq(1)
end

function CrossServerMatchResultPage:CloseWindow()
	self.alert_guild_view:Close()
end

function CrossServerMatchResultPage:ChangeScene()
	if self:IsOpen() then
		self:Close()
	end
end