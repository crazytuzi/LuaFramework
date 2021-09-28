ShenGeInlayView = ShenGeInlayView or BaseClass(BaseRender)

local MAX_BAG_GRID_NUM = 240
local COLUMN_NUM = 4
local ROW_NUM = 4
local BAG_PAGE_COUNT = 16
local DISCOUNT_XUANTU_PRASE = 13
local MAX_COMMON_GRID_INDEX = 15

function ShenGeInlayView:__init(instance)
	self.cell_list = {}

	self:ListenEvent("OnClickCompose", BindTool.Bind(self.OnClickCompose, self))
	self:ListenEvent("OnClickPreview", BindTool.Bind(self.OnClickPreview, self))
	self:ListenEvent("OnClickClean", BindTool.Bind(self.OnClickClean, self))
	self:ListenEvent("OnClickDecompose", BindTool.Bind(self.OnClickDecompose, self))
	self:ListenEvent("OnClickPage1", BindTool.Bind(self.OnClickPage, self, 1))
	self:ListenEvent("OnClickPage2", BindTool.Bind(self.OnClickPage, self, 2))
	self:ListenEvent("OnClickPage3", BindTool.Bind(self.OnClickPage, self, 3))
	self:ListenEvent("OnClickPageMask2", BindTool.Bind(self.OnClickPageMask, self, 2))
	self:ListenEvent("OnClickPageMask3", BindTool.Bind(self.OnClickPageMask, self, 3))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickBiPin", BindTool.Bind(self.OnClickBiPin, self))
	self:ListenEvent("OpenOverView", BindTool.Bind(self.OpenOverView, self))

	self.page_toggle_list = {}
	self.show_page_remind_list = {}
	for i = 1 , ShenGeEnum.SHENGE_SYSTEM_CUR_SHENGE_PAGE do
		self.page_toggle_list[i] = self:FindObj("TogglePage"..i).toggle
		self.show_page_remind_list[i] = self:FindVariable("ShowPageRemind"..i)
	end

	self.slot_cell_list = {}
	for i = 1, ShenGeEnum.SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID_SPECIAL do
		self.slot_cell_list[i] = ShenGeCell.New(self:FindObj("SlotCell"..i))
		self.slot_cell_list[i]:ListenClick(BindTool.Bind(self.OnClickShenGeCell, self, i - 1))
		self.slot_cell_list[i]:SetIndex(i - 1)
	end

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.list_view:Reload()
	self.list_view.list_page_scroll2:JumpToPageImmidate(0)

	self.fragment = self:FindVariable("Fragment")
	self.fight_power = self:FindVariable("FightPower")
	self.show_attr_tip = self:FindVariable("ShowAttrTip")
	self.history_level = self:FindVariable("HistoryLevel")
	self.cur_level = self:FindVariable("CurLevel")
	self.next_open_page = self:FindVariable("NextOpenPage")
	self.total_history_level = self:FindVariable("TotalHistoryLevel")
	self.show_next_open_page_text = self:FindVariable("ShowOpenNextPageTip")
	self.open_page_level = self:FindVariable("OpenPageLevel")

	self.show_page_mask_2 = self:FindVariable("ShowPageMask2")
	self.show_page_mask_3 = self:FindVariable("ShowPageMask3")
	self.show_bipin_icon = self:FindVariable("ShowBiPingIcon")
	self.discount_time = self:FindVariable("BiPinTime")

	self.fragment:SetValue(ShenGeData.Instance:GetFragments())

	self.click_index = -1
	self.is_click_bag_cell = false
	self.discount_close_time = 0
	self.discount_index = 0

	self:Flush()
end

function ShenGeInlayView:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for _, v in pairs(self.slot_cell_list) do
		v:DeleteMe()
	end

	if self.discount_timer then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
	end

	self.slot_cell_list = {}
	self.show_bipin_icon = nil
	self.discount_time = nil
end

-- 打开合成
function ShenGeInlayView:OnClickCompose()
	ViewManager.Instance:Open(ViewName.ShenGeComposeView)
end

