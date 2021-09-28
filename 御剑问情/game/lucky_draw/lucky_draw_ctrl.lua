require("game/lucky_draw/lucky_draw_data")
require("game/lucky_draw/lucky_draw_view")
require("game/lucky_draw/lucky_draw_auto_pop_view")
LuckyDrawCtrl = LuckyDrawCtrl or BaseClass(BaseController)

function LuckyDrawCtrl:__init()
	if LuckyDrawCtrl.Instance then
		print_error("[LuckyDrawCtrl] Attemp to create a singleton twice !")
	end
	LuckyDrawCtrl.Instance = self
	self.view = LuckyDrawView.New(ViewName.LuckyDrawView)
	self.auto_pop_view = LuckyDrawAutoPopView.New(ViewName.LuckyDrawAutoPopView)
	self.data = LuckyDrawData.New()
	self:RegisterAllProtocols()

	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))
end

function LuckyDrawCtrl:__delete()

	self:CacleSendDelayTime()
	self:CacleClearDelayTime()

	self.view:DeleteMe()

	self.data:DeleteMe()

	LuckyDrawCtrl.Instance = nil
end

function LuckyDrawCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRATianMingDivinationInfo, "OnRATianMingDivinationInfo")
	self:RegisterProtocol(SCTianMingDivinationActivityStartChouResult, "OnTianMingDivinationActivityStartChouResult")
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
	if protocol.item_count > 1 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.LOCKY_DRAW_10)
	end

	if self.data:GetAutoFlag() and self.view:IsOpen() then
		self:AutoDivination()
		return
	end

	if self.data:GetStopFlag() then
		self:ClearData()
		return
	end

	if not self.data:GetAutoFlag() then
		self.view:FlushAnimation(protocol.item_count > 1)
		return
	end
end

function LuckyDrawCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_QUERY_INFO, 0, 0)
		end
	end
end

function LuckyDrawCtrl:AutoDivination()
	self.view:FlushAutoAnimation()

	if not self.data:IsDesired() and self.view:IsOpen() then
        if not self.data:IsEnoughGold() then
            TipsCtrl.Instance:ShowLackDiamondView()
            self:ClearData()
            self.view:Flush()
            return
        end

        self:StartSendDelayTime()

        self:CacleSendDelayTime()
		self.delay_send_time = GlobalTimerQuest:AddDelayTimer(function()
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_START_CHOU, 1, 0)
			end, 0.05)
	elseif self.data:IsDesired() then
		self:ClearData()
	end
end

function LuckyDrawCtrl:StartSendDelayTime()
	self:CacleClearDelayTime()
	self.delay_clear_time = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.ClearData, self), 2)
end

function LuckyDrawCtrl:CacleClearDelayTime()
	if self.delay_clear_time then
		GlobalTimerQuest:CancelQuest(self.delay_clear_time)
		self.delay_clear_time = nil
	end
end

function LuckyDrawCtrl:CacleSendDelayTime()
	if self.delay_send_time then
		GlobalTimerQuest:CancelQuest(self.delay_send_time)
		self.delay_send_time = nil
	end
end

function LuckyDrawCtrl:ClearData()
	self.data:SetAutoFlag(false)
	self.data:SetStopFlag(false)
end