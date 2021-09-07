GuildLeagueWindow = GuildLeagueWindow or BaseClass(BaseWindow)

function GuildLeagueWindow:__init(model)
    self.model = model
    self.Mgr = GuildLeagueManager.Instance
    self.viewType = ViewType.Window
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.name = "GuildLeagueWindow"
    self.windowId = WindowConfig.WinID.guild_league_window
    self.resList = {
        {file = AssetConfig.guildleague_window, type = AssetType.Main},
        {file = AssetConfig.guildsiege, type = AssetType.Dep},
        -- {file = AssetConfig.guildleague_texture, type = AssetType.Dep},
    }
    self.OnOpenEvent:AddListener(function()
        self.Mgr:Require17619()
    end)
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.isend = false
    self.subArgs = nil
    self.index = 1
    self.kingguildupdate = function()
        self:UpdateRed()
    end
    self.beginFcallback = function()
        LuaTimer.Add(50, function()
            self.model:CloseWindow()
        end)
    end
end

function GuildLeagueWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFcallback)
    self.Mgr.LeagueKingGuildUpdate:RemoveListener(self.kingguildupdate)
    self.OnHideEvent:Fire()
    for _,panel in pairs(self.subcon) do
        if panel ~= nil then
            panel:DeleteMe()
        end
    end
    self:AssetClearAll()
end

function GuildLeagueWindow:OnOpen()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.subArgs = {self.openArgs[2], self.openArgs[3]}
        self.tabgroup:ChangeTab(self.openArgs[1])
        self.openArgs = nil
    else
        self.tabgroup:ChangeTab(self.index)
    end
end

function GuildLeagueWindow:OnHide()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
    self.subcon[self.index]:Hiden()
    -- self.tabgroup:ChangeTab(self.index)
end

function GuildLeagueWindow:InitPanel()
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFcallback)
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleague_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseWindow() end)
    self.Con = self.transform:Find("Main/Con")
    self.ConImg = self.Con:GetComponent(Image)

    self.subcon = {}
    self.subcon[1] = GuildLeagueInfoPanel.New(self.Con, self)
    -- self.subcon[2] = GuildLeagueFightSchedulePanel.New(self.Con, self)
    self.subcon[2] = GuildLeagueRankPanel.New(self.Con, self)
    -- self.subcon[4] = GuildLeagueGroupInfoPanel.New(self.Con, self)
    -- self.subcon[5] = GuildLeagueSchedulePanel.New(self.Con, self)
    self.subcon[3] = GuildLeagueDescPanel.New(self.Con, self)

    local TabGroupTrans = self.transform:Find("Main/TabMask/TabButtonGroup")
    local num = TabGroupTrans.childCount
    local tabopen = {
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        -- [5] = false,
        -- [6] = true,
        -- [7] = true,
    }
    local opennum = 0
    for i=1,num do
        TabGroupTrans:GetChild(i-1).gameObject:SetActive(tabopen[i])
        if tabopen[i] then
            opennum = opennum + 1
        end
    end
    TabGroupTrans.sizeDelta = Vector2(116*opennum, 43.1)
    local index = 0
    for i=1,num do
        local go = TabGroupTrans:GetChild(i-1).gameObject
        if go.activeSelf == true then
            go.transform.anchoredPosition = Vector2(index*116, -26)
            index = index +1
        end
    end

    local go = TabGroupTrans.gameObject
    self.tabgroup = TabGroup.New(go, function (tab) self:OnTabChange(tab) end, {notAutoSelect = true, noCheckRepeat = true})

    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.tabgroup:ChangeTab(self.openArgs[1])
        self.subArgs = {self.openArgs[2], self.openArgs[3]}
        self.openArgs = nil
    else
        self.tabgroup:ChangeTab(1)
    end
    self.Mgr.LeagueKingGuildUpdate:AddListener(self.kingguildupdate)
    self:UpdateRed()
end

function GuildLeagueWindow:OnTabChange(index)
    -- print(index)
    if index == 4 then
        CombatManager.Instance.WatchLogmodel:OpenWindow({4,1})
        self.tabgroup:ChangeTab(1)
        return
    end
    for i=1,6 do
        if self.subcon[i] ~= nil then
            self.subcon[i]:Hiden()
        end
    end
    self.subcon[index]:Show(self.subArgs)
    self.subArgs = nil
    self.index = index
end

function GuildLeagueWindow:UpdateRed()
    local live = self.Mgr.fightInfo ~= nil and next(self.Mgr.fightInfo) ~= nil and self.Mgr.fightInfo[1].phase > 4 and self.Mgr.currstatus == 2
    self.transform:Find("Main/TabMask/TabButtonGroup"):GetChild(1):Find("NotifyPoint").gameObject:SetActive(self.Mgr:CheckCanGuess() or live)
end