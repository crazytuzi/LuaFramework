-- @author jia
-- @date 2017年5月31日
-- 世界等级活动window
WorldLevWindow = WorldLevWindow or BaseClass(BaseWindow)

function WorldLevWindow:__init(model)
    self.model = model
    self.name = "WorldLevWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.world_lev_window

    self.resList = {
        { file = AssetConfig.halloweenwindow, type = AssetType.Main }
        ,{ file = AssetConfig.valentine_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.may_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.dailyicon, type = AssetType.Dep }
        ,{ file = AssetConfig.springfestival_texture, type = AssetType.Dep }
        ,{ file = AssetConfig.market_textures, type = AssetType.Dep }
    }

    self.panelList = { }
    self.panelIdList = { }
    self.rankTypeList = { }
    self.redListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener( function() self:OnOpen() end)
    self.OnHideEvent:AddListener( function() self:OnHide() end)
end

function WorldLevWindow:__delete()
    self.OnHideEvent:Fire()
    if self.tree ~= nil then
        self.tree:DeleteMe()
        self.tree = nil
    end
    if self.petLoader ~= nil then
        self.petLoader:DeleteMe()
        self.petLoader = nil
    end

    if self.panelIdList ~= nil then
        for _, v in pairs(self.panelIdList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelIdList = nil
    end
    self:AssetClearAll()
end

function WorldLevWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener( function() WindowManager.Instance:CloseWindow(self) end)
    self.titleImg = t:Find("Main/Title/Image"):GetComponent(Image)

    t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.valentine_textures, "TitleI18N1")
    t:Find("Main/Title/Image"):GetComponent(Image):SetNativeSize()
    t:Find("Main/Title").gameObject:SetActive(false)

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/BaseItem").gameObject
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    t:Find("Main/TitleText").gameObject:SetActive(true)
    self.TxtTitle = t:Find("Main/TitleText/Text"):GetComponent(Text)
    self.TxtTitle.text = TI18N("世界等级活动")

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function WorldLevWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end


function WorldLevWindow:OnOpen()
    if self.panelList ~= nil then
        for _, panelTab in pairs(self.panelList) do
            if panelTab ~= nil then
                for _, v in pairs(panelTab) do
                    if v ~= nil then
                        v:Hiden()
                    end
                end
            end
        end
    end

    self:RemoveListeners()
    WorldLevManager.Instance.redPointEvent:AddListener(self.redListener)

    self.openArgs = self.openArgs or { }

    self:InitTreeInfo()
    self.tree:SetData(self.treeInfo)

    if self.openArgs[1] ~= nil then
        self.pos = self.campaignIdToPos[self.openArgs[1]]
    else
        if self.pos == nil then
            self.pos = { 1, 1 }
        end
    end

    self.tree:ClickMain(self.pos[1], self.pos[2])

    self:CheckRedPoint()
end

function WorldLevWindow:OnHide()
    self:RemoveListeners()
end

function WorldLevWindow:RemoveListeners()
    WorldLevManager.Instance.redPointEvent:RemoveListener(self.redListener)
end

