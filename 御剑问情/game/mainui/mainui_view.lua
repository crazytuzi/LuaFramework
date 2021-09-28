require("game/famous_general/skill/general_skill_view")
require("game/mainui/mainui_view_player")
require("game/mainui/mainui_view_target")
require("game/mainui/mainui_view_skill")
require("game/mainui/mainui_view_map")
require("game/mainui/mainui_view_task")
require("game/mainui/mainui_view_team")
require("game/mainui/mainui_view_monster")
require("game/mainui/mainui_view_notify")
require("game/mainui/mainui_view_chat")
require("game/mainui/mainui_view_joystick")
require("game/mainui/mainui_view_exp")
require("game/mainui/mainui_view_reminder")
require("game/mainui/mainui_function_trailer")
require("game/mainui/mainui_beatk_icon")
require("game/mainui/mainui_icon_list")
require("game/mainui/mainui_res_icon_list")
require("game/mainui/goddess_skill_tips_view")
require("game/mainui/mainui_activity_preview")
require("game/mainui/mainui_view_hideshow")
require("game/mainui/mainui_view_task_other")
require("game/mainui/mini_map")

local SHOW_REDPOINT_LIMIT_LEVEL = 130
local PRIVATE_MIN_LEVEL = 130
local PRIVATE_MAX_LEVEL = 170
local AUTO_PRIVATE_TIME = 1200
local WEDDING_ACTIVITY_LEVEL = 130 -- 婚宴显示等级

local risingstar_img_path = {
	[0] = "Function_Open_Moqi.png",
	[1] = "Function_Open_Yuyi.png",
	[2] = "Function_Open_Guanghuan.png",
	[3] = "Function_Open_ZhuJueGuanghuan.png",
	[4] = "Icon_Function_Fazhen.png",
	[5] = "Function_Open_Zuoqi.png",
	[6] = "Function_Open_Zuji.png"
}

local degree_rewards_img_path = {
	[2062] = "Function_Open_Zuoqi.png",
	[2065] = "Function_Open_Yuyi.png",
	[2191] = "Function_Open_ZhuJueGuanghuan.png",
	[2192] = "Function_Open_Zuji.png",
	[2193] = "Function_Open_Moqi.png",
	[2194] = "Function_Open_Guanghuan.png",
	[2195] = "Icon_Function_Fazhen.png",
}

--主界面合并的按钮（key值为功能开启的名字, 不包括组名, 0为不显示，1为显示，由功能开启决定）
local GroupBtnList = {
	["xianyu"] = {
		["rune"] = 0,
		["img_fuling"] = 0,
		["hunqi_content"] = 0,
		["appearance"] = 0,
		["yingling"] = 0,
		["shengeview"] = 0,
		["shengxiao_uplevel"] = 0,
		["cardview"] = 0,
		["tiansheng"] = 0,
		["illustrated_handbook"] = 0,
	},
}

local DisPlayPanel = {
	[1] = "button_firstcharge_panel",
	[2] = "button_firstcharge_panel2",
	[3] = "button_firstcharge_panel3",
}

local secondChargeIndex = TabIndex.charge_first_rank
local show_push_index = 1

--忽略活动是否是放入活动卷轴中
local Ignore_Activity = {
	[2188] = true,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE] = true,
}

MainUIView = MainUIView or BaseClass(BaseView)

function MainUIView:__init()
	MainUIView.Instance = self

	self.tmp_button_data = {}
	self.tmp_activity_list = {}
	self.degree_activity_list = {}
	self.view_layer = UiLayer.MainUI
	self.ui_config = {"uis/views/main_prefab", "MainView"}
	self.red_point_list = {}
	self.is_operate_mount = false
	self.is_in = true
	self.active_close = false
	self.is_async_load = true
	self.player_button_ani_state = 0
	self.top_right_button_ani_state = 0
	self.privite_id = 0

	self.icon_list_view = MainuiIconListView.New(ViewName.MainUIIconList)
	self.res_icon_list = MainuiResIconListView.New(ViewName.MainUIResIconList)
	self.act_preview_view = MainUiActivityPreview.New(ViewName.MainUIActivityPreview)
	self.goddess_skill_tips_view = GoddessSkillTipsView.New(ViewName.MainUIGoddessSkillTip)
	self.goddess_skill_tips_view:SetCloseCallBack(BindTool.Bind(self.GoddessSkillTipsClose,self))

	self.role_attr_value_change = BindTool.Bind1(self.OnRoleAttrValueChange, self)
	GlobalTimerQuest:AddDelayTimer(function()
		ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChangeCallBack,self))
		PlayerData.Instance:ListenerAttrChange(self.role_attr_value_change)
	end, 0)

	self.pass_day_handle = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.DayPass, self))
	self.show_switch = true

end

function MainUIView:__delete()
	MainUIView.Instance = nil
	PlayerData.Instance:UnlistenerAttrChange(self.role_attr_value_change)
	GlobalEventSystem:UnBind(self.pass_day_handle)

end

--角色面板
function MainUIView:OnClickPlayer()
	ViewManager.Instance:Open(ViewName.Player, TabIndex.role_intro)
	TitleCtrl.Instance:SendCSGetTitleList()
end

--背包面板
function MainUIView:OnClickPackage()
	ViewManager.Instance:Open(ViewName.Player, TabIndex.role_bag)
	TitleCtrl.Instance:SendCSGetTitleList()
end

--宝具面板
function MainUIView:OnClickOpenMedal()
	ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
end

--锻造面板
function MainUIView:OnClickForge()
	ViewManager.Instance:Open(ViewName.Forge, TabIndex.forge_strengthen)
end

-- 打开跨服六界界面
function MainUIView:OpenKuafuView()
	--判断是否有BOSS，有则打开BOSS面板
	if not KuafuGuildBattleData.Instance:GetOpenState() then
		KuafuGuildBattleData.Instance:SetOpenState(true)
		ViewManager.Instance:Open(ViewName.KuaFuBattle, TabIndex.activity_kuafu_boss)
		self.button_liujieboss.animator:SetBool("Shake", false)
	else
		ViewManager.Instance:Open(ViewName.KuaFuBattle)
	end
end

function MainUIView:OpenKfLiuJiePreView()
	ViewManager.Instance:Open(ViewName.KuaFuLiuJiePre)
end

-- 首冲、再充、三充面板
function MainUIView:OpenRechargeView()
	DailyChargeData.Instance:SetShowPushIndex(2)
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

function MainUIView:OpenThreeRechargeView()
	DailyChargeData.Instance:SetShowPushIndex(3)
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

-- 幻装商城
function MainUIView:OpenHuanZhuangShopView()
	ViewManager.Instance:Open(ViewName.HuanZhuangShopView, 1)
end

-- 单笔返利
function MainUIView:OpenSingleRebateView()
	SingleRebateCtrl.Instance:Open()
end

-- 升星助战
function MainUIView:OpenRisingStarView()
	ViewManager.Instance:Open(ViewName.KiaFuRisingStarView)
	if self.show_risingeffect then
		self.show_risingeffect:SetValue(false)
	end
end

--进阶返利
function MainUIView:OpenDegreeView(activity_type)
	KaiFuDegreeRewardsCtrl.Instance:SetDegreeRewardsActivityType(activity_type)
	ViewManager.Instance:Open(ViewName.KaiFuDegreeRewardsView)
end

function MainUIView:OpenOneYuanSnatch()
	ViewManager.Instance:Open(ViewName.OneYuanSnatchView)

	if self.singlecharges_t and self.singlecharges_t[ACTIVITY_TYPE.KF_ONEYUANSNATCH] then
		self.singlecharges_t[ACTIVITY_TYPE.KF_ONEYUANSNATCH].img.animator:SetBool("Shake", false)
		self.singlecharges_t[ACTIVITY_TYPE.KF_ONEYUANSNATCH].show_eff:SetValue(false)
	end
end

function MainUIView:OpenXianzunka()
	ViewManager.Instance:Open(ViewName.XianzunkaView)
end

function MainUIView:OpenGodTempleView()
	ViewManager.Instance:Open(ViewName.GodTempleView)
end

function MainUIView:OpenFestival()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
	else
		ViewManager.Instance:Open(ViewName.FestivalView)
	end
end


function MainUIView:OpenSecretrShop()
	ViewManager.Instance:Open(ViewName.SecretrShopView)
end

function MainUIView:OpenGuildMoneyTree()
	ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE.GUILD_MONEYTREE)
end

function MainUIView:ShowGuildMoneyTree(state)
	if self.show_guild_moneytree then
		self.show_guild_moneytree:SetValue(state)
	end
end

function MainUIView:ShowGuildMoneyTreeIcon()
	local state = GuildData.Instance:GetMoneyTreeIcon() or 0
	self.show_guild_moneytree:SetValue(state == 1)
end

function MainUIView:ShowGuildMoneyTreeTime()
	local state = GuildData.Instance:GetMoneyTreeState()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local moneytree_info = GuildData.Instance:GetMoneyTreeTimeInfo()
	local next_time = moneytree_info.tianci_tongbi_close_time or 0
	local time = next_time - now_time

	if nil == self.showguild_moneytree_time or self.money_tree_timer then
		return
	end

	if time > 0 then
		self.money_tree_timer = CountDown.Instance:AddCountDown(time, 1, function (elapse_time, total_time)
			local left_time = total_time - elapse_time
			if left_time <= 0 then
				left_time = 0
				if self.money_tree_timer then
	    			CountDown.Instance:RemoveCountDown(self.money_tree_timer)
	    			self.money_tree_timer = nil
	   			end

	   			if self.show_guild_moneytree then
					self.show_guild_moneytree:SetValue(false)
				end

	   			self.showguild_moneytree_time:SetValue("")
	   		else
				local tree_time = TimeUtil.FormatSecond(left_time, 2)
		  		self.showguild_moneytree_time:SetValue(tree_time)
	        end

	    end)
	end
end

-- 形象面板
function MainUIView:OnClickAdvance()
	local default_open = AdvanceData.Instance:GetDefaultOpenView()
	if default_open == "mount_jinjie" then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.mount_jinjie)
	elseif default_open == "wing_jinjie" then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.wing_jinjie)
	elseif default_open == "halo_jinjie" then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.halo_jinjie)
	elseif default_open == "fight_mount" then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fight_mount)
	end
end

--女神面板
function MainUIView:OnClickGoddess()
	ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_info)
end

--公会面板
function MainUIView:OnClickGuild()
	local shake_state = GuildData.Instance:GetGuildChatShakeState()
	if shake_state == true then
		self:ShakeGuildChatBtn(false)
	end
	ViewManager.Instance:Open(ViewName.Guild)
end

--衣橱面板
function MainUIView:OpenClothespress()
	ViewManager.Instance:Open(ViewName.ClothespressView)
end

--福利面板
function MainUIView:OnOpenWelfare()
	ViewManager.Instance:Open(ViewName.Welfare)
end

function MainUIView:OpenJingJi()
	ViewManager.Instance:Open(ViewName.ArenaActivityView, TabIndex.arena_view)
end

--排行榜面板
function MainUIView:OpenRank()
	ViewManager.Instance:Open(ViewName.Ranking)
end

function MainUIView:OpenGuaji()
	ViewManager.Instance:Open(ViewName.YewaiGuajiView)
end

function MainUIView:OpenWorship()
	CityCombatCtrl.Instance:GoWorship() --前往膜拜
	--ViewManager.Instance:Open(ViewName.CityCombatView)
end

function MainUIView:OpenRechargeCapacity()
	ViewManager.Instance:Open(ViewName.RechargeCapacity)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt("activity_hall_day" .. ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY, cur_day)
	end
	if self.singlecharges_t and self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY] then
		self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY].img.animator:SetBool("Shake", false)
		self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY].show_eff:SetValue(false)
	end
end

function MainUIView:OpenSingleCharge2()
	ViewManager.Instance:Open(ViewName.FastCharging)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt("activity_hall_day" .. ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2, cur_day)
	end
	if self.singlecharges_t and self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2] then
		self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2].img.animator:SetBool("Shake", false)
		self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2].show_eff:SetValue(false)
	end
end

function MainUIView:OpenSingleCharge3()
	ViewManager.Instance:Open(ViewName.IncreaseSuperiorView)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt("activity_hall_day" .. ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3, cur_day)
	end
	if self.singlecharges_t and self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3] then
		self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3].img.animator:SetBool("Shake", false)
		self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3].show_eff:SetValue(false)
	end
end

function MainUIView:OpenIncreaseCapability()
	ViewManager.Instance:Open(ViewName.IncreaseCapabilityView)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt("activity_hall_day" .. ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_INCREASE_CAPABILITY, cur_day)
	end
	if self.singlecharges_t and self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_INCREASE_CAPABILITY] then
		self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_INCREASE_CAPABILITY].img.animator:SetBool("Shake", false)
		self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_INCREASE_CAPABILITY].show_eff:SetValue(false)
	end
end

function MainUIView:ClickChargeChange()
	local show_state = self.show_charge_btn_group:GetBoolean()

	--播放动画
	self:PlayChargeChange(not show_state)
end

local charge_sequence = nil
function MainUIView:PlayChargeChange(state)
	if charge_sequence then
		charge_sequence:Kill()
	end
	charge_sequence = DG.Tweening.DOTween.Sequence()

	local tween = nil
	local tween2 = nil
	local tween3 = nil

	self.show_frist_charge:SetValue(true)
	self.show_charge_btn_group:SetValue(true)

	local times = 0.3

	local first_charge_unsee_x = -150
	local first_charge_see_x = 0
	local max_first_charge_move_x = 150

	local charge_button_group_unsee_x = -100
	local charge_button_group_see_x = 10
	local max_charge_button_move_x = 110

	if state then
		tween = self.charge_btn_ani.rect:DORotate(Vector3(0, 0, 90), times)
		tween2 = self.first_charge_ani.rect:DOAnchorPosX(first_charge_unsee_x, times)
		tween3 = self.charge_button_group_ani.rect:DOAnchorPosX(charge_button_group_see_x, times)
	else
		tween = self.charge_btn_ani.rect:DORotate(Vector3(0, 0, 0), times)
		tween2 = self.first_charge_ani.rect:DOAnchorPosX(first_charge_see_x, times)
		tween3 = self.charge_button_group_ani.rect:DOAnchorPosX(charge_button_group_unsee_x, times)
	end

	charge_sequence:Append(tween)
	charge_sequence:Insert(0, tween2)
	charge_sequence:Insert(0, tween3)

	charge_sequence:SetEase(DG.Tweening.Ease.Linear)
	charge_sequence:SetUpdate(true)

	local canvas_group1 = self.first_charge_ani.canvas_group
	local canvas_group2 = self.charge_button_group_ani.canvas_group

	charge_sequence:OnUpdate(function()
		canvas_group1.alpha = math.abs(first_charge_unsee_x - self.first_charge_ani.rect.anchoredPosition.x) / max_first_charge_move_x
		canvas_group2.alpha = math.abs(charge_button_group_unsee_x - self.charge_button_group_ani.rect.anchoredPosition.x) / max_charge_button_move_x
	end)

	charge_sequence:OnComplete(function()
		canvas_group1.alpha = canvas_group1.alpha > 0.5 and 1 or 0
		canvas_group2.alpha = canvas_group2.alpha > 0.5 and 1 or 0
		self.show_frist_charge:SetValue(not state)
		self.show_charge_btn_group:SetValue(state)
	end)
end

--魔龙秘宝面板
function MainUIView:OpenMolongMibao()
	ViewManager.Instance:Open(ViewName.MolongMibaoView)
	if self.show_jixiantiaozhan_effect:GetBoolean() then
		GlobalTimerQuest:AddDelayTimer(function ()
			self.show_jixiantiaozhan_effect:SetValue(true)
		end, 60 * 30)
		self.show_jixiantiaozhan_effect:SetValue(false)
	end
end

-- 打开副本面板
function MainUIView:OpenFuBen()
	ViewManager.Instance:Open(ViewName.FuBen)
end


-- 打开活动卷轴
function MainUIView:OpenActivityHall()
	local data_list = ActivityData.Instance:GetActivityHallDatalistTwo()
	if #data_list == 1 then
		local data = data_list[1]
		if nil ~= data.fun_name then
			ViewManager.Instance:Open(data.open_name)
		elseif not data.is_teshu then
			local act_cfg = ActivityData.Instance:GetActivityConfig(data.type)
			if act_cfg then
				if act_cfg.open_name == ViewName.KaifuActivityView then
					ViewManager.Instance:Open(act_cfg.open_name, act_cfg.act_id + 100000)
				else
					ViewManager.Instance:Open(act_cfg.open_name)
				end
				MainuiActivityHallData.Instance:SetShowOnceEff(data.type, false)
				ActivityData.SCROLL_CLICK_EFF[data.type] = false

				local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
				if cur_day > -1 then
					UnityEngine.PlayerPrefs.SetInt("activity_hall_day" .. data.type, cur_day)
				end
			end
		else
			ViewManager.Instance:Open(data.view_name)
		end
	else
		ViewManager.Instance:Open(ViewName.ActivityHall)
	end
	if self.show_activity_hall_eff then
		self.show_activity_hall_eff:SetValue(false)
	end
end

function MainUIView:CloseTouZiButton()
	if self.chat_view then
		self.chat_view:IsShowTouZiButton()
	end
end

-- 打开社交面板
function MainUIView:OpenScoiety()
	ViewManager.Instance:Open(ViewName.Scoiety)
end

--拍卖行面板
function MainUIView:OnClickMarket()
	ViewManager.Instance:Open(ViewName.Market)
end

--合成面板
function MainUIView:OpenCompose()
	ViewManager.Instance:Open(ViewName.Compose, TabIndex.compose_stone)
end

--活动面板
function MainUIView:OpenActivity()
	ViewManager.Instance:Open(ViewName.Activity, TabIndex.activity_daily)
end

--Boss
function MainUIView:OpenBossView()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.world_boss)
end

--兑换面板
function MainUIView:OnClickExchange()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_mojing)
end

--商城面板
function MainUIView:OnClickShop()
	ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_youhui)
end

--设置面板
function MainUIView:OnClickSetting()
	ViewManager.Instance:Open(ViewName.Setting, TabIndex.setting_xianshi)
end

--寻宝面板
function MainUIView:OnClickTreasure()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
end

--首充
function MainUIView:OpenFirstCharge()
	self.show_charge_effect:SetValue(false)
	DailyChargeData.Instance:SetShowPushIndex(show_push_index)
	ViewManager.Instance:Open(ViewName.SecondChargeView, secondChargeIndex)--TabIndex.charge_first_rank)
end

--每日累充
function MainUIView:OpenLeiJiDaily()
	ViewManager.Instance:Open(ViewName.LeiJiDailyView)
end

--零元礼包
function MainUIView:OpenZeroGift()
	ViewManager.Instance:Open(ViewName.FreeGiftView)
	self.show_zero_gift_eff:SetValue(false)
end

--新手经验瓶
function  MainUIView:OpenExpBottle()
	ViewManager.Instance:Open(ViewName.FriendExpBottleView)
end

--福利boss
function  MainUIView:OpenWelfareBoss()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.world_boss)
end

--娱乐
function  MainUIView:ClickYuLe()
	ViewManager.Instance:Open(ViewName.YuLeView)
end

--累计充值面板
function MainUIView:OpenLeichong()
	ViewManager.Instance:Open(ViewName.LeiJiRechargeView)
end

-- 打开累计充值面板
function MainUIView:OpenLeiJiChargeView()
	-- self.show_recharge_effect:SetValue(false)
	ViewManager.Instance:Open(ViewName.LeiJiRechargeView)
end

function MainUIView:OpenActivityPreview()
	self.act_preview_view:Open()
end

--野外挂机面板
function MainUIView:OnYewaiGuaji()
	ViewManager.Instance:Open(ViewName.YewaiGuajiView)
end

--走棋子
function MainUIView:OpenGoPown()
	ViewManager.Instance:Open(ViewName.GoPawnView)
end

--结婚面板
function MainUIView:OpenMarriage()
	ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_honeymoon)
end

--跨服副本面板
function MainUIView:OpenFuBenMulti()
	ViewManager.Instance:Open(ViewName.KuaFuFuBenView)
end

--精灵面板
function MainUIView:OpenSpirit()
	ViewManager.Instance:Open(ViewName.SpiritView, TabIndex.spirit_spirit)
	SpiritCtrl.Instance:SendGetSpiritWarehouseItemListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
	SpiritCtrl.Instance:SendGetSpiritScore()
end

--打开活动面板
function MainUIView:OpenActivityView(activity_type)
	if activity_type == ACTIVITY_TYPE.GUILD_SHILIAN then
		if ActivityData.Instance:GetActivityIsOpen(activity_type) then
			local yes_func = function ()
				GuildMijingCtrl.SendGuildFbEnterReq()
			end
			TipsCtrl.Instance:ShowCommonAutoView("", str or Language.Guild.GuildActivityTips[activity_type], yes_func)
		else
			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_activity)
		end
	elseif activity_type == ACTIVITY_TYPE.ACTIVITY_TYPE_WEDDING then 							-- 婚宴
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.level >= WEDDING_ACTIVITY_LEVEL then
			ViewManager.Instance:Open(ViewName.WeddingDemandView)
			-- local fb_key = MarriageData.Instance:GetFbKey()
			-- MarriageCtrl.Instance:SendEnterWeeding(fb_key)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.CrossTeam.Levellimit)
		end
	elseif activity_type == ACTIVITY_TYPE.GONGCHENGZHAN then
		local time_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local activity_info = ActivityData.Instance:GetActivityStatuByType(activity_type)

        if HefuActivityData.Instance:IsHeFuFirstCombine() then
            ViewManager.Instance:Open(ViewName.HeFuCombatFirstView)
            ViewManager.Instance:Close(ViewName.CityCombatFirstView)
            ViewManager.Instance:Close(ViewName.CityCombatView)
            return
        end

		if time_day <= 3 and nil ~= activity_info and ACTIVITY_STATUS.STANDY == activity_info.status then
			ViewManager.Instance:Open(ViewName.CityCombatFirstView)
		else
			if ViewManager.Instance:IsOpen(ViewName.CityCombatFirstView) then
				ViewManager.Instance:Close(ViewName.CityCombatFirstView)
			end
			ViewManager.Instance:Open(ViewName.CityCombatView)
		end
		return
	elseif activity_type == ACTIVITY_TYPE.GUILDBATTLE then
		local time_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local activity_info = ActivityData.Instance:GetActivityStatuByType(activity_type)

        if HefuActivityData.Instance:IsHeFuFirstGuildWar() then
            ViewManager.Instance:Open(ViewName.XianMengWarView)
            ViewManager.Instance:Close(ViewName.GuildFirstView)
            ViewManager.Instance:Close(ViewName.Guild)
            return
        end

		if ViewManager.Instance:IsOpen(ViewName.GuildFirstView) then
			ViewManager.Instance:Close(ViewName.GuildFirstView)
		end

		if time_day <= 2 and nil ~= activity_info and ACTIVITY_STATUS.STANDY == activity_info.status then
			ViewManager.Instance:Open(ViewName.GuildFirstView)
			return
		end

		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_war)
		return
	else
		ActivityCtrl.Instance:ShowDetailView(activity_type)
	end
end

function MainUIView:OpenKaifuView(activity_type)
	ViewManager.Instance:Open(ViewName.KaifuActivityView, activity_type + 100000)
	if activity_type == ACTIVITY_TYPE.RAND_SINGLE_CHARGE then
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		if cur_day > -1 then
			UnityEngine.PlayerPrefs.SetInt("activity_hall_day" .. ACTIVITY_TYPE.RAND_SINGLE_CHARGE, cur_day)
		end
		if self.singlecharges_t and self.singlecharges_t[ACTIVITY_TYPE.RAND_SINGLE_CHARGE] then
			self.singlecharges_t[ACTIVITY_TYPE.RAND_SINGLE_CHARGE].img.animator:SetBool("Shake", false)
			self.singlecharges_t[ACTIVITY_TYPE.RAND_SINGLE_CHARGE].show_eff:SetValue(false)
		end
	end
end

function MainUIView:GetShenGeIconData()
	local data = {}

	if OpenFunData.Instance:CheckIsHide("rune") then
		table.insert(data, {
			name = "rune",
			res = "Icon_System_RUNE",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_tower)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Rune)
		})
	end

	if OpenFunData.Instance:CheckIsHide("cardview") then
		table.insert(data, {
			name = "cardview",
			res = "Icon_System_Card",
			callback = function ()
				ViewManager.Instance:Open(ViewName.CardView)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.CardView)
		})
	end

	--图鉴
	if OpenFunData.Instance:CheckIsHide("illustrated_handbook") then
		table.insert(data, {
			name = "handbook",
			res = "Icon_System_handbook",
			callback = function ()
				ViewManager.Instance:Open(ViewName.IllustratedHandbookView)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.IllustratedHandbook)
		})
	end

	-- if OpenFunData.Instance:CheckIsHide("img_fuling") then
	-- 	table.insert(data, {
	-- 		name = "fuling",
	-- 		res = "Icon_System_ImageFuLing",
	-- 		callback = function ()
	-- 			ViewManager.Instance:Open(ViewName.ImageFuLing)
	-- 		end,
	-- 		remind = RemindManager.Instance:GetRemind(RemindName.ImgFuLing)
	-- 	})
	-- end
	if OpenFunData.Instance:CheckIsHide("hunqi_content") then
		table.insert(data, {
			name = "hunqi",
			res = "Icon_System_HunQi",
			callback = function ()
				ViewManager.Instance:Open(ViewName.HunQiView, TabIndex.hunqi_content)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.HunQi)

		})
	end
	if OpenFunData.Instance:CheckIsHide("appearance") then
		table.insert(data, {
			name = "appearance",
			func = "appearance",
			res = "Icon_System_TheAppearance",
			callback = function ()
				ViewManager.Instance:Open(ViewName.AppearanceView)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Appearance)
		})
	end
	if OpenFunData.Instance:CheckIsHide("yingling") then
		table.insert(data, {
			name = "yingling",
			res = "Icon_System_TheShenShou",
			callback = function ()
				ViewManager.Instance:Open(ViewName.ShenShou)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.ShenShouGroup)
		})
	end
	if OpenFunData.Instance:CheckIsHide("shengeview") then
		table.insert(data, {
			name = "shengeview",
			res = "Icon_System_TheShenGe",
			callback = function ()
				ViewManager.Instance:Open(ViewName.ShenGeView, TabIndex.shen_ge_inlay)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.ShenGe)

		})
	end
	if OpenFunData.Instance:CheckIsHide("shengxiao_uplevel") then
		table.insert(data, {
			name = "shenxiao",
			res = "Icon_System_XingZuo",
			callback = function ()
				ViewManager.Instance:Open(ViewName.ShengXiaoView, TabIndex.shengxiao_uplevel)
			end,
			remind = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI) and RemindManager.Instance:GetRemind(RemindName.ShengXiao) + 1 or RemindManager.Instance:GetRemind(RemindName.ShengXiao)
		})
	end
	--神武
	if OpenFunData.Instance:CheckIsHide("shenwu") then
		table.insert(data, {
			name = "shenwu",
			res = "Icon_System_ShenWu",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Shenqi, TabIndex.shenbing)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.ShenQi)
		})
	end
	--名将
	if OpenFunData.Instance:CheckIsHide("tiansheng") then
		table.insert(data, {
			name = "General",
			res = "Icon_System_General",
			callback = function ()
				ViewManager.Instance:Open(ViewName.FamousGeneralView)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.General)
		})
	end
	--无双装备
	if OpenFunData.Instance:CheckIsHide("tianshenhutiview") then
		table.insert(data, {
			name = "Tianshenhuti",
			res = "Icon_System_Tianshenhuti",
			callback = function ()
				ViewManager.Instance:Open(ViewName.TianshenhutiView)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.TianshenhutiGroud)
		})
	end
	return data
end

function MainUIView:GetMarryIconData()
	local data = {}

	if OpenFunData.Instance:CheckIsHide("marriage") then
		table.insert(data, {
			name = "marriage",
			res = "Icon_System_Marrage",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_honeymoon)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Marry)
		})
	end

	if OpenFunData.Instance:CheckIsHide("MarryBaby") then
		table.insert(data, {
			name = "MarryBaby",
			res = "Icon_System_BaoBao",
			callback = function ()
				ViewManager.Instance:Open(ViewName.MarryBaby)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.MarryBaoBao)
		})
	end

	if OpenFunData.Instance:CheckIsHide("littlepet") then
		table.insert(data, {
			name = "littlepet",
			res = "Icon_System_SmallPet",
			callback = function ()
				ViewManager.Instance:Open(ViewName.LittlePetView)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.LittlePet)
		})
	end

	return data
end

function MainUIView:OnClickShenGe()
	local data = self:GetShenGeIconData()
	if #data > 1 then
		self.res_icon_list:SetClickObj(self.button_xianyu, 3)
		self.res_icon_list:SetData(data)
	else
		if data[1] then
			data[1].callback()
		end
	end
end

-- 结婚组
function MainUIView:OnClickMarry()
	local data = self:GetMarryIconData()
	if #data > 1 then
		self.res_icon_list:SetClickObj(self.button_marry, 2)
		self.res_icon_list:SetData(data)
	else
		if data[1] then
			data[1].callback()
		end
	end
end

-- 更新攻击模式
function MainUIView:UpdateAttackMode(mode)
	if self.player_view ~= nil then
		self.player_view:UpdateAttackMode(mode)
	end
end

function MainUIView:GetActiveState()
	return self:GetRootNode().activeSelf
end

-- 任务激活状态改变
function MainUIView:OnTaskRefreshActiveCellViews()

end

-- 挂机模式改变
function MainUIView:OnAutoChanged(on)
	local logic = Scene.Instance:GetSceneLogic()

	-- 不可以取消挂机
	if logic and not logic:CanCancleAutoGuaji() then
		-- GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		GuajiCache.guaji_type = GuajiType.Auto
		-- self.auto_button.toggle.isOn = true
		self.show_guaji:SetValue(false)

		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
		return
	end

	if KuaFuMiningCtrl.Instance:GetMiningState() then
		return
	end

	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	if on and role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		self.auto_button.toggle.isOn = false
		self.show_guaji:SetValue(true)
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CanNotGuajiInJump)
		return
	end
	self.show_guaji:SetValue(true)

	if on then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		self.show_guaji:SetValue(false)
	elseif GuajiCache.guaji_type == GuajiType.Auto then
		GuajiCtrl.Instance:StopGuaji()
		self.show_guaji:SetValue(true)
	elseif GuajiCache.guaji_type == GuajiType.None then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		self.show_guaji:SetValue(false)
	end
	GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
	GlobalEventSystem:Fire(MainUIEventType.CLICK_AUTO_BUTTON)
end

--显示或隐藏挂机按钮
function MainUIView:SetAutoVisible(state)
	if self.auto_button then
		self.auto_button:SetActive(state)
	end
end

function MainUIView:OnGuajiTypeChange(guaji_type)
	if self:IsRendering() then
		-- self.auto_button.toggle.isOn = (guaji_type == GuajiType.Auto)
		local logic = Scene.Instance:GetSceneLogic()

		-- 不可以取消挂机
		if logic and not logic:CanCancleAutoGuaji() then
			GuajiCache.guaji_type = GuajiType.Auto
			-- self.auto_button.toggle.isOn = true
			if self.show_guaji then
				self.show_guaji:SetValue(false)
			end
			self.exp = 0
			self.exp_t = {}
			if self.count_down == nil then
				self.count_down = GlobalTimerQuest:AddRunQuest(function() self:OnGuajiGetEXP() end, 10)
			end
			-- TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
			return
		end

		self.show_guaji:SetValue(true)
		if GuajiType.Auto == guaji_type then
			self.show_guaji:SetValue(false)
		else
			self.show_guaji:SetValue(true)
		end
	end
	if guaji_type == GuajiType.Auto then
		self.exp = 0
		self.exp_t = {}
		if self.count_down == nil then
			self.count_down = GlobalTimerQuest:AddRunQuest(function() self:OnGuajiGetEXP() end, 10)
		end
	else
		GlobalTimerQuest:CancelQuest(self.count_down)
		self.count_down = nil
		self.show_get_exp:SetValue(false)
	end
