-- @author 黄耀聪
-- @date 2016年9月8日

NewMoonPanel = NewMoonPanel or BaseClass(BasePanel)

function NewMoonPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "NewMoonPanel"
    self.mgr = NewMoonManager.Instance

    self.path = "prefabs/ui/springfestival/springfestivalpanel.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = AssetConfig.may_textures, type = AssetType.Dep},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }
    self.panelIdList = {}
    self.campaignIdToPos = {}
    self.checkRedListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function NewMoonPanel:__delete()
    self.OnHideEvent:Fire()
    if self.tree ~= nil then
        self.tree:DeleteMe()
        self.tree = nil
    end
    if self.panelIdList ~= nil then
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

function NewMoonPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.leftContainer = t:Find("Main/Left/Container").gameObject
    self.baseItem = t:Find("Main/Left/BaseItem").gameObject
    t:Find("Main/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function NewMoonPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NewMoonPanel:OnOpen()
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

    local type = self.openArgs[2] or 1
    self.panelList = {}

    self:InitTreeInfo()
    self.tree:SetData(self.treeInfo)

    -- local pos = {1, 1}
    -- if type ~= nil then
    --     pos = self.campaignIdToPos[type]
    --     if pos == nil then
    --         pos = {1, 1}
    --     end
    -- end

    self.tree:ClickMain(type, 1)
    self.mgr.onUpdateRedPoint:Fire()
end

function NewMoonPanel:OnHide()
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
end

function NewMoonPanel:RemoveListeners()
    self.mgr.onUpdateRedPoint:RemoveListener(self.checkRedListener)
end

function NewMoonPanel:ChangeTab(index, subIndex)
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

    local campaignData = DataCampaign.data_list[CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewMoon][type].sub[subIndex].id]

    local openArgs = {
        activityName = campaignData.name,
        name = campaignData.name,
        startTime = campaignData.cli_start_time[1],
        endTime = campaignData.cli_end_time[1],
        desc = campaignData.cond_desc,
        icon = self.treeInfo[index].iconName,
        bg = "MidAutumnBg",
        target = nil,
        sprite = self.treeInfo[index].sprite,
    }

    if panelId == nil then
        if type == CampaignEumn.NewMoonType.Dice then                       -- 骰子
            panelId = BigDipperPanel.New(model, self.rightContainer)
        elseif type == CampaignEumn.NewMoonType.Recharge then                  -- 连续充值
            panelId = ContinueChargePanel.New(model, self.rightContainer)
        end
        self.panelIdList[treeInfoId.id] = panelId
    end
    if panel == nil then
        panel = panelId
        panel.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewMoon][type]
        self.panelList[index][subIndex] = panelId
        -- panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)
    end

    self.lastIndex = index
    self.lastGroupIndex = subIndex

    if panel ~= nil then
        panel:Show(openArgs)
    end
end

function NewMoonPanel:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function NewMoonPanel:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewMoon]
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
                infoTab[c] = {height = 60, subs = {}, type = v.index, datalist = {}}
                c = c + 1
            end
            local main = infoTab[c - 1]
            main.datalist = v.sub
            main.resize = false
            main.label = baseCampaignData[v.sub[1].id].name
            if v.index == CampaignEumn.NewMoonType.Dice then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "2021")
            elseif v.index == CampaignEumn.NewMoonType.Recharge then
                main.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90002")
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

function NewMoonPanel:CheckRedPoint()
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





