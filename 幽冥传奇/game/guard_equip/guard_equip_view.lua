------------------------------------------------------------
-- 守护神装 配置:GuardGodEquipConfig
------------------------------------------------------------

GuardEquipView = GuardEquipView or BaseClass(BaseView)

function GuardEquipView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("word_guard_equip")
	self.texture_path_list[1] = 'res/xui/guard_equip.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"guard_equip_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.page_index = 1

end

function GuardEquipView:__delete()
end

function GuardEquipView:ReleaseCallBack()
	self.guard_shop_remind = nil
end

function GuardEquipView:LoadCallBack(index, loaded_times)
	self:CreateSlotType()
	self:CreatePower()
	self:CreateAttr()
	self:InitTextBtn()

	XUI.AddRemingTip(self.node_t_list["btn_left"].node)
	XUI.AddRemingTip(self.node_t_list["btn_right"].node)

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_back"].node, BindTool.Bind(self.OnBack, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_left"].node, BindTool.Bind(self.OnLeft, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_right"].node, BindTool.Bind(self.OnRight, self), true)
	
	-- 数据监听
	EventProxy.New(GuardEquipData.Instance, self):AddEventListener(GuardEquipData.GUARD_EQUIP_CHANGE, BindTool.Bind(self.OnGuardEquipChange, self))
end

--显示索引回调
function GuardEquipView:ShowIndexCallBack(index)
	self:Flush()
	self:FlushGuardShopRemind()
end

function GuardEquipView:OnFlush()
	self:FlushSlotType()
	self:FlushPageBtn()
end

----------视图函数----------

-- 创建守护神装 槽位类型翻页
function GuardEquipView:CreateSlotType()
	local ph = self.ph_list["ph_guard_equip_list"]
	local ph_item = ph
	local parent = self.node_t_list["layout_guard_equip"].node
	local base_grid = BaseGrid.New()
	base_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	self.slot_type = base_grid
	self:AddObj("slot_type")

	local table ={w = ph.w,h = ph.h, cell_count = 1, col = 1, row = 1, itemRender = self.GuardEquipItem, ui_config = ph_item}
	self.guard_type_item = base_grid:CreateCells(table)
	self.guard_type_item:setPosition(ph.x, ph.y)
	parent:addChild(self.guard_type_item, 2)
end

function GuardEquipView:FlushSlotType()
	self.data_list = GuardEquipData.Instance:GetOpenShowList() -- 从0开始
	self.max_page = #self.data_list + 1
	self.slot_type:ExtendGrid(self.max_page)
	self.slot_type:SetDataList(self.data_list)

	-- self.slot_type:ChangeToPage(1)
	self.node_t_list["btn_right"].node:setVisible(self.page_index ~= self.max_page)
	self.node_t_list["btn_left"].node:setVisible(self.page_index ~= 1)

	self:FlushPower()
	self:FlushAttrText()
end

function GuardEquipView:CreatePower()
	local ph = self.ph_list["ph_power"]
	local parent = self.node_t_list["layout_guard_equip"].node
	self.power_view = FightPowerView.New(ph.x, ph.y, parent, 20, true)
	self:AddObj("power_view")
	self.power_view:SetScale(1)
end

-- 刷新战力值视图
function GuardEquipView:FlushPower()
	local slot_list = self.data_list[self.page_index - 1] or {}
	local score = 0
	for i,v in ipairs(slot_list) do
		if next(v) then
			score = score + ItemData.Instance:GetItemScoreByData(v)
		end
	end

	self.power_view:SetNumber(score)
end

function GuardEquipView:CreateAttr()
	local ph = self.ph_list["ph_attr_list"]
	self.attr_list = ListView.New()
	self:AddObj("attr_list")
	self.attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.AttrTextRender, nil, nil, self.ph_list.ph_attr_txt_item)
	self.attr_list:SetItemsInterval(2)
	self.attr_list:SetMargin(2)
	self.node_t_list["layout_guard_equip"].node:addChild(self.attr_list:GetView(), 999)
end

function GuardEquipView:FlushAttrText()
	local slot_list = self.data_list[self.page_index - 1] or {}
	local attrs = {}
	for i,v in ipairs(slot_list) do
		if next(v) then
			local item_data = v
			local cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
			attrs = CommonDataManager.AddAttr(attrs, ItemData.Instance.GetStaitcAttrs(cfg))
		end
	end
	-- 排序
	table.sort(attrs, function(a, b)
		return a.type < b.type
	end)

	self.attr_list:SetDataList(RoleData.FormatRoleAttrStr(attrs))
	self.node_t_list["lbl_attr_tip"].node:setVisible(nil  == next(attrs))
end

function GuardEquipView:InitTextBtn()
	local ph
	local text_btn
	local parent = self.node_t_list["layout_open_guard_shop"].node
	ph = self.ph_list["ph_text_btn_1"]
	text_btn = RichTextUtil.CreateLinkText(Language.Tip.ButtonLabel[17], 20, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	parent:addChild(text_btn, 99)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self), true)
	self.open_guard_shop = text_btn
end

