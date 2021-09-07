-- @author 黄耀聪
-- @date 2017年6月19日, 星期一

IngotCrashWindow = IngotCrashWindow or BaseClass(BaseWindow)

function IngotCrashWindow:__init(model)
    self.model = model
    self.name = "IngotCrashWindow"
    self.windowId = WindowConfig.WinID.ingot_crash_content
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.ingotcrash_window, type = AssetType.Main},
        {file = AssetConfig.ingotcrash_textures, type = AssetType.Dep},
        {file = AssetConfig.godswarres, type = AssetType.Dep},
        {file = AssetConfig.bible_daily_gfit_bg2, type = AssetType.Dep},
        {file = AssetConfig.guildleague_texture, type = AssetType.Dep},
    }

    self.nameList = {}
    self.lineList16 = {}
    self.lineList8 = {}
    self.lineList4 = {}
    self.lineList3 = {}
    self.lineList2 = {}
    self.betList16 = {}
    self.betList8 = {}
    self.betList4 = {}
    self.betList3 = {}

    self.battleEighthList = {}
    self.battleQuarterList = {}
    self.battleHalfList = {}
    self.battleFinalList = {}
    self.battleLevelList = {self.battleEighthList, self.battleQuarterList, self.battleHalfList, self.battleFinalList}

    self.noOneString = TI18N("虚位以待")

    self.levelList = {self.lineList16, self.lineList8, self.lineList4, self.lineList2}
    self.betList = {self.betList16, self.betList8, self.betList4}

    self.updateListener = function() self:Reload() end

    self.nameThirdList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IngotCrashWindow:__delete()
    self.OnHideEvent:Fire()
    if self.playerList ~= nil then
        for _,v in pairs(self.playerList) do
            v.headSlot:DeleteMe()
        end
        self.playerList = nil
    end
    self:AssetClearAll()
end

function IngotCrashWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ingotcrash_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    local nameContainer = main:Find("NameList")
    for i=1,16 do
        local tab = {}
        tab.transform = nameContainer:GetChild(i - 1)
        tab.text = tab.transform:Find("Name"):GetComponent(Text)
        tab.btn = tab.transform:GetComponent(Button)
        self.nameList[i] = tab
        tab.btn.onClick:AddListener(function() if tab.data ~= nil then TipsManager.Instance:ShowPlayer(tab.data) end end)
    end

    local fight = main:Find("Fight16")
    for i=1,16 do
        self.lineList16[i] = self:CreateLine(fight:GetChild(i - 1))
    end

    fight = main:Find("Fight8")
    for i=1,8 do
        self.lineList8[i] = self:CreateLine(fight:GetChild(i - 1))
    end

    fight = main:Find("Fight4")
    for i=1,4 do
        self.lineList4[i] = self:CreateLine(fight:GetChild(i - 1))
    end

    fight = main:Find("Fight2")
    for i=1,2 do
        self.lineList2[i] = self:CreateLine(fight:GetChild(i - 1))
    end

    fight = main:Find("Bet16")
    for i=1,8 do
        self.betList16[i] = self:CreateBet(fight:GetChild(i - 1))
        self.battleEighthList[i] = IngotCrashBattle.New()
        local j = i
        self.betList16[i].eyeBtn.onClick:AddListener(function() self:OnEye(1,j) end)
    end

    fight = main:Find("Bet8")
    for i=1,4 do
        self.betList8[i] = self:CreateBet(fight:GetChild(i - 1))
        self.battleQuarterList[i] = IngotCrashBattle.New()
        local j = i
        self.betList8[i].eyeBtn.onClick:AddListener(function() self:OnEye(2,j) end)
    end

    fight = main:Find("Bet4")
    for i=1,2 do
        self.betList4[i] = self:CreateBet(fight:GetChild(i - 1))
        self.battleHalfList[i] = IngotCrashBattle.New()
        local j = i
        self.betList4[i].eyeBtn.onClick:AddListener(function() self:OnEye(3,j) end)
    end

    fight = main:Find("Bet3")
    self.betList3[1] = self:CreateBet(fight:GetChild(0))

    fight = main:Find("NameThird")
    for i=1,2 do
        local tab = {}
        tab.transform = fight:GetChild(i - 1)
        tab.text = tab.transform:Find("Name"):GetComponent(Text)
        tab.btn = tab.transform:GetComponent(Button)
        self.nameThirdList[i] = tab

        tab.btn.onClick:AddListener(function() if tab.data ~= nil then TipsManager.Instance:ShowPlayer(tab.data) end end)
    end

    fight = main:Find("Fight3")
    self.lineList3[1] = {
        transform = fight:GetChild(1),
        gameObject = fight:GetChild(1).gameObject
    }
    self.lineList3[2] = {
        transform = fight:GetChild(2),
        gameObject = fight:GetChild(2).gameObject
    }

    self.sendButton = main:Find("SendButton"):GetComponent(Button)
    self.toggleBtn = main:Find("Toggle"):GetComponent(Button)
    self.tick = main:Find("Toggle/Toggle/Tick").gameObject
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.championVsBtn = main:Find("Vs"):GetComponent(Button)

    self.battleFinalList[1] = IngotCrashBattle.New()
    self.battleFinalList[1].betBtn = self.championVsBtn
    self.battleFinalList[1].watchBtn = self.championVsBtn

    self.timeText = main:Find("Time"):GetComponent(Text)
    self.titleText = main:Find("Title/Text"):GetComponent(Text)

    self.playerList = {}
    for i=1,2 do
        local tab = {}
        tab.transform = main:Find("Info/Player" .. i)
        tab.gameObject = tab.transform.gameObject
        tab.nameText = tab.transform:Find("Text"):GetComponent(Text)
        tab.headSlot = HeadSlot.New()
        NumberpadPanel.AddUIChild(tab.transform, tab.headSlot.gameObject)
        tab.headSlot.transform:SetAsFirstSibling()
        tab.headSlot:SetMystery()
        self.playerList[i] = tab
    end

    self.championNameText = main:Find("Info/Champion/Text"):GetComponent(Text)
    self.thirdPlaceNameText = main:Find("Info/ThirdPlace/Text"):GetComponent(Text)

    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    main:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_daily_gfit_bg2, "DailyGiftBigBg")
    main:Find("Bg"):GetComponent(Image).enabled = true
    self.titleText.text = IngotCrashManager.Instance.activityName
    self.sendButton.onClick:AddListener(function() self:OnDamaku() end)
    self.toggleBtn.onClick:AddListener(function() self:OnToggle() end)
    main:Find("Info/Champion"):GetComponent(Button).onClick:AddListener(function() if self.championClickListener ~= nil then self.championClickListener() end end)
    self.timeText.horizontalOverflow = 1
    main:Find("Info/Cup"):GetComponent(Button).onClick:AddListener(function() if self.championClickListener ~= nil then self.championClickListener() end end)
    main:Find("Info/ThirdPlace"):GetComponent(Button).onClick:AddListener(function() if self.thirdClickListener ~= nil then self.thirdClickListener() end end)

    -- self.toggleBtn.gameObject:SetActive(false)
    -- self.sendButton.gameObject:SetActive(false)
end

function IngotCrashWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IngotCrashWindow:OnOpen()
    self:RemoveListeners()
    IngotCrashManager.Instance.onUpdateInfo:AddListener(self.updateListener)

    IngotCrashManager.Instance:send20011()

    self:Reload()

    -- IngotCrashManager.Instance:send20013(1)
end

function IngotCrashWindow:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    IngotCrashManager.Instance:send20013(0)
end

function IngotCrashWindow:RemoveListeners()
    IngotCrashManager.Instance.onUpdateInfo:RemoveListener(self.updateListener)
end

function IngotCrashWindow:CreateLine(trans)
    local tab = {}
    tab.transform = trans
    tab.gameObject = trans.gameObject
    tab.normal = trans:Find("Normal").gameObject
    tab.select = trans:Find("Select").gameObject
    return tab
end

function IngotCrashWindow:CreateBet(trans)
    local tab = {}
    tab.transform = trans
    tab.gameObject = trans.gameObject
    tab.eyeBtn = trans:Find("Eye"):GetComponent(Button)
    tab.eyeImage = trans:Find("Eye"):GetComponent(Image)
    tab.betBtn = trans:Find("Button"):GetComponent(Button)
    tab.betImage = trans:Find("Button"):GetComponent(Image)
    tab.betText = trans:Find("Button/Text"):GetComponent(Text)
    return tab
