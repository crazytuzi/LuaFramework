YellowEquipView = YellowEquipView or BaseClass(BaseRender)
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

function YellowEquipView:__init()
	self.cur_select = 0
	self.level_list_cell = {}
	self.scroller_list_cell = {}
	self.cells = {}
	self.tips_text_list = {}
	self.attr_text_list = {}
	self.item_image_list = {}
	self.attr_group = {}
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
	for i = 1, 6 do
		local text = self:FindObj("Text"..i)
		local attr = text:FindObj("Attr")
		local tips = text:FindObj("Tips")
		self.attr_text_list[i] = {text = text, attr = attr, tips = tips}
	end

	-- for i = 1, 8 do
	-- 	self.attr_group[i] = self:FindObj("attr_" .. i)
	-- end

	for i = 1, MAX_EQUIP do
		self.item_image_list[i] = self:FindVariable("ItemImage"..i)
	end

	PrefabPool.Instance:Load(AssetID("uis/views/redequipview_prefab","RedEquipItem"),
		function(prefab)
			for i = 1, MAX_EQUIP do
				local obj = GameObject.Instantiate(prefab)
				obj = U3DObject(obj)
				local item = YellowEquipItemCell.New(obj)
				item:SetInstanceParent(self:FindObj("Item"..i))
				item.root_node.toggle.group = self.item_group.toggle_group
				item:SetIcon(ResPath.GetEquipShadowDefualtIcon(Defult_Icon_List[i]))
				item:SetQuality(-1)
				self.cells[i] = item
			end
			PrefabPool.Instance:Free(prefab)
			self:Flush()
		end)

	self.display = self:FindObj("Display")
	self.page_toggle1 = self:FindObj("PageToggle1")

	self.level_list = self:FindObj("ListView")

	self.list_data = RedEquipData.Instance:GetOrangeOtherInfo()
	local level_list_delegate = self.level_list.list_simple_delegate
	self.list_num = #self.list_data
	--生成数量
	level_list_delegate.NumberOfCellsDel = function()
		local num = RedEquipData.Instance:GetOrangeItemNum()

		return num
	end
	level_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNameListView, self)

	self:FlushModel()
	self:InitScroller()
	self:Flush()
end

function YellowEquipView:__delete()
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
	self.attr_group = {}
	self.cur_select = 0
	YellowEquipScrollerCell.SelectEquipIndex = 0
end

function YellowEquipView:OpenCallBack()

end

function YellowEquipView:RefreshNameListView(cell,data_index)
	local icon_cell = self.level_list_cell[cell]
	if nil == icon_cell then
		icon_cell = YellowEquipItem.New(cell.gameObject)
		icon_cell:SetToggleGroup(self.level_list.toggle_group, data_index == self.cur_select)
		icon_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.level_list_cell[cell] = icon_cell
		YellowEquipItem.SelectLevelIndex = self.cur_select
	end
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local data = RedEquipData.Instance:GetOrangeProfOtherInfo(data_index,role_vo.prof)
	icon_cell:SetIndex(data_index)
	icon_cell:SetData(data)
	data_index = data_index + 1
end

--初始化装备滚动条
function YellowEquipView:InitScroller()
	local equip_data = RedEquipData.Instance:GetOrangeEquipItemCfg(self.cur_select)
	self.equip_list = RedEquipData.Instance:GetRedEquipList(equip_data[1])
	self.page_count = self:FindVariable("PageCount")
	self.scroller_list = self:FindObj("Scroller")
	local reward_list_delegate = self.scroller_list.list_simple_delegate
	reward_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	reward_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function YellowEquipView:RefreshCell(cell,data_index)
	local grounp_cell = self.scroller_list_cell[cell]
	if not grounp_cell then
		grounp_cell = YellowEquipScrollerCell.New(cell.gameObject)
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

