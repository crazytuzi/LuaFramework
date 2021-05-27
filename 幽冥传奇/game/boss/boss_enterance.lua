BossEntranceView = BossEntranceView or BaseClass(XuiBaseView)

function BossEntranceView:__init()
	self.texture_path_list[1] = 'res/xui/boss.png'
	self.texture_path_list[2] = 'res/xui/limit_activity.png'
	self.config_tab = {
		{"souyaota_ui_cfg", 1, {0}},
	}
	self.grid_list = nil 
	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)	
	self.item_list_event = BindTool.Bind1(self.ItemDataListChangeCallback, self)
end

function BossEntranceView:__delete()
end

function BossEntranceView:ReleaseCallBack()
	if self.boss_entrance_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.boss_entrance_timer)
		self.boss_entrance_timer = nil
	end
	if self.reward_cell ~= nil then
		for k,v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
end

function BossEntranceView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_enter_carbon.node:addClickEventListener(BindTool.Bind(self.OnEnterScene, self))
		self.node_t_list.btn_tip.node:addClickEventListener(BindTool.Bind(self.OnOpenTipsView, self))
		self:CreateCells()
	end
end

function BossEntranceView:CreateGrid()
	-- if self.grid_list == nil then
	-- 	self.grid_list = BaseGrid.New()
	-- 	local data = BossData.Instance:GetXiangYaoTaCfg()
	-- 	self.grid_list:SetPageChangeCallBack(BindTool.Bind1(self.OnPageChangeCallBack, self))
	-- 	local ph_baggrid = self.ph_list.ph_scroll_list
	-- 	local grid_node = self.grid_list:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, itemRender = BossEntranceRender, direction = ScrollDir.Horizontal,cell_count= #data, col = 4, row = 1,ui_config = self.ph_list.ph_list_item})
	-- 	grid_node:setAnchorPoint(0, 0)
	-- 	grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
	-- 	self.node_t_list.layout_souyaota.node:addChild(grid_node, 100)
	-- end
end

function BossEntranceView:OnPageChangeCallBack(grid, page_index, prve_page_index)
	-- self.gift_grid_index = page_index
	-- self:Flush()
end

function BossEntranceView:OpenCallBack()
	self:AddMoveAutoClose()
	BossCtrl.Instance:ReqBossRreshTime()
	if self.boss_entrance_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.boss_entrance_timer)
		self.boss_entrance_timer = nil
	end
	self.boss_entrance_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.FlushTime, self, -1), 1)
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_list_event)
end

function BossEntranceView:CloseCallBack()
	RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
	if ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_list_event)
	end
end

function BossEntranceView:ItemDataListChangeCallback()
	self:Flush()
end

function BossEntranceView:ShowIndexCallBack(index)
	self:Flush(index)
end

function BossEntranceView:OnFlush(param_t, index)
	
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	self.data = BossData.Instance:GetCurSuoYaoData(level, circle_level)
	local name = BossData.Instance:GetSceneCfg(self.data.scene_id)
	self.node_t_list.txt_layer_name.node:setString(name)
	local min_level = self.data.level_min[2]
	local min_circle = self.data.level_min[1]
	local max_level = self.data.level_max[2]
	local max_circle = self.data.level_max[1]
	local consume_count = self.data.consume.count
	local txt = ""
	if self.data.level_min[1] == 0 then
		txt = string.format(Language.Boss.EnterCondition3, min_level, max_level)
	else
		txt = string.format(Language.Boss.EnterCondition, min_circle, max_circle)
	end
	self.node_t_list.txt_consume_level.node:setString(txt)
	local consume_config = ItemData.Instance:GetItemConfig(self.data.consume_id)
	local num = ItemData.Instance:GetItemNumInBagById(self.data.consume_id)
	local color = "ff0000"
	if num >= consume_count then
		color = "00ff00"
	end
	if consume_config == nil then return end
	local name = consume_config.name
	local txt = string.format(Language.Boss.Consume_1, color, name, consume_count)
	RichTextUtil.ParseRichText(self.node_t_list.txt_consume.node, txt, 22)
	local bool_open = false
	if min_circle == 0 then
		if (min_level <= level and level <= max_level) then
			bool_open = true
		end 
	else
		if  (min_circle <= circle_level and circle_level <= max_circle) then
			bool_open = true
		end 
	end
	XUI.SetButtonEnabled(self.node_t_list.btn_enter_carbon.node, bool_open)
	self.node_t_list.txt_consume_level.node:setColor(bool_open and COLOR3B.GREEN or COLOR3B.RED)
	self:FlushTime()
	local reward_data = BossData.Instance:GetMyProfReward(self.data.drop_data)
	for k, v in pairs(reward_data) do
		if self.reward_cell[k] ~= nil then
			self.reward_cell[k]:SetData(v)
		end
	end
end

