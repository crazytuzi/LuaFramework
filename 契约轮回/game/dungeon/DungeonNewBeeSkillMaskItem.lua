DungeonNewBeeSkillMaskItem = DungeonNewBeeSkillMaskItem or class("DungeonNewBeeSkillMaskItem",BaseItem)
local DungeonNewBeeSkillMaskItem = DungeonNewBeeSkillMaskItem

function DungeonNewBeeSkillMaskItem:ctor(parent_node,layer)
	self.abName = "dungeon"
	self.assetName = "DungeonNewBeeSkillMaskItem"
	self.layer = layer

	self.data = nil
	DungeonNewBeeSkillMaskItem.super.Load(self)
end

function DungeonNewBeeSkillMaskItem:dctor()
end

function DungeonNewBeeSkillMaskItem:LoadCallBack()
	self.nodes = {
		"",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end

function DungeonNewBeeSkillMaskItem:AddEvent()
end

function DungeonNewBeeSkillMaskItem:SetData(data)

end