-- --------------------------
-- 主UI任务追踪
-- hosr
-- --------------------------
MainuiTracePanel = MainuiTracePanel or BaseClass(BasePanel)

function MainuiTracePanel:__init()
    self.resList = {
        {file = AssetConfig.mainuitrace, type = AssetType.Main},
        {file = AssetConfig.teamquest, type = AssetType.Dep},
        -- {file = AssetConfig.warrior_textures, type = AssetType.Dep},
        -- {file = AssetConfig.attr_icon, type = AssetType.Dep},
        -- {file = AssetConfig.may_textures, type = AssetType.Dep},
        -- {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        -- {file = AssetConfig.tower_raffle_textures, type = AssetType.Dep},
        -- {file = AssetConfig.rank_textures, type = AssetType.Dep},
        -- {file = AssetConfig.midAutumn_textures, type = AssetType.Dep},
        -- {file = AssetConfig.bufficon, type = AssetType.Dep},
    }

    self.tabSetting = {
        axis = BoxLayoutAxis.X
        ,spacing = 5
    }

    self.containerOriginX = 0

    self.isShow = false
    self.isFight = false
    self.has_init = false
    self.currentIndex = 0
    self.currentType = nil

    self.winIds = {
        [1] = WindowConfig.WinID.taskwindow,
        [2] = WindowConfig.WinID.team,
    }

    self.childTab = {}
    self.childObjTab = {}
    self.showList = TraceEumn.ShowTypeDetail[TraceEumn.ShowType.Normal]

    self.redListener = function() self:Red() end
    self.teamUpdate = function() self:UpdateFormation() end
    self.levelUp = function() self:LevelUp() end
    self.adaptListener = function() self:AdaptIPhoneX() end

    self.OnOpenEvent:Add(function() self:OnShow() end)

    self.effect = nil
    if RoleManager.Instance.RoleData.lev < 20 then
        self.effectPath = "prefabs/effect/20053.unity3d"
        table.insert(self.resList, {file = self.effectPath, type = AssetType.Main})
    end
end

function MainuiTracePanel:ShowCanvas(bool)
    if self.gameObject == nil then
        return
    end

    if bool then
        BaseUtils.ChangeLayersRecursively(self.transform, "UI")
        if self.raycaster == nil then
            self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        end
        if self.raycaster ~= nil then
            self.raycaster.enabled = true
        end
    else
        BaseUtils.ChangeLayersRecursively(self.transform, "Water")
        if self.raycaster == nil then
            self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        end
        if self.raycaster ~= nil then
            self.raycaster.enabled = false
        end
    end
end

function MainuiTracePanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.team_update, self.teamUpdate)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.teamUpdate)
    EventMgr.Instance:RemoveListener(event_name.team_info_update, self.teamUpdate)
    EventMgr.Instance:RemoveListener(event_name.team_list_update, self.redListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levelUp)
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener)

    for i,v in ipairs(self.childTab) do
        v:DeleteMe()
    end
    self.childTab = nil

    BaseUtils.CancelIPhoneXTween(self.transform)

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil

    self:AssetClearAll()
end

function MainuiTracePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mainuitrace))
    self.gameObject.name = "MainuiTracePanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(MainUIManager.Instance.MainUICanvasView.gameObject.transform)
    self.transform.localScale = Vector3.one
    self.transform.anchorMax = Vector2.one
    self.transform.anchorMin = Vector2.zero
    self.transform.anchoredPosition3D = Vector3.zero

    -- local rect = self.gameObject:GetComponent(RectTransform)
    -- rect.localPosition = Vector3.zero
    -- rect.anchoredPosition = Vector2.zero

    if RoleManager.Instance.RoleData.lev < 20 then
        self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
        self.effect.name = "QuestBtnEffect"
        self.effect.transform:SetParent(self.transform)
        self.effect:SetActive(false)
    end
    
    self.gameObject:SetActive(true)

    self.showBtn = self.transform:Find("ShowButton"):GetComponent(Button)
    self.showBtn.gameObject:SetActive(false)
    self.combatShowBtn = self.transform:Find("ShowButtonCombat"):GetComponent(Button)
    self.combatShowBtn.gameObject:SetActive(false)
    self.containerRect = self.transform:Find("Main/Container"):GetComponent(RectTransform)

    self.mainObj = self.transform:Find("Main").gameObject
    self.mainRect = self.mainObj:GetComponent(RectTransform)
    self.mainTrans = self.mainObj.transform
    self.hideBtn = self.mainTrans:Find("HideButton"):GetComponent(Button)
    self.tabGroupObj = self.mainTrans:Find("TabButtonGroup")

    -- self.questContent = self.mainTrans:Find("TaskContent").gameObject
    -- self.teamContent = self.mainTrans:Find("TeamContent").gameObject
    -- self.dungeonContent = self.mainTrans:Find("DungeonContent").gameObject
    -- self.qualifyContent = self.mainTrans:Find("QualifyContent").gameObject
    -- self.trialContent = self.mainTrans:Find("TrialContent").gameObject
    -- self.examQuestionContent = self.mainTrans:Find("ExamQuestonContent").gameObject
    -- self.warriorContent = self.mainTrans:Find("WarriorContent").gameObject
    -- self.fairylandContent = self.mainTrans:Find("FairylandContent").gameObject
    -- self.paradeContent = self.mainTrans:Find("ActivityContent").gameObject
    -- self.topCompeteContent = self.mainTrans:Find("TopCompeteContent").gameObject
    -- self.marryContent = self.mainTrans:Find("MarryContent").gameObject
    -- self.guildfightContent = self.mainTrans:Find("GuildFightContent").gameObject
    -- self.heroContent = self.mainTrans:Find("HeroContent").gameObject
    -- self.guildEliteFightContent = self.mainTrans:Find("GuildEliteFightContent").gameObject
    -- self.dragonBoatContent = self.mainTrans:Find("DragonBoat").gameObject
    -- self.masqueradeContent = self.mainTrans:Find("MasquerateContent").gameObject
    -- self.skylanternContent = self.mainTrans:Find("LanternFairContent").gameObject
    -- self.enjoymoonContent = self.mainTrans:Find("EnjoyMoonContent").gameObject
    -- self.nationalDayContent = self.mainTrans:Find("NationalDayContent").gameObject
    -- self.halloweenContent = self.mainTrans:Find("HalloweenContent").gameObject
    -- self.guildDungeonContent = self.mainTrans:Find("GuildDungeonContent").gameObject
    -- self.newExamContent = self.mainTrans:Find("NewExamContent").gameObject

    self.childObjTab = {
        -- [1] = self.questContent,
        -- [2] = self.teamContent,
        -- [3] = self.dungeonContent,
        -- [4] = self.qualifyContent,
        -- [5] = self.trialContent,
        -- [6] = self.examQuestionContent,
        -- [7] = self.fairylandContent,
        -- [8] = self.warriorContent,
        -- [9] = self.paradeContent,
        -- [10] = self.topCompeteContent,
        -- [11] = self.marryContent,
        -- [12] = self.guildfightContent,
        -- [13] = self.guildEliteFightContent,
        -- [14] = self.heroContent,
        -- [15] = self.dragonBoatContent,
        -- [16] = self.masqueradeContent,
        -- [17] = self.masqueradeContent,
        -- [18] = self.skylanternContent,
        -- [19] = self.enjoymoonContent,
        --[20] = self.enjoymoonContent,
        -- [21] = self.nationalDayContent,
        -- [22] = self.halloweenContent,
        -- [26] = self.guildDungeonContent,
        -- [28] = self.newExamContent,
    }

    for _,v in pairs(self.childObjTab) do
        v:SetActive(false)
    end

    self.showBtn.onClick:AddListener(function() self:TweenShow() end)
    self.combatShowBtn.onClick:AddListener(function() self:TweenShow() end)
    self.hideBtn.onClick:AddListener(function() self:TweenHiden() end)

    local setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index,special) self:ChangeTab(index,special) end, setting)
    local length = self.tabGroupObj.transform.childCount
    for i=0,length - 1 do
        self.tabGroupObj.transform:GetChild(i).gameObject:SetActive(false)
    end
    self.has_init = true

    -- self.tabGroup:ResetText(TraceEumn.BtnType.DragonBoat, TI18N("龙舟"))
    self.tabGroup:ResetText(TraceEumn.BtnType.DragonBoat, TI18N("滑雪"))
    self.tabGroup:ResetText(TraceEumn.BtnType.Halloween, TI18N("南 瓜"))

    -- self.tabGroup.buttonTab[TraceEumn.BtnType.DragonBoat].transform:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "dragonboat2")
    self.tabGroup.buttonTab[TraceEumn.BtnType.DragonBoat].transform:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "dragonboat")

    self:AutoShowType()
    self:AdaptIPhoneX()
    self:UpdateFormation()
    self:TweenShow()

    self:ClearMainAsset()

    EventMgr.Instance:AddListener(event_name.role_event_change, function() self:on_role_event_change() end)
    EventMgr.Instance:AddListener(event_name.trial_update, function() self:AutoShowType() end)
    EventMgr.Instance:AddListener(event_name.begin_fight, function() self:BeginFight() end)
    EventMgr.Instance:AddListener(event_name.end_fight, function() self:EndFight() end)
    EventMgr.Instance:AddListener(event_name.team_list_update, self.redListener)
    EventMgr.Instance:AddListener(event_name.team_update, self.teamUpdate)
    EventMgr.Instance:AddListener(event_name.team_info_update, self.teamUpdate)
    EventMgr.Instance:AddListener(event_name.team_leave, self.teamUpdate)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levelUp)
    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)
    -- 这里完了再去初始化对话框，保证层级遮挡
    MainUIManager.Instance:initDialog()

    self.isShow = true
    EventMgr.Instance:Fire(event_name.trace_quest_show)
    
    if BaseUtils.IsVerify then
        self.gameObject:SetActive(false)
    end
