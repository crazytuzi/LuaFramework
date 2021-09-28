GuildStorgeView = GuildStorgeView or BaseClass(BaseRender)

function GuildStorgeView:__init(instance)
	if instance == nil then
		return
	end

	self.scroller_bag = self:FindObj("Scroller")
	self.scroller_storge = self:FindObj("Scroller2")
	self.scroller_window = self:FindObj("Scroller3")

	self.title = self:FindVariable("Title")
	self.show_donate = self:FindVariable("ShowDonate")
	self.show_window = self:FindVariable("ShowWindow")
	self.show_select = self:FindVariable("ShowSelect")
	self.storge_score = self:FindVariable("StorgeScore")

	self:ListenEvent("OnClickDestory",
		BindTool.Bind(self.OnClickDestory, self))
	self:ListenEvent("OnClickCanBuy",
		BindTool.Bind(self.OnClickCanBuy, self))
	self:ListenEvent("OnClickSelfProf",
		BindTool.Bind(self.OnClickSelfProf, self))
	self:ListenEvent("OnClickDonate",
		BindTool.Bind(self.OnClickDonate, self))
	self:ListenEvent("CloseWindow",
		BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("OnClickSelect",
		BindTool.Bind(self.OnClickSelect, self))
	self:ListenEvent("OnClickAutoDonate",
		BindTool.Bind(self.OnClickAutoDonate, self))
	self:ListenEvent("OnClickAutoDestory",
		BindTool.Bind(self.OnClickAutoDestory, self))
	self:ListenEvent("OnClickCleanUp",
		BindTool.Bind(self.OnClickCleanUp, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))

	for i = 1, 6 do
		self:ListenEvent("OnClickLevel" .. i,
			function() self:SelectLevel(i) end)
	end

	self.add_function = BindTool.Bind(self.AddSelectList, self)
	self.package_list = {}
	self.storge_item_list = {}
	self.window_item_list = {}
	self.cell_list = {}
	self.select_donate_list = {}
	self.select_destory_list = {}
	self.only_show_can_buy = false
	self.only_show_self_prof = false
	self.is_donating = true
	self.last_flush_time = 0

	self.data_change = BindTool.Bind(self.FlushBag, self, change_item_id, change_item_index, change_reason)
	ItemData.Instance:NotifyDataChangeCallBack(self.data_change)

	self.score = 0
	self.last_flush_time = Status.NowTime
	self.last_flush_storge_time = Status.NowTime
	self.last_flush_window_time = Status.NowTime
	self.last_jump_time = Status.NowTime

	self.button_list = {}
	for i = 1,6 do
		self.button_list[i] = self:FindObj("SelectButton"..i)
	end

	self:InitScrollerBag()
	self:InitScrollerStorge()
	self:InitScrollerWindow()
end

function GuildStorgeView:__delete()
	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	for k,v in pairs(self.cell_window_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_window_list = {}
	for k,v in pairs(self.cell_storge_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_storge_list = {}
	if self.data_change then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.data_change)
		self.data_change = nil
	end
	self:RemoveDelayTime()
	self:RemoveStorgeDelayTime()
	self:RemoveWindowDelayTime()
	self:RemoveJumpDelayTime()
end

function GuildStorgeView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function GuildStorgeView:RemoveStorgeDelayTime()
	if self.storge_delay_time then
		GlobalTimerQuest:CancelQuest(self.storge_delay_time)
		self.storge_delay_time = nil
	end
end

function GuildStorgeView:RemoveWindowDelayTime()
	if self.window_delay_time then
		GlobalTimerQuest:CancelQuest(self.window_delay_time)
		self.window_delay_time = nil
	end
end

function GuildStorgeView:RemoveJumpDelayTime()
	if self.jump_delay_time then
		GlobalTimerQuest:CancelQuest(self.jump_delay_time)
		self.jump_delay_time = nil
	end
end

function GuildStorgeView:FlushBag(change_item_id, change_item_index, change_reason)
	if self.last_flush_time + 0.25 <= Status.NowTime then
		self.last_flush_time = Status.NowTime
		self.package_list = self:GetCanStorgeItem()
		if self.scroller_bag and not IsNil(self.scroller_bag.gameObject) and self.scroller_bag.scroller.isActiveAndEnabled then
			self.scroller_bag.scroller:RefreshAndReloadActiveCellViews(true)
		end
	else
		self.last_flush_time = Status.NowTime
		self:RemoveDelayTime()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:FlushBag() end, 0.3)
	end
end

function GuildStorgeView:Flush()
	self.package_list = self:GetCanStorgeItem()
	self:FlushStorge()
	self:FlushBag()
	self:FlushWindow()
	if self.last_jump_time + 0.1 <= Status.NowTime then
		self.last_jump_time = Status.NowTime
		self:JumpTo()
	else
		self.last_jump_time = Status.NowTime
		self:RemoveJumpDelayTime()
		self.jump_delay_time = GlobalTimerQuest:AddDelayTimer(function() self:JumpTo() end, 0.2)
	end

end

-- 跳转到第一页
function GuildStorgeView:JumpTo()
	GlobalTimerQuest:AddDelayTimer(function()
		if self.scroller_bag.list_page_scroll.isActiveAndEnabled and self.scroller_bag_is_loaded then
			self.scroller_bag.list_page_scroll:JumpToPageImmidate(0)
		end
	end, 0.1)

	GlobalTimerQuest:AddDelayTimer(function()
		if self.scroller_storge.list_page_scroll.isActiveAndEnabled and self.scroller_storge_is_loaded then
			self.scroller_storge.list_page_scroll:JumpToPageImmidate(0)
		end
	end, 0.1)
end

function GuildStorgeView:FlushStorge()
	if self.last_flush_storge_time + 0.1 <= Status.NowTime then
		self.last_flush_storge_time = Status.NowTime
		local storge_info = GuildData.Instance:GetGuildStorgeInfo()
		if storge_info then
			local storge_item_list = storge_info.storge_item_list
			self.storge_item_list = self:CheckRule(storge_item_list)
			self.score = storge_info.storage_score or 0
			self.storge_score:SetValue(self.score)
		end
		if self.scroller_storge.scroller.isActiveAndEnabled then
			self.scroller_storge.scroller:RefreshAndReloadActiveCellViews(true)
		end
	else
		self.last_flush_storge_time = Status.NowTime
		self:RemoveStorgeDelayTime()
		self.storge_delay_time = GlobalTimerQuest:AddDelayTimer(function() self:FlushStorge() end, 0.2)
	end
end

function GuildStorgeView:FlushWindow()
	if self.last_flush_window_time + 0.1 <= Status.NowTime then
		self.last_flush_window_time = Status.NowTime
		if self.is_donating then
			self.window_item_list = self:GetCanStorgeItem()
		else
			local storge_info = GuildData.Instance:GetGuildStorgeInfo()
			if storge_info then
				self.storge_item_list = self:CheckRule(storge_info.storge_item_list)
			end
			self.window_item_list = self.storge_item_list
		end
		if self.scroller_window.scroller.isActiveAndEnabled then
			self.scroller_window.scroller:RefreshAndReloadActiveCellViews(true)
		end
	else
		self.last_flush_window_time = Status.NowTime
		self:RemoveWindowDelayTime()
		self.window_delay_time = GlobalTimerQuest:AddDelayTimer(function() self:FlushWindow() end, 0.2)
	end
end

function GuildStorgeView:FlushHighLight()
	for k,v in pairs(self.cell_window_list) do
		v:FlushHighLight()
	end
end

function GuildStorgeView:OnClickDestory()
	local post = GuildData.Instance:GetGuildPost()
	if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
		return
	end
	self:ClearSelectList()
	self.show_window:SetValue(true)
	self.title:SetValue(Language.Guild.PiLiangXiaoHui)
	self.show_donate:SetValue(false)
	self.is_donating = false
	self:FlushWindow()
	if self.scroller_window.list_page_scroll.isActiveAndEnabled then
		self.scroller_window.list_page_scroll:JumpToPageImmidate(0)
	end
end

function GuildStorgeView:OnClickCanBuy(switch)
	self.only_show_can_buy = switch
	for k,v in pairs(self.select_destory_list) do
		v.is_select = false
	end
	self.select_destory_list = {}
	self:FlushStorge()
end

function GuildStorgeView:OnClickSelfProf(switch)
	self.only_show_self_prof = switch
	for k,v in pairs(self.select_destory_list) do
		v.is_select = false
	end
	self.select_destory_list = {}
	self:FlushStorge()
end

function GuildStorgeView:OnClickDonate()
	self:ClearSelectList()
	self.show_window:SetValue(true)
	self.title:SetValue(Language.Guild.PiLiangGongXian)
	self.show_donate:SetValue(true)
	self.is_donating = true
	self:FlushWindow()
	if self.scroller_window.list_page_scroll.isActiveAndEnabled then
		self.scroller_window.list_page_scroll:JumpToPageImmidate(0)
	end
end

function GuildStorgeView:CloseWindow()
	self:ClearSelectList()
	self.show_window:SetValue(false)
end

function GuildStorgeView:ClearSelectList()
	for k,v in pairs(self.select_destory_list) do
		v.is_select = false
	end
	self.select_destory_list = {}

	for k,v in pairs(self.select_donate_list) do
		v.is_select = false
	end

	for k,v in pairs(self.button_list) do
		v.toggle.isOn = false
	end

	self.select_donate_list = {}
end

function GuildStorgeView:OnClickSelect(switch)
	self.show_select:SetValue(switch)
end

function GuildStorgeView:SelectLevel(index)
	if self.is_donating then
		self.select_donate_list = {}
	else
		self.select_destory_list = {}
	end
	if index < 5 then
		local select_level = GUILD_STORGE_LEVEL[index] or 34
		for k,v in pairs(self.window_item_list) do
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg then
				if (item_cfg.order and item_cfg.order > select_level) or big_type ~= GameEnum.ITEM_BIGTYPE_EQUIPMENT then
					v.is_select = false
				else
					v.is_select = true
					self:AddSelectList(v, true)
				end
			end
		end
	elseif index == 5 then
		for k,v in pairs(self.window_item_list) do
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg then
				v.is_select = true
				self:AddSelectList(v, true)
			end
		end
	else
		for k,v in pairs(self.window_item_list) do
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg then
				if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
					v.is_select = false
				else
					v.is_select = true
					self:AddSelectList(v, true)
				end
			end
		end
	end
	self:FlushHighLight()
end

function GuildStorgeView:OnClickAutoDonate()
	local yes_func = function()
		local num = 0
		local item_list = {}
		for k,v in pairs(self.select_donate_list) do
			num = num + 1
			table.insert(item_list, {item_index = v.index, param_1 = v.num})
			v.is_select = false
		end
		GuildCtrl.Instance:SendStorgeOneKeyOperate(GUILD_STORGE_ONE_KEY_OPERATE.GUILD_STORGE_OPERATE_PUTON_ITEM_ONE_KEY, num, item_list)
		self.select_donate_list = {}
		self:FlushWindow()
	end

	local count = 0
	local score = 0
	for k,v in pairs(self.select_donate_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			score = item_cfg.guild_storage_score * v.num + score
		end
		count = count + 1
	end

	if count > 0 then
		local describe = string.format(Language.Guild.Donate, count, score)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoSelect)
	end
end

function GuildStorgeView:OnClickAutoDestory()
	local yes_func = function()
		local num = 0
		local item_list = {}

		local temp_list = {}
		for k,v in pairs(self.select_destory_list) do
			v.is_select = false
			table.insert(temp_list, v)
		end
		table.sort(temp_list, function(a, b) return a.index < b.index end)
		for i = #temp_list, 1, -1 do
			local data = temp_list[i]
			num = num + 1
			table.insert(item_list, {item_index = data.index, param_1 = data.item_id})
		end

		GuildCtrl.Instance:SendStorgeOneKeyOperate(GUILD_STORGE_ONE_KEY_OPERATE.GUILD_STORGE_OPERATE_DISCARD_ITEM_ONE_KEY, num, item_list)
		self.select_destory_list = {}
		self:FlushWindow()
	end

	local count = 0
	for k,v in pairs(self.select_destory_list) do
		count = count + 1
	end

	if count > 0 then
		local describe = string.format(Language.Guild.Destory, count)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoSelect)
	end
