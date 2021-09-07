-- 新春节活动
-- 黄耀聪 2016-01-16

SpringFestivalWindow = SpringFestivalWindow or BaseClass(BaseWindow)

function SpringFestivalWindow:__init(model)
    self.model = model
    self.name = "SpringFestivalWindow"
    self.windowId = WindowConfig.WinID.spring_festival
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.halloweenwindow, type = AssetType.Main},
        {file = AssetConfig.halloween_textures, type = AssetType.Dep},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = AssetConfig.halloween_textures, type = AssetType.Dep},
        {file = AssetConfig.christmas_textures, type = AssetType.Dep},
        {file = AssetConfig.guild_dep_res, type = AssetType.Dep},
        {file = AssetConfig.summer_res, type = AssetType.Dep},
        {file = AssetConfig.may_textures, type = AssetType.Dep},
    }

    self.campaignIdToPos = {}
    self.panelList = {}
    self.panelIdList = {}
    self.lastIndex = 0
    self.lastGroupIndex = 0

    self.redListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SpringFestivalWindow:__delete()
    self.OnHideEvent:Fire()

    if self.tree ~= nil then
        self.tree:DeleteMe()
        self.tree = nil
    end
    if self.panelIdList ~= nil then
        for _,v in pairs(self.panelIdList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelIdList = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SpringFestivalWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenwindow))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "TitleI18N")

    -- t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.SpringFestival_textures, "TitleI18N")

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/BaseItem").gameObject
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function SpringFestivalWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SpringFestivalWindow:OnOpen()
    if self.panelList ~= nil then
        for _,panelTab in pairs(self.panelList) do
            if panelTab ~= nil then
                for _,v in pairs(panelTab) do
                    v:Hiden()
                end
            end
        end
        -- self.panelList = nil
    end

    self:RemoveListeners()
    self:AddListeners()

    self.openArgs = self.openArgs or {}
    local type = self.openArgs[2] or 1

    self:InitTreeInfo()
    self.tree:SetData(self.treeInfo)

    self:CheckRedPoint()

    self.tree:ClickMain(type, 1)
end

function SpringFestivalWindow:OnHide()
    self:RemoveListeners()
    if self.panelList ~= nil then
        for _,panelTab in pairs(self.panelList) do
            if panelTab ~= nil then
                for _,v in pairs(panelTab) do
                    v:Hiden()
                end
            end
        end
    end
end

function SpringFestivalWindow:AddListeners()
    SpringFestivalManager.Instance.onCheckRed:AddListener(self.redListener)
    DoubleElevenManager.Instance:Send14045()
end

function SpringFestivalWindow:RemoveListeners()
    SpringFestivalManager.Instance.onCheckRed:RemoveListener(self.redListener)
end

function SpringFestivalWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function SpringFestivalWindow:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival]
    local baseCampaignData = DataCampaign.data_list
    self.mayData = tempData

    local infoTab = {}
    local c = 1
    for index,v in pairs(self.mayData) do
        if index ~= "count" then
            if infoTab[c] == nil then
                infoTab[c] = {height = 60, subs = {}, type = index, datalist = {}, resize = false}
                c = c + 1
            end
            local main = infoTab[c - 1]
            main.datalist = v.sub
            main.label = baseCampaignData[v.sub[1].id].name
            -- print(main.label)
            main.sprite = nil
            if index == CampaignEumn.SpringFestivalType.LuckyMoney then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res, "RedBagIcon")
            elseif index == CampaignEumn.SpringFestivalType.Continue then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "Gift")
            elseif index == CampaignEumn.SpringFestivalType.NewYearGoods then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "dwb10I18N")
            elseif index == CampaignEumn.SpringFestivalType.GroupPurchase then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "2021")
            elseif index == CampaignEumn.SpringFestivalType.Recharge then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift2")
            elseif index == CampaignEumn.SpringFestivalType.Snowman then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.christmas_textures, "Battle")
            elseif index == CampaignEumn.SpringFestivalType.SnowFight then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.christmas_textures, "Cute")
            elseif index == CampaignEumn.SpringFestivalType.Pumpkin then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.halloween_textures, "Pumpkin")
            elseif index == CampaignEumn.SpringFestivalType.Ski then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "Clock")
            elseif index == CampaignEumn.SpringFestivalType.HideAndSeek then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Lollipop")
            elseif index == CampaignEumn.SpringFestivalType.Exchange then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "2021")
            end
            local package = main.package or AssetConfig.halloween_textures
            if main.sprite == nil then
                main.sprite = self.assetWrapper:GetSprite(package, main.iconName)
            end
        end
    end
    table.sort(infoTab, function(a,b) return a.type < b.type end)
    self.treeInfo = infoTab

    self.campaignIdToPos = {}
    for index,v in pairs(infoTab) do
        for index2,sub in pairs(v.datalist) do
            if #v.subs == 0 then
                self.campaignIdToPos[sub.id] = {index, 1}
            else
                self.campaignIdToPos[sub.id] = {index, index2}
            end
        end
    end
