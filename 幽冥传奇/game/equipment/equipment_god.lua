EquipmentView = EquipmentView or BaseClass(XuiBaseView)

function EquipmentView:InitGodView()
	self:CreateAllGodCells()
	self:CreateGodAttrView()
	
	self.txt_get_god_stuff = RichTextUtil.CreateLinkText("", 20, COLOR3B.GREEN)
	self.txt_get_god_stuff:setPosition(370, 110)
	self.node_t_list.layout_equip_god.node:addChild(self.txt_get_god_stuff, 50)
	
	XUI.AddClickEventListener(self.node_t_list.btn_god_tips.node, BindTool.Bind(self.OnClickGodTips, self))
	XUI.AddClickEventListener(self.node_t_list.btn_god_up.node, BindTool.Bind(self.OnClickGodUpgrade, self))
	XUI.AddClickEventListener(self.txt_get_god_stuff, BindTool.Bind(self.OnClickGetGodStuff, self), true)
end

function EquipmentView:DeleteGodView()
	if self.cur_god_cell then
		self.cur_god_cell:DeleteMe()
		self.cur_god_cell = nil
	end
	
	if self.next_god_cell then
		self.next_god_cell:DeleteMe()
		self.next_god_cell = nil
	end
	
	if self.cur_god_attr then
		self.cur_god_attr:DeleteMe()
		self.cur_god_attr = nil
	end
	
	if self.next_god_attr then
		self.next_god_attr:DeleteMe()
		self.next_god_attr = nil
	end
	
	if self.god_cell_list ~= nil then
		for k, v in pairs(self.god_cell_list) do
			v:DeleteMe()
		end
		self.god_cell_list = {}
	end
	
	self.cur_god_cell_index = nil
end

function EquipmentView:CreateAllGodCells()
	self.cur_god_cell = self:CreateOneGodCell(self.ph_list.ph_cur_equip_cell)
	self.next_god_cell = self:CreateOneGodCell(self.ph_list.ph_next_equip_cell)
	
	self.cur_god_cell:SetRemind(false)
	self.cur_god_cell:SetShowTips(true)
	self.next_god_cell:SetRemind(false)
	self.next_god_cell:SetShowTips(true)
	
	self.god_cell_list = {}
	for i = 1, 10 do
		local cell = self:CreateOneGodCell(self.ph_list["ph_god_cell_" .. i])
		cell:SetIndex(i)
		cell:AddClickEventListener(BindTool.Bind(self.OnClickGodCell, self, cell), false)
		self.god_cell_list[i] = cell
	end
	EquipmentData.Instance:SetGodCellDataList()
end

function EquipmentView:CreateOneGodCell(ph)
	if ph == nil then return end
	
	local cell = GodItemRender.New()
	cell:SetAnchorPoint(0.5, 0.5)
	cell:SetPosition(ph.x, ph.y)
	cell:SetUiConfig(ph, true)
	self.node_t_list.layout_equip_god.node:addChild(cell:GetView(), 50)
	return cell
end

function EquipmentView:CreateGodAttrView()
	self.cur_god_attr = AttrView.New(195, 25, 20, ResPath.GetCommon("img9_115"), true)
	self.cur_god_attr:GetView():setPosition(110, 280)
	self.cur_god_attr:SetDefTitleText(Language.Common.No)
	self.node_t_list.layout_equip_god.node:addChild(self.cur_god_attr:GetView(), 50)
	
	self.next_god_attr = AttrView.New(195, 25, 20, ResPath.GetCommon("img9_115"), true)
	self.next_god_attr:GetView():setPosition(420, 280)
	self.next_god_attr:SetDefTitleText(Language.Common.MaxLevel)
	self.node_t_list.layout_equip_god.node:addChild(self.next_god_attr:GetView(), 50)
end

