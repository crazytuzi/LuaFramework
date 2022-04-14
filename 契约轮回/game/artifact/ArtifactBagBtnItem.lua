---
--- Created by  Administrator
--- DateTime: 2020/6/24 14:54
---
ArtifactBagBtnItem = ArtifactBagBtnItem or class("ArtifactBagBtnItem", BaseCloneItem)
local this = ArtifactBagBtnItem

function ArtifactBagBtnItem:ctor(obj, parent_node, parent_panel)
    ArtifactBagBtnItem.super.Load(self)
    self.model = ArtifactModel:GetInstance()
    self.events = {}

end

function ArtifactBagBtnItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ArtifactBagBtnItem:LoadCallBack()
    self.nodes = {
        "bg","select","stText"
    }
    self:GetChildren(self.nodes)
    self.stText = GetText(self.stText)
    self:InitUI()
    self:AddEvent()
end

function ArtifactBagBtnItem:InitUI()

end

function ArtifactBagBtnItem:AddEvent()

    local function call_back()
        self.model:Brocast(ArtifactEvent.bagBtnClick,self.index)
    end
    AddButtonEvent(self.bg.gameObject,call_back)
end

function ArtifactBagBtnItem:SetData(data,index)
    self.data = data
    self.index = index
    self.stText.text = self.data
end

function ArtifactBagBtnItem:SetSelect(isShow)
    SetVisible(self.select,isShow)
end