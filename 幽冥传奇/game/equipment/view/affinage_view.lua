-- 锻造-精炼
local AffinageView = BaseClass(SubView)

function AffinageView:__init()
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self.texture_path_list[2] = 'res/xui/equipbg.png'
	self.texture_path_list[3] = 'res/xui/appraisal.png'
    self.config_tab = {
		{"equipment_ui_cfg", 2, {0}},
	}
	self.is_bullet_window = false
end

function AffinageView:__delete()
end

function AffinageView:LoadCallBack(index, loaded_times)
	self:CreateAllAffinageCells()
	self:CreateAffinageAttrList()
	self:IntoQhLevelShow()
	-- self:CreateNumberBar()
	-- self:CreatePowerNumEffect()
	
	-- self.txt_get_affinage_stuff = RichTextUtil.CreateLinkText(Language.Equipment.GetProp, 20, COLOR3B.GREEN)
	-- local posx, posy = self.node_t_list.layout_equip_affinage.img_affinage_stone.node:getPosition()
	-- self.txt_get_affinage_stuff:setPosition(posx, posy-30)
	-- self.node_t_list.layout_equip_affinage.node:addChild(self.txt_get_affinage_stuff, 50)
	
	XUI.AddClickEventListener(self.node_t_list.btn_affinage_up.node, BindTool.Bind(self.OnClickAffinageUpgrade, self))
	XUI.AddClickEventListener(self.node_t_list.btn_affinage_up_1key.node, BindTool.Bind(self.OnClickAffinageOnekeyUp, self))
	XUI.AddClickEventListener(self.node_t_list.btn_affinage_tip.node, BindTool.Bind(self.OpemDescContent, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_1.node, BindTool.Bind(self.OpenSuitTips, self), true)


	--XUI.AddClickEventListener(self.node_t_list.btn_affinage_up.node, BindTool.Bind(self.OnClickAffinageUpgrade, self))
	
	self.btn_effec = RenderUnit.CreateEffect(23, self.node_t_list.btn_affinage_up.node, 10)
	self.btn_effec:setVisible(false)
	self.btn_effec_1key = RenderUnit.CreateEffect(23, self.node_t_list.btn_affinage_up_1key.node, 10)
	self.btn_effec_1key:setVisible(false)

	local affinage_data_event_proxy = EventProxy.New(AffinageData.Instance, self)
	affinage_data_event_proxy:AddEventListener(AffinageData.EQUIP_AFFINAGE_INFO, BindTool.Bind(self.OnEquipAffinageInfo, self))
	affinage_data_event_proxy:AddEventListener(AffinageData.AFFINAGE_LV_CHANGE, BindTool.Bind(self.OnAffinageLvChange, self))
	affinage_data_event_proxy:AddEventListener(AffinageData.AFFINAGE_UP_DEFEATED, BindTool.Bind(self.OnAffinageUpDefeated, self))

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	self:BindGlobalEvent(AffinageData.AFFINAGE_UP_SUCCED, BindTool.Bind(self.OnUpSucced,self))

	AffinageCtrl.SendEquipAffinageInfoReq()
	self.is_affinage_up = false
	self.one_key_up = false


	local parent = self.node_t_list["layout_equip_affinage"].node
	ph = self.ph_list["ph_text_btn_3"]
	text_btn = RichTextUtil.CreateLinkText(Language.Tip.ButtonLabel[17], 20, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	parent:addChild(text_btn, 99)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self, 1), true)

	ph = self.ph_list["ph_text_btn_4"]
	text_btn = RichTextUtil.CreateLinkText(Language.Tip.ButtonLabel[17], 20, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	parent:addChild(text_btn, 99)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self, 2), true)
end

function AffinageView:OpenSuitTips()
	EquipmentCtrl.Instance:OpenSuitAttr(2)
end

function AffinageView:OpemDescContent( ... )
	DescTip.Instance:SetContent(Language.DescTip.JiLianContent, Language.DescTip.jiLianTitle)
end

