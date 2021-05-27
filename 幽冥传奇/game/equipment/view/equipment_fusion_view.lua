------------------------------------------------------------
-- 锻造-融合 配置:EquipMeltCfg
------------------------------------------------------------

-- 固定的刷新路径 TabbarSelectCallBack - FlushEquipList(equip_type有改变) - EquipSelectCallBack - FlushCellList(self.select_index有改变)

local EquipmentFusionView = BaseClass(SubView)

local equip_type = nil
local show_type = 1

function EquipmentFusionView:__init()
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self.config_tab = {
		{"equipment_ui_cfg", 4, {0}},
	}
	self.cell_list = {}
	self.fusion_data = nil
	self.effect = nil
end

function EquipmentFusionView:__delete()
end

function EquipmentFusionView:LoadCallBack(index, loaded_times)
	XUI.RichTextSetCenter(self.node_t_list["rich_consume"].node)

	self:InitTextBtn()

	self:CreateTabbar()
	self:CreateEquipList()
	self:CreateCellList()

	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self))
	XUI.AddClickEventListener(self.node_t_list["btn_fusion_tip"].node, BindTool.Bind(self.OnTip, self))
	XUI.AddClickEventListener(self.node_t_list["btn_suit"].node, BindTool.Bind(self.OnSuit, self))

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_COIN, BindTool.Bind(self.OnMoneyChange, self))

	self:BindGlobalEvent(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.OnRemindChanged, self))
end

function EquipmentFusionView:ReleaseCallBack()
	equip_type = nil
	show_type = 1
	self.select_index = nil
	self.fusion_data = nil
	self.effect = nil

end

function EquipmentFusionView:OpenCallBack()
end

function EquipmentFusionView:CloseCallBack()
	self.fusion_data = nil
	self.select_equip = nil
end

function EquipmentFusionView:ShowIndexCallBack()
	self:Flush()
end

function EquipmentFusionView:OnFlush(param_t)
	local _type = 1
	local _type2 = equip_type or 1
	self:TabbarSelectCallBack(_type, _type2)

	self:FlushTabbarRemind()
end

----------视图函数----------

function EquipmentFusionView:CreateTabbar()
	local name_list = {}
	local cfg = EquipMeltCfg or {}
	local tabbar_title = cfg.tabbar_title and cfg.tabbar_title[1] or {}
	for i,v in ipairs(tabbar_title) do
		local name = v or ""
		table.insert(name_list, name)
	end
	local parent = self.node_t_list["layout_fusion"].node
	local ph = self.ph_list["ph_tabbar"] or {x = 0, y = 0, w = 10, h = 10}
	local call_back = BindTool.Bind(self.TabbarSelectCallBack, self, 1)

	local tabbar = Tabbar.New()
	tabbar = Tabbar.New()
	tabbar:CreateWithNameList(parent, ph.x, ph.y, call_back, name_list, false, ResPath.GetCommon("toggle_121"), 25, false)
	self.tabbar = tabbar
	self:AddObj("tabbar")

	local name_list = {}
	local cfg = EquipMeltCfg or {}
	local tabbar_title = cfg.tabbar_title and cfg.tabbar_title[2] or {}
	for i,v in ipairs(tabbar_title) do
		local name = v or ""
		table.insert(name_list, name)
	end
	local parent = self.node_t_list["layout_fusion"].node
	local ph = self.ph_list["ph_tabbar_2"] or {x = 0, y = 0, w = 10, h = 10}
	local call_back = BindTool.Bind(self.TabbarSelectCallBack, self, 2)
	local tabbar = Tabbar.New()
	tabbar = Tabbar.New()
	tabbar:CreateWithNameList(parent, ph.x, ph.y, call_back, name_list, false, ResPath.GetCommon("toggle_121"), 25, false)
	self.tabbar2 = tabbar
	self:AddObj("tabbar2")
end

