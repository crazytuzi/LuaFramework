require("game/reset_double_chongzhi/reset_double_chongzhi_data")
require("game/reset_double_chongzhi/reset_double_chongzhi_view")

ResetDoubleChongzhiCtrl = ResetDoubleChongzhiCtrl or BaseClass(BaseController)

function ResetDoubleChongzhiCtrl:__init()
	if ResetDoubleChongzhiCtrl.Instance then
		print_error("[PuTianTongQingCtrl] Attemp to create a singleton twice !")
	end
	ResetDoubleChongzhiCtrl.Instance = self

	self.data = ResetDoubleChongzhiData.New()
	self.view = ResetDoubleChongzhiView.New(ViewName.ResetDoubleChongzhiView)

	self:RegisterAllProtocols()

	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))
end

function ResetDoubleChongzhiCtrl:__delete()
	ResetDoubleChongzhiCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
end

function ResetDoubleChongzhiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAResetDoubleChongzhi, "OnSCRAResetDoubleChongzhi")
end

function ResetDoubleChongzhiCtrl:OnSCRAResetDoubleChongzhi(protocol)
	self.data:SetChongzhiInfo(protocol)

	if ViewManager.Instance:IsOpen(ViewName.VipView) then
		 VipCtrl.Instance:FlushView()
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI) then
		if self.data:IsAllRecharge() then
			local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
			if act_info then
				ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI,ACTIVITY_STATUS.CLOSE,
					act_info.next_time,act_info.start_time,act_info.end_time,act_info.open_type)
			end

			MainUICtrl.Instance:FlushView()
		end
	end
end

function ResetDoubleChongzhiCtrl:ActivityChange(act_type)
	if act_type ~= ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI then return end

	local open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)

	if open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI,
			RA_REST_DOUBLE_CHATGE_OPERA_TYPE.RA_RESET_DOUBLE_CHONGZHI_OPERA_TYPE_INFO)
	else
		if ViewManager.Instance:IsOpen(ViewName.VipView) then
			VipCtrl.Instance:FlushView()
		end
	end
end
