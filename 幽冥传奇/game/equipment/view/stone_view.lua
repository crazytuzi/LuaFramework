----------------------------------------
-- 锻造-宝石  配置文件名 EquipInlayCfg
----------------------------------------
local StoneView = BaseClass(SubView)

function StoneView:__init()
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self.texture_path_list[2] = 'res/xui/equipbg.png'
	self.config_tab = {
		{"equipment_ui_cfg", 3, {0}},
	}

	self.stone_list = nil
end

function StoneView:__delete()
end

function StoneView:LoadCallBack(index, loaded_times)
	self.equip_list = nil
	self.select_equip_slot = 1
	self.select_stone_slot = 1
	self.stone_grid = nil
	self.is_auto_compose = false
	self.is_auto_inlays = false
	self:FlushShowlayout(false)
	self:CreateStoneList()
	self:CreateStoneGrid()
	self:CreateStoneCellList()
	self:CreateGemShopView()
	self:CreateAttrList()

	local ph = self.ph_list.ph_bs_list
	self.empty_txt = XUI.CreateText(ph.x + ph.w / 2, ph.y + ph.h / 2, 200, 60,nil, Language.Equipment.EmptyBag, nil, 21, COLOR3B.BROWN2)
	self.node_t_list.layout_stone.node:addChild(self.empty_txt, 100)

	local stone_data_event_proxy = EventProxy.New(StoneData.Instance, self)
	stone_data_event_proxy:AddEventListener(StoneData.STONE_INSERT_CHANGE, BindTool.Bind(self.OnStoneInsertChange, self))
	stone_data_event_proxy:AddEventListener(StoneData.STONE_INSERT_SUCCESS, BindTool.Bind(self.OnStoneInsertSuccess, self))

	self:BindGlobalEvent(OtherEventType.BAG_STONE_CHANGED, BindTool.Bind(self.OnBagItemChange, self))

	XUI.AddClickEventListener(self.node_t_list.btn_xiangqian_tip.node, BindTool.Bind(self.OpenShowXiangQianTip, self))
	XUI.AddClickEventListener(self.node_t_list.btn_quick_buy.node, BindTool.Bind(self.OnQuickBuy, self))
	XUI.AddClickEventListener(self.node_t_list.btn_return.node, BindTool.Bind(self.ReturnShow, self))
	XUI.AddClickEventListener(self.node_t_list["btn_all_upgrade"].node, BindTool.Bind(self.OnAllUpgrade, self))
	XUI.AddClickEventListener(self.node_t_list["btn_all_put_on"].node, BindTool.Bind(self.OnAllPutOn, self))

	StoneCtrl.SendEquipInsetInfoReq()
end

function StoneView:ReleaseCallBack()
	if self.equip_item_list then
		for k, v in pairs(self.equip_item_list) do
			v:DeleteMe()
		end
		self.equip_item_list = {}
	end
	
	if self.stone_list then
		for i,v in ipairs(self.stone_list) do
			v:DeleteMe()
		end
		self.stone_list = nil
	end

	if self.stone_grid then
		self.stone_grid:DeleteMe()
		self.stone_grid = nil
	end

	self.is_auto_compose = nil
	self.is_auto_inlays = nil
	self.play_eff = nil

	if self.buy_list then
		self.buy_list:DeleteMe()
		self.buy_list = nil
	end
end

function StoneView:OpenCallBack()
end

function StoneView:CloseCallBack()
	if self.select_equip_slot then
		self.select_equip_slot = 1
	end

	StoneData.Instance:SetSelectEquipSlot(nil)
end

function StoneView:ShowIndexCallBack()
	StoneData.Instance:SetSelectEquipSlot(self.select_equip_slot)

	self:FlushBagStone()
	self:SetEquipCellList()
	self:OnSelectStoneEquipItem(self.equip_item_list[self.select_equip_slot])
end

function StoneView:OnFlush(param_t)

end

