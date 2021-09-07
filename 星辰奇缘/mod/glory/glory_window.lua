GloryWindow = GloryWindow or BaseClass(BaseWindow)

function GloryWindow:__init(model)
    self.model = model
    self.mgr = GloryManager.Instance

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.glory_window

    self.resList = {
        { file = AssetConfig.glorywindow, type = AssetType.Main, holdTime = 0 },
        { file = AssetConfig.glory_textures, type = AssetType.Dep },
        { file = AssetConfig.minnumber_1, type = AssetType.Dep },
        { file = AssetConfig.arena_textures, type = AssetType.Dep },
    }

    self.rankList = { }
    self.levelList = { }
    self.todayRewardList = { }
    self.rewardList = { }

    self.updateListener = function() self:Update() end
    self.updateRankListener = function() self:ReloadRank() end
    self.levelUpListener = function() self:LocateFriend() end
    self.updateModeListener = function() self:UpdateTodayReward() self:ReloadLevel() end

    self.OnOpenEvent:AddListener( function() self:OnOpen() end)
    self.OnHideEvent:AddListener( function() self:OnHide() end)
end

function GloryWindow:__delete()
    self.OnHideEvent:Fire()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.battleRewardSlotLayout ~= nil then
        self.battleRewardSlotLayout:DeleteMe()
        self.battleRewardSlotLayout = nil
    end
    if self.attrPanel ~= nil then
        self.attrPanel:DeleteMe()
        self.attrPanel = nil
    end
    if self.todayRewardList ~= nil then
        for _, v in pairs(self.todayRewardList) do
            if v ~= nil then
                v.loader:DeleteMe()
            end
        end
    end
    if self.battleGlorySlot ~= nil then
        self.battleGlorySlot:DeleteMe()
        self.battleGlorySlot = nil
    end
    if self.rankList ~= nil then
        for _, v in pairs(self.rankList) do
            if v ~= nil then
                v.headSlot:DeleteMe()
                v.headImage.sprite = nil
            end
        end
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.rewardList ~= nil then
        for _, v in pairs(self.rewardList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.data:DeleteMe()
            end
        end
    end
    self.model.selectLevelObj = nil
    self:AssetClearAll()
end

function GloryWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glorywindow))
    self.gameObject.name = "GloryWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    local main = t:Find("Main")

    local rank = main:Find("Rank")
    local container = rank:Find("Container")
    for i = 1, 4 do
        self.rankList[i] = { }
        self.rankList[i].transform = container:GetChild(i - 1)
        self.rankList[i].gameObject = self.rankList[i].transform.gameObject
        self.rankList[i].headSlot = HeadSlot.New()
        NumberpadPanel.AddUIChild(self.rankList[i].transform:Find("Head"), self.rankList[i].headSlot.gameObject)
        self.rankList[i].headSlot.transform:SetAsFirstSibling()
        self.rankList[i].headImage = self.rankList[i].transform:Find("Head/Image"):GetComponent(Image)
        self.rankList[i].levText = self.rankList[i].transform:Find("Head/Lev"):GetComponent(Text)
        self.rankList[i].button = self.rankList[i].gameObject:GetComponent(Button)
    end
    self.showRankButton = rank:Find("Show"):GetComponent(Button)
    self.rankNothing = rank:Find("Nothing").gameObject

    local battle = main:Find("Battle")
    self.battleLevelText = battle:Find("Name/Text"):GetComponent(Text)
    self.battleLevelImage = battle:Find("Name/Image"):GetComponent(Image)
    self.battleLevText = battle:Find("Lev"):GetComponent(Text)
    self.battleRewardTitleText = battle:Find("RewardBg/RewardTitle/Text"):GetComponent(Text)
    self.battleRewardSlotLayout = LuaBoxLayout.New(battle:Find("RewardBg/SlotList"), { axis = BoxLayoutAxis.X, cspacing = 0, border = 10 })
    self.battleModelContainer = battle:Find("Bg")
    self.battleRewardConditionText = battle:Find("RewardBg/Reward/Condition"):GetComponent(Text)
    self.battleRewardDisText = battle:Find("RewardBg/Reward/Dis"):GetComponent(Text)
    self.battleRewardDescText = battle:Find("RewardBg/Reward/Desc"):GetComponent(Text)
    self.battleRewardPreviewBtn = battle:Find("RewardBg/Reward/Preview"):GetComponent(Button)
    self.battleGlorySlot = ItemSlot.New()
    battle:Find("RewardBg/Reward/Slot/Image").gameObject:SetActive(false)
    NumberpadPanel.AddUIChild(battle:Find("RewardBg/Reward/Slot"), self.battleGlorySlot.gameObject)
    --  = SingleIconLoader.New(battle:Find("RewardBg/Reward/Slot/Image").gameObject)
    self.battleAddText = battle:Find("Add/Text"):GetComponent(Text)
    self.battleAddObj = battle:Find("Add").gameObject

    local progress = battle:Find("Progress")
    local levelContainer = progress:Find("LevelContainer")
    for i = 1, 6 do
        self.levelList[i] = GloryLevelItem.New(self.model, levelContainer:GetChild(i - 1).gameObject, self.assetWrapper)
        self.levelList[i].clickCallback = function(lev) self:ShowLevel(lev) end
    end
    self.sliderRect = progress:Find("Slider")
    self.friendHead = {
        gameObject = levelContainer:Find("Head").gameObject,
        transform = levelContainer:Find("Head"),
        image = levelContainer:Find("Head/Image"):GetComponent(Image),
        button = levelContainer:Find("Head"):GetComponent(Button),
        levText = levelContainer:Find("Head/Lev"):GetComponent(Text),
    }

    self.videoBtn = battle:Find("Video"):GetComponent(Button)
    self.infoText = main:Find("Info"):GetComponent(Text)
    self.clearRewardButton = main:Find("ClearReward"):GetComponent(Button)
    self.clearRewardImage = main:Find("ClearReward"):GetComponent(Image)
    self.clearRewardText = main:Find("ClearReward/Text"):GetComponent(Text)
    self.challengeButton = main:Find("Challenge"):GetComponent(Button)
    self.passedObj = main:Find("HasChallenge").gameObject
    self.challengeImage = self.challengeButton.gameObject:GetComponent(Image)
    self.challengeButtonCan = main:Find("Challenge/CanChallenge").gameObject
    self.challengeButtonNo = main:Find("Challenge/NoChallenge").gameObject
    self.challengeButtonNoText = main:Find("Challenge/NoChallenge"):GetComponent(Text)
    self.bugleBtn = main:Find("Battle/Bugle"):GetComponent(Button)
    self.noticeBtn = main:Find("Notice"):GetComponent(Button)

    self.modLayout = LuaBoxLayout.New(main:Find("TodayReward/Container"), { axis = BoxLayoutAxis.X, cspacing = 0, border = 5 })
    for i = 1, 3 do
        local tab = { }
        tab.transform = self.modLayout.panelRect:GetChild(i)
        tab.gameObject = tab.transform.gameObject
        tab.button = tab.gameObject:GetComponent(Button)
        tab.loader = SingleIconLoader.New(tab.transform:Find("Image").gameObject)
        tab.numText = tab.transform:Find("Num"):GetComponent(Text)
        self.todayRewardList[i] = tab
    end
    self.modAddText = main:Find("TodayReward/Container/Add"):GetComponent(Text)

    self.TxtDesc = main:Find("Battle/TxtDesc"):GetComponent(Text)
    self.TxtDesc.text = string.format(TI18N("每周奖励将在%s\n"), TI18N("<color='#00ff00'>周一五点</color>发放"))
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener( function() WindowManager.Instance:CloseWindow(self) end)
    self.battleRewardPreviewBtn.onClick:AddListener( function() self:OpenAttrShow() end)
    self.showRankButton.onClick:AddListener( function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ui_rank, { 1, 56 }) end)
    self.challengeButton.onClick:AddListener( function() self:OnClick() end)
    self.videoBtn.onClick:AddListener( function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_video, { self.selectLev }) end)
    self.noticeBtn.onClick:AddListener( function() self:OnNotice() end)
    self.bugleBtn.onClick:AddListener( function() self:OnBugle() end)
    self.clearRewardButton.onClick:AddListener( function() self:OnReward() end)
    self.bugleBtn.transform.anchoredPosition = Vector2(-13, 128)

    self.BtnAttention = main:Find("Attention"):GetComponent(Button);
    self.BtnAttention.onClick:AddListener(
    function()
       local TipsData = {TI18N("层数<color='#FFFF00'>越高</color>奖励越丰厚")}
        TipsManager.Instance:ShowText( { gameObject = self.BtnAttention.gameObject, itemData = TipsData})
    end )
    main:Find("Title/Text"):GetComponent(Text).text = GloryManager.Instance.name
