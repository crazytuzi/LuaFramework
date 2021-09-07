-- 万圣节活动面板
-- ljh  20161019

ThanksgivingWindow = ThanksgivingWindow or BaseClass(BaseWindow)

function ThanksgivingWindow:__init(model)
    self.model = model
    self.name = "ThanksgivingWindow"
    self.windowId = WindowConfig.WinID.halloweenwindow

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.halloweenwindow, type = AssetType.Main},
        {file = AssetConfig.thanksgiving_textures, type = AssetType.Dep},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
    }

    self.campaignIdToPos = {}
    self.panelList = {}
    self.panelIdList = {}
    self.lastIndex = 0
    self.lastGroupIndex = 0
    self.checkRedListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ThanksgivingWindow:__delete()
    self.OnHideEvent:Fire()

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

function ThanksgivingWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenwindow))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/BaseItem").gameObject
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false

    t:Find("Main/Title").gameObject:SetActive(true)
    t:Find("Main/Title/Image"):GetComponent(Image).preserveAspect = true
    t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.thanksgiving_textures, "TitleI18N")
    t:Find("Main/TitleText").gameObject:SetActive(false)
    -- t:Find("Main/TitleText/Text"):GetComponent(Text).text = TI18N("感恩节")
end

function ThanksgivingWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ThanksgivingWindow:OnOpen()
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

    self:AddListeners()

    self.openArgs = self.openArgs or {}
    local type = self.openArgs[2] or 1

    self:InitTreeInfo()
    self.tree:SetData(self.treeInfo)

    if self.treeInfo[type].type == CampaignEumn.ThanksgivingType.Exchange then
        type = 2
    end
    self.tree:ClickMain(type, 1)
    self:CheckRedPoint()
end

function ThanksgivingWindow:OnHide()
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

function ThanksgivingWindow:AddListeners()
    ThanksgivingManager.Instance.checkRed:AddListener(self.checkRedListener)
end

function ThanksgivingWindow:RemoveListeners()
    ThanksgivingManager.Instance.checkRed:RemoveListener(self.checkRedListener)
end

function ThanksgivingWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function ThanksgivingWindow:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Thanksgiving]
    local baseCampaignData = DataCampaign.data_list
    self.mayData = tempData
    -- for index,v in pairs(tempData) do
    --     -- if index == CampaignEumn.MayType.Summer then
    --         table.insert(self.mayData, v)
    --     -- end
    -- end
    -- BaseUtils.dump(self.mayData, "<color=#FF0000>mayData</color>")

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
            main.resize = false
            if index == CampaignEumn.ThanksgivingType.Recharge then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "2021")
            elseif index == CampaignEumn.ThanksgivingType.Question then
                main.spriteFunc = function(loader) load:SetSprite(DataItem.data_get[29090].icon) end
            elseif index == CampaignEumn.ThanksgivingType.Active then
                main.iconName = "ActiveIcon"
            elseif index == CampaignEumn.ThanksgivingType.Exchange then
                main.spriteFunc = function(loader) load:SetSprite(DataItem.data_get[90028].icon) end
            end
            local package = main.package or AssetConfig.thanksgiving_textures
            if main.sprite == nil then
                main.sprite = self.assetWrapper:GetSprite(package, main.iconName)
            end
        end
    end
    self.treeInfo = infoTab

    -- BaseUtils.dump(infoTab)

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

function ThanksgivingWindow:ChangeTab(index, subIndex)
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

    local campaignData = DataCampaign.data_list[CampaignManager.Instance.campaignTree[CampaignEumn.Type.Thanksgiving][type].sub[subIndex].id]

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
        if type == CampaignEumn.ThanksgivingType.Recruit then
            panelId = nil
        elseif type == CampaignEumn.ThanksgivingType.Recharge then
            panelId = ContinueChargePanel.New(NewMoonManager.Instance.model, self.rightContainer)
            panelId.campBaseData = DataCampaign.data_list[treeInfoId.id]
        elseif type == CampaignEumn.ThanksgivingType.Active then
            panelId = ThanksgivingActive.New(self.model, self.rightContainer)
        elseif type == CampaignEumn.ThanksgivingType.Question then
            panelId = MidAutumnDesc.New(self.model, self.rightContainer)
            panelId.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Thanksgiving][CampaignEumn.ThanksgivingType.Question]
        elseif type == CampaignEumn.ThanksgivingType.Exchange then
            self.model:OpenExchange()
            return
        end
        self.panelIdList[treeInfoId.id] = panelId
    end

    if panel == nil and panelId ~= nil then
        panel = panelId
        panel.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Thanksgiving][type]
        self.panelList[index][subIndex] = panelId
        -- panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)
    end

    self.lastIndex = index
    self.lastGroupIndex = subIndex

    if panel ~= nil then
        panel:Show(openArgs)
    end
end

function ThanksgivingWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function ThanksgivingWindow:CheckRedPoint()
    local campaignMgr = CampaignManager.Instance
    -- local mayData = campaignMgr.campaignTree[CampaignEumn.Type.May]

    for index,v in pairs(self.mayData) do
        if index ~= "count" then
            local mainRed = false
            local posMain = nil
            for _,sub in pairs(v.sub) do
                if DataCampaign.data_list[sub.id].cond_type ~= CampaignEumn.ShowType.BuyThree then
                    local pos = self.campaignIdToPos[sub.id]
                    posMain = pos[1]
                    mainRed = mainRed or (campaignMgr.redPointDic[sub.id] == true)
                    if pos ~= nil then
                        self.tree:RedSub(pos[1], pos[2], (campaignMgr.redPointDic[sub.id] == true))
                    end
                end
            end
            if posMain ~= nil then
                self.tree:RedMain(posMain, mainRed)
            end
        end
    end
end

