local LuxuryWanhaoEquipComposeView = BaseClass(SubView)

function LuxuryWanhaoEquipComposeView:__init()
	self.texture_path_list = {
		'res/xui/equipbg.png',
		'res/xui/rexue.png',
	}
	self.config_tab = {
		{"luxury_equip_ui_cfg", 3, {0}},
		{"luxury_equip_ui_cfg", 4, {0}},
		{"luxury_equip_ui_cfg", 5, {0}},
		{"luxury_equip_ui_cfg", 6, {0}},
	}
end

function LuxuryWanhaoEquipComposeView:__delete()
	-- body
end

LuxuryWanhaoEquipComposeView_WanHao_EquipPos =   {
	{equip_slot = EquipData.EquipSlot.itSubmachineGunPos, cell_pos = 1, cell_img = ResPath.GetEquipImg("cs_bg_3")},	-- 战神_头盔	45
	{equip_slot = EquipData.EquipSlot.itOpenCarPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
}

function LuxuryWanhaoEquipComposeView:ReleaseCallBack()
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

function LuxuryWanhaoEquipComposeView:LoadCallBack(index, loaded_times)
	--if loaded_times <= 1 then
		self.select_pos =  EquipData.EquipSlot.itSubmachineGunPos
		self.equip_cell = {}
		self:CreateItemCell()
		self:CreateCell()
		self:CreateNumBar()

		EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
		EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))

		XUI.AddClickEventListener(self.node_t_list.img_common_show_tip.node,BindTool.Bind1(self.OpenShowDesc, self))
		XUI.AddClickEventListener(self.node_t_list.btn_common_compose.node,BindTool.Bind1(self.ComposeEquip, self))
		EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	--end
		XUI.AddClickEventListener(self.node_t_list.img_suit.node,BindTool.Bind1(self.OpenSuitView, self))

end

function LuxuryWanhaoEquipComposeView:OpenSuitView()
	 ViewManager.Instance:OpenViewByDef(ViewDef.LuxuryEquipTip)
end


function LuxuryWanhaoEquipComposeView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_COIN then
		self:FlushRedPoint()
	end
end

function LuxuryWanhaoEquipComposeView:ComposeEquip()

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

function LuxuryWanhaoEquipComposeView:OpenShowDesc()
	DescTip.Instance:SetContent(Language.DescTip.WanHaoComposeContent, Language.DescTip.WanHaoComposeTitle)
end

function LuxuryWanhaoEquipComposeView:CreateItemCell()
	self.equip_cell = {}
	for k, v in pairs(LuxuryWanhaoEquipComposeView_WanHao_EquipPos) do
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

function LuxuryWanhaoEquipComposeView:FlushWanHaoShow()
	for k, v in pairs(LuxuryWanhaoEquipComposeView_WanHao_EquipPos ) do
		if self.equip_cell[v.equip_slot] then
			local cell = self.equip_cell[v.equip_slot]
			cell:SetData(v) 
		end
	end
end

function LuxuryWanhaoEquipComposeView:CreateNumBar()
	local ph = self.ph_list.ph_nunber2
	if nil == self.num_bar1 then
	    self.num_bar1 = NumberBar.New()
	    self.num_bar1:Create(ph.x - 20, ph.y - 10, 0, 0, ResPath.GetCommon("num_133_"))
	    self.num_bar1:SetSpace(-8)
	    self.node_t_list.layout_lux_common_panel.node:addChild(self.num_bar1:GetView(), 101)
	end
end


function LuxuryWanhaoEquipComposeView:OnClickEquipCell(cell)
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


function LuxuryWanhaoEquipComposeView:CreateCellRender(k)
	local cell = LuxyComposeEquipRender.New()
	local render_ph = self.ph_list["ph_item_render"..k] 
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(render_ph.x, render_ph.y)
	self.node_t_list["layout_wanhao"].node:addChild(cell:GetView(), 101)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end

function LuxuryWanhaoEquipComposeView:ItemDataListChangeCallback()
	self:FlushWanHaoShow()
	self:FlushRedPoint()
end

function LuxuryWanhaoEquipComposeView:OnChangeOneEquip( ... )
	self:FlushWanHaoShow()
	self:FlushRightShow()
	self:FlushRedPoint()
end

function LuxuryWanhaoEquipComposeView:OpenCallBack()
	-- body
end

function LuxuryWanhaoEquipComposeView:ShowIndexCallBack(index)
	self:Flush(index)
end

function LuxuryWanhaoEquipComposeView:CloseCallBack()
	-- body
end

function LuxuryWanhaoEquipComposeView:OnFlush( ... )
	self:FlushWanHaoShow()
	local cell = self.equip_cell[self.select_pos]
	self:OnClickEquipCell(cell)
	self:FlushRedPoint()
end


function LuxuryWanhaoEquipComposeView:CreateCell()
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

function LuxuryWanhaoEquipComposeView:FlushRedPoint()
	for k, v in pairs(LuxuryWanhaoEquipComposeView_WanHao_EquipPos) do
		local cell = self.equip_cell[v.equip_slot]
		if cell then
			local vis = LuxuryEquipUpgradeData.Instance:GetCanUpgradeByPos(v.equip_slot)
			cell:SetRemindVis(vis)
		end
	end
end


function LuxuryWanhaoEquipComposeView:FlushRightShow()

	local equip_pos = self.select_pos
	local equip_data = EquipData.Instance:GetEquipDataBySolt(equip_pos) 

	local vis = true
	if equip_data == nil then
		vis = false
	end
	self.role_equip_cell:SetData(nil)
	self.role_equip_cell:SetLockIconVisible(true)

	if equip_data then
		self.role_equip_cell:SetLockIconVisible(false)
		self.role_equip_cell:SetData(equip_data)
		
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


function LuxuryWanhaoEquipComposeView:FlushComsumeMoney(consume)
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

LuxyComposeEquipRender = LuxyComposeEquipRender or BaseClass(BaseRender)
function LuxyComposeEquipRender:__init()
	-- body
end


function LuxyComposeEquipRender:__delete()
	-- body
end

function LuxyComposeEquipRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_red.node:setVisible(false)

	if self.effect_show == nil then
		--local ph = self.ph_list.ph_effect
		self.effect_show = AnimateSprite:create()
		--self.effect_show:setPosition(ph.x, ph.y )
		self.view:addChild(self.effect_show, 99)
	end
end

function LuxyComposeEquipRender:OnFlush()
	if self.data == nil then
		return
	end
	local size = self.view:getContentSize()
	self.effect_show:setPosition(size.width/2, size.height/2 - 15)

	local equip_data =  EquipData.Instance:GetEquipDataBySolt(self.data.equip_slot) 

	local bool = false
    if equip_data then
        bool = true
    end
    local  eff_id = EquipData.Instance:GetLuxuryEquipEffectId(equip_data and equip_data.item_id  or 0, self.data.equip_slot)

	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.effect_show:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)

	 XUI.MakeGrey(self.effect_show, not bool)
	 self.node_tree.img_red.node:setLocalZOrder(999)
end

function LuxyComposeEquipRender:SetRemindVis(bool)
	if self.node_tree.img_red then
		self.node_tree.img_red.node:setVisible(bool)
	end
end

return LuxuryWanhaoEquipComposeView