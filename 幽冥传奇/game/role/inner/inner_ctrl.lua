require("scripts/game/role/inner/inner_data")
--------------------------------------------------------------
--内功相关
--------------------------------------------------------------
InnerCtrl = InnerCtrl or BaseClass(BaseController)
function InnerCtrl:__init()
	if InnerCtrl.Instance then
		ErrorLog("[InnerCtrl] Attemp to create a singleton twice !")
	end
	InnerCtrl.Instance = self

	self.inner_data = InnerData.New()

	self:RegisterAllProtocols()
end

function InnerCtrl:__delete()
	InnerCtrl.Instance = nil

	self.inner_data:DeleteMe()
	self.inner_data = nil
end

-- function InnerCtrl:RegisterAllProtocols()
-- 	self:RegisterProtocol(SCInnerEquipResult, "OnInnerEquipResult")
-- 	self:RegisterProtocol(SCInnerEquipData, "OnInnerEquipData")
-- end

-- function InnerCtrl:OnInnerEquipResult(protocol)
-- 	self.inner_data:SetEquipNum(protocol.slot, protocol.item_num)
-- end

-- function InnerCtrl:OnInnerEquipData(protocol)
-- 	for k, v in pairs(protocol.slot_list) do
-- 		self.inner_data:SetEquipNum(k, v)
-- 	end
-- end

-- --内功升级请求
-- function InnerCtrl.SendInnerUpReq()
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSInnerUpReq)
-- 	protocol:EncodeAndSend()
-- end

-- --内功一键升级请求
-- function InnerCtrl.SendInnerOneKeyUpReq()
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSInnerOneKeyUpReq)
-- 	protocol:EncodeAndSend()
-- end

-- --内功资质注入
-- function InnerCtrl.SendInnerEquipReq(series)
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSInnerEquip)
-- 	protocol.series = series
-- 	protocol:EncodeAndSend()
-- end
