require("game/mainui/mainui_view_player")
require("game/mainui/mainui_view_target")
require("game/mainui/mainui_view_skill")
require("game/mainui/mainui_view_map")
require("game/mainui/mainui_view_task")
require("game/mainui/mainui_view_team")
require("game/mainui/mainui_view_notify")
require("game/mainui/mainui_view_chat")
require("game/mainui/mainui_view_joystick")
require("game/mainui/mainui_view_exp")
require("game/mainui/mainui_view_reminder")
require("game/mainui/mainui_function_trailer")
require("game/mainui/mainui_beatk_icon")
require("game/mainui/mainui_icon_list")
require("game/mainui/mainui_view_hideshow")
require("game/mainui/mainui_res_icon_list")
require("game/mainui/goddess_skill_tips_view")
require("game/famous_general/general_skill_view")
local SHOW_REDPOINT_LIMIT_LEVEL = 40
local WEDDING_ACTIVITY_LEVEL = 50
local ATTACK_LIST_MAX = 8
local AUTO_FLUSH_CD = 10
local PLAYER_FLUSH_CD = 2
local AUTO_SHRIRNK_LEVEL_LIMIT = 70
MainUIView = MainUIView or BaseClass(BaseView)

function MainUIView:__init()
	MainUIView.Instance = self

	self.tmp_button_data = {}
	self.tmp_activity_list = {}
	self.view_layer = UiLayer.MainUI
	self.ui_config = {"uis/views/main", "MainView"}
	self.red_point_list = {}
	self.is_operate_mount = false
	self.is_in = true
	self.active_close = false
	self.is_async_load = true
	self.attack_select_index = 0

	self.low_blood_warning = 0.3			-- 人物低血警告百分比


	self.icon_list_view = MainuiIconListView.New(ViewName.MainUIIconList)
	self.res_icon_list = MainuiResIconListView.New(ViewName.MainUIResIconList)
	self.goddess_skill_tips_view = GoddessSkillTipsView.New(ViewName.MainUIGoddessSkillTip)
	self.goddess_skill_tips_view:SetCloseCallBack(BindTool.Bind(self.GoddessSkillTipsClose,self))

	self.transfer_reminding_name = {}

	GlobalTimerQuest:AddDelayTimer(function()
		ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChangeCallBack,self))
		PlayerData.Instance:ListenerAttrChange(BindTool.Bind1(self.OnRoleAttrValueChange, self))
	end, 0)

	self.pass_day_handle = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.DayPass, self))
	self.junxian_level_change_callback = GlobalEventSystem:Bind(MainUIEventType.JUNXIAN_LEVEL_CHANGE, BindTool.Bind(self.InitOpenFunctionIcon, self))	
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnChangeScene, self))
	self.show_switch = true
	self.select_obj_group_list = {}
	self.need_delay = true
	self.fight_role_list = {}
	self.role_cell_list = {}
	self.last_auto_time = 0					-- 上次自动刷新时间
	self.last_flush_time = 0				-- 上次手动刷新时间
end

function MainUIView:__delete()
	GlobalEventSystem:UnBind(self.pass_day_handle)
	GlobalEventSystem:UnBind(self.junxian_level_change_callback)

	MainUIView.Instance = nil
	self.pass_day_handle = nil
	self.junxian_level_change_callback = nil

	if self.junxian_timer ~= nil and GlobalTimerQuest ~= nil then
		GlobalTimerQuest:CancelQuest(self.junxian_timer)
		self.junxian_timer = nil
	end

	if self.scene_load_enter then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
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
--刷新面板物品是否滿
function MainUIView:OnFulshPackage(enable)
	self.is_full_bag:SetValue(enable)
end

--宝具面板
function MainUIView:OnClickOpenRoleSkill()
	-- ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_medal)
	ViewManager.Instance:Open(ViewName.RoleSkillView, TabIndex.role_skill_active, nil, nil, "role_skill_active")
end

--锻造面板
function MainUIView:OnClickForge()
	ViewManager.Instance:Open(ViewName.Forge, TabIndex.forge_strengthen)
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
function MainUIView:OnClickBeauty()
	ViewManager.Instance:Open(ViewName.Beauty, TabIndex.beauty_info)
end

--女神面板
function MainUIView:OnClickGoddess()
	ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shengwu)
end

--阵营(国家)面板
function MainUIView:OnClickCamp()
	ViewManager.Instance:Open(ViewName.Camp, TabIndex.camp_info)
	-- ViewManager.Instance:Open(ViewName.TaskSlide)
end

--公会面板
function MainUIView:OnClickGuild()
	ViewManager.Instance:Open(ViewName.Guild)
end

--福利面板
function MainUIView:OnOpenWelfare()
	ViewManager.Instance:Open(ViewName.Welfare)
end

function MainUIView:OpenRebateTouShi()
	ActSpecialRebateCtrl.Instance:SetViewType(ACT_SPECIAL_REBATE_TYPE.HEAD)
	ViewManager.Instance:Open(ViewName.ActSpecialRebateView, nil, "view_type", {view_type = ACT_SPECIAL_REBATE_TYPE.HEAD})
end

function MainUIView:OpenRebateYaoShi()
	ActSpecialRebateCtrl.Instance:SetViewType(ACT_SPECIAL_REBATE_TYPE.WAIST)
	ViewManager.Instance:Open(ViewName.ActSpecialRebateView, nil, "view_type", {view_type = ACT_SPECIAL_REBATE_TYPE.WAIST})
end

function MainUIView:OpenRebateMask()
	ActSpecialRebateCtrl.Instance:SetViewType(ACT_SPECIAL_REBATE_TYPE.FACE)
	ViewManager.Instance:Open(ViewName.ActSpecialRebateView, nil, "view_type", {view_type = ACT_SPECIAL_REBATE_TYPE.FACE})
end

function MainUIView:OpenRebateQiLingBi()
	ActSpecialRebateCtrl.Instance:SetViewType(ACT_SPECIAL_REBATE_TYPE.ARM)
	ViewManager.Instance:Open(ViewName.ActSpecialRebateView, nil, "view_type", {view_type = ACT_SPECIAL_REBATE_TYPE.ARM})
end

function MainUIView:OpenRebateLingZhu()
	ActSpecialRebateCtrl.Instance:SetViewType(ACT_SPECIAL_REBATE_TYPE.BEAD)
	ViewManager.Instance:Open(ViewName.ActSpecialRebateView, nil, "view_type", {view_type = ACT_SPECIAL_REBATE_TYPE.BEAD})
end

function MainUIView:OpenRebateXianBao()
	ActSpecialRebateCtrl.Instance:SetViewType(ACT_SPECIAL_REBATE_TYPE.TREASURE)
	ViewManager.Instance:Open(ViewName.ActSpecialRebateView, nil, "view_type", {view_type = ACT_SPECIAL_REBATE_TYPE.TREASURE})
end

function MainUIView:OpenRebateFoot()
	ActSpecialRebateCtrl.Instance:SetViewType(ACT_SPECIAL_REBATE_TYPE.FOOT)
	ViewManager.Instance:Open(ViewName.ActSpecialRebateView, nil, "view_type", {view_type = ACT_SPECIAL_REBATE_TYPE.FOOT})
end

--排行榜面板
function MainUIView:OpenRank()
	RankCtrl.Instance:SetCurIndex(RANK_TAB_TYPE.ZHANLI)
	ViewManager.Instance:Open(ViewName.Ranking)
end

--魔龙秘宝面板
function MainUIView:OpenMolongMibao()
	ViewManager.Instance:Open(ViewName.MolongMibaoView)
end

-- 打开副本面板
function MainUIView:OpenFuBen()
	ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_phase)
end

-- 打开抢地脉
function MainUIView:OpenDiMaiView()
	ViewManager.Instance:Open(ViewName.DiMai, TabIndex.dimai_renmai)
end

-- 打开活动卷轴
function MainUIView:OpenActivityHall()
	self.show_activity_hall_eff:SetValue(false)
	ViewManager.Instance:Open(ViewName.ActivityHall)
end

-- 打开社交面板
function MainUIView:OpenScoiety()
	ViewManager.Instance:Open(ViewName.Scoiety)
end

-- 打开召集面板
function MainUIView:OpenConvene()
	ViewManager.Instance:Open(ViewName.CallView)
end

--答题面板
function MainUIView:OnClickAnswer()
	-- ViewManager.Instance:Open(ViewName.Answer)
end

--富豪转盘面板
-- function MainUIView:OnClickWheel()
-- 	ViewManager.Instance:Open(ViewName.DaFuHao)
-- end

--拍卖行面板
function MainUIView:OnClickMarket()
	ViewManager.Instance:Open(ViewName.Market)
	if MarketCtrl.Instance.view and MarketCtrl.Instance.view.sell_view then
		MarketCtrl.Instance.view.sell_view:Flush()
	end
	if MarketCtrl.Instance.view and MarketCtrl.Instance.view.table_view then
		MarketCtrl.Instance.view.table_view:Flush()
	end
end

--合成面板
function MainUIView:OpenCompose()
	ViewManager.Instance:Open(ViewName.Compose, TabIndex.compose_stone)
end

--活动面板
function MainUIView:OpenActivity()
	ViewManager.Instance:Open(ViewName.Activity)
end

function MainUIView:OpenSecretrShop()
	ViewManager.Instance:Open(ViewName.SecretrShopView)
end

function MainUIView:OpenTurntableView()
	ViewManager.Instance:Open(ViewName.LuckyTurntableView)
end

function MainUIView:OpenHappyBargainView()
	ViewManager.Instance:Open(ViewName.HappyBargainView)
end

--Boss
function MainUIView:OpenBossView()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.miku_boss)
	-- self.task_view:DoMove()
end

function MainUIView:OpenAdventureShopView()
	ViewManager.Instance:Open(ViewName.AdventureShopView)
end

--兑换面板
function MainUIView:OnClickExchange()
	ExchangeCtrl.Instance:SendGetConvertRecordInfo()
	ExchangeCtrl.Instance:SendGetSocreInfoReq()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_mojing)
end

--商城面板
function MainUIView:OnClickShop()
	ViewManager.Instance:Open(ViewName.Shop)
end

--设置面板
function MainUIView:OnClickSetting()
	ViewManager.Instance:Open(ViewName.Setting, TabIndex.setting_notice)
end

--寻宝面板
function MainUIView:OnClickTreasure()
	local is_open = OpenFunData.Instance:CheckIsHide("treasure_choujiang")
	if is_open then
		ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
	else
		ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
	end
end

--首充
function MainUIView:OpenFirstCharge()
	DailyChargeData.Instance:SetShowPushIndex(1)
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

--每日累充
function MainUIView:OpenLeiJiDaily()
	ViewManager.Instance:Open(ViewName.LeiJiDailyView)
end

-- 天降豪礼
function MainUIView:OpenGodDropGiftView()
	ViewManager.Instance:Open(ViewName.GodDropGiftView)
end

-- 皇陵除恶
function MainUIView:OpenRoyalTomb()
	ViewManager.Instance:Open(ViewName.RoyalTombView)
end

-- 国家同盟
function MainUIView:OpenCampTeam()
	ViewManager.Instance:Open(ViewName.CampTeamView)
end

-- 跨服争霸
function MainUIView:OpenSpanBattleView()
	ViewManager.Instance:Open(ViewName.SpanBattleView)
end

-- 真言秘宝
function MainUIView:OpenRareTreasureView()
	ViewManager.Instance:Open(ViewName.RareTreasureView)
end

-- 神器面板
function MainUIView:OnClickShenqi()
	--ViewManager.Instance:Open(ViewName.Shenqi, TabIndex.shenbing_xiangqian)

	local data = {}
	if OpenFunData.Instance:CheckIsHide("shengeview") then
		table.insert(data, {
			res = "Icon_System_TheShenGe",
			callback = function ()
				ViewManager.Instance:Open(ViewName.ShenGeView, TabIndex.shen_ge_inlay)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.ShenGe)

		})
	end

	if OpenFunData.Instance:CheckIsHide("hunqi") then
		table.insert(data, {
			res = "Icon_System_HunQi",
			callback = function ()
				ViewManager.Instance:Open(ViewName.HunQiView, TabIndex.hunqi_content)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.HunQi)

		})
	end

	if OpenFunData.Instance:CheckIsHide("rune") then
		table.insert(data, {
			res = "Icon_System_RUNE",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_tower)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Rune)

		})
	end

	if OpenFunData.Instance:CheckIsHide("shenqi") then
		table.insert(data, {
			res = "Icon_System_shenqi",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Shenqi, TabIndex.shenbing)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.ShenQi)
			--remind = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI) and RemindManager.Instance:GetRemind(RemindName.ShengXiao) + 1 or RemindManager.Instance:GetRemind(RemindName.ShengXiao)
		})
	end

	--兵道
	if OpenFunData.Instance:CheckIsHide("goddess") then
		table.insert(data, {
			res = "Icon_System_bingdao",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shengwu)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Goddess_ShengWu)
			--remind = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI) and RemindManager.Instance:GetRemind(RemindName.ShengXiao) + 1 or RemindManager.Instance:GetRemind(RemindName.ShengXiao)
		})
	end

	-- 转生系统
	if OpenFunData.Instance:CheckIsHide("RebirthView") then
		table.insert(data, {
			res = "Icon_Rebirth",
			callback = function ()
				ViewManager.Instance:Open(ViewName.RebirthView, TabIndex.advance)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Rebirth)
		})
	end

	-- 装扮
	if OpenFunData.Instance:CheckIsHide("DressUp") then
		table.insert(data, {
			res = "Icon_System_DressUp",
			callback = function ()
				ViewManager.Instance:Open(ViewName.DressUp, TabIndex.headwear)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.DressUp)
		})
	end

	-- 卡牌系统
	if OpenFunData.Instance:CheckIsHide("bowuzhi") then
		table.insert(data, {
			res = "Icon_BoWuZhi",
			callback = function ()
				ViewManager.Instance:Open(ViewName.MuseumCardChapter)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.MuseumCard)
		})
	end

	-- 五行之灵系统
	if OpenFunData.Instance:CheckIsHide("SymbolView") then
		table.insert(data, {
			res = "Icon_Symbol",
			callback = function ()
				ViewManager.Instance:Open(ViewName.SymbolView, TabIndex.symbol_intro)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Symbol)
		})
	end

	if #data > 1 then
		self.res_icon_list:SetClickObj(self.button_shenqi, 2)
		self.res_icon_list:SetData(data)
	else
		ViewManager.Instance:Open(ViewName.Shenqi, TabIndex.shenbing_xiangqian)
	end
end

--零元礼包
function MainUIView:OpenZeroGift()
	ViewManager.Instance:Open(ViewName.FreeGiftView)
	self.show_zero_gift_eff:SetValue(false)
end

--累计充值面板
function MainUIView:OpenLeichong()
	ViewManager.Instance:Open(ViewName.LeiJiRechargeView)
end

--魔器面板
function MainUIView:OpenMagicWeapon()
	ViewManager.Instance:Open(ViewName.MagicWeaponView)
end

--地图面板
function MainUIView:OpenMap()
	local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if scene_cfg.smallmap_open and 1 == scene_cfg.smallmap_open then
		SysMsgCtrl.Instance:ErrorRemind(Language.Map.UnOpenInThisScene)
		return
	end
	ViewManager.Instance:Open(ViewName.Map)
end

--走棋子
function MainUIView:OpenGoPown()
	ViewManager.Instance:Open(ViewName.GoPawnView)
end

--结婚面板
function MainUIView:OpenMarriage()
	local data = {}
	-- 结婚
	if OpenFunData.Instance:CheckIsHide("marriage") then
		table.insert(data, {
			res = "Icon_System_Marrage",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_honeymoon)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Marry)
		})
	end

	-- 宝宝
	if OpenFunData.Instance:CheckIsHide("marriage_baby") then
		table.insert(data, {
			res = "Icon_Baby",
			callback = function ()
				ViewManager.Instance:Open(ViewName.MarryBaby)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.MarryBaoBao)
		})
	end

	-- 小宠物
	if OpenFunData.Instance:CheckIsHide("littlepet") then
		table.insert(data, {
			res = "Icon_System_SmallPet",
			callback = function ()
				ViewManager.Instance:Open(ViewName.LittlePetView)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.LittlePet)
		})
	end

	if #data > 1 then
		self.res_icon_list:SetClickObj(self.button_marriage, 2)
		self.res_icon_list:SetData(data)
	else
		ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_honeymoon)
	end
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

--国家战事
function MainUIView:OpenCampWar()
	ViewManager.Instance:Open(ViewName.NationalWarfare, TabIndex.national_warfare_rescue)
	if self.national_citai then
		NationalWarfareCtrl.Instance:Flush("change_to_index", {index = TabIndex.national_warfare_spy})
		self.national_citai = false
	end
end

--红装收集
function MainUIView:OpenRedEquip()
	ViewManager.Instance:Open(ViewName.RedEquipView)
end

function MainUIView:OpenMilitaryHall()
	ViewManager.Instance:Open(ViewName.MilitaryHallView, TabIndex.militaryhall)
end

function MainUIView:OpenKuaFuHall()
	ViewManager.Instance:Open(ViewName.MilitaryHallView, TabIndex.kuafuhall)
end

--打开活动面板
function MainUIView:OpenActivityView(activity_type)
	if activity_type == ACTIVITY_TYPE.RAND_CORNUCOPIA then
		ViewManager.Instance:Open(ViewName.TreasureBowlView)
	elseif activity_type == ACTIVITY_TYPE.CLASH_TERRITORY then
		ViewManager.Instance:Open(ViewName.ClashTerritory)
	elseif activity_type == ACTIVITY_TYPE.GUILD_SHILIAN then
		if ActivityData.Instance:GetActivityIsOpen(activity_type) then
			local yes_func = function ()
				GuildMijingCtrl.SendGuildFbEnterReq()
			end
			TipsCtrl.Instance:ShowCommonAutoView("", str or Language.Guild.GuildActivityTips[activity_type], yes_func)
		else
			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_activity)
		end
	elseif activity_type == ACTIVITY_TYPE.GUILD_BONFIRE then
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_activity)

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GREATE_SOLDIER_DRAW then
		-- ViewManager.Instance:Open(ViewName.GeneralChou)
	elseif activity_type == ACTIVITY_TYPE.WEDDING_ACTIVITY then 							-- 婚宴
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.level >= WEDDING_ACTIVITY_LEVEL then
			ViewManager.Instance:Open(ViewName.WeddingDemandView)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.CrossTeam.Levellimit)
		end
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP then 				-- 幻装商城
		ViewManager.Instance:Open(ViewName.HuanZhuangShopView)
	else
		ActivityCtrl.Instance:ShowDetailView(activity_type)
	end
end

function MainUIView:OnClickShenGe()
	-- ViewManager.Instance:Open(ViewName.ShenGeView, TabIndex.shen_ge_inlay)
	local data = {}
	if OpenFunData.Instance:CheckIsHide("shengeview") then
		table.insert(data, {
			res = "Icon_System_TheShenGe",
			callback = function ()
				ViewManager.Instance:Open(ViewName.ShenGeView, TabIndex.shen_ge_inlay)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.ShenGe)

		})
	end

	if OpenFunData.Instance:CheckIsHide("hunqi") then
		table.insert(data, {
			res = "Icon_System_HunQi",
			callback = function ()
				ViewManager.Instance:Open(ViewName.HunQiView, TabIndex.hunqi_content)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.HunQi)

		})
	end

	if OpenFunData.Instance:CheckIsHide("rune") then
		table.insert(data, {
			res = "Icon_System_RUNE",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_tower)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Rune)

		})
	end

	if OpenFunData.Instance:CheckIsHide("shenqi") then
		table.insert(data, {
			res = "Icon_System_shenqi",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Shenqi, TabIndex.shenbing)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.ShenQi)
			--remind = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI) and RemindManager.Instance:GetRemind(RemindName.ShengXiao) + 1 or RemindManager.Instance:GetRemind(RemindName.ShengXiao)
		})
	end

	if OpenFunData.Instance:CheckIsHide("goddess") then
		table.insert(data, {
			res = "Icon_System_Goddess",
			callback = function ()
				ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shengwu)
			end,
			remind = RemindManager.Instance:GetRemind(RemindName.Goddess)
			--remind = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI) and RemindManager.Instance:GetRemind(RemindName.ShengXiao) + 1 or RemindManager.Instance:GetRemind(RemindName.ShengXiao)
		})
	end

	if #data > 1 then
		self.res_icon_list:SetClickObj(self.button_shengeview, 2)
		self.res_icon_list:SetData(data)
	else
		ViewManager.Instance:Open(ViewName.ShenGeView, TabIndex.shen_ge_inlay)
	end
end

-- 更新攻击模式
function MainUIView:UpdateAttackMode(mode)
	if self.player_view ~= nil then
		self.player_view:UpdateAttackMode(mode)
	end
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

	if on and GuajiCache.guaji_type == GuajiType.None then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		self.show_guaji:SetValue(false)
	elseif GuajiCache.guaji_type == GuajiType.Auto then
		GuajiCtrl.Instance:StopGuaji()
		self.show_guaji:SetValue(true)
		-- 取消挂机的时候直接站立.避免还在冲锋状态
		Scene.Instance:GetMainRole():SetStatusIdle()
	elseif GuajiCache.guaji_type == GuajiType.None then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		self.show_guaji:SetValue(false)
	end
	GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
end

--显示或隐藏挂机按钮
function MainUIView:SetAutoVisible(state)
	self.auto_button:SetActive(state)
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
			return
		end

		self.show_guaji:SetValue(true)
		if GuajiType.Auto == guaji_type then
			self.show_guaji:SetValue(false)
		else
			self.show_guaji:SetValue(true)
		end
	end
end

function MainUIView:TeamTabChange(ison)
	if ison then
		if self.is_team_tab then
			ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
		end
	end
	self.is_team_tab = ison
end

function MainUIView:LeftTrackIsVisible()
	self.team_view:ReloadData()
end

function MainUIView:TeamButtonClick()
	self.team_view:ReloadData()
end

--充值
function MainUIView:OpenRecharge()
	if IS_AUDIT_VERSION then
		ViewManager.Instance:Open(ViewName.RechargeView)
	else
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	end
end

--战场大厅
function MainUIView:OpenBattleField()
	ViewManager.Instance:Open(ViewName.BattleField)
end

-- 嘉年华开服活动
function MainUIView:OpenNewServer()
	ViewManager.Instance:Open(ViewName.KaifuActivityView)
end

--怪物攻城
function MainUIView:OpenMonsterSiege()
	PlayerCtrl.Instance:SendReqCommonOpreate(COMMON_OPERATE_TYPE.COT_REQ_MONSTER_SIEGE_INFO)
	local camp = PlayerData.Instance.role_vo.camp
	local data = CampData.Instance:GetMonsterSiegeInfo()
	if data ~= nil then
		local other_camp = data.monster_siege_camp
		if other_camp ~= nil and other_camp > 0 and other_camp == camp then
			ViewManager.Instance:Open(ViewName.Camp, TabIndex.camp_build)
			return
		end
	end
	ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE.ACTIVITY_TYPE_MONSTER_SIEGE)
end

-- 开服七天充值
function MainUIView:OnClickQiTianChongZhi()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	KaiFuChargeCtrl.Instance:OpenChongZhiView()
	-- if open_day <= 7 then
	-- 	KaiFuChargeCtrl.Instance:OpenChongZhiView()
	-- end
end

-- 全民比拼
function MainUIView:OpenBiPin()
	ViewManager.Instance:Open(ViewName.CompetitionActivity)
	RemindManager.Instance:Fire(RemindName.BiPin)
end

-- 切换信息面板显示
function MainUIView:ClickSwitch()
	if not self.MenuIconToggle then return end

	local scene_id = Scene.Instance:GetSceneId()
	local view_name = ViewName.DaFuHao
	if BossData.IsNeutralBossScene(scene_id) then
		view_name = ViewName.BossFamilyInfoView
	end

	if ViewManager.Instance:IsOpen(view_name) then
		self:SetViewState(true)
		self.MenuIconToggle.isOn = false
		-- GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, true)
		if self.left_track_animator.isActiveAndEnabled then
			self.left_track_animator:SetBool("fade", false)
			self.task_tab_btn_animator:SetBool("fade", false)
			self.task_shrink_button_animator:SetBool("fade", false)
		end
		ViewManager.Instance:Close(view_name)
	else
		self:SetViewState(false)
		ViewManager.Instance:Open(view_name)
		if self.MenuIconToggle.isOn then
			self.MenuIconToggle.isOn = false
		end
		if view_name == ViewName.DaFuHao then
			GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true)
		end
	end
	if view_name == ViewName.DaFuHao then
		DaFuHaoCtrl.Instance.is_hide = true
	end
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

