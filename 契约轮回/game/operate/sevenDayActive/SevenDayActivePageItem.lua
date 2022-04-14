---
--- Created by  Administrator
--- DateTime: 2019/4/15 14:51
---
SevenDayActivePageItem = SevenDayActivePageItem or class("SevenDayActivePageItem", BaseCloneItem)
local this = SevenDayActivePageItem

function SevenDayActivePageItem:ctor(obj, parent_node, parent_panel)
    SevenDayActivePageItem.super.Load(self)
    self.events = {}
end

function SevenDayActivePageItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)

    if self.redPoint then
        self.redPoint:destroy()
        self.redPoint = nil
    end

end

function SevenDayActivePageItem:LoadCallBack()
    self.nodes = {
        "select","name","bg"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()

    --self.redPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    --self.redPoint:SetPosition(29, 24)
    --  self.rankBtn_red:SetRedDotParam(true)
end

function SevenDayActivePageItem:SetRedPoint(isShow)
    if self.redPoint then
        self.redPoint:SetRedDotParam(isShow)
    else
        self.redPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.redPoint:SetPosition(29, 24)
        self.redPoint:SetRedDotParam(isShow)
    end
end

function SevenDayActivePageItem:InitUI()

end

function SevenDayActivePageItem:AddEvent()
    
    local function call_back()
        GlobalEvent:Brocast(SevenDayActiveEvent.SevenDayActiveClickPageItem, self.data.id,self.actId)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function SevenDayActivePageItem:SetData(data,actId)
    self.data = data
    self.actId = actId
  --  print2(self.actId,"-------1---------")
   -- dump(data)
    local cfg = OperateModel:GetInstance():GetConfig(self.actId)
    self.name.text = cfg.name
end

function SevenDayActivePageItem:SetSeletc(show)
    SetVisible(self.select,show)
end