function ShenGeInlayView:IsBiPin()
	local discount_info, index = DisCountData.Instance:GetDiscountInfoByType(DISCOUNT_XUANTU_PRASE)
	self.discount_index = index
	self.show_bipin_icon:SetValue(discount_info ~= nil)
	self.discount_close_time = discount_info and discount_info.close_timestamp or 0
	if discount_info and self.discount_timer == nil then
		self:UpdateTimer()
		if self.discount_timer then
			GlobalTimerQuest:CancelQuest(self.discount_timer)
			self.discount_timer = nil
		end
		self.discount_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateTimer, self), 1)
	end
end

function ShenGeInlayView:UpdateTimer()
	local time = self.discount_close_time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
		self.show_bipin_icon:SetValue(false)
	else
		if time > 86400 then --一天
			self.discount_time:SetValue(TimeUtil.FormatSecond(time, 7))
		else
			self.discount_time:SetValue(TimeUtil.FormatSecond(time))
		end
	end
end

function ShenGeInlayView:OnClickPreview()
	ViewManager.Instance:Open(ViewName.ShenGeAttrView)
end

-- 点击整理背包
function ShenGeInlayView:OnClickClean()
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_SORT_BAG)
end

-- 一键分解
function ShenGeInlayView:OnClickDecompose()
	--ViewManager.Instance:Open(ViewName.ShenGeDecomposeView)
	ShenGeCtrl.Instance:ShowDecomposeDetail(0, nil, true)
end

function ShenGeInlayView:OnClickHelp()
	local tips_id = 167
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShenGeInlayView:OnClickBiPin()
	ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {self.discount_index})
end

--打开符文总览界面
function ShenGeInlayView:OpenOverView()
	ViewManager.Instance:Open(ViewName.ShenGePreview)
end

function ShenGeInlayView:OnClickShenGeCell(index)
	local list = ShenGeData.Instance:GetSlotStateList()
	local flag = list[index]
	if nil == flag then
		flag = false
	end
	if not flag then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.TotalLevelNoEnough)
		return
	end

	-- 等级限制
	local level_limit_flag, level_limit = ShenGeData.Instance:GetSpecialSlotOpenSate(index)
	if level_limit_flag == false then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.ShenGe.SpecialSlotLockTips, level_limit))
		return
	end

	local cell_data = self.slot_cell_list[index + 1]:GetData()
	if nil ~= cell_data and nil ~= cell_data.item_id and cell_data.item_id > 0 then
		ShenGeCtrl.Instance:ShowUpgradeView(cell_data, false)
		return
	end

	local quyu = math.floor(index / 4) + 1
	local same_quyu_data_num = #ShenGeData.Instance:GetSameQuYuDataList(quyu)
	-- 特殊玄图区域
	if index >= ShenGeEnum.SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID and index < ShenGeEnum.SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID_SPECIAL then
		quyu = SPECIAL_SHEN_GE_GRID_AREA[index] or 1
		same_quyu_data_num = #ShenGeData.Instance:GetSameQuYuSpecialDataList(quyu)
	end

	if same_quyu_data_num <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.NoShenGeTakeOn)
		return
	end

	local call_back = function(data)
		if nil == data then
			return
		end
		local cur_page = ShenGeData.Instance:GetCurPageIndex()
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_SET_RUAN, data.shen_ge_data.index, cur_page, index)
	end
	ShenGeCtrl.Instance:ShowSelectView(call_back, {[1] = quyu, [2] = index}, "from_inlay")
end

-- 点击符文页
function ShenGeInlayView:OnClickPage(index)
	local open_num = ShenGeData.Instance:GetShenGeOpenPageNum()
	if open_num < index then
		return
	end
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHANGE_RUNA_PAGE, index - 1)
end

function ShenGeInlayView:OnClickPageMask(index)
	local open_level = ShenGeData.Instance:GetShenGePageOpenLevel(index - 1)
	local str = string.format(Language.ShenGe.PageOpenTip, open_level, index)
	TipsCtrl.Instance:ShowSystemMsg(str)
end

function ShenGeInlayView:ClickBagCell(inde, data, cell)
	if nil == data then return end
	self.click_index = inde
	local close_call_back = function()
		self.click_index = -1
		cell:SetHighLight(false)
		self.is_click_bag_cell = false
	end
	ShenGeCtrl.Instance:ShowUpgradeView(data, true, close_call_back)
	self.is_click_bag_cell = true
