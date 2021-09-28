require("game/loop_charge_activity/loop_charge_view")
require("game/loop_charge_activity/loop_charge_data")
LoopChargeCtrl = LoopChargeCtrl or BaseClass(BaseController)

function LoopChargeCtrl:__init()
	if LoopChargeCtrl.Instance ~= nil then
		print_error("[LoopChargeCtrl] Attemp to create a singleton twice !")
	end

	LoopChargeCtrl.Instance = self
	self.red_flag = true
	self.data = LoopChargeData.New()
	self.view = LoopChargeView.New(ViewName.LoopChargeView)
	-- self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE,BindTool.Bind(self.FlushInfo, self))
	self:BindGlobalEvent(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.OnLevelChange, self))
	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))
	self:RegisterAllProtocols()
end

function LoopChargeCtrl:__delete()
	LoopChargeCtrl.Instance = nil
	self.data:DeleteMe()
	self.data = nil
end

function LoopChargeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSCirculationChongzhiOperate)
	self:RegisterProtocol(SCCirculationChongzhiInfo,"OnLoopCharge")
end

function LoopChargeCtrl:FlushInfo()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2,
			CIRCULATION_CHONGZHI_OPERA_TYPE.CIRCULATION_CHONGZHI_OPERA_TYPE_QUERY_INFO, 0, 0)
	RemindManager.Instance:Fire(RemindName.LoopChargeRemind)
	RemindManager.Instance:Fire(RemindName.LoopCharge)
end

function LoopChargeCtrl:OnLoopCharge(protocol)
	self.data:SetData(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.LoopCharge)
end

function LoopChargeCtrl:SendOperate(operate_type)
	local  protocol = ProtocolPool.Instance:GetProtocol(CSCirculationChongzhiOperate)
	protocol.operate_type = operate_type
	protocol:EncodeAndSend()
end

function LoopChargeCtrl:OnLevelChange()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level == OpenFunData.Instance:GetOpenLevel("LoopCharge") then
		RemindManager.Instance:Fire(RemindName.LoopChargeRemind)
		RemindManager.Instance:Fire(RemindName.LoopCharge)
	end
end

function LoopChargeCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2 then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOOP_CHARGE_2,
				CIRCULATION_CHONGZHI_OPERA_TYPE.CIRCULATION_CHONGZHI_OPERA_TYPE_QUERY_INFO, 0, 0)
			RemindManager.Instance:Fire(RemindName.LoopChargeRemind)
			RemindManager.Instance:Fire(RemindName.LoopCharge)
		end
	end
end