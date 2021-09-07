ForgeSpiritSoulView = ForgeSpiritSoulView or BaseClass(BaseRender)

local MAX_NUM = 36
local ROW = 3
local COLUMN = 4

local SOUL_BAOXIANG_NUM = 5	-- 抽命魂宝箱
local SOUL_SLOT_NUM = 7		-- 命魂槽数量
local SOUL_POOL_ROW = 3 	-- 命魂池的行数

function ForgeSpiritSoulView:__init()
	self.soul_items = {}
	self.get_soul_items = {}
	self.dress_soul_items = {}
	self.tmp_data = {}
	self.cur_click_slot_index = -1

	self.color_items = {}
	self.color_btn_costs = {}
	self.cells = {}

	-- self.chou_hun_list = {}
	self.fix_show_time = 8
	self.is_one_key_chou = false
	self.role_cell_list = {}
	self.cur_select_index = 1
	self.select_index = 1
end

function ForgeSpiritSoulView:__delete()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	for k, v in pairs(self.soul_items) do
		v:DeleteMe()
	end
	self.soul_items = {}

	self.tmp_data = {}

	for k, v in pairs(self.get_soul_items) do
		v:DeleteMe()
	end
	self.get_soul_items = {}
	self.cur_click_slot_index = nil
	self.fix_show_time = nil
	self.role_cell_list = {}	
	for k,v in pairs(self.role_cell_list) do
		v:DeleteMe()
	end
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
	self.is_one_key_chou = nil

	for k, v in pairs(self.dress_soul_items) do
		v:DeleteMe()
	end
	self.dress_soul_items = {}
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.forge_total_zhanli = nil

	if self.change_callback ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.change_callback)
		self.change_callback = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function ForgeSpiritSoulView:LoadCallBack()
	self:ListenEvent("OnClickGetSoul", BindTool.Bind(self.OnClickGetSoul, self))
	self:ListenEvent("OnClickCombineSoul", BindTool.Bind(self.OnClickCombineSoul, self))
	self:ListenEvent("OnClickSoulBag", BindTool.Bind(self.OnClickSoulBag, self))
	self:ListenEvent("OnClickOneKeySale", BindTool.Bind(self.OnClickOneKeySale, self))
	self:ListenEvent("OnClickOneKeyCall", BindTool.Bind(self.OnClickOneKeyCall, self))
	self:ListenEvent("OnClickChangeLife", BindTool.Bind(self.OnClickChangeLife, self))
	self:ListenEvent("OnClickOneKeyPutInBag", BindTool.Bind(self.OnClickOneKeyPutInBag, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickAttrsBtn", BindTool.Bind(self.OnClickAttrsBtn, self))
	self:ListenEvent("OnClickCloseAttrs", BindTool.Bind(self.OnClickCloseAttrs, self))
	self:ListenEvent("OnClickHandbook",BindTool.Bind(self.OnClickHandbook,self))
	self:ListenEvent("OnClickChouHun1", BindTool.Bind(self.OnClickChouHun, self, 1))
	self:ListenEvent("OnClickChouHun2", BindTool.Bind(self.OnClickChouHun, self, 2))
	self:ListenEvent("OnClickChouHun3", BindTool.Bind(self.OnClickChouHun, self, 3))
	self:ListenEvent("OnClickChouHun4", BindTool.Bind(self.OnClickChouHun, self, 4))
	self:ListenEvent("OnClickChouHun5", BindTool.Bind(self.OnClickChouHun, self, 5))
	self:ListenEvent("OnClickAdd", BindTool.Bind(self.OnClickAddHunLi, self))
	self.storage_exp = self:FindVariable("StorageExp")
	self.show_attr_label = self:FindVariable("ShowAttrsLabel")
	self.all_attr_fight_power = self:FindVariable("FightPower")
	self.hunli_count = self:FindVariable("SoulCount")
	self.show_get_redpoint = self:FindVariable("ShowGetRed")
	self.free_ingot_list = {
		self:FindVariable("FreeIngots1"),
		self:FindVariable("FreeIngots2"),
		self:FindVariable("FreeIngots3"),
		self:FindVariable("FreeIngots4"),
		self:FindVariable("FreeIngots5"),
	}
	self.is_preferential = self:FindVariable("IsPreferential")	
	self.soul_bag_toggle = self:FindObj("SoulBagToggle").toggle
	self.get_soul_toggle = self:FindObj("GetSoulToggle").toggle

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetSoulNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshSoulBagCell, self)

	for i = 1, SOUL_POOL_ROW do
		self.get_soul_items[i] = ForgeSpiritSoulItemGroupSixLengt.New(self:FindObj("ItemGroup"..i))
	end

	self.page_toggle_list = {
		self:FindObj("PageToggle1").toggle,
		self:FindObj("PageToggle2").toggle,
		self:FindObj("PageToggle3").toggle,
	}

    self.dress_soul_items = {}
	for i = 1, SOUL_SLOT_NUM do
		self.dress_soul_items[i] = ForgeSpiritDressSoulItem.New(self:FindObj("DressItem"..i))
	end
	
	for i = 1, SOUL_BAOXIANG_NUM do
		local icon = self:FindObj("Icon"..i)
		self.color_items[i] = icon
		self.color_btn_costs[i] = self:FindVariable("CostNum"..i)
	end

	self.forge_total_zhanli = self:FindVariable("total_zhanli")

	self.equip_list = self:FindObj("EquipListView")
	local equip_list_delegate = self.equip_list.list_simple_delegate
	equip_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetEquipNum, self)
	equip_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshEquipCell, self)

	self:SetPlayerData(PlayerData.Instance.role_vo)

	if not self.change_callback then
		self.change_callback = BindTool.Bind(self.GetHunLiCount, self)
		PlayerData.Instance:ListenerAttrChange(self.change_callback)
	end

	self:GetHunLiCount()

	local data_list = ForgeData.Instance:GetCurSoulEquipList()
	if data_list and data_list[self.select_index] then
		self.cur_select_index = data_list[self.select_index].equip_type
	end
	
	self:Flush()

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)

	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.OnRoleAttrLevelChange, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end

	RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritSoulGet)
