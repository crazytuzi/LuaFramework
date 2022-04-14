--
-- @Author: chk
-- @Date:   2018-12-12 20:22:37
--
FactionInfoCareerItemSettor2 = FactionInfoCareerItemSettor2 or class("FactionInfoCareerItemSettor2",BaseFactionInfoCareerItemSettor)
local FactionInfoCareerItemSettor2 = FactionInfoCareerItemSettor2

function FactionInfoCareerItemSettor2:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionInfoCareerItem2"
	self.layer = layer

	self.model = FactionModel:GetInstance()
	FactionInfoCareerItemSettor2.super.Load(self)
end

function FactionInfoCareerItemSettor2:SetPosition()
	local x = math.floor(self.index / 6)
	local y = (self.index - 1) % 5
	SetAnchoredPosition(self.transform,x * 483, 28-y * 85)
end
