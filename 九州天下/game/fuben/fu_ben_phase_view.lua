FuBenPhaseView = FuBenPhaseView or BaseClass(BaseRender)

local ROW_NUM = 5
local SHOW_ARROW_LEVEL = 131			-- 显示第一个副本箭头最大等级

function FuBenPhaseView:__init(instance)
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)

	self.list = {}
	self.today_times_list = {}
end

function FuBenPhaseView:__delete()
	for k, v in pairs(self.list) do
		if v then
			v:DeleteMe()
		end
	end
	self.list = {}
	self.today_times_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function FuBenPhaseView:CloseCallBack()
	self.today_times_list = {}
end

function FuBenPhaseView:GetNumberOfCells()
	return #FuBenData.Instance:SortPhaseFB()
end

function FuBenPhaseView:RefreshMountCell(list, data_index)
	local fuben_list = self.list[list]
	if fuben_list == nil then
		fuben_list = PhaseFuBenListView.New(list.gameObject)
		self.list[list] = fuben_list
	end
	self.today_times_list[data_index] = nil

	local sort_cfg = FuBenData.Instance:SortPhaseFB()[data_index + 1]
	local fuben_cfg = FuBenData.Instance:GetCurFbCfgByIndex(sort_cfg.fb_index)
	local fuben_info = FuBenData.Instance:GetPhaseFBInfo()
	local scene_config = ConfigManager.Instance:GetSceneConfig(fuben_cfg.scene_id)
	local data = {}
	if fuben_info and next(fuben_info) then
		data.is_pass = fuben_info[fuben_cfg.fb_index].is_pass
		data.today_use_times = fuben_info[fuben_cfg.fb_index].today_times
		data.free_times = fuben_cfg.free_times - data.today_use_times
		data.role_level = fuben_cfg.role_level
		data.had_active = fuben_cfg.role_level <= PlayerData.Instance:GetRoleLevel()
		data.no_active = fuben_cfg.role_level > PlayerData.Instance:GetRoleLevel()
		data.image_name = fuben_cfg.big_image
		data.small_image_name = fuben_cfg.ab_small
		data.fb_name = scene_config.name
		data.fb_index = fuben_cfg.fb_index
		data.reset_need_level = fuben_cfg.reset_need_level
		fuben_list:SetIndex(data_index + 1)
		fuben_list:SetData(data, data_index)

		local item_data = nil
		for i = 1, 2 do
			if data.is_pass == 0 then
				item_data = fuben_cfg.first_reward[i - 1]
				fuben_list:SetItemCellData(i, item_data)
			else
				item_data = fuben_cfg.normal_reward[i - 1]
				fuben_list:SetItemCellData(i, item_data)
			end
		end
	end
	fuben_list:ListenClick(BindTool.Bind(self.OnClickChallenge, self, fuben_cfg.fb_index))
end

function FuBenPhaseView:OnClickChallenge(data_index)
	local fuben_info = FuBenData.Instance:GetPhaseFBInfo()

	if not fuben_info or nil == next(fuben_info) or not fuben_info[data_index] then
		return
	end

	local fuben_cfg = FuBenData.Instance:GetCurFbCfgByIndex(data_index)

	local chong_zhi_count = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_FB_PHASE_COUNT)
	local today_times = fuben_info[data_index].today_times

	if self.today_times_list[data_index] and self.today_times_list[data_index] == today_times then
		return
	end

	if today_times >= chong_zhi_count + fuben_cfg.free_times then
		if chong_zhi_count ~= 3 then
			-- TipsCtrl.Instance:ShowSystemMsg(Language.NineGridChou.ChongzhiTip)
			-- TipsCtrl.Instance:ShowLockVipView(VIPPOWER.VAT_FB_PHASE_COUNT)
			SysMsgCtrl.Instance:ErrorRemind(Language.Camp.DayNotNum)
			return
		end
		TipsCtrl.Instance:ShowSystemMsg(Language.NineGridChou.NoResetTips)
		return
	end

	if fuben_cfg.free_times - today_times <= 0 then
		local func = function ()
			FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PHASE, data_index)
			self.today_times_list[data_index] = nil
		end
		local chong_zhi_count = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_FB_PHASE_COUNT)
		local price = FuBenData.Instance:GetPhaseFbResetGold(data_index, FuBenData.Instance:ChongZhiFbNum()[data_index +1].chong_zhi_num)
		local str = string.format(Language.FB.RestTimes, price)
		str = string.format("%s\n%s", str, Language.FB.ExpFbResetTimesRedStr)
		--TipsCtrl.Instance:ShowCommonTip(func, nil, str, nil, nil, true, false, "chongzhi")
		TipsCtrl.Instance:ShowCommonAutoView("chongzhi", str, func)
		return
	end

	local game_vo = GameVoManager.Instance:GetMainRoleVo()

	-- 扫荡
	if fuben_info[data_index].is_pass == 1 and game_vo.level >= fuben_cfg.reset_need_level then
		FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PHASE, data_index)
		self.today_times_list[data_index] = today_times
		return
	end

	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PHASE, data_index)
	UnityEngine.PlayerPrefs.SetInt("phaseindex", data_index)
	ViewManager.Instance:Close(ViewName.FuBen)
	
	if ViewManager.Instance:IsOpen(ViewName.Shenqi) then
		ViewManager.Instance:Close(ViewName.Shenqi)
	end
