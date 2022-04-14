--
-- @Author: chk
-- @Date:   2018-12-08 11:56:58
--
FactionInfoCareerItemSettor = FactionInfoCareerItemSettor or class("FactionInfoCareerItemSettor",BaseFactionInfoCareerItemSettor)
local FactionInfoCareerItemSettor = FactionInfoCareerItemSettor

function FactionInfoCareerItemSettor:ctor(parent_node,layer,index)
	self.abName = "faction"
	self.assetName = "FactionInfoCareerItem"
	--self.layer = layer
	--self.index = index
	--self.can_appointment = false --是否可以任命
	--self.model = FactionModel:GetInstance()
	FactionInfoCareerItemSettor.super.Load(self)
end
