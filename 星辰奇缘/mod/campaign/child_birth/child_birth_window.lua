-- 万圣节活动面板
-- ljh  20161019

ChildBirthWindow = ChildBirthWindow or BaseClass(BaseWindow)

function ChildBirthWindow:__init(model)
    self.model = model
    self.name = "ChildBirthWindow"
    self.windowId = WindowConfig.WinID.ChildBirthWindow

    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.halloweenwindow, type = AssetType.Main},
        {file = AssetConfig.halloween_textures, type = AssetType.Dep},
        {file = AssetConfig.newmoon_textures, type = AssetType.Dep},
        {file = AssetConfig.childbirth_textures, type = AssetType.Dep},
    }

    self.campaignIdToPos = {}
    self.panelList = {}
    self.panelIdList = {}
    self.lastIndex = 0
    self.lastGroupIndex = 0

    self.redListener = function() self:CheckRedPoint() end
    self.iconloader = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ChildBirthWindow:__delete()
    self.OnHideEvent:Fire()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
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

function ChildBirthWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenwindow))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.childbirth_textures, "TitleI18N")

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/BaseItem").gameObject
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function ChildBirthWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ChildBirthWindow:OnOpen()
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

    if self.treeInfo[type].type == CampaignEumn.HalloweenType.Exchange then
        type = 2
    end
    self.tree:ClickMain(type, 1)
end

function ChildBirthWindow:OnHide()
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

function ChildBirthWindow:AddListeners()
    ChildBirthManager.Instance.onCheckRed:AddListener(self.redListener)
end

function ChildBirthWindow:RemoveListeners()
    ChildBirthManager.Instance.onCheckRed:RemoveListener(self.redListener)
end

function ChildBirthWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function ChildBirthWindow:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.ChildBirth]
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
            if index == CampaignEumn.ChildBirthType.Happy then
                main.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90002")
            elseif index == CampaignEumn.ChildBirthType.Colorful then
                local id = main.gameObject:GetInstanceID()
                if self.iconloader[id] == nil then
                    self.iconloader[id] = SingleIconLoader.New(main.gameObject)
                end
                self.iconloader[id]:SetSprite(SingleIconType.Item, DataItem.data_get[29037].icon)
            elseif index == CampaignEumn.ChildBirthType.Flower then
                local id = main.gameObject:GetInstanceID()
                if self.iconloader[id] == nil then
                    self.iconloader[id] = SingleIconLoader.New(main.gameObject)
                end
                self.iconloader[id]:SetSprite(SingleIconType.Item, DataItem.data_get[29037].icon)
            end
            local package = main.package or AssetConfig.halloween_textures
            if main.sprite == nil then
                main.sprite = self.assetWrapper:GetSprite(package, main.iconName)
            end
        end
    end
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

function ChildBirthWindow:ChangeTab(index, subIndex)
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

    local campaignData = DataCampaign.data_list[CampaignManager.Instance.campaignTree[CampaignEumn.Type.ChildBirth][type].sub[subIndex].id]

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
        if type == CampaignEumn.ChildBirthType.Happy then                       --
            panelId = ChildBirthHappyPanel.New(self, self.rightContainer)
        elseif type == CampaignEumn.ChildBirthType.Colorful then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_birth_sub_window, {395})
            return
        elseif type == CampaignEumn.ChildBirthType.Flower then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_birth_sub_window, {397})
            return
        end
        self.panelIdList[treeInfoId.id] = panelId
    end

    if panel == nil then
        panel = panelId
        panel.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.ChildBirth][type]
        self.panelList[index][subIndex] = panelId
        -- panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)
    end

    self.lastIndex = index
    self.lastGroupIndex = subIndex

    if panel ~= nil then
        panel:Show(openArgs)
    end
end

function ChildBirthWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function ChildBirthWindow:CheckRedPoint()
    local campData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.ChildBirth]

    for index,v in pairs(campData) do
        if index ~= "count" then
            local mainRed = false
            local posMain = nil
            for _,sub in pairs(v.sub) do
                local pos = self.campaignIdToPos[sub.id]
                posMain = pos
                mainRed = mainRed or (ChildBirthManager.Instance.redPointDic[sub.id] == true)
            end
            if posMain ~= nil then
                self.tree:RedMain(posMain[1], mainRed)
            end
        end
    end
end