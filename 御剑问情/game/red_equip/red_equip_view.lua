RedEquipView = RedEquipView or BaseClass(BaseRender)
local BAG_ROW = 3
local BAG_COLUMN = 3
local MAX_EQUIP = 10
local RED_LEVEL = 5

local Defult_Icon_List =
	{
		[1] = "icon_toukui",
		[2] = "icon_yifu",
		[3] = "icon_kuzi",
		[4] = "icon_xiezi",
		[5] = "icon_hushou",
		[6] = "icon_xianglian",
		[7] = "icon_wuqi",
		[8] = "icon_jiezhi",
		[9] = "icon_yaodai",
		[10] = "icon_jiezhi",
		[11] = "icon_gouyu",
		[12] = "icon_gouyu2",
	}

function RedEquipView:__init()
	-- self.ui_config = {"uis/views/redequipview_prefab","RedEquipView"}
	-- self.play_audio = true
	self.cur_select = 0
	self.level_list_cell = {}
	self.scroller_list_cell = {}
	self.cells = {}
	self.tips_text_list = {}
	self.attr_text_list = {}
	self.item_image_list = {}
	self.select_cell_index = 0

	self:ListenEvent("Close", BindTool.Bind(self.CloseView,self))
	self:ListenEvent("AttributeTip", BindTool.Bind(self.HandleAttributeTip, self))
	self:ListenEvent("CloseAttributeTip", BindTool.Bind(self.CloseAttributeTip, self))
	self:ListenEvent("GoGet",BindTool.Bind(self.OnGotoGet, self))
	self:ListenEvent("CloseGemList", BindTool.Bind(self.CloseOrHideGemList, self))
	self:ListenEvent("OnClickCloss", BindTool.Bind(self.OnClickCloss, self))
	self:ListenEvent("OnClickHuanXing", BindTool.Bind(self.OnClickHuanXing, self))
	self:ListenEvent("OnClickTitle", BindTool.Bind(self.OnClickTitle, self))


	self.fight_power = self:FindVariable("FightPower")
	self.show_attribute_tip = self:FindVariable("ShowAttributeTip")
	self.is_show_gemlist = self:FindVariable("IsShowGemList")
	self.show_image = self:FindVariable("ShowImage")
	self.progress_text = self:FindVariable("Progress_text")
	self.progress = self:FindVariable("Progress")
	self.item_group = self:FindObj("item_list")
	self.title_gray = self:FindVariable("title_gray")
	self.button_gray = self:FindVariable("button_gray")
	self.button_text = self:FindVariable("button_text")
	self.title_img = self:FindVariable("title_img")
	self.add_per = self:FindVariable("add_per")
	-- self.is_show_small = self:FindVariable("IsShowSmallGemList")
	for i = 1, 2 do
		self.tips_text_list[i] = self:FindVariable("TipsText" .. i)
	end
	for i = 1, 2 do
		local text = self:FindObj("Text"..i)
		local attr = text:FindObj("Attr")
		local tips = text:FindObj("Tips")
		self.attr_text_list[i] = {text = text, attr = attr, tips = tips}
	end

	for i = 1, MAX_EQUIP do
		self.item_image_list[i] = self:FindVariable("ItemImage"..i)
	end

	-- local bunble, asset = ResPath.GetImages("bg_cell_equip")
	PrefabPool.Instance:Load(AssetID("uis/views/redequipview_prefab","RedEquipItem"),
		function(prefab)
			for i = 1, MAX_EQUIP do
				local obj = GameObject.Instantiate(prefab)
				-- obj.transform:SetParent(equip_parent.transform, false)
				obj = U3DObject(obj)
				local item = RedEquipItemCell.New(obj)
				item:SetInstanceParent(self:FindObj("Item"..i))
				item.root_node.toggle.group = self.item_group.toggle_group
				item:SetIcon(ResPath.GetEquipShadowDefualtIcon(Defult_Icon_List[i]))
				item:SetQuality(-1)
				-- item:SetDefualtBgState(false)
				-- item:ShowQuality(false)
				-- item:SetIconGrayScale(false)
				-- item:SetIsShowGrade(false)
				self.cells[i] = item
			end
			PrefabPool.Instance:Free(prefab)
			self:Flush()
		end)
	-- local bunble, asset = ResPath.GetImages("bg_cell_equip")
	-- for i = 1, MAX_EQUIP do
	-- 	local item = ItemCell.New()
	-- 	item:SetInstanceParent(self:FindObj("Item"..i))
	-- 	item:SetItemCellBg(bunble, asset)
	-- 	item:ShowQuality(false)
	-- 	item:SetIconGrayScale(false)
	-- 	item:SetIsShowGrade(false)
	-- 	self.cells[i] = item
	-- end

	-- self.money = MoneyBar.New()
	-- self.money:SetInstanceParent(self:FindObj("MoneyBar"))

	self.display = self:FindObj("Display")
	self.page_toggle1 = self:FindObj("PageToggle1")

	self.level_list = self:FindObj("ListView")

	self.list_data = RedEquipData.Instance:GetOtherInfo()
	local level_list_delegate = self.level_list.list_simple_delegate
	self.list_num = #self.list_data
	--生成数量
	level_list_delegate.NumberOfCellsDel = function()
		for i=0,self.list_num do
			local flag = RedEquipData.Instance:GetActiveFlag(i)
			if flag ~= 1 then
				return i + 1
			end
		end
		return self.list_num + 1
	end
	level_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNameListView, self)

	self:FlushModel()
	self:InitScroller()
	self:Flush()
