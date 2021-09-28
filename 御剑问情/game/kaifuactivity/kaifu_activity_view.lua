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

-- 现在开服活动跟合服活动公用这个面板
function KaifuActivityView:__init()
	self.ui_config = {"uis/views/kaifuactivity_prefab", "KaiFuView"}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.cur_index = 1
	self.cell_list = {}
	self.panel_list = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.cur_tab_list_length = 0

	-- 开服活动里面要加合服活动，拿合服活动的sub_type当作activity_type
	-- 这里规定activity_type小于100的为合服活动
	self.combine_server_max_type = 100

	self.hefu_script_list = {
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU] = RushToPurchase,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL] = LucklyTurntable,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_GONGCHENGZHAN] = CityContend,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS] = BossLoot,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK] = CombineServerChongZhiRank,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CONSUME_RANK] = CombineServerConsubeRank,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_PERSONAL_PANIC_BUY] = PersonFullServerSnapView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY] = HeFuFullServerSnapView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SINGLE_CHARGE] = CombineServerDanBiChongZhi,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift] = LoginjiangLiView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS] = HeFuBossView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI] = HeFuTouZiView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN] = HeFuJiJinView,
	}

	-- 打开界面后左边按钮list_view移动到的百分比
	self.list_percent = 0
end

function KaifuActivityView:__delete()
	self.hefu_script_list = {}
end

function KaifuActivityView:ReleaseCallBack()
	self.cur_type = nil
	self.cur_index = 1
	self.cur_day = nil

	self.right_combine_content = nil

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
	self.aysnc_load_list = {}
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.KaifuActivityView)
	end
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	-- 清理变量和对象
	-- self.show_chongzhi = nil
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
	self.cur_jinjie_name = nil
	self.cur_jinjie_grade = nil
	-- self.cur_chongzhi_diamonds = nil
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
	self.activity_name = nil
	self.is_show_kaifu = nil

	self.cur_type = 0
	self.last_type = 0
end

function KaifuActivityView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	-- self:ListenEvent("Chongzhi", BindTool.Bind(self.OnClickChongzhi, self))
	self:ListenEvent("Jinjie", BindTool.Bind(self.OnClickJinjie, self))
	self:ListenEvent("ShenJi", BindTool.Bind(self.OnClickShengJi, self))
	self:ListenEvent("PaTa", BindTool.Bind(self.OnClickPata, self))
	self:ListenEvent("ExpChallenge", BindTool.Bind(self.OnClickExpChallenge, self))
	self:ListenEvent("OnClickStrengthen", BindTool.Bind(self.OnClickStrengthen, self))

	-- self.show_chongzhi = self:FindVariable("ShowCongzhi")
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

	self.cur_jinjie_name = self:FindVariable("CurDayName")
	self.cur_jinjie_grade = self:FindVariable("CurGrade")
	-- self.cur_chongzhi_diamonds = self:FindVariable("CurDiamonds")
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

	self.activity_name = self:FindVariable("activity_name")
	self.right_combine_content = self:FindObj("RightCombineContent")
	self.is_show_kaifu = self:FindVariable("is_show_kaifu")

	self.panel_obj_list = {
		[TabIndex.kaifu_panel_one] = self:FindObj("Panel1"),
		[TabIndex.kaifu_panel_three] = self:FindObj("Panel2"),
		[TabIndex.kaifu_panel_six] = self:FindObj("Panel3"),
		[TabIndex.kaifu_panel_seven] = self:FindObj("Panel4"),
		[TabIndex.kaifu_panel_eight] = self:FindObj("Panel5"),
		[TabIndex.kaifu_panel_two] = self:FindObj("Panel6"),
		[TabIndex.kaifu_panel_ten] = self:FindObj("Panel7"),
		[TabIndex.kaifu_panel_twelve] = self:FindObj("Panel8"),
		[TabIndex.kaifu_personbuy] = self:FindObj("Panel9"),
		[TabIndex.kaifu_levelreward] = self:FindObj("WelfareLevelPanel"),
		[TabIndex.kaifu_7dayredpacket] = self:FindObj("7DayRedPackets"),
		[TabIndex.kaifu_goldenpigcall] = self:FindObj("GoldenPigCallPanel"),
		[TabIndex.kaifu_lianxuchongzhigao] = self:FindObj("Panel10"),
		[TabIndex.kaifu_lianxuchongzhichu] = self:FindObj("Panel11"),
		[TabIndex.kaifu_panel_fifteen] = self:FindObj("Panel15"),
		[TabIndex.kaifu_panel_sixteen] = self:FindObj("Panel16"),
		[TabIndex.kaifu_dailyactivereward] = self:FindObj("Panel17"),
		[TabIndex.kaifu_congzhirank] = self:FindObj("DayChongZhiRank"),
		[TabIndex.kaifu_xiaofeirank] = self:FindObj("DayXiaoFeiRank"),
		-- [TabIndex.kaifu_bianshenrank] = self:FindObj("DayBianShenRank"),
		-- [TabIndex.kaifu_beibianshenrank] = self:FindObj("DayBeiBianShenRank"),
		[TabIndex.kaifu_leijireward] = self:FindObj("LeijiReward"),
		[TabIndex.kaifu_danbichongzhi] = self:FindObj("DanBiChongZhi"),
		[TabIndex.kaifu_rechargerebate] = self:FindObj("RechargeRebate"),
		[TabIndex.kaifu_totalcharge] = self:FindObj("TotalCharge"),
		[TabIndex.kaifu_fullserversnap] = self:FindObj("FullServiceSnap"),
		[TabIndex.kaifu_totalconsume] = self:FindObj("TotalConsume"),
		[TabIndex.kaifu_dayconsume] = self:FindObj("DayConsume"),
		[TabIndex.kaifu_daily_love] = self:FindObj("DailyLove"),
		[TabIndex.kaifu_daychongzhi] = self:FindObj("DailyDanBi"),
		[TabIndex.kaifu_ZhiZunHuiYuan] = self:FindObj("ZhiZunHuiYuan"),
		[TabIndex.kaifu_levelinvest] = self:FindObj("LevelInvestment"),
		[TabIndex.kaifu_touziplan] = self:FindObj("TouZiPlanContent"),
		[TabIndex.expense_nice_gift] = self:FindObj("ConsumeGift")
	}
	self.panel_list = {
		[TabIndex.kaifu_panel_one] = KaifuActivityPanelOne.New(self.panel_obj_list[TabIndex.kaifu_panel_one]),
		[TabIndex.kaifu_panel_six] = KaifuActivityPanelSix.New(self.panel_obj_list[TabIndex.kaifu_panel_six]),
	}

	-- 合服小面板都是保存成单个的预制体 跟原开服界面的做法不同，故区分开
	self.combine_panel_list = {}
	self.cur_type = 0
	self.last_type = 0
	self.aysnc_load_list = {}

	self.tab_list = self:FindObj("ToggleList")
	local list_delegate = self.tab_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:Flush()

	self.btn_close = self:FindObj("BtnClose")								--关闭按钮

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.KaifuActivityView, BindTool.Bind(self.GetUiCallBack, self))
	RemindManager.Instance:Bind(self.remind_change, RemindName.KaiFu)
	--self.activity_name:SetValue(Language.Mainui.JingCaiAct)
	self.activity_name:SetValue(Language.Mainui.DailyActivity)
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
		self.activity_name:SetValue(Language.Mainui.CombineServer)
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.OPEN_SERVER) then
		self.activity_name:SetValue(Language.Mainui.NewServer)
	end
