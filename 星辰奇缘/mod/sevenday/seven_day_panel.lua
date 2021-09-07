-- @author 黄耀聪
-- @date 2016年7月13日

SevendayPanel = SevendayPanel or BaseClass(BasePanel)

function SevendayPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "SevendayPanel"

    self.resList = {
        {file = AssetConfig.sevenday_panel, type = AssetType.Main},
        {file = AssetConfig.sevenday_textures, type = AssetType.Dep},
        {file = AssetConfig.witch_girl, type = AssetType.Main},

        -- {file = string.format(AssetConfig.effect, 20054), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.verTab = {
        {name = TI18N("第1天")},
        {name = TI18N("第2天")},
        {name = TI18N("第3天")},
        {name = TI18N("第4天")},
        {name = TI18N("第5天")},
        {name = TI18N("第6天")},
        {name = TI18N("第7天")},
        {name = TI18N("第8天")},
    }

    self.horTab = {
        [1] = {name = TI18N("福利领取"), icon = "Icon1"},
        [2] = {name = "", icon = "Icon2"},
        [3] = {name = "", icon = "Icon3"},
        [4] = {name = TI18N("半价抢购"), icon = "Icon4"},
    }


    self.updateTargetProgBarListener = function()
        self:UpdateProgBar()
    end
    self.updateTargetRewardListener = function() self:UpdateTargetRewardState() end
    -- self.updateChargeListener = function() self:UpdateCharge() end

    self.targetOpenLevel = 0

    self.panelList = {}
    self.vertabList = {}
    self.hortabList = {}
    self.shakeTween = {}
    -- self.loaders = {}

    self.levListener = function() self:ChangeTab(model.currentX, model.currentY) end
    self.redListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.effTimerId1 = nil
    self.effTimerId2 = nil
    self.effTimerId3 = nil
    self.hasInit = false

    self.showOtherPanel = false
    self.otherPanel = nil
    self.isShowOtherRed = false
    self.effTimerId = nil
    self.LuaTimerList = {}
    self.signRewardEffect = nil


    self.specilLoaderList = {}
end

function SevendayPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.seven_day_target_upgrade, self.updateTargetRewardListener)
    EventMgr.Instance:RemoveListener(event_name.seven_day_charge_upgrade, self.redListener)
    SevendayManager.Instance.onUpdateTarget:RemoveListener()

    -- for k,v in pairs(self.loaders) do
    --     v:DeleteMe()
    -- end
    -- self.loaders = nil
    if self.specilLoaderList ~= nil then
        for k,v in pairs(self.specilLoaderList) do
            v:DeleteMe()
        end
        self.specilLoaderList = nil
    end
    if self.signRewardEffect ~= nil then
        self.signRewardEffect:DeleteMe()
        self.signRewardEffect = nil
    end

    if self.LuaTimerList ~= nil then
        for k,v in pairs(self.LuaTimerList) do
            if v ~= nil then
                LuaTimer.Delete(v)
                v = nil
            end
        end
    end

    if self.effTimerId1 ~= nil then
        LuaTimer.Delete(self.effTimerId1)
        self.effTimerId1 = nil
    end
    if self.effTimerId2 ~= nil then
        LuaTimer.Delete(self.effTimerId2)
        self.effTimerId2 = nil
    end
    if self.effTimerId3 ~= nil then
        LuaTimer.Delete(self.effTimerId3)
        self.effTimerId3 = nil
    end

    if self.giftPreview ~= nil then
        self.giftPreview:DeleteMe()
        self.giftPreview = nil
    end
    if self.shakeTween ~= nil then
        for _,id in pairs(self.shakeTween) do
            if id ~= nil then
                Tween.Instance:Cancel(id)
            end
        end
        self.shakeTween = nil
    end

    -- EventMgr.Instance:RemoveListener(event_name.seven_day_charge_upgrade, self.updateChargeListener)
    self.hasInit = false
    self.OnHideEvent:Fire()
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
    end

    if self.otherPanel ~= nil then
        self.otherPanel:DeleteMe()
        self.otherPanel = nil
    end
    if self.witchImage ~= nil then
        self.witchImage.sprite = nil
    end
    
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SevendayPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sevenday_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.witchImage = t:Find("MainPanel/Girl"):GetComponent(Image)
    self.witchImage.sprite = self.assetWrapper:GetSprite(AssetConfig.witch_girl, "Witch")
    t:Find("MainPanel/Girl").gameObject:SetActive(true)
    t:Find("MainPanel/Girl/CloseArea"):GetComponent(Button).onClick:AddListener(function() self.model:CloseWindow() end)

    self.verContainer = t:Find("VerticallLayer/Container")
    self.verCloner = self.verContainer.parent:Find("Cloner").gameObject
    self.horScrollRect = t:Find("HorizoncallLayer"):GetComponent(ScrollRect)
    self.horScrollRect.enabled = false
    self.horContainer = t:Find("HorizoncallLayer/Container")
    self.horCloner = self.horContainer.parent:Find("Cloner").gameObject
    self.horCloner.transform:Find("Icon").anchoredPosition = Vector2(24,1)
    self.horCloner.transform:Find("Icon").sizeDelta = Vector2(30,30)
    self.mainContainer = t:Find("MainPanel")

    self.progBarCon = t:Find("ProgCon")
    self.progBarCon.gameObject:SetActive(false)
    self.progBarTxt = t:Find("ProgCon/Text"):GetComponent(Text)
    self.progBarTxt.color = Color(232/255, 250/255, 255/255)
    self.progBar = t:Find("ProgCon/ProgBarBg/ProgBar")
    -- self.progBarBox1 = t:Find("ProgCon/ProgBarBg/ImgBox1"):GetComponent(Button)
    -- self.progBarBox2 = t:Find("ProgCon/ProgBarBg/ImgBox2"):GetComponent(Button)
    -- self.progBarBox3 = t:Find("ProgCon/ProgBarBg/ImgBox3"):GetComponent(Button)

    self.otherBtn = t:Find("OtherButton"):GetComponent(Button)
    self.otherSelect = t:Find("OtherButton/SelectImg")
    self.otherText = t:Find("OtherButton/Text"):GetComponent(Text)
    self.otherRedPoint = t:Find("OtherButton/NotifyPoint")

    self.otherSelect.gameObject:SetActive(false)
    self.otherBtn.onClick:AddListener(function() self:OpenOtherPanel() end)


    self.progBarBoxImgList = {}
    for i = 1, 3 do
        table.insert(self.progBarBoxImgList, t:Find(string.format("ProgCon/ProgBarBg/ImgBox%s", i)):GetComponent(Image))
    end

    t:Find("ProgCon/ProgBarBg/ImgBox1/Text"):GetComponent(Text).text = DataGoal.data_get_complete[1].count
    t:Find("ProgCon/ProgBarBg/ImgBox2/Text"):GetComponent(Text).text = DataGoal.data_get_complete[2].count
    t:Find("ProgCon/ProgBarBg/ImgBox3/Text"):GetComponent(Text).text = DataGoal.data_get_complete[3].count
    -- self.progBarBox1.onClick:AddListener(function()
    --     local finishNum = self.model:GetFinishTargetNum()
    --     if finishNum < DataGoal.data_get_complete[1].count then
    --         self:OnOpenBoxRewardList(1)
    --     end
    --         SevendayManager.Instance:send10241(DataGoal.data_get_complete[1].count)

    -- end)
    -- self.progBarBox2.onClick:AddListener(function()
    --     local finishNum = self.model:GetFinishTargetNum()
    --     if finishNum < DataGoal.data_get_complete[2].count then
    --         self:OnOpenBoxRewardList(2)
    --     end
    --         SevendayManager.Instance:send10241(DataGoal.data_get_complete[2].count)

    -- end)
    -- self.progBarBox3.onClick:AddListener(function()
    --     local finishNum = self.model:GetFinishTargetNum()
    --     if finishNum < DataGoal.data_get_complete[3].count then
    --         self:OnOpenBoxRewardList(3)
    --     end
    --     SevendayManager.Instance:send10241(DataGoal.data_get_complete[3].count)
    -- end)
    -- self.mainContainer:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.sevenday_bg, "SevenDayBg")
    -- self.mainContainer:Find("Bg").gameObject:SetActive(true)
    self.timeText = t:Find("Time/Text"):GetComponent(Text)
    self.timeObj = t:Find("Time").gameObject
    self.timeObj.gameObject:SetActive(false)

    for i,v in ipairs(self.verTab) do
        local tab = {}
        tab.obj = GameObject.Instantiate(self.verCloner)
        tab.trans = tab.obj.transform
        tab.trans:SetParent(self.verContainer)
        tab.trans.localScale = Vector3.one
        tab.trans.localPosition = Vector3.zero
        tab.normalText = tab.trans:Find("Normal/Text"):GetComponent(Text)
        tab.normalText.text = v.name
        tab.selectText = tab.trans:Find("Select/Text"):GetComponent(Text)
        tab.selectText.text = v.name

        -- local go = tab.trans:Find("Icon").gameObject
        -- local id = go:GetInstanceID()
        -- local imgLoader = self.loaders[id]
        -- if imgLoader == nil then
        --     imgLoader = SingleIconLoader.New(go)
        --     self.loaders[id] = imgLoader
        -- end

        -- if i ~= 8 then
        --     imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[DataGoal.data_discount[i].icon].icon)
        -- else
        --     imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[23082].icon)
        -- end

        if i == 7 then
            local tabTip = tab.trans:Find("ImgTips")
            tabTip.gameObject:SetActive(true)
            self.tabTip = tabTip
            if self.signRewardEffect == nil then
                self.signRewardEffect = BibleRewardPanel.ShowEffect(20406,tabTip.transform,Vector3(0.7,0.7, 1),Vector3(-18.5,-19.3,-400))
            end
            self.signRewardEffect:SetActive(true)

        end
        self.vertabList[i] = tab
    end

    for i,v in ipairs(self.horTab) do
        local tab = {}
        tab.obj = GameObject.Instantiate(self.horCloner)
        tab.trans = tab.obj.transform
        tab.trans:SetParent(self.horContainer)
        tab.trans.localScale = Vector3.one
        tab.trans.localPosition = Vector3.zero
        if i ~= 4 then
            tab.trans:Find("Normal"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Normal")
        end
        tab.trans:Find("Normal/Text"):GetComponent(Text).text = v.name
        tab.trans:Find("Select/Text"):GetComponent(Text).text = v.name
        tab.trans:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.sevenday_textures, v.icon)
        local iconImg = tab.trans:Find("Icon"):GetComponent(Image)
        tab.iconImg = iconImg
        self.hortabList[i] = tab
    end
    self.verCloner:SetActive(false)
    self.horCloner:SetActive(false)

    self.verTabGroup = TabGroup.New(self.verContainer.gameObject, function(index) self:VerChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = true, perWidth = 145, perHeight = 58, isVertical = true, spacing = -4, openLevel = {}, offsetWidth = 0, offsetHeight = 10})
    self.horTabGroup = TabGroup.New(self.horContainer.gameObject, function(index) self:HorChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = true, perWidth = 139, perHeight = 46, isVertical = false, spacing = 5, openLevel = {}, offsetWidth = 10, offsetHeight = 0})

    self.verTabGroup:Layout()
    self.horTabGroup:Layout()

    self.hasInit = true
    EventMgr.Instance:AddListener(event_name.seven_day_target_upgrade, self.updateTargetRewardListener)
    EventMgr.Instance:AddListener(event_name.seven_day_charge_upgrade, self.redListener)
    SevendayManager.Instance.onUpdateTarget:AddListener(self.updateTargetProgBarListener)
    -- EventMgr.Instance:AddListener(event_name.seven_day_charge_upgrade, self.updateChargeListener)
    SevendayManager.Instance:send10242()
    self:UpdateProgBar()