--投资计划
function MainUIView:OpenInvest()
	-- VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	-- ViewManager.Instance:Open(ViewName.VipView, 3)
	ViewManager.Instance:Open(ViewName.RechargeView)
end

--百倍返利
function MainUIView:OpenRebate()
	ViewManager.Instance:Open(ViewName.RebateView)
	-- RebateData.Instance:SetFirstOpenFlag()
	RemindManager.Instance:Fire(RemindName.Rebate)
end

--屏蔽模式改变
function MainUIView:OnShieldModeChanged()
	-- 获取下一个模式
	local mode = self.shield_mode:GetInteger() + 1
	if mode > 2 then mode = 0 end

	-- 网络请求
	if mode == 0 then
		SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_OTHERS, true, true)
		SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP, false, true)
	elseif mode == 1 then
		SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP, true, true)
		SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_OTHERS, false, true)
	elseif mode == 2 then
		SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_OTHERS, false, true)
		SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP, false, true)
	end
end

function MainUIView:UpdateShieldMode()
	local others = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	local camp = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
	if not others and not camp then
		self.shield_mode:SetValue(2)
	elseif others then
		self.shield_mode:SetValue(0)
	else
		self.shield_mode:SetValue(1)
	end
end

--显示或隐藏私聊提醒
function MainUIView:SetPriviteRemindVisible(value)
	self.show_privite_remind:SetValue(value)
end

function MainUIView:SetGuildChatRemindVisible(value)
	-- self.show_guildchat_res:SetValue(value)
end

function MainUIView:SetPriviteHead(info)
	self.privite_id = info.from_uid

	if not GuildChatView.Instance:IsOpen() then
		ChatData.Instance:SetCurrentRoleId(info.from_uid)
	end
	
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(info.from_uid)
	if AvatarManager.Instance:isDefaultImg(info.from_uid) == 0 or avatar_path_small == 0 then
		self.privite_role.gameObject:SetActive(true)
		self.privite_raw.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(info.prof, false, info.sex)
		self.default_icon:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.privite_role.gameObject) or IsNil(self.privite_raw.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(info.from_uid, false)
			end
			self.privite_raw.raw_image:LoadSprite(path, function ()
				self.privite_role.gameObject:SetActive(false)
				self.privite_raw.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(info.from_uid, false, callback)
	end
end

function MainUIView:ShowPriviteRemind(info)
	self:SetPriviteRemindVisible(false)
	-- self:SetGuildChatRemindVisible(true)
	GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.SetPriviteHead, self, info), 0.1)
end

function MainUIView:OpenPrivite()
	-- self:SetPriviteRemindVisible(false)
	-- ViewManager.Instance:CloseAll()
	-- if ViewManager.Instance:IsOpen(ViewName.Chat) then
	-- 	ChatCtrl.Instance.view:ChangeToIndex(TabIndex.chat_private)
	-- else
	-- 	ViewManager.Instance:Open(ViewName.Chat, TabIndex.chat_private)
	-- end
	if self.privite_id then
		ChatData.Instance:SetCurrentRoleId(self.privite_id)
	end
	ViewManager.Instance:Open(ViewName.ChatGuild)
	self:SetPriviteRemindVisible(false)
	-- self:SetGuildChatRemindVisible(false)
end

function MainUIView:SetShowShield(is_show)
	-- self.show_shield:SetValue(is_show)
end

--七天登录奖励
function MainUIView:OpenSevenLogin()
	ViewManager.Instance:Open(ViewName.SevenLoginGiftView)
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
	end
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, not is_on)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, not is_on)
	if ViewManager.Instance:IsOpen(ViewName.FbIconView) then
		self.map_info:SetValue(is_on and not IS_ON_CROSSSERVER)
		self.player_view:ShowRightBtns(is_on and not IS_ON_CROSSSERVER)
		self.target_view:ChangeToHigh(is_on)
	end
	self.show_sysinfo:SetValue(not is_on)
	self.show_switch_buttons:SetValue(self.show_switch and not is_on)

	--策划需求70之后玩家操作不收起右上角Buttons
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.level < AUTO_SHRIRNK_LEVEL_LIMIT then
		self.shrink_button.toggle.isOn = is_on
	end

	if IS_ON_CROSSSERVER then
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type and scene_type ~= SceneType.KfMining and scene_type ~= SceneType.Fishing and scene_type ~= SceneType.CrossGuildBattle then
			self.map_info:SetValue(false)
		end
	end


	level = PlayerData.Instance.role_vo.level
	local info = WelfareData.Instance:GetRewardByLevel(level)
	if self.function_trailer ~= nil and next(info) ~= nil and Scene.Instance:GetSceneType() == SceneType.Common then
		self.function_trailer:SetShowReward(not is_on)
	end
end

--点击菜单按钮
function MainUIView:OnClickMenu()

end

-- 魔龙按钮
function MainUIView:OnOpenMoLong()
	ViewManager.Instance:Open(ViewName.MoLong)
end

--小助手
function MainUIView:OpenHelperView()
	ViewManager.Instance:Open(ViewName.HelperView)
end

-- 小宠物
function MainUIView:OnOpenPet()
	ViewManager.Instance:Open(ViewName.PetView)
end

-- 转生
function MainUIView:OpenReincarnation()
	ViewManager.Instance:Open(ViewName.Reincarnation)
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

--打开温馨提示
function MainUIView:OpenRemindTipsView()
	TipsCtrl.Instance:CheckRemindTips()
	local remind_list = TipsRemindData.Instance:GetRemindList()
	if remind_list and #remind_list > 0 then
		TipsCtrl.Instance:OpenRemindTipsView()
	else
		self.show_remind_icon:SetValue(false)
		--SysMsgCtrl.Instance:ErrorRemind(Language.Common.NoRemindCharge)
	end
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
	-- KaifuActivityView里面的ShowIndexCallBack大于100000才会进判断然后再减100000 不知道为什么这么写
	ViewManager.Instance:Open(ViewName.KaifuActivityView, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE + 100000)
	-- ViewManager.Instance:Open(ViewName.ExpRefine)
end

-- 开服红包
function MainUIView:OpenActiviteHongBa()
	ViewManager.Instance:Open(ViewName.ActiviteHongBao)
end

-- 开服充值活动(我是集:月卡、投资计划、开服比拼、开服七天充值于一身的集合体)
function MainUIView:OpenKaiFuCharge()
	ViewManager.Instance:Open(ViewName.KaiFuChargeView)
end

-- 决斗场
function MainUIView:OpenFightView()
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

function MainUIView:OpenJuBaoPen()
	ViewManager.Instance:Open(ViewName.JuBaoPen)
end

function MainUIView:OpenGeneral()	
	ViewManager.Instance:Open(ViewName.FamousGeneralView)
end

function MainUIView:OpenRuneView()
	ViewManager.Instance:Open(ViewName.Rune)
end

-- function MainUIView:OpenRuneTowerView()
-- 	ViewManager.Instance:Open(ViewName.RuneTowerView)
-- end

function MainUIView:OpenZhuanZhuanLe()
	ViewManager.Instance:Open(ViewName.ZhuangZhuangLe)
end

function MainUIView:OpenMarryMeView()
	ViewManager.Instance:Open(ViewName.MarryMe)
end

-- 首冲、再充、三充面板
function MainUIView:OpenThreeChargeView()
	-- DailyChargeData.Instance:SetShowPushIndex(2)
	-- self.show_charge_effect1:SetValue(false)
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

function MainUIView:OpenKuafuView()
	ViewManager.Instance:Open(ViewName.KuaFuBattle)
end

--抢皇帝(攻城战)后的膜拜
function MainUIView:OpenCityCombatWorshipTip()
	local ok_func = function ()
		local other_cfg = CityCombatData.Instance:GetOtherConfig()
		if other_cfg then
			MoveCache.scene_id = other_cfg.worship_scene_id
			MoveCache.x = other_cfg.worship_pos_x
			MoveCache.y = other_cfg.worship_pos_y
			GuajiCtrl.Instance:MoveToScenePos(other_cfg.worship_scene_id, other_cfg.worship_pos_x, other_cfg.worship_pos_y)
		end
	end
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.CityCombat.GoToWorshipEmperor)
end

--抢国王(公会争霸)后的膜拜传送按钮事件
function MainUIView:OpenGuildBattleWorshipTip()
	local ok_func2 = function ()
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local config = GuildFightData.Instance:GetConfig()
		if config and main_role_vo then
			local camp = config.worship_scene[main_role_vo.camp]
			MoveCache.scene_id = camp.scene_id
			MoveCache.x = camp.pos_x
			MoveCache.y = camp.pos_y
			GuajiCtrl.Instance:MoveToScenePos(camp.scene_id, camp.pos_x, camp.pos_y)
		end
	end
	TipsCtrl.Instance:ShowCommonTip(ok_func2, nil, Language.GuildBattle.GoToWorship)
end

function MainUIView:OpenMieshiWar()
	ViewManager.Instance:Open(ViewName.CollectGoals)
end

function MainUIView:OnClickSavePower()
	ViewManager.Instance:Open(ViewName.Unlock)
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
	-- if GuaJiTaData.Instance:RuneTowerCanChallange() then
	-- 	table.insert(data, {
	-- 		name = Language.Mainui.RuneTower,
	-- 		callback = function ()
	-- 			ViewManager.Instance:Open(ViewName.RuneTowerView)
	-- 		end,
	-- 		remind = 0

	-- 	})
	-- end
	if CoolChatData.Instance:GetCoolChatRedPoint() then
		table.insert(data, {
			name = Language.Mainui.TuHaoJin,
			callback = function ()
				ViewManager.Instance:Open(ViewName.CoolChat)
			end,
			remind = 0

		})
	end
	if RuneData.Instance:GetBagHaveRuneGift() then
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

	-- 屏蔽变强按钮
	-- self.icon_list_view:SetClickObj(self.button_strength, 4)
	self.icon_list_view:SetData(data)
end

function MainUIView:OpenTargetView()
	ViewManager.Instance:Open(ViewName.PersonalGoals)
end

function MainUIView:OpenDaChen()
	ViewManager.Instance:Open(ViewName.NationalWarfare, TabIndex.national_warfare_minister)
end

function MainUIView:OpenGuoQi()
	ViewManager.Instance:Open(ViewName.NationalWarfare, TabIndex.national_warfare_flag)
end

--福利boss
function MainUIView:OnClickWorldBoss()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.world_boss)
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

	if self.MenuIconToggle ~= nil and self.MenuIconToggle.isOn ~= nil then
		self.MenuIconToggle.isOn = state
	end
	
	local scene_type = Scene.Instance:GetSceneType()
	if ViewManager.Instance:IsOpen(ViewName.FbIconView) or scene_type == SceneType.Kf_OneVOne then
		self.map_info:SetValue(state)
		if scene_type == SceneType.Kf_OneVOne then
			self.map_info:SetValue(false)
		end
		self.player_view:ShowRightBtns(state)
		self.target_view:ChangeToHigh(state)
	end
	if IS_ON_CROSSSERVER then
		if scene_type and scene_type ~= SceneType.KfMining and scene_type ~= SceneType.Fishing and scene_type ~= SceneType.CrossGuildBattle then
			self.map_info:SetValue(false)
		end
	end
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, not state)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, not state)
end

function MainUIView:HideMap(state)
	if self.hide_map then
		self.hide_map:SetValue(state)
	end
end

