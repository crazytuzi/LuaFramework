-- @author 黄耀聪
-- @date 2017年2月22日

GuildSiegeCastleWindow = GuildSiegeCastleWindow or BaseClass(BaseWindow)
-- GuildSiegeCastleWindow = GuildSiegeCastleWindow or BaseClass(BasePanel)

function GuildSiegeCastleWindow:__init(model)
    self.model = model
    self.name = "GuildSiegeCastleWindow"

    self.originChatPos = Vector2(-3.2, 7.82)
    self.originToPos = Vector2(-50, 11)
    self.originClosePos = Vector2(56, 44)
    self.originInfoOffsetMin = Vector2.zero
    self.originInfoOffsetMax = Vector2.zero

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.guild_siege_castle_window

    self.resList = {
        {file = AssetConfig.guildsiege_castle_window, type = AssetType.Main},
        {file = AssetConfig.guildsiege, type = AssetType.Dep},
        {file = AssetConfig.guildleague_texture, type = AssetType.Dep},
        {file = AssetConfig.guildsiege_loop, type = AssetType.Main},
        {file = AssetConfig.guildsiege_start, type = AssetType.Main},
        {file = AssetConfig.guard_head, type = AssetType.Dep},
    }

    self.guildList = {}
    self.castleList = {}
    self.pieceList = {}
    self.castleEnemyList = {}
    self.pieceEnemyList = {}
    self.starEffect = {{}, {}}

    self.attackString = TI18N("已进攻:<color='#ffff00'>%s</color>")
    self.myAttackString = TI18N("我的进攻次数:<color='#ffff00'>%s/2</color>")
    self.scale = 1

    self.firstHeight = 1024
    self.pirceHeight = 929
    self.maxSliderValue = 0.8
    self.minSliderValue = 0.2
    self.sliderWidth = 495

    -- self.memberDataList = {
    --     {name = "11111", x = 557, y = -192},
    --     {name = "11111", x = 359, y = -216},
    --     {name = "11111", x = 247, y = -355},
    --     {name = "11111", x = 490, y = -421},
    --     {name = "11111", x = 689, y = -415},
    --     {name = "11111", x = 490, y = -626},
    --     {name = "11111", x = 606, y = -717},
    --     {name = "11111", x = 226, y = -669},
    --     {name = "11111", x = 490, y = -819},
    --     {name = "11111", x = 339, y = -941},
    --     {name = "11111", x = 541, y = -987},
    --     {name = "11111", x = 669, y = -1160},
    --     {name = "11111", x = 557, y = -1331},
    --     {name = "11111", x = 706, y = -1361},
    --     {name = "11111", x = 490, y = -1594},
    -- }

    self.updateListener = function() self:UpdateInfo() end
    self.chatListener = function(bool) self:OnChatMain(bool) end
    self.checkListener = function() GuildSiegeManager.Instance:send19101() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildSiegeCastleWindow:__delete()
    self.OnHideEvent:Fire()
    if self.castleList ~= nil then
        for _,v in pairs(self.castleList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
    end
    if self.castleEnemyList ~= nil then
        for _,v in pairs(self.castleEnemyList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
    end
    if self.buttonLayout ~= nil then
        self.buttonLayout:DeleteMe()
        self.buttonLayout = nil
    end
    -- if self.starEffect ~= nil then
    --     for _,v in pairs(self.starEffect) do
    --         if v ~= nil then
    --             v:DeleteMe()
    --         end
    --     end
    --     self.starEffect = nil
    -- end
    -- if self.guildList ~= nil then
    --     for _,v in pairs(self.guildList) do
    --         if v.starEffect ~= nil then
    --             v.starEffect:DeleteMe()
    --         end
    --     end
    -- end
    if self.defendForce ~= nil then
        self.defendForce:DeleteMe()
        self.defendForce = nil
    end
    if self.castlePanel ~= nil then
        self.castlePanel:DeleteMe()
        self.castlePanel = nil
    end
    if self.playerPanel ~= nil then
        self.playerPanel:DeleteMe()
        self.playerPanel = nil
    end
    if self.descPanel ~= nil then
        self.descPanel:DeleteMe()
        self.descPanel = nil
    end
    if self.progressEffect ~= nil then
        self.progressEffect:DeleteMe()
        self.progressEffect = nil
    end
    self:AssetClearAll()
end

function GuildSiegeCastleWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildsiege_castle_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    if t:Find("GuildSiegeCheckCastle") ~= nil then
        GameObject.DestroyImmediate(t:Find("GuildSiegeCheckCastle").gameObject)
    end
    if t:Find("GuildSiegeCheckPlayer") ~= nil then
        GameObject.DestroyImmediate(t:Find("GuildSiegeCheckPlayer").gameObject)
    end

    local infoLevel = t:Find("Main/InfoLevel")
    self.toEnemyBtn = infoLevel:Find("ToEnemy"):GetComponent(Button)
    self.toGuildBtn = infoLevel:Find("ToGuild"):GetComponent(Button)
    self.attackObj = infoLevel:Find("Attack").gameObject
    self.attackText = infoLevel:Find("Attack/Text"):GetComponent(Text)
    self.slider = infoLevel:Find("Group/Value")
    self.timeText = infoLevel:Find("Group/TimeBg/Text"):GetComponent(Text)
    self.effectImgTrans = infoLevel:Find("Group/EffectImg")
    self.infoLevel = infoLevel

    self.mapLevel = t:Find("Main/MapLevel")
    self.guildMap = self.mapLevel:Find("My")
    self.enemyMap = self.mapLevel:Find("Enemy")
    self.guildCastleContainer = self.guildMap:Find("Container/Castles")
    self.enemyCastleContainer = self.enemyMap:Find("Container/Castles")
    self.castleCloner = self.mapLevel:Find("Castle").gameObject
    self.guildMap:GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChanged(1) end)
    self.enemyMap:GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChanged(2) end)

    self.progressEffect = BibleRewardPanel.ShowEffect(20303, self.slider:Find("EffectPos"), Vector3(1, 1, 1), Vector3(0, 0, -400))

    -- local realWidth = self.guildMap:Find("Container").rect.width
    self.scale = self.guildMap:Find("Container").rect.width / 960
    self.guildLayout = LuaBoxLayout.New(self.guildMap:Find("Container"), {axis = BoxLayoutAxis.Y, border = 0, cspacing = 0})
    self.guildLayout.panelRect.localScale = Vector3(self.scale, self.scale, 1)
    self.guildCastleContainer.anchoredPosition = Vector2(960 * (self.scale - 1) / 2, 0)
    self.enemyLayout = LuaBoxLayout.New(self.enemyMap:Find("Container"), {axis = BoxLayoutAxis.Y, border = 0, cspacing = 0})
    self.enemyLayout.panelRect.localScale = Vector3(self.scale, self.scale, 1)
    self.enemyCastleContainer.anchoredPosition = Vector2(960 * (self.scale - 1) / 2, 0)

    self.guildStart = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildsiege_start))
    self.guildLayout:AddCell(self.guildStart)

    self.enemyStart = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildsiege_start))
    self.enemyLayout:AddCell(self.enemyStart)

    self.guildLoopCloner = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildsiege_loop))
    self.guildLoopCloner.transform:SetParent(self.transform)
    self.guildLoopCloner.gameObject:SetActive(false)

    self.defendForce = GuildSiegeForce.New(self.model, infoLevel:Find("DefendForce").gameObject, self.assetWrapper)

    self.resultImage = infoLevel:Find("Result"):GetComponent(Image)

    for i=1,2 do
        local tab = {}
        tab.transform = infoLevel:Find("Guild" .. i)
        tab.gameObject = tab.transform.gameObject
        tab.iconImage = tab.transform:Find("Icon"):GetComponent(Image)
        tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
        tab.attachText = tab.transform:Find("Text"):GetComponent(Text)
        self.guildList[i] = tab
    end
    self.guildList[1].starText = infoLevel:Find("Group/LeftTextBg/Text"):GetComponent(Text)
    self.guildList[1].star = infoLevel:Find("Group/LeftTextBg/Star")
    -- self.guildList[1].precentText = infoLevel:Find("Group/Left"):GetComponent(Text)
    self.guildList[2].starText = infoLevel:Find("Group/RightTextBg/Text"):GetComponent(Text)
    self.guildList[2].star = infoLevel:Find("Group/RightTextBg/Star")
    -- self.guildList[2].precentText = infoLevel:Find("Group/Right"):GetComponent(Text)
    -- for i=1,2 do
    --     self.guildList[i].starEffect = BibleRewardPanel.ShowEffect(20304, self.guildList[i].star, Vector3(1, 1, 1), Vector3(0, 0, -400))
    -- end

    self.chatBtn = infoLevel:Find("Chat"):GetComponent(Button)
    self.chatBtn.onClick:AddListener(function() self:OnChat() end)
    self.closeBtn = t:Find("Main/Close"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    infoLevel:Find("Group/Notice"):GetComponent(Button).onClick:AddListener(function() self:OpenDesc({self.model.status}) end)
    self.toGuildBtn.onClick:AddListener(function() self:ToGuildOrEnemy(1) end)
    self.toEnemyBtn.onClick:AddListener(function() self:ToGuildOrEnemy(2) end)

    local buttonContainer = infoLevel:Find("ButtonContainer")
    self.buttonLayout = LuaBoxLayout.New(buttonContainer, {axis = BoxLayoutAxis.X, cspacing = 0, border = 10})

    self.defendRed = buttonContainer:Find("Defend/NotifyPoint").gameObject
    self.defendBtn = buttonContainer:Find("Defend"):GetComponent(Button)
    self.defendBtn.onClick:AddListener(function() self:ClickDefend() end)

    self.statBtn = buttonContainer:Find("Statistics"):GetComponent(Button)
    self.statBtn.onClick:AddListener(function() self:OpenStatistics() end)
    self.statRed = buttonContainer:Find("Statistics/NotifyPoint").gameObject

    self.myStatusBtn = buttonContainer:Find("MyStatus"):GetComponent(Button)
    self.myStatusBtn.onClick:AddListener(function() self:ClickMy() end)
    self.myRed = buttonContainer:Find("MyStatus/NotifyPoint").gameObject

    self.shopBtn = buttonContainer:Find("Shop"):GetComponent(Button)
    self.shopBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildstorewindow, {2}) end)
    self.shopRed = buttonContainer:Find("Shop/NotifyPoint").gameObject

    self.castleCloner:SetActive(false)
    self.defendForce:Hiden()

    self.resultImage.gameObject:SetActive(false)
    self.defendRed:SetActive(false)
    self.shopRed:SetActive(false)
