require("game/kaifu_charge/kaifu_charge_data")
require("game/kaifu_charge/kaifu_charge_view")
require("game/kaifu_charge/kaifu_bipin_rank_view")
KaiFuChargeCtrl = KaiFuChargeCtrl or BaseClass(BaseController)
function KaiFuChargeCtrl:__init()
	if KaiFuChargeCtrl.Instance then
		print_error("[KaiFuChargeCtrl] Attemp to create a singleton twice !")
		return
	end
	KaiFuChargeCtrl.Instance = self
	self.view = KaiFuChargeView.New(ViewName.KaiFuChargeView)
	self.data = KaiFuChargeData.New()
	self.bipin_rank = BiPinRankView.New()
	self.kaifu_chongzhi_view = KaiFuChongZhiView.New(ViewName.QiTianChongZhiView)
	self.bipin_view = KaiFuBiPinView.New(ViewName.KaiFuBiPinView)
	self:RegisterAllProtocols()
	self.is_first = true
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
	RemindManager.Instance:Register(RemindName.KaiFuBiPinBtn, BindTool.Bind(self.GetKaiFuBiPinRedPoint, self))
	RemindManager.Instance:Register(RemindName.PinkEquip, BindTool.Bind(self.GetPinkEquipRedPoint, self))
	RemindManager.Instance:Register(RemindName.KaiFuChargeFirst, BindTool.Bind(self.CheckKaiFuChargeFirst, self))
	RemindManager.Instance:Register(RemindName.FenQiZhiZhui, BindTool.Bind(self.FenQiZhiZhuiRedPoint, self))

	self.role_change_callback = BindTool.Bind(self.RoleChangeCallBack, self)
	PlayerData.Instance:ListenerAttrChange(self.role_change_callback)
end

function KaiFuChargeCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.bipin_rank ~= nil then
		self.bipin_rank:DeleteMe()
		self.bipin_rank = nil
	end

	if self.kaifu_chongzhi_view ~= nil then
		self.kaifu_chongzhi_view:DeleteMe()
		self.kaifu_chongzhi_view = nil
	end

	if self.bipin_view ~= nil then
		self.bipin_view:DeleteMe()
		self.bipin_view = nil
	end

	if self.role_change_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.role_change_callback)
		self.role_change_callback = nil
	end

	KaiFuChargeCtrl.Instance = nil
	
	if self.main_view_complete then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	RemindManager.Instance:UnRegister(RemindName.KaiFuBiPinBtn)
	RemindManager.Instance:UnRegister(RemindName.PinkEquip)
	RemindManager.Instance:UnRegister(RemindName.KaiFuChargeFirst)
	RemindManager.Instance:UnRegister(RemindName.FenQiZhiZhui)
end

function KaiFuChargeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCMonthCardInfo, "OnSCMonthCardInfo")
	self:RegisterProtocol(SCChongzhidahuikuiInfo, "OnSCChongZhiDaHuiKuiInfo")

	self:RegisterProtocol(SCXufuciliInfoAck, "OnSCXufuInfo")
	self:RegisterProtocol(SCXufuciliBuyAck, "OnSCXufuBuyResult")
	self:RegisterProtocol(SCXufuciliAllActiveStampInfoAck, "OnSCXufuActivityOpenInfo")

	self:RegisterProtocol(CSGetShengxingzhuliInfoReq)
	self:RegisterProtocol(SCGetShengxingzhuliInfoAck, "OnGetShengxingzhuliInfoAck")
	self:RegisterProtocol(CSGetShengxingzhuliRewardReq)

	self:RegisterProtocol(SCOpenGameActivityInfo, "OnSCOpenGameActivityInfo")

	-- 每日充值排行
	self:RegisterProtocol(SCRADayChongzhiRankInfo, "OnRADayChongzhiRankInfo")

	-- 每日消费排行
	self:RegisterProtocol(SCRADayConsumeRankInfo, "OnRADayConsumeRankInfo")

	--累计消费
	self:RegisterProtocol(SCRATotalConsumeGoldInfo, "OnSCRATotalConsumeGoldInfo")

	--累计充值
	self:RegisterProtocol(SCRATotalChargeInfo, "OnTotalChongZhiInfo")

	--累计充值new
	self:RegisterProtocol(SCRADailyTotalChongzhiInfo, "OnNewTotalChongZhiInfo")

	-- 百倍商城(个人抢购)
	-- self:RegisterProtocol(SCRAPersonalPanicBuyInfo, "OnRAPersonalPanicBuyInfo")

	self:RegisterProtocol(SCSuperDailyTotalChongzhiInfo, "OnSCSuperDailyTotalChongzhiInfo")

	-- 奋起直追
	self:RegisterProtocol(SCFenqizhizhuiAllInfo, "OnSCFenqizhizhuiAllInfo")
	-- 每日限购礼包
	self:RegisterProtocol(SCRADailyXiangoulibaoInfo,"OnSCRADailyXiangoulibaoInfo")

	self:RegisterProtocol(SCRADailyLoveRewardInfo,"OnSCRADailyLoveRewardInfo")

	self:RegisterProtocol(SCRASingleChargePrizeFeedbackInfo, "OnSCRASingleChargePrizeFeedbackInfo")
