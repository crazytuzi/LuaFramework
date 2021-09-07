-- @author 黄耀聪
-- @date 2017年11月13日, 星期一

GuildDragonMain = GuildDragonMain or BaseClass(BaseWindow)

function GuildDragonMain:__init(model)
    self.model = model
    self.name = "GuildDragonMain"
    self.windowId = WindowConfig.WinID.guilddragon_main
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.guilddragon_main, type = AssetType.Main}
        , {file = AssetConfig.guilddragon_textures, type = AssetType.Dep}
        , {file = AssetConfig.rolebg, type = AssetType.Dep}
        , {file = AssetConfig.rank_textures, type = AssetType.Dep}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
    }

    self.stateModel = {
        [GuildDragonEnum.State.Ready] = 32011,
        [GuildDragonEnum.State.Countdown] = 32011,
        [GuildDragonEnum.State.First] = 32011,
        [GuildDragonEnum.State.Second] = 32012,
        [GuildDragonEnum.State.Third] = 32013,
        [GuildDragonEnum.State.Reward] = 32013,
    }

    self.logList = {}
    self.panelList = {}
    self.numList = {}

    self.updateListener = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildDragonMain:__delete()
    self.OnHideEvent:Fire()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.logList ~= nil then
        for _,log in pairs(self.logList) do
            log:DeleteMe()
        end
        self.logList = nil
    end
    if self.panelList ~= nil then
        for _,panel in pairs(self.panelList) do
            panel:DeleteMe()
        end
        self.panelList = nil
    end
    if self.logLayout ~= nil then
        self.logLayout:DeleteMe()
        self.logLayout = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.numImage ~= nil then
        self.numImage.sprite = nil
    end
    if self.numList ~= nil then
        for _,img in pairs(self.numList) do
            img.sprite = nil
        end
    end
    if self.effect1 ~= nil then
        self.effect1:DeleteMe()
        self.effect1 = nil
    end
    self.transform:Find("Main/Show/RoleBg"):GetComponent(Image).sprite = nil
    self:AssetClearAll()
end