end

function GuildSiegeCastleWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildSiegeCastleWindow:OnOpen()
    self:RemoveListeners()
    self.transform:Find("Main/InfoLevel").localPosition = Vector3(0, 0, -1000)
    GuildSiegeManager.Instance.onUpdateStatus:AddListener(self.updateListener)
    GuildSiegeManager.Instance.onUpdateCheck:AddListener(self.checkListener)
    EventMgr.Instance:AddListener(event_name.chat_main_show, self.chatListener)

    self:ToGuildOrEnemy(self.openArgs or self.currentType or 2)
    self:UpdateInfo()

    GuildSiegeManager.Instance:send19106()

    SceneManager.Instance:SetSceneActive(false)

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 100, function() self:OnTime() end)
    end

    if self.playerPanel ~= nil and self.playerPanel.isOpen == true then
        self:ShowPlayer(self.currentPlayer)
    elseif self.castlePanel ~= nil and self.castlePanel.isOpen == true then
        self:ShowPlayer(self.currentCastle)
    elseif self.statPanel ~= nil and self.statPanel.isOpen == true then
        self:OpenStatistics()
    end
    self:AdaptIPhoneX()
end

function GuildSiegeCastleWindow:OnHide()
    if self.transform ~= nil and self.transform:Find("Main/InfoLevel") ~= nil then
        self.transform:Find("Main/InfoLevel").localPosition = Vector3(0, 0, 0)
    end
    SceneManager.Instance:SetSceneActive(true)
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.tweenSliderId ~= nil then
        Tween.Instance:Cancel(self.tweenSliderId)
        self.tweenSliderId = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.defendForce ~= nil then
        self.defendForce:Hiden()
    end
    if self.shieldTimerId ~= nil then
        LuaTimer.Delete(self.shieldTimerId)
        self.shieldTimerId = nil
    end
    self:RemoveListeners()
    self:HideAllEffects()