end

function GloryWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GloryWindow:OnHide()
    self:RemoveListeners()
    self.model:CloseBeforePanel();
    if self.previewComp ~= nil then
        self.previewComp:Hide()
        self.lastUnitId = nil
    end
    if self.TimerCD ~= nil then
        LuaTimer.Delete(self.TimerCD)
        self.TimerCD = nil
    end
end

function GloryWindow:Update()
    self:ReloadLevel()
    self:Reload()
    if self.model.lastLevel ~= nil and self.model.lastLevel ~= self.model.currentData.new_id then
        self:AnimReload()
        self.model.lastLevel = nil
    end
    self:ShowLevel(self.curLev);
end

function GloryWindow:OnOpen()
    self:RemoveListeners()
    GloryManager.Instance.onUpdateInfo:AddListener(self.updateListener)
    GloryManager.Instance.onUpdateRank:AddListener(self.updateRankListener)
    EventMgr.Instance:AddListener(event_name.exp_mode_change, self.updateModeListener)
    GloryManager.Instance.onUpdateLevel:AddListener(self.levelUpListener)

    GloryManager.Instance:send14426()
    GloryManager.Instance:send14427()


    self.dailyMode = nil
    self.normalMode = nil
    local newId = self.model.currentData.new_id or 0;
    if newId == DataGlory.data_level_length then
        self.dailyMode = DataGlory.data_level[newId].day_exp_mod
        self.normalMode = DataGlory.data_level[newId].normal_exp_mod
    else
        self.dailyMode = DataGlory.data_level[newId + 1].day_exp_mod
        self.normalMode = DataGlory.data_level[newId + 1].normal_exp_mod
    end

    RoleManager.Instance:send10036(self.dailyMode)

    if self.dailyMode ~= nil then
        RoleManager.Instance:send10036(self.dailyMode)
        self:UpdateTodayReward()
    end
    -- if self.normalMode ~= nil then
    --     RoleManager.Instance:send10036(self.normalMode)
    -- end
    -- BaseUtils.dump(self.model.currentData, "currentData")
    self:Update()
    self:LocateFriend()
