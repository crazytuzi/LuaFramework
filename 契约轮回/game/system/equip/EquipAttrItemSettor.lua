--
-- @Author: chk
-- @Date:   2018-08-30 10:58:56
--
EquipAttrItemSettor = EquipAttrItemSettor or class("EquipAttrItemSettor",BaseEquipAttrItemSettor)
local EquipAttrItemSettor = EquipAttrItemSettor

function EquipAttrItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "EquipAttrInfoItem"
	self.layer = layer

	--self.schedule_id = nil
	--self.itemRectTra = nil
	--self.titleRectTra = nil
	--self.lineRectTra = nil
	--self.TextRectTra = nil
	--self.equipAttr = nil
	--self.need_loaded_end = false
	--self.globalEvents = {}
	EquipAttrItemSettor.super.Load(self)

	print("创建属性item项——————")
end

function EquipAttrItemSettor:dctor()
end

function EquipAttrItemSettor:LoadCallBack()
	EquipAttrItemSettor.super.LoadCallBack(self)
	
end

function EquipAttrItemSettor:AddEvent()
	EquipAttrItemSettor.super.AddEvent(self)
end


function EquipAttrItemSettor:SetData(data)
	self.equipAttr = data
end


