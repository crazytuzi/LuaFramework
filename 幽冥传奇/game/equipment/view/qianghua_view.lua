local QianghuaView = BaseClass(SubView)

function QianghuaView:__init()
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self.texture_path_list[2] = 'res/xui/appraisal.png'
    self.config_tab = {
		{"equipment_ui_cfg", 1, {0}},
	}
	self.is_bullet_window = false
	self.item_cell = nil
end

function QianghuaView:__delete()
end

function QianghuaView:LoadCallBack(index, loaded_times)
	self.node_t_list["img_checkbox_hook"].node:setVisible(false) --屏蔽用钻石替换材料的选项
	self.node_t_list["layout_checkbox"].node:setVisible(false)

	self.strengthen_slot = 0
	self:CreateAllQianghuaCells()
	self:CreateItemCell()
	self:CreateAttrList()
	self:IntoQhLevelShow()
	self:InitTextBtn()
	
	
	self.node_t_list["btn_auto_qianghua"].remind_eff = RenderUnit.CreateEffect(23, self.node_t_list["btn_auto_qianghua"].node, 1)
	self.node_t_list["btn_auto_qianghua"].remind_eff:setVisible(false)

	self.node_t_list["img_max_lv"].node:setVisible(false)
	self.node_t_list["img_max_lv2"].node:setVisible(false)

	-- XUI.AddClickEventListener(self.node_t_list["layout_checkbox"].node, BindTool.Bind(self.OnCheckBox, self))
	XUI.AddClickEventListener(self.node_t_list.btn_qianghua.node, BindTool.Bind(self.OnClickQhHandler, self))
	XUI.AddClickEventListener(self.node_t_list["btn_auto_qianghua"].node, BindTool.Bind(self.OnClickAtuoQhHandler, self))
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnClickShowAttr, self))
	XUI.AddClickEventListener(self.node_t_list.btn_qianghua_tip.node, BindTool.Bind(self.OpenShowQianghuaTip, self))

	EventProxy.New(QianghuaData.Instance, self):AddEventListener(QianghuaData.FLUSH_STRENGTHEN_ATTR, BindTool.Bind(self.OnFlushStengthAttr, self))
	EventProxy.New(QianghuaData.Instance, self):AddEventListener(QianghuaData.STRENGTHEN_CHANGE, BindTool.Bind(self.OnStrengthChange, self))
	EventProxy.New(QianghuaData.Instance, self):AddEventListener(QianghuaData.STOP_STRENGTHEN, BindTool.Bind(self.OnStopStrength, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_COIN, BindTool.Bind(self.OnMoneyChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_GOLD, BindTool.Bind(self.OnMoneyChange, self))

	self:BindGlobalEvent(OtherEventType.STRENGTH_1KEY_SUCC, BindTool.Bind(self.OnUpSucced,self))
	QianghuaCtrl.SendEquipStrengthenInfoReq()
end

function QianghuaView:OpenShowQianghuaTip()
	DescTip.Instance:SetContent(Language.DescTip.QianghuaContent, Language.DescTip.QianghuaTitle)
end

function QianghuaView:ReleaseCallBack()
	if self.qianghua_cells then
		for k,v in pairs(self.qianghua_cells) do
			v:DeleteMe()
		end
		self.qianghua_cells = {}
	end
	if self.qh_act_cell1 then
		self.qh_act_cell1:DeleteMe()
		self.qh_act_cell1 = nil
	end
	if self.qh_act_cell2 then
		self.qh_act_cell2:DeleteMe()
		self.qh_act_cell2 = nil
	end
	if self.cur_strength_attr then 
		self.cur_strength_attr:DeleteMe()
		self.cur_strength_attr = nil
	end
	if self.next_strength_attr then
		self.next_strength_attr:DeleteMe()
		self.next_strength_attr = nil
	end
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.play_eff = nil
	self.max_lv_text = nil
	self.is_bullet_window = nil
	self.level_show_list = nil
end

function QianghuaView:OpenCallBack()
	self.qianghua_times = 0
end

function QianghuaView:CloseCallBack()
end

function QianghuaView:OnFlush(param_t)
	
end

function QianghuaView:ShowIndexCallBack()
end

----------视图函数----------

function QianghuaView:CreateAllQianghuaCells()
	self.qianghua_cells = {}
	for i = 0, MAX_STRENGTHEN_SLOT - 1 do
		local ph = self.ph_list["ph_qhcell_" .. (i + 1)]
		local cell = self:CreateQianghuaCell(ph)
		cell:SetIndex(i)
		self.qianghua_cells[i] = cell
	end
end

-- 强化选中cell
function QianghuaView:CreateQianghuaCell(ph)
	local rander_ph = self.ph_list.ph_qh_item
	local cell = QianghuaView.QianghuaRender.New()
	cell:SetUiConfig(rander_ph, true)
	self.node_t_list.layout_qianghua.node:addChild(cell:GetView(), 99)
	cell:GetView():setAnchorPoint(0.5, 0.5)
	cell:GetView():setPosition(ph.x, ph.y)
	cell:AddClickEventListener(BindTool.Bind(self.OnQianghuaCell, self))
	XUI.AddRemingTip(cell:GetView(), nil, nil, 15)
	return cell
end

-- 消耗物品cell
function QianghuaView:CreateItemCell()
	if self.item_cell then return end

	local item_cell = BaseCell.New()
	item_cell:SetPosition(self.ph_list.ph_qhitem.x, self.ph_list.ph_qhitem.y)
	item_cell:SetCellBg(ResPath.GetCommon("cell_100"))
	item_cell:GetCell():setAnchorPoint(0.5, 0.5)
	item_cell:SetIsShowTips(true)
	self.node_t_list.layout_qianghua.node:addChild(item_cell:GetCell(), 1, 1)
	self.item_cell = item_cell
	self.item_cell:SetData({item_id = 351, is_bind = 0})
end

function QianghuaView:OnQianghuaCell(item)
	self:OnSelectQianghuaCell(item)
end

function QianghuaView:CreateAttrList()
	local ph
	ph = self.ph_list.ph_qianghua_cur_attr
	self.cur_strength_attr = ListView.New()
	self.cur_strength_attr:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.AttrTextRender, nil, nil, self.ph_list.ph_attr_txt_item)
	self.cur_strength_attr:SetItemsInterval(2)
	self.cur_strength_attr:SetMargin(2)
	self.node_t_list.layout_qianghua.node:addChild(self.cur_strength_attr:GetView(), 50)

	ph = self.ph_list.ph_qianghua_next_attr
	self.next_strength_attr = ListView.New()
	self.next_strength_attr:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.AttrTextRender, nil, nil, self.ph_list.ph_next_attr_txt_item)
	self.next_strength_attr:SetItemsInterval(2)
	self.next_strength_attr:SetMargin(2)
	self.node_t_list.layout_qianghua.node:addChild(self.next_strength_attr:GetView(), 50)