end

function GloryWindow:RemoveListeners()
    GloryManager.Instance.onUpdateInfo:RemoveListener(self.updateListener)
    GloryManager.Instance.onUpdateRank:RemoveListener(self.updateRankListener)
    EventMgr.Instance:RemoveListener(event_name.exp_mode_change, self.updateModeListener)
    GloryManager.Instance.onUpdateLevel:RemoveListener(self.levelUpListener)
end

function GloryWindow:SetSlider(value)
    if value < 0 then
        value = 0
    elseif value > 1 then
        value = 1
    end

    self.sliderRect.sizeDelta = Vector2(128 + 512 * value, 17)
end

function GloryWindow:ShowLevel(lev)
    self.curLev = lev;
    local cfgData = DataGlory.data_level[lev]
    self.battleLevelText.text = string.format(TI18N("第%s层 %s"), lev, cfgData.name)
    self.battleLevText.text = string.format(TI18N("推荐评分:%s"), cfgData.need_fc)

    local w2 = self.battleLevelText.preferredWidth
    local w1 = self.battleLevelImage.transform.sizeDelta.x
    self.battleLevelText.transform.anchoredPosition = Vector2((w1 - w2) / 2 + 3, 0)
    self.battleLevelImage.transform.anchoredPosition = Vector2((w1 - w2) / 2 - 3, 3)

    if self.lastUnitId ~= cfgData.unit_id then
        self:ReloadPreview(cfgData.unit_id)
        self.lastUnitId = cfgData.unit_id
    end

    self.selectLev = lev

    -- print(lev)
    if lev >(self.model.currentData.new_id or 1) + 1 then
        self.challengeButtonCan:SetActive(false)
        self.challengeButtonNo:SetActive(true)
        self.challengeButtonNoText.text = string.format(TI18N("请先通过第%s关"), lev - 1)
        self.challengeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    else
        local offTime =(self.model.currentData.end_time or 0) - BaseUtils.BASE_TIME;
        if offTime > 0 then
            self.challengeButtonCan:SetActive(false)
            self.challengeButtonNo:SetActive(true)
            if self.TimerCD ~= nil then
                LuaTimer.Delete(self.TimerCD)
            end
            self.TimerCD = LuaTimer.Add(0, 1000,
            function()
                local time =(self.model.currentData.end_time or 0) - BaseUtils.BASE_TIME;
                if time > 0 then
                    self.challengeButtonNoText.text = BaseUtils.formate_time_gap(time, ":", 0, BaseUtils.time_formate.MIN);
                else
                    if self.TimerCD ~= nil then
                        LuaTimer.Delete(self.TimerCD)
                        self.TimerCD = nil
                    end
                    self.challengeButtonCan:SetActive(true)
                    self.challengeButtonNo:SetActive(false)
                    self.challengeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                end
            end );
            self.challengeButtonNoText.text = BaseUtils.formate_time_gap(offTime, ":", 0, BaseUtils.time_formate.MIN);
            self.challengeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        else
            self.challengeButtonCan:SetActive(true)
            self.challengeButtonNo:SetActive(false)
            self.challengeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        end
    end

    -- local gainData = DataGlory.data_gain[string.format("%s_%s_%s", self.model.currentData.max_id + 1, RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.sex)] or DataGlory.data_gain[string.format("%s_%s_%s", self.model.currentData.max_id + 1, 0, RoleManager.Instance.RoleData.sex)] or DataGlory.data_gain[string.format("%s_%s_%s", self.model.currentData.max_id + 1, RoleManager.Instance.RoleData.classes, 2)] or DataGlory.data_gain[string.format("%s_%s_%s", self.model.currentData.max_id + 1, 0, 2)]

    local list = nil
    if lev < DataGlory.data_level_length then
        if lev < self.model.currentData.max_id + 1 then
            self.battleRewardTitleText.text = TI18N("通关极品奖励")
            -- string.format(TI18N("第%s关通关奖励"), lev)
            list = GloryManager.RewardFilter((cfgData or { }).normal_reward_client or { })
        else
            self.battleRewardTitleText.text = string.format(TI18N("第%s关首通奖励"), lev)
            list = GloryManager.RewardFilter((cfgData or { }).first_reward or { })
        end
    else
        -- 已经最高
        self.battleRewardTitleText.text = TI18N("请等待新关卡开放")
    end
    -- if self.normalMode ~= nil then
    --     for i,v in ipairs((RoleManager.Instance.expModeTab[self.normalMode] or {}).list or {}) do
    --         if v.num > 0 then
    --             table.insert(list, {v.item_id, v.num})
    --         end
    --     end
    -- end

    self.battleRewardSlotLayout:ReSet()
    for i, v in ipairs(list) do
        local tab = self.rewardList[i]
        if tab == nil then
            tab = { }
            tab.slot = ItemSlot.New()
            tab.data = ItemData.New()
            self.rewardList[i] = tab
        end
        tab.data:SetBase(DataItem.data_get[v[1]])
        tab.slot:SetAll(tab.data, { inbag = false, nobutton = true })
        tab.slot:SetNum(v[2])
        self.battleRewardSlotLayout:AddCell(tab.slot.gameObject)
    end
    for i = #list + 1, #self.rewardList do
        self.rewardList[i].slot.gameObject:SetActive(false)
    end

    if cfgData.guard_num == 0 then
        self.battleAddText.text = TI18N("不能携带守护")
    elseif cfgData.guard_num == 4 then
        self.battleAddText.text = TI18N("特殊条件:无")
    else
        self.battleAddText.text = string.format(TI18N("守护人数≤%s"), cfgData.guard_num)
    end

    if lev > self.model.currentData.new_id then
        self.challengeButton.gameObject:SetActive(true)
        self.passedObj:SetActive(false)
    else
        self.challengeButton.gameObject:SetActive(false)
        self.passedObj:SetActive(true)
    end