end

function KaifuActivityView:GetNumberOfCells()
	self.cur_tab_list_length = #KaifuActivityData.Instance:GetOpenActivityList()

	return #KaifuActivityData.Instance:GetOpenActivityList()
end

function KaifuActivityView:RefreshCell(cell, data_index)
	local list = KaifuActivityData.Instance:GetOpenActivityList()
	if not list or not next(list) then return end
	local activity_type = list[data_index + 1] and list[data_index + 1].activity_type or list[data_index + 1].sub_type or 0
	local data = {}
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(activity_type)

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
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION then
		data.is_show = KaifuActivityData.Instance:IsShowJiZiRedPoint()
	end
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG then
		data.is_show = KaifuActivityData.Instance:IsShowGoldenPigRedPoint()
	end
	if activity_type == TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE then
		data.is_show = WelfareData.Instance:GetLevelRewardRemind() > 0
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI then
		data.is_show = KaifuActivityData.Instance:IsDailyDanBiRedPoint() and 1 or 0
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT then
		data.is_show_effect = true
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then
		local is_first_open = KaifuActivityData.Instance:IsFirstGaoOpen()
		data.is_show = is_first_open == true and is_first_open or KaifuActivityData.Instance:LianChongTeHuiGaoRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then
		local is_first_open = KaifuActivityData.Instance:IsFirstChuOpen()
		data.is_show = is_first_open == true and is_first_open or KaifuActivityData.Instance:LianChongTeHuiChuRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO then
		data.is_show = ActiviteHongBaoData.Instance:GetHongBaoRemind()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST then
		data.is_show = KaifuActivityData.Instance:ShowInvestRedPoint()
		data.is_show_effect = true
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE then
		data.is_show = KaifuActivityData.Instance:IsShowDayActiveRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT then
		data.is_show = KaifuActivityData.Instance:GetLeiJiChargeRewardRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE then
		data.is_show = KaifuActivityData.Instance:IsTotalChargeRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME then
		data.is_show = KaifuActivityData.Instance:IsDayConsumeRedPoint()
	end
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME then  		--累计消费
		data.is_show = KaifuActivityData.Instance:IsTotalConsumeRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.ZHIZUN_HUIYUAN_ACTIVITY_TYPE then  		--至尊会员
		data.is_show = KaifuActivityData.Instance:IsZhiZunHuiYuanRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.LEVEL_INVEST_ACTIVITY_TYPE then  		--等级投资
		data.is_show = KaifuActivityData.Instance:IsLevelInvestRedPoint()
	end

	if activity_type == TEMP_ADD_ACT_TYPE.TOUZI_PLAN_ACTIVITY_TYPE then  		--成长基金
		data.is_show = KaifuActivityData.Instance:IsTouZiPlanRedPoint()
	end
	--合服--登录奖励
	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift then
		data.is_show = HefuActivityData.Instance:GetShowRedPointBySubType(activity_type)
	end

	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS then
		data.is_show = HefuActivityData.Instance:IsShowBossLooyRedPoint(activity_type)
	end

	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL then
		data.is_show = HefuActivityData.Instance:IsLucklyTurntableRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI then
		data.is_show = KaifuActivityData.Instance:IsRechargeRebateRedPoint()
	end

	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI then
		data.is_show = HefuActivityData.Instance:IsShowTouZiRedPoint()
	end

	if activity_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN then
		data.is_show = HefuActivityData.Instance:IsShowHeFuJiJinRedPoint()
	end

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2 then
		data.is_show = KaifuActivityData.Instance:IsShowExpenseNiceGiftRedPoint()
	end

	data.name = list[data_index + 1].name

	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST then
		if KaifuActivityData.Instance:IsKaifuActivity(activity_type) then
			data.name = KaifuActivityData.Instance.special_tab_name[RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST]
		end
	end
	tab_btn:SetData(data)
