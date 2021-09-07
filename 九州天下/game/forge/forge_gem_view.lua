ForgeGem = ForgeGem or BaseClass(BaseRender)

local stone_num = 8

function ForgeGem:__init()
	self.cell_list = {}
	self.stone_cell_list = {}
	self.small_stone_cell_list = {}
	self.stone_cell = {}
	self.select_index = 1
	self.equip_index = 0
	self.select_cell_index = 0
end

function ForgeGem:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for _,v in pairs(self.stone_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.stone_cell_list = {}

	for _,v in pairs(self.small_stone_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.small_stone_cell_list = {}

	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	for _,v in pairs(self.stone_cell) do
		if v then
			v:DeleteMe()
		end
	end
	self.stone_cell = {}

	if self.attr_tips then
		self.attr_tips:DeleteMe()
		self.attr_tips = nil
	end

	if self.player_data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_listen)
		self.player_data_listen = nil
	end
end

function ForgeGem:LoadCallBack()
	self.player_data_listen = BindTool.Bind(self.FlushLimitText, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_listen)

	self.equip_index = ForgeData.Instance:GetDefaultEquipIndex()
	
	self.attr_name = self:FindVariable("AttrName")
	self.attr_value = self:FindVariable("AttrValue")
	self.power_name = self:FindVariable("PowerName")
	self.power_value = self:FindVariable("PowerValue")
	self.total_power = self:FindVariable("TotalPower")
	self.jia_type = self:FindVariable("jia_type")
	self.jia_num = self:FindVariable("jia_num")
	self.is_show_gem_list = self:FindVariable("IsShowGemList")
	self.is_show_gem_option = self:FindVariable("IsShowGemOption")
	self.gem_option_plane = self:FindObj("GemOptionPlane")
	self.is_max_level = self:FindVariable("is_max_level")

	self.is_show_small_gem_list = self:FindVariable("IsShowSmallGemList")

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self:FindObj("EquipCell"))

	self.stone_cell = {}
	for i = 1, stone_num do
		self.stone_cell[i] = GemStoneCell.New(self:FindObj("GemStoneCell" .. i), i, self)
	end

	self:CreateStoneSmallList()

	self.equip_list = self:FindObj("GemList")
	self.list_view_delegate = self.equip_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.stone_list = self:FindObj("StoneList")
	self.stone_list_view_delegate = self.stone_list.list_simple_delegate
	self.stone_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfStoneCells, self)
	self.stone_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshStoneView, self)

	self.attr_tips = GemAttrTips.New(self:FindObj("AttrTips"))
	self.attr_tips:SetActive(false)

	self:ListenEvent("CloseGemList", BindTool.Bind(self.ShowOrHideGemList, self, false))
	self:ListenEvent("CloseGemOption", BindTool.Bind(self.ShowOrHideGemOption, self, false))
	self:ListenEvent("OnClickInLay", BindTool.Bind(self.OnClickInLay, self))
	self:ListenEvent("OnClickUnLoad", BindTool.Bind(self.OnClickUnLoad, self))
	-- self:ListenEvent("OnClickLevelUp", BindTool.Bind(self.OnClickLevelUp, self))
	self:ListenEvent("OnClickStrength", BindTool.Bind(self.OnClickStrength, self))
	self:ListenEvent("OnClickTotalAttr", BindTool.Bind(self.OnClickTotalAttr, self))
	self:ListenEvent("OnClickCloseTips", BindTool.Bind(self.OnClickCloseTips, self))
	self:ListenEvent("OnClickDescTips", BindTool.Bind(self.OnClickDescTips, self))

	self.is_can_inlay = true

	self:Flush()
end

function ForgeGem:CreateStoneSmallList()
	self.small_stone_cell_list = {}
	self.scroller = self:FindObj("Scroller")

	self.small_stone_list_view_delegate = ListViewDelegate()
	PrefabPool.Instance:Load(AssetID("uis/views/forgeview_prefab", "GemItem"), function (prefab)
		if nil == prefab then
			return
		end
		self.enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		if nil ~= self.scroller and nil ~= self.scroller.scroller then
			self.scroller.scroller.Delegate = self.small_stone_list_view_delegate
		end	
		self.small_stone_list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfStoneCells, self)
		self.small_stone_list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.small_stone_list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)

		PrefabPool.Instance:Free(prefab)
	end)
end