----------视图函数----------

function StoneView:CreateStoneList()
	if nil == self.stone_list then 
		local parent = self.node_t_list["layout_stone"].node
		self.stone_list = {}
		for i= 1, 6 do
			local ph = self.ph_list["ph_stone_" .. i]
			local cell = StoneView.StoneItemRender.New(i, ph)
			cell:AddClickEventListener(BindTool.Bind(self.OnClickStoneCell, self))
			parent:addChild(cell:GetView(), 99)
			self.stone_list[i] = cell
		end
	end
end

function StoneView:FlushShowlayout(vis)
	self.node_t_list["layout_attr"].node:setVisible(not vis)
	self.node_t_list.layout_quiky_buy.node:setVisible(vis)
end

function StoneView:CreateStoneCellList()
	self.equip_item_list = {}
	for i = 1, 10 do
		local cell = self:CreateEquipCell(self.ph_list["ph_stone_cell_" .. i])
		cell:SetIndex(i)
		cell:AddClickEventListener(BindTool.Bind(self.OnSelectStoneEquipItem, self), false)
		self.equip_item_list[i] = cell
	end
end

function StoneView:CreateEquipCell(ph)
	if ph == nil then return end

	local cell = StoneView.EquipItemRender.New()
	cell:SetAnchorPoint(0.5, 0.5)
	cell:SetPosition(ph.x, ph.y)
	cell:SetUiConfig(ph, true)
	self.node_t_list.layout_stone.node:addChild(cell:GetView(), 50)
	return cell
end

function StoneView:CreateStoneGrid()
	if nil == self.stone_grid  then
		local ph = self.ph_list.ph_bs_list
		self.stone_grid = BaseGrid.New() 
		local grid_node = self.stone_grid:CreateCells({w = ph.w, h = ph.h, itemRender = StoneView.BagStoneRender, ui_config = self.ph_list.ph_bs_bag_cell, cell_count = 8, col = 4, row = 2, direction = ScrollDir.Vertical})
		self.node_t_list.layout_stone.layout_gem_bag.node:addChild(grid_node, 10)
		self.stone_grid:GetView():setPosition(ph.x, ph.y)
		self.stone_grid:SetSelectCallBack(BindTool.Bind(self.OnSelectStoneItem, self))
	end
end

function StoneView:CreateGemShopView()
	local ph = self.ph_list.ph_list
	if nil == self.buy_list then
		self.buy_list = ListView.New()
		self.buy_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CommonBuyRender, nil, nil, self.ph_list.ph_list_item)
		self.node_t_list.layout_stone.layout_quiky_buy.node:addChild(self.buy_list:GetView(), 100, 100)
		self.buy_list:GetView():setAnchorPoint(0, 0)
		self.buy_list:SetItemsInterval(8)
	end
	local data = ClientQuickyBuylistCfg and ClientQuickyBuylistCfg[ClientQuickyBuyType.baoshi] or {}
	self.buy_list:SetDataList(data)
	self.buy_list:JumpToTop(true)
end

function StoneView:CreateAttrList()
	local ph = self.ph_list["ph_stone_cur_attr"]
	self.cur_attr = ListView.New()
	self.cur_attr:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.AttrTextRender, nil, nil, self.ph_list.ph_attr_txt_item)
	self.cur_attr:SetItemsInterval(2)
	self.cur_attr:SetMargin(2)
	self.node_t_list["layout_attr"].node:addChild(self.cur_attr:GetView(), 50)
	self:AddObj("cur_attr")
end

function StoneView:FlushAttrText()
	local strengthen_info = QianghuaData.Instance:GetOneStrengthList(self.strengthen_slot)
	local cur_attr = {}
	for index, stone in ipairs(self.stone_list) do
		local data = stone:GetData()
		local item = data.item
		local item_cfg = ItemData.Instance:GetItemConfig(item.item_id)
		local attr = ItemData.GetStaitcAttrs(item_cfg)
		cur_attr = CommonDataManager.AddAttr(cur_attr, attr)
	end
	
	table.sort(cur_attr, function(a, b)
		return a.type < b.type
	end)
	self.cur_attr:SetDataList(RoleData.FormatRoleAttrStr(cur_attr))
