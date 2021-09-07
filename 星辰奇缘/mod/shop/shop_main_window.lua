ShopMainWindow = ShopMainWindow or BaseClass(BaseWindow)

function ShopMainWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.shop
    self.mgr = ShopManager.Instance

    self.resList = {
        {file = AssetConfig.shop_window, type = AssetType.Main}
        ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
    }

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.subPanelList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateRedListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function ShopMainWindow:__delete()
    self.OnHideEvent:Fire()

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end
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
    self.model.selectObj = nil
    self.model.selectedInfo = nil
    self.model.selectNum = 0
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ShopMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shop_window))
    self.gameObject.name = "ShopMainWindow"
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

    if BaseUtils.IsVerify then
        self.setting.openLevel = {999, 999, 1, 999}
        if BaseUtils.IsIosVest() then 
            self.setting.openLevel[4] = 999
        end
    end

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
        self.tabGroup.buttonTab[i].text.text = string.format(ColorHelper.TabButton1NormalStr, v.name)
    end
    self.tabCloner:SetActive(false)

    self.OnOpenEvent:Fire()
end

function ShopMainWindow:ChangeTab(index)
    ----------------------------------------很蛋疼的改动



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

    -- print(self.model.isShowRechargeTable)

    panel = self.subPanelList[currentIndex]



    if panel == nil then
        if currentIndex == 1 then
            self.subPanelList[currentIndex] = ShopPanel.New(self.model, self.mainPanel, currentIndex,self.transform)
        elseif currentIndex == 2 then
            self.subPanelList[currentIndex] = ShopPanel.New(self.model, self.mainPanel, currentIndex)
        elseif currentIndex == 3 then
            self.subPanelList[currentIndex] = ShopChargePanel.New(self.model, self.mainPanel, currentIndex)
        elseif currentIndex == 4 then
            self.subPanelList[currentIndex] = ShopTimelyPanel.New(self.model, self.mainPanel, currentIndex)
        end
        panel = self.subPanelList[currentIndex]
    end


    if self.lastIndex ~= nil then
        self.tabGroup.buttonTab[self.lastIndex].text.text = string.format(ColorHelper.TabButton1NormalStr, self.tabList[self.lastIndex].name)
    end


    self.lastIndex = currentIndex

    self.tabGroup.buttonTab[self.lastIndex].text.text = string.format(ColorHelper.TabButton1SelectStr, self.tabList[self.lastIndex].name)
    self.model.currentMain = currentIndex
    panel:Show()
end

function ShopMainWindow:OnClose()
    self.model.selectObj = nil
    self.model:CloseMain()
end

function ShopMainWindow:OnOpen()
    self.tabGroup:ChangeTab(self.model.currentMain)
    self:CheckRedPoint()

    self:RemoveListeners()
    self.mgr.onUpdateRedPoint:AddListener(self.updateRedListener)

    if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
        self.tabGroup.buttonTab[3].gameObject:SetActive(false)
    end
end

function ShopMainWindow:OnHide()
    self:RemoveListeners()

    self.subPanelList[self.lastIndex]:Hiden()
end

function ShopMainWindow:CheckRedPoint()
    local redList = {}
    for k,v in pairs(self.tabGroup.buttonTab) do
        local index = self.tabList[k].index
        if self.mgr.redPoint[index] ~= nil then
            local bool = false
            for _,red in pairs(self.mgr.redPoint[index]) do
                bool = bool or (red == true)
            end
            v.red:SetActive(bool)
        else
            v.red:SetActive(false)
        end
    end
end

function ShopMainWindow:UpdateRTPanel()
    self.mgr.onUpdateRT:Fire()
end

function ShopMainWindow:RemoveListeners()
    self.mgr.onUpdateRedPoint:RemoveListener(self.updateRedListener)
end

