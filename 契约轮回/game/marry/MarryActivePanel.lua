---
--- Created by  Administrator
--- DateTime: 2019/6/3 14:40
---
MarryActivePanel = MarryActivePanel or class("MarryActivePanel", BaseItem)
local this = MarryActivePanel

function MarryActivePanel:ctor(parent_node, parent_panel)
    self.abName = "marry";
    self.assetName = "MarryActivePanel"
    self.layer = "UI"

    self.events = {}
    MarryActivePanel.super.Load(self)
end

function MarryActivePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function MarryActivePanel:LoadCallBack()
    self.nodes = {

    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function MarryActivePanel:InitUI()

end

function MarryActivePanel:AddEvent()

end