end

function ShenGeInlayView:GetNumberOfCells()
	return MAX_BAG_GRID_NUM
end

function ShenGeInlayView:RefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = ItemCell.New()
		cell:SetInstanceParent(cellObj)
		cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / ROW_NUM) + 1 - page * COLUMN_NUM
	local cur_row = math.floor(index % ROW_NUM) + 1
	local grid_index = (cur_row - 1) * COLUMN_NUM - 1 + cur_colunm  + page * ROW_NUM * COLUMN_NUM

	local data = ShenGeData.Instance:GetShenGeItemData(grid_index)
	cell:ListenClick(BindTool.Bind(self.ClickBagCell, self, grid_index, data, cell))
	cell:SetInteractable(nil ~= data)
	cell:SetHighLight(self.click_index == grid_index)
	cell:SetIndex(grid_index)
	cell:SetData(data)
	cell:SetIconGrayScale(false)
end

function ShenGeInlayView:OnDataChange(info_type, param1, param2, param3, bag_list)
	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_COMPOSE_SHENGE_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SIGLE_CHANGE
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO then

		self:Flush()

	elseif info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_USING_PAGE_INDEX then
		self:Flush()

	elseif info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_SHENGE_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SHENGE_INFO then

		self:Flush("OnDataChange")

	elseif info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO then
		self.fragment:SetValue(ShenGeData.Instance:GetFragments())
	end
end

function ShenGeInlayView:SetSlotState(data_changed)
	local cur_page = ShenGeData.Instance:GetCurPageIndex()

	for k, v in pairs(self.slot_cell_list) do
		v:SetSlotData(ShenGeData.Instance:GetInlayData(cur_page, k - 1),data_changed)
	end
end

function ShenGeInlayView:SetOpenPageInfo()
	local open_num = ShenGeData.Instance:GetShenGeOpenPageNum()
	local open_level = ShenGeData.Instance:GetShenGePageOpenLevel(open_num)
	self.total_history_level:SetValue(ShenGeData.Instance:GetInlayHistoryTotalLevel())
	if open_level <= 0 then
		self.show_next_open_page_text:SetValue(false)
		return
	end
	self.show_next_open_page_text:SetValue(true)
	self.next_open_page:SetValue(CommonDataManager.GetDaXie(open_num + 1))
	self.total_history_level:SetValue(ShenGeData.Instance:GetInlayHistoryTotalLevel())
	self.open_page_level:SetValue(open_level)
end

-- 设置页面按钮上的红点
function ShenGeInlayView:SetPageRemind()
	local open_page_num = ShenGeData.Instance:GetShenGeOpenPageNum()

	for k, v in pairs(self.show_page_remind_list) do
		if k <= (open_page_num) then
			v:SetValue(ShenGeData.Instance:CalcShenRedPointByPageNum(k - 1))
		else
			v:SetValue(false)
		end
	end
end

function ShenGeInlayView:OnFlush(param_list)
	local open_num = ShenGeData.Instance:GetShenGeOpenPageNum()
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	for k, v in pairs(self.page_toggle_list) do
		v.interactable = k <= open_num
		if k == 2 then
			self.show_page_mask_2:SetValue(k > open_num)
		end
		if k == 3 then
			self.show_page_mask_3:SetValue(k > open_num)
		end
		v.isOn = k == (cur_page + 1)
	end

	self.cur_level:SetValue(ShenGeData.Instance:GetInlayLevel(cur_page))
	self.history_level:SetValue(ShenGeData.Instance:GetInlayPageHistoryLevel(cur_page))
	for k,v in pairs(param_list) do
		if k == "OnDataChange" then
			data_changed = true
		else
			data_changed = false
		end
	end
	self:SetSlotState(data_changed)

	local attr_list, other_capability = ShenGeData.Instance:GetInlayAttrListAndOtherFightPower(cur_page)
	local power = CommonDataManager.GetCapabilityCalculation(attr_list)
	self.fight_power:SetValue(power + other_capability)

	self:SetOpenPageInfo()

	self:SetPageRemind()

	if self.list_view.list_view.isActiveAndEnabled then
		if self.is_click_bag_cell then
			for _, v in pairs(self.cell_list) do
				if v:GetIndex() == self.click_index then
					local data = ShenGeData.Instance:GetShenGeItemData(self.click_index)
					v:SetData(data)
				end
			end
		else
			self.list_view.list_view:Reload()
		end
	end
