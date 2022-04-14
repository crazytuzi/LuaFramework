---
--- Created by  Administrator
--- DateTime: 2020/4/3 16:17
---
ThroneStarDungeRankItem = ThroneStarDungeRankItem or class("ThroneStarDungeRankItem", BaseCloneItem)
local this = ThroneStarDungeRankItem

function ThroneStarDungeRankItem:ctor(obj, parent_node, parent_panel)
    ThroneStarDungeRankItem.super.Load(self)
    self.events = {}
end

function ThroneStarDungeRankItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ThroneStarDungeRankItem:LoadCallBack()
    self.nodes = {
        "name","value","rank",
    }
    self:GetChildren(self.nodes)
    self.rank = GetText(self.rank)
    self.name = GetText(self.name)
    self.value = GetText(self.value)
    self:InitUI()
    self:AddEvent()
end

function ThroneStarDungeRankItem:InitUI()

end

function ThroneStarDungeRankItem:AddEvent()

end

function ThroneStarDungeRankItem:SetData(data,type)
    self.data = data
    self.name.text = "S."..self.data.id
    self.rank.text = self.data.rank
    if type == 1 then
        self.value.text = math.floor(self.data.damage/100).."%"
    else
        self.value.text = self.data.score
    end
end