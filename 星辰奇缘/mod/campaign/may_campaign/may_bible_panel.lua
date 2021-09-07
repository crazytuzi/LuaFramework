MayBiblePanel = MayBiblePanel or BaseClass(BasePanel)

function MayBiblePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MayBiblePanel"

    self.treeInfo = nil
    self.mgr = BibleManager.Instance

    self.path = "prefabs/ui/springfestival/springfestivalpanel.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = AssetConfig.may_textures, type = AssetType.Dep},
    }

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

function MayBiblePanel:__delete()
    self.OnHideEvent:Fire()
    if self.tree ~= nil then
        self.tree:DeleteMe()
        self.tree = nil
    end
    if self.panelList ~= nil then
        for _,panelTab in pairs(self.panelList) do
            if panelTab ~= nil then
                for _,v in pairs(panelTab) do
                    v:DeleteMe()
                end
            end
        end
        self.panelList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MayBiblePanel:InitPanel()
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

function MayBiblePanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onUpdateRedPoint:AddListener(self.checkRedListener)

    local type = self.model.currentSub

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

function MayBiblePanel:OnHide()
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

function MayBiblePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MayBiblePanel:RemoveListeners()
    self.mgr.onUpdateRedPoint:RemoveListener(self.checkRedListener)
end

function MayBiblePanel:ChangeTab(index)
    local model = self.model
    if self.lastIndex ~= nil and self.lastGroupIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil and self.panelList[self.lastIndex][self.lastGroupIndex] then
            self.panelList[self.lastIndex][self.lastGroupIndex]:Hiden()
        end
    end

    if self.panelList[index] == nil then self.panelList[index] = {} end
    local panel = self.panelList[index][1]

    if panel == nil then
        local type = self.treeInfo[index].type
        if type == CampaignEumn.MayType.Total then
            panel = TotalReturn.New(model, self.rightContainer)     -- 充值送豪礼
            -- panel.icon = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "SpringIcon2")
        elseif type == CampaignEumn.MayType.Summer then
            panel = BuyThreePanel.New(model, self.rightContainer)   -- 炎炎夏日礼包
            -- panel.icon = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "SpringIcon2")
        elseif type == CampaignEumn.MayType.Hand then
            panel = GiveMeYourHand.New(model, self.rightContainer)  -- 执子之手
            -- panel.icon = self.assetWrapper:GetSprite(AssetConfig.may_textures, "WithYou")
        elseif type == CampaignEumn.MayType.Rose then
            panel = RoseCasting.New(model, self.rightContainer)     -- 玫瑰传情
            -- panel.icon = self.assetWrapper:GetSprite(AssetConfig.may_textures, "RoseLove")
        elseif type == CampaignEumn.MayType.Reward then
            panel = RewardIOU.New(model, self.rightContainer)       -- 恋爱季礼盒
            -- panel.icon = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "SpringIcon2")
        end
        self.panelList[index][1] = panel
        panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)
        panel.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.May][type]
    end

    self.lastIndex = index
    self.lastGroupIndex = 1
    if panel ~= nil then
        panel:Show()
    end
end

function MayBiblePanel:ClickSub(data)
end

function MayBiblePanel:InitTreeInfo()
    local baseCampaignData = DataCampaign.data_list
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.May]
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
        if infoTab[c] == nil then
            infoTab[c] = {height = 60, subs = {}, type = v.index, datalist = {}}
            c = c + 1
        end
        local main = infoTab[c - 1]
        main.datalist = v.sub
        if v.index == CampaignEumn.MayType.Total then
            main.label = TI18N("充值送豪礼")
            main.package = AssetConfig.springfestival_texture
            main.iconName = "2021"
        elseif v.index == CampaignEumn.MayType.Summer then
            main.label = TI18N("盛夏光年")
            main.package = AssetConfig.springfestival_texture
            main.iconName = "SpringIcon2"
        elseif v.index == CampaignEumn.MayType.Hand then
            main.label = TI18N("执子之手")
            main.package = AssetConfig.may_textures
            main.iconName = "WithYou"
        elseif v.index == CampaignEumn.MayType.Rose then
            main.label = TI18N("玫瑰传情")
            main.package = AssetConfig.may_textures
            main.iconName = "RoseLove"
            main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "RoseLove")
        elseif v.index == CampaignEumn.MayType.Reward then
            main.label = TI18N("恋爱季礼盒")
            main.package = AssetConfig.springfestival_texture
            main.iconName = "QingmingIcon4"
        end
        main.sprite = self.assetWrapper:GetSprite(main.package, main.iconName)
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

function MayBiblePanel:CheckRedPoint()
    local campaignMgr = CampaignManager.Instance
    -- local mayData = campaignMgr.campaignTree[CampaignEumn.Type.May]

    for _,v in pairs(self.mayData) do
        local mainRed = false
        local posMain = nil
        for _,sub in pairs(v.sub) do
            local pos = self.campaignIdToPos[sub.id]
            posMain = pos[1]
            mainRed = mainRed or (campaignMgr.redPointDic[sub.id] == true)
            if pos ~= nil then
                self.tree:RedSub(pos[1], pos[2], (campaignMgr.redPointDic[sub.id] == true))
            end
        end
        if posMain ~= nil then
            self.tree:RedMain(posMain, mainRed)
        end
    end
end