function MainUIView:LoadCallBack()
	self.is_team_tab = false
	self.call_index = 1
	self.transfer_time_quest = {}
	self.transfer_begin_time = {}
	self.call_time = {}

	-- 监听事件
	self:ListenEvent("OpenPlayer", BindTool.Bind(self.OnClickPlayer, self))
	self:ListenEvent("OpenPackage", BindTool.Bind(self.OnClickPackage, self))
	self:ListenEvent("OpenRoleSkill", BindTool.Bind(self.OnClickOpenRoleSkill, self))
	self:ListenEvent("OpenForge", BindTool.Bind(self.OnClickForge, self))
	self:ListenEvent("OpenAdvance", BindTool.Bind(self.OnClickAdvance, self))
	self:ListenEvent("OpenBeauty", BindTool.Bind(self.OnClickBeauty, self))
	self:ListenEvent("OpenGoddessView", BindTool.Bind(self.OnClickGoddess, self))
	self:ListenEvent("OpenCamp", BindTool.Bind(self.OnClickCamp, self))
	self:ListenEvent("OpenGuild", BindTool.Bind(self.OnClickGuild, self))
	self:ListenEvent("OpenAnswer", BindTool.Bind(self.OnClickAnswer, self))
	self:ListenEvent("OpenMarket", BindTool.Bind(self.OnClickMarket, self))
	self:ListenEvent("AutoChanged", BindTool.Bind(self.OnAutoChanged, self))
	self:ListenEvent("ShieldModeChanged", BindTool.Bind(self.OnShieldModeChanged, self))
	self:ListenEvent("OpenWelfare", BindTool.Bind(self.OnOpenWelfare, self))
	self:ListenEvent("OpenMarriage", BindTool.Bind(self.OpenMarriage, self))
	self:ListenEvent("OpenRank", BindTool.Bind(self.OpenRank, self))
	self:ListenEvent("OpenMolongMibao", BindTool.Bind(self.OpenMolongMibao, self))
	self:ListenEvent("OpenFuBen", BindTool.Bind(self.OpenFuBen, self))
	self:ListenEvent("OpenFuBenMulti", BindTool.Bind(self.OpenFuBenMulti, self))
	self:ListenEvent("OpenScoiety", BindTool.Bind(self.OpenScoiety, self))
	self:ListenEvent("OpenConvene", BindTool.Bind(self.OpenConvene, self))
	self:ListenEvent("OpenCompose", BindTool.Bind(self.OpenCompose, self))
	self:ListenEvent("OpenActivity", BindTool.Bind(self.OpenActivity, self))
	self:ListenEvent("OpenSecretrShop", BindTool.Bind(self.OpenSecretrShop, self))
	self:ListenEvent("OpenTurntableView", BindTool.Bind(self.OpenTurntableView, self))
	self:ListenEvent("OpenHappyBargainView", BindTool.Bind(self.OpenHappyBargainView, self))
	self:ListenEvent("OpenBossView", BindTool.Bind(self.OpenBossView, self))
	-- self:ListenEvent("OpenWheel", BindTool.Bind(self.OnClickWheel, self))
	self:ListenEvent("OpenExchange", BindTool.Bind(self.OnClickExchange, self))
	self:ListenEvent("OpenShop", BindTool.Bind(self.OnClickShop, self))
	self:ListenEvent("OpenSetting", BindTool.Bind(self.OnClickSetting, self))
	self:ListenEvent("OpenTreasure", BindTool.Bind(self.OnClickTreasure, self))
	self:ListenEvent("OpenMap", BindTool.Bind(self.OpenMap, self))
	self:ListenEvent("OpenSpirit", BindTool.Bind(self.OpenSpirit, self))
	self:ListenEvent("OpenQixiActivity", BindTool.Bind(self.OpenQixiActivity, self))
	self:ListenEvent("OpenMidAutumnView", BindTool.Bind(self.OpenMidAutumnView, self))
	self:ListenEvent("OpenRecharge", BindTool.Bind(self.OpenRecharge, self))
	self:ListenEvent("OpenBattleField", BindTool.Bind(self.OpenBattleField, self))
	self:ListenEvent("ButtonChange", BindTool.Bind(self.ButtonChange, self))
	self:ListenEvent("OpenGoPown", BindTool.Bind(self.OpenGoPown, self))
	self:ListenEvent("ClickTeam", BindTool.Bind(self.TeamButtonClick, self))
	self:ListenEvent("ClickNewServer", BindTool.Bind(self.OpenNewServer, self))
	self:ListenEvent("OpenPrivite", BindTool.Bind(self.OpenPrivite, self))
	self:ListenEvent("ClickSwitch", BindTool.Bind(self.ClickSwitch, self))
	self:ListenEvent("OpenDailyCharge", BindTool.Bind(self.OpenDailyCharge, self))
	self:ListenEvent("OpenInvest", BindTool.Bind(self.OpenInvest, self))
	self:ListenEvent("OpenRebate", BindTool.Bind(self.OpenRebate, self))
	self:ListenEvent("OpenFirstCharge", BindTool.Bind(self.OpenFirstCharge, self))
	self:ListenEvent("OpenMagicWeapon", BindTool.Bind(self.OpenMagicWeapon, self))
	self:ListenEvent("OpenSevenLogin", BindTool.Bind(self.OpenSevenLogin, self))
	self:ListenEvent("OnClickMenu", BindTool.Bind(self.OnClickMenu, self))
	self:ListenEvent("OpenMoLong", BindTool.Bind(self.OnOpenMoLong, self))
	self:ListenEvent("OpenPet", BindTool.Bind(self.OnOpenPet, self))
	self:ListenEvent("OpenReincarnation", BindTool.Bind(self.OpenReincarnation, self))
	self:ListenEvent("EnterWedding", BindTool.Bind(self.EnterWedding, self))
	self:ListenEvent("OpenTempMount", BindTool.Bind(self.OpenTempMount, self))
	self:ListenEvent("OpenLeichong", BindTool.Bind(self.OpenLeichong, self))
	self:ListenEvent("OpenTempWing", BindTool.Bind(self.OpenTempWing, self))
	self:ListenEvent("OpenOnlineRewardView", BindTool.Bind(self.OpenOnlineRewardView, self))
	self:ListenEvent("OpenRemind", BindTool.Bind(self.OpenRemindTipsView, self))
	self:ListenEvent("OpenLineView", BindTool.Bind(self.OpenLineView, self))
	self:ListenEvent("OpenMember", BindTool.Bind(self.OpenMemberView, self))
	self:ListenEvent("OpenTarget", BindTool.Bind(self.OpenTargetView, self))
	self:ListenEvent("OpenRune", BindTool.Bind(self.OpenRuneView, self))
	--self:ListenEvent("OpenRuneTower", BindTool.Bind(self.OpenRuneTowerView, self))
	self:ListenEvent("OpenWantMarry", BindTool.Bind(self.OpenMarryMeView, self))
	-- self:ListenEvent("OpenStrength", BindTool.Bind(self.OpenStrength, self))			-- 变强屏蔽
	self:ListenEvent("OpenMieshiWar", BindTool.Bind(self.OpenMieshiWar, self))
	self:ListenEvent("OnClickSavePower", BindTool.Bind(self.OnClickSavePower, self))
	self:ListenEvent("OnClickShenGe", BindTool.Bind(self.OnClickShenGe, self))
	self:ListenEvent("OpenLeiJiDaily", BindTool.Bind(self.OpenLeiJiDaily, self))
	self:ListenEvent("OpenShenqi", BindTool.Bind(self.OnClickShenqi, self))				-- 神器
	self:ListenEvent("OpenZeroGift", BindTool.Bind(self.OpenZeroGift, self))
	self:ListenEvent("FightStateClick", BindTool.Bind(self.FightStateClick, self))
	self:ListenEvent("OpenJunXian", BindTool.Bind(self.OpenJunXianView, self))
	self:ListenEvent("OpenCityCombatWorshipTip", BindTool.Bind(self.OpenCityCombatWorshipTip, self))
	self:ListenEvent("OpenGuildBattleWorshipTip", BindTool.Bind(self.OpenGuildBattleWorshipTip, self))
	self:ListenEvent("OpenHelper", BindTool.Bind(self.OpenHelperView,self))
	self:ListenEvent("OpenCampWar", BindTool.Bind(self.OpenCampWar, self))
	self:ListenEvent("OnClickCountryTransfer", BindTool.Bind(self.OnClickOpenTransfer, self, 1))
	self:ListenEvent("OnClickFamilyTransfer", BindTool.Bind(self.OnClickOpenTransfer, self, 2))	
	self:ListenEvent("OnClickTeamTransfer", BindTool.Bind(self.OnClickOpenTransfer, self, 3))
	self:ListenEvent("ChangeMonster", BindTool.Bind(self.ChangeMonster, self))
	self:ListenEvent("ChangeCameraMode", BindTool.Bind(self.OnClickCameraMode, self))
	self:ListenEvent("OpenRedEquip", BindTool.Bind(self.OpenRedEquip, self))
	self:ListenEvent("OpenActivityHall", BindTool.Bind(self.OpenActivityHall, self))
	self:ListenEvent("OpenDiMaiView", BindTool.Bind(self.OpenDiMaiView, self))
	self:ListenEvent("OpenTempShenJi", BindTool.Bind(self.OpenTempShenJi, self))
	self:ListenEvent("OpenGodDropGiftView", BindTool.Bind(self.OpenGodDropGiftView, self))
	self:ListenEvent("OpenRoyalTomb", BindTool.Bind(self.OpenRoyalTomb, self))
	self:ListenEvent("OpenCampTeam", BindTool.Bind(self.OpenCampTeam, self))
	self:ListenEvent("OpenAdventureShopView", BindTool.Bind(self.OpenAdventureShopView, self))
	self:ListenEvent("OpenMilitaryHall", BindTool.Bind(self.OpenMilitaryHall, self))
	self:ListenEvent("OpenKuaFuHall", BindTool.Bind(self.OpenKuaFuHall, self))

	

	--活动
	self:ListenEvent("OpenWedding", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.WEDDING_ACTIVITY))
	self:ListenEvent("OpenTreasureBowl", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_CORNUCOPIA))
	self:ListenEvent("OpenTombExplore", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.TOMB_EXPLORE))
	self:ListenEvent("OpenCityCombat", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GONGCHENGZHAN))
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
	-- self:ListenEvent("OpenGuildBoss", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.GUILD_BOSS))
	self:ListenEvent("OpenCrossCrystal", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.SHUIJING))
	self:ListenEvent("OpenBanZhuan", BindTool.Bind(self.OpBanZhuan, self))
	self:ListenEvent("OpenMining", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_MINING))
	self:ListenEvent("OpenFishing", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.KF_FISHING))
	self:ListenEvent("OpenGeneralChou", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GREATE_SOLDIER_DRAW))
	self:ListenEvent("OpenHuanZhuangShop", BindTool.Bind(self.OpenActivityView, self, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP))

	self:ListenEvent("OpenActiviteHongBao", BindTool.Bind(self.OpenActiviteHongBa, self))
	self:ListenEvent("OpenExpRefine", BindTool.Bind(self.OpenExpRefineView, self))
	self:ListenEvent("OpenJuBaoPen", BindTool.Bind(self.OpenJuBaoPen, self))
	self:ListenEvent("OpenGeneral", BindTool.Bind(self.OpenGeneral, self))
	self:ListenEvent("OpenKaiFuCharge", BindTool.Bind(self.OpenKaiFuCharge, self))
	self:ListenEvent("OpenFightView", BindTool.Bind(self.OpenFightView, self))
	self:ListenEvent("OpenDaChen", BindTool.Bind(self.OpenDaChen, self))
	self:ListenEvent("OpenGuoQi", BindTool.Bind(self.OpenGuoQi, self))
	self:ListenEvent("OnClickWorldBoss", BindTool.Bind(self.OnClickWorldBoss, self))
	self:ListenEvent("OpenThreeChargeView", BindTool.Bind(self.OpenThreeChargeView, self))
	self:ListenEvent("OpenKuafuView", BindTool.Bind(self.OpenKuafuView, self))
	self:ListenEvent("OpenMonsterSiege", BindTool.Bind(self.OpenMonsterSiege, self))
	self:ListenEvent("OnClickQiTianChongZhi", BindTool.Bind(self.OnClickQiTianChongZhi, self))
	self:ListenEvent("OpenBiPin", BindTool.Bind(self.OpenBiPin, self))
	self:ListenEvent("OpenRechargeView", BindTool.Bind(self.OpenRechargeView, self))
	self:ListenEvent("OpenThreeRechargeView", BindTool.Bind(self.OpenThreeRechargeView, self))
	self:ListenEvent("OpenjunGiftActivity", BindTool.Bind(self.OpenjunGiftActivity, self))
	self:ListenEvent("OnFlushRoleList", BindTool.Bind(self.OnClickFlushList, self))
	self:ListenEvent("OpenDressShop", BindTool.Bind(self.OpenDressShop, self))
	self:ListenEvent("OpenSpanBattle", BindTool.Bind(self.OpenSpanBattleView, self))
	self:ListenEvent("OpenRareTreasure", BindTool.Bind(self.OpenRareTreasureView, self))
	self:ListenEvent("OpenKaifuDailyCharge", BindTool.Bind(self.OpenKaifuDailyCharge, self))
	self:ListenEvent("OpenRebateFoot", BindTool.Bind(self.OpenRebateFoot, self))
	self:ListenEvent("OpenRebateTouShi", BindTool.Bind(self.OpenRebateTouShi, self))
	self:ListenEvent("OpenRebateYaoShi", BindTool.Bind(self.OpenRebateYaoShi, self))
	self:ListenEvent("OpenRebateMask", BindTool.Bind(self.OpenRebateMask, self))
	self:ListenEvent("OpenRebateQiLingBi", BindTool.Bind(self.OpenRebateQiLingBi, self))
	self:ListenEvent("OpenRebateLingZhu", BindTool.Bind(self.OpenRebateLingZhu, self))
	self:ListenEvent("OpenRebateXianBao", BindTool.Bind(self.OpenRebateXianBao, self))
	self:ListenEvent("OpenThanksFeedBack", BindTool.Bind(self.OpenThanksFeedBack, self))

	self.shield_others = GlobalEventSystem:Bind(SettingData.Instance:GetGlobleType(SETTING_TYPE.SHIELD_OTHERS), BindTool.Bind(self.UpdateShieldMode, self))
	self.shield_camp = GlobalEventSystem:Bind(SettingData.Instance:GetGlobleType(SETTING_TYPE.SHIELD_SAME_CAMP), BindTool.Bind(self.UpdateShieldMode, self))
	GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE,BindTool.Bind(self.OnTaskChange, self))

	GlobalEventSystem:Bind(OtherEventType.VIRTUAL_TASK_CHANGE,BindTool.Bind(self.OnPersonGoalChange, self))
	-- GlobalEventSystem:Bind(OtherEventType.TASK_WINDOW,BindTool.Bind(self.OnOpenWindow, self))
	self.shrink_btn = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON,BindTool.Bind(self.OnShowOrHideShrinkBtn, self))
	self.menu_toggle_change = GlobalEventSystem:Bind(
		MainUIEventType.PORTRAIT_TOGGLE_CHANGE,
		BindTool.Bind(self.PortraitToggleChange, self))
	self.scene_load_complete = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.SceneLoadComplete, self))
	self.right_up_button_show = GlobalEventSystem:Bind(SceneEventType.SHOW_MAINUI_RIGHT_UP_VIEW, BindTool.Bind(self.ChangeMenuState, self))
	self.shrink_dafuhao_info = GlobalEventSystem:Bind(MainUIEventType.SHRINK_DAFUHAO_INFO, BindTool.Bind(self.OnTaskShrinkToggleChange, self))
	self.obj_dead = GlobalEventSystem:Bind(ObjectEventType.OBJ_DEAD, BindTool.Bind(self.OnObjDead, self))
	self.main_role_level_change = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.MainRoleLevelChange, self))
	self.main_role_realive = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind(self.FlushFightRoleList, self))

	self.data_listen = BindTool.Bind(self.ClashTerritoryDataChangeCallback, self)
	ClashTerritoryData.Instance:AddListener(ClashTerritoryData.INFO_CHANGE, self.data_listen)

	self.camera_mode_change = GlobalEventSystem:Bind(SettingEventType.MAIN_CAMERA_MODE_CHANGE, BindTool.Bind(self.CameraModeChange, self))

	-- 获取变量
	self.shield_mode = self:FindVariable("ShieldMode")
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
	self.show_shield = self:FindVariable("ShowShield")
	self.is_in_task_talk = self:FindVariable("IsInTaskTalk")
	self.show_shield:SetValue(false)
	self.is_in_task_talk:SetValue(false)
	self.map_info = self:FindVariable("IsShowMap")
	self.map_info:SetValue(true)
	self.show_marry_wedding = self:FindVariable("ShowMarryWedding")
	self.wedding_time = self:FindVariable("WeddingTime")
	self.default_icon = self:FindVariable("DefaultIcon")
	self.custom_icon = self:FindVariable("CustomIcon")
	self.show_sysinfo = self:FindVariable("Show_SysInfo")
	self.show_shrink_btn = self:FindVariable("ShowShrinkBtn")
	self.show_charge_effect = self:FindVariable("ShowChargeEffect")
	self.show_guaji = self:FindVariable("ShowGuaji")						-- 挂机文字显示
	self.show_save_power = self:FindVariable("ShowSavePower")
	self.show_shen_ge_effect = self:FindVariable("ShowShenGeEffect")
	self.camera_mode = self:FindVariable("CameraMode") 						-- 视角摄像机编号显示
	self.is_free_camera = self:FindVariable("IsFreeCamera") 				

	self.scene_camera_effect = self:FindVariable("SceneCameraEffect") 		-- 场景切换俯视特效
	self.show_charge_effect1 = self:FindVariable("ShowChargeEffect1")
	self.show_charge_effect2 = self:FindVariable("ShowChargeEffect2")
	self.show_adventure_shop_icon = self:FindVariable("ShowAdventureShop")
	-- self.set_call_btn_gray = {}
	-- self.set_call_btn_gray[1] = self:FindVariable("SetCountryCallGray")
	-- self.set_call_btn_gray[2] = self:FindVariable("SetFamilyCallGray")
	-- self.set_call_btn_gray[3] = self:FindVariable("SetTeamCallGray")
	-- self.set_call_btn_gray[3]:SetValue(true)

		if self.show_charge_effect1 then
			self.show_charge_effect1:SetValue(true)
		end

		if self.show_charge_effect2 then
			self.show_charge_effect2:SetValue(true)
		end

	-- 主按钮红点
	self.main_menu_redpoint = self:FindVariable("Show_Menu_Redpoint")

	self.panel = self:FindObj("Panel")
	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
		and UnityEngine.iOS.Device.generation == UnityEngine.iOS.DeviceGeneration.iPhoneX then
		local rect = self.panel.transform:GetComponent(typeof(UnityEngine.RectTransform))
		rect.offsetMin = Vector2(66, 0)
		rect.offsetMax = Vector2(-66, 0)
	end

	-- 获取控件
	self.auto_button = self:FindObj("AutoButton")
	self.team_button = self:FindObj("TeamButton")
	self.privite_remind = self:FindObj("PriviteRemind")
	self.privite_role = self:FindObj("PriviteRole")
	self.privite_raw = self:FindObj("PriviteRaw")
	self.city_combat_buttons = self:FindObj("CityCombatButtons")
	self.city_combat_buttons:SetActive(false)

	self.arrow_image = self:FindObj("ArrowImage")
	self.arrow_image:SetActive(false)

	--获取按钮
	self.button_player = self:FindObj("ButtonPlayer")
	self.button_forge = self:FindObj("ButtonForge")
	self.button_advance = self:FindObj("ButtonAdvance")
	self.button_beauty = self:FindObj("ButtonBeauty")
	self.button_famousgeneralview = self:FindObj("ButtonFamousgeneralview")
	self.button_goddess = self:FindObj("ButtonGoddess")
	self.button_roleskill = self:FindObj("ButtonRoleskill")
	self.button_spiritview = self:FindObj("ButtonSpirit")
	self.button_head = self:FindObj("ButtonHead")
	self.button_compose = self:FindObj("ButtonCompose")
	self.button_guild = self:FindObj("ButtonGuild")
	self.button_scoiety = self:FindObj("ButtonScoiety")
	self.button_marriage = self:FindObj("ButtonMarriage")
	-- self.button_ranking = self:FindObj("ButtonRank")
	self.button_exchange = self:FindObj("ButtonExhange")
	self.button_market = self:FindObj("ButtonMarket")
	self.button_shop = self:FindObj("ButtonShop")
	self.button_setting = self:FindObj("ButtonSetting")
	self.button_daily_charge = self:FindObj("ButtonDailyCharge")
	self.button_firstchargeview = self:FindObj("ButtonFirstCharge")
	self.button_investview = self:FindObj("ButtonInvest")
	self.button_molongmibaoview = self:FindObj("ButtonMolongMibaoView")
	self.button_camp = self:FindObj("ButtonCamp")
	self.button_militaryrank = self:FindObj("ButtonMilitaryRank")
	self.button_dimai = self:FindObj("ButtonDiMai")

	--self.button_runetowerview = self:FindObj("ButtonRuneTower")
	self.button_rune = self:FindObj("ButtonRune")
	self.button_shenqi = self:FindObj("ButtonShenQi")
	self.button_shengeview = self:FindObj("ButtonShenGeView")
	self.button_redequip = self:FindObj("ButtonRedEquip")
	self.task_contents = self:FindObj("TaskContents")
	self.task_shrink_button = self:FindObj("TaskShrinkButton")
	self.show_gatherbar_worship = self:FindObj("ShowWorshipBarCityCombat")
	self.show_gatherbar_worship:SetActive(false)
	self.gather_bar = self.show_gatherbar_worship:GetComponent(typeof(UnityEngine.UI.Slider))

	self.show_gb_gatherbar_worship = self:FindObj("ShowWorshipBarGuildBattle")
	self.show_gb_gatherbar_worship:SetActive(false)
	self.gb_gather_bar = self.show_gb_gatherbar_worship:GetComponent(typeof(UnityEngine.UI.Slider))

	self.task_shrink_button_animator = self.task_shrink_button.animator
	self.task_shrink_button.toggle:AddValueChangedListener(BindTool.Bind(self.OnTaskShrinkToggleChange, self))

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

	--引导用按钮
	self.menu_icon = self:FindObj("MenuIcon")
	self.shrink_button = self:FindObj("ShrinkButton")
	self.shrink_button.toggle.isOn = true
	
	self.boss_icon = self:FindObj("BossIcon")
	self.button_package = self:FindObj("ButtonPackage")

	self.button_baoju = self:FindObj("ButtonBaoju")
	self.button_kaifuactivityview = self:FindObj("ButtonKaifuactivity")

	self.MenuIconToggle = self.menu_icon.toggle
	self.MenuIconToggle:AddValueChangedListener(BindTool.Bind(self.OnMenuIconToggleChange,self))
	self.button_magicweaponview = self:FindObj("ButtonMoQi")
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
	self.button_petview = self:FindObj("ButtonPet")
	self.button_molong = self:FindObj("ButtonMoLong")
	self.button_mieshizhizhan = self:FindObj("ButtonTarget")
	-- self.button_strength = self:FindObj("ButtonStrength")
	self.button_CollectGoals = self:FindObj("ButtonMieshiWar")
	--self.button_shengeview = self:FindObj("ButtonShenGeView")
	self.button_zero_gift = self:FindObj("ButtonZeroGift")
	self.button_royal_tomb = self:FindObj("ButtonRoyalTomb")
	self.button_NationalWarfare = self:FindObj("ButtonNationalWarfare")
	self.red_blood_effect = self:FindObj("RedBloodEffect")
	self.day_activity_name_content = self:FindObj("DayActivityNameContent")
	local role_vo = PlayerData.Instance:GetRoleVo()
	self:SetRedBloodEffect(role_vo.hp, role_vo.max_hp)

	self.top_buttons = self:FindObj("TopButtons")
	self.top_buttons_animator = self.top_buttons:GetComponent(typeof(UnityEngine.Animator))

	-- 创建子View
	self.player_info = self:FindObj("PlayerInfo")
	self.player_view = MainUIViewPlayer.New(self:FindObj("PlayerInfo"))
	self.target_view = MainUIViewTarget.New(self:FindObj("TargetInfo"))
	self.skill_view = MainUIViewSkill.New(self:FindObj("SkillControl"), self)
	self.general_skill_view = GeneralSkillView.New(self:FindObj("GeneralSkill"), self)
	self.map_view = MainUIViewMap.New(self:FindObj("MapInfo"))
	self.task_view = MainUIViewTask.New(self:FindObj("TaskInfo"))
	self.task_view:SetPackage(self.button_package)
	self.team_view = MainUIViewTeam.New(self:FindObj("TeamInfo"))
	-- self.notify_view = MainUIViewNotify.New(self:FindObj("NotifyBanner"))
	self.chat_view = MainUIViewChat.New(self:FindObj("ChatWindow"))
	self.joystick_view = MainUIViewJoystick.New(self:FindObj("Joystick"))
	self.exp_view = MainUIViewExp.New(self:FindObj("ExpInfo"))
	self.reminding_view = MainUIViewReminding.New(self:FindObj("Reminding"))
	self.function_trailer = MainUIFunctiontrailer.New(self:FindObj("FunctionTrailer"))
	self.hide_show_view = MainUIViewHideShow.New(self:FindObj("HideShowPanel"))
	self.first_recharge_view = MainUIFirstCharge.New(self:FindObj("ButtonFirstCharge2"))

	-- 监听值改变
	self.team_button.toggle:AddValueChangedListener(BindTool.Bind(self.TeamTabChange, self))

	-- 监听系统事件
	self.guaji_change = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE,
		BindTool.Bind(self.OnGuajiTypeChange, self))
	self.red_point_change = GlobalEventSystem:Bind(MainUIEventType.CHANGE_RED_POINT,
		BindTool.Bind(self.ChangeRedPoint, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
	RemindManager.Instance:Bind(self.remind_change, RemindName.BeStrength)

	self.show_rebate_change = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_REBATE_BUTTON,
		BindTool.Bind(self.ShowRebateButton, self))
	self.change_mainui_button = GlobalEventSystem:Bind(MainUIEventType.CHANGE_MAINUI_BUTTON,
		BindTool.Bind(self.SetButtonVisible, self))

	--监听右上角列表事件
	self.top_buttons_animator:ListenEvent("TopListVisible", BindTool.Bind(self.TopRightVisible, self))

	self.show_switch_button = self:FindVariable("ShowSwitchBtn")
	self.show_switch_buttons = self:FindVariable("ShowSwitchBtns")
	self.Show_Daily_Charge = self:FindVariable("Show_Daily_Charge")
	self.show_kaifuactivityview_btn = self:FindVariable("ShowNewServer")
	self.show_kaifu_charge_view_btn = self:FindVariable("ShowKaifuCharge")
	self.show_beauty_icon = self:FindVariable("Show_Beauty_Icon")
	self.show_redequip_icon = self:FindVariable("ShowRedEquip")
	self.show_royal_tomb_icon = self:FindVariable("ShowRoyalTomb")
	self.show_dimai_icon = self:FindVariable("ShowDiMaiIcon")
	self.show_goddess_icon = self:FindVariable("Show_Goddess_Icon")
	self.show_exchange_icon = self:FindVariable("Show_Exchange_Icon")
	self.show_shop_icon = self:FindVariable("Show_Shop_Icon")
	self.show_market_icon = self:FindVariable("Show_Market_Icon")
	self.show_setting_icon = self:FindVariable("Show_Setting_Icon")
	self.show_player_icon = self:FindVariable("Show_Player_Icon")
	self.show_forge_icon = self:FindVariable("Show_Forge_Icon")
	self.show_advance_icon = self:FindVariable("Show_Advance_Icon")
	self.show_skill_icon = self:FindVariable("Show_Skill_Icon")
	self.show_spiritview_icon = self:FindVariable("Show_Spirit_Icon")
	self.show_magicweaponview_icon = self:FindVariable("Show_MoQi_Icon")
	self.show_camp_icon = self:FindVariable("Show_Camp_Icon")
	self.show_guild_icon = self:FindVariable("Show_Guild_Icon")
	self.show_sociality_icon = self:FindVariable("Show_Sociality_Icon")
	self.show_marriage_icon = self:FindVariable("Show_Marry_Icon")
	self.show_ranking_icon = self:FindVariable("Show_Rank_Icon")
	self.show_collect_icon = self:FindVariable("Show_Collect_Icon")
	self.show_petview_icon = self:FindVariable("Show_Pet_Icon")
	self.show_vipview_icon = self:FindVariable("Show_Vip_Icon")
	self.show_helperview_icon = self:FindVariable("Show_Helper_Icon")
	self.show_welfare_icon = self:FindVariable("Show_Welfare_Icon")
	self.show_jingcaiactivity_icon = self:FindVariable("Show_JingCaiActivity_Icon")
	self.show_gopawnview_icon = self:FindVariable("Show_GoPawn_Icon")
	self.show_treasure_icon = self:FindVariable("Show_XunBao_Icon")
	self.show_investview_icon = self:FindVariable("Show_Invest_Icon")
	self.show_rebateview_icon = self:FindVariable("Show_BaiBei_Icon")
	self.show_firstchargeview_icon = self:FindVariable("Show_ShouChong_Icon")
	self.show_kuafufubenview_icon = self:FindVariable("Show_DuoRenFuBen_Icon")
	self.show_boss_icon = self:FindVariable("Show_Boss_Icon")
	self.show_activity_icon = self:FindVariable("Show_ActivityRoom_Icon")
	self.show_chongzhi_icon = self:FindVariable("Show_ChongZhi_Icon")
	self.show_daily_icon = self:FindVariable("Show_EveryDayDo_Icon")
	self.show_baoju_icon = self:FindVariable("Show_Baoju_Icon")
	self.show_fuben_icon = self:FindVariable("Show_SingleFuBen_Icon")
	self.show_reincarnation_icon = self:FindVariable("Show_ZhuanSheng_Icon")
	self.show_compose_icon = self:FindVariable("Show_Compose_Icon")
	self.show_scoiety_icon = self:FindVariable("Show_Scoiety_Icon")
	self.show_molong_icon = self:FindVariable("Show_MoLong_Icon")
	-- self.show_guildchat_res = self:FindVariable("ShowGuildChatRes")
	self.show_rune_icon = self:FindVariable("Show_Rune_Icon")
	self.show_first_charge = self:FindVariable("Show_FirstCharge")
	self.show_logingift7view_icon = self:FindVariable("Show_SevenLogin_Icon")
	self.show_molongmibaoview_icon = self:FindVariable("Show_MolongMibao")
	--self.show_runetowerview_icon = self:FindVariable("ShowRuneTower")
	self.show_CollectGoals_icon = self:FindVariable("ShowMieshiWar")
	self.show_CollectGoals_image = self:FindVariable("ShowMieshiImage")
	--self.show_shengeview_icon = self:FindVariable("Show_ShenGe_Icon")
	self.show_daily_leiji = self:FindVariable("ShowDailyLeiJi")
	self.show_zero_gift_icon = self:FindVariable("ShowZeroGiftIcon")
	self.show_zero_gift_eff = self:FindVariable("ShowZeroGiftEff")
	self.show_NationalWarfare_icon = self:FindVariable("ShowNationalWarfareIcon")
	self.show_activity_hall_eff = self:FindVariable("ShowActivityHallEff")
	self.show_activity_hall_icon = self:FindVariable("ShowActivityHall")
	self.activity_hall_img = self:FindVariable("ActivityHallImg")
	self.show_recharge_icon = self:FindVariable("show_recharge_icon")
	self.charge_double = self:FindVariable("DoubleCharge")
	self.charge_double_shake = self:FindVariable("DoubleChargeShake")
	self.show_threecharge_icon = self:FindVariable("show_threecharge_icon")
	self.show_activity_hall_icon:SetValue(#ActivityData.Instance:GetActivityHallDatalist() > 0)
	self.show_activity_hall_eff:SetValue(true)
	self.show_monster_siege_icon = self:FindVariable("ShowMonsterSiege")
	self.show_span_battle_icon = self:FindVariable("ShowSpanBattle")

	self.is_show_player_info = self:FindVariable("IsShowPlayerInfo")
	self.is_show_temp_mount = self:FindVariable("ShowTempMount")
	self.is_show_temp_wing = self:FindVariable("ShowTempWing")
	self.is_full_bag = self:FindVariable("IsFullBag")
	self.hide_map = self:FindVariable("HideMap")
	self.jingcaiact_img = self:FindVariable("JingCaiActImg")
	self.show_activite_hongbao = self:FindVariable("Show_Activite_HongBao")
	self.show_charge_panel = self:FindVariable("Show_Charge_panel")
	self.has_first_recharge = self:FindVariable("HasFirstRecharge")
	self.show_gold_member_icon = self:FindVariable("ShowMemberBtn")
	self.show_leichong_icon = self:FindVariable("ShowLeiChongIcon")
	self.show_mieshizhizhan_icon = self:FindVariable("ShowTarget")
	self.show_person_target = self:FindVariable("ShowPersonTarget")
	self.bipin_time = self:FindVariable("BiPinTime")
	self.member_repdt = self:FindVariable("MemberRepdt")
	self.show_kf_battle_icon = self:FindVariable("Show_KFBattle_Icon")
	--self.rune_tower_time = self:FindVariable("RuneTowerTime")
	--self:CheckRunetowerCountDown()
	self.is_open_kaifuact = self:FindVariable("IsOpenKaifuAct")
	self.is_open_kaifuact:SetValue(ActivityData.Instance:GetActivityIsOpen(KaifuActivityType.TYPE))
	self.show_jubaopen_icon = self:FindVariable("ShowJuBaoPen")
	self.show_worship_entrance = self:FindVariable("show_citycombat_worship")
	self.show_gb_worship_btn = self:FindVariable("show_guildbattle_worship_btn")
	self.show_cc_worship_btn = self:FindVariable("show_citycombat_worship_btn")
	self.show_famousgeneralview_icon = self:FindVariable("ShowGeneral")
	self.show_militaryrank_icon = self:FindVariable("ShowJunXian")
	self.btn_junxian = self:FindObj("ButtonJunXian")
	self.junxian_img = self:FindVariable("JunXianImg")
	self.show_shenqi_icon = self:FindVariable("ShowShenqi")
	self.world_boss_time = self:FindVariable("WorldBossTime")
	self.banzhuan_time = self:FindVariable("BanZhuanTime")
	self.show_fb_icon =self:FindVariable("ShowFuBenIcon")
	self.show_remind_icon =self:FindVariable("ShowRemindIcon")
	self.remind_icon = self:FindObj("ButtonWenXinRemind")
	self.general_btn_bianShen_effect = self:FindObj("BianShenPanel")
	self.kaifu_act_img = self:FindVariable("KaiFuActImg")
	self.show_qitian_LeiChong_icon = self:FindVariable("Show_QiTianLeiChong_Icon")
	self.show_god_drop_gift_icon = self:FindVariable("ShowGodDropGiftIcon")
	self.show_camp_team_icon = self:FindVariable("ShowCampTeam")
	self.happy_bargain_icon = self:FindVariable("HappyBargainIcon")
	self.show_militaryhall_icon = self:FindVariable("ShowMilitaryHallIcon")
	self.show_kuafuhall_icon = self:FindVariable("ShowKuaFuHallIcon")

	--传送倒计时
	self.call_time[1] = self:FindVariable("CountryCallTime")
	self.call_time[2] = self:FindVariable("FamilyCallTime")
	self.call_time[3] = self:FindVariable("TeamCallTime")
	self.is_general = self:FindVariable("IsGeneral")
	self:CheckJuBaoPenIcon()
	self:SetJingcaiActImg()
	self:SetJunXianImg()

	if self.hide_player_info then
		self.is_show_player_info:SetValue(true)
		self.hide_player_info = false
	end

	--在线奖励
	self.show_online_redpoint = self:FindVariable("ShowOnlineRedPoint")
	self.online_time_text = self:FindVariable("OnlineTimeText")
	self.show_online_btn = self:FindVariable("ShowOnlineBtn")
	self.right_online_reward = self:FindObj("RightOnlineReward")
	self.show_online_btn:SetValue(false)

	--分线面板
	self.show_line_btn = self:FindVariable("ShowLineBtn")
	self.line_name = self:FindVariable("LineName")
	self.line_name:SetValue(string.format(Language.Common.Line, 1))

	self.hide_map:SetValue(false)

	self:UpdateShieldMode()
	self:SetAllRedPoint()

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Main, BindTool.Bind(self.GetUiCallBack, self))

	self:SetViewState(self.is_in)

	self:ShowRebateButton()
	self:MainRoleLevelChange()
	self:CameraModeChange()
	self.view_open_event = GlobalEventSystem:Bind(OtherEventType.VIEW_OPEN,
		BindTool.Bind(self.HasViewOpen, self))
	self.view_close_event = GlobalEventSystem:Bind(OtherEventType.VIEW_CLOSE,
		BindTool.Bind(self.HasViewClose, self))

	self.target_time = self:FindVariable("TargetTime")
	self.show_target_cd = self:FindVariable("ShowTargetCd")
	self:SetTargetTimeCountDown()
	self:DayPass()

	self.dachen_time = self:FindVariable("DaChenTime")
	self.guoqi_time = self:FindVariable("GuoQiTime")
	self.dachen_res = self:FindVariable("IconDaChenRes")
	self.flag_res = self:FindVariable("IconFlagRes")
	self.show_bipin = self:FindVariable("ShowBiPin")
	self.show_happy_bargain = self:FindVariable("ShowHappyBargain")
	self.bipin_src = self:FindVariable("BiPinSrc")
	self.shrink_button_repoint = self:FindVariable("ShrinkButtonRepoint")

	self.attack_list = self:FindObj("AttackList")
	local list_delegate = self.attack_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRollNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRoleCell, self)

	self:OnGuajiTypeChange(GuajiCache.event_guaji_type)

	-- 屏蔽变强按钮
	-- self.button_strength:SetActive(RemindManager.Instance:GetRemind(RemindName.BeStrength) > 0)
	self:ChangeCollectiveGoalsImage()

	--判断背包是否满
	local isfullbagshow = (#ItemData.Instance:GetBagItemDataList() + 1) >= COMMON_CONSTS.MAX_BAG_COUNT
	self:OnFulshPackage(isfullbagshow)
	self:ChangeGeneralState()

	self:SetMarryMeActTime()
	self:SetChuJunActTime()
	self:SetSecretrShopTime()
	self:CheckRemindTips()
	self:SetBiPinImg()
end


-- function MainUIView:CheckRunetowerCountDown()
-- 	if nil == self.rune_tower_time then return end
-- 	local rune_info = GuaJiTaData.Instance:GetRuneTowerInfo()
-- 	if rune_info.offline_time then
-- 		local left_hour = math.floor(rune_info.offline_time / 3600)
-- 		local left_min = math.floor((rune_info.offline_time - left_hour * 3600) / 60)
-- 		local temp_str = string.format(Language.Common.TimeStr2, left_hour, left_min)
-- 		if rune_info.offline_time < 3600 then
-- 			temp_str = string.format(Language.Mount.ShowRedStr, temp_str)
-- 		else
-- 			temp_str = string.format(Language.Mount.ShowGreenStr, temp_str)
-- 		end
-- 		self.rune_tower_time:SetValue(temp_str)
-- 	end
-- end

function MainUIView:SetTargetTimeCountDown()
	if self.target_countdown then
		GlobalTimerQuest:CancelQuest(self.target_countdown)
		self.target_countdown = nil
	end
	if not CollectiveGoalsData.Instance or not TimeCtrl.Instance then return end

	self.target_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(function ()
		local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local totle_time = CollectiveGoalsData.Instance:GetActiveTotalDay()
		local server_time = os.date('*t', TimeCtrl.Instance:GetServerTime())
		local day = totle_time - server_open_day
		local hour, min, sec = 23 - server_time.hour, 59 - server_time.min, 59 - server_time.sec
		local time_str = string.format(Language.CollectiveGoals.MainUIActiveTimeStr, day, hour, min, sec)
		self.target_time:SetValue(time_str)
	end), 0.5)