end


function QianghuaView:InitTextBtn()
	local ph
	local text_btn
	local parent = self.node_t_list["layout_qianghua"].node
	ph = self.ph_list["ph_text_btn_1"]
	text_btn = RichTextUtil.CreateLinkText(Language.Tip.ButtonLabel[17], 20, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	parent:addChild(text_btn, 99)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self, 1), true)

	ph = self.ph_list["ph_text_btn_2"]
	text_btn = RichTextUtil.CreateLinkText(Language.Tip.ButtonLabel[17], 20, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	parent:addChild(text_btn, 99)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self, 2), true)
end

function QianghuaView:OnTextBtn(index)
	if index == 1 then
		ViewManager.Instance:OpenViewByDef(ViewDef.Experiment.DigOre)
		if ViewManager.Instance:IsOpen(ViewDef.Experiment.DigOre) then
			ViewManager.Instance:CloseViewByDef(ViewDef.Equipment)
		end
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.Experiment.Trial)
		if ViewManager.Instance:IsOpen(ViewDef.Experiment.Trial) then
			ViewManager.Instance:CloseViewByDef(ViewDef.Equipment)
		end
	end
end

function QianghuaView:OnFlushStengthAttr()
	self:FlusQianghuaData()
end

function QianghuaView:OnStrengthChange(slot)
	self.qianghua_times = self.qianghua_times - 1
	if self.qianghua_times <= 0 then
		self:SetShowPlayEff(1121, 290, 250)
		self:FlushStrengthData()
		self:FlushAttrText()
		self:FlushEquipData()
		self:FlushSelecSlot()
		self:FlushMaxStrength()
	end