function EquipmentFusionView:CreateEquipList()
	local ph = self.ph_list["ph_equip_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE,}
	local parent = self.node_t_list["layout_fusion"].node
	local item_render = self.EquipRender
	local line_dis = ph_item.w + 16
	local direction = ScrollDir.Vertical -- 滑动方向-横向 -- Vertical=1：竖向 Horizontal=2：横向：Both=3：横竖都可以
	
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 2, line_dis, item_render, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	grid_scroll:SetSelectCallBack(BindTool.Bind(self.EquipSelectCallBack, self))
	self.equip_list = grid_scroll
	self:AddObj("equip_list")
end

function EquipmentFusionView:CreateCellList()
	-- 1-当前装备  2-消耗一  3-消耗二  4-合成后装备
	local parent = self.node_t_list["layout_fusion"].node
	local ph_list = self.ph_list or {}
	local index = 1
	local list = {}
	while(self.ph_list["ph_cell_" .. index])
	do
		local ph = self.ph_list["ph_cell_" .. index] or {x = 0, y = 0, w = 10, h = 10}
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		parent:addChild(cell:GetView(), 99)
		table.insert(list, cell)
		index = index + 1
	end

	self.cell_list = list
	self:AddObj("cell_list")
end

function EquipmentFusionView:InitTextBtn()
	local ph, text_btn
	local parent = self.node_t_list["layout_fusion"].node

	ph = self.ph_list["ph_text_btn"]
	text_btn = RichTextUtil.CreateLinkText("融合分解", 20, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	parent:addChild(text_btn, 99)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnRecycle, self), true)
end

function EquipmentFusionView:FlushEquipList()
	local show_list = {}
	if show_type == 1 then
		local equip_list = EquipData.Instance:GetEquipData()
		if equip_type == 1 then
			local meltcfg = EquipMeltCfg and EquipMeltCfg.meltcfg or {}
			local circle_cfg = meltcfg[1] and meltcfg[1][1] and meltcfg[1][1].circleLimit or 0
			local equip_slot_list = EquipmentData.Equip or {}
			for index = 0, EquipData.EquipSlot.itBaseEquipMaxPos do
				local slot = equip_slot_list[index + 1] and equip_slot_list[index + 1].equip_slot or 0
				local equip = {}
				if equip_list[slot] then
					local item = equip_list[slot]
					local item_id = item.item_id or 0
					local limit_level, circle = ItemData.GetItemLevel(item_id) -- 装备的等级和转数
					if circle >= circle_cfg then
						equip = item
					end
				end
				table.insert(show_list, equip)
			end
		elseif equip_type == 2 then
			for k, equip in pairs(equip_list) do
				local item_id = equip.item_id
				if ItemData.IsReXueEquip(item_id) then --是否为热血装备
					table.insert(show_list, equip)
				end
			end

			for k, equip in pairs(equip_list) do
				local item_id = equip.item_id
				if ItemData.IsZhanShenEquip(item_id) then --是否战神装备
					table.insert(show_list, equip)
				end
			end

			for k, equip in pairs(equip_list) do
				local item_id = equip.item_id
				if ItemData.IsShaShenEquip(item_id) then --是否是杀神装备
					table.insert(show_list, equip)
				end
			end
		end
	else
		if equip_type == 1 then
			show_list, _ = EquipmentFusionData.Instance:GetAllBagEquip()
			table.sort(show_list, function(a, b)
				if a.type == b.type then
					return a.fusion_lv > b.fusion_lv
				else
					return a.type < b.type
				end
			end)
		elseif equip_type == 2 then
			_, show_list = EquipmentFusionData.Instance:GetAllBagEquip()
			table.sort(show_list, function(a, b)
				local type_1 = EquipmentFusionData.GetEquipType(a.item_id)
				local type_2 = EquipmentFusionData.GetEquipType(b.item_id)
				if type_1 == type_2 then
					return a.fusion_lv > b.fusion_lv
				elseif a.fusion_lv > b.fusion_lv then
					return type_1 < type_2
				end
			end)
		end
	end

	local count = 10 - #show_list -- 至少显示10个格子
	for i = 1, count do
		table.insert(show_list, {})
	end

	self.equip_list:SetDataList(show_list)
	self.equip_list:SelectItemByIndex(self.select_index or 1)
end