end

function GloryWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.battleModelContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.battleModelContainer.gameObject:SetActive(true)
end

function GloryWindow:ReloadPreview(unit_id)
    local monsterData = DataUnit.data_unit[unit_id]

    self.modelCallback = self.modelCallback or function(composite) self:SetRawImage(composite) end

    local setting = {
        name = "Moster"
        ,
        orthographicSize = 0.8
        ,
        width = 480
        ,
        height = 360
        ,
        offsetY = - 0.38
        ,
        noDrag = true
        ,
        noMaterial = true
    }
    local monsterdata = { type = PreViewType.Npc, skinId = monsterData.skin, modelId = monsterData.res, animationId = monsterData.animation_id, scale = monsterData.scale / 100, noMaterial = false }

    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(self.modelCallback, setting, monsterdata)
    else
        self.previewComp:Reload(monsterdata, self.modelCallback)
        self.previewComp.loader.layer = "GloryPreview"
        self.previewComp:Show()
    end
end

function GloryWindow:Reload()
    local currentLevel = nil
    if self.model.lastLevel ~= nil then
        currentLevel = self.model.currentData.new_id
    else
        currentLevel = self.model.currentData.new_id + 1
    end

    local beginLevel = nil
    if currentLevel + 4 < DataGlory.data_level_length then
        beginLevel = currentLevel
    else
        beginLevel = DataGlory.data_level_length - 4
    end
    self:SetSlider((currentLevel - beginLevel) / 4)

    for i = 1, 6 do
        if beginLevel + i - 1 > DataGlory.data_level_length then
            self.levelList[i].gameObject:SetActive(false)
        else
            self.levelList[i]:SetData( { lev = beginLevel + i - 1 })
            self.levelList[i].transform.anchoredPosition = Vector2(128 *(i - 1), 0)
            self.levelList[i].gameObject:SetActive(true)
            self.levelList[i]:SetAlpha(1)
        end
    end

    for _, v in ipairs(self.levelList) do
        if v.data ~= nil and v.data.lev ==(self.model.currentData.new_id or 1) + 1 then
            v:OnClick()
        end
    end
    -- self:ShowLevel((self.model.currentData.new_id or 1) + 1)

    self.infoText.text = string.format(TI18N("已通关: <color='#00ff00'>%s</color>"), self.model.currentData.new_id)

    -- if self.model.currentData.day_reward == 1 then
    --     self.clearRewardImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    --     self.clearRewardText.color = ColorHelper.DefaultButton4
    -- else
    --     self.clearRewardImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    --     self.clearRewardText.color = ColorHelper.DefaultButton3
    -- end
    if self.model.currentData.last_week_flag == 1 then
        if self.effect == nil then
            self.effect = BibleRewardPanel.ShowEffect(20118, self.clearRewardButton.transform, Vector3(1.15, 0.78, 1), Vector3(-58, 22, -400))
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
    -- self.bugleBtn.gameObject:SetActive(self.model.currentData.buff_id ~= nil and self.model.currentData.buff_id ~= 0)
    -- self.bugleBtn.gameObject:SetActive(self.model.buffTab[self.model.currentData.lost_times] ~= nil)
    -- print(string.format("<color='#00ff00'>%s</color>", currentLevel))
    -- print(string.format("<color='#00ff00'>%s</color>", self.model.currentData.new_id))
    -- print(string.format("<color='#00ff00'>%s</color>", self.model.currentData.floor_num))
    self.bugleBtn.gameObject:SetActive(currentLevel - self.model.currentData.new_id < 2 and self.model.currentData.floor_num >= DataGlory.data_level[currentLevel].buff_num)