end

function KaiFuChargeCtrl:OnSCRADailyLoveRewardInfo(protocol)
	local state = protocol.ra_daily_love_daily_first_flag == 1
	self.data:SetOpenDailyCharge(state)
	MainUICtrl.Instance:SetBtnDailyCharge(state)
	self:Flush("daily_charge_content")
end

function KaiFuChargeCtrl:OnSCMonthCardInfo(protocol)
	self.data:SetMonthCardInfo(protocol)
	self:Flush("flush_yueka_view")
	RemindManager.Instance:Fire(RemindName.KaiFuYueKa)
	RemindManager.Instance:Fire(RemindName.KaiFuYueKaGold)
end

function KaiFuChargeCtrl:OnSCChongZhiDaHuiKuiInfo(protocol)
	self.data:SetChongZhiDaHuiKui(protocol)
	-- self.view:FlashContent()
	self:Flush("flush_chongzhi_view")
	LeiJiRDailyCtrl.Instance:FlusView()
	MainUICtrl.Instance:FlushChargeIcon()
	RemindManager.Instance:Fire(RemindName.KaiFuChongZhiItem)
	RemindManager.Instance:Fire(RemindName.DailyLeiJi)
end

-- 刷新View方法
function KaiFuChargeCtrl:Flush(key, value_t)
	if self.view then
		self.view:Flush(key, value_t)
	end
end

-- 刷新等级投资界面
function KaiFuChargeCtrl:FlushLevelTouZi()
	self:Flush("flush_touzi_view")
	RemindManager.Instance:Fire(RemindName.KaiFuLevelTouzi)
end

-- 刷新登陆投资界面
function KaiFuChargeCtrl:FlushLoginTouZi()
	self:Flush("flush_touzi_login_view")
	RemindManager.Instance:Fire(RemindName.KaiFuLoginTouzi)
end

-- 刷新比拼
function KaiFuChargeCtrl:FlushBiPin()
	self:Flush("flush_bipin_view")
	self.bipin_view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFuBiPinBtn)
end

-- 开服比拼红点
function KaiFuChargeCtrl:GetKaiFuBiPinRedPoint()
	local flag_seq = KaiFuChargeData.Instance:BiPinActCurRewardFlagSeq()
	local binpin_type_cfg = KaiFuChargeData.Instance:GetCurBiPinActJieShuCfg(flag_seq)
	local cur_grade = self.view:GetBiPinGrade()
	if not binpin_type_cfg then return 0 end
	if cur_grade >= binpin_type_cfg.cond2 then
		return 1
	end
	return 0
end

-- 比拼排行请求
function KaiFuChargeCtrl:ActSendGetRankListReq()
	self.bipin_rank:ActSendGetRankListReq()
end

function KaiFuChargeCtrl:CurValueGrade()
	if self.view:IsOpen() then
		self.view:CurValueGrade()
	end
end

function KaiFuChargeCtrl:OnSCOpenGameActivityInfo(protocol)
	self.data:SetOpenGameActivityInfo(protocol)
	self.kaifu_chongzhi_view.flush_list = true
	self.kaifu_chongzhi_view:Flush()
	RemindManager.Instance:Fire(RemindName.KaiFuChongZhiItem)
	MainUICtrl.Instance:FlushView()
end

-- 开服活动请求
function KaiFuChargeCtrl:SendOpenGameActivityInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenGameActivityInfoReq)
	protocol:EncodeAndSend()
end

--投资计划请求
function KaiFuChargeCtrl:SendTouZiActive(plan_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTouzijihuaActive)
	protocol.plan_type = plan_type
	protocol:EncodeAndSend()
end