function AffinageView:OnTextBtn(index)
	if index == 1 then
	    MoveCache.end_type = MoveEndType.Normal
        GuajiCtrl.Instance:FlyByIndex(48)
        ViewManager.Instance:OpenViewByDef(ViewDef.Dungeon.Material)

		if ViewManager.Instance:IsOpen(ViewDef.Dungeon.Material) then
			ViewManager.Instance:CloseViewByDef(ViewDef.Equipment)
		end
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.Shop)
		if ViewManager.Instance:IsOpen(ViewDef.Shop) then
			ViewManager.Instance:CloseViewByDef(ViewDef.Equipment)
		end
	end
end

function AffinageView:IntoQhLevelShow()
	local count = 15
	local img_width = 24 -- 图标的宽
	local path = ResPath.GetCommon("common_xing1")
	local parent = self.node_t_list["layout_equip_affinage"].node
	local x, y = self.node_t_list["bg_1"].node:getPosition()
	local x_origin = x - ((count - 1) * img_width) / 2 -- 图标起点
	local img_y = y

	self.level_show_list = self.level_show_list or {}
	local list = self.level_show_list
	for i = 1, count do
		local img_x = x_origin + (i - 1) * img_width
		list[i] = XUI.CreateImageView(img_x, img_y, path, true)
		parent:addChild(list[i], 99)
	end
end


function AffinageView:OpenCallBack()
	self.qianghua_times = 0
end

function AffinageView:CloseCallBack()
	self.one_key_up = false
end

function AffinageView:ReleaseCallBack()
	-- if self.affinage_num then
	-- 	self.affinage_num:DeleteMe()
	-- 	self.affinage_num = nil
	-- end
	
	if self.cur_affinage_cell then
		self.cur_affinage_cell:DeleteMe()
		self.cur_affinage_cell = nil
	end
	
	if self.next_affinage_cell then
		self.next_affinage_cell:DeleteMe()
		self.next_affinage_cell = nil
	end

	if self.consume_affinage_cell then
		self.consume_affinage_cell:DeleteMe()
		self.consume_affinage_cell = nil
	end
	
	if self.cur_affinage_attr then
		self.cur_affinage_attr:DeleteMe()
		self.cur_affinage_attr = nil
	end

	if self.next_affinage_attr then
		self.next_affinage_attr:DeleteMe()
		self.next_affinage_attr = nil
	end
	
	if self.affinage_cell_list ~= nil then
		for k, v in pairs(self.affinage_cell_list) do
			v:DeleteMe()
		end
		self.affinage_cell_list = {}
	end
	
	 if self.equip_cell1 then
        self.equip_cell1:DeleteMe()
        self.equip_cell1 = nil
    end

	self.cur_affinage_cell_index = nil
	self.play_eff = nil
	self.afffinage_effect = nil
	self.power_effect = nil
	self.max_lv_text = nil
	self.is_bullet_window = nil
end

function AffinageView:CreateNumberBar()
	-- if nil == self.affinage_num then 
	-- 	local ph = self.ph_list.ph_affinage_num
	-- 	self.affinage_num = NumberBar.New()
	-- 	self.affinage_num:SetRootPath(ResPath.GetCommon("num_121_"))
	-- 	self.affinage_num:SetPosition(ph.x, ph.y)
	-- 	self.affinage_num:SetGravity(NumberBarGravity.Left)
	-- 	self.node_t_list.layout_equip_affinage.node:addChild(self.affinage_num:GetView(), 300, 300)
	-- end
end