end

function MainuiTracePanel:OnShow()
    self:AutoShowType()
    self:AdaptIPhoneX()
    EventMgr.Instance:Fire(event_name.trace_quest_show)
end

--根据状态显示不同的追中panel
function MainuiTracePanel:on_role_event_change()
    --print(debug.traceback().."on_role_event_change")
    local mapid = SceneManager.Instance:CurrentMapId()
    local role = RoleManager.Instance.RoleData
    print("角色事件："..role.event)
    if role.event == RoleEumn.Event.TopCompete then
        self:ChangeShowType(TraceEumn.ShowType.TopCompete)
    elseif role.event == RoleEumn.Event.Event_fairyland then
        self:ChangeShowType(TraceEumn.ShowType.FairyLand)
    elseif role.event == RoleEumn.Event.Event_examination_palace then
        self:ChangeShowType(TraceEumn.ShowType.ExamQuestion)
    elseif role.event == RoleEumn.Event.Exam then
        self:ChangeShowType(TraceEumn.ShowType.ExamQuestion)
    elseif role.event == RoleEumn.Event.Match then
        self:ChangeShowType(TraceEumn.ShowType.Qualify)
    elseif mapid == 42100 then
        self:ChangeShowType(TraceEumn.ShowType.UnlimitedChallenge)
    elseif mapid == 51001 or mapid == 51000 then
        self:ChangeShowType(TraceEumn.ShowType.Warrior)
    elseif ParadeManager.Instance.selfstatus == 1 then
        self:ChangeShowType(TraceEumn.ShowType.Parade)
    elseif role.event == RoleEumn.Event.Marry
        or role.event == RoleEumn.Event.Marry_guest
        or role.event == RoleEumn.Event.Marry_cere
        or role.event == RoleEumn.Event.Marry_guest_cere then
        self:ChangeShowType(TraceEumn.ShowType.Marry)
    elseif role.event == RoleEumn.Event.GuildFight or role.event == RoleEumn.Event.GuildFightReady then
        self:ChangeShowType(TraceEumn.ShowType.GuildFight)
    elseif role.event == RoleEumn.Event.HeroReady or role.event == RoleEumn.Event.Hero then
        self:ChangeShowType(TraceEumn.ShowType.Hero)
    elseif role.event == RoleEumn.Event.GuildEliteFight then
        self:ChangeShowType(TraceEumn.ShowType.GuildEliteFight)
    elseif role.event == RoleEumn.Event.DragonBoat then
        self:ChangeShowType(TraceEumn.ShowType.DragonBoat)
    elseif role.event == RoleEumn.Event.Masquerade or role.event == RoleEumn.Event.MasqueradeReady then
        self:ChangeShowType(TraceEumn.ShowType.Masquerade)
    elseif role.event == RoleEumn.Event.EnjoyMoon then
        self:ChangeShowType(TraceEumn.ShowType.EnjoyMoon)
    elseif role.event == RoleEumn.Event.SkyLantern then
        self:ChangeShowType(TraceEumn.ShowType.SkyLantern)
    elseif role.event == RoleEumn.Event.DefenseCake or role.event == RoleEumn.Event.DefenseCakeSub then
        self:ChangeShowType(TraceEumn.ShowType.NationalDay)
    elseif role.event == RoleEumn.Event.CanYon or role.event == RoleEumn.Event.CanYonReady then
        self:ChangeShowType(TraceEumn.ShowType.CanYon)
    elseif role.event == RoleEumn.Event.Halloween or role.event == RoleEumn.Event.Halloween_sub then
        self:ChangeShowType(TraceEumn.ShowType.Halloween)
    elseif role.event == RoleEumn.Event.GodsWar then
        self:ChangeShowType(TraceEumn.ShowType.GodsWarReady)
    elseif mapid == 30015 then
        self:ChangeShowType(TraceEumn.ShowType.HalloweenReady)
    elseif mapid == 40000 then
        self:ChangeShowType(TraceEumn.ShowType.SnowBall)
    elseif role.event == RoleEumn.Event.GuildDungeon or role.event == RoleEumn.Event.GuildDungeonBattle then
        self:ChangeShowType(TraceEumn.ShowType.GuildDungeon)
    elseif role.event == RoleEumn.Event.AnimalChess then
        self:ChangeShowType(TraceEumn.ShowType.AnimalChess)
    elseif role.event == RoleEumn.Event.NewQuestionMatch then
        self:ChangeShowType(TraceEumn.ShowType.NewQuestionMatch)
    elseif role.event == RoleEumn.Event.IngotCrashReady
        or role.event == RoleEumn.Event.IngotCrashPVP
        or role.event == RoleEumn.Event.IngotCrashMatch
        then
        self:ChangeShowType(TraceEumn.ShowType.IngotCrash)
    elseif role.event == RoleEumn.Event.StarChallenge then
        self:ChangeShowType(TraceEumn.ShowType.StarChallenge)
    elseif role.event == RoleEumn.Event.ExquisiteShelf or mapid == ExquisiteShelfManager.Instance.readyMapId then
        self:ChangeShowType(TraceEumn.ShowType.ExquisiteShelf)
    elseif role.event == RoleEumn.Event.GuildDragon or role.event == RoleEumn.Event.GuildDragonFight or role.event == RoleEumn.Event.GuildDragonRod then
        self:ChangeShowType(TraceEumn.ShowType.GuildDragon)
    elseif role.event == RoleEumn.Event.GodsWarWorShip or role.event == RoleEumn.Event.GodsWarWorShipChampion  then
        self:ChangeShowType(TraceEumn.ShowType.GodsWarWorShip)
    elseif role.event == RoleEumn.Event.RushTop or role.event == RoleEumn.Event.RushTopPlay then
        self:ChangeShowType(TraceEumn.ShowType.RushTop)
    elseif role.event == RoleEumn.Event.Provocation  or role.event == RoleEumn.Event.ProvocationRoom then
        self:ChangeShowType(TraceEumn.ShowType.CrossArena)
    elseif role.event == RoleEumn.Event.ApocalypseLord then
        self:ChangeShowType(TraceEumn.ShowType.ApocalypseLord)
    elseif role.event == RoleEumn.Event.GodsWarChallenge then
        self:ChangeShowType(TraceEumn.ShowType.GodsWarChallenge)
    else
        self:ChangeShowType(TraceEumn.ShowType.Normal)
    end
