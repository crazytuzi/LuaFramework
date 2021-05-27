
CombindeServerArenaLosePage = CombindeServerArenaLosePage or BaseClass(XuiBaseView)

function CombindeServerArenaLosePage:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self:SetIsAnyClickClose(true)
	self.texture_path_list[1] = "res/xui/strength_fb.png"
	self.texture_path_list[2] = "res/xui/fuben.png"
	self.config_tab  = {
							{"fuben_child_view_ui_cfg", 8, {0},},
						}
	self.reward_cell = {}
end

function CombindeServerArenaLosePage:__delete()
	
end

function CombindeServerArenaLosePage:ReleaseCallBack()
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

function CombindeServerArenaLosePage:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCell()
		XUI.AddClickEventListener(self.node_t_list.layout_exit.node, BindTool.Bind1(self.OnExitFuben, self))
		self.scene_event = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.ChangeScene, self))
	end
end

function CombindeServerArenaLosePage:OnFlush(paramt, index)
	self.node_t_list.img_bg_3.node:loadTexture(ResPath.GetStrenfthFb("bg_14"))
	for k,v in pairs(paramt) do
		if k == "Lose" then
			local data = v.key 
			local reward_data = CombineServerArenaCfg.arena.loseAwards
			local cur_data = {}
			for i, v in ipairs(reward_data) do
				if v.id == 0 then
					local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
					if virtual_item_id then
						cur_data[i] = {["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0}
					end
				else
					cur_data[i] = {item_id = v.id, num = v.count, is_bind = 0}
				end
			end
			for k,v in pairs(self.reward_cell) do
				v:GetView():setVisible(false)
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
					v:GetView():setPositionX(ph.x + 55)
					self.node_t_list["rew_val_"..i].node:setPositionX(ph.x + 45)
				end
			end
			
			-- if data.state == 1 then
			-- 	self.node_t_list.img_bg_1.node:loadTexture(ResPath.GetStrenfthFb("bg_13"))
			-- elseif data.state == 0 then
			
			-- end
		end
	end
end

function CombindeServerArenaLosePage:CreateCell()
	self.reward_cell = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_rew_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_combine_arena_faild.node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end

function CombindeServerArenaLosePage:OpenCallBack()
end

function CombindeServerArenaLosePage:CloseCallBack()
end

function CombindeServerArenaLosePage:OnExitFuben()
	--Scene.Instance:QuitActiveFubenReq(1)
	if self:IsOpen() then
		self:Close()
	end
end

function CombindeServerArenaLosePage:ChangeScene()
	if self:IsOpen() then
		self:Close()
	end
end