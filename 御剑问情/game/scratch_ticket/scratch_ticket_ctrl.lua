require("game/scratch_ticket/scratch_ticket_view")
require("game/scratch_ticket/scratch_ticket_data")

ScratchTicketCtr = ScratchTicketCtr or BaseClass(BaseController)
function ScratchTicketCtr:__init()
	if ScratchTicketCtr.Instance then
		print_error("[ScratchTicketCtr] Attemp to create a singleton twice !")
	end
	ScratchTicketCtr.Instance = self

	self.data = ScratchTicketData.New()
	self.view = ScratchTicketView.New(ViewName.ScratchTicketView)

	self:RegisterAllProtocols()
    
    self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.GuaGuaLe)

	RemindManager.Instance:Fire(RemindName.GuaGuaLe)
	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))
end

function ScratchTicketCtr:__delete()
	ScratchTicketCtr.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function ScratchTicketCtr:RegisterAllProtocols()
	self:RegisterProtocol(SCRAGuaGuaInfo, "OnSCRAGuaGuaInfo")
	self:RegisterProtocol(SCRAGuaGuaMultiReward, "OnSCRAGuaGuaMultiReward")
end

function ScratchTicketCtr:OnSCRAGuaGuaInfo(protocol)
	self.data:SetRAGuaGuaInfo(protocol)		--服务器下发协议
	self.view:Flush()						--协议放松下来后刷新
	RemindManager.Instance:Fire(RemindName.GuaGuaLe)
end

function ScratchTicketCtr:OnSCRAGuaGuaMultiReward(protocol)
	self.data:GuaGuaMultiReward(protocol)	--服务器下发协议
	TipsCtrl.Instance:ShowTreasureView(ScratchTicketData.Instance:GetChestShopMode())
	self.view:Flush()						--协议放松下来后刷新
	RemindManager.Instance:Fire(RemindName.GuaGuaLe)
end


function ScratchTicketCtr:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
end

function ScratchTicketCtr:ActivityChange(activity_type, status, next_time, open_type)

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_QUERY_INFO,0,0)
		end
	end
end

function ScratchTicketCtr:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.GuaGuaLe then
		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, num > 0)
	end
end