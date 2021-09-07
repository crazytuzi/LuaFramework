-- @author 黄耀聪
-- @date 2016年9月9日

MidAutumnLetItGo = MidAutumnLetItGo or BaseClass(BaseWindow)

function MidAutumnLetItGo:__init(model)
    self.model = model
    self.name = "MidAutumnLetItGo"
    self.windowId = WindowConfig.WinID.mid_autumn_letitgo
    self.mgr = MidAutumnFestivalManager.Instance
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.midAutumn_lantern_letitgo, type = AssetType.Main},
        {file = AssetConfig.midAutumn_textures, type = AssetType.Dep},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
    }

    self.slotList = {}
    self.panelList = {}
    self.titleString = TI18N("赏月祈愿")

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MidAutumnLetItGo:__delete()
    self.OnHideEvent:Fire()
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
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

function MidAutumnLetItGo:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.midAutumn_lantern_letitgo))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.tabGroup = TabGroup.New(t:Find("Main/TabGroup").gameObject, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = true, perWidth = 44, perHeight = 96, isVertical = true, spacing = 5})

    self.panelList[1] = MidAutumnBless.New(self.model, t:Find("Main/Panel1").gameObject, self.assetWrapper)
    self.panelList[2] = MidAutumnRank.New(self.model, t:Find("Main/Panel2").gameObject, self.assetWrapper)
    self.titleText = t:Find("Main/title/Text"):GetComponent(Text)

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    self.panelList[1]:Hiden()
    self.panelList[2]:Hiden()
end

function MidAutumnLetItGo:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MidAutumnLetItGo:OnOpen()
    self:RemoveListeners()

    self.titleText.text = self.titleString
    self.openArgs = self.openArgs or {}
    self.tabGroup:ChangeTab(self.openArgs[1] or 1)
end

function MidAutumnLetItGo:OnHide()
    self:RemoveListeners()
end

function MidAutumnLetItGo:RemoveListeners()
end

function MidAutumnLetItGo:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function MidAutumnLetItGo:ChangeTab(index)
    local model = self.model
    if self.lastIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil then
            self.panelList[self.lastIndex]:Hiden()
        end
    end

    local panel = self.panelList[index]

    self.lastIndex = index
    if panel ~= nil then
        panel:Show(self.openArgs)
    end
end