end

function GuildSiegeCastleWindow:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateStatus:RemoveListener(self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.chat_main_show, self.chatListener)
    GuildSiegeManager.Instance.onUpdateCheck:RemoveListener(self.checkListener)
end

function GuildSiegeCastleWindow:SetSlider(value1, value2, time)
    if self.tweenSliderId ~= nil then
        Tween.Instance:Cancel(self.tweenSliderId)
        self.tweenSliderId = nil
    end
    if value1 + value2 == 0 then
        value1 = 1
        value2 = 1
    end
    self.tweenSliderId = Tween.Instance:ValueChange(self.slider.transform.sizeDelta.x, self.sliderWidth * (self.minSliderValue + (self.maxSliderValue - self.minSliderValue) * value1 / (value1 + value2)), time or 0, function() self.tweenSliderId = nil end, LeanTweenType.linear,
    function(value)
        if self.gameObject ~= nil and not BaseUtils.isnull(self.gameObject) then
            self.slider.transform.sizeDelta = Vector2(value, 17)
            self.effectImgTrans.anchoredPosition = Vector2(value, 0)
        end
    end
    ).id
end

function GuildSiegeCastleWindow:ToGuildOrEnemy(type)
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.currentType = type
    self:UpdateCastles(type)

    if type == 2 then   -- 查看敌人
        self.toGuildBtn.gameObject:SetActive(true)
        self.toEnemyBtn.gameObject:SetActive(false)
        self.enemyMap.gameObject:SetActive(true)
        self.tweenId = Tween.Instance:ValueChange(self.mapLevel.transform.anchorMin.x, 1, 0.4, function()
            self.tweenId = nil
            self.guildMap.gameObject:SetActive(false)
            GuildSiegeManager.Instance:send19108()
        end, LeanTweenType.easeOutCubic, function(value)
            -- self.mapLevel.transform.anchoredPosition = Vector2(value, 0)
            self.mapLevel.transform.anchorMin = Vector2(-value, 0)
            self.mapLevel.transform.anchorMax = Vector2(2-value, 1)
            self.mapLevel.transform.offsetMax = Vector2.zero
            self.mapLevel.transform.offsetMin = Vector2.zero
        end).id
        -- self.defendText.text = TI18N("我的状态")
    else
        self.toGuildBtn.gameObject:SetActive(false)
        self.toEnemyBtn.gameObject:SetActive(true)
        self.guildMap.gameObject:SetActive(true)
        self.tweenId = Tween.Instance:ValueChange(self.mapLevel.transform.anchorMax.x, 0, 0.4, function()
            self.tweenId = nil
            self.enemyMap.gameObject:SetActive(false)
            GuildSiegeManager.Instance:send19108()
        end, LeanTweenType.easeOutCubic, function(value)
            -- self.mapLevel.transform.anchoredPosition = Vector2(value, 0)
            self.mapLevel.transform.anchorMin = Vector2(-value, 0)
            self.mapLevel.transform.anchorMax = Vector2(2-value, 1)
            self.mapLevel.transform.offsetMax = Vector2.zero
            self.mapLevel.transform.offsetMin = Vector2.zero
        end).id
        -- self.defendText.text = TI18N("防守设置")
    end
