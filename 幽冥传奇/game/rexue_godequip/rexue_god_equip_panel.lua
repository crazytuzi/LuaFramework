local  ReXueGodEquipPanel = BaseClass(SubView)

function ReXueGodEquipPanel:__init( ... )
	self.texture_path_list = {
		'res/xui/equipbg.png',
		'res/xui/rexue.png',
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"rexue_god_equip_ui_cfg", 1, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
	}
	self.index = 1
end


function ReXueGodEquipPanel:__delete( ... )
	-- body
end

function ReXueGodEquipPanel:LoadCallBack( ... )
	--print(">>>>>>>>", self.equip_list)
	self:CreateList()
	self:CreateAccordition()
	self:CreateModelAndEffect()
	self:CreateCellShow()
	self:CreateSkillCell()
	if nil == self.tabbar then
		local ph = self.ph_list["ph_tabbar"]
		self.exchange_layout = self.node_t_list.layout_rexue
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.exchange_layout.node, ph.x, ph.y - 3,
			function(index) self:ChangeToIndex(index) end, 
			Language.ReXueGodEquip.TabGroup1, false, ResPath.GetCommon("toggle_121"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self.tabbar:SetSpaceInterval(5)
	end	
	
	
	self.all_data = nil
	self.select_data = nil
	XUI.AddClickEventListener(self.node_t_list.btn_tips_shenzhuang.node, BindTool.Bind1(self.OpenTips, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_compose_wu.node, BindTool.Bind1(self.ComposeWu, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_compose_other.node, BindTool.Bind1(self.ComposeOther, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_suit_tip.node, BindTool.Bind1(self.OpenSuitTips, self), true)


	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
	self.bag_compose_result = GlobalEventSystem:Bind(KnapsackEventType.KNAPSACK_COMPOSE_EQUIP, BindTool.Bind(self.ComposeResult, self))
	--self:ComposeResult()
end

function ReXueGodEquipPanel:OpenSuitTips()
	local suittype = self.index == 3 and 11 or 10
	ReXueGodEquipCtrl.Instance:OpenTipView(suittype)
end

function ReXueGodEquipPanel:ReleaseCallBack( ... )
	
	if self.tabbar  then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.equip_list then
		self.equip_list:DeleteMe()
		self.equip_list = nil 
	end

	if self.tabbar_list then
		self.tabbar_list:DeleteMe()
		self.tabbar_list = nil
	end
	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end

	if self.effect_model then
		self.effect_model:setStop()
		self.effect_model = nil
	end

	if self.compose_cell then
		self.compose_cell:DeleteMe()
		self.compose_cell = nil
	end
	if self.reward_cell then
		self.reward_cell:DeleteMe()
		self.reward_cell = nil
	end
	if self.comsume_cell then
		self.comsume_cell:DeleteMe()
		self.comsume_cell = nil
	end

	if self.comsume_cell2 then
		self.comsume_cell2:DeleteMe()
		self.comsume_cell2 = nil
	end

	if self.bag_compose_result then
		--self.bag_compose_result:DeleteMe()
		GlobalEventSystem:UnBind(self.bag_compose_result)
		self.bag_compose_result = nil
	end
	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil
	end
	if self.effect_show2 then
		self.effect_show2:setStop()
		self.effect_show2 = nil
	end
	if nil ~= self.time_delay then
		GlobalTimerQuest:CancelQuest(self.time_delay)
		self.time_delay = nil
	end

	if self.skill_cell then
		self.skill_cell:DeleteMe()
		self.skill_cell = nil
	end
end

function ReXueGodEquipPanel:ComposeResult()
	if nil == self.effect_show1 then
		local ph = self.ph_list.ph_reward_cell
	 	self.effect_show1 = AnimateSprite:create()
	 	self.effect_show1:setPosition(ph.x + 45, ph.y + 46)
	 	 self.node_t_list.layout_other_compose.node:addChild(self.effect_show1, 999)
	end
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1151)
	self.effect_show1:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
	self.time_delay = GlobalTimerQuest:AddDelayTimer(function ()
			if nil == self.effect_show2 then
				local ph = self.ph_list.ph_reward_cell
			 	self.effect_show2 = AnimateSprite:create()
			 	self.effect_show2:setPosition(ph.x + 35, ph.y + 25)
			 	 self.node_t_list.layout_other_compose.node:addChild(self.effect_show2, 999)
			end
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1152)
			self.effect_show2:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
		if nil ~= self.time_delay then
			GlobalTimerQuest:CancelQuest(self.time_delay)
			self.time_delay = nil
		end
	end, 1)
end

function ReXueGodEquipPanel:CreateSkillCell( ... )
	local ph = self.ph_list.ph_skill_cell
	if self.skill_cell == nil then
		self.skill_cell = RexueSkillCell.New()
		self.node_t_list.layout_rexue.node:addChild(self.skill_cell:GetView(), 99)
		self.skill_cell:GetView():setPosition(ph.x, ph.y)
		XUI.AddClickEventListener(self.skill_cell:GetView(), BindTool.Bind1(self.OpenSkillTip, self))
	end
end

function ReXueGodEquipPanel:SetSkillShow( ... )
	local skill_id = 0
	local skiill_level = 0
	local bool = false
	local icon = "2000_1"
	if self.index == 1 or self.index == 2 then
		skill_id = SuitPlusConfig[10].list[1].skillid
		skill_level =  1
		local suitlevel = EquipData.Instance:GetZhiZunSuitLevel()
		if suitlevel > 0 then
			skill_id = SuitPlusConfig[10].list[suitlevel].skillid
			skill_level =  SuitPlusConfig[10].list[suitlevel].skillLv
			bool = true
		end
		icon = "2000_1"
	elseif self.index == 3 then
		skill_id = SuitPlusConfig[11].list[1].skillid
		skill_level =  1
		local	suitlevel = EquipData.Instance:GetBazheLevel()
		if suitlevel > 0 then
			skill_id = SuitPlusConfig[11].list[suitlevel].skillid
			skill_level =  SuitPlusConfig[11].list[suitlevel].skillLv
			bool = true
		end
		icon = "2001_1"
	end
	local path = ResPath.GetSkillIcon(icon)
	self.skill_cell:SetItemIcon(path)
	self.skill_cell:MakeGray(not bool)
end

function ReXueGodEquipPanel:OpenSkillTip( ... )
	local skill_id = 0
	local skiill_level = 0
	local suit_type = 0
	local suitlevel = 0
	if self.index == 1 or self.index == 2 then
		skill_id = SuitPlusConfig[10].list[1].skillid
		skill_level =  0
		suit_type = 10
		suitlevel = EquipData.Instance:GetZhiZunSuitLevel()
		if suitlevel > 0 then
			skill_id = SuitPlusConfig[10].list[suitlevel].skillid
			skill_level =  SuitPlusConfig[10].list[suitlevel].skillLv
			
		end
	elseif self.index == 3 then
		skill_id = SuitPlusConfig[11].list[1].skillid
		skill_level =  0
		suit_type = 11
		suitlevel = EquipData.Instance:GetBazheLevel()
		if suitlevel > 0 then
			skill_id = SuitPlusConfig[11].list[suitlevel].skillid
			skill_level =  SuitPlusConfig[11].list[suitlevel].skillLv
		end
	end
	TipCtrl.Instance:OpenTipSkill(skill_id, skill_level, suit_type, suitlevel)
end

function ReXueGodEquipPanel:OpenTips( ... )
	DescTip.Instance:SetContent(Language.DescTip.GodEquipContent, Language.DescTip.GodEquipTitle)
end

function ReXueGodEquipPanel:ChangeToIndex(index)
	self.index = index
	self:SetListShow()
	if self.index == 1 or self.index == 2 then
		self:FlushWuqiYiFu()
		self:SetFlushPoint()
	else
		self:FlushOtherReXue()
		self.tabbar_list:SetSelectChildIndex(1, 1, false)
		self:FlushAccorditionPoint()
	end
	self:SetSkillShow()
end



function ReXueGodEquipPanel:SetListShow( ... )
	self.node_t_list.layout_list.node:setVisible(self.index ~= 3)
	self.node_t_list.layout_accodition.node:setVisible(self.index == 3)
	self.node_t_list.layout_role_model.node:setVisible(self.index ~= 3)
	self.node_t_list.layout_effect.node:setVisible(self.index == 3)
	self.node_t_list.layout_wu_compose.node:setVisible(self.index ~= 3)
	self.node_t_list.layout_other_compose.node:setVisible(self.index == 3)

	local path = ResPath.GetReXuePath("suit1_bg")
	if self.index == 3 then
		path = ResPath.GetReXuePath("suit2_bg")
	end
	self.node_t_list.btn_suit_tip.node:loadTexture(path)
end

function ReXueGodEquipPanel:OpenCallBack( ... )
	if self.tabbar then
		self.tabbar:SelectIndex(1)
	end
end

function ReXueGodEquipPanel:CreateList( ... )
	if nil == self.equip_list then
		local ph = self.ph_list.ph_list--获取区间列表
		self.equip_list = ListView.New()
		self.equip_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ReXueGodEquipEquipBtnItem, nil, nil, self.ph_list.ph_item_list)
		self.equip_list:SetItemsInterval(20)--格子间距
		self.equip_list:SetMargin(10)
		self.equip_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_list.node:addChild(self.equip_list:GetView(), 20)
		self.equip_list:SetSelectCallBack(BindTool.Bind(self.SelectEquipListCallback, self))
		self.equip_list:GetView():setAnchorPoint(0, 0)
	end
end

function ReXueGodEquipPanel:SelectEquipListCallback(item)
	if item == nil or item:GetData() == nil then
		return 
	end
	self.all_data = item:GetData()
	self.node_t_list.layout_wu_compose.node:setVisible(self.all_data.isClient and true or false)
	self.node_t_list.layout_other_compose.node:setVisible(not self.all_data.isClient)
	if self.all_data.isClient then
		self:FlushConsume()
	else
		self:FlushShowView(self.all_data)
	end
	self:FlushShowDisplay()
end

function ReXueGodEquipPanel:CreateAccordition( ... )
	if nil == self.tabbar_list then
		local ph = self.ph_list.ph_accordition
		self.tabbar_list = Accordion.New()
		self.tabbar_list:Create(ph.x + 5, ph.y, ph.w, ph.h, AccordionEquipRender, nil, 1, self.ph_list.ph_item_ui_config, self.ph_list.ph_child_uiConfog,nil,nil,15, nil)
		self.tabbar_list:SetSelectCallBack(BindTool.Bind(self.SelectChildNodeCallback, self))
		self.node_t_list.layout_accodition.node:addChild(self.tabbar_list:GetView(), 88)
		self.tabbar_list:SetExpandByIndex(0, false)
		self.tabbar_list:SetExpandCallBack(BindTool.Bind(self.SelectTreeNodeCallBack, self))
	end
end

function ReXueGodEquipPanel:SelectTreeNodeCallBack(item)
	-- body
	if item == nil or item:GetData() == nil then
		return
	end
	local data = item:GetData()
	self.cur_index = data.type
	self.tabbar_list:SetSelectChildIndex(1, data.type, true)
end

function ReXueGodEquipPanel:SelectChildNodeCallback(item)
	if item == nil or item:GetData() == nil then
		return
	end
	local data = item:GetData()
	self.tree_index = data.tree_index
	self.child_index = data.index
	self.select_data = data
	self.node_t_list.layout_wu_compose.node:setVisible(self.select_data.isClient and true or false)
	self.node_t_list.layout_other_compose.node:setVisible(not self.select_data.isClient)
	if self.select_data.isClient then
		self:FlushConsume(self.select_data)
	else
		self:FlushShowView()
	end
	self:FlushModel()
end

function ReXueGodEquipPanel:CreateModelAndEffect()
	local ph = self.ph_list.ph_role_model
	if nil == self.role_display then
		self.role_display = RoleDisplay.New(self.node_t_list.layout_role_model.node, 100, false, false, true, true, true, true, -37, 30)
		self.role_display:SetPosition(ph.x, ph.y)
		self.role_display:SetScale(0.8)
	end

	if nil == self.effect_model then
		local ph = self.ph_list.ph_effect
	 	self.effect_model = AnimateSprite:create()
	 	self.effect_model:setPosition(ph.x + 35, ph.y + 5)
	 	self.node_t_list.layout_effect.node:addChild(self.effect_model, 999)
	end

end


function ReXueGodEquipPanel:CreateCellShow( ... )
	local ph = self.ph_list.ph_compose_cell
	if self.compose_cell == nil then
		self.compose_cell = BaseCell.New()
		self.node_t_list.layout_wu_compose.node:addChild(self.compose_cell:GetView(), 99)
		self.compose_cell:GetView():setPosition(ph.x, ph.y)
	end

	local ph_1 = self.ph_list.ph_comsume_cell1
	if self.comsume_cell == nil then
		self.comsume_cell = BaseCell.New()
		self.node_t_list.layout_other_compose.node:addChild(self.comsume_cell:GetView(), 99)
		self.comsume_cell:GetView():setPosition(ph_1.x, ph_1.y)
	end

	local ph_2 = self.ph_list.ph_comsume_cell2
	if self.comsume_cell2 == nil then
		self.comsume_cell2 = BaseCell.New()
		self.node_t_list.layout_other_compose.node:addChild(self.comsume_cell2:GetView(), 99)
		self.comsume_cell2:GetView():setPosition(ph_2.x, ph_2.y)
	end

	local ph_3 = self.ph_list.ph_reward_cell
	if self.reward_cell == nil then
		self.reward_cell = BaseCell.New()
		self.node_t_list.layout_other_compose.node:addChild(self.reward_cell:GetView(), 99)
		self.reward_cell:GetView():setPosition(ph_3.x, ph_3.y)
	end
end


function ReXueGodEquipPanel:ShowIndexCallBack( ... )
	self:Flush(index)
end

function ReXueGodEquipPanel:OnFlush( ... )
	if self.tabbar then
		self.tabbar:SelectIndex(1)
	end
	self:SetListShow()
	self:FlushWuqiYiFu()
	self:FlushOtherReXue()
	self:FlushTabbarPoint()
	self:SetSkillShow()
	self:SetFlushPoint()
	self:FlushAccorditionPoint()
end

function ReXueGodEquipPanel:CloseCallBack( ... )
	-- body
end

function ReXueGodEquipPanel:FlushWuqiYiFu( ... )
	local index = COMPOSE_DEF[self.index]
	if index then
		local data = ReXueGodEquipData.Instance:GetReXueList(index)
		self.equip_list:SetDataList(data)
		self.equip_list:SelectIndex(1)
	end
end

function ReXueGodEquipPanel:ComposeWu()
	if self.all_data then
		self:OnSelectData(self.all_data)
	end
end
function ReXueGodEquipPanel:OnSelectData(data)
	local index = COMPOSE_DEF[self.index]
	local compose_index = data and data.index or 1
	local compose_second_type = data.child_index or 1
	if data.isClient then
		if self.index == 1 or self.index == 2 then

			if data.is_need_shouchong then
				if ChargeRewardData.Instance:GetChargeRewardHadGet(1) then --第一档已领取
					--gaibSysMsgCtrl.Instance:FloatingTopRightText("")
					return
				else
					ViewManager.Instance:OpenViewByDef(ViewDef.ChargeFirst)
				end
			else
				ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.RexueGodEquipDuiHuan)
				GlobalEventSystem:Fire(OPEN_VIEW_EVENT.OpenEvent, 3)
			end
			
		else
			ViewManager.Instance:OpenViewByDef(ViewDef.Explore.RareTreasure)
		end
		return
	else
		local consume_num_count = data.consume[1].count
		local num = BagData.Instance:GetItemNumInBagById(data.consume[1].id)
		if consume_num_count > num then
			 local item_id = data.consume[1].id
			 local config = ItemData.Instance:GetItemConfig(item_id)
			 if config.suitId <= 1 then --只有第一阶才会有
				  local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
			      local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
			      TipCtrl.Instance:OpenBuyTip(data)
			      return
			 end 
		end
		if RoleData.Instance:GetMainMoneyByType(data.consume[3].type) < data.consume[3].count then
			 local item_id = 493
			  local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
		      local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
		      TipCtrl.Instance:OpenBuyTip(data)
			return
		end
	end
	BagCtrl.SendComposeItem(index,compose_second_type, compose_index, 0, 1)
