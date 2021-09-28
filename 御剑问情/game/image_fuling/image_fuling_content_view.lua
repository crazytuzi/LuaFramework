ImageFuLingContentView = ImageFuLingContentView or BaseClass(BaseRender)

function ImageFuLingContentView:__init(instance)
	if instance == nil then
		return
	end

	self.cur_fuling_type = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT

	self.item_list = {}
	for i = 1, GameEnum.IMG_FULING_SLOT_COUNT do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item"..i))
		self.item_list[i]:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		self.item_list[i]:SetInteractable(true)
		self.item_list[i]:ShowQuality(false)
		self.item_list[i]:SetCellLock(true)
		self.item_list[i].root_node.transform:SetLocalScale(0.8, 0.8, 0.8)
	end

	self.cell_list = {}
	self.list_view = self:FindObj("list_view")
	self.list_view_delegate = self.list_view.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.list_view.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)

	self.button_obj = self:FindObj("btn_uplevel")
	self.btn_text = self:FindVariable("btn_text")
	self.is_max = self:FindVariable("is_max")

	self:ListenEvent("OnOpenItemWindow", BindTool.Bind(self.OnOpenItemWindow, self))
	self:ListenEvent("OnCloseItemWindow", BindTool.Bind(self.OnCloseItemWindow, self))
	self:ListenEvent("OnSelectAllItem", BindTool.Bind(self.OnSelectAllItem, self))
	self:ListenEvent("OnUpLevel", BindTool.Bind(self.OnUpLevel, self))
	self:ListenEvent("OnOpenHelp", BindTool.Bind(self.OnOpenHelp, self))

	self.skill_name = self:FindVariable("SkillName")
	self.skill_icon = self:FindVariable("SkillIcon")
	self.skill_desc = self:FindVariable("SkillDesc")
	self.skill_active_desc = self:FindVariable("SkillActiveDesc")
	self.level_prog_text = self:FindVariable("Levelprog")
	self.level_prog_value = self:FindVariable("LevelprogValue")
	self.fuling_name = self:FindVariable("FuLingName")
	self.fuling_level = self:FindVariable("FuLingLevel")

	self.maxhp = self:FindVariable("MaxHp")
	self.gongji = self:FindVariable("GongJi")
	self.fangyu = self:FindVariable("FangYu")
	self.mingzhong = self:FindVariable("MingZhong")
	self.shanbi = self:FindVariable("ShanBi")
	self.baoji = self:FindVariable("BaoJi")
	self.kangbao = self:FindVariable("KangBao")

	self.maxhp_add = self:FindVariable("MaxHp_Add")
	self.gongji_add = self:FindVariable("GongJi_Add")
	self.fangyu_add = self:FindVariable("FangYu_Add")
	self.mingzhong_add = self:FindVariable("MingZhong_Add")
	self.shanbi_add = self:FindVariable("ShanBi_Add")
	self.baoji_add = self:FindVariable("BaoJi_Add")
	self.kangbao_add = self:FindVariable("KangBao_Add")

	self.systemattr = self:FindVariable("SystemAttr")
	self.systemattr_add = self:FindVariable("SystemAttr_Add")

	self.is_max_level = self:FindVariable("IsMaxLevel")
	self.capability = self:FindVariable("Capability")

	self.is_show_maxhp = self:FindVariable("is_show_maxhp")
	self.is_show_gongji = self:FindVariable("is_show_gongji")
	self.is_show_fangyu = self:FindVariable("is_show_fangyu")
	self.is_show_mingzhong = self:FindVariable("is_show_mingzhong")
	self.is_show_shanbi = self:FindVariable("is_show_shanbi")
	self.is_show_baoji = self:FindVariable("is_show_baoji")
	self.is_show_kangbao = self:FindVariable("is_show_kangbao")

	self.raw_background = self:FindVariable("RawBackground")
	self.raw_image = self:FindObj("raw_image")

	self.tip_window = self:FindObj("tip_window")

	self.select_stuff_cache_list = {}
	self.is_show_item_window = self:FindVariable("IsShowItemWindow")
	self.scroller_window = self:FindObj("item_scroll")
	self.add_function = BindTool.Bind(self.AddSelectList, self)
	self.last_flush_window_time = Status.NowTime
	self:InitScrollerWindow()

	self.is_cell_active = false
	self.is_scroll_create = false
