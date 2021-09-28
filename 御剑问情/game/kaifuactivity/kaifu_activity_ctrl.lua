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
require("game/kaifuactivity/kaifu_activity_panel_personal_buy")
require("game/welfare/welfare_level_reward_view")
require("game/kaifuactivity/kaifu_activity_panel_fifteen")
require("game/kaifuactivity/kaifu_activity_panel_sixteen")
require("game/kaifuactivity/kaifu_activity_panel_danbichongzhi")
-- require("game/kaifuactivity/kaifu_activity_panel_bianshen_rank")
-- require("game/kaifuactivity/kaifu_activity_panel_beibianshen_rank")
require("game/kaifuactivity/kaifu_activity_panel_lianchongtehui_gao")
require("game/kaifuactivity/kaifu_activity_panel_lianchongtehui_chu")
require("game/kaifuactivity/kaifu_activity_panel_xiaofei_rank")
require("game/kaifuactivity/kaifu_activity_panel_daily_love")

require("game/kaifuactivity/kaifu_activity_goldenpigcall_view")
require("game/kaifuactivity/kaifu_activity_panel_congzhi_rank")

require("game/kaifuactivity/kaifu_activity_7day_redpacket")
require("game/kaifuactivity/daily_active_reward")
require("game/kaifuactivity/kaifu_activity_panel_total_charge")
require("game/kaifuactivity/kaifu_activity_panel_recharge_rebate")
require("game/kaifuactivity/kaifu_activity_panel_leiji_reward")
require("game/kaifuactivity/kaifu_activity_panel_boss_loot")
require("game/kaifuactivity/combine_server_dan_bi_chong_zhi_view")
require("game/kaifuactivity/kaifu_activity_panel_total_consume")
require("game/kaifuactivity/kaifu_activity_panel_day_consume")
require("game/kaifuactivity/kaifu_activity_panel_dailydanbi")
require("game/kaifuactivity/kaifu_activity_zhizunhuiyuan_view")
require("game/kaifuactivity/kaifu_activity_levelinvestment_view")
require("game/kaifuactivity/kaifu_activity_touziplan_view")
require("game/kaifuactivity/expense_reward_pool_panel_kaifu")
require("game/kaifuactivity/kaifu_activity_expense_gift")

require("game/kaifuactivity/kaifu_rising_star_view")


KaifuActivityCtrl = KaifuActivityCtrl or BaseClass(BaseController)

function KaifuActivityCtrl:__init()
	if KaifuActivityCtrl.Instance ~= nil then
		print_error("[KaifuActivityCtrl] Attemp to create a singleton twice !")
	end

	KaifuActivityCtrl.Instance = self
	self.view = KaifuActivityView.New(ViewName.KaifuActivityView)
	self.data = KaifuActivityData.New()
	self.sheng_xing_view = KaiFuRisingStarView.New(ViewName.KiaFuRisingStarView)
	self.degree_rewards_view = KaiFuDegreeRewardsView.New(ViewName.KaiFuDegreeRewardsView)

	self.activity_change = BindTool.Bind(self.ActivityChange, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change)

	self.battle_change = BindTool.Bind(self.BattleActivityChange, self)
	self.data:NotifyActChangeCallback(self.battle_change)

	self.scene_load_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.SceneLoadComplete, self))
	self.time_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.ServerOpenDay, self))
	self:RegisterAllProtocols()

	-- self.item_data_change_callback = BindTool.Bind1(self.OnItemDataChange, self)
	-- ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)
end

function KaifuActivityCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.sheng_xing_view then
		self.sheng_xing_view:DeleteMe()
		self.sheng_xing_view = nil
	end

	if self.degree_rewards_view then
		self.degree_rewards_view:DeleteMe()
		self.degree_rewards_view = nil
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

	-- ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)

	if nil ~= self.collection_start_timing then
		GlobalTimerQuest:CancelQuest(self.collection_start_timing)
	end

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
	self:RegisterProtocol(SCRATotalChargeInfo, "OnRATotalChargeInfo")

	self:RegisterProtocol(CSRandActivityOperaReq)



    -- 活跃奖励
	self:RegisterProtocol(SCRADayActiveDegreeInfo, "OnRADayActiveDegreeInfo")

	-- 礼包限购协议信息
	self:RegisterProtocol(SCRAOpenGameGiftShopBuyInfo, "OnRAOpenGameGiftShopBuyInfo")

	-- 百倍商城(个人抢购)
	self:RegisterProtocol(SCRAPersonalPanicBuyInfo, "OnRAPersonalPanicBuyInfo")

	-- 集字活动兑换次数
	self:RegisterProtocol(SCCollectExchangeInfo, "OnCollectExchangeInfo")

	-- 每日充值排行
	self:RegisterProtocol(SCRADayChongzhiRankInfo, "OnRADayChongzhiRankInfo")

	-- 连充特惠初
	self:RegisterProtocol(SCRAContinueChongzhiInfoChu, "OnRAContinueChongzhiInfoChu")

	-- 连充特惠高
	self:RegisterProtocol(SCRAContinueChongzhiInfoGao, "OnRAContinueChongzhiInfoGao")

	--金猪召唤积分信息
	self:RegisterProtocol(SCGoldenPigOperateInfo, "OnGoldenPigCallInfo")
	--金猪召唤Boss状态
	self:RegisterProtocol(SCGoldenPigBossState, "OnGoldenPigCallBossInfo")

	self:RegisterProtocol(SCOpenServerInvestInfo, "OnReciveInvestInfo")

	-- self:RegisterProtocol(SCActivityStatus, "OnActivityStatus")
	--全民抢购
	self:RegisterProtocol(SCRAServerPanicBuyInfo, "OnSCRAServerPanicBuyInfo")

    --累充回馈
	self:RegisterProtocol(SCChargeRewardInfo, "OnSCChargeRewardInfo")

	--累计充值
	self:RegisterProtocol(SCRANewTotalChargeInfo, "OnSCRANewTotalChargeInfo")

	--充值返利
	self:RegisterProtocol(SCRADayChongZhiFanLiInfo, "OnSCRADayChongZhiFanLiInfo")

	-- 每日消费排行
	self:RegisterProtocol(SCRADayConsumeRankInfo, "OnRADayConsumeRankInfo")

	--累计消费
	self:RegisterProtocol(SCRATotalConsumeGoldInfo, "OnSCRATotalConsumeGoldInfo")

	-- 每日累计消费
	self:RegisterProtocol(SCRADayConsumeGoldInfo, "OnRADayConsumeGoldInfo")

	-- 每日单笔
	self:RegisterProtocol(SCRADanbiChongzhiInfo, "OnRADanbiChongzhiInfo")

	-- 升星助力
	self:RegisterProtocol(CSGetShengxingzhuliInfoReq)
	self:RegisterProtocol(CSGetShengxingzhuliRewardReq)
	self:RegisterProtocol(SCGetShengxingzhuliInfoAck, "OnSCGetShengxingzhuliInfoAck")
	self:RegisterProtocol(SCGetShengxingzhuliRewardAck, "OnSCGetShengxingzhuliRewardAck")

	self:RegisterProtocol(SCRAExpenseNiceGift2ResultInfo, "SCRAExpenseNiceGift2ResultInfo")
	self:RegisterProtocol(SCRAExpenseNiceGift2Info, "OnSCRAExpenseNiceGiftInfo")
	-----------------------------------------------------------
end

--每日活跃奖励
function KaifuActivityCtrl:OnRADayActiveDegreeInfo(protocol)
	self.data:SetDayActiveDegreeInfo(protocol)
	if self.view:IsOpen() then
		self.view:FlushDayActivity()
	end
end

function KaifuActivityCtrl:OnRADayChongzhiRankInfo(protocol)
	self.data:SetDayChongzhiRankInfo(protocol)
	if self.view:IsOpen() then
		self.view:FlushDayChongZhi()
		self.view:FlushDanBiChongZhi()
	end