end

function MainuiTracePanel:TweenShow()
    if BaseUtils.IsVerify then
        self.gameObject:SetActive(false)
    end
    
    if self.childTab[self.currentIndex] ~= nil then
        self.childTab[self.currentIndex]:Show()
    end
    if not self.loading then
        self.mainObj:SetActive(true)
        self.showBtn.gameObject:SetActive(false)
        self.combatShowBtn.gameObject:SetActive(false)
        -- self.mainObj.transform.localPosition = Vector2(0, -95)
        local func = function()
            self.isShow = true
            EventMgr.Instance:Fire(event_name.trace_quest_show)
        end
        Tween.Instance:MoveX(self.mainRect, self.containerOriginX, 0.2, func)
        MainUIManager.Instance:TraceQuestSwitch(true)
    end
end

function MainuiTracePanel:TweenHiden()
    if self.loading then
        return
    end

    local func = function()
        if self.isFight then
            self.combatShowBtn.gameObject:SetActive(true)
        else
            self.showBtn.gameObject:SetActive(true)
        end
        self.mainObj.transform.localPosition = Vector2(306, -95)
        -- self.mainObj:SetActive(false)
        self.isShow = false
        EventMgr.Instance:Fire(event_name.trace_quest_hide)

        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:Hiden()
        end
    end
    -- func() self.mainObj.transform.localPosition = Vector2(250, -95)
    -- self.mainObj:SetActive(false)
    Tween.Instance:MoveX(self.mainRect, 306, 0.2, func)
    MainUIManager.Instance:TraceQuestSwitch(false)