end

function ForgeSpiritSoulView:OnRoleAttrLevelChange(key, new_value, old_value)
	if key == "level" then
		self.cur_select_index = 1
		self:Flush()
		if self.equip_list and self.equip_list.scroller then
			self.equip_list.scroller:ReloadData(0)
		end
	end
end

function ForgeSpiritSoulView:SetPlayerData(t)
	local equiplist = EquipData.Instance:GetDataList()
	self:SetData(equiplist)
end

function ForgeSpiritSoulView:SetData(equiplist)
	for k, v in pairs(self.cells) do
		if equiplist[k - 1] and equiplist[k - 1].item_id then
			v:SetData(equiplist[k - 1])
			v:SetIconGrayScale(false)
			v:ShowQuality(true)
			v:SetHighLight(self.cur_index == k)
		else
			local jiezhi_level = MojieData.Instance:GetLevelInfo(EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE)
			local guazhui_level = MojieData.Instance:GetLevelInfo(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI)
			local data = {}
			data.is_bind = 0
			v:SetData(data)
			v:SetIsShowGrade(false)

			--客户端做的装备表现
			if k == 8 and jiezhi_level >= 1 then 
				local equip_type = k == 8 and jiezhi_level or guazhui_level
				local bundle, asset = ResPath.GetPlayerImage("jewelry_" .. 1)
				v:SetAsset(bundle, asset )
				v:SetStrength(jiezhi_level)
				v:ShowStrengthLable(true)
				v:QualityColor(GameEnum.ITEM_COLOR_ORANGE)
			elseif k == 10 and guazhui_level >= 1 then
				local bundle, asset = ResPath.GetPlayerImage("jewelry_" .. 2)
				v:SetAsset(bundle, asset )
				v:SetStrength(guazhui_level)
				v:ShowStrengthLable(true)
				v:QualityColor(GameEnum.ITEM_COLOR_ORANGE)
			else
				local bundle, asset = ResPath.GetPlayerImage("equip_bg" .. k)
				v:SetAsset(bundle, asset )
				v:ShowQuality(false)
				v:SetHighLight(false)
			end
			v:ShowHighLight(false)
		end
	end
end

function ForgeSpiritSoulView:OnClickHandbook()
	-- body
	ViewManager.Instance:Open(ViewName.SoulHandBook)
end

function ForgeSpiritSoulView:CloseCallBack()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function ForgeSpiritSoulView:GetSoulNumberOfCells()
	return MAX_NUM / ROW
end

function ForgeSpiritSoulView:RefreshSoulBagCell(cell, data_index)
	local group = self.soul_items[cell]
	local bag_list = ForgeData.Instance:GetSpiritSoulBagInfo().grid_list
	if nil == group then
		group = SpiritSoulItemGroup.New(cell.gameObject)
		self.soul_items[cell] = group
	end
	local page = math.floor(data_index / COLUMN)
	local column = data_index - page * COLUMN
	local grid_count = COLUMN * ROW
	for i = 1, ROW do
		local index = (i - 1) * COLUMN + column + (page * grid_count)
		if group:GetData(i) and group:GetData(i).id == bag_list[index].id then
			group:IsDestroyEffect(i, false)
		else
			group:IsDestroyEffect(i, true)
		end
		group:SetData(i, bag_list and bag_list[index] or {})
		group:ListenClick(i, BindTool.Bind(self.OnClickBagSoulItem, self, index))
	end
end

function ForgeSpiritSoulView:GetEquipNum()
	return 8
	--return EquipData.Instance:GetDataCount()
end