end

function KaifuActivityView:OnClickClose()
	self:Close()
end

function KaifuActivityView:OnClickTabButton(activity_type, index, tab_btn)
	tab_btn:SetHighLight(true)
	if self.cur_type == activity_type then
		return
	end
	-- 这两个活动上线会用红点提醒一次玩家去看，每天只会提醒一次
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		UnityEngine.PlayerPrefs.SetInt(main_role_id .. "lianchongtehui_chu", cur_day)
		RemindManager.Instance:Fire(RemindName.LianChongTeHuiChu)
	elseif activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		UnityEngine.PlayerPrefs.SetInt(main_role_id .. "lianchongtehui_gao", cur_day)
		RemindManager.Instance:Fire(RemindName.LianChongTeHuiGao)
	end
	self.last_type = self.cur_type
	self.cur_type = activity_type
	self.cur_index = index
	self:OpenPanle()
	self:CloseChildPanel()
	self:Flush()
end

function KaifuActivityView:OpenPanle()
	if self.cur_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION then
		KaifuActivityData.Instance:SetCollectionLastRemindTime(TimeCtrl.Instance:GetServerTime())
		RemindManager.Instance:Fire(RemindName.KaiFu)

		RemindManager.Instance:SetTodayDoFlag(RemindName.JiZiAct)
		KaifuActivityCtrl.Instance:SetCollectionRunTimer()
	end
	if self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP and self.panel_list[TabIndex.kaifu_fullserversnap] then
		self.panel_list[TabIndex.kaifu_fullserversnap]:CloseCallBack()
	end
	if KaifuActivityData.Instance:IsZhengBaType(self.cur_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.cur_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)
	end
end