end

function QianghuaView:OnStopStrength()
end

function QianghuaView:OnBagItemChange(event)
	local strengthen_info = QianghuaData.Instance:GetOneStrengthList(self.strengthen_slot)
	local consume_cfg = QianghuaData.Instance:GetStrengthenConsume(self.strengthen_slot, strengthen_info.strengthen_level + 1)
	local stuff_id = 351
	if consume_cfg then
		stuff_id = consume_cfg[1].id
	end
	local is_flush = false
	if event.GetChangeDataList then
		for i,v in ipairs(event:GetChangeDataList()) do
			if v.data and v.data.item_id == stuff_id then
				is_flush = true
				break
			end
		end
	end
	if is_flush then
		self:FlushStrengthData()
		self:FlushEquipData()
	end
end

function QianghuaView:OnMoneyChange()
	self:FlushStrengthData()
	self:FlushEquipData()
end

function QianghuaView:FlushStrengthData()
	self:FlushQhLevelShow()
	self:FlushConsumes()
end

function QianghuaView:FlushConsumes()
	local strengthen_info = QianghuaData.Instance:GetOneStrengthList(self.strengthen_slot)
	local consume_cfg = QianghuaData.Instance:GetStrengthenConsume(self.strengthen_slot, strengthen_info.strengthen_level + 1)
	if consume_cfg then
		local has_count = 0
		local vis = self.node_t_list["img_checkbox_hook"].node:isVisible()

		local item_count = BagData.Instance:GetItemNumInBagById(consume_cfg[1].id)
		local stuff_count = consume_cfg[1].count - item_count
		local need_consume_moneys = stuff_count > 0
		if need_consume_moneys and vis then
			-- 需要消耗金钱时,改成显示消耗的金钱部分.
			local consume = EquipSlotStrongCfg and EquipSlotStrongCfg.moneys or {type = 15, id = 0, count = 10}
			local new_consume_cfg = ItemData.InitItemDataByCfg(consume)
			has_count = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) -- 写死替换材料显示取钻石数量
			stuff_count = stuff_count * consume.count
			stuff_id = new_consume_cfg.item_id
			-- local path = ResPath.GetCommon("gold")
			-- self.node_t_list["img_strength_stone"].node:loadTexture(path)
			-- self.node_t_list["img_strength_stone"].node:setScale(1)
		else
			stuff_id = consume_cfg[1].id
			stuff_count = consume_cfg[1].count
			has_count = BagData.Instance:GetItemNumInBagById(stuff_id)

			-- local item_cfg = ItemData.Instance:GetItemConfig(self.stuff_id)
			-- self.node_t_list["img_strength_stone"].node:loadTexture(ResPath.GetItem(tonumber(item_cfg.icon)))
			-- self.node_t_list["img_strength_stone"].node:setScale(0.35)
		end

		self.can_qianghua = has_count >= stuff_count
		self.stuff_data = {item_id = stuff_id, num = stuff_count - has_count} -- 消耗缓存 用于打开快速购买tips

		local xh_color = has_count >= stuff_count and COLOR3B.GREEN or COLOR3B.RED
		self.node_t_list["lbl_qh_stone"].node:setString(has_count .. "/" .. stuff_count)
		self.node_t_list["lbl_qh_stone"].node:setColor(xh_color)

		local consume_type, consume_count = consume_cfg[2].type, consume_cfg[2].count
		local has_count_2 = RoleData.Instance:GetMainMoneyByType(consume_type)
		local qh_stone_txt = string.format(Language.Equipment.StrengthPropNum, has_count_2 >= consume_count and COLORSTR.GREEN or COLORSTR.RED, has_count_2, consume_count) 
		RichTextUtil.ParseRichText(self.node_t_list.rich_qh_stone_2.node, qh_stone_txt, 18)
		self.node_t_list.rich_qh_stone_2.node:setIgnoreSize(true)
		self.node_t_list.rich_qh_stone_2.node:refreshView()

		-- 设置是否弹窗
		self.is_bullet_window = has_count < stuff_count

	else
		self.can_qinghua = true
	end

	self.item_cell:SetData({item_id = self.stuff_data.item_id, count = 1, is_bind = 0})