end

function FuBenPhaseView:OnFlush()
	self:FlushView()
end

function FuBenPhaseView:FlushView()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
	--屏蔽每次扫荡和重置后的滑动
	-- if self.list_view then
	-- 	self.list_view.scroller:ReloadData(0)
	-- end
end

function FuBenPhaseView:JumpToIndex(index)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	
	self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
		if self.list_view then
			self.list_view.scroller:JumpToDataIndex(index)
		end
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end, 0.1)
end


-- 生成的列表
PhaseFuBenListView = PhaseFuBenListView or BaseClass(BaseRender)

function PhaseFuBenListView:__init(instance)
	-- 剩余次数
	self.rest_time = self:FindVariable("RestTime")
	self.button_text = self:FindVariable("ButtonText")
	self.had_active = self:FindVariable("HadActive")
	self.no_active = self:FindVariable("NoActive")
	self.active_level = self:FindVariable("ActiveLevel")
	self.is_first = self:FindVariable("IsFirst")
	self.is_normal = self:FindVariable("IsNormal")
	self.text_des = self:FindVariable("DesText")
	self.raw_image = self:FindVariable("RawImage")
	self.show_arrow = self:FindVariable("ShowArrow")

	self.show_red_point = self:FindVariable("ShowRedPoint")

	self.challenge_button = self:FindObj("ChallengeButton")
	self.fb_name = self:FindVariable("FbName")
	self.show_complete_img = self:FindVariable("ShowCompleteImg")

	self.item_cells = {}
	self.set_modle_time_quests = {}
	for i = 1, 2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item"..i))
		self.item_cells[i] = item
	end
end

function PhaseFuBenListView:__delete()
	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
end

function PhaseFuBenListView:ListenClick(handler)
	self:ClearEvent("OnClickChallenge")
	self:ListenEvent("OnClickChallenge", handler)
end

function PhaseFuBenListView:SetItemCellData(i, data)
	self.item_cells[i]:SetData(data)
	self.item_cells[i]:SetParentActive(nil ~= data and nil ~= next(data))
end

function PhaseFuBenListView:GetIndex()
	return self.index
end

function PhaseFuBenListView:SetIndex(index)
	self.index = index
end

function PhaseFuBenListView:GetData()
	return self.data or {}
end

function PhaseFuBenListView:SetData(data, data_index)
	self.data = data
	self.challenge_button.button.interactable = true
	local game_vo = GameVoManager.Instance:GetMainRoleVo()

	if data.free_times <= 0 then
		local chong_zhi_count = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_FB_PHASE_COUNT)
		self.button_text:SetValue(Language.Common.ChongZhi)
		self.rest_time:SetValue(chong_zhi_count - math.abs(data.free_times))
		self.show_complete_img:SetValue(chong_zhi_count - math.abs(data.free_times) <= 0)
		self.text_des:SetValue(Language.Common.ChongZhi)
		self.show_red_point:SetValue(false)
	else
		self.show_complete_img:SetValue(false)
		if data.is_pass == 1 and game_vo.level >= data.reset_need_level then
			self.button_text:SetValue(Language.Common.SaoDang)
		else
			self.button_text:SetValue(Language.Common.TiaoZhan)
		end
		self.text_des:SetValue(Language.Common.ShengYu)
		self.rest_time:SetValue(data.free_times)
		self.show_red_point:SetValue(true)
	end
	self.fb_name:SetValue(data.fb_name)
	self.is_first:SetValue(data.is_pass == 0)
	self.is_normal:SetValue(data.is_pass == 1)
	self.had_active:SetValue(data.had_active)
	self.no_active:SetValue(data.no_active)
	self.active_level:SetValue(string.format(Language.Common.Zhuan_Level, data.role_level))
	local bundle, asset = ResPath.GetFubenRawImage(data.small_image_name, data.image_name)
	self.raw_image:SetAsset(bundle, asset)

	-- self.show_arrow:SetValue(data_index == 0 and game_vo.level < SHOW_ARROW_LEVEL and data.today_use_times <= 0)
	self.show_arrow:SetValue(false)
end