end

function StoneView:FlushStoneList()
	local equip_data_list = StoneData.Instance:GetEquipDataList()
	local equip_data = equip_data_list[self.select_equip_slot]
	for i,v in ipairs(equip_data.inset_stones or {}) do
		local stone_index = v.stone_index or 0
		local stone_is_blind = v.stone_is_blind or 0
		local data = {["equip"] = equip_data, ["item"] = {}}
		if stone_index > 0 then
			local item_id = StoneData.GetStoneItemID(stone_index)
			if item_id then
				data.item = {item_id = item_id, num = 1, is_bind = stone_is_blind}
			end
		end
		if self.stone_list[i] then
			self.stone_list[i]:SetData(data)
		end
	end
	self:FlushAttrText()
end

function StoneView:FlushBagStone()
	if self.stone_grid then 
		local stone_list = StoneData.Instance:GetBagStoneCfgList()
		self.empty_txt:setVisible(false)
		-- self.stone_grid:GetView():setVisible(#stone_list ~= 0)
		self.stone_grid:ExtendGrid(#stone_list)
		local real_list = {}
		local index = 0
		for i,v in ipairs(stone_list) do
			real_list[index] = v
			index = index + 1
		end
		self.stone_grid:SetDataList(real_list)
	end
end

function StoneView:SetEquipCellList()
	for k, v in pairs(StoneData.Instance:GetEquipDataList()) do
		if self.equip_item_list[k] then
			self.equip_item_list[k]:SetData(v)
		end
	end
end

function StoneView:SetShowPlayEff(eff_id, x, y)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.node_t_list.layout_stone.node:addChild(self.play_eff, 100)
	end
	self.play_eff:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

----------end----------

function StoneView:OnStoneInsertChange()
	self:SetEquipCellList()
	self:OnInlaysStone()
	self:FlushStoneList()

	self.node_t_list["btn_all_put_on"].node:setEnabled(true)
	self.node_t_list["btn_all_upgrade"].node:setEnabled(true)
end

function StoneView:OnStoneInsertSuccess(slot)
	self:SetShowPlayEff(1123, 290, 250)
end

function StoneView:OnBagItemChange(vo)
	self:SetEquipCellList()
	self:FlushBagStone()
end

function StoneView:OnSelectStoneEquipItem(cell)
	if cell == nil then return end

	self.select_equip_slot = cell:GetIndex()
	self.select_equip_data = cell:GetData()
	StoneData.Instance:SetSelectEquipSlot(self.select_equip_slot)

	for k,v in pairs(self.equip_item_list) do
		v:SetSelect(false)
	end
	cell:SetSelect(true)

	self:FlushStoneList()

	local path = ResPath.GetEquipment("equipment_img_" .. self.select_equip_slot)
	self.node_t_list["img_select_equip"].node:loadTexture(path)
end

function StoneView:OnSelectStoneItem(cell)
	if cell == nil then return end
	
	local data = cell:GetData()
	if data == nil or data.empty then
		return 
	end
	local slot = StoneData.Instance:GetStoneSlot(data.item_id)
	local param = {equip_slot = self.select_equip_slot, stone_slot = slot, stone_series = data.series}
	TipCtrl.Instance:OpenItem(data, EquipTip.FROME_BAG_STONE, param)
end

function StoneView:OnClickStoneCell(item)
	local limit_circle = StoneData.GetStoneSlotLimitList()
	local cfg_zhuan = limit_circle[item.index]
	local equip_id = item.data.equip.equip and item.data.equip.equip.item_id or 0
	local level, zhuan = ItemData.GetItemLevel(equip_id)

	local data = item.data
	self.select_stone_slot = item.index
	if item.have_better then
		-- 已开放并且有更好的宝石 时为true, 否则为false
		StoneCtrl.Instance.SendEquipInlayGemReq(self.select_equip_slot, self.select_stone_slot, item.best_stone.series)
	elseif data.item and next(data.item) then
		-- 已镶嵌宝石
		TipCtrl.Instance:OpenItem(data.item, EquipTip.FROME_EQUIP_STONE, {equip_slot = self.select_equip_slot, stone_slot = self.select_stone_slot})
	else
		-- 未开放并且未镶嵌宝石
		local tip
		if zhuan == cfg_zhuan and cfg_zhuan == 0 then
			tip = Language.Equipment.StoneSlotTip1
		elseif zhuan < cfg_zhuan then
			tip = string.format(Language.Equipment.StoneSlotTip2, cfg_zhuan)
		elseif equip_id ~= 0 then
			local max_level = MAX_STONE_LEVEL * self.select_stone_slot -- 满级宝石
			local level = max_level - (MAX_STONE_LEVEL - 1) -- 1级宝石
			local item_id = StoneData.GetStoneItemID(level) or 0
			local num = 1
			TipCtrl.Instance:OpenGetNewStuffTip(item_id, num)
			return
		end
		SysMsgCtrl.Instance:FloatingTopRightText(tip)
	end
end

function StoneView:OnClickGetStoneStuff()
	TipCtrl.Instance:OpenBuyTip(EquipmentData.Instance:GetAdvStuffWayConfig()[EquipmentData.TabIndex.equipment_stone][1])
end

function StoneView:OnClickAKeyInlaysHandler()
	self.is_auto_inlays = true
	self:OnInlaysStone()
end

function StoneView:OnInlaysStone()
	if not self.is_auto_inlays then return end
	local stone_list = StoneData.Instance:GetBagStoneCfgList()
	local data_list = StoneData.Instance:GetEquipDataList()
	local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local limit_circle = StoneData.GetStoneSlotLimitList()
	for i,v in ipairs(data_list) do
		for k = 1, 5 do
			inset_level = StoneData.Instance.FormatStoneLevel(v.inset_stones[k].stone_index)
			if stone_list[1] then
				stone_index = StoneData.Instance.FormatStoneLevel(stone_list[1].stone_lv)
			end
			if stone_list and stone_list[1] and limit_circle[k] <= circle_level and (0 == v.inset_stones[k].stone_index  or stone_index > inset_level) then 
				StoneCtrl.SendEquipInlayGemReq(i, k, stone_list[1].series)
				return
			end
		end
	end
	self.is_auto_inlays = false
end

function StoneView:OnQuickBuy()
	self:FlushShowlayout(true)
end

function StoneView:ReturnShow()
	self:FlushShowlayout(false)
end

function StoneView:OpenShowXiangQianTip( ... )
	DescTip.Instance:SetContent(Language.DescTip.XiangQianConetent, Language.DescTip.XiangQianTitle)
end

function StoneView:OnAllUpgrade()
	BagData.Instance:SetDaley(true, 1)
	self.node_t_list["btn_all_upgrade"].node:setEnabled(false)
	
	local consumes_list = {} -- 物品消耗记录
	local virtual_consumes_list = {} -- 虚拟物品消耗记录

	local equip_inset_info = StoneData.Instance:GetEquipInsetInfo()
	local limit_circle = StoneData.GetStoneSlotLimitList()
	-- 根据定义的顺序升级
	local order = StoneData.Order
	for i, equip_slot in ipairs(order) do
		local equip = self.equip_item_list[equip_slot] or {} -- 装备图标
		-- 装备图标 有显示红点时,才进入判断
		if equip.can_upgrade then
			local equip_data = equip:GetData().equip or {item_id = 0}
			local level, zhuan = ItemData.GetItemLevel(equip_data.item_id)
			local inset_info = equip_inset_info[equip_slot] or {} -- 当前装备的镶嵌信息
			for stone_slot, slot_data in ipairs(inset_info) do
				-- 判断当前宝石槽位是否开放
				if zhuan >= limit_circle[stone_slot] then

					----------升级逻辑----------
					local stone_index = slot_data.stone_index or 0
					if stone_index > 0 then
						----------可升级判断----------
						local item_id = StoneData.GetStoneItemID(stone_index)
						local level, slot = StoneData.Instance:GetStoneLevelAndSlot(item_id)
						local cfg = StoneData.GetStoneUpgradeConsumes(level, slot)
						local consumes = cfg.consumes or {}
						local can_upgrade = BagData.ContinueCheckConsumesCount(consumes, consumes_list, virtual_consumes_list)

						----------可升级判断end----------

						if can_upgrade then
							StoneCtrl.SendStoneUpgradeReq(equip_slot, slot) -- 请求宝石升级

							-- 记录已消耗数量,避免消耗不足还进行请求
							BagData.ContinueRecordConsumesCount(consumes, consumes_list, virtual_consumes_list)
						end
					end
					----------升级逻辑end----------

				end -- limit_circle 宝石槽位是否开放

			end -- inset_info 镶嵌信息

		end -- equip.can_upgrade 装备图标 有显示红点

	end -- order

	if nil == next(consumes_list) and nil == next(virtual_consumes_list) then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.StoneSlotTip8)
		self.node_t_list["btn_all_upgrade"].node:setEnabled(true)
		BagData.Instance:SetDaley(false)
	end
end

-- "一键镶嵌"按钮
function StoneView:OnAllPutOn()
	BagData.Instance:SetDaley(true, 1)
	self.node_t_list["btn_all_put_on"].node:setEnabled(false)
	local equip_inset_info = StoneData.Instance:GetEquipInsetInfo()
	local best_stone_list = StoneData.Instance:GetBestStoneList()
	local has_send_list = {}
	local order = StoneData.Order
	for i, equip_slot in ipairs(order) do
		local equip = self.equip_item_list[equip_slot] or {}
		if equip.have_better_stone then
			local equip_data = equip:GetData().equip or {item_id = 0}
			local level, zhuan = ItemData.GetItemLevel(equip_data.item_id)
			local limit_circle = StoneData.GetStoneSlotLimitList()
			local inset_info = equip_inset_info[equip_slot] or {} -- 当前装备的镶嵌信息
			for stone_slot, stone in pairs(best_stone_list) do
				if zhuan >= limit_circle[stone_slot] then -- 开放时.
					local slot_data = inset_info[stone_slot] or {}
					local stone_index = slot_data.stone_index or 0
					local old_item_id = StoneData.GetStoneItemID(stone_index) or 0 -- 当前槽位镶嵌的宝石ID

					local stone_item_id = stone.item_id or 0
					if stone_item_id > old_item_id then -- 是更好的宝石
						local has_send_count = has_send_list[stone_item_id] or 0 -- 该宝石已请求镶嵌的次数
						local stone_num = BagData.Instance:GetItemNumInBagById(stone_item_id)
						if (stone_num - has_send_count) > 0 then
							StoneCtrl.Instance.SendEquipInlayGemReq(equip_slot, stone_slot, stone.series) -- 请求镶嵌宝石
							has_send_list[stone_item_id] = has_send_count + 1
						end
					end
				end
			end
		end
	end

	if nil == next(has_send_list) then
		-- "背包中没有更好的宝石"
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.StoneSlotTip7)
		self.node_t_list["btn_all_put_on"].node:setEnabled(true)
		BagData.Instance:SetDaley(false)
	end
