require("scripts/game/fumo_task/fumo_data")
require("scripts/game/fumo_task/fumo_view")
--伏魔任务Ctr
FoMoCtrl = FoMoCtrl or BaseClass(BaseController)

function FoMoCtrl:__init()
	if FoMoCtrl.Instance ~= nil then
		ErrorLog("[FoMoCtrl] attempt to create singleton twice!")
		return
	end
	FoMoCtrl.Instance = self
	self.data = FuMoData.New()
	self.view = FumoView.New(ViewName.FumoTask)
	self:RegisterAllProtocls()
end	

function FoMoCtrl:__delete()
	self.data:DeleteMe()
	self.view:DeleteMe()
	FoMoCtrl.Instance = nil
end	


function FoMoCtrl:RegisterAllProtocls()
	self:RegisterProtocol(SCFumoInfoBack,"OnFumoInfoBack")
	self:RegisterProtocol(SCFumoStateBack,"OnFumoStateBack")
end

function FoMoCtrl:SendFumoOperateReq(op_type,task_id,much_award)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFumoOperateReq)
	protocol.op_type = op_type
	protocol.task_id = task_id
	protocol.much_award = much_award
	protocol:EncodeAndSend()
end

function FoMoCtrl:OnFumoInfoBack(protocol)
	self.data:ChangeBaseInfo(protocol)
	if protocol.open_type == 1 then
		ViewManager.Instance:Open(ViewName.FumoTask)
	end	
	GlobalEventSystem:Fire(FumoEventType.FUMO_INFO_CHANGE_BACK)
	
end	

function FoMoCtrl:OnFumoStateBack(protocol)
	self.data:ChangeStateInfo(protocol)
	GlobalEventSystem:Fire(FumoEventType.FUMO_VIEW_OPERATE_BACK)
end	
