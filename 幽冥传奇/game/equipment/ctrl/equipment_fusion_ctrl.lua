require("scripts/game/equipment/data/equipment_fusion_data")

--------------------------------------------------------
-- 锻造-融合 Ctrl
--------------------------------------------------------

EquipmentFusionCtrl = EquipmentFusionCtrl or BaseClass(BaseController)

function EquipmentFusionCtrl:__init()
	if	EquipmentFusionCtrl.Instance then
		ErrorLog("[EquipmentFusionCtrl]:Attempt to create singleton twice!")
	end
	EquipmentFusionCtrl.Instance = self

	self.data = EquipmentFusionData.New()

	self:RegisterAllProtocols()
end

function EquipmentFusionCtrl:__delete()
	EquipmentFusionCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

--登记所有协议
function EquipmentFusionCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCDiamondsCreateResult, "OnDiamondsCreateResult")	--钻石打造
end

----------接收----------

-- 接收打钻结果(8, 34)
-- function EquipmentFusionCtrl:OnDiamondsCreateResult(protocol)
-- 	-- self.data:SetCreateResults(protocol)
-- end

----------发送----------

-- 锻造-融合 请求装备融合 (7, 31)
function EquipmentFusionCtrl.SendEquipmentFusionReq(series1, series2, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipmentFusion)
	protocol.series1 = series1
	protocol.series2 = series2
	protocol.index = index
	protocol:EncodeAndSend()
end

-- 锻造-融合-装备分解
function EquipmentFusionCtrl.SendEquipmentFusionRecycleReq(series_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CS_7_58)
	protocol.series_list = series_list
	protocol:EncodeAndSend()
end

--------------------
