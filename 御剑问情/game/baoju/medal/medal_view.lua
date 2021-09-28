MedalView = MedalView or BaseClass(BaseRender)

local EFFECT_CD = 1
local AttrGetPower = nil

local ListViewDelegate = ListViewDelegate
--属性排序
local Defult_List =
	{
		[1] = "max_hp",
		[2] = "gong_ji",
		[3] = "fang_yu",
		[4] = "ming_zhong",
		[5] = "shan_bi",
		[6] = "bao_ji",
		[7] = "jian_ren",
		[8] = "per_jingzhun",
		[9] = "per_baoji",
		[10] = "per_pofang",
		[11] = "per_mianshang",
	}

local DISPLAYNAME = {
	[16001] = "medal_view_special_1",
}

function MedalView:__init()
	MedalView.Instance = self
	self.medal_max_level = MedalData.Instance:GetMaxLevel()
	self.effect_cd = 0
	self.old_index = -1
	if AttrGetPower == nil then
		AttrGetPower = {
			mount_attr_add = BindTool.Bind(MountData.GetMountAttrSum, MountData.Instance),
			wing_attr_add = BindTool.Bind(WingData.GetWingAttrSum,WingData.Instance),
			halo_attr_add = BindTool.Bind(HaloData.GetHaloAttrSum,HaloData.Instance),
			-- magic_bow_attr_add = BindTool.Bind(ShengongData.GetShengongAttrSum,ShengongData.Instance),
			-- magic_wing_attr_add = BindTool.Bind(ShenyiData.GetShenyiAttrSum,ShenyiData.Instance),
		}
	end

	MedalCtrl.Instance:RegisterView(self)
	--滚动条
	self.cell_list = {}
	self:InitScroller()
	-- self:InitIconScroller()
	self.scroller_select_number = 1
	--属性文本
	self.attr_list = {}
	local obj_group = self:FindObj("ObjGroup")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "Attr") ~= nil then
			self.attr_list[count] = MedalAttrText.New(obj)
			count = count + 1
		end
	end
	--变量
	self.activate_days = self:FindVariable("ActivateDays")
	self.level = self:FindVariable("Level")
	self.rand = self:FindVariable("Rank")
	self.medal_name = self:FindVariable("MedalName")
	self.power = self:FindVariable("PowerValue")
	self.power_next = self:FindVariable("NextPowerValue")
	self.is_show_next_arrow = self:FindVariable("IsShowNextArrow")
	self.process_left_value = self:FindVariable("ProcessLeftValue")
	self.process_right_value = self:FindVariable("ProcessRightValue")
	self.slider_value = self:FindVariable("SliderValue")
	self.class_text = self:FindVariable("ClassText")
	self.class_bg = self:FindVariable("ClassBG")
	self.show_right_btn = self:FindVariable("ShowRightBtn")
	self.show_left_btn = self:FindVariable("ShowLeftBtn")
	self.is_show_tips = self:FindVariable("IsShowTips")
	self.show_right_btn:SetValue(true)
	self.show_left_btn:SetValue(true)

	self:ListenEvent("OnClickRightButton",
		BindTool.Bind(self.OnClickRightButton, self))
	self:ListenEvent("OnClickLeftButton",
		BindTool.Bind(self.OnClickLeftButton, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))

	self.selet_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	if self.selet_data_index <= 0 then
		self.selet_data_index = 1
	end

	self.effect_root = self:FindObj("EffectRoot")
	self.medal_total_data = MedalData.Instance:GetMedalSuitCfg()

	-- 勋章模型
	self.center_display = self:FindObj("CenterDisplay")
	self:InitMedalModel()

	--动画勋章
	local ani_callback = BindTool.Bind(self.FlushPreviewData, self)
	local get_icon_callback = BindTool.Bind(self.GetIconId, self)
	-- self.ani_medal = AniMedalIcon.New(self, #self.medal_total_data, ani_callback, get_icon_callback)
end

function MedalView:__delete()
	if MedalCtrl.Instance ~= nil then
		MedalCtrl.Instance:UnRegisterView()
	end

	if self.medalModel then
		self.medalModel:DeleteMe()
		self.medalModel = nil
	end
	-- if self.ani_medal then
	-- 	self.ani_medal:DeleteMe()
	-- end
	self.old_index = -1

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.attr_list) do
		v:DeleteMe()
	end
	self.attr_list = {}
