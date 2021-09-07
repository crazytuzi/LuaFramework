-- @author 黄耀聪
-- @date 2016年7月22日

AuctionWindow = AuctionWindow or BaseClass(BaseWindow)

function AuctionWindow:__init(model)
    self.model = model
    self.name = "AuctionWindow"
    self.windowId = WindowConfig.WinID.auction_window

    self.resList = {
        {file = AssetConfig.strategy_window, type = AssetType.Main},
    }
    self.panelList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function AuctionWindow:__delete()
    self.OnHideEvent:Fire()
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
    end
    if self.model.operationPanel ~= nil then
        self.model.operationPanel:DeleteMe()
        self.model.operationPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    AuctionManager.Instance:send16705()
    self:AssetClearAll()
end

function AuctionWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.strategy_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    self.titleText = main:Find("Title/Text"):GetComponent(Text)
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.tabContainer = main:Find("TabListPanel")
    self.tabCloner = self.tabContainer:Find("TabButton").gameObject
    self.mainContainer = main

    self.titleText.text = TI18N("拍 卖")

    self.tabCloner:SetActive(false)
    self.closeBtn.onClick:AddListener(function() self.model:CloseWindow() end)
end

function AuctionWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function AuctionWindow:OnOpen()
    self:RemoveListeners()

    if self.panelList[1] == nil then
        self.panelList[1] = AuctionPanel.New(self.model, self.mainContainer.gameObject)
    end
    self.panelList[1]:Show(self.openArgs)
    self.openArgs = {}
end

function AuctionWindow:OnHide()
    self:RemoveListeners()
end

function AuctionWindow:RemoveListeners()
end


