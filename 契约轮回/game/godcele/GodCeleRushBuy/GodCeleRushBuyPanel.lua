---
--- Created by  Administrator
--- DateTime: 2019/4/22 20:07
---
GodCeleRushBuyPanel = GodCeleRushBuyPanel or class("GodCeleRushBuyPanel", BaseItem)
local this = GodCeleRushBuyPanel

function GodCeleRushBuyPanel:ctor(parent_node, parent_panel, actID)
    self.abName = "sevenDayActive"
    self.assetName = "GodCeleRushBuyPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.rewardItems = {}
    self.isActOver = false
    -- self.items = {}
    self.model = GodCelebrationModel:GetInstance()
    self.actID = actID
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    -- dump(self.data)
    GodCeleRushBuyPanel.super.Load(self)
end

function GodCeleRushBuyPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for _, item in pairs(self.rewardItems) do
        item:destroy()
    end
    self.rewardItems = {}
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function GodCeleRushBuyPanel:LoadCallBack()
    if self.model.isFirstOpen_buy == true then
        self.model.isFirstOpen_buy = false
        self.model.redPoints[self.actID] = false
        self.model:UpdateRedPoint()
    end
    self.nodes = {
        "ScrollView/Viewport/Content", "rTime", "GodCeleRushBuyItem", "ScrollView/Viewport"
    }
    self:GetChildren(self.nodes)
    self.rTime = GetText(self.rTime)
    self:InitUI()
    self:AddEvent()
    --print2(self.actID)
    ShopController:GetInstance():RequestActItems(self.actID)
    --  ShopController:GetInstance():RequestSlotGoods()

    self.schedules = GlobalSchedule:Start(handler(self, self.CountDown), 0.2, -1);


end

function GodCeleRushBuyPanel:InitUI()
    --  local itemTab = self.model:GetRushBuyShopList(self.actID)
    -- self:UpdateItems(itemTab)
    self:SetMask()

end

function GodCeleRushBuyPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function GodCeleRushBuyPanel:AddEvent()
    self.events[#self.events + 1] = GlobalEvent:AddListener(ShopEvent.HandelShopBoughtList, handler(self, self.UpdateShopBoughtList))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ShopEvent.HandleSingleBought, handler(self, self.UpdateShopItemLimit))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ShopEvent.SuccessToBuyGoodsInShop, handler(self, self.SuccessToBuyGoodsInShop))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ShopEvent.HandleActItems, handler(self, self.HandleActItems))

end

function GodCeleRushBuyPanel:CountDown()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%d";
    timeTab = TimeManager:GetLastTimeData(os.time(), self.openData.act_etime);
    if table.isempty(timeTab) then
        -- Notify.ShowText("活动结束了");
        -- self.rtime.text = "活动剩余：已结束"
        --self.isActOver = true
        self.rTime.text = string.format("Event countdown: <color=#%s>%s</color>", "ff0000", "Ended")
        GlobalSchedule.StopFun(self.schedules);
    else
        --dump(timeTab)
        if timeTab.hour then
            timestr = timestr .. string.format(formatTime, timeTab.hour) .. "hr";
        end
        if timeTab.min then
            timestr = timestr .. string.format(formatTime, timeTab.min) .. "min";
        end
        if timeTab.sec then
            timestr = timestr .. string.format(formatTime, timeTab.sec) .. "sec"
        end
        local color = "27C31F"
        if not timeTab.day then
            color = "ff0000"
        end
        self.rTime.text = string.format("Event countdown: <color=#%s>%s</color>", color, timestr)
        -- self.rtime.text = "活动剩余：" .. timestr;
    end

end

function GodCeleRushBuyPanel:UpdateItems(items)
    local tab = items
    table.sort(tab, function(a, b)
        return a.order < b.order
    end)
    self.rewardItems = self.rewardItems or {}
    for i = 1, #tab do
        local item = self.rewardItems[i]
        if not item then
            item = GodCeleRushBuyItem(self.GodCeleRushBuyItem.gameObject, self.Content, "UI")
            self.rewardItems[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(tab[i], self.actID, self.StencilId)
    end
    for i = #tab + 1, #self.rewardItems do
        local Item = self.rewardItems[i]
        Item:SetVisible(false)
    end
end

function GodCeleRushBuyPanel:UpdateShopBoughtList()
    --  print2("gggggggggggggggg")
    --  dump(ShopModel:GetInstance().goodsBoughtList)
    local retTab = ShopModel:GetInstance().goodsBoughtList
    --  local itemTab = self.model:GetRushBuyShopList(self.actID)
    for i = 1, #self.itemsCfg do
        if retTab[self.itemsCfg[i].id] then
            self.itemsCfg[i].times = retTab[self.itemsCfg[i].id]
        end
    end
    self:UpdateItems(self.itemsCfg)


end

function GodCeleRushBuyPanel:UpdateShopItemLimit()
    --  print2("fffffffffffffffffffff")
    --  dump(ShopModel:GetInstance().goodsBoughtList)
end

function GodCeleRushBuyPanel:SuccessToBuyGoodsInShop()
    -- print2("购买成功")
    --  Notify.ShowText("购买成功")
end

function GodCeleRushBuyPanel:HandleActItems(data)
    --  print2("活动商品")
    -- dump(data)
    local tab = {}
    for i = 1, #data.items do
        --local item = data.items[i]
        data.items[i]["times"] = 0
    end
    self.itemsCfg = data.items
    self:UpdateItems(data.items)
    ShopController:GetInstance():RequestSlotGoods()
end