end

function SevendayPanel:OnOpenBoxRewardList(index)
    if self.giftPreview == nil then
        self.giftPreview = GiftPreview.New(self.model.mainWin.gameObject)
    end
    local cfgData = DataGoal.data_get_complete[index]
    self.giftPreview:Show({reward = cfgData.item_reward, text = TI18N("打开礼包将获得以下奖励"), autoMain = true})
end

function SevendayPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SevendayPanel:OnOpen()
    local model = self.model
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levListener)
    SevendayManager.Instance.onUpdateRed:AddListener(self.redListener)

    self:CheckHalfOpen()
    self:CheckRedPoint()
    self:OnTime()
    self.openArgs = self.openArgs or {model.currentX, model.currentY}

    local days, day8 = self.model:GetCurrentDay()

    for i=1,8 do
        if i == days then
            -- self.vertabList[i].normalText.text = string.format("<color='#ffff00'>%s</color>", self.verTab[i].name)
            -- self.vertabList[i].selectText.text = string.format("<color='#ffff00'>%s</color>", self.verTab[i].name)
        else
            self.vertabList[i].normalText.text = self.verTab[i].name
            self.vertabList[i].selectText.text = self.verTab[i].name
        end
        if i == 8 then
            self.verTabGroup.openLevel[i] = 999
        else
            -- if i > days then
            --     self.verTabGroup.cannotSelect[i] = true --不能选中
            -- else
            --     self.verTabGroup.cannotSelect[i] = false --可以选中
            -- end
        end
    end
    self.verTabGroup:Layout()
    self:CheckDayBtnRedPoint()
    for i=1,7 do
        if i > days then
            self.verTabGroup.buttonTab[i]["normal"].transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.sevenday_textures, "NotTab")
        else
            self.verTabGroup.buttonTab[i]["normal"].transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton8")
        end
    end

    if SevendayManager.Instance.lastDays == nil or SevendayManager.Instance.lastDays < 15 then
        self.targetOpenLevel = 0
    else
        self.targetOpenLevel = 999
    end

    local targetY = 0
    for i=1,#BibleManager.Instance.servenDayData.seven_day do
        local dayData = BibleManager.Instance.servenDayData.seven_day[i]
        if dayData.rewarded == 0 then
            targetY = i
            break
        end
    end
    if targetY == 0 then
        --选到第一个明日可领
        if self.verTabGroup.openLevel[days+1] == 0 then
            --有开启显示
            targetY = days+1
        else
            local tempDay = days
            for i=tempDay, 1, -1 do
                if self.verTabGroup.openLevel[i] == 0 then
                    targetY = i
                    break
                end
            end
        end
    end
    if targetY == 0 then
        targetY = days
    end
    if targetY == 8 then
        targetY = 7
    end

    model.currentX = self.openArgs[1] or 1
    model.currentY = self.openArgs[2] or targetY
    self.horTabGroup:ChangeTab(model.currentX)
    self.verTabGroup:ChangeTab(model.currentY)

    if self.effTimerId1 ~= nil then
        LuaTimer.Delete(self.effTimerId1)
        self.effTimerId1 = nil
    end
    if self.effTimerId2 ~= nil then
        LuaTimer.Delete(self.effTimerId2)
        self.effTimerId2 = nil
    end
    if self.effTimerId3 ~= nil then
        LuaTimer.Delete(self.effTimerId3)
        self.effTimerId3 = nil
    end
    local finishNum = self.model:GetFinishTargetNum()
    finishNum = 80
    -- if finishNum >= DataGoal.data_get_complete[1].count then
    --     self.effTimerId1 = LuaTimer.Add(1000, 3000, function()
    --        self.progBarBox1.gameObject.transform.localScale = Vector3(1.2,1.1,1)
    --        Tween.Instance:Scale(self.progBarBox1.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    --     end)
    -- end
    -- if finishNum >= DataGoal.data_get_complete[2].count then
    --     self.effTimerId2 = LuaTimer.Add(1000, 3000, function()
    --        self.progBarBox2.gameObject.transform.localScale = Vector3(1.2,1.1,1)
    --        Tween.Instance:Scale(self.progBarBox2.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    --     end)
    -- end
    -- if finishNum >= DataGoal.data_get_complete[3].count then
    --     self.effTimerId3 = LuaTimer.Add(1000, 3000, function()
    --        self.progBarBox3.gameObject.transform.localScale = Vector3(1.2,1.1,1)
    --        Tween.Instance:Scale(self.progBarBox3.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    --     end)
    -- end
end

--更新进度条
function SevendayPanel:UpdateProgBar()
    if self.hasInit == false then
         return
    end
    local finishNum = self.model:GetFinishTargetNum()
    local totalNum = DataGoal.data_get_complete[#DataGoal.data_get_complete].count
    self.progBarTxt.text = string.format(" %s/%s", finishNum, totalNum)
    self.otherText.text = string.format("(<color='#13fc60'>%s</color>/%s)",finishNum,totalNum)
    local percent = finishNum/totalNum
    self.progBar:GetComponent(RectTransform).sizeDelta = Vector2(percent*408, 16)

    -- self.progBarBox1.transform:GetComponent(RectTransform).anchoredPosition = Vector2((DataGoal.data_get_complete[1].count/totalNum)*408, 0)
    -- self.progBarBox2.transform:GetComponent(RectTransform).anchoredPosition = Vector2((DataGoal.data_get_complete[2].count/totalNum)*408, 0)
    -- self.progBarBox3.transform:GetComponent(RectTransform).anchoredPosition = Vector2((DataGoal.data_get_complete[3].count/totalNum)*408, 0)
end

--更新福利里面今日累冲
function SevendayPanel:UpdateCharge()
    if self.hasInit == false then
         return
    end
    if self.panelList[1] ~= nil then
        self.panelList[1]:UpdateCharge()
    end
end

--更新目标奖励领取状态
function SevendayPanel:UpdateTargetRewardState()
    if self.hasInit == false then
         return
    end
    local finishNum = self.model:GetFinishTargetNum()
    local totalNum = DataGoal.data_get_complete[#DataGoal.data_get_complete].count


    local hasGotList = {}
    if self.model.complete_list ~= nil then
        for i = 1, #DataGoal.data_get_complete do
            local cfgData = DataGoal.data_get_complete[i]
            local hasNotGet = true --还没有领取这个位置的奖励
            for k, v in pairs(self.model.complete_list) do
                if v.count == cfgData.count then
                    hasNotGet = false --已经领取了
                    -- BaseUtils.SetGrey(self.progBarBoxImgList[i], true)
                    hasGotList[i] = true
                    break
                end
            end
            if hasNotGet then
                if finishNum < cfgData.count then
                    hasNotGet = false
                end
            end
        end
    end

    if self.effTimerId1 ~= nil then
        LuaTimer.Delete(self.effTimerId1)
        self.effTimerId1 = nil
    end
    if self.effTimerId2 ~= nil then
        LuaTimer.Delete(self.effTimerId2)
        self.effTimerId2 = nil
    end
    if self.effTimerId3 ~= nil then
        LuaTimer.Delete(self.effTimerId3)
        self.effTimerId3 = nil
    end
    local finishNum = self.model:GetFinishTargetNum()
    -- finishNum = 80
    -- if finishNum >= DataGoal.data_get_complete[1].count and hasGotList[1] ~= true then
    --     self.effTimerId1 = LuaTimer.Add(1000, 3000, function()
    --        self.progBarBox1.gameObject.transform.localScale = Vector3(1.2,1.1,1)
    --        Tween.Instance:Scale(self.progBarBox1.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    --     end)
    -- end
    -- if finishNum >= DataGoal.data_get_complete[2].count and hasGotList[2] ~= true then
    --     self.effTimerId2 = LuaTimer.Add(1000, 3000, function()
    --        self.progBarBox2.gameObject.transform.localScale = Vector3(1.2,1.1,1)
    --        Tween.Instance:Scale(self.progBarBox2.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    --     end)
    -- end
    -- if finishNum >= DataGoal.data_get_complete[3].count and hasGotList[3] ~= true then
    --     self.effTimerId3 = LuaTimer.Add(1000, 3000, function()
    --        self.progBarBox3.gameObject.transform.localScale = Vector3(1.2,1.1,1)
    --        Tween.Instance:Scale(self.progBarBox3.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    --     end)
    -- end



    self:UpdateOthenRedPoint(hasGotList)
end

function SevendayPanel:GetCurrentDay()
    local days = #BibleManager.Instance.servenDayData.seven_day
    local y = tonumber(os.date("%y", BaseUtils.BASE_TIME))
    local m = tonumber(os.date("%m", BaseUtils.BASE_TIME))
    local d = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local day8 = BibleManager.Instance.servenDayData.seven_day[8]
    if day8 ~= nil and (day8.year ~= y or day8.month ~= m or day8.day ~= d) then
        days = 8
    end
    return days, day8
end

function SevendayPanel:OnHide()
    self:RemoveListeners()
end

function SevendayPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levListener)
    SevendayManager.Instance.onUpdateRed:RemoveListener(self.redListener)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function SevendayPanel:VerChangeTab(index)
    local days, day8 = self.model:GetCurrentDay()


    if index > days then
        self.verTabGroup.buttonTab[index].select:SetActive(false)
        self.verTabGroup.buttonTab[index].normal:SetActive(true)
    end
    local btnCfgData = DataGoal.data_tab[index].effect
    local str = btnCfgData[1].val
    self.hortabList[2].trans:Find("Normal/Text"):GetComponent(Text).text = btnCfgData[1].val
    self.hortabList[2].trans:Find("Select/Text"):GetComponent(Text).text = btnCfgData[1].val

    self:HorTabSetIcon(2,str)


    local str = btnCfgData[2].val
    self.hortabList[3].trans:Find("Normal/Text"):GetComponent(Text).text = btnCfgData[2].val
    self.hortabList[3].trans:Find("Select/Text"):GetComponent(Text).text = btnCfgData[2].val


    self:HorTabSetIcon(3,str)





    local model = self.model
    self.model.currentY = index

    local lev = 0
    if self.halfOpen[index] == true and (SevendayManager.Instance.lastDays == nil or SevendayManager.Instance.lastDays < 15) then
        lev = 0
    else
        lev = 255
    end

    self.horTabGroup.openLevel = {0, self.targetOpenLevel, self.targetOpenLevel, lev}
    if index == 8 then
        self.horTabGroup.openLevel = {0, 999, lev}
        self.model.currentX = 1
        self.horTabGroup:ChangeTab(model.currentX)
    end
    self.horTabGroup:Layout()


     if (index > days) then
        --不开
        -- NoticeManager.Instance:FloatTipsByString(string.format(TI18N("登录第<color='#00ff00'>%s</color>天才能查看"), index))
        self.hortabList[2].trans.gameObject:SetActive(false)
        self.hortabList[3].trans.gameObject:SetActive(false)
        model.currentX = 1
    end

    if lev == 255 and model.currentX == 3 then
        model.currentX = 1
        self:ChangeTab(model.currentX, model.currentY)
        self.horTabGroup:ChangeTab(model.currentX)
        return
    end

    self:ChangeTab(model.currentX, model.currentY)
end

function SevendayPanel:HorChangeTab(index)
    local model = self.model
    self.model.currentX = index
    self:ChangeTab(model.currentX, model.currentY)
end

function SevendayPanel:ChangeTab(x, y)

    local model = self.model
    if self.lastIndexX ~= nil then
        if self.panelList[self.lastIndexX] ~= nil then
            self.panelList[self.lastIndexX]:Hiden()
            self.horTabGroup.buttonTab[self.lastIndexX].gameObject.transform.localScale = Vector3(1,1,1)
        end
    end



    if self.horTabGroup.buttonTab[x] ~= nil then
        self.horTabGroup.buttonTab[x].gameObject.transform.localScale = Vector3(0.85,0.85,1)
        if self.LuaTimerList[x] ~= nil then
            LuaTimer.Delete(self.LuaTimerList[x])
            self.LuaTimerList[x] = nil
        end
        self.LuaTimerList[x] = LuaTimer.Add(0, function()
               Tween.Instance:Scale(self.horTabGroup.buttonTab[x].gameObject, Vector3(1,1,1), 1.4, function()   end, LeanTweenType.easeOutElastic)
            end)
    end



    if self.showOtherPanel == true then
        self.showOtherPanel = false
        self.witchImage.gameObject:SetActive(true)
        self.horContainer.gameObject:SetActive(true)
        self.otherSelect.gameObject:SetActive(false)
        self.timeObj.gameObject:SetActive(false)
        if self.otherPanel ~= nil then
            self.otherPanel:Hiden()
        end
    end



    local panel = self.panelList[x]

    if panel == nil then
        if x == 1 then
            panel = SevendayWelfare.New(model,self.mainContainer)
        elseif x == 2 or x == 3 then
            panel = SevendayTarget.New(model,self.mainContainer)
        elseif x == 4 then
            panel = SevendayHalfPrice.New(model,self.mainContainer)
        end
        self.panelList[x] = panel
    end

    self.lastIndexX = x
    if panel ~= nil then
        if x == 1 or x == 4 then
            panel:Show(y)
        else
            local tab = x
            panel:Show({day = y, tabId = tab})
        end
    end
    self.openArgs = {}
    self:CheckRedPoint()
end

function SevendayPanel:CheckHalfOpen()
    self.halfOpen = self.halfOpen or {}
    local lev = RoleManager.Instance.RoleData.lev
    for _,v in pairs(DataGoal.data_discount) do
        -- self.halfOpen[v.day] = (lev <= v.lev)
        self.halfOpen[v.day] = false
    end
end

function SevendayPanel:CheckRedPoint()
    self:CheckDayBtnRedPoint()
    local redDic = SevendayManager.Instance.redPointDic
    for i,v in ipairs(self.horTabGroup.buttonTab) do
        v.red:SetActive(false)
    end
    local res = redDic[self.model.currentY]
    if res ~= nil then
        local i = 1
        while res ~= 0 do --逻辑1
            if i == 4 then
                --仅对半价抢购做处理
                self.horTabGroup.buttonTab[i].red:SetActive(res % 2 == 1)
            end
            if i ~= 3 then
                --页签2被拆分成两个（2，3)所以越过3，将第3次计算留在第4个页签
                res = math.floor(res / 2)
            end
            i = i + 1
        end
    end

    -------------------检查福利是否有得领取
    --检查福利目标是否达成，有得领取
    for k, v in pairs(DataGoal.data_goal) do
        if v.tabId == 15 and v.day == self.model.currentY then
            --检查福利里面目标是否达成，有得领取
            local protoData = self.model.targetTab[v.id]
            if protoData ~= nil and protoData.finish == 1 and protoData.rewarded ~= 1 then
                self.horTabGroup.buttonTab[1].red:SetActive(true)
            end
        end
    end

    local days, day8 = self.model:GetCurrentDay()
    if self.model.dayToCharge[self.model.currentY] ~= nil and self.model.todayChargeData ~= nil then
        --检查充值福利是否达成，有得领取
        for i,v in ipairs(self.model.dayToCharge[self.model.currentY]) do
            if self.model.currentY == days then
                --是不是当天的
                if self.model.todayChargeData.day_charge >= DataCheckin.data_daily_charge[v].charge then
                    --充值数据满足
                    if self.model.chargeTab[v] == nil or self.model.chargeTab[v].rewarded == 0 then
                        --还没领取
                         self.horTabGroup.buttonTab[1].red:SetActive(true)
                        break
                    end
                end
            end
        end
    end
    if  self.model.currentY <= days then
        --达到登陆天数
        if (BibleManager.Instance.servenDayData.seven_day[self.model.currentY] == nil or BibleManager.Instance.servenDayData.seven_day[self.model.currentY].rewarded == 0) then
            self.horTabGroup.buttonTab[1].red:SetActive(true)
        end
    else
        self.horTabGroup.buttonTab[1].red:SetActive(false)
    end

    -------------------检查目标是否有得领取
    for i,v in ipairs(self.horTabGroup.buttonTab) do
        if i == 2 or i == 3 then
            v.red:SetActive(false)
        end
        if i == 2 or i == 3 then
            local state = false
            local datalist = {}
            if self.model.dayToIds[self.model.currentY] ~= nil then
                for _,v in pairs(self.model.dayToIds[self.model.currentY]) do
                    if DataGoal.data_goal[v].tabId == DataGoal.data_tab[self.model.currentY].effect[i-1].tabId then
                        table.insert(datalist, v)
                    end
                end
            end
            for j=1,#datalist do
                local protoData = self.model.targetTab[datalist[j]]
                if protoData ~= nil and protoData.finish == 1 and protoData.rewarded ~= 1 then
                    state = true
                    break
                end
            end
            v.red:SetActive(state)
        end
    end
end

function SevendayPanel:CheckDayBtnRedPoint()
    local redDic = SevendayManager.Instance.redPointDic
    local days, day8 = self.model:GetCurrentDay()
    for key_day,v in ipairs(self.verTabGroup.buttonTab) do
        -- 旧逻辑，恕我无知啊，实在看不懂
        -- local res = redDic[k]
        -- local state = false
        -- if res ~= nil then
        --     local i = 1
        --     while res ~= 0 do
        --         if res % 2 == 1 then
        --             state = true
        --             break
        --         end
        --         res = math.floor(res / 2)
        --         i = i + 1
        --     end
        -- end

        local state = false
        if days >= key_day then
            --达到登陆天数
            if (BibleManager.Instance.servenDayData.seven_day[key_day] == nil or BibleManager.Instance.servenDayData.seven_day[key_day].rewarded == 0) then
                state = true
            end

            if state == false then
                --检查福利目标是否达成，有得领取
                for k, v in pairs(DataGoal.data_goal) do
                    if v.tabId == 15 and v.day == key_day then
                        --检查福利里面目标是否达成，有得领取
                        local protoData = self.model.targetTab[v.id]
                        if protoData ~= nil and protoData.finish == 1 and protoData.rewarded ~= 1 then
                            state = true
                        end
                    end
                end
            end

            if state == false then
                local days, day8 = self.model:GetCurrentDay()
                if self.model.dayToCharge[key_day] ~= nil and self.model.todayChargeData ~= nil then
                    --检查充值福利是否达成，有得领取
                    for i,v in ipairs(self.model.dayToCharge[key_day]) do
                        if key_day == days then
                            --是不是当天的
                            if self.model.todayChargeData.day_charge >= DataCheckin.data_daily_charge[v].charge then
                                --充值数据满足
                                if self.model.chargeTab[v] == nil or self.model.chargeTab[v].rewarded == 0 then
                                    --还没领取
                                    state = true
                                    break
                                end
                            end
                        end
                    end
                end
            end

            -------------------检查目标是否有得领取
            if state == false then
                for i = 2, 3 do
                    local datalist = {}
                    if self.model.dayToIds[key_day] ~= nil then
                        for _,v in pairs(self.model.dayToIds[key_day]) do
                            if DataGoal.data_goal[v].tabId == DataGoal.data_tab[key_day].effect[i-1].tabId then
                                table.insert(datalist, v)
                            end
                        end
                        for j=1,#datalist do
                            local protoData = self.model.targetTab[datalist[j]]
                            if protoData ~= nil and protoData.finish == 1 and protoData.rewarded ~= 1 then
                                state = true
                                break
                            end
                        end
                    end
                end
            end
        end
        v.red:SetActive(state)
    end
end

function SevendayPanel:OnTime()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if SevendayManager.Instance.lastDays ~= nil and SevendayManager.Instance.lastDays < 15 then
        if SevendayManager.Instance.lastDays == 14 then
            self.timerId = LuaTimer.Add(0, 500, function()
                local h = tonumber(os.date("%H", BaseUtils.BASE_TIME))
                local m = tonumber(os.date("%m", BaseUtils.BASE_TIME))
                local s = tonumber(os.date("%S", BaseUtils.BASE_TIME))
                local s = 86400 - h * 3600 - m * 60 - s
                local _
                _,h,m,s = BaseUtils.time_gap_to_timer(s)
                if h > 0 then
                    self.timeText.text = string.format(TI18N("%s小时%s分"), tostring(h), tostring(m))
                elseif m > 0 then
                    self.timeText.text = string.format(TI18N("%s分%s秒"), tostring(m), tostring(s))
                elseif s > 0 then
                    self.timeText.text = string.format(TI18N("%s秒"), tostring(s))
                else
                    self.timeText.text = string.format(TI18N("已结束"))
                end
            end)
        else
            self.timerId = LuaTimer.Add(0, 60 * 1000, function()
                local h = tonumber(os.date("%H", BaseUtils.BASE_TIME))
                local m = tonumber(os.date("%m", BaseUtils.BASE_TIME))
                local s = tonumber(os.date("%S", BaseUtils.BASE_TIME))
                local s = 86400 - h * 3600 - m * 60 - s
                local _,h2,_,_ = BaseUtils.time_gap_to_timer(s)
                if SevendayManager.Instance.lastDays < 14 then
                    self.timeText.text = string.format(TI18N("%s天%s小时"), tostring(14 - SevendayManager.Instance.lastDays), tostring(h2))
                else
                    self:OnTime()
                end
            end)
        end
    else
        self.timeObj:SetActive(false)
    end
end


function SevendayPanel:OpenOtherPanel()
    if self.showOtherPanel == false then

        self.otherSelect.gameObject:SetActive(true)
        self.verTabGroup:UnSelect(self.verTabGroup.currentIndex)
        self:ChangeTab(0,0)

        self.showOtherPanel = true
        self.witchImage.gameObject:SetActive(false)
        self.horContainer.gameObject:SetActive(false)
        self.timeObj.gameObject:SetActive(true)
        if self.otherPanel == nil then
            self.otherPanel = SevendayOther.New(self.model,self.mainContainer,self)
        end

        self.otherPanel:Show()

    end

end


function SevendayPanel:UpdateOthenRedPoint(Golist)
    print("=========================================================================================")

    self.isShowOtherRed = false
    for i,v in ipairs(DataGoal.data_get_complete) do
        local finishNum = self.model:GetFinishTargetNum()
        print(finishNum .. "完成任务数量")
        if finishNum >= DataGoal.data_get_complete[i].count and Golist[i] ~= true then
            self.isShowOtherRed = true
        end
    end


    if self.isShowOtherRed == true then
        self.otherRedPoint.gameObject:SetActive(true)
    else
        self.otherRedPoint.gameObject:SetActive(false)
    end

end


function SevendayPanel:HorTabSetIcon(index,str)
    if self.specilLoaderList[index] == nil then
        self.specilLoaderList[index] = SingleIconLoader.New(self.hortabList[index].trans:Find("Icon").gameObject)
    end

    if str == "冒险技能" then
        self.specilLoaderList[index]:SetSprite(SingleIconType.Item,20025)
    elseif str == "公会任务" then
        self.specilLoaderList[index]:SetSprite(SingleIconType.Item,90011)
    elseif str == "翅膀进阶" then
        self.specilLoaderList[index]:SetSprite(SingleIconType.Item,21100)
    elseif str == "爵位挑战" then
        self.specilLoaderList[index]:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.sevenday_textures,"1024"))
    elseif str == "十二星座" then
        self.specilLoaderList[index]:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.sevenday_textures,"2013"))
    elseif index == 2 then
        self.specilLoaderList[index]:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.sevenday_textures,"Icon2"))
    elseif index == 3 then
        self.specilLoaderList[index]:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.sevenday_textures,"Icon3"))
    end

end











