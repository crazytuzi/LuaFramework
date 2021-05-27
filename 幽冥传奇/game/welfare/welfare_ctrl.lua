require("scripts/game/welfare/welfare_data")
require("scripts/game/welfare/welfare_view")
require("scripts/game/welfare/ck_buy_financing_view")
require("scripts/game/welfare/login_reward_data")
require("scripts/game/welfare/add_sign_reward_tips_view")
require("scripts/game/welfare/login_reward_view")
require("scripts/game/welfare/welfare_findres_tip")

-- 福利
WelfareCtrl = WelfareCtrl or BaseClass(BaseController)

WelfareViews = {
	CkBuyFinancing = "ck_buy_financing",
}

function WelfareCtrl:__init()
	if WelfareCtrl.Instance then
		ErrorLog("[WelfareCtrl]:Attempt to create singleton twice!")
	end
	WelfareCtrl.Instance = self
	
	self.login_data = LoginRewardData.New()

	self.data = WelfareData.New()
	self.view = WelfareView.New(ViewDef.Welfare)
	self.ck_buy_financing_view = CkBuyFinancingView.New(WelfareViews.CkBuyFinancing)
	self.add_sign_reward_tips = AddSignRewardTipsView.New()
	self.login_reward_view = WelfareLoginRewardView.New(ViewDef.LoginReward)
	self.findre_tip = FindresTips.New(ViewDef.FindreTip)


	self:RegisterAllProtocals()

	self.role_data_event = BindTool.Bind(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)
	self:BindGlobalEvent(OtherEventType.TODAY_CHARGE_GOLD_CHANGE, BindTool.Bind(self.OnTodayChargeChange, self))
	self:BindGlobalEvent(OtherEventType.OPEN_DAY_CHANGE, BindTool.Bind(self.RecvMainInfoCallBack, self))
	self:BindGlobalEvent(OtherEventType.PASS_DAY, BindTool.Bind(self.PassDayCallBack, self))

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.SignInReward)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.LoginReward)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.FindresView)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OnlineReward, true, 1)
	--RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OfflineExp)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.FinancingRec)
end

function WelfareCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.login_data:DeleteMe()
	self.login_data = nil

	self.view:DeleteMe()
	self.view = nil

	self.login_reward_view:DeleteMe()
	self.login_reward_view = nil

	self.findre_tip:DeleteMe()
	self.findre_tip = nil

	WelfareCtrl.Instance = nil
	if RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
	end
end

function WelfareCtrl:FlushViewRemind()
	self.view:Flush(0, "remind")
end

function WelfareCtrl:OnTodayChargeChange(gold_num)
	self.data:UpdateSignInData()
end

function WelfareCtrl:RoleDataChangeCallback(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_ACTOR_SIGNIN then
		self.data:UpdateSignInData()
		self.view:Flush(TabIndex.welfare_daily_sign_in)
	elseif key == OBJ_ATTR.CREATURE_LEVEL then
		self.data:SetFinancingInfo()
		-- self.view:Flush(TabIndex.welfare_financing)
		OpenServiceAcitivityCtrl.Instance:FlushViewIndex(TabIndex.openserviceacitivity_financing)
		self.view:Flush(TabIndex.welfare_offline_exp)
	elseif key == OBJ_ATTR.ACTOR_CIRCLE then
		self.data:SetFinancingInfo()
		-- self.view:Flush(TabIndex.welfare_financing)
		OpenServiceAcitivityCtrl.Instance:FlushViewIndex(TabIndex.openserviceacitivity_financing)
	end
end

function WelfareCtrl:GetRemindNum(remind_name)
	if not ViewManager.Instance:CanShowUi(ViewName.Welfare) then
		return 0
	end

	if remind_name == RemindName.OnlineReward then
		self.data:FlushOnlineTime()
	elseif remind_name == RemindName.FindresView then
		self.data:FindresShow()
	end

	return self.data:GetRemindNum(remind_name)
end

function WelfareCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCAddSignAwardMark, "OnAddSignAwardMark")
	self:RegisterProtocol(SCAgainSignOneTimemark, "OnAgainSignOneTimemark")
	self:RegisterProtocol(SCOfflineExpInfo, "OnOfflineExpInfo")
	self:RegisterProtocol(SCGetOfflineExpResult, "OnGetOfflineExpResult")
	self:RegisterProtocol(SCOnlineRewardResult, "OnOnlineRewardResult")
	self:RegisterProtocol(SCGetOnlineReward, "OnGetOnlineReward")
	self:RegisterProtocol(SCOnlineRewardInfo, "OnOnlineRewardInfo")
	self:RegisterProtocol(SCFinancing, "OnFinancing")
	self:RegisterProtocol(SCConsumeRankInfo, "OnConsumeRankInfo")
	self:RegisterProtocol(SCRechargeRankInfo, "OnRechargeRankInfo")
	self:RegisterProtocol(SCRetrieveInfo, "OnRetrieveInfo")

	self:RegisterProtocol(SCSevenDaysLoadingGetInformation, "OnSevenDaysLoadingGetInformation")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.GetSevenDaysLoginRewardInfo))