end


-- 活动信息
function KaifuActivityCtrl:OnKaifuActivityInfo(protocol)
	self.data:SetActivityInfo(protocol)
	self.view:Flush()
	self.view:FlushShouChongTuanGou()
	RemindManager.Instance:Fire(RemindName.KaiFu)
	RemindManager.Instance:Fire(RemindName.BiPin)

	if CompetitionActivityCtrl.Instance.view:IsOpen() then
		CompetitionActivityCtrl.Instance.view:FlushBtnReward()
	end

	-- MainUICtrl.Instance.view:SetAllRedPoint()
end

-- 金猪召唤积分信息返回
function KaifuActivityCtrl:OnGoldenPigCallInfo(protocol)
	self.data:SetGoldenPigCallInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

-- 金猪召唤boss信息返回
function KaifuActivityCtrl:OnGoldenPigCallBossInfo(protocol)
	self.data:SetGoldenPigCallBossInfo(protocol.boss_state)
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

-- 全服进阶信息
function KaifuActivityCtrl:OnActivityUpgradeInfo(protocol)
	self.data:SetActivityUpgradeInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

function KaifuActivityCtrl:OnOpenServerRankInfo(protocol)
	self.data:SetOpenServerRankInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFu)

	CompetitionActivityCtrl.Instance:FlushView()
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
	LeiJiRechargeCtrl.Instance:LeiJiRechargeFlushNext()
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
			-- CollectiveGoalsCtrl.Instance:GetView():Flush()
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

--请求金猪召唤信息
function KaifuActivityCtrl:SendGoldenPigCallInfoReq(operate_type, param)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGoldenPigOperateReq)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param = param or 0

	send_protocol:EncodeAndSend()
end

-- 百倍商城购买数量信息
function KaifuActivityCtrl:OnRAPersonalPanicBuyInfo(protocol)
	self.data:SetPersonalBuyInfo(protocol.buy_numlist)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	ViewManager.Instance:FlushView(ViewName.TipsCommonBuyView)
end

--全名抢购
function KaifuActivityCtrl:OnSCRAServerPanicBuyInfo(protocol)
	self.data:SetFullServerSnapInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	-- self.data:FlushLeiJiChargeRewardRedPoint()
end


-- 集字活动兑换次数
function KaifuActivityCtrl:OnCollectExchangeInfo(protocol)
	self.data:SetCollectExchangeInfo(protocol.exchange_times)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

-- 每日单笔
function KaifuActivityCtrl:OnRADanbiChongzhiInfo(protocol)
	self.data:SetDailyDanBiInfo(protocol)
	if self.view:IsOpen() then
		self.view:FlushDailyDanBi()
		self.view:Flush()
	end
	self.data:FlushDailyDanBiHallRedPoindRemind()
end

function KaifuActivityCtrl:FlushKaifuView()
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KaifuActivityCtrl:FlushZhiZunHuiYuan()
	self.view:FlushZhiZunHuiYuan()
	self.view:Flush()
end

function KaifuActivityCtrl:FlushLevelInvest()
	self.view:FlushLevelInvest()
	self.view:Flush()
end

function KaifuActivityCtrl:FlushHeFuTouZiView()
	self.view:FlushHeFuTouZiView()
end

function KaifuActivityCtrl:FlushTouZiPlan()
	self.view:FlushTouZiPlan()
	self.view:Flush()
end

function KaifuActivityCtrl:FlushView()
	if self.view:IsOpen() then
		self.view:FlushJinJieView()
		self.view:Flush()
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
				-- elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG then 	--金猪召唤活动
				-- 	self:SendGoldenPigCallInfoReq(GOLDEN_PIG_OPERATE_TYPE.GOLDEN_PIG_OPERATE_TYPE_REQ_INFO)
				else
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
				end
			end
			if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.COMBINE_SERVER) then
				HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
				HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)
				-- HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_INFO_REQ)
				-- HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_RANK_REQ)
				-- HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_ROLE_INFO_REQ)
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
				elseif v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG then 	--金猪召唤活动
					self:SendGoldenPigCallInfoReq(GOLDEN_PIG_OPERATE_TYPE.GOLDEN_PIG_OPERATE_TYPE_REQ_INFO)
				else
					self:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
				end
			end
		end
	end

	local is_remind_today = RemindManager.Instance:RemindToday(RemindName.JiZiAct)
	RemindManager.Instance:Fire(RemindName.KaiFu)
	if is_remind_today then
		self:SetCollectionRunTimer()
	end