function KaifuActivityView:AsyncLoadView(activity_type)
	if self.aysnc_load_list[activity_type] then return end
	self.aysnc_load_list[activity_type] = true
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA then
		if not self.panel_list[TabIndex.kaifu_panel_seven] then
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "SevenContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_panel_seven].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_panel_seven] = KaifuActivityPanelSeven.New(obj)
				self.panel_list[TabIndex.kaifu_panel_seven]:Flush(activity_type)
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN then
		if not self.panel_list[TabIndex.kaifu_panel_three] then
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "ThreeContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_panel_three].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_panel_three] = KaifuActivityPanelThree.New(obj)
				self.panel_list[TabIndex.kaifu_panel_three]:Flush(activity_type)
			end)
		end
	elseif KaifuActivityData.Instance:IsBossLieshouType(activity_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_BOSS_INFO)
		if not self.panel_list[TabIndex.kaifu_panel_eight] then
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "EightContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_panel_eight].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_panel_eight] = KaifuActivityPanelEight.New(obj)
				self.panel_list[TabIndex.kaifu_panel_eight]:Flush(activity_type)
			end)
		end
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION then
		if not self.panel_list[TabIndex.kaifu_panel_two] then
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "TwoContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_panel_two].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_panel_two] = KaifuActivityPanelTwo.New(obj)
				self.panel_list[TabIndex.kaifu_panel_two]:Flush(activity_type)
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT then
		if not self.panel_list[TabIndex.kaifu_panel_twelve] then
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "TwelveContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_panel_twelve].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_panel_twelve] = KaifuActivityPanelTwelve.New(obj)
				self.panel_list[TabIndex.kaifu_panel_twelve]:Flush(activity_type)
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP then
		if not self.panel_list[TabIndex.kaifu_personbuy] then
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "PanelPersonBuyContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_personbuy].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_personbuy] = KaifuActivityPanelPersonBuy.New(obj)
				self.panel_list[TabIndex.kaifu_personbuy]:Flush()
			end)
		end
	elseif activity_type == TEMP_ADD_ACT_TYPE.WELFARE_LEVEL_ACTIVITY_TYPE then
		if not self.panel_list[TabIndex.kaifu_levelreward] then
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "LevelRewardContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_levelreward].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_levelreward] = LevelRewardView.New(obj)
				self.panel_list[TabIndex.kaifu_levelreward]:Flush()
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO then
		if not self.panel_list[TabIndex.kaifu_7dayredpacket] then
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "7DayRedpacketContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_7dayredpacket].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_7dayredpacket] = KaifuActivity7DayRedpacket.New(obj)
				self.panel_list[TabIndex.kaifu_7dayredpacket]:Flush()
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG then
		KaifuActivityCtrl.Instance:SendGoldenPigCallInfoReq(GOLDEN_PIG_OPERATE_TYPE.GOLDEN_PIG_OPERATE_TYPE_REQ_INFO)
		if not self.panel_list[TabIndex.kaifu_goldenpigcall] then
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "GoldenPigCallContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_goldenpigcall].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_goldenpigcall] = KaifuActivityGoldenPigCallView.New(obj)
				self.panel_list[TabIndex.kaifu_goldenpigcall]:Flush()
			end)
		end
	elseif activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO then
		if not self.panel_list[TabIndex.kaifu_lianxuchongzhigao] then
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "LianXuChongZhiGaoContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_lianxuchongzhigao].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_lianxuchongzhigao] = LianXuChongZhiGao.New(obj)
			end)
		end
	elseif activity_type == TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU then
		if not self.panel_list[TabIndex.kaifu_lianxuchongzhichu] then
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "LianXuChongZhiChuContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_lianxuchongzhichu].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_lianxuchongzhichu] = LianXuChongZhiChu.New(obj)
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KAIFU_INVEST then
		if self.panel_list[TabIndex.kaifu_panel_fifteen] then
			self.panel_list[TabIndex.kaifu_panel_fifteen]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "FifteenContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_panel_fifteen].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_panel_fifteen] = KaifuActivityPanelFifteen.New(obj)
				self.panel_list[TabIndex.kaifu_panel_fifteen]:OpenCallBack()
			end)
		end
	--珍宝兑换
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE then
		if self.panel_list[TabIndex.kaifu_panel_sixteen] then
			self.panel_list[TabIndex.kaifu_panel_sixteen]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "SixteenContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_panel_sixteen].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_panel_sixteen] = KaifuActivityPanelSixteen.New(obj)
				self.panel_list[TabIndex.kaifu_panel_sixteen]:OpenCallBack()
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_ACTIVIE_DEGREE then
		if self.panel_list[TabIndex.kaifu_dailyactivereward] then
			self.panel_list[TabIndex.kaifu_dailyactivereward]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "DailyActiveRewardContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_dailyactivereward].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_dailyactivereward] = DailyActiveReward.New(obj)
				self.panel_list[TabIndex.kaifu_dailyactivereward]:OpenCallBack()
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK then
		if self.panel_list[TabIndex.kaifu_congzhirank] then
			self.panel_list[TabIndex.kaifu_congzhirank]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "ChongZhiRankContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_congzhirank].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_congzhirank] = CongZhiRank.New(obj)
				self.panel_list[TabIndex.kaifu_congzhirank]:OpenCallBack()
				self.panel_list[TabIndex.kaifu_congzhirank]:Flush()
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK then
		if self.panel_list[TabIndex.kaifu_xiaofeirank] then
			self.panel_list[TabIndex.kaifu_xiaofeirank]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "XiaoFeiRankContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_xiaofeirank].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_xiaofeirank] = XiaoFeiRank.New(obj)
				self.panel_list[TabIndex.kaifu_xiaofeirank]:OpenCallBack()
			end)
		end
	-- elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK then
	-- 	if self.panel_list[TabIndex.kaifu_bianshenrank] then
	-- 		self.panel_list[TabIndex.kaifu_bianshenrank]:OpenCallBack()
	-- 	else
	-- 		UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "BianShenRankContent", function(obj)
	-- 			obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_bianshenrank].transform, false)
	-- 			obj = U3DObject(obj)
	-- 			self.panel_list[TabIndex.kaifu_bianshenrank] = BianShenRank.New(obj)
	-- 			self.panel_list[TabIndex.kaifu_bianshenrank]:OpenCallBack()
	-- 		end)
	-- 	end
	-- elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK then
	-- 	if self.panel_list[TabIndex.kaifu_beibianshenrank] then
	-- 		self.panel_list[TabIndex.kaifu_beibianshenrank]:OpenCallBack()
	-- 	else
	-- 		UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "BeiBianShenRankContent", function(obj)
	-- 			obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_beibianshenrank].transform, false)
	-- 			obj = U3DObject(obj)
	-- 			self.panel_list[TabIndex.kaifu_beibianshenrank] = BeiBianShenRank.New(obj)
	-- 			self.panel_list[TabIndex.kaifu_beibianshenrank]:OpenCallBack()
	-- 		end)
	-- 	end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT then
		if self.panel_list[TabIndex.kaifu_leijireward] then
			self.panel_list[TabIndex.kaifu_leijireward]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "LeiJiRewardContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_leijireward].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_leijireward] = LeiJiRewardView.New(obj)
				self.panel_list[TabIndex.kaifu_leijireward]:OpenCallBack()
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI then
		if self.panel_list[TabIndex.kaifu_danbichongzhi] then
			self.panel_list[TabIndex.kaifu_danbichongzhi]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "DanBiChongZhiContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_danbichongzhi].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_danbichongzhi] = KaifuActivityPanelDanBiChongZhi.New(obj)
				self.panel_list[TabIndex.kaifu_danbichongzhi]:OpenCallBack()
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_DAY_CHONGZHI_FANLI then
		if self.panel_list[TabIndex.kaifu_rechargerebate] then
			self.panel_list[TabIndex.kaifu_rechargerebate]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "RechargeRebateContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_rechargerebate].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_rechargerebate] = KaifuActivityRechargeRebate.New(obj)
				self.panel_list[TabIndex.kaifu_rechargerebate]:OpenCallBack()
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE then
		if self.panel_list[TabIndex.kaifu_totalcharge] then
			self.panel_list[TabIndex.kaifu_totalcharge]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "TotalChargeContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_totalcharge].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_totalcharge] = TotalCharge.New(obj)
				self.panel_list[TabIndex.kaifu_totalcharge]:OpenCallBack()
			end)
		end
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FULL_SERVER_SNAP then
		if self.panel_list[TabIndex.kaifu_fullserversnap] then
			self.panel_list[TabIndex.kaifu_fullserversnap]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "FullServerSnapContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_fullserversnap].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_fullserversnap] = FullServerSnapView.New(obj)
				self.panel_list[TabIndex.kaifu_fullserversnap]:OpenCallBack()
			end)
		end
	--累计消费
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CONSUME then
		if self.panel_list[TabIndex.kaifu_totalconsume] then
			self.panel_list[TabIndex.kaifu_totalconsume]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "TotalComsumeContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_totalconsume].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_totalconsume] = OpenActTotalConsume.New(obj)
				self.panel_list[TabIndex.kaifu_totalconsume]:OpenCallBack()
			end)
		end

	--每日单笔
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI then
		if self.panel_list[TabIndex.kaifu_daychongzhi] then
			self.panel_list[TabIndex.kaifu_daychongzhi]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "DailyDanBi", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_daychongzhi].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_daychongzhi] = OpenActDailyDanBi.New(obj)
				self.panel_list[TabIndex.kaifu_daychongzhi]:OpenCallBack()
			end)
		end
	--每日消费
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CONSUME then
		if self.panel_list[TabIndex.kaifu_dayconsume] then
			self.panel_list[TabIndex.kaifu_dayconsume]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "DayComsumeContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_dayconsume].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_dayconsume] = OpenActDayConsume.New(obj)
				self.panel_list[TabIndex.kaifu_dayconsume]:OpenCallBack()
			end)
		end
	--每日一爱
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_LOVE then
		if self.panel_list[TabIndex.kaifu_daily_love] then
			self.panel_list[TabIndex.kaifu_daily_love]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "DailyLoveContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_daily_love].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_daily_love] = OpenActDailyLove.New(obj)
				self.panel_list[TabIndex.kaifu_daily_love]:OpenCallBack()
			end)
		end
	--至尊会员
	elseif activity_type == TEMP_ADD_ACT_TYPE.ZHIZUN_HUIYUAN_ACTIVITY_TYPE then
		if self.panel_list[TabIndex.kaifu_ZhiZunHuiYuan] then
			self.panel_list[TabIndex.kaifu_ZhiZunHuiYuan]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "ZhiZunHuiYuanContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_ZhiZunHuiYuan].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_ZhiZunHuiYuan] = OpenActZhiZunHuiYuan.New(obj)
				self.panel_list[TabIndex.kaifu_ZhiZunHuiYuan]:OpenCallBack()
			end)
		end
	--等级投资
	elseif activity_type == TEMP_ADD_ACT_TYPE.LEVEL_INVEST_ACTIVITY_TYPE then
		if self.panel_list[TabIndex.kaifu_levelinvest] then
			self.panel_list[TabIndex.kaifu_levelinvest]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "LevelInvestment", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_levelinvest].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_levelinvest] = OpenActLevelInvestment.New(obj)
				self.panel_list[TabIndex.kaifu_levelinvest]:OpenCallBack()
			end)
		end
	--成长基金
	elseif activity_type == TEMP_ADD_ACT_TYPE.TOUZI_PLAN_ACTIVITY_TYPE then
		if self.panel_list[TabIndex.kaifu_touziplan] then
			self.panel_list[TabIndex.kaifu_touziplan]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "TouZiPlanContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.kaifu_touziplan].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.kaifu_touziplan] = OpenActTouZiPlan.New(obj)
				self.panel_list[TabIndex.kaifu_touziplan]:OpenCallBack()
			end)
		end
	-- 消费好礼
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2 then
		-- activity_tag
		if self.panel_list[TabIndex.expense_nice_gift] then
			self.panel_list[TabIndex.expense_nice_gift]:OpenCallBack()
		else
			UtilU3d.PrefabLoad("uis/views/kaifuactivity_prefab", "ExpenseNiceGiftContent", function(obj)
				obj.transform:SetParent(self.panel_obj_list[TabIndex.expense_nice_gift].transform, false)
				obj = U3DObject(obj)
				self.panel_list[TabIndex.expense_nice_gift] = KaifuExpenseGift.New(obj)
				self.panel_list[TabIndex.expense_nice_gift]:OpenCallBack()
			end)
		end

	elseif activity_type > 0 and activity_type < self.combine_server_max_type then
		self:OpenCombineChildPanel()
	else
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
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

		self.list_percent = self.cur_index / self:GetNumberOfCells()
	end