end

function MainuiTracePanel:BeginFight()
    self.isFight = true
    self:TweenHiden()
end

function MainuiTracePanel:EndFight()
    self.isFight = false
    self:TweenShow()
end

function MainuiTracePanel:Layout()
    self.tabLayout:AddCell()
end

function MainuiTracePanel:ChangeTab(index, special)
    if self.currentIndex ~= 0 and self.currentIndex ~= index then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:Hiden()
        end
    end

    if not special and self.currentIndex == index then
        if self.winIds[index] ~= nil then
            WindowManager.Instance:OpenWindowById(self.winIds[index])
        end
    end
    --无队伍时 点击队伍button直接打开面板
    if index == 2 and RoleManager.Instance.RoleData.team_status == 0 then
        if self.winIds[index] ~= nil then
            WindowManager.Instance:OpenWindowById(self.winIds[index])
        end
    end

    self.currentIndex = index
    local child = self.childTab[self.currentIndex]

    if child == nil then
        -- 挂在追踪展示下的子标签面板
        if index == 1 then
            self.traceQuest = MainuiTraceQuest.New(self)
            child = self.traceQuest
        elseif index == 2 then
            self.traceTeam = MainuiTraceTeam.New(self)
            child = self.traceTeam
        elseif index == 3 then
            self.traceDun = MainuiTraceDungeon.New(self)
            child = self.traceDun
        elseif index == 4 then
            self.qualifyPanel = MainuiQualifyPanel.New(self)
            child = self.qualifyPanel
        elseif index == 5 then
            self.traceTrial = MainuiTraceTrial.New(self)
            child = self.traceTrial
        elseif index == 6 then
            self.examQuestion = MainuiExamQuestionPanel.New(self)
            child = self.examQuestion
        elseif index == 7 then
            self.fairyLand = MainuiFairyLandPanel.New(self)
            child = self.fairyLand
        elseif index == 8 then
            self.warriorPanel = MainuiTraceWarrior.New(self)
            child = self.warriorPanel
        elseif index == 9 then
            self.traceParade = MainuiTraceParade.New(self)
            child = self.traceParade
        elseif index == 10 then
            self.topCompete = MainuiTopCompetePanel.New(self)
            child = self.topCompete
        elseif index == 11 then
            self.marry = MainuiMarryPanel.New(self)
            child = self.marry
        elseif index == 12 then
            self.guildfight = GuildfightPanel.New(self)
            child = self.guildfight
        elseif index == 13 then
            self.guildEliteFight = GuildfightElitePanel.New(self)
            child = self.guildEliteFight
        elseif index == 14 then
            self.heroPanel = MainuiTraceHero.New(self)
            child = self.heroPanel
        elseif index == 15 then
            self.dragonBoat = MainuiTraceDragonboat.New(self)
            child = self.dragonBoat
        elseif index == 16 then
            self.masquerade = MainuiTraceMasquerade.New(self)
            child = self.masquerade
        elseif index == 17 then
            self.unlimitedchallenge = MainuiTraceUnlimitedChallenge.New(self)
            child = self.unlimitedchallenge
        elseif index == 18 then
            self.skylantern = MainuiTraceSkylantern.New(self)
            child = self.skylantern
        elseif index == 19 then
            self.enjoymoon = MainuiTraceEnjoymoon.New(self)
            child = self.enjoymoon
        elseif index == 20 then
            self.canyon = MainuiTraceCanYon.New(self)
            child = self.canyon
        elseif index == 21 then
            self.nationalday = MainuiTraceNationalDay.New(self)
            child = self.nationalday
        elseif index == 22 then
            self.halloween = MainuiTraceHalloween.New(self)
            child = self.halloween
        elseif index == 23 then
            self.halloneenReady = MainuiTracePumpkinReady.New(self)
            child = self.halloneenReady
        elseif index == 24 then
            self.godswar = MainuiTraceGodsWar.New(self)
            child = self.godswar
        elseif index == 25 then
            self.snowball = MainuiTraceSnowBall.New(self)
            child = self.snowball
        elseif index == 26 then
            child = MainuiTraceGuildDungeon.New(self)
        elseif index == 27 then
            self.animalChessTrace = MainuiTraceAnimalChess.New(self)
            child = self.animalChessTrace
        elseif index == 28 then
            self.newExam = MainuiTraceNewExam.New(self)
            child = self.newExam
        elseif index == 29 then
            self.ingotCrash = MainuiTraceIngotCrash.New(self)
            child = self.ingotCrash
        elseif index == 30 then
            self.starChallenge = MainuiTraceStarChallenge.New(self)
            child = self.starChallenge
        elseif index == 31 then
            self.exquisiteShelf = MainuiTraceExquisiteShelf.New(self)
            child = self.exquisiteShelf
        elseif index == 32 then
            self.guildDragon = MainuiTraceGuildDragon.New(self)
            child = self.guildDragon
        elseif index == 33 then

            self.rushTop = MainuiTraceRushTop.New(self)
            child = self.rushTop
        elseif index == 34 then
            self.godsWarWorShip = MainuiTraceGodsWarWorShip.New(self)
            child = self.godsWarWorShip
        elseif index == 35 then
            self.crossArena = MainuiTraceCrossArena.New(self)
            child = self.crossArena
        elseif index == 36 then
            self.apocalypse = MainuiTraceApocalypseLord.New(self)
            child = self.apocalypse
        end
        self.childTab[index] = child
    end
    -- child:Init(self.childObjTab[self.currentIndex])

    child:Show()
    if self.currentType == TraceEumn.ShowType.SnowBall and self.currentIndex == 2 then
        self.tabGroup:ShowRed(25, true)
    else
        self.tabGroup:ShowRed(25, false)
    end
    self:CheckShowEffect()