end

function ReXueGodEquipPanel:ComposeOther( ... )
	if self.select_data then
		self:OnSelectData(self.select_data)
	end
end

function ReXueGodEquipPanel:FlushConsume(data)
	self.all_data  = data or self.all_data 
	all_data = self.all_data
	if all_data == nil then
		return
	end
	local consume = all_data.consume
	self.compose_cell:SetData({item_id = consume[1].id, num = 1, is_bind = 0})
	

	local item_cfg = ItemData.Instance:GetItemConfig(consume[1].id)
	local name = item_cfg.name
	self.node_t_list.rich_consume_name.node:setString(name)

	local consume_count = consume[1].count
	local had_count = BagData.Instance:GetItemNumInBagById( consume[1].id, nil)

	local color = had_count >= consume_count and COLOR3B.GREEN or COLOR3B.RED
	local consume_count = "X  ".. consume_count
	local text = "合成"
	local data_consume = consume
	local is_font = nil
	local bool = true
	if all_data.isClient then
		consume_count = ""
		text = "前往兑换"
		data_consume = {} 
		is_font = ""
		if all_data.is_need_shouchong then
			text = "首充获取"
			if  ChargeRewardData.Instance:GetChargeRewardHadGet(1) then
				text = "已领取"
				bool = false
			end
		end
	end
	self:FlushComsumeMoney(data_consume, self.node_t_list.rich_consume.node, is_font)
	self.node_t_list.btn_compose_wu.node:setTitleText(text)
	self.node_t_list.rich_consume_count.node:setString(consume_count)
	self.node_t_list.rich_consume_count.node:setColor(color)
	XUI.SetButtonEnabled(self.node_t_list.btn_compose_wu.node, bool)
	