end

function MainUIView:OnGuajiGetEXP()
	local scene_type = Scene.Instance:GetSceneType()
	if self.exp > 0 and (scene_type == SceneType.Common or scene_type == SceneType.RuneTower or scene_type == SceneType.ExpFb) then
		table.insert(self.exp_t, self.exp)
		if #self.exp_t > 6 then
			table.remove(self.exp_t, 1)
		end
		local total_exp = 0
		for i = 1, 6 do
			total_exp = total_exp + (self.exp_t[i] or self.exp)
		end
		self.show_get_exp:SetValue(true)
		local result,unit = CommonDataManager.ConverNum2(total_exp)
		self.show_exp_number:SetValue(result)
		self.show_exp_unit:SetValue(unit)
		self.exp = 0
	else
		self.show_get_exp:SetValue(false)
	end
end

function MainUIView:OnMainRoleEXPChange(reason, delta)
	if GuajiCache.guaji_type == GuajiType.Auto and reason == 1 then
		if self.exp then
			self.exp = self.exp + delta
		end
	end
end

function MainUIView:OnMainRoleRevive()
	HpBagData.Instance:SetIsShowRepdt(true)
	RemindManager.Instance:Fire(RemindName.HpBag)
end

function MainUIView:RandomInfoChange()
end

--自动私聊
function MainUIView:AutoPrivateChat()
	if self.private_chat_quest then return end
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level >= PRIVATE_MIN_LEVEL and level <= PRIVATE_MAX_LEVEL then
		self.private_chat_quest = GlobalTimerQuest:AddRunQuest(function()
			self.private_chat_timer = self.private_chat_timer + UnityEngine.Time.deltaTime
			if self.private_chat_timer >= AUTO_PRIVATE_TIME then
				self.private_chat_timer = 0
				self.get_is_auto_private = true
				ScoietyCtrl.Instance:RandomRoleListReq()
			end
		end, 0)
	end
end

function MainUIView:CancelAutoPrivateChat()
	if self.private_chat_quest then
		GlobalTimerQuest:CancelQuest(self.private_chat_quest)
		self.private_chat_quest = nil
	end
end

function MainUIView:TeamTabChange(ison)
	if ison and not self.monster_button then
		-- if self.is_team_tab then
		-- 	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
		-- end
	end
	self.is_team_tab = ison
end

function MainUIView:LeftTrackIsVisible()
	if self.team_view then
		self.team_view:ReloadData()
	end
end

function MainUIView:TeamOrMonsterButtonClick()
	if self.monster_button then
		self:MonsterButtonClick()
	else
		self:TeamButtonClick()
	end
end

function MainUIView:TeamButtonClick()
	if self.team_view then
		self.team_view:ReloadData()
	end
end

function MainUIView:MonsterButtonClick()
	if self.monster_view then
		self.monster_view:Flush()
	end
end

function MainUIView:IsShowOrHideMonsterButton(state)
	if state then
		if self.monster_view then
			if state == self.monster_button then
				return
			end
			self.show_monster_button:SetValue(state)
			self.monster_button = state
			self.team_button.toggle.isOn = true
			self.task_button.toggle.isOn = false
			self:TeamOrMonsterButtonClick()
		end
	else
		self.show_monster_button:SetValue(state)
		self.monster_button = state
		self.team_button.toggle.isOn = false
		self.task_button.toggle.isOn = not self.task_other_view:HasOtherPanel()
	end
end

function MainUIView:IsShowMonsterKillTip()
	if self.monster_view then
		self.monster_view:IsShowTip()
	end
end

--充值
function MainUIView:OpenRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--普天同庆
function MainUIView:OpenRestDouble()
	ViewManager.Instance:Open(ViewName.ResetDoubleChongzhiView)
	if self.act_effect_list and self.act_effect_list[ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI] then
		self.act_effect_list[ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI]:SetValue(false)
	end
end

function MainUIView:OpenOnLine()
	ViewManager.Instance:Open(ViewName.OnLineView)
end

--神兽装备收集
function MainUIView:OpenRedEquip()
	ViewManager.Instance:Open(ViewName.RedTaoZhuangView)
end

--战场大厅
function MainUIView:OpenBattleField()
	ViewManager.Instance:Open(ViewName.BattleField)
end

-- 开服活动
function MainUIView:OpenNewServer()
	ViewManager.Instance:Open(ViewName.KaifuActivityView)
	-- local data = {}
	-- if KaifuActivityData.Instance:IsShowKaifuIcon() then
	-- 	table.insert(data, {
	-- 		name = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.OPEN_SERVER) and Language.Mainui.NewServer or Language.Mainui.JingCaiAct,
	-- 		callback = function ()
	-- 			ViewManager.Instance:Open(ViewName.KaifuActivityView)
	-- 		end,
	-- 		remind = KaifuActivityData.Instance:IsShowNewServerRedPoint() and 1 or 0
	-- 	})
	-- end

	-- if KaifuActivityData.Instance:IsShowKaifuIcon() then
	-- 	table.insert(data, {
	-- 		name = Language.Mainui.BossLieShou,
	-- 		callback = function ()
	-- 			ViewManager.Instance:Open(ViewName.KaifuActivityView, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BOSS_LIESHOU + 100000)
	-- 		end,
	-- 		remind = KaifuActivityData.Instance:IsShowBossRedPoint() and 1 or 0
	-- 	})
	-- end
	-- if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA) then
	-- 	table.insert(data, {
	-- 		name = Language.Mainui.GuildBattle,
	-- 		callback = function ()
	-- 			ViewManager.Instance:Open(ViewName.KaifuActivityView, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA + 100000)
	-- 		end,
	-- 		remind = KaifuActivityData.Instance:IsShowZhengbaRedPoint() and 1 or 0
	-- 	})
	-- end
	-- self.icon_list_view:SetClickObj(self.button_kaifuactivityview)
	-- self.icon_list_view:SetData(data)
end

-- 切换信息面板显示
function MainUIView:ClickSwitch()
	if ViewManager.Instance:IsOpen(ViewName.DaFuHao) then
		self:SetViewState(true)
		self.MenuIconToggle.isOn = false
		-- GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, true)
		if self.left_track_animator.isActiveAndEnabled then
			self.left_track_animator:SetBool("fade", false)
			self.task_tab_btn_animator:SetBool("fade", false)
			self.task_shrink_button_animator:SetBool("fade", false)
		end
		ViewManager.Instance:Close(ViewName.DaFuHao)
	else
		self:SetViewState(false)
		ViewManager.Instance:Open(ViewName.DaFuHao)
		if self.MenuIconToggle.isOn then
			self.MenuIconToggle.isOn = false
		end
		GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true)
	end
	DaFuHaoCtrl.Instance.is_hide = true
end

function MainUIView:GetMenuToggleState()
	if self.MenuIconToggle then
		return self.MenuIconToggle.isOn
	end
	return false
end

--首充
function MainUIView:OpenDailyCharge()
	ViewManager.Instance:Open(ViewName.DailyChargeView)
end

--红名面板
function MainUIView:OpenRedName()
	ViewManager.Instance:Open(ViewName.RedNameView)
end

--投资计划
function MainUIView:OpenInvest()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView, 3)
end

--跨服充值榜
function MainUIView:OpenKuaFuChongZhi()
	ViewManager.Instance:Open(ViewName.KuaFuChongZhiRank)
end

--百倍返利
function MainUIView:OpenRebate()
	ViewManager.Instance:Open(ViewName.RebateView)
	RemindManager.Instance:SetRemindToday(RemindName.Rebate)
end

--显示或隐藏私聊提醒
function MainUIView:SetPriviteRemindVisible(value)
	self.show_privite_remind:SetValue(value)
end

--检查是否可以隐藏私聊提醒
function MainUIView:CheckCanHidePriviteRemind()
	if not self.privite_id or not ChatData.Instance:GetPrivateObjByRoleId(self.privite_id) then
		self:SetPriviteRemindVisible(false)
	end
end

function MainUIView:SetPriviteHead(info)
	self.privite_id = info.role_id
	CommonDataManager.SetAvatar(info.role_id, self.privite_raw, self.privite_role, self.default_icon, info.sex, info.prof, false)
end

function MainUIView:ShowPriviteRemind(info)
	self:SetPriviteRemindVisible(true)
	self:SetPriviteHead(info)
end

function MainUIView:OpenPrivite()
	if self.privite_id > 0 then
		--有可能该玩家被封禁了
		if ChatData.Instance:GetPrivateObjByRoleId(self.privite_id) then
			ChatData.Instance:SetCurrentId(self.privite_id)
			ViewManager.Instance:Open(ViewName.ChatGuild)
		end
	end
	self.privite_id = 0
end

--七天登录奖励
function MainUIView:OpenSevenLogin()
	ViewManager.Instance:Open(ViewName.LoginGift7View)
end

--停止右上角收缩按钮动画计时
function MainUIView:StopShrinkButtonAniTimeQuest()
	if self.shrink_button_ani_complete_time_quest then
		GlobalTimerQuest:CancelQuest(self.shrink_button_ani_complete_time_quest)
		self.shrink_button_ani_complete_time_quest = nil
	end
end

function MainUIView:ShrinkButtonToggleChange(is_on)
	self:StopShrinkButtonAniTimeQuest()

	local state = is_on and 1 or 0
	if state == 0 then
		self.top_right_button_ani_state = state
	else
		self.shrink_button_ani_complete_time_quest = GlobalTimerQuest:AddDelayTimer(function ()
			self.top_right_button_ani_state = state
			GlobalEventSystem:Fire(MainUIEventType.TOP_RIGHT_BUTTON_VISIBLE, state)
		end, 0.5)
	end

	--检查右上角收缩动画的红点
	if self.shrink_button_script then
		self.shrink_button_script:CheckRedPoint()
	end
end

function MainUIView:GetTopRightButtonAniState()
	return self.top_right_button_ani_state
end

function MainUIView:OnMenuIconToggleChange(is_on)
	if self.show_charge_panel then
		self.show_charge_panel:SetValue(not is_on)
	end
	if not is_on then
		if self.res_icon_list:IsOpen() then
			self.res_icon_list:Close()
		end
		if self.icon_list_view:IsOpen() then
			self.icon_list_view:Close()
		end
		if self.act_preview_view:IsOpen() then
			self.act_preview_view:Close()
		end
	end
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, not is_on)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, not is_on)
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local enable = false
	local is_show = true
	if ViewManager.Instance:IsOpen(ViewName.FbIconView) then
		self.map_info:SetValue(is_on)
		self.player_view:ShowRightBtns(is_on)
		self.target_view:ChangeToHigh(is_on)

		enable = main_role_lv >= GameEnum.SHRINK_BTN_INTERABLE_LEVEL and is_on or false
		is_show = false or is_on
	else
		enable = main_role_lv >= GameEnum.SHRINK_BTN_INTERABLE_LEVEL and true or false
	end

	self.map_view:ShowShrinkButton(is_show)

	self.show_shrink_btn:SetValue(enable)
	self.shrink_button.toggle.enabled = enable

	self.show_switch_buttons:SetValue(self.show_switch and not is_on)
	if main_role_lv >= GameEnum.SHRINK_BTN_INTERABLE_LEVEL then
		self.shrink_button.toggle.isOn = is_on
	end

	if is_on == false then
		self:CheckRecordGuildShake()
		self:CheckExpBottleShake()
	end

	if ViewManager.Instance:IsOpen(ViewName.Fishing) then
		self.map_info:SetValue(false)
	end
	-- if IS_ON_CROSSSERVER then
	-- 	local scene_type = Scene.Instance:GetSceneType()
	-- 	if scene_type and scene_type ~= SceneType.KfMining then
	-- 		self.map_info:SetValue(false)
	-- 	end
	-- end
end

--如果记录了self.record_guild_shake 为 true 就需要播放颤抖或停止颤抖
function MainUIView:CheckRecordGuildShake()
	if self.record_guild_shake == true then
		if self.guild_chat_count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.guild_chat_count_down)
			self.guild_chat_count_down = nil
		end
		self.guild_chat_count_down = CountDown.Instance:AddCountDown(0.1, 0.1, BindTool.Bind(self.GuildChatCountDown, self))
	end
end


function MainUIView:GuildChatCountDown(elapse_time, total_time)
	if total_time - elapse_time <= 0 then
		self.record_guild_shake = false
		self:ShakeGuildChatBtn(GuildData.Instance:GetGuildChatShakeState())
	end
end

--点击菜单按钮
function MainUIView:OnClickMenu()
	MainUICtrl.Instance:CloseNearPeopleView()
end

-- 转生
function MainUIView:OpenReincarnation()
	ViewManager.Instance:Open(ViewName.Player, TabIndex.role_reincarnation)
end

-- 临时坐骑
function MainUIView:OpenTempMount()
	ViewManager.Instance:Open(ViewName.TempMount)
end

-- 临时羽翼
function MainUIView:OpenTempWing()
	ViewManager.Instance:Open(ViewName.TempWing)
end

-- 进入婚宴
function MainUIView:EnterWedding()
	local fb_key = MarriageData.Instance:GetFbKey()
	MarriageCtrl.Instance:SendEnterWeeding(fb_key)
end

--打开在线奖励
function MainUIView:OpenOnlineRewardView()
	ViewManager.Instance:Open(ViewName.OnLineReward)
end

--打开分线面板
function MainUIView:OpenLineView()
	ViewManager.Instance:Open(ViewName.Map)
end

-- 打开黄金会员
function MainUIView:OpenMemberView()
	ViewManager.Instance:Open(ViewName.GoldMemberView)
	GoldMemberData.Instance:SetIsShowRepdt()
	RemindManager.Instance:Fire(RemindName.GoldMember)
end

-- 经验炼制
function MainUIView:OpenExpRefineView()
	ViewManager.Instance:Open(ViewName.ExpRefine)
end



-- 开服红包
function MainUIView:OpenActiviteHongBa()
	ViewManager.Instance:Open(ViewName.ActiviteHongBao)
end

function MainUIView:OpenBiPin()
	ViewManager.Instance:Open(ViewName.CompetitionActivity)
	RemindManager.Instance:Fire(RemindName.BiPin)
end

function MainUIView:OpenJuBaoPen()
	ViewManager.Instance:Open(ViewName.JuBaoPen)
end

function MainUIView:OpenKaiFuInvest()
	ViewManager.Instance:Open(ViewName.KaiFuInvestView)
end

function MainUIView:OpenRuneView()
	ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_tower)
end

function MainUIView:OpenMiningView()
	local tab_index = TabIndex.mining_mining
	if OpenFunData.Instance:CheckIsHide("mining_challenge") then
		tab_index = TabIndex.mining_challenge
	elseif OpenFunData.Instance:CheckIsHide("mining_mine") then
		tab_index = TabIndex.mining_mining
	elseif OpenFunData.Instance:CheckIsHide("mining_sea") then
		tab_index = TabIndex.mining_sea
	end
	ViewManager.Instance:Open(ViewName.MiningView, tab_index)
end

function MainUIView:OpenMarryMeView()
	ViewManager.Instance:Open(ViewName.MarryMe)
end

function MainUIView:OpenZhuanZhuanLe()
	ViewManager.Instance:Open(ViewName.ZhuangZhuangLe)
	if self.act_effect_list and self.act_effect_list[ACTIVITY_TYPE.RAND_LOTTERY_TREE] then
		self.act_effect_list[ACTIVITY_TYPE.RAND_LOTTERY_TREE]:SetValue(false)
	end
end

function MainUIView:OpenMieshiWar()
	ViewManager.Instance:Open(ViewName.CollectGoals)
end

function MainUIView:OnClickSavePower()
	ViewManager.Instance:Open(ViewName.Unlock)
end

function MainUIView:OpenJinYinTyView()
	ViewManager.Instance:Open(ViewName.JinYinTaView)
	if self.act_effect_list and self.act_effect_list[ACTIVITY_TYPE.RAND_JINYINTA] then
		self.act_effect_list[ACTIVITY_TYPE.RAND_JINYINTA]:SetValue(false)
	end
end

function MainUIView:OpenZhenBaoGeView()
	ViewManager.Instance:Open(ViewName.TreasureLoftView)
	if self.act_effect_list and self.act_effect_list[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT] then
		self.act_effect_list[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT]:SetValue(false)
	end
end

function MainUIView:OpenFuZhu()
	local data = {}

	if OpenFunData.Instance:CheckIsHide("market") then
		table.insert(data, {
			res = "Icon_System_Market",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Market)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Market)

		})
	end
	if OpenFunData.Instance:CheckIsHide("shop") then
		table.insert(data, {
			res = "Icon_System_Shop",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_youhui)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Shop)
		})
	end
	if OpenFunData.Instance:CheckIsHide("compose") then
		table.insert(data, {
			res = "Icon_System_Compose",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Compose, TabIndex.compose_stone)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Compose)
		})
	end

	self.res_icon_list:SetClickObj(self.button_fuzhu, 2)
	self.res_icon_list:SetData(data)
end

function MainUIView:OpenStrength()
	local data = {}
	if FuBenData.Instance:PowerTowerCanChallange() then
		table.insert(data, {
			name = Language.Mainui.Pata,
			callback = function ()
				ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_tower)
			end,
			remind = 0
		})
	end
	if GuaJiTaData.Instance:RuneTowerCanChallange() then
		table.insert(data, {
			name = Language.Mainui.RuneTower,
			callback = function ()
				ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_tower)
			end,
			remind = 0

		})
	end
	if RemindManager.Instance:GetRemind(RemindName.CoolChat) > 0 then
		table.insert(data, {
			name = Language.Mainui.TuHaoJin,
			callback = function ()
				ViewManager.Instance:Open(ViewName.CoolChat)
			end,
			remind = 0

		})
	end
	if RuneData.Instance:GetBagHaveRuneGift() > 0 then
		table.insert(data, {
			name = Language.Mainui.RuneGift,
			callback = function ()
				ViewManager.Instance:Open(ViewName.Player, TabIndex.role_bag)
			end,
			remind = 0

		})
	end

	if PackageData.Instance:CheckBagBatterEquip() ~= 0 then
		table.insert(data, {
			name = Language.Role.TiHuanZhuangBei,
			callback = function ()
				ViewManager.Instance:Open(ViewName.Player, TabIndex.role_bag)
			end,
			remind = 0
		})
	end

	if FuBenData.Instance:GetIsCanPushCommonFb(PUSH_FB_TYPE.PUSH_FB_TYPE_HARD) then
		table.insert(data, {
			name = Language.Mainui.PushSpeFb,
			callback = function ()
				ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_push_special)
			end,
			remind = 0
		})
	end

	if GodTemplePataData.Instance:CanChallange() then
		table.insert(data, {
			name = Language.Mainui.GodTemple,
			callback = function ()
				ViewManager.Instance:Open(ViewName.GodTempleView, TabIndex.godtemple_pata)
			end,
			remind = 0
		})
	end

	self.icon_list_view:SetClickObj(self.button_strength, 2)
	self.icon_list_view:SetData(data)
end

function MainUIView:OpenTargetView()
	ViewManager.Instance:Open(ViewName.PersonalGoals)
end

function MainUIView:PortraitToggleChange(state, from_move, is_guide)
	if FunctionGuide.Instance:GetIsGuide() and not is_guide then
		--引导期间不接收任何处理（除引导外）
		return
	end
	if from_move and self.MenuIconToggle.isOn == state then
		return
	end
	if not self:IsRendering() then
		self.menu_toggle_state = state
		return
	end
	self.MenuIconToggle.isOn = state
	local scene_type = Scene.Instance:GetSceneType()
	if ViewManager.Instance:IsOpen(ViewName.FbIconView) then
		if scene_type == SceneType.Kf_OneVOne then
			self.map_info:SetValue(self.MenuIconToggle.isOn)
			if scene_type == SceneType.Kf_OneVOne then
				self.map_info:SetValue(false)
			end
			self.player_view:ShowRightBtns(self.MenuIconToggle.isOn)
			self.target_view:ChangeToHigh(self.MenuIconToggle.isOn)
		end
	end
	if ViewManager.Instance:IsOpen(ViewName.Fishing) then
		self.map_info:SetValue(false)
	end
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, not self.MenuIconToggle.isOn)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, not self.MenuIconToggle.isOn)
end

function MainUIView:HideMap(state)
	if self.hide_map then
		self.hide_map:SetValue(state)
	end
end