function EquipmentFusionView:FlushCellList()
	if nil == self.select_equip then
		self.select_index = self.select_index or 1
		local items = self.equip_list:GetItems()
		if items[self.select_index] then
			self.select_equip = items[self.select_index]:GetData()
		end
	end

	local cur_fusion_lv = EquipmentFusionData.GetFusionLv(self.select_equip)
	local fusion_type = ItemData.GetIsBasisEquip(item_id) and 1 or 2
	local cfg = EquipMeltCfg or {}
	local meltcfg = cfg.meltcfg and cfg.meltcfg[fusion_type] or {}
	local max_fusion_lv = #meltcfg
	local eff_vis = false
	
	local text = ""
	if cur_fusion_lv < max_fusion_lv and self.select_equip and next(self.select_equip) then
		local item_id = self.select_equip.item_id or 0
		local can_fusion_list = {}
		local bag_list = BagData.Instance:GetDataListSeries()
		local cur_equip_list = BagData.Instance:GetSeriesByItemId(item_id)
		if next(cur_equip_list) then -- 背包中有这个装备时,才判断融合等级是否相同
			for series, _ in pairs(cur_equip_list) do
				local item = BagData.Instance:GetOneItemBySeries(series)
				if item and item.item_id == item_id then
					local fusion_lv = EquipmentFusionData.GetFusionLv(item)
					if fusion_lv == cur_fusion_lv and (show_type ~= 2 or series ~= self.select_equip.series) then
						table.insert(can_fusion_list, item)
					end
				end
			end
		end

		local fusion_equip_num = #can_fusion_list
		local color = fusion_equip_num > 0 and COLOR3B.GREEN or COLOR3B.RED
		self.node_t_list["lbl_consume"].node:setString(fusion_equip_num .. "/1")
		self.node_t_list["lbl_consume"].node:setColor(color)

		local consumes = meltcfg[cur_fusion_lv + 1] and meltcfg[cur_fusion_lv + 1].consumes or {}
		local cur_consume = consumes[1] or {}
		local consume_num_cfg = cur_consume.count or 0
		local consume_num = BagData.GetConsumesCount(cur_consume.id, cur_consume.type)
		local path = ResPath.GetCommon("bind_gold")
		local color = consume_num >= consume_num_cfg and COLORSTR.GREEN or COLORSTR.RED
		text = string.format("{image;%s}{color;%s;%s}/%s", path, color, CommonDataManager.ConverMoney(consume_num), CommonDataManager.ConverMoney(consume_num_cfg))

		if self.cell_list[1] then
			self.cell_list[1]:SetData(self.select_equip)
		end

		if self.cell_list[2] then
			self.cell_list[2]:SetData(self.select_equip)
		end

		if self.cell_list[3] then
			self.cell_list[3]:SetOpen(consumes[2] ~= nil)
			self.cell_list[3]:SetData(consumes[2])
		end

		if self.cell_list[4] then
			local new_equip = TableCopy(self.select_equip)
			EquipmentFusionData.SetFusionLv(new_equip, math.min(cur_fusion_lv + 1, max_fusion_lv))
			self.cell_list[4]:SetData(new_equip)
		end

		self.can_fusion = (fusion_equip_num > 0) and (consume_num >= consume_num_cfg)
		self.node_t_list["btn_1"].node:setEnabled(self.can_fusion)

		self.series2 = can_fusion_list[1] and can_fusion_list[1].series
	else
		for i, cell in ipairs(self.cell_list) do
			cell:SetData()
		end
		self.node_t_list["lbl_consume"].node:setString("")
		self.node_t_list["btn_1"].node:setEnabled(false)
		self.can_fusion = false
		self.series2 = nil
	end

	local rich = self.node_t_list["rich_consume"].node
	RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.WHITE)
	rich:refreshView()

	local vis = cur_fusion_lv >= max_fusion_lv
	self.node_t_list["lbl_max_lv_tip"].node:setVisible(vis)
	self.node_t_list["btn_1"].node:setVisible(not vis)

	self.tabbar2:SetRemindByIndex(1, RemindManager.Instance:GetRemind(RemindName.EquipmentFusion) > 0)

	self:FlushSelectEffect(nil, self.can_fusion)
end