function ForgeSpiritSoulView:RefreshEquipCell(cell, cell_index)
	 cell_index = cell_index + 1

	local item_cell = self.role_cell_list[cell]
	if item_cell == nil then
		item_cell = EquipItem.New(cell.gameObject)
		self.role_cell_list[cell] = item_cell
	end
	item_cell:SetIndex(cell_index)
	local data_list = ForgeData.Instance:GetCurSoulEquipList()
	-- item_cell:SetData(data_list[cell_index == 7 and 8 or cell_index])
	item_cell:SetData(data_list[cell_index])

	--item_cell:SetClickCallBack(BindTool.Bind(self.OnClickEquipCellCallBack, self))
	item_cell:SetParent(self)
	item_cell:FlushHL(self:GetSelectIndex())
end

function ForgeSpiritSoulView:OnClickEquipCellCallBack(cell)
	if nil == cell then
		return
	end
	if cell.is_lock_index and cell.data then
		local str = ""
		if cell.data.sort_type and cell.data.sort_type == FORGE_LEVEL_TYPE.OPEN then
			str = Language.JingLing.ForgeLevelTextBtn
		else
			str = Language.JingLing.ForgeLevelText
		end
		TipsCtrl.Instance:ShowSystemMsg(string.format(str, cell.level_label))
		self:SetSelectIndex(cell.index)
		self.cur_select_index = cell.data.equip_type
		self:FlushEquipList()
		return
	end

	self:SetSelectIndex(cell.index)
	--cell:FlushHL(self:GetSelectIndex())
	self.cur_select_index = cell.data.equip_type
	self:Flush()
	self:FlushEquipList()
end
	
function ForgeSpiritSoulView:OnClickEquipCell(cell)
	if nil == cell and cell.data == nil then
		return
	end
	if cell.is_lock_index or cell.data.sort_type then
		local str = ""
		if  cell.data.sort_type == FORGE_LEVEL_TYPE.OPEN then
			str = Language.JingLing.ForgeLevelTextBtn
		else
			str = Language.JingLing.ForgeLevelText
		end
		TipsCtrl.Instance:ShowSystemMsg(string.format(str, cell.level_label))
		-- self:SetSelectIndex(cell.index)
		-- self.cur_select_index = cell.data.equip_type
		-- self:FlushEquipList()
		return
	end

	self:SetSelectIndex(cell.index)
	--cell:FlushHL(self:GetSelectIndex())
	self.cur_select_index = cell.data.equip_type
	self:Flush()
	self:FlushEquipList()
end

function ForgeSpiritSoulView:FlushEquipList()
	if self.equip_list.scroller.isActiveAndEnabled then
		self.equip_list.scroller:RefreshActiveCellViews()
	end
end

-- 打开总属性面板
function ForgeSpiritSoulView:OnClickAttrsBtn()
	local slot_soul_info = ForgeData.Instance:GetSpiritSlotSoulInfo()
	local temp_attr_list = CommonDataManager.GetAttributteNoUnderline()
	if slot_soul_info and next(slot_soul_info) then
		for _,v in pairs(slot_soul_info.lieming_list) do
			for k2, v2 in pairs(v.slot_list) do
				if v2.hunshou_id > 0 then
					local cfg = ForgeData.Instance:GetSpiritSoulCfg(v2.hunshou_id)
					local attr_list = ForgeData.Instance:GetSoulAttrCfg(v2.hunshou_id, v2.level) or {}
					if temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] then
						temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] = temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] + attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]]	
					end
				end
			end									
		end
	end
	TipsCtrl.Instance:OpenGeneralView(temp_attr_list)
end

-- 关闭总属性面板
function ForgeSpiritSoulView:OnClickCloseAttrs()
end

-- 背包命魂格子
function ForgeSpiritSoulView:OnClickBagSoulItem(index)
	if index == nil then return end
	local bag_list= ForgeData.Instance:GetSpiritSoulBagInfo().grid_list
	local data = bag_list and bag_list[index] or {}
	if nil == data or nil == next(data) then return end
	if data.id <= 0 then return end
	
	if not ForgeData.Instance:IsHaveSoulEquip(self.cur_select_index) then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.NoHaveForgeTip)
	 return
	 end

	data.item_data = {id = data.id, index = data.index}
	TipsCtrl.Instance:ShowSpiritSoulPropView(data, ForgeData.SOUL_FROM_VIEW.SOUL_BAG, self.cur_select_index)
end

-- 获取命魂按钮
function ForgeSpiritSoulView:OnClickGetSoul()
	self.soul_bag_toggle.isOn = false
	self.is_one_key_chou = false

	ForgeCtrl.Instance:IsShowSoulBg(true)
end

-- 合并命魂
function ForgeSpiritSoulView:OnClickCombineSoul()
	local ok_func = function ()
		ForgeCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.MERGE)
	end
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.JingLing.SoulCombineStr , nil, nil, true, false, "combinesoul")
end

-- 命魂背包
function ForgeSpiritSoulView:OnClickSoulBag()
	self.get_soul_toggle.isOn = false
	self.is_one_key_chou = false
	self:FlushBagView()
	ForgeCtrl.Instance:IsShowSoulBg(false)
