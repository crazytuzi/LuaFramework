OpenServerNewActivityPanel = OpenServerNewActivityPanel or BaseClass(BasePanel)

function OpenServerNewActivityPanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.treeInfo = nil
    self.mgr = BibleManager.Instance

    -- self.path = "prefabs/ui/springfestival/springfestivalpanel.unity3d"
    self.resList = {
        -- {file = self.path, type = AssetType.Main},
        {file = AssetConfig.openserverlpanel, type = AssetType.Main},
        {file = AssetConfig.open_server_textures, type = AssetType.Dep},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
    }

    -- 这是一个一级panel列表，
    -- 结构如下
    -- self.panelList = {
    --     [index] = panel
    -- }
    self.panelList = {}
    self.panelIdList = {}

    -- 活动id对应面板位置
    -- 结构如下
    -- self.campaignIdToPos = {
    --     [campaignId] = pos
    -- }
    self.campaignIdToPos = {}

    self.checkRedListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenServerNewActivityPanel:__delete()
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
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerNewActivityPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.openserverlpanel))
    self.gameObject.name = "OpenServerNewActivityPanel"
    local t = self.gameObject.transform
    self.transform = t

    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.leftContainer = self.transform:Find("Main/Left/Container").gameObject
    self.baseItem = self.transform:Find("Main/Left/BaseItem").gameObject

    self.rightContainer = self.transform:Find("Main/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function OpenServerNewActivityPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onUpdateRedPoint:AddListener(self.checkRedListener)
    OpenServerManager.Instance.checkRed:AddListener(self.checkRedListener)

    local type = self.model.currentSub

    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.openId = self.openArgs[1]
    end
    self:InitTreeInfo()
    self.tree:SetData(self.treeInfo)

    local pos = self.campaignIdToPos[self.openId] or {1, 1}
    self.tree:ClickMain(pos[1], pos[2])

    self.mgr.onUpdateRedPoint:Fire()
end

function OpenServerNewActivityPanel:OnHide()
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

function OpenServerNewActivityPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerNewActivityPanel:RemoveListeners()
    OpenServerManager.Instance.checkRed:RemoveListener(self.checkRedListener)
    self.mgr.onUpdateRedPoint:RemoveListener(self.checkRedListener)
end

function OpenServerNewActivityPanel:ChangeTab(index)
    local model = self.model
    if self.lastIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil and self.panelList[self.lastIndex][1] then
            self.panelList[self.lastIndex][1]:Hiden()
        end
    end

    if self.panelList[index] == nil then self.panelList[index] = {} end
    local panel = self.panelList[index][1]
    local type = self.treeInfo[index].type
    local treeInfoId = self.treeInfo[index].datalist[1]
    local panelId = self.panelIdList[treeInfoId.id]

    local campaignData = DataCampaign.data_list[treeInfoId.id]

    print(string.format( "campaignId: %s, type: %s, index: %s", treeInfoId.id, type, index))

    if panelId == nil then
        if type == CampaignEumn.OpenServerType.Lucky then                           -- 充值红包
            panelId = OpenServerLuckyPanel.New(model, self.rightContainer, self.treeInfo[index].datalist)
        elseif type == CampaignEumn.OpenServerType.Rank then                        -- 排行榜奖励
            panelId = OpenServerRankPanel.New(model, self.rightContainer, self.treeInfo[index].datalist)
        elseif type == CampaignEumn.OpenServerType.Therion then                     -- 神兽兑换
            panelId = OpenServerTherionPanel.New(model, self.rightContainer, self.treeInfo[index].datalist)
        elseif type == CampaignEumn.OpenServerType.ConsumeReturn then               -- 消费返利
            panelId = ConsumeReturnPanel.New(model, self.rightContainer) -- OpenServerTherionPanel.New(model, self.rightContainer, self.treeInfo[index].datalist)
        elseif type == CampaignEumn.OpenServerType.ActiveReward then                -- 活跃度大奖
            panelId = ActiveRewardPanel.New(model, self.rightContainer) -- OpenServerTherionPanel.New(model, self.rightContainer, self.treeInfo[index].datalist)
        -- elseif type == CampaignEumn.OpenServerType.Continue then
        --     panelId = OpenServerContinueCharge.New(model, self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.Flog then                        -- 幸运翻牌
            panelId = OpenServerFlop.New(model, self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.Wish then                        -- 许愿仙池
            panelId = OpenServerTreviFountainPanel.New(model, self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.Ship then                        -- 星梦游轮
            panelId = OpenServerDividend.New(model, self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.Reward then                      -- 限时礼包
            panelId = OpenServerReward.New(model, self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.Seven then                       -- 七天乐享
            panelId = OpenServerSeven.New(model, self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.Online then                      -- 在线奖励
            panelId = OpenServerRotary.New(model, self.rightContainer)
            panelId.campaignType = CampaignEumn.Type.OpenServer
            panelId.mainType = CampaignEumn.OpenServerType.Online
        elseif type == CampaignEumn.OpenServerType.MonthAndFund then                --月度和基金
            panelId = OpenServerMonthAndFundPanel.New(model, self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.ZeroBuy then                     --0元购礼包
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.zero_buy_win,{treeInfoId.id})
        elseif type == CampaignEumn.OpenServerType.ContinuousRecharge then          --连充活动
            panelId = OpenServerContinuousRecharge.New(model,self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.DirectBuy then                   --直购礼包
            panelId = OpenServerDirectBuyPanel.New(model,self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.ValuePackage then                --超值礼包
            panelId = OpenServerValuePackagePanel.New(model,self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.AccumulativeRecharge then        --累充活动
            panelId = OpenServerAccumulativeRechargePanel.New(model,self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.ToyReward then                   --抽奖活动
            panelId = OpenServerToyRewardPanel.New(model,self.rightContainer)
        elseif type == CampaignEumn.OpenServerType.Exchange_Window then             --积分兑换活动
            local datalist = {}
            local lev = RoleManager.Instance.RoleData.lev
            local strList = StringHelper.Split(campaignData.camp_cond_client, ",")
            local exchange_first = tonumber(strList[1]) or 2
            local exchange_second = tonumber(strList[2]) or 28
            for i,v in pairs(ShopManager.Instance.model.datalist[exchange_first][exchange_second]) do
                table.insert(datalist, v)
            end
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = campaignData.reward_title, extString = campaignData.content})
        end
    end

    if panelId ~= nil then
        panel = panelId
        panelId.campId = treeInfoId.id
        panel.protoData = (CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer] or {})[type] or {}
        self.panelList[index][1] = panelId
        self.panelIdList[campaignData.id] = panelId
        -- panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)

        self.lastIndex = index
        self.lastGroupIndex = subIndex

        if panelId ~= nil then
            panelId:Show()
        end
    end
end

function OpenServerNewActivityPanel:ClickSub(data)
end

function OpenServerNewActivityPanel:InitTreeInfo()
    local baseCampaignData = DataCampaign.data_list
    local openserverData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer]
    if openserverData == nil then
        openserverData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer1]
    end
    local changeIndex = nil

    local infoTab = {}
    local c = 1

    for index,v in pairs(openserverData or {}) do
        if index ~= "count" and
            -- 不显示页签的条件应该写在这里
            (not (index == CampaignEumn.OpenServerType.Wish and #DataCampaignWish.data_times - CampaignManager.Instance.campaignWishTimes <= 0)) and
            (not (index == CampaignEumn.OpenServerType.Online and self:IsOpenConsumeReturnPanel() == false))
            then

            if infoTab[c] == nil then
                infoTab[c] = {height = 60, subs = {}, type = v.index, datalist = {}}
                c = c + 1
            end
            local main = infoTab[c - 1]
            main.close = not self:CheckOpen(v)
            if main.close and index == self.lastIndex then
                changeIndex = 1
            end
            main.datalist = v.sub
            main.label = baseCampaignData[v.sub[1].id].name
            if index == CampaignEumn.OpenServerType.Lucky then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "I18NIcon1")
            elseif index == CampaignEumn.OpenServerType.Rank then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "I18NIcon2")
            elseif index == CampaignEumn.OpenServerType.Therion then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "I18NIcon8")
            elseif index == CampaignEumn.OpenServerType.ConsumeReturn then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "I18NIcon7")
            elseif index == CampaignEumn.OpenServerType.ActiveReward then
                -- main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "Icon5")
            -- elseif index == CampaignEumn.OpenServerType.Continue then
            --     main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "Icon6")
            elseif index == CampaignEumn.OpenServerType.Flog then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "I18NIcon5")
            elseif index == CampaignEumn.OpenServerType.Wish then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "I18NIcon4")
            elseif index == CampaignEumn.OpenServerType.Ship then
                -- main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "Icon3")
            elseif index == CampaignEumn.OpenServerType.Reward then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "I18NIcon3")
            elseif index == CampaignEumn.OpenServerType.Online then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "I18NIcon9")
            elseif index == CampaignEumn.OpenServerType.Seven then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "I18NIcon10")
            elseif index == CampaignEumn.OpenServerType.MonthAndFund then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "Monthly")
                main.resize = false
            elseif index == CampaignEumn.OpenServerType.ZeroBuy then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "Icon11")
                main.resize = false
            elseif index == CampaignEumn.OpenServerType.ContinuousRecharge then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "Icon12")
                main.resize = false
            elseif index == CampaignEumn.OpenServerType.DirectBuy then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "Icon13")
                main.resize = false
            elseif index == CampaignEumn.OpenServerType.ValuePackage then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "Icon14")
                main.resize = false
            elseif index == CampaignEumn.OpenServerType.AccumulativeRecharge then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "Icon15")
                main.resize = false
            elseif index == CampaignEumn.OpenServerType.ToyReward then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "Icon16")
                main.resize = false
            elseif index == CampaignEumn.OpenServerType.Exchange_Window then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "Icon17")
                main.resize = false
            end
            -- if main ~= nil then
            --     main.label = DataCampaign.data_list[v.sub[1].id].name
            -- end
        end
    end
    self.treeInfo = infoTab

    -- 这是个假活动，七天乐享
    if OpenServerManager.Instance:CheckSeven() ~= nil then
        table.insert(self.treeInfo, {
            height = 60,
            subs = {},
            label = TI18N("七天乐享"),
            type = CampaignEumn.OpenServerType.Seven,
            datalist = {{id = 509}, {id = 510}},
            sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "I18NIcon10")
        })
    else
    end

    self.campaignIdToPos = {}
    for index,v in pairs(infoTab) do
        for _,sub in pairs(v.datalist) do
            self.campaignIdToPos[sub.id] = {index, 1}
        end
    end
    -- BaseUtils.dump(self.treeInfo, "tree")
    if changeIndex ~= nil then
        LuaTimer.Add(200, function()
            self.tree:ClickMain(changeIndex, 1)
        end)
    end
