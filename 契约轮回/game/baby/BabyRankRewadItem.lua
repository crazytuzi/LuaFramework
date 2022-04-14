---
--- Created by  Administrator
--- DateTime: 2019/11/11 15:40
---
BabyRankRewadItem = BabyRankRewadItem or class("BabyRankRewadItem", BaseCloneItem)
local this = BabyRankRewadItem

function BabyRankRewadItem:ctor(obj, parent_node, parent_panel)
    BabyRankRewadItem.super.Load(self)
    self.events = {}
    self.itemicon = {}
    self.model = ArenaModel:GetInstance()
end

function BabyRankRewadItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.itemicon then
        for i, v in pairs(self.itemicon) do
            v:destroy()
        end
        self.itemicon = {}
    end

end

function BabyRankRewadItem:LoadCallBack()
    self.nodes = {
        "des","iconParent",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self:InitUI()
    self:AddEvent()
end

function BabyRankRewadItem:InitUI()

end

function BabyRankRewadItem:AddEvent()

end

function BabyRankRewadItem:SetData(data)
    self.data = data
    local des = string.format("No.%s reward",self.data.rank_min)
    if self.data.rank_min ~= self.data.rank_max then
        des = string.format("Top %s-%s reward",self.data.rank_min,self.data.rank_max)
    end
    self.des.text = des
    self:CreateIcon(String2Table(self.data.gain))
end

function BabyRankRewadItem:CreateIcon(tab)
    for i = 1, #tab do
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = tab[i][1]
        param["num"] = tab[i][2]
        param["can_click"] = true
        param["bind"] = tab[i][3]
        -- param["size"] = {x=70,y=70}
        --  param["size"] = {x = 72,y = 72}
        self.itemicon[i]:SetIcon(param)
    end
end