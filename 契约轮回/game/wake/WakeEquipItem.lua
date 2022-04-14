WakeEquipItem = WakeEquipItem or class("WakeEquipItem",BaseCloneItem)
local WakeEquipItem = WakeEquipItem

function WakeEquipItem:ctor(obj,parent_node,layer)
	WakeEquipItem.super.Load(self)
end

function WakeEquipItem:dctor()
	self.equip_item:destroy()
end

function WakeEquipItem:LoadCallBack()
	self.nodes = {
		"item", "name"
	}
	self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self:AddEvent()
end

function WakeEquipItem:AddEvent()
end

--data:item_id
function WakeEquipItem:SetData(data)
	self.data = data
	local param = {}
    param["model"] = self.model
    param["item_id"] = self.data
    param["can_click"] = true
    param["size"] = {x=80, y=80}
	self.equip_item = GoodsIconSettorTwo(self.item)
	self.equip_item:SetIcon(param)
	self.name.text = Config.db_item[self.data].name
end