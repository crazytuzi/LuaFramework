-- @author 黄耀聪
-- @date 2016年9月10日

MidAutumnFestivalWindow = MidAutumnFestivalWindow or BaseClass(BaseWindow)

function MidAutumnFestivalWindow:__init(model)
    self.model = model
    self.name = "MidAutumnFestivalWindow"
    self.windowId = WindowConfig.WinID.mid_autumn_window

    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.midAutumn_window, type = AssetType.Main},
        {file = AssetConfig.midAutumn_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MidAutumnFestivalWindow:__delete()
    self.OnHideEvent:Fire()
    if self.midAutumnPanel ~= nil then
        self.midAutumnPanel:DeleteMe()
        self.midAutumnPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MidAutumnFestivalWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.midAutumn_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
end

function MidAutumnFestivalWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MidAutumnFestivalWindow:OnOpen()
    self:RemoveListeners()

    if self.midAutumnPanel == nil then
        self.midAutumnPanel = MidAutumnPanel.New(self.model, self.transform:Find("Main").gameObject)
    end

    self.openArgs = self.openArgs or {}
    self.midAutumnPanel:Show(self.openArgs)
end

function MidAutumnFestivalWindow:OnHide()
    self:RemoveListeners()

    if self.midAutumnPanel ~= nil then
        self.midAutumnPanel:Hiden()
    end
end

function MidAutumnFestivalWindow:RemoveListeners()
end

function MidAutumnFestivalWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end