end

function MainUIView:GetCityCombatButtons()
	return self.city_combat_buttons
end

function MainUIView:CheckRemindTips()
	if self.remind_countdown then
		GlobalTimerQuest:CancelQuest(self.remind_countdown)
		self.remind_countdown = nil
	end
	self.remind_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(function ()
		TipsCtrl.Instance:CheckRemindTips()
		local remind_list = TipsRemindData.Instance:GetRemindList()
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		if remind_list and #remind_list > 0 and role_level >= GameEnum.NOVICE_WARM_TIP then
			self.show_remind_icon:SetValue(true)
			self.remind_icon.animator:SetBool("Shake", true)
		else
			self.show_remind_icon:SetValue(false)
			self.remind_icon.animator:SetBool("Shake", false)
		end
	end), 10)
end

function MainUIView:FlushGoalsIcon()
	self.player_view:FlushGoalsIcon()
end

function MainUIView:MainRoleLevelChange()
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	if main_role_lv < 60 then
		self.shrink_button.toggle.isOn = true
	end

	self.show_shrink_btn:SetValue(main_role_lv >= 30 and true or false)
	self.show_charge_effect:SetValue(main_role_lv >= 60 and true or false)
	self.show_save_power:SetValue(main_role_lv >= GameEnum.NOVICE_LEVEL)
	self:SetRandActIcon()
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

	if self.team_view ~= nil then
		self.team_view:DeleteMe()
		self.team_view = nil
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

	if self.first_recharge_view ~= nil then
		self.first_recharge_view:DeleteMe()
		self.first_recharge_view = nil
	end

	if self.hide_show_view ~= nil then
		self.hide_show_view:DeleteMe()
		self.hide_show_view = nil
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

	if self.shield_others then
		GlobalEventSystem:UnBind(self.shield_others)
		self.shield_others = nil
	end

	if self.shield_camp then
		GlobalEventSystem:UnBind(self.shield_camp)
		self.shield_camp = nil
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

	if nil ~= self.guaji_change then
		GlobalEventSystem:UnBind(self.guaji_change)
		self.guaji_change = nil
	end

	if nil ~= self.red_point_change then
		GlobalEventSystem:UnBind(self.red_point_change)
		self.red_point_change = nil
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

	if nil ~= self.main_role_level_change then
		GlobalEventSystem:UnBind(self.main_role_level_change)
		self.main_role_level_change = nil
	end

	if self.main_role_realive ~= nil then
		GlobalEventSystem:UnBind(self.main_role_realive)
		self.main_role_realive = nil
	end

	if self.shrink_btn ~= nil then
		GlobalEventSystem:UnBind(self.shrink_btn)
		self.shrink_btn = nil
	end

	if self.data_listen and ClashTerritoryData.Instance then
		ClashTerritoryData.Instance:RemoveListener(ClashTerritoryData.INFO_CHANGE, self.data_listen)
		self.data_listen = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	self:StopOnlineCountDown()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Main)
	end

	if self.target_countdown then
		GlobalTimerQuest:CancelQuest(self.target_countdown)
		self.target_countdown = nil
	end

	if self.world_boss_countdown then
		GlobalTimerQuest:CancelQuest(self.world_boss_countdown)
		self.world_boss_countdown = nil
	end

	if self.banzhuan_countdown then
		GlobalTimerQuest:CancelQuest(self.banzhuan_countdown)
		self.banzhuan_countdown = nil
	end

	if nil ~= self.count_down then
		GlobalTimerQuest:CancelQuest(self.count_down)
		self.count_down = nil
	end

	if nil ~= self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.camera_mode_change then
		GlobalEventSystem:UnBind(self.camera_mode_change)
		self.camera_mode_change = nil
	end

	if self.dachen_countdown then
		GlobalTimerQuest:CancelQuest(self.dachen_countdown)
		self.dachen_countdown = nil
	end

	if self.guoqi_countdown then
		GlobalTimerQuest:CancelQuest(self.guoqi_countdown)
		self.guoqi_countdown = nil
	end

	if self.marry_me_count_down then
		CountDown.Instance:RemoveCountDown(self.marry_me_count_down)
		self.marry_me_count_down = nil
	end

	if self.chujun_count_down then
		CountDown.Instance:RemoveCountDown(self.chujun_count_down)
		self.chujun_count_down = nil
	end
	
	if self.secretr_shop_down then
		CountDown.Instance:RemoveCountDown(self.secretr_shop_down)
		self.secretr_shop_down = nil
	end
	
	if self.remind_countdown then
		GlobalTimerQuest:CancelQuest(self.remind_countdown)
		self.remind_countdown = nil
	end
	
	self:RemoveActTimeCountDown()

	-- 清理变量和对象
	self.shield_mode = nil
	self.is_in_special_scene = nil
	self.is_show_map_info = nil
	self.hide_vip = nil
	self.show_privite_remind = nil
	self.show_task = nil
	self.show_shield = nil
	self.is_in_task_talk = nil
	self.map_info = nil
	self.show_marry_wedding = nil
	self.wedding_time = nil
	self.default_icon = nil
	self.custom_icon = nil
	self.show_sysinfo = nil
	self.show_shrink_btn = nil
	self.show_charge_effect = nil
	self.show_charge_effect1 = nil
	self.show_charge_effect2 = nil
	self.show_guaji = nil
	self.show_save_power = nil
	self.main_menu_redpoint = nil
	self.auto_button = nil
	self.team_button = nil
	self.privite_remind = nil
	self.privite_role = nil
	self.privite_raw = nil
	self.city_combat_buttons = nil
	self.arrow_image = nil
	self.button_player = nil
	self.button_forge = nil
	self.button_advance = nil
	self.button_beauty = nil
	self.button_goddess = nil
	self.button_famousgeneralview = nil
	self.button_roleskill = nil
	self.button_spiritview = nil
	self.button_head = nil
	self.button_compose = nil
	self.button_guild = nil
	self.button_scoiety = nil
	self.button_marriage = nil
	self.button_ranking = nil
	self.button_exchange = nil
	self.button_market = nil
	self.button_shop = nil
	self.button_setting = nil
	self.button_daily_charge = nil
	self.button_firstchargeview = nil
	self.button_investview = nil
	self.button_molongmibaoview = nil
	self.button_redequip = nil
	--self.button_runetowerview = nil
	self.button_rune = nil
	self.button_shenqi = nil
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
	self.button_baoju = nil
	self.general_btn_bianShen_effect = nil
	self.button_kaifuactivityview = nil
	self.MenuIconToggle = nil
	self.button_magicweaponview = nil
	self.button_logingift7view = nil
	self.button_member = nil
	self.button_welfare = nil
	self.button_gopawnview = nil
	self.button_treasure = nil
	self.button_reincarnation = nil
	self.button_rebateview = nil
	self.button_chongzhi = nil
	self.button_camp = nil
	self.button_militaryrank = nil
	self.button_dimai = nil
	self.button_jingcaiactivity = nil
	self.button_activity = nil
	self.button_boss = nil
	self.button_kuafufubenview = nil
	self.button_fuben = nil
	self.button_vipview = nil
	self.button_helperview = nil
	self.button_petview = nil
	self.button_molong = nil
	self.button_mieshizhizhan = nil
	-- self.button_strength = nil
	self.button_CollectGoals = nil
	self.button_shengeview = nil
	self.button_zero_gift = nil
	self.button_royal_tomb = nil
	self.button_NationalWarfare = nil
	self.button_joystick = nil
	self.day_activity_name_content = nil
	self.red_blood_effect = nil
	self.top_buttons = nil
	self.top_buttons_animator = nil
	self.player_info = nil
	self.show_switch_button = nil
	self.show_switch_buttons = nil
	self.Show_Daily_Charge = nil
	self.show_kaifuactivityview_btn = nil
	self.show_kaifu_charge_view_btn = nil
	self.show_beauty_icon = nil
	self.show_redequip_icon = nil
	self.show_royal_tomb_icon = nil
	self.show_camp_team_icon = nil
	self.show_dimai_icon = nil
	self.show_goddess_icon = nil
	self.show_exchange_icon = nil
	self.show_shop_icon = nil
	self.show_market_icon = nil
	self.show_setting_icon = nil
	self.show_player_icon = nil
	self.show_forge_icon = nil
	self.show_advance_icon = nil
	self.show_skill_icon = nil
	self.show_spiritview_icon = nil
	self.show_magicweaponview_icon = nil
	self.show_camp_icon = nil
	self.show_guild_icon = nil
	self.show_sociality_icon = nil
	self.show_marriage_icon = nil
	self.show_ranking_icon = nil
	self.show_collect_icon = nil
	self.show_petview_icon = nil
	self.show_vipview_icon = nil
	self.show_helperview_icon = nil
	self.show_welfare_icon = nil
	self.show_jingcaiactivity_icon = nil
	self.show_gopawnview_icon = nil
	self.show_treasure_icon = nil
	self.show_investview_icon = nil
	self.show_rebateview_icon = nil
	self.show_firstchargeview_icon = nil
	self.show_kuafufubenview_icon = nil
	self.show_boss_icon = nil
	self.show_activity_icon = nil
	self.show_chongzhi_icon = nil
	self.show_daily_icon = nil
	self.show_baoju_icon = nil
	self.show_fuben_icon = nil
	self.show_fb_icon = nil
	self.show_remind_icon = nil
	self.show_reincarnation_icon = nil
	self.show_compose_icon = nil
	self.show_scoiety_icon = nil
	self.show_molong_icon = nil
	self.show_rune_icon = nil
	self.show_first_charge = nil
	self.show_logingift7view_icon = nil
	self.show_span_battle_icon = nil
	self.show_molongmibaoview_icon = nil
	--self.show_runetowerview_icon = nil
	self.show_CollectGoals_icon = nil
	self.show_CollectGoals_image = nil
	self.is_show_player_info = nil
	self.is_show_temp_mount = nil
	self.is_show_temp_wing = nil
	self.is_full_bag = nil
	self.hide_map = nil
	self.jingcaiact_img = nil
	self.show_activite_hongbao = nil
	self.show_charge_panel = nil
	self.has_first_recharge = nil
	self.show_gold_member_icon = nil
	self.show_leichong_icon = nil
	self.show_mieshizhizhan_icon = nil
	self.show_person_target = nil
	self.member_repdt = nil
	self.show_kf_battle_icon = nil
	self.rune_tower_time = nil
	self.is_open_kaifuact = nil
	self.show_online_redpoint = nil
	self.online_time_text = nil
	self.show_online_btn = nil
	self.show_line_btn = nil
	self.line_name = nil
	self.target_time = nil
	self.show_target_cd = nil
	self.show_shengeview_icon = nil
	self.show_shen_ge_effect = nil
	self.button_package = nil
	self.show_daily_leiji = nil
	self.show_jubaopen_icon = nil
	self.show_zero_gift_icon = nil
	self.show_zero_gift_eff = nil
	self.show_NationalWarfare_icon = nil
	self.show_gb_gatherbar_worship = nil
	self.show_gb_worship_btn = nil
	self.show_worship_entrance = nil
	self.show_shenqi_icon = nil
	self.gather_bar = nil
	self.gb_gather_bar = nil
	self.is_general = nil
	self.show_cc_worship_btn = nil
	self.general_skill_view = nil
	self.show_gatherbar_worship = nil
	self.dachen_time = nil
	self.guoqi_time = nil
	self.world_boss_time = nil
	self.banzhuan_time = nil
	self.dachen_res = nil
	self.flag_res = nil
	self.show_bipin = nil
	self.bipin_src = nil
	self.bipin_time = nil
	self.shrink_button_repoint = nil
	self.show_monster_siege_icon = nil

	self.hideable_button_list = nil
	self.act_btn_time_list = nil
	self.act_btn_time_list2 = nil
	self.act_effect_list = nil
	self.act_effect_list_2 = nil
	self.show_famousgeneralview_icon = nil
	self.show_militaryrank_icon = nil
	self.junxian_img = nil
	self.show_happy_bargain = nil
	self.happy_bargain_icon = nil
	self.show_kuafuhall_icon = nil
	self.show_militaryhall_icon = nil

	self.tweener = nil
	self.gb_tweener = nil
	self.call_index = nil
	self.camera_mode = nil
	self.is_free_camera = nil
	self.scene_camera_effect = nil
	self.transfer_time_quest = {}
	self.transfer_begin_time = {}
	self.call_time = {}
	-- self.set_call_btn_gray = {}
	self.transfer_reminding_name = {}
	self.red_point_list = {}
	self.show_activity_hall_icon = nil
	self.show_activity_hall_eff = nil
	self.activity_hall_img = nil
	self.show_recharge_icon = nil
	self.show_threecharge_icon = nil
	self.kaifu_act_img = nil
	self.kaifu_act_img = nil
	self.show_qitian_LeiChong_icon = nil
	self.right_online_reward = nil
	self.remind_icon = nil
	self.btn_junxian = nil
	self.charge_double = nil
	self.charge_double_shake = nil
	self.attack_list = nil
	self.show_god_drop_gift_icon = nil
	self.show_adventure_shop_icon = nil
	self.panel = nil
end

function MainUIView:OpenCallBack()
	self:FlushChargeIcon()
	self:InitOpenFunctionIcon()
	self.player_view:FlushGoalsIcon()
	self:Flush()
	self.player_view:OpenToFlush()
	GlobalTimerQuest:AddDelayTimer(function()
		GlobalEventSystem:Fire(MainUIEventType.MAINUI_OPEN_COMLETE)
	end, 0)
	self:ChangeFunctionTrailer()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	self:ChangeRewardItemByLevel(level)
	FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
	FuBenCtrl.Instance:SendGetExpFBInfoReq()
	FuBenCtrl.Instance:SendGetStoryFBGetInfo()
	FuBenCtrl.Instance:SendGetVipFBGetInfo()
	FuBenCtrl.Instance:SendGetTowerFBGetInfo()
	self:IsDoubleRechargeShake()

	self:Flush("check_show_mount")
	self:Flush("mount_change")
end

--是否显示功能预告
function MainUIView:ChangeFunctionTrailer()
	local cur_trailer_cfg = OpenFunData.Instance:GetCurTrailerCfg()
	if self.function_trailer then
		self.function_trailer:FlushView(cur_trailer_cfg)
	end
end

function MainUIView:ChangeRewardItemByLevel(level)
	if self.function_trailer then
		self.function_trailer:FlushRewardItem(level)
	end
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
	end
end

function MainUIView:FlushBeAtkIconState(role_vo)
	if self.reminding_view then
		self.reminding_view:SetBeAtkIconState(role_vo)
	end
end

function MainUIView:SetFunctionTrailerState(state)
	-- self.show_function_trailer:SetValue(state)
end

function MainUIView:TopRightVisible(state)
	state = state == "1" and true or false
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_TOP_RIGHT_BUTTON, state)
end

function MainUIView:ShowRebateButton(is_show)
	if nil ~= DailyChargeData.Instance then
		local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
		local is_show = is_show or RebateCtrl.Instance:GetBuyState()
		if self.show_rebateview_icon then
			self.show_rebateview_icon:SetValue(history_recharge >= DailyChargeData.Instance:GetMinRecharge() and is_show and OpenFunData.Instance:CheckIsHide("rebateview"))
		end
	end
end

function MainUIView:CheckRechargeIcon(is_show)
	local is_can_show1 = DailyChargeData.Instance:GetThreeRechargeOpen(1)
	local is_can_show2 = DailyChargeData.Instance:GetThreeRechargeOpen(2)
	local is_can_show3 = DailyChargeData.Instance:GetThreeRechargeOpen(3)
	self.show_recharge_icon:SetValue(is_can_show2)
	self.show_firstchargeview_icon:SetValue(is_can_show1)
	self.show_threecharge_icon:SetValue(is_can_show3)
	local show_double = false
	local charge_list = RechargeData.Instance:GetRechargeIdList()
	for k,v in pairs(charge_list) do
		local id = v >= 3 and (v - 1) or v
		if DailyChargeData.Instance:CheckIsFirstRechargeById(id) then
			show_double = true
		end
	end
	self.charge_double:SetValue(show_double)
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

	if old_scene_type ~= new_scene_type then
		self.fight_state_button.toggle.isOn = false
	end
	-- Scene.SendReqTeamMemberPos()
	self:ChangeFunctionTrailer()
	self.need_delay = true

	-- 中立boss列表
	local scene_id = Scene.Instance:GetSceneId()
	if new_scene_type == SceneType.Common and BossData.IsNeutralBossScene(scene_id) and not IS_ON_CROSSSERVER then
		if OpenFunData.Instance:CheckIsHide("neutral_boss") then
			self.show_switch_button:SetValue(true)
			if BossData.Instance:GetIsSetCurInfo() then
				self:SetViewState(false)
				if not ViewManager.Instance:IsOpen(ViewName.BossFamilyInfoView) then
					ViewManager.Instance:Open(ViewName.BossFamilyInfoView)
				end
				if self.MenuIconToggle.isOn then
					self.MenuIconToggle.isOn = false
				end
			end
		end
	else
		if not BossData.IsMikuBossScene(scene_id) and not BossData.IsFamilyBossScene(scene_id) and not BossData.IsBabyBossScene(scene_id) then
			if ViewManager.Instance:IsOpen(ViewName.BossFamilyInfoView) then
				if not ViewManager.Instance:IsOpen(ViewName.DaFuHao) and new_scene_type == SceneType.Common and not BossData.IsWorldBossScene(scene_id) then
					self:SetViewState(true)
					self.show_switch_button:SetValue(false)
				end
				ViewManager.Instance:Close(ViewName.BossFamilyInfoView)
				BossData.Instance:SetCurInfo(nil, nil)
			end
		end
	end
end

function MainUIView:ChangeMenuState()
	if ViewManager.Instance:IsOpen(ViewName.FbIconView) then
		self.map_info:SetValue(self.MenuIconToggle.isOn)
		self.player_view:ShowRightBtns(self.MenuIconToggle.isOn)
		self.target_view:ChangeToHigh(self.MenuIconToggle.isOn)
	elseif ViewManager.Instance:IsOpen(ViewName.MountFuBenView)
		or ViewManager.Instance:IsOpen(ViewName.WingFuBenView)
		or ViewManager.Instance:IsOpen(ViewName.JingLingFuBenView) then
		self.map_info:SetValue(false)
	else
		self.map_info:SetValue(true)
		self.player_view:ShowRightBtns(true)
		self.target_view:ChangeToHigh(true)
	end
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type then
		if scene_type == SceneType.Kf_OneVOne then
			self.map_info:SetValue(false)
		end
		self.show_fb_icon:SetValue(scene_type == SceneType.Common)
	end
	if IS_ON_CROSSSERVER then
		if scene_type and scene_type ~= SceneType.KfMining and scene_type ~= SceneType.Fishing and scene_type ~= SceneType.CrossGuildBattle then
			self.map_info:SetValue(false)
		end
	end
	self.skill_view:OnFlush({skill = true})
end

function MainUIView:ClashTerritoryDataChangeCallback()
	self.skill_view:OnFlush({skill = true})
end


function MainUIView:GoddessSkillTipsClose()
	if self.skill_view then
		self.skill_view:OnFlush({goddess_skill_tips = true})
	end
end

function MainUIView:SetViewState(is_in)
	if is_in then
		if self.task_shrink_button then
			-- if self.MenuIconToggle then
			-- 	self.task_shrink_button.canvas_group.alpha = self.MenuIconToggle.isOn and 0 or 1
			-- 	self.task_contents.canvas_group.alpha = self.MenuIconToggle.isOn and 0 or 1
			-- 	self.task_tab_btn.canvas_group.alpha = self.MenuIconToggle.isOn and 0 or 1
			-- else
				-- self.task_shrink_button.canvas_group.alpha = 1
				-- self.task_contents.canvas_group.alpha = 1
			-- end
		end
	end

	if self.is_in_special_scene then
		self.is_in_special_scene:SetValue(is_in)
		if self.left_track_animator.isActiveAndEnabled then
			if self.MenuIconToggle then
				self.left_track_animator:SetBool("fade", self.MenuIconToggle.isOn)
				self.task_tab_btn_animator:SetBool("fade", self.MenuIconToggle.isOn)
				self.task_shrink_button_animator:SetBool("fade", self.MenuIconToggle.isOn)
			else
				self.left_track_animator:SetBool("fade", false)
				self.task_tab_btn_animator:SetBool("fade", false)
				self.task_shrink_button_animator:SetBool("fade", false)
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
		self.show_logingift7view_icon:SetValue(is_show)
	end
end

function MainUIView:SetShowSpanBattleIcon(is_show)
	if self.show_span_battle_icon then
		self.show_span_battle_icon:SetValue(is_show)
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
		if self.wedding_time then 
			self.wedding_time:SetValue(time_str)
		end
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
	local level = PlayerData.Instance:GetRoleLevel()
	if lover_id and lover_id > 0 and level >= 50 then
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
		local value = OpenFunData.Instance:CheckIsHide("kaifuactivityview")
		self.show_kaifuactivityview_btn:SetValue(value or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER))
	end
	if self.show_kaifu_charge_view_btn then
		local value = OpenFunData.Instance:CheckIsHide("kaifuchargeview")
		self.show_kaifu_charge_view_btn:SetValue(KaifuActivityData.Instance:IsShowKaifuIcon() and value)
	end
end

function MainUIView:SetIsFinishTarget(is_show)
	self.show_person_target:SetValue(is_show)
end

-- 显示膜拜的采集进度条
function MainUIView:ShowWorshipGatherBar()
	self.show_gatherbar_worship:SetActive(true)
	self.gather_bar.value = 0
	if self.tweener then
		self.tweener:Pause()
	end
	self.tweener = self.gather_bar:DOValue(1, 3, false)
	self.tweener:SetEase(DG.Tweening.Ease.Linear)
	self.tweener:OnComplete(function ()
		self.show_gatherbar_worship:SetActive(false)	
	end)
end

