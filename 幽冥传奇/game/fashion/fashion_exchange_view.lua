------------------------------------------------------------
-- 时装-兑换 配置 ItemSynthesisConfig[14]
------------------------------------------------------------

local FashionExchangeView = FashionExchangeView or BaseClass(SubView)

function FashionExchangeView:__init()
	self.texture_path_list[1] = 'res/xui/fashion.png'
	self.config_tab = {
		{"fashion_ui_cfg", 3, {0}},
	}
	self.tree_index = nil
	self.cur_index = nil
	self.child_index = nil
	self.compose_num = 1
	self.effect_show = nil
	self.effect_show1 = nil
	self.effect_show2 = nil
	self.max_num = 1
end

function FashionExchangeView:__delete()
end

function FashionExchangeView:ReleaseCallBack()
	if self.effect_show then
		self.effect_show:setStop()
		self.effect_show = nil
	end

	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil
	end

	if self.effect_show2 then
		self.effect_show2:setStop()
		self.effect_show2 = nil
	end
	if self.effect_show3 then
		self.effect_show3:setStop()
		self.effect_show3 = nil
	end
	if self.effect_show4 then
		self.effect_show4:setStop()
		self.effect_show4 = nil
	end

	if nil ~= self.time_delay then
		GlobalTimerQuest:CancelQuest(self.time_delay)
		self.time_delay = nil
	end

	if self.child_list  then
		self.child_list:DeleteMe()
		self.child_list = nil
	end
end

function FashionExchangeView:LoadCallBack(index, loaded_times)
	self:CreateAccoediton()
	self:CreateCell()

	XUI.AddClickEventListener(self.node_t_list.btn_conpose.node, BindTool.Bind(self.ComposeItem, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_del.node, BindTool.Bind(self.DelNum, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_add.node, BindTool.Bind(self.AddNum, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_max.node, BindTool.Bind(self.AddMaxNum, self), true)
	XUI.AddClickEventListener(self.node_t_list.layout_times.node, BindTool.Bind(self.OpenPopNum, self), true)
	
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))

	self:BindGlobalEvent(KnapsackEventType.KNAPSACK_COMPOSE_EQUIP, BindTool.Bind(self.ComposeResult, self))

	if nil == self.effect_show then
		local ph = self.ph_list.ph_effect2
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1143)
		self.effect_show = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.effect_show:setPosition(ph.x + 15, ph.y + 5)
		self.node_t_list["layout_compose"].node:addChild(self.effect_show, 9)
	end

	if nil == self.effect_show3 then
		local ph = self.ph_list.ph_effect1
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1142)
		self.effect_show3 = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.effect_show3:setPosition(ph.x + 15, ph.y + 10)
		self.node_t_list["layout_compose"].node:addChild(self.effect_show3, 9)
	end

	if nil == self.effect_show4 then
		local ph = self.ph_list.ph_effect3
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1142)
		self.effect_show4 = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.effect_show4:setPosition(ph.x + 15, ph.y + 10)
		self.node_t_list["layout_compose"].node:addChild(self.effect_show4, 9)
	end
	self:CreateSecondChildList()

end

function FashionExchangeView:OpenCallBack()
end

function FashionExchangeView:ShowIndexCallBack()
	self:Flush()
end

function FashionExchangeView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			self:FlushShowView()
			
			self:FlushDataList()
			if self.child_list then
				self.child_list:SelectIndex(1)
			end
			self:FlushAllRemind()
		elseif k == "changeTabbar" then
			if self.tabbar then
				local index = v.index
				if not BagData.Instance:GetIsOpenByIndex(v.index) then
					index = 1
				end
				local child_index = v.second_index or 1
				self.tabbar:SetSelectChildIndex(child_index, index, true)
			end
		end
	end
	
end

function FashionExchangeView:ComposeResult()
	if nil == self.effect_show1 then
		local ph = self.ph_list.ph_effect2
		self.effect_show1 = AnimateSprite:create()
		self.effect_show1:setPosition(ph.x + 15, ph.y + 5)
		 self.node_t_list["layout_compose"].node:addChild(self.effect_show1, 999)
	end
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1136)
	self.effect_show1:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
	self.time_delay = GlobalTimerQuest:AddDelayTimer(function ()
			if nil == self.effect_show2 then
				local ph = self.ph_list.ph_effect2
				self.effect_show2 = AnimateSprite:create()
				self.effect_show2:setPosition(ph.x + 15, ph.y + 5)
				 self.node_t_list["layout_compose"].node:addChild(self.effect_show2, 999)
			end
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1137)
			self.effect_show2:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
		if nil ~= self.time_delay then
			GlobalTimerQuest:CancelQuest(self.time_delay)
			self.time_delay = nil
		end
	end, 0.8)

	self:SetTextShow()
	self:FlushAllRemind()
	self:FlushDataList()