function ForgeGem:GetCellView(scroller, data_index, cell_index)
	local cell = scroller:GetCellView(self.enhanced_cell_type)

	data_index = data_index + 1
	local scroller_cell = self.small_stone_cell_list[cell]
	if nil == scroller_cell then
		self.small_stone_cell_list[cell] = GemScrollerCell.New(cell.gameObject)
		scroller_cell = self.small_stone_cell_list[cell]
		scroller_cell.parent_view = self
		scroller_cell.root_node.toggle.group = self.scroller.toggle_group
	end
	if self.scroller_data[data_index].cfg then
		self.scroller_data[data_index].data_index = data_index
		scroller_cell:SetData(self.scroller_data[data_index])
	end
	return cell
end

function ForgeGem:SetScrollerData(data)
	self.scroller_data = data
end

function ForgeGem:SetSelectGemBagIndex(index)
	self.select_gem_bag_index = index
end

function ForgeGem:GetCellSize()
	return 110
end

function ForgeGem:GetNumberOfCells()
	return EquipData.Instance:GetDataCount()
end

function ForgeGem:RefreshView(cell, data_index)
	data_index = data_index + 1

	local equip_cell = self.cell_list[cell]
	if equip_cell == nil then
		equip_cell = GemItemCell.New(cell.gameObject)
		equip_cell.parent_view = self
		self.cell_list[cell] = equip_cell
	end
	equip_cell:SetIndex(data_index)
	local data = ForgeData.Instance:GetCurEquipList()
	equip_cell:SetData(data[data_index])
end

function ForgeGem:GetNumberOfStoneCells()
	local data = ForgeData.Instance:GetStoneListByIndex(self.equip_index)
	return #data
end

function ForgeGem:RefreshStoneView(cell, data_index)
	data_index = data_index + 1

	local stone_cell = self.stone_cell_list[cell]
	if stone_cell == nil then
		stone_cell = StoneItemCell.New(cell.gameObject)
		stone_cell.parent_view = self
		self.stone_cell_list[cell] = stone_cell
	end
	stone_cell:SetIndex(data_index)
	local data = ForgeData.Instance:GetStoneListByIndex(self.equip_index)

	stone_cell:SetData(data[data_index])
end

function ForgeGem:SetSelectIndex(select_index, equip_index)
	self.select_index = select_index
	self.equip_index = equip_index
end

function ForgeGem:GetSelectIndex()
	return self.select_index or 1
end

function ForgeGem:GetEquipIndex()
	return self.equip_index or 0
end

function ForgeGem:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function ForgeGem:ShowOrHideGemList(is_show, cell_index, show_gem_list)
	self.is_show_gem_list:SetValue(is_show)
	if is_show then
		self.select_cell_index = cell_index
		self.gem_scroller_select_index = 1
		if show_gem_list then
			self.scroller.scroller:ReloadData(0)
		end
	end
end

function ForgeGem:SetSmallGemListValue(visible)
	self.is_show_small_gem_list:SetValue(visible)
end

function ForgeGem:ShowOrHideGemOption(is_show, pos, cell_index)
	self.is_show_gem_option:SetValue(is_show)
	if is_show then
		self.gem_option_plane.transform.position = pos
		self.select_cell_index = cell_index
	end
end

function ForgeGem:OnClickInLay()
	if self.gem_scroller_select_index == nil and self.scroller_data == nil or self.scroller_data[self.gem_scroller_select_index] == nil
	or next(self.scroller_data[self.gem_scroller_select_index]) == nil then
		return
	end

	local bag_index = ItemData.Instance:GetItemIndex(self.scroller_data[self.gem_scroller_select_index].item_id)
	ForgeCtrl.Instance:SendStoneInlay(self.equip_index, self.select_cell_index, bag_index, 1)
	self:ShowOrHideGemList(false)
end

function ForgeGem:OnClickUnLoad()
	ForgeCtrl.Instance:SendStoneInlay(self.equip_index, self.select_cell_index, 0, 0)
	self:ShowOrHideGemList(false)
end

function ForgeGem:OnClickStrength()
	ViewManager.Instance:Open(ViewName.Compose, TabIndex.compose_stone)
end

function ForgeGem:OnClickTotalAttr()
	if self.attr_tips.root_node.gameObject.activeSelf then
		self.attr_tips:SetActive(false)
	else
		self.attr_tips:SetData()
		self.attr_tips:SetActive(true)
	end
end