end

function KaifuActivityView:OpenCallBack()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
		HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_INFO_REQ)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_RANK_REQ)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_ROLE_INFO_REQ)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN, CSA_FOUNDATION_OPERA.CSA_FOUNDATION_INFO_REQ)
	end
	local list = KaifuActivityData.Instance:GetOpenActivityList()
	-- 把0赋给0？？？G16的垃圾代码
	-- if list and next(list) then
		-- self.cur_type = self.cur_type or list[self.cur_index].activity_type

	-- 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.cur_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	-- end
	--刷新活动信息
	for _, v in pairs(list) do
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v.activity_type or v.sub_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
	self:OpenPanle()
	self:Flush()
end

function KaifuActivityView:CloseCallBack()
	self.last_type = self.cur_type
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.count_down_chu ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_chu)
		self.count_down_chu = nil
	end
	if self.count_down_gao ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_gao)
		self.count_down_gao = nil
	end
	self.cur_day = nil
	self.cur_index = 1
	self.cur_type = nil

	for k,v in pairs(self.panel_list) do
		if v.CloseCallBack then
			v:CloseCallBack()
		end
	end

	self.cur_tab_list_length = 0
end

-- function KaifuActivityView:OnClickChongzhi()
-- 	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
-- 	ViewManager.Instance:Open(ViewName.VipView)
-- 	self:Close()
-- end

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

