KaifuActivityView = KaifuActivityView or BaseClass(BaseView)

local OpenNameList = {ViewName.Advance, ViewName.Advance, ViewName.Advance, ViewName.Goddess, ViewName.Goddess, ViewName.HelperView, ViewName.FuBen,
				ViewName.FuBen, ViewName.Forge, ViewName.Forge,
		}
local Table_Index = {TabIndex.mount_jinjie, TabIndex.wing_jinjie, TabIndex.halo_jinjie, TabIndex.goddess_shengong, TabIndex.goddess_shenyi,
				TabIndex.helper_upgrade, TabIndex.fb_tower, TabIndex.fb_exp, TabIndex.forge_strengthen, TabIndex.forge_baoshi,
		}
local PaiHangBang_Index = {PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT, PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING, PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO,
					PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG, PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI,
						[9] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP, [10] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP,
		}
local activity_show_top_list = {
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION] = 1,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRY_GIFT] = 1,
}

function KaifuActivityView:__init()
	self.ui_config = {"uis/views/kaifuactivity", "KaiFuView"}
	self.play_audio = true
	self:SetMaskBg()
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.cur_index = 1
	self.cell_list = {}
	self.panel_list = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.cur_tab_list_length = 0
	self.chu_jun_info_data = {}
	
	-- 这里规定activity_type小于100的为合服活动
	self.combine_server_max_type = 100

	self.hefu_script_list = {
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK] = CombineServerChongZhiRank,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift] = CombineServerLoginJiangLiView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY] = HeFuFullServerSnapView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS] = CombineServerBoss,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CAS_SUB_TYPE_PVP] = HeFuPVPView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CAS_SUB_TYPE_TIANTIANFANLI] = CombineServerChongzhiTotal,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SANRIKUANGHUAN] = ThreeDayActivity,
	}
	self.list_percent = 0
end

function KaifuActivityView:__delete()
end

function KaifuActivityView:ReleaseCallBack()
	self.cur_type = nil
	self.cur_index = 1
	self.cur_day = nil
	self.right_combine_content = nil
	self.is_show_kaifu = nil

	for k, v in pairs(self.panel_list) do
		v:DeleteMe()
	end
	self.panel_list = {}

	for k, v in pairs(self.combine_panel_list) do
		v:DeleteMe()
	end
	
	self.combine_panel_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.cell_list = {}
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.KaifuActivityView)
	end
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.chu_role_info then
		GlobalEventSystem:UnBind(self.chu_role_info)
		self.chu_role_info = nil
	end

	-- 清理变量和对象
	self.show_chongzhi = nil
	self.show_jinjie = nil
	self.show_chongji = nil
	self.show_pata = nil
	self.show_exp_challenge = nil
	self.show_equip_strengthen = nil
	self.show_rank_jinjie = nil
	self.show_reset_day = nil
	self.show_top_bg = nil
	self.show_leiji_chongzhi = nil
	self.show_normal_bg = nil
	self.show_jizi_bg = nil
	self.show_no_bg = nil
	self.show_marrygift_bg = nil
	self.cur_jinjie_name = nil
	self.cur_jinjie_grade = nil
	self.cur_chongzhi_diamonds = nil
	self.rest_day = nil
	self.reset_hour = nil
	self.reset_min = nil
	self.reset_sec = nil
	self.cur_chongji_name = nil
	self.current_level = nil
	self.cur_pata_name = nil
	self.cur_pata_num = nil
	self.cur_exp_challege_name = nil
	self.cur_exp_challege_num = nil
	self.cur_equip_name = nil
	self.cur_equip_num = nil
	self.cur_rank_name = nil
	self.leiji_diamonds = nil
	self.panel_obj_list = nil
	self.tab_list = nil
	self.btn_close = nil
	self.is_show_title = nil
	if self.delay_set_attached then
		GlobalTimerQuest:CancelQuest(self.delay_set_attached)
		self.delay_set_attached = nil
	end
end