function EquipmentFusionView:FlushSelectEffect(effect_id, vis)
	local effect_id = effect_id or 10056
	local effect = self.effect
	local loops = COMMON_CONSTS.MAX_LOOPS -- 播放数量

	if vis and nil == self.effect then
		local parent = self.node_t_list["layout_fusion"].node
		local ph = self.ph_list["ph_cell_4"] or {x = 0, y = 0, w = 10, h = 10}
		local zorder = 98
		local frame_interval = nil -- 每帧间隔时间

		effect = RenderUnit.CreateEffect(effect_id, parent, zorder, frame_interval, loops, ph.x + 40, ph.y + 40)
	end

	if effect then
		effect:setVisible(vis)
		if vis then
			local path, name = ResPath.GetEffectUiAnimPath(effect_id)
			effect:setAnimate(path, name, loops, FrameTime.Effect, false)
		end
	end

	self.effect = effect
end

function EquipmentFusionView:PlayOnceEffect(effect_id)
	local effect_id = effect_id or 10057

	local parent = self.node_t_list["layout_fusion"].node
	local ph = self.ph_list["ph_cell_4"] or {x = 0, y = 0, w = 10, h = 10}
	local zorder = nil
	local remove_on_finished = true -- 完成时删除
	local callback = nil -- 回调
	local frame_interval = nil -- 每帧间隔时间

	RenderUnit.PlayEffectOnce(effect_id, parent, zorder, ph.x, ph.y, remove_on_finished, callback, frame_interval)
end

-- 检查融合是否成功
function EquipmentFusionView:CheckFusion()
	local need_play = false
	local fusion_data = self.fusion_data
	if fusion_data then
		local old_equip = fusion_data.equip
		if old_equip then
			if fusion_data.show_type == 1 then
				local equip_list = EquipData.Instance:GetEquipData()
				for slot, equip in pairs(equip_list) do
					if equip.series == old_equip.series then
						if equip.fusion_lv > old_equip.fusion_lv then
							need_play = true
						end
						break
					end
				end
			elseif fusion_data.show_type == 2 then	
				local equip = BagData.Instance:GetItemInBagBySeries(old_equip.series)
				if equip and equip.fusion_lv > old_equip.fusion_lv then
					need_play = true
				end
			end
		end
	end

	if need_play then
		self:PlayOnceEffect()
		self.fusion_data = nil
	end
end

----------视图函数end----------

function EquipmentFusionView:TabbarSelectCallBack(_type, _type2)
	if _type == 1 then
		if equip_type ~= _type2 then
			equip_type = _type2
			self.select_index = nil
			self:FlushEquipList()

			local path = ResPath.GetEquipment("btn_suit" .. equip_type)
			self.node_t_list["btn_suit"].node:loadTextures(path)
		end
	else
		if show_type ~= _type2 then
			show_type = _type2
			self.select_index = nil
			self:FlushEquipList()
		end
	end

	self.equip_list:JumpToTop()
end

function EquipmentFusionView:EquipSelectCallBack(equip)
	local index = equip:GetIndex()
	
	if self.select_index ~= index then
		self.select_index = index
		self.select_equip = equip:GetData()

		self:FlushCellList()
	end
end

function EquipmentFusionView:OnBtn()
	local series1 = self.select_equip and self.select_equip.series
	local series2 = self.series2
	local index = show_type or 1
	if self.fusion_data then
		SystemHint.Instance:FloatingTopRightText("融合中,请稍等..")
	else
		if series1 ~= nil and series2 ~= nil then
			self.fusion_data = {equip = self.select_equip, show_type = show_type}
			EquipmentFusionCtrl.SendEquipmentFusionReq(series1, series2, index)
		end
	end
end

-- "?"按钮点击回调
function EquipmentFusionView:OnTip()
	local language = Language or {}
	local desctip = Language.DescTip or {}
	local title = desctip.EquipmentFusionsTitle or ""
	local desc = desctip.EquipmentFusionsContent or ""

	DescTip.Instance:SetContent(desc, title)
end

function EquipmentFusionView:OnSuit()
	EquipmentCtrl.Instance:OpenSuitAttr((equip_type or 1) + 3)
end

function EquipmentFusionView:OnRecycle()
	ViewManager.Instance:OpenViewByDef(ViewDef.EquipmentFusionRecycle)
end