function AffinageView:CreateAllAffinageCells()

	--self.cur_affinage_cell = self:CreateOneAffinageCell(self.ph_list.ph_cur_equip_cell)
	--self.next_affinage_cell = self:CreateOneAffinageCell(self.ph_list.ph_next_equip_cell)
	
	-- self.cur_affinage_cell:SetRemind(false)
	-- self.cur_affinage_cell:SetShowTips(true)
	-- self.cur_affinage_cell.cell:SetCellSpecialBg(ResPath.GetCommon("cell_112"))
	-- self.cur_affinage_cell.affinage_lv_text:setPosition(80, 80)
	-- self.next_affinage_cell:SetRemind(false)
	-- self.next_affinage_cell:SetShowTips(true)
	-- self.next_affinage_cell.cell:SetCellSpecialBg(ResPath.GetCommon("cell_112"))
	--self.next_affinage_cell.affinage_lv_text:setPosition(80, 80)

	local ph = self.ph_list.ph_prop_cell
	self.consume_affinage_cell = BaseCell.New()
	self.consume_affinage_cell:GetView():setAnchorPoint(0.5, 0.5)
	-- self.consume_affinage_cell:SetCellSpecialBg(ResPath.GetCommon("cell_112"))
	self.consume_affinage_cell:SetPosition(ph.x, ph.y)
	self.node_t_list.layout_equip_affinage.node:addChild(self.consume_affinage_cell:GetView(), 99)

	
	self.affinage_cell_list = {}
	for i = 1, 10 do
		local cell = self:CreateOneAffinageCell(self.ph_list["ph_affinage_cell_" .. i])
		cell:SetIndex(i)
		cell:AddClickEventListener(BindTool.Bind(self.OnSelectAffinageCell, self))
		self.affinage_cell_list[i] = cell
	end
	AffinageData.Instance:SetAffinageCellDataList()
end

function AffinageView:CreateOneAffinageCell(ph,zorder)
	if ph == nil then return end
	local rander_ph = self.ph_list.ph_qaffinage_item
	local cell = AffinageView.AffinageItemRender.New()
	cell:SetAnchorPoint(0.5, 0.5)
	cell:SetPosition(ph.x, ph.y)
	cell:SetUiConfig(rander_ph, true)
	if zorder == nil then
		zorder = 50
	end
	self.node_t_list.layout_equip_affinage.node:addChild(cell:GetView(), zorder)
	return cell
end

-- function AffinageView:OnSelectAffinageCell(cell)
-- 	if cell == nil then
-- 		return
-- 	end
-- 	self.cur_affinage_cell_index = cell:GetIndex()
-- 	self:FlushImgShow()
-- end

function AffinageView:FlushImgShow()
	self.node_t_list["img_equipment_bg2"].node:loadTexture(ResPath.GetEquipment("equipment_img_" .. self.cur_affinage_cell_index ))
	local affinage_lv = AffinageData.Instance:GetAffinageLevelBySlot(self.cur_affinage_cell_slot)
	self.node_t_list.lbl_affinage_level.node:setString("+".. affinage_lv)

	local level = affinage_lv == 0 and 0 or affinage_lv%15 == 0 and 15 or affinage_lv%15

	for k, v in pairs(self.level_show_list) do
		if level >= k then
			v:loadTexture(ResPath.GetCommon("common_xing2"))
		else
			v:loadTexture(ResPath.GetCommon("common_xing1"))
		end
	end
end

function AffinageView:CreateAffinageAttrList()
	local ph = self.ph_list.ph_affinage_cur_attr
	self.cur_affinage_attr = ListView.New()
	self.cur_affinage_attr:Create(ph.x + 10, ph.y, ph.w, ph.h, ScrollDir.Vertical, AttrAffinageTextRender, nil, nil, self.ph_list.ph_affinage_cur_attr_item)
	self.cur_affinage_attr:SetItemsInterval(2)
	self.cur_affinage_attr:SetMargin(2)
	self.node_t_list.layout_equip_affinage.node:addChild(self.cur_affinage_attr:GetView(), 999)

	ph = self.ph_list.ph_affinage_next_attr
	self.next_affinage_attr = ListView.New()
	self.next_affinage_attr:Create(ph.x + 10, ph.y, ph.w, ph.h, ScrollDir.Vertical, AttrAffinageTextRender, nil, nil, self.ph_list.ph_next_attr_txt_item)
	self.next_affinage_attr:SetItemsInterval(2)
	self.next_affinage_attr:SetMargin(2)
	self.node_t_list.layout_equip_affinage.node:addChild(self.next_affinage_attr:GetView(),999)
end

function AffinageView:CreatePowerNumEffect()
	if nil == self.power_effect then
		self.power_effect = RenderUnit.CreateEffect(21, self.node_t_list.layout_equip_affinage.node, 25)
	end
	-- local ph = self.ph_list.ph_affinage_num
	-- self.power_effect:setPosition(ph.x + 15, ph.y + 20)
end