end

-- 从链接进来，显示抽命魂页面
function ForgeSpiritSoulView:SetGetSoulPanel()
	self.get_soul_toggle.isOn = true
end

-- 默认显示背包那一面
function ForgeSpiritSoulView:ResetOpenState()
	self.get_soul_toggle.isOn = false
end

function ForgeSpiritSoulView:FlushBagView()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function ForgeSpiritSoulView:JumpToPage(page)
	page = page or 1
	local jump_index = 0
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.list_view.scroller.snapTweenType
	local scrollerTweenTime = 0.2
	local scroll_complete = function()
		self.current_page = page
	end
	self.list_view.scroller:JumpToDataIndex(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
	self.page_toggle_list[1].isOn = true
end

-- 一键卖经验
function ForgeSpiritSoulView:OnClickOneKeySale()
	local soul_bag_info = ForgeData.Instance:GetSpiritSoulBagInfo()
	local liehun_pool = soul_bag_info.liehun_pool
	if not liehun_pool or not next(liehun_pool) then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.SoulPoolNoCanSale)
		return
	end

	local can_sale = false
	for k, v in pairs(liehun_pool) do
		if v.id > 0 then
			can_sale = true
		end
	end
	if not can_sale then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.SoulPoolNoCanSale)
		return
	end

	local ok_func = function ()
		self.is_one_key_chou = false
		ForgeCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.CONVERT_TO_EXP)
	end
	if ForgeData.Instance:IsHadMoreThenPurpleSoul() then
		self.is_one_key_chou = false
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.JingLing.SoulOneKeySaleSoulPoolStr , nil, nil, true, false, "onekeysalepurple")
		return
	end
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.JingLing.SoulOneKeySaleCallStr , nil, nil, true, false, "onekeysale")
end

function ForgeSpiritSoulView:OnClickHelp()
	local tip_id = 41
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

-- 一键放入背包
function ForgeSpiritSoulView:OnClickOneKeyPutInBag()
	local soul_bag_info = ForgeData.Instance:GetSpiritSoulBagInfo()
	local liehun_pool = soul_bag_info.liehun_pool
	if not liehun_pool or not next(liehun_pool) then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.SoulPoolNoCanPutBag)
		return
	end

	local can_sale = false
	for k, v in pairs(liehun_pool) do
		if v.id > 0 and v.id ~= GameEnum.HUNSHOU_EXP_ID then
			can_sale = true
		end
	end
	if not can_sale then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.SoulPoolNoCanPutBag)
		return
	end
	local ok_func = function ()
		ForgeCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.PUT_BAG_ONE_KEY)
		self.is_one_key_chou = false
	end
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.JingLing.PutBagOnekey , nil, nil, true, false, "putbagonekey")
end

-- 一键召唤
function ForgeSpiritSoulView:OnClickOneKeyCall()
		local ok_func = function ()
		ForgeCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.BATCH_HUNSHOU)
			 self.is_one_key_chou = true
		end
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.JingLing.SoulMultipleCallStr , nil, nil, true, false, "multiplecall")			
end

-- 逆天改命
function ForgeSpiritSoulView:OnClickChangeLife()
	local soul_bag_info = ForgeData.Instance:GetSpiritSoulBagInfo()
	local lieming_cfg = ConfigManager.Instance:GetAutoConfig("lieming_auto")
	local ok_func = function ()
		ForgeCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.SUPER_CHOUHUN)
		self.is_one_key_chou = false
	end

	local discount_price = lieming_cfg.other[1].super_chouhun_discount_price
	local price = lieming_cfg.other[1].super_chouhun_price
	local life_str = soul_bag_info.daily_has_change_color <= 0 and Language.JingLing.SoulChangeLife or ""
	local content_str = Language.JingLing.SoulChangeLifeStr .. life_str
	local str = string.format(content_str, soul_bag_info.daily_has_change_color <= 0 and discount_price or price)
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, str, nil, nil, true, false, "changelife")
end

-- 点击命魂槽
function ForgeSpiritSoulView:OnClickSlotSoul(index, is_lock)
	if nil == index then return end
	self.cur_click_slot_index = index
	local slot_soul_info = ForgeData.Instance:GetSlotSoulInfoByIndex(self.cur_select_index)
	if not slot_soul_info then return end
	local slot_list = slot_soul_info.slot_list
	local data = slot_list and slot_list[index] or {}
	local hunge_activity_condition = ConfigManager.Instance:GetAutoConfig("lieming_auto").hunge_activity_condition
	if is_lock then
		local msg = ""
		local level = hunge_activity_condition[index].role_level
		local level_zhuan = string.format(Language.Common.Zhuan_Level, level)
		msg = string.format(Language.JingLing.SoulSlotOpenAdition, level_zhuan)
		TipsCtrl.Instance:ShowSystemMsg(msg)
		return
	end
	if nil == data.hunshou_id or data.hunshou_id <= 0 then return end
	data.index = self.cur_click_slot_index - 1
	local callback = function()
		self.cur_click_slot_index = -1
	end
	TipsCtrl.Instance:ShowSpiritDressSoulView(data, callback, self.cur_select_index)
