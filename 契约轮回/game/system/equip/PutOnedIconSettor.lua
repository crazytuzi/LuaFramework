--
-- @Author: chk
-- @Date:   2018-09-17 20:00:46
--
PutOnedIconSettor = PutOnedIconSettor or class("PutOnedIconSettor",GoodsIconSettorTwo)
local PutOnedIconSettor = PutOnedIconSettor

function PutOnedIconSettor:ctor(parent_node,layer)
	--self.layer = layer
	--self.abName = "system"
	--self.assetName = "PutOnedIconSettor"

	--PutOnedIconSettor.super.Load(self)
end

function PutOnedIconSettor:dctor()
end

function PutOnedIconSettor:AddEvent()
	PutOnedIconSettor.super.AddEvent(self)

	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.PutOffEquip,handler(self,self.DealPutOff))
end

function PutOnedIconSettor:DealPutOff(slot)
	if self.slot == slot then
		self:destroy()
	end
end

function PutOnedIconSettor:SetSlot(slot)
	self.slot = slot
end