end

-- 根据当前状态自动改变显示类型
-- 外部可以调用这个方法来进行登录时的处理，前提是要的状态能拿到
-- 否则就在各自数据更新完了再准确调用ChangeShowTypw
-- 类型枚举查看 trace_eumn.lua
function MainuiTracePanel:AutoShowType()
    -- Log.Error("MainuiTracePanel:AutoShowType="..RoleManager.Instance.RoleData.event)
    local role = RoleManager.Instance.RoleData
    local mapid = SceneManager.Instance:CurrentMapId()
    if role.event == RoleEumn.Event.TopCompete then
        self:ChangeShowType(TraceEumn.ShowType.TopCompete)
    elseif role.event == RoleEumn.Event.Event_fairyland then
        self:ChangeShowType(TraceEumn.ShowType.FairyLand)
    elseif role.event == RoleEumn.Event.Event_examination_palace then
        self:ChangeShowType(TraceEumn.ShowType.ExamQuestion)
    elseif role.event == RoleEumn.Event.Exam then
        self:ChangeShowType(TraceEumn.ShowType.ExamQuestion)
    elseif role.event == RoleEumn.Event.Match then
        self:ChangeShowType(TraceEumn.ShowType.Qualify)
    elseif SceneManager.Instance:CurrentMapId() == 51000 or SceneManager.Instance:CurrentMapId() == 51001 then
        self:ChangeShowType(TraceEumn.ShowType.Warrior)
    elseif SceneManager.Instance:CurrentMapId() == 60001 then
        self:ChangeShowType(TraceEumn.ShowType.Trial)
    elseif mapid == 42100 then
        self:ChangeShowType(TraceEumn.ShowType.UnlimitedChallenge)
    elseif mapid == 42000 or mapid == TowerMap[1] or mapid == TowerMap[2] or mapid == TowerMap[3] or role.event == RoleEumn.Event.Dungeon then
        -- DungeonManager.Instance:CheckOutStatus()
    elseif role.event == RoleEumn.Event.Marry
        or role.event == RoleEumn.Event.Marry_guest
        or role.event == RoleEumn.Event.Marry_cere
        or role.event == RoleEumn.Event.Marry_guest_cere then
        self:ChangeShowType(TraceEumn.ShowType.Marry)
    elseif role.event == RoleEumn.Event.GuildFight or role.event == RoleEumn.Event.GuildFightReady then
        self:ChangeShowType(TraceEumn.ShowType.GuildFight)
    elseif role.event == RoleEumn.Event.GuildEliteFight then
        self:ChangeShowType(TraceEumn.ShowType.GuildEliteFight)
    elseif role.event == RoleEumn.Event.HeroReady or role.event == RoleEumn.Event.Hero then
        self:ChangeShowType(TraceEumn.ShowType.Hero)
    elseif role.event == RoleEumn.Event.DragonBoat then
        self:ChangeShowType(TraceEumn.ShowType.DragonBoat)
    elseif role.event == RoleEumn.Event.Masquerade or role.event == RoleEumn.Event.MasqueradeReady then
        self:ChangeShowType(TraceEumn.ShowType.Masquerade)
    elseif role.event == RoleEumn.Event.EnjoyMoon then
        self:ChangeShowType(TraceEumn.ShowType.EnjoyMoon)
    elseif role.event == RoleEumn.Event.SkyLantern then
        self:ChangeShowType(TraceEumn.ShowType.SkyLantern)
    elseif role.event == RoleEumn.Event.CanYon or role.event == RoleEumn.Event.CanYonReady then
        self:ChangeShowType(TraceEumn.ShowType.CanYon)
    elseif role.event == RoleEumn.Event.DefenseCake or role.event == RoleEumn.Event.DefenseCakeSub then
        self:ChangeShowType(TraceEumn.ShowType.NationalDay)
    elseif role.event == RoleEumn.Event.Halloween or role.event == RoleEumn.Event.Halloween_sub then
        self:ChangeShowType(TraceEumn.ShowType.Halloween)
    elseif role.event == RoleEumn.Event.GodsWar then
        self:ChangeShowType(TraceEumn.ShowType.GodsWarReady)
    elseif mapid == 30015 then
        self:ChangeShowType(TraceEumn.ShowType.HalloweenReady)
    elseif mapid == 40000 then
        self:ChangeShowType(TraceEumn.ShowType.SnowBall)
    elseif role.event == RoleEumn.Event.GuildDungeon or role.event == RoleEumn.Event.GuildDungeonBattle then
        self:ChangeShowType(TraceEumn.ShowType.GuildDungeon)
    elseif role.event == RoleEumn.Event.AnimalChess then
        self:ChangeShowType(TraceEumn.ShowType.AnimalChess)
    elseif role.event == RoleEumn.Event.NewQuestionMatch then
        self:ChangeShowType(TraceEumn.ShowType.NewQuestionMatch)
    elseif role.event == RoleEumn.Event.IngotCrashReady
        or role.event == RoleEumn.Event.IngotCrashPVP
        or role.event == RoleEumn.Event.IngotCrashMatch
        then
        self:ChangeShowType(TraceEumn.ShowType.IngotCrash)
    elseif role.event == RoleEumn.Event.StarChallenge then
        self:ChangeShowType(TraceEumn.ShowType.StarChallenge)
    elseif role.event == RoleEumn.Event.ExquisiteShelf or mapid == ExquisiteShelfManager.Instance.readyMapId then
        self:ChangeShowType(TraceEumn.ShowType.ExquisiteShelf)
    elseif role.event == RoleEumn.Event.GuildDragon or role.event == RoleEumn.Event.GuildDragonFight or role.event == RoleEumn.Event.GuildDragonRod then
        self:ChangeShowType(TraceEumn.ShowType.GuildDragon)
    elseif role.event == RoleEumn.Event.GodsWarWorShip then
        self:ChangeShowType(TraceEumn.ShowType.GodsWarWorShip)
    elseif role.event == RoleEumn.Event.RushTop  or role.event == RoleEumn.Event.RushTopPlay then
        self:ChangeShowType(TraceEumn.ShowType.RushTop)
    elseif role.event == RoleEumn.Event.Provocation  or role.event == RoleEumn.Event.ProvocationRoom then
        self:ChangeShowType(TraceEumn.ShowType.CrossArena)
    elseif role.event == RoleEumn.Event.ApocalypseLord then
        self:ChangeShowType(TraceEumn.ShowType.ApocalypseLord)
    elseif role.event == RoleEumn.Event.GodsWarChallenge then
        self:ChangeShowType(TraceEumn.ShowType.GodsWarChallenge)
    else
        self:ChangeShowType(TraceEumn.ShowType.Normal)
    end
