ValentineWindow = ValentineWindow or BaseClass(BaseWindow)

function ValentineWindow:__init(model)
    self.model = model
    self.name = "ValentineWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.valentine_window

    self.resList = {
        {file = AssetConfig.halloweenwindow, type = AssetType.Main}
        , {file = AssetConfig.may_textures, type = AssetType.Dep}
        ,{file = AssetConfig.marchevent_texture, type = AssetType.Dep}
    }

    self.panelList = {}
    self.panelIdList = {}

    self.redListener = function() self:CheckRedPoint() end
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ValentineWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t
    self.transform:SetAsLastSibling()

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self.model:CloseWindow() end)
    self.titleImg = t:Find("Main/Title/Image"):GetComponent(Image)

    -- t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.SpringFestival_textures, "TitleI18N")

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/BaseItem").gameObject
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function ValentineWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ValentineWindow:__delete()
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

function ValentineWindow:OnOpen()
    self.transform:SetAsLastSibling()
    if self.panelList ~= nil then
        for _,panelTab in pairs(self.panelList) do
            if panelTab ~= nil then
                for _,v in pairs(panelTab) do
                    v:Hiden()
                end
            end
        end
    end

--    if ValentineManager.Instance:CheckValentineOnly() then
--        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "TitleI18N2")
--    else
--        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "TitleI18N")
--    end

    self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.marchevent_texture, "textImag2_ti18n")
    self:RemoveListeners()
    ValentineManager.Instance.redPointEvent:AddListener(self.redListener)

    self.openArgs = self.openArgs or {}

    self:InitTreeInfo()
    self.tree:SetData(self.treeInfo)


    if self.openArgs[1] ~= nil then
        self.pos = self.campaignIdToPos[self.openArgs[1]]
    else
        if ValentineManager.Instance.sevenLoginData.flag == 0 and ValentineManager.Instance.sevenLoginData.num < 7 then
            self.pos = self.campaignIdToPos[582]
        else
            self.pos = self.campaignIdToPos[567]
        end
    end

    self.pos = self.pos or {1}

    self.tree:ClickMain(self.pos[1], self.pos[2])

    self:CheckRedPoint()
end

function ValentineWindow:OnHide()
    self:RemoveListeners()
end

function ValentineWindow:RemoveListeners()
    ValentineManager.Instance.redPointEvent:RemoveListener(self.redListener)
end

function ValentineWindow:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine]
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
            if index == CampaignEumn.ValentineType.Love then
                 main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item,DataItem.data_get[90018].icon) end
            elseif index == CampaignEumn.ValentineType.Chocolate then
                main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item,DataItem.data_get[22530].icon) end
            elseif index == CampaignEumn.ValentineType.Spirit then
               main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift5")
            elseif index == CampaignEumn.ValentineType.CakeExchange then
               main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item,DataItem.data_get[90039].icon) end
            elseif index == CampaignEumn.ValentineType.Recharge then
               main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item,DataItem.data_get[90002].icon) end
            end

            local package = main.package or AssetConfig.may_textures
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

function ValentineWindow:ChangeTab(index, subIndex)
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
        if type == CampaignEumn.ValentineType.Recharge then
            panelId = DoubleElevenFeedbackPanel.New(model, self.rightContainer)
            panelId.bg = AssetConfig.feedbackbg
            panelId.campaignData = campaignData
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})

            -- panelId = GiveMeYourHand.New(self.model, self.rightContainer)
            -- panelId.afterSprintFunc = function(loader) loader:SetSprite(SingleIconType.Item, DataItem.data_get[20044].icon) end
            -- panelId.bg = AssetConfig.valentine_bg
            -- table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campId = campaignData.id
            panelId.target = "44_1"
       elseif type == CampaignEumn.ValentineType.CakeExchange then
            if ValentineManager.Instance:CheckCakeExchange() then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.cakeexchangwindow)
            end
            return
        elseif type == CampaignEumn.ValentineType.Reward then
            panelId = RewardIOU.New(self.model, self.rightContainer)
            panelId.icon = self.assetWrapper:GetSprite(AssetConfig.may_textures, "WithYou")
            panelId.bg = AssetConfig.valentine_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine][CampaignEumn.ValentineType.Reward]
        elseif type == CampaignEumn.ValentineType.Chocolate then
            -- panelId = RoseCasting.New(self.model, self.rightContainer)
            -- panelId.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine][type]
            -- panelId.icon = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift2")

            panelId = SevenLoginPanel.New(self.model,self.rightContainer)
            panelId = treeInfoId.id
            panelId.bg = AssetConfig.seven_login_big_bg
            -- panelId.afterSprintFunc = function(loader) loader:SetSprite(SingleIconType.Item, DataItem.data_get[29037].icon) end
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ValentineType.Lantern then
            panelId = MidAutumnDesc.New(self.model, self.rightContainer)
            panelId.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine][CampaignEumn.ValentineType.Lantern]
            panelId.bg = AssetConfig.valentine_lantern_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ValentineType.Exchange then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.valentine_exchange)
            return
        elseif type == CampaignEumn.ValentineType.Love then
            panelId = LoveConnection.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.whitevalentine_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campData = campaignData
            panelId.targetNpc = nil
        elseif type == CampaignEumn.ValentineType.Spirit then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marchevent_window,{2})
            return
        end
    end

    if panelId ~= nil then
        panel = panelId
        -- panel.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine][type]
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

function ValentineWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function ValentineWindow:CheckRedPoint()
    local campData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine]
    -- BaseUtils.dump(campData,"红点监测打开方法付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付")
    -- BaseUtils.dump(ValentineManager.Instance.redPointDic,"红点监测打开方法付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付付")
    for index,v in pairs(campData) do
        if index ~= "count" then
            local mainRed = false
            local posMain = nil
            for _,sub in pairs(v.sub) do
                local pos = self.campaignIdToPos[sub.id]
                posMain = pos
                mainRed = mainRed or (CampaignManager.Instance.campaignTab[sub.id] ~= nil and ValentineManager.Instance.redPointDic[sub.id] == true)
            end
            if posMain ~= nil then
                self.tree:RedMain(posMain[1], mainRed)
            end
        end
    end
end
