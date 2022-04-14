--
-- @Author: chk
-- @Date:   2018-09-17 22:26:21
--
EquipDetailViewOnly = EquipDetailViewOnly or class("EquipDetailViewOnly",BaseEquipDetailView)
local EquipDetailViewOnly = EquipDetailViewOnly

function EquipDetailViewOnly:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "EquipDetailView"
	self.layer = layer

	self:InitData()
	EquipDetailViewOnly.super.Load(self)
end

function EquipDetailViewOnly:dctor()
end

function EquipDetailViewOnly:LoadCallBack()
	EquipDetailViewOnly.super.LoadCallBack(self)

	SetVisible(self.btnContain.gameObject,false)
end

function EquipDetailViewOnly:AddEvent()
	self:AddClickCloseBtn()
	self.events[#self.events+1] = GlobalEvent:AddListener(GoodsEvent.CreateAttEnd,handler(self,self.DealCreateAttEnd))
end