end

function KaifuActivityCtrl:SetCollectionRunTimer()
	if nil ~= self.collection_start_timing then
		local quest = GlobalTimerQuest:GetRunQuest(self.collection_start_timing)
		if nil ~= quest then
			quest[3] = Status.NowTime + quest[2]
		end
		return
	end

	self.collection_start_timing = GlobalTimerQuest:AddRunQuest(function ()
		RemindManager.Instance:Fire(RemindName.KaiFu)
	end, GameEnum.ZIJI_INTERVAL_TIME)
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

--金猪召唤前往击杀关闭界面
function KaifuActivityCtrl:CloseKaiFuView()
	self.view:Close()
end

function KaifuActivityCtrl:ActivityChange(activity_type, status, next_time, open_type)
	-- 在跨服
	if IS_ON_CROSSSERVER then return end

	if not self.data:IsShowKaifuIcon() and (ACTIVITY_TYPE.OPEN_SERVER == activity_type and status ~= ACTIVITY_STATUS.OPEN) then
		MainUICtrl.Instance:SetNewServerBtnState()
		if self.view:IsOpen() then
			self.view:Close()
		end
		return
	end

    --中秋祈福
    if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2,
			RA_HUANLE_YAOJIANG_2_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_2_TYPE_QUERY_INFO)
    end

	--版本累计充值信息请求
	if activity_type == FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE and status == ACTIVITY_STATUS.OPEN then
		self:SendGetKaifuActivityInfo(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE,
		RA_VERSION_TOTAL_CHARGE_OPERA_TYPE.RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO)
	end

    --版本连续充值
    if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE and status == ACTIVITY_STATUS.OPEN then
	    self:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE,
		RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	end


	--吉祥三宝信息请求
	if activity_type == FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE and status == ACTIVITY_STATUS.OPEN then
		FestivalActivityCtrl.Instance:SendGetSanBaoActivityInfo(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE,
		RA_VERSION_TOTAL_CHARGE_OPERA_TYPE.RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO)
	end

	-- if KaifuActivityData.IsDegreeRewardsType(activity_type) and status ==  ACTIVITY_STATUS.OPEN then
	-- 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_UPGRADE_NEW_OPERA_TYPE.RA_UPGRADE_NEW_OPERA_TYPE_QUERY_INFO) --活动打开时请求信息
	-- 	self:SetDegreeRewardsActivityType(activity_type)
	-- end
end

function KaifuActivityCtrl:OnRAContinueChongzhiInfoChu(protocol)
	self.data:SetChongZhiChu(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.LianChongTeHuiChu)
end

function KaifuActivityCtrl:OnRAContinueChongzhiInfoGao(protocol)
	self.data:SetChongZhiGao(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.LianChongTeHuiGao)
end


