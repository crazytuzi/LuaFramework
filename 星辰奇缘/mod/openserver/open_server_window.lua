OpenServerWindow = OpenServerWindow or BaseClass(BaseWindow)

function OpenServerWindow:__init(model)
    self.model = model
    self.cacheMode = CacheMode.Visible
    self.windowId = WindowConfig.WinID.open_server_window

    self.resList = {
        {file = AssetConfig.open_server_window, type = AssetType.Main}
    }

    self.subPanelList = {}
    self.title = TI18N("开服联欢")

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function OpenServerWindow:__delete()
    self.OnHideEvent:Fire()
    if self.subPanelList ~= nil then
        for k,v in pairs(self.subPanelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.subPanelList = nil
    end
    if self.model.giftPreview ~= nil then
        self.model.giftPreview:DeleteMe()
        self.model.giftPreview = nil
    end
    if self.model.babyTips ~= nil then
        self.model.babyTips:DeleteMe()
        self.model.babyTips = nil
    end
    if self.model.photoPanel ~= nil then
        self.model.photoPanel:DeleteMe()
        self.model.photoPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_window))
    self.gameObject.name = "OpenServerWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.mainPanel = self.transform:Find("Main")

    self.closeBtn = self.mainPanel:Find("Close"):GetComponent(Button)
    self.tabListPanel = self.mainPanel:Find("TabListPanel")
    self.titleText = self.mainPanel:Find("Title/Text"):GetComponent(Text)

    self.titleText.text = self.title

    self.tabListPanel.gameObject:SetActive(false)
    self.closeBtn.onClick:AddListener(function() self:OnClose() end)
    self.OnOpenEvent:Fire()
end

function OpenServerWindow:OnOpen()
    local args = self.openArgs

    if self.subPanelList[1] == nil then
        self.subPanelList[1] = OpenServerNewActivityPanel.New(self.model, self.mainPanel)
    end
    self.subPanelList[1]:Show(args)
end

function OpenServerWindow:OnHide()
    if self.subPanelList[1] ~= nil then
        self.subPanelList[1]:Hiden()
    end
end

function OpenServerWindow:RemoveListeners()
end

function OpenServerWindow:OnClose()
    self.model:CloseWindow()
end