end

-- 勋章模型
function MedalView:InitMedalModel()
	if not self.medalModel then
		self.medalModel = RoleModel.New("medal_view")
		self.medalModel:SetDisplay(self.center_display.ui3d_display)
	end
end

function MedalView:SetMedalModelData(index)
	if self.old_index == index then return end
	self.old_index = index
	local res_id = MedalData.Instance:GetMedalResId(index)
	local bubble, asset = ResPath.GetMedalModel(res_id)
	self.medalModel:SetPanelName(self:SetSpecialModle(res_id))
	self.medalModel:SetMainAsset(bubble, asset)
	-- self.medalModel:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XUN_ZHANG], res_id, DISPLAY_PANEL.ADVANCE_SUCCE)
end
-- 结束

function MedalView:OnClickHelp()
	local tips_id = 21    -- 勋章tips
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MedalView:OpenCallBack()
	for k,v in pairs(self.scroller_data) do
		v.is_on = false
		v.is_bind_only = false
	end
	self.delay_timer_quest_1 = GlobalTimerQuest:AddDelayTimer(function()
	self.scroller.scroller:ReloadData(0)
	end, 0)
	self:ShowCurrentIcon()
	self.is_frist = true
	self:SetFlush()
	-- if self.icon_scroller.scroller.isActiveAndEnabled then
	-- 	self.icon_scroller.scroller:RefreshActiveCellViews()
	-- end
	-- GlobalTimerQuest:AddDelayTimer(function()
	self:JumpToIndex(self.selet_data_index)
	-- end, 0.3)
end

function MedalView:CloseCallBack()
	for k,v in pairs(self.scroller_data) do
		v.is_on = false
		v.is_bind_only = false
	end

	for k,v in pairs(self.cell_list) do
		if v.CloseCallBack then
			v:CloseCallBack()
		end
	end
	if self.delay_timer_quest_1 then
		GlobalTimerQuest:CancelQuest(self.delay_timer_quest_1)
		self.delay_timer_quest_1 = nil
	end
end

function MedalView:ShowCurrentIcon()
	self.selet_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	if self.selet_data_index <= 0 then
		self.selet_data_index = 1
	end
	if self.selet_data_index >= 9 then
		self.show_right_btn:SetValue(false)
		self.show_left_btn:SetValue(true)
	elseif self.selet_data_index <= 1 then
		self.show_right_btn:SetValue(true)
		self.show_left_btn:SetValue(false)
	end
	-- self.ani_medal:OpenCallBack()
end

--动画勋章 获取刷新数据
function MedalView:GetIconId()
	return ResPath.GetMedalSuitIcon(self.selet_data_index)
end

local OrderTable = {
	[1] = "mount_attr_add",
	[2] = "wing_attr_add",
	[3] = "halo_attr_add",
	-- [4] = "magic_bow_attr_add",
	-- [5] = "magic_wing_attr_add",
}