--投资奖励领取请求
function KaiFuChargeCtrl:SendTouZiReward(plan_type, seq)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFetchTouZiJiHuaReward)          
	protocol.plan_type = plan_type 					-- 0等级投资  1登陆投资
	protocol.seq = seq 					
	protocol:EncodeAndSend()
end

--月卡奖励领取请求
function KaiFuChargeCtrl:SendMonthReward(fetch_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMonthCardFetchDayReward)
	protocol.fetch_type = fetch_type
	protocol:EncodeAndSend()
end

function KaiFuChargeCtrl:OpenBiPinRank()
	self.bipin_rank:Open()
end

function KaiFuChargeCtrl:FlushBiPinRank()
	self.bipin_rank:Flush()
end


------------------------- 折扣 ------------------------------------
--徐福赐礼信息
function KaiFuChargeCtrl:SendXufuInfoReq(function_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSXufuciliInfoReq)
	protocol.function_type = function_type					--功能类型
	protocol:EncodeAndSend()
end

function KaiFuChargeCtrl:OnSCXufuInfo(protocol)
	self.data:SetXufuInfo(protocol)
	self:Flush("flush_discount_view", {"flush_type_cell"})
end

--购买信息
function KaiFuChargeCtrl:SendXufuBuyReq(cost_seq, gift_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSXufuciliBuyReq)
	protocol.cost_seq = cost_seq							--花费类型
	protocol.gift_type = gift_type							--礼包类型
	protocol:EncodeAndSend()
end

function KaiFuChargeCtrl:OnSCXufuBuyResult(protocol)
	self.data:SetXufuBuyResult(protocol)
end

--功能开启信息
function KaiFuChargeCtrl:SendXufuActivityOpenReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSXufuciliAllActiveStampInfoReq)
	protocol:EncodeAndSend()
end

function KaiFuChargeCtrl:OnSCXufuActivityOpenInfo(protocol)
	self.data:SetXufuActivityOpenInfo(protocol)
	self:Flush("flush_discount_view_show")
	self:Flush("flush_discount_view", {"flush_all_type"})
	RemindManager.Instance:Fire(RemindName.XuFuCiLi)
end

------------------------- END ------------------------------------------

------------------------- 升星助力begin --------------------------------
-- 升星助力的请求
function KaiFuChargeCtrl:SendShengxingzhuliIReq()
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSGetShengxingzhuliInfoReq)
	protocol_send:EncodeAndSend()
end

-- 升星助力的回复
function KaiFuChargeCtrl:OnGetShengxingzhuliInfoAck(protocol)
	self.data:SetShengxingzhuliInfo(protocol)
	self:Flush("flush_rising_star_view")
	RemindManager.Instance:Fire(RemindName.KaiFuRiSingBtnRedPoint)
end

-- 请求领取升星助力的奖励
function KaiFuChargeCtrl:SendShengxingzhuliRewardReq()
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSGetShengxingzhuliRewardReq)
	protocol_send:EncodeAndSend()
end

------------------------- 升星助力end ----------------------------------

function KaiFuChargeCtrl:GetView()
	return self.view
end


--请求开服活动领取信息
function KaiFuChargeCtrl:SendOpenGameActivityFetchReward(reward_type, seq)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSOpenGameActivityFetchReward)
	protocol_send.reward_type = reward_type 			 
	protocol_send.seq = seq 		
	protocol_send:EncodeAndSend()
end

function KaiFuChargeCtrl:MianUIOpenComlete()
 	KaiFuChargeCtrl.Instance:SendOpenGameActivityInfoReq()
	RemindManager.Instance:Fire(RemindName.KaiFuChargeFirst)
	RemindManager.Instance:Fire(RemindName.KaiFuChongZhiItem)
end

-----------每日充值排行
function KaiFuChargeCtrl:OnRADayChongzhiRankInfo(protocol)
	self.data:SetDayChongzhiRankInfo(protocol)
	if self.view:IsOpen() then
		self:Flush("flush_chongzhi_rank_view")
		-- self.view:FlushDanBiChongZhi()
	end
end

-----------每日消费排行
function KaiFuChargeCtrl:OnRADayConsumeRankInfo(protocol)
	self.data:SetDayConsumeRankInfo(protocol)
	if self.view:IsOpen() then
		self:Flush("flush_xiaofei_rank_view")
	end
end