function MainUIView:LoadCallBack()
	self.private_chat_timer = 0
	self.is_team_tab = false
	self.get_is_auto_private = false
	self.record_guild_shake = false
	self.monster_button = false
	--在线奖励
	self.show_online_redpoint = self:FindVariable("ShowOnlineRedPoint")
	self.online_time_text = self:FindVariable("OnlineTimeText")
	self.show_online_btn = self:FindVariable("ShowOnlineBtn")
	self.online_can_reward = self:FindVariable("IsOnlineReward")
	--分线面板
	self.show_line_btn = self:FindVariable("ShowLineBtn")
	self.line_name = self:FindVariable("LineName")
	self.line_name_active = self:FindVariable("LineNameActive")
	self.line_name:SetValue(string.format(Language.Common.Line, 1))

	self.festival_icon = self:FindVariable("FestivalIcon")
	self.festival_text = self:FindVariable("FestivalText")

	local str_type = FestivalActivityData.Instance:GetBgCfg().str_type
	self.festival_icon:SetAsset(ResPath.GetFestivalImageInMain(str_type, "_icon"))
	self.festival_text:SetAsset(ResPath.GetFestivalImageInMain(str_type, "_text"))

	self.group3 = self:FindObj("ButtonGroup3")
	self.group3_name_table = self.group3:GetComponent(typeof(UINameTable))
	self.group3_event_table = self.group3:GetComponent(typeof(UIEventTable))
	self.group3_variable_table = self.group3:GetComponent(typeof(UIVariableTable))

	-- 监听事件
	self:ListenEvent("OpenPlayer", BindTool.Bind(self.OnClickPlayer, self))
	self:ListenEvent("OpenPackage", BindTool.Bind(self.OnClickPackage, self))
	self:ListenEvent("OpenBaoJu", BindTool.Bind(self.OnClickOpenMedal, self))
	self:ListenEvent("OpenForge", BindTool.Bind(self.OnClickForge, self))
	self:ListenEvent("OpenAdvance", BindTool.Bind(self.OnClickAdvance, self))
	self:ListenEvent("OpenGoddess", BindTool.Bind(self.OnClickGoddess, self))
	self:ListenEvent("OpenGuild", BindTool.Bind(self.OnClickGuild, self))
	self:ListenEvent("OpenClothespress", BindTool.Bind(self.OpenClothespress, self))
	self:ListenEvent("OpenMarket", BindTool.Bind(self.OnClickMarket, self))
	self:ListenEvent("AutoChanged", BindTool.Bind(self.OnAutoChanged, self))
	self:ListenEvent("OnYewaiguaji", BindTool.Bind(self.OnYewaiGuaji, self))
	self:ListenEvent("OpenWelfare", BindTool.Bind(self.OnOpenWelfare, self))
	self:ListenEvent("OpenMarriage", BindTool.Bind(self.OpenMarriage, self))
	self:ListenEvent("OpenRank", BindTool.Bind(self.OpenRank, self))
	self:ListenEvent("OpenShenMiShop", BindTool.Bind(self.OpenSecretrShop, self))
	self:ListenEvent("OpenGuildMoneyTree", BindTool.Bind(self.OpenGuildMoneyTree, self))
	self:ListenEvent("OpenMolongMibao", BindTool.Bind(self.OpenMolongMibao, self))
	self:ListenEvent("OpenFuBen", BindTool.Bind(self.OpenFuBen, self))
	self:ListenEvent("OpenFuBenMulti", BindTool.Bind(self.OpenFuBenMulti, self))
	self:ListenEvent("OpenScoiety", BindTool.Bind(self.OpenScoiety, self))
	self:ListenEvent("OpenCompose", BindTool.Bind(self.OpenCompose, self))
	self:ListenEvent("OpenActivity", BindTool.Bind(self.OpenActivity, self))
	self:ListenEvent("OpenBossView", BindTool.Bind(self.OpenBossView, self))
	self:ListenEvent("OpenExchange", BindTool.Bind(self.OnClickExchange, self))
	self:ListenEvent("OpenShop", BindTool.Bind(self.OnClickShop, self))
	self:ListenEvent("OpenSetting", BindTool.Bind(self.OnClickSetting, self))
	self:ListenEvent("OpenTreasure", BindTool.Bind(self.OnClickTreasure, self))
	self:ListenEvent("OpenSpirit", BindTool.Bind(self.OpenSpirit, self))
	self:ListenEvent("OpenRecharge", BindTool.Bind(self.OpenRecharge, self))
	self:ListenEvent("OpenBattleField", BindTool.Bind(self.OpenBattleField, self))
	self:ListenEvent("OpenGoPown", BindTool.Bind(self.OpenGoPown, self))
	self:ListenEvent("ClickTeam", BindTool.Bind(self.TeamOrMonsterButtonClick, self))
	self:ListenEvent("ClickNewServer", BindTool.Bind(self.OpenNewServer, self))
	self:ListenEvent("OpenPrivite", BindTool.Bind(self.OpenPrivite, self))
	self:ListenEvent("ClickSwitch", BindTool.Bind(self.ClickSwitch, self))
	self:ListenEvent("OpenDailyCharge", BindTool.Bind(self.OpenDailyCharge, self))
	self:ListenEvent("OpenRedName", BindTool.Bind(self.OpenRedName, self))
	self:ListenEvent("OpenInvest", BindTool.Bind(self.OpenInvest, self))
	self:ListenEvent("OpenRebate", BindTool.Bind(self.OpenRebate, self))
	self:ListenEvent("OpenFirstCharge", BindTool.Bind(self.OpenFirstCharge, self))
	self:ListenEvent("OpenSevenLogin", BindTool.Bind(self.OpenSevenLogin, self))
	self:ListenEvent("OnClickMenu", BindTool.Bind(self.OnClickMenu, self))
	self:ListenEvent("OpenReincarnation", BindTool.Bind(self.OpenReincarnation, self))
	self:ListenEvent("EnterWedding", BindTool.Bind(self.EnterWedding, self))
	self:ListenEvent("OpenTempMount", BindTool.Bind(self.OpenTempMount, self))
	self:ListenEvent("OpenLeichong", BindTool.Bind(self.OpenLeichong, self))
	self:ListenEvent("OpenTempWing", BindTool.Bind(self.OpenTempWing, self))
	self:ListenEvent("OpenOnlineRewardView", BindTool.Bind(self.OpenOnlineRewardView, self))
	self:ListenEvent("OpenLineView", BindTool.Bind(self.OpenLineView, self))
	self:ListenEvent("OpenMember", BindTool.Bind(self.OpenMemberView, self))
	self:ListenEvent("OpenTarget", BindTool.Bind(self.OpenTargetView, self))
	self:ListenEvent("OpenRune", BindTool.Bind(self.OpenRuneView, self))
	self:ListenEvent("OpenMining", BindTool.Bind(self.OpenMiningView, self))
	self:ListenEvent("OpenWantMarry", BindTool.Bind(self.OpenMarryMeView, self))
	self:ListenEvent("OpenStrength", BindTool.Bind(self.OpenStrength, self))
	self:ListenEvent("OpenMieshiWar", BindTool.Bind(self.OpenMieshiWar, self))
	self:ListenEvent("OnClickSavePower", BindTool.Bind(self.OnClickSavePower, self))
	self:ListenEvent("OnClickShenGe", BindTool.Bind(self.OnClickShenGe, self))
	self:ListenEvent("OnClickMarry", BindTool.Bind(self.OnClickMarry, self))
	self:ListenEvent("OpenLeiJiDaily", BindTool.Bind(self.OpenLeiJiDaily, self))
	self:ListenEvent("OpenZeroGift", BindTool.Bind(self.OpenZeroGift, self))
	self:ListenEvent("FightStateClick", BindTool.Bind(self.FightStateClick, self))
	self:ListenEvent("OpenExpBottle", BindTool.Bind(self.OpenExpBottle, self))
	self:ListenEvent("ClickYuLe", BindTool.Bind(self.ClickYuLe, self))
	self:ListenEvent("ChangeCameraMode", BindTool.Bind(self.OnClickCameraMode, self))
	self:ListenEvent("OpenWelfareBoss", BindTool.Bind(self.OpenWelfareBoss, self))
	self:ListenEvent("OpenJingJi", BindTool.Bind(self.OpenJingJi, self))
	self:ListenEvent("OpenActivityHall", BindTool.Bind(self.OpenActivityHall, self))
	self:ListenEvent("OnClickPhotoShot", BindTool.Bind(self.OnClickPhotoShot, self))
	self:ListenEvent("OpenFuZhu", BindTool.Bind(self.OpenFuZhu, self))
	self:ListenEvent("OpenLoopCharge", BindTool.Bind(self.OpenLoopCharge, self))
	self:ListenEvent("OpenNiChongWoSong", BindTool.Bind(self.OpenNiChongWoSong, self))
	self:ListenEvent("OpenDayTrailer", BindTool.Bind(self.OpenDayTrailer, self))
	self:ListenEvent("OpenLianhun", BindTool.Bind(self.OpenLianhun, self))
	self:ListenEvent("OpenRestDouble", BindTool.Bind(self.OpenRestDouble, self))
	self:ListenEvent("OpenOnLine", BindTool.Bind(self.OpenOnLine, self))
	self:ListenEvent("OpenRedEquip", BindTool.Bind(self.OpenRedEquip, self))

	--活动
	self:ListenEvent("OpenTombExplore", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.TOMB_EXPLORE))
	self:ListenEvent("OpenCityCombat", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GONGCHENGZHAN))
	self:ListenEvent("OpenWeekBoss", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.WEEKBOSS))
	self:ListenEvent("OpenXiuLuoTower", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_XIULUO_TOWER))
	self:ListenEvent("OpenCrossHotSpring", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_HOT_SPRING))
	self:ListenEvent("OpenClashTerritory", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.CLASH_TERRITORY))
	self:ListenEvent("OpenQuestion", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.QUESTION_2))
	self:ListenEvent("OpenBigRich", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.BIG_RICH))
	self:ListenEvent("OpenDoubleEscort", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.HUSONG))
	self:ListenEvent("OpenCrossOneVsOne", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_ONEVONE))
	self:ListenEvent("OpenGuildBattle", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GUILDBATTLE))
	self:ListenEvent("OpenTianJiangCaiBao", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.TIANJIANGCAIBAO))
	self:ListenEvent("OpenElementBattle", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.QUNXIANLUANDOU))
	self:ListenEvent("OpenGuildMijing", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GUILD_SHILIAN))
	self:ListenEvent("OpenGuildBonFire", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GUILD_BONFIRE))
	self:ListenEvent("OpenGuildBoss", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GUILD_BOSS))
	self:ListenEvent("OpenCrossCrystal", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.SHUIJING))
	self:ListenEvent("OpenYiZhanDaoDi", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.CHAOSWAR))
	self:ListenEvent("OpenJingHuaHuSong", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.JINGHUA_HUSONG))
	self:ListenEvent("OpenZhuanZhuanLe", BindTool.Bind(self.OpenZhuanZhuanLe, self,ACTIVITY_TYPE.RAND_LOTTERY_TREE))
	self:ListenEvent("OpenShuShan", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.HUANGCHENGHUIZHAN))
	self:ListenEvent("OpenDailyLove", BindTool.Bind(self.OpenKaifuView, self, ACTIVITY_TYPE.RAND_DAILY_LOVE))
	self:ListenEvent("OpenKuaFuChongZhi", BindTool.Bind(self.OpenKuaFuChongZhi, self,ACTIVITY_TYPE.KF_KUAFUCHONGZHI))
	self:ListenEvent("OpenWedding", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.ACTIVITY_TYPE_WEDDING))
	self:ListenEvent("OpenKuaFuMining", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_MINING))
	self:ListenEvent("OpenMining", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_MINING))
	self:ListenEvent("OpenTeamReq", BindTool.Bind(self.ShowApplyView, self, APPLY_OPEN_TYPE.TEAM))
	self:ListenEvent("OpenFishing", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_FISHING))
	self.group3_event_table:ListenEvent("OpenActivityView", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.CROSS_SHUIJING))

	self:ListenEvent("OpenJinYinTa", BindTool.Bind(self.OpenJinYinTyView, self))
	self:ListenEvent("OpenZhenBaoGe", BindTool.Bind(self.OpenZhenBaoGeView, self))
	self:ListenEvent("OpenActiviteHongBao", BindTool.Bind(self.OpenActiviteHongBa, self))
	self:ListenEvent("OpenExpRefine", BindTool.Bind(self.OpenExpRefineView, self))
	self:ListenEvent("OpenBiPin", BindTool.Bind(self.OpenBiPin, self))
	self:ListenEvent("OpenJuBaoPen", BindTool.Bind(self.OpenJuBaoPen, self))
	self:ListenEvent("OpenKaifuInvest", BindTool.Bind(self.OpenKaiFuInvest, self))
	self:ListenEvent("OpenLeiJiReCharge", BindTool.Bind(self.OpenLeiJiChargeView, self))
	self:ListenEvent("OpenKfLiuJiePreView", BindTool.Bind(self.OpenKfLiuJiePreView, self))
	self:ListenEvent("OpenActivityPreView", BindTool.Bind(self.OpenActivityPreview,self))
	self:ListenEvent("OpenKuafuView", BindTool.Bind(self.OpenKuafuView, self))
	self:ListenEvent("OpenRechargeView", BindTool.Bind(self.OpenRechargeView, self))
	self:ListenEvent("OpenThreeRechargeView", BindTool.Bind(self.OpenThreeRechargeView, self))
	self:ListenEvent("OpenHuanZhuangShopView", BindTool.Bind(self.OpenHuanZhuangShopView, self))
	self:ListenEvent("OpenRisingStarView", BindTool.Bind(self.OpenRisingStarView, self))
	self:ListenEvent("OpenMountDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE))
	self:ListenEvent("OpenWingDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE))
	self:ListenEvent("OpenHaloDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW))
	self:ListenEvent("OpenFootDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW))
	self:ListenEvent("OpenFightMountDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW))
	self:ListenEvent("OpenShenGongDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW))
	self:ListenEvent("OpenShenYiDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW))
	self:ListenEvent("OpenYaoShiDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE))
	self:ListenEvent("OpenTouShiDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE))
	self:ListenEvent("OpenQiLinBiDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE))
	self:ListenEvent("OpenMaskDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE))
	self:ListenEvent("OpenXianBaoDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE))
	self:ListenEvent("OpenLingZhuDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE))
	self:ListenEvent("OpenLingChongDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE))
	self:ListenEvent("OpenLingGongDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE))
	self:ListenEvent("OpenLingQiDegree", BindTool.Bind(self.OpenDegreeView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE))
	self:ListenEvent("OpenGuaji", BindTool.Bind(self.OpenGuaji, self))
	self:ListenEvent("OpenWorship", BindTool.Bind(self.OpenWorship, self))
	self:ListenEvent("OpenSingleRebateView", BindTool.Bind(self.OpenSingleRebateView, self))
	self:ListenEvent("ClickChargeChange", BindTool.Bind(self.ClickChargeChange, self))
	self:ListenEvent("OpenRechargeCapacity", BindTool.Bind(self.OpenRechargeCapacity, self))
	self:ListenEvent("OpenSingleCharge2", BindTool.Bind(self.OpenSingleCharge2, self))
	self:ListenEvent("OpenSingleCharge3", BindTool.Bind(self.OpenSingleCharge3, self))
	self:ListenEvent("OpenIncreaseCapability", BindTool.Bind(self.OpenIncreaseCapability, self))
	self:ListenEvent("OpenDanBiChongZhi", BindTool.Bind(self.OpenKaifuView, self, ACTIVITY_TYPE.RAND_SINGLE_CHARGE))
	self:ListenEvent("OpenOneYuanSnatch", BindTool.Bind(self.OpenOneYuanSnatch, self))
	self:ListenEvent("OpenFestival", BindTool.Bind(self.OpenFestival, self))
	self:ListenEvent("OpenXianzunka", BindTool.Bind(self.OpenXianzunka, self))
	self:ListenEvent("OpenGodTemple", BindTool.Bind(self.OpenGodTempleView, self))

	-- 获取变量
	self.button_preview_img = self:FindVariable("PreviewIcon")
	self.preview_img_text = self:FindVariable("PreviewIconText")
	self.is_in_special_scene = self:FindVariable("IsInSpecialScene")
	self.is_in_special_scene:SetValue(true)
	self.is_show_map_info = self:FindVariable("IsShowMapInfo")
	self.hide_vip = self:FindVariable("HideVip")
	self:GetVariable()
	self:FindHideableButton()
	self:FindActivityBtnTime()
	self.show_privite_remind = self:FindVariable("Show_Privite_Remind")
	self:SetPriviteRemindVisible(false)
	self.show_task = self:FindVariable("ShowTask")
	self.is_in_task_talk = self:FindVariable("IsInTaskTalk")
	self.is_in_task_talk:SetValue(false)
	self.map_info = self:FindVariable("IsShowMap")
	self.map_info:SetValue(true)
	self.show_marry_wedding = self:FindVariable("ShowMarryWedding")
	self.wedding_time = self:FindVariable("WeddingTime")
	self.default_icon = self:FindVariable("DefaultIcon")
	self.show_sysinfo = self:FindVariable("Show_SysInfo")
	self.show_shrink_btn = self:FindVariable("ShowShrinkBtn")
	self.show_charge_effect = self:FindVariable("ShowChargeEffect")
	self.show_guaji = self:FindVariable("ShowGuaji")		-- 挂机文字显示
	self.show_save_power = self:FindVariable("ShowSavePower")
	self.camera_mode = self:FindVariable("CameraMode")
	self.show_exp_bottle_text = self:FindVariable("ShowExpBottleText")
	self.need_friend_num = self:FindVariable("NeedFriendNum")
	self.show_jixiantiaozhan_effect = self:FindVariable("show_jixiantiaozhan_effect")
	self.mlmb_time_txt = self:FindVariable("MlmbTimeTxt")
	self.is_photoshot = self:FindVariable("is_photoshot")
	self.show_recharge_icon = self:FindVariable("Show_Recharge_Icon")
	self.show_three_charge_icon = self:FindVariable("Show_Three_Recharge_Icon")
	self.second_charge = self:FindVariable("Second_Charge")
	self.third_charge = self:FindVariable("Third_Charge")
	self.show_word_image = self:FindVariable("ShowWordImage")
	self.jingua_husong_num = self:FindVariable("JingHuaHuSongNum")
	self.show_single_rebate_icon = self:FindVariable("ShowSingleRebateIcon")
	self.show_team_req = self:FindVariable("ShowTeamReq")
	self.show_guild_moneytree = self:FindVariable("ShowGuildMoneyTree")
	self.showguild_moneytree_time = self:FindVariable("GuildMoneyTreeTime")
	self.show_redtaozhuangview_icon = self:FindVariable("ShowRedEquip")

	-- self:SetMolongMibaoTime()
	self:SetJinyinTaActTime()
	self:SetZhenBaoGeActTime()
	self:SetZhuanZhuanLeActTime()
	self:SetMarryMeActTime()


	-- 主按钮红点
	self.main_menu_redpoint = self:FindVariable("Show_Menu_Redpoint")

	self.panel = self:FindObj("Panel")

	if SafeAreaAdpater then
		if not self.safe_adapter then
			self.safe_adapter = SafeAreaAdpater.Bind(self.panel.gameObject)
		end
	else
		if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
			and UnityEngine.iOS.Device.generation == UnityEngine.iOS.DeviceGeneration.iPhoneX then
			local rect = self.panel.transform:GetComponent(typeof(UnityEngine.RectTransform))
			rect.offsetMin = Vector2(66, 0)
			rect.offsetMax = Vector2(-66, 0)
		end
	end

	-- 获取控件
	self.auto_button = self:FindObj("AutoButton")
	self.team_button = self:FindObj("TeamButton")
	self.task_button = self:FindObj("TaskButton")
	self.privite_remind = self:FindObj("PriviteRemind")
	self.privite_role = self:FindObj("PriviteRole")
	self.privite_raw = self:FindObj("PriviteRaw")
	self.city_combat_buttons = self:FindObj("CityCombatButtons")
	self.city_combat_buttons:SetActive(false)

	self.arrow_image = self:FindObj("ArrowImage")
	self.arrow_image:SetActive(false)

	--获取按钮
	self.button_liujieboss = self:FindObj("ButtonKuaFu")
	self.button_festival = self:FindObj("FetsivalImage")
	self.button_player = self:FindObj("ButtonPlayer")
	self.button_forge = self:FindObj("ButtonForge")
	self.button_advance = self:FindObj("ButtonAdvance")
	self.button_goddess = self:FindObj("ButtonGoddress")
	self.button_baoju = self:FindObj("ButtonBaoju")
	self.button_spiritview = self:FindObj("ButtonSpirit")
	self.button_head = self:FindObj("ButtonHead")
	--self.button_compose = self:FindObj("ButtonCompose")
	self.button_guild = self:FindObj("ButtonGuild")
	self.button_scoiety = self:FindObj("ButtonScoiety")
	self.button_marriage = self:FindObj("ButtonMarriage")
	self.button_ranking = self:FindObj("ButtonRank")
	self.new_rank_btn = self:FindObj("NewRankBtn")						--引导用按钮
	self.button_exchange = self:FindObj("ButtonExhange")
	--self.button_market = self:FindObj("ButtonMarket")
	--self.button_shop = self:FindObj("ButtonShop")
	--self.button_setting = self:FindObj("ButtonSetting")
	self.button_daily_charge = self:FindObj("ButtonDailyCharge")
	self.button_firstchargeview = self:FindObj("ButtonFirstCharge")
	self.button_investview = self:FindObj("ButtonInvest")
	self.button_molongmibaoview = self:FindObj("ButtonMolongMibaoView")
	self.button_rune = self:FindObj("ButtonRune")
	self.button_mining = self:FindObj("ButtonMining")
	self.task_contents = self:FindObj("TaskContents")
	self.task_shrink_button = self:FindObj("TaskShrinkButton")
	self.task_shrink_button_animator = self.task_shrink_button.animator
	self.task_shrink_button.toggle:AddValueChangedListener(BindTool.Bind(self.OnTaskShrinkToggleChange, self))
	self.button_exp_bottle =self:FindObj("ExpBottleButton")
	self.button_exp_bottle_Icon =self:FindObj("ExpBottleButtonIcon")
	self.button_fuzhu =self:FindObj("ButtonFuZhu")
	self.button_activity_hall_icon = self:FindObj("ButtonActivityScroll")

	self.fight_state_button = self:FindObj("FightStateBtn")
	self.fight_state_button.toggle:AddValueChangedListener(BindTool.Bind(self.OnFightStateToggleChange, self))
	self.change_fight_state_toggle = GlobalEventSystem:Bind(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, BindTool.Bind(self.ChangeFightStateToggle, self))

	self.track_info = self:FindObj("TrackInfo")
	self.left_track_animator = self.track_info.animator
	--监听左侧任务列表动画事件
	self.left_track_animator:ListenEvent("IsVisible", BindTool.Bind(self.LeftTrackIsVisible, self))

	self.task_tab_btn = self:FindObj("TabButtons")
	self.task_tab_btn_animator = self.task_tab_btn.animator

	self.online_reward_btn = self:FindObj("OnlineRewardBtn")
	self.online_reward_animator = self.online_reward_btn.animator

	self.act_hongbao_btn = self:FindObj("ActHongBaoBtn")
	self.act_hongbao_ani = self.act_hongbao_btn.animator
	self.act_hongbao_down = self:FindObj("ImageDiamon")
	self.act_hongbao_down_ani = self.act_hongbao_down.animator

	-- 监听系统图标组的动画
	self.player_button_group = self:FindObj("PlayerButtonGroup")
	self.player_button_group.animator:ListenEvent("PlayerBtnVisible", BindTool.Bind(self.PlayerBtnVisible, self))

	--引导用按钮
	self.menu_icon = self:FindObj("MenuIcon")
	self.shrink_button = self:FindObj("ShrinkButton")
	self.shrink_button.toggle.isOn = false
	self.shrink_button.toggle:AddValueChangedListener(BindTool.Bind(self.ShrinkButtonToggleChange,self))
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	self.shrink_button.toggle.enabled = main_role_lv >= GameEnum.SHRINK_BTN_INTERABLE_LEVEL and true or false
	self.boss_icon = self:FindObj("BossIcon")
	self.button_package = self:FindObj("ButtonPackage")
	self.shrink_button_script = self.shrink_button:GetComponent(typeof(ShrinkButton))

	self.show_shrink_btn:SetValue(main_role_lv >= GameEnum.SHRINK_BTN_INTERABLE_LEVEL and true or false)

	self.btn_daily = self:FindObj("ButtonDaily")
	self.button_kaifuactivityview = self:FindObj("ButtonKaifuactivity")
	self.server_active_view = self:FindObj("ButtonKaifuactivity")

	self.MenuIconToggle = self.menu_icon.toggle
	self.MenuIconToggle:AddValueChangedListener(BindTool.Bind(self.OnMenuIconToggleChange,self))
	self.button_logingift7view = self:FindObj("ButtonSevenLogin")
	self.button_member = self:FindObj("ButtonMember")
	self.button_welfare = self:FindObj("ButtonWelfare")
	self.button_gopawnview = self:FindObj("ButtonGoPawn")
	self.button_treasure = self:FindObj("ButtonXunBao")
	self.button_reincarnation = self:FindObj("ButtonZhuanSheng")
	self.button_rebateview = self:FindObj("ButtonRebate")
	self.button_chongzhi = self:FindObj("ButtonChongZhi")
	self.button_jingcaiactivity = self:FindObj("ButtonJingCaiActivity")
	self.button_activity = self:FindObj("ButtonActivityRoom")
	self.button_boss = self:FindObj("ButtonBoss")
	self.button_kuafufubenview = self:FindObj("ButtonDuoRenFuBen")
	self.button_fuben = self:FindObj("ButtonSingleFuBen")
	self.button_vipview = self:FindObj("ButtonVip")
	self.button_helperview = self:FindObj("ButtonHelper")
	self.button_daily = self:FindObj("ButtonEventDayDo")
	self.button_mieshizhizhan = self:FindObj("ButtonTarget")
	self.button_strength = self:FindObj("ButtonStrength")
	self.button_CollectGoals = self:FindObj("ButtonMieshiWar")
	self.button_xianyu = self:FindObj("ButtonShenGeView")
	self.button_marry = self:FindObj("ButtonMarry")
	self.button_zero_gift = self:FindObj("ButtonZeroGift")
	self.button_chat_guild = self:FindObj("ButtonGuildChat")
	self.button_chat_guild_icon = self:FindObj("ButtonGuildChatIcon")
	self.button_shushan = self:FindObj("ButtonShuShan")
	self.button_arenaactivityview = self:FindObj("ButtonJingJi")
	self.button_xianzunkaview = self:FindObj("XianzunkaBtn")
	self.dazhao_effect = self:FindObj("DaZhaoEffect")
	self.button_act_preview = self:FindObj("ButtonActivityPreview")
	self.top_buttons = self:FindObj("TopButtons")
	self.loop_charge_obj = self:FindObj("LoopCharge")
	self.button_triple_exp = self:FindObj("ButtonTripleExp")
	self.button_first_charge2 = self:FindObj("ButtonFirstCharge2")
	self.charge_button_group_ani = self:FindObj("ChargeButtonGroupAni")
	self.first_charge_ani = self:FindObj("FirstChargeAni")
	self.charge_btn_ani = self:FindObj("ChargeBtnAni")
	self.button_lianhunview = self:FindObj("ButtonLianhun")
	self.button_tianshen_grave = self.group3_name_table:Find("ButtonTianShenGrave")
	self.button_godtempleview = self:FindObj("ButtonGodTempleView")

	self.singlecharges_t = {}
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY] = {}
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY].show_eff = self:FindVariable("ShowRechargeCapacityEff")
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY].img = self:FindObj("RechargeCapacityImg")
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2] = {}
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2].show_eff =  self:FindVariable("ShowSingleCharge2Eff")
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2].img = self:FindObj("SingleCharge2Img")
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3] = {}
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3].show_eff = self:FindVariable("ShowSingleCharge3Eff")
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3].img = self:FindObj("SingleCharge3Img")
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_INCREASE_CAPABILITY] = {}
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_INCREASE_CAPABILITY].show_eff = self:FindVariable("ShowIncreaseCapabilityEff")
	self.singlecharges_t[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_INCREASE_CAPABILITY].img = self:FindObj("IncreaseCapabilityImg")
	self.singlecharges_t[ACTIVITY_TYPE.RAND_SINGLE_CHARGE] = {}
	self.singlecharges_t[ACTIVITY_TYPE.RAND_SINGLE_CHARGE].show_eff = self:FindVariable("ShowDanBiChongZhiEff")
	self.singlecharges_t[ACTIVITY_TYPE.RAND_SINGLE_CHARGE].img = self:FindObj("DanBiChongZhiImg")
	self.singlecharges_t[ACTIVITY_TYPE.KF_ONEYUANSNATCH] = {}
	self.singlecharges_t[ACTIVITY_TYPE.KF_ONEYUANSNATCH].show_eff = self:FindVariable("ShowOneYuanEffe")
	self.singlecharges_t[ACTIVITY_TYPE.KF_ONEYUANSNATCH].img = self:FindObj("SingleOneYuanImage")

	self:SetAllSinglechargeEff()

	-- 创建子View
	self.player_info = self:FindObj("PlayerInfo")
	self.player_view = MainUIViewPlayer.New(self:FindObj("PlayerInfo"))
	self.target_view = MainUIViewTarget.New(self:FindObj("TargetInfo"))
	self.skill_view = MainUIViewSkill.New(self:FindObj("SkillControl"), self)
	self.general_skill_view = GeneralSkillView.New(self:FindObj("GeneralSkill"), self)
	self.map_view = MainUIViewMap.New(self:FindObj("MapInfo"))
	self.task_other_view = MainUIViewTaskOther.New(self:FindObj("Task"))
	self.task_view = MainUIViewTask.New(self:FindObj("TaskInfo"))
	self.task_view:SetPackage(self.button_package)
	self.team_view = MainUIViewTeam.New(self:FindObj("TeamInfo"))
	self.monster_view = MainUIViewMonster.New(self:FindObj("MonsterInfo"))
	-- self.notify_view = MainUIViewNotify.New(self:FindObj("NotifyBanner"))
	self.chat_view = MainUIViewChat.New(self:FindObj("ChatWindow"))
	self.joystick_view = MainUIViewJoystick.New(self:FindObj("Joystick"))
	self.exp_view = MainUIViewExp.New(self:FindObj("ExpInfo"))
	self.reminding_view = MainUIViewReminding.New(self:FindObj("Reminding"))
	self.function_trailer = MainUIFunctiontrailer.New(self:FindObj("FunctionTrailer"))
	self.hide_show_view = MainUIViewHideShow.New(self:FindObj("HideShowPanel"))
	self.first_recharge_view = MainUIFirstCharge.New(self:FindObj("ButtonFirstCharge2"))
	self.mini_map = MiniMap.New(self:FindObj("MiniMap"))

	-- 监听值改变
	self.team_button.toggle:AddValueChangedListener(BindTool.Bind(self.TeamTabChange, self))

	self.init_icon_list_event = GlobalEventSystem:Bind(MainUIEventType.INIT_ICON_LIST, BindTool.Bind(self.InitOpenFunctionIcon, self))

	-- 监听系统事件
	self.guaji_change = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE,
		BindTool.Bind(self.OnGuajiTypeChange, self))
	self.red_point_change = GlobalEventSystem:Bind(MainUIEventType.CHANGE_RED_POINT,
		BindTool.Bind(self.ChangeRedPoint, self))
	self.scene_change_event = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT,
		BindTool.Bind(self.OnEnterScene, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
	RemindManager.Instance:Bind(self.remind_change, RemindName.BeStrength)

	self.show_rebate_change = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_REBATE_BUTTON,
		BindTool.Bind(self.ShowRebateButton, self))
	self.change_mainui_button = GlobalEventSystem:Bind(MainUIEventType.CHANGE_MAINUI_BUTTON,
		BindTool.Bind(self.SetButtonVisible, self))

	self.show_switch_button = self:FindVariable("ShowSwitchBtn")
	self.show_switch_buttons = self:FindVariable("ShowSwitchBtns")
	self.Show_Daily_Charge = self:FindVariable("Show_Daily_Charge")
	self.show_kaifuactivityview_btn = self:FindVariable("ShowNewServer")
	self.show_goddess_icon = self:FindVariable("Show_Goddess_Icon")
	self.show_clothespress_icon = self:FindVariable("Show_Clothespress_Icon")
	self.show_exchange_icon = self:FindVariable("Show_Exchange_Icon")
	self.show_setting_icon = self:FindVariable("Show_Setting_Icon")
	self.show_player_icon = self:FindVariable("Show_Player_Icon")
	self.show_forge_icon = self:FindVariable("Show_Forge_Icon")
	self.show_advance_icon = self:FindVariable("Show_Advance_Icon")
	self.show_spiritview_icon = self:FindVariable("Show_Spirit_Icon")
	self.show_guild_icon = self:FindVariable("Show_Guild_Icon")
	self.show_sociality_icon = self:FindVariable("Show_Sociality_Icon")
	self.show_marriage_icon = self:FindVariable("Show_Marry_Icon")
	self.show_ranking_icon = self:FindVariable("Show_Rank_Icon")
	self.show_vipview_icon = self:FindVariable("Show_Vip_Icon")
	self.show_helperview_icon = self:FindVariable("Show_Helper_Icon")
	self.show_welfare_icon = self:FindVariable("Show_Welfare_Icon")
	self.show_jingcaiactivity_icon = self:FindVariable("Show_JingCaiActivity_Icon")
	self.show_treasure_icon = self:FindVariable("Show_XunBao_Icon")
	self.show_investview_icon = self:FindVariable("Show_Invest_Icon")
	self.show_rebateview_icon = self:FindVariable("Show_BaiBei_Icon")
	self.show_xianzunkaview_icon = self:FindVariable("ShowXianzunka")
	self.show_firstchargeview_icon = self:FindVariable("Show_ShouChong_Icon")
	self.show_boss_icon = self:FindVariable("Show_Boss_Icon")
	self.show_activity_icon = self:FindVariable("Show_ActivityRoom_Icon")
	self.show_arenaactivityview_icon = self:FindVariable("Show_JingJi_Icon")
	self.show_chongzhi_icon = self:FindVariable("Show_ChongZhi_Icon")
	self.show_rest_double = self:FindVariable("ShowRestDouble")
	self.show_daily_icon = self:FindVariable("Show_EveryDayDo_Icon")
	self.show_fuben_icon = self:FindVariable("Show_SingleFuBen_Icon")
	self.show_scoiety_icon = self:FindVariable("Show_Scoiety_Icon")
	self.show_first_charge = self:FindVariable("Show_FirstCharge")
	self.show_charge_arrow = self:FindVariable("ShowArrowCharge")
	self.show_logingift7view_icon = self:FindVariable("Show_SevenLogin_Icon")
	self.show_molongmibaoview_icon = self:FindVariable("Show_MolongMibao")
	self.show_mining_icon = self:FindVariable("ShowMining")
	self.show_CollectGoals_icon = self:FindVariable("ShowMieshiWar")
	self.show_yewaiguaji_icon = self:FindVariable("ShowYewaiGuaji")
	self.show_CollectGoals_image = self:FindVariable("ShowMieshiImage")
	self.show_daily_leiji = self:FindVariable("ShowDailyLeiJi")
	self.show_zero_gift_icon = self:FindVariable("ShowZeroGiftIcon")
	self.show_zero_gift_eff = self:FindVariable("ShowZeroGiftEff")
	self.show_exp_bottle_icon = self:FindVariable("ShowExpBottleIcon")
	self.show_chatguild_icon = self:FindVariable("ShowGuildChatBtn")
	self.show_yule_icon = self:FindVariable("ShowYuLeIcon")
	self.show_yule_icon_in_special = self:FindVariable("ShowYuLeIconInSpecial")
	self.show_activity_hall_eff = self:FindVariable("ShowActivityHallEff")
	self.show_activity_hall_icon = self:FindVariable("ShowActivityHall")
	self.show_kf_battle_icon = self:FindVariable("Show_KFBattle_Icon")
	self.show_kf_battle_pre_icon = self:FindVariable("Show_KFBattlePre_Icon")
	self.activity_hall_img = self:FindVariable("ActivityHallImg")
	self.activity_hall_imgtwo = self:FindVariable("ActivityHallImgTwo")
	self.show_lianhunview_icon = self:FindVariable("ShowLianhunBtn")
	-- self.show_LoopCharge_icon = self:FindVariable("show_LoopCharge_icon")
	self.show_nichongwosong = self:FindVariable("ShowNiChongWoSong")
	self.show_godtempleview_icon = self:FindVariable("Show_GodTempleView_Icon")
	self.show_godtempleview_icon:SetValue(false)
	self.show_activity_hall_icon:SetValue(#ActivityData.Instance:GetActivityHallDatalist() > 0 and main_role_lv >= GameEnum.ACT_HALL_ICON_LEVEL)
	self.show_activity_hall_eff:SetValue(true)

	--版本活动图标
	self.show_festival_icon = self:FindVariable("ShowFestival")
	if OpenFunData.Instance:CheckIsHide("festivalview") then
		self.show_festival_icon:SetValue(FestivalActivityData.Instance:GetActivityOpenNum() > 0)
	end

	self.show_online_icon = self:FindVariable("ShowOnLine")
	self.show_online_icon:SetValue(ActivityOnLineData.Instance:GetActivityOpenNum() > 0)

	self.show_hefuactivityview_btn = self:FindVariable("ShowServerActiveIcon")
	self.shenyu_img = self:FindVariable("ShenYuImg")
	self.shenyu_text = self:FindVariable("shenyuText")

	self.show_charge_change_btn = self:FindVariable("ShowChargeChangeBtn")
	self.show_charge_btn_group = self:FindVariable("ShowChargeBtnGroup")
	self.show_frist_charge = self:FindVariable("ShowFristCharge")

	--仙域组图标
	self.show_xianyu_icon = self:FindVariable("Show_XianYu_Icon")

	--辅助组图标
	-- self.show_fuzhu_icon = self:FindVariable("Show_FuZhu_Icon")
	self.show_shop_icon = self:FindVariable("Show_Shop_Icon")
	self.show_market_icon = self:FindVariable("Show_Market_Icon")
	self.show_compose_icon = self:FindVariable("Show_Compose_Icon")

	--天数功能预告相关
	self.show_day_open_trailer = self:FindVariable("ShowDayOpenTrailer")
	self.day_open_trailer_text = self:FindVariable("DayOpenTrailerText")
	self.day_open_trailer_icon = self:FindVariable("DayOpenTrailerIcon")
	self.show_day_open_trailer_effect = self:FindVariable("ShowDayOpenTrailerEffect")

	self.is_show_player_info = self:FindVariable("IsShowPlayerInfo")
	self.is_show_temp_mount = self:FindVariable("ShowTempMount")
	self.is_show_temp_wing = self:FindVariable("ShowTempWing")
	self.hide_map = self:FindVariable("HideMap")
	self.activity_icon_num = self:FindVariable("ActivityIconNum")
	self.show_charge_panel = self:FindVariable("Show_Charge_panel")
	self.has_first_recharge = self:FindVariable("HasFirstRecharge")
	self.show_gold_member_icon = self:FindVariable("ShowMemberBtn")
	self.show_bipin = self:FindVariable("ShowBiPin")
	self.show_ZhuLi = self:FindVariable("ShowZhuLi")
	self.show_leichong_icon = self:FindVariable("ShowLeiChongIcon")
	self.show_mieshizhizhan_icon = self:FindVariable("ShowTarget")
	self.show_person_target = self:FindVariable("ShowPersonTarget")
	self.bipin_src = self:FindVariable("BiPinSrc")
	self.ZhuLi_src = self:FindVariable("ZhuLiSrc")
	self.bipin_text = self:FindVariable("BiPin_Text")
	self.show_get_exp = self:FindVariable("ShowGetEXP")
	self.show_exp_number = self:FindVariable("ShowEXPNumber")
	self.show_exp_unit = self:FindVariable("ShowExpUnit")
	self.member_repdt = self:FindVariable("MemberRepdt")
	self.bipin_time = self:FindVariable("BiPinTime")
	self.ZhuLi_time = self:FindVariable("ZhuLiTime")
	self.rune_tower_time = self:FindVariable("RuneTowerTime")
	self.show_guild_bubble = self:FindVariable("ShowGuildBubble")
	self.show_welfare_boss = self:FindVariable("ShowWelfareBoss")
	self.show_recharge_icon_1 = self:FindVariable("ShowRechargeIcon")
	self.act_preview_time = self:FindVariable("ActivePreviewTime")
	self.show_monster_button = self:FindVariable("ShowMonsterButton")
	self.is_general = self:FindVariable("IsGeneral")
	self.show_recharge_icon_1:SetValue(ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE) and KaifuActivityData.Instance:IsShowLeiJiRechargeIcon())

	self.is_open_kaifuact = self:FindVariable("IsOpenKaifuAct")
	self.is_open_kaifuact:SetValue(ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.OPEN_SERVER))
	self.show_jubaopen_icon = self:FindVariable("ShowJuBaoPen")
	self:CheckJuBaoPenIcon()
	self:SetJingcaiActImg()
	self:ChangeRisingStarTime()
	self:SetBiPinImg()

	self.is_open_yewaiguaji_icon = false
	if self.hide_player_info then
		self.is_show_player_info:SetValue(true)
		self.hide_player_info = false
	end

	-- 自动挂机按钮特效
	self.show_auto_effect = self:FindVariable("ShowAutoEffect")
	-- 双倍充值标签
	self.show_double_chong_zhi = self:FindVariable("ShowDoubleChongZhi")
	self.is_double_recarge_shake = self:FindVariable("IsDoubleRechargeShake")


	self.hide_map:SetValue(false)

	self:SetAllRedPoint()

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Main, BindTool.Bind(self.GetUiCallBack, self))

	self:SetViewState(self.is_in)

	self:ShowRebateButton()
	self:MainRoleLevelChange()
	self:ChangeGeneralState()

	self:SetSecretrShopTime()
	self:DayPass()

	self:OnGuajiTypeChange(GuajiCache.event_guaji_type)

	self.button_strength:SetActive(RemindManager.Instance:GetRemind(RemindName.BeStrength) > 0)
	self:ChangeCollectiveGoalsImage()
	self:CameraModeChange()
	self.view_open_event = GlobalEventSystem:Bind(OtherEventType.VIEW_OPEN,
		BindTool.Bind(self.HasViewOpen, self))
	self.view_close_event = GlobalEventSystem:Bind(OtherEventType.VIEW_CLOSE,
		BindTool.Bind(self.HasViewClose, self))


	self.task_change_handle = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE,BindTool.Bind(self.OnTaskChange, self))
	self.person_glal_change_handle = GlobalEventSystem:Bind(OtherEventType.VIRTUAL_TASK_CHANGE,BindTool.Bind(self.OnPersonGoalChange, self))
	self.shrink_btn = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON,BindTool.Bind(self.OnShowOrHideShrinkBtn, self))
	self.menu_toggle_change = GlobalEventSystem:Bind(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, BindTool.Bind(self.PortraitToggleChange, self))
	self.scene_load_complete = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.SceneLoadComplete, self))
	self.right_up_button_show = GlobalEventSystem:Bind(SceneEventType.SHOW_MAINUI_RIGHT_UP_VIEW, BindTool.Bind(self.ChangeMenuState, self))
	self.shrink_dafuhao_info = GlobalEventSystem:Bind(MainUIEventType.SHRINK_DAFUHAO_INFO, BindTool.Bind(self.OnTaskShrinkToggleChange, self))
	self.main_role_level_change = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.MainRoleLevelChange, self))
	self.main_role_exp_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_EXP_CHANGE, BindTool.Bind(self.OnMainRoleEXPChange, self))
	self.main_role_realive = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind1(self.OnMainRoleRevive, self))
	-- self.random_info_change = GlobalEventSystem:Bind(OtherEventType.RANDOM_INFO_CHANGE, BindTool.Bind(self.RandomInfoChange, self))
	self.camera_mode_change = GlobalEventSystem:Bind(SettingEventType.MAIN_CAMERA_MODE_CHANGE, BindTool.Bind(self.CameraModeChange, self))
	self.data_listen = BindTool.Bind(self.ClashTerritoryDataChangeCallback, self)
	ClashTerritoryData.Instance:AddListener(ClashTerritoryData.INFO_CHANGE, self.data_listen)

	if nil ~= FontTextureReBuild then
		FontTextureReBuild.Instance:SetIsOpen(true)
		FontTextureReBuild.Instance:SetCanRefresh(true)
	end