--勋章预览数据
function MedalView:FlushPreviewData()
	local select_data = self.medal_total_data[self.selet_data_index]
	local current_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	local cur_jie = MedalData.Instance:GetCurActiveJie()
	if MedalData.Instance:GetMedalTotalLevel() < MedalData.Instance:GetIsActiveById(self.selet_data_index) then
		self.activate_days:SetValue(ToColorStr(select_data.description, TEXT_COLOR.RED))
	else
		self.activate_days:SetValue(ToColorStr(Language.Common.YiActivate, TEXT_COLOR.GREEN))
	end

	if self.selet_data_index == 0 then
		self.class_text:SetValue('')
		self.class_bg:SetAsset('','')
	else
		self.class_text:SetValue(ZhiBaoData.Instance:GetChsNumber(self.selet_data_index))
		self.class_bg:SetAsset(ResPath.GetMountGradeQualityBG(math.ceil(self.selet_data_index/2)))
	end

	if self.selet_data_index > cur_jie then
		self.is_show_tips:SetValue(true)
		local next_data = self.medal_total_data[self.selet_data_index]
		self.level:SetValue(next_data.total_level)
		self.rand:SetValue(Language.Common.NumToChs[self.selet_data_index])
	else
		self.is_show_tips:SetValue(false)
	end
	self.medal_name:SetValue(select_data.name)

	local current_data = self.medal_total_data[current_data_index]
	if current_data == nil then
		current_data = {
	    total_level=0,
        mount_attr_add=0,
        wing_attr_add=0,
        halo_attr_add=0,
        magic_bow_attr_add=0,
        magic_wing_attr_add=0,
	}
	end

	local original_power = 0
	local current_power = 0
	local select_power = 0

	for k,v in pairs(AttrGetPower) do
		local power = 0
		local attr = v()
		if attr ~= 0 then
			power = CommonDataManager.GetCapability(attr)
		end
		original_power = original_power + power
	end
	local count = 1
	for k,v in ipairs(OrderTable) do
		if count > #self.attr_list then
			print('属性数量超出可显示范围')
			break
		end
		local data = {}
		data.name = Language.BaoJu.AdvanceAttr[v]
		data.icon = Language.BaoJu.IconName[v]
		data.value = current_data[v]
		local power = 0

		local attr = AttrGetPower[v]()
		if attr ~= 0 then
			power = CommonDataManager.GetCapability(attr)
		end
		current_power = current_power + math.floor(power * (1 + data.value / 10000))
		if select_data.total_level > current_data.total_level then
			data.next_value = select_data[v]
			local next_power = 0
			local next_attr = AttrGetPower[v]()
			if next_attr ~= 0 then
				next_power = CommonDataManager.GetCapability(next_attr)
			end
			select_power = select_power + math.floor(next_power * (1 + select_data[v] / 10000))
		else
			data.next_value = nil
		end
		self.attr_list[count]:SetData(data)
		count = count + 1
	end
	if select_power > 0 and select_data.total_level > current_data.total_level then
		self.power_next:SetValue(select_power - current_power)
		-- self.is_show_next_arrow:SetValue(true)
	else
		self.power_next:SetValue(select_power)
		-- self.is_show_next_arrow:SetValue(false)
	end
	-- print_error(select_power,current_power)
	local cur_capility = MedalData.Instance:CalculateCap()
	self.power:SetValue(cur_capility)
	if count <= #self.attr_list then
		for i=count,#self.attr_list do
			self.attr_list[i]:SetActive(false)
		end
	end
end

function MedalView:SetFlush()
	local current_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	local next_total_level = 0
	if self.medal_total_data[current_data_index + 1] then
		if MedalData.Instance:GetMedalIsOneJie() then
			next_total_level = self.medal_total_data[current_data_index + 1].total_level
		else
			next_total_level = self.medal_total_data[1].total_level
		end
	end
	local current_total_level = MedalData.Instance:GetMedalTotalLevel()

	self.process_left_value:SetValue(current_total_level < self.medal_max_level and current_total_level or "-")
	self.process_right_value:SetValue(current_total_level < self.medal_max_level and next_total_level or "-")

	if self.is_frist then
		self.is_frist = false
		self.slider_value:InitValue(current_total_level/next_total_level)
	else
		self.slider_value:SetValue(current_total_level/next_total_level)
	end

	self:FlushPreviewData()
	self:SetMedalModelData(self.selet_data_index)
end

--升级时刷新数据
function MedalView:FlushScroller()
	self:SetMedalModelData(self.selet_data_index)
	self:JumpToIndex(self.selet_data_index)
	self:SetFlush()
	self.scroller.scroller:RefreshActiveCellViews()
