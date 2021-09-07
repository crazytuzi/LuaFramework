-- @author 黄耀聪
-- @date 2017年5月12日

MayIOUWindow = MayIOUWindow or BaseClass(BaseWindow)

function MayIOUWindow:__init(model)
    self.model = model
    self.name = "MayIOUWindow"
    self.cacheMode = CacheMode.Visible
    self.windowId = WindowConfig.WinID.may_iou_window

    self.resList = {
        {file = AssetConfig.halloweenwindow, type = AssetType.Main},
        {file = AssetConfig.valentine_textures, type = AssetType.Dep},
        {file = AssetConfig.may_textures, type = AssetType.Dep},
    }

    self.panelList = {}
    self.panelIdList = {}

    self.redListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MayIOUWindow:__delete()
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
    self:AssetClearAll()
end

function MayIOUWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.titleImg = t:Find("Main/Title/Image"):GetComponent(Image)

    t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.valentine_textures, "TitleI18N1")
    t:Find("Main/Title/Image"):GetComponent(Image):SetNativeSize()

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/BaseItem").gameObject
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function MayIOUWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end


function MayIOUWindow:OnOpen()
    if self.panelList ~= nil then
        for _,panelTab in pairs(self.panelList) do
            if panelTab ~= nil then
                for _,v in pairs(panelTab) do
                    if v ~= nil then
                      v:Hiden()
                    end
                end
            end
        end
    end

    self:RemoveListeners()
    MayIOUManager.Instance.redPointEvent:AddListener(self.redListener)

    self.openArgs = self.openArgs or {}

    self:InitTreeInfo()
    self.tree:SetData(self.treeInfo)

    if self.openArgs[1] ~= nil then
        self.pos = self.campaignIdToPos[self.openArgs[1]]
    else
        if self.pos == nil then
            self.pos = {1, 1}
        end
    end

    self.tree:ClickMain(self.pos[1], self.pos[2])

    BaseUtils.dump(CampaignEumn.MayIOUType, "MayIOUType")

    self:CheckRedPoint()
end

function MayIOUWindow:OnHide()
    self:RemoveListeners()
end

function MayIOUWindow:RemoveListeners()
    MayIOUManager.Instance.redPointEvent:RemoveListener(self.redListener)
end

function MayIOUWindow:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU]
    local baseCampaignData = DataCampaign.data_list
    self.mayData = tempData
    local infoTab = {}
    local c = 1
    for index,v in pairs(self.mayData) do
        if index ~= "count" then
            if index ~= CampaignEumn.MayIOUType.Intimacy or CampaignManager.Instance:CheckIntimacy() then
                if infoTab[c] == nil then
                    infoTab[c] = {height = 60, subs = {}, type = index, datalist = {}, resize = false}
                    c = c + 1
                end
                local main = infoTab[c - 1]
                main.datalist = v.sub
                main.label = baseCampaignData[v.sub[1].id].name
                -- print(main.label)
                main.sprite = nil
                if index == CampaignEumn.MayIOUType.Intimacy then
                    main.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90018")
                elseif index == CampaignEumn.MayIOUType.Recharge then
                    main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift2")
                elseif index == CampaignEumn.MayIOUType.Bird then
                    main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift1")
                elseif index == CampaignEumn.MayIOUType.Reward then
                    main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "WithYou")
                elseif index == CampaignEumn.MayIOUType.Love then
                    main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item, DataItem.data_get[90018].icon) end
                elseif index == CampaignEumn.MayIOUType.Hand then
                    main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item, DataItem.data_get[20044].icon) end
                elseif index == CampaignEumn.MayIOUType.Chocolate then
                    main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift2")
                elseif index == CampaignEumn.MayIOUType.Lantern then
                    main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item, DataItem.data_get[29037].icon) end
                elseif index == CampaignEumn.MayIOUType.Exchange then
                    main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item, DataItem.data_get[90034].icon) end
                end
                local package = main.package or AssetConfig.may_textures
                if main.sprite == nil then
                    main.sprite = self.assetWrapper:GetSprite(package, main.iconName)
                end
            end
        end
    end
    table.sort(infoTab, function(a,b) return a.type < b.type end)
    self.treeInfo = infoTab
    BaseUtils.dump(infoTab,"YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY")
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

