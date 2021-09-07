-- @author 黄耀聪
-- @date 2016年9月8日

MidAutumnPanel = MidAutumnPanel or BaseClass(BasePanel)

function MidAutumnPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MidAutumnPanel"
    self.mgr = BibleManager.Instance

    self.path = "prefabs/ui/springfestival/springfestivalpanel.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = AssetConfig.midAutumn_textures, type = AssetType.Dep},
        {file = AssetConfig.may_textures, type = AssetType.Dep},
        {file = AssetConfig.midAutumnBg, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }
    self.panelIdList = {}
    self.campaignIdToPos = {}
    self.checkRedListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MidAutumnPanel:__delete()
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

function MidAutumnPanel:InitPanel()
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

function MidAutumnPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MidAutumnPanel:OnOpen()
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

function MidAutumnPanel:OnHide()
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

function MidAutumnPanel:RemoveListeners()
    self.mgr.onUpdateRedPoint:RemoveListener(self.checkRedListener)
end

function MidAutumnPanel:ChangeTab(index, subIndex)
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

    local campaignData = DataCampaign.data_list[CampaignManager.Instance.campaignTree[CampaignEumn.Type.MidAutumn][type].sub[subIndex].id]

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
        if type == CampaignEumn.MidAutumnType.SkyLantern then                       -- 孔明灯会
            panelId = MidAutumnDesc.New(model, self.rightContainer, AssetConfig.midAutumnBg)
            openArgs.initcallback = function(panel) panel.bottom:SetActive(false) end
        elseif type == CampaignEumn.MidAutumnType.Reward then                  -- 花好月圆礼包
            panelId = MidAutumnReward.New(model, self.rightContainer)
        elseif type == CampaignEumn.MidAutumnType.EnjoyMoon then               -- 中秋赏月夜
            panelId = EnjoyMoonPanel.New(model, self.rightContainer, AssetConfig.midAutumnBg)
        elseif type == CampaignEumn.MidAutumnType.Dress then                   -- 赏月礼服
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {1, 4})
            return
        elseif type == CampaignEumn.MidAutumnType.Feedback then                -- 暖心回馈
            panelId = MidAutumnFeedback.New(model, self.rightContainer)
        elseif type == CampaignEumn.MidAutumnType.Exchange then                -- 中秋兑换
            local datalist = {}
            local lev = RoleManager.Instance.RoleData.lev
            for i,v in pairs(ShopManager.Instance.model.datalist[2][7]) do
                table.insert(datalist, v)
            end
            BaseUtils.dump(datalist)
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = TI18N("中秋兑换"), extString = "{assets_2,90025}可在孔明灯、赏月夜获得"})
            return
        end
        self.panelIdList[treeInfoId.id] = panelId
    end

    if type == CampaignEumn.MidAutumnType.SkyLantern then
    elseif type == CampaignEumn.MidAutumnType.Reward then
        openArgs.target = "50_1"
    elseif type == CampaignEumn.MidAutumnType.EnjoyMoon then
        openArgs.target = "50_1"
    elseif type == CampaignEumn.MidAutumnType.Dress then
        openArgs.target = "51_1"
        openArgs.bg = "MidAutumnBg"
    elseif type == CampaignEumn.MidAutumnType.Feedback then
        openArgs.target = "51_1"
        openArgs.bg = "MidAutumnBg"
    end

    if panel == nil then
        panel = panelId
        panel.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MidAutumn][type]
        self.panelList[index][subIndex] = panelId
        -- panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)
    end

    self.lastIndex = index
    self.lastGroupIndex = subIndex

    if panel ~= nil then
        panel:Show(openArgs)
    end
end

function MidAutumnPanel:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function MidAutumnPanel:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MidAutumn]
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
            main.label = baseCampaignData[v.sub[1].id].name
            if v.index == CampaignEumn.MidAutumnType.SkyLantern then
                main.iconName = "LanternRed"
            elseif v.index == CampaignEumn.MidAutumnType.Reward then
                main.iconName = "QingmingIcon4"
                main.package = AssetConfig.springfestival_texture
            elseif v.index == CampaignEumn.MidAutumnType.EnjoyMoon then
                main.iconName = "FullMoon"
            elseif v.index == CampaignEumn.MidAutumnType.Dress then
                main.iconName = "Cloth"
            elseif v.index == CampaignEumn.MidAutumnType.Feedback then
                main.iconName = "Feedback"
            elseif v.index == CampaignEumn.MidAutumnType.Exchange then
                main.iconName = "Mooncake"
            end
            local package = main.package or AssetConfig.midAutumn_textures
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

function MidAutumnPanel:CheckRedPoint()
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