end

function GuildSiegeCastleWindow:UpdateInfo()
    local statusData = self.model.statusData or {}
    self.valueList = self.valueList or {}

    local status = self.model:FinalResult()
    if status == GuildSiegeEumn.ResultType.None then
        self.resultImage.gameObject:SetActive(false)
    else
        self.resultImage.gameObject:SetActive(true)
        if status == GuildSiegeEumn.ResultType.Draw then        -- 平局
            self.resultImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "tide")
        elseif status == GuildSiegeEumn.ResultType.Loss then    -- 完败
            self.resultImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "lose1")
        elseif status == GuildSiegeEumn.ResultType.Fail then    -- 惜败
            self.resultImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "lose2")
        elseif status == GuildSiegeEumn.ResultType.Win then     -- 险胜
            self.resultImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "win2")
        elseif status == GuildSiegeEumn.ResultType.Victory then -- 完胜
            self.resultImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "win1")
        end
    end

    for i,guild in ipairs(self.guildList) do
        local data = (statusData.guild_match_list or {})[i] or {}
        guild.nameText.text = data.guild_name or ""
        guild.attachText.text = string.format(self.attackString, data.atk_times or 0)

        if self.valueList[i] ~= nil then
            if (data.score or 0) > self.valueList[i] then
                self:ShowStarEffect(i)
            end
        end
        self.valueList[i] = data.score or 0

        guild.starText.text = self.valueList[i]
    end
    self:SetSlider(self.valueList[1], self.valueList[2], 0.5)

    local sum = self.valueList[1] + self.valueList[2]
    if sum == 0 then sum = 1 end

    if self.model.myCastle ~= nil then
        self.attackObj:SetActive(true)
        self.attackText.text = string.format(self.myAttackString, 2 - (self.model.myCastle.atk_times or 0))
    else
        self.attackObj:SetActive(false)
    end

    self.attackObj:SetActive(self.model.status ~= GuildSiegeEumn.Status.Disactive)

    self.buttonLayout:ReSet()
    self.defendBtn.gameObject:SetActive(false)
    self.myStatusBtn.gameObject:SetActive(false)
    if self.model.status == GuildSiegeEumn.Status.Acceptable then
        self.buttonLayout:AddCell(self.myStatusBtn.gameObject)
    end
    if ((self.model.myCastle or {}).order or 0) ~= 0 and self.model.status ~= GuildSiegeEumn.Status.Disactive then
        self.buttonLayout:AddCell(self.defendBtn.gameObject)
    end
    self.buttonLayout:AddCell(self.statBtn.gameObject)
    self.buttonLayout:AddCell(self.shopBtn.gameObject)

    self:UpdateCastles(self.currentType or 1)
    self:CheckRed()

    if GuildSiegeManager.Instance:CheckMeIn() then
        if self.canFightEffect ~= nil then
            self.canFightEffect:SetActive(true)
        else
            self.canFightEffect = BibleRewardPanel.ShowEffect(20053, self.toEnemyBtn.transform, Vector3(1, 1, 1), Vector3(-32, -24, -400))
        end
    else
        if self.canFightEffect ~= nil then
            self.canFightEffect:SetActive(false)
        end
    end

    self.progressEffect:SetActive(true)
