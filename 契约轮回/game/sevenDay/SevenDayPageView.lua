---
--- Created by  Administrator
--- DateTime: 2019/3/11 15:31
---
SevenDayPageView = SevenDayPageView or class("SevenDayPageView", BaseCloneItem)
local this = SevenDayPageView


function SevenDayPageView:ctor(parent_node, parent_panel)
    self.model = SevenDayModel:GetInstance()
    self.events = {}
    self.items = {}
    SevenDayPageView.super.Load(self)

end

function SevenDayPageView:dctor()
    self.model:RemoveTabListener(self.events)
    for i, v in pairs(self.items) do
        v:destroy()
    end
    self.items = {}
end

function SevenDayPageView:LoadCallBack()
    self.nodes = 
    {
        "SevenDayLittleItem","Content","SevenDayBigItem",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function SevenDayPageView:InitUI()

end

function SevenDayPageView:AddEvent()

    self.events[#self.events + 1] = self.model:AddListener(SevenDayEvent.SevenDayItemClick, handler(self, self.SevenDayItemClick))
    self.events[#self.events + 1] = self.model:AddListener(SevenDayEvent.SevenDayInfo, handler(self, self.SevenDayInfo))
    self.events[#self.events + 1] = self.model:AddListener(SevenDayEvent.SevenDayReward, handler(self, self.SevenDayReward))
end

function SevenDayPageView:SetData(page)
    self.pageIndex = page
    self:InitItems()
end
function SevenDayPageView:InitItems()
    local index
    local len
    local db = Config.db_yylogin
    if self.pageIndex == 1  then
        index = 1
        len = #db/2
    elseif self.pageIndex == 2 then
        index = 8
        len = #db
    end
    for i = index, len,1 do
        if i == 7 or i == 14 then
            self.items[i]= SevenDayBigItem(self.SevenDayBigItem.gameObject,self.Content,"UI")
        else
            self.items[i]= SevenDayLittleItem(self.SevenDayLittleItem.gameObject,self.Content,"UI")
        end
        self.items[i]:SetData(db[i],i)
    end
end

function SevenDayPageView:UpdateItem()

end

function SevenDayPageView:SevenDayItemClick(index)
    self:SetSelect(index)
end

function SevenDayPageView:SetSelect(index)
    for i, v in pairs(self.items) do
        if  i == index then
            v:Select(true)
        else
            v:Select(false)
        end
    end
end

function SevenDayPageView:SelectNext()
    
end

function SevenDayPageView:SevenDayReward(data)
    local day = data.day
    if self.items[day] then
        self.items[day]:UpdateInfo()
    end
    
end

function SevenDayPageView:SevenDayInfo(data)
    for i, v in pairs( self.items) do
        v:UpdateInfo()
    end
end