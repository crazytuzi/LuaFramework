MarketDesignatedPanel = MarketDesignatedPanel or class("MarketDesignatedPanel", BaseItem)
local MarketDesignatedPanel = MarketDesignatedPanel

function MarketDesignatedPanel:ctor(parent_node, layer)
    self.abName = "market";
    self.assetName = "MarketDesignatedPanel"
    self.layer = "UI"

    self.parentPanel = parent_node;
    self.model = MarketModel:GetInstance()
    self.Events = {} --事件
    self.leftItems = {}
    self.rightItems = {}
    self.model.isOpenMarket = true
    MarketDesignatedPanel.super.Load(self);
end

function MarketDesignatedPanel:dctor()
    GlobalEvent:RemoveTabListener(self.Events)
    self.model.isOpenMarket = false
    for i, v in pairs(self.leftItems) do
        v:destroy()
        v = nil
    end
    self.leftItems = {}
    for i, v in pairs(self.rightItems) do
        v:destroy()
        v = nil
    end
    self.rightItems = {}
end
function MarketDesignatedPanel:Open()
    WindowPanel.Open(self)
end


function MarketDesignatedPanel:LoadCallBack()
    self.nodes =
    {
        "MarketDesignatedItem",
        "left/leftNull",
        "left/leftScrollView/Viewport/leftItemContent",
        "right/rightNull",
        "right/rightScrollView/Viewport/rightItemContent",
        "BuyMarketBuyPanel",
        "rightTipsParent",
        "BuyMarketBuyTowPanel"
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self:InitUI()
    self:AddEvent()

    MarketController:GetInstance():RequeseDealingInfo()
end

function MarketDesignatedPanel:InitUI()

end
function MarketDesignatedPanel:AddEvent()
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.MarketDesignatedDealing, handler(self, self.UpdateDealing))
   -- self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateGoodData, handler(self, self.UpdateGood))
   -- self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateTwoGoodData, handler(self, self.UpdateTwoGood))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.MarketDesignatedClickItem, handler(self, self.MarketDesignatedClickItem))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketUpBtn, handler(self, self.UpShelfMarketUpBtn))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.MarketDesignatedBuy, handler(self, self.MarketDesignatedBuy))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.MarketDesignatedRefuse, handler(self, self.MarketDesignatedRefuse))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketAlter, handler(self, self.UpShelfMarketAlter))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketRemove, handler(self, self.UpShelfMarketRemove))

end

function MarketDesignatedPanel:UpdateDealing(data)
    self.leftData = data.from_me
    self.rightData = data.to_me
    self:UpdateLeftItems(self.leftData)
    self:UpdateRightItems(self.rightData)

end

function MarketDesignatedPanel:UpdateLeftItems(items)
    if items == nil or items == {} or #items == 0 then
        SetVisible(self.leftNull,true)
        for i = 1, #self.leftItems do
            self.leftItems[i]:SetVisible(false)
        end
    else
      --  for i = 1, #items do
            self.leftItems = self.leftItems or {}

            for i = 1, #items do
                local buyItem =  self.leftItems[i]
                if  not buyItem then
                    buyItem = MarketDesignatedItem(self.MarketDesignatedItem.gameObject,self.leftItemContent,"UI")

                    self.leftItems[i] = buyItem
                else
                    buyItem:SetVisible(true)
                end
                buyItem:SetData(items[i],1)
            end
            for i = #items + 1,#self.leftItems do
                local buyItem = self.leftItems[i]
                buyItem:SetVisible(false)
            end

        end
   -- end
