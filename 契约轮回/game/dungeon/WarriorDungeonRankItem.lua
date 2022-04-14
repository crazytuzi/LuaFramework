---
--- Created by  Administrator
--- DateTime: 2019/8/13 19:49
---
WarriorDungeonRankItem = WarriorDungeonRankItem or class("WarriorDungeonRankItem", BaseCloneItem)
local this = WarriorDungeonRankItem

function WarriorDungeonRankItem:ctor(obj, parent_node, parent_panel)
    WarriorDungeonRankItem.super.Load(self)
    self.events = {}
end

function WarriorDungeonRankItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function WarriorDungeonRankItem:LoadCallBack()
    self.nodes = {
		"role_rank","score","rankicon","selected","role_name",
    }
    self:GetChildren(self.nodes)
	self.role_rank = GetText(self.role_rank)
	self.role_name = GetText(self.role_name)
	self.score = GetText(self.score)
	self.rankicon = GetImage(self.rankicon)
    self:InitUI()
    self:AddEvent()
	SetVisible(self.selected,false)
end

function WarriorDungeonRankItem:InitUI()

end

function WarriorDungeonRankItem:AddEvent()

end

function WarriorDungeonRankItem:SetData(data,index)
	dump(data)
	SetVisible(self.rankicon,index <= 3)
	SetVisible(self.role_rank,index>3)
	lua_resMgr:SetImageTexture(self, self.rankicon, "dungeon_image", "melee_dungeon_rank_icon_"..index, false, nil, false)
	self.role_rank.text = index
	if not data then
		self.role_name.text = "Nobody made the list yet"
		self.score.text = " "
		return
	end
    self.data = data
	local role = self.data.base
	self.role_name.text = role.name
	self.score.text = self.data.sort
end