function AffinageView:OnFlush(param_t)
end

function AffinageView:OnEquipAffinageInfo()
	self:SetAffinageCellList()
	self.cur_affinage_cell_index = AffinageData.Instance:GetAffinageCurrentIndex()
	self:OnSelectAffinageCell(self.affinage_cell_list[self.cur_affinage_cell_index])
	self:FlushConsume(self.cur_affinage_cell_index)
	self:FlushAffinageCellRemind()
	self:SetAffinageConsume(self.cur_affinage_cell_index)
	-- self:SetAffinageEff(9, 482, 408)

end

function AffinageView:OnAffinageLvChange()
	self:FlushConsume(self.cur_affinage_cell_index)
	self:FlushAffinageCellRemind()
	self:SetAffinageConsume(self.cur_affinage_cell_index)
	self:FlushImgShow()
	self:SetAffinageCellList()
	-- self.is_affinage_up = false
	-- self.node_t_list.btn_affinage_up.node:setEnabled(false)
	-- -- self:SetShowPlayEff(17, 480, 300)
	-- local before_cell = self.affinage_cell_list[self.cur_affinage_cell_index]
	-- self.cur_affinage_cell_index = AffinageData.Instance:GetAffinageCurrentIndex()

	-- local cell = self.affinage_cell_list[self.cur_affinage_cell_index]
	-- self.equip_cell1 = self.equip_cell1 or self:CreateOneAffinageCell(self.ph_list.ph_cur_equip_cell,999)

 --    self.equip_cell1:SetVisible(false)
	
	-- self.equip_cell1:SetPosition(cell:GetView():getPosition())
	-- self.equip_cell1:SetIndex(cell:GetIndex())
	-- self.equip_cell1:SetData(cell:GetData())

	-- self:TransitionCell(self.equip_cell1:GetView(),
	-- cc.p(self.cur_affinage_cell:GetView():getPosition()),
	-- function()
	-- 	self.equip_cell1:SetVisible(false)
	-- 	self.cur_affinage_cell:SetIndex(cell:GetIndex())
	-- 	self.cur_affinage_cell:SetData(cell:GetData())

        -- self:OnSelectAffinageCell(self.affinage_cell_list[self.cur_affinage_cell_index])
 --        self:SetAffinageCellList()
	-- 	self:FlushConsume(self.cur_affinage_cell_index)
	-- 	local new_cell_data = AffinageData.Instance:GetAffinageCellDataList() [self.cur_affinage_cell_index]
	-- 	self.affinage_cell_list[self.cur_affinage_cell_index]:SetData(new_cell_data)
		self:SetAffinageAttrView(self.cur_affinage_cell_index)
	-- 	self:SetAffinageConsume(self.cur_affinage_cell_index)
	-- 	self:SetNextLvData(new_cell_data)
	-- 	self:FlushAffinageCellRemind()
	-- 	self.node_t_list.btn_affinage_up.node:setEnabled(true)
	-- end)
	
end

function AffinageView:TransitionCell(node1, pos1, callback)
	local move1 = cc.MoveTo:create(0.6, pos1)
	local callfunc = cc.CallFunc:create(callback)
	local sequence = cc.Sequence:create(move1, callfunc)
	node1:setVisible(true)
	node1:runAction(sequence)
end

function AffinageView:OnAffinageUpDefeated()
	self.is_affinage_up = false
end

function AffinageView:OnBagItemChange(event)
	local affinage_lv = AffinageData.Instance:GetAffinageLevelBySlot(self.cur_affinage_cell_slot)
	local consume_cfg = AffinageData.GetAffinageConsumeCfg(self.cur_affinage_cell_slot, affinage_lv + 1)
	local consume_id = 3479
	if consume_cfg then
		consume_id = consume_cfg.id
	end
	local is_flush = false
	if event.GetChangeDataList then
		for i,v in ipairs(event:GetChangeDataList()) do
			if v.data and v.data.item_id == consume_id and self.cur_affinage_cell_index then
				is_flush = true
				break
			end
		end
	end
	if is_flush then
		self:SetAffinageConsume(self.cur_affinage_cell_index)
		self:FlushConsume(self.cur_affinage_cell_index)
		self:FlushAffinageCellRemind()
	end