end

function FashionExchangeView:OpenPopNum()
	if nil == self.pop_num_view then
		self.pop_num_view = NumKeypad.New()
		self.pop_num_view:SetOkCallBack(BindTool.Bind(self.OnOKCallBack, self))
		self:AddObj("pop_num_view")
	end

	self.pop_num_view:SetText(0)
	local cur_index = self.tabbar:GetExpandIndex()
	self.pop_num_view:SetMaxValue(self.max_num)
	self.pop_num_view:Open()
end

function FashionExchangeView:OnOKCallBack(compose_num)
	if compose_num >= 100 then
		compose_num = 100
	end

	self:SetComposeNum(compose_num)
end

function FashionExchangeView:DelNum()
	if self.compose_num >  1 then
		local compose_num = self.compose_num - 1 
		self:SetComposeNum(compose_num)
	end
	self:SetTextShow()
end

function FashionExchangeView:AddNum()
	if self.compose_num < 100 then
		local compose_num = self.compose_num + 1
		self:SetComposeNum(compose_num)
	end
end

-- 设置合成数量
function FashionExchangeView:SetComposeNum(compose_num)
	self.compose_num = compose_num
	self:SetTextShow()
end

function FashionExchangeView:AddMaxNum()
	local tree_index = self.tree_index or 14
	local child_index = self.child_index  or 1
	local second_index = self.second_index or 1
	local cfg = ItemSynthesisConfig[tree_index] and  ItemSynthesisConfig[tree_index].list or {}
	local cur_config = cfg[child_index] and cfg[child_index].itemList
	local cur_data = cur_config and cur_config[second_index] or {}
	local consume = cur_data.consume
	local max_num = BagData.Instance:GetNumByCompose(consume)
	local compose_num = max_num >= 100 and 100 or (max_num == 0 and 1 or max_num)
	self:SetComposeNum(compose_num)
	
	self.max_num = self.compose_num
end

function FashionExchangeView:CreateCell()
	local parent = self.node_t_list["layout_compose"].node
	if self.perview_cell == nil then
		local ph = self.ph_list.ph_preview_cell
		local cell = BaseCell.New()
		cell:GetView():setPosition(ph.x -1.5, ph.y-3.5)
		parent:addChild(cell:GetView(), 99)
		self.perview_cell = cell
		self:AddObj("perview_cell")
	end

	self.consume_cell_list = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:GetView():setPosition(ph.x -2, ph.y)
		parent:addChild(cell:GetView(), 99)
		cell:SetCellBg(ResPath.GetCommon("cell_110"))
		self.consume_cell_list[i] = cell
	end
	if next(self.consume_cell_list) then
		self:AddObj("consume_cell_list")
	end
end

function FashionExchangeView:CreateAccoediton()
	if self.tabbar == nil then
		local ph = self.ph_list.ph_scroll_list
		local parent = self.node_t_list["layout_compose"].node
		local tabbar = Accordion.New()
		tabbar:Create(ph.x, ph.y, ph.w, ph.h, AccordionComposeRender, nil, 0, self.ph_list.ph_item_ui_config, self.ph_list.ph_child_uiConfog,nil,nil,10, nil)
		tabbar:SetSelectCallBack(BindTool.Bind(self.SelectChildNodeCallback, self))
		parent:addChild(tabbar:GetView(), 88)
		tabbar:SetExpandByIndex(0, false)
		tabbar:SetExpandCallBack(BindTool.Bind(self.SelectTreeNodeCallBack, self))
		self.tabbar = tabbar
		self:AddObj("tabbar")
	end

	self:FlushAccoediton()	
end