end

function ImageFuLingContentView:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.cell_window_list) do
		v:DeleteMe()
	end
	self.cell_window_list = {}

	self.list_view = nil
	self.skill_icon = nil
	self.skill_desc = nil
	self.skill_active_desc = nil
	self.level_prog_text = nil
	self.level_prog_value = nil
	self.fuling_name = nil

	self.maxhp = nil
	self.gongji = nil
	self.fangyu = nil
	self.mingzhong = nil
	self.shanbi = nil
	self.baoji = nil
	self.kangbao = nil

	self.maxhp_add = nil
	self.gongji_add = nil
	self.fangyu_add = nil
	self.mingzhong_add = nil
	self.shanbi_add = nil
	self.baoji_add = nil
	self.kangbao_add = nil

	self.systemattr = nil
	self.systemattr_add = nil

	self.is_max_level = nil
	self.capability = nil

	self.is_show_maxhp = nil
	self.is_show_gongji = nil
	self.is_show_fangyu = nil
	self.is_show_mingzhong = nil
	self.is_show_shanbi = nil
	self.is_show_baoji = nil
	self.is_show_kangbao = nil

	self.raw_background = nil
	self.raw_image = nil
	self.is_cell_active = false

	self:RemoveWindowDelayTime()

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

function ImageFuLingContentView:RemoveWindowDelayTime()
	if self.window_delay_time then
		GlobalTimerQuest:CancelQuest(self.window_delay_time)
		self.window_delay_time = nil
	end
end

function ImageFuLingContentView:InitScrollerWindow()
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

function ImageFuLingContentView:GetWindowNumberOfCells()
	return 20
end

function ImageFuLingContentView:GetCellSize(data_index)
	return 96
end

function ImageFuLingContentView:GetWindowCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.window_enhanced_cell_type)

	local cell = self.cell_window_list[cell_view]
	if cell == nil then
		self.cell_window_list[cell_view] = FuLingScrollItemCell.New(cell_view)
		cell = self.cell_window_list[cell_view]
		cell:SetClickFunc(self.add_function)
	end

	local data = self:GetItemPanelData(self.window_item_list, data_index + 1, 4, 4)
	cell:SetData(data)
	return cell_view
end

function ImageFuLingContentView:ClearSelectList()
	for k,v in pairs(self.select_stuff_cache_list) do
		v.is_select = false
	end
	self.select_stuff_cache_list = {}
end

function ImageFuLingContentView:AddSelectList(data, switch)
	if data and data.item_id then
		self.select_stuff_cache_list[data] = switch and data or nil
	end

	local add_exp = 0
	for k,v in pairs(self.select_stuff_cache_list) do
		local stuff_cfg = ImageFuLingData.Instance:GetFuLingStuffItemConfig(self.cur_fuling_type, v.item_id)
		add_exp = add_exp + stuff_cfg.add_exp
	end

	local info = ImageFuLingData.Instance:GetImgFuLingData(self.cur_fuling_type)
	local level_cfg = ImageFuLingData.Instance:GetImgFuLingLevelCfg(self.cur_fuling_type, info.level)
	local add_str = add_exp > 0 and string.format(Language.Common.ToColor, TEXT_COLOR.YELLOW, "+" .. add_exp) or ""

	-- if   (info.cur_exp~=nil or info.cur_exp~=0) and (level_cfg.exp~=nil or level_cfg.exp~=0) then
		self.level_prog_text:SetValue(info.cur_exp .. add_str .. "/" .. level_cfg.exp)
	-- end
end

