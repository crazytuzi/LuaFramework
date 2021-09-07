LabourBiblePanel = LabourBiblePanel or BaseClass(BasePanel)

function LabourBiblePanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.treeInfo = nil
    self.mgr = BibleManager.Instance

    self.path = "prefabs/ui/springfestival/springfestivalpanel.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
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

function LabourBiblePanel:__delete()
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

function LabourBiblePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "LabourBiblePanel"
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

function LabourBiblePanel:OnOpen()
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

function LabourBiblePanel:OnHide()
    self:RemoveListeners()
end

function LabourBiblePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function LabourBiblePanel:RemoveListeners()
    self.mgr.onUpdateRedPoint:RemoveListener(self.checkRedListener)
end

function LabourBiblePanel:ChangeTab(index)
    local model = self.model
    if self.lastIndex ~= nil and self.lastGroupIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil and self.panelList[self.lastIndex][self.lastGroupIndex] then
            self.panelList[self.lastIndex][self.lastGroupIndex]:Hiden()
        end
    end

    if self.panelList[index] == nil then self.panelList[index] = {} end
    local panel = self.panelList[index][1]

    if panel == nil then
        if self.treeInfo[index].type == CampaignEumn.LabourType.Reward then
            panel = BuyBuyBuy.New(model, self.rightContainer, self.treeInfo[index])
            self.panelList[index][1] = panel
        elseif self.treeInfo[index].type == CampaignEumn.LabourType.Trials then
            panel = LabourBraveTrials.New(model, self.rightContainer, self.treeInfo[index])
            self.panelList[index][1] = panel
        elseif self.treeInfo[index].type == CampaignEumn.LabourType.Monkey then
            panel = LabourBraveTrials.New(model, self.rightContainer, self.treeInfo[index])
            self.panelList[index][1] = panel
        elseif self.treeInfo[index].type == CampaignEumn.LabourType.LuckyBag then
            --守护福袋
            panel = DefendWelfareBagPanel.New(model, self.rightContainer)
            self.panelList[index][1] = panel
        elseif self.treeInfo[index].type == CampaignEumn.LabourType.Eggs then
            --神秘彩蛋
            panel = MysticalEggPanel.New(model, self.rightContainer)
            self.panelList[index][1] = panel
        end
    end

    self.lastIndex = index
    self.lastGroupIndex = 1
    if panel ~= nil then
        panel:Show()
    end
end

function LabourBiblePanel:ClickSub(data)
end

function LabourBiblePanel:InitTreeInfo()
    local baseCampaignData = DataCampaign.data_list
    local labourData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Labour]
    -- BaseUtils.dump(labourData, "<color=#FF0000>labourData</color>")
    local infoTab = {}
    local c = 1
    for index,v in pairs(labourData) do
        if infoTab[c] == nil then
            infoTab[c] = {height = 60, subs = {}, type = v.index, datalist = {}}
            c = c + 1
        end
        local main = infoTab[c - 1]
        main.datalist = v.sub
        if index == CampaignEumn.LabourType.Reward then
            main.label = TI18N("劳动光荣礼包")
            main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "SpringIcon2")
        elseif index == CampaignEumn.LabourType.Trials then
            main.label = TI18N("四季试炼")
            for k,sub in pairs(v.sub) do
                main.label = baseCampaignData[sub.id].name
            end
            main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "ActitIcon")
        elseif index == CampaignEumn.LabourType.Monkey then
            main.label = TI18N("点石成金")
            for k,sub in pairs(v.sub) do
                main.label = baseCampaignData[sub.id].name
            end
            main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "2021")
        elseif index == CampaignEumn.LabourType.LuckyBag then
            main.label = TI18N("守护福袋")
            main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "I18Ndwb1")
        elseif index == CampaignEumn.LabourType.Eggs then
            main.label = TI18N("神秘彩蛋")
            main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "Dice")
        end
    end
    self.treeInfo = infoTab
    BaseUtils.dump(infoTab, "<color=#FF0000>infoTab</color>")

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

function LabourBiblePanel:CheckRedPoint()
    local campaignMgr = CampaignManager.Instance
    local labourData = campaignMgr.campaignTree[CampaignEumn.Type.Labour]

    for _,v in pairs(labourData) do
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



