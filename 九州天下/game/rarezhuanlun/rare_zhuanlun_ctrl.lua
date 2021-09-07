require("game/rarezhuanlun/rare_zhuanlun_view")
require("game/rarezhuanlun/rare_zhuanlun_data")
RareDialCtrl = RareDialCtrl or BaseClass(BaseController)

function RareDialCtrl:__init()
	if RareDialCtrl.Instance ~= nil then
		print_error("[RareDialCtrl] attempt to create singleton twice!")
		return
	end
	RareDialCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = RareDialView.New(ViewName.RareDial)
	self.data = RareDialData.New()

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	-- self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	-- RemindManager.Instance:Bind(self.remind_change, RemindName.RareDial)

end

function RareDialCtrl:__delete()

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	-- if self.remind_change then
	-- 	RemindManager.Instance:UnBind(self.remind_change)
	-- 	self.remind_change = nil
	-- end

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end



	RareDialCtrl.Instance = nil
end

function RareDialCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAExtremeLuckyAllInfo, "SCRAExtremeLuckyAllInfo")
	self:RegisterProtocol(SCRAExtremeLuckySingleInfo, "SCRAExtremeLuckySingleInfo")
end

function RareDialCtrl:SCRAExtremeLuckyAllInfo(protocol)
	self.data:SetRAExtremeLuckyAllInfo(protocol)
	RemindManager.Instance:Fire(RemindName.RareDial)
	self.view:Flush()
end

function RareDialCtrl:SCRAExtremeLuckySingleInfo(protocol)
	self.data:SetRewardInfo(protocol)
	if self.fetch_award then
		self.view:FlushRightCell()
		self.fetch_award = false
	else
		self.view:FlushAnimation()
	end
	RemindManager.Instance:Fire(RemindName.RareDial)
end

function RareDialCtrl:SendInfo(opera_type,param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR or 0
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end

function RareDialCtrl:FlushItem()
	if self.view.is_open then
		self.view:FlushItem()
	end
end

function RareDialCtrl:FetchAward()
	self.fetch_award = true
end

-- function RareDialCtrl:RemindChangeCallBack(remind_name, num)
-- 	if remind_name == RemindName.RareDial then
-- 		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR, num > 0)
-- 	end
-- end

function RareDialCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR and status == ACTIVITY_STATUS.OPEN then
		self:SendInfo(RA_EXTREME_LUCKY_OPERA_TYPE.RA_EXTREME_LUCKY_OPERA_TYPE_QUERY_INFO)
	end 
end
