MarketPanel = MarketPanel or class("MarketPanel", WindowPanel)
local MarketPanel = MarketPanel

function MarketPanel:ctor()
    self.abName = "market"
    self.assetName = "MarketPanel"
    self.image_ab = "market_image";
    self.layer = "UI"
    self.events = {}
    self.panel_type = 2
    self.model = MarketModel:GetInstance()
    self.show_sidebar = true        --是否显示侧边栏
    --self.is_show_money=true
    if self.show_sidebar then
        -- 侧边栏配置
        self.sidebar_data = {
            { text = ConfigLanguage.Market.Market, id = 1 },
            { text = ConfigLanguage.Market.Shelf, id = 2 },
            { text = ConfigLanguage.Market.Designation, id = 3 },
            { text = ConfigLanguage.Market.Record, id = 4 },
        }
    end
    self:Reset()
end

function MarketPanel:Reset()

end

function MarketPanel:dctor()
    self.model:RemoveTabListener(self.events)
    self.model = nil
    if self.currentView then
        self.currentView:destroy();
    end

end

function MarketPanel:Open()
    WindowPanel.Open(self)
end

function MarketPanel:LoadCallBack()

    self:SetTileTextImage("market_image", "market_title_1");
    self:UpdateRedPoint()
end

function MarketPanel:OpenCallBack()
    self.events[#self.events + 1] = self.model:AddListener(MarketEvent.UpdateRedPoint, handler(self, self.UpdateRedPoint))
end

function MarketPanel:CloseCallBack()

end

function MarketPanel:UpdateRedPoint()
    self:SetIndexRedDotParam(3,self.model.redPoints[1])
end

function MarketPanel:SwitchCallBack(index)
    if self.currentView then
        self.currentView:destroy();
    end

    self.currentView = nil
    if index == 1 then
        self.currentView = BuyMarketPanel(self.transform, "UI");
        self:PopUpChild(self.currentView)

    elseif index == 2 then
        self.currentView = UpShelfMaketPanel(self.transform, "UI");
        self:PopUpChild(self.currentView)

    elseif index == 3 then
        self.currentView = MarketDesignatedPanel(self.transform, "UI");
        self:PopUpChild(self.currentView)
    elseif index == 4 then
        self.currentView = MarketRecordPanel(self.transform, "UI");
        self:PopUpChild(self.currentView)
    end
    self.selectedIndex = index

    end