require("scripts/game/recycleYB/recycle_yb_data")
require("scripts/game/recycleYB/recycle_yb")

RecycleYBCtrl = RecycleYBCtrl or BaseClass(BaseController)
function RecycleYBCtrl:__init()
	if RecycleYBCtrl.Instance then
		ErrorLog("[RecycleYBCtrl]:Attempt to create singleton twice!")
	end
	RecycleYBCtrl.Instance = self

	self.data = RecycleYBData.New()
	self.view = RecycleYBView.New(ViewName.RecycleYB)
	self:RegisterAllProtocls()
	
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.SendRecycleInfoReq, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.RecycleYB)
	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
end
function RecycleYBCtrl:__delete()
	if ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
	end
end

function RecycleYBCtrl:RegisterAllProtocls()
	self:RegisterProtocol(SCServerRecycleData,"OnRecycleData")
end

function RecycleYBCtrl:OnRecycleData(protocol)
	self.data:RecycleYBProtocolInfo(protocol)
	GlobalEventSystem:Fire(OpenServerActivityEventType.OPENSERVER_Recycle_YB)
	RemindManager.Instance:DoRemind(RemindName.RecycleYB)
end
function RecycleYBCtrl.SendRecycleYBReq(YBindex)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetServerRecycleRewardReq)
	protocol.reward_pos = YBindex
	protocol:EncodeAndSend()
end
function RecycleYBCtrl.SendRecycleInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSServerRecycleReq)
	protocol:EncodeAndSend()
end
function RecycleYBCtrl:GetRemindSign(remind_name)
	if remind_name == RemindName.RecycleYB then
		return self.data:GetBoolShowEffect()
	end
end
function RecycleYBCtrl:ItemDataChangeCallback()
	local num = self.data:GetBoolShowEffect()
	RemindManager.Instance:DoRemind(RemindName.RecycleYB)
	if num ==  1 then
		RecycleYBCtrl.SendRecycleInfoReq()
	end
end