end

function MainUIView:CheckRunetowerCountDown()
	if nil == self.rune_tower_time then return end
	local rune_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	if rune_info.offline_time then
		local left_hour = math.floor(rune_info.offline_time / 3600)
		local left_min = math.floor((rune_info.offline_time - left_hour * 3600) / 60)
		local temp_str = string.format(Language.Common.TimeStr2, left_hour, left_min)
		if rune_info.offline_time < 3600 then
			temp_str = string.format(Language.Mount.ShowRedStr, temp_str)
		else
			temp_str = string.format(Language.Mount.ShowGreenStr, temp_str)
		end
		self.rune_tower_time:SetValue(temp_str)
	end
end

function MainUIView:IsShowDoubleChongZhi()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if self.show_double_chong_zhi then
		local rest_double_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
		local rest_double_isAll = ResetDoubleChongzhiData.Instance:IsAllRecharge()
		self.show_double_chong_zhi:SetValue((cur_day <= 7 and not DailyChargeData.Instance:AllOptionRecharge()) or (rest_double_open and not rest_double_isAll))
		self:IsDoubleRechargeShake()
	end
end

function MainUIView:IsDoubleRechargeShake()
	if self.show_double_chong_zhi then
		if self.double_shake_next_timer == nil then
			self:DoubleRechargeShake(5)
			self.double_shake_next_timer = GlobalTimerQuest:AddRunQuest(function()			--每隔10分钟抖动
				self:DoubleRechargeShake(10)
			end, 600)
		end
	end
end

function MainUIView:DoubleRechargeShake(time)
	self.is_double_recarge_shake:SetValue(true)
	GlobalTimerQuest:AddDelayTimer(function()
		self.is_double_recarge_shake:SetValue(false)
	end, time)
end

function MainUIView:DoubleRechargeAlwaysShake(is_shake)
	GuildData.Instance:SetGuildChatShakeState(is_shake)
	self.is_double_recarge_shake:SetValue(is_shake)
end

function MainUIView:GetCityCombatButtons()
	return self.city_combat_buttons
end

function MainUIView:FlushGoalsIcon()
	self.player_view:FlushGoalsIcon()
end

function MainUIView:ShowGuildChatIcon(is_show)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.show_chatguild_icon:SetValue((is_show or true) and OpenFunData.Instance:CheckIsHide("chatguild"))
end

function MainUIView:CheckLeiJiRechargeIcon()
	if not self.show_recharge_icon_1 then return end
	self.show_recharge_icon_1:SetValue(ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE) and KaifuActivityData.Instance:ShowMainLeiJiRechargeIcon())
end

function MainUIView:ShowWelfareBossIcon(is_show)
	self.show_welfare_boss:SetValue(is_show)
end

function MainUIView:MainRoleLevelChange()
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level

	local enable = main_role_lv >= GameEnum.SHRINK_BTN_INTERABLE_LEVEL and true or false
	local bool = self.show_shrink_btn:GetBoolean()
	if not bool and enable then
		--表示刚激活该状态
		self.shrink_button.toggle.isOn = true
	elseif not enable then
		self.shrink_button.toggle.isOn = false
	end
	self.show_shrink_btn:SetValue(enable)
	self.shrink_button.toggle.enabled = enable
	self.show_charge_effect:SetValue(enable)
	self.show_save_power:SetValue(main_role_lv >= GameEnum.NOVICE_LEVEL)
end

function MainUIView:ReleaseCallBack()
	if self.player_view ~= nil then
		self.player_view:DeleteMe()
		self.player_view = nil
	end

	if self.target_view ~= nil then
		self.target_view:DeleteMe()
		self.target_view = nil
	end

	if self.skill_view ~= nil then
		self.skill_view:DeleteMe()
		self.skill_view = nil
	end

	if self.map_view ~= nil then
		self.map_view:DeleteMe()
		self.map_view = nil
	end

	if self.task_view ~= nil then
		self.task_view:DeleteMe()
		self.task_view = nil
	end

	if self.task_other_view ~= nil then
		self.task_other_view:DeleteMe()
		self.task_other_view = nil
	end

	if self.team_view ~= nil then
		self.team_view:DeleteMe()
		self.team_view = nil
	end

	if self.monster_view ~= nil then
		self.monster_view:DeleteMe()
		self.monster_view = nil
	end

	if self.notify_view ~= nil then
		self.notify_view:DeleteMe()
		self.notify_view = nil
	end

	if self.chat_view ~= nil then
		self.chat_view:DeleteMe()
		self.chat_view = nil
	end

	if self.joystick_view ~= nil then
		self.joystick_view:DeleteMe()
		self.joystick_view = nil
	end

	if self.exp_view ~= nil then
		self.exp_view:DeleteMe()
		self.exp_view = nil
	end

	if self.reminding_view ~= nil then
		self.reminding_view:DeleteMe()
		self.reminding_view = nil
	end

	if self.function_trailer ~= nil then
		self.function_trailer:DeleteMe()
		self.function_trailer = nil
	end

	if self.hide_show_view ~= nil then
		self.hide_show_view:DeleteMe()
		self.hide_show_view = nil
	end

	if self.first_recharge_view ~= nil then
		self.first_recharge_view:DeleteMe()
		self.first_recharge_view = nil
	end

	if self.icon_list_view ~= nil then
		self.icon_list_view:DeleteMe()
		self.icon_list_view = nil
	end

	if self.res_icon_list ~= nil then
		self.res_icon_list:DeleteMe()
		self.res_icon_list = nil
	end

	if self.goddess_skill_tips_view ~= nil then
		self.goddess_skill_tips_view:DeleteMe()
		self.goddess_skill_tips_view = nil
	end

	if self.general_skill_view then
		self.general_skill_view:DeleteMe()
		self.general_skill_view = nil
	end

	if self.change_fight_state_toggle then
		GlobalEventSystem:UnBind(self.change_fight_state_toggle)
		self.change_fight_state_toggle = nil
	end

	if self.view_open_event then
		GlobalEventSystem:UnBind(self.view_open_event)
		self.view_open_event = nil
	end

	if self.view_close_event then
		GlobalEventSystem:UnBind(self.view_close_event)
		self.view_close_event = nil
	end

	if self.act_preview_view then
		self.act_preview_view:DeleteMe()
		self.act_preview_view = nil
	end

	if nil ~= self.guaji_change then
		GlobalEventSystem:UnBind(self.guaji_change)
		self.guaji_change = nil
	end

	if nil ~= self.red_point_change then
		GlobalEventSystem:UnBind(self.red_point_change)
		self.red_point_change = nil
	end
	if nil ~= self.scene_change_event then
		GlobalEventSystem:UnBind(self.scene_change_event)
		self.scene_change_event = nil
	end

	if nil ~= self.show_rebate_change then
		GlobalEventSystem:UnBind(self.show_rebate_change)
		self.show_rebate_change = nil
	end
	if nil ~= self.change_mainui_button then
		GlobalEventSystem:UnBind(self.change_mainui_button)
		self.change_mainui_button = nil
	end

	if self.menu_toggle_change ~= nil then
		GlobalEventSystem:UnBind(self.menu_toggle_change)
		self.menu_toggle_change = nil
	end

	if self.scene_load_complete ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_complete)
		self.scene_load_complete = nil
	end

	if self.right_up_button_show ~= nil then
		GlobalEventSystem:UnBind(self.right_up_button_show)
		self.right_up_button_show = nil
	end


	if self.shrink_dafuhao_info ~= nil then
		GlobalEventSystem:UnBind(self.shrink_dafuhao_info)
		self.shrink_dafuhao_info = nil
	end

	if self.main_role_exp_change ~= nil then
		GlobalEventSystem:UnBind(self.main_role_exp_change)
		self.main_role_exp_change = nil
	end

	if self.main_role_realive ~= nil then
		GlobalEventSystem:UnBind(self.main_role_realive)
		self.main_role_realive = nil
	end

	if self.shrink_btn ~= nil then
		GlobalEventSystem:UnBind(self.shrink_btn)
		self.shrink_btn = nil
	end

	if nil ~= self.task_change_handle then
		GlobalEventSystem:UnBind(self.task_change_handle)
		self.task_change_handle = nil
	end

	if self.data_listen and ClashTerritoryData.Instance then
		ClashTerritoryData.Instance:RemoveListener(ClashTerritoryData.INFO_CHANGE, self.data_listen)
		self.data_listen = nil
	end

	if self.person_glal_change_handle and ClashTerritoryData.Instance then
		ClashTerritoryData.Instance:RemoveListener(ClashTerritoryData.INFO_CHANGE, self.person_glal_change_handle)
		self.person_glal_change_handle = nil
	end

	if self.main_role_level_change then
		GlobalEventSystem:UnBind(self.main_role_level_change)
		self.main_role_level_change = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.private_chat_quest then
		GlobalTimerQuest:CancelQuest(self.private_chat_quest)
		self.private_chat_quest = nil
	end

	if self.liujieboss_ani_quest then
		GlobalTimerQuest:CancelQuest(self.liujieboss_ani_quest)
		self.liujieboss_ani_quest = nil
	end

	-- if self.random_info_change then
	-- 	GlobalEventSystem:UnBind(self.random_info_change)
	-- 	self.random_info_change = nil
	-- end

	if self.camera_mode_change then
		GlobalEventSystem:UnBind(self.camera_mode_change)
		self.camera_mode_change = nil
	end

	self:StopOnlineCountDown()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Main)
	end

	if self.delay_text_timer then
		GlobalTimerQuest:CancelQuest(self.delay_text_timer)
		self.delay_text_timer = nil
	end

	if self.mlmb_timer then
		GlobalTimerQuest:CancelQuest(self.mlmb_timer)
		self.mlmb_timer = nil
	end

	if self.zhuanzhuanle_next_timer then
       GlobalTimerQuest:CancelQuest(self.zhuanzhuanle_next_timer)
	   self.zhuanzhuanle_next_timer = nil
	end

	if self.jinyinta_next_timer then
		GlobalTimerQuest:CancelQuest(self.jinyinta_next_timer)
		self.jinyinta_next_timer = nil
	end

	if self.zhenbaoge_next_timer then
		GlobalTimerQuest:CancelQuest(self.zhenbaoge_next_timer)
		self.zhenbaoge_next_timer = nil
	end

	if self.marry_me_count_down then
		CountDown.Instance:RemoveCountDown(self.marry_me_count_down)
		self.marry_me_count_down = nil
	end

	if self.guild_chat_count_down then
		CountDown.Instance:RemoveCountDown(self.guild_chat_count_down)
		self.guild_chat_count_down = nil
	end

	if self.wedding_count_down then
		CountDown.Instance:RemoveCountDown(self.wedding_count_down)
		self.wedding_count_down = nil
	end

	if self.rising_star_countdown then
		CountDown.Instance:RemoveCountDown(self.rising_star_countdown)
		self.rising_star_countdown = nil
	end

	if self.mini_map then
		self.mini_map:DeleteMe()
		self.mini_map = nil
	end

	if nil ~= self.count_down then
		GlobalTimerQuest:CancelQuest(self.count_down)
		self.count_down = nil
	end

	if self.double_shake_next_timer then
		GlobalTimerQuest:CancelQuest(self.double_shake_next_timer)
		self.double_shake_next_timer = nil
	end

	if self.init_icon_list_event then
		GlobalEventSystem:UnBind(self.init_icon_list_event)
		self.init_icon_list_event = nil
	end

	if self.secretr_shop_down then
		CountDown.Instance:RemoveCountDown(self.secretr_shop_down)
		self.secretr_shop_down = nil
	end

	if self.money_tree_timer then
	    CountDown.Instance:RemoveCountDown(self.money_tree_timer)
	   	self.money_tree_timer = nil
	end

	self:StopShrinkButtonAniTimeQuest()
	self:RemoveActTimeCountDown()

	-- 清理变量和对象
	self.safe_adapter = nil
	self.button_preview_img = nil
	self.preview_img_text = nil
	self.is_in_special_scene = nil
	self.is_show_map_info = nil
	self.hide_vip = nil
	self.show_privite_remind = nil
	self.show_task = nil
	self.is_in_task_talk = nil
	self.map_info = nil
	self.show_marry_wedding = nil
	self.wedding_time = nil
	self.default_icon = nil
	self.show_sysinfo = nil
	self.show_shrink_btn = nil
	self.show_charge_effect = nil
	self.show_guaji = nil
	self.show_save_power = nil
	self.main_menu_redpoint = nil
	self.auto_button = nil
	self.team_button = nil
	self.task_button = nil
	self.privite_remind = nil
	self.privite_role = nil
	self.privite_raw = nil
	self.city_combat_buttons = nil
	self.arrow_image = nil
	self.button_player = nil
	self.button_forge = nil
	self.button_advance = nil
	self.button_liujieboss = nil
	self.button_festival = nil
	self.button_goddess = nil
	self.button_baoju = nil
	self.button_spiritview = nil
	self.button_head = nil
	self.button_compose = nil
	self.button_guild = nil
	self.button_scoiety = nil
	self.button_marriage = nil
	self.button_ranking = nil
	self.button_act_preview = nil
	self.button_exchange = nil
	self.button_market = nil
	self.button_shop = nil
	self.button_setting = nil
	self.button_daily_charge = nil
	self.button_firstchargeview = nil
	self.button_investview = nil
	self.button_molongmibaoview = nil
	self.button_rune = nil
	self.button_mining = nil
	self.button_lianhunview = nil
	self.task_contents = nil
	self.task_shrink_button = nil
	self.task_shrink_button_animator = nil
	self.fight_state_button = nil
	self.track_info = nil
	self.left_track_animator = nil
	self.task_tab_btn = nil
	self.task_tab_btn_animator = nil
	self.online_reward_btn = nil
	self.online_reward_animator = nil
	self.act_hongbao_btn = nil
	self.act_hongbao_ani = nil
	self.act_hongbao_down = nil
	self.act_hongbao_down_ani = nil
	self.menu_icon = nil
	self.shrink_button = nil
	self.boss_icon = nil
	self.btn_daily = nil
	self.button_kaifuactivityview = nil
	self.MenuIconToggle = nil
	self.button_logingift7view = nil
	self.button_member = nil
	self.button_welfare = nil
	self.button_gopawnview = nil
	self.button_treasure = nil
	self.button_reincarnation = nil
	self.button_rebateview = nil
	self.button_chongzhi = nil
	self.button_jingcaiactivity = nil
	self.button_activity = nil
	self.button_arenaactivityview = nil
	self.button_xianzunkaview = nil
	self.button_boss = nil
	self.button_kuafufubenview = nil
	self.button_fuben = nil
	self.button_vipview = nil
	self.button_helperview = nil
	self.button_daily = nil
	self.button_mieshizhizhan = nil
	self.button_strength = nil
	self.button_CollectGoals = nil
	self.button_xianyu = nil
	self.button_marry = nil
	self.button_zero_gift = nil
	self.button_exp_bottle =nil
	self.button_exp_bottle_Icon = nil
	self.show_exp_bottle_icon =nil
	self.top_buttons = nil
	self.player_info = nil
	self.show_switch_button = nil
	self.show_switch_buttons = nil
	self.Show_Daily_Charge = nil
	self.show_kaifuactivityview_btn = nil
	self.show_goddess_icon = nil
	self.show_clothespress_icon = nil
	self.show_exchange_icon = nil
	self.show_setting_icon = nil
	self.show_player_icon = nil
	self.show_forge_icon = nil
	self.show_advance_icon = nil
	self.show_spiritview_icon = nil
	self.show_guild_icon = nil
	self.show_sociality_icon = nil
	self.show_marriage_icon = nil
	self.show_ranking_icon = nil
	self.show_vipview_icon = nil
	self.show_helperview_icon = nil
	self.show_welfare_icon = nil
	self.show_jingcaiactivity_icon = nil
	self.show_treasure_icon = nil
	self.show_investview_icon = nil
	self.show_rebateview_icon = nil
	self.show_xianzunkaview_icon = nil
	self.show_firstchargeview_icon = nil
	self.show_boss_icon = nil
	self.show_activity_icon = nil
	self.show_arenaactivityview_icon = nil
	self.show_chongzhi_icon = nil
	self.show_rest_double = nil
	self.show_daily_icon = nil
	self.show_fuben_icon = nil
	self.show_scoiety_icon = nil
	self.show_first_charge = nil
	self.show_logingift7view_icon = nil
	self.show_molongmibaoview_icon = nil
	self.show_mining_icon = nil
	self.show_CollectGoals_icon = nil
	self.show_CollectGoals_image = nil
	self.show_lianhunview_icon = nil
	self.show_yewaiguaji_icon = nil
	self.show_day_open_trailer = nil
	self.day_open_trailer_icon = nil
	self.day_open_trailer_text = nil
	self.show_day_open_trailer_effect = nil
	self.is_show_player_info = nil
	self.is_show_temp_mount = nil
	self.is_show_temp_wing = nil
	self.activity_icon_num = nil
	self.hide_map = nil
	self.show_charge_panel = nil
	self.has_first_recharge = nil
	self.show_gold_member_icon = nil
	self.show_bipin = nil
    self.show_ZhuLi = nil
	self.show_leichong_icon = nil
	self.show_mieshizhizhan_icon = nil
	self.show_person_target = nil
	self.bipin_src = nil
	self.ZhuLi_src = nil
	self.bipin_text = nil
	self.show_get_exp = nil
	self.show_exp_number = nil
	self.show_exp_unit = nil
	self.member_repdt = nil
	self.bipin_time = nil
	self.ZhuLi_time = nil
	self.rune_tower_time = nil
	self.show_guild_bubble = nil
	self.is_open_kaifuact = nil
	self.show_online_redpoint = nil
	self.online_time_text = nil
	self.online_can_reward = nil
	self.show_online_btn = nil
	self.show_line_btn = nil
	self.line_name = nil
	self.line_name_active = nil
	self.show_welfare_boss = nil
	self.button_package = nil
	self.show_daily_leiji = nil
	self.show_jubaopen_icon = nil
	self.show_zero_gift_icon = nil
	self.show_zero_gift_eff = nil
	self.show_auto_effect = nil
	self.mlmb_time_txt = nil
	self.dazhao_effect = nil
	self.is_photoshot = nil
	self.show_kf_battle_icon = nil
	self.show_kf_battle_pre_icon = nil
	self.show_risingstar_icon = nil
	self.showr_isingstar_remind = nil
	self.rising_star_icon = nil
	self.rising_star_time = nil
	self.show_LoopCharge_icon = nil
	self.loop_charge_obj = nil
	self.show_nichongwosong = nil
	self.show_charge_btn_group = nil
	self.show_charge_change_btn = nil
	self.show_frist_charge = nil
	self.button_first_charge2 = nil
	self.charge_button_group = nil
	self.charge_button_group_ani = nil
	self.charge_btn_ani = nil
	self.first_charge_ani = nil
	self.show_team_req = nil
	self.show_festival_icon = nil
	self.show_online_icon = nil
	self.show_godtempleview_icon = nil
	self.button_godtempleview = nil

	self.hideable_button_list = nil
	self.act_btn_time_list = nil
	self.act_btn_time_list2 = nil
	self.act_effect_list = nil
	self.act_effect_list_2 = nil
	self.show_chatguild_icon = nil
	self.show_yule_icon = nil
	self.show_yule_icon_in_special = nil
	self.red_point_list = {}
	self.get_is_auto_private = false
	self.private_chat_timer = 0
	self.button_chat_guild = nil
	self.button_chat_guild_icon = nil
	self.button_shushan = nil
	self.record_guild_shake = false
	self.camera_mode = nil
	self.show_exp_bottle_text = nil
	self.show_jixiantiaozhan_effect = nil
	self.need_friend_num = nil
	self.show_activity_hall_icon = nil
	self.activity_hall_img = nil
	self.activity_hall_imgtwo = nil
	self.shenyu_img = nil
	self.shenyu_text = nil
	self.show_xianyu_icon = nil
	self.show_fuzhu_icon = nil
	self.show_activity_hall_eff = nil
	self.show_recharge_icon_1 = nil
	self.act_preview_time = nil
	self.server_active_view = nil
	self.show_hefuactivityview_btn = nil
	self.third_charge = nil
	self.show_three_charge_icon = nil
	self.show_recharge_icon = nil
	self.second_charge = nil
	self.button_fuzhu = nil
	self.show_double_chong_zhi = nil
	self.is_double_recarge_shake = nil
	self.show_monster_button = nil
	self.shrink_button_script = nil
	self.show_charge_arrow = nil
	self.panel = nil
	self.player_button_group = nil
	self.show_shop_icon = nil
	self.show_market_icon = nil
	self.show_compose_icon = nil
	self.show_word_image = nil
	self.jingua_husong_num = nil
	self.new_rank_btn = nil
	self.button_triple_exp = nil
	self.is_general = nil
	self.button_activity_hall_icon = nil
	self.show_single_rebate_icon = nil
	self.singlecharges_t = nil
	self.show_guild_moneytree = nil
	self.showguild_moneytree_time = nil
	self.group3_variable_table = nil
	self.group3_event_table = nil
	self.group3_name_table = nil
	self.group3 = nil
	self.button_tianshen_grave = nil
	self.show_redtaozhuangview_icon = nil

	self.festival_icon = nil
	self.festival_text = nil
end

function MainUIView:OpenCallBack()
	self.is_force_change_charge = true						--是否强制切换左上角充值展示

	self:FlushChargeIcon()
	self.player_view:FlushGoalsIcon()
	self:Flush()
	self.player_view:OpenToFlush()
	GlobalTimerQuest:AddDelayTimer(function()
		GlobalEventSystem:FireByQueue(MainUIEventType.MAINUI_OPEN_COMLETE)
	end, 0)
	self:ChangeFunctionTrailer()
	FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
	FuBenCtrl.Instance:SendGetExpFBInfoReq()
	FuBenCtrl.Instance:SendGetStoryFBGetInfo()
	FuBenCtrl.Instance:SendGetVipFBGetInfo()
	FuBenCtrl.Instance:SendGetTowerFBGetInfo()
	-- self:AutoPrivateChat()
	self:ShakeGuildChatBtn(GuildData.Instance:GetGuildChatShakeState())

	--刷新一下聊天界面
	self.chat_view:FulshChatView()

	GlobalTimerQuest:AddDelayTimer(function()
		--检查右上角收缩动画的红点
		if self.shrink_button_script then
			self.shrink_button_script:CheckRedPoint()
		end
	end, 5)

	self:Flush("mount_change")
	self:Flush("check_show_mount")
	self:Flush("fight_mount_change")
	self:Flush("check_show_fight_mount")

	self:CheckRedNameIcon()
	self:JingHuaHuSongNum()
	self:ShowGuildMoneyTreeIcon()
	self:ShowGuildMoneyTreeTime()
end

function MainUIView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:ChangeFunctionTrailer()
		self:OnGuajiTypeChange(GuajiCache.event_guaji_type)
		if self.menu_toggle_state ~= nil then
			self:PortraitToggleChange(self.menu_toggle_state)
			self.menu_toggle_state = nil
		end
		self:CheckShouFirstChargeEff()
		self.task_other_view:ReFreshState()
	end
end

--是否显示功能预告
function MainUIView:ChangeFunctionTrailer()
	local cur_trailer_cfg = OpenFunData.Instance:GetCurTrailerCfg()
	if self.function_trailer then
		self.function_trailer:FlushView(cur_trailer_cfg)
	end
end

-- function MainUIView:SetRendering(value)
-- 	BaseView.SetRendering(self, value)
-- 	if value then
-- 		self:ChangeFunctionTrailer()
-- 		self:OnGuajiTypeChange(GuajiCache.event_guaji_type)
-- 		if self.menu_toggle_state ~= nil then
-- 			self:PortraitToggleChange(self.menu_toggle_state)
-- 			self.menu_toggle_state = nil
-- 		end
-- 		self:CheckShouFirstChargeEff()
-- 	end
-- end

function MainUIView:SetRootNodeActive(value)
	if not value then
		self.old_root_node_pos = self.root_node.transform.localPosition
		self.root_node.transform.localPosition = Vector3(-100000, -100000, 0)
	else
		if nil ~= self.old_root_node_pos then
			self.root_node.transform.localPosition = self.old_root_node_pos
			self.old_root_node_pos = nil
		end
	end
end

function MainUIView:GetLiuJieBossImageAnimator()
	if self.button_liujieboss then
		self:CancelQuest()
		local is_open = KuafuGuildBattleData.Instance:GetOpenState()
		local have_boss_can_kill = KuafuGuildBattleData.Instance:HaveBossCanKill()
		if have_boss_can_kill and not is_open then
			self.button_liujieboss.animator:SetBool("Shake", true)
			self.liujieboss_ani_quest = GlobalTimerQuest:AddDelayTimer(
				function()
					self.button_liujieboss.animator:SetBool("Shake", false)
					self:CancelQuest()
				end
			,180)
		else
			self.button_liujieboss.animator:SetBool("Shake", false)
		end
	end
end

local value_remind = {[RemindName.FestivalActivity] = 0, [RemindName.OpenFestivalPanel] = 0}
function MainUIView:SetFestivalAnimator(remind_name, value)
	value_remind[remind_name] = value
	local num = 0

	for k,v in pairs(value_remind) do
		if v > 0 then
			num = 1
		end
	end
	self.button_festival.animator:SetBool("Shake", num == 1)
end

function MainUIView:CancelQuest()
	if self.liujieboss_ani_quest then
		GlobalTimerQuest:CancelQuest(self.liujieboss_ani_quest)
		self.liujieboss_ani_quest = nil
	end
end

function MainUIView:FlushBeAtkIconState(role_vo)
	self.reminding_view:SetBeAtkIconState(role_vo)
end

function MainUIView:SetFunctionTrailerState(state)
	-- self.show_function_trailer:SetValue(state)
end

function MainUIView:ShowRebateButton(is_show)
	if nil ~= DailyChargeData.Instance then
		local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
		local is_show = is_show or RebateCtrl.Instance:GetBuyState()
		if self.show_rebateview_icon then
			self.show_rebateview_icon:SetValue(history_recharge >= DailyChargeData.GetMinRecharge() and is_show and OpenFunData.Instance:CheckIsHide("rebateview"))
		end
	end
end

function MainUIView:SceneLoadComplete(old_scene_type, new_scene_type)
	self:ChangeMenuState()
	self.show_switch_buttons:SetValue(true)
	local open_line = PlayerData.Instance:GetAttr("open_line") or 0
	if open_line <= 0 then
		self.show_line_btn:SetValue(false)
	else
		self.show_line_btn:SetValue(true)
		local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		scene_key = scene_key + 1
		self.line_name:SetValue(string.format(Language.Common.Line, scene_key))
	end

	if old_scene_type ~= new_scene_type and not IS_ON_CROSSSERVER then
		self.fight_state_button.toggle.isOn = false
	end

	self.line_name_active:SetValue(new_scene_type == SceneType.Common)
	-- Scene.SendReqTeamMemberPos()
	self:ChangeFunctionTrailer()
	self.player_view:UpdateAttackModeNotice()
	-- --非普通场景不显示娱乐图标
	-- if new_scene_type == SceneType.Common and not GuajiCtrl.Instance:IsSpecialCommonScene() then
	-- 	self.show_yule_icon_in_special:SetValue(true)
	-- else
	-- 	self.show_yule_icon_in_special:SetValue(false)
	-- end
end

function MainUIView:ChangeMenuState()
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local enable = true
	local is_show = true

	if ViewManager.Instance:IsOpen(ViewName.FbIconView) then
		self.map_info:SetValue(self.MenuIconToggle.isOn)
		self.player_view:ShowRightBtns(self.MenuIconToggle.isOn)
		self.target_view:ChangeToHigh(self.MenuIconToggle.isOn)

		enable = main_role_lv >= GameEnum.SHRINK_BTN_INTERABLE_LEVEL and self.MenuIconToggle.isOn or false
		is_show = false
	elseif ViewManager.Instance:IsOpen(ViewName.MountFuBenView)
		or ViewManager.Instance:IsOpen(ViewName.WingFuBenView)
		or ViewManager.Instance:IsOpen(ViewName.JingLingFuBenView) then
		self.map_info:SetValue(false)
		enable = false
	else
		self.map_info:SetValue(true)
		self.player_view:ShowRightBtns(true)
		self.target_view:ChangeToHigh(true)
	end

	self.map_view:ShowShrinkButton(is_show)

	self.show_shrink_btn:SetValue(enable)
	self.shrink_button.toggle.isOn = false

	self.shrink_button.toggle.enabled = enable

	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Kf_OneVOne then
		self.map_info:SetValue(false)
	end

	self.show_yewaiguaji_icon:SetValue(self.is_open_yewaiguaji_icon
		and YewaiGuajiData.Instance:GetFlagShowIcon())

	-- if IS_ON_CROSSSERVER then
	-- 	if scene_type and scene_type ~= SceneType.KfMining and scene_type ~= SceneType.Fishing and scene_type ~= SceneType.CrossGuildBattle then
	-- 		self.map_info:SetValue(false)
	-- 	end
	-- end
	if ViewManager.Instance:IsOpen(ViewName.Fishing) then
		self.map_info:SetValue(false)
	end

	self.skill_view:OnFlush({skill = true})
end

function MainUIView:ClashTerritoryDataChangeCallback()
	self.skill_view:OnFlush({skill = true})
end

function MainUIView:GetDaZhaoEffect()
	return self.dazhao_effect
end

function MainUIView:GoddessSkillTipsClose()
	if self.skill_view then
		self.skill_view:OnFlush({goddess_skill_tips = true})
	end
end