-- 背包物品改变
function EquipmentFusionView:OnBagItemChange(event)
	if self:IsOpen() then
		local need_flush = false
		local item_type_list = EquipmentFusionData.Instance:GetItemTypeList()
		for i, v in ipairs(event.GetChangeDataList()) do
			if v.change_type == ITEM_CHANGE_TYPE.LIST then
				need_flush = true
			else
				local item_type = v.data.type
				local item_id = v.data.item_id
				if item_type_list[1] and item_type_list[1][item_type] then
					need_flush = true
				elseif item_type_list[2] and item_type_list[2][item_type] then
					need_flush = true
				end
			end

			if need_flush then
				self.select_equip = nil
				self:FlushEquipList()
				self:FlushCellList()
				self:FlushTabbarRemind()
				self:CheckFusion()
				break
			end
		end
	end
end

-- 穿戴装备改变
function EquipmentFusionView:OnChangeOneEquip()
	if self:IsOpen() then
		if equip_type ~= 2 then
			self.select_equip = nil
			self:FlushEquipList()
			self:FlushCellList()
		end

		self:CheckFusion()
	end
end

-- 金钱改变
function EquipmentFusionView:OnMoneyChange()
	if self:IsOpen() then
		self:FlushEquipList()
		self:FlushCellList()
	end
end

function EquipmentFusionView:OnRemindChanged(remind_name, num)
	if remind_name == RemindName.EquipmentFusion then
		self.tabbar2:SetRemindByIndex(1, num > 0)
	end
end

function EquipmentFusionView:FlushTabbarRemind()
	local remind_num = RemindManager.Instance:GetRemind(RemindName.EquipmentFusion)

	local remind_num_list = {0, 0}
	if remind_num > 0 then
		local equip_list = EquipData.Instance:GetEquipData() or {}
		for slot, equip in pairs(equip_list) do
			local can_fusion = false
			local item_id = equip.item_id or 0

			-- 判断物品类型是否可融合
			local fusion_type = 0
			if remind_num_list[1] == 0 and ItemData.GetIsBasisEquip(item_id) then --是否为基础装备
				fusion_type = 1
				can_fusion = true
			elseif remind_num_list[2] == 0 and ItemData.IsReXueEquip(item_id) --是否为热血装备
				or ItemData.IsZhanShenEquip(item_id) --是否为战神装备
				or ItemData.IsShaShenEquip(item_id) --是否为杀神装备
			then
				fusion_type = 2
				can_fusion = true
			end

			local cur_fusion_lv = 0

			-- 判断第一个消耗是否足够
			if can_fusion then
				local cfg = EquipMeltCfg or {}
				local meltcfg = cfg.meltcfg and cfg.meltcfg[fusion_type] or {}
				cur_fusion_lv = EquipmentFusionData.GetFusionLv(equip)
				local cur_meltcfg = meltcfg[cur_fusion_lv + 1]
				if cur_meltcfg then
					local limit_level, zhuan = ItemData.GetItemLevel(item_id)
					can_fusion = fusion_type == 2 or zhuan >= cur_meltcfg.circleLimit
				else
					can_fusion = false
				end
				
				-- 基础装备需装备达到对应转数才可融合
				if can_fusion then
					local consumes = cur_meltcfg.consumes or {}
					local cur_consume = consumes[1] or {}
					local consume_num_cfg = cur_consume.count or 0
					local consume_num = BagData.GetConsumesCount(cur_consume.id, cur_consume.type)
					can_fusion = consume_num_cfg ~= 0 and consume_num >= consume_num_cfg
				end
			end

			-- 是否有融合等级相同的装备
			if can_fusion then
				can_fusion = false
				local can_fusion_list = {}
				local bag_list = BagData.Instance:GetDataListSeries()
				local cur_equip_list = BagData.Instance:GetSeriesByItemId(item_id)
				if next(cur_equip_list) then -- 背包中有这个装备时,才判断融合等级是否相同
					for series, _ in pairs(cur_equip_list) do
						local item = BagData.Instance:GetOneItemBySeries(series)
						local fusion_lv = EquipmentFusionData.GetFusionLv(item)
						if fusion_lv == cur_fusion_lv then
							can_fusion = true
							break
						end
					end
				end
			end

			if can_fusion then
				if ItemData.GetIsBasisEquip(item_id) then
					remind_num_list[1] = 1
				else
					remind_num_list[2] = 1
				end

				if remind_num_list[1] > 0 and remind_num_list[2] > 0 then
					break
				end
			end
		end

		for i, v in ipairs(remind_num_list) do
			self.tabbar:SetRemindByIndex(i, v > 0)
		end
	else
		self.tabbar:SetRemindByIndex(1, false)
		self.tabbar:SetRemindByIndex(2, false)
	end
