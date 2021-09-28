require("game/time_limit_sale/time_limit_sale_data")
require("game/time_limit_sale/time_limit_sale_view")

TimeLimitSaleCtrl = TimeLimitSaleCtrl or BaseClass(BaseController)

function TimeLimitSaleCtrl:__init()
	if TimeLimitSaleCtrl.Instance then
		print_error("[TimeLimitSaleCtrl]:Attempt to create singleton twice!")
	end
	TimeLimitSaleCtrl.Instance = self

	self.view = TimeLimitSaleView.New(ViewName.TimeLimitSaleView)
	self.data = TimeLimitSaleData.New()

	self:RegisterAllProtocols()

	self.main_open_bind = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainUiOpen, self))

	self.old_server_time = 0
	self.timelimit_left_time = 0
	self.check_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.CaleTimeQuest, self), 1)

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Register(RemindName.RemindXianShiMiaoSha, self.remind_change)
end

function TimeLimitSaleCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.main_open_bind then
		GlobalEventSystem:UnBind(self.main_open_bind)
		self.main_open_bind = nil
	end

	if self.check_time_quest then
		GlobalTimerQuest:CancelQuest(self.check_time_quest)
		self.check_time_quest = nil
	end

		RemindManager.Instance:UnRegister(RemindName.RemindXianShiMiaoSha)

	TimeLimitSaleCtrl.Instance = nil
end

function TimeLimitSaleCtrl:RegisterAllProtocols()
	-- 注册接收到的协议
	self:RegisterProtocol(SCRARushBuyingAllInfo, "OnSCRARushBuyingAllInfo")		--限时拍卖信息
end

function TimeLimitSaleCtrl:OnSCRARushBuyingAllInfo(protocol)
	self.data:SetAllInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("list")
	end
	RemindManager.Instance:Fire(RemindName.RemindXianShiMiaoSha)
end

function TimeLimitSaleCtrl:MainUiOpen()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING, RA_RUSH_BUYING_OPERA_TYPE.RA_RUSH_BUYING_OPERA_TYPE_QUERY_ALL_INFO)
	end
end

function TimeLimitSaleCtrl:CaleTimeQuest()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING) then
		return
	end
end

function TimeLimitSaleCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING and status == ACTIVITY_STATUS.OPEN then
		self:SendAllInfoReq()
	end
end

function TimeLimitSaleCtrl:SendAllInfoReq()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING,
										RA_CIRCULATION_CHONGZHI_OPERA_TYPE.RA_CIRCULATION_CHONGZHI_OPERA_TYPE_QUERY_INFO)
end

function TimeLimitSaleCtrl:RemindChangeCallBack()
	local show_redpoint = self.data:FlushRedPoint()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING, show_redpoint)
end