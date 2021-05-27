
CrossEatChickenResult = CrossEatChickenResult or BaseClass(XuiBaseView)

function CrossEatChickenResult:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.texture_path_list[1] = "res/xui/strength_fb.png"
	self.texture_path_list[2] = "res/xui/fuben.png"
	self.config_tab  = {
							{"fuben_child_view_ui_cfg", 11, {0},},
						}
	self.reward_cell = {}
end

function CrossEatChickenResult:__delete()
	
end

function CrossEatChickenResult:ReleaseCallBack()
	if self.scene_event then
		 GlobalEventSystem:UnBind(self.scene_event)
		 self.scene_event = nil
	end

	if self.reward_cell ~= nil then
		for i,v in ipairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
end

function CrossEatChickenResult:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCell()
		self.scene_event = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.ChangeScene, self))
		local main_role_name = Scene.Instance:GetMainRole():GetName() or ""
		self.node_t_list.txt_cross_eat_chicken_player.node:setString(main_role_name)
	end
end

function CrossEatChickenResult:OnFlush(paramt, index)
	for k, v in pairs(paramt) do
		if k == "result" then
			self.node_t_list.txt_cross_eat_chicken_rank.node:setString(string.format(Language.Common.RankText, v[1]))
			self.node_t_list.txt_cross_eat_kill_cnt.node:setString(v[2])
			self.node_t_list.txt_cross_eat_score.node:setString(v[3])

			local reward_data = CrossEatChickenCfg.pkScore
			local cur_data = {}
			for k1, v1 in pairs(reward_data) do
				if v[1] <= v1.cond[2] and v[1] >= v1.cond[1] then
					for k_1, v_1 in pairs(v1.award) do
						if v_1.id == 0 then
							local virtual_item_id = ItemData.Instance:GetVirtualItemId(v_1.type)
							if virtual_item_id then
								cur_data[k_1] = {["item_id"] = virtual_item_id, ["num"] = v_1.count, is_bind = 0}
							end
						else
							cur_data[k_1] = {item_id = v_1.id, num = v_1.count, is_bind = 0}
						end
					end
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
		end
	end
end

function CrossEatChickenResult:CreateCell()
	self.reward_cell = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_rew_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_cross_eat_chicken_result.node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end

function CrossEatChickenResult:OpenCallBack()
end

function CrossEatChickenResult:CloseCallBack()
	local enroll_state = CrossEatChickenData.Instance:GetMyInfo("my_enroll_state")
	local is_tips = CrossEatChickenData.Instance:GetRemindTipState()
	if is_tips == 1 and enroll_state == 1 then
		if nil == self.alert_guild_view then
			self.alert_guild_view = Alert.New()
		end
		self.alert_guild_view:SetShowCheckBox(true)
		self.alert_guild_view:SetLableString(Language.CrossServerMatch.IsEnroll)
		if self.alert_guild_view:GetIsNolongerTips() == false then
			self.alert_guild_view:Open()
			self.alert_guild_view:SetOkFunc(BindTool.Bind(self.EnrollMatch, self))
		else
			self.alert_guild_view:SetOkFunc(BindTool.Bind(self.CloseWindow, self))
		end
		-- self.alert_guild_view:SetCancelFunc(BindTool.Bind2(self.CloseWindow, self))
	end
end

function CrossEatChickenResult:EnrollMatch()
	CrossEatChickenCtrl.CrossEatChickeEnrollReq(1)
end

function CrossEatChickenResult:CloseWindow()
	self.alert_guild_view:Close()
end

function CrossEatChickenResult:ChangeScene()
	if self:IsOpen() then
		self:Close()
	end
end