end

function RedEquipView:__delete()
	for i,v in ipairs(self.level_list_cell) do
		v:DeleteMe()
	end
	self.level_list_cell = {}

	for i,v in ipairs(self.scroller_list_cell) do
		v:DeleteMe()
	end
	self.scroller_list_cell = {}

	self.level_list = nil
	self.scroller_list = nil
	self.display = nil
	self.fight_power = nil
	self.show_attribute_tip = nil
	self.enhanced_cell_type = nil
	self.small_list_view_delegate = nil
	self.is_show_gemlist = nil
	self.page_count = nil
	self.page_toggle1 = nil
	self.show_image = nil
	self.progress_text = nil
	self.progress = nil
	self.item_group = nil
	self.title_gray = nil
	self.button_gray = nil
	self.button_text = nil
	self.title_img = nil
	-- self.is_show_small = nil

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end

	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}

	self.tips_text_list = {}
	self.attr_text_list = {}
	self.item_image_list = {}
	self.cur_select = 0
	RedEquipScrollerCell.SelectEquipIndex = 0
end

function RedEquipView:OpenCallBack()

end

function RedEquipView:RefreshNameListView(cell,data_index)
	local icon_cell = self.level_list_cell[cell]
	if nil == icon_cell then
		icon_cell = RedEquipItem.New(cell.gameObject)
		icon_cell:SetToggleGroup(self.level_list.toggle_group, data_index == self.cur_select)
		icon_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.level_list_cell[cell] = icon_cell
		RedEquipItem.SelectLevelIndex = self.cur_select
	end
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local data = RedEquipData.Instance:GetProfOtherInfo(data_index,role_vo.prof)
	icon_cell:SetIndex(data_index)
	icon_cell:SetData(data)
	data_index = data_index + 1
end

--初始化装备滚动条
function RedEquipView:InitScroller()
	local equip_data = RedEquipData.Instance:GetEquipItemCfg(self.cur_select)
	self.equip_list = RedEquipData.Instance:GetRedEquipList(equip_data[1])
	self.page_count = self:FindVariable("PageCount")
	self.scroller_list = self:FindObj("Scroller")
	local reward_list_delegate = self.scroller_list.list_simple_delegate
	reward_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	reward_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function RedEquipView:RefreshCell(cell,data_index)
	local grounp_cell = self.scroller_list_cell[cell]
	if not grounp_cell then
		grounp_cell = RedEquipScrollerCell.New(cell.gameObject)
		grounp_cell:SetToggleGrounp(self.scroller_list.toggle_group)
		self.scroller_list_cell[cell] = grounp_cell
	end
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN  + column + (page * grid_count)
		local data = self.equip_list[index + 1]
		grounp_cell:SetData(data, i, index)
		grounp_cell:ListenClick(BindTool.Bind(self.OnClickSubCallBack, self, index, data, grounp_cell, i), i)
	end