end

function AffinageView:FlushAffinageCellRemind()
	local circle_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	for k, v in pairs(self.affinage_cell_list) do
		local data = v:GetData()
		if data ~= nil then
			local consume_cfg = AffinageData.GetAffinageConsumeCfg(data.slot, data.affinage_lv + 1)
			if consume_cfg then
				local have = BagData.Instance:GetItemNumInBagById(consume_cfg.id)
				v:SetRemind(have >= consume_cfg.count and circle_lv >= AffinageData.GetApotheosisOpenLv())
			else
				v:SetRemind(false)
			end
		end
	end
	self:BtnRemindEffecShow()
end

function AffinageView:BtnRemindEffecShow()
	local num = AffinageData.Instance:GetCanAffinage()
	self.btn_effec:setVisible(num > 0)
	self.btn_effec_1key:setVisible(num > 0)
end

function AffinageView:FlushConsume(select_index)
	local slot = 1
	local cell = self.affinage_cell_list[select_index]
	if cell then
		local data = cell:GetData()
		slot = data.slot
	end

	local affinage_lv = AffinageData.Instance:GetAffinageLevelBySlot(slot)
	local consume_cfg = AffinageData.GetAffinageConsumeCfg(slot, affinage_lv + 1)
	local text = ""
	local color = COLOR3B.RED
	if consume_cfg then 
		self.consume_affinage_cell:SetData({item_id = consume_cfg.id, num = 1, is_bind = 0})
		local num = BagData.Instance:GetItemNumInBagById(consume_cfg.id)
		color = num >= consume_cfg.count and COLOR3B.GREEN or COLOR3B.RED 
		text = num .. "/".. consume_cfg.count
	end
	self.consume_affinage_cell:SetRightBottomText(text, color)
end

function AffinageView:SetAffinageCellList()
	local cell_data_list = AffinageData.Instance:GetAffinageCellDataList()
	for k, v in pairs(cell_data_list) do
		self.affinage_cell_list[k]:SetData(v)
	end
end

function AffinageView:SetAffinageAttrView(select_index)
	local slot = 1
	local cell = self.affinage_cell_list[select_index]
	if cell then
		local data = cell:GetData()
		slot = data.slot
	end

	local affinage_lv = AffinageData.Instance:GetAffinageLevelBySlot(slot)
	local attr_data = AffinageData.Instance:GetAffinageAttr(slot, affinage_lv)
	local n_attr_data = AffinageData.Instance:GetAffinageAttr(slot, affinage_lv + 1)
	local next_attr = {{type_str = Language.Common.MaxLv,},}
	if n_attr_data then 
		-- table.sort(n_attr_data, function(a, b)
		-- 	return a.type < b.type
		-- end)
		next_attr = RoleData.FormatRoleAttrStr(n_attr_data)
	end
	local attr = RoleData.FormatRoleAttrStr(attr_data)

	self.cur_affinage_attr:SetDataList(attr)
	self.next_affinage_attr:SetDataList(next_attr)
-- 	-- self.affinage_num:SetNumber(CommonDataManager.GetAttrSetScore(attr_data))
-- 	local cur_attr = RoleData.FormatRoleAttrStr(attr_data)
-- 	table.sort(cur_attr, function(a, b)
-- 		return a.type < b.type
-- 	end)
-- 	-- self.cur_affinage_attr:SetData(cur_attr)

end

