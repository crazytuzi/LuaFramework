require("game/kaifuactivity/kaifu_activity_data")
require("game/kaifuactivity/kaifu_activity_view")
require("game/kaifuactivity/kaifu_activity_panel_one")
require("game/kaifuactivity/kaifu_activity_panel_three")
require("game/kaifuactivity/kaifu_activity_panel_six")
require("game/kaifuactivity/kaifu_activity_panel_seven")
require("game/kaifuactivity/kaifu_activity_panel_eight")
require("game/kaifuactivity/kaifu_activity_panel_two")
require("game/kaifuactivity/kaifu_activity_panel_ten")
require("game/kaifuactivity/kaifu_activity_panel_twelve")
-- require("game/kaifuactivity/kaifu_activity_panel_personal_buy")
require("game/welfare/welfare_level_reward_view")
require("game/kaifuactivity/kaifu_activity_panel_boss_reward")
require("game/kaifuactivity/kaifu_activity_panel_war_goals")
require("game/kaifuactivity/kaifu_activity_panel_chujun_gift")
require("game/kaifuactivity/kaifu_activity_panel_marry_gift")
require("game/kaifuactivity/kaifu_activity_panel_daily_national")
require("game/kaifuactivity/kaifu_activity_active_reward")
require("game/kaifuactivity/kaifu_activity_panel_exp_refine")

require("game/kaifuactivity/kaifu_activity_panel_lianchongtehui_gao")
require("game/kaifuactivity/kaifu_activity_panel_lianchongtehui_chu")
require("game/kaifuactivity/kaifu_activity_panel_total_consume")
-- require("game/kaifuactivity/combine_server_dan_bi_chong_zhi_view")

local PaiHangBang_Index = {PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT, PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING, PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO,
					PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG, PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI,
						[9] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP, [10] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP,
		}

KaifuActivityCtrl = KaifuActivityCtrl or BaseClass(BaseController)

function KaifuActivityCtrl:__init()
	if KaifuActivityCtrl.Instance ~= nil then
		print_error("[KaifuActivityCtrl] Attemp to create a singleton twice !")
	end
	KaifuActivityCtrl.Instance = self
	self.view = KaifuActivityView.New(ViewName.KaifuActivityView)
	self.data = KaifuActivityData.New()

	self.activity_change = BindTool.Bind(self.ActivityChange, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change)

	self.battle_change = BindTool.Bind(self.BattleActivityChange, self)
	self.data:NotifyActChangeCallback(self.battle_change)

	self.scene_load_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.SceneLoadComplete, self))
	self.time_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.ServerOpenDay, self))
	self:RegisterAllProtocols()
	RemindManager.Instance:Register(RemindName.ItemCollection, BindTool.Bind(self.GetItemCollectionRedNum, self))
	RemindManager.Instance:Register(RemindName.BossXuanshang, BindTool.Bind(self.GetBossXuanshangRedNum, self))
	RemindManager.Instance:Register(RemindName.ActiveReward, BindTool.Bind(self.GetActiviteRewardRedNum, self))
end

function KaifuActivityCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.scene_load_complete ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_complete)
		self.scene_load_complete = nil
	end

	if self.time_quest ~= nil then
		GlobalEventSystem:UnBind(self.time_quest)
		self.time_quest = nil
	end

	if self.activity_change ~= nil then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change)
		self.activity_change = nil
	end

	if self.battle_change ~= nil then
		self.data:UnNotifyActChangeCallback(self.battle_change)
		self.battle_change = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	RemindManager.Instance:UnRegister(RemindName.ItemCollection)
	RemindManager.Instance:UnRegister(RemindName.BossXuanshang)
	RemindManager.Instance:UnRegister(RemindName.ActiveReward)
	KaifuActivityCtrl.Instance = nil
end

function KaifuActivityCtrl:GetView()
	return self.view
end

function KaifuActivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAOpenServerInfo, "OnKaifuActivityInfo")
	self:RegisterProtocol(SCRAOpenServerUpgradeInfo, "OnActivityUpgradeInfo")
	self:RegisterProtocol(SCRAOpenServerRankInfo, "OnOpenServerRankInfo")
	self:RegisterProtocol(SCRAOpenServerBossInfo, "OnOpenServerBossInfo")
	self:RegisterProtocol(SCRAOpenServerBattleInfo, "OnOpenServerBattleInfo")
	--self:RegisterProtocol(SCRATotalChargeInfo, "OnRATotalChargeInfo")

	-- 礼包限购协议信息
	self:RegisterProtocol(SCRAOpenGameGiftShopBuyInfo, "OnRAOpenGameGiftShopBuyInfo")

	-- 百倍商城(个人抢购)
	self:RegisterProtocol(SCRAPersonalPanicBuyInfo, "OnRAPersonalPanicBuyInfo")

	-- 集字活动兑换次数
	self:RegisterProtocol(SCCollectExchangeInfo, "OnCollectExchangeInfo")
	
	-- Boss悬赏
	self:RegisterProtocol(SCRABossXuanshangInfo, "OnRABossXuanshangInfo")

	-- 战事目标
	self:RegisterProtocol(SCRAWarGoalInfo, "OnWarGoalsInfo")

	--每日国事
	self:RegisterProtocol(SCRADailyNationWarInfo, "OnDailyNationalInfo")

	-- 储君有礼
	self:RegisterProtocol(SCRAChujunGiftInfo, "OnRAChujunGiftInfo")

	--结婚礼金
	self:RegisterProtocol(SCRAMarryGiftInfo, "OnSCRAMarryGiftInfo")

	-- 活跃奖励
	self:RegisterProtocol(SCRADayActiveDegreeInfo, "OnRADayActiveDegreeInfo")

	self:RegisterProtocol(SCChargeRewardInfo, "OnSCChargeRewardInfo")

	-- 连充特惠初
	self:RegisterProtocol(SCRAContinueChongzhiInfoChu, "OnRAContinueChongzhiInfoChu")

	-- 连充特惠高
	self:RegisterProtocol(SCRAContinueChongzhiInfoGao, "OnRAContinueChongzhiInfoGao")

	-- 感恩回馈 
	self:RegisterProtocol(SCRAAppreciationRewardInfo, "OnSCRAAppreciationRewardInfo")

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

-- 活动信息
function KaifuActivityCtrl:OnKaifuActivityInfo(protocol)
	self.data:SetActivityInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
	RemindManager.Instance:Fire(RemindName.BiPin)

	if CompetitionActivityCtrl.Instance.view:IsOpen() then
		CompetitionActivityCtrl.Instance:GetView():CurValueGrade()
		CompetitionActivityCtrl.Instance:GetView():FlushBtnReward()
	end

	-- MainUICtrl.Instance.view:SetAllRedPoint()
	-- KaiFuChargeCtrl.Instance:CurValueGrade()
	KaiFuChargeCtrl.Instance:FlushBiPin()
	KaiFuChargeCtrl.Instance:Flush("kaifu_group_buy")
end

function KaifuActivityCtrl:OnRAContinueChongzhiInfoChu(protocol)
	self.data:SetChongZhiChu(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.LianChongTeHuiChu)
	RemindManager.Instance:Fire(RemindName.RemindGroupBuyRedpoint)
	KaiFuChargeCtrl.Instance:Flush("rush_chu_baserender")
end

function KaifuActivityCtrl:OnRAContinueChongzhiInfoGao(protocol)
	self.data:SetChongZhiGao(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.LianChongTeHuiGao)
	KaiFuChargeCtrl.Instance:Flush("rush_tall_baserender")
end

function KaifuActivityCtrl:OnSCRATotalConsumeGoldInfo(protocol)
	self.data:SetRATotalConsumeGoldInfo(protocol)
	self.view:FlushTotalConsume()
	RemindManager.Instance:Fire(RemindName.KaiFuTotalReward)
end

-- 全服进阶信息
function KaifuActivityCtrl:OnActivityUpgradeInfo(protocol)
	self.data:SetActivityUpgradeInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

function KaifuActivityCtrl:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
	if IS_ON_CROSSSERVER then
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = rand_activity_type or 0
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end

function KaifuActivityCtrl:OnOpenServerRankInfo(protocol)
	self.data:SetOpenServerRankInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

-- 开服活动boss猎手信息返回
function KaifuActivityCtrl:OnOpenServerBossInfo(protocol)
	self.data:SetBossLieshouInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)

	if not self.data:IsShowKaifuIcon() and self.view:IsOpen() then
		self.view:Close()
	end
end

-- 累计充值活动信息返回
function KaifuActivityCtrl:OnRATotalChargeInfo(protocol)
	self.data:SetLeiJiChongZhiInfo(protocol)
	self.view:Flush()
	-- LeiJiRechargeCtrl.Instance:LeiJiRechargeFlush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
	RemindManager.Instance:Fire(RemindName.KfLeichong)
end

-- 开服活动战场争霸信息
function KaifuActivityCtrl:OnOpenServerBattleInfo(protocol)
	self.data:SetBattleUidInfo(protocol)
	if protocol.yuansu_uid > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.yuansu_uid)
	end
	if protocol.guildbatte_uid > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.guildbatte_uid)
	end
	if protocol.gongchengzhan_uid > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.gongchengzhan_uid)
	end
	if protocol.territorywar_uid > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.territorywar_uid)
	end
	self.view:Flush()
