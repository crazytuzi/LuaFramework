-- @Author: lwj
-- @Date:   2018-11-19 14:10:05
-- @Last Modified time: 2018-11-19 14:10:09

FlashSalePanel = FlashSalePanel or class("FlashSalePanel", BaseItem)
local FlashSalePanel = FlashSalePanel

function FlashSalePanel:ctor(parent_node, layer)
    self.abName = "shop"
    self.assetName = "FlashSalePanel"
    self.layer = layer

    self.saleItemList = {}
    self.model = ShopModel.GetInstance()
    self.is_loading_item = false

    BaseItem.Load(self)
end

function FlashSalePanel:dctor()
    self:CleanSaleItem()
    self.model:Brocast(ShopEvent.ShowShopPanelContains)
    if self.removeflashsaleitemevent_id then
        GlobalEvent:RemoveListener(self.removeflashsaleitemevent_id)
        self.removeflashsaleitemevent_id = nil
    end

    if self.updateflashsaleitemevent_id then
        GlobalEvent:RemoveListener(self.updateflashsaleitemevent_id)
        self.updateflashsaleitemevent_id = nil
    end
end

function FlashSalePanel:LoadCallBack()
    self.nodes = {
        "GoodsScroll/Viewport/Content",
    }
    self:GetChildren(self.nodes)
    self:LoadFlashSale()
    self:AddEvent()
end

function FlashSalePanel:AddEvent()
    self.removeflashsaleitemevent_id = GlobalEvent:AddListener(ShopEvent.FlashSaleItemDestroy, handler(self, self.HandleFlashItemDestroy))
    self.updateflashsaleitemevent_id = GlobalEvent:AddListener(ShopEvent.UpdateFlashSale, handler(self, self.UpdateFlashSaleItem))
end

function FlashSalePanel:LoadFlashSale()
    if not self.is_loading_item then
        self.is_loading_item = true
        local itemList = self.model:GetFlashSaleList()
        local item = nil
        local data = nil
        local len = table.nums(itemList)
        if len < 5 then
            len = 5
        end
        for i = 1, len do
            item = FlashSaleItem(self.Content, "UI")
            data = itemList[i]
            item:SetData(data)
            table.insert(self.saleItemList, item)
        end
        self.is_loading_item = false
    end
end

function FlashSalePanel:UpdateFlashSaleItem()
    self:CleanSaleItem()
    self:LoadFlashSale()
end

function FlashSalePanel:HandleFlashItemDestroy(item)
    for i, v in pairs(self.saleItemList) do
        if v.data.id == item.data.id then
            table.removebyvalue(self.saleItemList, v)
        end
    end
end

function FlashSalePanel:CleanSaleItem()
    if table.nums(self.saleItemList) > 0 then
        for i, v in pairs(self.saleItemList) do
            v:destroy()
        end
        self.saleItemList = {}
    end
end