function EquipmentView:OnFlushGodView(param_t)
	for k, v in pairs(param_t) do
		if k == "all" then
			self:SetGodCellList()
			self:OnClickGodCell(self.god_cell_list[self.cur_god_cell_index or 1])
			self:FlushGodCellRemind()
		elseif k == "item_config_change" then
			self:SetGodCellList()
			self:OnClickGodCell(self.god_cell_list[self.cur_god_cell_index or 1])
			self:SetGodConsume(self.cur_god_cell_index)
		elseif k == "god_lv_change" then
			self:SetGodCellList()
			self:OnClickGodCell(self.god_cell_list[self.cur_god_cell_index or 1])
		elseif k == "god_lv_up" then
			self.cur_god_cell_index = v.slot
			local new_cell_data = EquipmentData.Instance:GetGodCellDataList() [self.cur_god_cell_index]
			self.god_cell_list[self.cur_god_cell_index]:SetData(new_cell_data)
			self:SetGodAttrView(self.cur_god_cell_index)
			self:SetGodConsume(self.cur_god_cell_index)
			self:SetNextLvData(new_cell_data)
			
			self:SetShowPlayEff(902, 670, 300)
		elseif k == "item_data_change" then
			self:FlushGodCellRemind()
		end
	end
end

function EquipmentView:FlushGodCellRemind()
	local circle_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	for k, v in pairs(self.god_cell_list) do
		local data = v:GetData()
		if data ~= nil then
			local consume_cfg = EquipmentData.GetGodConsumeCfg(k, data.god_lv + 1)
			if consume_cfg then
				local have = BagData.Instance:GetItemNumInBagById(consume_cfg.id)
				v:SetRemind(have >= consume_cfg.count and circle_lv >= EquipmentData.GetApotheosisOpenLv())
			else
				v:SetRemind(false)
			end
		end
	end
end

function EquipmentView:SetGodCellList()
	for k, v in pairs(EquipmentData.Instance:GetGodCellDataList()) do
		self.god_cell_list[k]:SetData(v)
	end
end

function EquipmentView:SetGodAttrView(slot)
	local god_lv = EquipmentData.Instance:GetGodLevelBySlot(slot)
	local cur_attr_cfg = EquipmentData.GetGodAttrCfg(slot, god_lv)
	local next_attr_cfg = EquipmentData.GetGodAttrCfg(slot, god_lv + 1)
	self.cur_god_attr:SetData(cur_attr_cfg)
	self.next_god_attr:SetData(next_attr_cfg)
end

function EquipmentView:SetGodConsume(slot)
	local god_lv = EquipmentData.Instance:GetGodLevelBySlot(slot)
	local consume_cfg = EquipmentData.GetGodConsumeCfg(slot, god_lv + 1)
	if consume_cfg then
		self.node_t_list.layout_god_consume.node:setVisible(true)
		self.node_t_list.btn_god_up.node:setVisible(true)
		self:ShowMaxLevelText(false)
		self.txt_get_god_stuff:setVisible(true)
		local item_cfg = ItemData.Instance:GetItemConfig(consume_cfg.id)
		if item_cfg then
			self.node_t_list.lbl_god_need.node:setString(string.format("%s*%d", item_cfg.name, consume_cfg.count))
			local have = BagData.Instance:GetItemNumInBagById(consume_cfg.id)
			self.node_t_list.lbl_god_have.node:setString(have)
			self.node_t_list.lbl_god_have.node:setColor(have >= consume_cfg.count and COLOR3B.GREEN or COLOR3B.RED)
			self.txt_get_god_stuff:setString(Language.Equipment.Obtain .. item_cfg.name)
			XUI.SetButtonEnabled(self.node_t_list.btn_god_up.node, have >= consume_cfg.count)
		end
	else    -- 满级
		self.node_t_list.layout_god_consume.node:setVisible(false)
		self.node_t_list.btn_god_up.node:setVisible(false)
		self.txt_get_god_stuff:setVisible(false)
		self:ShowMaxLevelText(true, 620, 130)
	end
end