end

function RedEquipView:GetNumberOfCells()
	local num = math.ceil(#self.equip_list/(BAG_ROW*BAG_COLUMN)) * BAG_COLUMN
	return num == 0 and 3 or num
end

function RedEquipView:FlushEquipList()
	local page = math.ceil(#self.equip_list/(BAG_ROW*BAG_COLUMN))
	page = page < 1 and 1 or page
	self.page_toggle1.toggle.isOn = true
	RedEquipScrollerCell.SelectEquipIndex = 0
	self.page_count:SetValue(page)
	self.scroller_list.list_page_scroll:SetPageCount(page)
	self.scroller_list.scroller:ReloadData(0)
end

function RedEquipView:OnClickSubCallBack(index, data, cell)
	if nil == data then return end
	self.cur_equip_data = data
	RedEquipScrollerCell.SelectEquipIndex = index
end

function RedEquipView:OnClickCloss()
	self.is_show_gemlist:SetValue(false)
	if nil == self.cur_equip_data or nil == self.list_data[self.cur_select] then return end
	RedEquipCtrl.Instance:SendRedEquipInfo(COMMON_OPERATE_TYPE.COT_REQ_RED_EQUIP_COLLECT_TAKEON, self.list_data[self.cur_select].seq, self.select_cell_index - 1 , self.cur_equip_data.index)
end

function RedEquipView:OnClickHuanXing()
	RedEquipCtrl.Instance:SendRedEquipInfo(COMMON_OPERATE_TYPE.COT_REQ_RED_EQUIP_COLLECT_FETCH_TITEL_REWARD, self.cur_select)
end

function RedEquipView:OnClickTitle()
	local other_cfg = RedEquipData.Instance:GetOtherStar(self.cur_select) or {}
	-- local item_id = other_cfg.reward_title_id or 0
	TipsCtrl.Instance:OpenItem({item_id = other_cfg.reward_title_item})
end

function RedEquipView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data and self.cur_select == cell.index then return end
	self.cur_select = cell.index
	self:SetData()
	self:UpAttrData()
	if RedEquipData.Instance:GetActiveFlag(self.cur_select) ~= 1 then
		local show_tip = self.cur_select == 0 and string.format(Language.RedEquip.RedEquipTips1,self.cur_select + 1) or string.format(Language.RedEquip.RedEquipTips2,self.cur_select + 2)
		SysMsgCtrl.Instance:ErrorRemind(show_tip)
	end
end

function RedEquipView:FlushModel()
	if not self.role_model then
		self.role_model = RoleModel.New("red_equip_panel")
		self.role_model:SetDisplay(self.display.ui3d_display)
	end
	if self.role_model then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.role_model:SetModelResInfo(role_vo, nil, nil, nil, nil, nil)
	end
end

function RedEquipView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "all" then
		end
	end
	self:SetData()
	self:UpAttrData()
	self.level_list.scroller:RefreshAndReloadActiveCellViews(false)
end

function RedEquipView:SetData(equiplist)
	local show_list = RedEquipData.Instance:GetActiveFlag(self.cur_select) ~= 1
	self.show_image:SetValue(not show_list)
    if show_list then
		return
    end
	local equiplist = RedEquipData.Instance:GetEquipSlot(self.cur_select)
	local equip_data = RedEquipData.Instance:GetEquipItemCfg(self.cur_select)
	for k, v in pairs(self.cells) do
		local is_show_tips,flag =  RedEquipData.Instance:GetIsShowTipsImage(self.cur_select, equiplist[k], equip_data[k])
		local yes_equip = true
		if equiplist[k] and equiplist[k].item_id and equiplist[k].item_id > 0 then
			v:SetData(equiplist[k])
			-- v:SetIconGrayScale(false)
			-- v:ShowQuality(true)
		else
			local data = {}
			-- data.is_bind = 0
			-- if equip_data[k] then
			-- 	data.item_id= equip_data[k]
			-- end
			v:SetData(data)
			-- local bundle, asset = ResPath.GetRedEquipImage("equip_" .. k)
			v:SetIcon(ResPath.GetEquipShadowDefualtIcon(Defult_Icon_List[k]))
			-- local bundle, asset = ResPath.GetRedEquipImage("equip_" .. k)
			-- v:SetAsset(bundle, asset)
			v:SetQuality(-1)
			-- v:SetDefualtBgState(false)
			-- v:SetIsShowGrade(false)
			-- v:ShowQuality(false)
			yes_equip = false
		end
		self.item_image_list[k]:SetValue(is_show_tips)
		-- v:SetHighLight(false)
		v:ListenClick(BindTool.Bind(self.OnClickEquipItem, self, k, v, is_show_tips, yes_equip))
	end
end

function RedEquipView:OnClickEquipItem(index, cell, is_show_tips, yes_equip)
	-- cell:SetHighLight(false)?
	if RedEquipData.Instance:GetActiveFlag(self.cur_select) ~= 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.RedEquip.RedEquipTips)
		return
	end
	local equip_data = RedEquipData.Instance:GetEquipItemCfg(self.cur_select)
	local ts_virtual =  RedEquipData.Instance:GetWayItemCfg(self.cur_select , index)
	self.equip_list = RedEquipData.Instance:GetRedEquipList(equip_data[index])
	self.cur_equip_data = self.equip_list[1]
	self.select_cell_index = index
	local close_call_back = function()
		if cell then
			cell:SetHightLight(false)
		end
	end
	if not yes_equip then
		if is_show_tips then
			self:OnClickCloss()
		else
			TipsCtrl.Instance:OpenItem({item_id = ts_virtual}, TipsFormDef.FROM_NOTHING, nil, close_call_back)
		end
	else
		-- self.is_show_small:SetValue(not is_show_tips)
		if RedEquipData.Instance:GetRedEquipIsYes(self.cur_select, equip_data[index]) then

		end
		self.is_show_gemlist:SetValue(true)
		self:FlushEquipList()
		return
		-- TipsCtrl.Instance:OpenItem(cell.data, TipsFormDef.FROM_RED_EQUIP)
		-- TipsCtrl.Instance:OpenItem({item_id = ts_virtual}, TipsFormDef.FROM_NOTHIpoNG, nil, close_call_back)
	end
end

function RedEquipView:UpAttrData()
	local equiplist = RedEquipData.Instance:GetEquipSlot(self.cur_select)
	local other_cfg = RedEquipData.Instance:GetOtherStar(self.cur_select)
	local stars_info = RedEquipData.Instance:GetStarsInfo(self.cur_select)
	local title_state = RedEquipData.Instance:GetTitleActiveFlag(self.cur_select) or 0
	local equip_cfg = RedEquipData.Instance:GetEquipCfg(self.cur_select)
	if nil == other_cfg or nil == equiplist or nil == stars_info then
		return
	end

	local star_num = stars_info.stars
	local equip_num = stars_info.item_count
	-- local item_cfg, big_type = ItemData.Instance:GetItemConfig(other_cfg.reward_title_id or 0)
	local bundle, asset = ResPath.GetTitleIcon(other_cfg.reward_title_id)
	self.title_img:SetAsset(bundle, asset)

	self.progress_text:SetValue(equip_num .. "/" .. 10)
	self.progress:SetValue(equip_num / 10)
	if title_state == 1 then
		self.button_text:SetValue(Language.Activity.ButtonText11)
		self.button_gray:SetValue(true)
		self.title_gray:SetValue(true)
	else
		self.button_text:SetValue(Language.Activity.ButtonText12)
		if equip_num >= 8 then
			self.button_gray:SetValue(false)
			self.title_gray:SetValue(true)
		else
			self.button_gray:SetValue(true)
			self.title_gray:SetValue(false)
		end
	end
	self.add_per:SetValue(other_cfg.star_add_attr_percent)
	local power = 0
	local add_num = star_num * other_cfg.star_add_attr_percent
	self.tips_text_list[1]:SetValue(string.format(Language.RedEquip.RedEquipRedText,star_num) .. "/30")
	self.tips_text_list[2]:SetValue(add_num .. "%")
	for i = 1,2 do
		local index = 1
		if equip_num >= 1 and equip_num < 10 then
			index = equip_num + i - 1
		elseif equip_num >= 10 then
			index = equip_num + i - 2
		elseif equip_num == 0 then
			index = i
		end
		local attr_list = RedEquipData.Instance:GetAttrCfg(self.cur_select, index)
		local attr = RedEquipData.Instance:GetAttrAddInfo(attr_list, add_num)
		local attr_str = ""
    	local attr_str2 = ""
    	for k,v in pairs(attr) do
      		if v > 0 and Language.Common.AttrNameNoUnderline[k] then
        		attr_str = attr_str .. "<color=#B78358>" ..Language.Common.AttrNameNoUnderline[k] .. ":</color>" .. v
        		attr_str2 = attr_str2 .. Language.Common.AttrNameNoUnderline[k] .. ":" .. v
      		end
    	end

		if index <= equip_num then
			self.attr_text_list[i].attr.text.text =  attr_str
			self.attr_text_list[i].tips.text.text = string.format(Language.RedEquip.RedEquipValueText,add_num .. "%")
		else
			self.attr_text_list[i].attr.text.text = string.format(Language.RedEquip.RedEquipGrayText, attr_str2)
			self.attr_text_list[i].tips.text.text = string.format(Language.RedEquip.RedEquipJiqiText,index)
		end
	end
	for i=1,equip_num do
		local attr_list = RedEquipData.Instance:GetAttrCfg(self.cur_select, i)
		local attr = RedEquipData.Instance:GetAttrAddInfo(attr_list, add_num)
		power = power + CommonDataManager.GetCapabilityCalculation(attr)
	end
	self.fight_power:SetValue(power)
end

function RedEquipView:GetCellSize()
	return 120
end

function RedEquipView:HandleAttributeTip()
	TipsCtrl.Instance:ShowHelpTipView(280)
end

function RedEquipView:CloseAttributeTip()
	self.show_attribute_tip:SetValue(false)
end

function RedEquipView:OnGotoGet()
	local client_cfg = RedEquipData.Instance:GetBossInfo(self.cur_select)
	if client_cfg then
		-- local param_list = Split(client_cfg, "#")
		-- if param_list[2] then
		-- 	ViewManager.Instance:OpenByCfg(client_cfg, nil, param_list[2] .. "_index")
		-- else
		-- 	ViewManager.Instance:OpenByCfg(client_cfg)
		-- end
		ViewManager.Instance:OpenByCfg(client_cfg)
	end
end

function RedEquipView:CloseOrHideGemList()
	self.is_show_gemlist:SetValue(false)
end

function RedEquipView:CloseView()
	self:Close()
end


---------------------------------------------------------------------------------------------------
RedEquipItem = RedEquipItem or BaseClass(BaseCell)
RedEquipItem.SelectLevelIndex = 0
function RedEquipItem:__init(instance)
     self:ListenEvent("ItemClick",BindTool.Bind(self.OnIconBtnClick, self))
     self.name = self:FindVariable("IconName")
     self.red_point = self:FindObj("RedPoint")
     self.lock = self:FindObj("Lock")
end

function RedEquipItem:__delete()

end

function RedEquipItem:SetToggleGroup(group, bool)
	self.root_node.toggle.group = group
end

-- function RedEquipItem:SetToggleOn(index)
-- 	self.root_node.toggle.isOn = self.index == index
-- end

function RedEquipItem:OnIconBtnClick()
	self:OnClick()
	RedEquipItem.SelectLevelIndex = self.index
end

function RedEquipItem:OnFlush()
	if nil == self.data then return end
	if self.data then
		local title_state = RedEquipData.Instance:GetTitleInfo(self.data.seq)
		self.name:SetValue(self.data.name)
		local flag = RedEquipData.Instance:GetActiveFlag(self.data.seq) ~= 1
		self.lock:SetActive(flag)
		local flag2 = RedEquipData.Instance:GetEquipList(self.data.seq)
		if (not flag and flag2) or title_state then
			self.red_point:SetActive(true)
		else
			self.red_point:SetActive(false)
		end
	end
	self.root_node.toggle.isOn = RedEquipItem.SelectLevelIndex == self.index
end

function RedEquipItem:ShowRedPoint(is_show)
	self.red_point:SetActive(is_show)
end


--------------------------------------------RedEquipScrollerCell-----------------------------------------------------------------------


RedEquipScrollerCell = RedEquipScrollerCell or BaseClass(BaseCell)
RedEquipScrollerCell.SelectEquipIndex = 0
function RedEquipScrollerCell:__init()
	self.item_cell_list = {}
	for i = 1, 3 do
		local item = self:FindObj("item_" .. i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item)
		item_cell:SetData(nil)
		table.insert(self.item_cell_list, item_cell)
	end
end

function RedEquipScrollerCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function RedEquipScrollerCell:SetData(data, i, index)
	self.item_cell_list[i]:SetData(data)
	self.item_cell_list[i]:SetIndex(index)
	if nil == data then
		self.item_cell_list[i]:SetInteractable(false)
	else
		self.item_cell_list[i]:SetInteractable(true)
	end
	self.item_cell_list[i].root_node.toggle.isOn = RedEquipScrollerCell.SelectEquipIndex == index and data ~= nil
end

function RedEquipScrollerCell:SetParent(parent)
	self.parent = parent
	for k, v in ipairs(self.item_cell_list) do
		v.parent = parent
	end
end

function RedEquipScrollerCell:SetToggleGrounp(group)
	for k, v in ipairs(self.item_cell_list) do
		v.root_node.toggle.group = group
	end
end

function RedEquipScrollerCell:ListenClick(func, i)
	self.item_cell_list[i]:ListenClick(func)
end


----------RedEquipItemCell--------
RedEquipItemCell = RedEquipItemCell or BaseClass(BaseCell)

function RedEquipItemCell:__init()
	-- self.quality = self:FindVariable("Quality")
	self.icon = self:FindVariable("Icon")
	-- self.show_arrow = self:FindVariable("ShowArrow")
	-- self.color_label = self:FindVariable("ColorLabel")
	-- self.show_arrow:SetValue(false)
	-- self.color_label:SetAsset("", "")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("item_cell"))
	self.item:SetItemActive(false)
	self.item:ShowHighLight(false)