--显示公会争霸的膜拜采集进度条
function MainUIView:ShowGuildBattleWorshipGatherBar()
	self.show_gb_gatherbar_worship:SetActive(true)

	local addexp_timestamp = GuildFightData.Instance:GetWorshipInfo().next_addexp_timestamp - TimeCtrl.Instance:GetServerTime()
	local time = os.date("%S", addexp_timestamp)

	self.gb_gather_bar.value = 0
	if self.gb_tweener then
		self.gb_tweener:Pause()
	end
	self.gb_tweener = self.gb_gather_bar:DOValue(1, time, false)
	self.gb_tweener:SetEase(DG.Tweening.Ease.Linear)
	self.gb_tweener:OnComplete(function ()
		self.show_gb_gatherbar_worship:SetActive(false)	
	end)
end

-- 显示抢皇帝膜拜传送按钮
function MainUIView:ShowWorshipEntrance(value)
	-- local worship_is_open =CityCombatData.Instance:GetWorshipIsOpen()
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	local limit_level = CityCombatData.Instance:GetOtherConfig().worship_level_limit
	if self.show_worship_entrance then
		self.show_worship_entrance:SetValue(main_role.level >= limit_level and value)
		if value == true then
			--self:SetWorshipTimeCountDown()
		end
	end
end

function MainUIView:ChangeDoubleEscortState()
	if not CampData.Instance:GetCampYunbiaoIsOpen() then return end
	if self.husong_countdown then
		GlobalTimerQuest:CancelQuest(self.husong_countdown)
		self.husong_countdown = nil
	end
	self.husong_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(function ()
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG) then
			return
		end
		local time = CampData.Instance:GetCampYunbiaoStatus() - TimeCtrl.Instance:GetServerTime()
		local time_str = time >= 3600 and TimeUtil.FormatSecond(time, 1) or TimeUtil.FormatSecond(time, 2)
		if self.act_btn_time_list then
			self.act_btn_time_list[ACTIVITY_TYPE.HUSONG]:SetValue(time_str)
		end
		self:SetButtonVisible(MainUIData.RemindingName.Double_Escort, CampData.Instance:GetCampYunbiaoIsOpen())
	end), 0.5)
end

function MainUIView:ChangeDaChenState()
	if nil == self.dachen_time then return end

	if self.dachen_countdown then
		GlobalTimerQuest:CancelQuest(self.dachen_countdown)
		self.dachen_countdown = nil
	end
	local total_standy_time = NationalWarfareData.Instance:GetDaChenStandbyCD() + TimeCtrl.Instance:GetServerTime()
	self.dachen_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(function ()
		local standy_time = total_standy_time - TimeCtrl.Instance:GetServerTime()
		local _, act_time = NationalWarfareData.Instance:GetDaChenStatus()
		local time_str = ""
		if standy_time > 0 then
			time_str = standy_time >= 3600 and TimeUtil.FormatSecond(standy_time, 1) or TimeUtil.FormatSecond(standy_time, 2)
			if nil ~= self.dachen_time then
				self.dachen_time:SetValue(ToColorStr(time_str, TEXT_COLOR.RED))
			end
		else
			time_str = act_time >= 3600 and TimeUtil.FormatSecond(act_time, 1) or TimeUtil.FormatSecond(act_time, 2)
		end
		if self.dachen_time then
			self.dachen_time:SetValue(ToColorStr(time_str, TEXT_COLOR.GREEN_5))
		end
	end), 0.5)
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
	local camp_dachen = NationalWarfareData.Instance:GetCampDachen()
	local is_open = NationalWarfareData.Instance:GetDaChenStatus()
	if mainrole_vo.camp == camp_dachen then
		local bundle, asset = ResPath.GetMainUIButton("Icon_Protect_DaChen")
		self.dachen_res:SetAsset(bundle, asset)
	else
		local bundle, asset = ResPath.GetMainUIButton("Icon_Kill_DaChen")
		self.dachen_res:SetAsset(bundle, asset)
	end
	local level = PlayerData.Instance:GetRoleLevel()
	if level >= 70 then
		self:SetButtonVisible(MainUIData.RemindingName.DaChen, is_open)
	end
end

function MainUIView:ChangeGuoQiState()
	if nil == self.guoqi_time then return end

	if self.guoqi_countdown then
		GlobalTimerQuest:CancelQuest(self.guoqi_countdown)
		self.guoqi_countdown = nil
	end
	local total_standy_time = NationalWarfareData.Instance:GetGuoQiStandbyCD() + TimeCtrl.Instance:GetServerTime()
	self.guoqi_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(function ()
		local standy_time = total_standy_time - TimeCtrl.Instance:GetServerTime()
		local _, act_time = NationalWarfareData.Instance:GetGuoQiStatus()
		local time_str = ""
		if standy_time > 0 then
			time_str = standy_time >= 3600 and TimeUtil.FormatSecond(standy_time, 1) or TimeUtil.FormatSecond(standy_time, 2)
		else
			time_str = act_time >= 3600 and TimeUtil.FormatSecond(act_time, 1) or TimeUtil.FormatSecond(act_time, 2)
		end
		if nil ~= self.guoqi_time then
			self.guoqi_time:SetValue(ToColorStr(time_str, TEXT_COLOR.GREEN_5))
		end
	end), 0.5)
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
	local camp_guoqi = NationalWarfareData.Instance:GetCampGuoQi()
	local is_open = NationalWarfareData.Instance:GetGuoQiStatus()
	if mainrole_vo.camp == camp_guoqi then
		local bundle, asset = ResPath.GetMainUIButton("Icon_Protect_Flag")
		self.flag_res:SetAsset(bundle, asset)
	else
		local bundle, asset = ResPath.GetMainUIButton("Icon_Kill_Flag")
		self.flag_res:SetAsset(bundle, asset)
	end
	local level = PlayerData.Instance:GetRoleLevel()
	if level >= 70 then
		self:SetButtonVisible(MainUIData.RemindingName.GuoQi, is_open)
	end
end

--福利boss按钮状态
function MainUIView:ChangeWorldBossState()
	if nil == self.world_boss_time then return end

	local world_boss_info = BossData.Instance:GetCommonActivityInfo()
	if not world_boss_info or not next(world_boss_info) then return	end
	
	if self.world_boss_countdown then
		GlobalTimerQuest:CancelQuest(self.world_boss_countdown)
		self.world_boss_countdown = nil
	end

	if world_boss_info.status == COMMON_ACTIVITY_STATUS_TYPE.COMMON_ACTIVITY_STATUS_TYPE_STANDBY then
		self.world_boss_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(function ()
			local standy_time = world_boss_info.param_1 - TimeCtrl.Instance:GetServerTime()
			local time_str = standy_time >= 3600 and TimeUtil.FormatSecond(standy_time, 3) or TimeUtil.FormatSecond(standy_time, 2)	
			self.world_boss_time:SetValue(ToColorStr(time_str, TEXT_COLOR.RED))
		end), 0)
	elseif world_boss_info.status == COMMON_ACTIVITY_STATUS_TYPE.COMMON_ACTIVITY_STATUS_TYPE_OPEN then
		self.world_boss_time:SetValue(ToColorStr(Language.Activity.KaiQiZhong, TEXT_COLOR.GREEN_5))
	end
	local level = PlayerData.Instance:GetRoleLevel()
	if level >= 50 then
		self:SetButtonVisible(MainUIData.RemindingName.WorldBoss, world_boss_info.status > 0)
	end
end

-- 搬砖按钮状态
function MainUIView:ChangeBanZhuanState()
	if nil == self.banzhuan_time then return end

	local banzhuan_info = CampData.Instance:GetCampCommonInfo()
	if not banzhuan_info or not next(banzhuan_info) then return end
	
	if self.banzhuan_countdown then
		GlobalTimerQuest:CancelQuest(self.banzhuan_countdown)
		self.banzhuan_countdown = nil
	end

	local banzhuan_open = NationalWarfareData.Instance:GetCampBanZhuanIsOpen()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if banzhuan_open and main_role_vo.level >= 50 then
		self:SetButtonVisible(MainUIData.RemindingName.BanZhuan, true)
		self.banzhuan_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(function ()
			local standy_time = banzhuan_info.param3 - TimeCtrl.Instance:GetServerTime()
			local time_str = standy_time >= 3600 and TimeUtil.FormatSecond(standy_time, 3) or TimeUtil.FormatSecond(standy_time, 2)	
			self.banzhuan_time:SetValue(ToColorStr(time_str, TEXT_COLOR.GREEN_5))
			if standy_time <= 0 then
				self:SetButtonVisible(MainUIData.RemindingName.BanZhuan, false)
				if self.banzhuan_countdown then
					GlobalTimerQuest:CancelQuest(self.banzhuan_countdown)
					self.banzhuan_countdown = nil
				end
			end
		end), 0)
	else
		self:SetButtonVisible(MainUIData.RemindingName.BanZhuan, false)
	end
end

function MainUIView:CameraModeChange(param_1, param_2)
	if param_2 then
		if self.is_free_camera then
			self.camera_flag = param_2
			-- self.camera_mode:SetValue(param_2 + 1)
			self.is_free_camera:SetValue(flag == 1 and SceneType.ExpFb ~= Scene.Instance:GetSceneType() and Scene.Instance:GetSceneId() ~= 3153)
		end
	else
		local guide_flag_list = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_KEY_FLAG)
		local flag = guide_flag_list.item_id or 0
		if PlayerData.Instance.role_vo.hold_beauty_npcid > 0 then
			flag = self.camera_flag or 0
			if flag <= 0 then
				flag = 0
			end
		end
		if self.is_free_camera then
			-- self.camera_mode:SetValue(flag + 1)
			self.is_free_camera:SetValue(flag == 1 and SceneType.ExpFb ~= Scene.Instance:GetSceneType() and Scene.Instance:GetSceneId() ~= 3153)
		end
	end
end

function MainUIView:OnClickCameraMode()
	if PlayerData.Instance.role_vo.hold_beauty_npcid > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CameraBeautyLimit)
		return 
	end
	
	if Scene.Instance:GetSceneType() == SceneType.ExpFb or (Scene.Instance:GetSceneType() == SceneType.CrossGuildBattle and Scene.Instance:GetSceneId() == 3153) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CameraExpFbLimit)
	end

	local guide_flag_list = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_KEY_FLAG)
	local flag = guide_flag_list.item_id or 0
		flag = flag + 1
	if flag >= GameEnum.MAX_CAMERA_MODE then
		flag = 0
	end
	self.camera_flag = flag
	Scene.Instance:SetCameraMode(flag)
	-- self.camera_mode:SetValue(flag + 1)
	self.is_free_camera:SetValue(flag == 1 and SceneType.ExpFb ~= Scene.Instance:GetSceneType() and Scene.Instance:GetSceneId() ~= 3153)
	
	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.CAMERA_KEY_FLAG, flag)
	SettingData.Instance:SetSettingDataListByKey(HOT_KEY.CAMERA_KEY_FLAG, flag)
end

function MainUIView:OnFlush(param_t)
	self.skill_view:OnFlush(param_t)
	if self.show_kaifuactivityview_btn then
		self.show_kaifuactivityview_btn:SetValue(KaifuActivityData.Instance:IsShowKaifuIcon() and OpenFunData.Instance:CheckIsHide("kaifuactivityview"))
	end

	if self.show_kaifu_charge_view_btn then
		--local OpenServerDay = TimeCtrl.Instance:GetCurOpenServerDay()
		self.show_kaifu_charge_view_btn:SetValue(KaifuActivityData.Instance:IsShowKaifuIcon() and OpenFunData.Instance:CheckIsHide("kaifuchargeview"))
	end

	-- if self.show_span_battle_icon then
	-- 	self.show_span_battle_icon:SetValue(OpenFunData.Instance:CheckIsHide("spanbattleview"))
	-- end

	if self.show_qitian_LeiChong_icon then
		self.show_qitian_LeiChong_icon:SetValue(TimeCtrl.Instance:GetCurOpenServerDay() <= 7 and OpenFunData.Instance:CheckIsHide("qitian_chongzhi") and KaiFuChargeData.Instance:IsRewardQiTianChongZhi())
	end

	if nil ~= self.is_show_temp_mount and nil ~= MountData.Instance then
		--self.is_show_temp_mount:SetValue(MountData.Instance:IsShowTempMountIcon() and OpenFunData.Instance:CheckIsHide(ViewName.TempMount))
		self.is_show_temp_mount:SetValue(false) --屏蔽坐骑按钮
	end

	if nil ~= self.is_show_temp_wing and nil ~= WingData.Instance then
		self.is_show_temp_wing:SetValue(WingData.Instance:IsShowTempWingIcon() and OpenFunData.Instance:CheckIsHide(ViewName.TempMount))
	end

	if self.show_switch_button and IS_ON_CROSSSERVER then
		self.show_switch_button:SetValue(false)
	end

	if self.need_delay then
		GlobalTimerQuest:CancelQuest(self.junxian_timer)

		self.junxian_timer = GlobalTimerQuest:AddDelayTimer(function () 
			if self.btn_junxian ~= nil then
				self.btn_junxian.animator:SetBool("IsShow", RemindManager.Instance:GetRemind(RemindName.JunXian) > 0)
			end	

			GlobalTimerQuest:CancelQuest(self.junxian_timer)
			self.junxian_timer = nil
			self.need_delay = false
		end, 2)
	end
	
	for k, v in pairs(param_t) do
		if k == "mail_rec" then
			self.chat_view:Flush(k, v)
		elseif k == "friend_rec" then
			self.chat_view:Flush(k, v)
		elseif k == "team_req" then
			self.chat_view:Flush(k, v)
		elseif k == "join_req" then
			self.chat_view:Flush(k, v)
		elseif k == "trade_req" then
			self.chat_view:Flush(k, v)
		elseif k == "weeding_get_invite" then
			self.chat_view:Flush(k, v)
		elseif k == "gift_btn" then
			self.chat_view:Flush(k, v)
		elseif k == "hongbao" then
			self.chat_view:Flush(k, v)
		elseif k == "kouling_hongbao" then
			self.chat_view:Flush(k, v)
		elseif k == "server_hongbao" then
			self.chat_view:Flush(k, v)
		elseif k == "team_list" then
			self.team_view:ReloadData()
		elseif k == "sos_req" then
			self.chat_view:Flush(k, v)
		elseif k == "wedding" then
			-- self:ChangeWeddingState()
		elseif k == "show_privite_remind" then
			self:ShowPriviteRemind(v[1])
		elseif k == "guild_yao" then
			self.chat_view:Flush(k, v)
		elseif k == "guild_storage" then
			self.chat_view:Flush(k, v)
		elseif k == "off_line" then
			self.chat_view:Flush(k, v)
		elseif k == "be_atk" then
			self:FlushBeAtkIconState(v[1])
		elseif k == "on_line" then
			self:FlushOnlineReward()
		elseif k == "love_content" then
			self.chat_view:Flush(k, v)
		elseif k == "discount" then
			self.chat_view:Flush(k, v)
		elseif k == "discount_red" then
			self.chat_view:Flush(k, v)
		elseif k == "discount_ani" then
			self.chat_view:Flush(k, v)
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
		elseif k == "chat_info" then
			self.chat_view:Flush(k, v)
		elseif k == "dafuhao" then
			-- 下面这段是UG01的
			-- if self.show_switch_button then
			-- 	self.show_switch_button:SetValue(DaFuHaoData.Instance:IsShowDaFuHao()) 
			-- end
			if DaFuHaoData.Instance:GetIsCanGather() and ActivityData.Instance:GetActivityIsOpen(DaFuHaoDataActivityId.ID) and not IS_ON_CROSSSERVER then
				local activity_cfg = ActivityData.Instance:GetActivityConfig(DaFuHaoDataActivityId.ID)
				local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
				local is_show_btn = true
				if activity_cfg ~= nil then
					local level_limit = activity_cfg.min_level
					if main_role_vo and main_role_vo.level < level_limit then
						is_show_btn = false
					end
				end
				if is_show_btn then
					if DaFuHaoData.Instance:GetDaFuHaoInfo().gather_total_times and DaFuHaoData.Instance:GetDaFuHaoInfo().gather_total_times < 20 then
						self.show_switch_button:SetValue(true)
						if not ViewManager.Instance:IsOpen(ViewName.DaFuHao) and main_role_vo and main_role_vo.level >= 70 then		-- 策划说70级之前不自动跳转
							self:SetViewState(false)
							ViewManager.Instance:Open(ViewName.DaFuHao)
							if self.MenuIconToggle.isOn then
								self.MenuIconToggle.isOn = false
							end
							GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true)
						end
					elseif DaFuHaoData.Instance:GetDaFuHaoInfo().gather_total_times and DaFuHaoData.Instance:GetDaFuHaoInfo().gather_total_times >= 20 then
						-- self.show_switch_button:SetValue(false)
						if ViewManager.Instance:IsOpen(ViewName.DaFuHao) then
							self:ClickSwitch()
						end
					end
					-- self:ClickSwitch()
				else
					self.show_switch_button:SetValue(false)
				end
			else
				local scene_id = Scene.Instance:GetSceneId()
				if not BossData.IsNeutralBossScene(scene_id) then
					self.show_switch_button:SetValue(false)
				end
			end
		elseif k == "guild_goddess" then
			self.chat_view:Flush(k, v)
		elseif k == "guild_invite" then
			self.chat_view:Flush(k, v)
		elseif k == "bag_full" then
			self.chat_view:Flush(k, v)
		elseif k == "shen_ge_effect" then
			if nil ~= self.show_shen_ge_effect then
				self.show_shen_ge_effect:SetValue(ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI)
					and OpenFunData.Instance:CheckIsHide("shengxiao_uplevel"))
			end
		elseif k == "jubaopen" then
			self:CheckJuBaoPenIcon()
		elseif k == "trailerview" then
			self:ChangeFunctionTrailer()
		elseif k == "show_guild_popchat" then
			self.chat_view:Flush(k, v)
		elseif k == "flush_popchat_view" then
			self.chat_view:Flush(k, v)
		elseif k == "flush_popmain_view" then
			self.chat_view:Flush(k, v)
		elseif k == "activity_time" then
			self.chat_view:Flush(k, v)
		elseif k == "general_bianshen" then
			self:ChangeGeneralState()
			self.general_skill_view:Flush(v[1])
		elseif k == "city_combat_worship" then
			-- self:ShowWorshipGatherBar()
		elseif k == "show_city_combat_worship" then
			self:ShowWorshipEntrance(v[1])
		elseif k == "guild_fight_worship" then
			self:ShowGuildBattleWorshipGatherBar()
		elseif k == "double_escort" then
			self:ChangeDoubleEscortState()
		elseif k == "dachen" then
			self:ChangeDaChenState()
		elseif k == "guoqi" then
			self:ChangeGuoQiState()
		elseif k == "guild_boss" then
			self.chat_view:Flush(k, v)
		elseif k == "flush_package" then
			self:OnFulshPackage((#ItemData.Instance:GetBagItemDataList()+1) >= COMMON_CONSTS.MAX_BAG_COUNT)
		elseif k == "world_boss" then
			self:ChangeWorldBossState()
		elseif k == "banzhuan" then
			self:ChangeBanZhuanState()
		elseif k == "recharge" then
			self:CheckRechargeIcon(v[1])
			local is_can_show = DailyChargeData.Instance:GetThreeRechargeOpen(2)
			self.show_recharge_icon:SetValue(is_can_show)
		elseif k == "world_level" then
			self.chat_view:Flush(k, v)
		elseif k == "show_affiche" then
			self.chat_view:Flush(k, v)
		elseif k == "check_show_mount" then
			--self.joystick_view:CheckShowMount()
		elseif k == "mount_change" then
			self.joystick_view:FlushMountState()
		elseif k == "is_camp_building" then
			self.chat_view:Flush(k, v)
		end
	end

	if self.joystick_view then
		self.joystick_view:CheckShowMount()
	end
	
	self:SetShrinkButtonRepoint()
	self.day_activity_name_content:SetActive(not IS_ON_CROSSSERVER)
end

function MainUIView:GetSkillButtonPosition()
	if self.skill_view then
		return self.skill_view:GetSkillButtonPosition()
	end
end

function MainUIView:ButtonChange(switch)
	local _switch = switch or false
	if self.target_view then
		self.target_view:SetState(_switch)
	end
end

--可隐藏按钮
function MainUIView:FindHideableButton()
	self.hideable_button_list = {}
	self.hideable_button_list[MainUIData.RemindingName.XiuLuoTower] = self:FindVariable("ShowXiuLuoTower")
	self.hideable_button_list[MainUIData.RemindingName.TreasureBowl] = self:FindVariable("ShowTreasureBowl")
	self.hideable_button_list[MainUIData.RemindingName.TombExplore] = self:FindVariable("ShowTombExplore")
	self.hideable_button_list[MainUIData.RemindingName.CityCombat] = self:FindVariable("ShowCityCombat")
	self.hideable_button_list[MainUIData.RemindingName.Show_Seven_Login] = self:FindVariable("Show_Seven_Login")
	self.hideable_button_list[MainUIData.RemindingName.Show_Collection] = self:FindVariable("Show_Collection")
	self.hideable_button_list[MainUIData.RemindingName.Cross_Hot_Spring] = self:FindVariable("ShowCrossHotSpring")
	self.hideable_button_list[MainUIData.RemindingName.Big_Rich] = self:FindVariable("ShowBigRich")
	self.hideable_button_list[MainUIData.RemindingName.Question] = self:FindVariable("ShowQuestion")
	self.hideable_button_list[MainUIData.RemindingName.Double_Escort] = self:FindVariable("ShowDoubleEscort")
	self.hideable_button_list[MainUIData.RemindingName.Cross_One_Vs_One] = self:FindVariable("ShowCrossOneVsOne")
	self.hideable_button_list[MainUIData.RemindingName.Clash_Territory] = self:FindVariable("ShowClashTerritory")
	self.hideable_button_list[MainUIData.RemindingName.Guild_Battle] = self:FindVariable("ShowGuildBattle")
	self.hideable_button_list[MainUIData.RemindingName.Fall_Money] = self:FindVariable("ShowTianJiangCaiBao")
	self.hideable_button_list[MainUIData.RemindingName.Element_Battle] = self:FindVariable("ShowElementBattle")
	self.hideable_button_list[MainUIData.RemindingName.GuildMijing] = self:FindVariable("ShowGuildMijing")
	self.hideable_button_list[MainUIData.RemindingName.GuildBonfire] = self:FindVariable("ShowGuildBonfire")
	-- self.hideable_button_list[MainUIData.RemindingName.GuildBoss] = self:FindVariable("ShowGuildBoss")
	self.hideable_button_list[MainUIData.RemindingName.CrossCrystal] = self:FindVariable("ShowCrossCrystal")
	--self.hideable_button_list[MainUIData.RemindingName.Show_Reincarnation] = self:FindVariable("Show_Reincarnation")
	self.hideable_button_list[MainUIData.RemindingName.MolongMibao] = self:FindVariable("Show_MolongMibao")
	self.hideable_button_list[MainUIData.RemindingName.show_invest_icon] = self.show_invest_icon
	self.hideable_button_list[MainUIData.RemindingName.ExpRefine] = self:FindVariable("ShowExpRefineBtn")
	self.hideable_button_list[MainUIData.RemindingName.BanZhuan] = self:FindVariable("ShowBanZhuan")
	self.hideable_button_list[MainUIData.RemindingName.Kf_Mining] = self:FindVariable("ShowMining")
	self.hideable_button_list[MainUIData.RemindingName.MarryMe] = self:FindVariable("ShowWantMarry")
	self.hideable_button_list[MainUIData.RemindingName.Fishing] = self:FindVariable("ShowFishing")
	self.hideable_button_list[MainUIData.RemindingName.GuildBattle_Worship] = self:FindVariable("show_guildbattle_worship")
	self.hideable_button_list[MainUIData.RemindingName.DaChen] = self:FindVariable("ShowDaChen")
	self.hideable_button_list[MainUIData.RemindingName.GuoQi] = self:FindVariable("ShowGuoQi")
	self.hideable_button_list[MainUIData.RemindingName.MiningFight] = self:FindVariable("ShowFightMining")  
	self.hideable_button_list[MainUIData.RemindingName.WorldBoss] = self:FindVariable("ShowWorldBossIcon")
	self.hideable_button_list[MainUIData.RemindingName.MonsterSiege] = self:FindVariable("ShowMonsterSiege")
	self.hideable_button_list[MainUIData.RemindingName.WeddingActivity] = self:FindVariable("ShowWeddingActivity")
	self.hideable_button_list[MainUIData.RemindingName.HuanZhuangShopActivity] = self:FindVariable("ShowHuanZhuangShopActivity")
	self.hideable_button_list[MainUIData.RemindingName.ChujunGift] = self:FindVariable("ShowChujunGiftActivity")
	self.hideable_button_list[MainUIData.RemindingName.SecretrShop] = self:FindVariable("ShowSecretrShop")
	self.hideable_button_list[MainUIData.RemindingName.ShenJiSkill] = self:FindVariable("ShowTempShenJi")
	self.hideable_button_list[MainUIData.RemindingName.LuckyTurntable] = self:FindVariable("ShowLuckyTurntable")
	self.hideable_button_list[MainUIData.RemindingName.GodDropGift] = self:FindVariable("ShowGodDropGiftIcon")
	self.hideable_button_list[MainUIData.RemindingName.DressShop] = self:FindVariable("ShowDressShop")
	self.hideable_button_list[MainUIData.RemindingName.QixiActivity] = self:FindVariable("ShowQixiIcon")
	self.hideable_button_list[MainUIData.RemindingName.MidAutumnAct] = self:FindVariable("ShowMidAutumnIcon")
	--self.hideable_button_list[MainUIData.RemindingName.AdventureShop] = self:FindVariable("ShowAdventureShop")
	self.hideable_button_list[MainUIData.RemindingName.RareTreasure] = self:FindVariable("ShowRareTreasure")
	self.hideable_button_list[MainUIData.RemindingName.ShowDailyCharge] = self:FindVariable("ShowDailyChargeIcon")
	self.hideable_button_list[MainUIData.RemindingName.ThanksFeedBack] = self:FindVariable("ShowThanksFeedBack")

	self.hideable_button_list[MainUIData.RemindingName.ActRebateFoot] = self:FindVariable("ShowRbFootIcon")
	self.hideable_button_list[MainUIData.RemindingName.ActRebateTouShi] = self:FindVariable("ShowRbTouShiIcon")
	self.hideable_button_list[MainUIData.RemindingName.ActRebateYaoShi] = self:FindVariable("ShowRbYaoShiIcon")
	self.hideable_button_list[MainUIData.RemindingName.ActRebateMask] = self:FindVariable("ShowRbMaskIcon")
	self.hideable_button_list[MainUIData.RemindingName.ActRebateQiLingBi] = self:FindVariable("ShowRbQiLingBiIcon")
	self.hideable_button_list[MainUIData.RemindingName.ActRebateLingBao] = self:FindVariable("ShowRbLingZhuIcon")
	self.hideable_button_list[MainUIData.RemindingName.ActRebateXianbao] = self:FindVariable("ShowRbXianBaoIcon")

	self.transfer_reminding_name = {
		MainUIData.RemindingName.ShowCounTranBtn,
		MainUIData.RemindingName.ShowFamilyTranBtn, 
		MainUIData.RemindingName.ShowTeamTranBtn
	}
	self.hideable_button_list[self.transfer_reminding_name[1]] = self:FindVariable("ShowCountryTranBtn")
	self.hideable_button_list[self.transfer_reminding_name[2]] = self:FindVariable("ShowFamilyTranBtn")
	self.hideable_button_list[self.transfer_reminding_name[3]] = self:FindVariable("ShowTeamTranBtn")

	for k,v in pairs(self.hideable_button_list) do
		if self.tmp_button_data[k] ~= nil then
			if k == MainUIData.RemindingName.MolongMibao then
				v:SetValue(self.tmp_button_data[k] and OpenFunData.Instance:CheckIsHide("molongmibaoview"))
			elseif k == MainUIData.RemindingName.MarryMe then
					local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
					local is_open = OpenFunData.Instance:CheckIsHide("marriage")
					v:SetValue(is_open and self.tmp_button_data[k])
			elseif k == MainUIData.RemindingName.ChujunGift then
					local is_open = OpenFunData.Instance:CheckIsHide("kaifuactivityview")
					v:SetValue(is_open and self.tmp_button_data[k])
			elseif k == MainUIData.RemindingName.SecretrShop then
					local is_open = OpenFunData.Instance:CheckIsHide("SecretrShopView")
					v:SetValue(is_open and self.tmp_button_data[k])
			elseif k == MainUIData.RemindingName.HuanZhuangShopActivity then
					v:SetValue(not IS_AUDIT_VERSION and self.tmp_button_data[k])
			elseif k == MainUIData.RemindingName.ShowDailyCharge then
				 	local is_open = OpenFunData.Instance:CheckIsHide("kaifuchargeview")
					v:SetValue(self.tmp_button_data[k] and is_open and KaiFuChargeData.Instance:IsOpenDailyCharge())
			else
				v:SetValue(self.tmp_button_data[k])
			end
		else
			v:SetValue(false)
		end
	end
	self.hideable_button_list[MainUIData.RemindingName.MiningFight]:SetValue(false)
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
		elseif key == MainUIData.RemindingName.ChujunGift then
			ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT)
			self:SetChuJunActTime()
			local is_open = OpenFunData.Instance:CheckIsHide("kaifuactivityview")
			self.hideable_button_list[key]:SetValue(is_open and is_show)
		elseif key == MainUIData.RemindingName.SecretrShop then
			self:SetSecretrShopTime()
			local is_open = OpenFunData.Instance:CheckIsHide("SecretrShopView")
			self.hideable_button_list[key]:SetValue(is_open and is_show)
		elseif key == MainUIData.RemindingName.MarryMe then
			ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.MARRY_ME)
			self:SetMarryMeActTime()
			local is_open = OpenFunData.Instance:CheckIsHide("marriage")
			self.hideable_button_list[key]:SetValue(is_open and is_show)
		elseif key == MainUIData.RemindingName.Rank then
			local is_open = OpenFunData.Instance:CheckIsHide("ranking")
			self.hideable_button_list[key]:SetValue(is_open and not IS_AUDIT_VERSION)	
		elseif key == MainUIData.RemindingName.ShowDailyCharge then
			local is_open = OpenFunData.Instance:CheckIsHide("kaifuchargeview")
			self.hideable_button_list[key]:SetValue(is_open and KaiFuChargeData.Instance:IsOpenDailyCharge())
		else
			if key == MainUIData.RemindingName.WeddingActivity then
				local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
				if main_role_vo.level < WEDDING_ACTIVITY_LEVEL then
					self.hideable_button_list[key]:SetValue(false)
					return
				end
			end
			self.hideable_button_list[key]:SetValue(is_show or self:SpecActIsOpen(key))
		end
	end
