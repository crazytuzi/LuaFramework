ChildBiblePanel = ChildBiblePanel or BaseClass(BasePanel)

function ChildBiblePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ChildBiblePanel"

    self.treeInfo = nil
    self.mgr = BibleManager.Instance

    self.activityName = TI18N("六一活动")
    self.dragonBoatName = TI18N("端午活动")

    self.path = "prefabs/ui/springfestival/springfestivalpanel.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = AssetConfig.may_textures, type = AssetType.Dep},
    }

    self.panelIdList = {}

    -- 这是一个二级panel列表，
    -- 结构如下
    -- self.panelList = {
    --     [index] = {
    --         [group_index] = panel
    --     }
    -- }
    self.panelList = {}

    -- 活动id对应面板位置
    -- 结构如下
    -- self.campaignIdToPos = {
    --     [campaignId] = {[1] = main, [2] = sub}
    -- }
    self.campaignIdToPos = {}

    self.checkRedListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ChildBiblePanel:__delete()
    self.OnHideEvent:Fire()
    if self.tree ~= nil then
        self.tree:DeleteMe()
        self.tree = nil
    end
    if self.panelList ~= nil then
        for _,panelTab in pairs(self.panelIdList) do
            if panelTab ~= nil then
                panelTab:DeleteMe()
            end
        end
        self.panelList = nil
        self.panelIdList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ChildBiblePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t

    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.leftContainer = self.transform:Find("Main/Left/Container").gameObject
    self.baseItem = self.transform:Find("Main/Left/BaseItem").gameObject
    self.transform:Find("Main/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = self.transform:Find("Main/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function ChildBiblePanel:OnOpen()
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
    self.mgr.onUpdateRedPoint:AddListener(self.checkRedListener)

    local type = self.model.currentSub
    self.panelList = {}

    self:InitTreeInfo()
    self.tree:SetData(self.treeInfo)

    local pos = {1, 1}
    if type ~= nil then
        pos = self.campaignIdToPos[type]
        if pos == nil then
            pos = {1, 1}
        end
    end

    self.tree:ClickMain(pos[1], pos[2])
    self.mgr.onUpdateRedPoint:Fire()
end

function ChildBiblePanel:OnHide()
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
end

function ChildBiblePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ChildBiblePanel:RemoveListeners()
    self.mgr.onUpdateRedPoint:RemoveListener(self.checkRedListener)
end

function ChildBiblePanel:ChangeTab(index, subIndex)
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

    local campaignData = DataCampaign.data_list[CampaignManager.Instance.campaignTree[CampaignEumn.Type.Children][type].sub[subIndex].id]

    local openArgs = {
        activityName = campaignData.reward_title,
        name = campaignData.name,
        startTime = campaignData.cli_start_time[1],
        endTime = campaignData.cli_end_time[1],
        desc = campaignData.cond_desc,
        icon = self.treeInfo[index].iconName,
        bg = "ChildBg",
        target = nil,
    }

    if panelId == nil then
        if type == CampaignEumn.ChildType.Login then
            panelId = LoginTotalPanel.New(model, self.rightContainer)     -- 累计登录
        elseif type == CampaignEumn.ChildType.Manager then
            panelId = PathFindingPanel.New(model, self.rightContainer)     -- 小鬼当家
        elseif type == CampaignEumn.ChildType.Candy then
            panelId = PathFindingPanel.New(model, self.rightContainer)     -- 糖果总动员
        elseif type == CampaignEumn.ChildType.Happy then
            -- panelId = BuyThreePanel.New(model, self.rightContainer)
            -- panelId.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Children][type]
        elseif type == CampaignEumn.ChildType.Cake then
            panelId = ExchangeActivityPanel.New(model, self.rightContainer)
            panelId.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Children][type].sub[subIndex]
        elseif type == CampaignEumn.ChildType.DragonBoat then
            panelId = PathFindingPanel.New(model, self.rightContainer)     -- 赛龙舟
        elseif type == CampaignEumn.ChildType.RiverTroll then
            panelId = PathFindingPanel.New(model, self.rightContainer)     -- 清河妖
        elseif type == CampaignEumn.ChildType.Total then                   -- 累计充值
            panelId = TotalReturn.New(model, self.rightContainer)
            panelId.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Children][type]
        end
        self.panelIdList[treeInfoId.id] = panelId
    end

    if type == CampaignEumn.ChildType.Login then
    elseif type == CampaignEumn.ChildType.Manager then
        openArgs.target = "50_1"
    elseif type == CampaignEumn.ChildType.Candy then
        openArgs.target = "50_1"
    elseif type == CampaignEumn.ChildType.DragonBoat then
        openArgs.target = "51_1"
        openArgs.bg = "DragonboatBg"
    elseif type == CampaignEumn.ChildType.RiverTroll then
        openArgs.target = "51_1"
        openArgs.bg = "DragonboatBg"
    end

    if panel == nil then
        panel = panelId
        self.panelList[index][subIndex] = panelId
        -- panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)
        -- panel.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.May][type]
    end

    self.lastIndex = index
    self.lastGroupIndex = subIndex
    if panel ~= nil then
        panel:Show(openArgs)
    end
end

function ChildBiblePanel:ClickSub(data)
    BaseUtils.dump(data, "subdata")
    self:ChangeTab(data[1], data[2])
end

function ChildBiblePanel:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Children]
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
        if index ~= "count" and v.index ~= CampaignEumn.ChildType.Happy then
            if infoTab[c] == nil then
                infoTab[c] = {height = 60, subs = {}, type = v.index, datalist = {}}
                c = c + 1
            end
            local main = infoTab[c - 1]
            main.datalist = v.sub
            main.label = baseCampaignData[v.sub[1].id].name
            if v.index == CampaignEumn.ChildType.Login then
                main.iconName = "Clock"
            elseif v.index == CampaignEumn.ChildType.Manager then
                main.iconName = "Lollipop"
            elseif v.index == CampaignEumn.ChildType.Candy then
                main.iconName = "Candy"
            elseif v.index == CampaignEumn.ChildType.Happy then
                main.iconName = "2021"
                main.package = AssetConfig.springfestival_texture
            elseif v.index == CampaignEumn.ChildType.Cake then
                main.iconName = "DumplingMaking"
                main.package = AssetConfig.may_textures
                for i,sub1 in ipairs(v.sub) do
                    local campaignData = baseCampaignData[sub1.id]
                    main.subs[i] = {label = campaignData.reward_title, height = 45, callbackData = {c - 1, i}}
                end
            elseif v.index == CampaignEumn.ChildType.DragonBoat then
                main.iconName = "DragonBoat"
                main.package = AssetConfig.may_textures
            elseif v.index == CampaignEumn.ChildType.RiverTroll then
                main.iconName = "RiverTroll"
                main.package = AssetConfig.may_textures
            elseif v.index == CampaignEumn.ChildType.Total then
                main.iconName = "QingmingIcon4"
                main.package = AssetConfig.springfestival_texture
            end
            local package = main.package or AssetConfig.may_textures
            main.sprite = self.assetWrapper:GetSprite(package, main.iconName)
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

function ChildBiblePanel:CheckRedPoint()
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



