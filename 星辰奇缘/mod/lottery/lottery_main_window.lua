-- ---------------------------------
-- 一闷夺宝主界面
-- hosr
-- ---------------------------------
LotteryMainWindow = LotteryMainWindow or BaseClass(BaseWindow)

function LotteryMainWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.lottery_main
    self.cacheMode = CacheMode.Destroy
    -- self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.lottery_main, type = AssetType.Main},
        {file = AssetConfig.lottery_res, type = AssetType.Dep},
        {file = AssetConfig.button1, type = AssetType.Dep},
    }

    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.currentTabIndex = 1
    self.recordPanelTab = 1
    self.showPanel = nil
    self.recordPanel = nil
    self.exchangePanel = nil

    self.listener = function() end
end

function LotteryMainWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.lottery_main_update, self.listener)

    if self.showPanel ~= nil then
        self.showPanel:DeleteMe()
        self.showPanel = nil
    end

    if self.recordPanel ~= nil then
        self.recordPanel:DeleteMe()
        self.recordPanel = nil
    end

    if self.exchangePanel ~= nil then
        self.exchangePanel:DeleteMe()
        self.exchangePanel = nil
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function LotteryMainWindow:Close()
    self.model:CloseMain()
end

function LotteryMainWindow:OnHide()
end

function LotteryMainWindow:OnOpen()
    if self.openArgs ~= nil then
        self.tabGroup:ChangeTab(self.openArgs[1])
    else
        self.tabGroup:ChangeTab(self.currentTabIndex)
    end
end

function LotteryMainWindow:OnSwitchTab(index, recordTab)
    self.recordPanelTab = recordTab
    self.tabGroup:ChangeTab(index)
end

function LotteryMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.lottery_main))
    self.gameObject.name = "LotteryMainWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.main = self.transform:Find("Main").gameObject
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.tabGroupObj = self.transform:Find("Main/TabButtonGroup").gameObject
    local setting = {
        notAutoSelect = true,
        noCheckRepeat = false,
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:TabChange(index) end, setting)

    EventMgr.Instance:AddListener(event_name.lottery_main_update, self.listener)

    self:OnOpen()
end

function LotteryMainWindow:TabChange(index)
    self.currentTabIndex = index
    if index == 1 then
        self:ShowShowPanel()
    elseif index == 2 then
        self:ShowRecordPanel()
    elseif index == 3 then
        self:ShowExchangePanel()
    end
end

-- 打开抢购页
function LotteryMainWindow:ShowRecordPanel()
    if self.showPanel ~= nil then
        self.showPanel:Hiden()
    end
    if self.exchangePanel ~= nil then
        self.exchangePanel:Hiden()
    end
    if self.recordPanel == nil then
        self.recordPanel = LotteryRecordPanel.New(self)
    end
    self.recordPanel:Show(self.recordPanelTab)
end

-- 打开记录页
function LotteryMainWindow:ShowShowPanel()
    if self.recordPanel ~= nil then
        self.recordPanel:Hiden()
    end
    if self.exchangePanel ~= nil then
        self.exchangePanel:Hiden()
    end
    if self.showPanel == nil then
        self.showPanel = LotteryShowPanel.New(self)
    end
    self.showPanel:Show(1)
end

--打开兑换页
function LotteryMainWindow:ShowExchangePanel()
    if self.showPanel ~= nil then
        self.showPanel:Hiden()
    end
    if self.recordPanel ~= nil then
        self.recordPanel:Hiden()
    end
    if self.exchangePanel == nil then
        self.exchangePanel = LotteryExchangePanel.New(self)
    end
    self.exchangePanel:Show()
end