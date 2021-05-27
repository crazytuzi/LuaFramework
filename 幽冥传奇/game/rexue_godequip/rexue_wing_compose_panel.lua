local  RexueWingComposePanel = BaseClass(SubView)

function RexueWingComposePanel:__init( ... )
	self.texture_path_list = {
		'res/xui/equipbg.png',
		'res/xui/rexue.png',
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"rexue_god_equip_ui_cfg", 8, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
	}
	--self.btn_info = {ViewDef.MainGodEquipView.ReXueFuzhuang.MeiBaShouTao, ViewDef.MainGodEquipView.ReXueFuzhuang.ZhanChongShenHZuang, ViewDef.MainGodEquipView.WingShenZhuang,}

end


function RexueWingComposePanel:__delete( ... )
	-- body
end

function RexueWingComposePanel:LoadCallBack( ... )

	self:CreateZhangCHongAccordition()
	self:CreateCell()
	self:CreateNumber()
	XUI.AddClickEventListener(self.node_t_list.img_common_show_tip.node,BindTool.Bind1(self.OpenDescConetnt,self))
	XUI.AddClickEventListener(self.node_t_list.btn_common_compose.node,BindTool.Bind1(self.ComposePanel,self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function RexueWingComposePanel:ItemDataListChangeCallback( ... )
	self:FlushRightShow()
	self:FlushPoint()
end

function RexueWingComposePanel:ComposePanel( ... )
	local index = 15 
	local data = self.select_data 
	if data == nil then
		return
	end
	local compose_index = data and data.index or 1
	local compose_second_type = data.child_index or 1
	local consume_num_count = data.consume[1].count
	local num = BagData.Instance:GetItemNumInBagById(data.consume[1].id)
	if consume_num_count > num then
		 local item_id = data.consume[1].id
		 local config = ItemData.Instance:GetItemConfig(item_id)
		-- if config.suitId <= 1 then --只有第一阶才会有
		  local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
	      local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
	      TipCtrl.Instance:OpenBuyTip(data)
	      return
		 --end 
	end
	if RoleData.Instance:GetMainMoneyByType(data.consume[2].type) < data.consume[2].count then
		 local item_id = 493
		  local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
	      local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
	      TipCtrl.Instance:OpenBuyTip(data)
		return
	end
	BagCtrl.SendComposeItem(index,compose_second_type, compose_index, 0, 1)

end


function RexueWingComposePanel:OpenDescConetnt( ... )
	DescTip.Instance:SetContent(Language.DescTip.WingComposeContent, Language.DescTip.wingComposeTitle)
end

function RexueWingComposePanel:ReleaseCallBack( ... )
	if self.tabbar_list then
		self.tabbar_list:DeleteMe()
		self.tabbar_list = nil 
	end
	if self.consume_cell then
		self.consume_cell:DeleteMe()
		self.consume_cell = nil 
	end
	if self.reward_cell then
		self.reward_cell:DeleteMe()
		self.reward_cell = nil 
	end
	if self.num_bar then
		self.num_bar:DeleteMe()
		self.num_bar = nil
	end
end


function RexueWingComposePanel:CreateZhangCHongAccordition( ... )
	if nil == self.tabbar_list then
		local ph = self.ph_list.ph_accodition2
		self.tabbar_list = Accordion.New()
		self.tabbar_list:Create(ph.x + 5, ph.y, ph.w, ph.h, AccordionCommonRender, 1, 1, self.ph_list.ph_item_ui_config2, self.ph_list.ph_child_uiConfog2,nil,nil,15, nil)
		self.tabbar_list:SetSelectCallBack(BindTool.Bind(self.SelectChildNodeCallback, self))
		self.node_t_list.layout_common_compose.node:addChild(self.tabbar_list:GetView(), 88)
		self.tabbar_list:SetExpandByIndex(0, false)
		self.tabbar_list:SetExpandCallBack(BindTool.Bind(self.SelectTreeNodeCallBack, self))
	end
end


function RexueWingComposePanel:CreateCell( ... )
	if nil == self.consume_cell then
		local ph = self.ph_list.ph_common_cell_2
		self.consume_cell = BaseCell.New()
		self.node_t_list.layout_common_compose.node:addChild(self.consume_cell:GetView(), 99)
		self.consume_cell:GetView():setPosition(ph.x + 15, ph.y + 18)
	end
	if nil == self.reward_cell then
		local ph = self.ph_list.ph_common_cell_3 
		self.reward_cell = BaseCell.New()
		self.node_t_list.layout_common_compose.node:addChild(self.reward_cell:GetView(), 99)
		self.reward_cell:GetView():setPosition(ph.x + 15, ph.y + 18)
	end
end

function RexueWingComposePanel:CreateNumber( ... )
	local ph = self.ph_list.ph_nunber2
	if nil == self.num_bar then
	    self.num_bar = NumberBar.New()
	    self.num_bar:Create(ph.x - 20, ph.y - 10, 0, 0, ResPath.GetCommon("num_133_"))
	    self.num_bar:SetSpace(-8)
	    self.node_t_list.layout_common_compose.node:addChild(self.num_bar:GetView(), 101)
	end
end

function RexueWingComposePanel:SelectTreeNodeCallBack(item)
	-- body
	if item == nil or item:GetData() == nil then
		return
	end
	local data = item:GetData()
	self.cur_index = data.type
	self.tabbar_list:SetSelectChildIndex(1, data.type, true)
end

function RexueWingComposePanel:SelectChildNodeCallback(item)
	if item == nil or item:GetData() == nil then
		return
	end
	local data = item:GetData()
	self.tree_index = data.tree_index
	self.child_index = data.index
	self.select_data = data
	self:FlushRightShow()
end

function RexueWingComposePanel:FlushRightShow()
	if  self.select_data then
		local consume = self.select_data.consume

		local reward = self.select_data.award

		self.reward_cell:SetData({item_id = reward[1].id, num = 1,is_bind = reward[1].bind or 0 })

		self.consume_cell:SetData({item_id = consume[1].id, num = 1, is_bind =  consume[1].bind or 0})

		local num = BagData.Instance:GetItemNumInBagById(consume[1].id)
		-- print(">>>>>>>>>", consume[1].id, num)
		local need_count = consume[1].count
		local color = num >= need_count and COLOR3B.GREEN or COLOR3B.RED

		local text= num .. "/".. need_count
		self.consume_cell:SetRightBottomText(text, color)

		local item_id = reward[1].id 
		local item_config = ItemData.Instance:GetItemConfig(item_id)
		local attr_list = RoleData.FormatRoleAttrStr(item_config.staitcAttrs)
		local score =  CommonDataManager.GetAttrSetScore(item_config.staitcAttrs, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF))
		self.num_bar:SetNumber(score)

		local consume_text = ""

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
				local num_s = string.format("%.1f",num/10000)
				consume_text = consume_text .. string.format(Language.Bag.ComposeTip2, path,"20,20", scale, v.id, is_show_tips, color, num_s, v.count/10000).."   "
			end
		end
		RichTextUtil.ParseRichText(self.node_t_list.rich_common_text_consume1.node, consume_text)
		XUI.RichTextSetCenter(self.node_t_list.rich_common_text_consume1.node)

		--属性显示
		for i=1,5 do
			self.node_t_list["text_type_next_value"..i].node:setString("")
			self.node_t_list["text_type_name"..i].node:setString("")
			self.node_t_list["text_type_value"..i].node:setString("")
		end

		local type = item_config.stype

		local equip_data = WingData.Instance:GerEquipDataByIndex(type)
		if equip_data == nil then
			for i = 1, 5 do
				if attr_list[i] then
					self.node_t_list["text_type_value"..i].node:setString(0)
					self.node_t_list["text_type_name"..i].node:setString(attr_list[i].type_str .. ":")
					self.node_t_list["text_type_next_value"..i].node:setString(attr_list[i].value_str)
					local color = RoleData.Instance:GetAttrColorByType(attr_list[i].type)
					self.node_t_list["text_type_value"..i].node:setColor(color)
					self.node_t_list["text_type_name"..i].node:setColor(color)
					self.node_t_list["text_type_next_value"..i].node:setColor(color)
				end
			end
		else
			for i = 1, 5 do
				if attr_list[i] then

					self.node_t_list["text_type_next_value"..i].node:setString(attr_list[i].value_str)
					local color = RoleData.Instance:GetAttrColorByType(attr_list[i].type)
					self.node_t_list["text_type_next_value"..i].node:setColor(color)
				end
			end

			local equip_config = ItemData.Instance:GetItemConfig(equip_data.item_id)
			local attr = equip_config.staitcAttrs
			local attr_list = RoleData.FormatRoleAttrStr(attr)
			for i = 1, 5 do
				if attr_list[i] then
					local color = RoleData.Instance:GetAttrColorByType(attr_list[i].type)
					self.node_t_list["text_type_value"..i].node:setString(attr_list[i].value_str)
					self.node_t_list["text_type_name"..i].node:setString(attr_list[i].type_str..":")
					self.node_t_list["text_type_value"..i].node:setColor(color)
					self.node_t_list["text_type_name"..i].node:setColor(color)
				end
			end

		end
	end
end




function RexueWingComposePanel:OpenCallBack( ... )
	-- body
end

function RexueWingComposePanel:CloseCallBack( ... )
	-- body
end

function RexueWingComposePanel:ShowIndexCallBack(index)
	self:Flush(index)
end

function RexueWingComposePanel:OnFlush( ... )
	local data  = ReXueGodEquipData.Instance:GetComspoeData(4)
	if self.tabbar_list then
		self.tabbar_list:SetData(data)
		self.tabbar_list:SetSelectChildIndex(1, 1, true)
		self:FlushPoint()
	end

end

function RexueWingComposePanel:FlushPoint( ... )
	local data = ReXueGodEquipData.Instance:GetComspoeData(4)
	if data == nil then
		return
	end
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in pairs(data) do
		local node = self.tabbar_list:GetTreeNodeByTreeIndex(v.type)
		local vis = ReXueGodEquipData.Instance:SetTreepoint(v.index, v.child_index, sex)
		
		if node then
			node:FlushEquipRemind(vis)
		end
		for k1, v1 in pairs(v.child) do
			 local child_node = self.tabbar_list:GetChidNodeByIndex(v.type, k1)
			 if child_node then
			 	local data = v1
			 	local vis  = ReXueGodEquipData.Instance:SetSecondPoint(v1.remin_data)
	
			 	child_node:FlushEquipRemind(vis)
			 end
		end
	end
end

return RexueWingComposePanel