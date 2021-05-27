require("scripts/game/invest_plan/invest_plan_data")
require("scripts/game/invest_plan/invest_plan_view")

--------------------------------------------------------------
--投资计划
--------------------------------------------------------------
InvestPlanCtrl = InvestPlanCtrl or BaseClass(BaseController)
function InvestPlanCtrl:__init()
	if InvestPlanCtrl.Instance then
		ErrorLog("[InvestPlanCtrl] Attemp to create a singleton twice !")
	end
	InvestPlanCtrl.Instance = self

	-- self.view = InvestPlanView.New(ViewName.InvestPlan)
	self.data = InvestPlanData.New()

	self:RegisterAllProtocols()
	self:RegisterAllEvents()
end

function InvestPlanCtrl:__delete()
	InvestPlanCtrl.Instance = nil

	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end

	-- self.view:DeleteMe()
	-- self.view = nil

	self.data:DeleteMe()
	self.data = nil

end

function InvestPlanCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCInvestPlanInfoIss, "OnInvestPlanInfoIss")
end

function InvestPlanCtrl:RegisterAllEvents()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	-- 换天重新获取数据
	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.InvestPlanInfoReq, self))
	self.role_data_event = BindTool.Bind(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.InvestPlan)
end

function InvestPlanCtrl:OnRecvMainRoleInfo()
	self:InvestPlanInfoReq()
end

function InvestPlanCtrl:RoleDataChangeCallback(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_GOLD then
		if value - old_value == InvestPlanCfg.GoldNum then
			self:InvestPlanInfoReq()
		end
	elseif key == OBJ_ATTR.CREATURE_LEVEL and value == 65 then
		self:InvestPlanInfoReq()
	end
end

function InvestPlanCtrl:GetRemindNum(remind_name)
	return self.data:GetRemindNum()
end

-----------------------下发投资计划数据--------------------------------
function InvestPlanCtrl:OnInvestPlanInfoIss(protocol)
	-- print("投资计划数据==剩余天数：==领取状态：", protocol.rest_day, protocol.fetch_state)
	self.data:SetInvestPlanData(protocol)
	RemindManager.Instance:DoRemind(RemindName.InvestPlan)
	self.view:Flush()
end


--------------------------请求-------------------------

-- 请求投资计划信息
function InvestPlanCtrl:InvestPlanInfoReq(req_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSInvestPlanInfoReq)
	protocol.req_type = req_type or 0
	protocol:EncodeAndSend()
end

-- 请求领取投资计划信息
function InvestPlanCtrl:InvestPlanAwarFetchReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSInvestPlanAwarFetchReq)
	protocol:EncodeAndSend()
end