end

function GloryWindow:AnimReload()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if (self.model.lastLevel or 1) + 4 < DataGlory.data_level_length then
        -- 移动关卡按钮
        local x_tab = { }
        for i, v in ipairs(self.levelList) do
            x_tab[i] = v.transform.anchoredPosition.x
        end
        self.tweenId = Tween.Instance:ValueChange(0, -1, 0.5, function() self.tweenId = nil end, LeanTweenType.linear, function(value)
            for i, v in ipairs(self.levelList) do
                v.transform.anchoredPosition = Vector2(x_tab[i] + 128 * value, 0)
                if v.transform.anchoredPosition.x < 0 then
                    v:SetAlpha((128 + v.transform.anchoredPosition.x) / 128)
                else
                    v:SetAlpha(1)
                end
            end
        end ).id
    else
        -- 进度条变化
        self.tweenId = Tween.Instance:ValueChange(self.sliderRect.sizeDelta.x, self.sliderRect.sizeDelta.x + 128, 0.5, function() self.tweenId = nil end, LeanTweenType.linear, function(value) self.sliderRect.sizeDelta = Vector2(value, 17) end).id
    end
end

function GloryWindow:ReloadRank()
    local datalist = { }
    for i, v in ipairs(self.model.currentData.rank_list or { }) do
        if i <= 4 then
            table.insert(datalist, v)
        end
    end
    for i, data in ipairs(datalist) do
        self.rankList[i].headImage.gameObject:SetActive(false)
        self.rankList[i].headSlot.gameObject:SetActive(true)

        local clickCallback = function()
            TipsManager.Instance:ShowPlayer( { id = data.rid, zone_id = data.zone_id, platform = data.platform, sex = data.sex, classes = data.classes, name = data.name, lev = data.lev })
        end
        self.rankList[i].headSlot:SetAll( { id = data.rid, zone_id = data.zone_id, platform = data.platform, sex = data.sex, classes = data.classes, name = data.name, lev = data.lev }, { clickCallback = clickCallback })
        self.rankList[i].button.onClick:RemoveAllListeners()
        self.rankList[i].button.onClick:AddListener(clickCallback)
        self.rankList[i].headImage.sprite = PreloadManager.Instance:GetClassesHeadSprite(data.classes, data.sex)
        self.rankList[i].levText.text = string.format(TI18N("%s层"), data.new_id or 1)
        -- self.rankList[i].button.onClick:RemoveAllListeners()
    end
    for i = #datalist + 1, #self.rankList do
        self.rankList[i].headImage.gameObject:SetActive(true)
        self.rankList[i].headSlot.gameObject:SetActive(false)
        self.rankList[i].headImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "Unknow")
        self.rankList[i].levText.text = TI18N("<color='#ffff9a'>虚位以待</color>")
        self.rankList[i].button.onClick:RemoveAllListeners()
    end
    self.rankNothing:SetActive(false)