end

function IngotCrashWindow:Reload()
    BaseUtils.dump(self.model.best16Tab, "best16Tab")
    self.tick:SetActive(not IngotCrashManager.Instance.isShowDamaku)

    self:AnalyzeAll()
    self:AnalyzeThird()
    -- self:UpdateVideo()

    local win = 0
    local loss = 0
    for k,v in pairs(self.model.best16Tab) do
        if v.is_lose == 0 then
            win = win + 1
        else
            loss = loss + 1
        end
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if IngotCrashManager.Instance.now_round < IngotCrashManager.Instance.max_round - 3 then
        self.timeText.text = TI18N("竞猜尚未开始")
    elseif (win == 1 and loss == 15) or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Close then
        self.timeText.text = TI18N("竞猜已结束")
    elseif IngotCrashManager.Instance.now_round == IngotCrashManager.Instance.max_round and IngotCrashManager.Instance.phase ~= IngotCrashEumn.Phase.Guess then
        self.timeText.text = TI18N("冠军正在诞生，拭目以待！")
    else
        if self.timerId == nil then
            self.timerId = LuaTimer.Add(0, 30, function() self:OnTime() end)
        end
    end

    self:CheckVote()
end

function IngotCrashWindow:RiseWay(player)
    if player.is_lose == 1 then
        for i=1, player.lose_round - (IngotCrashManager.Instance.max_round - 3) do
            local level = self.levelList[i][math.ceil(player.pos / math.pow(2, i - 1))]
            level.select:SetActive(true)
            level.normal:SetActive(false)

            local bet = self.betList[i][math.ceil(player.pos / math.pow(2, i))]
            bet.gameObject:SetActive(true)
            bet.eyeBtn.gameObject:SetActive(true)
            bet.betBtn.gameObject:SetActive(false)

            -- if self.model.guessTab[BaseUtils.Key(player.rid,player.platform,player.zone_id)] ~= nil then
            --     bet.eyeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.ingotcrash_textures, "InfoIconGreen")
            -- end
        end
    else
        local beginIndex = nil
        local num = nil
        local is_up = nil
        local unknow = nil
        for i=1,4 do
            is_up = true
            num = math.pow(2, i)
            unknow = 0
            beginIndex = math.floor((player.pos - 1) / num) * num + 1
            for j=beginIndex,beginIndex + num - 1 do
                if self.model.best16Tab[j] == nil then
                    unknow = unknow + 1
                    is_up = false
                end
                if j ~= player.pos and is_up then
                    is_up = is_up and (self.model.best16Tab[j].is_lose == 1)
                end
            end

            if is_up then
                local level = self.levelList[i][math.ceil(player.pos / math.pow(2, i - 1))]
                level.select:SetActive(true)
                level.normal:SetActive(false)

                if i < 4 then
                    local bet = self.betList[i][math.ceil(player.pos / num)]
                    bet.gameObject:SetActive(true)
                    bet.eyeBtn.gameObject:SetActive(true)
                    bet.betBtn.gameObject:SetActive(false)

                    -- local indexList = {}

                    -- for j=beginIndex,beginIndex + num - 1 do
                    --     if self.model.best16Tab[j] ~= nil and self.model.best16Tab[j].is_lose == 0 then
                    --         table.insert(indexList, j)
                    --     end
                    -- end
                end
            else
                if i < 4 and unknow == 0 and (IngotCrashManager.Instance.now_round == 0 or i <= IngotCrashManager.Instance.now_round - (IngotCrashManager.Instance.max_round - 4)) then
                    local bet = self.betList[i][math.ceil(player.pos / num)]
                    bet.gameObject:SetActive(true)
                    bet.eyeBtn.gameObject:SetActive(IngotCrashManager.Instance.phase ~= IngotCrashEumn.Phase.Guess)
                    bet.betBtn.gameObject:SetActive(IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess)

                    if self.model.guessTab[BaseUtils.Key(player.rid, player.platform,  player.zone_id)] ~= nil then
                        -- 已下注
                        bet.betImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                        bet.betText.color = ColorHelper.DefaultButton2
                    end

                    local indexList = {}

                    for j=beginIndex,beginIndex + num - 1 do
                        if self.model.best16Tab[j] ~= nil and self.model.best16Tab[j].is_lose == 0 then
                            table.insert(indexList, j)
                        end
                    end

                    bet.betBtn.onClick:RemoveAllListeners()
                    bet.betBtn.onClick:AddListener(function() self:OnVote(i, indexList[1], indexList[2]) end)
                end
                break
            end
        end
    end