function KaifuActivityView:FlushShouChongTuanGou()
	if self.panel_list[TabIndex.kaifu_panel_three] then
		self.panel_list[TabIndex.kaifu_panel_three]:Flush()
	end
end

function KaifuActivityView:FlushDayChongZhi()
	if self.panel_list[TabIndex.kaifu_congzhirank] then
		self.panel_list[TabIndex.kaifu_congzhirank]:FlushChongZhi()
	end
end

function KaifuActivityView:FlushDailyLove()
	if self.panel_list[TabIndex.kaifu_daily_love] then
		self.panel_list[TabIndex.kaifu_daily_love]:Flush()
	end
end

function KaifuActivityView:FlushLeiJiChongZhi()
	if self.panel_list[TabIndex.kaifu_leijireward] then
		self.panel_list[TabIndex.kaifu_leijireward]:Flush()
	end
end

function KaifuActivityView:FlushDayXiaoFei()
	if nil ~= self.panel_list[TabIndex.kaifu_xiaofeirank] then
		self.panel_list[TabIndex.kaifu_xiaofeirank]:FlushXiaoFei()
	end
end

function KaifuActivityView:FlushDailyDanBi()
	if nil ~= self.panel_list[TabIndex.kaifu_daychongzhi] then
		self.panel_list[TabIndex.kaifu_daychongzhi]:Flush()
	end