end

----------------------------------------
-- 装备显示渲染
----------------------------------------
EquipmentFusionView.EquipRender = BaseClass(BaseRender)
local EquipRender = EquipmentFusionView.EquipRender
function EquipRender:__init()
	self.cell = nil
end

function EquipRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function EquipRender:CreateChild()
	BaseRender.CreateChild(self)
	local parent = self.view
	local ph = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local cell = BaseCell.New()
	-- cell:SetIsShowTips(false)
	cell:SetPosition(ph.x, ph.y)
	cell:GetView():setTouchEnabled(false)
	parent:addChild(cell:GetView(), 2)
	self.cell = cell

	local size = self.view:getContentSize()
	local x, y = size.width / 2, size.height / 2
	local path = ResPath.GetCommon("cell_116")
	self.bg = XUI.CreateImageView(x, y,  path)
	self.view:addChild(self.bg, 1)
end

function EquipRender:OnFlush()
	if nil == self.data then return end
	self.cell:SetData(self.data)
	self:FlushIcon()
	self:FlushRemind()
end

function EquipRender:FlushIcon()
	if self.index <= 10 and equip_type == 1 and show_type == 1 and nil == next(self.data) then
		self.cell:GetView():setVisible(false)
		self.bg:setVisible(true)
		if nil == self.icon then
			local size = self.view:getContentSize()
			local path = ResPath.GetEquipment("equipment_img_" .. self.index)
			self.icon = XUI.CreateImageView(size.width / 2, size.height / 2, path, XUI.IS_PLIST)
			self.view:addChild(self.icon, 3)
		end

		if self.icon then
			self.icon:setVisible(true)
		end
	else
		self.cell:GetView():setVisible(true)
		self.bg:setVisible(false)
		if self.icon then
			self.icon:setVisible(false)
		end
	end
end

function EquipRender:FlushRemind()
	local can_fusion = false

	if next(self.data) then
		local item_id = self.data.item_id or 0
		local cfg = EquipMeltCfg or {}
		local fusion_type = ItemData.GetIsBasisEquip(item_id) and 1 or 2
		local meltcfg = cfg.meltcfg and cfg.meltcfg[fusion_type] or {}
		local cur_fusion_lv = EquipmentFusionData.GetFusionLv(self.data)
		local cur_meltcfg = meltcfg[cur_fusion_lv + 1]
		if cur_meltcfg then -- 下一级配置为空时,不可融合
			local limit_level, zhuan = ItemData.GetItemLevel(item_id)
			can_fusion = fusion_type == 2 or zhuan >= cur_meltcfg.circleLimit
		else
			can_fusion = false
		end
		
		-- 基础装备需装备达到对应转数才可融合
		if can_fusion then
			local consumes = cur_meltcfg.consumes or {}
			local cur_consume = consumes[1] or {}
			local consume_num_cfg = cur_consume.count or 0
			local consume_num = BagData.GetConsumesCount(cur_consume.id, cur_consume.type)
			can_fusion = consume_num_cfg ~= 0 and consume_num >= consume_num_cfg
		end

		if can_fusion then
			can_fusion = false
			local bag_list = BagData.Instance:GetDataListSeries()
			local cur_equip_list = BagData.Instance:GetSeriesByItemId(item_id)
			if next(cur_equip_list) then -- 背包中有这个装备时,才判断融合等级是否相同
				for series, _ in pairs(cur_equip_list) do
					local item = BagData.Instance:GetOneItemBySeries(series)
					local fusion_lv = EquipmentFusionData.GetFusionLv(item)
					if fusion_lv == cur_fusion_lv and (show_type ~= 2 or series ~= self.data.series) then
						can_fusion = true
						break
					end
				end
			end
		end
	end

	if can_fusion and self.view.UpdateReimd == nil then
		local check_have_remind_func, eff_id, x, y, z_order
		z_order = 1000
		XUI.AddRemingTip(self.view, check_have_remind_func, eff_id, x, y, z_order)
	end

	if self.view.UpdateReimd then
		self.view:UpdateReimd(can_fusion)
	end
end

return EquipmentFusionView