end

----------------------------------------
-- 宝石背包item
----------------------------------------
StoneView.BagStoneRender = BaseClass(BaseRender)
local BagStoneRender = StoneView.BagStoneRender

function BagStoneRender:__init()
	self:AddClickEventListener()
end

function BagStoneRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
	end
end

function BagStoneRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_cell
	self.cell = BaseCell.New()
	self.cell:SetEventEnabled(false)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetPosition(ph.x, ph.y)
	self.view:addChild(self.cell:GetView(), 50)
end

function BagStoneRender:OnFlush()
	if self.data == nil or self.data.empty then
		self.cell:SetData()
	else 
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		local color = Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6))
		self.cell:SetData(self.data)
	end
end

function BagStoneRender:CreateSelectEffect()
end

----------------------------------------
-- 装备Item
----------------------------------------
StoneView.EquipItemRender = BaseClass(BaseRender)
local EquipItemRender = StoneView.EquipItemRender
function EquipItemRender:__init()
	self:AddClickEventListener()
end

function EquipItemRender:__delete()
	self.stone_lv_text = nil
	self.remind_flag = nil
	self.equip = nil

	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function EquipItemRender:CreateChild()
	BaseRender.CreateChild(self)

	local size = self.view:getContentSize()
	local x, y = size.width / 2, size.height / 2
	local path = ResPath.GetCommon("cell_116")
	local bg = XUI.CreateImageView(x, y,  path)
	self.view:addChild(bg, 1)
	XUI.AddRemingTip(self.view)

	local parent = self.view
	local cell = BaseCell.New()
	cell:SetPosition(0, 0)
	cell:GetView():setTouchEnabled(false)
	parent:addChild(cell:GetView(), 50)
	self.cell = cell
