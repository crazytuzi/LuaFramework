---
--- Created by  Administrator
--- DateTime: 2020/6/3 14:59
---
LuckyWheelItem = LuckyWheelItem or class("LuckyWheelItem", BaseCloneItem)
local this = LuckyWheelItem

function LuckyWheelItem:ctor(obj, parent_node, parent_panel)
    LuckyWheelItem.super.Load(self)
    self.events = {}
    self.model = LuckyWheelModel:GetInstance()
end

function LuckyWheelItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function LuckyWheelItem:LoadCallBack()
    self.nodes = {
        "select","iconPanent/icon","iconPanent/nums"
    }
    self:GetChildren(self.nodes)
   -- SetVisible(self.select,false)
    self.nums = GetText(self.nums)
    self.icon = GetImage(self.icon)

    self:InitUI()
    self:AddEvent()
end

function LuckyWheelItem:InitUI()

end

function LuckyWheelItem:AddEvent()

end

function LuckyWheelItem:SetData(data,index)
    self.index = index
    self.data = data
    self.nums.text = self.data[2]
    local iconName = self.model:GetImageName(self.index)
    lua_resMgr:SetImageTexture(self, self.icon,"luckywheel_image",iconName,false)
    if not self.isNeedSetPos then
        self.isNeedSetPos = true
        local angle = GetTurnTableAngle(self.index, self.model.maxRoundNum)
        SetRotate(self.select, 0, 0, angle)

        local l_x, l_y = GetTurnTablePos(self.index, self.model.maxRoundNum, 118)
        local x, y = self:GetPosition()
        SetLocalPosition(self.select, l_x - x, l_y - y)
    end

    --local lx,ly = GetTurnTablePos(self.index, self.model.maxRoundNum, -59)
    --SetLocalPosition(self.select.transform,lx,ly)

end

function LuckyWheelItem:SetPosition()
    
end

function LuckyWheelItem:SetShow(isShow)
    SetVisible(self.select,isShow)
end