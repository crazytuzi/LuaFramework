--进阶
FuBenPhaseView = FuBenPhaseView or BaseClass(BaseRender)

local ROW_NUM = 5
local NAME_LIST = {"Mount", "Wing", "Footprint", "Halo", "Fazhen"}
local SMALL_NAME_LIST = {"mount", "wing", "footprint", "halo", "fazhen"}
local SAO_DANG_LEVEL_LIMIT = 350		-- 开启扫荡最低等级
local SHOW_ARROW_LEVEL = 131			-- 显示第一个副本箭头最大等级

function FuBenPhaseView:__init(instance)
	self.list_view = self:FindObj("ListView")
	-- self:ListenEvent("zhuanpanclick",BindTool.Bind(self.ZhuanPanClick, self))
	self.turntable_info = TurntableInfoCell.New(self:FindObj("Turntable"))
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
	if self.turntable_info ~= nil then
		self.turntable_info:DeleteMe()
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
		local is_active = false
		if fuben_cfg.fun_name == "" then
			local game_vo = GameVoManager.Instance:GetMainRoleVo()
			is_active = game_vo.level >= fuben_cfg.role_level
		else
			local is_fun_open = OpenFunData.Instance:CheckIsHide(fuben_cfg.fun_name)
			is_active = is_fun_open
		end

		data.is_pass = fuben_info[fuben_cfg.fb_index].is_pass
		data.today_use_times = fuben_info[fuben_cfg.fb_index].today_times
		data.free_times = fuben_cfg.free_times - data.today_use_times
		data.role_level = fuben_cfg.role_level
		data.had_active = is_active
		data.no_active = not is_active
		data.image_name = NAME_LIST[fuben_cfg.fb_type]
		data.small_image_name = SMALL_NAME_LIST[fuben_cfg.fb_type]
		data.fb_name = scene_config.name
		data.fb_index = fuben_cfg.fb_index
		fuben_list:SetIndex(data_index + 1)
		fuben_list:SetData(data, data_index)

		local item_data = nil
		for i = 1, 2 do
			if data.free_times <= 0 then
				item_data = fuben_cfg.reset_reward[i - 1]
				fuben_list:SetItemCellData(i, item_data)
			elseif data.is_pass == 0 then
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
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.VAT_FB_PHASE_COUNT)
			return
		end
		TipsCtrl.Instance:ShowSystemMsg(Language.NineGridChou.NoResetTips)
		return
	end

	if fuben_cfg.free_times - today_times <= 0 then
		local func = function ()
			FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PHASE, data_index)
			self.today_times_list[data_index] = today_times
		end
		local price = FuBenData.Instance:GetPhaseFbResetGold(data_index, today_times)
		local str = string.format(Language.FB.RestTimes, price)
		TipsCtrl.Instance:ShowCommonTip(func, nil, str, nil, nil, true, false, "chongzhi")
		return
	end

	local game_vo = GameVoManager.Instance:GetMainRoleVo()

	-- 扫荡
	if fuben_info[data_index].is_pass == 1 and game_vo.level >= SAO_DANG_LEVEL_LIMIT then
		FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PHASE, data_index)
		self.today_times_list[data_index] = today_times
		return
	end

	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PHASE, data_index)
	UnityEngine.PlayerPrefs.SetInt("phaseindex", data_index)
	ViewManager.Instance:Close(ViewName.FuBen)
end

function FuBenPhaseView:FlushView()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function FuBenPhaseView:IsShowEffect()
	self.turntable_info:SetShowEffect(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
end

function FuBenPhaseView:ZhuanPanClick()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
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
	self.is_chongzhi = self:FindVariable("IsChongZhi")
	self.text_des = self:FindVariable("DesText")
	self.raw_image = self:FindVariable("RawImage")
	self.show_arrow = self:FindVariable("ShowArrow")

	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.fb_name_img = self:FindVariable("FbNameImg")

	self.challenge_button = self:FindObj("ChallengeButton")
	self.fb_name = self:FindVariable("FbName")
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

function PhaseFuBenListView:RestImage()
	self.is_first:SetValue(false)
	self.is_normal:SetValue(false)
	self.is_chongzhi:SetValue(false)
end

function PhaseFuBenListView:SetData(data, data_index)
	self.data = data
	self.challenge_button.button.interactable = true
	local game_vo = GameVoManager.Instance:GetMainRoleVo()

	self:RestImage()
	if data.free_times <= 0 then
		local chong_zhi_count = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_FB_PHASE_COUNT)
		self.button_text:SetValue(Language.Common.ChongZhi)
		self.rest_time:SetValue(chong_zhi_count - math.abs(data.free_times))
		self.text_des:SetValue(Language.Common.ChongZhi)
		self.is_chongzhi:SetValue(true)
		self.show_red_point:SetValue(false)
	else
		if data.is_pass == 1 and game_vo.level >= SAO_DANG_LEVEL_LIMIT then
			self.button_text:SetValue(Language.Common.SaoDang)
			self.is_normal:SetValue(true)
		else
			self.button_text:SetValue(Language.Common.TiaoZhan)
			self.is_first:SetValue(true)
		end
		self.text_des:SetValue(Language.Common.ShengYu)
		self.rest_time:SetValue(data.free_times)
		self.show_red_point:SetValue(true)
	end
	self.fb_name:SetValue(data.fb_name)
	self.had_active:SetValue(data.had_active)
	self.no_active:SetValue(data.no_active)
	-- local level_befor = math.floor(data.role_level % 100) ~= 0 and math.floor(data.role_level % 100) or 100
	-- local level_behind = math.floor(data.role_level % 100) ~= 0 and math.floor(data.role_level / 100) or math.floor(data.role_level / 100) - 1
	-- local level_zhuan =  string.format(Language.Common.Zhuan_Level, level_befor, level_behind)
	local level_zhuan = PlayerData.GetLevelString(data.role_level)
	self.active_level:SetValue(level_zhuan)
	local bundle, asset = ResPath.GetFubenRawImage(data.small_image_name, data.image_name)
	self.raw_image:SetAsset(bundle, asset)

	self.show_arrow:SetValue(data_index == 0 and game_vo.level < SHOW_ARROW_LEVEL and data.today_use_times <= 0)
	self.fb_name_img:SetAsset(ResPath.GetFbViewImage("word_advance_" .. self.data.fb_index))
end