function MainUIView:SetViewState(is_in)
	-- if is_in then
	-- 	if self.task_shrink_button then
			-- if self.MenuIconToggle then
			-- 	self.task_shrink_button.canvas_group.alpha = self.MenuIconToggle.isOn and 0 or 1
			-- 	self.task_contents.canvas_group.alpha = self.MenuIconToggle.isOn and 0 or 1
			-- 	self.task_tab_btn.canvas_group.alpha = self.MenuIconToggle.isOn and 0 or 1
			-- else
				-- self.task_shrink_button.canvas_group.alpha = 1
				-- self.task_contents.canvas_group.alpha = 1
			-- end
		-- end
	-- end

	if self.is_in_special_scene then
		self.is_in_special_scene:SetValue(is_in)
		if self.left_track_animator.isActiveAndEnabled then
			if self.MenuIconToggle then
				self.left_track_animator:SetBool("fade", self.MenuIconToggle.isOn)
				if self.task_tab_btn.gameObject.activeInHierarchy then
					self.task_tab_btn_animator:SetBool("fade", self.MenuIconToggle.isOn)
				end
				if self.task_shrink_button.gameObject.activeInHierarchy then
					self.task_shrink_button_animator:SetBool("fade", self.MenuIconToggle.isOn)
				end
			else
				self.left_track_animator:SetBool("fade", false)
				if self.task_tab_btn.gameObject.activeInHierarchy then
					self.task_tab_btn_animator:SetBool("fade", false)
				end
				if self.task_shrink_button.gameObject.activeInHierarchy then
					self.task_shrink_button_animator:SetBool("fade", false)
				end
			end
		end
		-- self.is_in_special_scene:SetValue(is_in)
	else
		self.is_in = is_in
	end
	if not is_in and self.MenuIconToggle then --临时修改!
		self.MenuIconToggle.isOn = not self.MenuIconToggle.isOn
		self.MenuIconToggle.isOn = not self.MenuIconToggle.isOn
	end
end

function MainUIView:SetShowMapInfo(is_show)
	if self.is_show_map_info then
		self.is_show_map_info:SetValue(is_show)
	end
end

function MainUIView:SetShowTask(is_show)
	if self.task_view then
		self.show_task:SetValue(is_show)
	end
end

function MainUIView:SetAllViewState(switch)
	self:SetViewState(switch)
	if self.hide_vip then
		self.hide_vip:SetValue(switch)
	end
	if self.player_info then
		self.player_info:SetActive(switch)
	end
end

function MainUIView:SetPlayerInfoState(switch)
	if self.is_show_player_info then
		self.is_show_player_info:SetValue(switch)
	else
		self.hide_player_info = not switch
	end
end

function MainUIView:SetShowLoginGiftIcon(is_show)
	if self.show_logingift7view_icon then
		local fun_open = OpenFunData.Instance:CheckIsHide("logingift7view")
		self.show_logingift7view_icon:SetValue(fun_open and is_show)
	end
end

function MainUIView:SetFestivaluIcon(is_show)
	if self.show_festival_icon and OpenFunData.Instance:CheckIsHide("festivalview") then
		self.show_festival_icon:SetValue(is_show)
	end
end

function MainUIView:SetOnLineIcon(is_show)
	if self.show_online_icon then
		self.show_online_icon:SetValue(is_show)
	end
end

function MainUIView:SetShowExpBottle(is_show)
	if self.show_exp_bottle_icon then
		self.show_exp_bottle_icon:SetValue(is_show)
	end
end


function MainUIView:SetWeddingTime()
	local leave_time = MarriageData.Instance:GetWeedingTime()
	if leave_time <= 0 then
		return
	end
	local function timer_func(elapse_time, total_time)
		if total_time - elapse_time <= 0 then
			self:StopWeddingTime()
			return
		end

		local time_str = TimeUtil.FormatSecond(total_time - elapse_time, 2)
		self.wedding_time:SetValue(time_str)
	end
	if self.wedding_count_down then
		CountDown.Instance:RemoveCountDown(self.wedding_count_down)
		self.wedding_count_down = nil
	end
	self.wedding_count_down = CountDown.Instance:AddCountDown(leave_time, 1, timer_func)
end

function MainUIView:StopWeddingTime()
	if self.wedding_count_down then
		CountDown.Instance:RemoveCountDown(self.wedding_count_down)
		self.wedding_count_down = nil
	end
	self.show_marry_wedding:SetValue(false)
end

function MainUIView:ChangeWeddingState()
	self:StopWeddingTime()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local lover_id = main_role_vo.lover_uid
	if lover_id and lover_id > 0 then
		local is_wedding = MarriageData.Instance:GetIsHoldingWeeding()
		if is_wedding then
			local is_marry_user = MarriageData.Instance:IsMarryUser()
			if is_marry_user then
				self.show_marry_wedding:SetValue(true)
				self:SetWeddingTime()
			end
		end
	end
end

-- 设置开服活动按钮状态
function MainUIView:SetNewServerBtnState()
	if self.show_kaifuactivityview_btn then
		self.show_kaifuactivityview_btn:SetValue(KaifuActivityData.Instance:IsShowKaifuIcon())
	end
end

function MainUIView:SetIsFinishTarget(is_show)
	self.show_person_target:SetValue(is_show)
end

function MainUIView:FlushGoldMemberIcon()
	local is_fun_open = OpenFunData.Instance:CheckIsHide("gold_member")
	local is_get_reward = GoldMemberData.Instance:IsGetReward()

	self.show_gold_member_icon:SetValue(is_fun_open and not is_get_reward)
end

function MainUIView:OnFlush(param_t)
	if self.skill_view then
		self.skill_view:OnFlush(param_t)
	end
	if self.show_kaifuactivityview_btn then
		self.show_kaifuactivityview_btn:SetValue((KaifuActivityData.Instance:IsShowKaifuIcon())
				and OpenFunData.Instance:CheckIsHide("kaifuactivityview"))
	end

	if nil ~= self.is_show_temp_mount and nil ~= MountData.Instance then
		self.is_show_temp_mount:SetValue(MountData.Instance:IsShowTempMountIcon() and OpenFunData.Instance:CheckIsHide(ViewName.TempMount))
	end

	if nil ~= self.is_show_temp_wing and nil ~= WingData.Instance then
		self.is_show_temp_wing:SetValue(WingData.Instance:IsShowTempWingIcon() and OpenFunData.Instance:CheckIsHide(ViewName.TempMount))
	end

	if self.show_switch_button and IS_ON_CROSSSERVER then
		self.show_switch_button:SetValue(false)
	end

	if self.show_ranking_icon then
		self.show_ranking_icon:SetValue(OpenFunData.Instance:CheckRankingIsOpen())
	end

	-- 普天同庆
	if self.show_rest_double then
		local open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
		self.show_rest_double:SetValue(open)
		self:IsShowDoubleChongZhi()
	end

	-- 一元夺宝
	-- if self.show_one_yuan_snatch then
	-- 	local act_info = ActivityData.Instance:GetCrossRandActivityStatusByType(ACTIVITY_TYPE.KF_ONEYUANSNATCH)
	-- 	if act_info then
	-- 		self.show_one_yuan_snatch:SetValue(act_info.status == ACTIVITY_STATUS.OPEN)
	-- 	end
	-- end
	for k, v in pairs(param_t) do
		if k == "mail_rec" then
			self.chat_view:SetMailRecVisible(v[1])
		elseif k == "crazy_rec" then
			self.chat_view:SetCrazyTreeRecVisible(v[1])
		elseif k == "friend_rec" then
			self.chat_view:SetFriendRecVisible(v[1])
		elseif k == "team_req" then
			self.chat_view:SetTeamReqVisible(v[1])
			self.show_team_req:SetValue(v[1] and IS_ON_CROSSSERVER)
		elseif k == "join_req" then
			self.chat_view:SetJoinReqVisible(v[1])
		elseif k == "trade_req" then
			self.chat_view:SetTradeReqVisible(v[1])
		elseif k == "weeding_get_invite" then
			self.chat_view:SetWeedingGetInbiteVisible(v[1])
		elseif k == "gift_btn" then
			self.chat_view:SetGiftBtnVisible(v[1])
		elseif k == "hongbao" then
			self.chat_view:CreateHongBao(v[1], v[2])
		elseif k == "server_hongbao" then
			self.chat_view:CreateServerHongBao(v[1], v[2])
		elseif k == "always_shake" then
			self:DoubleRechargeAlwaysShake(v[1])
		elseif k == "team_list" then
			self.team_view:ReloadData()
		elseif k == "sos_req" then
			self.chat_view:CreateSos(v[1])
		elseif k == "wedding" then
			self:ChangeWeddingState()
		elseif k == "guild_yao" then
			self.chat_view:SetGuildApplyVisible(v[1])
		elseif k == "off_line" then
			self.chat_view:ShowOffLineBtn(v[1])
		elseif k == "be_atk" then
			self:FlushBeAtkIconState(v[1])
		elseif k == "on_line" then
			self:FlushOnlineReward()
		elseif k == "love_content" then
			self.chat_view:ShowLoveContentBtn(v[1])
		elseif k == "discount" then
			self.chat_view:ShowDisCountBtn(v[1])
		elseif k == "discount_red" then
			self.chat_view:SetDiscountRed(v[1])
		elseif k == "discount_ani" then
			self.chat_view:SetDisCountTrigger()
		elseif k == "temp_vip" then
			self.player_view:FlushTempVip()
		elseif k == "show_diamondown" then
			self:ShowDiamonDown()
		elseif k == "activity_hongbao_ani" then
			self:ChangeActHongBaoAni(v[1], v[2])
		elseif k == "change_red_point" then
			self:ChangeRedPoint(v[1], v[2])
		elseif k == "change_act_hongbao_btn" then
			self:ChangeActHongBaoBtn(v[1])
		elseif k == "change_target_state" then
			self:SetIsFinishTarget(v[1])
		elseif k == "congratulate_btn" then
			self.chat_view:SetShowCongratulateBtn(v[1])
		elseif k == "dafuhao" then
			if self.show_switch_button then
				self.show_switch_button:SetValue(false) -- DaFuHaoData.Instance:IsShowDaFuHao()
			end
		elseif k == "guild_goddess" then
			self.chat_view:SetGuildGoddessVisible(v[1])
		elseif k == "guild_invite" then
			self.chat_view:CreateGuildInvite(v[1])
		elseif k == "bag_full" then
			self.chat_view:SetBagFullVisible(v[1])
		elseif k == "kouling_hongbao" then
			self.chat_view:FlushKoulingHongbao()
		-- elseif k == "guild_hongbao" then
		-- 	self.chat_view:SetGuildHongBaoVisible(v[1])
		elseif k == "shen_ge_effect" then
			if nil ~= self.show_shen_ge_effect then
				self.show_shen_ge_effect:SetValue(ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI)
					and OpenFunData.Instance:CheckIsHide("shengxiao_uplevel"))
			end
		elseif k == "auto_effect" then
			local scene_logic = Scene.Instance:GetSceneLogic()
			if nil ~= scene_logic then
				self.show_auto_effect:SetValue(scene_logic:IsShowAutoEffect())
			else
			end
		elseif k == "jubaopen" then
			self:CheckJuBaoPenIcon()
		elseif k == "daily_love" then
			self:CheckDailyLoveIcon()
		elseif k == "single_rebate" then
			self:CheckSingleRebateIcon()
		elseif k == "red_name" then
			self:CheckRedNameIcon()
		elseif k == "trailerview" then
			self:ChangeFunctionTrailer()
		elseif k == "show_privite_remind" then
			self:ShowPriviteRemind(v[1])
		elseif k == "flush_popchat_view" then
			self.chat_view:FlushPopChatView()
		elseif k == "show_guildchat_redpt" then
			self.chat_view:ShowGuildChatRedPt(v[1])
		elseif k == "privite_visible" then
			self:SetPriviteRemindVisible(v[1])
		elseif k == "check_canhide_privite_remind" then
			self:CheckCanHidePriviteRemind()
		elseif k == "MarryBlessing" then
			self.chat_view:ShowMarryBlessing(v[1])
		elseif k == "GuildMemberFull" then
			self.chat_view:ShowGuildMemberFull(v[1])
		elseif k == "GuildShake" then
			self:ShakeGuildChatBtn(v[1])
		elseif k == "flush_guild_chat_icon" then
			self:ShowGuildChatIcon(v[1])
		elseif k == "flush_welfare_icon" then
			self:ShowWelfareBossIcon(v[1])
		elseif k == "reminder_charge" then
			self.reminding_view:FlushFirstCharge()
		elseif k == "leiji_charge" then
			self:CheckLeiJiRechargeIcon(v[1])
		elseif k == "chat_buttons" then
			self.chat_view:SetChatButtonsVisible(v[1])
		elseif k == "recharge" then
			self:CheckRechargeIcon(v[1])
		elseif k == "wedding_remind" then
			self.chat_view:ChangeWeddingRemind()
		elseif k == "rising_star" then
			self:ChangeRisingStarIcon(v[1])
		elseif k == "mount_change" then
			self.chat_view:FlushMountState()
		elseif k == "check_show_mount" then
			self.chat_view:CheckShowMountBtn()
		elseif k == "fight_mount_change" then
			self.joystick_view:FlushFightMountState()
		elseif k == "check_show_fight_mount" then
			self.joystick_view:CheckShowFightMount()
		elseif k == "login_gift_icon" then
			self:SetShowLoginGiftIcon(v[1])
		elseif k == "flush_gold_member" then
			self:FlushGoldMemberIcon()
		elseif k == "change_monster_list" then
			self:ChangeMonsterViewState()
			if self.monster_view then
				self.monster_view:Flush()
			end
		elseif k == "general_bianshen" then
			self:ChangeGeneralState()
			self.general_skill_view:Flush(v[1])
		elseif k == "degree_rewards" then
			self:ChangeDegreeRewardIcon(v[1])
		elseif k == "on_open_trigger" then
			self:OnOpenTrigger(v[1], v[2])
		elseif k == "flush_open_trailer" then
			self:FlushDayOpenTrailer()
		elseif k == "return_reward_icon" then
			self.chat_view:ShowReturnRewardIcon()
		elseif k == "flush_kuafu_liujie" then
			if self.act_effect_list[ACTIVITY_TYPE.KF_GUILDBATTLE] then
				local flag = KuafuGuildBattleData.Instance:GetTripleStatu()
				local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_GUILDBATTLE)
				if activity_info then
					local activity_flag = activity_info.status == ACTIVITY_STATUS.OPEN
					if activity_flag then
						self.act_effect_list[ACTIVITY_TYPE.KF_GUILDBATTLE]:SetValue(true)
					else
						self.act_effect_list[ACTIVITY_TYPE.KF_GUILDBATTLE]:SetValue(flag)
					end
				else
					self.act_effect_list[ACTIVITY_TYPE.KF_GUILDBATTLE]:SetValue(flag)
				end
			end
		end
	end
	self:FlushInChongWoSong()
	self:PhototShot()
	self:CheckShouFirstChargeEff()
	self:HasViewOpen()
	self:HasViewClose()
end

function MainUIView:CheckRechargeIcon()
	local is_can_show1 = DailyChargeData.Instance:GetThreeRechargeOpen(1)
	local is_can_show2 = DailyChargeData.Instance:GetThreeRechargeOpen(2)
	local is_can_show3 = DailyChargeData.Instance:GetThreeRechargeOpen(3)

	self.show_recharge_icon:SetValue(is_can_show2)
	self.show_three_charge_icon:SetValue(is_can_show3)
end

function MainUIView:PhototShot()
	local need_lv = 0
	local dengji = 0
	local cfg = {}
	if nil ~= PlayerData.Instance:GetRoleLevel() then
		dengji = PlayerData.Instance:GetRoleLevel()
	end

	if nil ~= OpenFunData.Instance:OpenFunCfg() then
		cfg = OpenFunData.Instance:OpenFunCfg()
	end

	for k, v in pairs(cfg) do
		if v.name == "screen_shot" then
			need_lv = v.trigger_param
		end
	end

	if dengji >= need_lv then
		self.is_photoshot:SetValue(true)
	else
		self.is_photoshot:SetValue(false)
	end
end

function MainUIView:GetSkillButtonPosition()
	if self.skill_view then
		return self.skill_view:GetSkillButtonPosition()
	end
end

--可隐藏按钮
function MainUIView:FindHideableButton()
	self.hideable_button_list = {}
	self.hideable_button_list[MainUIData.RemindingName.XiuLuoTower] = self:FindVariable("ShowXiuLuoTower")
	self.hideable_button_list[MainUIData.RemindingName.TombExplore] = self:FindVariable("ShowTombExplore")
	self.hideable_button_list[MainUIData.RemindingName.CityCombat] = self:FindVariable("ShowCityCombat")
	self.hideable_button_list[MainUIData.RemindingName.WeekBoss] = self:FindVariable("ShowWeekBoss")
	self.hideable_button_list[MainUIData.RemindingName.Show_Seven_Login] = self:FindVariable("Show_Seven_Login")
	self.hideable_button_list[MainUIData.RemindingName.Show_Collection] = self:FindVariable("Show_Collection")
	self.hideable_button_list[MainUIData.RemindingName.Cross_Hot_Spring] = self:FindVariable("ShowCrossHotSpring")
	self.hideable_button_list[MainUIData.RemindingName.Big_Rich] = self:FindVariable("ShowBigRich")
	self.hideable_button_list[MainUIData.RemindingName.Question] = self:FindVariable("ShowQuestion")
	self.hideable_button_list[MainUIData.RemindingName.Double_Escort] = self:FindVariable("ShowDoubleEscort")
	self.hideable_button_list[MainUIData.RemindingName.Cross_One_Vs_One] = self:FindVariable("ShowCrossOneVsOne")
	-- self.hideable_button_list[MainUIData.RemindingName.Clash_Territory] = self:FindVariable("ShowClashTerritory")
	self.hideable_button_list[MainUIData.RemindingName.Fishing] = self:FindVariable("ShowFishing")
	self.hideable_button_list[MainUIData.RemindingName.Guild_Battle] = self:FindVariable("ShowGuildBattle")
	self.hideable_button_list[MainUIData.RemindingName.Fall_Money] = self:FindVariable("ShowTianJiangCaiBao")
	self.hideable_button_list[MainUIData.RemindingName.Element_Battle] = self:FindVariable("ShowElementBattle")
	self.hideable_button_list[MainUIData.RemindingName.GuildMijing] = self:FindVariable("ShowGuildMijing")
	self.hideable_button_list[MainUIData.RemindingName.GuildBonfire] = self:FindVariable("ShowGuildBonfire")
	self.hideable_button_list[MainUIData.RemindingName.GuildBoss] = self:FindVariable("ShowGuildBoss")
	self.hideable_button_list[MainUIData.RemindingName.CrossCrystal] = self:FindVariable("ShowCrossCrystal")
	self.hideable_button_list[MainUIData.RemindingName.Show_Reincarnation] = self:FindVariable("Show_Reincarnation")
	self.hideable_button_list[MainUIData.RemindingName.MolongMibao] = self:FindVariable("Show_MolongMibao")
	self.hideable_button_list[MainUIData.RemindingName.show_invest_icon] = self.show_invest_icon
	self.hideable_button_list[MainUIData.RemindingName.SingleRebate] = self:FindVariable("ShowSingleRebateView")
	self.hideable_button_list[MainUIData.RemindingName.ExpRefine] = self:FindVariable("ShowExpRefineBtn")
	self.hideable_button_list[MainUIData.RemindingName.MarryMe] = self:FindVariable("ShowWantMarry")
	self.hideable_button_list[MainUIData.RemindingName.YiZhanDaoDi] = self:FindVariable("ShowYiZhanDaoDi")
	self.hideable_button_list[MainUIData.RemindingName.ZhuanZhuanLe] = self:FindVariable("ShowZhuanZhuanLe")
	self.hideable_button_list[MainUIData.RemindingName.JinYinTa] = self:FindVariable("ShouJinYinTa")
	self.hideable_button_list[MainUIData.RemindingName.ZhenBaoGe] = self:FindVariable("ShowZhenBaoGe")
	self.hideable_button_list[MainUIData.RemindingName.Huan_Zhuang_Shop] = self:FindVariable("ShowHuanZhuangShopView")
	self.hideable_button_list[MainUIData.RemindingName.ShuShan] = self:FindVariable("ShowShuShan")
	self.hideable_button_list[MainUIData.RemindingName.DailyLove] = self:FindVariable("ShowDailyLove")
	self.hideable_button_list[MainUIData.RemindingName.RedName] = self:FindVariable("ShowRedName")
	self.hideable_button_list[MainUIData.RemindingName.TripleGuaji] = self:FindVariable("ShowTripleExp")
	self.hideable_button_list[MainUIData.RemindingName.WeddingActivity] = self:FindVariable("ShowWeddingActivity")
	self.hideable_button_list[MainUIData.RemindingName.JingHuaHuSong] = self:FindVariable("ShowJingHuaHuSong")
	self.hideable_button_list[MainUIData.RemindingName.MountDegree] = self:FindVariable("ShowMountDegree")
	self.hideable_button_list[MainUIData.RemindingName.Worship] = self:FindVariable("ShowWorship")
	self.hideable_button_list[MainUIData.RemindingName.WingDegree] = self:FindVariable("ShowWingDegree")
	self.hideable_button_list[MainUIData.RemindingName.HaloDegree] = self:FindVariable("ShowHaloDegree")
	self.hideable_button_list[MainUIData.RemindingName.FootDegree] = self:FindVariable("ShowFootDegree")
	self.hideable_button_list[MainUIData.RemindingName.FightMountDegree] = self:FindVariable("ShowFightMountDegree")
	self.hideable_button_list[MainUIData.RemindingName.ShenGongDegree] = self:FindVariable("ShowShenGongDegree")
	self.hideable_button_list[MainUIData.RemindingName.ShenYiDegree] = self:FindVariable("ShowShenYiDegree")
	self.hideable_button_list[MainUIData.RemindingName.YaoShiDegree] = self:FindVariable("ShowYaoShiDegree")
	self.hideable_button_list[MainUIData.RemindingName.TouShiDegree] = self:FindVariable("ShowTouShiDegree")
	self.hideable_button_list[MainUIData.RemindingName.QiLinBiDegree] = self:FindVariable("ShowQiLinBiDegree")
	self.hideable_button_list[MainUIData.RemindingName.LoopCharge2] = self:FindVariable("show_LoopCharge_icon")
	self.hideable_button_list[MainUIData.RemindingName.RechargeCapacity] = self:FindVariable("ShowButtonRechargeCapacity")
	self.hideable_button_list[MainUIData.RemindingName.SingleCharge2] = self:FindVariable("ShowButtonSingleCharge2")
	self.hideable_button_list[MainUIData.RemindingName.SingleCharge3] = self:FindVariable("ShowButtonSingleCharge3")
	self.hideable_button_list[MainUIData.RemindingName.IncreaseCapability] = self:FindVariable("ShowButtonIncreaseCapability")
	self.hideable_button_list[MainUIData.RemindingName.DanBiChongZhi] = self:FindVariable("ShowButtonDanBiChongZhi")
	self.hideable_button_list[MainUIData.RemindingName.Kf_Mining] = self:FindVariable("ShowKuaFuMining")
	self.hideable_button_list[MainUIData.RemindingName.SecretrShop] = self:FindVariable("ShowShenMiShop")
	self.hideable_button_list[MainUIData.RemindingName.MaskDegree] = self:FindVariable("ShowMaskDegree")
	self.hideable_button_list[MainUIData.RemindingName.XianBaoDegree] = self:FindVariable("ShowXianBaoDegree")
	self.hideable_button_list[MainUIData.RemindingName.LingZhuDegree] = self:FindVariable("ShowLingZhuDegree")
	self.hideable_button_list[MainUIData.RemindingName.OnYuan] = self:FindVariable("ShowOneYuanSnatch")
	self.hideable_button_list[MainUIData.RemindingName.TianShenGrave] = self.group3_variable_table:FindVariable("ShowTianshenGrave")
	self.hideable_button_list[MainUIData.RemindingName.LingChongDegree] = self:FindVariable("ShowLingChongDegree")
	self.hideable_button_list[MainUIData.RemindingName.LingGongDegree] = self:FindVariable("ShowLingGongDegree")
	self.hideable_button_list[MainUIData.RemindingName.LingQiDegree] = self:FindVariable("ShowLingQiDegree")
	-- self.hid

	for k,v in pairs(self.hideable_button_list) do
		if self.tmp_button_data[k] ~= nil then

			if k == MainUIData.RemindingName.MolongMibao then
				v:SetValue(self.tmp_button_data[k] and OpenFunData.Instance:CheckIsHide("molongmibaoview"))
			elseif k == MainUIData.RemindingName.LoopCharge2 then
				v:SetValue(self.tmp_button_data[k] and OpenFunData.Instance:CheckIsHide("LoopCharge"))
			elseif k == MainUIData.RemindingName.SecretrShop then
				local is_open = OpenFunData.Instance:CheckIsHide("SecretrShopView")
				v:SetValue(is_open and self.tmp_button_data[k])
			else
				v:SetValue(self.tmp_button_data[k])
			end
		else
			v:SetValue(false)
		end
	end
end

function MainUIView:SetButtonVisible(key, is_show)
	
	if key == "zero_gift" then
		if self.show_zero_gift_icon then
			self.show_zero_gift_icon:SetValue(OpenFunData.Instance:CheckIsHide("zero_gift") and FreeGiftData.Instance:CanShowZeroGift())
		end
		return
	end

	if self.hideable_button_list == nil and is_show ~= nil then
		self.tmp_button_data[key] = is_show
		return
	end

	if self.hideable_button_list[key] ~= nil then

		if key == MainUIData.RemindingName.MolongMibao then
			self.hideable_button_list[key]:SetValue(OpenFunData.Instance:CheckIsHide("molongmibaoview") and (is_show or self:SpecActIsOpen(key)))
			-- self:SetMolongMibaoTime()
		elseif key == MainUIData.RemindingName.JinYinTa then
			self.hideable_button_list[key]:SetValue(OpenFunData.Instance:CheckIsHide("JinYinTaView") and (is_show or self:SpecActIsOpen(key)))
			self:SetJinyinTaActTime()
		elseif key == MainUIData.RemindingName.ZhenBaoGe then
			self.hideable_button_list[key]:SetValue(OpenFunData.Instance:CheckIsHide("TreasureLoftView") and (is_show or self:SpecActIsOpen(key)))
			self:SetZhenBaoGeActTime()
		elseif key == MainUIData.RemindingName.ZhuanZhuanLe then
			self.hideable_button_list[key]:SetValue(OpenFunData.Instance:CheckIsHide("ZhuangZhuangLeView") and (is_show or self:SpecActIsOpen(key)))
			self:SetZhuanZhuanLeActTime()
		elseif key == MainUIData.RemindingName.DailyLove then 		--每日一爱
			self.hideable_button_list[key]:SetValue(OpenFunData.Instance:CheckIsHide("kaifuactivityview") and is_show)
		elseif key == MainUIData.RemindingName.TripleGuaji then
			self.hideable_button_list[key]:SetValue(YewaiGuajiData.Instance:IsShowMainUIIcon() and is_show)
		elseif key == MainUIData.RemindingName.SecretrShop then
			self:SetSecretrShopTime()
			local is_open = OpenFunData.Instance:CheckIsHide("SecretrShopView")
			self.hideable_button_list[key]:SetValue(is_open and is_show)
		elseif key == MainUIData.RemindingName.LoopCharge2 then
			self.hideable_button_list[key]:SetValue(OpenFunData.Instance:CheckIsHide("LoopCharge") and is_show)
		else
			if key == MainUIData.RemindingName.MarryMe then
				ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.MARRY_ME)
				self:SetMarryMeActTime()
			elseif key == MainUIData.RemindingName.WeddingActivity then
				local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
				if main_role_vo.level < WEDDING_ACTIVITY_LEVEL then
					self.hideable_button_list[key]:SetValue(false)
				end
			end
			
			self.hideable_button_list[key]:SetValue(is_show or self:SpecActIsOpen(key))
		end
	end
end

function MainUIView:SpecActIsOpen(key)
	if key == MainUIData.RemindingName.ExpRefine then
		return ExpRefineData.Instance:GetExpRefineBtnIsShow()
	end
	return false
end

function MainUIView:SetArrowImage(bool)
	self.arrow_image:SetActive(false) -- 先屏蔽第一次打开每日必做的提示箭头
end