end

function OpenServerNewActivityPanel:CheckRedPoint()
    local campaignMgr = CampaignManager.Instance
    local openserverData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer]
    if openserverData == nil then
        openserverData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer1]
    end

    for index,v in pairs(openserverData or {}) do
        if index ~= "count" then
            local mainRed = false
            local posMain = nil

            for _,sub in pairs(v.sub) do
                posMain = posMain or self.campaignIdToPos[sub.id]
                mainRed = mainRed or (campaignMgr.redPointDic[sub.id] == true)
            end
            if posMain ~= nil then
                self.tree:RedMain(posMain[1], mainRed)
            end
        end
    end

    local pos = self.campaignIdToPos[509]
    if pos ~= nil then
        self.tree:RedMain(pos[1], campaignMgr.redPointDic[509] == true)
    end
end

function OpenServerNewActivityPanel:CheckOpen(data)
    if type(data) == "number" then
        return true
    end
    if data.index == CampaignEumn.OpenServerType.Flog then
        -- 开服翻牌活动
        if self.model.cardData ~= nil and self.model.cardData.times == 8 then
            return false
        else
            return true
        end
    elseif data.index == CampaignEumn.OpenServerType.Continue then
        local openTime = CampaignManager.Instance.open_srv_time+14*24*3600
        if NewMoonManager.Instance.model.chargeData ~= nil and (NewMoonManager.Instance.model.chargeData.first_time == 0 or
            not BaseUtils.is_cross_day(NewMoonManager.Instance.model.chargeData.first_time)) then
            -- NewMoonManager.Instance.model.chargeData.first_time+24*3600 > BaseUtils.BASE_TIME) then
            return false
        elseif BaseUtils.BASE_TIME > openTime then
            return false
        else
            return true
        end
    else
        return true
    end
end

function OpenServerNewActivityPanel:IsOpenConsumeReturnPanel()
    local dataList = {}
    local dataItemList = CampaignManager.Instance:GetCampaignDataList(CampaignEumn.Type.OpenServer)
    for i,v in ipairs(dataItemList) do
        local baseData = DataCampaign.data_list[v.id]
        if baseData ~= nil and baseData.index == CampaignEumn.OpenServerType.ConsumeReturn then
            v.baseData = baseData
            table.insert(dataList,v)
        end
    end
    table.sort(dataList,function (a,b)
        return a.baseData.group_index < b.baseData.group_index
    end)

    local isOpen = false
    for i=1,#dataList do
        if dataList[i].status ~= 2 then
            isOpen = true
        end
    end

    return isOpen
end