end

function ReXueGodEquipPanel:FlushShowDisplay()
	local info = {[OBJ_ATTR.ENTITY_MODEL_ID] = 0, [OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = 0,
	 		[OBJ_ATTR.ACTOR_WING_APPEARANCE] = 0, 	[OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE] = 0,
	 		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = 0}

	 local data = self.all_data
	 if self.index == 1 then
	 	info[OBJ_ATTR.ENTITY_MODEL_ID] = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_MODEL_ID)
	 	local config = ItemData.Instance:GetItemConfig(data.award[1].id)
	 	info[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE]  = config.shape

	 elseif self.index == 2 then
	 	info[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_WEAPON_APPEARANCE)
	 	local config = ItemData.Instance:GetItemConfig(data.award[1].id)
	 	info[OBJ_ATTR.ENTITY_MODEL_ID]  = config.shape
	 end
	self.role_display:SetRoleVo(info)
end

function ReXueGodEquipPanel:FlushComsumeMoney(consume, node, font)
	local text = ""
	local font = font and "" or "消耗: "
	for k, v in pairs(consume) do
		local item_id = v.id
		local num = BagData.Instance:GetItemNumInBagById(v.id, nil)
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local path = ResPath.GetItem(item_cfg.icon)
		if v.type > 0 then
			item_id = tagAwardItemIdDef[v.type]

			num = RoleData.Instance:GetMainMoneyByType(v.type) or 0
			path =  RoleData.GetMoneyTypeIconByAwardType(v.type)
			local color = (num >= v.count) and "00ff00" or "ff0000"
			local is_show_tips = v.type > 0 and 0 or 1
			local scale = v.type > 0 and 1 or 0.5
			text = text .. string.format(Language.Bag.ComposeTip, path,"20,20", scale, v.id, is_show_tips, color, v.count).."   "
		end
		
	end
	RichTextUtil.ParseRichText(node,font..text)
	XUI.RichTextSetCenter(node)
