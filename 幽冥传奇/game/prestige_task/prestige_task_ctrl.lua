require("scripts/game/prestige_task/prestige_task_view")
require("scripts/game/prestige_task/prestige_task_data")
require("scripts/game/prestige_task/prestige_task_tip")

PrestigeTaskCtrl = PrestigeTaskCtrl or BaseClass(BaseController)
function PrestigeTaskCtrl:__init()
	if	PrestigeTaskCtrl.Instance then
		ErrorLog("[PrestigeTaskCtrl]:Attempt to create singleton twice!")
	end
	PrestigeTaskCtrl.Instance = self
	
	self.data = PrestigeTaskData.New()
	self.view = PrestigeTaskView.New(ViewDef.PrestigeTask)
	self.tip_view = PrestigeTaskTip.New(ViewDef.PrestigeTaskTip)
	
	self:RegisterAllProtocols()--监听协议 发送和下发
end

function PrestigeTaskCtrl:__delete()
	
	self.view:DeleteMe()															
	self.view = nil
	
	self.data:DeleteMe()
	self.data = nil
	
	self.tip_view:DeleteMe()
	self.tip_view = nil

	PrestigeTaskCtrl.Instance = nil
end

function PrestigeTaskCtrl:RegisterAllProtocols()
	--self:RegisterProtocol(SCPrestigeTaskResult, "OnPrestigeTaskResult")
end

--------------------------------------下发-------------------------------------------
-- 接收威望任务兑换次数 请求(139, 22)
function PrestigeTaskCtrl:OnPrestigeTaskResult(protocol)
	--self.data:SetData(protocol)
	--print("数据下发")
end

--------------------------------------发送-------------------------------------------
-- -- 请求进入威望任务场景 (139, 22)
-- function PrestigeTaskCtrl:SendPrestigeTaskChallenge()
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSPrestigeTaskEnterrdReq)
-- 	protocol:EncodeAndSend()
-- end

-- -- 威望任务兑换 (返回 139 21)
-- function PrestigeTaskCtrl:SendGetPrestigeTaskAward(index)
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSPrestigeTaskExchangeReq)
-- 	protocol.index = index
-- 	protocol:EncodeAndSend()
-- end 