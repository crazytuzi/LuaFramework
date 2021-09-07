BibleRewardPanel = BibleRewardPanel or BaseClass(BasePanel)

function BibleRewardPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance

    self.effectPath = "prefabs/effect/20104.unity3d"
    self.guideEffect = nil

    self.resList = {
        {file = AssetConfig.bible_welfare_panel, type = AssetType.Main}
        , {file = self.effectPath, type = AssetType.Main}
        , {file = AssetConfig.bible_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.eyou_activity_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.may_textures, type = AssetType.Dep}
    }
    self.index = nil
    -- self.key_to_indexs = {}

    if model.bibleList[9] ~= nil then --限时特惠处理
        if BaseUtils.IsInTimeRange(PrivilegeManager.Instance.startMonth,PrivilegeManager.Instance.startDay,PrivilegeManager.Instance.endMonth,PrivilegeManager.Instance.endDay) == false then
            model.bibleList[9].name = TI18N("限时特惠")
        else
            model.bibleList[9].name = TI18N("首发狂欢")
        end
    end

    for k,v in pairs(model.bibleList) do
        if v ~= nil and v.package ~= nil then
            table.insert(self.resList, {file = v.package, type = AssetType.Dep})
        end
    end

    self.timerId = 0

    self.panelList = {}
    self.tabGroupObjList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.redPointListener = function() self:CheckRedPoint() end
    self.updateDailyListener = function() self:UpadteDaily() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)

    self.thereTabIndex = nil

    self.tabArray = {}
    for k,v in pairs(model.bibleList) do
        table.insert(self.tabArray, v)
        self.tabArray[#self.tabArray].id = k
    end
    table.sort(self.tabArray, function(a,b) return a.index < b.index end)
    for i,v in ipairs(self.tabArray) do
        if v.id == 15 then
            self.thereTabIndex = i
            if CampaignManager.Instance.buyThreeTab ~= nil then
                self.tabArray[self.thereTabIndex].name = DataCampaign.data_list[CampaignManager.Instance.buyThreeTab.sub[1].id].name
            end
        end
    end
    -- BaseUtils.dump(self.tabArray)
end

function BibleRewardPanel:__delete()
    self:StopTimer()

    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.tabGroupObjList ~= nil then
        for _,v in pairs(self.tabGroupObjList) do
            v.tagImg.sprite = nil
            v.iconImg.sprite = nil
        end
    end
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.panelList = nil
    end
    self.model.lastSelect = nil
    self:AssetClearAll()
end

function BibleRewardPanel:InitPanel()
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_welfare_panel))
    self.gameObject.name = "BibleRewardPanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainPanel = self.transform:Find("MainPanel")
    self.mainPanelImg = self.mainPanel:GetComponent(Image)
    self.downObj = self.transform:Find("Down").gameObject
    self.tabContainer = self.transform:Find("WelfareListPanel/Container")
    self.tabCloner = self.transform:Find("WelfareListPanel/Cloner").gameObject
    self.tabCloner.transform:SetParent(self.mainPanel.parent)
    self.maxTabGroupHeight = self.transform:Find("WelfareListPanel"):GetComponent(RectTransform).sizeDelta.y
    self.tabContainerrRect = self.tabContainer:GetComponent(RectTransform)
    self.tabCloner:SetActive(false)
    self.downObj:SetActive(false)

    self.tabGroupSetting = {
        notAutoSelect = true,
        openLevel = {0, 0},
        perWidth = 175,
        perHeight = 60,
        isVertical = true,
        noCheckRepeat = true,
        spacing = 0
    }
    self.tabGroup = TabGroup.New(self.tabContainer.gameObject, function(index) self:ChangeTab(index) end, self.tabGroupSetting)

    self.guideEffect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    local etrans = self.guideEffect.transform
    etrans:SetParent(self.transform)
    Utils.ChangeLayersRecursively(etrans, "UI")
    etrans.localScale = Vector3.one
    etrans.localPosition = Vector3(0, 0, -500)
    self.guideEffect:SetActive(false)

    self.OnOpenEvent:Fire()