end

function ReXueGodEquipPanel:FlushOtherReXue(  )
	local data = ReXueGodEquipData.Instance:GetComspoeData()
	self.tabbar_list:SetData(data)
end

function ReXueGodEquipPanel:FlushShowView(data)
	self.select_data = data or self.select_data
	if self.select_data == nil then
		return
	end
	local consume = self.select_data.consume
	self.comsume_cell:SetData({item_id = consume[1].id, num = 1, is_bind = 0 })
	self.comsume_cell2:SetData({item_id = consume[2].id, num = 1, is_bind = 0 })
	self.reward_cell:SetData({item_id = self.select_data.award[1].id, num = 1, is_bind = 0})
	self:FlushComsumeMoney(consume, self.node_t_list.rich_consume_other.node)

	self.node_t_list.text_consume_num1.node:setString( "X ".. (consume[1].count))
	self.node_t_list.text_consume_num2.node:setString( "X ".. (consume[2].count))

end

function ReXueGodEquipPanel:FlushModel( ... )
	local show_id =  self.select_data.award[1].id
	local eff_model_cfg = SpecialTipsCfg[show_id]
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_model_cfg.modleId)
	self.effect_model:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
end


function ReXueGodEquipPanel:FlushTabbarPoint( ... )
	for k,v in pairs(COMPOSE_DEF) do
		local vis = ReXueGodEquipData.Instance:SingleCanPoint(v)
		--print(">>>>>>>>>", k, vis, v)
		self.tabbar:SetRemindByIndex(k, vis)
	end