function KaifuActivityView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("Chongzhi", BindTool.Bind(self.OnClickChongzhi, self))
	self:ListenEvent("Jinjie", BindTool.Bind(self.OnClickJinjie, self))
	self:ListenEvent("ShenJi", BindTool.Bind(self.OnClickShengJi, self))
	self:ListenEvent("PaTa", BindTool.Bind(self.OnClickPata, self))
	self:ListenEvent("ExpChallenge", BindTool.Bind(self.OnClickExpChallenge, self))
	--self:ListenEvent("OnClickStrengthen", BindTool.Bind(self.OnClickStrengthen, self))

	self.show_chongzhi = self:FindVariable("ShowCongzhi")
	self.show_jinjie = self:FindVariable("ShowJinjie")
	self.show_chongji = self:FindVariable("ShowChongjiDaLi")
	self.show_pata = self:FindVariable("PaTa")
	self.show_exp_challenge = self:FindVariable("ExpChallenge")
	self.show_equip_strengthen = self:FindVariable("ShowEquipStrengthen")
	self.show_rank_jinjie = self:FindVariable("ShowRankJinjie")
	self.show_reset_day = self:FindVariable("ShowResetDay")
	self.show_top_bg = self:FindVariable("ShowTopBg")
	self.show_leiji_chongzhi = self:FindVariable("ShowLeiJiChongZhi")

	self.show_normal_bg = self:FindVariable("ShowNormalBg")
	self.show_jizi_bg = self:FindVariable("ShowJiZiBg")
	self.show_no_bg = self:FindVariable("ShowNoBg")
	self.show_marrygift_bg = self:FindVariable("ShowMarryGiftBg")

	self.cur_jinjie_name = self:FindVariable("CurDayName")
	self.cur_jinjie_grade = self:FindVariable("CurGrade")
	self.cur_chongzhi_diamonds = self:FindVariable("CurDiamonds")
	self.rest_day = self:FindVariable("RestDay")
	self.reset_hour = self:FindVariable("ResetHour")
	self.reset_min = self:FindVariable("ResetMin")
	self.reset_sec = self:FindVariable("ResetSec")

	self.cur_chongji_name = self:FindVariable("ChongJiText")
	self.current_level = self:FindVariable("CurrentLevel")

	self.cur_pata_name = self:FindVariable("PaTaName")
	self.cur_pata_num = self:FindVariable("PaTaNum")

	self.cur_exp_challege_name = self:FindVariable("ExpChallengeName")
	self.cur_exp_challege_num = self:FindVariable("ExpChallengeNum")

	self.cur_equip_name = self:FindVariable("EquipName")
	self.cur_equip_num = self:FindVariable("EquipValue")

	self.cur_rank_name = self:FindVariable("RankName")

	self.leiji_diamonds = self:FindVariable("LeiJiDiamonds")
	self.right_combine_content = self:FindObj("RightCombineContent")
	self.is_show_kaifu = self:FindVariable("is_show_kaifu")
	self.is_show_title = self:FindVariable("is_show_title")

	self.panel_obj_list = {
		self:FindObj("Panel1"),
		self:FindObj("Panel2"),
		self:FindObj("Panel3"),
		self:FindObj("Panel4"),
		self:FindObj("Panel5"),
		self:FindObj("Panel6"),
		self:FindObj("Panel7"),
		self:FindObj("Panel8"),
		self:FindObj("Panel9"),
		self:FindObj("WelfareLevelPanel"),
		self:FindObj("PanelBossReward"),
		self:FindObj("PanelWarGoals"),
		self:FindObj("PanelChuJunGift"),
		self:FindObj("PanelMarryGift"),
		self:FindObj("PanelDailyNationalAffairs"),
		self:FindObj("PanelActiveReward"),
		self:FindObj("PanelActiveExpRefine"),
	}

	self.panel_list = {
		[1] = KaifuActivityPanelOne.New(),
		[2] = KaifuActivityPanelThree.New(),
		[3] = KaifuActivityPanelSix.New(),
		[4] = KaifuActivityPanelSeven.New(),
		[5] = KaifuActivityPanelEight.New(),
		[6] = KaifuActivityPanelTwo.New(),
		[7] = KaifuActivityPanelTen.New(),
		[8] = KaifuActivityPanelTwelve.New(),
		[9] = KaifuActivityPanelPersonBuy.New(),
		[10] = LevelRewardView.New(),
		[11] = KaifuActivityPanelBossReward.New(),
		[12] = KaifuActivityPanelWarGoals.New(),
		[13] = KaifuActivityPanelChuJunGift.New(),
		[14] = KaifuActivityPanelMarryGift.New(),
		[15] = KaifuActivityPanelDailyNational.New(),
		[16] = DailyActiveReward.New(),
		[17] = KaiFuExpRefineView.New(),
	}

	-- 合服小面板都是保存成单个的预制体 跟原开服界面的做法不同，故区分开
	self.combine_panel_list = {}
	-- self.cur_type = 0
	self.last_type = 0

	for k,v in pairs(self.panel_list) do
		local content_obj = self.panel_obj_list[k]
		content_obj.uiprefab_loader:Wait(function(obj)
			obj = U3DObject(obj)
			v:SetInstance(obj)
		end)
	end



	self.tab_list = self:FindObj("ToggleList")
	local list_delegate = self.tab_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:Flush()

	self.btn_close = self:FindObj("BtnClose")								--关闭按钮

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.KaifuActivityView, BindTool.Bind(self.GetUiCallBack, self))
	RemindManager.Instance:Bind(self.remind_change, RemindName.KaiFu)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ItemCollection)
	self.chu_role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfo, self))
	self.is_open_activity = true