function GuildDragonMain:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddragon_main))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.tabGroup = TabGroup.New(main:Find("TabContainer").gameObject, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = true, perWidth = 90, perHeight = 33, isVertical = false, spacing = 5})

    local rank = main:Find("Rank")

    local show = main:Find("Show")
    self.slider = show:Find("Slider"):GetComponent(Slider)
    self.noticeBtn = show:Find("Notice"):GetComponent(Button)
    self.numImage = show:Find("Num"):GetComponent(Image)
    self.numContainer = show:Find("NumContainer")
    self.timeText = show:Find("Time"):GetComponent(Text)
    self.phaseText = show:Find("Phase/Text"):GetComponent(Text)
    self.previewContainer = show:Find("Preview")
    show:Find("RoleBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebg, "RoleBg")

    self.logItem = show:Find("Log/Scroll/Cloner").gameObject
    self.logScroll = show:Find("Log/Scroll"):GetComponent(ScrollRect)
    local logContainer = show:Find("Log/Scroll/Container")
    self.nothingObj = show:Find("Log/Nothing").gameObject
    self.logLayout = LuaBoxLayout.New(logContainer, {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.logList[1] = GuildDragonLog.New(self.model, self.logItem)
    self.logLayout:AddCell(self.logList[1].gameObject)
    for i=2,10 do
        self.logList[i] = GuildDragonLog.New(self.model, GameObject.Instantiate(self.logItem))
        self.logLayout:AddCell(self.logList[i].gameObject)
    end

    self.logSetting = {
       item_list = self.logList
       ,data_list = {} --数据列表
       ,item_con = logContainer  --item列表的父容器
       ,single_item_height = self.logItem.transform.sizeDelta.y --一条item的高度
       ,item_con_last_y = logContainer.anchoredPosition.y ---父容器改变时上一次的y坐标
       ,scroll_con_height = self.logScroll.transform.sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.logScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.logSetting) end)

    self.rodBtn = main:Find("Rob"):GetComponent(Button)
    self.rodBtnText = main:Find("Rob/Text"):GetComponent(Text)
    self.challengeBtn = main:Find("Challenge"):GetComponent(Button)
    self.challengeBtnText = main:Find("Challenge/Text"):GetComponent(Text)

    self.rodBtn.onClick:AddListener(function() self:OnRod() end)
    self.challengeBtn.onClick:AddListener(function() self:OnChallenge() end)
end

function GuildDragonMain:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDragonMain:OnOpen()
    self:RemoveListeners()
    GuildDragonManager.Instance.stateEvent:AddListener(self.updateListener)

    self.tabGroup:ChangeTab(1)
    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 200, function()
            self:UpdateSlider()
            self:UpdateLoot()
            self:UpdateChallenge()
            self:UpdateButtonText()
        end)
    end
    self:ReloadLog()
    self:Update()
end

function GuildDragonMain:OnHide()
    self:RemoveListeners()
    for _,panel in pairs(self.panelList) do
        if panel ~= nil then
            panel:Hiden()
        end
    end
    -- self.tabGroup.currentIndex = 0
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function GuildDragonMain:ReloadLog()
    self.logSetting.data_list = (self.model.myData or {}).challenge_msg or {}
    BaseUtils.refresh_circular_list(self.logSetting)

    self.nothingObj:SetActive(#self.logSetting.data_list == 0)
end

function GuildDragonMain:RemoveListeners()
    GuildDragonManager.Instance.stateEvent:RemoveListener(self.updateListener)
end

function GuildDragonMain:ChangeTab(index)
    if self.panelList[self.lastIndex] ~= nil then
        self.panelList[self.lastIndex]:Hiden()
    end
    if index == 1 or index == 2 then
        if self.panelList[index] == nil then
            self.panelList[index] = GuildDragonRank.New(self.model, self.transform:Find("Main/Panel").gameObject)
        end
        self.panelList[index]:Show(index)
        self.lastIndex = index
    elseif index == 3 then
        if self.panelList[index] == nil then
            self.panelList[index] = GuildDragonSpoils.New(self.model, self.transform:Find("Main/Panel"))
        end
        self.panelList[index]:Show()
        self.lastIndex = index
    end
end

function GuildDragonMain:OnRod()
    if BaseUtils.BASE_TIME < GuildDragonManager.Instance.model.myData.loot_time then
        NoticeManager.Instance:FloatTipsByString(TI18N("您刚刚已经掠夺过了，给别人一条生路吧！"))
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddragon_rod)
    end
end

function GuildDragonMain:OnChallenge()
    WindowManager.Instance:CloseWindow(self, false)
    GuildDragonManager.Instance:Challenge()
end

function GuildDragonMain:ReloadPreview(npc_id)
    self.previewCallback = self.previewCallback or function(composite) self:PreviewCallback(composite) end
    local unitData = DataUnit.data_unit[npc_id]
    local modelData = {type = PreViewType.Npc, skinId = unitData.skin, modelId = unitData.res, animationId = unitData.animation_id, scale = 1}
    if self.previewComp == nil then
        local setting = setting or {
            name = "GuildDragonMain"
            ,orthographicSize = 0.8
            ,width = 300
            ,height = 300
            ,offsetY = -0.55
            ,noDrag = false
        }
        self.previewComp = PreviewComposite.New(self.previewCallback, setting, modelData)
    else
        self.previewComp:Reload(modelData, self.previewCallback)
    end
end

function GuildDragonMain:PreviewCallback(composite)
    composite.tpose.transform.localRotation = Quaternion.Euler(0, -35, 0)
    composite.rawImage.transform:SetParent(self.previewContainer)
    composite.rawImage.transform.localScale = Vector3.one
    composite.rawImage.transform.localPosition = Vector3.zero
end

function GuildDragonMain:ChangeTitle(index)
    for i,title in ipairs(self.titleList) do
        title.text = self.rankTitleString[index][i]
    end
end

function GuildDragonMain:Update()
    if GuildDragonManager.Instance.state == GuildDragonEnum.State.Ready then
        self.phaseText.text = string.format(TI18N("第%s阶段"), BaseUtils.NumToChn(1))
    elseif GuildDragonManager.Instance.state == GuildDragonEnum.State.First then
        self.phaseText.text = string.format(TI18N("第%s阶段"), BaseUtils.NumToChn(1))
    elseif GuildDragonManager.Instance.state == GuildDragonEnum.State.Second then
        self.phaseText.text = string.format(TI18N("第%s阶段"), BaseUtils.NumToChn(2))
    elseif GuildDragonManager.Instance.state == GuildDragonEnum.State.Third then
        self.phaseText.text = string.format(TI18N("第%s阶段"), BaseUtils.NumToChn(3))
    end
    self:LayoutNum(GuildDragonEnum.Power[GuildDragonManager.Instance.state])
    if self.lastNpcId ~= self.stateModel[GuildDragonManager.Instance.state] then
        self.lastNpcId = self.stateModel[GuildDragonManager.Instance.state] or 32011
        self:ReloadPreview(self.lastNpcId)
    end
end

function GuildDragonMain:UpdateSlider()
    local value = GuildDragonManager.Instance:GetRest(BaseUtils.BASE_TIME) / 1000

    if value > 1 then value = 1
    elseif value < 0 then value = 0
    end
    self.slider.value = value

    self.timeText.text = BaseUtils.formate_time_gap(GuildDragonManager.Instance:GetRestTime(), ":", 0, BaseUtils.time_formate.MIN)
end

function GuildDragonMain:UpdateLoot()
    if GuildDragonManager.Instance:InDragonCD() and not GuildDragonManager.Instance:InLootCD() then
        -- 可掠夺不可挑战
        if self.effect ~= nil then
            self.effect:SetActive(true)
        else
            self.effect = BaseUtils.ShowEffect(20053, self.rodBtn.transform, Vector3(1.7, 0.65, 0), Vector3(-54, -15, -400))
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end

function GuildDragonMain:UpdateChallenge()
    if not GuildDragonManager.Instance:InDragonCD() then
        -- 可挑战
        if self.effect1 ~= nil then
            self.effect1:SetActive(true)
        else
            self.effect1 = BaseUtils.ShowEffect(20053, self.challengeBtn.transform, Vector3(1.7, 0.65, 0), Vector3(-54, -15, -400))
        end
    else
        if self.effect1 ~= nil then
            self.effect1:SetActive(false)
        end
    end
end

function GuildDragonMain:UpdateButtonText()
    if BaseUtils.BASE_TIME < GuildDragonManager.Instance.model.myData.challenge_time then
        self.challengeBtnText.text = BaseUtils.formate_time_gap(GuildDragonManager.Instance.model.myData.challenge_time - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.MIN)
    else
        self.challengeBtnText.text = TI18N("挑战巨龙")
    end
    if BaseUtils.BASE_TIME < GuildDragonManager.Instance.model.myData.loot_time then
        self.rodBtnText.text = BaseUtils.formate_time_gap(GuildDragonManager.Instance.model.myData.loot_time - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.MIN)
    else
        self.rodBtnText.text = TI18N("掠夺龙币")
    end
end

function GuildDragonMain:LayoutNum(num)
    local list = StringHelper.ConvertStringTable(tostring(num))
    local name = nil
    local width = 0
    local delta = 0
    for i,v in ipairs(list) do
        if v == "." then
            name = "BluePoint"
            delta = -3
        else
            name = "Blue" .. v
            delta = 0
        end
        if self.numList[i] == nil then
            local obj = GameObject.Instantiate(self.numImage.gameObject)
            obj.gameObject:SetActive(true)
            obj.transform:SetParent(self.numContainer)
            obj.transform.localScale = Vector3.one
            obj.transform.anchorMax = Vector2(0,0)
            obj.transform.anchorMin = Vector2(0,0)
            obj.transform.pivot = Vector2(0,0)
            self.numList[i] = obj:GetComponent(Image)
        end
        local sprite = self.assetWrapper:GetSprite(AssetConfig.guilddragon_textures, name)
        self.numList[i].sprite = sprite
        self.numList[i]:SetNativeSize()
        self.numList[i].transform.anchoredPosition3D = Vector3(width + delta, 0, 0)
        self.numList[i].gameObject:SetActive(true)

        if sprite == nil then
            Log.Error(string.format("为什么会有这个数！！！%s", tostring(num)))
        else
            width = width + sprite.textureRect.size.x
        end
        sprite = nil
    end
    for i=#list+1,#self.numList do
        self.numList[i].gameObject:SetActive(false)
    end
    self.numImage.gameObject:SetActive(false)
end