end

function KaifuActivityView:FlushZhiZunHuiYuan()
	if nil ~= self.panel_list[TabIndex.kaifu_ZhiZunHuiYuan] then
		self.panel_list[TabIndex.kaifu_ZhiZunHuiYuan]:Flush()
	end
end

function KaifuActivityView:FlushLevelInvest()
	if nil ~= self.panel_list[TabIndex.kaifu_levelinvest] then
		self.panel_list[TabIndex.kaifu_levelinvest]:Flush()
	end
end

function KaifuActivityView:FlushTouZiPlan()
	if nil ~= self.panel_list[TabIndex.kaifu_touziplan] then
		self.panel_list[TabIndex.kaifu_touziplan]:Flush()
	end
end

function KaifuActivityView:FlushDayActivity()
	if self.panel_list[TabIndex.kaifu_dailyactivereward] then
		self.panel_list[TabIndex.kaifu_dailyactivereward]:Flush()
	end
end

function KaifuActivityView:FlushDayConsume()
	if self.panel_list[TabIndex.kaifu_dayconsume] then
		self.panel_list[TabIndex.kaifu_dayconsume]:Flush()
	end
end

function KaifuActivityView:FlushTotalConsume()
	if self.panel_list[TabIndex.kaifu_totalconsume] then
		self.panel_list[TabIndex.kaifu_totalconsume]:Flush()
	end
end

function KaifuActivityView:FlushDanBiChongZhi()
	if self.panel_list[TabIndex.kaifu_danbichongzhi] then
		self.panel_list[TabIndex.kaifu_danbichongzhi]:Flush()
	end
end

function KaifuActivityView:FlushRechargeRebate()
	if self.panel_list[TabIndex.kaifu_rechargerebate] then
		self.panel_list[TabIndex.kaifu_rechargerebate]:Flush()
	end
end

function KaifuActivityView:FlushTotalCharge()
	if self.panel_list[TabIndex.kaifu_totalcharge] then
		self.panel_list[TabIndex.kaifu_totalcharge]:Flush()
	end
end

function KaifuActivityView:OnFlush(param_t)
	local list = KaifuActivityData.Instance:GetOpenActivityList()

	if list and next(list) then
		self:FlushLeftTabListView(list)
		self:FlushRightPanel(list, param_t)
	end

	if self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK then
		if self.panel_list[TabIndex.kaifu_xiaofeirank] then
			self.panel_list[TabIndex.kaifu_xiaofeirank]:Flush()
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
end

function KaifuActivityView:FlushRightPanel(list, param_t)
	self.cur_type = self.cur_type or list[self.cur_index].activity_type
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
			cond = CommonDataManager.ConverMoney(cond)
			if self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE then
				self.leiji_diamonds:SetValue(cond)
			else
				-- self.cur_chongzhi_diamonds:SetValue(cond)
			end
		end
		if KaifuActivityData.Instance:IsNomalType(self.cur_type) then
			self.cur_chongji_name:SetValue(Language.Common.Jinjie_Type[jinjie_type])
			local level = GameVoManager.Instance:GetMainRoleVo().level
			-- local level_befor = math.floor(level % 100) ~= 0 and math.floor(level % 100) or 100
			-- local level_behind = math.floor(level % 100) ~= 0 and math.floor(level / 100) or math.floor(level / 100) - 1
			-- local level_zhuan = string.format(Language.Common.Zhuan_Level, level_befor, level_behind)
			local level_zhuan = PlayerData.GetLevelString(level)
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
	-- 先关闭上一个面板（目前只适用合服界面）
	local last_panel = self.combine_panel_list[self.last_type]
	if last_panel then
		last_panel:SetActive(false)
	end

	for k, v in pairs(self.panel_obj_list) do
		v:SetActive(false)
	end

	local cur_panel = nil
	local panel_index = KaifuActivityData.Instance:ShowWhichPanelByType(self.cur_type) or 0
	if self.cur_type > self.combine_server_max_type then
		cur_panel = self.panel_list[panel_index]
		if nil == cur_panel then
			self:AsyncLoadView(self.cur_type)
		end
		-- if panel_index == TabIndex.expense_nice_gift then
		-- 	print_error("点亮")
		-- end
		if self.panel_obj_list[panel_index] then
			self.panel_obj_list[panel_index]:SetActive(true)
		end
	else
		self:AsyncLoadView(self.cur_type)
		cur_panel = self.combine_panel_list[self.cur_type]
	end
	self.is_show_kaifu:SetValue(self.cur_type > 0 and self.cur_type < self.combine_server_max_type)

	if cur_panel then
		cur_panel:SetActive(true)
		if cur_panel.Flush then
			for k,v in pairs(param_t) do
				if k == "luckly" then
					cur_panel:Flush(k)
					return
				else
					cur_panel:Flush(self.cur_type)
				end
			end
		end

		if cur_panel.FlushView then
			cur_panel:FlushView()
		end
	end

	if self.panel_list[panel_index] then
		self.panel_list[panel_index]:Flush(self.cur_type)
	end

	local end_day = list[self.cur_index] and list[self.cur_index].end_day_idx or 0
	local end_act_day = end_day - TimeCtrl.Instance:GetCurOpenServerDay()
	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local reset_time_s = 24 * 3600 - cur_time
	if end_act_day >= 0 then
		reset_time_s = reset_time_s + 24 * 3600 * end_act_day
	end
	self:SetRestTime(reset_time_s)


	-- self.show_chongzhi:SetValue(KaifuActivityData.Instance:IsChongzhiType(self.cur_type) and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)
	self.show_jinjie:SetValue(KaifuActivityData.Instance:IsAdvanceType(self.cur_type) and not KaifuActivityData.Instance:IsAdvanceRankType(self.cur_type))

	self.show_chongji:SetValue(KaifuActivityData.Instance:IsChongJiType(self.cur_type))
	self.show_pata:SetValue(KaifuActivityData.Instance:IsPaTaType(self.cur_type))
	self.show_exp_challenge:SetValue(KaifuActivityData.Instance:IsExpChallengeType(self.cur_type))
	self.show_equip_strengthen:SetValue(KaifuActivityData.Instance:IsStrengthenType(self.cur_type))
	self.show_rank_jinjie:SetValue(KaifuActivityData.Instance:IsAdvanceRankType(self.cur_type))
	self.show_top_bg:SetValue(not KaifuActivityData.Instance:IsZhengBaType(self.cur_type))
	self.show_leiji_chongzhi:SetValue(self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)

	self.show_normal_bg:SetValue(self.cur_type ~= ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION
							and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU)
	self.show_jizi_bg:SetValue(self.cur_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION and self.cur_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU)
	self.show_no_bg:SetValue(self.cur_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU or KaifuActivityData.Instance:IsTempAddType(self.cur_type))