end


function QianghuaView:FlushMaxStrength()
	local max_level = QianghuaData.Instance:GetMaxStrengthLevel()
	local all_strength_level = QianghuaData.Instance:GetAllStrengthLevelIgnoreEquip()
	if all_strength_level >= max_level * 10 then 
		self.node_t_list.btn_qianghua.node:setVisible(false)
		self.node_t_list["btn_auto_qianghua"].node:setVisible(false)
		self.node_t_list["img_gold"].node:setVisible(false)
		self.node_t_list["lbl_qh_stone"].node:setVisible(false)
		self.node_t_list["lbl_qh_stone"].node:setVisible(false)
		self.node_t_list["rich_qh_stone_2"].node:setVisible(false)
		self.item_cell:GetView():setVisible(false)

		self.node_t_list["img_max_lv"].node:setVisible(true)
		self.node_t_list["img_max_lv2"].node:setVisible(true)
	else
		self.node_t_list.btn_qianghua.node:setVisible(true)
		self.node_t_list["btn_auto_qianghua"].node:setVisible(true)
		self.node_t_list["img_gold"].node:setVisible(true)
		self.node_t_list["rich_qh_stone_2"].node:setVisible(true)
		self.item_cell:GetView():setVisible(true)

		self.node_t_list["img_max_lv"].node:setVisible(false)
		self.node_t_list["img_max_lv2"].node:setVisible(false)
	end
end

function QianghuaView:FlushSelecSlot()
	for k,v in pairs(self.qianghua_cells) do
		if k == self.strengthen_slot then
			v:SetSelect(true)
			local data = v:GetData()
			self.node_t_list["lbl_qh_level"].node:setString("+" .. data.strengthen_level)
		else
			v:SetSelect(false)
		end
	end
end

function QianghuaView:FlushEquipData()
	local can_auto_qianghua = false -- 可自动强化
	for k,v in pairs(self.qianghua_cells) do
		local strengthen_info = QianghuaData.Instance:GetOneStrengthList(k)
		v:SetData(strengthen_info)

		if strengthen_info then
			local consume_cfg = QianghuaData.Instance:GetStrengthenConsume(k, strengthen_info.strengthen_level and (strengthen_info.strengthen_level + 1))
			if consume_cfg and consume_cfg[1] then
				local stuff_id, stuff_count = consume_cfg[1].id, consume_cfg[1].count
				self.consume_item = stuff_id
				local has_count = BagData.Instance:GetItemNumInBagById(stuff_id)

				local consume_type, consume_count = consume_cfg[2].type, consume_cfg[2].count
				local has_count_2 = RoleData.Instance:GetMainMoneyByType(consume_type)

				local vis = has_count >= stuff_count and has_count_2 >= consume_count
				v:GetView():UpdateReimd(vis)
				can_auto_qianghua = can_auto_qianghua or vis
			else
				v:GetView():UpdateReimd(false)
			end
		end
	end

	self.node_t_list["btn_auto_qianghua"].remind_eff:setVisible(can_auto_qianghua)
end

function QianghuaView:FlusQianghuaData()
	self:FlushEquipData()
	self:FlushSelecSlot()
	self:FlushStrengthData()
	self:FlushAttrText()
	self:FlushMaxStrength()
end

function QianghuaView:SetShowPlayEff(eff_id, x, y)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.node_t_list.layout_qianghua.node:addChild(self.play_eff, 999)
	end
	self.play_eff:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

function QianghuaView:OnUpSucced()
	self:SetShowPlayEff(1121, 290, 250)	