function EquipmentView:SetNextLvData(data)
	if data == nil then return end
	
	self.cur_god_cell:SetData(data)
	self.node_t_list.img_god_word.node:setVisible(data.equip_data ~= nil)
	self.node_t_list.img_god_lv.node:setVisible(data.equip_data ~= nil)
	
	local limit_god_lv = EquipmentData.GetLimitGodLevel(data.level, data.circle_lv)
	self.node_t_list.img_god_lv.node:loadTexture(limit_god_lv and ResPath.GetEquipment("god_lv_" .. limit_god_lv) or "")
	
	local next_data = TableCopy(data)
	local next_lv = next_data.god_lv + 1
	next_lv = next_lv > 5 and 5 or next_lv
	next_data.god_lv = next_lv
	if next_data.equip_data then
		next_data.equip_data.slot_apotheosis = next_lv
	end
	self.next_god_cell:SetIndex(self.cur_god_cell_index)
	self.next_god_cell:SetData(next_data)
end

function EquipmentView:OnClickGodCell(cell)
	if cell == nil or self.cur_god_cell_index == cell:GetIndex() then
		return
	end
	
	for k, v in pairs(self.god_cell_list) do
		v:SetSelect(false)
	end
	cell:SetSelect(true)
	self.cur_god_cell_index = cell:GetIndex()
	self.cur_god_cell:SetIndex(self.cur_god_cell_index)
	
	local data = cell:GetData()
	self.cur_god_cell:SetData(data)
	
	self:SetGodAttrView(self.cur_god_cell_index)
	self:SetGodConsume(self.cur_god_cell_index)
	
	self:SetNextLvData(data)
end

function EquipmentView:OnClickGodTips()
	DescTip.Instance:SetContent(Language.Equipment.GodDetail, Language.Equipment.GodTitle)
end

function EquipmentView:OnClickGodUpgrade()
	EquipmentCtrl.SendEquipApotheosisReq(self.cur_god_cell_index - 1)
end

function EquipmentView:OnClickGetGodStuff()
	TipCtrl.Instance:OpenStuffTip(Language.Equipment.AdvanceStuffGetWay, EquipmentData.Instance:GetAdvStuffWayConfig() [TabIndex.equipment_god])
end


GodItemRender = GodItemRender or BaseClass(BaseRender)
function GodItemRender:__init()
end

function GodItemRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.god_lv_text = nil
end

function GodItemRender:CreateChild()
	BaseRender.CreateChild(self)
	
	local size = self.view:getContentSize()
	
	self.cell = BaseCell.New()
	self.cell:SetEventEnabled(false)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetRightBottomTexVisible(false)
	self.cell:SetPosition(size.width / 2, size.height / 2)
	self.cell:SetRemind(true, false, BaseCell.SIZE - 20)
	self.view:addChild(self.cell:GetView())
	
	self.god_lv_text = XUI.CreateText(10, 10, 0, 0, nil, "", nil, 18, COLOR3B.RED)
	self.god_lv_text:setAnchorPoint(0, 0)
	self.view:addChild(self.god_lv_text, 50)
end

function GodItemRender:SetRemind(vis)
	self.cell:SetRemind(vis)
end

function GodItemRender:SetShowTips(b)
	self.cell:SetEventEnabled(b)
	self.cell:SetIsShowTips(b)
end

function GodItemRender:OnFlush()
	if self.data == nil then return end
	
	self.cell:SetData(self.data.equip_data)
	self.cell:SetProfIconVisible(false)
	self.cell:SetRightTopNumText(0)
	self.cell:SetBgTa(ResPath.GetEquipBg(string.format("equip_ta_%d", self.index + EquipData.EquipIndex.Weapon - 1)))
	self.cell:SetBgTaVisible(self.data.equip_data == nil)
	
	local name = ""
	if self.data.god_lv > 0 then
		name = EquipmentData.GetGodLevelName(self.data.god_lv >= 5 and 5 or self.data.god_lv)
	end
	self.god_lv_text:setString(name)
end 