end

-- 升级时刷新特效
function MedalView:FlushEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui_x/ui_sjcg_prefab",
			"UI_sjcg",
			self.effect_root.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

--初始化滚动条
function MedalView:InitScroller()
	self.scroller_data = MedalData.Instance:GetMedalInfo()
	for k,v in pairs(self.scroller_data) do
		v.is_on = false
		v.is_bind_only = false
	end

	self.list_view_delegate = ListViewDelegate()
	self.scroller = self:FindObj("Scroller")

	PrefabPool.Instance:Load(AssetID("uis/views/baoju_prefab", "MedalItem"), function (prefab)
		if nil == prefab then
			return
		end
		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.enhanced_cell_type = enhanced_cell_type
		self.scroller.scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)

		PrefabPool.Instance:Free(prefab)
	end)
end

--滚动条数量
function MedalView:GetNumberOfCells()
	return #self.scroller_data
end

--滚动条大小 84 410
function MedalView:GetCellSize(data_index)
	data_index = data_index + 1
	local is_on = self.scroller_data[data_index].is_on
	if is_on then
		return 516
	else
		return 107
	end
end

--初始化刷新条
function MedalView:SetScrollInit(data)
	self.icon_callback_data = data["all"] or {}
	self.is_icon_call_back = false
	self:ClearDelayTimerQuestTwo()
	self.delay_timer_quest_2 = GlobalTimerQuest:AddDelayTimer(function ()
		self.is_icon_call_back = true
		self:SetFlush()
		self.scroller.scroller:RefreshActiveCellViews()
	end, 0)
end

function MedalView:ClearDelayTimerQuestTwo()
	if self.delay_timer_quest_2 then
		GlobalTimerQuest:CancelQuest(self.delay_timer_quest_2)
		self.delay_timer_quest_2 = nil
	end
end

function MedalView:GetIconCallBackData()
	return self.icon_callback_data
end

function MedalView:GetIsIconCallBack()
	return self.is_icon_call_back
end

function MedalView:SetIsIconCallBack(is_icon_call_back)
	self.is_icon_call_back = is_icon_call_back
end

--滚动条刷新
function MedalView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	data_index = data_index + 1
	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = MedalScrollCell.New(cell_view.gameObject)
		cell = self.cell_list[cell_view]
		cell.index = data_index
		cell.mother_view = self
	end
	local data = self.scroller_data[data_index]
	data.data_index = data_index
	cell:SetData(data)
	return cell_view
end

