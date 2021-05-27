require("scripts/game/supply_contention/supply_contention_score_view")
require("scripts/game/supply_contention/supply_contention_data")

SupplyContentionScoreCtrl = SupplyContentionScoreCtrl or BaseClass(BaseController)

function SupplyContentionScoreCtrl:__init()
	if SupplyContentionScoreCtrl.Instance then
		ErrorLog("[SupplyContentionScoreCtrl]:Attempt to create singleton twice!")
	end
	SupplyContentionScoreCtrl.Instance = self

	self.data = SupplyContentionData.New()
	self.view = SupplyContentionScoreView.New(ViewName.SupplyContentionScoreView)

	self:RegisterAllProtocols()

	self.isInSupplyContention = false --是否在补给争夺
end


function SupplyContentionScoreCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGetSupplyContentionRankData, "OnRankInfo")
	self:RegisterProtocol(SCGetSupplyContentionRolePosData, "OnRoleInfo")
	self:RegisterProtocol(SCGetSupplyContentionMyData, "OnMyInfo")
end


function SupplyContentionScoreCtrl:OnRankInfo(protocol)
	self.data:UpdataRankData(protocol)
	self.view:Flush();
end


function SupplyContentionScoreCtrl:OnRoleInfo(protocol)
	GlobalEventSystem:Fire(SupplyContentionEventType.SUPPLY_CONTENTION_ROLE_POS_CHANGE,protocol)
end


function SupplyContentionScoreCtrl:OnMyInfo(protocol)
	GlobalEventSystem:Fire(SupplyContentionEventType.SUPPLY_CONTENTION_SCRON_CHANGE,protocol)
end




function SupplyContentionScoreCtrl:SendSupplyContentionState(value)
	self.isInSupplyContention = value;
end



--请求活动排行榜数据
function SupplyContentionScoreCtrl:SendDeleteMailReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSSupplyContentionRankDataReq)
	protocol:EncodeAndSend()
end

--请求获取押镖者位置
function SupplyContentionScoreCtrl:SendGetRolePosReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSSupplyContentionRolePosReq)
	protocol:EncodeAndSend()
end



function SupplyContentionScoreCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

    SupplyContentionScoreCtrl.Instance = nil
end