end

function IngotCrashWindow:AnalyzeAll()
    self:CheckVote()
    for _,line in pairs(self.lineList16) do
        line.select:SetActive(false)
        line.normal:SetActive(true)
    end
    for _,line in pairs(self.lineList8) do
        line.select:SetActive(false)
        line.normal:SetActive(true)
    end
    for _,line in pairs(self.lineList4) do
        line.select:SetActive(false)
        line.normal:SetActive(true)
    end
    for _,line in pairs(self.lineList2) do
        line.select:SetActive(false)
        line.normal:SetActive(true)
    end
    for _,line in pairs(self.lineList3) do
        line.gameObject:SetActive(false)
        line.gameObject:SetActive(false)
    end
    for _,bet in pairs(self.betList16) do
        bet.gameObject:SetActive(false)
        bet.eyeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "InfoIconBg1")
    end
    for _,bet in pairs(self.betList8) do
        bet.gameObject:SetActive(false)
        bet.eyeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "InfoIconBg1")
    end
    for _,bet in pairs(self.betList4) do
        bet.gameObject:SetActive(false)
        bet.eyeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "InfoIconBg1")
    end
    -- for _,bet in pairs(self.betList3) do
    --     bet.gameObject:SetActive(false)
    -- end

    for i,v in ipairs(self.nameList) do
        v.data = self.model.best16Tab[i]
        if self.model.best16Tab[i] == nil then
            v.text.text = self.noOneString
        else
            if self.model.best16Tab[i].is_lose == 1 then
                v.text.text = string.format("<color='#909090'>%s</color>", self.model.best16Tab[i].name)
            else
                v.text.text = string.format("<color='#ffff00'>%s</color>", self.model.best16Tab[i].name)
            end
        end
    end

    if IngotCrashManager.Instance.now_round > IngotCrashManager.Instance.max_round - 4 then
        for pos,player in pairs(self.model.best16Tab) do
            self:RiseWay(player)
        end
    end

    local indexList = {}
    if IngotCrashManager.Instance.now_round == IngotCrashManager.Instance.max_round then
        -- 最后一轮
        local player1 = self:GetTop(1,8)
        local player2 = self:GetTop(9,16)

        if player1 ~= nil then
            indexList[1] = player1.pos
        end
        if player2 ~= nil then
            indexList[2] = player2.pos
        end
    elseif IngotCrashManager.Instance.now_round == IngotCrashManager.Instance.max_round - 1 then
        for j=1,2 do
            indexList[j] = nil
            for i=(j - 1) * 8 + 1,j*8 do
                if self.model.best16Tab[i] ~= nil and self.model.best16Tab[i].is_lose == 0 then
                    if indexList[j] ~= nil then
                        indexList[j] = nil
                        break
                    else
                        indexList[j] = self.model.best16Tab[i].pos
                    end
                end
            end
        end
    end

    self.championVsBtn.onClick:RemoveAllListeners()

    self.championClickListener = function()
        if indexList[1] ~= nil and indexList[2] ~= nil then
            if self.model.best16Tab[indexList[1]].is_lose == 0 and self.model.best16Tab[indexList[2]].is_lose == 0 then
                if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess or IngotCrashManager.Instance.now_round == IngotCrashManager.Instance.max_round then
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_vote, {type = 4, player1 = indexList[1], player2 = indexList[2]})
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("竞猜尚未开启，请留意竞猜公告{face_1,2}"))
                end
            else
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_vote, {type = 4, player1 = indexList[1], player2 = indexList[2]})
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("决赛玩家尚未确定"))
        end
    end
    self.championVsBtn.onClick:AddListener(self.championClickListener)

    for i=1,2 do
        if indexList[i] == nil then
            self.playerList[i].nameText.text = self.noOneString
            self.playerList[i].headSlot:SetMystery()
        else
            local player = self.model.best16Tab[indexList[i]]
            self.playerList[i].nameText.text = player.name
            self.playerList[i].headSlot:SetAll({id = player.rid, platform = player.platform, zone_id = player.zone_id, classes = player.classes, sex = player.sex}, {isSmall = true})
        end
    end

    local player = self:GetTop(1, 16)
    if player ~= nil and player.rank == 1 then
        self.championNameText.text = player.name
        self.championVsBtn.onClick:RemoveAllListeners()
        self.championVsBtn.onClick:AddListener(function() IngotCrashManager.Instance:send20023() end)
    else
        if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess and #indexList == 2 then
            self.championNameText.text = TI18N("点击下注")
        else
            self.championNameText.text = TI18N("冠 军")
        end
    end