function WorldLevWindow:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.WorldLev]
    local baseCampaignData = DataCampaign.data_list
    self.mayData = tempData
    if self.mayData == nil then
        return
    end
    local infoTab = { }
    local c = 1
    for index, v in pairs(self.mayData) do
        if index ~= "count" then
            if infoTab[c] == nil then
                infoTab[c] = { height = 60, subs = { }, type = index, datalist = { }, resize = false }
                c = c + 1
            end
            local main = infoTab[c - 1]
            main.datalist = v.sub
            main.label = baseCampaignData[v.sub[1].id].name
            -- print(main.label)
            main.sprite = nil
            if index == CampaignEumn.WorldLevType.Constellation then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, "2013")
            elseif index == CampaignEumn.WorldLevType.Gift then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift1")
            elseif index == CampaignEumn.WorldLevType.Gift2 then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift1")
            elseif index == CampaignEumn.WorldLevType.Gift3 then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift1")
            elseif index == CampaignEumn.WorldLevType.Gift4 then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift1")
            elseif index == CampaignEumn.WorldLevType.Pet then
                main.isSprite = true
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift1")
                -- self.petLoader = SingleIconLoader.New(self.tree.mainTab[c].iconLoader.image.gameObject)
                -- self.petLoader:SetSprite(SingleIconType.Pet, 10021)
                -- main.sprite = PreloadManager.Instance:GetSprite(AssetConfig.headother_textures, "10021")
            elseif index == CampaignEumn.WorldLevType.PlayerKill then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, "1029")
            elseif index == CampaignEumn.WorldLevType.Weapon then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "QingmingIcon3")
            elseif index == CampaignEumn.WorldLevType.Weapon2 then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "QingmingIcon3")
            elseif index == CampaignEumn.WorldLevType.Wing then
                main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item, DataItem.data_get[21102].icon) end
            elseif index == CampaignEumn.WorldLevType.Consume then

            elseif index == CampaignEumn.WorldLevType.TotalRecharge then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "Gift")
            elseif index == CampaignEumn.WorldLevType.TotalRecharge2 then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "Gift")

                -- TODO 活动图标未定
            elseif index == CampaignEumn.WorldLevType.Mount then
               main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item, DataItem.data_get[23674].icon) end
            elseif index == CampaignEumn.WorldLevType.Home then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.market_textures, "OtherButton")
            elseif index == CampaignEumn.WorldLevType.Arena then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, "1002")
            elseif index == CampaignEumn.WorldLevType.Stone then
                main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item, DataItem.data_get[20807].icon) end

            elseif index == CampaignEumn.WorldLevType.Recharge then
                main.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90018")
            elseif index == CampaignEumn.WorldLevType.Recharge2 then
                main.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90018")
            elseif index == CampaignEumn.WorldLevType.WorldChampion then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, "2028")
            end
            local package = main.package or AssetConfig.may_textures
            if main.sprite == nil then
                main.sprite = self.assetWrapper:GetSprite(package, main.iconName)
            end
        end
    end
    table.sort(infoTab, function(a, b) return a.type < b.type end)
    self.treeInfo = infoTab
    self.campaignIdToPos = { }
    for index, v in pairs(infoTab) do
        for index2, sub in pairs(v.datalist) do
            if #v.subs == 0 then
                self.campaignIdToPos[sub.id] = { index, 1 }
            else
                self.campaignIdToPos[sub.id] = { index, index2 }
            end
        end
    end
end