--显示详细点击后
function MedalView:ChangeDataCellSize(data_index, is_On)
	self.scroller_data[data_index].is_on = is_On
	self.scroller.scroller:RefreshAndReloadActiveCellViews(false)
	if is_On then
		local jump_index = data_index - 1
		local last_index = #self.scroller_data
		if data_index >= last_index then
			self.scroller.scroll_rect.verticalNormalizedPosition = 0
			return
		end
		local scrollerOffset = 0
		local cellOffset = 0
		local useSpacing = false
		local scrollerTweenType = self.scroller.scroller.snapTweenType
		local scrollerTweenTime = 0.2
		local scroll_complete = nil
		self.scroller.scroller:JumpToDataIndexForce(
			jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
	end
end

--只用绑定点击后
function MedalView:OnBindOnlyCHange(data_index, is_On)
	self.scroller_data[data_index].is_bind_only = is_On
end

function MedalView:GetScrollerData(data_index)
	return self.scroller_data[data_index]
end

function MedalView:CloseOther()
	for k,v in pairs(self.scroller_data) do
		v.is_on = false
	end
end

function MedalView:OnClickRightButton()
	local active_index = MedalData.Instance:GetCurActiveJie()
	if self.selet_data_index <= active_index then
		self.selet_data_index = self.selet_data_index + 1
	end
	if self.selet_data_index > #self.medal_total_data then
		self.selet_data_index = #self.medal_total_data
	end
	self:SetMedalModelData(self.selet_data_index)
	self:JumpToIndex(self.selet_data_index)
end

function MedalView:OnClickLeftButton()
	self.selet_data_index = self.selet_data_index - 1
	if self.selet_data_index < 1 then
		self.selet_data_index = 1
	end
	self:SetMedalModelData(self.selet_data_index)
	self:JumpToIndex(self.selet_data_index)
end

function MedalView:JumpToIndex(index)
	local active_index = MedalData.Instance:GetCurActiveJie()
	index = index - 1
	self.show_left_btn:SetValue(true)
	self.show_right_btn:SetValue(true)
	if index >= active_index then
		self.show_right_btn:SetValue(false)
	end
	if index >= 5 then
		self.show_right_btn:SetValue(false)
	elseif index <= 0 then
		self.show_left_btn:SetValue(false)
	end
	local jump_index = index
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	self:FlushPreviewData()
	-- local scrollerTweenType = self.icon_scroller.scroller.snapTweenType
	-- local scrollerTweenTime = 0.1
	-- local scroll_complete = BindTool.Bind(self.FlushPreviewData, self)
	-- self.icon_scroller.scroller:JumpToDataIndexForce(
	-- 	jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function MedalView:SetSpecialModle(modle_id)
	local display_name = "medal_view"
	local id = tonumber(modle_id)
	for k,v in pairs(DISPLAYNAME) do
		if id == k then
			display_name = v
			return display_name
		end
	end
	return display_name
end

-----------------------------------------------------------Icon滚动条----------------------------------------------------------------------
--初始化滚动条
function MedalView:InitIconScroller()
	self.icon_list_view_delegate = ListViewDelegate()
	self.icon_scroller = self:FindObj("ScrollerIcon")

	PrefabPool.Instance:Load(AssetID("uis/views/baoju_prefab", "MedalCell"), function (prefab)
		if nil == prefab then
			return
		end
		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.icon_enhanced_cell_type = enhanced_cell_type
		self.icon_scroller.scroller.Delegate = self.icon_list_view_delegate

		self.icon_list_view_delegate.numberOfCellsDel = function() return 10 end
		self.icon_list_view_delegate.cellViewSizeDel = function() return 388 end
		self.icon_list_view_delegate.cellViewDel = BindTool.Bind(self.GetIconCellView, self)

		PrefabPool.Instance:Free(prefab)
	end)
end

--滚动条刷新
function MedalView:GetIconCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.icon_enhanced_cell_type)
	data_index = data_index + 1
	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = MedalScrollIconCell.New(cell_view.gameObject)
		cell = self.cell_list[cell_view]
	end
	local data = {}
	data.data_index = data_index
	cell:SetData(data)
	return cell_view
end

----------------------------------------------------------------------------
--MedalScrollCell	勋章滚动条格子
----------------------------------------------------------------------------
MedalScrollCell = MedalScrollCell or BaseClass(BaseCell)

function MedalScrollCell:__init()
	--监听点击事件
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.OnFlush, self)
	self:ListenEvent("ShowDetailsChange", BindTool.Bind(self.ShowDetailsChange, self))
	self:ListenEvent("GetClick", BindTool.Bind(self.GetWayClick, self))
	self:ListenEvent("UpgradeClick", BindTool.Bind(self.UpgradeClick, self))
	--勋章图标
	self.medal_icon = self:FindVariable("Icon")
	--勋章名
	self.medal_name = self:FindVariable("Name")
	--勋章等级
	self.medal_level = self:FindVariable("Level")
	--只用绑定
	self.toggle_bind_only = self:FindObj("ToggleBindOnly").toggle
	self.toggle_bind_only:AddValueChangedListener(BindTool.Bind(self.OnBindOnlyCHange, self))
	--属性
	self.attr_list = {}
	self.icon_list = {}
	self.show_attr_list = {}
	for i=1,4 do
		self.attr_list[i] = self:FindVariable('Attr'..i)
		self.icon_list[i] = self:FindVariable("AttrIcon" .. i)
		self.show_attr_list[i] = self:FindVariable("ShowAttr" .. i)
	end
	--战力
	self.power = self:FindVariable("Power")
	--升级材料
	self.upgrade_stuff_name = self:FindVariable("UpgradeStuffName")
	self.upgrade_stuff_need_num = self:FindVariable("UpgradeStuffNeedNumber")
	self.upgrade_stuff_had_num = self:FindVariable("UpgradeStuffHadNumber")
	self.is_show_max_level = self:FindVariable("IsShowMaxLevel")
	self.upgrade_item_cell = ItemCell.New(self:FindObj("ItemCell"))
	--加成
	self.is_show_add = self:FindVariable("is_show_add")
	self.addition_value = self:FindVariable("AdditionValue")
	self.addition_name = self:FindVariable("AdditionName")
	--显示详细
	self.toggle_show_details = self:FindObj("ToggleShowDetails").toggle
	--显示详细动画
	self.ani = self.root_node.animator
	self.ani:ListenEvent("AniFinish", BindTool.Bind(self.AniFinish, self))
	--红点
	self.show_red_point = self:FindVariable("ShowRedPoint")

	self.mask = self:FindObj("Mask")
	self.mask:SetActive(false)
