---
--- Created by  Administrator
--- DateTime: 2019/11/25 17:05
---
CompeteGuessItem = CompeteGuessItem or class("CompeteGuessItem", BaseCloneItem)
local this = CompeteGuessItem

function CompeteGuessItem:ctor(obj, parent_node, parent_panel)
    CompeteGuessItem.super.Load(self)
    self.events = {}
    self.model = CompeteModel:GetInstance()
end

function CompeteGuessItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function CompeteGuessItem:LoadCallBack()
    self.nodes = {
        "select","bg","name",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()
end

function CompeteGuessItem:InitUI()

end

function CompeteGuessItem:AddEvent()
    local function call_back()
        self.model:Brocast(CompeteEvent.CompeteGuessItemClick,self)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function CompeteGuessItem:SetData(data)
    self.data = data
    local costTab = String2Table(self.data.cost)
    self.costId = 0
    self.costNum = 0
    if not table.isempty(costTab)  then
        self.costId = costTab[1][1]
        self.costNum = costTab[1][2]
    end
    self.name.text = self.costNum..enumName.ITEM[self.costId]
end

function CompeteGuessItem:SetSelect(isShow)
    
end