end

function QianghuaView:FlushAttrText()
	local strengthen_info = QianghuaData.Instance:GetOneStrengthList(self.strengthen_slot)
	local cur_attr = QianghuaData.Instance.GetStrengthenAttrCfg(self.strengthen_slot, strengthen_info.strengthen_level)
	local n_attr_data = QianghuaData.Instance.GetStrengthenAttrCfg(self.strengthen_slot, strengthen_info.strengthen_level + 1)
	local next_attr = {{type_str = Language.Common.MaxLv,},}
	if n_attr_data then
		next_attr = RoleData.FormatRoleAttrStr(n_attr_data)
	end
	
	self.cur_strength_attr:SetDataList(RoleData.FormatRoleAttrStr(cur_attr))
	self.next_strength_attr:SetDataList(next_attr)
end

function QianghuaView:IntoQhLevelShow()
	local count = QianghuaData.max_level
	local img_width = 24 -- 图标的宽
	local path = ResPath.GetCommon("star")
	local parent = self.node_t_list["layout_qianghua"].node
	local x, y = self.node_t_list["bg_1"].node:getPosition()
	local x_origin = x - ((count - 1) * img_width) / 2 -- 图标起点
	local img_y = y

	self.level_show_list = self.level_show_list or {}
	local list = self.level_show_list
	for i = 1, count do
		local img_x = x_origin + (i - 1) * img_width
		list[i] = XUI.CreateImageView(img_x, img_y, path, true)
		list[i]:setGrey(true)
		parent:addChild(list[i], 99)
	end
end

function QianghuaView:FlushQhLevelShow()
	local strengthen_info = QianghuaData.Instance:GetOneStrengthList(self.strengthen_slot)
	local lv = strengthen_info.strengthen_level
	local index, count = QianghuaData.GetQinghuaLvShowIndex(lv)

	local list = self.level_show_list
	for i,v in ipairs(list) do
		list[i]:setGrey(count < i)
	end
end

function QianghuaView:OnSelectQianghuaCell(cell)
	if nil == cell or nil == cell:GetData() then return end
	self.strengthen_slot = cell:GetIndex()
	self.node_t_list["img_equipment_bg"].node:loadTexture(ResPath.GetEquipment("equipment_img_" .. (self.strengthen_slot + 1)))
	self:FlusQianghuaData()
end

function QianghuaView:OnClickQhHandler()
	if self.can_qianghua then 
		local real_slot = self.strengthen_slot
		local vis = self.node_t_list["img_checkbox_hook"].node:isVisible()
		local index = vis and 1 or 0
		QianghuaCtrl.Instance:SendEquipStrengthen(real_slot or 0, index)
	else
		self:OpenTip()
	end
end

function QianghuaView:OnClickAtuoQhHandler()
	self.qianghua_times = 0 -- 已强化次数 用于屏蔽回调

	-- 根据定义的顺序升级
	local order = QianghuaData.Order

	local consumes_list = {} -- 物品消耗记录
	local virtual_consumes_list = {} -- 虚拟物品消耗记录

	-- 获取强化等级列表 qianghua_lv_list 和 最小强化等级 min_lv
	local qianghua_lv_list = {}
	local min_lv = 9999
	for equip_slot, cell in pairs(self.qianghua_cells) do
		local strengthen_info = cell:GetData()
		local qianghua_lv = strengthen_info.strengthen_level or MAX_STRENGTHEN_LEVEL
		qianghua_lv_list[qianghua_lv] = qianghua_lv_list[qianghua_lv] or {}
		qianghua_lv_list[qianghua_lv][equip_slot] = true
		min_lv = qianghua_lv < min_lv and qianghua_lv or min_lv 
	end

	local need_upgrade_list = {} -- 需要升级的槽位列表
	local can_keep_up = true -- 可以继续升级
	for qianghua_lv = min_lv, MAX_STRENGTHEN_LEVEL - 1 do
		local cur_lv_list = qianghua_lv_list[qianghua_lv] or {}

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

				--------------------升级逻辑--------------------

				----------可升级判断----------
				local consumes = QianghuaData.Instance:GetStrengthenConsume(equip_slot, qianghua_lv+1)
				local can_upgrade = BagData.ContinueCheckConsumesCount(consumes, consumes_list, virtual_consumes_list)
				----------可升级判断end----------

				if can_upgrade then
					local real_slot = equip_slot
					local vis = self.node_t_list["img_checkbox_hook"].node:isVisible()
					local index = vis and 1 or 0
					QianghuaCtrl.Instance:SendEquipStrengthen(real_slot, index) -- 请求强化
					
					-- 记录已消耗数量,避免消耗不足还进行请求
					BagData.ContinueRecordConsumesCount(consumes, consumes_list, virtual_consumes_list)
					
					self.qianghua_times = self.qianghua_times + 1
				else
					can_keep_up = false
					break
				end
				--------------------升级逻辑end--------------------

			end -- need_up 需要升级
		end -- order

		-- "不能继续升级时"时,停止判断
		if not can_keep_up then
			break
		end
	end

	-- 未进行升级时,弹出强化石购买提示
	if nil == next(consumes_list) and nil == next(virtual_consumes_list) then
		self:OpenTip()
	end
