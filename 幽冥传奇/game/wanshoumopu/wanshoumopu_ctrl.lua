require("scripts/game/wanshoumopu/wanshoumopu_data")
require("scripts/game/wanshoumopu/wanshoumopu_view")

WanShouMoPuCtrl = WanShouMoPuCtrl or BaseClass(BaseController)

function WanShouMoPuCtrl:__init()
	if WanShouMoPuCtrl.Instance then
		ErrorLog("[WanShouMoPuCtrl]:Attempt to create singleton twice!")
	end
	WanShouMoPuCtrl.Instance = self
	self.view = WanShouMoPuView.New(ViewName.WanShouMoPu)
	self.data = WanShouMoPuData.New()
	self:RegisterAllProtocols()
end

function WanShouMoPuCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil


	self.data:DeleteMe()
	self.data = nil

	WanShouMoPuCtrl.Instance = nil
end

function WanShouMoPuCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCWanShouMoPuTaskIss,"OnFinishInfo")
end

function WanShouMoPuCtrl:InfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSWanShouMoPuReq)
	protocol:EncodeAndSend()
end

function WanShouMoPuCtrl:FinishReq(task)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFinishWanShouReq)
	protocol.task = task
	protocol:EncodeAndSend()
end

function WanShouMoPuCtrl:OnFinishInfo(protocol)
	self.data:SetInfo(protocol)
	-- local index = 1
	-- if protocol.finish_task > #WanShouMoPuConfig / 2 then
	-- 	index = 2
	-- end
	self.view:Flush({TabIndex.wanshou, TabIndex.wanmo}, "data")
end