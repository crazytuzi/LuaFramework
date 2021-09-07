-- @author zhouyijun
-- @date 2017年5月18日

DragonBoatFestivalWindow = DragonBoatFestivalWindow or BaseClass(BaseWindow)

function DragonBoatFestivalWindow:__init(model)
    self.model = model
    self.name = "DragonBoatFestivalWindow"
    self.cacheMode = CacheMode.Visible
    self.windowId = WindowConfig.WinID.dragon_boat_festival

    self.resList = {
        {file = AssetConfig.halloweenwindow, type = AssetType.Main},
        {file = AssetConfig.dragonboat_textures, type = AssetType.Dep},
        {file = AssetConfig.may_textures, type = AssetType.Dep},
        {file = AssetConfig.teamquest, type = AssetType.Dep},
    }

    self.panelList = {}
    self.panelIdList = {}

    self.redListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function DragonBoatFestivalWindow:__delete()
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

function DragonBoatFestivalWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.titleImg = t:Find("Main/Title/Image"):GetComponent(Image)

    t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.dragonboat_textures, "i18ndragonboattitle")--"TitleI18N1")
    t:Find("Main/Title/Image"):GetComponent(Image):SetNativeSize()

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/BaseItem").gameObject
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function DragonBoatFestivalWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end


function DragonBoatFestivalWindow:OnOpen()
    CampaignManager.Instance:Send14000()
    if self.panelList ~= nil then
        for _,panelTab in pairs(self.panelList) do
            if panelTab ~= nil then
                for _,v in pairs(panelTab) do
                    v:Hiden()
                end
            end
        end
    end
    self:InitTreeInfo()

    self.tree:SetData(self.treeInfo)

    self:RemoveListeners()
    DragonBoatFestivalManager.Instance.redPointEvent:AddListener(self.redListener)

    self.openArgs = self.openArgs or {}


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

function DragonBoatFestivalWindow:OnHide()
    self:RemoveListeners()
end

function DragonBoatFestivalWindow:RemoveListeners()
    DragonBoatFestivalManager.Instance.redPointEvent:RemoveListener(self.redListener)
end

function DragonBoatFestivalWindow:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.DragonBoatFestival]
    local baseCampaignData = DataCampaign.data_list
    self.mayData = tempData




    self.openCampaign = {}
    self:CheckOpenCampaign()
    local infoTab = {}
    local c = 1
    for index,v in pairs(self.mayData) do
        if index ~= "count" then
            -- if index ~= CampaignEumn.MayIOUType.Intimacy or CampaignManager.Instance:CheckIntimacy() then
                if infoTab[c] == nil and self.openCampaign[index] ~= false then
                    infoTab[c] = {height = 60, subs = {}, type = index, datalist = {}, resize = false}
                    c = c + 1
                end
                local main = infoTab[c - 1]
                main.datalist = v.sub
                main.label = baseCampaignData[v.sub[1].id].name
                -- print(main.label)
                main.sprite = nil

                -- LoginReward = nil      -- 登录送礼
                -- ,Boat = nil            -- 赛龙舟
                -- ,Zongzi = nil          -- 包粽子
                -- ,Consume = nil         -- 累计消费

                if index == CampaignEumn.DragonBoatType.LoginReward then
                    --登录送礼
                    main.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90018")
                    main.label = "登录送礼"

                elseif index == CampaignEumn.DragonBoatType.Boat then
                    --赛龙舟
                    -- main.sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "dragonboat2")
                    main.sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "dragonboat")
                    main.label = "滑雪"
                elseif index ==CampaignEumn.DragonBoatType.Zongzi then
                    --包粽子
                    main.sprite = self.assetWrapper:GetSprite(AssetConfig.dragonboat_textures, "zongzi_icon")-- may_textures, "WithYou")
                    main.label = "包粽子"
                elseif index ==CampaignEumn.DragonBoatType.Consume then
                    --累计消费
                    main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Gift2")
                    main.label = "累计消费"
                end

                local package = main.package or AssetConfig.may_textures
                if main.sprite == nil then
                    main.sprite = self.assetWrapper:GetSprite(package, main.iconName)
                end
            -- end
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

function DragonBoatFestivalWindow:ChangeTab(index, subIndex)
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
        -- LoginReward =   593      -- 登录送礼
        -- ,Boat =         594      -- 赛龙舟
        -- ,Zongzi =       595      -- 包粽子
        -- ,Consume =     598      -- 累计消费
        if type == CampaignEumn.DragonBoatType.LoginReward then
           print("----登录送礼")
            panelId = SevenLoginPanel.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
            panelId.bg = AssetConfig.dragonboatlogin_big_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.DragonBoatType.Boat then
            print("----赛龙舟")
            panelId = DragonBoatPanel.New(self.model, self.rightContainer)
            panelId.campId = campaignData.id
            panelId.bg = AssetConfig.i18ndragonboat
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.DragonBoatType.Zongzi then
            print("----包粽子")
            panelId = RiceDumplingPanel.New(self.model,self.rightContainer)
            panelId.campDataGroup = {type = CampaignEumn.Type.DragonBoatFestival, index = CampaignEumn.DragonBoatType.Zongzi}
            panelId.campId = treeInfoId.id
            panelId.bg = AssetConfig.rice_dumpling_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.DragonBoatType.Consume then
            print("----累计消费")
            panelId = DragonBoatConsmRtnPanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.dragonboat_consumebg2
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campaignGroup = CampaignManager.Instance.campaignTree[CampaignEumn.Type.DragonBoat][CampaignEumn.DragonBoatType.Consume]
        end
    end

    if panelId ~= nil then
        panel = panelId
        -- panel.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU][type]
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

function DragonBoatFestivalWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function DragonBoatFestivalWindow:CheckRedPoint()
    local campData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.DragonBoatFestival]

    for index,v in pairs(campData) do
        if index ~= "count" then
            local mainRed = false
            local posMain = nil
            for _,sub in pairs(v.sub) do
                local pos = self.campaignIdToPos[sub.id]
                posMain = pos
                mainRed = mainRed or (CampaignManager.Instance.campaignTab[sub.id] ~= nil and DragonBoatFestivalManager.Instance.redPointDic[sub.id] == true)
            end
            if posMain ~= nil then
                self.tree:RedMain(posMain[1], mainRed)
            end
        end
    end
end

function DragonBoatFestivalWindow:CheckOpenCampaign()
    if DragonBoatFestivalManager.Instance.isCheckoutLogin == false then
        self.openCampaign[CampaignEumn.DragonBoatType.LoginReward] =false
    end
end