end

function GuildSiegeCastleWindow:ShowStarEffect(index)
    -- if self.starEffect[index] == nil then
    --     self.starEffect[index] = BibleRewardPanel.ShowEffect(20305, self.guildList[index].star, Vector3(1, 1, 1), Vector3(0, 0, -400))
    -- else
    --     self.starEffect[index]:SetActive(false)
    --     self.starEffect[index]:SetActive(true)
    -- end
end

function GuildSiegeCastleWindow:UpdateCastles(type)
    local memberList = (((self.model.statusData or {}).guild_match_list or {})[type] or {}).castle_list or {}
    local layout = self.guildLayout
    local castleList = self.castleList
    local pieceList = self.pieceList
    local castleContainer = self.guildCastleContainer
    local start = self.guildStart

    -- BaseUtils.dump(memberList, tostring(type))

    if type == 1 then   -- 己方
    else                -- 敌方
        layout = self.enemyLayout
        castleList = self.castleEnemyList
        pieceList = self.pieceEnemyList
        castleContainer = self.enemyCastleContainer
        start = self.enemyStart
    end

    local y = 0
    local minY = 0

    local memList = {}
    for k,v in pairs(memberList) do
        if v.order > 0 then
            table.insert(memList, k)
        end
    end
    table.sort(memList, function(a,b) return memberList[a].order < memberList[b].order end)

    -- memberList = {}
    -- for i=1,50 do
    --     table.insert(memberList, {order = i, all_atk_times = 0, loss_star = 0, classes = 2, type = type, sex = 0})
    -- end
    local c = 0
    for i,k in ipairs(memList) do
        local v = memberList[k]
        local item = castleList[v.order]
        if item == nil then
            item = GuildSiegeCastleItem.New(self.model, GameObject.Instantiate(self.castleCloner))
            item.name = tostring(v.order)
            item.transform:SetParent(castleContainer)
            item.transform.localScale = Vector3.one
            item.assetWrapper = self.assetWrapper
            item.btn.onClick:RemoveAllListeners()
            item.btn.onClick:AddListener(function() self:ClickCastle(item.data) end)
            castleList[v.order] = item
            item.transform.localScale = Vector3(1 / self.scale, 1 / self.scale, 1)
        end
        if v.order > 0 then
            item:SetData(v, v.order)
            item:SetActive(true)
            c = c + 1

            y = item:GetSectionY()
            if y < minY then minY = y end
        end
    end
    for i=c + 1,#castleList do
        castleList[i]:SetActive(false)
    end

    local n = -minY - self.firstHeight
    if n < 0 then n = 1 end
    n = math.ceil(n / self.pirceHeight)

    local h = -self.firstHeight
    layout:ReSet()
    layout:AddCell(start)
    for i=1,n + 1 do
        if pieceList[i] == nil then
            pieceList[i] = GameObject.Instantiate(self.guildLoopCloner)
        end

        layout:AddCell(pieceList[i])
    end
    for i=1,n + 1 do
        pieceList[i].transform.anchoredPosition = Vector2(0, h)
        h = h - self.pirceHeight
    end
    layout.panelRect.sizeDelta = Vector2(layout.panelRect.sizeDelta.x, -h)
    castleContainer:SetAsLastSibling()

    if -minY < (960 * ctx.ScreenHeight / ctx.ScreenWidth) then
        layout.panelRect.sizeDelta = Vector2(layout.panelRect.sizeDelta.x, (960 * ctx.ScreenHeight / ctx.ScreenWidth))
    elseif layout.panelRect.sizeDelta.y + minY > 30 then
        layout.panelRect.sizeDelta = Vector2(layout.panelRect.sizeDelta.x, -minY + 30)
    end

    if self.shieldTimerId ~= nil then
        LuaTimer.Delete(self.shieldTimerId)
    end
    self.shieldTimerId = LuaTimer.Add(100, function() self:SetShilds(type) end)

    self:OnValueChanged(type)