end

function BibleRewardPanel:ReloadTabGroup()
    local model = self.model
    local openLevel = {}
    if CampaignManager.Instance.buyThreeTab ~= nil and self.thereTabIndex ~= nil then
        -- BaseUtils.dump(self.tabArray)
        -- print(self.thereTabIndex)
        self.tabArray[self.thereTabIndex].name = DataCampaign.data_list[CampaignManager.Instance.buyThreeTab.sub[1].id].name
    end
    local i = 1
    for h,v in ipairs(self.tabArray) do
        i = v.key --以键值对方式存数据
        if self.tabGroupObjList[i] == nil then
            self.tabGroupObjList[i] = {}
            self.tabGroupObjList[i].obj = GameObject.Instantiate(self.tabCloner)
            local t = self.tabGroupObjList[i].obj.transform
            self.tabGroupObjList[i].normalText = t:Find("Normal/Text"):GetComponent(Text)
            self.tabGroupObjList[i].selectText = t:Find("Select/Text"):GetComponent(Text)
            self.tabGroupObjList[i].timeText = t:Find("TimeText"):GetComponent(Text)
            self.tabGroupObjList[i].iconImg = t:Find("Icon"):GetComponent(Image)
            self.tabGroupObjList[i].tagImg = t:Find("Tag"):GetComponent(Image)
            self.tabGroupObjList[i].tagText = t:Find("Tag/Text"):GetComponent(Text)
            t:Find("NotifyPoint").gameObject:SetActive(false)
            self.tabGroupObjList[i].name = tostring(i)
            -- self.key_to_indexs[v.key] = i
        end
        if v.key == 22 and self.model.currentTribleData ~= nil then
            self.tabGroupObjList[i].normalText.text = self.model.currentTribleData.title
            self.tabGroupObjList[i].selectText.text = self.model.currentTribleData.title
        else
            self.tabGroupObjList[i].normalText.text = v.name
            self.tabGroupObjList[i].selectText.text = v.name
        end
        if v.tag == model.tagType.Worth then
            self.tabGroupObjList[i].tagImg.gameObject:SetActive(true)
            self.tabGroupObjList[i].tagImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel4")
            self.tabGroupObjList[i].tagText.text = TI18N("超值")
        else
            self.tabGroupObjList[i].tagImg.gameObject:SetActive(false)
        end
        if v.package == nil then
            self.tabGroupObjList[i].iconImg.sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures, tostring(v.icon))
        else
            self.tabGroupObjList[i].iconImg.sprite = self.assetWrapper:GetSprite(v.package, tostring(v.icon))
        end
        local obj = self.tabGroupObjList[i].obj
        obj:GetComponent(Button).onClick:RemoveAllListeners()
        obj.transform:SetParent(self.tabContainer)
        obj.transform.localScale = Vector3.one
        local rect = obj:GetComponent(RectTransform)
        rect.pivot = Vector2(0,0.5)
        -- if v.lev ~= nil then
        --     openLevel[i] = v.lev
        -- else
        --     openLevel[i] = 0
        -- end
    end
    self:CheckTabShow()
    for i,v in ipairs(self.tabArray) do
        if v.lev ~= nil then
            openLevel[i] = v.lev
        else
            openLevel[i] = 0
        end
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
    end
    self.tabGroupSetting.openLevel = openLevel
    self.tabGroup = TabGroup.New(self.tabContainer.gameObject, function(index) self:ChangeTab(index) end, self.tabGroupSetting)
    self.downObj:SetActive(self.tabGroup.rect.sizeDelta.y > self.maxTabGroupHeight)
end

