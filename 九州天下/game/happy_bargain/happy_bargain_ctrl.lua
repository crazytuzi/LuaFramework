require("game/happy_bargain/happy_bargain_data")
require("game/happy_bargain/happy_bargain_view")
require("game/happy_bargain/happy_bargain_panel_day_target")
require("game/happy_bargain/happy_bargain_panel_happy_lottery")
require("game/happy_bargain/happy_bargain_chongzhi_rank_view")
require("game/happy_bargain/happy_bargain_panel_single_charge")
require("game/happy_bargain/happy_bargain_panel_rebate")

local IS_OPEN = false

HappyBargainCtrl = HappyBargainCtrl or BaseClass(BaseController)
function HappyBargainCtrl:__init()
	if HappyBargainCtrl.Instance then
		print_error("[HappyBargainCtrl] Attemp to create a singleton twice !")
		return
	end
	HappyBargainCtrl.Instance = self
	self.view = HappyBargainView.New(ViewName.HappyBargainView)
	self.data = HappyBargainData.New()

	self:RegisterAllProtocols()

	self.activity_change = BindTool.Bind(self.ActivityChange, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change)

	self.pass_day = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.MainuiOpenCreate, self))
	self.mainui_open_comlete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))
end

function HappyBargainCtrl:__delete()
	if self.mainui_open_comlete then
		GlobalEventSystem:UnBind(self.mainui_open_comlete)
		self.mainui_open_comlete = nil
	end

	if self.activity_change then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change)
		self.activity_change = nil
	end	

	if self.pass_day then
		GlobalEventSystem:UnBind(self.pass_day)
		self.pass_day = nil
	end

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
end

function HappyBargainCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAHappyDrawRareRankInfo, "OnSCRAHappyDrawRareRankInfo")
	-- self:RegisterProtocol(SCMonthCardInfo, "OnSCMonthCardInfo")
	self:RegisterProtocol(SCRAConsumeAimInfo, "OnSCRAConsumeAimInfo")
	self:RegisterProtocol(SCRAHuntingRewardInfo, "OnSCRAHuntingRewardInfo")
	self:RegisterProtocol(SCCrossRAChongzhiRankGetRankACK, "OnCrossRAChongzhiRankGetRankACK")
	self:RegisterProtocol(SCRASingleChargePrizeInfo,"OnRASingleChargePrizeInfo")
	self:RegisterProtocol(SCCrossRAChongzhiRankChongzhiInfo,"OnCrossRAChongzhiRankChongzhiInfo")
end


function HappyBargainCtrl:OnSCRAConsumeAimInfo(protocol)
	if self.data ~= nil then
		self.data:SetHappyBargainDayTargetProtocols(protocol)
	end
	RemindManager.Instance:Fire(RemindName.DayTarget)
	if self.view then
		self.view:Flush()
	end
end

--跨服活动通用请求
function HappyBargainCtrl:SendCrossRandActivityRequest(activity_type, opera_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossRandActivityRequest)
	send_protocol.activity_type = activity_type or 0
	send_protocol.opera_type = opera_type or 0
	send_protocol.param_1= param_1 or 0
	send_protocol.param_2= param_2 or 0
	send_protocol.param_3= param_3 or 0
	send_protocol:EncodeAndSend()
end

--跨服排行请求
function HappyBargainCtrl:SendGetPersonRankListReq(cross_activity_type,param_1)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossRARankGetRank)
	send_protocol.cross_activity_type = cross_activity_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol:EncodeAndSend()
end

--跨服充值排行返回
function HappyBargainCtrl:OnCrossRAChongzhiRankGetRankACK(protocol)
	self.data:SetPersonRankListProtocols(protocol)
	if self.view then
		self.view:Flush("chongzhi")
	end
end

--个人充值信息返回
function HappyBargainCtrl:OnCrossRAChongzhiRankChongzhiInfo(protocol)
	self.data:SetCrossRAChongzhiRankChongzhiInfo(protocol)
	if self.view then
		self.view:Flush("chongzhi")
	end
end

function HappyBargainCtrl:Flush()
	if self.view then
		self.view:Flush()
	end
end

--单笔大奖信息返回
function HappyBargainCtrl:OnRASingleChargePrizeInfo(protocol)
	self.data:SetSingleChargeInfo(protocol)
	RemindManager.Instance:Fire(RemindName.SingleCharge)
    if self.view then
		self.view:Flush()
	end
end

-- 返利活动
function HappyBargainCtrl:OnSCRAHuntingRewardInfo(protocol)
	self.data:SetHappyBargainRebateProtocols(protocol)
	RemindManager.Instance:Fire(RemindName.RebateAct)
	if self.view then
		self.view:Flush()
	end
end

function HappyBargainCtrl:ActivityChange(activity_type, status, next_time, open_type)
	MainUICtrl.Instance:ChangeHappyBtn(self:IsOpenActivity())
end

function HappyBargainCtrl:IsOpenActivity()
	local happy_activity_sort_index_list = self.data:GetHappyActivityList()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local can_show = level >= 70
	local limit_day = day >= 8 and day <= 14
	for i,v in ipairs(happy_activity_sort_index_list) do
		if ActivityData.Instance:GetActivityIsOpen(v) and can_show and (limit_day or v == ACTIVITY_TYPE.CROSS_RAND_ACTIVITY_TYPE_CHONGZHI_RANK) then
			return true
		end
	end
	return false
end

function HappyBargainCtrl:MainuiOpenCreate()
	MainUICtrl.Instance:ChangeHappyBtn(self:IsOpenActivity())
end

--------------------------------------欢乐抽--------------------------------------------
-- 接收全服珍稀榜信息
function HappyBargainCtrl:OnSCRAHappyDrawRareRankInfo(protocol)
	self.data:SetDrawRareRankInfo(protocol)
	RemindManager.Instance:Fire(RemindName.HappyLottery)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function HappyBargainCtrl:FlushView()	
	self.view:Flush()
end

function HappyBargainCtrl:CloseView()	
	self.view:Close()
end
----------------------------------------------------------------------------------------------