end

function GuildStorgeView:OnClickCleanUp()
	PackageCtrl.Instance:SendKnapsackStoragePutInOrder(GameEnum.STORAGER_TYPE_BAG, 0)
end

function GuildStorgeView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(151)
end

--初始化滚动条
function GuildStorgeView:InitScrollerBag()
	local ListViewDelegate = ListViewDelegate
	self.toggle_group = self.scroller_bag:GetComponent("ToggleGroup")
	self.list_view_delegate = ListViewDelegate()

	PrefabPool.Instance:Load(AssetID("uis/views/guildview_prefab", "ItemCellPanel"), function (prefab)
		if nil == prefab then
			return
		end
		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		PrefabPool.Instance:Free(prefab)

		self.enhanced_cell_type = enhanced_cell_type
		self.scroller_bag.scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end

function GuildStorgeView:GetNumberOfCells()
	return 40
end

function GuildStorgeView:GetCellSize(data_index)
	return 96
end

function GuildStorgeView:GetCellView(scroller, data_index, cell_index)
	self.scroller_bag_is_loaded = true
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)

	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = GuildPackageScrollCell.New(cell_view)
		cell = self.cell_list[cell_view]
		cell:SetToggleGroup(self.toggle_group)
	end

	local data = self:GetItemPanelData(self.package_list, data_index + 1, 4, 4)
	cell:SetType(TipsFormDef.FROM_BAG_ON_GUILD_STORGE)
	cell:SetData(data)
	return cell_view