function YellowEquipView:GetNumberOfCells()
	local num = math.ceil(#self.equip_list/(BAG_ROW*BAG_COLUMN)) * BAG_COLUMN
	return num == 0 and 3 or num
end

function YellowEquipView:FlushEquipList()
	local page = math.ceil(#self.equip_list/(BAG_ROW*BAG_COLUMN))
	page = page < 1 and 1 or page
	self.page_toggle1.toggle.isOn = true
	YellowEquipScrollerCell.SelectEquipIndex = 0
	self.page_count:SetValue(page)
	self.scroller_list.list_page_scroll:SetPageCount(page)
	self.scroller_list.scroller:ReloadData(0)
end

function YellowEquipView:OnClickSubCallBack(index, data, cell)
	if nil == data then return end
	self.cur_equip_data = data
	YellowEquipScrollerCell.SelectEquipIndex = index
end

function YellowEquipView:OnClickCloss()
	self.is_show_gemlist:SetValue(false)
	if nil == self.cur_equip_data or nil == self.list_data[self.cur_select] then return end
	RedEquipCtrl.Instance:SendRedEquipInfo(COMMON_OPERATE_TYPE.COT_REQ_ORANGE_EQUIP_COLLECT_TAKEON, self.list_data[self.cur_select].seq, self.select_cell_index - 1 , self.cur_equip_data.index)
end

function YellowEquipView:OnClickHuanXing()
	RedEquipCtrl.Instance:SendRedEquipInfo(COMMON_OPERATE_TYPE.COT_REQ_RED_EQUIP_COLLECT_FETCH_TITEL_REWARD, self.cur_select)
end

function YellowEquipView:OnClickTitle()
	local other_cfg = RedEquipData.Instance:GetOrangeOtherStar(self.cur_select) or {}
	-- local item_id = other_cfg.reward_title_id or 0
	TipsCtrl.Instance:OpenItem({item_id = other_cfg.reward_title_item})
end

function YellowEquipView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data and self.cur_select == cell.index then return end
	self.cur_select = cell.index
	self:SetData()
	self:UpAttrData()
	-- if RedEquipData.Instance:GetOrangeActiveFlag(self.cur_select) ~= 1 then
	-- 	local show_tip = self.cur_select == 0 and string.format(Language.RedEquip.RedEquipTips1,self.cur_select + 1) or string.format(Language.RedEquip.RedEquipTips2,self.cur_select + 2)
	-- 	SysMsgCtrl.Instance:ErrorRemind(show_tip)
	-- end
	local num, state, active_role_level = RedEquipData.Instance:GetOrangeItemNum()

	if not state then
 		if (num - 1) == self.cur_select then
 			local level_num_1 = math.floor(active_role_level / 100) or 0
 			local level_num_2 = active_role_level - (level_num_1 * 100) or 0
 			local show_tip = string.format(Language.RedEquip.RedEquipTips3, level_num_1, level_num_2, num + 1)
 			SysMsgCtrl.Instance:ErrorRemind(show_tip)
 		end
 	end
end

function YellowEquipView:FlushModel()
	if not self.role_model then
		self.role_model = RoleModel.New("red_equip_panel")
		self.role_model:SetDisplay(self.display.ui3d_display)
	end
	if self.role_model then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.role_model:SetModelResInfo(role_vo, nil, nil, nil, nil, nil)
	end
end

function YellowEquipView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "all" then
		end
	end
	self:SetData()
	self:UpAttrData()
	self.level_list.scroller:RefreshAndReloadActiveCellViews(false)
end

function YellowEquipView:SetData(equiplist)
	local num, state = RedEquipData.Instance:GetOrangeItemNum()

	if state then
 		self.show_image:SetValue(true)
 	else
 		self.show_image:SetValue((num - 1) ~= self.cur_select)
 	end

	local equiplist = RedEquipData.Instance:GetOrangeEquipSlot(self.cur_select)
	local equip_data = RedEquipData.Instance:GetOrangeEquipItemCfg(self.cur_select)

	if nil == equiplist or nil == equip_data then
		return
	end

	for k, v in pairs(self.cells) do
		local is_show_tips,flag =  RedEquipData.Instance:GetOrangeIsShowTipsImage(self.cur_select, equiplist[k], equip_data[k])
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

function YellowEquipView:OnClickEquipItem(index, cell, is_show_tips, yes_equip)
	-- cell:SetHighLight(false)?
	-- if RedEquipData.Instance:GetOrangeActiveFlag(self.cur_select) ~= 1 then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.RedEquip.RedEquipTips)
	-- 	return
	-- end
	local equip_data = RedEquipData.Instance:GetOrangeEquipItemCfg(self.cur_select)
	local ts_virtual =  RedEquipData.Instance:GetOrangeWayItemCfg(self.cur_select , index)
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
		SysMsgCtrl.Instance:ErrorRemind(Language.RedEquip.RedEquipJiqiText3)
		self:FlushEquipList()
		return
	end
end

function YellowEquipView:UpAttrData()
	local equiplist = RedEquipData.Instance:GetOrangeEquipSlot(self.cur_select)
	local other_cfg = RedEquipData.Instance:GetOrangeOtherStar(self.cur_select)
	local stars_info = RedEquipData.Instance:GetOrangeStarsInfo(self.cur_select)
	local equip_cfg = RedEquipData.Instance:GetOrangeEquipCfg(self.cur_select)
	if nil == other_cfg or nil == equiplist or nil == stars_info then
		return
	end

	local star_num = stars_info.stars
	local equip_num = stars_info.item_count

	self.progress_text:SetValue(equip_num .. "/" .. 10)
	self.progress:SetValue(equip_num / 10)

	local power = 0
	local power_list = {}
	power_list = RedEquipData.Instance:GetOrangeAttrCfg(self.cur_select,equip_num)

  	for i = 1, 6 do
  		local taozhuang_info = RedEquipData.Instance:GetOrangeAttrInfo(self.cur_select,i)
  		if taozhuang_info then
  			local attr_str1 = ""
  			local attr_str2 = ""
  			local count = taozhuang_info.collect_count or 0
  			self.attr_text_list[i].text:SetActive(true)
  			for k, v in pairs(taozhuang_info) do
  				if Language.Common.AttrNameNoUnderline[k] and v > 0 then
  					if equip_num >= count then
  						attr_str1 = "<color=#B78358>" ..Language.Common.AttrNameNoUnderline[k] .. ":</color>" .. v
  						attr_str2 = Language.RedEquip.RedEquipJiqiText2
  					else
  						attr_str1 = "<color=#636363ff>" ..Language.Common.AttrNameNoUnderline[k] .. ":" .. v .. "</color>"
  						attr_str2 = string.format(Language.RedEquip.RedEquipJiqiText, count)
  					end
  				end
  			end

  			self.attr_text_list[i].attr.text.text = attr_str1
			self.attr_text_list[i].tips.text.text = attr_str2
  		else
  			self.attr_text_list[i].text:SetActive(false)
  		end
  	end

	for i = 1, #power_list do
		power = power + CommonDataManager.GetCapabilityCalculation(power_list[i])
	end

	self.fight_power:SetValue(power)
end

function YellowEquipView:GetCellSize()
	return 120
end

function YellowEquipView:HandleAttributeTip()
	TipsCtrl.Instance:ShowHelpTipView(282)
end

function YellowEquipView:CloseAttributeTip()
	self.show_attribute_tip:SetValue(false)
end

function YellowEquipView:OnGotoGet()
	local client_cfg = RedEquipData.Instance:GetOrangeBossInfo(self.cur_select)
	local num, state = RedEquipData.Instance:GetOrangeItemNum()

	if not state and (num - 1) == self.cur_select then
 		return
 	end

	if client_cfg then
		ViewManager.Instance:OpenByCfg(client_cfg)
	end
end

function YellowEquipView:CloseOrHideGemList()
	self.is_show_gemlist:SetValue(false)
end

function YellowEquipView:CloseView()
	self:Close()
end


---------------------------------------------------------------------------------------------------
YellowEquipItem = YellowEquipItem or BaseClass(BaseCell)
YellowEquipItem.SelectLevelIndex = 0
function YellowEquipItem:__init(instance)
     self:ListenEvent("ItemClick",BindTool.Bind(self.OnIconBtnClick, self))
     self.name = self:FindVariable("IconName")
     self.red_point = self:FindObj("RedPoint")
     self.lock = self:FindObj("Lock")
end

function YellowEquipItem:__delete()

end

function YellowEquipItem:SetToggleGroup(group, bool)
	self.root_node.toggle.group = group
end

function YellowEquipItem:OnIconBtnClick()
	self:OnClick()
	YellowEquipItem.SelectLevelIndex = self.index
end

function YellowEquipItem:OnFlush()
	if nil == self.data then return end
	if self.data then
		-- local title_state = RedEquipData.Instance:GetOrangeTitleInfo(self.data.seq)
		self.name:SetValue(self.data.name)
		-- local flag = RedEquipData.Instance:GetOrangeActiveFlag(self.data.seq) ~= 1
		-- self.lock:SetActive(flag)
		local num, state = RedEquipData.Instance:GetOrangeItemNum()

		if state then
	 		self.lock:SetActive(false)
	 	else
	 		self.lock:SetActive((num - 1) == self.index)
	 	end

		local flag2 = RedEquipData.Instance:GetOrangeEquipList(self.data.seq)
		if flag2 then
			self.red_point:SetActive(true)
		else
			self.red_point:SetActive(false)
		end
	end
	self.root_node.toggle.isOn = YellowEquipItem.SelectLevelIndex == self.index
end

function YellowEquipItem:ShowRedPoint(is_show)
	self.red_point:SetActive(is_show)
end


--------------------------------------------YellowEquipScrollerCell-----------------------------------------------------------------------


YellowEquipScrollerCell = YellowEquipScrollerCell or BaseClass(BaseCell)
YellowEquipScrollerCell.SelectEquipIndex = 0
function YellowEquipScrollerCell:__init()
	self.item_cell_list = {}
	for i = 1, 3 do
		local item = self:FindObj("item_" .. i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item)
		item_cell:SetData(nil)
		table.insert(self.item_cell_list, item_cell)
	end
end

function YellowEquipScrollerCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function YellowEquipScrollerCell:SetData(data, i, index)
	self.item_cell_list[i]:SetData(data)
	self.item_cell_list[i]:SetIndex(index)
	if nil == data then
		self.item_cell_list[i]:SetInteractable(false)
	else
		self.item_cell_list[i]:SetInteractable(true)
	end
	self.item_cell_list[i].root_node.toggle.isOn = YellowEquipScrollerCell.SelectEquipIndex == index and data ~= nil
end

function YellowEquipScrollerCell:SetParent(parent)
	self.parent = parent
	for k, v in ipairs(self.item_cell_list) do
		v.parent = parent
	end
end

function YellowEquipScrollerCell:SetToggleGrounp(group)
	for k, v in ipairs(self.item_cell_list) do
		v.root_node.toggle.group = group
	end
end

function YellowEquipScrollerCell:ListenClick(func, i)
	self.item_cell_list[i]:ListenClick(func)
end


----------YellowEquipItemCell--------
YellowEquipItemCell = YellowEquipItemCell or BaseClass(BaseCell)

function YellowEquipItemCell:__init()
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

function YellowEquipItemCell:__delete()
	self.item:DeleteMe()
end

function YellowEquipItemCell:SetData(data)
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

function YellowEquipItemCell:ShowArrow(value, k)
	self.show_arrow:SetValue(value)
end

function YellowEquipItemCell:SetColorLabel(asset, bunble)
	self.color_label:SetAsset(asset, bunble)
end

function YellowEquipItemCell:SetIcon(bundle, asset)
	if nil ==  bundle or nil == asset then return end
	self.icon:SetAsset(bundle, asset)
end

function YellowEquipItemCell:SetQuality(level)
	-- local bundle1, asset1 = ResPath.GetRoleEquipQualityIcon(level)
	-- self.quality:SetAsset(bundle1, asset1)
	self.item:SetQualityByColor(level)
end

function YellowEquipItemCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
	self.item:ListenClick(handler)
end

function YellowEquipItemCell:SetInteractable(enable)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.interactable = enable
	end
end

function YellowEquipItemCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function YellowEquipItemCell:SetHightLight(value)
	if nil == self.root_node.toggle then return end
	self.root_node.toggle.isOn = value
end