end


function ReXueGodEquipPanel:FlushAccorditionPoint()
	local data = ReXueGodEquipData.Instance:GetComspoeData()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in pairs(data) do
		local node = self.tabbar_list:GetTreeNodeByTreeIndex(v.type)
		-- print(">>>>>>>>>>>", v.tree_index, v.child_index)
		local vis = ReXueGodEquipData.Instance:SetTreepoint(v.index, v.child_index, sex)
		
		if node then
			node:FlushEquipRemind(vis)
		end
		for k1, v1 in pairs(v.child) do
			 local child_node = self.tabbar_list:GetChidNodeByIndex(v.type, k1)
			 -- print(child_node)
			 if child_node then
			 	local data = v1
			 	local vis = BagData.Instance:SetSecondPoint(v1.remin_data)
	
			 	child_node:FlushEquipRemind(vis)
			 end
		end
	end
end

function ReXueGodEquipPanel:SetFlushPoint()
	local index = COMPOSE_DEF[self.index]
	local data = ReXueGodEquipData.Instance:GetReXueList(index)
	for k,v in pairs(data) do
		local node = self.equip_list:GetItemAt(k)
		local vis = BagData.Instance:SetSecondPoint(v.remin_data)
		if node then
			node:FlushRemind(vis) 
		end
	end