function GuardEquipView:FlushPageBtn()
	local btn_left_remind = false
	local btn_right_remind = false
	local btn_left = self.node_t_list["btn_left"].node
	local btn_right = self.node_t_list["btn_right"].node

	local remind_list = GuardEquipData.Instance:GetRemindIndexList()
	local previous_page = self.page_index - 1 
	previous_page = previous_page >= 1 and previous_page or -1
	for i = 1, previous_page do
		if nil ~= remind_list[i] then
			btn_left_remind = true
			break
		end
	end

	local next_page = self.page_index + 1
	for i = next_page, self.max_page do
		if nil ~= remind_list[i] then
			btn_right_remind = true
			break
		end
	end

	btn_left.remind_img:setVisible(btn_left_remind)
	btn_right.remind_img:setVisible(btn_right_remind)

	btn_left:setVisible(self.page_index ~= 1)
	btn_right:setVisible(self.page_index ~= self.max_page)
end

function GuardEquipView:FlushGuardShopRemind()
	local index = RemindManager.Instance:GetRemind(RemindName.GuardShopCanExchange)
	if index > 0 then
		UiInstanceMgr.AddRectEffect({node = self.node_t_list["layout_open_guard_shop"].node, init_size_scale = 1.3, act_size_scale = 1.6, offset_w = -75, offset_h = 3, color = COLOR3B.GREEN})
	else
		UiInstanceMgr.DelRectEffect(self.node_t_list["layout_open_guard_shop"].node)
	end
end

----------end----------
-- 返回按钮
function GuardEquipView:OnBack()
	ViewManager.Instance:OpenViewByDef(ViewDef.Role.RoleInfoList)
	self:Close()
end

function GuardEquipView:OnLeft()
	if self.slot_type:IsChangePage() then return end -- 正在翻面时跳出
	self.slot_type:ChangeToPage(self.page_index - 1)
end

function GuardEquipView:OnRight()
	if self.slot_type:IsChangePage() then return end -- 正在翻面时跳出
	self.slot_type:ChangeToPage(self.page_index + 1)
end

function GuardEquipView:OnPageChangeCallBack(grid_render, page_index, prve_page_index)
	self.node_t_list["lbl_attr_name"].node:setString(Language.GuardEquip.AttrName[page_index])
	self.page_index = page_index

	self:FlushAttrText()
	self:FlushPower()
	self:FlushPageBtn()
end

function GuardEquipView:OnTextBtn(index)
	ViewManager.Instance:OpenViewByDef(ViewDef.GuardShop)
	ViewManager.Instance:CloseViewByDef(ViewDef.Role)
end

function GuardEquipView:OnGuardEquipChange(slot_type, slot, equip)
	self:Flush()
end

function GuardEquipView:OnBagItemChange()
	self:FlushGuardShopRemind()
end
--------------------

----------------------------------------
-- 守护神装渲染
----------------------------------------
GuardEquipView.GuardEquipItem = BaseClass(BaseRender)
local GuardEquipItem = GuardEquipView.GuardEquipItem
function GuardEquipItem:__init()
	--self.item_cell = nil
end

function GuardEquipItem:__delete()
	if self.slot_list then
		for i,v in ipairs(self.slot_list) do
			v:DeleteMe()
		end
		self.slot_list = nil
	end

end

-- SlotItem坐标
local pos_list = {
	{{115, 405}, {80, 285}, {140, 110}, {195,230}, {320, 175}, {395, 75}, {415, 245},},
	{{25, 82}, {75, 212}, {170, 355}, {225, 255}, {250, 135}, {375, 225}, {335, 385},},
	{{110, 355}, {80, 230}, {85,80}, {165, 165}, {255, 105}, {270, 260}, {385, 120},},
	{{132, 395}, {155, 270}, {225, 170}, {240, 35}, {330, 115}, {350, 255}, {350, 390},},
	{{115, 250}, {160, 415}, {170, 130}, {200, 10}, {225, 315}, {310, 100}, {340, 210},},
	{{110, 255}, {160, 390}, {215, 50}, {260, 255}, {285, 395}, {300, 165}, {400, 230},},
}

local eff_pos_list = {{265, 269}, {288, 284}, {268, 274}, {295, 290},}

function GuardEquipItem:CreateChild()
	BaseRender.CreateChild(self)

	local index = self.index + 1

	local path = ResPath.GetBigPainting("guard_equip_bg_" .. index, true)
	self.node_tree["img_bg"].node:loadTexture(path)
	local path = ResPath.GetGuardEquip("guard_equip_type_" .. index)
	self.node_tree["img_type_name"].node:loadTexture(path)

	local effect_list = GuardGodEquipConfig and GuardGodEquipConfig.effect_id or {}
	local effect_id = effect_list and effect_list[self.index + 1] or 0
	local size = self.view:getContentSize()
	local eff = AnimateSprite:create()
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
	eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	local pos = eff_pos_list[self.index + 1] or {268.5, 269.5}
	local x, y = pos[1], pos[2]
	eff:setPosition(x, y)
	self.view:addChild(eff, 1)
end