end

function GuildSiegeCastleWindow:SetShilds(type)
    local castleTab = self.castleList
    if type == 2 then
        castleTab = self.castleEnemyList
    end
    for i,v in ipairs(castleTab) do
        local castleData = DataGuildSiege.data_castle[v.data.order]
        if castleData.type == 2 then
            if v.data.loss_star < 3 then
                v:SetShild(true, true)
            else
                castleTab[v.data.order]:SetShild(false, true)
            end
        else
            local bool = false
            for _,order in pairs(castleData.need_check) do
                if order > 0 then
                    bool = bool or (castleTab[order].data.loss_star < 3)
                end
            end
            v:SetShild(bool, false)
        end
    end
end

function GuildSiegeCastleWindow:OnTime()
    if self.model.targetTime == nil then
        self.timeText.text = nil
    else
        local formatString = nil
        if self.model.status == GuildSiegeEumn.Status.Ready then
            formatString = TI18N("<color='#00ff00'>%s</color>后开战")
        elseif self.model.status == GuildSiegeEumn.Status.Acceptable then
            formatString = TI18N("<color='#00ff00'>%s</color>后结束")
        else
            self.timeText.text = TI18N("已结束")
        end
        if formatString ~= nil then
            if self.model.targetTime - BaseUtils.BASE_TIME < 0 then
                self.timeText.text = TI18N("已结束")
            elseif self.model.targetTime - BaseUtils.BASE_TIME < 60 then
                self.timeText.text = string.format(formatString, BaseUtils.formate_time_gap(self.model.targetTime - BaseUtils.BASE_TIME, 1, 1, BaseUtils.time_formate.SEC))
            elseif self.model.targetTime - BaseUtils.BASE_TIME < 3600 then
                self.timeText.text = string.format(formatString, BaseUtils.formate_time_gap(self.model.targetTime - BaseUtils.BASE_TIME, 1, 1, BaseUtils.time_formate.MIN))
            else
                self.timeText.text = string.format(formatString, BaseUtils.formate_time_gap(self.model.targetTime - BaseUtils.BASE_TIME, 1, 1, BaseUtils.time_formate.HOUR))
            end
        end
    end