end

function RedEquipItemCell:__delete()
	self.item:DeleteMe()
end

function RedEquipItemCell:SetData(data)
	self.item:SetShowUpArrow(false)
	if not data then
		return
	end
	if not next(data) then
		self.item:SetItemActive(false)
		return
	end
	self.data = data
	self.item:SetData(self.data)
	self.item:SetItemActive(true)
	self.item:SetInteractable(true)
	local flag = RedEquipData.Instance:GetBetter(self.data)
	self.item:SetShowUpArrow(flag)
end

function RedEquipItemCell:ShowArrow(value, k)
	self.show_arrow:SetValue(value)
end

function RedEquipItemCell:SetColorLabel(asset, bunble)
	self.color_label:SetAsset(asset, bunble)
end

function RedEquipItemCell:SetIcon(bundle, asset)
	if nil ==  bundle or nil == asset then return end
	self.icon:SetAsset(bundle, asset)
end

function RedEquipItemCell:SetQuality(level)
	-- local bundle1, asset1 = ResPath.GetRoleEquipQualityIcon(level)
	-- self.quality:SetAsset(bundle1, asset1)
	self.item:SetQualityByColor(level)
end

function RedEquipItemCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
	self.item:ListenClick(handler)
end

function RedEquipItemCell:SetInteractable(enable)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.interactable = enable
	end
end

function RedEquipItemCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function RedEquipItemCell:SetHightLight(value)
	if nil == self.root_node.toggle then return end
	self.root_node.toggle.isOn = value
end