end

function KaifuActivityCtrl:GetKaiFuHuoDongTime()
	self.view:GetKaiFuTime()
end

-- 设置战场争霸人物信息
function KaifuActivityCtrl:SetBattleRoleInfo(uid, protocol)
	local uid_info = self.data:GetBattleUidInfo()
	for k, v in pairs(uid_info) do
		if v == uid and v > 0 and not self.data:GetBattleRoleInfo()[k] then
			self.data:SetBattleRoleInfo(k, protocol)
			CollectiveGoalsCtrl.Instance:GetView():Flush()
			if self.view:IsOpen() then
				self.view:Flush()
			end
			break
		end
	end
end

-- 设置礼包限购信息
function KaifuActivityCtrl:OnRAOpenGameGiftShopBuyInfo(protocol)
	self.data:SetGiftShopFlag(protocol)
	KaiFuChargeCtrl.Instance:Flush("kaifu_activity_panel_twelve")
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

-- 购买礼包
function KaifuActivityCtrl:SendRAOpenGameGiftShopBuy(seq)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRAOpenGameGiftShopBuy)
	protocol.seq = seq or 0
	protocol:EncodeAndSend()
end

-- 请求礼包信息
function KaifuActivityCtrl:SendRAOpenGameGiftShopBuyInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSRAOpenGameGiftShopBuyInfoReq)
	protocol:EncodeAndSend()
end

-- 百倍商城购买数量信息
function KaifuActivityCtrl:OnRAPersonalPanicBuyInfo(protocol)
	self.data:SetPersonalBuyInfo(protocol.buy_numlist)
	KaiFuChargeCtrl.Instance:Flush("kaifu_personal_buy")
	ViewManager.Instance:FlushView(ViewName.TipsCommonBuyView)
end


-- 集字活动兑换次数
function KaifuActivityCtrl:OnCollectExchangeInfo(protocol)
	self.data:SetCollectExchangeInfo(protocol.exchange_times)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

-- 感恩回馈
function KaifuActivityCtrl:OnSCRAAppreciationRewardInfo(protocol)
	self.data:SetThanksFeedBackData(protocol)
	KaiFuChargeCtrl.Instance:Flush("thanks_feed_back")
	RemindManager.Instance:Fire(RemindName.ThanksFeedBackRedPoint)
end

function KaifuActivityCtrl:FlushKaifuView()
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KaifuActivityCtrl:FlushView()
	if self.view:IsOpen() then
		self.view:FlushJinJieView()
	end
end

function KaifuActivityCtrl:ServerOpenDay(cur_day, is_new_day)
	if not is_new_day or IS_ON_CROSSSERVER then return end

	if not self.data:IsShowKaifuIcon() then
		MainUICtrl.Instance:SetNewServerBtnState()
		if self.view:IsOpen() then
			self.view:Close()
		end
		return
	end
	if self.data:IsShowKaifuIcon() then

		self.data:ClearActivityInfo()

		local list = self.data:GetOpenActivityList()
		if list == nil or next(list) == nil then
			return
		end
		for k, v in pairs(list) do
			if self.data.info[v.activity_type] == nil then
				if self.data:IsBossLieshouType(v.activity_type) then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_BOSS_INFO)
				elseif self.data:IsZhengBaType(v.activity_type) then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT then 	--开服活动礼包限购
					self:SendRAOpenGameGiftShopBuyInfo()
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP then --开服百倍商城
					self:SendGetKaifuActivityInfo(v.activity_type, RA_PERSONAL_PANIC_BUY_OPERA_TYPE.RA_PERSONAL_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
				else
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
				end
			end

			if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
				HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
			end
		end
		self.view:Flush()
	end
end

function KaifuActivityCtrl:SceneLoadComplete()
	-- 在跨服
	if IS_ON_CROSSSERVER then return end

	if self.data:IsShowKaifuIcon() then
		local list = self.data:GetOpenActivityList(TimeCtrl.Instance:GetCurOpenServerDay())
		if list == nil or next(list) == nil then return end
		for k, v in pairs(list) do
			if self.data.info[v.activity_type] == nil then
				if self.data:IsBossLieshouType(v.activity_type) then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_BOSS_INFO)
				elseif self.data:IsZhengBaType(v.activity_type) then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT then 	--开服活动礼包限购
					self:SendRAOpenGameGiftShopBuyInfo()
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP then --开服百倍商城
					self:SendGetKaifuActivityInfo(v.activity_type, RA_PERSONAL_PANIC_BUY_OPERA_TYPE.RA_PERSONAL_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
				else
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
				end
			end
		end
	end
	RemindManager.Instance:Fire(RemindName.KaiFuIsFirst)
end

-- 开服争霸活动改变
function KaifuActivityCtrl:BattleActivityChange(activity_type, status, next_time, open_type)
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA) then
		local act_info = self.data:GetActivityStatuByType(activity_type) or {}
		if act_info.status ~= status then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA,
				RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)
		end
	end