end

function EquipItemRender:OnFlush()
	if self.data == nil then
		return
	end
	
	self.have_better_stone = false
	local limit_circle = StoneData.GetStoneSlotLimitList()
	local best_stone_list = StoneData.Instance:GetBestStoneList()
	local equip_inset_info = StoneData.Instance:GetEquipInsetInfo()
	local equip_id = self.data.equip and self.data.equip.item_id
	if equip_id then
		local level, zhuan = ItemData.GetItemLevel(equip_id)
		local stone_info = equip_inset_info[self.index] or {}
		for i, v in pairs(best_stone_list) do
			if zhuan >= limit_circle[i] then
				local stone_index = stone_info[i] and stone_info[i].stone_index
				local item_id = StoneData.GetStoneItemID(stone_index)
				if (not item_id) or item_id < v.item_id then
					self.have_better_stone = true
					break
				end
			end
		end

		local can_upgrade_list = StoneData.Instance:GetStoneCanUpgradeList()
		local upgrade_consumes_list = can_upgrade_list[self.index]
		self.can_upgrade = false
		if upgrade_consumes_list ~= nil then
			for i, v in pairs(upgrade_consumes_list) do
				if zhuan >= limit_circle[i] then
					self.can_upgrade = true
					break
				end
			end
		end

		self.cell:SetData(self.data.equip)
		self.cell:GetView():setVisible(true)
		if self.equip then
			self.equip:setVisible(false)
		end
	else
		self.cell:GetView():setVisible(false)
		if self.equip == nil and self.index > 0 then
			local size = self.view:getContentSize()
			local x, y = size.width / 2, size.height / 2
			local path = ResPath.GetEquipment("equipment_img_" .. self.index)
			self.equip = XUI.CreateImageView(x, y, path)
			self.view:addChild(self.equip, 2)
		else
			if self.equip then
				self.equip:setVisible(true)
			end
		end
	end

	self.view:UpdateReimd(self.have_better_stone or self.can_upgrade)