end

function WelfareCtrl:RecvMainInfoCallBack()

	-- 超值理财标记
	cfg = FinancingCfg
	begin_day = 1
	end_day = cfg.openDay

	local boor = #WelfareData.Instance:GetFinancingItemData() > 0
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) and boor then
		WelfareCtrl.FinancingReq(FINANCING_TYPE_DEF.INFO)
	end

	-- 消费排行标记
	local boor = WelfareData.Instance:GetConsumeRankOpen() ~= nil
	if boor then
		WelfareCtrl.Instance.ConsumeRankReq(2)
	end

	-- 充值排行标记
	local boor = WelfareData.Instance:GetRechargeRankOpen() ~= nil
	if boor then
		WelfareCtrl.Instance.RechargeRankReq(2)
	end
end

function WelfareCtrl:PassDayCallBack()
	WelfareData.Instance:UpdateSignInData()
	WelfareCtrl.OnlineRewardInfoReq()
end

--7天登陆奖励信息
function WelfareCtrl:OnSevenDaysLoadingGetInformation(protocol)
	self.login_data:SetLoginRewardFlag(protocol.kind_number_rewards)
	self.login_data:SetAddLoginTimes(protocol.add_up_days)
	RemindManager.Instance:DoRemind(RemindName.LoginReward)
	self.view:Flush(TabIndex.welfare_login_reward, "flush_receive")
end

--获取7天登陆奖励信息请求
function WelfareCtrl.GetSevenDaysLoginRewardInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetSevenDaysLoginRewardInfo)
	protocol:EncodeAndSend()
end

--领取7天登陆奖励
function WelfareCtrl.GetSevenDaysLoadingRewardsReq(days_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetSevenDaysLoadingRewardsReq)
	protocol.days_id = days_id or 0
	protocol:EncodeAndSend()
end


---------------------------------------
-- 下发 begin
---------------------------------------

--累计签到领奖标记
function WelfareCtrl:OnAddSignAwardMark(protocol)
	self.data:SetAddSignRewardMark(protocol)
	self.data:UpdateSignInData()
	self.view:Flush(TabIndex.welfare_daily_sign_in, "sign_in_flush")
end

--再签一次到标记
function WelfareCtrl:OnAgainSignOneTimemark(protocol)
	self.data:SetAgainSignOneTimemark(protocol)
	self.data:UpdateSignInData()
	self.view:Flush(TabIndex.welfare_daily_sign_in)
end

--离线经验信息
function WelfareCtrl:OnOfflineExpInfo(protocol)
	self.data:SetOfflineExpInfo(protocol)
	self.view:Flush(TabIndex.welfare_offline_exp)
end

--领取离线经验结果
function WelfareCtrl:OnGetOfflineExpResult(protocol) 
	if protocol.result == 1 then
		self.data:SetOfflineExpInfo()
		self.view:Flush(TabIndex.welfare_offline_exp)
	end
end

