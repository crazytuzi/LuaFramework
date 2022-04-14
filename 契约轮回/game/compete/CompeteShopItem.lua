---
--- Created by  Administrator
--- DateTime: 2019/11/22 10:19
---
CompeteShopItem = CompeteShopItem or class("CompeteShopItem", BaseCloneItem)
local this = CompeteShopItem

function CompeteShopItem:ctor(obj, parent_node, parent_panel)
    CompeteShopItem.super.Load(self)
    self.model = CompeteModel:GetInstance()
end

function CompeteShopItem:dctor()
    if self.itemicon then
        self.itemicon:destroy()
    end

    if self.events then
        GlobalEvent:RemoveTabListener(self.events)
        self.events = nil
    end
end

function CompeteShopItem:LoadCallBack()
    self.nodes = {
        "name","moneyObj/moneyIcon","moneyObj/moneyText","buyBtn","iconParent","count",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.moneyIcon = GetImage(self.moneyIcon)
    self.moneyText = GetText(self.moneyText)
    self.count = GetText(self.count)
    self:InitUI()
    self:AddEvent()
end

function CompeteShopItem:InitUI()

end

function CompeteShopItem:AddEvent()
    self.events = self.events or {}
    local function call_back()
        ShopController:GetInstance():RequestBuyGoods(self.data.id,1)
    end
    AddClickEvent(self.buyBtn.gameObject,call_back)

    local function call_back()
        self:UpdateCount()
    end
    self.events[#self.events+1] = GlobalEvent:AddListener(ShopEvent.HandleSingleBought, call_back)
    self.events[#self.events+1] = GlobalEvent:AddListener(ShopEvent.HandelShopBoughtList, call_back)
end

function CompeteShopItem:SetData(data)
    self.data = data


    local priceTab = String2Table(self.data.price)
    if  not table.isempty(priceTab) then
        local moneyId = priceTab[1]
        local moneyNum = priceTab[2]
        local iconName = Config.db_item[moneyId].icon
        GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
        --logError(moneyId,moneyNum)
        local curMoney =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.CompeteScore)
        local color = "eb0000"
        if curMoney > moneyNum then
            color = "6CFE00"
        end
       -- self.moneyText.text = string.format("<color=#%s>%s</color>",color,moneyNum)
        self.moneyText.text = moneyNum
    end
    local itemTab = String2Table(self.data.item)
    if  not table.isempty(itemTab) then
        local itemID = itemTab[1]
        local itemNum = itemTab[2]
        local bind = itemTab[3] or 1
        local itemCfg = Config.db_item[itemID]
        if not itemCfg then
            logError("itemID:"..itemID.." mallId :"..self.data.id)
            return
        end
        local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(itemCfg.color), itemCfg.name)
        self.name.text = str
        self:CreateIcon(itemID,itemNum,bind)
    end

    self:UpdateCount()
    --local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.BabyScore)
    --self.moneyText.text = money
end

function CompeteShopItem:CreateIcon(itemID,itemNum,bind)
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end
    local param = {}
    param["model"] = self.model
    param["item_id"] = itemID
    param["num"] = itemNum
    param["bind"] = bind
    param["can_click"] = true
    --  param["size"] = {x = 72,y = 72}

    self.itemicon:SetIcon(param)
end

function CompeteShopItem:UpdateCount()
    local num = ShopModel.GetInstance():GetGoodsBoRecordById(self.data.id) or 0
    self.count.text = string.format("Redeem: %s/%s", self.data.limit_num-num,self.data.limit_num)
end