end

function MainUIView:SpecActIsOpen(key)
	if key == MainUIData.RemindingName.ExpRefine then
		return ExpRefineData.Instance:GetExpRefineIsOpen()
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
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_CORNUCOPIA] = self:FindVariable("TreasureBowlTime")
	self.act_btn_time_list[ACTIVITY_TYPE.TOMB_EXPLORE] = self:FindVariable("TombExploreTime")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_XIULUO_TOWER] = self:FindVariable("XiuLuoTowerTime")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_HOT_SPRING] = self:FindVariable("CrossHotSpringTime")
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
	-- self.act_btn_time_list[ACTIVITY_TYPE.GUILD_BOSS] = self:FindVariable("GuildBossTime")
	self.act_btn_time_list[ACTIVITY_TYPE.SHUIJING] = self:FindVariable("CrossCrystalTime")
	-- self.act_btn_time_list[ACTIVITY_TYPE.BANZHUAN] = self:FindVariable("BanZhuanTime")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_MINING] = self:FindVariable("MiningTime")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_FISHING] = self:FindVariable("FishingTime")
	self.act_btn_time_list[ACTIVITY_TYPE.MARRY_ME] = self:FindVariable("MarryMeTimes")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GREATE_SOLDIER_DRAW] = self:FindVariable("GeneralTime")
	self.act_btn_time_list[ACTIVITY_TYPE.GUILDBATTLE_WORSHIP] = self:FindVariable("guildbattle_worship_time")
	self.act_btn_time_list[ACTIVITY_TYPE.GONGCHENGZHAN_WORSHIP] = self:FindVariable("citycombat_worship_time")
	self.act_btn_time_list[ACTIVITY_TYPE.KF_GUILDBATTLE] = self:FindVariable("KFBattleTime")
	self.act_btn_time_list[ACTIVITY_TYPE.ACTIVITY_TYPE_MONSTER_SIEGE] = self:FindVariable("MonsterSiegeTime")
	self.act_btn_time_list[ACTIVITY_TYPE.WEDDING_ACTIVITY] = self:FindVariable("WeddingTimes")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT] = self:FindVariable("ShowChuJunTime")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP] = self:FindVariable("SecretrShopTime")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UEHUI_DAZUOZHAN] = self:FindVariable("QiXiActivityTime")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN] = self:FindVariable("MidAutumnActivityTime")
	self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_APPRECIATION_REWARD] = self:FindVariable("ThanksFeedBackTime")
	-- self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP] = self:FindVariable("HuanZhuangShopTimes")
	self.act_btn_time_list2 = {}
	self.act_btn_time_list2[ACTIVITY_TYPE.GONGCHENGZHAN] = self:FindVariable("CityCombatTime2")
	self.act_btn_time_list2[ACTIVITY_TYPE.CLASH_TERRITORY] = self:FindVariable("ClashTerritoryTime2")
	self.act_btn_time_list2[ACTIVITY_TYPE.GUILDBATTLE] = self:FindVariable("GuildBattleTime2")

	self.act_effect_list = {}
	self.act_effect_list[ACTIVITY_TYPE.GONGCHENGZHAN] = self:FindVariable("ShowCityCombatEffect")
	self.act_effect_list[ACTIVITY_TYPE.RAND_CORNUCOPIA] = self:FindVariable("ShowTreasureBowlEffect")
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
	-- self.act_effect_list[ACTIVITY_TYPE.GUILD_BOSS] = self:FindVariable("ShowGuildBossEffect")
	self.act_effect_list[ACTIVITY_TYPE.SHUIJING] = self:FindVariable("ShowCrossCrystalEffect")
	-- self.act_effect_list[ACTIVITY_TYPE.BANZHUAN] = self:FindVariable("ShowBanZhuanEffect")
	self.act_effect_list[ACTIVITY_TYPE.KF_MINING] = self:FindVariable("ShowMiningEffect")
	self.act_effect_list[ACTIVITY_TYPE.KF_FISHING] = self:FindVariable("ShowFishingEffect")

	self.act_effect_list_2 = {}
	self.act_effect_list_2[ACTIVITY_TYPE.GONGCHENGZHAN] = self:FindVariable("ShowCityCombatEffect2")
	self.act_effect_list_2[ACTIVITY_TYPE.CLASH_TERRITORY] = self:FindVariable("ShowClashTerritoryEffect2")
	self.act_effect_list_2[ACTIVITY_TYPE.GUILDBATTLE] = self:FindVariable("ShowGuildBattleEffect2")


	for k,v in pairs(self.act_btn_time_list) do
		local activity_info= ActivityData.Instance:GetActivityStatuByType(k)
		if activity_info then
			self:SetActivityBtnTime(k, activity_info.next_time)
		end
	end
end

function MainUIView:SetActivityBtnTime(act_type, time)
	if self.act_btn_time_list and self.act_btn_time_list[act_type] ~= nil and TimeCtrl.Instance then
		time = math.max(time - TimeCtrl.Instance:GetServerTime(), 0)
		local str_time = ""
		local activity_info = ActivityData.Instance:GetActivityStatuByType(act_type)	
		if activity_info then
			if activity_info.status == ACTIVITY_STATUS.STANDY then
				str_time = ToColorStr(TimeUtil.FormatSecond2Str(time), TEXT_COLOR.RED)
			elseif activity_info.status == ACTIVITY_STATUS.OPEN then
				if time > 3600 then
					str_time = ToColorStr(TimeUtil.FormatSecond2DHMS(time, 4), TEXT_COLOR.GREEN_5)
				else
					str_time = ToColorStr(TimeUtil.FormatSecond2Str(time), TEXT_COLOR.GREEN_5)
				end
			end
			self.act_btn_time_list[act_type]:SetValue(str_time)
		end
	end
end

