-- 老玩家回归活动面板
-- ljh  20161119

RegressionWindow = RegressionWindow or BaseClass(BaseWindow)

function RegressionWindow:__init(model)
    self.model = model
    self.name = "RegressionWindow"
    self.windowId = WindowConfig.WinID.regression_window

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.regression_window, type = AssetType.Main},
        {file = AssetConfig.regression_textures, type = AssetType.Dep},
    }

    self.campaignIdToPos = {}
    self.panelList = {}
    self.panelIdList = {}
    self.lastIndex = 0
    self.lastGroupIndex = 0

    self._CheckRedPoint = function()
        self:CheckRedPoint()
    end
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RegressionWindow:__delete()
    self.OnHideEvent:Fire()

    if self.panelIdList ~= nil then
        for _,v in pairs(self.panelIdList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelIdList = nil
    end

    if self.tree ~= nil then
        self.tree:DeleteMe()
        self.tree = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RegressionWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.regression_window))
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
end

function RegressionWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RegressionWindow:OnOpen()
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
    local type = self.openArgs[2] or self.lastIndex

    self:InitTreeInfo()
    self.tree:SetData(self.treeInfo)

    if self:CheckHappyEncourageGift() then
        self.tree.mainTab[3].gameObject:SetActive(true)
    else
        self.tree.mainTab[3].gameObject:SetActive(false)
        if type == 3 then
            type = 1
        end
    end

    if self:CheckHandInHand() then
        self.tree.mainTab[2].gameObject:SetActive(true)
    else
        self.tree.mainTab[2].gameObject:SetActive(false)
        if type == 2 then
            type = 1
        end
    end

    if self:CheckLogin() then
        self.tree.mainTab[1].gameObject:SetActive(true)
    else
        self.tree.mainTab[1].gameObject:SetActive(false)
        if type == 1 then
            type = 2
        end
    end

    self.tree:ClickMain(type, 1)

    self:CheckRedPoint()
end

function RegressionWindow:OnHide()
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

function RegressionWindow:AddListeners()
    RegressionManager.Instance.loginUpdate:Add(self._CheckRedPoint)
    RegressionManager.Instance.recruitUpdate:Add(self._CheckRedPoint)
end

function RegressionWindow:RemoveListeners()
    RegressionManager.Instance.loginUpdate:Remove(self._CheckRedPoint)
    RegressionManager.Instance.recruitUpdate:Remove(self._CheckRedPoint)
end

function RegressionWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function RegressionWindow:InitTreeInfo()
    -- local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Regression]
    -- local baseCampaignData = DataCampaign.data_list
    -- self.mayData = tempData
    -- -- for index,v in pairs(tempData) do
    -- --     -- if index == CampaignEumn.MayType.Summer then
    -- --         table.insert(self.mayData, v)
    -- --     -- end
    -- -- end
    -- BaseUtils.dump(self.mayData, "<color=#FF0000>mayData</color>")

    -- local infoTab = {}
    -- local c = 1
    -- for index,v in pairs(self.mayData) do
    --     if index ~= "count" then
    --         if infoTab[c] == nil then
    --             infoTab[c] = {height = 60, subs = {}, type = index, datalist = {}, resize = false}
    --             c = c + 1
    --         end
    --         local main = infoTab[c - 1]
    --         main.datalist = v.sub
    --         main.label = baseCampaignData[v.sub[1].id].name
    --         main.sprite = nil
    --         if index == CampaignEumn.RegressionType.RegressionLogin then
    --             -- main.iconName = "Pumpkin"
    --         elseif index == CampaignEumn.RegressionType.HandInHand then
    --             -- main.iconName = "KillEvil"
    --         end
    --         local package = main.package or AssetConfig.regression_textures
    --         if main.sprite == nil then
    --             main.sprite = self.assetWrapper:GetSprite(package, main.iconName)
    --         end
    --     end
    -- end
    -- self.treeInfo = infoTab

    -- BaseUtils.dump(infoTab)

    -- 忽然改成不是活动了，直接把初始化数据放这里了
    local infoTab = {
        [1] = {
            subs = {
            },
            resize = false,
            datalist = {
                [1] = {
                    id = 368,
                    _class_type = {
                        __delete = false,
                    },
                    group_index = 1,
                    status = 0,
                    reward_max = 0,
                    reward_can = 0,
                    target_val = 0,
                    value = 0,
                    ext_val = 0,
                },
            },
            type = 1,
            height = 60,
            label = "回归登陆",
            sprite = self.assetWrapper:GetSprite(AssetConfig.regression_textures, "RegressionIcon4"),
        },
        [2] = {
            subs = {
            },
            resize = false,
            datalist = {
                [1] = {
                    id = 369,
                    _class_type = {
                        __delete = false,
                    },
                    group_index = 1,
                    status = 1,
                    reward_max = 1,
                    reward_can = 1,
                    target_val = 0,
                    value = 0,
                    ext_val = 0,
                },
            },
            type = 2,
            height = 60,
            label = "携手并进礼",
            sprite = self.assetWrapper:GetSprite(AssetConfig.regression_textures, "RegressionIcon2"),
        },
        [3] = {
            subs = {
            },
            resize = false,
            datalist = {
                [1] = {
                    id = 370,
                    _class_type = {
                        __delete = false,
                    },
                    group_index = 1,
                    status = 1,
                    reward_max = 1,
                    reward_can = 1,
                    target_val = 0,
                    value = 0,
                    ext_val = 0,
                },
            },
            type = 3,
            height = 60,
            label = "欢乐助长礼",
            sprite = self.assetWrapper:GetSprite(AssetConfig.regression_textures, "RegressionIcon3"),
        },
    }

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

function RegressionWindow:ChangeTab(index, subIndex)
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

    -- local campaignData = DataCampaign.data_list[CampaignManager.Instance.campaignTree[CampaignEumn.Type.Regression][type].sub[subIndex].id]

    local openArgs = {
        -- activityName = campaignData.name,
        -- name = campaignData.name,
        -- startTime = campaignData.cli_start_time[1],
        -- endTime = campaignData.cli_end_time[1],
        -- desc = campaignData.cond_desc,
        icon = self.treeInfo[index].iconName,
        -- bg = "MidAutumnBg",
        target = nil,
        sprite = self.treeInfo[index].sprite,
    }

    -- print(type)

    if panelId == nil then
        if type == CampaignEumn.RegressionType.RegressionLogin then
            panelId = RegressionLoginPanel.New(self, self.rightContainer)
        elseif type == CampaignEumn.RegressionType.HandInHand then
            panelId = HandInHandPanel.New(self, self.rightContainer)
        elseif type == CampaignEumn.RegressionType.HappyEncourageGift then
            panelId = HappyEncourageGiftPanel.New(self, self.rightContainer)
        else
            panelId = RegressionLoginPanel.New(self, self.rightContainer)
        end
        self.panelIdList[treeInfoId.id] = panelId
    end

    if panel == nil then
        panel = panelId
        -- panel.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Regression][type]
        self.panelList[index][subIndex] = panelId
        -- panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)
    end

    self.lastIndex = index
    self.lastGroupIndex = subIndex

    if panel ~= nil then
        panel:Show(openArgs)
    end
end

function RegressionWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function RegressionWindow:CheckRedPoint()
    self.tree:RedMain(1, self.model:CheckRedPointLogin())
    self.tree:RedMain(2, self.model:CheckRedPointBerecruit())
end

function RegressionWindow:CheckHandInHand()
    return self.model.status == 1
end

function RegressionWindow:CheckLogin()
    return self.model.login_status == 1
end

function RegressionWindow:CheckHappyEncourageGift()
    return #self.model.buffs > 0
end