end

function IngotCrashWindow:AnalyzeThird()
    for _,v in ipairs(self.lineList3) do
        v.gameObject:SetActive(false)
    end
    self.betList3[1].gameObject:SetActive(false)

    local thirdList = {}
    for _,v in pairs(self.model.best16Tab) do
        if v.lose_round == IngotCrashManager.Instance.max_round - 1 or (v.rank > 2 and v.rank < 5) then
            thirdList[math.ceil(v.pos / 8)] = v
        end
    end

    -- self.betList3[1].betBtn.onClick:RemoveAllListeners()

    self.hasThird = false

    self.thirdPlaceNameText.text = TI18N("季 军")
    if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess and #thirdList == 2 then
        self.thirdPlaceNameText.text = TI18N("点击下注")
    else
    end

    for i,v in ipairs(self.nameThirdList) do
        v.data = thirdList[i]
        if thirdList[i] ~= nil then
            -- BaseUtils.dump(thirdList[i], tostring(i))
            v.text.text = thirdList[i].name
            self.lineList3[i].gameObject:SetActive(thirdList[i].rank == 3)
            self.hasThird = self.hasThird or (thirdList[i].rank == 3)

            if thirdList[i].rank == 3 then
                -- self.betList3[1].betBtn.gameObject:SetActive(false)
                -- self.betList3[1].eyeBtn.gameObject:SetActive(true)
                -- self.betList3[1].eyeBtn.onClick:RemoveAllListeners()
                -- self.betList3[1].eyeBtn.onClick:AddListener(function() self:OnVideo(thirdList[1].pos, thirdList[2].pos) end)
                self.thirdPlaceNameText.text = thirdList[i].name
            end
        else
            v.text.text = self.noOneString
        end
    end

    self.thirdClickListener = function()
        if self.hasThird == true then
            -- self:OnVideo(thirdList[1].pos, thirdList[2].pos)
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_vote, {type = 0, player1 = thirdList[1].pos, player2 = thirdList[2].pos})
        else
            if thirdList[1] ~= nil and thirdList[2] ~= nil then
                --self:OnVote(0, thirdList[1].pos, thirdList[2].pos)
                if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess or IngotCrashManager.Instance.now_round == IngotCrashManager.Instance.max_round then
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_vote, {type = 0, player1 = thirdList[1].pos, player2 = thirdList[2].pos})
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("竞猜尚未开启，请留意竞猜公告{face_1,2}"))
                end
            end
        end
    end
end

function IngotCrashWindow:OnTime()
    local dis = (IngotCrashManager.Instance.time or 0) - BaseUtils.BASE_TIME
    local min_str = nil
    local sec_str = nil
    if dis < 0 then
        dis = 0
    end
    min_str = math.floor(dis / 60)
    sec_str = dis % 60
    if dis > 60 then
        if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
            self.timeText.text = string.format(TI18N("竞猜剩余时间: <color='#00ff00'>%s</color>"), string.format(TI18N("%s分钟%s秒"), min_str, sec_str))
        else
            self.timeText.text = string.format(TI18N("比赛进行中，下轮竞猜开启: <color='#00ff00'>%s</color>"), string.format(TI18N("%s分钟%s秒"), min_str, sec_str))
        end
    else
        if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
            self.timeText.text = string.format(TI18N("竞猜剩余时间: <color='#00ff00'>%s</color>"), string.format(TI18N("%s秒"), sec_str))
        else
            self.timeText.text = string.format(TI18N("比赛进行中，下轮竞猜开启: <color='#00ff00'>%s</color>"), string.format(TI18N("%s分钟%s秒"), min_str, sec_str))
        end
    end