function BibleRewardPanel:ChangeTab(index)
    local model = self.model
    if model.lastSelect ~= nil then
        if self.panelList[model.lastSelect] ~= nil then
            self.panelList[model.lastSelect]:Hiden()
        end
    end
    self.index = index
    local id = self.tabArray[index].id
    if self.panelList[id] == nil then
        if id == 1 then
            self.panelList[1] = BibleDailyPanel.New(model, self.mainPanel)
        elseif id == 2 then
            self.panelList[2] = BibleSevendayPanel.New(model, self.mainPanel)
        elseif id == 3 then
            self.panelList[3] = BibleLevelupPanel.New(model, self.mainPanel)
        elseif id == 4 then
            self.panelList[4] = MultiInvestPanel.New(model, self.mainPanel)
        elseif id == 5 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.firstrecharge_window)
            return
        elseif id == 6 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {1, 2})
            return
        elseif id == 7 then
            self.panelList[7] = BibleCDKeyPanel.New(model, self.mainPanel)
        elseif id == 8 then
            self.panelList[8] = BibleOnlineRewardPanel.New(model, self.mainPanel)
            self.panelList[8].campaignType = CampaignEumn.Type.OnLine
            self.panelList[8].mainType = 1
        elseif id == 9 then
            self.panelList[9] = BibleLimitTimePrivilegePanel.New(model, self.mainPanel, self, index)
        elseif id == 10 then
            self.panelList[10] = BibleDailyHoroscopePanel.New(model, self.mainPanel, self, index)
        elseif id == 11 then
            self.panelList[id] = BibleFestivalPanel.New(model, self.mainPanel)
        elseif id == 12 then
            self.panelList[id] = BibleSuperVipGiftPanel.New(model, self.mainPanel)
        elseif id == 13 then
            self.panelList[id] = BibleEvaluateGamePanel.New(model, self.mainPanel)
        elseif id == 14 then
            self.panelList[id] = BibleFocusGiftPanel.New(model, self.mainPanel)
        elseif id == 15 then
            self.panelList[id] = BuyThreePanel.New(model, self.mainPanel)
            self.panelList[id].campaignData = CampaignManager.Instance.buyThreeTab
        elseif id == 16 then
            self.panelList[id] = BibleDailyGiftPanel.New(model, self.mainPanel)
        elseif id == 17 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {4})
            return
        elseif id == 18 then
            self.panelList[18] = GrowFundPanel.New(model, self.mainPanel)
        elseif id == 19 then
            self.panelList[19] = RecruitmentRewardPanel.New(model, self.mainPanel)
        elseif id == 20 then
            self.panelList[20] = BibleRealNamePanel.New(model, self.mainPanel)
        elseif id == 21 then
            self.panelList[21] = FashionNewListingPanel.New(model, self.mainPanel)
        elseif id == 22 then
            self.panelList[22] = TribleGiftPanel.New(model, self.mainPanel)
        elseif id == 23 then
            self.panelList[23] = BibleRechargePanel.New(model, self.mainPanel)
        -- elseif id == 24 and SdkManager.Instance:IsOpenRealName() then
        elseif id == 24 then
            self.panelList[24] = RealNamePanel.New(model, self.mainPanel)
        elseif id == 25 then
            self.panelList[25] = QRCodePanel.New(model, self.mainPanel)
        elseif id == 26 then
            self.panelList[26] = DownloadNewApkPanel.New(model, self.mainPanel)
        elseif id == 27 then
            self.panelList[27] = PublicNumberPanel.New(model, self.mainPanel)
        elseif id == 28 then
            self.panelList[28] = DirectBuyPanel.New(model, self.mainPanel)
        end

        if self.panelList[id] ~= nil then
            self.panelList[id].OnOpenEvent:AddListener(function() self:HideOthers() end)
        end
    end

    model.lastSelect = id
    if self.panelList[id] ~= nil then
        self.panelList[id]:Show(id)
    end

    self:ShowGuide()
end

function BibleRewardPanel:HideOthers()
    local model = self.model
    for id,panel in pairs(self.panelList) do
        if panel ~= nil then
            if id ~= model.lastSelect then
                panel:Hiden()
            end
        end
    end
end