end 

function EquipItemRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2,  size.height / 2, size.width + 10, size.height + 10, ResPath.GetCommon("img9_286"), true, cc.rect(8, 9, 13, 11))
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 99)
end


----------------------------------------
-- 镶嵌槽位Item
----------------------------------------
StoneView.StoneItemRender = BaseClass(BaseRender)
local StoneItemRender = StoneView.StoneItemRender
function StoneItemRender:__init(index, ph)
	self.width = ph.w or 80
	self.height = ph.h or 80
	self.index = index or 1
	self.x = ph.x or 284
	self.y = ph.y or 303
	self.have_better = false -- 有更好的宝石

	self:AddClickEventListener()
end

function StoneItemRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end

	self.img_lock = nil
	self.have_better = nil
end

function StoneItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.view:setContentWH(self.width, self.height)
	self.view:setAnchorPoint(0.5, 0.5)
	self.view:setPosition(self.x, self.y)

	self.cell = BaseCell.New()
	self.cell:SetCfgEffVis(false)
	self.cell:SetCellBgVis(false)
	self.cell:SetEventEnabled(false)
	self.cell:SetPosition(self.width / 2, self.height / 2)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetCellBg()
	self.view:addChild(self.cell:GetView(), 1)

	local x, y = self.width / 2, self.height / 2
	local path = ResPath.GetCommon("lock_close_2")
	self.img_lock = XUI.CreateImageView(x, y,  path)
	self.view:addChild(self.img_lock, 2)
	XUI.AddRemingTip(self.view)

	local text = string.format(Language.Equipment.SlotOpen, 0)
	local color3b = COLOR3B.GRAY
	self.open_tip_text = XUI.CreateText(x, -25, 80, 25, nil, text, nil, 20, color3b)
	self.view:addChild(self.open_tip_text)