end

-- 改变显示类型
-- 即改变当前显示的两个按钮类型
function MainuiTracePanel:ChangeShowType(type)
    if self.has_init == false then
        return
    end
    -- print("MainuiTracePanel:on_role_event_change()"..RoleManager.Instance.RoleData.event)
    -- print(type)
    -- print(debug.traceback())

    -- 不处理重复切换，更新的问题底下每个模块自己做，不应该通过切换来进行
    if self.currentType ~= nil and self.currentType == type then
        return
    end
    self.currentType = type

    -- 先把旧的隐藏掉
    for _,btnType in ipairs(self.showList) do
        self.tabGroup.buttonTab[btnType].gameObject:SetActive(false)
    end
    -- 再处理新的，显示和布局
    self.showList = TraceEumn.ShowTypeDetail[type]

    for i,btnType in ipairs(self.showList) do
        local btn = self.tabGroup.buttonTab[btnType].gameObject
        btn.transform.localPosition = Vector2(92 * (i - 1), 0)
        btn:SetActive(true)
    end
    -- 变化后选中第一个
    self.tabGroup:ChangeTab(self.showList[1], true)
end

function MainuiTracePanel:Red()
    if TeamManager.Instance:HasApply() or TeamManager.Instance:HasRequest() then
        self.tabGroup:ShowRed(2, true)
    else
        self.tabGroup:ShowRed(2, false)
    end