end

-- 刷新弹出Tip数据
function ForgeSpiritSoulView:FlushSlotSoulTip()
	if -1 >= self.cur_click_slot_index then return end

	local slot_soul_info = ForgeData.Instance:GetSlotSoulInfoByIndex(self.cur_select_index)
	if not slot_soul_info then return end
	local slot_list = slot_soul_info.slot_list
	local data = slot_list and slot_list[self.cur_click_slot_index] or {}
	if nil == data.hunshou_id or data.hunshou_id <= 0 then return end
	data.index = self.cur_click_slot_index - 1
	local callback = function()
		self.cur_click_slot_index = -1
	end
	TipsCtrl.Instance:ShowSpiritDressSoulView(data, callback, self.cur_select_index)
end

-- 点击召唤出来的命魂
function ForgeSpiritSoulView:OnClickHadCallSoulItem(index)
	if nil == index then return end
	local liehun_pool = ForgeData.Instance:GetSpiritSoulBagInfo().liehun_pool
	local data = liehun_pool and liehun_pool[index] or {}

	if not data.id or data.id <= 0 then return end

	data.item_data = {id = data.id, index = data.index}
	TipsCtrl.Instance:ShowSpiritSoulPropView(data, ForgeData.SOUL_FROM_VIEW.SOUL_POOL, self.cur_select_index)
	self.is_one_key_chou = false
end

-- 命魂抽取存放池
function ForgeSpiritSoulView:SetSoulPoolItemData()
	local soul_bag_info = ForgeData.Instance:GetSpiritSoulBagInfo()

	local slot_soul_info = ForgeData.Instance:GetSlotSoulInfoByIndex(self.cur_select_index)
	if not slot_soul_info then return end
	local bit_list = bit:d2b(slot_soul_info.slot_activity_flag)
	if soul_bag_info and next(soul_bag_info) then
		local liehun_pool = soul_bag_info.liehun_pool
		for k, v in pairs(self.get_soul_items) do
			for n = 0, 5 do
				if v:GetData(n + 1) and v:GetData(n + 1).id == liehun_pool[(k - 1) * 6 + n].id then
					v:IsDestroyEffect(n + 1, false)
				else
					v:IsDestroyEffect(n + 1, true)
				end
				v:SetData(n + 1, liehun_pool[(k - 1) * 6 + n])
				v:ListenClick(n + 1, BindTool.Bind(self.OnClickHadCallSoulItem, self, (k - 1) * 6 + n))
			end
		end
	end
end

-- 设置抽命魂颜色
function ForgeSpiritSoulView:SetItemColor()
	local soul_bag_info = ForgeData.Instance:GetSpiritSoulBagInfo()
	local chou_hun_cfg = ForgeData.Instance:GetSpiritCallSoulCfg()
	local color = soul_bag_info and soul_bag_info.liehun_color or -1
	local baoxiang_index = 0
	for k, v in pairs(self.color_items) do
		if k == (color + 1) then
			baoxiang_index = k
			v.grayscale.GrayScale = 0
			self.free_ingot_list[k]:SetValue(soul_bag_info.daily_has_free_chou <= 0)
		else
			v.grayscale.GrayScale = 255
			v.animator:SetBool("Shake", false)
			self.free_ingot_list[k]:SetValue(false)	
		end
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if not self.time_quest then
		local time = 0
		if self.color_items[baoxiang_index] then
			self.color_items[baoxiang_index].animator:SetBool("Shake", true)
		end
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			time = time - 1
			if self.color_items[baoxiang_index] and time <= 0 then
				self.color_items[baoxiang_index].animator:SetBool("Shake", true)
				time = 1
			end
		end, 1)
	end
end

function ForgeSpiritSoulView:OnClickChouHun(index)
	local soul_bag_info = ForgeData.Instance:GetSpiritSoulBagInfo()
	local color = soul_bag_info and soul_bag_info.liehun_color or -1
	if index ~= (color + 1) then return end

	self.is_one_key_chou = false
	ForgeCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.CHOUHUN)
end

-- 设置抽猎命的消耗魂力数值
function ForgeSpiritSoulView:SetCostHunli()
	local cfg = ForgeData.Instance:GetSpiritCallSoulCfg()
	local soul_bag_info = ForgeData.Instance:GetSpiritSoulBagInfo()
	local color = soul_bag_info and soul_bag_info.liehun_color or -1
	for k, v in pairs(self.color_btn_costs) do
		if color + 1 == k and soul_bag_info.daily_has_free_chou ~= nil and soul_bag_info.daily_has_free_chou <= 0 then
			v:SetValue(0)
		else
			v:SetValue(cfg[k] and cfg[k].cost_gold or 0)
		end
	end
