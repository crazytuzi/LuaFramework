local LuxuryXionghaoEquipComposeView = BaseClass(SubView)

function LuxuryXionghaoEquipComposeView:__init()
	self.texture_path_list = {
		'res/xui/equipbg.png',
		'res/xui/rexue.png',
	}
	self.config_tab = {
		{"luxury_equip_ui_cfg", 3, {0}},
		{"luxury_equip_ui_cfg", 4, {0}},
		{"luxury_equip_ui_cfg", 5, {0}},
		{"luxury_equip_ui_cfg", 8, {0}},
	}
end

LuxuryXionghaoEquipComposeView_XiongHao_EquipPos =   {
	{equip_slot = EquipData.EquipSlot.itJazzHatPos, cell_pos = 1, cell_img = ResPath.GetEquipImg("cs_bg_3")},	-- 战神_头盔	45
	{equip_slot = EquipData.EquipSlot.itGoldDicePos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
	{equip_slot = EquipData.EquipSlot.itGoldenSkullPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
	{equip_slot = EquipData.EquipSlot.itGlobeflowerPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
	{equip_slot = EquipData.EquipSlot.itGentlemenBootsPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
}

-- itOpenCarPos = 30,				--敞篷车
-- 	itAnCrownPos=31,				--皇冠
-- 	itGoldenSkullPos =32,			--金骷髅
-- 	itGoldChainPos=33,				-- 金链子
-- 	itGoldPipePos = 34,				--金烟斗
-- 	itGoldDicePos = 35,				--金骰子
-- 	itGlobeflowerPos = 36,			--金莲花
-- 	itJazzHatPos = 37,				-- 爵士帽
-- 	itRolexPos= 38,					--劳力士
-- 	itDiamondRingPos = 39,			--钻戒
-- 	itGentlemenBootsPos = 40,		--绅士靴 40

function LuxuryXionghaoEquipComposeView:ReleaseCallBack()
	if self.equip_cell then
		for k, v in pairs(self.equip_cell) do
			v:DeleteMe()
		end
		self.equip_cell = {}
	end

	if self.reward_cell then
		self.reward_cell:DeleteMe()
		self.reward_cell = nil 
	end
	if self.role_equip_cell then
		self.role_equip_cell:DeleteMe()
		self.role_equip_cell = nil 
	end

	if self.consume_cell then
		self.consume_cell:DeleteMe()
		self.consume_cell = nil 
	end

	if self.num_bar1 then
		self.num_bar1:DeleteMe()
		self.num_bar1 = nil 
	end
end

function LuxuryXionghaoEquipComposeView:LoadCallBack(index, loaded_times)
	--if loaded_times <= 1 then
		self.select_pos =  EquipData.EquipSlot.itJazzHatPos
		self.equip_cell = {}
		self:CreateItemCell()
		self:CreateCell()
		self:CreateNumBar()

		EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
		EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))

		XUI.AddClickEventListener(self.node_t_list.img_common_show_tip.node,BindTool.Bind1(self.OpenShowDesc, self))
		XUI.AddClickEventListener(self.node_t_list.btn_common_compose.node,BindTool.Bind1(self.ComposeEquip, self))
		EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))

		XUI.AddClickEventListener(self.node_t_list.img_suit.node,BindTool.Bind1(self.OpenSuitView, self))
	--end
end

function LuxuryXionghaoEquipComposeView:OpenSuitView()
	 ViewManager.Instance:OpenViewByDef(ViewDef.LuxuryEquipTip)
end

function LuxuryXionghaoEquipComposeView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_COIN then
		self:FlushRedPoint()
	end
end

function LuxuryXionghaoEquipComposeView:ComposeEquip()
	local equip_pos = self.select_pos
	local equip_data = EquipData.Instance:GetEquipDataBySolt(equip_pos) 
	local item_id = equip_data and equip_data.item_id or 0

	local con_text = ""
	local cfg = LuxuryEquipUpgradeData.Instance:GetUpgradeCfg(self.select_pos, item_id)
	if cfg == nil then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.MaxLvTips)
		return
	end
	local consume = cfg.consume 

	if consume[1].count > BagData.Instance:GetItemNumInBagById(consume[1].id) then
		TipCtrl.Instance:OpenGetStuffTip(consume[1].id)
		return
	end
	if  RoleData.Instance:GetMainMoneyByType(consume[2].type) < consume[2].count  then
		local item_id = 493
		TipCtrl.Instance:OpenGetStuffTip(item_id)
		return
	end
	 LuxuryEquipUpgradeCtrl.SendLuxuryEquipUpgrade(self.select_pos)