end


function KaifuActivityView:GetNumberOfCells()
	self.cur_tab_list_length = #KaifuActivityData.Instance:GetOpenActivityList()
	return #KaifuActivityData.Instance:GetOpenActivityList()
end

function KaifuActivityView:RefreshCell(cell, data_index)
	local list = KaifuActivityData.Instance:GetOpenActivityList()
	if not list or not next(list) then return end
	local activity_type = list[data_index + 1] and list[data_index + 1].activity_type or list[data_index + 1].sub_type or 0
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(activity_type)
	local data = {}
	-- local activity_type = list[data_index + 1].activity_type
	data.activity_type = activity_type
	local tab_btn = self.cell_list[cell]
	if tab_btn == nil then
		tab_btn = LeftTableButton.New(cell.gameObject)
		self.cell_list[cell] = tab_btn
	end
	tab_btn:SetToggleGroup(self.tab_list.toggle_group)
	tab_btn:SetHighLight(self.cur_type == activity_type)
	tab_btn:ListenClick(BindTool.Bind(self.OnClickTabButton, self, activity_type, data_index + 1, tab_btn))

	data.is_show = false
	data.is_show_effect = false
	local reward_cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)

	if activity_info then
		for k, v in pairs(reward_cfg) do
			if data.is_show then
				break
			end
			if not KaifuActivityData.Instance:IsGetReward(v.seq, activity_type) and
				KaifuActivityData.Instance:IsComplete(v.seq, activity_type) then
				data.is_show = true
				break
			end
		end
	end

	if KaifuActivityData.Instance:IsBossLieshouType(activity_type) then
		data.is_show = KaifuActivityData.Instance:IsShowBossRedPoint()
		data.is_show_effect = true
	end
	-- if KaifuActivityData.Instance:IsZhengBaType(activity_type) then
	-- 	data.is_show = KaifuActivityData.Instance:IsShowZhengbaRedPoint()
	-- end
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WAR_GOALS then
		data.is_show = KaifuActivityData.Instance:GetWarGoalsRedPoint() > 0
	end
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_XUANSHANG then
		data.is_show = KaifuActivityData.Instance:GetBossRewardRedPoint()
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_NATION_WAR then
		data.is_show = KaifuActivityData.Instance:GetDailyNationalPoint()
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION then
		if self.is_open_activity then
			if self.delay_set_attached == nil then
				self.delay_set_attached = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CallRemindInit, self), 1)
			end
		self.is_open_activity = false
		end
		data.is_show = KaifuActivityData.Instance:IsShowJiZiRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE then
		data.is_show = WelfareData.Instance:GetLevelRewardRemind() > 0
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT then
		data.is_show_effect = true
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE then
		data.is_show = KaifuActivityData.Instance:IsShowDayActiveRedPoint()
	end

	-- if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
	-- 	data.is_show = KaifuActivityData.Instance:IsShowLeiJiChongZhiRedPoint()
	-- end
	if activity_type > 0 and activity_type < self.combine_server_max_type then
		data.is_show = HefuActivityData.Instance:GetShowRedPointBySubType(activity_type)
	end

	data.name = list[data_index + 1].name
	data.index = data_index
	tab_btn:SetData(data)