function BossEntranceView:CreateCells()
	self.reward_cell = {}
	for i = 1, 6 do
		local ph = self.ph_list.ph_cell
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 85*(i-1), ph.y)
		self.node_t_list["layout_souyaota"].node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end

function BossEntranceView:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.CREATURE_LEVEL or key == OBJ_ATTR.ACTOR_CIRCLE then
		self:Flush()
	end
end

function BossEntranceView:FlushTime()
	if self.data == nil then return end
	local remaintime = self.data.refresh_time - TimeCtrl.Instance:GetServerTime()
	local txt = ""
	if remaintime > 0 then
		txt = string.format(Language.Boss.RefrshTime, TimeUtil.FormatSecond(remaintime, 3))
	else
		txt = Language.Boss.BossAppear
	end
	self.node_t_list.txt_time.node:setString(txt)
	self.node_t_list.txt_time.node:setColor(remaintime > 0 and COLOR3B.GREEN or COLOR3B.GREEN)
end

function BossEntranceView:OnEnterScene()
	BossCtrl.Instance:SendEnterSouYaoTaReq()
end

function BossEntranceView:OnOpenTipsView()
	DescTip.Instance:SetContent(Language.Boss.TipSuoYaoTaDesc, Language.Boss.TipSuoYaoTaTitle)
end
-- BossEntranceRender = BossEntranceRender or BaseClass(BaseRender)

-- function BossEntranceRender:__init()

-- end

-- function BossEntranceRender:__delete()
-- 	self:DeleteRedEnvelopeTimer()
-- end

-- function BossEntranceRender:CreateChild()
-- 	BaseRender.CreateChild(self)
-- 	self.node_tree.btn_enter_map.node:addClickEventListener(BindTool.Bind(self.OnEnterScene, self))
-- end

-- function BossEntranceRender:OnEnterScene()
-- 	BossCtrl.Instance:SendEnterSouYaoTaReq()
-- end

-- function BossEntranceRender:OnFlush()
-- 	if self.data == nil then return end
-- 	self:CreateRedEnvelopeTimer()

-- 	local min_level = self.data.level_min[2]
-- 	local min_circle = self.data.level_min[1]
-- 	local max_level = self.data.level_max[2]
-- 	local max_circle = self.data.level_max[1]
-- 	local consume_count = self.data.consume.count
-- 	local bool_open = false
-- 	if circle_level == 0 then
-- 		if (min_level <= level and level <= max_level) then
-- 			bool_open = true
-- 		end 
-- 	else
-- 		if  (min_circle <= circle_level and circle_level <= max_circle) then
-- 			bool_open = true
-- 		end 
-- 	end
-- 	XUI.SetButtonEnabled(self.node_tree.btn_enter_map.node, bool_open)
-- 	local consume_config = ItemData.Instance:GetItemConfig(self.data.consume_id)
-- 	if consume_config == nil then return end
-- 	local name = consume_config.name
-- 	local txt = nil 
-- 	if bool_open == true then
-- 		txt = string.format(Language.Boss.Consume, name, consume_count)
-- 	else 
-- 		if min_circle == 0 then
-- 			txt = string.format(Language.Boss.EnterCondition3, min_level, max_level)
-- 		else
-- 			txt = string.format(Language.Boss.EnterCondition, min_circle, max_circle)
-- 		end
-- 	end
-- 	self.node_tree.txt_desc.node:setString(txt)
-- 	local name = BossData.Instance:GetSceneCfg(self.data.scene_id)
-- 	self.node_tree.txt_layer_name.node:setString(name)
	
-- end

-- function BossEntranceRender:CreateRedEnvelopeTimer()
-- 	if self.boss_entrance_timer ~= nil then
-- 		GlobalTimerQuest:CancelQuest(self.boss_entrance_timer)
-- 		self.boss_entrance_timer = nil
-- 	end
-- 	self.boss_entrance_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.FlushTime, self, -1), 1)
-- end

-- function BossEntranceRender:DeleteRedEnvelopeTimer()
-- 	if self.boss_entrance_timer ~= nil then
-- 		GlobalTimerQuest:CancelQuest(self.boss_entrance_timer)
-- 		self.boss_entrance_timer = nil
-- 	end
-- end

-- function BossEntranceRender:FlushTime()
-- 	local remaintime = self.data.refresh_time - TimeCtrl.Instance:GetServerTime()
-- 	if remaintime < 0 then
-- 		self:DeleteRedEnvelopeTimer()
-- 	end
-- 	local txt = ""
-- 	if remaintime > 0 then
-- 		txt = string.format(Language.Boss.RefrshTime, TimeUtil.FormatSecond(remaintime, 3))
-- 	else
-- 		txt = Language.Boss.BossAppear
-- 	end
-- 	self.node_tree.txt_time.node:setString(txt)
-- 	self.node_tree.txt_time.node:setColor(remaintime > 0 and COLOR3B.WHITE or COLOR3B.GREEN)
-- end