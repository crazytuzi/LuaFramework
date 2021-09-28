require("game/jubaopen/ju_bao_pen_view")
require("game/jubaopen/ju_bao_pen_data")

JuBaoPenCtrl = JuBaoPenCtrl or BaseClass(BaseController)

function JuBaoPenCtrl:__init()
	if JuBaoPenCtrl.Instance ~= nil then
		print_error("[JuBaoPenCtrl] attempt to create singleton twice!")
		return
	end
	JuBaoPenCtrl.Instance = self

	self.view = JuBaoPenView.New(ViewName.JuBaoPen)
	self.data = JuBaoPenData.New()

	self:RegisterAllProtocols()
	self:BindGlobalEvent(OtherEventType.RANDOW_ACTIVITY, BindTool.Bind(self.RandomActivity, self))
	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))

	self.is_receive_rand_activity = false
end

function JuBaoPenCtrl:__delete()
	self.view:DeleteMe()
	self.data:DeleteMe()
	JuBaoPenCtrl.Instance = nil
end

function JuBaoPenCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRACornucopiaFetchInfo, "OnRACornucopiaFetchInfo")
	self:RegisterProtocol(SCRACornucopiaFetchReward, "OnRACornucopiaFetchReward")
end

function JuBaoPenCtrl:OnRACornucopiaFetchInfo(protocol)
	self.data:SetRACornucopiaFetchInfo(protocol)
	self.view:Flush("charge")
	ViewManager.Instance:FlushView(ViewName.Main, "jubaopen")
	if self.is_receive_rand_activity then
		RemindManager.Instance:Fire(RemindName.JuBaoPen)
	end
end

function JuBaoPenCtrl:OnRACornucopiaFetchReward(protocol)
	self.view:Flush("roll", {protocol.get_reward_gold})
end

function JuBaoPenCtrl:RandomActivity()
	self.is_receive_rand_activity = true
	RemindManager.Instance:Fire(RemindName.JuBaoPen)
end

function JuBaoPenCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA, RA_CORNUCOPIA_OPERA_TYPE.RA_CORNUCOPIA_OPERA_TYPE_QUERY_INFO)
		end
	end
end

function JuBaoPenCtrl:OpenView()
	local max_lun = JuBaoPenData.Instance:GetMaxLun()
	local cur_lun = JuBaoPenData.Instance:GetRewardLun()
	if cur_lun <= max_lun then
		self.view:Open()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.JuBaoPen.GetAll)
	end
end