end

function GuildSiegeCastleWindow:ClickDefend()
    self:HideAllEffects()
    -- if self.model.status == GuildSiegeEumn.Status.Ready then
        self.model.hasShowDefend = true
        self.defendForce:Show()
    -- elseif self.model.status == GuildSiegeEumn.Status.Acceptable then
    --     self:ShowPlayer(self.model.myCastle)
    -- end

    self:CheckRed()
end

function GuildSiegeCastleWindow:CheckRed()
    self.defendRed:SetActive(self.model.hasShowDefend ~= true)
    self.statRed:SetActive(self.model.hasShowStat ~= true)
    self.myRed:SetActive(self.model.hasShowMy ~= true)
end

function GuildSiegeCastleWindow:ShowCastle(args)
    self:HideAllEffects()
    self.currentCastle = args
    if self.gameObject ~= nil then
        if self.castlePanel == nil then
            self.castlePanel = GuildSiegeCheckCastle.New(self.model, self.gameObject)
        end
        self.castlePanel:Show(args)
    end
end

function GuildSiegeCastleWindow:ShowPlayer(args)
    self:HideAllEffects()
    self.currentPlayer = args
    if self.gameObject ~= nil then
        if self.playerPanel == nil then
            self.playerPanel = GuildSiegeCheckPlayer.New(self.model, self.gameObject)
        end
        -- BaseUtils.dump(self.model.myCastle, "myCastle")
        self.playerPanel:Show(args)
    end
end

function GuildSiegeCastleWindow:ClickCastle(castle)
    if castle == nil then return end
    if self.model.status == GuildSiegeEumn.Status.Ready then
        self:ShowCastle(castle)
    else
        -- if castle.is_combat == 1 then
        --     self:ShowButtons(castle)
        -- else
        --     self:ShowPlayer(castle)
        -- end
        self:ShowPlayer(castle)
    end
end

function GuildSiegeCastleWindow:ClickMy()
    self.model.hasShowMy = true
    local myCastle = self.model.myCastle
    local roledata = RoleManager.Instance.RoleData
    for _,v in ipairs((((self.model.statusData or {}).guild_match_list or {})[1] or {}).castle_list or {}) do
        if v.r_id == roledata.id and v.r_plat == roledata.platform and v.r_zone == roledata.zone_id then
            myCastle = v
        end
    end
    self:ShowPlayer(myCastle)
    self:CheckRed()
end

function GuildSiegeCastleWindow:OpenStatistics()
    self:HideAllEffects()
    self.model.hasShowDefend = true
    if self.statPanel == nil then
        self.statPanel = GuildSiegeStatistics.New(self.model, self.gameObject)
    end
    self.statPanel:Show()
    self:CheckRed()
end

function GuildSiegeCastleWindow:OpenDesc(args)
    self:HideAllEffects()
    if self.descPanel == nil then
        self.descPanel = GuildSiegeDescPanel.New(self.model, self.gameObject)
    end
    self.descPanel:Show(args)
end

function GuildSiegeCastleWindow:OnChatMain(bool)
    if bool then
        self.transform.localPosition = Vector3(0, 0, 600)
        self:HideAllEffects()
    else
        ChatManager.Instance.model:ShowCanvas(bool)
        self.transform.localPosition = Vector3(0, 0, 0)
        self:UpdateCastles(self.currentType or 1)
    end
end

function GuildSiegeCastleWindow:HideAllEffects()
    if self.castleList ~= nil then
        for _,v in pairs(self.castleList) do
            if v ~= nil then
                v:HideEffects()
            end
        end
    end

    if self.castleEnemyList ~= nil then
        for _,v in pairs(self.castleEnemyList) do
            if v ~= nil then
                v:HideEffects()
            end
        end
    end

    if self.progressEffect ~= nil then
        self.progressEffect:SetActive(false)
    end

    if self.canFightEffect ~= nil then
        self.canFightEffect:SetActive(false)
    end
end