function BibleRewardPanel:OnOpen()
    self:RemoveListener()
    self.mgr.onUpdateRedPoint:AddListener(self.redPointListener)
    self.mgr.onUpdateDaily:AddListener(self.updateDailyListener)

    self:ReloadTabGroup()
    self:CheckRedPoint()
    for k,v in pairs(self.tabArray) do
        if v ~= nil and v.id == self.model.currentSub then
            self.model.currentSub = k
            break
        end
    end
    if self.tabGroup.buttonTab[self.model.currentSub] == nil then
        self.model.currentSub = 1
    end

    LuaTimer.Add(50, function()
        self.tabGroup:ChangeTab(self.model.currentSub)

        if QuestManager.Instance:GetQuest(10084) ~= nil then
            GuideManager.Instance:OpenWindow(WindowConfig.WinID.biblemain)
        elseif QuestManager.Instance:GetQuest(22084) ~= nil then
            GuideManager.Instance:OpenWindow(WindowConfig.WinID.biblemain)
        end
    end)
end

function BibleRewardPanel:OnHide()
    if self.panelList ~= nil then
        for k,v in pairs(self.panelList) do
            if v ~= nil then
                v:Hiden()
            end
        end
    end
    self:RemoveListener()
    self.model.currentSub = 1
end

function BibleRewardPanel.ShowEffect(id, transform, scale, position, time, rotation,sortingOrder)
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(transform)
        effectObject.name = "Effect"
        effectObject.transform.localScale = scale
        effectObject.transform.localPosition = position
        effectObject.transform.localRotation = rotation or Quaternion.identity
        if sortingOrder ~= nil then
            local renders = effectObject.transform:GetComponentsInChildren(Renderer, true)
            for i=1, #renders do
                renders[i].sortingOrder = sortingOrder
            end
        end
        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    end
    return BaseEffectView.New({effectId = id, time = time, callback = fun})
end

function BibleRewardPanel.ShowEffectInModel(id, transform, scale, position, time, rotation,t)
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(transform)
        if t == true then
           effectObject.transform:Find("01").transform.localScale = Vector3(1,1,1)
        end
        effectObject.name = "Effect"
        effectObject.transform.localScale = scale
        effectObject.transform.localPosition = position
        effectObject.transform.localRotation = rotation or Quaternion.identity
        -- effectObject.transform:Reset()

        Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")
    end
    return BaseEffectView.New({effectId = id, time = time, callback = fun})
end


function BibleRewardPanel:RemoveListener()
    self.mgr.onUpdateDaily:RemoveListener(self.updateDailyListener)
    self.mgr.onUpdateRedPoint:RemoveListener(self.redPointListener)
    -- EventMgr.Instance:RemoveListener(event_name.mainicontime_update, self.mainicontime_update)
end

-- 检查是否显示页签
function BibleRewardPanel:CheckTabShow()
    local model = self.model
    local untouchableLev = 200  --不可能到达的等级
    local openCondition = self.model:CheckTabShow()
    --BaseUtils.dump(openCondition, "openCondition")
    --print(SdkManager.Instance:IsOpenRealName() and BibleManager.Instance.isRealName == 0)
    self.timeCondition = {
        [16] = self.model:GetDailyGiftLeftTime()
        ,[9] = self.model:checkLimittimePrivilege() --限时特惠
    }
    for k,v in pairs(self.tabArray) do
        if openCondition[v.id] ~= nil then
            if openCondition[v.id] ~= true then
                v.lev = untouchableLev
            else
                v.lev = 0
            end
        else
            v.lev = 0
        end
    end
    local doTimer = false
    for k, v in pairs(self.timeCondition) do
        if v > 0 then
            self.tabGroupObjList[k].timeText.gameObject:SetActive(true)
            self.tabGroupObjList[k].timeText.supportRichText = true
            self.tabGroupObjList[k].normalText.gameObject.transform.anchoredPosition = Vector2(19.2, 1.5)
            self.tabGroupObjList[k].selectText.gameObject.transform.anchoredPosition = Vector2(19.2, 1.5)
            doTimer = true
        end
    end
    if doTimer then
        self:StartTimer()
    end
end