end

-- 打开快速购买提醒
function QianghuaView:OpenTip()
	self.stuff_data = self.stuff_data or {}
	local item_id = self.stuff_data.item_id or 0
	local num = self.stuff_data.num and self.stuff_data.num > 0 and self.stuff_data.num or 1
	TipCtrl.Instance:OpenGetNewStuffTip(item_id, num)
end

function QianghuaView:OnClickShowAttr()
	EquipmentCtrl.Instance:OpenSuitAttr(1)
end

function QianghuaView:OnClickOnekeyStrengthen()
	-- if self.is_bullet_window then
	-- 	self:OnClickObtainMaterial()
	-- else
		QianghuaCtrl.SendOneKeyStrengthen()
	-- end
end

function QianghuaView:OnClickObtainMaterial()
	TipCtrl.Instance:OpenBuyTip(EquipmentData.Instance:GetAdvStuffWayConfig()[EquipmentData.TabIndex.equipment_qianghua][1])
end

-- 点击复选框
function QianghuaView:OnCheckBox()
	local vis = self.node_t_list["img_checkbox_hook"].node:isVisible()
	self.node_t_list["img_checkbox_hook"].node:setVisible(not vis)

	self:FlushConsumes()
end

----------------------------------------------------------------------------------------------------
--强化item
----------------------------------------------------------------------------------------------------
QianghuaView.QianghuaRender = BaseClass(BaseRender)
local QianghuaRender = QianghuaView.QianghuaRender

function QianghuaRender:__init()
end

function QianghuaRender:__delete()
end

function QianghuaRender:CreateChild()
	BaseRender.CreateChild(self)
end

function QianghuaRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.lbl_qh_level.node:setString("+" .. self.data.strengthen_level)
	self.node_tree.lbl_qh_level.node:setColor(COLOR3B.GREEN)

	self.node_tree.img_equipment_bg.node:loadTexture(ResPath.GetEquipment("equipment_img_" .. self.index + 1))
end

function QianghuaRender:CreateSelectEffect()
	local size = self.node_tree["img_cell"].node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2,  size.height / 2 + 24, size.width + 10, size.height + 10, ResPath.GetCommon("img9_286"), true, cc.rect(8, 9, 13, 11))
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 99)
end


-- 属性文本
QianghuaView.AttrTextRender = BaseClass(BaseRender)
local AttrTextRender = QianghuaView.AttrTextRender
function AttrTextRender:__init()
	
end

function AttrTextRender:__delete()

end

function AttrTextRender:CreateChild()
	BaseRender.CreateChild(self)
end

function AttrTextRender:OnFlush()
	if nil == self.data then 
		self.node_tree.lbl_attr_txt.node:setString("")
		return 
	end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str .. "：")
	self.node_tree.lbl_attr_txt.node:setString(self.data.value_str)
end

function AttrTextRender:CreateSelectEffect()
end

return QianghuaView