end

function KaifuActivityCtrl:ActivityChange(activity_type, status, next_time, open_type)
	-- 在跨服
	if IS_ON_CROSSSERVER then return end

	if not self.data:IsShowKaifuIcon() and (KaifuActivityType.TYPE == activity_type and status ~= ACTIVITY_STATUS.OPEN) then
		MainUICtrl.Instance:SetNewServerBtnState()
		if self.view:IsOpen() then
			self.view:Close()
		end
		return
	end
	if status == 2 and (activity_type == KaifuActivityType.TYPE or self.data:IsKaifuActivity(activity_type)) then
		local list = self.data:GetOpenActivityList(TimeCtrl.Instance:GetCurOpenServerDay())
		local activity_info = ActivityData.Instance:GetActivityStatuByType(activity_type)
		if list == nil or next(list) == nil then
			return
		end
		for k, v in pairs(list) do
			if self.data.info[v.activity_type] == nil or (activity_info and activity_info.status ~= status) then
				if self.data:IsBossLieshouType(v.activity_type) then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_BOSS_INFO)
				elseif self.data:IsZhengBaType(v.activity_type) then
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)

				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT then 	--开服活动礼包限购
					self:SendRAOpenGameGiftShopBuyInfo()
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP then --开服百倍商城
					self:SendGetKaifuActivityInfo(v.activity_type, RA_PERSONAL_PANIC_BUY_OPERA_TYPE.RA_PERSONAL_PANIC_BUY_OPERA_TYPE_QUERY_INFO)
				else
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
				end
			end
		end
	end
end
function KaifuActivityCtrl:OnRABossXuanshangInfo(protocol)
	self.data:SetBossXuanshangInfo(protocol)
	RemindManager.Instance:Fire(RemindName.BossXuanshang)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

--战事目标
function KaifuActivityCtrl:OnWarGoalsInfo(protocol)
	self.data:SetWarGoalsInfo(protocol)
	RemindManager.Instance:Fire(RemindName.WarGoals)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

--每日国事
function KaifuActivityCtrl:OnDailyNationalInfo(protocol)
	self.data:SetDailyNationalInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

--储君有礼
function KaifuActivityCtrl:OnRAChujunGiftInfo(protocol)
	self.data:SetChujunGiftInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

--结婚礼金
function KaifuActivityCtrl:OnSCRAMarryGiftInfo(protocol)
	self.data:SetMarryGiftInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

--每日活跃奖励
function KaifuActivityCtrl:OnRADayActiveDegreeInfo(protocol)
	self.data:SetDayActiveDegreeInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.ActiveReward)
end

function KaifuActivityCtrl:SendRandActivityOperaReq(rand_activity_type, opera_type, param_1, param_2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = rand_activity_type
	protocol.opera_type = opera_type
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end

function KaifuActivityCtrl:OnSCChargeRewardInfo(protocol)
	self.data:SetChargeRewardInfo(protocol)
	KaiFuChargeCtrl.Instance:Flush()
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.KaiFuLeiJiReward)
end

function KaifuActivityCtrl:GetItemCollectionRedNum()
	if KaifuActivityData.Instance:IsShowJiZiRedPoint() then
		return 1
	end
	return 0
end

function KaifuActivityCtrl:GetBossXuanshangRedNum()
	if KaifuActivityData.Instance:GetBossRewardRedPoint() then
		return 1
	end
	return 0
end

function KaifuActivityCtrl:GetActiviteRewardRedNum()
	return KaifuActivityData.Instance:IsShowDayActiveRedPoint() and 1 or 0
end

--主界面创建
function KaifuActivityCtrl:MainuiOpenCreate()
	local  activity_type_list = {
		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU,
		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO,
		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_TOTAL_CHONGZHI,
	}
		for i,v in ipairs(activity_type_list) do
		if ActivityData.Instance:GetActivityIsOpen(v) then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
		end
	end
end

function KaifuActivityCtrl:FlushView(key)
	if self.view:IsOpen() then
		self.view:Flush(key)
	end
end