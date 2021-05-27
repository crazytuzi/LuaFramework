require("scripts/game/role/cycle/role_cycle_data")

RoleCycleCtrl = RoleCycleCtrl or BaseClass(BaseController)
function RoleCycleCtrl:__init()
	if RoleCycleCtrl.Instance then
		ErrorLog("[RoleCycleCtrl] attempt to create singleton twice!")
		return
	end

	RoleCycleCtrl.Instance = self
	self.data = RoleCycleData.New()
	-- GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo))

	self:RegisterAllProtocols()
end

function RoleCycleCtrl:__delete()
	RoleCycleCtrl.Instance = nil
	
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function RoleCycleCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCIssueCycExchaRestTime, "OnIssueCycExchaRestTime")
	-- self:RegisterProtocol(SCIsIssueCycleInfoSucc, "OnIsIssueCycleInfoSucc")

end

function RoleCycleCtrl:OnRecvMainRoleInfo()
	-- RoleCycleCtrl.GetExchanRestTimeReq()
end

---------------------下发---------------------
-- 今天兑换轮回修为剩余次数
function RoleCycleCtrl:OnIssueCycExchaRestTime(protocol)

end

-- 轮回成功下发
-- function RoleCycleCtrl:OnIsIssueCycleInfoSucc(protocol)
-- 	if protocol.issue_state == 0 then
-- 		GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_CYCLE_SUCC)
-- 	end
-- end

-----------------------请求-------------------

--兑换轮回修为(返回 139 177)
function RoleCycleCtrl.ExchanCycleCultivaReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSExchaCycleCultivReq)
	protocol:EncodeAndSend()
end

--轮回请求
function RoleCycleCtrl.CycleReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCycleReq)
	protocol:EncodeAndSend()
end

--获取今天兑换轮回修为剩余次数(返回 139 177)
function RoleCycleCtrl.GetExchanRestTimeReq()
	-- local protocol = ProtocolPool.Instance:GetProtocol(CSGetCycleExchaRestTime)
	-- protocol:EncodeAndSend()
end