--活动按钮时间
function MainUIView:FindActivityBtnTime()
	self.act_btn_time_list = {}
	self.act_btn_time_list[ACTIVITY_TYPE.GONGCHENGZHAN] = self:FindVariable("CityCombatTime")
	self.act_btn_time_list[ACTIVITY_TYPE.WEEKBOSS] = self:FindVariable("WeekBossTime")
	self.act_btn_time_list[ACTIVITY_TYPE.TOMB_EXPLORE] = self:FindVariable("TombExploreTime")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_XIULUO_TOWER] = self:FindVariable("XiuLuoTowerTime")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_HOT_SPRING] = self:FindVariable("CrossHotSpringTime")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_GUILDBATTLE] = self:FindVariable("KFBattleTime")
	self.act_btn_time_list[ACTIVITY_TYPE.BIG_RICH] = self:FindVariable("BigRichTime")
	self.act_btn_time_list[ACTIVITY_TYPE.QUESTION_2] = self:FindVariable("QuestionTime")
	self.act_btn_time_list[ACTIVITY_TYPE.HUSONG] = self:FindVariable("DoubleEscortTime")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_ONEVONE] = self:FindVariable("CrossOneVsOneTime")
	self.act_btn_time_list[ACTIVITY_TYPE.CLASH_TERRITORY] = self:FindVariable("ClashTerritoryTime")
	self.act_btn_time_list[ACTIVITY_TYPE.GUILDBATTLE] = self:FindVariable("GuildBattleTime")
	self.act_btn_time_list[ACTIVITY_TYPE.TIANJIANGCAIBAO] = self:FindVariable("TianJiangCaiBaoTime")
	self.act_btn_time_list[ACTIVITY_TYPE.QUNXIANLUANDOU] = self:FindVariable("ElementBattleTime")
	self.act_btn_time_list[ACTIVITY_TYPE.GUILD_SHILIAN] = self:FindVariable("GuildMijingTime")
	self.act_btn_time_list[ACTIVITY_TYPE.GUILD_BONFIRE] = self:FindVariable("GuildBonfireTime")
	self.act_btn_time_list[ACTIVITY_TYPE.GUILD_BOSS] = self:FindVariable("GuildBossTime")
	self.act_btn_time_list[ACTIVITY_TYPE.SHUIJING] = self:FindVariable("CrossCrystalTime")
	self.act_btn_time_list[ACTIVITY_TYPE.CROSS_SHUIJING] = self.group3_variable_table:FindVariable("TianShenGraveTime")
	self.act_btn_time_list[ACTIVITY_TYPE.HUANGCHENGHUIZHAN] = self:FindVariable("ShuShanTime")
	self.act_btn_time_list[ACTIVITY_TYPE.CHAOSWAR] = self:FindVariable("YiZhanDaoDiTime")
	self.act_btn_time_list[ACTIVITY_TYPE.MARRY_ME] = self:FindVariable("MarryMeTimes")
	self.act_btn_time_list[ACTIVITY_TYPE.ACTIVITY_TYPE_WEDDING] = self:FindVariable("WeddingTimes")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_JINYINTA] = self:FindVariable("ShouJinYinTaTime")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT] = self:FindVariable("ShowZhenBaoGeTime")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP] = self:FindVariable("ShenMiShopTime")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_LOTTERY_TREE] = self:FindVariable("ZhuanZhuanLeTime")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_FISHING] = self:FindVariable("FishingTime")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_MINING] = self:FindVariable("MiningTime")
	self.act_btn_time_list2 = {}
	self.act_btn_time_list2[ACTIVITY_TYPE.GONGCHENGZHAN] = self:FindVariable("CityCombatTime2")
	self.act_btn_time_list2[ACTIVITY_TYPE.CLASH_TERRITORY] = self:FindVariable("ClashTerritoryTime2")
	self.act_btn_time_list2[ACTIVITY_TYPE.GUILDBATTLE] = self:FindVariable("GuildBattleTime2")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP] = self:FindVariable("HuanZhuangShopTime")
	self.act_btn_time_list[ACTIVITY_TYPE.ACTIVITY_TYPE_TRIPLE_GUAJI] = self:FindVariable("TripleActTime")
	self.act_btn_time_list[ACTIVITY_TYPE.JINGHUA_HUSONG] = self:FindVariable("JingHuaHuSongTime")
	self.act_btn_time_list[ACTIVITY_TYPE.GONGCHENG_WORSHIP] = self:FindVariable("WorshipOpenTime")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2] = self:FindVariable("LoopChargeActTime")

	self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI] = self:FindVariable("RestDoubleTime")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_ONEYUANSNATCH] = self:FindVariable("SnatchActTime")

	self.act_effect_list = {}
	self.act_effect_list[ACTIVITY_TYPE.GONGCHENGZHAN] = self:FindVariable("ShowCityCombatEffect")
	self.act_effect_list[ACTIVITY_TYPE.TOMB_EXPLORE] = self:FindVariable("ShowTombExploreEffect")
	self.act_effect_list[ACTIVITY_TYPE.KF_XIULUO_TOWER] = self:FindVariable("ShowXiuLuoTowerEffect")
	self.act_effect_list[ACTIVITY_TYPE.KF_HOT_SPRING] = self:FindVariable("ShowCrossHotSpringEffect")
	self.act_effect_list[ACTIVITY_TYPE.BIG_RICH] = self:FindVariable("ShowBigRichEffect")
	self.act_effect_list[ACTIVITY_TYPE.QUESTION_2] = self:FindVariable("ShowQuestionEffect")
	self.act_effect_list[ACTIVITY_TYPE.HUSONG] = self:FindVariable("ShowDoubleEscortEffect")
	self.act_effect_list[ACTIVITY_TYPE.KF_ONEVONE] = self:FindVariable("ShowCrossOneVsOneEffect")
	self.act_effect_list[ACTIVITY_TYPE.CLASH_TERRITORY] = self:FindVariable("ShowClashTerritoryEffect")
	self.act_effect_list[ACTIVITY_TYPE.GUILDBATTLE] = self:FindVariable("ShowGuildBattleEffect")
	self.act_effect_list[ACTIVITY_TYPE.TIANJIANGCAIBAO] = self:FindVariable("ShowTianJiangCaiBaoEffect")
	self.act_effect_list[ACTIVITY_TYPE.QUNXIANLUANDOU] = self:FindVariable("ShowElementBattleEffect")
	self.act_effect_list[ACTIVITY_TYPE.GUILD_SHILIAN] = self:FindVariable("ShowGuildMijingEffect")
	self.act_effect_list[ACTIVITY_TYPE.GUILD_BONFIRE] = self:FindVariable("ShowGuildBonfireEffect")
	self.act_effect_list[ACTIVITY_TYPE.GUILD_BOSS] = self:FindVariable("ShowGuildBossEffect")
	self.act_effect_list[ACTIVITY_TYPE.SHUIJING] = self:FindVariable("ShowCrossCrystalEffect")
	self.act_effect_list[ACTIVITY_TYPE.CROSS_SHUIJING] = self.group3_variable_table:FindVariable("ShowTianShenGraveEffect")
	self.act_effect_list[ACTIVITY_TYPE.CHAOSWAR] = self:FindVariable("ShowYiZhanDaoDiEffect")
	self.act_effect_list[ACTIVITY_TYPE.RAND_JINYINTA] = self:FindVariable("ShouJinYinTaEffect")
	self.act_effect_list[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT] = self:FindVariable("ShouZhenBaoGeEffect")
	self.act_effect_list[ACTIVITY_TYPE.RAND_LOTTERY_TREE] = self:FindVariable("ShowZhuanZhuanLeEffect")
	self.act_effect_list[ACTIVITY_TYPE.KF_GUILDBATTLE] = self:FindVariable("ShowKFBattleEffect")
	self.act_effect_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP] = self:FindVariable("ShowHuanZhuangShopEffect")
	self.act_effect_list[ACTIVITY_TYPE.ACTIVITY_TYPE_TRIPLE_GUAJI] = self:FindVariable("ShowTripleEffect")
	self.act_effect_list[ACTIVITY_TYPE.JINGHUA_HUSONG] = self:FindVariable("ShowJingHuaHuSongEffect")
	self.act_effect_list[ACTIVITY_TYPE.GONGCHENG_WORSHIP] = self:FindVariable("ShowWorshipEffect")
	self.act_effect_list[ACTIVITY_TYPE.HUANGCHENGHUIZHAN] = self:FindVariable("ShowShuShanEffect")
	self.act_effect_list[ACTIVITY_TYPE.KF_MINING] = self:FindVariable("ShowMiningEffect")
	self.act_effect_list[ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI] = self:FindVariable("ShowRestDoubleEffect")
	self.act_effect_list[ACTIVITY_TYPE.KF_FISHING] = self:FindVariable("ShowFishingEffect")

	self.show_risingstar_icon = self:FindVariable("show_RisingStar_icon")
	self.rising_star_icon = self:FindVariable("rising_star_icon")

	self.rising_star_time = self:FindVariable("rising_star_time")

	self.act_effect_list_2 = {}
	self.act_effect_list_2[ACTIVITY_TYPE.CLASH_TERRITORY] = self:FindVariable("ShowClashTerritoryEffect2")


	for k,v in pairs(self.act_btn_time_list) do
		local activity_info= ActivityData.Instance:GetActivityStatuByType(k)
		if k == ACTIVITY_TYPE.KF_ONEYUANSNATCH then
			-- 一元夺宝限时特殊处理
			local act_info = ActivityData.Instance:GetCrossRandActivityStatusByType(ACTIVITY_TYPE.KF_ONEYUANSNATCH)
			activity_info = act_info
		end
		if activity_info then
			if self.act_effect_list[k]then
				self.act_effect_list[k]:SetValue(activity_info.status == ACTIVITY_STATUS.OPEN)
			end
			if activity_info.status == ACTIVITY_STATUS.STANDY then
				self:SetActivityBtnTime(k, activity_info.next_time)

			elseif activity_info.status == ACTIVITY_STATUS.OPEN and self.act_btn_time_list[k] then
				self.act_btn_time_list[k]:SetValue(Language.Activity.KaiQiZhong)
				if k == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2 then
					local next_time = activity_info.end_time
					local time = math.max(next_time - TimeCtrl.Instance:GetServerTime() , 0)
					self.act_btn_time_list[k]:SetValue(TimeUtil.FormatBySituation(time))
				end
			end
		end
	end
end

function MainUIView:SetActivityBtnTime(act_type, time)
	if self.act_btn_time_list and self.act_btn_time_list[act_type] ~= nil then
		time = math.max(time - TimeCtrl.Instance:GetServerTime(), 0)
		if time > 3600 then
			self.act_btn_time_list[act_type]:SetValue(TimeUtil.FormatSecond(time, 1))
		else
			self.act_btn_time_list[act_type]:SetValue(TimeUtil.FormatSecond(time, 2))
		end
		-- if self.act_btn_time_list2[act_type] then
		-- 	if ActivityData.IsOpenServerSpecAct(act_type) then
		-- 		self.act_btn_time_list[act_type]:SetValue(Language.Activity.FirstKaiQi)
		-- 		self.act_btn_time_list2[act_type]:SetValue(TimeUtil.FormatSecond(time, 3))
		-- 	else
		-- 		self.act_btn_time_list[act_type]:SetValue(TimeUtil.FormatSecond(time, 2))
		-- 		self.act_btn_time_list2[act_type]:SetValue("")
		-- 	end
		-- end
	end
end
local ActRemindNameT = {
	[ACTIVITY_TYPE.GONGCHENGZHAN] = MainUIData.RemindingName.CityCombat,
	[ACTIVITY_TYPE.WEEKBOSS] = MainUIData.RemindingName.WeekBoss,
	[ACTIVITY_TYPE.TOMB_EXPLORE] = MainUIData.RemindingName.TombExplore,
	[ACTIVITY_TYPE.KF_XIULUO_TOWER] = MainUIData.RemindingName.XiuLuoTower,
	[ACTIVITY_TYPE.KF_HOT_SPRING] = MainUIData.RemindingName.Cross_Hot_Spring,
	[ACTIVITY_TYPE.BIG_RICH] = MainUIData.RemindingName.Big_Rich,
	[ACTIVITY_TYPE.QUESTION_2] = MainUIData.RemindingName.Question,
	[ACTIVITY_TYPE.HUSONG] = MainUIData.RemindingName.Double_Escort,
	[ACTIVITY_TYPE.KF_ONEVONE] = MainUIData.RemindingName.Cross_One_Vs_One,
	[ACTIVITY_TYPE.CLASH_TERRITORY] = MainUIData.RemindingName.Clash_Territory,
	[ACTIVITY_TYPE.GUILDBATTLE] = MainUIData.RemindingName.Guild_Battle,
	[ACTIVITY_TYPE.TIANJIANGCAIBAO] = MainUIData.RemindingName.Fall_Money,
	[ACTIVITY_TYPE.QUNXIANLUANDOU] = MainUIData.RemindingName.Element_Battle,
	[ACTIVITY_TYPE.GUILD_SHILIAN] = MainUIData.RemindingName.GuildMijing,
	[ACTIVITY_TYPE.GUILD_BONFIRE] = MainUIData.RemindingName.GuildBonfire,
	[ACTIVITY_TYPE.GUILD_BOSS] = MainUIData.RemindingName.GuildBoss,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE] = MainUIData.RemindingName.SingleRebate,
	[ACTIVITY_TYPE.SHUIJING] = MainUIData.RemindingName.CrossCrystal,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE] = MainUIData.RemindingName.ExpRefine,
	[ACTIVITY_TYPE.MARRY_ME] = MainUIData.RemindingName.MarryMe,
	[ACTIVITY_TYPE.CHAOSWAR] = MainUIData.RemindingName.YiZhanDaoDi,
	[ACTIVITY_TYPE.RAND_LOTTERY_TREE] = MainUIData.RemindingName.ZhuanZhuanLe,
	[ACTIVITY_TYPE.RAND_JINYINTA] = MainUIData.RemindingName.JinYinTa,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT] = MainUIData.RemindingName.ZhenBaoGe,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP] = MainUIData.RemindingName.Huan_Zhuang_Shop,
	[ACTIVITY_TYPE.HUANGCHENGHUIZHAN] = MainUIData.RemindingName.ShuShan,
	[ACTIVITY_TYPE.RAND_DAILY_LOVE] = MainUIData.RemindingName.DailyLove,
	[ACTIVITY_TYPE.ACTIVITY_TYPE_WEDDING] = MainUIData.RemindingName.WeddingActivity,
	[ACTIVITY_TYPE.ACTIVITY_TYPE_TRIPLE_GUAJI] = MainUIData.RemindingName.TripleGuaji,
	[ACTIVITY_TYPE.JINGHUA_HUSONG] = MainUIData.RemindingName.JingHuaHuSong,
	[ACTIVITY_TYPE.GONGCHENG_WORSHIP] = MainUIData.RemindingName.Worship,
	[ACTIVITY_TYPE.KF_MINING] = MainUIData.RemindingName.Kf_Mining,
	[ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP] = MainUIData.RemindingName.SecretrShop,
	[ACTIVITY_TYPE.KF_FISHING] = MainUIData.RemindingName.Fishing,

	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE] = MainUIData.RemindingName.MountDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE] = MainUIData.RemindingName.WingDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW] = MainUIData.RemindingName.HaloDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW] = MainUIData.RemindingName.FootDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW] = MainUIData.RemindingName.FightMountDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW] = MainUIData.RemindingName.ShenGongDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW] = MainUIData.RemindingName.ShenYiDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE] = MainUIData.RemindingName.YaoShiDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE] = MainUIData.RemindingName.TouShiDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE] = MainUIData.RemindingName.QiLinBiDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2] = MainUIData.RemindingName.LoopCharge2,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY] = MainUIData.RemindingName.RechargeCapacity,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2] = MainUIData.RemindingName.SingleCharge2,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3] = MainUIData.RemindingName.SingleCharge3,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_INCREASE_CAPABILITY] = MainUIData.RemindingName.IncreaseCapability,
	[ACTIVITY_TYPE.RAND_SINGLE_CHARGE] = MainUIData.RemindingName.DanBiChongZhi,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE] = MainUIData.RemindingName.MaskDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE] = MainUIData.RemindingName.XianBaoDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE] = MainUIData.RemindingName.LingZhuDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE] = MainUIData.RemindingName.LingChongDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE] = MainUIData.RemindingName.LingGongDegree,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE] = MainUIData.RemindingName.LingQiDegree,
	[ACTIVITY_TYPE.CROSS_SHUIJING] = MainUIData.RemindingName.TianShenGrave,
	[ACTIVITY_TYPE.KF_ONEYUANSNATCH] = MainUIData.RemindingName.OnYuan,
}
function MainUIView:ActivityChangeCallBack(activity_type, status, next_time, open_type)

	self:SetJingcaiActImg()
	if self.is_open_kaifuact and activity_type ==  ACTIVITY_TYPE.OPEN_SERVER then
		self.is_open_kaifuact:SetValue(status == ACTIVITY_STATUS.OPEN)
	end
	RemindManager.Instance:Fire(RemindName.ExpRefine)

	local act_cfg = ActivityData.Instance:GetActivityConfig(activity_type)

	if self.show_activity_hall_icon then
		local hall_act = ActivityData.Instance:GetActivityHallDatalist()
		local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
		self.show_activity_hall_icon:SetValue(#hall_act > 0 and main_role_lv >= GameEnum.ACT_HALL_ICON_LEVEL)
		RemindManager.Instance:Fire(RemindName.ACTIVITY_JUAN_ZHOU)
	end

	if self.show_festival_icon and OpenFunData.Instance:CheckIsHide("festivalview") then
		local num = FestivalActivityData.Instance:GetActivityOpenNum()
		self.show_festival_icon:SetValue(num > 0)
	end

	if self.show_online_icon then
		local num = ActivityOnLineData.Instance:GetActivityOpenNum()
		self.show_online_icon:SetValue(num > 0)
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE then
		if self.tmp_activity_list[activity_type] == nil then
			self.tmp_activity_list[activity_type] = {activity_type = activity_type}
		end
		self:Flush("return_reward_icon")
	end

    --合服仙盟战和攻城战
	if activity_type == ACTIVITY_TYPE.GUILDBATTLE then
	    HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	end

	if act_cfg and act_cfg.is_inscroll == 1 and not Ignore_Activity[activity_type] then return end
	if status ~= ACTIVITY_STATUS.CLOSE then
		local level = PlayerData.Instance.role_vo.level
		if (act_cfg and act_cfg.min_level > level ) then
			self.tmp_activity_list[activity_type] = {activity_type = activity_type, status = status, next_time = next_time, open_type = open_type}
			return
		elseif self.tmp_activity_list[activity_type] then
			self.tmp_activity_list[activity_type] = nil
		end

		--进阶返利活动特殊处理
		if not KaiFuDegreeRewardsData.IsCanOpenDegreeRewards(activity_type) then
			self.degree_activity_list[activity_type] = {activity_type = activity_type, status = status, next_time = next_time, open_type = open_type}
			return
		elseif self.degree_activity_list[activity_type] then
			self.degree_activity_list[activity_type] = nil
		end
	else
		if self.tmp_activity_list[activity_type] then
			self.tmp_activity_list[activity_type] = nil
		end

		if self.degree_activity_list[activity_type] then
			self.degree_activity_list[activity_type] = nil
		end
	end

	if activity_type == ACTIVITY_TYPE.MARRY_ME then
		if GameVoManager.Instance:GetMainRoleVo().lover_uid <= 0 then
			RemindManager.Instance:Fire(RemindName.MarryMe)
		end
	elseif activity_type == ACTIVITY_TYPE.ACTIVITY_TYPE_WEDDING then  --婚礼准备状态请求婚礼信息
		MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_GET_WEDDING_INFO)
	end
	if CollectiveGoalsData.Instance:IsGoalsAct(activity_type) then
		self:ChangeCollectiveGoalsImage()
	end

	if ActRemindNameT[activity_type] then
		self:SetButtonVisible(ActRemindNameT[activity_type], status ~= ACTIVITY_STATUS.CLOSE)
		if activity_type == ACTIVITY_TYPE.MARRY_ME then
			self:SetButtonVisible(ActRemindNameT[activity_type], status ~= ACTIVITY_STATUS.CLOSE and GameVoManager.Instance:GetMainRoleVo().lover_uid <= 0)
		end
		if activity_type == ACTIVITY_TYPE.RAND_DAILY_LOVE then 	--每日一爱
			self:SetButtonVisible(ActRemindNameT[activity_type], status ~= ACTIVITY_STATUS.CLOSE and OpenFunData.Instance:CheckIsHide("kaifuactivityview"))
		end
		if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE then 	--单笔返利
			self:CheckSingleRebateIcon()
		end
	end
	if status == ACTIVITY_STATUS.STANDY and nil == self.act_time_countdown then
		self:RemoveActTimeCountDown()
		self.act_time_countdown = GlobalTimerQuest:AddRunQuest(function()
			if nil == self.act_btn_time_list then
				return
			end
			local has_act_open = false
			local activity_info = nil
			for k,v in pairs(self.act_btn_time_list) do
				activity_info = ActivityData.Instance:GetActivityStatuByType(k)
				if activity_info and activity_info.status == ACTIVITY_STATUS.STANDY then
					has_act_open = true
					self:SetActivityBtnTime(k, activity_info.next_time)
					if self.act_effect_list[k]then
						self.act_effect_list[k]:SetValue(false)
					end
				end
			end
			if has_act_open == false then
				self:RemoveActTimeCountDown()
			end
		end, 1)
	end

	if status == ACTIVITY_STATUS.OPEN then
		if self.act_btn_time_list and self.act_btn_time_list[activity_type] then
			self.act_btn_time_list[activity_type]:SetValue(Language.Activity.KaiQiZhong)
			if self.act_effect_list[activity_type]then
				self.act_effect_list[activity_type]:SetValue(true)
			end
		end

		if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2 and nil == self.loop_charge_count_down then
			self.loop_charge_count_down = GlobalTimerQuest:AddRunQuest(function()
			if nil == self.act_btn_time_list then
				return
			end
			local has_act_open = false
			local activity_info = ActivityData.Instance:GetActivityStatuByType(activity_type)
			if activity_info and activity_info.status == ACTIVITY_STATUS.OPEN then
				has_act_open = true
				local next_time = activity_info.end_time
				local time = math.max(next_time - TimeCtrl.Instance:GetServerTime() , 0)
				if self.act_btn_time_list[activity_type] then
					self.act_btn_time_list[activity_type]:SetValue(TimeUtil.FormatBySituation(time))
				end
			end
			if has_act_open == false then
				if self.loop_charge_count_down then
					GlobalTimerQuest:CancelQuest(self.loop_charge_count_down)
					self.loop_charge_count_down = nil
				end
			end
			end, 1)
		end

		self:SetAllSinglechargeEff(activity_type)

		-- if self.act_btn_time_list2[activity_type] then
		-- 	if ActivityData.IsOpenServerSpecAct(activity_type) then
		-- 		self.act_btn_time_list[activity_type]:SetValue(Language.Activity.FirstKaiQi)
		-- 		self.act_btn_time_list2[activity_type]:SetValue(Language.Activity.KaiQiZhong)
		-- 	else
		-- 		self.act_btn_time_list[activity_type]:SetValue(Language.Activity.KaiQiZhong)
		-- 		self.act_btn_time_list2[activity_type]:SetValue("")
		-- 	end
		-- end
	end

	if activity_type == ACTIVITY_TYPE.KF_GUILDBATTLE and status == ACTIVITY_STATUS.CLOSE and not KuafuGuildBattleData.Instance:GetTripleStatu() then
		self.act_btn_time_list[activity_type]:SetValue("")
		if self.act_effect_list[activity_type]then
			self.act_effect_list[activity_type]:SetValue(false)
		end
	end

	if not IS_ON_CROSSSERVER and status == ACTIVITY_STATUS.OPEN and act_cfg and act_cfg.open_panel == 1 and SceneType.Common == Scene.Instance:GetSceneType() then
		if activity_type ~= ACTIVITY_TYPE.GUILD_SHILIAN and
		activity_type ~= ACTIVITY_TYPE.GUILD_BOSS then
			self:OpenActivityView(activity_type)
		end
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA then
		RemindManager.Instance:Fire(RemindName.JuBaoPen)
		self:CheckJuBaoPenIcon()
	end
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE and self.show_recharge_icon_1 then
		self.show_recharge_icon_1:SetValue(status == ACTIVITY_STATUS.OPEN and KaifuActivityData.Instance:IsShowLeiJiRechargeIcon())
	end

	if activity_type == ACTIVITY_TYPE.HUANGCHENGHUIZHAN and status == ACTIVITY_STATUS.CLOSE then
		ActivityCtrl.Instance:CloseShuShanFightView()
	end

	if activity_type == ACTIVITY_TYPE.GONGCHENG_WORSHIP and ACTIVITY_STATUS.CLOSE == status then
		ViewManager.Instance:Close(ViewName.WorshipView)
	end

	self:OnFlushActPreviewIcon()
	self:OnFlushActPreviewTimer()
	if self.chat_view then
		self.chat_view:FlushActivityPre()
	end
end

function MainUIView:CheckJuBaoPenIcon()
	if self.show_jubaopen_icon then
		self.show_jubaopen_icon:SetValue(JuBaoPenData.Instance:CheckIsShow())
	end
end

--每日一爱
function MainUIView:CheckDailyLoveIcon()
	if DailyChargeData.Instance:GetChongZhiInfo().today_recharge then
		if DailyChargeData.Instance:GetChongZhiInfo().today_recharge > 0 then
			self:SetButtonVisible(ActRemindNameT[ACTIVITY_TYPE.RAND_DAILY_LOVE], false) 	--如果当天充值了，则不显示每日一爱图标
		end
	end
	if KaifuActivityData.Instance then
		if KaifuActivityData.Instance.daily_love_is_open == true then
			self:SetButtonVisible(ActRemindNameT[ACTIVITY_TYPE.RAND_DAILY_LOVE], false)		--如果当前登录已经打开过每日一爱面板，则隐藏图标
		end
	end
end

--单笔返利
function MainUIView:CheckSingleRebateIcon()
	if self.show_single_rebate_icon then
		local result = true
		if not SingleRebateData.Instance:IsFunOpen() then
			result = false
		end
		if DailyChargeData.Instance:GetChongZhiInfo().today_recharge then
			if DailyChargeData.Instance:GetChongZhiInfo().today_recharge > 0 then
				result = false 																	--如果当天充值了，则不显示单笔返利图标
			end
		end
		if SingleRebateData.Instance then
			if SingleRebateData.Instance.single_rebate_is_open == true then
				result = false 																	--如果当前登录已经打开过单笔返利面板，则隐藏图标
			end
		end
		self.show_single_rebate_icon:SetValue(result)
	end
end

--红名提醒面板
function MainUIView:CheckRedNameIcon()
	if PlayerData.Instance:GetAttr("evil") >= 100 and RedNameData.Instance:GetNoMoreOpen() == false then
		self:SetButtonVisible(MainUIData.RemindingName.RedName, true)
	else
		self:SetButtonVisible(MainUIData.RemindingName.RedName, false)
	end
end

function MainUIView:RemoveActTimeCountDown()
	if self.act_time_countdown then
		GlobalTimerQuest:CancelQuest(self.act_time_countdown)
		self.act_time_countdown = nil
	end
end

-- 获取红点的Variable
function MainUIView:GetVariable()
	self.red_point_list[RemindName.PlayerView] = self:FindVariable("Player")
	self.red_point_list[RemindName.Baoju] = self:FindVariable("Baoju")
	self.red_point_list[RemindName.Forge] = self:FindVariable("Forge")
	self.red_point_list[RemindName.Advance] = self:FindVariable("Advance")
	self.red_point_list[RemindName.Goddess_Ground] = self:FindVariable("Goddress")
	self.red_point_list[RemindName.Guild] = self:FindVariable("Guild")
	self.red_point_list[RemindName.Clothespress] = self:FindVariable("Clothespress")
	self.red_point_list[RemindName.Scoiety] = self:FindVariable("Scoiety")
	self.red_point_list[RemindName.ScoietyOneKeyFriend] = self:FindVariable("ShowScoietyEffect")
	self.red_point_list[RemindName.Marry] = self:FindVariable("Marriage")
	-- self.red_point_list[RemindName.Rank] = self:FindVariable("Rank")
	self.red_point_list[RemindName.FuBenMulti] = self:FindVariable("FuBenMulti")
	self.red_point_list[RemindName.FuBenSingle] = self:FindVariable("FuBenSingle")
	self.red_point_list[RemindName.BattleField] = self:FindVariable("BattleField")
	self.red_point_list[RemindName.ActivityHall] = self:FindVariable("ActivityHall")
	self.red_point_list[RemindName.XunBaoGroud] = self:FindVariable("TreasureHunt")
	self.red_point_list[RemindName.JingCai_Act] = self:FindVariable("NewServer")
	self.red_point_list[RemindName.Welfare] = self:FindVariable("Welfare")
	self.red_point_list[RemindName.Echange] = self:FindVariable("Echange")
	self.red_point_list[RemindName.Auto] = self:FindVariable("Auto")
	self.red_point_list[RemindName.PlayerPackage] = self:FindVariable("Package")
	self.red_point_list[RemindName.RechargeGroud] = self:FindVariable("Deposit")
	self.red_point_list[RemindName.Vip] = self:FindVariable("Vip")
	self.red_point_list[RemindName.Spirit] = self:FindVariable("Spirit")
	self.red_point_list[RemindName.DailyCharge] = self:FindVariable("Daily_Charge")
	self.red_point_list[RemindName.FirstCharge] = self:FindVariable("First_Charge")
	self.red_point_list[RemindName.Invest] = self:FindVariable("Invest")
	self.red_point_list[RemindName.KfLeichong] = self:FindVariable("Show_Leiji_ChongZhi_Red")
	self.red_point_list[RemindName.Rebate] = self:FindVariable("Rebate")
	self.red_point_list[RemindName.HuanJing_XunBao] = self:FindVariable("HuanJing_XunBao")
	self.red_point_list[RemindName.SevenLogin] = self:FindVariable("Seven_Login_Redpt")
	self.red_point_list[RemindName.Reincarnation] = self:FindVariable("Reincarnation_Redpt")
	self.red_point_list[RemindName.MoLongMiBao] = self:FindVariable("MolongMibao_redpt")
	self.red_point_list[RemindName.ActHongBao] = self:FindVariable("GetActHongBao")
	self.red_point_list[RemindName.ExpRefine] = self:FindVariable("ShowExpRefine_Redpt")
	-- self.red_point_list[RemindName.BiPin] = self:FindVariable("ShowBiPin_Redpt")
	self.red_point_list[RemindName.zhuli] = self:FindVariable("ShowZhuLi_Redpt")
	self.red_point_list[RemindName.Boss] = self:FindVariable("Show_boss_redpoint")
	self.red_point_list[RemindName.PersonalGoals] = self:FindVariable("Show_personal_goals_redpoint")
	self.red_point_list[RemindName.CollectiveGoals] = self:FindVariable("Show_collective_goals_redpoint")
	self.red_point_list[RemindName.GoldMember] = self:FindVariable("MemberRepdt")
	self.red_point_list[RemindName.HpBag] = self:FindVariable("ShowHpBagRedPoint")
	self.red_point_list[RemindName.Arena] = self:FindVariable("ShowArenaRedPoint")
	self.red_point_list[RemindName.MarryMe] = self:FindVariable("ShowWantMarryRemind")
	self.red_point_list[RemindName.GuildChat] = self:FindVariable("ShowGuildChat")
	self.red_point_list[RemindName.NoGuild] = self:FindVariable("ShowGuildEffect")
	self.red_point_list[RemindName.JuBaoPen] = self:FindVariable("JuBaoPenReminder")
	self.red_point_list[RemindName.DailyLeiJi] = self:FindVariable("DailyLeiJi")
	self.red_point_list[RemindName.ZeroGift] = self:FindVariable("ShowZeroGiftRemind")
	self.red_point_list[RemindName.Mining] = self:FindVariable("ShowMiningRedPoint")
	self.red_point_list[RemindName.YuLe] = self:FindVariable("YuLeRemind")
	self.red_point_list[RemindName.FriendExpBottleView] = self:FindVariable("FriendExpBottleVieweRemind")
	self.red_point_list[RemindName.JINYINTA] = self:FindVariable("ShowJinYinTaRedPoint")
	self.red_point_list[RemindName.ZhenBaoge] = self:FindVariable("ShowZhenBaoGeRedPoint")
	self.red_point_list[RemindName.ZHUANZHUANLE] = self:FindVariable("zhuanzhuanle_red_point")
	self.red_point_list[RemindName.ACTIVITY_JUAN_ZHOU] = self:FindVariable("ShowActivityHallRedPoint")
	self.red_point_list[RemindName.ShowKfBattleGroup] = self:FindVariable("ShowKFBattleRemind")
	self.red_point_list[RemindName.ShowKfBattlePreRemind] = self:FindVariable("ShowKfBattlePreRemind")
	self.red_point_list[RemindName.SecondCharge] = self:FindVariable("Second_Charge")
	self.red_point_list[RemindName.ThirdCharge] = self:FindVariable("Third_Charge")
	self.red_point_list[RemindName.ShowHuanZhuangShopPoint] = self:FindVariable("huanzhuangshop_red_point")
	self.red_point_list[RemindName.Setting] = self:FindVariable("Setting")
	self.red_point_list[RemindName.BeStrength] = self:FindVariable("ShowStrengthRedPoint")
	self.red_point_list[RemindName.ChargeGroup] = self:FindVariable("ChargeGroupRemind")
	self.red_point_list[RemindName.LianhunGroud] = self:FindVariable("ShowLianhunBtnRed")
	self.red_point_list[RemindName.FestivalActivity] = self:FindVariable("ShowFestivalRedPoint")
	self.red_point_list[RemindName.OpenFestivalPanel] = self:FindVariable("ShowFestivalEffect")
	self.red_point_list[RemindName.RedEquip] = self:FindVariable("ShowRedEquipPoint")

	self.red_point_list[RemindName.Shop] = self:FindVariable("Shop")
	self.red_point_list[RemindName.Market] = self:FindVariable("Market")
	self.red_point_list[RemindName.Compose] = self:FindVariable("Compose")
	self.red_point_list[RemindName.LoopCharge] = self:FindVariable("LoopChargeRed")
	self.red_point_list[RemindName.SecondChargeFrame] = self:FindVariable("ChargeRedpoint")
	self.red_point_list[RemindName.Arena] = self:FindVariable("ShowJingJiRemind")
	self.red_point_list[RemindName.TitleShopPoint] = self:FindVariable("NiChongWoSongRed")
	self.red_point_list[RemindName.TripleGuaji] = self:FindVariable("ShowTripleRed")
	self.red_point_list[RemindName.Xianzunka] = self:FindVariable("XianzunkaRepdt")
	self.red_point_list[RemindName.GodTemple] = self:FindVariable("GodTempleRemind")

	-- 结婚组红点
	self.red_point_list[RemindName.MarryGroup] = self:FindVariable("MarryGroupRed")

	--仙域组的红点
	self.red_point_list[RemindName.XianYu] = self:FindVariable("XianYu_Remind")
	self.red_point_list[RemindName.RisingStar] = self:FindVariable("ShowRisingStarRemind")

	self.red_point_list[RemindName.SecretrShop] = self:FindVariable("ShenMiShopShopRedPoint")

	self.red_point_list[RemindName.MountDegree] = self:FindVariable("MountDegreeRed")
	self.red_point_list[RemindName.WingDegree] = self:FindVariable("WingDegreeRed")
	self.red_point_list[RemindName.HaloDegree] = self:FindVariable("HaloDegreeRed")
	self.red_point_list[RemindName.FootDegree] = self:FindVariable("FootDegreeRed")
	self.red_point_list[RemindName.FightMountDegree] = self:FindVariable("FightMountDegreeRed")
	self.red_point_list[RemindName.ShenGongDegree] = self:FindVariable("ShenGongDegreeRed")
	self.red_point_list[RemindName.ShenYiDegree] = self:FindVariable("ShenYiDegreeRed")
	self.red_point_list[RemindName.YaoShiDegree] = self:FindVariable("YaoShiDegreeRed")
	self.red_point_list[RemindName.TouShiDegree] = self:FindVariable("TouShiDegreeRed")
	self.red_point_list[RemindName.QiLinBiDegree] = self:FindVariable("QiLinBiDegreeRed")
	self.red_point_list[RemindName.MaskDegree] = self:FindVariable("MaskDegreeRed")
	self.red_point_list[RemindName.XianBaoDegree] = self:FindVariable("XianBaoDegreeRed")
	self.red_point_list[RemindName.LingZhuDegree] = self:FindVariable("LingZhuDegreeRed")
	self.red_point_list[RemindName.LingChongDegree] = self:FindVariable("LingChongDegreeRed")
	self.red_point_list[RemindName.LingGongDegree] = self:FindVariable("LingGongDegreeRed")
	self.red_point_list[RemindName.LingQiDegree] = self:FindVariable("LingQiDegreeRed")
	self.red_point_list[RemindName.OnLineActivity] = self:FindVariable("ShowOnLineRedPoint")

	self:ClearRedPoint()
