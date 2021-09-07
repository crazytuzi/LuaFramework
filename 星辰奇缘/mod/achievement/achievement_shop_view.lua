AchievementShopView = AchievementShopView or BaseClass(BaseWindow)

function AchievementShopView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.achievementshopwindow
    self.mgr = ShopManager.Instance

    self.resList = {
        {file = AssetConfig.achievementshopwindow, type = AssetType.Main}
        ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
    }

    self.subPanelList = {}

    self.selectObj = nil
    self.selectedInfo = nil
    self.selectNum = 0

    self.lastIndex = 1

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function AchievementShopView:__delete()
    self.OnHideEvent:Fire()

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.subPanelList ~= nil then
        for k,v in pairs(self.subPanelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.subPanelList = nil
    end
    self.selectObj = nil
    self.selectedInfo = nil
    self.selectNum = 0
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()

    self.model.selectItem = nil
    self.model.selectObj = nil
    self.model.selectedInfo = nil
    self.model.selectNum = nil
    self.model.infoCurrencyType = nil
    self.model.uniPrice = nil
end

function AchievementShopView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.achievementshopwindow))
    self.gameObject.name = "AchievementShopView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform
    local model = self.model

    self.mainPanel = t:Find("Main")
    self.tabGroupContainer = self.mainPanel:Find("SideTabButtonGroup")
    self.tabCloner = self.mainPanel:Find("Button").gameObject
    self.closeBtn = self.mainPanel:Find("CloseButton"):GetComponent(Button)

    self.setting = {
        noCheckRepeat = true,
        notAutoSelect = true,
        perWidth = 46,
        perHeight = 100,
        isVertical = true
    }

    self.closeBtn.onClick:AddListener(function() self:OnClose() end)

    local obj = nil
    local rect = nil
    self.tabList = {}
    for k,v in ipairs(model.dataTypeList) do
        table.insert(self.tabList, {index = k, order = v.order, name = v.name})
    end
    table.sort(self.tabList, function(a,b) return a.order < b.order end)
    for i,v in ipairs(self.tabList) do
        obj = GameObject.Instantiate(self.tabCloner)
        obj.name = tostring(i)
        obj.transform:SetParent(self.tabGroupContainer)
        obj.transform.localScale = Vector3.one
        obj.transform.localPosition = Vector3.zero
        rect = obj:GetComponent(RectTransform)
        rect.anchoredPosition = Vector2(0, (1 - i) * self.setting.perHeight)
    end

    self.tabGroup = TabGroup.New(self.tabGroupContainer.gameObject, function(index) self:ChangeTab(index) end, self.setting)
    for i,v in ipairs(self.tabList) do
        self.tabGroup.buttonTab[i].text.text = v.name
    end
    self.tabCloner:SetActive(false)

    self.tabGroup.gameObject:SetActive(false)
    self.OnOpenEvent:Fire()
end

function AchievementShopView:ChangeTab(index)
    local panel = nil
    local currentIndex = nil
    if self.lastIndex ~= nil then
        currentIndex = self.tabList[self.lastIndex].index
        panel = self.subPanelList[currentIndex]
    end
    if panel ~= nil then
        panel:Hiden()
    end
    currentIndex = self.tabList[index].index
    panel = self.subPanelList[currentIndex]

    if panel == nil then
        if currentIndex == 1 then
            self.subPanelList[currentIndex] = AchievementShopPanel.New(self.model, self.mainPanel, currentIndex)
        elseif currentIndex == 2 then
            self.subPanelList[currentIndex] = ShopPanel.New(self.model, self.mainPanel, currentIndex)
        elseif currentIndex == 3 then
            self.subPanelList[currentIndex] = ShopChargePanel.New(self.model, self.mainPanel, currentIndex)
        end
        panel = self.subPanelList[currentIndex]
    end

    self.lastIndex = currentIndex
    self.model.shop_currentMain = currentIndex
    panel:Show()
end

function AchievementShopView:OnClose()
    self.model.selectObj = nil
    -- self.model:CloseAchievementShopWindow()
    WindowManager.Instance:CloseWindow(self)
end

function AchievementShopView:OnOpen()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.model.shop_currentMain = self.openArgs[1]
        if self.openArgs ~= nil and #self.openArgs > 1 then
            self.model.shop_currentSub = self.openArgs[2]
        end
    end

    self.tabGroup:ChangeTab(self.model.shop_currentMain)
end

function AchievementShopView:OnHide()
    self.subPanelList[self.lastIndex]:Hiden()
end
