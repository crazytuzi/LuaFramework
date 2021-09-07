-- @author 黄耀聪
-- @date 2016年9月10日

NewMoonWindow = NewMoonWindow or BaseClass(BaseWindow)

function NewMoonWindow:__init(model)
    self.model = model
    self.name = "NewMoonWindow"
    self.windowId = WindowConfig.WinID.new_moon_window

    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.midAutumn_window, type = AssetType.Main},
        {file = AssetConfig.newmoon_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function NewMoonWindow:__delete()
    self.OnHideEvent:Fire()
    if self.newMoonPanel ~= nil then
        self.newMoonPanel:DeleteMe()
        self.newMoonPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function NewMoonWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.midAutumn_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newmoon_textures, "I18N_Title")
end

function NewMoonWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NewMoonWindow:OnOpen()
    self:RemoveListeners()

    if self.newMoonPanel == nil then
        self.newMoonPanel = NewMoonPanel.New(self.model, self.transform:Find("Main").gameObject)
    end

    self.openArgs = self.openArgs or {}
    self.newMoonPanel:Show(self.openArgs)
end

function NewMoonWindow:OnHide()
    self:RemoveListeners()

    if self.newMoonPanel ~= nil then
        self.newMoonPanel:Hiden()
    end
end

function NewMoonWindow:RemoveListeners()
end

function NewMoonWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end