function FashionExchangeView:FlushAccoediton()
	self.compose_data = {}
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local r_index = 1
	local cfg = ItemSynthesisConfig[14]
	if circle >= cfg.openlimit.circle  and level >= cfg.openlimit.level and open_day >= cfg.openlimit.serverday then
		local color = cfg.color and Str2C3b(cfg.color) or COLOR3B.WHITE
		local cur_data = {name = cfg.name, type = r_index, index = 14,color = color, child = {}}
		cur_data.child = BagData:InitChildList(cfg.list, v, level, circle, open_day)
		table.insert(self.compose_data, cur_data)
		r_index = r_index + 1
	end
	self.tabbar:SetData(self.compose_data)
end

function FashionExchangeView:SelectTreeNodeCallBack(item)
	if item == nil or item:GetData() == nil then
		return
	end
	local data = item:GetData()
	self.cur_index = data.type
	self.tabbar:SetSelectChildIndex(1, data.type, true)
end

function FashionExchangeView:SelectChildNodeCallback(item)
	if item == nil or item:GetData() == nil then
		return
	end
	local data = item:GetData()
	self.tree_index = data.tree_index
	self.child_index = data.index
	
	self:FlushDataList()
	if self.child_list then
		self.child_list:SelectIndex(1)
	end
end

function FashionExchangeView:FlushShowView()
	local tree_index = self.tree_index or 14
	local child_index = self.child_index  or 1
	local second_index = self.second_index or 1
	local cfg = ItemSynthesisConfig[tree_index] and  ItemSynthesisConfig[tree_index].list or {}
	local second_config = cfg[child_index] or {}
	local cur_config = second_config.itemList
	local cur_data = cur_config and cur_config[second_index] or {}
	local consume = cur_data.consume
	local max_num = BagData.Instance:GetNumByCompose(consume)
	local compose_num = second_config.min_num and second_config.min_num or max_num >= 100 and 100 or (max_num == 0 and 1 or max_num)
	self:SetComposeNum(compose_num)
	self.max_num = self.compose_num
	
	local perview_data = {item_id =cur_data.award and cur_data.award[1].id or 1, num = 1, is_bind = cur_data.award and cur_data.award[1].bind or 0 }
	self.perview_cell:SetData(perview_data)
	self.perview_cell:SetCellBg(ResPath.GetCommon("cell_118"))
	for k, v in pairs(self.consume_cell_list) do
		v:SetData(nil)
		v:SetLockIconVisible(true)
	end
	for k, v in pairs(cur_data.consume) do
		if self.consume_cell_list[k] then
			if v.type <= 0 then
				local item_id = v.id	
				self.consume_cell_list[k]:SetData({item_id = item_id, num =1, is_bind = v.bind or 0})
				self.consume_cell_list[k]:SetCellBg(ResPath.GetCommon("cell_110"))
			end
		end
	end
end

function FashionExchangeView:SetTextShow()
	self.node_t_list.text_num.node:setString(self.compose_num)
	local tree_index = self.tree_index or 14
	local child_index = self.child_index  or 1
	local second_index = self.second_index or 1
	local cfg = ItemSynthesisConfig[tree_index] and  ItemSynthesisConfig[tree_index].list or {}
	local cur_config = cfg[child_index] and cfg[child_index].itemList
	local cur_data = cur_config and cur_config[second_index] or {}

	local consume = cur_data.consume
	local text = ""

	RichTextUtil.ParseRichText(self.node_t_list["text_had_"..1].node, "")
	RichTextUtil.ParseRichText(self.node_t_list["text_had_"..2].node, "")
	RichTextUtil.ParseRichText(self.node_t_list["text_had_"..3].node, "")
	for k, v in pairs(consume) do
		local item_id = v.id
		local num = BagData.Instance:GetItemNumInBagById(v.id, nil)
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local path = ResPath.GetItem(item_cfg.icon)

		if v.type > 0 then
			item_id = tagAwardItemIdDef[v.type]

			num = RoleData.Instance:GetMainMoneyByType(v.type) or 0
			path =  RoleData.GetMoneyTypeIconByAwardType(v.type)

			local color = (num >= v.count * self.compose_num) and "00ff00" or "ff0000"
			local is_show_tips = v.type > 0 and 0 or 1
			local scale = v.type > 0 and 1 or 0.5
			text = text .. string.format(Language.Bag.ComposeTip, path,"20,20", scale, v.id, is_show_tips, color, v.count * self.compose_num).."   "
		end

		if v.type <= 0 then
			local color = (num >= v.count * self.compose_num) and "00ff00" or "ff0000"
			local str_color = Str2C3b(color)
			if self.node_t_list["text_had_"..k] then
				local text = string.format("{wordcolor;%s;%d} / %d", color, num, v.count * self.compose_num)
				RichTextUtil.ParseRichText(self.node_t_list["text_had_"..k].node, text)
				XUI.RichTextSetCenter(self.node_t_list["text_had_"..k].node)
			end
		end
	end

	RichTextUtil.ParseRichText(self.node_t_list.rich_consume.node, text)
	XUI.RichTextSetCenter(self.node_t_list.rich_consume.node)