end

function MedalScrollCell:__delete()
	self.upgrade_item_cell:DeleteMe()
	self.toggle_show_details = nil
	self.toggle_bind_only = nil
	self.mask = nil

end

function MedalScrollCell:GetItemId(item_id,uplevel_stuff_id)
	if uplevel_stuff_id == item_id then
		return true
	else
		return false
	end
end

function MedalScrollCell:OnFlush()
	--图标
	self.medal_icon:SetAsset(ResPath.GetMedalIcon(self.data.id))
	--红点
	self.show_red_point:SetValue(self.data.can_upgrade or false)
	--重载动画和显示详细
	self.toggle_show_details.isOn = self.data.is_on
	if self.data.is_on then
		self:ClearDelayTimerQuest()
		self.delay_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
			self.ani:SetBool("IsShow", self.data.is_on)
			self.ani:SetBool("Fix", true)
		end, 0)
		self:FlushDetails()
	end
	--重载只用绑定
	self.toggle_bind_only.isOn = self.data.is_bind_only

	local cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(self.data.id, self.data.level)
	if cfg then
		self.medal_name:SetValue(cfg.xunzhang_name)
		self.medal_level:SetValue('Lv.'..self.data.level)
	end
end

function MedalScrollCell:ClearDelayTimerQuest()
	if self.delay_timer_quest then
		GlobalTimerQuest:CancelQuest(self.delay_timer_quest)
		self.delay_timer_quest = nil
	end
end