end

function ForgeSpiritSoulView:OnFlush()
	self:SetSoulPoolItemData()
	local soul_bag_info = ForgeData.Instance:GetSpiritSoulBagInfo()
	local slot_soul_info = ForgeData.Instance:GetSlotSoulInfoByIndex(self.cur_select_index)
	if slot_soul_info and next(slot_soul_info) and ForgeData.Instance:IsHaveSoulEquip(self.cur_select_index) then
		local bit_list = bit:d2b(slot_soul_info.slot_activity_flag)
		for k, v in pairs(self.dress_soul_items) do
			local id = slot_soul_info.slot_list[k].hunshou_id or -1
			local soul_level_info = ForgeData.Instance:GetSoulLevelCfg(k)
			local attr_cfg = ForgeData.Instance:GetSoulAttrCfg(id, slot_soul_info.slot_list[k].level)
			local data = {}
			data.is_lock = (bit_list and bit_list[32 - k] or 0) ~= 1
			data.show_level = (slot_soul_info.slot_list[k] and slot_soul_info.slot_list[k].level or 0) > 0
			data.level = slot_soul_info.slot_list[k].level or 0
			data.text = string.format(Language.JingLing.SoulLevelText, soul_level_info.role_level)
			if attr_cfg ~= nil and soul_bag_info and soul_bag_info.hunshou_exp and slot_soul_info.slot_list[k].exp then
				data.show_redpoint = soul_bag_info.hunshou_exp > attr_cfg.exp - slot_soul_info.slot_list[k].exp
			else
				data.show_redpoint = false
			end
			self.tmp_data[k] = data.show_redpoint
			local id = slot_soul_info.slot_list[k].hunshou_id or -1
			v:SetData(data)

			if not v:GetEffectId() or v:GetEffectId() ~= id then
				v:LoadEffect(id)
			end
			v:ListenClick(BindTool.Bind(self.OnClickSlotSoul, self, k, data.is_lock))
		end
	else
		for k, v in pairs(self.dress_soul_items) do
			local data = {}
			data.is_lock = false
			data.level = 0
			data.show_level = 0
			data.text = nil
			data.show_redpoint = false
			v:SetData(data)
			v:LoadEffect(-2)
		end
	end
	self.storage_exp:SetValue(soul_bag_info and soul_bag_info.hunshou_exp or 0)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local soul_bag_info = ForgeData.Instance:GetSpiritSoulBagInfo()
	if vo.hunli >= 50000 or soul_bag_info.daily_has_free_chou <= 0 then
		self.show_get_redpoint:SetValue(true)
	else
		self.show_get_redpoint:SetValue(false)
	end
	self:FlushBagView()
	self:SetItemColor()
	self:SetCostHunli()
	self:FlushSlotSoulTip()
	if soul_bag_info.notify_reason == LIEMING_BAG_NOTIFY_REASON.LIEMING_BAG_NOTIFY_REASON_BAG_MERGE then
		self:JumpToPage()
	end

	local zhanli = 0
	for k,v in pairs(slot_soul_info.slot_list) do
		local cfg = ForgeData.Instance:GetSoulAttrCfg(v.hunshou_id, v.level)
		local soul_cfg = ForgeData.Instance:GetSpiritSoulCfg(v.hunshou_id)
		if cfg then
			local cap_table = {}
			cap_table[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]] = cfg[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]]
			zhanli = zhanli + CommonDataManager.GetCapabilityCalculation(cap_table)
		end
	end
	self.forge_total_zhanli:SetValue(zhanli)

	self.is_preferential:SetValue(soul_bag_info.daily_has_change_color <= 0)
	self:FlushEquipList()
end

function ForgeSpiritSoulView:SetSelectIndex(select_index)
	self.select_index = select_index
end

function ForgeSpiritSoulView:GetSelectIndex()
	return self.select_index or 0
end

function ForgeSpiritSoulView:GetHunLiCount()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.hunli_count:SetValue(vo.hunli)
end

function ForgeSpiritSoulView:OnClickAddHunLi()
	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end
	TipsCtrl.Instance:ShowCommonBuyView(func, 23902, nil, 1)
end

function ForgeSpiritSoulView:RemindChangeCallBack(remind_name, num)
	if RemindName.SpiritSoulGet == remind_name then
		self.show_get_redpoint:SetValue(num > 0)
	end
end

-- 3个长度的命魂格子组，在命魂背包
SpiritSoulItemGroup = SpiritSoulItemGroup or BaseClass(BaseRender)

function SpiritSoulItemGroup:__init(instance)
	self.items = {
		ForgeSpiritSoulItem.New(self:FindObj("SoulItem1")),
		ForgeSpiritSoulItem.New(self:FindObj("SoulItem2")),
		ForgeSpiritSoulItem.New(self:FindObj("SoulItem3")),
	}
end

function SpiritSoulItemGroup:__delete()
	for k, v in pairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
end