end

function GuildStorgeView:InitScrollerStorge()
	self.cell_storge_list = {}
	self.storge_toggle_group = self.scroller_storge:GetComponent("ToggleGroup")
	local ListViewDelegate = ListViewDelegate
	self.storge_list_view_delegate = ListViewDelegate()

	PrefabPool.Instance:Load(AssetID("uis/views/guildview_prefab", "ItemCellPanel"), function (prefab)
		if nil == prefab then
			return
		end
		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		PrefabPool.Instance:Free(prefab)

		self.storge_enhanced_cell_type = enhanced_cell_type
		self.scroller_storge.scroller.Delegate = self.storge_list_view_delegate

		self.storge_list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetStorgeNumberOfCells, self)
		self.storge_list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.storge_list_view_delegate.cellViewDel = BindTool.Bind(self.GetStorgeCellView, self)
	end)
end

function GuildStorgeView:GetStorgeNumberOfCells()
	return 40
end

function GuildStorgeView:GetStorgeCellView(scroller, data_index, cell_index)
	self.scroller_storge_is_loaded = true
	local cell_view = scroller:GetCellView(self.storge_enhanced_cell_type)

	local cell = self.cell_storge_list[cell_view]
	if cell == nil then
		self.cell_storge_list[cell_view] = GuildPackageScrollCell.New(cell_view)
		cell = self.cell_storge_list[cell_view]
		cell:SetToggleGroup(self.storge_toggle_group)
	end

	local data = self:GetItemPanelData(self.storge_item_list, data_index + 1, 4, 4)
	cell:SetType(TipsFormDef.FROM_STORGE_ON_GUILD_STORGE)
	cell:SetData(data)
	return cell_view