function ImageFuLingContentView:OnOpenItemWindow()
	self.is_show_item_window:SetValue(true)
	self:ClearSelectList()
	self:OnFlushItemWindow()
end

function ImageFuLingContentView:OnCloseItemWindow()
	self.tip_window.animator:SetBool("show", false)
	self.tip_window.animator:WaitEvent("exit", function(param)
			self.is_show_item_window:SetValue(false)
			self:ClearSelectList()
			self:OnFlushAll()
			self:OnFlushItemWindow()
		end)

	-- self.is_show_item_window:SetValue(false)
	-- self:ClearSelectList()
	-- self:OnFlushAll()
	-- self:OnFlushItemWindow()
end

function ImageFuLingContentView:OnSelectAllItem()
	for k,v in pairs(self.window_item_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			v.is_select = true
			self:AddSelectList(v, true)
		end
	end
	self:FlushHighLight()
end

function ImageFuLingContentView:FlushHighLight()
	for k,v in pairs(self.cell_window_list) do
		v:FlushHighLight()
	end
end

function ImageFuLingContentView:OnOpenHelp()
	local tips_id = 236
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ImageFuLingContentView:OnUpLevel()
	if nil == next(self.select_stuff_cache_list) then
		SysMsgCtrl.Instance:ErrorRemind(Language.MagicCard.InputUpgrade)
		return
	end

	for k,v in pairs(self.select_stuff_cache_list) do
		local stuff_cfg = ImageFuLingData.Instance:GetFuLingStuffItemConfig(self.cur_fuling_type, v.item_id)
		if nil ~= stuff_cfg then
			ImageFuLingCtrl.Instance:SendImgFuLingUpLevelReq(self.cur_fuling_type, stuff_cfg.stuff_index or 0)
		end
	end

	self:OnCloseItemWindow()
end

function ImageFuLingContentView:OnClickItem(img_index)
	local close_call_back = function() self.item_list[img_index]:SetHighLight(false) end

	local item_id = ImageFuLingData:GetSpecialImageActiveItemId(self.cur_fuling_type, img_index)
	local info = ImageFuLingData.Instance:GetImgFuLingData(self.cur_fuling_type)
	if info.img_id_list[img_index] <= 0 then
		close_call_back()
		SysMsgCtrl.Instance:ErrorRemind(Language.Advance.UnlockFuLing)
		return
	end

	TipsCtrl.Instance:OpenItem(self.item_list[img_index]:GetData(), nil, nil, close_call_back)
end

function ImageFuLingContentView:OpenCallBack()
	self:Flush()
end

function ImageFuLingContentView:CloseCallBack()
	self.cur_fuling_type = IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_MOUNT
end

function ImageFuLingContentView:ItemDataChangeCallback()
	if self.list_view then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function ImageFuLingContentView:OnFlush(param_t)
	if self.list_view then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:OnFlushAll()
end

function ImageFuLingContentView:GetNumberOfCells()
	return GameEnum.IMG_FULING_JINGJIE_TYPE_MAX - 1
end

function ImageFuLingContentView:RefreshView(cell, data_index)
	local fuling_type_cell = self.cell_list[cell]
	if fuling_type_cell == nil then
		fuling_type_cell = ImageFuLingTypeCell.New(cell.gameObject, self)
		fuling_type_cell.root_node.toggle.group = self.list_view.toggle_group
		self.cell_list[cell] = fuling_type_cell
	end

	local data_list = ImageFuLingData.Instance:GetFuLingTabInfoList()
	fuling_type_cell:SetData(data_list[data_index + 1])
	
	self.is_cell_active = true
end

function ImageFuLingContentView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if not self.is_scroll_create then
		if self.is_cell_active and self.list_view and self.list_view.scroller.isActiveAndEnabled then
			self.list_view.scroller:JumpToDataIndex(self.cur_fuling_type)
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
			self.is_scroll_create = true
		end
	end
end

function ImageFuLingContentView:GetItemPanelData(item_list, index, row, column)
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
	end
	return list
end

function ImageFuLingContentView:SetCurSelectIndex(fuling_type, is_jump)
	if nil == fuling_type then
		return
	end

	self.cur_fuling_type = fuling_type
	self:OnFlushAll()
	self:OnFlushItemWindow()

	if is_jump and self.is_cell_active and self.is_scroll_create and self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:JumpToDataIndex(fuling_type)
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function ImageFuLingContentView:GetCurSelectIndex()
	return self.cur_fuling_type
end

function ImageFuLingContentView:OnFlushItemWindow()
	if self.last_flush_window_time + 0.1 <= Status.NowTime then
		self.last_flush_window_time = Status.NowTime

		self.window_item_list = ImageFuLingData.Instance:GetCanConsumeStuff(self.cur_fuling_type)
		if self.scroller_window.scroller.isActiveAndEnabled then
			self.scroller_window.scroller:RefreshAndReloadActiveCellViews(true)
		end
	else
		self.last_flush_window_time = Status.NowTime
		self:RemoveWindowDelayTime()
		self.window_delay_time = GlobalTimerQuest:AddDelayTimer(function() self:OnFlushItemWindow() end, 0.2)
	end
end

function ImageFuLingContentView:OnFlushAll()
	self.skill_icon:SetAsset(ResPath.ImgFuLingSkillIcon(self.cur_fuling_type))
	self.raw_background:SetAsset(ResPath.ImgFuLingTypeRawImage(self.cur_fuling_type))

	local info = ImageFuLingData.Instance:GetImgFuLingData(self.cur_fuling_type)
	if nil == info then
		return
	end

	local skill_cfg = ImageFuLingData.Instance:GetImgFuLingSkillLevelCfg(self.cur_fuling_type, info.skill_level)
	local skill_desc = skill_cfg.description
	skill_desc = string.gsub(skill_desc, "%[param_a]", tonumber(skill_cfg.param_a))
	skill_desc = string.gsub(skill_desc, "%[param_b]", tonumber(skill_cfg.param_b))
	skill_desc = string.gsub(skill_desc, "%[param_c]", tonumber(skill_cfg.param_c / 1000))
	skill_desc = string.gsub(skill_desc, "%[param_d]", tonumber(skill_cfg.param_d / 1000))
	skill_desc = string.gsub(skill_desc, "%[param_e]", tonumber(skill_cfg.param_e))
	self.skill_desc:SetValue(skill_desc)
	self.skill_name:SetValue(skill_cfg.skill_name .. " LV." .. info.skill_level)

	local next_skill_cfg = ImageFuLingData.Instance:GetImgFuLingSkillLevelCfg(self.cur_fuling_type, info.skill_level + 1)
	if next_skill_cfg then
		local tag = info.skill_level <= 0 and Language.Advance.JiHuo or Language.Advance.ShengJi
		self.skill_active_desc:SetValue(string.format(Language.Advance.SkillActiveDesc, next_skill_cfg.img_count_limit, tag))
	else
		self.skill_active_desc:SetValue(Language.Advance.SkillMaxLevel)
	end
	self.fuling_level:SetValue(info.level)

	local level_cfg = ImageFuLingData.Instance:GetImgFuLingLevelCfg(self.cur_fuling_type, info.level)
	-- local last_level_cfg=ImageFuLingData.Instance:GetImgFuLingLevelCfg(self.cur_fuling_type, info.level-1)
	local level_attr = CommonDataManager.GetAttributteByClass(level_cfg)

	self.maxhp:SetValue(level_cfg and level_attr.max_hp or 0)
	self.gongji:SetValue(level_cfg and level_attr.gong_ji or 0)
	self.fangyu:SetValue(level_cfg and level_attr.fang_yu or 0)
	self.mingzhong:SetValue(level_cfg and level_attr.ming_zhong or 0)
	self.shanbi:SetValue(level_cfg and level_attr.shan_bi or 0)
	self.baoji:SetValue(level_cfg and level_attr.bao_ji or 0)
	self.kangbao:SetValue(level_cfg and level_attr.jian_ren or 0)
	self.systemattr:SetValue(level_cfg and level_cfg.per_add / 100 or 0)


	self.level_prog_text:SetValue(info.cur_exp .. " / " .. level_cfg.exp)
	self.level_prog_value:SetValue(info.cur_exp / level_cfg.exp)

	local next_level_cfg = ImageFuLingData.Instance:GetImgFuLingLevelCfg(self.cur_fuling_type, info.level + 1)
	self.is_max_level:SetValue(nil == next_level_cfg)
	self.button_obj.button.interactable = nil ~= next_level_cfg
	self.is_max : SetValue(false)
	self.btn_text:SetValue(nil == next_level_cfg and Language.Common.YiManJi or Language.Common.UpGrade)
	if nil == next_level_cfg then
		self.is_max : SetValue(true)
	end
	local next_level_attr = CommonDataManager.GetAttributteByClass(next_level_cfg)
	local dif_attr = CommonDataManager.LerpAttributeAttr(level_attr, next_level_attr)
	if nil ~= next_level_cfg then
		self.maxhp_add:SetValue(dif_attr.max_hp)
		self.gongji_add:SetValue(dif_attr.gong_ji)
		self.fangyu_add:SetValue(dif_attr.fang_yu)
		self.mingzhong_add:SetValue(dif_attr.ming_zhong)
		self.shanbi_add:SetValue(dif_attr.shan_bi)
		self.baoji_add:SetValue(dif_attr.bao_ji)
		self.kangbao_add:SetValue(dif_attr.jian_ren)

		local pre_add = level_cfg and level_cfg.per_add or 0
		self.systemattr_add:SetValue((next_level_cfg.per_add - pre_add) / 100)
	else
  		--如果当前等级大于等于最高级，则显示目前最高经验
		self.level_prog_text:SetValue("已满级")
		self.level_prog_value:SetValue(1)
	end

	self.is_show_maxhp:SetValue((nil ~= level_cfg and level_cfg.maxhp > 0) or (nil ~= next_level_cfg and next_level_cfg.maxhp > 0))
	self.is_show_gongji:SetValue((nil ~= level_cfg and level_cfg.gongji > 0) or (nil ~= next_level_cfg and next_level_cfg.gongji > 0))
	self.is_show_fangyu:SetValue((nil ~= level_cfg and level_cfg.fangyu > 0) or (nil ~= next_level_cfg and next_level_cfg.fangyu > 0))
	self.is_show_mingzhong:SetValue((nil ~= level_cfg and level_cfg.mingzhong > 0) or (nil ~= next_level_cfg and next_level_cfg.mingzhong > 0))
	self.is_show_shanbi:SetValue((nil ~= level_cfg and level_cfg.shanbi > 0) or (nil ~= next_level_cfg and next_level_cfg.shanbi > 0))
	self.is_show_baoji:SetValue((nil ~= level_cfg and level_cfg.baoji > 0) or (nil ~= next_level_cfg and next_level_cfg.baoji > 0))
	self.is_show_kangbao:SetValue((nil ~= level_cfg and level_cfg.jianren > 0) or (nil ~= next_level_cfg and next_level_cfg.jianren > 0))

	self.fuling_name:SetValue(Language.Advance.FuLingTabName1[self.cur_fuling_type])

	for i = 1, GameEnum.IMG_FULING_SLOT_COUNT do
		local img_id = info.img_id_list[i]
		if nil ~= img_id and img_id > 0 then
			self.item_list[i]:ShowQuality(true)
		else
			self.item_list[i]:ShowQuality(false)
			self.item_list[i]:SetData(nil)
			self.item_list[i]:SetCellLock(true)
		end

		local item_id = ImageFuLingData:GetSpecialImageActiveItemId(self.cur_fuling_type, img_id)
		if nil ~= item_id then
			self.item_list[i]:SetData({item_id = item_id, num = 1, is_bind = false})
		end
	end

	local extra_cap = ImageFuLingData.Instance:GetFuLingExtraCapabilityByType(self.cur_fuling_type, info.level)
	local capability = ImageFuLingData.Instance:GetImgFuLingCapability(self.cur_fuling_type, info.level)
	self.capability:SetValue(capability + extra_cap)
end

-----------------------ImageFuLingTypeCell-----------------

ImageFuLingTypeCell = ImageFuLingTypeCell or BaseClass(BaseCell)
function ImageFuLingTypeCell:__init(instance, parent)
	self.parent = parent
	self.show_red_point = self:FindVariable("show_red_point")
	self.type_icon = self:FindVariable("type_icon")
	self.type_name = self:FindVariable("type_name")

	self:ListenEvent("OnItemClick", BindTool.Bind(self.OnItemClick, self))
end

function ImageFuLingTypeCell:__delete()
	self.parent = nil
	self.show_red_point = nil
	self.type_icon = nil
	self.type_name = nil
end

function ImageFuLingTypeCell:OnFlush()
	if nil == self.data then
		return
	end

	self.data = self.data > 1 and self.data +1 or self.data 
	self.root_node.toggle.isOn = self.parent:GetCurSelectIndex() == self.data

	self.type_icon:SetAsset(ResPath.GetImgFuLingTypeIcon(self.data))
	self.type_name:SetValue(Language.Advance.FuLingTabName[self.data])

	local item_list = ImageFuLingData.Instance:GetCanConsumeStuff(self.data)
	self.show_red_point:SetValue(#item_list > 0)
end

function ImageFuLingTypeCell:OnItemClick()
	self.parent:SetCurSelectIndex(self.data)
end

-------------------------------------------------------- FuLingScrollItemCell ----------------------------------------------------------

FuLingScrollItemCell = FuLingScrollItemCell or BaseClass(BaseCell)

function FuLingScrollItemCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

	self.item_list = {}
	self.old_data = nil
	for i = 1, 4 do
		self.item_list[i] = {}
		self.item_list[i].obj = self:FindObj("ItemCell" .. i)
		self.item_list[i].cell = ItemCell.New()
		self.item_list[i].cell:SetInstanceParent(self.item_list[i].obj)
		self.item_list[i].cell:IsDestroyEffect(true)
		local func = function ()
			if self.data[i].item_id == nil then
				self.item_list[i].cell:SetHighLight(false)
				return
			end
			TipsCtrl.Instance:OpenItem(self.data[i], self.form_type, nil, function() self.item_list[i].cell:SetHighLight(false) end)
		end
		self.item_list[i].cell:ListenClick(func)
	end
end

function FuLingScrollItemCell:__delete()
	for k,v in pairs(self.item_list) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_list = {}
end

function FuLingScrollItemCell:SetToggleGroup(toggle_group)
	for i = 1, 4 do
		self.item_list[i].cell:SetToggleGroup(toggle_group)
	end
end

function FuLingScrollItemCell:OnFlush()
	for i = 1, 4 do
		local data = self.data[i]
		self:FLushCell(i, data)
	end
end

function FuLingScrollItemCell:FLushCell(i, data)
	self.item_list[i].cell:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local gamevo = GameVoManager.Instance:GetMainRoleVo()

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

function FuLingScrollItemCell:SetClickFunc(func)
	if func then
		for i = 1, 4 do
			local cell = self.item_list[i].cell
			cell:ListenClick(BindTool.Bind(self.SelectFunc, self, i, func))
		end
	end
end

function FuLingScrollItemCell:SelectFunc(i, func)
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

function FuLingScrollItemCell:FlushHighLight()
	for i = 1, 4 do
		local data = self.data[i]
		if data and data.is_select then
			self.item_list[i].cell:SetHighLight(true)
		else
			self.item_list[i].cell:SetHighLight(false)
		end
	end
end