local ActRemindNameT = {
	[ACTIVITY_TYPE.GONGCHENGZHAN] = MainUIData.RemindingName.CityCombat,
	[ACTIVITY_TYPE.RAND_CORNUCOPIA] = MainUIData.RemindingName.TreasureBowl,
	[ACTIVITY_TYPE.TOMB_EXPLORE] = MainUIData.RemindingName.TombExplore,
	[ACTIVITY_TYPE.KF_XIULUO_TOWER] = MainUIData.RemindingName.XiuLuoTower,
	[ACTIVITY_TYPE.KF_HOT_SPRING] = MainUIData.RemindingName.Cross_Hot_Spring,
	[ACTIVITY_TYPE.BIG_RICH] = MainUIData.RemindingName.Big_Rich,
	[ACTIVITY_TYPE.QUESTION_2] = MainUIData.RemindingName.Question,
	[ACTIVITY_TYPE.HUSONG] = MainUIData.RemindingName.Double_Escort,
	--[ACTIVITY_TYPE.KF_ONEVONE] = MainUIData.RemindingName.Cross_One_Vs_One,
	[ACTIVITY_TYPE.CLASH_TERRITORY] = MainUIData.RemindingName.Clash_Territory,
	[ACTIVITY_TYPE.GUILDBATTLE] = MainUIData.RemindingName.Guild_Battle,
	[ACTIVITY_TYPE.TIANJIANGCAIBAO] = MainUIData.RemindingName.Fall_Money,
	[ACTIVITY_TYPE.QUNXIANLUANDOU] = MainUIData.RemindingName.Element_Battle,
	[ACTIVITY_TYPE.GUILD_SHILIAN] = MainUIData.RemindingName.GuildMijing,
	[ACTIVITY_TYPE.GUILD_BONFIRE] = MainUIData.RemindingName.GuildBonfire,
	-- [ACTIVITY_TYPE.GUILD_BOSS] = MainUIData.RemindingName.GuildBoss,
	[ACTIVITY_TYPE.SHUIJING] = MainUIData.RemindingName.CrossCrystal,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE] = MainUIData.RemindingName.ExpRefine,
	[ACTIVITY_TYPE.BANZHUAN] = MainUIData.RemindingName.BanZhuan,
	[ACTIVITY_TYPE.KF_MINING] = MainUIData.RemindingName.Kf_Mining,
	[ACTIVITY_TYPE.KF_FISHING] = MainUIData.RemindingName.Fishing,
	[ACTIVITY_TYPE.MARRY_ME] = MainUIData.RemindingName.MarryMe,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GREATE_SOLDIER_DRAW] = MainUIData.RemindingName.GeneralChou,
	[ACTIVITY_TYPE.GUILDBATTLE_WORSHIP] = MainUIData.RemindingName.GuildBattle_Worship,
	[ACTIVITY_TYPE.ACTIVITY_TYPE_MONSTER_SIEGE] = MainUIData.RemindingName.MonsterSiege,
	[ACTIVITY_TYPE.WEDDING_ACTIVITY] = MainUIData.RemindingName.WeddingActivity,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP] = MainUIData.RemindingName.HuanZhuangShopActivity,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT] = MainUIData.RemindingName.ChujunGift,
	[ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP] = MainUIData.RemindingName.SecretrShop,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_TURNTABLE] = MainUIData.RemindingName.LuckyTurntable,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOD_DROP_GIFT] = MainUIData.RemindingName.GodDropGift,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_IMAGE_CHANGE_SHOP] = MainUIData.RemindingName.DressShop,
	-- [ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UEHUI_DAZUOZHAN] = MainUIData.RemindingName.QixiActivity
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ADVENTURE_SHOP] = MainUIData.RemindingName.AdventureShop,
	[ACTIVITY_TYPE.CROSS_MI_BAO_RANK] = MainUIData.RemindingName.RareTreasure,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW] = MainUIData.RemindingName.ActRebateFoot,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE] = MainUIData.RemindingName.ActRebateYaoShi,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE] = MainUIData.RemindingName.ActRebateTouShi,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE] = MainUIData.RemindingName.ActRebateQiLingBi,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE] = MainUIData.RemindingName.ActRebateMask,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE] = MainUIData.RemindingName.ActRebateXianbao,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE] = MainUIData.RemindingName.ActRebateLingBao,
	[ACTIVITY_TYPE.RAND_DAILY_LOVE] = MainUIData.RemindingName.ShowDailyCharge,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_APPRECIATION_REWARD] = MainUIData.RemindingName.ThanksFeedBack,
}
function MainUIView:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	self:SetJingcaiActImg()
	if self.is_open_kaifuact and activity_type ==  KaifuActivityType.TYPE then
		self.is_open_kaifuact:SetValue(status == ACTIVITY_STATUS.OPEN)
	end
	RemindManager.Instance:Fire(RemindName.ExpRefine)
	local act_cfg = ActivityData.Instance:GetActivityConfig(activity_type)

	if self.show_activity_hall_icon then
		self.show_activity_hall_icon:SetValue(#ActivityData.Instance:GetActivityHallDatalist() > 0)
	end
	if act_cfg and act_cfg.is_inscroll == 1 then return end

	if status ~= ACTIVITY_STATUS.CLOSE then
		local level = PlayerData.Instance.role_vo.level
		if act_cfg and act_cfg.min_level > level then
			self.tmp_activity_list[activity_type] = {activity_type = activity_type, status = status, next_time = next_time, open_type = open_type}
			return
		elseif self.tmp_activity_list[activity_type] then
			self.tmp_activity_list[activity_type] = nil
		end
	else
		if self.tmp_activity_list[activity_type] then
			self.tmp_activity_list[activity_type] = nil
		end
		if activity_type == ACTIVITY_TYPE.KF_GUILDBATTLE then
			self.act_btn_time_list[activity_type]:SetValue("")
			if self.act_effect_list[activity_type]then
				self.act_effect_list[activity_type]:SetValue(false)
			end
		end
	end

	if activity_type == ACTIVITY_TYPE.MARRY_ME then
		if GameVoManager.Instance:GetMainRoleVo().lover_uid <= 0 then
			RemindManager.Instance:Fire(RemindName.MarryMe)
		end
	elseif activity_type == ACTIVITY_TYPE.WEDDING_ACTIVITY then  --婚礼准备状态请求婚礼信息
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
	end

	self:SetRandActIcon()

	if nil == self.act_time_countdown then
		self.act_time_countdown = GlobalTimerQuest:AddRunQuest(function()
			if nil == self.act_btn_time_list then
				return
			end
			local has_act_open = false
			local activity_info = nil
			for k,v in pairs(self.act_btn_time_list) do
				activity_info = ActivityData.Instance:GetActivityStatuByType(k)
				if activity_info and (activity_info.status == ACTIVITY_STATUS.STANDY or activity_info.status == ACTIVITY_STATUS.OPEN) then
					has_act_open = true
						if activity_info.type ~= ACTIVITY_TYPE.MARRY_ME and activity_info.type ~= ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT and activity_info.type ~= ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP then
							self:SetActivityBtnTime(k, activity_info.next_time)
						end
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

	if not IS_ON_CROSSSERVER and status == ACTIVITY_STATUS.OPEN and act_cfg and act_cfg.open_panel == 1 and SceneType.Common == Scene.Instance:GetSceneType() then
		if activity_type ~= ACTIVITY_TYPE.GUILD_SHILIAN and
		-- activity_type ~= ACTIVITY_TYPE.GUILD_BOSS and
		activity_type ~= ACTIVITY_TYPE.GUILD_BONFIRE then
			self:OpenActivityView(activity_type)
		end
	end

	for k,v in pairs(ACTIVITY_ACT_TYPE_BATTLE) do
		if v == activity_type then
				RemindManager.Instance:Fire(RemindName.ActivityHall)
		end
	end
	for k,v in pairs(ACTIVITY_ACT_TYPE_DAILY) do
		if v == activity_type then
				RemindManager.Instance:Fire(RemindName.ActivityHall)
		end
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA then
		RemindManager.Instance:Fire(RemindName.JuBaoPen)
		self:CheckJuBaoPenIcon()
	end

	if activity_type == ACTIVITY_TYPE.QUNXIANLUANDOU or activity_type == ACTIVITY_TYPE.GONGCHENGZHAN or activity_type == ACTIVITY_TYPE.GUILDBATTLE then
		RemindManager.Instance:Fire(RemindName.CombinePVP)
	end
end

function MainUIView:SetRandActIcon()
	local is_show_qixi = false
	if ACTIVITY_ACT_QIXI_DATA ~= nil then
		for k,v in pairs(ACTIVITY_ACT_QIXI_DATA) do
			if v ~= nil and v.act_id ~= nil then
				local qixi_data = ActivityData.Instance:GetActivityStatuByType(v.act_id)
				if qixi_data ~= nil and qixi_data.status ~= ACTIVITY_STATUS.CLOSE then
					is_show_qixi = true
					break
				end
			end
		end

		local qixi_open = OpenFunData.Instance:CheckIsHide("QiXiActivityView")

		self:SetButtonVisible(MainUIData.RemindingName.QixiActivity, is_show_qixi and qixi_open)
	end

	local is_show_mid_autumn = false
	if ACTIVITY_ACT_MID_AUTUMN_DATA ~= nil then
		for k,v in pairs(ACTIVITY_ACT_MID_AUTUMN_DATA) do
			if v ~= nil and v.act_id ~= nil then
				local mid_atm_data = ActivityData.Instance:GetActivityStatuByType(v.act_id)
				if mid_atm_data ~= nil and mid_atm_data.status ~= ACTIVITY_STATUS.CLOSE then
					is_show_mid_autumn = true
					break
				end
			end
		end

		local mid_atm_open = OpenFunData.Instance:CheckIsHide("ActivityMidAutumnView")

		self:SetButtonVisible(MainUIData.RemindingName.MidAutumnAct, is_show_mid_autumn and mid_atm_open)
	end
end


function MainUIView:OpenKaifuDailyCharge()
	ViewManager.Instance:Open(ViewName.KaiFuChargeView, TabIndex.kaifu_daily_charge)
end

function MainUIView:OpenThanksFeedBack()
	ViewManager.Instance:Open(ViewName.KaiFuChargeView, TabIndex.kaifu_thanksfeedback)
end

function MainUIView:SetBtnDailyCharge(is_show)
	self:SetButtonVisible(MainUIData.RemindingName.ShowDailyCharge, is_show)
end

function MainUIView:CheckJuBaoPenIcon()
	if self.show_jubaopen_icon then
		self.show_jubaopen_icon:SetValue(JuBaoPenData.Instance:CheckIsShow())
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
	self.red_point_list[RemindName.RoleSkill] = self:FindVariable("RoleSkill")
	-- self.red_point_list[RemindName.Medal] = self:FindVariable("ShowMedalRed")
	self.red_point_list[RemindName.Forge] = self:FindVariable("Forge")
	self.red_point_list[RemindName.Advance] = self:FindVariable("Advance")
	self.red_point_list[RemindName.Beauty] = self:FindVariable("Beauty")
	self.red_point_list[RemindName.Goddess_ShengWu] = self:FindVariable("Goddess")
	self.red_point_list[RemindName.Camp] = self:FindVariable("Camp")
	self.red_point_list[RemindName.Guild] = self:FindVariable("Guild")
	self.red_point_list[RemindName.Scoiety] = self:FindVariable("Scoiety")
	self.red_point_list[RemindName.MainMarry] = self:FindVariable("Marriage")
	self.red_point_list[RemindName.Rank] = self:FindVariable("Rank")
	self.red_point_list[RemindName.Compose] = self:FindVariable("Compose")
	self.red_point_list[RemindName.Market] = self:FindVariable("Market")
	self.red_point_list[RemindName.FuBenMulti] = self:FindVariable("FuBenMulti")
	self.red_point_list[RemindName.FuBenSingle] = self:FindVariable("FuBenSingle")
	self.red_point_list[RemindName.BattleField] = self:FindVariable("BattleField")
	self.red_point_list[RemindName.ActivityHall] = self:FindVariable("ActivityHall")
	self.red_point_list[RemindName.XunBaoGroud] = self:FindVariable("TreasureHunt")
	self.red_point_list[RemindName.JingCai_Act] = self:FindVariable("NewServer")
	self.red_point_list[RemindName.Welfare] = self:FindVariable("Welfare")
	self.red_point_list[RemindName.Echange] = self:FindVariable("Echange")
	self.red_point_list[RemindName.Shop] = self:FindVariable("Shop")
	self.red_point_list[RemindName.Setting] = self:FindVariable("Setting")
	self.red_point_list[RemindName.Church] = self:FindVariable("Church")
	self.red_point_list[RemindName.Auto] = self:FindVariable("Auto")
	self.red_point_list[RemindName.PlayerPackage] = self:FindVariable("Package")
	self.red_point_list[RemindName.RechargeGroud] = self:FindVariable("Deposit")
	self.red_point_list[RemindName.Vip] = self:FindVariable("Vip")
	self.red_point_list[RemindName.Spirit] = self:FindVariable("Spirit")
	self.red_point_list[RemindName.DailyCharge] = self:FindVariable("Daily_Charge")
	self.red_point_list[RemindName.FirstCharge] = self:FindVariable("First_Charge")
	self.red_point_list[RemindName.Invest] = self:FindVariable("Invest")
	self.red_point_list[RemindName.KfLeichong] = self:FindVariable("Show_Leiji_ChongZhi")
	self.red_point_list[RemindName.Rebate] = self:FindVariable("Rebate")
	self.red_point_list[RemindName.HuanJing_XunBao] = self:FindVariable("HuanJing_XunBao")
	self.red_point_list[RemindName.SevenLogin] = self:FindVariable("Seven_Login_Redpt")
	self.red_point_list[RemindName.Collection] = self:FindVariable("Collection_Redpt")
	self.red_point_list[RemindName.Reincarnation] = self:FindVariable("Reincarnation_Redpt")
	self.red_point_list[RemindName.Pet] = self:FindVariable("Pet")
	self.red_point_list[RemindName.MagicWeapon] = self:FindVariable("magic_weapon")
	self.red_point_list[RemindName.MoLongMiBao] = self:FindVariable("MolongMibao_redpt")
	self.red_point_list[RemindName.ActHongBao] = self:FindVariable("GetActHongBao")
	self.red_point_list[RemindName.ExpRefine] = self:FindVariable("ShowExpRefine_Redpt")
	self.red_point_list[RemindName.PersonalGoals] = self:FindVariable("Show_personal_goals_redpoint")
	self.red_point_list[RemindName.CollectiveGoals] = self:FindVariable("Show_collective_goals_redpoint")
	self.red_point_list[RemindName.GoldMember] = self:FindVariable("MemberRepdt")
	-- self.red_point_list[RemindName.HpBag] = self:FindVariable("ShowHpBagRedPoint")
	self.red_point_list[RemindName.Rune] = self:FindVariable("ShowRuneRedPoint")
	self.red_point_list[RemindName.RuneTower] = self:FindVariable("ShowRuneTowerRemind")
	self.red_point_list[RemindName.MarryMe] = self:FindVariable("ShowWantMarryRemind")
	self.red_point_list[RemindName.GuildChat] = self:FindVariable("ShowGuildChat")
	self.red_point_list[RemindName.NoGuild] = self:FindVariable("ShowGuildEffect")
	self.red_point_list[RemindName.ShenGeView] = self:FindVariable("ShenGe")
	self.red_point_list[RemindName.JuBaoPen] = self:FindVariable("JuBaoPenReminder")
	self.red_point_list[RemindName.DailyLeiJi] = self:FindVariable("DailyLeiJi")
	self.red_point_list[RemindName.ZeroGift] = self:FindVariable("ShowZeroGiftRemind")
	self.red_point_list[RemindName.JunXian] = self:FindVariable("JunXianRed")
	self.red_point_list[RemindName.General] = self:FindVariable("GeneralRed")
	self.red_point_list[RemindName.ShenQiView] = self:FindVariable("ShowShenqiRedPoint")
	self.red_point_list[RemindName.KaiFuCharge] = self:FindVariable("ShowKaiFuChargeRedPoint")
	self.red_point_list[RemindName.HappyBargain] = self:FindVariable("ShowHappyBargainRemind")
	self.red_point_list[RemindName.RedEquip] = self:FindVariable("ShowRedEquipRedPoint")
	self.red_point_list[RemindName.DiMaiTask] = self:FindVariable("ShowDiMaiRedPoint")
	self.red_point_list[RemindName.BiPin] = self:FindVariable("ShowBiPinRed")
	self.red_point_list[RemindName.SecondCharge] = self:FindVariable("Second_Charge")
	self.red_point_list[RemindName.ThirdCharge] = self:FindVariable("Third_Charge")
	self.red_point_list[RemindName.ShowHuanZhuangShopPoint] = self:FindVariable("ShowHuanZhuangShopPoint")
	self.red_point_list[RemindName.KaiFuChongZhiItem] = self:FindVariable("QiTianChongZhiRemind")
	self.red_point_list[RemindName.CampWar] = self:FindVariable("ShowCampWarRedPoint")
	self.red_point_list[RemindName.ACTIVITY_JUAN_ZHOU] = self:FindVariable("ShowActivityHallRedPoint")
	self.red_point_list[RemindName.BossRemind] = self:FindVariable("BossRed")
	self.red_point_list[RemindName.KfBattleRemind] = self:FindVariable("KfBattleRedPoint")
	self.red_point_list[RemindName.LuckyTurntable] = self:FindVariable("LuckyTurntableRemind")
	self.red_point_list[RemindName.SecretrShop] = self:FindVariable("SecretrShopRedPoint")
	self.red_point_list[RemindName.ShenJiSkill] = self:FindVariable("ShowTempSJRedPoint")
	self.red_point_list[RemindName.GodDropGift] = self:FindVariable("ShowGDGRedPoint")
	self.red_point_list[RemindName.CampTeam] = self:FindVariable("ShowCampTeamRedPoint")
	self.red_point_list[RemindName.QixiActivity] = self:FindVariable("ShowQixiRedPoint")
	self.red_point_list[RemindName.AdventureShop] = self:FindVariable("ShowAdventureShopRemind")
	self.red_point_list[RemindName.RareTreasure] = self:FindVariable("ShowRareTreasureRedPoint")
	self.red_point_list[RemindName.MidAutumnAct] = self:FindVariable("ShowMidAtmRedPoint")
	self.red_point_list[RemindName.ActRebateFoot] = self:FindVariable("ShowRbFootRed")
	self.red_point_list[RemindName.ActRebateTouShi] = self:FindVariable("ShowRbTouShiRed")
	self.red_point_list[RemindName.ActRebateYaoShi] = self:FindVariable("ShowRbYaoShiRed")
	self.red_point_list[RemindName.ActRebateMask] = self:FindVariable("ShowRbMaskRed")
	self.red_point_list[RemindName.ActRebateQiLingBi] = self:FindVariable("ShowRbQiLingBiRed")
	self.red_point_list[RemindName.ActRebateLingBao] = self:FindVariable("ShowRbLingZhuRed")
	self.red_point_list[RemindName.ActRebateXianBao] = self:FindVariable("ShowRbXianBaoRed")
	self.red_point_list[RemindName.ThanksFeedBackRedPoint] = self:FindVariable("ShowThanksFeedBackRedPoint")
	self:ClearRedPoint()
end

-- 清空红点
function MainUIView:ClearRedPoint()
	for _, v in pairs(self.red_point_list) do
		v:SetValue(false)
	end

	if self.btn_junxian ~= nil then
		self.btn_junxian.animator:SetBool("IsShow", false)
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

	if self.btn_junxian ~= nil then
		self.btn_junxian.animator:SetBool("IsShow", RemindManager.Instance:GetRemind(RemindName.JunXian) > 0)
	end		

	TreasureCtrl.Instance:SendChestShopItemListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
	GoPawnCtrl.Instance:SendMoveChessFreeInfo(0)
	self:CheckMenuRedPoint()
	self:SetShrinkButtonRepoint()
end

-- 改变红点
function MainUIView:ChangeRedPoint(index, state)
	if self.red_point_list[index] then
		self.red_point_list[index]:SetValue(state)
	end

	if index == RemindName.JunXian then
		if self.btn_junxian ~= nil then
			self.btn_junxian.animator:SetBool("IsShow", state)
		end	
	end
end

-- 提醒改变
function MainUIView:RemindChangeCallBack(remind_name, num)
	if self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end

	if remind_name == RemindName.JunXian then
		if self.btn_junxian ~= nil then
			self.btn_junxian.animator:SetBool("IsShow", num > 0)
		end	
	end
	-- 屏蔽变强按钮
	-- if remind_name == RemindName.BeStrength then
	-- 	self.button_strength:SetActive(num > 0)
	-- end
end

function MainUIView:SetShrinkButtonRepoint()
	local di_mai = (RemindManager.Instance:GetRemind(RemindName.DiMaiTask) > 0) and OpenFunData.Instance:CheckIsHide("dimai")
	local fuben_single = (RemindManager.Instance:GetRemind(RemindName.FuBenSingle) > 0) and OpenFunData.Instance:CheckIsHide("fuben")
	local activity_hall = (RemindManager.Instance:GetRemind(RemindName.ActivityHall) > 0) and OpenFunData.Instance:CheckIsHide("activity")
	local Welfare = (RemindManager.Instance:GetRemind(RemindName.Welfare) > 0) and OpenFunData.Instance:CheckIsHide("welfare")
	local seven_login = (RemindManager.Instance:GetRemind(RemindName.SevenLogin) > 0) and OpenFunData.Instance:CheckIsHide("logingift7view")
	local huanhua_shop = (RemindManager.Instance:GetRemind(RemindName.ShowHuanZhuangShopPoint) > 0) and self.tmp_button_data[MainUIData.RemindingName.HuanZhuangShopActivity]
	local gold_member = (RemindManager.Instance:GetRemind(RemindName.GoldMember) > 0) and OpenFunData.Instance:CheckIsHide("gold_member")
	if self.shrink_button_repoint then
		self.shrink_button_repoint:SetValue(di_mai or fuben_single or Welfare or seven_login or activity_hall or huanhua_shop or gold_member)
	end
	
end

function MainUIView:GetHuanZhuangShopActivity()
	return self.tmp_button_data[MainUIData.RemindingName.HuanZhuangShopActivity]
end



function MainUIView:OnTaskChange(task_event_type, task_id)
	if task_event_type == "accepted_remove" then
		if task_id == 540 or task_id == 5540 or task_id == 10540 then --完成任务,弹首充
		FirstChargeCtrl.Instance:OpenTipView()
		end
	end
	if task_event_type == "accepted_add" then
		self:OnOpenTrigger(1, task_id)
	end

	if task_event_type == "completed_list" then
		self:InitOpenFunctionIcon()
		return
	end
	if task_event_type == "completed_add" then
		self:OnOpenTrigger(2, task_id)
	end

end

function MainUIView:OnPersonGoalChange(value, flag)
	if flag then
		self:OnOpenTrigger(5, value)
	end
	if value then
		local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
		if self.show_CollectGoals_icon then
			self.show_CollectGoals_icon:SetValue(server_open_day <= 4 and OpenFunData.Instance:CheckIsHide("CollectGoals"))
		end
	end
end

function MainUIView:OnOpenTrigger(trigger_type, value)
	if self.shrink_button == nil then return end

	self:Flush("check_show_mount")
	self:InitOpenFunctionIcon()
	local open_fun_data = OpenFunData.Instance
	local single_fun_cfg_list = open_fun_data:OnTheTrigger(trigger_type, value)
	if single_fun_cfg_list == nil then
		return
	end
	for k,v in pairs(single_fun_cfg_list) do
		GlobalEventSystem:Fire(OpenFunEventType.OPEN_TRIGGER, v.name)
		if v.open_type == FunOpenType.Fly or v.open_type == FunOpenType.OpenTipView then
			TaskCtrl.Instance:SetAutoTalkState(false)
			local view_manager = ViewManager.Instance
			view_manager:CloseAll()
			if view_manager:IsOpen(ViewName.TaskDialog) then
				view_manager:Close(ViewName.TaskDialog)
			end
			-- 红装按钮出来alpha为0，先处理一下才
			local alpha = 0
			if v.open_type == FunOpenType.OpenTipView then
				alpha = 1
			end
			if not self.judge_icon_active_time_quest and not self.time_quest then
				GlobalEventSystem:Fire(FinishedOpenFun, true)
				self:SetButtonAlpha(open_fun_data:GetName(v.open_param), alpha)
				if v.with_param == FunWithType.Up then
					if FuBenCtrl.Instance:GetFuBenIconView():IsOpen() then
						self.MenuIconToggle.isOn = true
					else
						self.shrink_button.toggle.isOn = true
						self.MenuIconToggle.isOn = false
					end
				end

				if v.with_param == FunWithType.Down then
					self.shrink_button.toggle.isOn = false
					self.MenuIconToggle.isOn = true
					self:MainRoleLevelChange()
				end

				self:CalToJuggeIconActive(v)
			else
				self:SetButtonAlpha(open_fun_data:GetName(v.open_param), 1)
			end
		elseif v.open_type == FunOpenType.OpenModel then
			TaskCtrl.Instance:SetAutoTalkState(false)
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
					if  history_recharge < DailyChargeData.Instance:GetTotalChongZhiYi() then
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
	local open_fun_data = OpenFunData.Instance
	if not self.judge_icon_active_time_quest and not self.time_quest then
		self:SetButtonAlpha(open_fun_data:GetName(cfg.open_param), 0)
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
	else
		self:SetButtonAlpha(open_fun_data:GetName(cfg.open_param), 1)
	end
end

function MainUIView:CalToJuggeIconActive(cfg)
	local open_fun_data = OpenFunData.Instance
	local name = open_fun_data:GetName(cfg.open_param)
	local timer_cal = 0.1
	if cfg.open_type == FunOpenType.Fly and self["button_"..name] then
		if cfg.with_param == OPEN_FLY_DICT_TYPE.UP then
			self["button_"..name].rect.sizeDelta = Vector2(0, 70)
		else
			self["button_"..name].rect.sizeDelta = Vector2(0, 93)
		end
	end
	self.judge_icon_active_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			TipsCtrl.Instance:ShowOpenFunFlyView(cfg)
			GlobalTimerQuest:CancelQuest(self.judge_icon_active_time_quest)
			self.judge_icon_active_time_quest = nil
		end
	end, 0)
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

function MainUIView:MoveMainIcon(cfg)
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
		width = 93
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer + UnityEngine.Time.deltaTime
		if timer <= 0.5 then
			the_button.rect.sizeDelta = Vector2(width*timer * 2, width)
		elseif timer > 0.5 then
			the_button.rect.sizeDelta = Vector2(width, width)
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end, 0)
end

function MainUIView:GetButtonPos(name)
	if self["button_" .. name] and self["button_"..name].transform then
		return self["button_"..name].transform.position
	end
	return nil
end

function MainUIView:GetCanvasGroupBlockRayCasts(name)
	if self["button_" .. name] and self["button_" .. name].canvas_group then
		return self["button_" .. name].canvas_group.blocksRaycasts
	end
end

function MainUIView:SetButtonAlpha(name, alpha)
	if self["button_"..name] and self["button_"..name].canvas_group then
		self["button_"..name].canvas_group.alpha = alpha
	else
		print_warning("###########SetButtonAlpha has not canvas_group", name)
	end
end

function MainUIView:OnShowOrHideShrinkBtn(state)
	if not self:IsRendering() then return end
	self.shrink_button.toggle.isOn = state
	if state == false then
		self:MainRoleLevelChange()
	end
end

--初始化图标
function MainUIView:InitOpenFunctionIcon()
	local open_fun_data = OpenFunData.Instance
	for k,v in pairs(open_fun_data:OpenFunCfg()) do
		if v.icon ~= "" then			
			local is_show = open_fun_data:CheckIsHide(v.name)
			if self["show_"..v.name.."_icon"] then
				if v.name == "firstchargeview" then
				local is_can_show = DailyChargeData.Instance:GetThreeRechargeOpen(1)
				self.show_firstchargeview_icon:SetValue(is_show and is_can_show)
				--self:CheckShouFirstChargeEff()
				elseif v.name == "chongzhi" then
					local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
					self["show_"..v.name.."_icon"]:SetValue(is_show and not is_first)
					self:CheckShouFirstChargeEff()
				elseif v.name == "leichong" then
					local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
					self["show_"..v.name.."_icon"]:SetValue(is_show and not is_first)
				elseif v.name == "investview" then
					self["show_"..v.name.."_icon"]:SetValue(is_show and not DailyChargeData.Instance:GetFirstChongzhi10State())
				elseif v.name == "rebateview" then
					if nil ~= RebateCtrl.Instance.is_buy and self.show_rebateview_icon then
						local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
						self.show_rebateview_icon:SetValue(history_recharge >= DailyChargeData.Instance:GetMinRecharge() and RebateCtrl.Instance.is_buy and OpenFunData.Instance:CheckIsHide("rebateview"))
					end
				elseif v.name == "molongmibaoview" then
					self["show_"..v.name.."_icon"]:SetValue(is_show and MolongMibaoData.Instance:IsShowMolongMibao())
				elseif v.name == "CollectGoals" then
					self["show_"..v.name.."_icon"]:SetValue(is_show and TimeCtrl.Instance:GetCurOpenServerDay() <= 4)
				elseif v.name == "jubaopen" then
					self:CheckJuBaoPenIcon()
				elseif v.name == "daily_charge" then
					if self.Show_Daily_Charge then
						self.Show_Daily_Charge:SetValue(is_show and not is_first and is_daily)
					end
				elseif v.name == "zero_gift" then
					self["show_"..v.name.."_icon"]:SetValue(is_show and FreeGiftData.Instance:CanShowZeroGift())
				elseif v.name == "logingift7view" then
					self["show_"..v.name.."_icon"]:SetValue(is_show and SevenLoginGiftData.Instance:GetLoginAllReward() and not IS_AUDIT_VERSION)
				elseif v.name == "span_battle" or v.name == "royal_tomb" or v.name == "welfare" or v.name == "gold_member" or v.name == "ranking" then
					self["show_"..v.name.."_icon"]:SetValue(is_show and not IS_AUDIT_VERSION)
				else
					self["show_"..v.name.."_icon"]:SetValue(is_show)
				end
			end
			-- if is_show and v.name == "marriage" then
			-- 	RemindManager.Instance:Fire(RemindName.MarryMe)
			-- end
		end
	end
	if self.show_jingcaiactivity_icon then
		self.show_jingcaiactivity_icon:SetValue(false) --精彩活动还没做暂时关闭
	end
	for k,v in pairs(RemindFunName) do
		RemindManager.Instance:Fire(k)
	end
end

function MainUIView:FlushChargeIcon()
	if nil ~= DailyChargeData.Instance then
		local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
		local is_daily = DailyChargeData.Instance:GetDailyChongzhiOpen()
		local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
		-- if self.show_firstchargeview_icon then
		-- 	local open = OpenFunData.Instance:CheckIsHide("firstchargeview")
		-- 	self.show_firstchargeview_icon:SetValue(open and not is_first)
		-- 	-- self.has_first_recharge:SetValue(not DailyChargeData.Instance:GetFirstChongzhi10State())
		-- end
		if self.show_chongzhi_icon then

			local open = OpenFunData.Instance:CheckIsHide("vipview")
			self.show_chongzhi_icon:SetValue((open or IS_AUDIT_VERSION) and not is_first)
			--self.has_first_recharge:SetValue(not DailyChargeData.Instance:GetFirstChongzhi10State())
		end
		if self.show_daily_leiji then
			local flag = DailyChargeData.Instance:GetDailyLeiJiGetFlag()
			local open = OpenFunData.Instance:CheckIsHide("leiji_daily")
			self.show_daily_leiji:SetValue(open and flag and not is_first)
		end
		if self.show_leichong_icon then
			local open = OpenFunData.Instance:CheckIsHide("leichong")
			self.show_leichong_icon:SetValue(open and not is_first)
			-- self.has_first_recharge:SetValue(not DailyChargeData.Instance:GetFirstChongzhi10State())
		end
		if self.Show_Daily_Charge then
			local open = OpenFunData.Instance:CheckIsHide("daily_charge")
			self.Show_Daily_Charge:SetValue(open and not is_first)
		end
		-- if self.show_investview_icon then
		-- 	self.show_investview_icon:SetValue(history_recharge >= DailyChargeData.Instance:GetMinRecharge() and OpenFunData.Instance:CheckIsHide("investview"))
		-- end
		self:ShowRebateButton()
		self:CheckShouFirstChargeEff()
	end
end

function MainUIView:CheckShouFirstChargeEff()
	if self.first_recharge_view == nil or not self:IsRendering() then return end
	-- 首充模型显示条件：没首充过 + 功能开启
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
	local open = history_recharge < 10 and OpenFunData.Instance:CheckIsHide("firstchargeview")
	-- local open = not DailyChargeData.Instance:HasFirstRecharge() and OpenFunData.Instance:CheckIsHide("recharge")
	self.show_first_charge:SetValue(open)
	if open then
		self.first_recharge_view:OnFlush()
	end
end

function MainUIView:OnRoleAttrValueChange(key, new_value, old_value)
	if RemindByAttrChange[key] then
		for k,v in pairs(RemindByAttrChange[key]) do
			RemindManager.Instance:Fire(v)
		end
	end
	if key == "level" then
		self:ChangeFunctionTrailer()
		self:ChangeRewardItemByLevel(new_value)
		if math.abs(new_value - old_value) >= 1 and new_value ~= 1 then
			self:OnOpenTrigger(3, new_value)
			MainUICtrl.Instance:CheckMainUiChatIconVisible()
		else
			self:InitOpenFunctionIcon()
		end
		for k,v in pairs(self.tmp_activity_list) do
			self:ActivityChangeCallBack(v.activity_type, v.status, v.next_time, v.open_type)
		end
	elseif key == "special_appearance" and self.skill_view then
		self.skill_view:OnFlush({skill = true, special_appearance = new_value})
		if self.reminding_view then
			self.reminding_view:ChangeLianFuInfoStatus(new_value)
		end
	elseif key == "lover_uid" then
		self:SetButtonVisible(ActRemindNameT[ACTIVITY_TYPE.MARRY_ME], MarryMeData.Instance:GetMarryMeRemind(true))
	elseif key == "hp" or key == "max_hp" then
		local max_hp = PlayerData.Instance:GetRoleVo().max_hp
		self:SetRedBloodEffect(new_value, max_hp)
	elseif key == "mount_appeid" then
		self:Flush("mount_change")
	end
	self:SetJunXianImg()
end

function MainUIView:DayPass()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local total_day = CollectiveGoalsData.Instance:GetActiveTotalDay()
	if self.show_target_cd then
		self.show_target_cd:SetValue(server_open_day <= total_day)
	end
	RemindManager.Instance:Fire(RemindName.MoLongMiBao)
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

--显示膜拜点击按钮(攻城战)
function MainUIView:ShowCCWorshipBtn(state)
	if self.show_cc_worship_btn then
		self.show_cc_worship_btn:SetValue(state)
	end
end
--显示膜拜点击按钮(公会争霸)
function MainUIView:ShowGBWorshipBtn(state)
	if self.show_gb_worship_btn then
		self.show_gb_worship_btn:SetValue(state)
	end
end

------------------在线奖励----------------------------
function MainUIView:StopOnlineCountDown()
	if self.online_time_quest then
		GlobalTimerQuest:CancelQuest(self.online_time_quest)
		self.online_time_quest = nil
	end
end

function MainUIView:StarOnlineCountDown(target_time)
	local function timer_func()
		local online_time = WelfareData.Instance:GetTotalOnlineTime()
		local diff_sec = target_time - online_time
		if diff_sec <= 0 then
			self.online_time_text:SetValue(Language.Common.KeLingQu)
			self.show_online_redpoint:SetValue(true)
			--控制动画
			self.right_online_reward.animator:SetBool("shake", true)
			self:StopOnlineCountDown()
			return
		end

		local time_str = ""
		if diff_sec >= 3600 then
			--大于一小时的三位数
			time_str = TimeUtil.FormatSecond(diff_sec)
		else
			time_str = TimeUtil.FormatSecond(diff_sec, 2)
		end
		self.online_time_text:SetValue(time_str)
	end
	self.online_time_quest = GlobalTimerQuest:AddRunQuest(timer_func, 1)
end

function MainUIView:FlushOnlineReward()
	self:StopOnlineCountDown()
	local reward_data, is_all_get = WelfareData.Instance:GetOnlineReward()
	if nil == reward_data or nil == next(reward_data) then return end
	local scene_type = Scene.Instance:GetSceneType()
	local reward_need_sec = (reward_data.minutes) * 60
	if is_all_get or IS_ON_CROSSSERVER or scene_type ~= SceneType.Common then
		self.show_online_btn:SetValue(false)
	else
		self.show_online_btn:SetValue(true)
		local btn_text = ""
		local red_point_flag = false
		local online_time = WelfareData.Instance:GetTotalOnlineTime()
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
		self.online_time_text:SetValue(btn_text)
		self.show_online_redpoint:SetValue(red_point_flag)
		self.right_online_reward.animator:SetBool("shake", red_point_flag)
	end
end