function WorldLevWindow:ChangeTab(index, subIndex)
    local model = self.model
    if self.lastIndex ~= nil and self.lastGroupIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil and self.panelList[self.lastIndex][self.lastGroupIndex] then
            self.panelList[self.lastIndex][self.lastGroupIndex]:Hiden()
        end
    end
    subIndex = subIndex or 1
    if self.panelList[index] == nil then self.panelList[index] = { } end
    local type = self.treeInfo[index].type
    local treeInfoId = self.treeInfo[index].datalist[subIndex]
    local panelId = self.panelIdList[treeInfoId.id]
    local campaignData = DataCampaign.data_list[treeInfoId.id]
    local rankType = self.rankTypeList[treeInfoId.id] or 0
    local openArgs = {
        activityName = campaignData.name,
        name = campaignData.name,
        startTime = campaignData.cli_start_time[1],
        endTime = campaignData.cli_end_time[1],
        desc = campaignData.cond_desc,
        icon = self.treeInfo[index].iconName,
        -- bg = "MidAutumnBg",
        target = nil,
        sprite = self.treeInfo[index].sprite,
    }
    if panelId == nil then
        if type == CampaignEumn.WorldLevType.Gift then
            panelId = WorldLevGiftPanel.New(self.rightContainer,type)
        elseif type == CampaignEumn.WorldLevType.Gift2 then
            panelId = WorldLevGiftPanel.New(self.rightContainer,type)
        elseif type == CampaignEumn.WorldLevType.Gift3 then
            panelId = WorldLevGiftPanel.New(self.rightContainer,type)
        elseif type == CampaignEumn.WorldLevType.Gift4 then
            panelId = WorldLevGiftPanel.New(self.rightContainer,type)
        elseif type == CampaignEumn.WorldLevType.Consume then

        elseif type == CampaignEumn.WorldLevType.TotalRecharge then
            panelId = DragonBoatConsmRtnPanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.bg_worldlevtotalrechargebg
            table.insert(panelId.resList, { file = panelId.bg, type = AssetType.Main })
            panelId.campaignGroup = CampaignManager.Instance.campaignTree[CampaignEumn.Type.WorldLev][type]
        elseif type == CampaignEumn.WorldLevType.TotalRecharge2 then
            panelId = DragonBoatConsmRtnPanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.bg_worldlevtotalrechargebg
            table.insert(panelId.resList, { file = panelId.bg, type = AssetType.Main })
            panelId.campaignGroup = CampaignManager.Instance.campaignTree[CampaignEumn.Type.WorldLev][type]

        elseif type == CampaignEumn.WorldLevType.Constellation then
            rankType = CampaignEumn.CampaignRankType.Constellation;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)
        elseif type == CampaignEumn.WorldLevType.Pet then
            rankType = CampaignEumn.CampaignRankType.Pet;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)
        elseif type == CampaignEumn.WorldLevType.PlayerKill then
            rankType = CampaignEumn.CampaignRankType.PlayerKill;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)
        elseif type == CampaignEumn.WorldLevType.Weapon then
            rankType = CampaignEumn.CampaignRankType.Weapon;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)
        elseif type == CampaignEumn.WorldLevType.Weapon2 then
            rankType = CampaignEumn.CampaignRankType.Weapon2;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)
        elseif type == CampaignEumn.WorldLevType.WorldChampion then
            rankType = CampaignEumn.CampaignRankType.WorldChampion;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)
        elseif type == CampaignEumn.WorldLevType.Wing then
            rankType = CampaignEumn.CampaignRankType.Wing;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)
        elseif type == CampaignEumn.WorldLevType.PlayerKill then
            rankType = CampaignEumn.CampaignRankType.PlayerKill;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)
        elseif type == CampaignEumn.WorldLevType.Mount then
            rankType = CampaignEumn.CampaignRankType.Mount;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)
        elseif type == CampaignEumn.WorldLevType.Home then
            rankType = CampaignEumn.CampaignRankType.Home;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)
        elseif type == CampaignEumn.WorldLevType.Arena then
            rankType = CampaignEumn.CampaignRankType.Arena;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)
        elseif type == CampaignEumn.WorldLevType.Stone then
            rankType = CampaignEumn.CampaignRankType.Stone;
            panelId = CampaignRankPanel.New(self.rightContainer, rankType,treeInfoId.id)

        elseif type == CampaignEumn.WorldLevType.Recharge then
            panelId = DoubleElevenFeedbackPanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.bg_worldlevrechargebg
            table.insert(panelId.resList, { file = panelId.bg, type = AssetType.Main })
            panelId.campaignData = campaignData
        elseif type == CampaignEumn.WorldLevType.Recharge2 then
            panelId = DoubleElevenFeedbackPanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.bg_worldlevrechargebg
            table.insert(panelId.resList, { file = panelId.bg, type = AssetType.Main })
            panelId.campaignData = campaignData
        end
    end
    self.rankTypeList[treeInfoId.id] = rankType
    if rankType > 0 then
        WorldLevManager.Instance:RequestInitData(rankType)
        WorldLevManager.Instance.CurRankType = rankType
    end
    if panelId ~= nil then
        self.panelList[index][subIndex] = panelId
        self.panelIdList[campaignData.id] = panelId
        self.lastIndex = index
        self.lastGroupIndex = subIndex
        if panelId ~= nil then
            panelId:Show(openArgs)
        end
    end
end

function WorldLevWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function WorldLevWindow:CheckRedPoint()
    local campData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.WorldLev]
    if campData ~= nil then
        for index, v in pairs(campData) do
            if index ~= "count" then
                local mainRed = false
                local posMain = nil
                for _, sub in pairs(v.sub) do
                    local pos = self.campaignIdToPos[sub.id]
                    posMain = pos
                    mainRed = mainRed or(CampaignManager.Instance.campaignTab[sub.id] ~= nil and WorldLevManager.Instance.redPointDic[sub.id] == true)
                end
                if posMain ~= nil then
                    self.tree:RedMain(posMain[1], mainRed)
                end
            end
        end
    end
end