end

function LuxuryXionghaoEquipComposeView:OpenShowDesc()
	DescTip.Instance:SetContent(Language.DescTip.XiongHaoComposeContent, Language.DescTip.XiongHaoComposeTitle)
end

function LuxuryXionghaoEquipComposeView:CreateItemCell()
	self.equip_cell = {}
	for k, v in pairs(LuxuryXionghaoEquipComposeView_XiongHao_EquipPos) do
		local cell = self:CreateCellRender(k)
		cell:SetIndex(v.equip_slot)
		cell:AddClickEventListener(BindTool.Bind1(self.OnClickEquipCell, self), true)
		-- table.insert(self.equip_cell, cell)
		self.equip_cell[v.equip_slot] = cell
	end
	if self.select_pos and self.equip_cell[self.select_pos] then
		self.equip_cell[self.select_pos]:SetSelect(true)
	end
end

function LuxuryXionghaoEquipComposeView:FlushWanHaoShow()
	for k, v in pairs(LuxuryXionghaoEquipComposeView_XiongHao_EquipPos ) do
		if self.equip_cell[v.equip_slot] then
			local cell = self.equip_cell[v.equip_slot]
			cell:SetData(v) 
		end
	end
end

function LuxuryXionghaoEquipComposeView:CreateNumBar()
	local ph = self.ph_list.ph_nunber2
	if nil == self.num_bar1 then
	    self.num_bar1 = NumberBar.New()
	    self.num_bar1:Create(ph.x - 20, ph.y - 10, 0, 0, ResPath.GetCommon("num_133_"))
	    self.num_bar1:SetSpace(-8)
	    self.node_t_list.layout_lux_common_panel.node:addChild(self.num_bar1:GetView(), 101)
	end
end


function LuxuryXionghaoEquipComposeView:OnClickEquipCell(cell)
	if cell == nil or cell:GetData() == nil then
		return
	end
	cell:SetSelect(true)
	self.select_data1 = cell:GetData()
	if self.select_pos and self.equip_cell[self.select_pos] and 
		self.select_pos ~= self.select_data1.equip_slot then

		self.equip_cell[self.select_pos]:SetSelect(false)
	end
	self.select_pos =  self.select_data1.equip_slot

	self:FlushRightShow()
end


function LuxuryXionghaoEquipComposeView:CreateCellRender(k)
	local cell = LuxyComposeEquipRender.New()
	local render_ph = self.ph_list["ph_xionghao_item_render"..k] 
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(render_ph.x, render_ph.y)
	self.node_t_list["layout_xionghao"].node:addChild(cell:GetView(), 101)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end

function LuxuryXionghaoEquipComposeView:ItemDataListChangeCallback()
	self:FlushWanHaoShow()
	self:FlushRedPoint()
end

function LuxuryXionghaoEquipComposeView:OnChangeOneEquip()
	self:FlushWanHaoShow()
	self:FlushRightShow()
	self:FlushRedPoint()
end

function LuxuryXionghaoEquipComposeView:OpenCallBack()
	-- body
end

function LuxuryXionghaoEquipComposeView:ShowIndexCallBack(index)
	self:Flush(index)
end

function LuxuryXionghaoEquipComposeView:CloseCallBack()
	-- body
end

function LuxuryXionghaoEquipComposeView:OnFlush( ... )
	self:FlushWanHaoShow()
	local cell = self.equip_cell[self.select_pos]
	self:OnClickEquipCell(cell)
	self:FlushRedPoint()
end