end

function KaifuActivityView:CallRemindInit()
	ClickOnceRemindList[RemindName.ItemCollection] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.ItemCollection)
end

function KaifuActivityView:OnClickClose()
	self:Close()
end

function KaifuActivityView:OnClickTabButton(activity_type, index, tab_btn)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION then
		self:CallRemindInit()
	end
	tab_btn:SetHighLight(true)
	if self.cur_type == activity_type then
		return
	end
	self.last_type = self.cur_type
	self.cur_type = activity_type
	self.cur_index = index
	if KaifuActivityData.Instance:IsZhengBaType(self.cur_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.cur_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)
	elseif KaifuActivityData.Instance:IsBossLieshouType(self.cur_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.cur_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_BOSS_INFO)
	elseif self.cur_type > 0 and self.cur_type < self.combine_server_max_type then
		self:OpenCombineChildPanel()
	else
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.cur_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
	self.is_show_kaifu:SetValue(self.cur_type > 0 and self.cur_type < self.combine_server_max_type)
	self:CloseChildPanel()
	self:Flush()
end

function KaifuActivityView:ShowIndexCallBack(index)
	if index > 100000 then
		self.cur_type = index - 100000
		local list = KaifuActivityData.Instance:GetOpenActivityList()
		for k,v in pairs(list) do
			if v.activity_type == self.cur_type then
				self.cur_index = k
			end
		end
	end
end

function KaifuActivityView:OpenCallBack()
	self.is_show_title:SetValue(false)
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
		HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)
		self.is_show_title:SetValue(true)
	end

	local list = KaifuActivityData.Instance:GetOpenActivityList()
	if list and next(list) then
		self.cur_type = self.cur_type or list[self.cur_index].activity_type
		for k, v in pairs(list) do
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
		end
	end
	self:OpenCombineChildPanel()
	self:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFuIsFirst)
end

function KaifuActivityView:CloseCallBack()
	self.last_type = self.cur_type
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	-- if self.chu_role_info then
	-- 	GlobalEventSystem:UnBind(self.chu_role_info)
	-- 	self.chu_role_info = nil
	-- end

	if self.panel_list[4] then
		self.panel_list[4]:CloseCallBack()
	end
	self.cur_day = nil
	self.cur_index = 1
	self.cur_type = nil
	if self.panel_list[3] then
		self.panel_list[3]:CloseCallBack()
	end
	self.cur_tab_list_length = 0
end

function KaifuActivityView:OnClickChongzhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end

function KaifuActivityView:OnClickJinjie()
	if KaifuActivityData.Instance:IsAdvanceType(self.cur_type) then
		local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
		if jinjie_type then
			ViewManager.Instance:Open(OpenNameList[jinjie_type], Table_Index[jinjie_type])
			self:Close()
		end
	end
end
-----打开小助手升级面板
function KaifuActivityView:OnClickShengJi()
	if KaifuActivityData.Instance:IsChongJiType(self.cur_type) then
		local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
		ViewManager.Instance:Open(OpenNameList[jinjie_type], Table_Index[jinjie_type])
		self:Close()
	end
end
-----打开勇者之塔副本面板
function KaifuActivityView:OnClickPata()
	if KaifuActivityData.Instance:IsPaTaType(self.cur_type) then
		local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
		ViewManager.Instance:Open(OpenNameList[jinjie_type], Table_Index[jinjie_type])
		self:Close()
	end
end
-----打开经验副本面板
function KaifuActivityView:OnClickExpChallenge()
	if KaifuActivityData.Instance:IsExpChallengeType(self.cur_type) then
		local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
		ViewManager.Instance:Open(OpenNameList[jinjie_type], Table_Index[jinjie_type])
		self:Close()
	end
end

function KaifuActivityView:OnClickStrengthen()
	local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
	ViewManager.Instance:Open(OpenNameList[jinjie_type], Table_Index[jinjie_type])
	self:Close()
end

