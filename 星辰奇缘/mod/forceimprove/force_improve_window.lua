ForceImproveWindow = ForceImproveWindow or BaseClass(BaseWindow)

function ForceImproveWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.force_improve
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.mgr = ForceImproveManager.Instance

    self.depPath = "textures/ui/forceimprove.unity3d"

    self.resList = {
        {file = AssetConfig.force_improve_window, type = AssetType.Main}
        , {file = self.depPath, type = AssetType.Dep}
    }

    self.tabGroupObj = nil
    self.tabGroup = nil

    self.currentIndex = 1
    self.childTab = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:UpdateRedPoint() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function ForceImproveWindow:__delete()
    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    for k,v in pairs(self.childTab) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.childTab = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ForceImproveWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.force_improve_window))
    self.gameObject.name = "ForceImproveWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.mainTransform:FindChild("Close"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup").gameObject
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, {notAutoSelect = true})
end

function ForceImproveWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function ForceImproveWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ForceImproveWindow:OnOpen()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:Hiden()
        end
        self.currentIndex = self.openArgs[1]
    end

    self.tabGroup.noCheckRepeat = true
    self.tabGroup:ChangeTab(self.currentIndex)
    self.tabGroup.noCheckRepeat = false

    self:UpdateRedPoint()
    self.mgr.onUpdateForce:AddListener(self.updateListener)
end

function ForceImproveWindow:OnHide()
    self.openArgs = nil
    local child = self.childTab[self.currentIndex]
    if child ~= nil then
        child:Hiden()
    end
    self.mgr.onUpdateForce:RemoveListener(self.updateListener)
end

function ForceImproveWindow:ChangeTab(index)
    if self.currentIndex ~= 0 and self.currentIndex ~= index then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:Hiden()
        end
    end

    self.currentIndex = index
    local child = self.childTab[self.currentIndex]
    if child == nil then
        if index == 1 then
            child = ForceImprovePanel.New(self)
        elseif index == 2 then
            child = ForcePromotionPanel.New(self)
        else
            child = ForcePromotionPanel.New(self)
        end
        self.childTab[self.currentIndex] = child
    end

    child:Show(self.openArgs)

    if index == 2 then
        self.model.firstTimeOpenForceImproveWindow = false
        self.tabGroup:ShowRed(2, false)
    end
end

function ForceImproveWindow:UpdateRedPoint()
    -- self.tabGroup:ShowRed(2, self.model.firstTimeOpenForceImproveWindow or self.model:CheckCanUpgrade(true))
    self.tabGroup:ShowRed(2, self.model:CheckCanUpgrade(false))
end