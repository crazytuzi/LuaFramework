WorldChampionMainWindow = WorldChampionMainWindow or BaseClass(BaseWindow)

function WorldChampionMainWindow:__init(model)
    self.model = model
    self.Mgr = self.model.mgr
    self.name = "WorldChampionMainWindow"
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.worldchampionmainwindow, type = AssetType.Main},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
    }

    self.isend = false
    self.showRedPoint = function() self:ShowRedPoint() end
    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function WorldChampionMainWindow:__delete()
    self.OnHideEvent:Fire()

    for i=1,3 do
        if self.subcon[i] ~= nil then
            self.subcon[i]:DeleteMe()
        end
    end
    if self.subcon[6] ~= nil then
        self.subcon[6]:DeleteMe()
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionMainWindow:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionmainwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseMainWindow() end)
    self.Con = self.transform:Find("Main/Con")
    self.ConImg = self.Con:GetComponent(Image)

    self.subcon = {}
    self.subcon[1] = WorldChampionSubonePanel.New(self.Con, self)
    self.subcon[2] = NoOneAllRankSubPanel.New(self.model,self.Con)
    self.subcon[3] = WorldChampionSubthreePanel.New(self.Con, self)
    self.subcon[4] = self.Con:Find("No1InWorldSub4").gameObject
    self.sub4Text = self.subcon[4].transform:Find("Desc"):GetComponent(Text)
    if WorldChampionManager.Instance.pk_type == 1 then
        self.sub4Text.text = self.Mgr.WindowDesc
    elseif WorldChampionManager.Instance.pk_type == 2 then
        self.sub4Text.text = self.Mgr.WindowDesc2V2
    end
    local go = self.transform:Find("Main/TabButtonGroup").gameObject

    -- if WorldChampionManager.Instance.rankData.best_rank_lev < 8 then
    --     go.transform:GetChild(5).gameObject:SetActive(false)
    -- else
        --self.subcon[6] = WorldChampionBadgePanel.New(self.Con, self)
    -- end
    self.redPoint = go.transform:GetChild(5):Find("NotifyPoint")
    self.redPoint:GetComponent(RectTransform).anchoredPosition = Vector2(55, 15)
    self:ShowRedPoint()
    self.tabgroup = TabGroup.New(go, function (tab) self:OnTabChange(tab) end, {notAutoSelect = true})

    local btn = go.transform:GetChild(5):GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function()
        --historical_high best_rank_lev
        -- if WorldChampionManager.Instance.rankData.historical_high < 8 then
        --     NoticeManager.Instance:FloatTipsByString(TI18N("武道会达到<color='#ffff00'>已臻大成</color>段位开启{face_1,18}"))
        -- else
            self.tabgroup:ChangeTab(6)
        -- end
    end)

    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.tabgroup:ChangeTab(self.openArgs[1])
    else
        self.tabgroup:ChangeTab(1)
    end

    self:OnOpen()
end

function WorldChampionMainWindow:OnTabChange(index)
    if index == 5 then
        CombatManager.Instance.WatchLogmodel:OpenWindow({4,1})
        self.tabgroup:ChangeTab(1)
        return
    end
    if index == 6 then
        WorldChampionManager.Instance.model:OpenBadgeWindow({1})
        self.tabgroup:ChangeTab(1)
        self.model:CloseMainWindow()
        return
    end
    for i=1,4 do
        if self.subcon[i] ~= nil then
            if i == index then
                if i ~= 4 then
                    self.subcon[i]:Show()
                else
                    self.subcon[i]:SetActive(true)
                end
            else
                if i ~= 4 then
                    self.subcon[i]:Hiden()
                else
                    self.subcon[i]:SetActive(false)
                end
            end
        end
    end
    -- if self.subcon[6] ~= nil then
    --     self.subcon[6]:Hiden()
    -- end
    -- if index == 6 then
    --     if self.subcon[6] ~= nil then
    --         self.subcon[6]:Show()
    --     end
    --     for i=1,3 do
    --         self.subcon[i]:Hiden()
    --     end
    --     self.subcon[4]:SetActive(false)
    -- end
end

function WorldChampionMainWindow:ShowRedPoint()
    if BackpackManager.Instance:GetItemCount(22785) > 0 then
        self.redPoint.gameObject:SetActive(true)
    else
       self.redPoint.gameObject:SetActive(false)
    end
end

function WorldChampionMainWindow:OnOpen()
    WorldChampionManager.Instance.onStarChange:AddListener(self.showRedPoint)
    self:ShowRedPoint()
end

function WorldChampionMainWindow:OnHide()
    WorldChampionManager.Instance.onStarChange:RemoveListener(self.showRedPoint)
end