function KaifuActivityView:RemindChangeCallBack(remind_name, num)
	self:Flush()
end

function KaifuActivityView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			local list = KaifuActivityData.Instance:GetOpenActivityList()
			if list and next(list) then
				self:FlushLeftTabListView(list)
			end

			if self.cur_type and self.cur_type == 2166 and self.panel_list[13] ~= nil then
				for k,v in pairs(self.chu_jun_info_data) do
					self.panel_list[13]:RoleInfo(k, v)
				end
			end
		elseif k == "role_info" then
			if self.cur_type and self.cur_type == 2166 and self.panel_list[13] ~= nil then
				self.panel_list[13]:RoleInfo(v.role_id, v.protocol)
			end
		end
	end
end

function KaifuActivityView:FlushLeftTabListView(list)
	if list == nil or next(list) == nil then return end
	
	if self.tab_list.scroller.isActiveAndEnabled then
		if self.list_percent > 0 then
			self.tab_list.scroller:ReloadData(self.list_percent)
			self.list_percent = 0
		elseif self.cur_day ~= TimeCtrl.Instance:GetCurOpenServerDay() or self.cur_tab_list_length ~= #list then
			if not list[self.cur_index] or (self.cur_type ~= list[self.cur_index].activity_type) then
				self.cur_index = 1
				self.cur_type = nil
			end
			self.tab_list.scroller:ReloadData(0)
		else
			self.tab_list.scroller:RefreshActiveCellViews()
		end
	end
	self.cur_day = TimeCtrl.Instance:GetCurOpenServerDay()

	self:FlushPanel(list)
end

