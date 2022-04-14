---
--- Created by  Administrator
--- DateTime: 2019/7/15 10:37
---
WeddingShopItem = WeddingShopItem or class("WeddingShopItem", BaseCloneItem)
local this = WeddingShopItem

function WeddingShopItem:ctor(obj, parent_node, parent_panel)
    WeddingShopItem.super.Load(self)
    self.events = {}
    self.model = MarryModel:GetInstance()
end

function WeddingShopItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.itemicon then
        self.itemicon:destroy()
    end
end

function WeddingShopItem:LoadCallBack()
    self.nodes = {
        "iconParent","priIcon","price","bg","name","select",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.price = GetText(self.price)
    self.priIcon = GetImage(self.priIcon)
    self:InitUI()
    self:AddEvent()
end

function WeddingShopItem:InitUI()

end

function WeddingShopItem:AddEvent()
    
    local function call_back()
        self.model:Brocast(MarryEvent.WeddingShopClick,self.data.id)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function WeddingShopItem:SetData(data)
    self.data = data
    self:SetInfo()
end

function WeddingShopItem:SetInfo()
    local itemTab = String2Table(self.data.item)
    local itemId = itemTab[1]
    local num = itemTab[2]
    local bind = itemTab[3]
    self:CreateIcon(itemId,num,bind)
    local itemCfg = Config.db_item[itemId]
    local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(itemCfg.color), itemCfg.name)
    self.name.text = str

    local priceTab = String2Table(self.data.price)
    local prcId = priceTab[1]
    local price = priceTab[2]
    self.price.text = price
    GoodIconUtil:CreateIcon(self, self.priIcon, prcId, true)


end

function WeddingShopItem:SetShow(show)
    SetVisible(self.select,show)
end

function WeddingShopItem:CreateIcon(itemId,num,bind)
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end
    local param = {}
    param["model"] = self.model
    param["item_id"] = itemId
    param["num"] = num
    param["bind"] = bind
    param["can_click"] = true
    --  param["size"] = {x = 72,y = 72}

    self.itemicon:SetIcon(param)
end