end


-- 神格槽
ShenGeCell = ShenGeCell or BaseClass(BaseRender)

function ShenGeCell:__init(instance)
	self.icon = self:FindVariable("Icon")
	self.show_lock = self:FindVariable("ShowLock")
	--self.show_level = self:FindVariable("ShowLevel")
	self.level = self:FindVariable("Level")
	self.shen_ge_level = self:FindVariable("ShenGeLevel")
	self.quality = self:FindVariable("Quality")
	--self.show_quality = self:FindVariable("ShowQuality")
	self.show_redmind = self:FindVariable("ShowRedmind")
	self.index = 0
end

function ShenGeCell:ListenClick(handler)
	self:ListenEvent("Click", handler)
end

function ShenGeCell:SetIndex(index)
	self.index = index
end

function ShenGeCell:GetData()
	return self.data
end

function ShenGeCell:SetSlotData(data,data_changed)
	if data ~= nil and (self.data == nil or data.item_id ~= self.data.item_id) and data_changed then
		GameObjectPool.Instance:SpawnAsset("effects2/prefab/ui/ui_jinengshengji_1_prefab", "UI_Jinengshengji_1", BindTool.Bind(self.LoadEffect, self))
	end
	self.data = data
	local list = ShenGeData.Instance:GetSlotStateList()
	local flag = list[self.index]
	if nil == flag then
		flag = false
	end

	self.show_lock:SetValue(not flag)
	local groove_index, next_open_level = ShenGeData.Instance:GetNextGrooveIndexAndNextGroove()

	--self.show_level:SetValue(groove_index == (self.index) and next_open_level > 0)
	if next_open_level > 0 then
		self.level:SetValue(string.format(Language.ShenGe.OpenGroove, next_open_level))
	end

	--self.show_quality:SetValue(false)
	self.show_redmind:SetValue(false)

	if ShenGeData.Instance:GetSpecialSlotOpenSate(self.index) == false then
		self.show_lock:SetValue(true)
		return
	end

	--玄图格子为空的时候 红点的判断
	if nil == data or nil == data.item_id or data.item_id <= 0 then
		self.icon:ResetAsset()
		local is_can_inlay = false
		local slot_state_list = ShenGeData.Instance:GetSlotStateList()
		-- 特殊玄图红点特殊处理
		if self.index < ShenGeEnum.SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID then
			if slot_state_list[self.index] and (nil == data or data.item_id <= 0) and #ShenGeData.Instance:GetSameQuYuDataList(math.floor(self.index / 4) + 1) > 0 then
				is_can_inlay = true
			end
		else
			if slot_state_list[self.index] and (nil == data or data.item_id <= 0) and #ShenGeData.Instance:GetSameQuYuSpecialDataList(SPECIAL_SHEN_GE_GRID_AREA[self.index]) > 0 then
				is_can_inlay = true
			end
		end
		self.show_redmind:SetValue(is_can_inlay)
		return
	end
	
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then return end

	self.icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
	self.shen_ge_level:SetValue(data.shen_ge_data.level)
	self.quality:SetAsset(ResPath.GetRomeNumImage(data.shen_ge_data.quality))
	--self.show_quality:SetValue(true)

	-- local cur_page = ShenGeData.Instance:GetCurPageIndex()
	-- self.show_redmind:SetValue(ShenGeData.Instance:GetShenGeInlayCellCanUpLevel(cur_page, data.shen_ge_data.index))
end

function ShenGeCell:LoadEffect(obj)
	if not obj then
		return
	end
	local transform = obj.transform
	transform:SetParent(self.root_node.gameObject.transform, false)
	local function Free()
		if IsNil(obj) then
			return
		end
		GameObjectPool.Instance:Free(obj)
	end
	GlobalTimerQuest:AddDelayTimer(Free, 1)
end