function SpiritSoulItemGroup:ListenClick(i, handler)
	self.items[i]:ListenClick(handler)
end

function SpiritSoulItemGroup:SetData(i, data)
	self.items[i]:SetData(data)
end


function SpiritSoulItemGroup:IsDestroyEffect(i, enable)
	self.items[i]:IsDestroyEffect(enable)
end

function SpiritSoulItemGroup:GetData(i)
	return self.items[i]:GetData()
end

-- 6个长度的命魂格子组，在命魂获取面板
ForgeSpiritSoulItemGroupSixLengt = ForgeSpiritSoulItemGroupSixLengt or BaseClass(BaseRender)

function ForgeSpiritSoulItemGroupSixLengt:__init(instance)
	self.items = {
		ForgeSpiritSoulItem.New(self:FindObj("SoulItem1")),
		ForgeSpiritSoulItem.New(self:FindObj("SoulItem2")),
		ForgeSpiritSoulItem.New(self:FindObj("SoulItem3")),
		ForgeSpiritSoulItem.New(self:FindObj("SoulItem4")),
		ForgeSpiritSoulItem.New(self:FindObj("SoulItem5")),
		ForgeSpiritSoulItem.New(self:FindObj("SoulItem6")),
	}
end

function ForgeSpiritSoulItemGroupSixLengt:__delete()
	for k, v in pairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
end

function ForgeSpiritSoulItemGroupSixLengt:ListenClick(i, handler)
	self.items[i]:ListenClick(handler)
end

function ForgeSpiritSoulItemGroupSixLengt:SetItemActive(i, enable)
	self.items[i]:SetActive(enable)
end

function ForgeSpiritSoulItemGroupSixLengt:SetData(i, data)
	self.items[i]:SetData(data, false, true)
end

function ForgeSpiritSoulItemGroupSixLengt:IsDestroyEffect(i, enable)
	self.items[i]:IsDestroyEffect(enable)
end

function ForgeSpiritSoulItemGroupSixLengt:GetData(i)
	return self.items[i]:GetData()
end


-- 穿着的命魂格子
ForgeSpiritDressSoulItem = ForgeSpiritDressSoulItem or BaseClass(BaseRender)

function ForgeSpiritDressSoulItem:__init(instance)
	self.level = self:FindVariable("Level")
	self.show_level = self:FindVariable("ShowLevel")
	self.show_lock = self:FindVariable("ShowLock")
	self.show_redpoint = self:FindVariable("ShowRedpoint")
	self.jie_text = self:FindVariable("JieText")
	self.effect = nil
	self.is_load = false
	self.is_stop_load_effect = false
end

function ForgeSpiritDressSoulItem:__delete()
	self.is_load = nil
	if self.effect then
		GameObject.Destroy(self.effect)
		self.effect = nil
	end
	self.id = nil
end

function ForgeSpiritDressSoulItem:ListenClick(handler)
	self:ClearEvent("click")
	self:ListenEvent("click", handler)
end

function ForgeSpiritDressSoulItem:SetData(data)
	self.level:SetValue(data.level)
	self.show_level:SetValue(data.show_level)
	self.show_lock:SetValue(data.is_lock)
	self.jie_text:SetValue(data.text)
	self.show_redpoint:SetValue(data.show_redpoint)
end

function ForgeSpiritDressSoulItem:LoadEffect(id)
	self.id = id
	local cfg = ForgeData.Instance:GetSpiritSoulCfg(id)

	if self.effect then
		GameObject.Destroy(self.effect)
		self.effect = nil
	elseif self.is_load and id < 0 then
		self.is_stop_load_effect = true
	end

	if id == GameEnum.HUNSHOU_EXP_ID then
		cfg = {name = Language.JingLing.ExpHun, hunshou_color = 1, hunshou_effect = "minghun_g_01"}
	end
	if cfg then
		if cfg.hunshou_effect and not self.effect and not self.is_load then
			self.is_load = true

			PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/ui_jinglinminghun/" .. string.lower(cfg.hunshou_effect) .. "_prefab", cfg.hunshou_effect), function (prefab)
				if not prefab then return end

				if self.root_node == nil then
					return
				end

				if self.is_stop_load_effect then
					self.is_stop_load_effect = false
					return
				end

				local obj = GameObject.Instantiate(prefab)
				PrefabPool.Instance:Free(prefab)
				local transform = obj.transform
				transform:SetParent(self.root_node.transform, false)
				self.effect = obj.gameObject
				self.is_load = false
			end)
		end
	end
end

function ForgeSpiritDressSoulItem:GetEffectId()
	return self.id
end

--------------------------------
ForgeSpiritSoulItem = ForgeSpiritSoulItem or BaseClass(BaseRender)

function ForgeSpiritSoulItem:__init(instance)
	self.name = self:FindVariable("name")

	self.icon_root = self:FindObj("Icon")

	self.effect = nil
	self.tip_effect = nil
	self.is_destroy_effect = true
	self.is_loading = false

	self.is_is_destroy_effect_loading = false
