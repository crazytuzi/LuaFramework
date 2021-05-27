MagicCityCommonSucessView = MagicCityCommonSucessView or BaseClass(XuiBaseView)

function MagicCityCommonSucessView:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self:SetIsAnyClickClose(true)
	self.texture_path_list[1] = "res/xui/strength_fb.png"
	self.texture_path_list[2] = "res/xui/fuben.png"
	self.config_tab  = {
							{"fuben_child_view_ui_cfg", 3, {0},},
						}
	self.reward_cell = {}
	self.star_list = {}
end

function MagicCityCommonSucessView:__delete()
	
end

function MagicCityCommonSucessView:ReleaseCallBack()
	if self.reward_cell ~= nil then
		for i,v in ipairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
	if self.scene_event then
		 GlobalEventSystem:UnBind(self.scene_event)
		 self.scene_event = nil
	end
end

function MagicCityCommonSucessView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		
		self:CreateCell()
		self:CreateStar()
		XUI.AddClickEventListener(self.node_t_list.layout_exit.node, BindTool.Bind1(self.OnExitFuben, self))
		self.scene_event = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.ChangeScene, self))
	end
end

function MagicCityCommonSucessView:OnFlush(paramt, index)
	for k,v in pairs(paramt) do
		if k == "Success" then
			local data = v.key 
			local reward_data = data.reward_data
			local txt = ""
			if data.activity_id == ActiveFbID.MagicCity then
				reward_data = MagicCityData.Instance:GetReward(data.activity_id_child, data.tongguang_star)
				txt = string.format(Language.MagicCity.TongGuangTime, TimeUtil.FormatSecond(data.tongguang_time, 2))
			elseif data.activity_id  == ActiveFbID.GuildExploreBoss then
				reward_data = GuildData.Instance:GetExploreReward(data.activity_id_child)
			elseif data.activity_id == ActiveFbID.TeamBoss then
				if #reward_data <= 0 then -- 没有奖励
					txt = Language.Boss.TongGuangDesc
				end
			end

			self.node_t_list.txt_tonguang_time.node:setString(txt)
			self.node_t_list.layout_boss_reward.node:setVisible(false)
			local cur_data = {}
			for i, v in ipairs(reward_data) do
				if v.type > 0 then
					local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
					local count = 0
					if v.type == tagAwardType.qatAddExp then
						count = ItemData.Instance:CalcuSpecialExpVal(v)
					else
						count = v.count
					end
					if virtual_item_id then
						cur_data[i] = {["item_id"] = virtual_item_id, ["num"] = count, is_bind = 0}
					end
				else
					cur_data[i] = {item_id = v.id, num = v.count, is_bind = 0}
				end
			end
			for k,v in pairs(self.reward_cell) do
				v:GetView():setVisible(false)
				self.node_t_list["rew_val_"..k].node:setVisible(false)
			end
			for i, v in ipairs(self.reward_cell) do
				if #cur_data >= i then
					v:GetView():setVisible(true)
					self.node_t_list["rew_val_"..i].node:setVisible(true)
				end
			end
			for i, v in ipairs(cur_data) do
				self.node_t_list["rew_val_"..i].node:setString("x"..v.num)
			end
			for i, v in ipairs(cur_data) do
				self.reward_cell[i]:SetData({item_id = v.item_id, num = 1, is_bind = 0})
			end

			for i, v in ipairs(self.reward_cell) do
				local ph = self.ph_list["ph_rew_"..i]
				if #cur_data == 1 then
					v:GetView():setPositionX(ph.x + 105)
					self.node_t_list["rew_val_"..i].node:setPositionX(ph.x + 105)
				elseif #cur_data == 2 then
					v:GetView():setPositionX(ph.x + 45)
					self.node_t_list["rew_val_"..i].node:setPositionX(ph.x + 45)
				end
			end
			local path = ""
			if data.state == 1 then
				if data.activity_id == ActiveFbID.ExperDesertKillGod then
					path = ResPath.GetStrenfthFb("tiyan_bg")
				else
					path = ResPath.GetStrenfthFb("bg_4")
				end
				self.node_t_list.img_bg_4.node:loadTexture(ResPath.GetStrenfthFb("bg_6"))
				self:StarVisible(data.tongguang_star or 3)
			elseif data.state == 2 then
				path = ResPath.GetStrenfthFb("bg_7")
				self.node_t_list.img_bg_4.node:loadTexture(ResPath.GetStrenfthFb("bg_8"))
				for k,v in pairs(self.star_list) do
					v:setVisible(false)
				end
			end
			self.node_t_list.img_bg_5.node:loadTexture(path)
		end
	end
end

function MagicCityCommonSucessView:CreateCell()
	self.reward_cell = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_rew_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_strength_success_title.node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end

function MagicCityCommonSucessView:CreateStar()
	self.star_list = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_star_"..i]
		local file = ResPath.GetCommon("star_2_1")	
		local start = XUI.CreateImageView(ph.x + 35 , ph.y + 40, file)
		self.node_t_list.layout_strength_success_title.node:addChild(start, 999)
		table.insert(self.star_list, start)
	end
end

function MagicCityCommonSucessView:StarVisible(star)
	for i,v in pairs(self.star_list) do
		if star >= i then
			v:setVisible(true)
		else
			v:setVisible(false)
		end
	end
end

function MagicCityCommonSucessView:OpenCallBack()
end

function MagicCityCommonSucessView:CloseCallBack()
end

function MagicCityCommonSucessView:OnExitFuben()
	if self:IsOpen() then
		self:Close()
	end
	local sceneType = Scene.Instance:GetSceneType()
	if Scene.Instance:GetFbID() > 0 then
		Scene.Instance:QuitActiveFubenReq(sceneType)
	end
end

function MagicCityCommonSucessView:ChangeScene()
	-- if self:IsOpen() then
	-- 	self:Close()
	-- end
end