function AffinageView:SetAffinageConsume(select_index)
	local slot = 1
	local cell = self.affinage_cell_list[select_index]
	if cell then
		local data = cell:GetData()
		slot = data.slot
	end

	local affinage_lv = AffinageData.Instance:GetAffinageLevelBySlot(slot)
	local consume_cfg = AffinageData.GetAffinageConsumeCfg(slot, affinage_lv + 1)
	if consume_cfg  then
		self.node_t_list.btn_affinage_up.node:setVisible(true)
		self.node_t_list.btn_affinage_up_1key.node:setVisible(true)
	-- 	local has_count = BagData.Instance:GetItemNumInBagById(consume_cfg.id)
	-- 	local jl_stone_txt = string.format(Language.Equipment.StrengthPropNum, has_count >= consume_cfg.count and COLORSTR.GREEN or COLORSTR.RED, has_count, consume_cfg.count) 
	-- 	RichTextUtil.ParseRichText(self.node_t_list.rich_qh_stone_3.node, jl_stone_txt, 18)

	-- 	-- self.node_t_list.layout_equip_affinage.img_affinage_stone.node:loadTexture(ResPath.GetItem(consume_cfg.id))
	-- 	-- self.node_t_list.layout_equip_affinage.img_affinage_stone.node:setScale(0.35)
	-- 	self.is_bullet_window = has_count < consume_cfg.count
	else    -- 满级
		self.node_t_list.btn_affinage_up.node:setVisible(false)
		self.node_t_list.btn_affinage_up_1key.node:setVisible(false)
	-- 	local btn_x, btn_y = self.node_t_list.btn_affinage_up.node:getPosition()
	-- 	if self.max_lv_text == nil then
	-- 		self.max_lv_text = XUI.CreateText(btn_x+82, btn_y, 0, 0, nil, Language.Common.AlreadyTopLv, "", 22, COLOR3B.G_W2)
	-- 		self.max_lv_text:setAnchorPoint(0.5, 0.5)
	-- 		self.node_t_list.layout_equip_affinage.node:addChild(self.max_lv_text, 999)
	-- 	end
	-- 	RichTextUtil.ParseRichText(self.node_t_list.rich_qh_stone_3.node, "", 18)
	-- 	-- self.node_t_list.rich_affinage_stone.node:setVisible(false)
	end
end

function AffinageView:SetNextLvData(data)
	if data == nil then return end
	
	--self.cur_affinage_cell:SetData(data)
	local next_data = TableCopy(data)
	local next_lv = next_data.affinage_lv + 1
	next_data.affinage_lv = next_lv
	if next_data.equip_data then
		next_data.equip_data.slot_apotheosis = next_lv
	end
	self.next_affinage_cell:SetIndex(self.cur_affinage_cell_index)
	self.next_affinage_cell:SetData(next_data)
end

function AffinageView:OnSelectAffinageCell(cell)
	if cell == nil then
		return
	end
	for k, v in pairs(self.affinage_cell_list) do
		v:SetSelect(false)
	end
	cell:SetSelect(true)
	self.cur_affinage_cell_index = cell:GetIndex()
	local slot = 1
	local cell = self.affinage_cell_list[self.cur_affinage_cell_index]
	if cell then
		local data = cell:GetData()
		slot = data.slot
	end
	self.cur_affinage_cell_slot = slot

	-- self.cur_affinage_cell:SetIndex(self.cur_affinage_cell_index)
	
	local data = cell:GetData()
	--self.cur_affinage_cell:SetData(data)
	self:FlushImgShow()
	self:SetAffinageAttrView(self.cur_affinage_cell_index)
	self:SetAffinageConsume(self.cur_affinage_cell_index)
	self:FlushConsume(self.cur_affinage_cell_index)
	
	--self:SetNextLvData(data)
end

function AffinageView:OnUpSucced()
	if self.one_key_up then
		self:SetShowPlayEff(17, 480, 300)
		self.one_key_up = false	
	end
end

function AffinageView:SetShowPlayEff(eff_id, x, y)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.node_t_list.layout_equip_affinage.node:addChild(self.play_eff, 999)
	end
	self.play_eff:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end


function AffinageView:SetAffinageEff(eff_id, x, y)
	if nil == self.afffinage_effect then 
		self.afffinage_effect = RenderUnit.CreateEffect(eff_id, self.node_t_list.layout_equip_affinage.node, 999)
	end 
	self.afffinage_effect:setPosition(x, y)
end