function KaifuActivityView:FlushPanel(list)
	self.cur_type = self.cur_type or list[self.cur_index].activity_type
	self.is_show_kaifu:SetValue(self.cur_type > 0 and self.cur_type < self.combine_server_max_type)
	local cond, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.cur_type)
	if cond then
		if KaifuActivityData.Instance:IsAdvanceType(self.cur_type) then
			self.cur_jinjie_grade:SetValue(cond)
			if jinjie_type then
				if not KaifuActivityData.Instance:IsAdvanceRankType(self.cur_type) then
					self.cur_jinjie_name:SetValue(Language.Common.Jinjie_Type[jinjie_type])
				else
					local rank_info = KaifuActivityData.Instance:GetOpenServerRankInfo(self.cur_type) or {}
					local rank = rank_info.myself_rank or -1
					local str = (rank + 1 >= 1 and rank + 1 < 100) and
					Language.Common.Jinjie_Type[jinjie_type]..string.format(Language.Rank.OnRankNum, rank + 1)or Language.Rank.NoInRank
					self.cur_rank_name:SetValue(str)
				end
			end
		end
		if KaifuActivityData.Instance:IsChongzhiType(self.cur_type) then
			if cond > 99999 and cond <= 99999999 then
				cond = cond / 10000
				cond = math.floor(cond)
				cond = cond .. Language.Common.Wan
			elseif cond > 99999999 then
				cond = cond / 100000000
				cond = math.floor(cond)
				cond = cond .. Language.Common.Yi
			end
			if self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
				self.leiji_diamonds:SetValue(cond)
			else
				self.cur_chongzhi_diamonds:SetValue(cond)
			end
		end
		if KaifuActivityData.Instance:IsNomalType(self.cur_type) then
			self.cur_chongji_name:SetValue(Language.Common.Jinjie_Type[jinjie_type])
			local level = GameVoManager.Instance:GetMainRoleVo().level
			local level_befor = math.floor(level % 100) ~= 0 and math.floor(level % 100) or 100
			local level_behind = math.floor(level % 100) ~= 0 and math.floor(level / 100) or math.floor(level / 100) - 1
			local level_zhuan = string.format(Language.Common.Zhuan_Level, level_befor, level_behind)
			self.current_level:SetValue(level_zhuan)
			self.cur_pata_name:SetValue(Language.Common.Jinjie_Type[jinjie_type])
			self.cur_pata_num:SetValue(cond)
			self.cur_exp_challege_name:SetValue(Language.Common.Jinjie_Type[jinjie_type])
			self.cur_exp_challege_num:SetValue(cond)
		end
		if KaifuActivityData.Instance:IsStrengthenType(self.cur_type) then
			self.cur_equip_name:SetValue(Language.Common.Jinjie_Type[jinjie_type])
			self.cur_equip_num:SetValue(cond)
		end
	end
	-- local panel_index = KaifuActivityData.Instance:ShowWhichPanelByType(self.cur_type)

	-- for k, v in pairs(self.panel_obj_list) do
	-- 	v:SetActive(false)
	-- 	if panel_index and panel_index == k then
	-- 		v:SetActive(true)
	-- 	end
	-- end
	-- if self.panel_list[panel_index] then
	-- 	self.panel_list[panel_index]:SetCurTyoe(self.cur_type)
	-- 	self.panel_list[panel_index]:Flush()
	-- end
	local last_panel = self.combine_panel_list[self.last_type]
	if last_panel then
		last_panel:SetActive(false)
	end

	for k, v in pairs(self.panel_obj_list) do
		v:SetActive(false)
	end

	local cur_panel = nil
	local panel_index = KaifuActivityData.Instance:ShowWhichPanelByType(self.cur_type) 
	if self.cur_type > self.combine_server_max_type then
		cur_panel = self.panel_list[panel_index]
		if self.panel_obj_list[panel_index] ~= nil then
			self.panel_obj_list[panel_index]:SetActive(true)
		end
	else
		cur_panel = self.combine_panel_list[self.cur_type]

		if cur_panel then
			cur_panel:SetActive(true)
		end

	end
	if cur_panel then
		-- cur_panel:SetActive(true)
		if cur_panel.SetCurTyoe then
			cur_panel:SetCurTyoe(self.cur_type)
		end
		cur_panel:Flush()
	end

	local end_day = list[self.cur_index] and list[self.cur_index].end_day_idx or 0
	local end_act_day = math.abs(end_day - TimeCtrl.Instance:GetCurOpenServerDay())
	if end_act_day == 0 then
		-- {sec = 37, min = 44, day = 26, isdst = false, wday = 7, yday = 238, year = 2017, month = 8, hour = 16}
		local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
		local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
		local reset_time_s = 24 * 3600 - cur_time
		self.show_reset_day:SetValue(false)
		self:SetRestTime(reset_time_s)
	else
		self.rest_day:SetValue(end_act_day)
		self.show_reset_day:SetValue(true)
	end

	self.show_chongzhi:SetValue(KaifuActivityData.Instance:IsChongzhiType(self.cur_type) and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)
	self.show_jinjie:SetValue(KaifuActivityData.Instance:IsAdvanceType(self.cur_type) and not KaifuActivityData.Instance:IsAdvanceRankType(self.cur_type))

	self.show_chongji:SetValue(KaifuActivityData.Instance:IsChongJiType(self.cur_type))
	self.show_pata:SetValue(KaifuActivityData.Instance:IsPaTaType(self.cur_type))
	self.show_exp_challenge:SetValue(KaifuActivityData.Instance:IsExpChallengeType(self.cur_type))
	self.show_equip_strengthen:SetValue(KaifuActivityData.Instance:IsStrengthenType(self.cur_type))
	self.show_rank_jinjie:SetValue(KaifuActivityData.Instance:IsAdvanceRankType(self.cur_type))
	self.show_top_bg:SetValue(self:IsShowViewTopImg())
	self.show_leiji_chongzhi:SetValue(self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)

	self.show_normal_bg:SetValue(self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP and self.cur_type ~= ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION
							and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU)
	self.show_jizi_bg:SetValue(self.cur_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU)
	self.show_no_bg:SetValue(self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU or self.cur_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRY_GIFT 
						or KaifuActivityData.Instance:IsTempAddType(self.cur_type))
	self.show_marrygift_bg:SetValue(self.cur_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRY_GIFT)
end

function KaifuActivityView:IsShowViewTopImg()
	if activity_show_top_list[self.cur_type] then
		return true
	end
	return false
end

function KaifuActivityView:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.reset_hour:SetValue(left_hour)
			self.reset_min:SetValue(left_min)
			self.reset_sec:SetValue(left_sec)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function KaifuActivityView:FlushTotalConsume()
	if self.panel_list[20] then
		self.panel_list[20]:Flush()
	end
