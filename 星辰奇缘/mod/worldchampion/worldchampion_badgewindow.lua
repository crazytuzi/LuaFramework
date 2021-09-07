WorldChampionBadgeWindow = WorldChampionBadgeWindow or BaseClass(BaseWindow)

function WorldChampionBadgeWindow:__init(model)
    self.model = model
    self.Mgr = self.model.mgr
    self.name = "WorldChampionBadgeWindow"
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.worldchampionbadgewindow , type = AssetType.Main},
        {file = AssetConfig.no1inworldbadge_textures, type = AssetType.Dep},

        --{file = AssetConfig.handbook_res, type = AssetType.Dep},
    }


    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function WorldChampionBadgeWindow:__delete()
    self.OnHideEvent:Fire()

    for i=1,3 do
        if self.subcon[i] ~= nil then
            self.subcon[i]:DeleteMe()
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function WorldChampionBadgeWindow:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionbadgewindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseBadgeWindow() end)
    self.Con = self.transform:Find("Main/Con")

    self.subcon = {}

    self.subcon[1] = WorldChampionBadgePanel.New(self.Con,self.model)
    self.subcon[2] = WorldChampionBadgeCollectPanel.New(self.Con,self.model)
    self.subcon[3] = WorldChampionBadgeCombinationPanel.New(self.Con,self.model)

    local go = self.transform:Find("Main/TabButtonGroup").gameObject

    self.tabgroup = TabGroup.New(go, function (tab) self:OnTabChange(tab) end, {notAutoSelect = true})

    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.tabgroup:ChangeTab(self.openArgs[1])
    else
        self.tabgroup:ChangeTab(1)
    end

    self:OnOpen()
end

function WorldChampionBadgeWindow:OnTabChange(index)
    for i=1,3 do
        if self.subcon[i] ~= nil then
            if i == index then
                self.subcon[i]:Show()
            else
                self.subcon[i]:Hiden()
            end
        end
    end
end



function WorldChampionBadgeWindow:OnOpen()
    -- self.Mgr.onOpenBadge:Fire()

end

function WorldChampionBadgeWindow:OnHide()
    -- self.Mgr.onHideBadge:Fire()
end