--理财处理
function WelfareCtrl:OnFinancing(protocol)
	self.data:SetFinancingInfo(protocol)
	-- self.view:Flush(TabIndex.welfare_financing)
	-- RemindManager.Instance:DoRemind(RemindName.FinancingRec)
end

--抽奖返回结果
function WelfareCtrl:OnOnlineRewardResult(protocol)
	self.data:GetRewardResult(protocol)
end

--下发奖品结果
function WelfareCtrl:OnGetOnlineReward(protocol)
	self.OnlineRewardInfoReq()
end

--领取在线奖励信息
function WelfareCtrl:OnOnlineRewardInfo(protocol)
	self.data:SetOnlineRewardInfo(protocol)
end

-- 开服活动消费排行处理(139, 58)
function WelfareCtrl:OnConsumeRankInfo(protocol)
	self.data:SetConsumeRankInfo(protocol)
end

function WelfareCtrl:OnRechargeRankInfo(protocol)
	self.data:SetRechargeRankInfo(protocol)
end

-- 下发资源找回
function WelfareCtrl:OnRetrieveInfo(protocol)
	self.data:SetFindResData(protocol)
end

---------------------------------------
-- 下发 end
---------------------------------------

---------------------------------------
-- 请求 begin
---------------------------------------

--每日签到
function WelfareCtrl.EveryDaySignReq(day)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEveryDaySignReq)
	protocol.sign_which_day = day
	protocol:EncodeAndSend()
end

--领取累积天数奖励
function WelfareCtrl.GetAddDaysReward(reward_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetAddDaysRewardsReq)
	protocol.reward_index = reward_index
	protocol:EncodeAndSend()
end

--领取离线经验
function WelfareCtrl.GetOfflineExp(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetOfflineExp)
	protocol.index = index
	protocol:EncodeAndSend()
end

--请求领取在线奖励信息
function WelfareCtrl.OnlineRewardInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOnlineRewardInfo)
	protocol:EncodeAndSend()
end

--开始抽奖
function WelfareCtrl.StartOnlineReward(index)
	-- print(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStartOnlineReward)
	protocol.index = index
	protocol:EncodeAndSend()
end

--请求下发奖品
function WelfareCtrl.GetOnlineReward(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetOnlineReward)
	protocol.index = index
	protocol:EncodeAndSend()
end

--理财
function WelfareCtrl.FinancingReq(req_type, receive_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFinancingReq)
	protocol.req_type = req_type
	protocol.receive_index = receive_index or 0
	protocol:EncodeAndSend()
end

--领取序列号卡奖励
function WelfareCtrl.OnGetSerialNumberRewardsReq(cd_key)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetSerialNumberRewardsReq)
	protocol.cd_key = cd_key
	protocol:EncodeAndSend()
end

-- 请求资源找回
function WelfareCtrl:FindResGetReq(value, task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSResourceRecoveryReq)
	protocol.value_type = value
	if value == 1 or value == 2 then
		protocol.task_id = task_id
	end
	protocol:EncodeAndSend()
end

-- 请求开服活动消费排行处理(返回139, 58)
function WelfareCtrl.ConsumeRankReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSConsumeRankReq)
	protocol.index = index -- 事件, 1领取, 2数据
	protocol:EncodeAndSend()
end

-- 请求开服活动充值排行处理(返回139, 64)
function WelfareCtrl.RechargeRankReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRechargeRankReq)
	protocol.index = index -- 事件, 1领取, 2数据
	protocol:EncodeAndSend()
end
---------------------------------------
-- 请求 end
---------------------------------------

function WelfareCtrl:SetDataWefare(data)
	self.add_sign_reward_tips:SetViewData(data)
end

-- 打开资源找回次数   param_t = {找回方式， 物品list，剩余次数，消耗元宝}
function WelfareCtrl:OpenFindreTipItem(param_t)
	
	ViewManager.Instance:OpenViewByDef(ViewDef.FindreTip)
	ViewManager.Instance:FlushViewByDef(ViewDef.FindreTip, 0, "param", param_t)
end