end

function KaifuActivityView:FlushJinJieView()
	if not self:IsOpen() then return end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.cur_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
end

function KaifuActivityView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function KaifuActivityView:RoleInfo(role_id, protocol)
	local list = KaifuActivityData.Instance:GetChujunIdList()
	if list == nil then
		return
	end

	for k,v in pairs(list) do
		if v ~= nil and v == role_id then
			if self.cur_type and self.cur_type == 2166 then
				self:Flush("role_info", {role_id = role_id, protocol = protocol})
			else
				self.chu_jun_info_data[role_id] = protocol
			end
			break
		end
	end

	return 
end

function KaifuActivityView:OpenCombineChildPanel()
	if not self.cur_type or self.cur_type > self.combine_server_max_type then
		return
	end
	local cur_type = self.cur_type
	local panel = self.combine_panel_list[cur_type]

	if nil == panel then
		PrefabPool.Instance:Load(AssetID("uis/views/kaifuactivity_prefab","panel_" .. cur_type), function(prefab)
			local obj = U3DObject(GameObject.Instantiate(prefab))
			if self.right_combine_content  == nil or obj == nil or prefab == nil or self.hefu_script_list[cur_type] == nil then
				return
			end
			local parent = self.right_combine_content.transform
			if parent == nil then return end
			obj.transform:SetParent(parent, false)
			panel = self.hefu_script_list[cur_type].New()
			panel:SetInstance(obj)
			self.combine_panel_list[cur_type] = panel
			panel:SetActive(true)
			if panel.OpenCallBack then
				panel:OpenCallBack()
			end

		end)
	else
		if panel.OpenCallBack then
			panel:OpenCallBack()
		end
	end


end

function KaifuActivityView:CloseChildPanel()
	if self.cur_type == self.last_type then
		return
	end
	local panel = self.combine_panel_list[self.last_type]
	if nil == panel then
		return
	end
	if panel.CloseCallBack then
		panel:CloseCallBack()
	end
	-- panel:SetActive(false)

end

LeftTableButton = LeftTableButton or BaseClass(BaseRender)

function LeftTableButton:__init(instance)
	self.name = self:FindVariable("Name")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.show_effect = self:FindVariable("ShowEffect")
	self.show_red_bg = self:FindVariable("ShowRedBG")
	self.select_path = self:FindVariable("select_path")
	self.normal_path = self:FindVariable("normal_path")
	self.normal_img = self:FindObj("normal_img")
	self.high_light_img = self:FindObj("high_light_img")
	self.data = nil
end

function LeftTableButton:SetData(data)
	if not data then return end
	self.data = data
	self:Flush()
end

function LeftTableButton:OnFlush()
	local data = self.data
	if data == nil then return end
	self.name:SetValue(data.name)
	self.show_red_point:SetValue(data.is_show)
	self.show_effect:SetValue(data.is_show_effect)
	self.show_red_bg:SetValue(data.is_show_effect)
	 self.select_path:SetAsset(ResPath.GetKaiFuActivityRes("tab_select_" .. data.activity_type))
	 self.normal_path:SetAsset(ResPath.GetKaiFuActivityRes("tab_" .. data.activity_type))

	if self.high_light_img ~= nil then
		local bundle, asset = ResPath.GetKaiFuActivityRes("tab_select_" .. data.index)
		-- self.high_light_img:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(bundle, asset, function()
		-- 	self.high_light_img:GetComponent(typeof(UnityEngine.UI.Image)):SetNativeSize()
		-- end)
	end

	if self.normal_img ~= nil then
		local bundle, asset = ResPath.GetKaiFuActivityRes("tab_" .. data.index)
		-- self.normal_img:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(bundle, asset, function()
		-- 	self.normal_img:GetComponent(typeof(UnityEngine.UI.Image)):SetNativeSize()
		-- end)
	end
end

function LeftTableButton:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function LeftTableButton:ListenClick(handler)
	self:ClearEvent("click")
	self:ListenEvent("click", handler)
end

function LeftTableButton:SetHighLight(enable)
	self.root_node.toggle.isOn = enable

	self.high_light_img:SetActive(enable)
	self.normal_img:SetActive(not enable)
end
