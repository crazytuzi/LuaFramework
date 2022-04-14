---
--- Created by  Administrator
--- DateTime: 2019/8/30 17:28
---
BabyGoodsItem = BabyGoodsItem or class("BabyGoodsItem", BaseItem)
local this = BabyGoodsItem

function BabyGoodsItem:ctor(parent_node, parent_panel)

    self.abName = "baby"
    self.assetName = "BabyGoodsItem"
    self.layer = layer
    self.events = {}
    self.model = BabyModel:GetInstance()
    BabyGoodsItem.super.Load(self)
end

function BabyGoodsItem:dctor()
    if self.itemicon then
        self.itemicon:destroy()
    end
    GlobalEvent:RemoveTabListener(self.events)
end

function BabyGoodsItem:LoadCallBack()
    self.nodes = {
        "iconParent","addBtn",
    }
    self:GetChildren(self.nodes)
    SetVisible(self.addBtn,false)
    self:InitUI()
    self:AddEvent()
    if self.is_need_setData then
        self:SetData(self.data,self.type,self.itemNum)
    end
end

function BabyGoodsItem:InitUI()

end

function BabyGoodsItem:AddEvent()
    local function call_back()
        Notify.ShowText("Need to jump to the mall, no id")
    end
    AddClickEvent(self.addBtn.gameObject,call_back)
    
    local function call_back(id) --物品更新
        if id == self.data then
            self:CreateIcon()
        end
    end

    self.events[#self.events + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
end

function BabyGoodsItem:SetData(data,type,num)
    self.data = data
    self.type = type
    self.itemNum = num
    if not self.data then
        return
    end
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    --local num = BagModel:GetInstance():GetItemNumByItemID(self.data) or 0
    --SetVisible(self.addBtn,num <= 0)
    self:CreateIcon()
end

function BabyGoodsItem:CreateIcon()
    local num = BagModel:GetInstance():GetItemNumByItemID(self.data);
   -- SetVisible(self.addBtn,num < self.itemNum)
    local param = {}
    param["item_id"] = self.data
    local color = "00FF1A"
    if num < self.itemNum then
        color = "FF1200"
    end
    param["num"] = string.format("<color=#%s>%s/%s</color>",color,num,self.itemNum)
    param["model"] = BagModel
    param["can_click"] = true
    param["show_num"] = true
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end
    self.itemicon:SetIcon(param)
end
