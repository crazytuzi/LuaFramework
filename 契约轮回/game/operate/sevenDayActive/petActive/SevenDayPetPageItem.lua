---
--- Created by  Administrator
--- DateTime: 2019/8/23 10:07
---
SevenDayPetPageItem = SevenDayPetPageItem or class("SevenDayPetPageItem", BaseCloneItem)
local this = SevenDayPetPageItem

function SevenDayPetPageItem:ctor(obj, parent_node, parent_panel)
    SevenDayPetPageItem.super.Load(self)
    self.events = {}
end

function SevenDayPetPageItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.redPoint then
        self.redPoint:destroy()
        self.redPoint = nil
    end
end

function SevenDayPetPageItem:LoadCallBack()
    self.nodes = {
        "select","name","bg"
    }
    self:GetChildren(self.nodes)
    self.nameLine = self.name:GetComponent('Outline')
    self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()
end

function SevenDayPetPageItem:InitUI()

end

function SevenDayPetPageItem:AddEvent()
    local function call_back()
        GlobalEvent:Brocast(SevenDayActiveEvent.SevenDayPetClickPageItem, self.data.id,self.actId)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function SevenDayPetPageItem:SetData(data,actId)
    self.data = data
    self.actId = actId
    local cfg = OperateModel:GetInstance():GetConfig(self.actId)
    self.name.text = cfg.name
end

function SevenDayPetPageItem:SetSeletc(show)
    SetVisible(self.select,show)
    local r,g,b,a = 41,103,156,255
    if show then
        r,g,b,a = 242,158,84,255
      --  SetOutLineColor(self.nameLine, r, g, b, a)
    end
    SetOutLineColor(self.nameLine, r, g, b, a)
end

function SevenDayPetPageItem:SetRedPoint(isShow)
    if self.redPoint then
        self.redPoint:SetRedDotParam(isShow)
    else
        self.redPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.redPoint:SetPosition(82, 20)
        self.redPoint:SetRedDotParam(isShow)
    end
end