end

function GloryWindow:UpdateTodayReward()
    self.modLayout:ReSet()
    local tab = { }
    local datalist = { }
    for i, v in ipairs((RoleManager.Instance.expModeTab[self.dailyMode] or { }).list or { }) do
        if v.num > 0 then
            tab[v.item_id] =(tab[v.item_id] or 0) + v.num
            -- table.insert(datalist, v)
        end
    end
    local newid = self.model.currentData.new_id or 0
    if newid < DataGlory.data_level_length then
        for _, v in ipairs(GloryManager.RewardFilter(DataGlory.data_level[newid + 1].day_reward)) do
            tab[v[1]] =(tab[v[1]] or 0) + v[2]
        end
    end
    for base_id, v in pairs(tab) do
        table.insert(datalist, { item_id = base_id, num = v })
    end

    for i, v in ipairs(datalist) do
        local tab = self.todayRewardList[i]
        if tab == nil then
            tab = { }
            tab.gameObject = GameObject.Instantiate(self.todayRewardList[1].gameObject)
            tab.button = tab.gameObject:GetComponent(Button)
            tab.transform = tab.transform
            tab.loader = SingleIconLoader.New(tab.transform:Find("Image").gameObject)
            tab.numText = tab.transform:Find("Num"):GetComponent(Text)
            self.todayRewardList[i] = tab
        end
        tab.loader:SetSprite(SingleIconType.Item, DataItem.data_get[v.item_id].icon)
        tab.numText.text = ItemSlot:FormatNum(v.num)
        tab.button.onClick:RemoveAllListeners()
        tab.button.onClick:AddListener( function() TipsManager.Instance:ShowItem( { gameObject = tab.gameObject, itemData = DataItem.data_get[v.item_id] }) end)
        self.modLayout:AddCell(tab.gameObject)
    end
    if #datalist == 0 then
        self.modAddText.gameObject:SetActive(false)
    else
        local titleid = self.model.currentData.new_title_id or 1;
        self.modAddText.text = string.format("+%s%%", math.floor(DataGlory.data_title[titleid].rate / 10))
        self.modLayout:AddCell(self.modAddText.gameObject)
    end
    for i = #datalist + 1, #self.todayRewardList do
        self.todayRewardList[i].gameObject:SetActive(false)
    end
