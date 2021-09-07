-- @author 黄耀聪
-- @date 2016年7月13日

SevendayWindow = SevendayWindow or BaseClass(BaseWindow)

function SevendayWindow:__init(model)
    self.model = model
    self.name = "SevendayWindow"
    self.windowId = WindowConfig.WinID.seven_day_window
    self.mgr = SevendayManager.Instance
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.sevenday_window, type = AssetType.Main},
        {file = AssetConfig.sevenday_textures, type = AssetType.Dep},
    }

    self.panelList = {}

    -- self.titleString = TI18N("目 标")

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SevendayWindow:__delete()
    self.OnHideEvent:Fire()
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SevendayWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sevenday_window))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    local main = t:Find("Main")
    -- self.titleText = main:Find("Title/Text"):GetComponent(Text)
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.tabContainer = main:Find("TabListPanel")
    self.tabCloner = self.tabContainer:Find("TabButton").gameObject
    self.mainContainer = main
    -- self.titleText.text = self.titleString

    self.tabCloner:SetActive(false)
    self.closeBtn.onClick:AddListener(function() self.model:CloseWindow() end)
end

function SevendayWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SevendayWindow:OnOpen()
    self:RemoveListeners()

    if self.panelList[1] == nil then
        self.panelList[1] = SevendayPanel.New(self.model, self.mainContainer)
    end
    self.panelList[1]:Show(self.openArgs)
    SevendayManager.Instance:send10242()
end

function SevendayWindow:OnHide()
    self:RemoveListeners()
end

function SevendayWindow:RemoveListeners()
end


