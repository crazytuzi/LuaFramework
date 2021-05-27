require("scripts/game/investment/investment_view")
require("scripts/game/investment/investment_data")

InvestmentCtrl = InvestmentCtrl or BaseClass(BaseController)

function InvestmentCtrl:__init()
	if InvestmentCtrl.Instance then
		ErrorLog("[InvestmentCtrl]:Attempt to create singleton twice!")
	end
	InvestmentCtrl.Instance = self
	self.data = InvestmentData.New()
	self.view = InvestmentView.New(ViewDef.Investment)
	self:RegisterAllProtocols()

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.RecvMainRoleInfo))
end

function InvestmentCtrl:__delete( )
	InvestmentCtrl.Instance = nil

	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil
end

function InvestmentCtrl:RecvMainRoleInfo()
	InvestmentCtrl.Instance:SendGetRebateEveryDayInfo()
	InvestmentCtrl.RequestInvestmentInfo(1)
	InvestmentCtrl.SendLuxuryGifts(1)
end

function InvestmentCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCInvestmentInfo, "OnInvestmentResult")
	self:RegisterProtocol(SCRebateEveryDayInfo, "OnRebateEveryDayInfo")
	self:RegisterProtocol(SC_139_226, "OnLuxuryGiftsSign")

end

function InvestmentCtrl:OnDailyGiftBagInfoChange(protocol)
	self.data:SetDailyGiftBagDataChange(protocol)
end

-- 下发超值投资(139, 202)
function InvestmentCtrl:OnInvestmentResult(protocol)
	if not IS_ON_CROSSSERVER and not IS_AUDIT_VERSION then
		if protocol.op_type == 1 then
			InvestmentData.Instance:SetDaliyList(protocol)
		elseif protocol.op_type >= 2 then
			 InvestmentData.Instance:SetDaliyData(protocol)
		end

		RemindManager.Instance:DoRemind(RemindName.Investment)
	end
end

function InvestmentCtrl.RequestInvestmentInfo(type,index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSInvestmentInfo)
	protocol.op_type = type
	protocol.award_index = index
	protocol:EncodeAndSend()
end

-- 请求天天返利信息
function InvestmentCtrl:SendGetRebateEveryDayInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSRebateEveryDayInfo)
	protocol.op_type = 2
	protocol:EncodeAndSend()
end

-- 请求领取天天返利奖励
function InvestmentCtrl:SendGetRebateEveryDayReward(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRebateEveryDayInfo)
	protocol.op_type = 3
	protocol.award_index = index
	protocol:EncodeAndSend()
end

-- 下发天天返利信息
function InvestmentCtrl:OnRebateEveryDayInfo(protocol)
	self.data:SetRebateEveryDayInfo(protocol)

	RemindManager.Instance:DoRemind(RemindName.EveryDayRebate)
end

--接收天天充值豪礼数据
function InvestmentCtrl:OnLuxuryGiftsSign(protocol)
	self.data:SetLuxuryGiftsSign(protocol)
end

--请求 天天充值豪礼
function InvestmentCtrl.SendLuxuryGifts(op_type, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CS_139_221)
	protocol.op_type = op_type -- 事件id, 1玩家数据, 2领取
	if op_type == 2 then
		protocol.index = index
	end
	protocol:EncodeAndSend()
end