end

function FashionExchangeView:FlushAllRemind()
	local data = self.compose_data
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in pairs(data) do
		local node = self.tabbar:GetTreeNodeByTreeIndex(v.type)
		local vis = BagData.Instance:SetTreepoint(v.index, circle, level, open_day, sex)
		
		if node then
			node:FlushRemind(vis)
		end
		for k1, v1 in pairs(v.child) do
			 local child_node = self.tabbar:GetChidNodeByIndex(v.type, k1)
			 if child_node then
				local data = v1
				local vis = BagData.Instance:SetChildpoint(v.index, v1.index)
				child_node:FlushRemind(vis)
			 end
		end
	end
	
end

function FashionExchangeView:FlushListRemind()
	local items = self.child_list:GetAllItems()
	for k, v in pairs(items) do
		local data = v:GetData()
		local vis = BagData.Instance:SetSecondPoint(data.data1) 
		v:FlushRemind(vis)
	end
end

function FashionExchangeView:CreateSecondChildList()
	if self.child_list == nil then
		local parent = self.node_t_list["layout_list"].node
		local ph = self.ph_list.ph_list--获取区间列表
		local list = ListView.New()
		list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ComposeSecondItem, nil, nil, self.ph_list.ph_item_list)
		list:SetItemsInterval(10)--格子间距
		list:SetMargin(10)
		list:SetJumpDirection(ListView.Top)--置顶
		parent:addChild(list:GetView(), 20)
		list:SetSelectCallBack(BindTool.Bind(self.SelectEquipListCallback, self))
		list:GetView():setAnchorPoint(0, 0)
		self.child_list = list
		self:AddObj("child_list")
	end
end

function FashionExchangeView:FlushDataList()
	local tree_index = self.tree_index or 14
	local child_index = self.child_index or 1
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local data = BagData.Instance:InitSecondChild(tree_index, child_index, level, circle, open_day, sex)
	self.child_list:SetDataList(data)
	self:FlushListRemind()
end

function FashionExchangeView:SelectEquipListCallback(item)
	if item == nil or item:GetData() == nil then return end
	self.second_index = item:GetData().index
	self:FlushShowView()
end

function FashionExchangeView:ComposeItem()
	local tree_index = self.tree_index or 14
	local child_index = self.child_index  or 1
	local second_index = self.second_index or 1
	local cfg = ItemSynthesisConfig[tree_index] and  ItemSynthesisConfig[tree_index].list or {}
	local cur_config = cfg[child_index] and cfg[child_index].itemList
	local cur_data = cur_config and cur_config[second_index] or {}

	local consume = cur_data.consume

	if BagData.Instance:GetItemNumInBagById(consume[1].id) < consume[1].count * self.compose_num then
		if ShopData.GetItemPriceCfg(consume[1].id)  then
			TipCtrl.Instance:OpenGetNewStuffTip(consume[1].id)
		else
			TipCtrl.Instance:OpenGetStuffTip(consume[1].id)
		end
		return
	end

	BagCtrl.SendComposeItem(tree_index, child_index, second_index, 1, self.compose_num)
end

----------------------------------------

function FashionExchangeView:RoleDataChangeCallback(vo)
	if self:IsOpen() then
		if vo.key == OBJ_ATTR.ACTOR_COIN then
			self:SetTextShow()
			self:FlushAllRemind()
		elseif vo.key == OBJ_ATTR.CREATURE_LEVEL then
			self:FlushDataList()
			self:FlushShowView()
			self:FlushAllRemind()
		end
	end
end

function FashionExchangeView:ItemDataListChangeCallback()
	if self:IsOpen() then
		self:SetTextShow()
		self:FlushAllRemind()
		self:FlushDataList()
	end
end


return FashionExchangeView