function AffinageView:OnClickAffinageUpgrade()
	local affinage_lv = AffinageData.Instance:GetAffinageLevelBySlot(self.cur_affinage_cell_slot)
	local consume_cfg = AffinageData.GetAffinageConsumeCfg(self.cur_affinage_cell_slot, affinage_lv + 1)
	if consume_cfg  then
		local num = BagData.Instance:GetItemNumInBagById(consume_cfg.id)
		if num >= consume_cfg.count  then 
			AffinageCtrl.SendEquipAffinageReq(EquipmentData.Equip[self.cur_affinage_cell_index].equip_slot)
		else
			local id = consume_cfg.id
			TipCtrl.Instance:OpenGetNewStuffTip(id, 1)
			-- local item_id = EquipmentData.Instance:GetAdvStuffWayConfig()[EquipmentData.TabIndex.equipment_affinage][1]
			-- local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
			-- local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
			--TipCtrl.Instance:OpenNewBuyTip(EquipmentData.Instance:GetAdvStuffWayConfig()[EquipmentData.TabIndex.equipment_affinage][1])
		end
	end
end

function AffinageView:OnClickAffinageOnekeyUp()
	-- if self.is_bullet_window then
	-- 	--self:OnClickGetAffinageStuff()
	-- else
		--AffinageCtrl.SendOneKeyEquipAffinageReq()
	-- 	self.one_key_up = true
	-- end

	self.jilian_times = 0 -- 已强化次数 用于屏蔽回调

	-- 根据定义的顺序升级
	local order = QianghuaData.Order

	local consumes_list = {} -- 物品消耗记录
	local virtual_consumes_list = {} -- 虚拟物品消耗记录

	-- 获取精炼等级列表 qianghua_lv_list 和 最小强化等级 min_lv
	local jilian_lv_list = {}
	local min_lv = 9999
	for equip_slot, cell in pairs(self.affinage_cell_list) do
		local jilian_info = cell:GetData()
		local jilian_lv = jilian_info.affinage_lv or MAX_JILIAN_LEVEL
		jilian_lv_list[jilian_lv] = jilian_lv_list[jilian_lv] or {}
		jilian_lv_list[jilian_lv][equip_slot - 1] = true
		min_lv = jilian_lv < min_lv and jilian_lv or min_lv 
	end

	local need_upgrade_list = {} -- 需要升级的槽位列表
	local can_keep_up = true -- 可以继续升级
	for jilian_lv = min_lv, MAX_JILIAN_LEVEL - 1 do
		local cur_lv_list = jilian_lv_list[jilian_lv] or {}

		-- 根据定义的槽位顺序升级
		for i, equip_slot in ipairs(order) do

			-- 当前槽位是否需要升级
			local need_up = false
			if cur_lv_list[equip_slot] then
				need_up = true
				need_upgrade_list[equip_slot] = true
			elseif need_upgrade_list[equip_slot] then
				need_up = true
			end

			-- need_up 是否需要升级
			if need_up then

				----------升级逻辑----------

				----------可升级判断----------
				-- print("2222",equip_slot)
				local consumes = AffinageData.GetAffinageConsumeCfg(equip_slot, jilian_lv+1)
				local can_upgrade = nil ~= next(consumes or {}) -- 当前槽位是否可升级

				if consumes then

				    local item_id = consumes.id or 1
					local _type = consumes.type or 0
					local has_been_consume_count -- 本次一键升级已消耗的数量
					if _type == tagAwardType.qatEquipment then
						has_been_consume_count = consumes_list[item_id] or 0
					else
						has_been_consume_count = virtual_consumes_list[_type] or 0
					end

					local consume_count = BagData.GetConsumesCount(item_id, _type) -- 此方法有区分虚拟物品数量获取
					local cfg_consume_count = consumes.count or 0
					if (consume_count - has_been_consume_count) < cfg_consume_count then
						can_upgrade = false
					end
				end
				----------可升级判断end----------

				if can_upgrade then
					local real_slot = equip_slot
					-- local vis = self.node_t_list["img_checkbox_hook"].node:isVisible()
					-- local index = vis and 1 or 0
					--print(real_slot)
					AffinageCtrl.SendEquipAffinageReq(real_slot) -- 请求精炼
					-- 记录已消耗数量,避免消耗不足还进行请求
					local has_been_consume_count = consumes_list[consumes.id] or 0
						consumes_list[consumes.id] = has_been_consume_count + consumes.count
					self.jilian_times = self.jilian_times + 1
				else
					can_keep_up = false
					break
				end
				----------升级逻辑end----------

			end -- need_up 需要升级
		end -- order

		-- "不能继续升级时"时,停止判断
		if not can_keep_up then
			break
		end
	end

	-- 未进行升级时,弹出强化石购买提示
	if nil == next(consumes_list) and nil == next(virtual_consumes_list) then
		local affinage_lv = AffinageData.Instance:GetAffinageLevelBySlot(self.cur_affinage_cell_slot)
		local consume_cfg = AffinageData.GetAffinageConsumeCfg(self.cur_affinage_cell_slot, affinage_lv + 1)
		if consume_cfg == nil then
			consume_cfg = AffinageData.GetAffinageConsumeCfg(self.cur_affinage_cell_slot, affinage_lv)
		end
		local id = consume_cfg.id
		TipCtrl.Instance:OpenGetNewStuffTip(id, 1)
	end