function ForgeGem:OnClickCloseTips()
	self.attr_tips:SetActive(false)
end

function ForgeGem:OnClickDescTips()
	TipsCtrl.Instance:ShowHelpTipView(147)
end

function ForgeGem:FlushEquipCell()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end

	self.equip_cell:SetData({item_id = equip_data.item_id, num = equip_data.num, is_bind = equip_data.is_bind})
	self.equip_cell:ClearItemEvent()
	self.equip_cell:ShowHighLight(false)
end

function ForgeGem:FlushGemStoneCell()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	local gem_info = ForgeData.Instance:GetGemInfo()
	local gem_data = gem_info[self.equip_index] or {}
	local gem_state = ForgeData.Instance:GetGemStateByEquipData(equip_data)

	for i = 1, stone_num do
		self.stone_cell[i]:SetData(equip_data)
	end

	local is_all_inlay = true
	for i = 1, 8 do
		if gem_data[i - 1].stone_id == 0 and gem_state[i] == ForgeData.GemState.CanInLay then
			ForgeData.Instance:SetCanInLayStoneIndex(i - 1)
			is_all_inlay = false
			break
		end
	end

	-- 找到等级最低的宝石位置
	local stone_id = 999999
	local index = 0
	if is_all_inlay then
		for i = 1, 8 do
			if gem_state[i] == ForgeData.GemState.HasInLay then
				local gem_id = gem_data[i - 1].stone_id
				local best_gem_flag = ForgeData.Instance:GetHasBestGemStone(gem_id)
				if best_gem_flag then
					if gem_data[i - 1].stone_id < stone_id then
						index = i - 1
						stone_id = gem_data[i - 1].stone_id
					end
				end
			end
		end
		ForgeData.Instance:SetCanInLayStoneIndex(index)
	end

	local stone_type = ForgeData.Instance:GetStoneTypeByIndex(self.equip_index)
	local add_per = ShenqiData.Instance:GetJiaChengPer(stone_type)
	local act_num = 0
	local act_str = ""
	if stone_type == SHENBING_ADDPER.SHENBIN_TYPE then
		-- 攻击加成
		act_num = (ShenqiData.Instance:GetShenBingActvityNum() * add_per) / 100
		act_str = Language.ShenQiAddPer[SHENBING_ADDPER.SHENBIN_TYPE]
	elseif stone_type == SHENBING_ADDPER.BAOJIA_TYPE then
		-- 气血加成
		act_num = (ShenqiData.Instance:GetBaoJiaActvityNum() * add_per) / 100
		act_str = Language.ShenQiAddPer[SHENBING_ADDPER.BAOJIA_TYPE]
	elseif stone_type == SHENBING_ADDPER.QILING_TYPE then
		--	防御加成
		local addnum = ShenqiData.Instance:GetShenBingLevel()
		act_num = (addnum * add_per) / 100
		local act_num1 = (ShenqiData.Instance:GetQiLingLevel() * add_per) / 100
		act_num = act_num + act_num1
		act_str = Language.ShenQiAddPer[SHENBING_ADDPER.QILING_TYPE]
	end
	self.jia_num:SetValue(act_num)
	self.jia_type:SetValue(act_str)
end

function ForgeGem:FlushGemAttr()
	local gem_cfg = ForgeData.Instance:GetGemCfgByEquipIndex(self.equip_index)
	local gem_attr = ForgeData.Instance:GetGemAttrByEquipIndex(self.equip_index)

	if nil == next(gem_attr) then
		self:ResetAttr()
		return
	end

	self.attr_name:SetValue(Language.Common.AttrNameNoUnderline[gem_cfg.attr_type1] .. "：")
	self.attr_value:SetValue(gem_attr[gem_cfg.attr_type1])
	self.power_name:SetValue(Language.Forge.ZhanLi)
	self.power_value:SetValue(CommonDataManager.GetCapabilityCalculation(gem_attr))

	local total_attr = ForgeData.Instance:GetGemTotalAttr()
	self.total_power:SetValue(CommonDataManager.GetCapabilityCalculation(total_attr))

	self.is_max_level:SetValue(ForgeData.Instance:GetStoneTotalLevel() >= ForgeData.Instance:GetGemMaxLevel())


end

function ForgeGem:FlushLimitText(attr_name)
	if attr_name == "level" or attr_name == "vip_level" then
		ForgeCtrl.Instance:SendStoneInfo()
	end
end