end

function GloryWindow:OpenAttrShow()
    if self.attrPanel == nil then
        self.attrPanel = GloryAttrShow.New(self.model, self.gameObject)
    end
    self.attrPanel:Show()
end

function GloryWindow:OnClick()
    if self.curLev >(self.model.currentData.new_id or 1) + 1 then
        return
    end
    local tmp = DataGlory.data_level[self.curLev]
    if tmp == nil then
        return
    end
    if tmp.need_lev > RoleManager.Instance.RoleData.lev then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("勇士怪物已被胖揍的生活不能自理，请提升到<color='#00ff00'>%s级</color>再来挑战！"), tmp.need_lev))
        return
    end
    local time =(self.model.currentData.end_time or 0) - BaseUtils.BASE_TIME;
    if time > 0 then
        local confirmData = NoticeConfirmData.New()
        confirmData.content = TI18N("消耗{assets_1,90003,1000}即可立刻挑战，是否继续？");
        confirmData.cancelLabel = TI18N("考虑下")
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureCallback = function() GloryManager.Instance:send14429() end
        NoticeManager.Instance:ConfirmTips(confirmData)
        return;
    end
    --    if self.model.currentData.total_times <= self.model.currentData.day_times then
    --        NoticeManager.Instance:FloatTipsByString(TI18N("今日挑战次数已满"))
    --        return
    --    end
    self.model:OpenBeforePanel();
end

function GloryWindow:OnReward()
    --    if self.model.currentData.reward ~= 1 then
    --        if self.model.currentData.day_times < self.model.currentData.total_times then
    --            local confirmData = NoticeConfirmData.New()
    --            confirmData.content = TI18N("每日奖励每天可领取<color='#00ff00'>一次</color>，关数<color='#00ff00'>越高</color>奖励<color='#00ff00'>越高</color>，是否确认领取？")
    --            confirmData.type = ConfirmData.Style.Normal
    --            confirmData.sureCallback = function() GloryManager.Instance:send14425() end
    --            NoticeManager.Instance:ConfirmTips(confirmData)
    --        else
    --            GloryManager.Instance:send14425()
    --        end
    --    else
    --        NoticeManager.Instance:FloatTipsByString(TI18N("今天奖励已领取"))
    --    end
    -- GloryManager.Instance:send14425()

    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_reward)
end

function GloryWindow:ReloadLevel()
    -- ------------------------ 下一爵位 -------------------------------

    local next_title_level = nil

    for i = self.model.currentData.max_id + 1, DataGlory.data_level_length do
        if DataGlory.data_level[i].title ~= 0 then
            next_title_level = i
            break
        end
    end

    if next_title_level == nil then
        self.battleRewardConditionText.text = TI18N("请等待新爵位开放")
        self.battleRewardDescText.text = ""
        self.battleRewardDisText.text = ""
        self.battleAddObj:SetActive(false)
    else
        if next_title_level == self.model.currentData.new_id + 1 then
            self.battleRewardConditionText.text = string.format(TI18N("通关第%s层"), next_title_level)
            self.battleRewardDisText.text = ""
        else
            self.battleRewardConditionText.text = string.format(TI18N("通关第%s层"), next_title_level)
            self.battleRewardDisText.text = string.format(ColorHelper.DefaultButton1Str, string.format(TI18N("(还有<color='#00ff00'>%s</color>层)"), next_title_level - self.model.currentData.new_id))
        end
        self.battleRewardDescText.text = DataGlory.data_level[next_title_level].title_desc
        self.battleAddObj:SetActive(DataGlory.data_title[DataGlory.data_level[next_title_level].title_id].rate > 0)

        self.battleGlorySlot:SetAll(DataItem.data_get[DataGlory.data_level[next_title_level].title], { inbag = false, nobutton = true })
    end

    local w1 = self.battleRewardConditionText.preferredWidth
    local w2 = self.battleRewardDisText.preferredWidth

    self.battleRewardConditionText.transform.anchoredPosition = Vector2((w1 - w2) / 2, -25)
    self.battleRewardDisText.transform.anchoredPosition = Vector2((w1 - w2) / 2, -25)
