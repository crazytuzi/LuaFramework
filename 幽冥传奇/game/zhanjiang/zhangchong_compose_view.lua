local View = BaseClass(SubView)

View.CanWearEquipNumMax = 6			--战将装备可佩戴最大数
View.AlreadyCanGetEquipNum = ItemData.ItemType.itHeroEquipMax - ItemData.ItemType.itHeroCuff	--战将已经能获取的装备数

function View:__init()
	self:SetModal(true)
	self.texture_path_list[1] = "res/xui/zhanjiang.png"

	self.config_tab = {
		{"zhanjiang_ui_cfg", 3, {0}},
	}	

	-- 管理自定义对象
	self._objs = {}
end

function View:LoadCallBack()
	self:CreateAccordition()
	self:CreateCellShow()

	if nil == self._objs.tabbar then
		local ph = self.ph_list["ph_tabbar"]
		self.exchange_layout = self.node_t_list.layout_rexue
		self._objs.tabbar = Tabbar.New()
		self._objs.tabbar:CreateWithNameList(self.exchange_layout.node, ph.x, ph.y - 3,
			function(index) self:ChangeToIndex(index) end, 
			{"合成"}, false, ResPath.GetCommon("toggle_121"))
		self._objs.tabbar:ChangeToIndex(self:GetShowIndex())
		self._objs.tabbar:SetSpaceInterval(5)
	end	

	XUI.AddClickEventListener(self.node_t_list.btn_compose_wu.node, BindTool.Bind1(self.ComposeWu, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_compose_other.node, BindTool.Bind1(self.ComposeOther, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_suit_tip.node, BindTool.Bind1(self.OpenSuitTips, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_help.node, function ()
		DescTip.Instance:SetContent(Language.DescTip.ZhangChongComposeContent, Language.DescTip.ZhangChongComposeTitle)
	end, true)

	local consume_id = 2462
	local link_stuff = RichTextUtil.CreateLinkText("获取途径", 20, COLOR3B.GREEN)
	link_stuff:setPosition(850, 30)
	self.node_t_list.layout_rexue.node:addChild(link_stuff, 99)
	XUI.AddClickEventListener(link_stuff, function ()
		local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[consume_id]
		local data = string.format("{reward;0;%d;1}", consume_id) .. (ways and ways or "")
		TipCtrl.Instance:OpenBuyTip(data)
	end, true)

end

function View:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack DigOreAward") end
		v:DeleteMe()
	end
	self._objs = {}
end

function View:ShowIndexCallBack()
	self:Flush()
end

function View:OnFlush(param_t)
end


function View:OpenSuitTips()
	local suittype = self.index == 3 and 11 or 10
	ReXueGodEquipCtrl.Instance:OpenTipView(suittype)
end

--霸者装备
function View:GetComspoeData()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local r_index = 1
	self.compose_data = {}
	local cfg = ItemSynthesisConfig[16]
	if circle >= cfg.openlimit.circle  and level >= cfg.openlimit.level and open_day >= cfg.openlimit.serverday then
		for k, v in pairs(cfg.list) do
			local cur_data = {name = v.name, type = r_index, index = 12, child_index = k, child = {}}
			cur_data.child = self:InitChildList(v.itemList,  12, k, circle, level, open_day)
			table.insert(self.compose_data, cur_data)
			r_index = r_index + 1
		end
	end
	return self.compose_data
end

function View:InitChildList(list, tree_index, child_type, circle, level, open_day)
	
	local data = {}
	for i, v in ipairs(list) do
		--if v.child_index == child_type then

			if level >= (v.openlimit.level or 0) and  
				circle >= (v.openlimit.circle or 0) and 
				open_day >= (v.openlimit.serverday or 0) and( level >= (v.openlimit.minlevel or 0) and level <= (v.openlimit.maxlevel or 9999)) then
				local item_cfg = ItemData.Instance:GetItemConfig(v.award[1].id)
				local name = item_cfg.name
				local color = Str2C3b(string.format("%06x", item_cfg.color))
				local cur_data = {name = name, type = i, tree_index = tree_index, remin_data = v , child_index = child_type, index = i, color = color, award = v.award, consume = v.consume, isClient = v.openlimit.isClient}
				table.insert(data,cur_data)
			end
		--end
	end
	return data
end

function View:CreateAccordition( ... )
	if nil == self._objs.tabbar_list then
		local ph = self.ph_list.ph_accordition
		self._objs.tabbar_list = Accordion.New()
		self._objs.tabbar_list:Create(ph.x + 5, ph.y, ph.w, ph.h, AccordionZCRender, nil, 1, self.ph_list.ph_item_ui_config, self.ph_list.ph_child_uiConfog,nil,nil,15, nil)
		self._objs.tabbar_list:SetSelectCallBack(BindTool.Bind(self.SelectChildNodeCallback, self))
		self.node_t_list.layout_accodition.node:addChild(self._objs.tabbar_list:GetView(), 88)
		self._objs.tabbar_list:SetExpandByIndex(0, false)
		self._objs.tabbar_list:SetExpandCallBack(BindTool.Bind(self.SelectTreeNodeCallBack, self))
	end
	local data = self:GetComspoeData()
	self._objs.tabbar_list:SetData(data)
end

function View:CreateCellShow( ... )
	local ph = self.ph_list.ph_compose_cell
	if self._objs.compose_cell == nil then
		self._objs.compose_cell = BaseCell.New()
		self.node_t_list.layout_wu_compose.node:addChild(self._objs.compose_cell:GetView(), 99)
		self._objs.compose_cell:GetView():setPosition(ph.x, ph.y)
	end

	local ph_1 = self.ph_list.ph_comsume_cell1
	if self._objs.comsume_cell == nil then
		self._objs.comsume_cell = BaseCell.New()
		self.node_t_list.layout_other_compose.node:addChild(self._objs.comsume_cell:GetView(), 99)
		self._objs.comsume_cell:GetView():setPosition(ph_1.x, ph_1.y)
	end

	local ph_2 = self.ph_list.ph_comsume_cell2
	if self._objs.comsume_cell2 == nil then
		self._objs.comsume_cell2 = BaseCell.New()
		self.node_t_list.layout_other_compose.node:addChild(self._objs.comsume_cell2:GetView(), 99)
		self._objs.comsume_cell2:GetView():setPosition(ph_2.x, ph_2.y)
	end

	local ph_3 = self.ph_list.ph_reward_cell
	if self._objs.reward_cell == nil then
		self._objs.reward_cell = BaseCell.New()
		self.node_t_list.layout_other_compose.node:addChild(self._objs.reward_cell:GetView(), 99)
		self._objs.reward_cell:GetView():setPosition(ph_3.x, ph_3.y)
	end
end

function View:ComposeWu()
	if self.all_data then
		self:OnSelectData(self.all_data)
	end
end
function View:OnSelectData(data)
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

function View:ComposeOther( ... )
	if self.select_data then
		self:OnSelectData(self.select_data)
	end
end

function View:SelectChildNodeCallback(item)
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
	-- self:FlushModel()
end


function View:SelectTreeNodeCallBack(item)
	-- body
	if item == nil or item:GetData() == nil then
		return
	end
	local data = item:GetData()
	self.cur_index = data.type
	self._objs.tabbar_list:SetSelectChildIndex(1, data.type, true)
end

function View:FlushConsume(data)
	self.all_data  = data or self.all_data 
	all_data = self.all_data
	if all_data == nil then
		return
	end
	local consume = all_data.consume
	self._objs.compose_cell:SetData({item_id = consume[1].id, num = 1, is_bind = 0})
	

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


function View:FlushComsumeMoney(consume, node, font)
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

function View:FlushShowView(data)
	self.select_data = data or self.select_data
	if self.select_data == nil then
		return
	end
	local consume = self.select_data.consume
	self._objs.comsume_cell:SetData({item_id = consume[1].id, num = 1, is_bind = 0 })
	self._objs.comsume_cell2:SetData({item_id = consume[2].id, num = 1, is_bind = 0 })
	self._objs.reward_cell:SetData({item_id = self.select_data.award[1].id, num = 1, is_bind = 0})
	self:FlushComsumeMoney(consume, self.node_t_list.rich_consume_other.node)

	self.node_t_list.text_consume_num1.node:setString( "X ".. (consume[1].count))
	self.node_t_list.text_consume_num2.node:setString( "X ".. (consume[2].count))

end

AccordionZCRender = AccordionZCRender or BaseClass(AccordionItemRender)
function AccordionZCRender:__init( ... )

end

function AccordionZCRender:__delete( ... )
	-- body
end

function AccordionZCRender:CreateChild( ... )
	BaseRender.CreateChild(self)
end

function AccordionZCRender:OnFlush( ... )
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

function AccordionZCRender:OnSelectChange( is_select)
	if self.node_tree["img_rototation"] then
		local rotation = is_select and 0 or -90
		self.node_tree["img_rototation"].node:setRotation(rotation)
	end
end


function AccordionZCRender:FlushEquipRemind(vis)
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

-- function AccordionZCRender:CreateSelectEffect()
-- 	if self:IsChild() then
-- 		local size = self.view:getContentSize()
-- 		self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetReXuePath("img_select"), true)
-- 		self.view:addChild(self.select_effect, 200, 200)
-- 	end
-- end

return View