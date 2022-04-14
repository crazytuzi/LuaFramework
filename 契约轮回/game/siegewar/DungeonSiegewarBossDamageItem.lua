DungeonSiegewarBossDamageItem = DungeonSiegewarBossDamageItem or class("DungeonSiegewarBossDamageItem",BaseCloneItem)
local DungeonSiegewarBossDamageItem = DungeonSiegewarBossDamageItem

function DungeonSiegewarBossDamageItem:ctor(obj,parent_node,layer)
	DungeonSiegewarBossDamageItem.super.Load(self)
end

function DungeonSiegewarBossDamageItem:dctor()
end

function DungeonSiegewarBossDamageItem:LoadCallBack()
	self.nodes = {
		"damage", "name"
	}
	self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.damage = GetText(self.damage)
	self:AddEvent()
end

function DungeonSiegewarBossDamageItem:AddEvent()
end

function DungeonSiegewarBossDamageItem:SetData(data)
	if data.type == 3 then
		self.name.text = string.format("S%s", RoleInfoModel:GetInstance():GetServerName(data.id))
	else
		self.name.text = data.name
	end
	self.damage.text = string.format("%0.1f", data.damage/100) .. "%"
end