end

-- 清空红点
function MainUIView:ClearRedPoint()
	for _, v in pairs(self.red_point_list) do
		v:SetValue(false)
	end
end

-- 设置全部红点的状态
function MainUIView:SetAllRedPoint()
	if not self:IsLoaded() then
		return
	end
	for k,v in pairs(self.red_point_list) do
		v:SetValue(RemindManager.Instance:GetRemind(k) > 0)
	end

	self:GetActivityHallImageAnimator(RemindManager.Instance:GetRemind(RemindName.ACTIVITY_JUAN_ZHOU))

	TreasureCtrl.Instance:SendChestShopItemListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
	YuLeCtrl.Instance:SendMoveChessFreeInfo(0)
	self:CheckMenuRedPoint()
end

-- 改变红点
function MainUIView:ChangeRedPoint(index, state)
	if self.red_point_list[index] then
		self.red_point_list[index]:SetValue(state)
	end
	if index == RemindName.ACTIVITY_JUAN_ZHOU then
		self:GetActivityHallImageAnimator(state)
	end
end

-- 提醒改变
function MainUIView:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.FestivalActivity or remind_name == RemindName.OpenFestivalPanel then
		self:SetFestivalAnimator(remind_name, num)
	end

	if self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
	if remind_name == RemindName.BeStrength then
		self:OnFlushActPreviewIcon()
	elseif remind_name == RemindName.ACTIVITY_JUAN_ZHOU then
		self:GetActivityHallImageAnimator(num)
	end
end

-- 设置限时活动图标抖动
function MainUIView:GetActivityHallImageAnimator(num)
	if self.button_activity_hall_icon then
		if num > 0 then
			self.button_activity_hall_icon.animator:SetBool("Shake", true)
		else
			self.button_activity_hall_icon.animator:SetBool("Shake", false)
		end
	end
end

-- 设置5个单笔充值活动图标抖动和特效显示
function MainUIView:SetAllSinglechargeEff(activity_type)
	if self.singlecharges_t then
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		if activity_type then
			local act_t = self.singlecharges_t[activity_type]
			if act_t then
				local bendi_day = UnityEngine.PlayerPrefs.GetInt("activity_hall_day" .. activity_type)
				if act_t.img.gameObject.activeSelf then
					act_t.img.animator:SetBool("Shake", true)
					if activity_type == ACTIVITY_TYPE.KF_ONEYUANSNATCH then
				    end
				end


				act_t.show_eff:SetValue(bendi_day ~= cur_day)
			end
		else
			for k,v in pairs(self.singlecharges_t) do
				local bendi_day = UnityEngine.PlayerPrefs.GetInt("activity_hall_day" .. k)
				if v.img.gameObject.activeSelf then
					v.img.animator:SetBool("Shake", bendi_day ~= cur_day)
				end
				v.show_eff:SetValue(bendi_day ~= cur_day)
			end
		end
	end
end

--进入场景
function MainUIView:OnEnterScene()
	self:ChangeMonsterViewState()
	self:Flush("on_line")
	self:Flush("flush_open_trailer")
end

-- 主界面喇叭
function MainUIView:OpenLevelLimitHorn()
	if self.chat_view then
		self.chat_view:OpenLevelLimitHorn()
	end
end

function MainUIView:ChangeMonsterViewState()
	--加个0.1秒的延迟防止主界面没显示的情况下去设置参数
	GlobalTimerQuest:AddDelayTimer(function()
		local scene_id = Scene.Instance:GetSceneId()
		self:IsShowOrHideMonsterButton(YewaiGuajiData.Instance:IsGuaJiScene(scene_id))
	end, 0.1)
end

function MainUIView:PlayerBtnVisible(state)
	state = tonumber(state)
	self.player_button_ani_state = state
	GlobalEventSystem:Fire(MainUIEventType.PLAYER_BUTTON_VISIBLE, state)
end

function MainUIView:GetPlayerButtonAniState()
	return self.player_button_ani_state
end

function MainUIView:OnFlushActPreviewIcon()
	local has_streng_remind = RemindManager.Instance:GetRemind(RemindName.BeStrength) > 0
	if self.button_strength then
		self.button_strength:SetActive(has_streng_remind)
	end

	if has_streng_remind then return end

	local cfg = ActivityData.Instance:GetNextActivityOpenInfo()
	if nil ~= cfg then
		if self.button_act_preview and cfg.act_id ~= self.cur_preview_act_id then
			-- self.show_act_preview_effect:SetValue(true)Invest
			self.cur_preview_act_id = cfg.act_id
		end

		if self.button_act_preview then
			self.button_act_preview:SetActive(false)  --true 屏蔽左上角活动提示
		end
		if self.button_preview_img and cfg.icon ~= "" then
			self.button_preview_img:SetAsset(ResPath.GetMainUI(cfg.icon))
			self.preview_img_text:SetAsset(ResPath.GetMainUI(cfg.icon .. "_text"))
		end
	else
		if self.button_act_preview then
			self.button_act_preview:SetActive(false)
		end
	end
end

function MainUIView:OpenLoopCharge()
	ViewManager.Instance:Open(ViewName.LoopChargeView)
end

function MainUIView:OpenNiChongWoSong()
	ViewManager.Instance:Open(ViewName.TitleShopView)
end

function MainUIView:OnFlushActPreviewTimer()
	if nil == self.act_preview_time_time_quest then
		local timer_func = function()
			self:OnFlushActPreviewIcon()
			if self.act_preview_time and self.button_act_preview and self.button_act_preview.gameObject.activeSelf then
				local time_str = ActivityData.Instance:GetNextActivityCountDownStr()
				self.act_preview_time:SetValue(time_str)
			end
		end
		self.act_preview_time_time_quest = GlobalTimerQuest:AddRunQuest(timer_func, 1)
	end
end

function MainUIView:OnTaskChange(task_event_type, task_id)
	if task_event_type == "accepted_add" then
		self:OnOpenTrigger(OPEN_FUN_TRIGGER_TYPE.ACHIEVE_TASK, task_id)
	end

	if task_event_type == "completed_list" then
		self:InitOpenFunctionIcon()
		for k,v in pairs(self.tmp_activity_list) do
			self:ActivityChangeCallBack(v.activity_type, v.status, v.next_time, v.open_type)
		end

		for k,v in pairs(self.degree_activity_list) do
			self:ActivityChangeCallBack(v.activity_type, v.status, v.next_time, v.open_type)
		end
		return
	end
	if task_event_type == "completed_add" then
		self:OnOpenTrigger(OPEN_FUN_TRIGGER_TYPE.SUBMIT_TASK, task_id)
	end
end

function MainUIView:OnPersonGoalChange(value, flag)
	if flag then
		self:OnOpenTrigger(OPEN_FUN_TRIGGER_TYPE.PERSON_CHAPTER, value)
	end
	if value then
		local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
		if self.show_CollectGoals_icon then
			self.show_CollectGoals_icon:SetValue(server_open_day <= 4 and OpenFunData.Instance:CheckIsHide("CollectGoals"))
		end
	end
end

function MainUIView:GetPackageBtn()
	return self.button_package
end

function MainUIView:OnOpenTrigger(trigger_type, value)
	if self.shrink_button == nil then return end

	self:InitOpenFunctionIcon()
	local open_fun_data = OpenFunData.Instance
	local single_fun_cfg_list = open_fun_data:OnTheTrigger(trigger_type, value)
	if single_fun_cfg_list == nil then
		return
	end

	for k,v in pairs(single_fun_cfg_list) do
		GlobalEventSystem:Fire(OpenFunEventType.OPEN_TRIGGER, v.name)
		if v.open_type == FunOpenType.Fly then
			local view_manager = ViewManager.Instance
			view_manager:CloseAll()
			if view_manager:IsOpen(ViewName.TaskDialog) then
				view_manager:Close(ViewName.TaskDialog)
			end
			GlobalEventSystem:Fire(FinishedOpenFun, true)

			self.fight_state_button.toggle.isOn = false
			self.MenuIconToggle.isOn = true

			self:CalToJuggeIconActive(v)
		elseif v.open_type == FunOpenType.OpenModel then
			ViewManager.Instance:CloseAll()
			GlobalEventSystem:Fire(FinishedOpenFun, true)
			TipsCtrl.Instance:ShowOpenFunctionView(v.name, v.res_type)

		elseif v.open_type == FunOpenType.OpenView then
			if v.name == ViewName.TempMount then
				ViewManager.Instance:Open(ViewName.TempMount)
			elseif v.name == ViewName.TempWing then
				ViewManager.Instance:Open(ViewName.TempWing)
			elseif v.name == ViewName.OpenFirstcharge then
			-- self.delay_open_view = GlobalTimerQuest:AddDelayTimer(function()
				local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
				if  history_recharge < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 then
					ViewManager.Instance:Open(ViewName.SecondChargeView)
					FirstChargeCtrl.Instance:SetAutoCloseViewTime(10, true)
				end
				-- self.delay_open_view = nil
			-- end, 1)
			end
		end
	end

	--功能开启时需要判断的红点
	RemindManager.Instance:Fire(RemindName.RuneTreasure)

	-- 刷新星座遗迹特效显示
	if nil ~= self.show_shen_ge_effect then
		self.show_shen_ge_effect:SetValue(ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI)
			and OpenFunData.Instance:CheckIsHide("shengxiao_uplevel"))
	end
end

function MainUIView:FlyToDict(cfg)
	self:InitOpenFunctionIcon()
	local chat_view = ChatCtrl.Instance:GetView()
	if chat_view:IsOpen() then
		chat_view:Close()
	end
	if not self.MenuIconToggle.isOn then
		 self.MenuIconToggle.isOn = true
	end

	if not self.shrink_button.toggle.isOn then
		self.shrink_button.toggle.isOn = true
	end
	self:CalToJuggeIconActive(cfg)
end

function MainUIView:CalToJuggeIconActive(cfg)
	local name = OpenFunData.Instance:GetName(cfg.open_param)
	--组合图标特殊处理一下
	if name == "rune" then
		--这个xianyu就是仙域图标
		name = "xianyu"
	end
	local target_obj = self["button_"..name]

	if target_obj then
		TipsCtrl.Instance:ShowOpenFunFlyView(cfg, target_obj)
	end
end

--计算RMB购买时间
function MainUIView:SetSecretrShopTime()
	if self.secretr_shop_down then
		CountDown.Instance:RemoveCountDown(self.secretr_shop_down)
		self.secretr_shop_down = nil
	end

	--计算时间函数
	local function calc_times(times)
		local time_tbl = TimeUtil.Format2TableDHMS(times)
		local time_des = ""
		if time_tbl.day > 0 then
			--大于1天的只显示天数和时间
			time_des = string.format("%s%s%s%s", time_tbl.day, Language.Common.TimeList.d, time_tbl.hour, Language.Common.TimeList.h)
		else
			--小于一天的就显示三位时间
			time_des = TimeUtil.FormatSecond(times)
		end
		self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP]:SetValue(time_des)
	end

	--计时函数
	local function time_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP]:SetValue("00:00")
			CountDown.Instance:RemoveCountDown(self.secretr_shop_down)
			self.secretr_shop_down = nil
		end

		--先计算出剩余时间秒数
		local times = total_time - math.floor(elapse_time)
		calc_times(times)
	end


	local left_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP)
	--不足1s按1s算（向上取整）
	left_time = math.ceil(left_time)
	if left_time > 0 then
		--活动进行中
		calc_times(left_time)
		self.secretr_shop_down = CountDown.Instance:AddCountDown(left_time, 1, time_func)
	else
		--活动已结束
		self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP]:SetValue("00:00")
	end
end

function MainUIView:CameraModeChange(param_1, param_2)
	if param_2 then
		if self.camera_mode then
			self.camera_mode:SetValue(param_2 + 1)
		end
	else
		local guide_flag_list = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_KEY_FLAG)
		local flag = guide_flag_list.item_id or 0
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo and main_role_vo.task_appearn > 0 then
			flag = self.camera_mode:GetInteger() - 1
		end
		if self.camera_mode then
			self.camera_mode:SetValue(flag + 1)
		end
	end

end

function MainUIView:OnClickCameraMode()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 抱花任务时不能切换镜头
	if main_role_vo.task_appearn == CHANGE_MODE_TASK_TYPE.GATHER or main_role_vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
		return
	end
	local flag = self.camera_mode:GetInteger()
	if flag >= GameEnum.MAX_CAMERA_MODE then
		flag = 0
	end
	Scene.Instance:SetCameraMode(flag)
	self.camera_mode:SetValue(flag + 1)
	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.CAMERA_KEY_FLAG, flag)
	SettingData.Instance:SetSettingDataListByKey(HOT_KEY.CAMERA_KEY_FLAG, flag)
end

function MainUIView:OnClickPhotoShot()
	local ui_camera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	if ui_camera then
		ui_camera.enabled = false
		local path = UnityEngine.Application.persistentDataPath
		path = string.format("%s%s.jpg", path, os.time())
		local callback = function(result, new_path)
			if true == result then
				ScreenShotCtrl.Instance:OpenScreenView(new_path, function() ui_camera.enabled = true end)
			else
				ui_camera.enabled = true
			end
		end
		UtilU3d.Screenshot(path, callback)
	end
end

function MainUIView:SetShrinkToggle(isOn)
	if isOn then
		self.shrink_button.toggle.isOn = isOn
	else
		if self.shrink_button.toggle.isOn == false then
			self.shrink_button.toggle.isOn = true
		end
	end
end

function MainUIView:StopOpenSizeTween()
	if self.fun_open_size_tween then
		self.fun_open_size_tween:Kill()
		self.fun_open_size_tween = nil
	end
end

function MainUIView:MoveMainIcon(cfg)
	self:StopOpenSizeTween()
	local open_fun_data = OpenFunData.Instance
	local the_button = self["button_"..open_fun_data:GetName(cfg.open_param)]
	if not the_button then
		return
	end
	local timer = 0
	local width = 0
	if cfg.with_param == OPEN_FLY_DICT_TYPE.UP then
		width = 70
	else
		width = 90
	end

	self.fun_open_size_tween = the_button.rect:DOSizeDelta(Vector2(width, width), 0.5)
	self.fun_open_size_tween:SetEase(DG.Tweening.Ease.Linear)
	self.fun_open_size_tween:SetUpdate(true)
	self.fun_open_size_tween:OnComplete(function()
		self.fun_open_size_tween = nil
	end)
end

function MainUIView:OnShowOrHideShrinkBtn(state)
	if not self:IsRendering() then return end
	self.shrink_button.toggle.isOn = state
	if state == false then
		self:MainRoleLevelChange()
	end
end

function MainUIView:ShowEXPBottleText(num)
	if self.delay_text_timer then
		GlobalTimerQuest:CancelQuest(self.delay_text_timer)
		self.delay_text_timer = nil
	end
	if self.button_exp_bottle and self.button_exp_bottle.gameObject.activeSelf then
		self.show_exp_bottle_text:SetValue(true)
		self.need_friend_num:SetValue(num)
		self.delay_text_timer=GlobalTimerQuest:AddDelayTimer(function ()
			self.show_exp_bottle_text:SetValue(false)
		end,3)
	end
end

function MainUIView:CheckShowFightMount()
	if self.joystick_view then
		self.joystick_view:CheckShowFightMount()
	end
end

function MainUIView:CloseExpBottleText()
--	self.show_exp_bottle_text:SetValue(false)
end

function MainUIView:CheckBtnGroup(name, is_show)
	for group_name, group_list in pairs(GroupBtnList) do
		local show_varibile = self["show_"..group_name.."_icon"]
		if nil ~= show_varibile then
			if group_list[name] then
				group_list[name] = is_show and 1 or 0

				local show_group_state = false
				for _, v in pairs(group_list) do
					if v == 1 then
						--组内有其中一个成员则显示组
						show_group_state = true
						break
					end
				end
				show_varibile:SetValue(show_group_state)
			end
		end

	end
end

--初始化图标
function MainUIView:InitOpenFunctionIcon()
	self:Flush("check_show_mount")
	self:Flush("check_show_fight_mount")

	local open_fun_data = OpenFunData.Instance
	for k,v in pairs(open_fun_data:OpenFunCfg()) do
		local is_show = open_fun_data:CheckIsHide(v.name)
		open_fun_data:ChangeFunOpenMap(v.name, is_show)

		--判断组
		self:CheckBtnGroup(v.name, is_show)

		if self["show_"..v.name.."_icon"] then
			if v.name == "firstchargeview" then
				--已废弃的图标（不显示）
				self.show_firstchargeview_icon:SetValue(false)
			elseif v.name == "chongzhi" then
				local active_flag1, _ = DailyChargeData.Instance:GetThreeRechargeFlag(1)
				self["show_"..v.name.."_icon"]:SetValue(is_show and active_flag1 == 1 and next(DailyChargeData.Instance:GetChongZhiInfo()) ~= nil)
				self:CheckShouFirstChargeEff()
			elseif v.name == "leichong" then
				local active_flag1, _ = DailyChargeData.Instance:GetThreeRechargeFlag(1)
				self["show_"..v.name.."_icon"]:SetValue(is_show and active_flag1 == 1)
			elseif v.name == "investview" then
				self["show_"..v.name.."_icon"]:SetValue(is_show and not DailyChargeData.Instance:GetFirstChongzhi10State())
			elseif v.name == "rebateview" then
				if nil ~= RebateCtrl.Instance.is_buy and self.show_rebateview_icon then
					local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
					self.show_rebateview_icon:SetValue(history_recharge >= DailyChargeData.GetMinRecharge() and RebateCtrl.Instance.is_buy and OpenFunData.Instance:CheckIsHide("rebateview"))
				end
			elseif v.name == "molongmibaoview" then
				self["show_"..v.name.."_icon"]:SetValue(is_show and MolongMibaoData.Instance:IsShowMolongMibao())
			elseif v.name == "CollectGoals" then
				self["show_"..v.name.."_icon"]:SetValue(is_show and TimeCtrl.Instance:GetCurOpenServerDay() <= 4)
			elseif v.name == "jubaopen" then
				self:CheckJuBaoPenIcon()
			elseif v.name == "daily_charge" then
				if self.Show_Daily_Charge then
					local active_flag1, _ = DailyChargeData.Instance:GetThreeRechargeFlag(1)
					local is_daily = DailyChargeData.Instance:GetDailyChongzhiOpen()
					local is_get = DailyChargeData.Instance:GetDailyChongzhiTimesCanReward()
					self.Show_Daily_Charge:SetValue(is_show and active_flag1 == 1 and (is_daily or is_get))
				end
			elseif v.name == "zero_gift" then
				self["show_"..v.name.."_icon"]:SetValue(is_show and FreeGiftData.Instance:CanShowZeroGift())
			elseif v.name == "exp_bottle" then
				self["show_"..v.name.."_icon"]:SetValue(is_show and FriendExpBottleData.Instance:IsLevelSatisfy() and not FriendExpBottleData.Instance:IsMaxTimes())
				self:CheckExpBottleShake()
			elseif v.name == "chatguild" then
				self.show_chatguild_icon:SetValue(is_show)
			elseif v.name == "yewaiguaji" then
				if is_show then
					self.is_open_yewaiguaji_icon = true
				else
					self.is_open_yewaiguaji_icon = false
				end
				self.show_yewaiguaji_icon:SetValue(self.is_open_yewaiguaji_icon and YewaiGuajiData.Instance:GetFlagShowIcon())
			elseif v.name == "leiji_recharge" then
				self.show_recharge_icon_1:SetValue(is_show and ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE) and KaifuActivityData.Instance:IsShowLeiJiRechargeIcon())
			elseif v.name == "logingift7view" then						--七天登陆
				self.show_logingift7view_icon:SetValue(is_show and LoginGift7Data.Instance:GetLoginAllReward())
			elseif v.name == "gold_member" then
				local is_get_reward = GoldMemberData.Instance:IsGetReward()
				self.show_gold_member_icon:SetValue(not is_get_reward and is_show)
			else
				self["show_"..v.name.."_icon"]:SetValue(is_show)
			end
		end

		if v.name == "leiji_daily" and self.show_daily_leiji then
			local active_flag1, _ = DailyChargeData.Instance:GetThreeRechargeFlag(1)
			local flag = DailyChargeData.Instance:GetDailyLeiJiFrameGetFlag()
			self.show_daily_leiji:SetValue(is_show and flag and active_flag1 == 1)
		end

		if self.shenyu_img then
			local open_count  = 0
			local data = self:GetShenGeIconData()
			local shengyu_img = "Icon_System_ShenGe"
			if #data == 1 then
				shengyu_img = data[1].res
			end
			self.shenyu_img:SetAsset(ResPath.GetMainUI(shengyu_img))
			self.shenyu_text:SetAsset(ResPath.GetMainUI(shengyu_img .. "_text"))
		end
	end
	if self.show_jingcaiactivity_icon then
		self.show_jingcaiactivity_icon:SetValue(false) --精彩活动还没做暂时关闭
	end
	for k,v in pairs(RemindFunName) do
		RemindManager.Instance:Fire(k)
	end

	--self:ChangeDegreeRewardIcon(KaiFuDegreeRewardsData.Instance:GetDegreeActivityType())

	if self.show_nichongwosong then
		self.show_nichongwosong:SetValue(ActivityData.Instance:GetActivityOpenByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP))
	end

	-- 进阶返利活动
	for k,v in pairs(self.degree_activity_list) do
		self:ActivityChangeCallBack(v.activity_type, v.status, v.next_time, v.open_type)
	end
end

function MainUIView:FlushInChongWoSong()
	if self.show_nichongwosong then
		self.show_nichongwosong:SetValue(ActivityData.Instance:GetActivityOpenByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP))
	end
end

function MainUIView:FlushChargeIcon()
	if nil ~= DailyChargeData.Instance then
		local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
		local is_daily = DailyChargeData.Instance:GetDailyChongzhiOpen()
		local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0

		local active_flag1, _ = DailyChargeData.Instance:GetThreeRechargeFlag(1)

		if active_flag1 == 1 then
			if self.show_chongzhi_icon then
				local open = OpenFunData.Instance:CheckIsHide("chongzhi")
				self.show_chongzhi_icon:SetValue(open and next(DailyChargeData.Instance:GetChongZhiInfo()) ~= nil)
				if open then
					self:IsShowDoubleChongZhi()
				end
			end

			if self.show_daily_leiji then
				local flag = DailyChargeData.Instance:GetDailyLeiJiFrameGetFlag()
				local open = OpenFunData.Instance:CheckIsHide("leiji_daily")
				self.show_daily_leiji:SetValue(open and flag)
			end

			if self.show_leichong_icon then
				local open = OpenFunData.Instance:CheckIsHide("leichong")
				self.show_leichong_icon:SetValue(open)
			end

			if self.Show_Daily_Charge then
				local open = OpenFunData.Instance:CheckIsHide("daily_charge")
				local is_get = DailyChargeData.Instance:GetDailyChongzhiTimesCanReward()
				self.Show_Daily_Charge:SetValue(open and (is_daily or is_get))
			end

			if self.show_investview_icon then
				self.show_investview_icon:SetValue(history_recharge >= DailyChargeData.GetMinRecharge() and OpenFunData.Instance:CheckIsHide("investview"))
			end
		end


		self:ShowRebateButton()
		self:CheckShouFirstChargeEff()
	end
end

function MainUIView:CheckShouFirstChargeEff()
	if self.first_recharge_view == nil or not self:IsRendering() then return end
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
	local open = history_recharge < DailyChargeData.GetMinRecharge() and OpenFunData.Instance:CheckIsHide("firstchargeview") and next(DailyChargeData.Instance:GetChongZhiInfo()) ~= nil

	local active_flag1, fetch_flag1 = DailyChargeData.Instance:GetThreeRechargeFlag(1)
	local active_flag2, fetch_flag2 = DailyChargeData.Instance:GetThreeRechargeFlag(2)
	local active_flag3, fetch_flag3 = DailyChargeData.Instance:GetThreeRechargeFlag(3)

	self.show_charge_arrow:SetValue(not open and next(DailyChargeData.Instance:GetChongZhiInfo()) ~= nil)
	if fetch_flag1~=1 then
		self.show_word_image:SetValue(1)
	elseif fetch_flag2~=1 then
		self.show_word_image:SetValue(2)
	elseif fetch_flag3~=1 then
		self.show_word_image:SetValue(3)
	end
	self.show_first_charge:SetValue(fetch_flag1~=1 or fetch_flag2~=1 or fetch_flag3~=1)

	self.first_recharge_view:OnFlush()

	self:FlushChargeChange()
end

function MainUIView:OnRoleAttrValueChange(key, new_value, old_value)
	if RemindByAttrChange[key] then
		for k,v in pairs(RemindByAttrChange[key]) do
			RemindManager.Instance:Fire(v)
		end
	end
	if key == "level" then
		self:ChangeFunctionTrailer()
		self:FlushDayOpenTrailer()

		if math.abs(new_value - old_value) >= 1 and new_value ~= 1 then
			self:OnOpenTrigger(OPEN_FUN_TRIGGER_TYPE.UPGRADE, new_value)
			MainUICtrl.Instance:CheckMainUiChatIconVisible()
		else
			self:InitOpenFunctionIcon()
		end
		for k,v in pairs(self.tmp_activity_list) do
			self:ActivityChangeCallBack(v.activity_type, v.status, v.next_time, v.open_type)
		end

		for k,v in pairs(self.degree_activity_list) do
			self:ActivityChangeCallBack(v.activity_type, v.status, v.next_time, v.open_type)
		end

	elseif key == "special_appearance" and self.skill_view then
		self.skill_view:OnFlush({skill = true, special_appearance = new_value})
	elseif key == "lover_uid" then
		self:SetButtonVisible(ActRemindNameT[ACTIVITY_TYPE.MARRY_ME], MarryMeData.Instance:GetMarryMeRemind(true))
	elseif key == "guild_id" then
		if new_value == 0 then
			self:Flush(MainUIViewChat.IconList.GuildHongBao, {false})
		end
	elseif key == "mount_appeid" then
		self:Flush("mount_change")
	elseif key == "fight_mount_appeid" then
		self:Flush("fight_mount_change")
	end
end

function MainUIView:DayPass()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local total_day = CollectiveGoalsData.Instance:GetActiveTotalDay()
	RemindManager.Instance:Fire(RemindName.MoLongMiBao)
	self:InitOpenFunctionIcon()
	self:ChangeRisingStarTime()
	self:FlushDayOpenTrailer()
	self:FlushChargeChange()
end

local is_init_charge = false
function MainUIView:FlushChargeChange()
	if nil == self.show_charge_btn_group then
		return
	end

	if not is_init_charge then
		is_init_charge = true
		--初始化界面
		self.first_charge_ani.rect.anchoredPosition = Vector3(-150, 0, 0)
		self.first_charge_ani.canvas_group.alpha = 0
		self.charge_button_group_ani.rect.anchoredPosition = Vector3(-100, 0, 0)
		self.charge_button_group_ani.canvas_group.alpha = 0
	end

	local active_flag1, fetch_flag1 = DailyChargeData.Instance:GetThreeRechargeFlag(1)
	if active_flag1 == nil then
		return
	end

	local active_flag2, fetch_flag2 = DailyChargeData.Instance:GetThreeRechargeFlag(2)
	local active_flag3, fetch_flag3 = DailyChargeData.Instance:GetThreeRechargeFlag(3)

	if active_flag1 ~= 1 or (fetch_flag1 == 1 and fetch_flag2 == 1 and fetch_flag3 == 1) then
		self.is_force_change_charge = false

		--没有首冲或者已经领取三次充值的奖励，不显示加号
		self.show_charge_change_btn:SetValue(false)

		if active_flag1 ~= 1 then
			self.first_charge_ani.rect.anchoredPosition = Vector3(0, 0, 0)
			self.first_charge_ani.canvas_group.alpha = 1
			self.show_charge_btn_group:SetValue(false)
			self.show_frist_charge:SetValue(true)
		else
			self.charge_button_group_ani.rect.anchoredPosition = Vector3(10, 0, 0)
			self.charge_button_group_ani.canvas_group.alpha = 1
			self.show_charge_btn_group:SetValue(true)
			self.show_frist_charge:SetValue(false)
		end
	elseif active_flag1 == 1 then
		--已经首冲并且没有进行二冲或者三冲的话
		self.show_charge_change_btn:SetValue(true)

		if self.is_force_change_charge then
			self.is_force_change_charge = false

			if TimeCtrl.Instance:GetCurOpenServerDay() > 1 and GameVoManager.Instance:GetMainRoleVo().level >= 200 then
				self.charge_btn_ani.rect.localEulerAngles = Vector3(0, 0, 90)
				self.charge_button_group_ani.rect.anchoredPosition = Vector3(10, 0, 0)
				self.charge_button_group_ani.canvas_group.alpha = 1
				self.show_charge_btn_group:SetValue(true)
				self.show_frist_charge:SetValue(false)
			else
				self.charge_btn_ani.rect.localEulerAngles = Vector3(0, 0, 0)
				self.first_charge_ani.rect.anchoredPosition = Vector3(0, 0, 0)
				self.first_charge_ani.canvas_group.alpha = 1
				self.show_charge_btn_group:SetValue(false)
				self.show_frist_charge:SetValue(true)
			end
		end
	end
end

function MainUIView:ChangeCollectiveGoalsImage()
	-- local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()    --屏蔽灭世之战
	-- if self.show_CollectGoals_icon then
	-- 	self.show_CollectGoals_icon:SetValue(server_open_day <= 4 and OpenFunData.Instance:CheckIsHide("CollectGoals"))
	-- 	if server_open_day <= 4 then
	-- 		local bundle, asset = ResPath.GetJumpIcon(self:CollectiveGoalsImage())
	-- 		self.show_CollectGoals_image:SetAsset(bundle, asset)
	-- 	end
	-- end