function MainUIView:GetTaskView()
	return self.task_view
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
		return
	end
	if ui_name == GuideUIName.MainUIRoleHead then
		if ui_param == 1 then
			GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, true, false, true)
			return NextGuideStepFlag
		elseif ui_param == 2 then
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
		if ui_param == 1 then
			GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, true)
			return NextGuideStepFlag
		elseif ui_param == 2 then
			GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)
			return NextGuideStepFlag
		else
			if not self.shrink_button.toggle.isOn then
				return NextGuideStepFlag
			end
			local callback = BindTool.Bind(self.RightShrinkClick, self)
			return self.shrink_button, callback
		end
	elseif ui_name == GuideUIName.GeneralBtnBianShenEffect then
			--名将变身
		if not self.general_btn_bianShen_effect then
			return NextGuideStepFlag
		end
		local callback = self.skill_view:GetClickGeneralSkillCallBack()
		return self.general_btn_bianShen_effect, callback

	elseif ui_name == GuideUIName.MainUiButtonMilitaryRank then
		--军衔
		if self.button_militaryrank.gameObject.activeInHierarchy then
			return self.button_militaryrank, BindTool.Bind(self.OpenJunXianView, self)
		end
	elseif ui_name == GuideUIName.MainUiButtonNationalCitan then
		--国家战事
		if self.button_NationalWarfare.gameObject.activeInHierarchy then
			self.national_citai = true
			return self.button_NationalWarfare
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function MainUIView:GetMainCheckView()
	return self.chat_view
end

function MainUIView:OnTaskShrinkToggleChange(isOn)
	self.show_switch = not isOn
	self.show_switch_buttons:SetValue(not isOn and not self.MenuIconToggle.isOn)
end

function MainUIView:ChangeFightStateToggle(state, count)
	if state and FunctionGuide.Instance:GetIsGuide() then
		return
	end
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
end

--右下角屏蔽按钮点击
function MainUIView:FightStateClick(isOn)
	if not self.fight_state_button.toggle.enabled then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotHandle)
	else
		GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, not isOn)
		GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, not isOn)
		self:FlushFightRoleList()
	end
end

function MainUIView:OpenJunXianView()
	local task_data = TaskData.Instance:GetTaskCapAcceptedIdList()
	for k, v in pairs(task_data) do
		task_cfg = TaskData.Instance:GetTaskConfig(k)
		if task_cfg.task_type == TASK_TYPE.JUN then
			if TaskData.JunXianTaskLimit() then
				break
			end
			MilitaryRankCtrl.Instance:OpenDecreeView(DECREE_SHOW_TYPE.ACCEPT_TASK)
			return
		end
	end
	ViewManager.Instance:Open(ViewName.MilitaryRank)
end

function MainUIView:ChangeActHongBaoBtn(value)
	if self.show_activite_hongbao then
		self.show_activite_hongbao:SetValue(value)
	end
end

function MainUIView:ChangeBiPinBtn(value)
	if self.show_bipin then
		self.show_bipin:SetValue(value)
	end
end

function MainUIView:ChangeHappyBtn(value)
	if self.show_happy_bargain then
		self.show_happy_bargain:SetValue(value)
	end
	self:SetHappyBargainImg()
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

function MainUIView:SetJingcaiActImg()
	if self.jingcaiact_img == nil or not ActivityData.Instance then return end
	local img = "Icon_System_Activity"
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
		img = "Icon_System_CombineServer"
	elseif ActivityData.Instance:GetActivityIsOpen(KaifuActivityType.TYPE) then
		img = "Icon_System_LeiJiRecharge"
	end

	self.jingcaiact_img:SetAsset(ResPath.GetMainUIButton(img))

	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local kaifu_img = open_day > GameEnum.NEW_SERVER_DAYS and "Icon_System_KuangHuan" or "Icon_System_ActivityNewServer"
	self.kaifu_act_img:SetAsset(ResPath.GetMainUIButton(kaifu_img))
end

function MainUIView:SetJunXianImg()
	if self.junxian_img == nil then return end
	local img = "head_icon_1"
	if not MilitaryRankData.Instance then return end
	local cur_level = MilitaryRankData.Instance:GetCurLevel()
	if cur_level and 0 ~= cur_level then
		img = "head_icon_" .. cur_level
	end

	self.junxian_img:SetAsset(ResPath.GetMainUI(img))
end

function MainUIView:SetHappyBargainImg()
	local img_name = "Icon_HappyBargain_"
	local opengame_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if opengame_day ~= nil and opengame_day >= 8 and opengame_day <= 14 then
		img_name = img_name .. opengame_day
	else
		return
	end

	if self.happy_bargain_icon then
		self.happy_bargain_icon:SetAsset(ResPath.GetMainUIButton(img_name))
	end
end

function MainUIView:ShowIndexCallBack()
	self:ChangeFunctionTrailer()
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
		self.act_btn_time_list[ACTIVITY_TYPE.MARRY_ME]:SetValue("00:00")
	end
end

--计算储君有礼时间
function MainUIView:SetChuJunActTime()
	if self.chujun_count_down then
		CountDown.Instance:RemoveCountDown(self.chujun_count_down)
		self.chujun_count_down = nil
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
		self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT]:SetValue(time_des)
	end

	--计时函数
	local function time_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT]:SetValue("00:00")
			CountDown.Instance:RemoveCountDown(self.chujun_count_down)
			self.chujun_count_down = nil
		end

		--先计算出剩余时间秒数
		local times = total_time - math.floor(elapse_time)
		calc_times(times)
	end

	local left_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT)
	--不足1s按1s算（向上取整）
	left_time = math.ceil(left_time)
	if left_time > 0 then
		--活动进行中
		calc_times(left_time)
		self.chujun_count_down = CountDown.Instance:AddCountDown(left_time, 1, time_func)
	else
		--活动已结束
		self.act_btn_time_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT]:SetValue("00:00")
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
	if view and view.view_name == ViewName.ActivityHall then
		self.activity_hall_img:SetAsset(ResPath.GetMainUIButton("Icon_System_Act_Hall2"))
	end
end

function MainUIView:HasViewClose(view)
	if view and view.view_name == ViewName.ActivityHall then
		self.activity_hall_img:SetAsset(ResPath.GetMainUIButton("Icon_System_Act_Hall"))
	end
end

function MainUIView:SetBiPinImg()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	if nil == self.bipin_src or day > GameEnum.NEW_SERVER_DAYS then return end
	local bundle, asset = ResPath.GetMainUIButton("Icon_bipin_" .. day)
	self.bipin_src:SetAsset(bundle, asset)
end

function MainUIView:CheckMenuRedPoint()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.main_menu_redpoint then
		self.main_menu_redpoint:SetValue(main_role_vo.level >= SHOW_REDPOINT_LIMIT_LEVEL)
	end
end

function MainUIView:ChangeGeneralState()
	if self.is_general then
		local value = FamousGeneralData.Instance:GetCurUseSeq()
		local has_general_skill = FamousGeneralData.Instance:GetHasGeneralSkill()
		self.is_general:SetValue(value ~= -1 or has_general_skill)
	end
end

function MainUIView:SetRedBloodEffect(hp, max_hp)
	if self.red_blood_effect then
		self.red_blood_effect:SetActive(hp / max_hp <= self.low_blood_warning)
	end

	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Fishing then
		self.red_blood_effect:SetActive(false)
	end
end

-- 设置膜拜时间
function MainUIView:SetWorshipCountDown(time)
	if self.reminding_view then
		self.reminding_view:SetWorshipCountDown(time)
	end
end

function MainUIView:GetGBWorshipCountDown()
	if self.reminding_view then
		local count_down = self.reminding_view:GetGBWorshipCountDown()
		return count_down
	end
	return nil
end

function MainUIView:SetGBWorshipCountDown(time)
	if self.reminding_view then
		self.reminding_view:SetGBWorshipCountDown(time)
	end
end

-- 设置膜拜按钮CD
function MainUIView:ShowWorshipCdmask(state)
	if self.reminding_view then
		self.reminding_view:ShowWorshipCdmask(state)
	end
end

function MainUIView:ShowGBWorshipCdmask(state)
	if self.reminding_view then
		self.reminding_view:ShowGBWorshipCdmask(state)
	end
end

--传送按钮
function MainUIView:OnClickOpenTransfer(index)
	if index then
		self.call_index = index
		local camp_cfg = CallData.Instance:GetCampCall()
		if not camp_cfg then return end

		local scene_id = camp_cfg[index].scene_id
		local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
		if not scene_config then return end

		local scene_name = scene_config.name
		local x = camp_cfg[index].x
		local y = camp_cfg[index].y
		local name = camp_cfg[index].name
		local post = camp_cfg[index].post	
		local nation = camp_cfg[index].nation
		
		if camp_cfg[index].is_kf and camp_cfg[index].activity_type ~= nil then
			local act_cfg = ActivityData.Instance:GetActivityConfig(camp_cfg[index].activity_type)
			if act_cfg ~= nil and act_cfg.act_name ~= nil then
				scene_name = act_cfg.act_name .. Language.Common.DE .. "\n" .. scene_name
			end
		end

		--召集发起者
		local str = ""
		local call_type = camp_cfg[index].call_type
		if call_type == CALL_FROM_TYPE.CALL_TYPE_DACHEN_TO_DEFENDER or call_type == CALL_FROM_TYPE.CALL_TYPE_FLAG_TO_DEFENDER or call_type == CALL_FROM_TYPE.CALL_TYPE_QIYUN_TOWER then
			str = string.format(Language.Convene.CallFromDesc[call_type], scene_name, x, y)
		elseif call_type == CALL_FROM_TYPE.CALL_TYPE_DESTORY_TASK then
			str = string.format(Language.Convene.CallFromDesc[call_type],Language.Convene.Nation[nation], scene_name, x, y)
		else
			local post_name =  ToColorStr(Language.Convene.Post[index][post], COLOR.PURPLE)
			local name_with_color = ToColorStr(name, COLOR.GREEN)
			str = string.format(Language.Convene.CallDesc[index], post_name, name_with_color, scene_name, x, y)
		end

		local func = function ()
			if camp_cfg[index].is_kf and camp_cfg[index].activity_type ~= nil and not IS_ON_CROSSSERVER then
				if camp_cfg[index].call_info ~= nil then
					CallCtrl.Instance:SendCrossCallStartCross(camp_cfg[index].call_info)
				end
				--CrossServerCtrl.Instance:SendCrossStartReq(camp_cfg[index].activity_type, scene_id)
			else
				if scene_id and x and y then
					CallCtrl.Instance:TransferByCall(scene_id, x, y, nil, 1)
				else
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.FlyFail)
				end
			end
		end
		if nil ~= call_type and call_type == CALL_FROM_TYPE.CALL_TYPE_QIYUN_TOWER then
			local tip_str = string.format(Language.Convene.CallFromDesc[9]) 
			TipsCtrl.Instance:ShowCommonTip(func, nil, str,nil,nil,nil,true,nil,nil,nil,tip_str,nil,nil,nil,nil,30,true)
			return			
		end
		TipsCtrl.Instance:ShowCommonTip(func, nil, str)
	end
end

--自动接受召集的传送
function MainUIView:DoTransfer(index)
	if index then
		local camp_cfg = CallData.Instance:GetCampCall()
		local scene_id = camp_cfg[index].scene_id or 0
		local x = camp_cfg[index].x or 0
		local y = camp_cfg[index].y or 0
		CallCtrl.Instance:TransferByCall(scene_id, x, y, nil, 1)
	end
end

--召集按钮显示及倒计时
function MainUIView:SetTransferBtnVIsible(index)
	if self.transfer_begin_time == nil then
		self.transfer_begin_time = {}
	end

	self.transfer_begin_time[index] = TimeCtrl.Instance:GetServerTime()
	local other_config = ConfigManager.Instance:GetAutoConfig("other_config_auto").team_callin_scene
	local scene_id = Scene.Instance:GetSceneId()

	self:SetButtonVisible(self.transfer_reminding_name[index], true)
	for k, v in pairs(other_config) do
		if v.not_scene_id == scene_id then
			self:SetButtonVisible(self.transfer_reminding_name[index], false)
		end
	end
	self:OnClickOpenTransfer(index)
	self:TransferUpdataTime(index)
	GlobalTimerQuest:CancelQuest(self.transfer_time_quest[index])
	self.transfer_time_quest[index] = GlobalTimerQuest:AddTimesTimer(
		BindTool.Bind2(self.TransferUpdataTime, self, index), 1, 999999999)
end

--传送按钮倒计时
function MainUIView:TransferUpdataTime(index)
	local count_down_time = 0
	if index == 1 then
		count_down_time = 2 * 60			--国家倒计时
	elseif index == 2 then
		count_down_time = 2 * 60			--家族倒计时
	elseif	index == 3 then
		count_down_time = 2 * 60			--队伍倒计时
	end
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local reset_time_s = {}
	for i = 1, 3 do
		if self.transfer_begin_time[i] ~= nil then
			reset_time_s[i] = self.transfer_begin_time[i] + count_down_time - cur_time				-- 剩余时间 = 开始时间 + 任务时间 - 当前时间
		end
	end
	for i = 1, 3 do
		if self.call_time[i] then
			if reset_time_s[i] ~= nil and reset_time_s[i] > 0 then
				if reset_time_s[i] > 3600 then
					self.call_time[i]:SetValue(TimeUtil.FormatSecond(reset_time_s[i], 1))
				else
					self.call_time[i]:SetValue(TimeUtil.FormatSecond(reset_time_s[i], 2))
				end
			else
				self:SetButtonVisible(self.transfer_reminding_name[i], false)
				self.transfer_begin_time[i] = nil
			end
		end		
	end
	for i = 1, 3 do
		if(self.transfer_begin_time[i] == nil) then
			GlobalTimerQuest:CancelQuest(self.transfer_time_quest[i])
		end
	end
end

--召集传送成功
function MainUIView:OnResetPosCallBack()
	self.transfer_begin_time[self.call_index] = nil 		--使按钮消失并取消循环监听
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function MainUIView:ChangeMonster()	
	-- 获取所有可选对象
	local obj_list = Scene.Instance:GetObjListByType(SceneObjType.Monster)
	if not next(obj_list) then
		return
	end

	local temp_obj_list = {}
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local target_x, target_y = 0, 0

	local can_select = true
	for k, v in pairs(obj_list) do
		can_select = not v:IsRealDead()
		if can_select then
			target_x, target_y = v:GetLogicPos()
			table.insert(temp_obj_list, {obj = v, dis = GameMath.GetDistance(x, y, target_x, target_y, false)})
		end
	end
	if not next(temp_obj_list) then
		return
	end
	SortTools.SortAsc(temp_obj_list, "dis")

	-- 排除已选过的
	local select_obj_list = self.select_obj_group_list[SceneObjType.Monster]
	if nil == select_obj_list then
		select_obj_list = {}
		self.select_obj_group_list[SceneObjType.Monster] = select_obj_list
	end

	-- local select_obj = nil
	-- for i, v in ipairs(temp_obj_list) do
	-- 	if nil == select_obj_list[v.obj:GetObjId()] then
	-- 		select_obj = v.obj
	-- 		break
	-- 	end
	-- end

	-- 策划需求  只在血量最少的两个人里面来回选择
	local select_obj = nil
	for i, v in ipairs(temp_obj_list) do
		local last_select_obj = select_obj_list[SceneObjType.Monster]
		if nil == last_select_obj or last_select_obj:GetObjId() ~= v.obj:GetObjId() then
			select_obj = v.obj
			break
		end
	end

	-- 如果没有选中，选第一个，并清空已选列表
	if nil == select_obj then
		select_obj = temp_obj_list[1].obj
		select_obj_list = {}
		self.select_obj_group_list[SceneObjType.Monster] = select_obj_list
	end
	if nil == select_obj then
		return
	end
	select_obj_list[SceneObjType.Monster] = select_obj

	GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, select_obj, "select")

	return select_obj
end


function MainUIView:SetSceneCameraEffect(value)
	if self.scene_camera_effect then
		self.scene_camera_effect:SetValue(value)
	end
end

function MainUIView:ShowGuildChatRes(value)
	if self.chat_view ~= nil then
		self.chat_view:ShowGuildChatRes(value)
	end
end

function MainUIView:ShowGuildChatDaTi(value)
	self.chat_view:ShowGuildChatDaTi(value)
end

function MainUIView:ChangeHuanZhuangShopBtn(value)
	if self.is_show_huan_zhuang_shop_icon then
		self.is_show_huan_zhuang_shop_icon:SetValue(value)
	end
end

function MainUIView:ShowAdventureShop(value)
	if self.show_adventure_shop_icon then
		self.show_adventure_shop_icon:SetValue(value)
	end
end

function MainUIView:OpBanZhuan()
	local banzhuan_info = NationalWarfareData.Instance:GetCampBanzhuanStatus()
	if banzhuan_info.task_phase == 0 then
		local npc_cfg = NationalWarfareData.Instance:GetBanZhuanNpcCfg()
		NationalWarfareData.Instance:MoveTaskNpc(npc_cfg, GameVoManager.Instance:GetMainRoleVo().camp)
	else 
		local task_view = MainUICtrl.Instance:GetView():GetTaskView()
		if task_view then
			local task_data = NationalWarfareData.Instance:GetBanZhuanTaskCfg()
			task_view:OperateTask(task_data)
		end
	end
end

function MainUIView:OnChangeScene(scene_id)
	local other_config = ConfigManager.Instance:GetAutoConfig("other_config_auto").team_callin_scene
	
	for i = 1, 3 do
		for k, v in pairs(other_config) do
			if v.not_scene_id == scene_id then
				self:SetButtonVisible(self.transfer_reminding_name[i], false)
			end
		end
	end
end

--------------------------------------------------------------------------
local MODEL_CFG = {
	[1] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1.5, 1.5, 1.5),
	},
	[2] = {
		rotation = Vector3(0, -20, 0),
		scale = Vector3(1.5, 1.5, 1.5),
	},
	[3] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1.3, 1.3, 1.3),
	},
	[4] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1.2, 1.2, 1.2),
	},
}
MainUIFirstCharge = MainUIFirstCharge or BaseClass(BaseRender)

function MainUIFirstCharge:__init()
	self.model_display = self:FindObj("model")
end

function MainUIFirstCharge:__delete()
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
end

function MainUIFirstCharge:OnFlush()
	if nil == self.model_view then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local camera = "first_charge_view_" .. main_role_vo.prof
		self.model_view = RoleModel.New(camera)
		self.model_view:SetDisplay(self.model_display.ui3d_display)
		local reward_cfg = DailyChargeData.Instance:GetFirstRewardByWeek()
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local num_str = string.format("%02d", reward_cfg.wepon_index2)
		local weapon_show_id = "950" .. main_role_vo.prof .. "00202"
		self.model_view:SetMainAsset(ResPath.GetWeaponShowModel(weapon_show_id, "950"..main_role_vo.prof.."002"))
		self.model_view:SetLoadComplete(BindTool.Bind(self.ModelLoadCompleteCallBack,self))
		self.model_view:SetTransform(MODEL_CFG[main_role_vo.prof])
		-- local cfg =	self.model_view.ui3d_display_cfg.mainview_weapon_model[tonumber(weapon_show_id)]
		-- if cfg then
		-- 	self.model_view:SetTransform(cfg)
		-- end
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

function MainUIView:OpenThreeRechargeView()
	DailyChargeData.Instance:SetShowPushIndex(3)
	self.show_charge_effect2:SetValue(false)
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

-- 首冲、再充、三充面板
function MainUIView:OpenRechargeView()
	DailyChargeData.Instance:SetShowPushIndex(2)
	 --self.show_charge_effect1:SetValue(false)
	ViewManager.Instance:Open(ViewName.SecondChargeView)
end

function MainUIView:IsPauseAutoTask()
	if self.task_view then
		return self.task_view:IsPauseAutoTask()
	end
	return true
end

function MainUIView:OpenQixiActivity()
	ViewManager.Instance:Open(ViewName.ActivityQiXiView)
end

function MainUIView:OpenMidAutumnView()
	ViewManager.Instance:Open(ViewName.ActivityMidAutumnView)
end
function MainUIView:OpenjunGiftActivity()
	ViewManager.Instance:Open(ViewName.KaifuActivityView, TabIndex.kaifu_chujun)
end

function MainUIView:GetXunLunState()
	if self.reminding_view then
		return self.reminding_view:GetIsXunLuState()
	end
end

function MainUIView:IsDoubleRechargeShake()
	if self.charge_double_shake then
		if self.double_shake_next_timer == nil then
			self:DoubleRechargeShake(5)
			self.double_shake_next_timer = GlobalTimerQuest:AddRunQuest(function()			--每隔10分钟抖动
				self:DoubleRechargeShake(10)
			end, 600)
		end
	end
end

function MainUIView:DoubleRechargeShake(time)
	if self.charge_double_shake then
		self.charge_double_shake:SetValue(true)
	end
	GlobalTimerQuest:AddDelayTimer(function()
		if self.charge_double_shake then
			self.charge_double_shake:SetValue(false)
		end
	end, time)
end

function MainUIView:CheckShowMount()
	if self.joystick_view then
		self.joystick_view:CheckShowMount()
	end
end

function MainUIView:OnClickFlushList()
	if self.last_flush_time + PLAYER_FLUSH_CD >= Status.NowTime then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OperateFrequencyTip)
		return
	else
		self:FlushFightRoleList()
		self.last_flush_time = Status.NowTime
	end
end

function MainUIView:OpenDressShop()
	ViewManager.Instance:Open(ViewName.DressShopView)
end

function MainUIView:FlushFightRoleList()
	if self.attack_list then
		local obj_list = Scene.Instance:GetObjListByType(SceneObjType.Role)
		self.fight_role_list = {}
		for k,v in pairs(obj_list) do
			if Scene.Instance:IsEnemy(v) then
				table.insert(self.fight_role_list, {obj = v, capability = v:GetVo().total_capability})
			end
		end
		SortTools.SortDesc(self.fight_role_list, "capability")
		self.attack_list.scroller:ReloadData(0)
	end
end

function MainUIView:GetRollNumberOfCells()
	local length = #self.fight_role_list
	-- 策划说最多显示8个
	local num = length < ATTACK_LIST_MAX and length or ATTACK_LIST_MAX
	return num
end

function MainUIView:RefreshRoleCell(cell, data_index)
	local role_cell = self.role_cell_list[cell]
	data_index = data_index + 1
	if not role_cell then
		role_cell = AttackRoleCell.New(cell.gameObject, self)
		self.role_cell_list[cell] = role_cell
	end
	role_cell:SetIndex(data_index)
	role_cell:SetData(self.fight_role_list[data_index] or {})
	role_cell:FlushHL()
end

function MainUIView:GetSelectIndex()
	return self.attack_select_index
end

function MainUIView:FlushAttackHL()
	for k,v in pairs(self.role_cell_list) do
		v:FlushHL()
	end
end

function MainUIView:SetCurIndex(index)
	self.attack_select_index = index or 0
end

function MainUIView:OnObjDead(obj)
	if self.last_auto_time + AUTO_FLUSH_CD >= Status.NowTime then return end
	if obj and not obj:IsMainRole() then
		for k,v in pairs(self.fight_role_list) do
			if v.obj:GetVo().role_id == obj:GetVo().role_id then
				self:FlushFightRoleList()
				self.last_auto_time = Status.NowTime
			end
		end
	end
end

function MainUIView:OpenTempShenJi()
	RoleSkillCtrl.Instance:OpenShenJIView()
end

-----------------------------------AttackRoleCell----------------------
AttackRoleCell = AttackRoleCell or BaseClass(BaseCell)
function AttackRoleCell:__init(instance, parent)
	self.parent = parent
	self.role_name = self:FindVariable("Name")
	self.guild_name = self:FindVariable("CurHp")
	self.show_hl = self:FindVariable("ShowHL")
	self:ListenEvent("CilickRole", BindTool.Bind(self.OnClickRole, self))
end

function AttackRoleCell:__delete()
	self.parent = nil
end

function AttackRoleCell:OnFlush()
	if not self.data or not next(self.data) then return end
	local role_vo = self.data.obj:GetVo()
	if not role_vo or not next(role_vo) then return end
	local name_str = ToColorStr(Language.Common.ScnenCampNameAbbr[role_vo.camp], CAMP_COLOR[role_vo.camp]) .. "·" .. role_vo.name
	self.role_name:SetValue(name_str)
	self.guild_name:SetValue(role_vo.guild_name)
end

function AttackRoleCell:OnClickRole()
	if self.parent then
		self.parent:SetCurIndex(self.index)
		self.parent:FlushAttackHL()
	end
	if not self.data.obj:IsRealDead() then
		GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, self.data.obj, SceneTargetSelectType.SELECT)
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	else
		if not self.data or not self.data.obj then return end
		local role_vo = self.data.obj:GetVo()
		if not role_vo then return end
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), role_vo.pos_x, role_vo.pos_y)
	end
end

function AttackRoleCell:FlushHL()
	if self.parent and self.show_hl then
		local cur_index = self.parent:GetSelectIndex()
		self.show_hl:SetValue(self.index == cur_index)
	end
end