end

function KaifuActivityView:SetRestTime(diff_time)
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(total_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local time_str = ""
			local day_second = 24 * 60 * 60         -- 一天有多少秒
			local left_day = math.floor(left_time / day_second)
			if left_day > 0 then
				time_str = TimeUtil.FormatSecond(left_time, 7)
			elseif left_time < day_second then
				if math.floor(left_time / 3600) > 0 then
					time_str = TimeUtil.FormatSecond(left_time, 1)
				else
					time_str = TimeUtil.FormatSecond(left_time, 2)
				end
			end
			self.reset_hour:SetValue(time_str)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
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

function KaifuActivityView:FlushHeFuTouZiView()
	if self.combine_panel_list and self.combine_panel_list[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI] then
		self.combine_panel_list[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI]:Flush()
	end
end

function KaifuActivityView:OpenCombineChildPanel()
	if self.cur_type > self.combine_server_max_type then
		return
	end
	local cur_type = self.cur_type

	local panel = self.combine_panel_list[cur_type]
	if nil == panel then
		UtilU3d.PrefabLoad(
			"uis/views/hefuactivity_prefab",
			"panel_" .. cur_type,
			function(obj)
				obj.transform:SetParent(self.right_combine_content.transform, false)
				obj = U3DObject(obj)
				if nil == self.hefu_script_list[cur_type] then
					print_error("没有对应的脚本文件！！！！, 活动号：", cur_type)
					return
				end

				panel = self.hefu_script_list[cur_type].New(obj)
				self.combine_panel_list[cur_type] = panel
				panel:SetActive(true)
				if panel.OpenCallBack then
					panel:OpenCallBack()
				end
			end)
	else
		panel:SetActive(true)

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

function KaifuActivityView:ExpenseViewStartRoll()
	if nil ~= self.panel_list[TabIndex.expense_nice_gift] then
		self.panel_list[TabIndex.expense_nice_gift].roll_bar_anim:SetTrigger("Roll")
		self.panel_list[TabIndex.expense_nice_gift]:StartRoll()
	end
end

LeftTableButton = LeftTableButton or BaseClass(BaseRender)

function LeftTableButton:__init(instance)
	self.name = self:FindVariable("Name")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.show_effect = self:FindVariable("ShowEffect")
	self.show_red_bg = self:FindVariable("ShowRedBG")
	self.left_button = self:FindVariable("left_button")
end

function LeftTableButton:SetData(data)
	if data == nil then return end
	self.name:SetValue(data.name)
	self.show_red_point:SetValue(data.is_show)
	self.show_effect:SetValue(data.is_show_effect)
	self.show_red_bg:SetValue(data.is_show_effect)
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
	self.left_button:SetValue(enable)
end