function GuildSiegeCastleWindow:OnChat()
    ChatManager.Instance.model:ShowCanvas(true)
    ChatManager.Instance.model:ShowChatWindow({MsgEumn.ChatChannel.Guild})
end

function GuildSiegeCastleWindow:OnAttack(castle)
    if self.playerPanel ~= nil then
        self.playerPanel:OnAttack(castle)
    end
end

function GuildSiegeCastleWindow:OnValueChanged(type)
    local layout = self.guildLayout
    local castleList = self.castleList
    local pieceList = self.pieceList

    -- BaseUtils.dump(memberList, tostring(type))

    if type == 1 then   -- 己方
    else                -- 敌方
        layout = self.enemyLayout
        castleList = self.castleEnemyList
        pieceList = self.pieceEnemyList
    end

    local y0 = layout.panelRect.anchoredPosition.y
    -- local h = (960 * ctx.ScreenHeight / ctx.ScreenWidth)
    local h = self.mapLevel.rect.height / self.scale

    -- print(h)
    for _,v in pairs(castleList) do
        v.gameObject:SetActive(-v.transform.anchoredPosition.y < y0 / self.scale + h + 100 and -v.transform.anchoredPosition.y > y0 / self.scale - 100)
    end
    self.canUpdate = false
end

function GuildSiegeCastleWindow:ShowButtons(castle)
    if self.buttonPanel == nil then
        self.buttonPanel = GuildSiegeButtonPanel.New(self.model, self.transform:Find("Main/ButtonPanel").gameObject)
    end
    self.buttonPanel:Show(castle)

    local castleTrans = nil
    local container = nil
    if castle.type == 1 then
        castleTrans = self.castleList[castle.order].transform
        container = self.guildCastleContainer.parent
    else
        castleTrans = self.castleEnemyList[castle.order].transform
        container = self.enemyCastleContainer.parent
    end

    if castleTrans ~= nil then
        local size = self.buttonPanel.main.sizeDelta
        local screenHeight = 960 * ctx.ScreenHeight / ctx.ScreenWidth

        -- 当前城堡左上角相对于屏幕左上角的坐标
        local y0 = container.anchoredPosition.y + castleTrans.anchoredPosition.y + castleTrans.sizeDelta.y * (1 - castleTrans.pivot.y)
        local x0 = castleTrans.anchoredPosition.x - castleTrans.sizeDelta.x * castleTrans.pivot.x

        local x = nil
        local y = nil
        if x0 + castleTrans.sizeDelta.x + size.x + 20 > 960 then
            x = x0 - size.x - 20
        else
            x = x0 + castleTrans.sizeDelta.x + 20
        end
        if y0 - size.y < -screenHeight then
            y = size.y - screenHeight
        elseif y0 > 0 then
            y = 0
        else
            y = y0
        end

        self.buttonPanel:SetPos(x, y)
    end
end

function GuildSiegeCastleWindow:AdaptIPhoneX()
    if MainUIManager.Instance.adaptIPhoneX then
        if Screen.orientation == ScreenOrientation.LandscapeRight then
            self.originChatPos = Vector2(-3.2, -5)
            self.originToPos = Vector2(-90, 0)
        else
            self.originChatPos = Vector2(34.44, -5)
            self.originToPos = Vector2(-50, 0)
        end
        self.originClosePos = Vector2(56, 56)
        self.originInfoOffsetMin = Vector2(0, 12)
        self.originInfoOffsetMax = Vector2(0, -12)
    else
        self.originChatPos = Vector2(-3.2, 7.82)
        self.originToPos = Vector2(-50, 11)
        self.originClosePos = Vector2(56, 44)
        self.originInfoOffsetMin = Vector2.zero
        self.originInfoOffsetMax = Vector2.zero
    end

    self.chatBtn.transform.anchoredPosition = self.originChatPos
    self.toEnemyBtn.transform.anchoredPosition = self.originToPos
    self.toGuildBtn.transform.anchoredPosition = self.originToPos
    self.closeBtn.transform.anchoredPosition = self.originClosePos
    self.infoLevel.offsetMin = self.originInfoOffsetMin
    self.infoLevel.offsetMax = self.originInfoOffsetMax
end