function LuxuryXionghaoEquipComposeView:CreateCell()
	if self.reward_cell == nil then
		local ph = self.ph_list.ph_common_cell_1
		self.reward_cell = BaseCell.New()
		self.reward_cell:SetPosition(ph.x + 10, ph.y +15)
		self.node_t_list.layout_lux_common_panel.node:addChild(self.reward_cell:GetView(), 999)
	end
	if nil == self.role_equip_cell then
		local ph = self.ph_list.ph_common_cell_2
		self.role_equip_cell = BaseCell.New()
		self.role_equip_cell:SetPosition(ph.x + 10, ph.y + 20)
		self.node_t_list.layout_lux_common_panel.node:addChild(self.role_equip_cell:GetView(), 999)
	end

	if nil == self.consume_cell then
		local ph = self.ph_list.ph_common_cell_3
		self.consume_cell = BaseCell.New()
		self.consume_cell:SetPosition(ph.x + 10, ph.y + 20)
		self.node_t_list.layout_lux_common_panel.node:addChild(self.consume_cell:GetView(), 999)
	end
end

function LuxuryXionghaoEquipComposeView:FlushRedPoint()
	for k, v in pairs(LuxuryXionghaoEquipComposeView_XiongHao_EquipPos) do
		local cell = self.equip_cell[v.equip_slot]
		if cell then
			local vis = LuxuryEquipUpgradeData.Instance:GetCanUpgradeByPos(v.equip_slot)
			cell:SetRemindVis(vis)
		end
	end
end


function LuxuryXionghaoEquipComposeView:FlushRightShow()

	local equip_pos = self.select_pos
	local equip_data = EquipData.Instance:GetEquipDataBySolt(equip_pos) 

	self.role_equip_cell:SetData(nil)
	self.role_equip_cell:SetLockIconVisible(true)
	
	if equip_data then
		self.role_equip_cell:SetData(equip_data)
		self.role_equip_cell:SetLockIconVisible(false)
		self.role_equip_cell:SetCellBg(ResPath.GetCommon("cell_118"))
	end
	for i=1,5 do
		self.node_t_list["text_type_next_value"..i].node:setString("")
		self.node_t_list["text_type_name"..i].node:setString("")
		self.node_t_list["text_type_value"..i].node:setString("")
	end
	local item_id = equip_data and equip_data.item_id or 0

	local con_text = ""
	local cfg = LuxuryEquipUpgradeData.Instance:GetUpgradeCfg(self.select_pos, item_id)
	self.consume_cell:SetData(nil)
	self.reward_cell:SetData(nil)
	if cfg ~= nil then
		local  consume = cfg.consume[1]

		self.consume_cell:SetData({item_id = consume.id, num = 1, is_bind = 0})

		local had_num = BagData.Instance:GetItemNumInBagById(consume.id)
		local color = had_num >= consume.count and COLOR3B.GREEN or COLOR3B.RED
		local text = had_num.."/"..consume.count
		self.consume_cell:SetRightBottomText(text, color)

		local reward_item_id = cfg.itemId 
		self.reward_cell:SetData({item_id = reward_item_id, num =1,is_bind = 0})

		con_text = self:FlushComsumeMoney(cfg.consume) 


		local item_config = ItemData.Instance:GetItemConfig(cfg.itemId)

		local attr = item_config.staitcAttrs
		local attr_list = RoleData.FormatRoleAttrStr(attr)
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
		end
	end
	local score = 0
	if equip_data ~= nil then
		local equip_config = ItemData.Instance:GetItemConfig(equip_data.item_id)
		local attr = equip_config.staitcAttrs
		local attr_list = RoleData.FormatRoleAttrStr(attr)

		score =  CommonDataManager.GetAttrSetScore(equip_config.staitcAttrs or {}, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF))
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

	self.num_bar1:SetNumber(score) 

	RichTextUtil.ParseRichText(self.node_t_list.rich_common_text_consume1.node, con_text)
	XUI.RichTextSetCenter(self.node_t_list.rich_common_text_consume1.node)

	self.reward_cell:SetCellBg(ResPath.GetCommon("cell_118"))
	self.role_equip_cell:SetCellBg(ResPath.GetCommon("cell_118"))
	self.consume_cell:SetCellBg(ResPath.GetCommon("cell_118"))
end


function LuxuryXionghaoEquipComposeView:FlushComsumeMoney(consume)
	local text = ""
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
			text = text .. string.format(Language.Bag.ComposeTip2, path,"20,20", scale, v.id, is_show_tips, color, num_s, v.count/10000).."   "
		end
		
	end
	return text 
end

return LuxuryXionghaoEquipComposeView