end

function SpringFestivalWindow:ChangeTab(index, subIndex)
    local model = self.model
    if self.lastIndex ~= nil and self.lastGroupIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil and self.panelList[self.lastIndex][self.lastGroupIndex] then
            self.panelList[self.lastIndex][self.lastGroupIndex]:Hiden()
        end
    end

    subIndex = subIndex or 1
    if self.panelList[index] == nil then self.panelList[index] = {} end
    local panel = self.panelList[index][subIndex]
    local type = self.treeInfo[index].type
    local treeInfoId = self.treeInfo[index].datalist[subIndex]
    local panelId = self.panelIdList[treeInfoId.id]

    local campaignData = DataCampaign.data_list[treeInfoId.id]

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
        if type == CampaignEumn.SpringFestivalType.Continue then
            panelId = ContinueChargePanel.New(NewMoonManager.Instance.model, self.rightContainer)
            panelId.campBaseData = campaignData
        elseif type == CampaignEumn.SpringFestivalType.NewYearGoods then
            panelId = HalloweenMoonPanel.New(self.model, self.rightContainer)
            panelId.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival][type]
        elseif type == CampaignEumn.SpringFestivalType.GroupPurchase then
            panelId = DoubleElevenGroupBuyPanel.New(DoubleElevenManager.Instance.model, self.rightContainer, self)
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.SpringFestivalType.Recharge then
            panelId = DoubleElevenFeedbackPanel.New(model, self.rightContainer)
            panelId.bg = AssetConfig.doubleelevenfeedbacki18n
            panelId.campaignData = campaignData
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.SpringFestivalType.Snowman then
            panelId = ChristmasDescPanel.New(model, self.rightContainer)
            panelId.campId = campaignData.id
            panelId.bg = AssetConfig.christmas_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.SpringFestivalType.SnowFight then
            panelId = ChristmasDescPanel.New(model, self.rightContainer)
            panelId.campId = campaignData.id
            panelId.bg = AssetConfig.christmas_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.SpringFestivalType.HideAndSeek then
            panelId = SeekChildrenPanel.New(SummerManager.Instance.model,self.rightContainer)
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.SpringFestivalType.Pumpkin then
            panelId = HalloweenPumpkingoblinPanel.New(self)
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.SpringFestivalType.Ski then
            panelId = PathFindingPanel.New(model, self.rightContainer)     -- 赛龙舟
            panelId.target = "80_1"
            panelId.campId = campaignData.id
            panelId.bg = AssetConfig.snowfighti18n
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.SpringFestivalType.LuckyMoney then
            panelId = LuckMoney2.New(model, self.rightContainer)     -- 压岁钱
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.SpringFestivalType.Exchange then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.spring_festival_exchange)
            return
        end
    end

    if panelId ~= nil then
        panel = panelId
        panel.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival][type]
        self.panelList[index][subIndex] = panelId
        self.panelIdList[campaignData.id] = panelId
        -- panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)

        self.lastIndex = index
        self.lastGroupIndex = subIndex

        if panelId ~= nil then
            panelId:Show(openArgs)
        end
    end
end

function SpringFestivalWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function SpringFestivalWindow:CheckRedPoint()
    local campData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival]

    for index,v in pairs(campData) do
        if index ~= "count" then
            local mainRed = false
            local posMain = nil
            for _,sub in pairs(v.sub) do
                local pos = self.campaignIdToPos[sub.id]
                posMain = pos
                mainRed = mainRed or (CampaignManager.Instance.campaignTab[sub.id] ~= nil and SpringFestivalManager.Instance.redPointDic[sub.id] == true)
            end
            if posMain ~= nil then
                self.tree:RedMain(posMain[1], mainRed)
            end
        end
    end
end

