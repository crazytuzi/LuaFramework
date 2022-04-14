---
--- Created by  Administrator
--- DateTime: 2019/11/26 19:28
---
CompeteRankBtnItem = CompeteRankBtnItem or class("CompeteRankBtnItem", BaseCloneItem)
local this = CompeteRankBtnItem

function CompeteRankBtnItem:ctor(obj, parent_node, parent_panel)
    CompeteRankBtnItem.super.Load(self)
    self.events = {}
    self.model = CompeteModel:GetInstance()
end

function CompeteRankBtnItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function CompeteRankBtnItem:LoadCallBack()
    self.nodes = {
        "name","select","bg",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()
end

function CompeteRankBtnItem:InitUI()

end

function CompeteRankBtnItem:AddEvent()
    local function call_back()
        self.model:Brocast(CompeteEvent.CompeteRankBtnClick,self.data)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function CompeteRankBtnItem:SetData(data)
    self.data = data
    self.name.text = "No."..self.data.season.."Phase"
end

function CompeteRankBtnItem:SetSelect(isShow)
    if isShow then
        SetColor(self.name, 133, 132, 176, 255)
    else
        SetColor(self.name, 255, 255, 255, 255)
    end
    SetVisible(self.select,isShow)
end