function BibleRewardPanel:CheckRedPoint()
    local redPointDic = BibleManager.Instance.redPointDic[1]

    -- BaseUtils.dump(redPointDic, "redPointDic")

    for k,v in pairs(self.tabGroup.buttonTab) do
        v.red:SetActive(redPointDic[self.tabArray[k].id] == true)
    end
end

------计时器逻辑
function BibleRewardPanel:StartTimer()
    self:StopTimer()
    self.timerId = LuaTimer.Add(0, 1000, function() self:TimerTick() end)
end

function BibleRewardPanel:StopTimer()
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
end

function BibleRewardPanel:TimerTick()
    for k, v in pairs(self.timeCondition) do
        if v > 0 then
            local txt = self.tabGroupObjList[k].timeText
            if k == 16 then
                local timeLeft = self.model.bibleDailyGiftSocketData.max_time - (self.model.bibleDailyGiftSocketData.keep_time + (BaseUtils.BASE_TIME - math.max(self.model.bibleDailyGiftSocketData.login_time,self.model.bibleDailyGiftSocketData.start_time))) - self.model.billeDailyGiftDebugTime
                local _, myHour, myMinute, mySecond = BaseUtils.time_gap_to_timer(timeLeft)
                myHour = myHour >= 10 and tostring(myHour) or string.format("0%s", myHour)
                myMinute = myMinute >= 10 and tostring(myMinute) or string.format("0%s", myMinute)
                mySecond = mySecond >= 10 and tostring(mySecond) or string.format("0%s", mySecond)
                txt.text = string.format("<color='#13fc60'>%s:%s:%s</color>", myHour, myMinute, mySecond)
            elseif k == 9 then --限时返利
                local dataIfo = PrivilegeManager.Instance.limitTimePrivilegeInfo
                local countData = dataIfo.max_time - (dataIfo.keep_time + (BaseUtils.BASE_TIME - math.max(dataIfo.login_time,dataIfo.start_time))) - 1800
                local _, myHour, myMinute, mySecond = BaseUtils.time_gap_to_timer(countData)
                myHour = myHour >= 10 and tostring(myHour) or string.format("0%s", myHour)
                myMinute = myMinute >= 10 and tostring(myMinute) or string.format("0%s", myMinute)
                mySecond = mySecond >= 10 and tostring(mySecond) or string.format("0%s", mySecond)
                txt.text = string.format("<color='#13fc60'>%s:%s:%s</color>", myHour, myMinute, mySecond)
            end
        end
    end
end

function BibleRewardPanel:CheckGuide()
    local quest = QuestManager.Instance:GetQuest(10084)
    if quest ~= nil then
        if quest.progress_ser[1].finish == 1 and quest.progress_ser[2].finish == 0 then
            return true
        end
    end

    quest = QuestManager.Instance:GetQuest(22084)
    if quest ~= nil then
        if quest.progress_ser[1].finish == 1 and quest.progress_ser[2].finish == 0 then
            return true
        end
    end

    return false
end

function BibleRewardPanel:ShowGuide()
    if not BaseUtils.is_null(self.guideEffect) then
        self.guideEffect:SetActive(false)
    end
    if self.model.lastSelect ~= nil and self.model.lastSelect ~= 8 and self:CheckGuide() and not BaseUtils.is_null(self.guideEffect) then
        local obj = self.tabGroupObjList[8].obj
        if obj ~= nil then
            local etrans = self.guideEffect.transform
            etrans:SetParent(obj.transform)
            Utils.ChangeLayersRecursively(etrans, "UI")
            etrans.localScale = Vector3.one
            etrans.localPosition = Vector3(90, 0, -500)
            self.guideEffect:SetActive(true)
            LuaTimer.Add(200, function()
                TipsManager.Instance:ShowGuide({gameObject = obj, data = TI18N("再来看看还有什么<color='#ffff00'>奖励</color>吧"), forward = TipsEumn.Forward.Right})
            end)
        end
    end
end

function BibleRewardPanel:UpadteDaily()
    self:ShowGuide()
end
