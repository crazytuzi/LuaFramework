---
--- Created by  Administrator
--- DateTime: 2019/6/11 16:15
---
MarryFriendFlowerItem = MarryFriendFlowerItem or class("MarryFriendFlowerItem", BaseCloneItem)
local this = MarryFriendFlowerItem

function MarryFriendFlowerItem:ctor(obj, parent_node, parent_panel)
    MarryFriendFlowerItem.super.Load(self)
    self.events = {}
    self.model = MarryModel:GetInstance()
end

function MarryFriendFlowerItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function MarryFriendFlowerItem:LoadCallBack()
    self.nodes = {
        "flwer","num"
    }
    self:GetChildren(self.nodes)
    self.num = GetText(self.num)
    self.iconImg = GetImage(self.flwer)
    self:InitUI()
    self:AddEvent()
end

function MarryFriendFlowerItem:InitUI()

end

function MarryFriendFlowerItem:AddEvent()

end

function MarryFriendFlowerItem:SetData(data)
    self.data = data
    local num = self.model:GetFlowerNum(self.data.id)
    local itemCfg = Config.db_item[self.data.id]
    if itemCfg then
        local  icon = itemCfg.icon
        GoodIconUtil.GetInstance():CreateIcon(self, self.iconImg, icon, true)
    end
    self.num.text = num

end