end
function MarketDesignatedPanel:UpdateRightItems(items)
    for i, v in pairs(self.rightItems) do
        v:destroy()
    end
    self.rightItems = {}
    if items == nil or items == {} or #items == 0 then
        SetVisible(self.rightNull,true)
        --for i = 1, #self.rightItems do
        --    self.rightItems[i]:SetVisible(false)
        --end
    else
    --    for i = 1, #items do
          --  self.rightItems = self.rightItems or {}
        for i, v in pairs(items) do
            local buyItem =  self.rightItems[i]
            if  not buyItem then
                buyItem = MarketDesignatedItem(self.MarketDesignatedItem.gameObject,self.rightItemContent,"UI")

                self.rightItems[i] = buyItem
                --else
                --    buyItem:SetVisible(true)
            end
            buyItem:SetData(v,2)
        end
            --for i = 1, #items do
            --    local buyItem =  self.rightItems[i]
            --    if  not buyItem then
            --        buyItem = MarketDesignatedItem(self.MarketDesignatedItem.gameObject,self.rightItemContent,"UI")
            --
            --        self.rightItems[i] = buyItem
            --    --else
            --    --    buyItem:SetVisible(true)
            --    end
            --    buyItem:SetData(items[i],2)
            --end
            --for i = #items + 1,#self.rightItems do
            --    local buyItem = self.rightItems[i]
            --    buyItem:SetVisible(false)
            --end

       -- end
    end
end


--物品详细信息
function MarketDesignatedPanel:UpdateGood(data)
    if self.itemType == 1 then
        self.buyPanel = BuyMarketBuyPanel(self.BuyMarketBuyPanel.gameObject,self.transform,"UI")
        self.buyPanel:UpdateInfo(data.item)
        self.buyPanel:SetItemData(data.item,2,true)
    else
        self.buyPanel = BuyMarketBuyPanel(self.BuyMarketBuyPanel.gameObject,self.rightTipsParent.transform,"UI")
        self.buyPanel:UpdateInfo(data.item)
        self.buyPanel:SetItemData(data.item,2,false)
    end
end


function MarketDesignatedPanel:UpdateTwoGood(data)
    if self.itemType == 1 then
        self.buyPanel = BuyMarketBuyTowPanel(self.BuyMarketBuyTowPanel.gameObject,self.transform,"UI")
        self.buyPanel:UpdateInfo(data.item)
        self.buyPanel:SetItemData(data.item,2,true)
    else
        self.buyPanel = BuyMarketBuyTowPanel(self.BuyMarketBuyTowPanel.gameObject,self.rightTipsParent.transform,"UI")
        self.buyPanel:UpdateInfo(data.item)
        self.buyPanel:SetItemData(data.item,2,false)
    end
end

function MarketDesignatedPanel:MarketDesignatedClickItem(type)
    self.itemType = type
    MarketController:GetInstance():RequeseGoodInfo(self.model.selectGoodItem.uid)
end

function MarketDesignatedPanel:UpShelfMarketUpBtn(type)
    GlobalEvent:Brocast(MarketEvent.OpenUpShelfTowPanel,index)
end





--修改
function MarketDesignatedPanel:UpShelfMarketAlter(data)
   -- self.buyPanel:destroy()
    for i, v in pairs(self.model.leftDealInfos) do
        if v.item.uid == data.uid then
            v.item.price = data.price
        end
    end
    self:UpdateLeftItems(self.model.leftDealInfos)
end
--下架
function MarketDesignatedPanel:UpShelfMarketRemove(data)
  --  self.buyPanel:destroy()
    for i, v in pairs(self.model.leftDealInfos) do
        if v.item.uid == data.uid then
            table.remove(self.model.leftDealInfos,i)
        end
    end
    self:UpdateLeftItems(self.model.leftDealInfos)
end


---购买
function MarketDesignatedPanel:MarketDesignatedBuy(data)
    --self.buyPanel:destroy()
    --for i, v in pairs(self.model.rightDealInfos) do
    --    if v.item.uid == data.uid then
    --        table.remove(self.model.rightDealInfos,i)
    --    end
    --end
    dump(self.model.rightDealInfos)
    self:UpdateRightItems(self.model.rightDealInfos)
end
--拒绝
function MarketDesignatedPanel:MarketDesignatedRefuse(data)
--    self.buyPanel:destroy()
--    for i, v in pairs(self.model.rightDealInfos) do
--        if v.item.uid == data.uid then
--            table.remove(self.model.rightDealInfos,i)
--        end
--    end
    dump(self.model.rightDealInfos)
    self:UpdateRightItems(self.model.rightDealInfos)
end