function MedalScrollCell:FlushDetails()
	local cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(self.data.id, self.data.level) or {}
	if self.data.level == 0 then
		cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(self.data.id, 1) or {} 		--获取1级的属性，以便于对有用属性进行筛选
	end
	if not cfg then return end
	--属性
	local attrs = CommonDataManager.GetAttributteByClass(cfg)
	local count = 1
	for i,v in ipairs(Defult_List) do
		if attrs[v] > 0 then
			local chs_attr_name = CommonDataManager.GetAttrName(v)..':'
			local value = 0
			if self.data.level > 0 then
				value = attrs[v]
			end
			local attr_value = '  '..value, TEXT_COLOR.GRAY_WHITE
			self.attr_list[count]:SetValue(chs_attr_name..attr_value)
			self.icon_list[count]:SetAsset(ResPath.GetBaseAttrIcon(CommonDataManager.GetAttrName(v)))
			self.show_attr_list[count]:SetValue(true)
			count = count + 1
			if count > #self.attr_list then
				break
			end
		else
			self.show_attr_list[count]:SetValue(false)
		end
	end
	if count <= #self.attr_list then
		for i=count,#self.attr_list do
			self.attr_list[i]:SetValue('')
		end
	end
	--战力
	if self.data.level < 1 then
		self.power:SetValue(0)
	else
		local power = CommonDataManager.GetCapability(attrs)
		self.power:SetValue(power)
	end
	--加成
	local level = self.data.level
	local name = nil
	local value = 0
	local set_zero = false
	local cfg_for_filtrate = cfg
	if self.data.level < 10 then
		 cfg_for_filtrate = MedalData.Instance:GetLevelCfgByIdAndLevel(self.data.id, 10) or {} 	--筛选用，把10级之后有数值的属性留下
	end
	for k,v in pairs(cfg_for_filtrate) do
		if string.sub(k, 1, 3) == 'per' then
			if v > 0 then
				if self.data.level < 10 then
					set_zero = true
				end
				name = k
				value = v
				break
			end
		end
	end

	-- print_log("<><>",name,value)
	if value > 0 and name then
		if set_zero then
			value = 0
		end
		self.is_show_add:SetValue(true)
		self.addition_name:SetValue(Language.BaoJu.MedalAttrToChs[name]..':')
		self.addition_value:SetValue((value/100)..'%')
	else
		self.is_show_add:SetValue(false)
	end

	--升级所需物品
	if next(cfg) then
		local stuff_cfg = ItemData.Instance:GetItemConfig(cfg.uplevel_stuff_id)
		if stuff_cfg ~= nil then
			local item_data = {}
			item_data.item_id = stuff_cfg.icon_id
			self.upgrade_item_cell:SetData(item_data, false)
			self.upgrade_stuff_name:SetValue(stuff_cfg.name)
			local had_num = ItemData.Instance:GetItemNumInBagById(cfg.uplevel_stuff_id)
			if had_num < cfg.uplevel_stuff_num then
				had_num = had_num
			end
			self.upgrade_stuff_need_num:SetValue(cfg.uplevel_stuff_num)

			if cfg.uplevel_stuff_num > had_num then
				self.upgrade_stuff_had_num:SetValue(string.format("<color=#fe3030>%s</color>",had_num))
			else
				self.upgrade_stuff_had_num:SetValue(string.format("<color=#111cea>%s</color>",had_num))
			end

			if self.data.level == 0 then
				local zero_cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(self.data.id, 0)
				if zero_cfg then
					self.upgrade_stuff_need_num:SetValue(zero_cfg.uplevel_stuff_num)					
					if zero_cfg.uplevel_stuff_num > had_num then
						self.upgrade_stuff_had_num:SetValue(string.format("<color=#fe3030>%s</color>",had_num))
					else
						self.upgrade_stuff_had_num:SetValue(string.format("<color=#111cea>%s</color>",had_num))
					end
				end
			end
			self.is_show_max_level:SetValue(false)
		end
	else
		--满级时
		self.is_show_max_level:SetValue(true)
	end

	local cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(self.data.id, self.data.level)
	if MedalView.Instance:GetIsIconCallBack() and self:GetItemId(MedalView.Instance:GetIconCallBackData().item_id,cfg.uplevel_stuff_id) then
		MedalView.Instance:SetIsIconCallBack(false)
		self:ShowDetailsChange(true)
		self.toggle_show_details.isOn = true
	end
end

--动画播放完后
function MedalScrollCell:AniFinish()
	if self.is_on then
		self.mother_view:ChangeDataCellSize(self.data.data_index, true)
	end
end

--显示详细按下后
function MedalScrollCell:ShowDetailsChange(is_On)
	self.mask:SetActive(true)
	if is_On then
		self.mother_view:CloseOther()
		self.is_on = true
		self:FlushDetails()
	else
		self.is_on = false
		-- self.mask:SetActive(false)
		self.mother_view:ChangeDataCellSize(self.data.data_index, is_On)
	end
	self.ani:SetBool("Fix", false)
	self.ani:SetBool("IsShow", is_On)