end

function MainUIView:CollectiveGoalsImage()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local act_type = CollectiveGoalsData.Instance:GetActType(server_day)
	local act_type = CollectiveGoalsData.Instance:GetActType(server_open_day)
	if ActivityData.Instance:GetActivityIsOpen(act_type) then
		return server_open_day + 1
	end
	local _, _, flag = CollectiveGoalsData.Instance:GetNextTime()
	local flag = server_open_day + flag
	return flag
end

function MainUIView:ShakeGuildChatBtn(is_shake)
	GuildData.Instance:SetGuildChatShakeState(is_shake)
	self.show_guild_bubble:SetValue(is_shake)
	if self.MenuIconToggle.isOn == false and self.fight_state_button.toggle.isOn == false then
		self.button_chat_guild_icon.animator:SetBool("shake", is_shake)
	else
		self.record_guild_shake = true --如果是隐藏状态下的话先记录好状态，在显示时再播放颤抖动画
	end
end
------------------在线奖励----------------------------
function MainUIView:StopOnlineCountDown()
	if self.online_time_quest then
		GlobalTimerQuest:CancelQuest(self.online_time_quest)
		self.online_time_quest = nil
	end
end

function MainUIView:SetExpBottleShakeState(enable)
	if self.button_exp_bottle_Icon and self.button_exp_bottle.gameObject.activeInHierarchy then
		self.record_exp_bottle_shake = enable
		self.button_exp_bottle_Icon.animator:SetBool("Shake", enable)
	end
end

function MainUIView:CheckExpBottleShake()
	if self.record_exp_bottle_shake then
		GlobalTimerQuest:AddDelayTimer(function ()
		if self.button_exp_bottle_Icon and self.button_exp_bottle.gameObject.activeInHierarchy then
			self.button_exp_bottle_Icon.animator:SetBool("Shake", self.record_exp_bottle_shake)
			if self.button_exp_bottle_Icon.animator:GetBool("Shake") ~= self.record_exp_bottle_shake then
				self:CheckExpBottleShake()
			end
		end
		end,5)
	end
end

function MainUIView:StarOnlineCountDown(target_time)
	local function timer_func()
		local online_time = WelfareData.Instance:GetTotalOnlineTime()
		local diff_sec = target_time - online_time
		if diff_sec <= 0 then
			self.online_can_reward:SetValue(true)
			self.online_time_text:SetValue(Language.Common.KeLingQu)
			self.show_online_redpoint:SetValue(true)
			-- bug:在线奖励有 在线奖励可领取，但是点进去是不能领取的
			-- 代码没分析出，先通过永不停止计时器观察一段时间（对性能影响不大)
			-- self:StopOnlineCountDown()
			return
		end

		local time_str = ""
		if diff_sec >= 3600 then
			--大于一小时的三位数
			time_str = TimeUtil.FormatSecond(diff_sec)
		else
			time_str = TimeUtil.FormatSecond(diff_sec, 2)
		end
		self.online_can_reward:SetValue(false)
		self.online_time_text:SetValue(time_str)
	end

	self:StopOnlineCountDown()
	self.online_time_quest = GlobalTimerQuest:AddRunQuest(timer_func, 1)
end

function MainUIView:FlushOnlineReward()
	-- bug:在线奖励有 在线奖励可领取，但是点进去是不能领取的
	-- 代码没分析出，先通过永不停止计时器观察一段时间（对性能影响不大)
	-- self:StopOnlineCountDown()
	local reward_data, is_all_get = WelfareData.Instance:GetOnlineReward()
	if nil == reward_data or nil == next(reward_data) then return end

	if is_all_get then
		self.show_online_btn:SetValue(false)
		return
	end

	local scene_type = Scene.Instance:GetSceneType()
	local red_point_flag = false
	local btn_text = ""

	if IS_ON_CROSSSERVER or scene_type ~= SceneType.Common then
		self.show_online_btn:SetValue(false)
	else
		self.show_online_btn:SetValue(true)
		local online_time = WelfareData.Instance:GetTotalOnlineTime()
		local reward_need_sec = (reward_data.minutes) * 60
		local diff_sec = online_time - reward_need_sec

		if diff_sec >= 0 then
			btn_text = Language.Common.KeLingQu
			red_point_flag = true
		else
			diff_sec = math.abs(diff_sec)
			self:StarOnlineCountDown(reward_need_sec)
			local time_str = ""
			if diff_sec >= 3600 then
				--大于一小时的三位数
				time_str = TimeUtil.FormatSecond(diff_sec)
			else
				time_str = TimeUtil.FormatSecond(diff_sec, 2)
			end
			btn_text = time_str
		end
	end
	self.online_time_text:SetValue(btn_text)
	self.show_online_redpoint:SetValue(red_point_flag)
	self.online_can_reward:SetValue(red_point_flag)
end
-----------------------------------------------------

--引导用函数
function MainUIView:MainMenuClick()
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end

	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, true, false, true)
end

function MainUIView:RightShrinkClick()
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, true)
end

function MainUIView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return nil
	end
	if ui_name == GuideUIName.MainUIRoleHead then
		if ui_param == MainViewOperateState.AutoOpen then
			GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, true, false, true)
			return NextGuideStepFlag
		elseif ui_param == MainViewOperateState.AutoClose then
			GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false, false, true)
			return NextGuideStepFlag
		else
			if self.MenuIconToggle.isOn then
				return NextGuideStepFlag
			end
			local callback = BindTool.Bind(self.MainMenuClick, self)
			return self.menu_icon, callback
		end
	elseif ui_name == GuideUIName.MainUIRightShrink then
		if ui_param == MainViewOperateState.AutoOpen then
			GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, true)
			return NextGuideStepFlag
		elseif ui_param == MainViewOperateState.AutoClose then
			GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)
			return NextGuideStepFlag
		else
			if not self.shrink_button.toggle.isOn then
				return NextGuideStepFlag
			end
			local callback = BindTool.Bind(self.RightShrinkClick, self)
			return self.shrink_button, callback
		end
	elseif ui_name == GuideUIName.MainUINewRankBtn then
		if self.new_rank_btn.gameObject.activeInHierarchy then
			local callback = BindTool.Bind(self.OpenRank, self)
			return self.new_rank_btn, callback
		end
	elseif ui_name == GuideUIName.MainUISingleFuBen then
		if self.button_fuben.gameObject.activeInHierarchy then
			return self.button_fuben, function()
				self:OpenFuBen()
			end
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
	return nil
end

function MainUIView:GetMainCheckView()
	return self.chat_view
end

function MainUIView:OnTaskShrinkToggleChange(isOn)
	self.show_switch = not isOn
	if self.show_switch_buttons then
		self.show_switch_buttons:SetValue(not isOn and not self.MenuIconToggle.isOn)
	end
end

function MainUIView:ChangeFightStateToggle(state, count)
	count = count or 1
	--尝试100次
	if count > 100 then
		return
	end

	if self.fight_state_button.gameObject.activeInHierarchy then
		self.fight_state_button.toggle.isOn = state
	else
		GlobalTimerQuest:AddDelayTimer(function()
			self:ChangeFightStateToggle(state, count+1)
		end, 0)
	end
end

function MainUIView:ChangeFightStateEnable(enable)
	if self.fight_state_button.gameObject.activeInHierarchy then
		self.fight_state_button.toggle.enabled = enable
	else
		GlobalTimerQuest:AddDelayTimer(function()
			self:ChangeFightStateEnable(enable)
		end, 0)
	end
end

function MainUIView:GetFightToggleState()
	if self.fight_state_button then
		return self.fight_state_button.toggle.isOn
	end
	return false
end

function MainUIView:OnFightStateToggleChange(isOn)
	MainUIData.IsFightState = isOn
	GlobalEventSystem:Fire(MainUIEventType.FIGHT_STATE_BUTTON, isOn)
	ViewManager.Instance:CheckViewRendering()
	if isOn == false then
		self:CheckRecordGuildShake()
		self:CheckExpBottleShake()
	end
end

--右下角屏蔽按钮点击
function MainUIView:FightStateClick()
	if not self.fight_state_button.toggle.enabled then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotHandle)
	end
end

function MainUIView:ChangeActHongBaoBtn(value)
	-- if self.show_activite_hongbao then
	-- 	self.show_activite_hongbao:SetValue(value)
	-- end
end

function MainUIView:ChangeBiPinBtn(value)
	if self.show_bipin then
		self.show_bipin:SetValue(value)
	end
end

function MainUIView:ChangeZhuLIBtn(value)
	if self.show_ZhuLi then
		self.show_ZhuLi:SetValue(value)
	end
end

function MainUIView:SetBiPinTimeCountDown(time)
	if self.bipin_time then
		if time > 3600 then
			self.bipin_time:SetValue(TimeUtil.FormatSecond(time, 1))
		else
			self.bipin_time:SetValue(TimeUtil.FormatSecond(time, 2))
		end
		self:SetBiPinImg()
	end
end

function MainUIView:SetZhuLiTimeCountDown(time)
	if self.ZhuLi_time then
		if time > 3600 then
			self.ZhuLi_time:SetValue(TimeUtil.FormatSecond(time, 1))
		else
			self.ZhuLi_time:SetValue(TimeUtil.FormatSecond(time, 2))
		end
		self:SetBiPinImg()
	end
end

function MainUIView:SetJingcaiActImg()
	if self.activity_icon_num == nil then return end
	--1是精彩活动 2是合服活动 3是开服活动
	local icon_num = 1
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
		icon_num = 2
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.OPEN_SERVER) then
		icon_num = 3
	end

	self.activity_icon_num:SetValue(icon_num)
end

local mlmb_invalid_time = 0
local mlmb_time = 0
function MainUIView:SetMolongMibaoTime()
	if nil == self.mlmb_time_txt then return end
	mlmb_invalid_time = MolongMibaoData.Instance:GetChapterInvalidTime()
	local function timer_func(elapse_time, total_time)
		mlmb_time = mlmb_invalid_time - TimeCtrl.Instance:GetServerTime()
		if mlmb_time > 3600 * 24 then
			local time_tbl = TimeUtil.Format2TableDHMS(mlmb_time)
			local time_des = ""
			time_des = string.format("%s%s%s%s", time_tbl.day, Language.Common.TimeList.d, time_tbl.hour, Language.Common.TimeList.h)
			self.mlmb_time_txt:SetValue(time_des)
		elseif mlmb_time > 3600 then
			self.mlmb_time_txt:SetValue(TimeUtil.FormatSecond(mlmb_time, 1))
		else
			self.mlmb_time_txt:SetValue(TimeUtil.FormatSecond(mlmb_time, 2))
		end
		if mlmb_time <= 0 then
			if self.mlmb_timer then
				GlobalTimerQuest:CancelQuest(self.mlmb_timer)
				self.mlmb_timer = nil
			end
		end
	end
	if nil == self.mlmb_timer then
		self.mlmb_timer = GlobalTimerQuest:AddRunQuest(timer_func, 1)
	end
end

-- 金银塔活动倒计时
function MainUIView:SetJinyinTaActTime()
	local function timer_func()
		if self.act_btn_time_list then
			if self.act_btn_time_list[ACTIVITY_TYPE.RAND_JINYINTA] then
		 		local jinyinta_act_time = JinYinTaData.Instance:GetActEndTime()
		 		if jinyinta_act_time >= (24 * 3600 * 10) then
					self.act_btn_time_list[ACTIVITY_TYPE.RAND_JINYINTA]:SetValue(TimeUtil.FormatSecond2DHMS(jinyinta_act_time,2))
				elseif jinyinta_act_time > (24 * 3600) then
					local act_time = jinyinta_act_time - math.floor(jinyinta_act_time / (24 * 3600)) * (24 * 3600)
                    if act_time >= (10 * 3600) then
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_JINYINTA]:SetValue(TimeUtil.FormatSecond2DHMS(jinyinta_act_time,3))
			    	else
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_JINYINTA]:SetValue(TimeUtil.FormatSecond2DHMS(jinyinta_act_time,4))
			    	end
				elseif jinyinta_act_time > 3600 then
					if jinyinta_act_time >= (10 * 3600) then
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_JINYINTA]:SetValue(TimeUtil.FormatSecond2DHMS(jinyinta_act_time,3))
					else
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_JINYINTA]:SetValue(TimeUtil.FormatSecond2DHMS(jinyinta_act_time,4))
			    	end
				else
					self.act_btn_time_list[ACTIVITY_TYPE.RAND_JINYINTA]:SetValue(TimeUtil.FormatSecond(jinyinta_act_time, 2))
				end
				if jinyinta_act_time <= 0 then
					if self.jinyinta_next_timer then
						GlobalTimerQuest:CancelQuest(self.jinyinta_next_timer)
						self.jinyinta_next_timer = nil
					end
				end
			end
		else
			if self.jinyinta_next_timer then
				GlobalTimerQuest:CancelQuest(self.jinyinta_next_timer)
				self.jinyinta_next_timer = nil
			end
		end
	end
	if nil == self.jinyinta_next_timer then
		self.jinyinta_next_timer = GlobalTimerQuest:AddRunQuest(timer_func, 1)
	end
end

-- 金银塔活动倒计时
function MainUIView:SetZhenBaoGeActTime()
	local function timer_func()
		if self.act_btn_time_list then
			if self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT] then
		 		local zhenbaoge_act_time = TreasureLoftData.Instance:GetActEndTime()
		 		if zhenbaoge_act_time >= (24 * 3600 * 10) then
					self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT]:SetValue(TimeUtil.FormatSecond2DHMS(zhenbaoge_act_time,2))
				elseif zhenbaoge_act_time > (24 * 3600) then
					local act_time = zhenbaoge_act_time - math.floor(zhenbaoge_act_time / (24 * 3600)) * (24 * 3600)
                    if act_time >= (10 * 3600) then
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT]:SetValue(TimeUtil.FormatSecond2DHMS(zhenbaoge_act_time,3))
			    	else
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT]:SetValue(TimeUtil.FormatSecond2DHMS(zhenbaoge_act_time,4))
			    	end
				elseif zhenbaoge_act_time > 3600 then
					if zhenbaoge_act_time >= (10 * 3600) then
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT]:SetValue(TimeUtil.FormatSecond2DHMS(zhenbaoge_act_time,3))
					else
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT]:SetValue(TimeUtil.FormatSecond2DHMS(zhenbaoge_act_time,4))
			    	end
				else
					self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT]:SetValue(TimeUtil.FormatSecond(zhenbaoge_act_time, 2))
				end
				if zhenbaoge_act_time <= 0 then
					if self.zhenbaoge_next_timer then
						GlobalTimerQuest:CancelQuest(self.zhenbaoge_next_timer)
						self.zhenbaoge_next_timer = nil
					end
				end
			end
		else
			if self.zhenbaoge_next_timer then
				GlobalTimerQuest:CancelQuest(self.zhenbaoge_next_timer)
				self.zhenbaoge_next_timer = nil
			end
		end
	end
	if nil == self.zhenbaoge_next_timer then
		self.zhenbaoge_next_timer = GlobalTimerQuest:AddRunQuest(timer_func, 1)
	end
end

function MainUIView:SetZhuanZhuanLeActTime()
	local function timer_func()
		if self.act_btn_time_list then
			if self.act_btn_time_list[ACTIVITY_TYPE.RAND_LOTTERY_TREE] then
		 		local zhuanzhuanle_act_time = ZhuangZhuangLeData.Instance:GetActEndTime()
                if zhuanzhuanle_act_time >= (24 * 3600 * 10) then
					self.act_btn_time_list[ACTIVITY_TYPE.RAND_LOTTERY_TREE]:SetValue(TimeUtil.FormatSecond2DHMS(zhuanzhuanle_act_time,2))
				elseif zhuanzhuanle_act_time > (24 * 3600) then
					local act_time = zhuanzhuanle_act_time - math.floor(zhuanzhuanle_act_time / (24 * 3600)) * (24 * 3600)
					if act_time >= (10 * 3600) then
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_LOTTERY_TREE]:SetValue(TimeUtil.FormatSecond2DHMS(zhuanzhuanle_act_time,3))
			    	else
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_LOTTERY_TREE]:SetValue(TimeUtil.FormatSecond2DHMS(zhuanzhuanle_act_time,4))
			    	end
				elseif zhuanzhuanle_act_time > 3600 then
					if zhuanzhuanle_act_time >= (10 * 3600) then
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_LOTTERY_TREE]:SetValue(TimeUtil.FormatSecond2DHMS(zhuanzhuanle_act_time,3))
					else
						self.act_btn_time_list[ACTIVITY_TYPE.RAND_LOTTERY_TREE]:SetValue(TimeUtil.FormatSecond2DHMS(zhuanzhuanle_act_time,4))
			    	end
				else
					self.act_btn_time_list[ACTIVITY_TYPE.RAND_LOTTERY_TREE]:SetValue(TimeUtil.FormatSecond(zhuanzhuanle_act_time, 2))
				end
				if zhuanzhuanle_act_time <= 0 then
					if self.zhuanzhuanle_next_timer then
						GlobalTimerQuest:CancelQuest(self.zhuanzhuanle_next_timer)
						self.zhuanzhuanle_next_timer = nil
					end
				end
			end
		else
			if self.zhuanzhuanle_next_timer then
				GlobalTimerQuest:CancelQuest(self.zhuanzhuanle_next_timer)
				self.zhuanzhuanle_next_timer = nil
			end
		end
	end
	if nil == self.zhuanzhuanle_next_timer then
		self.zhuanzhuanle_next_timer = GlobalTimerQuest:AddRunQuest(timer_func, 1)
	end
end

--计算我们结婚吧时间
function MainUIView:SetMarryMeActTime()
	if self.marry_me_count_down then
		CountDown.Instance:RemoveCountDown(self.marry_me_count_down)
		self.marry_me_count_down = nil
	end

	--计算时间函数
	local function calc_times(times)
		local time_tbl = TimeUtil.Format2TableDHMS(times)
		local time_des = ""
		if time_tbl.day > 0 then
			--大于1天的只显示天数和时间
			time_des = string.format("%s%s%s%s", time_tbl.day, Language.Common.TimeList.d, time_tbl.hour, Language.Common.TimeList.h)
		else
			--小于一天的就显示三位时间
			time_des = TimeUtil.FormatSecond(times)
		end
		self.act_btn_time_list[ACTIVITY_TYPE.MARRY_ME]:SetValue(time_des)
	end

	--计时函数
	local function time_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self.act_btn_time_list[ACTIVITY_TYPE.MARRY_ME]:SetValue("00:00")
			CountDown.Instance:RemoveCountDown(self.marry_me_count_down)
			self.marry_me_count_down = nil
		end

		--先计算出剩余时间秒数
		local times = total_time - math.floor(elapse_time)
		calc_times(times)
	end

	local left_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.MARRY_ME)
	--不足1s按1s算（向上取整）
	left_time = math.ceil(left_time)
	if left_time > 0 then
		--活动进行中
		calc_times(left_time)
		self.marry_me_count_down = CountDown.Instance:AddCountDown(left_time, 1, time_func)
	else
		--活动已结束
		if 	self.hideable_button_list[MainUIData.RemindingName.MarryMe] then
			self.hideable_button_list[MainUIData.RemindingName.MarryMe]:SetValue(false)
		end
		self.act_btn_time_list[ACTIVITY_TYPE.MARRY_ME]:SetValue("00:00")
	end
end

function MainUIView:ShowIndexCallBack()
	self:ChangeFunctionTrailer()
end

function MainUIView:ChangeActHongBaoAni(flag, is_loop)
	if self.act_hongbao_ani and self.act_hongbao_ani.isActiveAndEnabled then
		self.act_hongbao_ani:SetBool("Shake", flag)
	end
	if is_loop and not self.hongbao_shake_timer then
		self.hongbao_shake_timer =  GlobalTimerQuest:AddDelayTimer(function()
			if self.act_hongbao_ani.isActiveAndEnabled then
				self.act_hongbao_ani:SetBool("Shake", false)
			end
			self.hongbao_shake_timer = nil
		end, 1)
	end
end

function MainUIView:ShowDiamonDown()
	if self.hongbao_down_timer then return end
	if self.act_hongbao_down_ani then
		self.act_hongbao_down:SetActive(true)
		if self.act_hongbao_down_ani.isActiveAndEnabled then
			self.act_hongbao_down_ani:SetBool("Down", true)
			self.hongbao_down_timer = GlobalTimerQuest:AddDelayTimer(function()
				self.act_hongbao_down_ani:SetBool("Down", false)
				self.hongbao_down_timer = nil
			end, 1)
		end
	end
end

function MainUIView:HasViewOpen(view)
	local data_list = ActivityData.Instance:GetActivityHallDatalistTwo()
	local icon = ""
	local icon_name = ""
	if #data_list == 1 then
		if nil ~= data_list[1].fun_name then
			icon = data_list[1].icon
			icon_name = data_list[1].icon_name
		else
			local act_cfg = ActivityData.Instance:GetActivityConfig(data_list[1].type)
			if act_cfg then
				icon = act_cfg.icon
				icon_name = act_cfg.act_id
			end
		end
		self.activity_hall_img:SetAsset(ResPath.GetMainUI(icon))
		self.activity_hall_imgtwo:SetAsset(ResPath.GetMainRandomActRes("randactivity_"..icon_name))
	else
		self.activity_hall_img:SetAsset(ResPath.GetMainUI("Icon_System_Act_Hall2"))
		self.activity_hall_imgtwo:SetAsset(ResPath.GetMainUI("Icon_System_Act_Hall_text"))
	end
end

function MainUIView:HasViewClose(view)
	-- if view and view.view_name == ViewName.ActivityHall then
	-- 	self.activity_hall_img:SetAsset(ResPath.GetMainUI("Icon_System_Act_Hall"))
	-- end
	local icon = ""
	local icon_name = ""
	local data_list = ActivityData.Instance:GetActivityHallDatalistTwo()
	if #data_list == 1 then
		if nil ~= data_list[1].fun_name then
			icon = data_list[1].icon
			icon_name = data_list[1].icon_name
		else
			local act_cfg = ActivityData.Instance:GetActivityConfig(data_list[1].type)
			if act_cfg then
				icon = act_cfg.icon
				icon_name = act_cfg.act_id
			end
		end
		self.activity_hall_img:SetAsset(ResPath.GetMainUI(icon))
		self.activity_hall_imgtwo:SetAsset(ResPath.GetMainRandomActRes("randactivity_"..icon_name))
	else
		self.activity_hall_img:SetAsset(ResPath.GetMainUI("Icon_System_Act_Hall2"))
		self.activity_hall_imgtwo:SetAsset(ResPath.GetMainUI("Icon_System_Act_Hall_text"))
	end
end

function MainUIView:SetBiPinImg()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	if nil == self.bipin_src or day > GameEnum.NEW_SERVER_DAYS or day < 0 then return end
	local bundle, asset = ResPath.GetCompetitionActivityByMain("Icon_" .. day)
	local bundle_1, asset_1 = ResPath.GetCompetitionActivityByMain("Icon_" .. day .. "_" .. day)
	self.bipin_src:SetAsset(bundle, asset)
	self.bipin_text:SetAsset(bundle_1, asset_1)
end

function MainUIView:SetZhuLiImg()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	if nil == self.ZhuLi_src or day > KaifuActivityData.Instance:GetRisingStarCfg().open_day then return end
	local bundle, asset = ResPath.GetOpenGameActivityRes("Icon_" .. day)
	self.ZhuLi_src:SetAsset(bundle, asset)
end

function MainUIView:CheckMenuRedPoint()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.main_menu_redpoint then
		self.main_menu_redpoint:SetValue(main_role_vo.level >= SHOW_REDPOINT_LIMIT_LEVEL)
	end
end

function MainUIView:ChangeRisingStarIcon(type)
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	--if nil == self.rising_star_icon or day > 15  then return end
	if self.rising_star_icon then
		self.rising_star_icon:SetAsset(ResPath.GetRisingStarActivityRes(risingstar_img_path[type]))
	end
end

-- 进阶返利按钮显示限制
function MainUIView:ChangeDegreeRewardIcon(ac_type)
    if ActRemindNameT[ac_type] then
		self:SetButtonVisible(ActRemindNameT[ac_type])
	end
end

function MainUIView:ChangeRisingStarTime()
	if self.rising_star_countdown then
		GlobalTimerQuest:CancelQuest(self.rising_star_countdown)
		self.rising_star_countdown = nil
	end
	self.rising_star_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(function ()
		if self.rising_star_time then
			local server_time = TimeCtrl.Instance:GetServerTime()
			local server_time2 = TimeUtil.NowDayTimeEnd(server_time)
			local time = server_time2 - server_time

			if time > 24 * 3600 then
				local time_tbl = TimeUtil.Format2TableDHMS(time)
				local time_des = string.format("%s%s%s%s", time_tbl.day, Language.Common.TimeList.d, time_tbl.hour, Language.Common.TimeList.h)
				self.rising_star_time:SetValue(time_des)
			elseif time > 3600 then
				self.rising_star_time:SetValue(TimeUtil.FormatSecond(time, 1))
			else
				self.rising_star_time:SetValue(TimeUtil.FormatSecond(time, 2))
			end
		end
	end), 1)
end

function MainUIView:ChangeGeneralState()
	if self.is_general then
		local use_seq_value = GeneralSkillData.Instance:GetCurUseSeq()
		local flag = use_seq_value ~= -1
		self.is_general:SetValue(flag)
	end
end

function MainUIView:JingHuaHuSongNum()
	local num = MainUIData.Instance:GetJingHuaHuSongNum()
	if nil == num then
		num = 0
	end

	if self.jingua_husong_num then
		self.jingua_husong_num:SetValue(num)
	end
end

function MainUIView:HideBianShen(is_show)
	if self.skill_view then
		self.skill_view:HideBianShen(is_show)
	end
end

function MainUIView:OpenDayTrailer()
	ViewManager.Instance:Open(ViewName.TipsDayOpenTrailerView)
end

function MainUIView:OpenLianhun()
	ViewManager.Instance:Open(ViewName.LianhunView)
end

function MainUIView:ShowApplyView(open_type)
	ScoietyCtrl.Instance:ShowApplyView(open_type)
end

--刷新天数功能预告
function MainUIView:FlushDayOpenTrailer()
	if self.show_day_open_trailer == nil then
		return
	end

	--跨服中直接隐藏
	if IS_ON_CROSSSERVER then
		self.show_day_open_trailer:SetValue(false)
		return
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local other_cfg = OpenFunData.Instance:GetNoticeOtherCfg()
	if main_role_vo.level < other_cfg.level_limit then
		self.show_day_open_trailer:SetValue(false)
		return
	end

	local trailer_info = OpenFunData.Instance:GetNowDayOpenTrailerInfo()
	if nil == trailer_info then
		self.show_day_open_trailer:SetValue(false)
		return
	end

	self.show_day_open_trailer:SetValue(true)

	local bundle, asset = ResPath.GetMainUI(trailer_info.res_icon)
	self.day_open_trailer_icon:SetAsset(bundle, asset)

	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()

	local text_res = "Icon_Tomorrow_Text"
	local show_effect = false
	if open_server_day == trailer_info.open_day and main_role_vo.level >= trailer_info.level_limit then
		text_res = "Icon_UnLock_Text"
		show_effect = true
	end

	bundle, asset = ResPath.GetMainUI(text_res)
	self.day_open_trailer_text:SetAsset(bundle, asset)
	self.show_day_open_trailer_effect:SetValue(show_effect)
end

function MainUIView:GetShowGeneral()
	return self.skill_view:GetShowGeneral()
end

function MainUIView:GetGeneralCD()
	return self.skill_view:GetGeneralCD()
end


MainUIFirstCharge = MainUIFirstCharge or BaseClass(BaseRender)

function MainUIFirstCharge:__init()
	self.model_display = self:FindObj("model")
end

function MainUIFirstCharge:__delete()
	if self.test_model_view then
		self.test_model_view:DeleteMe()
		self.test_model_view = nil
	end

	if nil ~= self.act_preview_time_time_quest then
		GlobalTimerQuest:CancelQuest(self.act_preview_time_time_quest)
		self.act_preview_time_time_quest = nil
	end
end

function MainUIFirstCharge:LoadCallBack()
	self.bundle = 0
	self.asset = 0
end

function MainUIFirstCharge:ReleaseCallBack()
	self.bundle = nil
	self.asset = nil
end

function MainUIFirstCharge:OnFlush()
	if nil == self.test_model_view then
		self.test_model_view = RoleModel.New("button_firstcharge_panel")
		self.test_model_view:SetDisplay(self.model_display.ui3d_display)
	end

	local reward_cfg = DailyChargeData.Instance:GetFirstRewardByWeek()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	local active_flag1, fetch_flag1 = DailyChargeData.Instance:GetThreeRechargeFlag(1)
	local active_flag2, fetch_flag2 = DailyChargeData.Instance:GetThreeRechargeFlag(2)
	local active_flag3, fetch_flag3 = DailyChargeData.Instance:GetThreeRechargeFlag(3)

	local num_str = 0
	local show_id = 0

	local data = DailyChargeData.Instance:GetThreeRechargeAuto()

	if active_flag1~=1 or fetch_flag1~=1 then
		show_push_index = 1
		secondChargeIndex = TabIndex.charge_first_rank
		num_str = string.format("%02d", reward_cfg.wepon_index2)
		show_id = "100" .. main_role_vo.prof .. num_str
		local bundle, asset = ResPath.GetWeaponShowModel(show_id, "100" .. main_role_vo.prof .. "01")
		if self.bundle ~= bundle or self.asset ~= asset then
			self.bundle = bundle
			self.asset = asset
			self.test_model_view:SetPanelName(DisPlayPanel[1])
			self.test_model_view:SetMainAsset(bundle, asset)
			self.test_model_view:SetLoadComplete(BindTool.Bind(self.ModelLoadCompleteCallBack,self))
		end

		return
	end

	if active_flag2~=1 or fetch_flag2~=1 then
		show_push_index = 2
		secondChargeIndex = TabIndex.charge_second_rank
		show_id = data[2]["model".. main_role_vo.prof]
		local bundle, asset = ResPath.GetWingModel(show_id)
		if self.bundle ~= bundle or self.asset ~= asset then
			self.bundle = bundle
			self.asset = asset
			self.test_model_view:SetPanelName(DisPlayPanel[2])
			self.test_model_view:SetMainAsset(bundle, asset)
			self.test_model_view:SetLoadComplete(BindTool.Bind(self.ModelLoadCompleteCallBack,self))
		end

		return
	end

	if active_flag3~=1 or fetch_flag3~=1 then
		show_push_index = 3
		secondChargeIndex = TabIndex.charge_thrid_rank
		show_id = data[3]["model".. main_role_vo.prof]
		local bundle, asset = ResPath.GetMountModel(show_id)
		if self.bundle ~= bundle or self.asset ~= asset then
			self.bundle = bundle
			self.asset = asset
			self.test_model_view:SetPanelName(DisPlayPanel[3])
			self.test_model_view:SetMainAsset(bundle, asset)
			self.test_model_view:SetLoadComplete(BindTool.Bind(self.ModelLoadCompleteCallBack,self))
		end

		return
	end
end

function MainUIFirstCharge:ModelLoadCompleteCallBack(part, obj)
	local move_root = obj.transform:FindHard("MoveRoot")
	if move_root then
		self.animator = obj.transform:FindHard("MoveRoot"):GetComponent(typeof(UnityEngine.Animator))
	end
	if self.animator then
		self.animator.enabled = false
	end
end
