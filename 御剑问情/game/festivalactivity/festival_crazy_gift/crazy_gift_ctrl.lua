require("game/festivalactivity/festival_crazy_gift/crazy_gift_data")

CrazyGiftCtrl = CrazyGiftCtrl or BaseClass(BaseController)

function CrazyGiftCtrl:__init()
	if nil ~= CrazyGiftCtrl.Instance then
		return
	end
    CrazyGiftCtrl.Instance = self
    self.data = CrazyGiftData.New()
    self:RegisterAllProtocols()
    self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
    ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChangeCallBack,self))
end

function CrazyGiftCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
	end

	if self.main_view_complete then
    	GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end

	CrazyGiftCtrl.Instance = nil
end
function CrazyGiftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRACrazyGiftInfo, "OnSCRACrazyGiftInfo")
end

function CrazyGiftCtrl:OnSCRACrazyGiftInfo(protocol)
	local is_all_sell = self.data:IsAllSell()
    self.data:SetGiftInfo(protocol)
    if is_all_sell ~= self.data:IsAllSell() then
    	FestivalActivityData.Instance:SetActivityStatusForce(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CRAZY_GIFT, self.data:IsAllSell())
   		FestivalActivityCtrl.Instance:FlushView("toggle")
   	end
   	FestivalActivityCtrl.Instance:FlushView("crazygiftview")
end

function CrazyGiftCtrl:SendBuyGiftInfo(rand_activity_type,opera_type,param1,param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = rand_activity_type
    protocol.opera_type = opera_type
    protocol.param_1 = param1          --礼包类型
    protocol.param_2 = param2          --礼包seq
    protocol:EncodeAndSend()
end

function CrazyGiftCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CRAZY_GIFT)
	if is_open then
		-- 请求活动信息
	 	CrazyGiftCtrl.Instance:SendBuyGiftInfo(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CRAZY_GIFT, GameEnum.RA_CRAZY_GIFT_REQ_TYPE_INFO, 0, 0)
	end
end

function CrazyGiftCtrl:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	if FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CRAZY_GIFT == activity_type then
		if status == ACTIVITY_STATUS.OPEN then
			CrazyGiftCtrl.Instance:SendBuyGiftInfo(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CRAZY_GIFT, GameEnum.RA_CRAZY_GIFT_REQ_TYPE_INFO, 0, 0)
		end
	end
end