end

function GuildStorgeView:InitScrollerWindow()
	self.cell_window_list = {}
	self.window_toggle_group = self.scroller_window:GetComponent("ToggleGroup")
	local ListViewDelegate = ListViewDelegate
	self.window_list_view_delegate = ListViewDelegate()

	PrefabPool.Instance:Load(AssetID("uis/views/guildview_prefab", "ItemCellPanel"), function (prefab)
		if nil == prefab then
			return
		end
		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		PrefabPool.Instance:Free(prefab)
		
		self.window_enhanced_cell_type = enhanced_cell_type
		self.scroller_window.scroller.Delegate = self.window_list_view_delegate

		self.window_list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetWindowNumberOfCells, self)
		self.window_list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.window_list_view_delegate.cellViewDel = BindTool.Bind(self.GetWindowCellView, self)
	end)
end

function GuildStorgeView:GetWindowNumberOfCells()
	return 24
end

function GuildStorgeView:GetWindowCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.window_enhanced_cell_type)

	local cell = self.cell_window_list[cell_view]
	if cell == nil then
		self.cell_window_list[cell_view] = GuildPackageScrollCell.New(cell_view)
		cell = self.cell_window_list[cell_view]
		-- cell:SetToggleGroup(self.window_toggle_group)
		cell:SetClickFunc(self.add_function)
	end

	local data = self:GetItemPanelData(self.window_item_list, data_index + 1, 4, 4)
	cell:SetType(0)
	cell:SetData(data)
	return cell_view