end

function AffinageView:OnClickGetAffinageStuff()
	--TipCtrl.Instance:OpenBuyTip(EquipmentData.Instance:GetAdvStuffWayConfig()[EquipmentData.TabIndex.equipment_affinage][1])
end




AffinageView.AffinageItemRender = BaseClass(BaseRender)
local AffinageItemRender = AffinageView.AffinageItemRender

function AffinageItemRender:__init()
end

function AffinageItemRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.affinage_lv_text = nil
	self.img_remind = nil
end

function AffinageItemRender:CreateChild()
	BaseRender.CreateChild(self)
	
	local size = self.view:getContentSize()
	
	-- self.cell = BaseCell.New()
	-- -- self.cell:SetEventEnabled(false)
	-- self.cell:SetAnchorPoint(0.5, 0.5)
	-- self.cell:SetRightBottomTexVisible(false)
	-- self.cell:SetPosition(size.width / 2, size.height / 2)
	-- self.cell:SetRemind(false, false, BaseCell.SIZE - 20)
	-- self.view:addChild(self.cell:GetView())
	
	-- self.affinage_lv_text = XUI.CreateText(70, 70, 0, 0, nil, "", nil, 18, COLOR3B.YELLOW)
	-- self.affinage_lv_text:setAnchorPoint(1, 1)
	-- self.view:addChild(self.affinage_lv_text, 50)

	self.img_remind = XUI.CreateImageView(size.width - 85, size.height - 25,  ResPath.GetMainui("remind_flag"))
    self.img_remind:setAnchorPoint(0, 0)
    self.view:addChild(self.img_remind, 9999)
    self.img_remind:setVisible(false)
end

function AffinageItemRender:SetRemind(vis)
	-- self.cell:SetRemind(vis)
	self.img_remind:setVisible(vis)
end

function AffinageItemRender:SetShowTips(b)
	-- self.cell:SetEventEnabled(b)
	-- self.cell:SetIsShowTips(b)
end

function AffinageItemRender:OnFlush()
	if self.data == nil then return end
	
	--self.cell:SetData(self.data.equip_data)
	--self.cell:SetProfIconVisible(false)
	--self.cell:SetRightTopNumText(0)
	-- if self.index > 0 then
		self.node_tree.img_equipment_bg.node:loadTexture(ResPath.GetEquipment("equipment_img_" .. (self.data.slot + 1)))
	--end
	self.node_tree.lbl_qh_level.node:setString("+" .. self.data.affinage_lv)

	--self.affinage_lv_text::setString("+" .. self.data.affinage_lv)
	--PrintTable(self.data)
end 


AttrAffinageTextRender = AttrAffinageTextRender or  BaseClass(BaseRender)

function AttrAffinageTextRender:__init()
	
end

function AttrAffinageTextRender:__delete()

end

function AttrAffinageTextRender:CreateChild()
	BaseRender.CreateChild(self)
end

function AttrAffinageTextRender:OnFlush()
	if nil == self.data then 
		self.node_tree.lbl_attr_txt.node:setString("")
		return 
	end

	self.node_tree.lbl_attr_name.node:setString(self.data.type_str .. "：")
	self.node_tree.lbl_attr_txt.node:setString(self.data.value_str)
end

function AttrAffinageTextRender:CreateSelectEffect()
end

return AffinageView