function GuardEquipItem:OnFlush()
	if nil == self.data then return end
	local index = self.index + 1

	if nil == self.slot_list then
		-- 创建槽位
		self.slot_list = {}
		local cfg = GuardGodEquipConfig or {}
		local max_slot = cfg.max_slot or 0
		for i = 1, max_slot do
			local pos = pos_list[index] and pos_list[index][i] or pos_list[1][i]
			local slot = self.SlotItem.New(index)
			slot:SetUiConfig(self.ph_list["ph_slot_item"], true)
			slot:SetPosition(pos[1], pos[2])
			slot:SetIndex(i)
			slot:AddClickEventListener(BindTool.Bind(self.SlotCallback, self, i))
			slot:SetData(self.data[i])
			self.view:addChild(slot:GetView(), 99)
			self.slot_list[i] = slot
		end
	else
		for i,v in ipairs(self.slot_list) do
			v:SetData(self.data[i] or {})
		end
	end

end

function GuardEquipItem:SlotCallback(slot)
	local index = self.index + 1
	local remind_list = GuardEquipData.Instance:GetRemindIndexList()
	local remind_index = remind_list[index] and remind_list[index][slot]
	if remind_index then
		local item_id = remind_index
		local series = BagData.Instance:GetItemSeriesInBagById(item_id)
		GuardEquipCtrl.SendWearGuardEquipReq(series)
	else
		local slot_data = self.slot_list[slot]:GetData()
		if slot_data.item_id then
			TipCtrl.Instance:OpenItem(slot_data, EquipTip.FROM_NORMAL)
		end
	end
end

function GuardEquipItem:FlushSlot(slot, equip)
	local slot_item = self.slot_list[slot]
	if slot_item then
		slot_item:SetData(equip)
	end
end

function GuardEquipItem:CreateSelectEffect()
	return
end

function GuardEquipItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end

----------------------------------------
-- 守护神装槽位渲染
----------------------------------------
GuardEquipItem.SlotItem = BaseClass(BaseRender)
local SlotItem = GuardEquipItem.SlotItem
function SlotItem:__init(type)
	self.type = type
	self.img_equip = nil
end

function SlotItem:__delete()
	if self.order then
		self.order:DeleteMe()
		self.order = nil
	end

	self.img_equip = nil
end

function SlotItem:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list["ph_order"]
	local path = ResPath.GetCommon("num_2_")
	local parent = parent
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
	number_bar:SetSpace(-8)
	number_bar:SetGravity(NumberBarGravity.Center)
	self.view:addChild(number_bar:GetView(), 99)
	self.order = number_bar

	self.node_tree["img_order"].node:setAnchorPoint(0, 0)

	XUI.AddRemingTip(self.view, BindTool.Bind(self.FlushRemind, self), nil, 75, 90)
end

function SlotItem:OnFlush()
	if nil == self.data then return end
	local phase = self.data.quality or 0 -- 未装备时,显示0
	self.order:SetNumber(phase)
	local is_grey = phase == 0
	XUI.SetLayoutImgsGrey(self.view, is_grey)
	self.order:SetGrey(is_grey)

	if self.data.item_id then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		local icon_id = tonumber(item_cfg.icon)
		local path = ResPath.GetItem(icon_id)
		if self.img_equip then
			self.img_equip:loadTexture(path)
		else
			local x, y = self.node_tree["img_cell"].node:getPosition()
			local z = self.node_tree["img_cell"].node:getLocalZOrder()
			-- self.node_tree["img_cell"].node:loadTexture(path)
			self.img_equip = XUI.CreateImageView(x, y, path, XUI.IS_PLIST)
			self.img_equip:setScale(0.85)
			self.view:addChild(self.img_equip, z)
		end

		self.node_tree["img_cell"].node:setGrey(true)
	end

	----------------------------------------
	-- 调整 美术字"阶" 的坐标
	----------------------------------------
	local num_size = self.order:GetNumberBar():getContentSize()
	local view_size = self.order:GetView():getContentSize()
	local order_x, order_y = self.order:GetView():getPosition()
	local space = 2 -- 美术字"阶"和 order 的间隔
	local order_low_right_x = order_x + num_size.width / 2 + view_size.width / 2 -- order的右下角x坐标
	local x = order_low_right_x + space
	self.node_tree["img_order"].node:setPosition(x, order_y)
	----------------------------------------

	local cfg = GuardGodEquipConfig or {}
	local max_slot = cfg.max_slot or 7
	local slot_index = (self.type - 1) * max_slot + self.index
	self.node_tree["lbl_slot_name"].node:setString(Language.GuardEquip.SlotName[slot_index] or "")

	self.view:UpdateReimd()
	self.view.remind_img:setGrey(false)
end

function SlotItem:FlushRemind()
	local remind_list = GuardEquipData.Instance:GetRemindIndexList()
	local remind_index = remind_list[self.type] and remind_list[self.type][self.index] 
	local vis = nil ~= remind_index
	return vis
end

function SlotItem:CreateSelectEffect()
	return
end


-- 属性文本
GuardEquipView.AttrTextRender = BaseClass(BaseRender)
local AttrTextRender = GuardEquipView.AttrTextRender
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