end

function GuildStorgeView:AddSelectList(data, switch)
	if data and data.item_id then
		if self.is_donating then
			self.select_donate_list[data] = switch and data or nil
		else
			self.select_destory_list[data] = switch and data or nil
		end
	end
end

function GuildStorgeView:GetCanStorgeItem()
	local equip_info = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	local temp_list = {}
	if equip_info then
		for k,v in pairs(equip_info) do
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg and v.is_bind == 0 then
				if item_cfg.color >= 4 and item_cfg.sub_type ~= 201 and item_cfg.search_type ~= 108 then   --108（情缘装备搜索类型）
					table.insert(temp_list, v)
				end
			end
		end
	end
	
	local material_info = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_OTHER)
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	if material_info then
		for k,v in pairs(material_info) do
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if (v.item_id == 27789 or v.item_id == 27790 or v.item_id == 27791)
				and item_cfg.limit_prof ~= prof and v.is_bind == 0 then
				table.insert(temp_list, v)
			end
		end
	end
	return temp_list
end

function GuildStorgeView:CheckRule(item_list)
	if not item_list then return {} end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = main_role_vo.prof
	local level = main_role_vo.level
	local temp_list = {}
	for k,v in pairs(item_list) do
		local flag = true
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if self.only_show_self_prof then
			if item_cfg then
				if item_cfg.limit_prof ~= 5 and item_cfg.limit_prof ~= prof then
					flag = false
				end

				if item_cfg.limit_level > level then
					flag = false
				end
			end
		end
		if self.only_show_can_buy then
			if item_cfg then
				if item_cfg.guild_storage_score > self.score then
					flag = false
				end
			end
		end
		if flag then
			table.insert(temp_list, v)
		end
	end
	return temp_list
end

function GuildStorgeView:GetItemPanelData(item_list, index, row, column)
	if not item_list then return end
	local index1 = math.floor(index / column)
	local index2 = index % column
	if index2 == 0 then
		index1 = index1 - 1
		index2 = column
	end
	local num = index1 * row * column
	local list = {}
	for i = 1, row do
		local index3 = index2 + (i - 1) * column + num
		list[i] = item_list[index3] or {}
		list[i].data_index = index3
	end
	return list
end

-------------------------------------------------------- GuildPackageScrollCell ----------------------------------------------------------

GuildPackageScrollCell = GuildPackageScrollCell or BaseClass(BaseCell)

function GuildPackageScrollCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

	self.item_list = {}
	self.old_data = nil
	for i = 1, 4 do
		self.item_list[i] = {}
		self.item_list[i].obj = self:FindObj("ItemCell" .. i)
		self.item_list[i].cell = ItemCell.New()
		self.item_list[i].cell:SetInstanceParent(self.item_list[i].obj)
		local func = function ()
			if self.data[i].item_id == nil then
				self.item_list[i].cell:SetHighLight(false)
				if self.data[i].locked then
					SysMsgCtrl.Instance:ErrorRemind(Language.Guild.StorgeCell)
				end
				return
			end
			TipsCtrl.Instance:OpenItem(self.data[i], self.form_type, nil, function() self.item_list[i].cell:SetHighLight(false) end)
		end
		self.item_list[i].cell:ListenClick(func)
	end
end

function GuildPackageScrollCell:__delete()
	for k,v in pairs(self.item_list) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_list = {}
end

function GuildPackageScrollCell:SetToggleGroup(toggle_group)
	for i = 1, 4 do
		self.item_list[i].cell:SetToggleGroup(toggle_group)
	end
end

function GuildPackageScrollCell:OnFlush()
	for i = 1, 4 do
		local data = self.data[i]
		self:FLushCell(i, data)
		-- if self.old_data == nil or self.data[i].item_id ~= self.old_data[i].item_id then
		-- 	self:FLushCell(i, data)
		-- else
		-- 	if self.data[i].is_select then
		-- 		self.item_list[i].cell:SetHighLight(true)
		-- 	else
		-- 		self.item_list[i].cell:SetHighLight(false)
		-- 	end
		-- 	if self.form_type == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE then
		-- 		local is_locked = self:IsLocked(data)
		-- 		data.locked = is_locked
		-- 		self.item_list[i].cell:SetCellLock(is_locked)
		-- 	end
		-- end
	end
	-- self.old_data = self.data
end

function GuildPackageScrollCell:FLushCell(i, data)
	if self.form_type == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE then
		data.locked = self:IsLocked(data)
	end
	self.item_list[i].cell:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	if item_cfg and self.form_type == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE 
		and (item_cfg.limit_prof == gamevo.prof or item_cfg.limit_prof == 5) 
		and item_cfg.limit_level <= gamevo.level then
		self.item_list[i].cell:SetShowUpArrow(gamevo.capability < EquipData.Instance:GetEquipLegendFightPowerByData(data))
	end
	if data.item_id == nil and not data.locked then
		self.item_list[i].cell:SetInteractable(false)
	else
		self.item_list[i].cell:SetInteractable(true)
	end
	if self.data[i].is_select then
		self.item_list[i].cell:SetHighLight(true)
	else
		self.item_list[i].cell:SetHighLight(false)
	end
end

function GuildPackageScrollCell:IsLocked(data)
	if self.form_type == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE then
		local size = GuildData.Instance:GetGuildStorgeSize()
		if size then
			if data.data_index > size then
				return true
			else
				return false
			end
		end
	end
	return false
end

function GuildPackageScrollCell:SetType(form_type)
	self.form_type = form_type
end

function GuildPackageScrollCell:SetClickFunc(func)
	if func then
		for i = 1, 4 do
			local cell = self.item_list[i].cell
			cell:ListenClick(BindTool.Bind(self.SelectFunc, self, i, func))
		end
	end
end

function GuildPackageScrollCell:SelectFunc(i, func)
	if self.data[i].item_id then
		if self.data[i].is_select then
			self.data[i].is_select = false
		else
			self.data[i].is_select = true
		end
		self.item_list[i].cell:SetHighLight(self.data[i].is_select)
		func(self.data[i], self.data[i].is_select)
	end
end

function GuildPackageScrollCell:FlushHighLight()
	for i = 1, 4 do
		local data = self.data[i]
		if data and data.is_select then
			self.item_list[i].cell:SetHighLight(true)
		else
			self.item_list[i].cell:SetHighLight(false)
		end
	end
end