-- function KaifuActivityCtrl:OnActivityStatus(protocol)
-- 	print_error(protocol)
-- 	self.data:SetActivityStatus(protocol)
-- 	self.view:Flush()
-- end
function KaifuActivityCtrl:SendRandActivityOperaReq(rand_activity_type, opera_type, param_1, param_2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = rand_activity_type
	protocol.opera_type = opera_type
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end


function KaifuActivityCtrl:OnReciveInvestInfo(protocol)
	self.data:FlushInvestData(protocol)
	local info = ActivityData.Instance:GetActivityStatuByType(2176)
	info.status = ACTIVITY_STATUS.CLOSE
	for k,v in pairs(KAIFU_INVEST_TYPE) do
		local invest_statu = KaifuActivityData.Instance:GetInvestStateByType(v)
		if invest_statu ~= INVEST_STATE.outtime and invest_statu ~= INVEST_STATE.complete then
			info.status = ACTIVITY_STATUS.OPEN
		end
	end
end

--累充回馈
function KaifuActivityCtrl:OnSCChargeRewardInfo(protocol)
	self.data:SetChargeRewardInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	self.data:FlushLeiJiChargeRewardRedPoint()
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

function KaifuActivityCtrl:OnSCRANewTotalChargeInfo(protocol)
	self.data:SetRANewTotalChargeInfo(protocol)
	self.view:FlushTotalCharge()
	self.data:FlushTotalChargeHallRedPoindRemind()
end

function KaifuActivityCtrl:OnSCRADayChongZhiFanLiInfo(protocol)
	self.data:SetRARechargeRebateInfo(protocol)
	self.view:FlushRechargeRebate()
	self.data:FlushChongZhiFanLiRedPoindRemind()
end

function KaifuActivityCtrl:OnSCRATotalConsumeGoldInfo(protocol)
	self.data:SetRATotalConsumeGoldInfo(protocol)
	self.view:FlushTotalConsume()
	self.data:FlushTotalConsumeHallRedPoindRemind()
end

function KaifuActivityCtrl:OnRADayConsumeRankInfo(protocol)
	self.data:SetDayConsumeRankInfo(protocol)
	if self.view:IsOpen() then
		self.view:FlushDayXiaoFei()
	end
end

function KaifuActivityCtrl:FlushView(key)
	if self.view:IsOpen() then
		self.view:Flush(key)
	end
end

function KaifuActivityCtrl:OnRADayConsumeGoldInfo(protocol)
	self.data:DailyTotalConsumeInfo(protocol)
	self.view:FlushDayConsume()
	self.data:FlushDailyTotalConsumeHallRedPoindRemind()
end

----------------------------升星助力------------------------------
-- 升星助力的请求
function KaifuActivityCtrl:SendShengxingzhuliIReq()
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSGetShengxingzhuliInfoReq)
	protocol_send:EncodeAndSend()
end

-- 请求领取升星助力的奖励
function KaifuActivityCtrl:SendShengxingzhuliRewardReq()
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSGetShengxingzhuliRewardReq)
	protocol_send:EncodeAndSend()
end

-- 升星助力的回复
function KaifuActivityCtrl:OnSCGetShengxingzhuliInfoAck(protocol)
	self.data:SetShengxingzhuliInfo(protocol)
	if self.sheng_xing_view:IsOpen() then
		self.sheng_xing_view:Flush()
	end

	ViewManager.Instance:FlushView(ViewName.Main, "rising_star", {protocol.func_type})
	RemindManager.Instance:Fire(RemindName.RisingStar)
end

-- 服务端回复领取升星助力的奖励
function KaifuActivityCtrl:OnSCGetShengxingzhuliRewardAck(protocol)
	-- self.data:SetShengxingzhuliInfo(protocol)
	-- self:Flush("flush_rising_star_view")
	-- self.sheng_xing_view:Flush("flush_rising_star_view")
	-- RemindManager.Instance:Fire(RemindName.KaiFuRiSingBtnRedPoint)
end


function KaifuActivityCtrl:SCRAExpenseNiceGift2ResultInfo(protocol)
	self.data:SetExpenseNiceGiftResultInfo(protocol)

	if self.view then
		self.view:ExpenseViewStartRoll()
	end
end

function KaifuActivityCtrl:SendExpenseNiceGiftInfo(opera_type, param_1, param_2)
	self:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT_2, opera_type, param_1, param_2)
end

function KaifuActivityCtrl:OnSCRAExpenseNiceGiftInfo(protocol)
	self.data:SetExpenseNiceGiftInfo(protocol)

	if self.view then
		self.view:Flush()
	end

	RemindManager.Instance:Fire(RemindName.ExpenseNiceGiftRemind_2)
end