function ForgeGem:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			if v.need_flush == nil or v.need_flush then
				if self.select_index == 1 then
					self.equip_list.scroller:ReloadData(0)
				else
					self.equip_list.scroller:RefreshAndReloadActiveCellViews(true)
				end
			end

			if self.stone_list.scroller.isActiveAndEnabled then
				self.stone_list.scroller:RefreshAndReloadActiveCellViews(true)
			end

			self:FlushEquipCell()
			self:FlushGemStoneCell()
			self:FlushGemAttr()
		end
	end
end

function ForgeGem:ResetAttr()
	self.attr_name:SetValue("")
	self.attr_value:SetValue("")
	self.power_name:SetValue("")
	self.power_value:SetValue(0)
end

function ForgeGem:SetCanInLayState(state)
	self.is_can_inlay = state
end

function ForgeGem:GetCanInLayState()
	return self.is_can_inlay
end

------------------------GemItemCell------------------------------
GemItemCell = GemItemCell or BaseClass(BaseCell)

function GemItemCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
	self.name = self:FindVariable("name")
	-- self.level = self:FindVariable("level")
	self.show_hl = self:FindVariable("show_hl")
	self.show_red_point = self:FindVariable("show_red_point")

	self.gem_path_list = {}
	self.is_show_gem_list = {}
	self.gem_obj_list = {}
	for i = 1, stone_num do
		self.gem_path_list[i] = self:FindVariable("gem_path_" .. i)
		self.is_show_gem_list[i] = self:FindVariable("is_show_gem_" .. i)
		self.gem_obj_list[i] = self:FindObj("Gam" .. i)
	end

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function GemItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function GemItemCell:ClickItem()
	local select_index = self.parent_view:GetSelectIndex()
	self.parent_view:SetSelectIndex(self.index, self.data.index)
	self.parent_view:FlushAllHL()
	self.parent_view:Flush("all", {need_flush = false})
end

function GemItemCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	local cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.name:SetValue(cfg.name)
	self.item_cell:SetData({item_id = self.data.item_id, num = self.data.num, is_bind = self.data.is_bind})

	local equip_strength_level, cur_level, total_level = ForgeData.Instance:GetLevelCfgByStrengthLv(self.data.index, self.data.param.strengthen_level)

	local type_list = ForgeData.Instance:GetCurGemTypeListByIndex(self.data.index)
	local gem_state = ForgeData.Instance:GetGemStateByEquipData(self.data)
	table.sort(gem_state,function(a,b)
		return a > b
	end)
	local gem_info = ForgeData.Instance:GetGemInfo()
	local cur_gem_info = gem_info[self.data.index]
	local item_color_table = {}
	for i = 1, stone_num  do
		local item_cfg = ItemData.Instance:GetItemConfig(cur_gem_info[i - 1].stone_id) or {}
		local item_cfg_color = item_cfg.color or 0
		table.insert(item_color_table,item_cfg_color)
	end
	table.sort(item_color_table, function(a,b)
		return a > b
	end )
	for i = 1, stone_num do
		local bundle, asset = ResPath.GetForgeImg("stone_0")	
		bundle, asset = ResPath.GetForgeImg("stone_" .. item_color_table[i])

		self.is_show_gem_list[i]:SetValue(gem_state[i] ~= ForgeData.GemState.Lock)
		if self.gem_obj_list[i] ~= nil and gem_state[i] ~= ForgeData.GemState.Lock then
			self.gem_obj_list[i]:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(bundle, asset, function()
				self.gem_obj_list[i]:GetComponent(typeof(UnityEngine.UI.Image)):SetNativeSize()
			end)
		end
	end

	self:FlushHL()
	self.show_red_point:SetValue(ForgeData.Instance:GetGemRemindByIndex(self.data.index))
end

function GemItemCell:FlushHL()
	local select_index = self.parent_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end

------------------------GemStoneCell------------------------------
GemStoneCell = GemStoneCell or BaseClass(BaseCell)