end

function ReXueGodEquipPanel:ItemDataListChangeCallback( ... )
	self:FlushConsume()
	self:FlushShowView()
	self:FlushTabbarPoint()
	self:FlushAccorditionPoint()
	self:SetFlushPoint()
end

ReXueGodEquipEquipBtnItem = ReXueGodEquipEquipBtnItem or BaseClass(BaseRender)
function ReXueGodEquipEquipBtnItem:__init( ... )
	-- body
end

function ReXueGodEquipEquipBtnItem:__delete( ... )
	-- body
end


function ReXueGodEquipEquipBtnItem:CreateChild( ... )
	BaseRender.CreateChild(self)
end

function ReXueGodEquipEquipBtnItem:OnFlush( ... )
	if self.data == nil then
		return 
	end
	local show_item = self.data.award[1]
	local config = ItemData.Instance:GetItemConfig(show_item.id)
	local name = config.name
	self.node_tree.lbl_equip_name.node:setString(name)
	self.node_tree["lbl_equip_name"].node:setLocalZOrder(999)
end
-- select_bg

function ReXueGodEquipEquipBtnItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetReXuePath("select_bg"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 222)
end


function ReXueGodEquipEquipBtnItem:FlushRemind(vis)
	local path = path or ResPath.GetMainui("remind_flag")
	local size = self.view:getContentSize()
	x = size.width -10
	y = size.height - 20
	if vis and nil == self.remind_bg_sprite then		
		self.remind_bg_sprite = XUI.CreateImageView(x, y, path, true)
		self.remind_bg_sprite:setScale(0.6)
		self.view:addChild(self.remind_bg_sprite, 999, 999)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

AccordionEquipRender = AccordionEquipRender or BaseClass(AccordionItemRender)
function AccordionEquipRender:__init( ... )

end

function AccordionEquipRender:__delete( ... )
	-- body
end

function AccordionEquipRender:CreateChild( ... )
	BaseRender.CreateChild(self)
end

function AccordionEquipRender:OnFlush( ... )
	if self.data == nil then
		return 
	end

	if self.node_tree["lbl_name"] then
		self.node_tree["lbl_name"].node:setString(self.data.name)
	end
	if self.node_tree["text_name1"] then
		self.node_tree["text_name1"].node:setString(self.data.name)
		self.node_tree["text_name1"].node:setColor(self.data.color)
		self.node_tree["text_name1"].node:setLocalZOrder(998)
	end

	if self.node_tree["img_rototation"] then
		local rotation =  self.is_select and 0 or -90
		self.node_tree["img_rototation"].node:setRotation(rotation)
	end

end

function AccordionEquipRender:OnSelectChange( is_select)
	if self.node_tree["img_rototation"] then
		local rotation = is_select and 0 or -90
		self.node_tree["img_rototation"].node:setRotation(rotation)
	end
end


function AccordionEquipRender:FlushEquipRemind(vis)
	--local path = path or ResPath.GetMainui("remind_flag")
	local size = self.view:getContentSize()
	x = size.width - 10
	y = size.height - 15
	if vis and nil == self.remind_bg_sprite then
	
		self.remind_bg_sprite = XUI.CreateImageView(x, y, ResPath.GetMainui("remind_flag"), true)
		self.remind_bg_sprite:setScale(0.6)
		self.view:addChild(self.remind_bg_sprite, 999, 999)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

function AccordionEquipRender:CreateSelectEffect()
	if self:IsChild() then
		local size = self.view:getContentSize()
		self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetReXuePath("img_select"), true)
		self.view:addChild(self.select_effect, 200, 200)
	end
end

RexueSkillCell = RexueSkillCell or BaseClass(BaseCell)
function RexueSkillCell:SetAddClickEventListener( ... )
	-- body
end
return ReXueGodEquipPanel