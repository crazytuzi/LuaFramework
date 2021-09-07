-- 万圣节活动面板
-- ljh  20161019

NewYearWindow = NewYearWindow or BaseClass(BaseWindow)

function NewYearWindow:__init(model)
    self.model = model
    self.name = "NewYearWindow"
    self.windowId = WindowConfig.WinID.newyearwindow

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.new_year_window, type = AssetType.Main},
        {file = AssetConfig.newyear_textures, type = AssetType.Dep},
        {file = AssetConfig.open_server_textures, type = AssetType.Dep},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = AssetConfig.midAutumn_textures, type = AssetType.Dep},
    }

    self.d = nil
    self.h = nil
    self.m = nil
    self.s = nil
    self.timeString1 = TI18N("%s天%s小时")
    self.timeString2 = TI18N("%s小时%s分钟")
    self.timeString3 = TI18N("%s分钟%s秒")
    self.timeString4 = TI18N("%s秒")
    self.timeString5 = TI18N("活动已结束")

    self.campaignIdToPos = {}
    self.panelList = {}
    self.panelIdList = {}
    self.lastIndex = 0
    self.lastGroupIndex = 0

    self.redListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function NewYearWindow:__delete()
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

function NewYearWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.new_year_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newyear_textures, "Title")
    t:Find("Main/Title/Image"):GetComponent(Image).preserveAspect = true

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.timeText = t:Find("Main/Panel/Time/Text"):GetComponent(Text)
    self.baseItem = t:Find("Main/Panel/Left/BaseItem").gameObject

    -- self.baseItem.transform:Find("MainButton/Select"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "OpenServerNewSelect")
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function NewYearWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NewYearWindow:OnOpen()
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
    if type == 23226 then --五彩仙盒特殊处理
        type = 1
    end

    self:InitTreeInfo()
    self.tree:SetData(self.treeInfo)

    if self.treeInfo[type].type == CampaignEumn.NewYearType.Exchange then
        type = 2
    end
    self.tree:ClickMain(type, 1)

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 1000, function() self:OnTime() end)
    end

    self:CheckRedPoint()
end

function NewYearWindow:OnHide()
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

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function NewYearWindow:AddListeners()
    self:RemoveListeners()
    NewYearManager.Instance.redPointEvent:AddListener(self.redListener)
end

function NewYearWindow:RemoveListeners()
    NewYearManager.Instance.redPointEvent:RemoveListener(self.redListener)
end

function NewYearWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function NewYearWindow:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear]
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
                infoTab[c] = {height = 75, subs = {}, type = index, datalist = {}, resize = false}
                c = c + 1
            end
            local main = infoTab[c - 1]
            main.datalist = v.sub
            -- main.label = baseCampaignData[v.sub[1].id].name
            main.label = ""
            main.sprite = nil
            if index == CampaignEumn.NewYearType.Recharge then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.newyear_textures, "Fight")
            elseif index == CampaignEumn.NewYearType.Exchange then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.newyear_textures, "Reward")
            elseif index == CampaignEumn.NewYearType.Fight then
                main.sprite = self.assetWrapper:GetSprite(AssetConfig.newyear_textures, "Feedback")
            end
            local package = main.package or AssetConfig.halloween_textures
            if main.sprite == nil then
                -- main.sprite = self.assetWrapper:GetSprite(package, main.iconName)
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

function NewYearWindow:ChangeTab(index, subIndex)
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
    self.type = type
    local treeInfoId = self.treeInfo[index].datalist[subIndex]
    local panelId = self.panelIdList[treeInfoId.id]

    local campaignData = DataCampaign.data_list[CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear][type].sub[subIndex].id]

    -- print(type)

    if panelId == nil then
        if type == CampaignEumn.NewYearType.Recharge then                       -- 累计充值
            panelId = NewYearReward.New(self.model, self.rightContainer)
            panelId.campaignGroup = CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear][CampaignEumn.NewYearType.Recharge]
        elseif type == CampaignEumn.NewYearType.Exchange then                       -- 累计充值
            self.model:OpenExchange()
            return
        elseif type == CampaignEumn.NewYearType.Fight then
            -- panelId = NewYearDescPanel.New(self.model, self)
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.luckey_chest_window)
            return
        end
        self.panelIdList[treeInfoId.id] = panelId
    end

    if panel == nil then
        panel = panelId
        panel.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear][type]
        self.panelList[index][subIndex] = panelId
        -- panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)
    end

    self.lastIndex = index
    self.lastGroupIndex = subIndex

    if panel ~= nil then
        panel:Show(openArgs)
    end
end

function NewYearWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function NewYearWindow:OnTime()
    if self.type == nil or CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear][self.type] == nil then
        return
    end
    local end_time = ((DataCampaign.data_list[(((CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear][self.type] or {}).sub or {})[1] or {}).id or 0] or {}).cli_end_time or {})[1]
    if end_time == nil then
        self.timeText.text = self.timeString5
        return
    end
    end_time = os.time({year = end_time[1], month = end_time[2], day = end_time[3], hour = end_time[4], mimute = end_time[5], second = end_time[6]})
    self.d,self.h,self.m,self.s = BaseUtils.time_gap_to_timer(end_time - BaseUtils.BASE_TIME)
    if self.d ~= 0 then
        self.timeText.text = string.format(self.timeString1, self.d, self.h)
    elseif self.h ~= 0 then
        self.timeText.text = string.format(self.timeString2, self.h, self.m)
    elseif self.m ~= 0 then
        self.timeText.text = string.format(self.timeString3, self.m, self.s)
    elseif self.s ~= 0 then
        self.timeText.text = string.format(self.timeString4, self.s)
    else
        self.timeText.text = self.timeString5
    end
end

function NewYearWindow:CheckRedPoint()
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear] ~= nil then
        for index,v in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewYear]) do
            if index ~= "count" then
                local mainRed = false
                local posMain = nil
                for _,sub in pairs(v.sub) do
                    local pos = self.campaignIdToPos[sub.id]
                    posMain = pos
                    mainRed = mainRed or (NewYearManager.Instance.redPointDic[sub.id] == true)
                end
                if posMain ~= nil then
                    self.tree:RedMain(posMain[1], mainRed)
                end
            end
        end
    end
end

