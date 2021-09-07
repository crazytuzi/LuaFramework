NewLabourWindow = NewLabourWindow or BaseClass(BaseWindow)

function NewLabourWindow:__init(model)
    self.model = model
    self.name = "NewLabourWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.newlabourwindow

    self.resList = {
        {file = AssetConfig.halloweenwindow, type = AssetType.Main},
        {file = AssetConfig.may_textures, type = AssetType.Dep},
        {file = AssetConfig.halloween_textures, type = AssetType.Dep},
        {file = AssetConfig.newmoon_textures, type = AssetType.Dep},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
    }

    self.panelList = {}
    self.panelIdList = {}

    self.redListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function NewLabourWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self.model:CloseWindow() end)
    self.titleImg = t:Find("Main/Title/Image"):GetComponent(Image)
    self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, string.format("Title%sI18N",NewLabourManager.SYSTEM_ID))

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/BaseItem").gameObject
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function NewLabourWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NewLabourWindow:__delete()
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

function NewLabourWindow:OnOpen()
    if self.panelList ~= nil then
        for _,panelTab in pairs(self.panelList) do
            if panelTab ~= nil then
                for _,v in pairs(panelTab) do
                    v:Hiden()
                end
            end
        end
    end

    self:RemoveListeners()
    NewLabourManager.Instance.redPointEvent:AddListener(self.redListener)

    self.openArgs = self.openArgs or {}

    self:InitTreeInfo()
    self.tree:SetData(self.treeInfo)

    if self.openArgs[1] ~= nil then
        self.pos = self.campaignIdToPos[self.openArgs[1]] or {1, 1}
    else
        if self.pos == nil then
            self.pos = {1, 1}
        end
    end

    self.tree:ClickMain(self.pos[1], self.pos[2])

    self:CheckRedPoint()
end

function NewLabourWindow:OnHide()
    self:RemoveListeners()
end

function NewLabourWindow:RemoveListeners()
    NewLabourManager.Instance.redPointEvent:RemoveListener(self.redListener)
end

function NewLabourWindow:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewLabour]
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
            if index == CampaignEumn.NewLahourType.Type1 then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "newlabhour1")
            elseif index == CampaignEumn.NewLahourType.Type2 then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "newlabhour2")
            elseif index == CampaignEumn.NewLahourType.Type3 then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "newlabhour3")
            elseif index == CampaignEumn.NewLahourType.Group then
                main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item, 29061) end
            elseif index == CampaignEumn.NewLahourType.Back then
                main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item, 90002) end
            elseif index == CampaignEumn.NewLahourType.Reward then
                main.spriteFunc = function(loader) loader:SetSprite(SingleIconType.Item, 22529) end
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

function NewLabourWindow:ChangeTab(index, subIndex)
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
        if type == CampaignEumn.NewLahourType.Type1 then
           panelId = DefendWelfareBagPanel.New(self.model, self.rightContainer)
        elseif type == CampaignEumn.NewLahourType.Type2 then
            panelId = NewLabourTypePanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.newlahourbgi18n
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campData = campaignData
            panelId.targetNpc = "86_1"
            panelId.btnName = TI18N("前去清扫")
        elseif type == CampaignEumn.NewLahourType.Type3 then
            panelId = NewLabourTypePanel.New(self.model, self.rightContainer)
            panelId.bg =AssetConfig.newlahourbgi18n
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campData = campaignData
            panelId.targetNpc = "86_1"
            panelId.btnName = TI18N("前去寻找")
            panelId.hideBtn = false
        elseif type == CampaignEumn.NewLahourType.Back then
            panelId = DoubleElevenFeedbackPanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.feedbackbg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campaignData = campaignData
        elseif type == CampaignEumn.NewLahourType.Group then
            panelId = DoubleElevenGroupBuyPanel.New(DoubleElevenManager.Instance.model, self.rightContainer, self.gameObject)
            panelId.bg = AssetConfig.groupbuybg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.NewLahourType.Reward then
            panelId = HalloweenMoonPanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.rewardbg
            panelId.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewLabour][type]
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
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

function NewLabourWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function NewLabourWindow:CheckRedPoint()
    local campData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewLabour]
    for index,v in pairs(campData) do
        if index ~= "count" then
            local mainRed = false
            local posMain = nil
            for _,sub in pairs(v.sub) do
                local pos = self.campaignIdToPos[sub.id]
                posMain = pos
                 mainRed = mainRed or (CampaignManager.Instance.campaignTab[sub.id] ~= nil and NewLabourManager.Instance.redPointDic[sub.id] == true)
            end
            if posMain ~= nil then
                 self.tree:RedMain(posMain[1], mainRed)
            end
        end
    end
end