end

function StoneItemRender:OnFlush()
	if self.data == nil then return end
	local equip_id = self.data.equip.equip and self.data.equip.equip.item_id or 0

	local level, zhuan = ItemData.GetItemLevel(equip_id)
	local limit_circle = StoneData.GetStoneSlotLimitList()
	local item = self.data.item

	self.cell:SetData(next(item) and item or nil)

	local best_stone_list = StoneData.Instance:GetBestStoneList()
	self.best_stone = best_stone_list[self.index]

	if equip_id == 0 or zhuan < limit_circle[self.index] then -- 未开放时.
		local path = ResPath.GetCommon("lock_close_2")
		self.img_lock:loadTexture(path)
		self.img_lock:setVisible(next(item) == nil)
		XUI.SetLayoutImgsGrey(self.cell:GetView(), true)
		self.view:UpdateReimd(false)
		self.have_better = false
		local text = string.format(Language.Equipment.SlotOpen, limit_circle[self.index] or 0)
		self.open_tip_text:setString(text)
		self.open_tip_text:setVisible((limit_circle[self.index] or 0) ~= 0)
	elseif (not next(item)) then -- 开放后镶嵌物品为空
		self.img_lock:setVisible(true)
		local path = ResPath.GetEquipment("stone_type_" .. self.index)
		self.img_lock:loadTexture(path)

		self.have_better = self.best_stone ~= nil
		self.view:UpdateReimd(self.have_better)
		self.open_tip_text:setVisible(false)
	else
		self.img_lock:setVisible(false)
		XUI.SetLayoutImgsGrey(self.cell:GetView(), false)

		local item_id = self.best_stone and self.best_stone.item_id or 0
		self.have_better = item_id > item.item_id
		self.open_tip_text:setVisible(false)
		local can_upgrade_list = StoneData.Instance:GetStoneCanUpgradeList()
		local select_equip_slot = StoneData.Instance:GetSelectEquipSlot()
		local upgrade_consumes = can_upgrade_list[select_equip_slot] and can_upgrade_list[select_equip_slot][self.index]
		self.can_upgrade = upgrade_consumes ~= nil
		self.view:UpdateReimd(self.have_better or self.can_upgrade)
	end

end

function StoneItemRender:CreateSelectEffect()
end

----------------------------------------
-- 属性文本
----------------------------------------
StoneView.AttrTextRender = BaseClass(BaseRender)
local AttrTextRender = StoneView.AttrTextRender

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

return StoneView