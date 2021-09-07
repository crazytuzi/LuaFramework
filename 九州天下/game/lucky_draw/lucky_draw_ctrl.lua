require("game/lucky_draw/lucky_draw_data")
require("game/lucky_draw/lucky_draw_view")
LuckyDrawCtrl = LuckyDrawCtrl or BaseClass(BaseController)

function LuckyDrawCtrl:__init()
	if LuckyDrawCtrl.Instance then
		print_error("[LuckyDrawCtrl] Attemp to create a singleton twice !")
	end
	LuckyDrawCtrl.Instance = self
	self.view = LuckyDrawView.New(ViewName.LuckyDrawView)
	self.data = LuckyDrawData.New()
	self:RegisterAllProtocols()

	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))
end

function LuckyDrawCtrl:__delete()

	self.view:DeleteMe()

	self.data:DeleteMe()

	LuckyDrawCtrl.Instance = nil
end

function LuckyDrawCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRATianMingDivinationInfo, "OnRATianMingDivinationInfo")
	self:RegisterProtocol(SCTianMingDivinationChouResult, "OnTianMingDivinationActivityStartChouResult")
end

function LuckyDrawCtrl:OnRATianMingDivinationInfo(protocol)
	self.data:SetLuckyDrawInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function LuckyDrawCtrl:OnTianMingDivinationActivityStartChouResult(protocol)
	self.data:SetLuckyDrawResultInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	self.view:FlushAnimation()
end

function LuckyDrawCtrl:Open()
	self.view:Open()
end

function LuckyDrawCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_QUERY_INFO, 0, 0)
		end
	end
end