function GemStoneCell:__init(instance, index, parent_view)
	self.stone_index = index
	self.parent_view = parent_view

	self.is_locked = self:FindVariable("IsLocked")
	self.is_show_attr = self:FindVariable("IsShowAttr")
	self.attr_text = self:FindVariable("attr_text")

	self.improve_button = self:FindObj("ImproveButton")
	self.improve_button.button:AddClickListener(BindTool.Bind(self.ImproveClick, self, index))

	self.gem_icon = self:FindObj("GemIcon")
	self.gem_icon.button:AddClickListener(BindTool.Bind(self.GemIconClick, self, index))

	self.btn_plus = self:FindObj("PlusButton")
	self.btn_plus.button:AddClickListener(BindTool.Bind(self.PlusClick, self, index))

	self.quality_bg = self:FindObj("QualityBg")

	self.is_show_gem_attr = self:FindVariable("IsShowGemAttr")
	self.attr_value = self:FindVariable("attr_value")
end

function GemStoneCell:__delete()
	
end

function GemStoneCell:ImproveClick(index)
	self:PlusClick(index)
end

function GemStoneCell:PlusClick(index)
	local can_inlay, _ = ForgeData.Instance:GetIsCanInLayDataByIndex(self.data.index)

	if can_inlay then
		local data = ForgeData.Instance:GetStoneListByIndex(self.data.index)
		if data[1].cfg then
			local equip_index = self.parent_view:GetEquipIndex()
			local bag_index = ItemData.Instance:GetItemIndex(data[1].item_id)
			ForgeCtrl.Instance:SendStoneInlay(equip_index, index - 1, bag_index, 1)
		end
	else
		local cfg = ForgeData.Instance:GetGemCfgByEquipIndex(self.data.index)
		local gem_cfg = ForgeData.Instance:GetGemCfgByTypeAndLevel(cfg.stone_type, 1)
		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, gem_cfg.item_id, nil, 1)
	end
end

function GemStoneCell:GemIconClick(index)
	local data = ForgeData.Instance:GetStoneListByIndex(self.data.index)
	if data[1].cfg then
		self.parent_view:SetScrollerData(ForgeData.Instance:GetStoneListByIndex(self.data.index))
		self.parent_view:SetSmallGemListValue(true)
		self.parent_view:ShowOrHideGemList(true, index - 1, true)
	else
		self.parent_view:SetSmallGemListValue(false)
		self.parent_view:ShowOrHideGemList(true, index - 1, false)
	end
end

function GemStoneCell:OnFlush()
	self:ClearData()

	if nil == self.data then return end
	--print_error("self.data",self.data)
	local gem_state = ForgeData.Instance:GetGemStateByEquipData(self.data)
	self.is_locked:SetValue(gem_state[self.stone_index] == ForgeData.GemState.Lock)
	self.is_show_attr:SetValue(gem_state[self.stone_index] == ForgeData.GemState.Lock)

	local gem_limit_cfg = ForgeData.Instance:GetGemOpenLimitCfg(self.stone_index - 1)
	self.attr_text:SetValue(string.format(Language.Forge.GemOpenLimit[gem_limit_cfg.limit], gem_limit_cfg.param1))

	local gem_info = ForgeData.Instance:GetGemInfo()
	local gem_data = gem_info[self.data.index] or {}
	local gem_id = gem_data[self.stone_index - 1].stone_id
	if gem_state[self.stone_index] == ForgeData.GemState.HasInLay then
		self.gem_icon:SetActive(true)
		self.gem_icon.image:LoadSprite(ResPath.GetItemIcon(gem_id))
	else
		self.gem_icon:SetActive(false)
	end

	local item_info = ItemData.Instance:GetItemConfig(gem_id)
	if item_info then
		self.quality_bg.image:LoadSprite(ResPath.GetImages("bg_cell_color_" .. item_info.color))
	else
		self.quality_bg.image:LoadSprite(ResPath.GetImages("bg_cell_common"))
	end

	self.btn_plus:SetActive(gem_state[self.stone_index] == ForgeData.GemState.CanInLay)

	local can_inlay, _ = ForgeData.Instance:GetIsCanInLayDataByIndex(self.data.index)
	if gem_state[self.stone_index] == ForgeData.GemState.CanInLay then
		self.improve_button:SetActive(can_inlay)
	elseif gem_state[self.stone_index] == ForgeData.GemState.HasInLay then
		local best_gem_flag = ForgeData.Instance:GetHasBestGemStone(gem_id)
		self.improve_button:SetActive(best_gem_flag)
	end

	local gem_info = ForgeData.Instance:GetGemInfo()
	local equip_index = self.parent_view:GetEquipIndex()
	local gem_attr = ForgeData.Instance:GetGemAttrByEquipIndex(self.data.index)
	local gem_cfg = ForgeData.Instance:GetGemCfg(gem_info[equip_index][self.stone_index - 1].stone_id)
	if gem_cfg then
		--self.attr_value:SetValue(Language.Common.AttrNameNoUnderline[gem_cfg.attr_type1] .. ":" .. gem_cfg.attr_val1)
		self.attr_value:SetValue(string.format(Language.Forge.GemItemStr, Language.Common.AttrNameNoUnderline[gem_cfg.attr_type1], gem_cfg.attr_val1))
		self.is_show_gem_attr:SetValue(gem_state[self.stone_index] ~= ForgeData.GemState.CanInLay)
	end