-----------累计充值
function KaiFuChargeCtrl:OnTotalChongZhiInfo(protocol)
	self.data:SetLeiJiChongZhiInfo(protocol)
	RemindManager.Instance:Fire(RemindName.KaiFu)
	RemindManager.Instance:Fire(RemindName.KfLeichong)
	RemindManager.Instance:Fire(RemindName.KaiFuLeiJiChongZhi)
	if self.view:IsOpen() then
		self:Flush("flush_acttotal_chongzhi")
	end
end

-----------累计充值new
function KaiFuChargeCtrl:OnNewTotalChongZhiInfo(protocol)
	self.data:SetNewTotalChongZhiInfo(protocol)
	RemindManager.Instance:Fire(RemindName.KaiFuNewTotalReward)
	if self.view:IsOpen() then
		self:Flush("flush_New_total_chongzhi")
	end
end

function KaiFuChargeCtrl:OnSCRATotalConsumeGoldInfo(protocol)
	self.data:SetRATotalConsumeGoldInfo(protocol)
	KaifuActivityCtrl.Instance:OnSCRATotalConsumeGoldInfo(protocol)
	if self.view:IsOpen() then
		self:Flush("flush_acttotal_consume")

	end
	-- self.data:FlushTotalConsumeHallRedPoindRemind()
end

function KaiFuChargeCtrl:OnSCRASingleChargePrizeFeedbackInfo(protocol)
	self.data:SetSuperChargeFeedback(protocol)
	if self.view:IsOpen() then
		self:Flush("super_charge_feedback")
	end
	RemindManager.Instance:Fire(RemindName.SuperChargeFeedback)
end

----------开服七日累充
function KaiFuChargeCtrl:OpenChongZhiView()
	self.kaifu_chongzhi_view:Open()
end

-------------始皇武库
function KaiFuChargeCtrl:OnSCSuperDailyTotalChongzhiInfo(protocol)
	self.data:SetSCSuperDailyTotalChongzhiInfo(protocol)
	self.view:Flush("pink_equip")
	RemindManager.Instance:Fire(RemindName.PinkEquip)
end

--------始皇武库红点
function KaiFuChargeCtrl:GetPinkEquipRedPoint()
	local remind_num = self.data:IsCanGetReward() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPER_DAILY_TOTAL_CHONGZHI, remind_num > 0)
	return remind_num
end

function KaiFuChargeCtrl:CheckKaiFuChargeFirst()
	if self.is_first then
		self.is_first = false
		return 1
	end
	return 0
end

-- 奋起直追
function KaiFuChargeCtrl:OnSCFenqizhizhuiAllInfo(protocol)
	self.data:SetSCFenqizhizhuiAllInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.FenQiZhiZhui)
end

function KaiFuChargeCtrl:SendFenqizhizhuiOperaReq(opera_type, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFenqizhizhuiOperaReq)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol:EncodeAndSend()
end

function KaiFuChargeCtrl:FenQiZhiZhuiRedPoint()
	local num = 0
	local info = self.data:GetFenQiInfo()
	if info == nil or next(info) == nil then
		return num
	end

	if info.is_fetch == 0 then
		local today_config = self.data:GetFenQiCfg()
		if today_config == nil or next(today_config) == nil then
			return num
		end

		if info.today_chongzhi_num >= today_config.need_chongzhi and info.func_is_max_grade == 0 then
			num = 1
		end
	end
	return num
end

------------随机活动
function KaiFuChargeCtrl:SendGiftReq(activity_type, opera_type,param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = activity_type
	protocol.opera_type = opera_type
	protocol.param_1 = param_1 or 0
	protocol:EncodeAndSend()
end

function KaiFuChargeCtrl:SendBuyType(buy_type, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRecordRmbBuy)
	protocol.buy_type = buy_type or 0
	protocol.param = index or 0
	protocol:EncodeAndSend()
end

function KaiFuChargeCtrl:OnSCRADailyXiangoulibaoInfo(protocol)
	self.data:SetMeiRiLiBaoInfo(protocol)
	RemindManager.Instance:Fire(RemindName.MeiRiZhanBei)
	if self.view:IsOpen() then
		self:Flush("meiri_zhanbei")
	end
end

function KaiFuChargeCtrl:RoleChangeCallBack(key, value, old_value)
	if key == "level" then
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		local has_open_view = self.data:GetHasOpenView()
		if has_open_view then
			if main_vo.level == 89 then
				ViewManager.Instance:Open(ViewName.KaiFuChargeView, TabIndex.kaifu_meiri_zhanbei)
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MEIRI_ZHANBEI_GIFT)
			end
		end
	end
end