FriendlyTipItem = FriendlyTipItem or class("FriendlyTipItem",BaseCloneItem)
local FriendlyTipItem = FriendlyTipItem

function FriendlyTipItem:ctor(parent_node,layer)
	FriendlyTipItem.super.Load(self)
end

function FriendlyTipItem:dctor()
end

function FriendlyTipItem:LoadCallBack()
	self.nodes = {
		"name","value","desc",
	}
	self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.value = GetText(self.value)
	self.desc = GetText(self.desc)
	self:AddEvent()
end

function FriendlyTipItem:AddEvent()
end

--data:db_flower_honey.level
function FriendlyTipItem:SetData(data)
	self.data = data
	local item = Config.db_flower_honey[data]
	self.name.text = string.format("<color=%s>%s</color>", item.color, item.name)
	self.value.text = string.format("<color=%s>%s</color>", item.color, item.honey)
	self.desc.text = string.format("<color=%s>%s</color>", item.color, item.desc)
end