end

function ForgeSpiritSoulItem:__delete()
	if self.effect then
		GameObject.Destroy(self.effect)
		self.effect = nil
	end
	if self.tip_effect then
		GameObject.Destroy(self.tip_effect)
		self.tip_effect = nil
	end
	self.is_destroy_effect = nil
	self.data = nil
end

function ForgeSpiritSoulItem:CloseCallBack()
	if self.tip_effect then
		GameObject.Destroy(self.tip_effect)
		self.tip_effect = nil
	end
	self.is_is_destroy_effect_loading = false
end

function ForgeSpiritSoulItem:IsDestroyEffect(enable)
	self.is_destroy_effect = enable
end

function ForgeSpiritSoulItem:SetData(data)
	self.data = data
	if nil == data then return end
	local cfg = ForgeData.Instance:GetSpiritSoulCfg(data.id)
	if data.id == GameEnum.HUNSHOU_EXP_ID then
		cfg = {name = Language.JingLing.ExpHun, hunshou_color = 1, hunshou_effect = "minghun_g_01"}
	end

	if self.effect and self.is_destroy_effect then
		GameObject.Destroy(self.effect)
		self.effect = nil
	elseif self.is_loading and self.is_destroy_effect then
		self.is_is_destroy_effect_loading = true
	end

	if cfg then
		local str = "<color=%s>"..cfg.name.."</color>"
		self.name:SetValue(string.format(str, SOUL_NAME_COLOR[cfg.hunshou_color]))
		if cfg.hunshou_effect then
			if not self.effect and not self.is_loading then

				local name = data.id ~= GameEnum.HUNSHOU_EXP_ID and cfg.hunshou_effect or "minghun_g_01"
				self.is_loading = true

				PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/ui_jinglinminghun/" .. string.lower(name) .. "_prefab", name), function (prefab)
					if not prefab or self.effect then return end

					if self.is_is_destroy_effect_loading then
						self.is_loading = false
						self.is_is_destroy_effect_loading = false
						return
					end

					local obj = GameObject.Instantiate(prefab)
					PrefabPool.Instance:Free(prefab)
					local transform = obj.transform
					transform:SetParent(self.icon_root.transform, false)
					self.effect = obj.gameObject
					self.is_loading = false
				end)
			end
		end
	else
		self.name:SetValue("")
	end
end

function ForgeSpiritSoulItem:GetData()
	return self.data
end

-- function ForgeSpiritSoulItem:SetItemActive(enable)
-- 	self.root_node:SetActive(enable)
-- end

function ForgeSpiritSoulItem:ListenClick(handler)
	self:ClearEvent("click")
	self:ListenEvent("click", handler)
end
-- function ForgeSpiritSoulItem:SetToggleGroup(toggle_group)
-- 	self.root_node.toggle.group = toggle_group
-- end

----------------------------equipitem
EquipItem = EquipItem or BaseClass(BaseCell)

function EquipItem:__init()
	self.show_hl = self:FindVariable("ShowHL")
	self.show_rp = self:FindVariable("ShowRP")
	self.is_lock = self:FindVariable("IsLock")
	--self.is_lock_level = self:FindVariable("is_lock_level")
	self.level = self:FindVariable("Level")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self.item_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
	self:ListenEvent("OnClickEquip", BindTool.Bind(self.OnClickEquip, self))
end

function EquipItem:__delete()
end

function EquipItem:OnFlush()
	self.item_cell:SetData(self.data)
	self.is_lock_index, self.level_label = ForgeData.Instance:GetCurEquipIsLock(self.data.equip_type)
	-- local show_red = ForgeData.Instance:CheckSingleSoulItemRed(self.index)
	local show_red = ForgeData.Instance:CheckSingleSoulItemRed(self.data.equip_type)
	self.show_rp:SetValue(show_red)

	local str = ""
	if self.is_lock_index and self.data.equip_type == ForgeData.Instance:GetCurEquipNextLevel()then
		str = string.format(Language.JingLing.ForgeNextLevelText, self.level_label) 
	end
	self.level:SetValue(str)
	self.is_lock:SetValue(self.is_lock_index)

	if self.data.sort_type then
		local bundle, asset = ResPath.GetForgeImg("equip_bg" .. SortIndexNew[self.data.equip_type] + 1)
		local bundlebg, assetbg = ResPath.GetImages("bg_cell_equip")
		self.item_cell:SetItemCellBg(bundlebg, assetbg)
		self.item_cell:SetAsset(bundle, asset)
	end
end

function EquipItem:ClickItem()
	self.item_cell:ShowHighLight(false)
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function EquipItem:SetParent(parent)
	self.parent = parent
end

function EquipItem:FlushHL(select_index)
	self.show_hl:SetValue(select_index == self.index)
end

function EquipItem:OnClickEquip()
	if self.parent then
		self.parent:OnClickEquipCell(self)
	end	
end