end

function MedalScrollCell:CloseCallBack()
	if self.is_on then
		self.is_on = false
		self.mother_view:ChangeDataCellSize(1, false)
		self.ani:SetBool("Fix", false)
		self.ani:SetBool("IsShow", false)
	end
end

--点击使用绑定
function MedalScrollCell:OnBindOnlyCHange(is_On)
	self.mother_view:OnBindOnlyCHange(self.data.data_index, is_On)
end

function MedalScrollCell:GetWayClick()
	local cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(self.data.id, self.data.level)
	if cfg ~= nil then
		TipsCtrl.Instance:ShowItemGetWayView(cfg.uplevel_stuff_id)
	end
end

function MedalScrollCell:UpgradeClick()
	local cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(self.data.id, self.data.level)
	if not cfg then return end
	local max_level = MedalData.Instance:GetLingYuMaxLevel(self.data.id)
	if self.data.level >= max_level then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.LingYuMaxLevel)
	else
		local stuff_cfg = ItemData.Instance:GetItemConfig(cfg.uplevel_stuff_id)
		if stuff_cfg ~= nil then
			local had_num = ItemData.Instance:GetItemNumInBagById(cfg.uplevel_stuff_id)
			if had_num >= cfg.uplevel_stuff_num then
				local flag = self.toggle_bind_only.isOn and 1 or 0
				MedalCtrl.Instance:SendMedalUpgrade(self.data.id, flag)
				AudioService.Instance:PlayAdvancedAudio()
			else
				TipsCtrl.Instance:ShowItemGetWayView(cfg.uplevel_stuff_id)
			end
		end
	end
end

function MedalScrollCell:SetCallBack(call_back)
	self.call_back = call_back
end

----------------------------------------------------------------------------
--MedalAttrText		勋章属性文本
----------------------------------------------------------------------------
MedalAttrText = MedalAttrText or BaseClass(BaseCell)
function MedalAttrText:__init()
	self.attr_name = self:FindVariable("Name")
	self.current_value = self:FindVariable("CurrentValue")
	self.next_value = self:FindVariable("NextValue")
	self.is_show_arrow = self:FindVariable("IsShowArrow")
	self.attr_icon = self:FindVariable("AttrIcon")
end

function MedalAttrText:__delete()

end

function MedalAttrText:OnFlush()
	self:SetActive(true)
	self.attr_name:SetValue(self.data.name ..':')
	local bubble, asset = ResPath.GetImages(self.data.icon, "icon_atlas")
	self.attr_icon:SetAsset(bubble, asset)
	self.current_value:SetValue('+' .. (self.data.value/100) .. '%')
	if self.data.next_value ~= nil then
		if MedalData.Instance:GetMedalIsOneJie() then
			local next_add_value = self.data.next_value/100 - self.data.value/100
			self.next_value:SetValue('+' .. next_add_value .. '%')
			self.is_show_arrow:SetValue(true)
		else
			self.is_show_arrow:SetValue(true)
			self.current_value:SetValue('+'..(0)..'%')
			self.next_value:SetValue('+'..(self.data.next_value/100)..'%')
		end

	else
		if MedalData.Instance:GetMedalIsOneJie() then
			self.next_value:SetValue('')
			self.is_show_arrow:SetValue(false)
		else
			self.is_show_arrow:SetValue(true)
			self.current_value:SetValue('+' .. (0)..'%')
			self.next_value:SetValue('+' .. (self.data.value/100) .. '%')
		end
	end
end

------------------------------------------------IconCell-------------------------------------------------
MedalScrollIconCell = MedalScrollIconCell or BaseClass(BaseCell)

function MedalScrollIconCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)
	self.icon = self:FindVariable("Icon")
end

function MedalScrollIconCell:__delete()

end

function MedalScrollIconCell:Flush()
	if self.data then
		-- self.icon:SetAsset(ResPath.GetMedalSuitIcon(self.data.data_index))
	end
end