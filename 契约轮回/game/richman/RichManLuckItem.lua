---
--- Created by  Administrator
--- DateTime: 2020/4/16 15:27
---
RichManLuckItem = RichManLuckItem or class("RichManLuckItem", BaseCloneItem)
local this = RichManLuckItem

function RichManLuckItem:ctor(obj, parent_node, parent_panel)
    RichManLuckItem.super.Load(self)
    self.events = {}
end

function RichManLuckItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.itemicon then
        self.itemicon:destroy()
    end
    if  self.eft then
        self.eft:destroy()
    end
end

function RichManLuckItem:LoadCallBack()
    self.nodes = {
        "iconParent","effParent"
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self.eft = UIEffect(self.effParent, 45001, false, self.layer)
    self.eft:SetConfig({ is_loop = true })
    self.eft.is_hide_clean = false
    self.eft:SetOrderIndex(423)
    SetVisible(self.effParent,false)
end

function RichManLuckItem:InitUI()

end

function RichManLuckItem:AddEvent()

end

function RichManLuckItem:SetData(data)
    self.data = data
    self:CreateIcon()
end

function RichManLuckItem:CreateIcon()
    local rewardTab = String2Table(self.data.reward)
    if rewardTab then
        self.itemId = rewardTab[1][1]
        local num = rewardTab[1][2]
        local bind = rewardTab[1][3]
        local item =  self.itemicon
        if not item then
            item = GoodsIconSettorTwo(self.iconParent)
            self.itemicon = item
        end
        --if self.itemicon[i] == nil then
        --    self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        --end
        local param = {}
        param["model"] = BagModel
        param["item_id"] = self.itemId
        param["num"] = num
        param["bind"] = bind
        param["can_click"] = true
        param["size"] = {x = 78,y = 78}
        self.itemicon:SetIcon(param)
    end
end

function RichManLuckItem:ShowEff(isShow)
    SetVisible(self.effParent,isShow)
end