function MayIOUWindow:ChangeTab(index, subIndex)
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
        if type == CampaignEumn.MayIOUType.Intimacy then
            panelId = IntiMacyPanel.New(self.rightContainer)
            panelId.campBaseData = campaignData
        elseif type == CampaignEumn.MayIOUType.Recharge then
            -- panelId = ContinueChargePanel.New(NewMoonManager.Instance.model, self.rightContainer)
            -- panelId = TotalReturn.New(model, self.rightContainer)
            -- panelId.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU][CampaignEumn.MayIOUType.Recharge]
            -- panelId = NewYearReward.New(self.model, self.rightContainer)
            -- panelId.campaignGroup = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU][CampaignEumn.MayIOUType.Recharge]
            panelId = ContinueChargePanel.New(NewMoonManager.Instance.model, self.rightContainer)
            panelId.campBaseData = campaignData
        elseif type == CampaignEumn.MayIOUType.Bird then
            panelId = DoubleElevenFeedbackPanel.New(model, self.rightContainer)
            panelId.bg = AssetConfig.childbirth_feedback_bg
            panelId.campaignData = campaignData
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.MayIOUType.Reward then
            panelId = RewardIOU.New(self.model, self.rightContainer)
            panelId.icon = self.assetWrapper:GetSprite(AssetConfig.may_textures, "WithYou")
            panelId.bg = AssetConfig.valentine_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU][CampaignEumn.MayIOUType.Reward]
        elseif type == CampaignEumn.MayIOUType.Hand then
            panelId = GiveMeYourHand.New(self.model, self.rightContainer)
            panelId.afterSprintFunc = function(loader) loader:SetSprite(SingleIconType.Item, DataItem.data_get[20044].icon) end
            panelId.bg = AssetConfig.valentine_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campId = campaignData.id
            panelId.target = "44_1"
        elseif type == CampaignEumn.MayIOUType.Chocolate then
            -- panelId = RoseCasting.New(self.model, self.rightContainer)
            -- panelId.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU][type]
            -- panelId.icon = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift2")

            panelId = HalloweenMoonPanel.New(self.model, self.rightContainer)
            panelId.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU][type]
            panelId.bg = AssetConfig.valentine_bg
            panelId.afterSprintFunc = function(loader) loader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift2")) end
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.MayIOUType.Lantern then
            panelId = MidAutumnDesc.New(self.model, self.rightContainer)
            panelId.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU][CampaignEumn.MayIOUType.Lantern]
            panelId.bg = AssetConfig.valentine_lantern_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.MayIOUType.Exchange then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.valentine_exchange)
            return
        elseif type == CampaignEumn.MayIOUType.Love then
            panelId = LoveConnection.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.whitevalentine_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campData = campaignData
            panelId.targetNpc = nil
        end
    end

    if panelId ~= nil then
        panel = panelId
        if type == CampaignEumn.MayIOUType.Intimacy then
            if CampaignManager.Instance:CheckIntimacy() then
                if IntimacyManager.Instance == nil then
                    IntimacyManager.New()
                end
                IntimacyManager.Instance:Send17858()
                IntimacyManager.Instance:Send17859()
                IntimacyManager.Instance:Send17860()
            else
                if IntimacyManager.Instance ~= nil then
                    IntimacyManager.Instance:DeleteMe()
                    IntimacyManager.Instance = nil
                end
                return
           end
        end
        -- panel.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU][type]
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

function MayIOUWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function MayIOUWindow:CheckRedPoint()
    local campData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU]

    for index,v in pairs(campData) do
        if index ~= "count" then
            local mainRed = false
            local posMain = nil
            for _,sub in pairs(v.sub) do
                local pos = self.campaignIdToPos[sub.id]
                posMain = pos
                mainRed = mainRed or (CampaignManager.Instance.campaignTab[sub.id] ~= nil and MayIOUManager.Instance.redPointDic[sub.id] == true)
            end
            if posMain ~= nil then
                self.tree:RedMain(posMain[1], mainRed)
            end
        end
    end
end



