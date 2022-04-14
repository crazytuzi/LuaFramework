-- @Author: lwj
-- @Date:   2019-09-06 20:02:47 
-- @Last Modified time: 2019-09-06 20:02:49

GodCelePageItem = GodCelePageItem or class("GodCelePageItem", BaseCloneItem)
local GodCelePageItem = GodCelePageItem

function GodCelePageItem:ctor(parent_node, layer)
    GodCelePageItem.super.Load(self)
end

function GodCelePageItem:dctor()
    --GlobalEvent:RemoveTabListener(self.events)

    if self.redPoint then
        self.redPoint:destroy()
        self.redPoint = nil
    end

end

function GodCelePageItem:LoadCallBack()
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

function GodCelePageItem:SetRedPoint(isShow)
    if self.redPoint then
        self.redPoint:SetRedDotParam(isShow)
    else
        self.redPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.redPoint:SetPosition(29, 24)
        self.redPoint:SetRedDotParam(isShow)
    end
end

function GodCelePageItem:InitUI()

end

function GodCelePageItem:AddEvent()

    local function call_back()
        GlobalEvent:Brocast(GodCeleEvent.SevenDayActiveClickPageItem, self.data.id,self.actId)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function GodCelePageItem:SetData(data,actId)
    self.data = data
    self.actId = actId
    --  print2(self.actId,"-------1---------")
    -- dump(data)
    local cfg = OperateModel:GetInstance():GetConfig(self.actId)
    self.name.text = cfg.name
end

function GodCelePageItem:SetSeletc(show)
    SetVisible(self.select,show)
end