end

-- 更新组队按钮上的阵法显示
function MainuiTracePanel:UpdateFormation()
    local btn = self.tabGroup.buttonTab[TraceEumn.BtnType.Team]
    local tag = btn.transform:Find("TagFormation").gameObject
    local label = tag.transform:Find("Text"):GetComponent(Text)
    if TeamManager.Instance:HasTeam() then
        if TeamManager.Instance.TypeData.team_formation ~= 0 then
            local formationData = DataFormation.data_list[string.format("%s_%s", TeamManager.Instance.TypeData.team_formation, 1)]
            if formationData ~= nil then
                tag:SetActive(true)
                local list = StringHelper.ConvertStringTable(formationData.name)
                label.text = list[1]..list[2]
            end
        end
    else
        tag:SetActive(false)
    end

    self:CheckShowEffect()
end

function MainuiTracePanel:LevelUp()
    if RoleManager.Instance.RoleData.lev > 19 then
        self:DestroyEffect()
    end
end

-- 显示任务按钮特效
function MainuiTracePanel:ShowQuestBtnEffect()
    if not BaseUtils.is_null(self.effect) then
        local btn = self.tabGroup.buttonTab[TraceEumn.BtnType.Quest]
        self.effect.transform:SetParent(btn.transform)
        self.effect.transform.localScale = Vector3(1.5, 0.7, 1)
        self.effect.transform.localPosition = Vector3(0, -36, 0)
        Utils.ChangeLayersRecursively(self.effect.transform, "UI")
        self.effect:SetActive(false)
        self.effect:SetActive(true)
    end
end

function MainuiTracePanel:DestroyEffect()
    if not BaseUtils.is_null(self.effect) then
        self.effect:SetActive(false)
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end
end

function MainuiTracePanel:HideQuestBtnEffect()
    if not BaseUtils.is_null(self.effect) then
        self.effect:SetActive(false)
    end
end

function MainuiTracePanel:Clear()
    self.currentType = nil
end

function MainuiTracePanel:CheckShowEffect()
    if self.currentIndex == TraceEumn.BtnType.Team and self.currentType == TraceEumn.ShowType.Normal then
        -- 普通状态下，切换到队伍
        -- 1.＜30用特效提示
        -- 2.无队伍、队伍只有自己一个人、暂离时，显示【任务】特效
        -- 3.非暂离且队伍2人或以上，不显示特效
        if RoleManager.Instance.RoleData.lev <= 30
            and (TeamManager.Instance:MemberCount() <= 1 or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Away) then
            self:ShowQuestBtnEffect()
        else
            self:HideQuestBtnEffect()
        end
    else
        self:HideQuestBtnEffect()
    end
end

function MainuiTracePanel:DeletePanel(type)
    if self.childTab[type] ~= nil then
        self.childTab[type]:DeleteMe()
        self.childTab[type] = nil
    end
end

function MainuiTracePanel:AdaptIPhoneX()
    BaseUtils.AdaptIPhoneX(self.transform)
end