end

function GemStoneCell:ClearData()
	self.is_locked:SetValue(false)
	self.btn_plus:SetActive(false)
	self.gem_icon:SetActive(false)
	self.improve_button:SetActive(false)
	self.is_show_gem_attr:SetValue(false)
end

------------------------StoneItemCell------------------------------
StoneItemCell = StoneItemCell or BaseClass(BaseCell)

function StoneItemCell:__init()
	self.attr = self:FindVariable("attr")
	self.btn_text = self:FindVariable("btn_text")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))

	self:ListenEvent("ClickInLay", BindTool.Bind(self.ClickInLay, self))
end

function StoneItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function StoneItemCell:ClickInLay()
	if self.data.item_id then
		if not self.parent_view:GetCanInLayState() then return end
		self.parent_view:SetCanInLayState(false)
		local stone_index = ForgeData.Instance:GetCanInLayStoneIndex()
		local bag_index = ItemData.Instance:GetItemIndexByIdAndBind(self.data.item_id, self.data.is_bind)
		ForgeCtrl.Instance:SendStoneInlay(self.parent_view.equip_index, stone_index, bag_index, 1)
	else
		ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
	end
end

function StoneItemCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	local gem_cfg = ForgeData.Instance:GetGemCfg(self.data.item_id or self.data.id)
	self.attr:SetValue(string.format(Language.Forge.AttrValue, Language.Common.AttrNameNoUnderline[gem_cfg.attr_type1], gem_cfg.attr_val1))

	self.item_cell:SetData({item_id = self.data.item_id or self.data.id, is_bind = self.data.is_bind or 0, num = self.data.num or 1})
	self.btn_text:SetValue(self.data.item_id and Language.Forge.XiangQian or Language.Forge.XunBao)
end

------------------------GemScrollerCell----------------------------
GemScrollerCell = GemScrollerCell or BaseClass(BaseCell)

function GemScrollerCell:__init()
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ListenClick(function() end)
	self.gem_name = self:FindVariable("Name")
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleValueChange, self))
end

function GemScrollerCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function GemScrollerCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	local cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.gem_name:SetValue(cfg.name)

	self.item_cell:SetData(self.data)
	if self.parent_view.gem_scroller_select_index == self.data.data_index then
		self.root_node.toggle.isOn = false
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end
end

function GemScrollerCell:OnToggleValueChange(is_on)
	if is_on then
		self.parent_view.gem_scroller_select_index = self.data.data_index
		-- self.parent:SetSelectGemBagIndex(self.data.index)
	end
end

-------------GemAttrTips--------------------------------
GemAttrTips = GemAttrTips or BaseClass(BaseCell)

function GemAttrTips:__init()
	self.cur_attr_value = self:FindVariable("cur_attr_value")
	self.next_attr_value = self:FindVariable("next_attr_value")
	self.cur_level = self:FindVariable("cur_level")
	self.next_level = self:FindVariable("next_level")
	self.cur_power = self:FindVariable("cur_power")
	self.next_power = self:FindVariable("next_power")
end

function GemAttrTips:__delete()

end

function GemAttrTips:OnFlush()
	local level = ForgeData.Instance:GetStoneTotalLevel()
	local cur_cfg, next_level, next_cfg = ForgeData.Instance:GetGemAddCfgAndNextLevel()

	self.cur_level:SetValue(level)
	self.next_level:SetValue(next_level)
	self.cur_attr_value:SetValue(cur_cfg.per_pvp_hurt_increase / 100 .. "%")
	self.next_attr_value:SetValue(next_cfg.per_pvp_hurt_increase / 100 .. "%")
	self.cur_power:SetValue(CommonDataManager.GetCapabilityCalculation(cur_cfg))
	self.next_power:SetValue(CommonDataManager.GetCapabilityCalculation(next_cfg))
end