end

function GloryWindow:OnBugle()
    -- local buff_id = nil
    -- for _, v in ipairs(self.model.buffTab[self.model.currentData.lost_times]) do
    --     if v.min <= self.model.currentData.total_times then
    --         buff_id = v.buffs[1]
    --         break
    --     end
    -- end
    local buff_id = DataGlory.data_level[self.model.currentData.new_id + 1].buff_id
    if buff_id ~= nil then
        TipsManager.Instance:ShowText( { gameObject = self.bugleBtn.gameObject, itemData = { TI18N("经过多次挑战，发现了怪物的弱点，获得增益："), DataBuff.data_list[buff_id].desc } })
    end
end

function GloryWindow:OnNotice()
    TipsManager.Instance:ShowText( {
        gameObject = self.noticeBtn.gameObject,
        itemData =
        {
            TI18N("1. 每日可进行<color='#00ff00'>无限次</color>挑战"),
            TI18N("2. 爵位挑战将在每周一重置<color='#00ff00'>5关</color>挑战并发放排行周奖励"),
            TI18N("3. 本周最高挑战层数<color='#00ff00'>越高</color>可领取到<color='#00ff00'>越丰厚</color>的周奖励，个人周奖励可在<color='#00ff00'>下周一五点</color>后进行领取"),
            TI18N("4. 根据所到达过的<color='#00ff00'>最高</color>关数，将会获得丰厚的<color='#00ff00'>总奖励加成</color>")
        }
    } )
end

function GloryWindow:FindTheFriend()
    local floorData = nil
    for _, floor in ipairs(self.model.nearData or { }) do
        for i, person in pairs(floor.role_list) do
            local key = BaseUtils.Key(person.rid, person.platform, person.zone_id)
            if FriendManager.Instance.friend_List[key] ~= nil and FriendManager.Instance.friend_List[key].type == 0 then
                floorData = BaseUtils.copytab(person)
                floorData.floor = floor.floor
                return floorData
            end
        end
    end
    return nil
end

function GloryWindow:LocateFriend()
    local floorData = self:FindTheFriend()
    self.friendHead.gameObject:SetActive(floorData ~= nil)
    self.friendHead.button.onClick:RemoveAllListeners()
    if floorData ~= nil then
        local friendData = FriendManager.Instance.friend_List[BaseUtils.Key(floorData.rid, floorData.platform, floorData.zone_id)]
        self.friendHead.image.sprite = PreloadManager.Instance:GetClassesHeadSprite(friendData.classes, friendData.sex)
        self.friendHead.levText.text = friendData.lev

        for i, v in ipairs(self.levelList) do
            if v.transform.anchoredPosition.x >= 128 and v.data ~= nil and v.data.lev == floorData.floor then
                self.friendHead.transform:SetParent(v.transform)
                self.friendHead.transform.anchoredPosition = Vector2(0, 60)
                self.friendHead.transform.localScale = Vector3.one
                self.friendHead.button.onClick:AddListener( function()
                    TipsManager.Instance:ShowPlayer( { id = friendData.id, zone_id = friendData.zone_id, platform = friendData.platform, sex = friendData.sex, classes = friendData.classes, name = friendData.name, lev = friendData.lev })
                end )
                return
            end
        end
        self.friendHead.gameObject:SetActive(false)
    end
end

