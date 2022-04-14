--
-- @Author: chk
-- @Date:   2018-09-29 15:48:00
--
EquipBestAttrItemSettor = EquipBestAttrItemSettor or class("EquipBestAttrItemSettor",BaseWidget)
local EquipBestAttrItemSettor = EquipBestAttrItemSettor

function EquipBestAttrItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "EquipBestAttrItem"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	EquipBestAttrItemSettor.super.Load(self)
end

function EquipBestAttrItemSettor:dctor()
end

function EquipBestAttrItemSettor:LoadCallBack()
	self.nodes = {
		"",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end

function EquipBestAttrItemSettor:AddEvent()
end

function EquipBestAttrItemSettor:SetData(data)

end