end

function IngotCrashWindow:OnToggle()
    self.tick:SetActive(IngotCrashManager.Instance.isShowDamaku)
    IngotCrashManager.Instance.isShowDamaku = not IngotCrashManager.Instance.isShowDamaku
end

function IngotCrashWindow:OnDamaku()
    DanmakuManager.Instance.model:OpenPanel({sendCall = function(msg) IngotCrashManager.Instance:send20014(msg) end})
end

function IngotCrashWindow:OnVote(type, index1, index2)
    if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_vote, {type = type, player1 = index1, player2 = index2})
    --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_vote, {type = type, player1 = index1, player2 = index2})
    -- elseif IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Champion then
    --     IngotCrashManager.Instance:send20023()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("竞猜尚未开启，请留意竞猜公告{face_1,2}"))
    end
end

function IngotCrashWindow:UpdateVideo()
    local indexList = nil
    for i,betList in ipairs(self.betList) do
        local num = math.pow(2, i)
        for j,bet in ipairs(betList) do
            indexList = {}
            for iii=(j - 1) * num + 1, j * num do
                if self.model.best16Tab[iii] ~= nil and (self.model.best16Tab[iii].is_lose == 0 or self.model.best16Tab[iii].lose_round - (IngotCrashManager.Instance.max_round - 2) >= i) then
                    table.insert(indexList, iii)
                end
            end
            -- bet.eyeBtn.onClick:RemoveAllListeners()
            -- bet.eyeBtn.onClick:AddListener(function() self:OnVideo(indexList[1], indexList[2]) end)
        end
    end

    indexList = {}
    for i=1,16 do
        if self.model.best16Tab[i] ~= nil and self.model.best16Tab[i].lose_round == IngotCrashManager.Instance.max_round - 1 then
            table.insert(indexList, i)
        end
    end
end

function IngotCrashWindow:OnEye(round, index)
    local num = math.pow(2,round)
    local beginIndex = (index - 1) * num + 1

    local player1 = self:GetTop(beginIndex, beginIndex - 1 + num / 2)
    local player2 = self:GetTop(beginIndex + num / 2, beginIndex + num - 1)

    if player1 ~= nil and player2 ~= nil then
        -- self:OnVote(round, player1.pos, player2.pos)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_vote, {type = round, player1 = player1.pos, player2 = player2.pos})
    end
end

function IngotCrashWindow:GetTop(beginIndex, endIndex)
    local player = nil
    for i=beginIndex,endIndex do
        if self.model.best16Tab[i] ~= nil then
            if self.model.best16Tab[i].is_lose == 0 then
                return self.model.best16Tab[i]
            elseif player == nil or player.lose_round < self.model.best16Tab[i].lose_round then
                player = self.model.best16Tab[i]
            end
        end
    end
    return player
end

-- 查看录像
function IngotCrashWindow:OnVideo(index1, index2)
    local player1 = self.model.best16Tab[index1]
    local player2 = self.model.best16Tab[index2]

    if player1.is_combat > 1 then
        IngotCrashManager.Instance:send20010(player1.rid, player1.platform, player1.zone_id)
    end
end

function IngotCrashWindow:OnClickChampion()
end

function IngotCrashWindow:CheckVote()
    for _,list in pairs(self.betList) do
        for _,v in pairs(list) do
            if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
                v.betImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                v.betText.color = ColorHelper.DefaultButton3
            else
                v.betImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                v.betText.color = ColorHelper.DefaultButton4
            end
        end
    end

    for _,v in pairs(self.betList3) do
        if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
            v.betImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            v.betText.color = ColorHelper.DefaultButton3
        else
            v.betImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            v.betText.color = ColorHelper.DefaultButton4
        end
    end
end
