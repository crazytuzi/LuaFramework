-- 万圣节活动面板
-- ljh  20161019

FoolWindow = FoolWindow or BaseClass(BaseWindow)

function FoolWindow:__init(model)
    self.model = model
    self.name = "FoolWindow"
    self.windowId = WindowConfig.WinID.foolwindow

    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.halloweenwindow, type = AssetType.Main},
        {file = AssetConfig.halloween_textures, type = AssetType.Dep},
        {file = AssetConfig.newmoon_textures, type = AssetType.Dep},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.campaignIdToPos = {}
    self.panelList = {}
    self.panelIdList = {}
    self.lastIndex = 0
    self.lastGroupIndex = 0

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function FoolWindow:__delete()
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

function FoolWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenwindow))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.halloween_textures, "TitleI18N")
    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/BaseItem").gameObject
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function FoolWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function FoolWindow:OnOpen()
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

    if self.treeInfo[type].type == CampaignEumn.FoolType.Exchange then
        type = 2
    end
    self.tree:ClickMain(type, 1)
end

function FoolWindow:OnHide()
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

function FoolWindow:AddListeners()
end

function FoolWindow:RemoveListeners()
end

function FoolWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function FoolWindow:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Fool]
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
            if index == CampaignEumn.FoolType.Back then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures, "WelfareIcon9")
            elseif index == CampaignEumn.FoolType.Group then
                main.iconName = "Reward"
            end
            local package = main.package or AssetConfig.halloween_textures
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

function FoolWindow:ChangeTab(index, subIndex)
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

    local campaignData = DataCampaign.data_list[CampaignManager.Instance.campaignTree[CampaignEumn.Type.Fool][type].sub[subIndex].id]

    -- print(type)

    if panelId == nil then
        if type == CampaignEumn.FoolType.Group then                       -- 团购
            panelId = DoubleElevenGroupBuyPanel.New(DoubleElevenManager.Instance.model, self.rightContainer, self.gameObject)
            panelId.bg = AssetConfig.groupbuybg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.FoolType.Back then                       -- 返利
            panelId = DoubleElevenFeedbackPanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.feedbackbg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campaignData = campaignData
        elseif type == CampaignEumn.FoolType.Reward then
            panelId = HalloweenMoonPanel.New(self.model, self.rightContainer)
        end
        self.panelIdList[treeInfoId.id] = panelId
    end

    if panel == nil then
        panel = panelId
        panel.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Fool][type]
        self.panelList[index][subIndex] = panelId
        -- panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)
    end

    self.lastIndex = index
    self.lastGroupIndex = subIndex

    if panel ~= nil then
        panel:Show()
    end
end

function FoolWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end


