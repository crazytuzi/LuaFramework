--
-- zxs
-- 巅峰战报详细
--
local QUIDialog = import(".QUIDialog")
local QUIDialogTopAgainstRecordDetail = class("QUIDialogTopAgainstRecordDetail", QUIDialog)
local QUIWidgetFightEndTitleDetailClient = import("..widgets.QUIWidgetFightEndTitleDetailClient")
local QUIWidgetFightEndDetailClient = import("..widgets.QUIWidgetFightEndDetailClient")
local QListView = import("...views.QListView")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("..QUIViewController")

function QUIDialogTopAgainstRecordDetail:ctor(options)
    local ccbFile = "ccb/Dialog_TopRecord_detail.ccbi"
    local callBack = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},
        {ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
    }
    QUIDialogTopAgainstRecordDetail.super.ctor(self, ccbFile, callBack, options)
    self.isAnimation = true

    self._data = {}
    self._info = options.info
    self:initData()
    self:setScoreList()
    self:initListView()
end

function QUIDialogTopAgainstRecordDetail:initData()
    local attackScore = 0
    local defenseScore = 0
    for i, v in pairs(self._info.scoreList or {}) do
        if v == true then
            attackScore = attackScore + 1
        else
            defenseScore = defenseScore + 1
        end
    end

    local info = {}
    info.name1 = self._info.fighter1.name
    info.name2 = self._info.fighter2.name
    info.level1 = self._info.fighter1.level
    info.level2 = self._info.fighter2.level
    info.avatar1 = self._info.fighter1.avatar
    info.avatar2 = self._info.fighter2.avatar
    info.attackScore = attackScore
    info.defenseScore = defenseScore
    table.insert(self._data, {oType = 1, info = info})

    local timeStr = self:getTimeDescription(self._info.time or 0)
    self._ccbOwner.tf_time:setString(timeStr)
end

function QUIDialogTopAgainstRecordDetail:getTimeDescription(time)
    local gap = math.floor((q.serverTime()*1000 - time)/1000 )
    if gap > 0 then
        if gap < HOUR then
            return math.floor(gap/MIN) .. "分钟前"
        elseif gap < DAY then
            return math.floor(gap/HOUR) .. "小时前"
        elseif gap < WEEK then
            return math.floor(gap/DAY) .. "天前"
        else
            return "7天前"
        end
    end
    return "7天前"
end

function QUIDialogTopAgainstRecordDetail:setScoreList()
    if self._info.scoreList[1] ~= nil then
        local info = {}
        info.index = 1
        info.isWin = self._info.scoreList[1]
        info.heroFighter = self._info.replayInfo.fighter1
        info.heroAlternateFighter = self._info.replayInfo.userAlternateInfos
        info.heroSubFighter = self._info.replayInfo.sub1Fighter1
        info.heroSubFighter2 = self._info.replayInfo.sub2Fighter1
        info.heroSubFighter3 = self._info.replayInfo.sub3Fighter1
        info.enemyFighter = self._info.replayInfo.fighter2
        info.enemyAlternateFighter = self._info.replayInfo.enemyAlternateInfos
        info.enemySubFighter = self._info.replayInfo.sub1Fighter2
        info.enemySubFighter2 = self._info.replayInfo.sub2Fighter2
        info.enemySubFighter3 = self._info.replayInfo.sub3Fighter2
        info.teamHeroSkillIndex = self._info.replayInfo.team1HeroSkillIndex
        info.teamHeroSkillIndex2 = self._info.replayInfo.team1HeroSkillIndex2
        info.teamHeroSkillIndex3 = self._info.replayInfo.team1HeroSkillIndex3
        info.teamEnemySkillIndex = self._info.replayInfo.team1EnemySkillIndex
        info.teamEnemySkillIndex2 = self._info.replayInfo.team1EnemySkillIndex2
        info.teamEnemySkillIndex3 = self._info.replayInfo.team1EnemySkillIndex3
        info.heroSoulSpirit = self._info.replayInfo.team1HeroSoulSpirits
        info.enemySoulSpirit = self._info.replayInfo.team1EnemySoulSpirits

        info.heroGodarmList = self._info.replayInfo.team1GodarmList
        info.enemyGodarmList = self._info.replayInfo.team1EnemyGodarmList

        if self._info.scoreList[2] ~= nil then
            info.isMultiTeam = true
        end
        if self._info.reportType == REPORT_TYPE.SOTO_TEAM then
            info.isAlternateTeam = true
        end
        table.insert(self._data, {oType = 2, info = info})
    end
    
    if self._info.scoreList[2] ~= nil then
        local info = {}
        info.index = 2
        info.isWin = self._info.scoreList[2]
        info.heroFighter = self._info.replayInfo.team2HeroInfoes
        info.heroSubFighter = self._info.replayInfo.team2Sub1Fighter1
        info.enemyFighter = self._info.replayInfo.team2Rivals
        info.enemySubFighter = self._info.replayInfo.team2Sub1Fighter2
        info.teamHeroSkillIndex = self._info.replayInfo.team2HeroSkillIndex
        info.teamHeroSkillIndex2 = self._info.replayInfo.team2HeroSkillIndex2
        info.teamEnemySkillIndex = self._info.replayInfo.team2EnemySkillIndex
        info.teamEnemySkillIndex2 = self._info.replayInfo.team2EnemySkillIndex2
        info.heroSoulSpirit = self._info.replayInfo.team2HeroSoulSpirits
        info.enemySoulSpirit = self._info.replayInfo.team2EnemySoulSpirits
        info.isMultiTeam = true
  
        info.heroGodarmList = self._info.replayInfo.team2GodarmList
        info.enemyGodarmList = self._info.replayInfo.team2EnemyGodarmList

        table.insert(self._data, {oType = 2, info = info})
    end
    if self._info.scoreList[3] ~= nil then
        local info = {}
        info.index = 3
        info.isWin = self._info.scoreList[3]
        info.isMultiTeam = true
        if self._info.scoreList[1] == true then
            info.heroFighter = self._info.replayInfo.team2HeroInfoes
            info.heroSubFighter = self._info.replayInfo.team2Sub1Fighter1
            info.enemyFighter = self._info.replayInfo.fighter2
            info.enemySubFighter = self._info.replayInfo.sub1Fighter2
            info.teamHeroSkillIndex = self._info.replayInfo.team2HeroSkillIndex
            info.teamHeroSkillIndex2 = self._info.replayInfo.team2HeroSkillIndex2
            info.teamEnemySkillIndex = self._info.replayInfo.team1EnemySkillIndex
            info.teamEnemySkillIndex2 = self._info.replayInfo.team1EnemySkillIndex2
            info.heroSoulSpirit = self._info.replayInfo.team2HeroSoulSpirits
            info.enemySoulSpirit = self._info.replayInfo.team1EnemySoulSpirits
            info.heroGodarmList = self._info.replayInfo.team2GodarmList
            info.enemyGodarmList = self._info.replayInfo.team1EnemyGodarmList

        else
            info.heroFighter = self._info.replayInfo.fighter1
            info.heroSubFighter = self._info.replayInfo.sub1Fighter1
            info.enemyFighter = self._info.replayInfo.team2Rivals
            info.enemySubFighter = self._info.replayInfo.team2Sub1Fighter2
            info.teamHeroSkillIndex = self._info.replayInfo.team1HeroSkillIndex
            info.teamHeroSkillIndex2 = self._info.replayInfo.team1HeroSkillIndex2
            info.teamEnemySkillIndex = self._info.replayInfo.team2EnemySkillIndex
            info.teamEnemySkillIndex2 = self._info.replayInfo.team2EnemySkillIndex2
            info.heroSoulSpirit = self._info.replayInfo.team1HeroSoulSpirits
            info.enemySoulSpirit = self._info.replayInfo.team2EnemySoulSpirits
            info.heroGodarmList = self._info.replayInfo.team1GodarmList
            info.enemyGodarmList = self._info.replayInfo.team2EnemyGodarmList            
        end

        table.insert(self._data, {oType = 2, info = info})
    end
end

function QUIDialogTopAgainstRecordDetail:initListView()
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                -- body
                local isCacheNode = true
                local itemData = self._data[index]
                local item = list:getItemFromCache(itemData.oType)
                if not item then
                    if itemData.oType == 1 then
                        item = QUIWidgetFightEndTitleDetailClient.new()
                    else
                        item = QUIWidgetFightEndDetailClient.new()
                        item:addEventListener(QUIWidgetFightEndDetailClient.EVENT_CLICK_HEAD, handler(self, self.headClickHandler))
                    end
                    isCacheNode = false
                end
                item:setInfo(itemData.info)
                info.item = item
                info.size = item:getContentSize()
                
                if itemData.oType == 2 then
                    item:registerItemBoxPrompt(index, list)
                end

                return isCacheNode
            end,
            ignoreCanDrag = true,
            enableShadow = false,
            totalNumber = #self._data,
        }  
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._data})
    end
end

function QUIDialogTopAgainstRecordDetail:headClickHandler(event)
    local actorId = event.actorId
    local isHero = event.isHero or false
    local isSoulSpirit = event.isSoulSpirit or false

    local reportId = self._info.reportId
    local reportType = self._info.reportType
    QReplayUtil:getReplayInfo(reportId, function (data)
        QReplayUtil:downloadReplay(reportId, function (replay, replayInfo)
            if self:safeCheck() and replayInfo then
                local fighter = QReplayUtil:getFighterFromReplayInfo(replayInfo, isHero)
                self:showHeroInfo(fighter, actorId, isSoulSpirit)
            end
        end, nil, reportType, true)
    end, nil, reportType)
end

function QUIDialogTopAgainstRecordDetail:showHeroInfo(fighter, actorId, isSoulSpirit)
    
    print(" sfighter -- ",fighter)
    printTable(fighter)
    local actorIds = {}
    local isNPC = false
    local isSoulNowHero = false
    local function getActorIds(heros)
        if isNPC then
            return
        end
        for i, value in pairs( heros or {} ) do
            -- 如果是魂灵，则需要从魂师里找有没有护佑的对象，有的话，查看的对象就是该魂师 actorId做个转换
            if isSoulSpirit then
                if value.soulSpirit and value.soulSpirit.id == actorId then
                    actorId = value.actorId
                    isSoulNowHero = true
                end
            end
            if value.actorId == actorId and not value.equipments then
                isNPC = true
                break
            end
            table.insert(actorIds, value.actorId)
        end
    end
    getActorIds(fighter.heros)
    getActorIds(fighter.alternateHeros)
    getActorIds(fighter.subheros)
    getActorIds(fighter.sub2heros)
    getActorIds(fighter.sub3heros)
    getActorIds(fighter.main1Heros)
    getActorIds(fighter.sub1heros)
    
    if isSoulSpirit and not isSoulNowHero then
        app.tip:floatTip("该魂灵还没有护佑魂师")
        return
    end

    if isNPC then
        app.tip:floatTip("该魂师正在闭关修炼，请勿打扰")
        return
    end

    local pos = 0
    for i, id in ipairs(actorIds) do
        if id == actorId then
            pos = i
            break
        end
    end
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroInfo", 
        options = {hero = actorIds, pos = pos, fighter = fighter or {}}})
end

function QUIDialogTopAgainstRecordDetail:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogTopAgainstRecordDetail:_onTriggerClose(event)
    if q.buttonEventShadow(event,self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogTopAgainstRecordDetail:_onTriggerShare(event)
    if q.buttonEventShadow(event,self._ccbOwner.btn_share) == false then return end
    app.sound:playSound("common_cancel")
    
    local reportId = self._info.reportId
    local reportType = self._info.reportType
    local name1 = self._info.fighter1.name
    local name2 = self._info.fighter2.name
    QReplayUtil:getReplayInfo(reportId, function (data)
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogReplayShare", 
            options = {myNickName = name1, rivalName = name2, replayId = reportId, replayType = reportType}}, {isPopCurrentDialog = false})
    end, nil, reportType)
end

function QUIDialogTopAgainstRecordDetail:_onTriggerReplay(event)
     if q.buttonEventShadow(event,self._ccbOwner.btn_replay) == false then return end
    app.sound:playSound("common_cancel")
    
    local reportId = self._info.reportId
    local reportType = self._info.reportType
    QReplayUtil:getReplayInfo(reportId, function (data)
        QReplayUtil:downloadReplay(reportId, function (replay)
            QReplayUtil:play(replay, data.scoreList, data.fightReportStats, true)
        end, nil, reportType)
    end, nil, reportType)

    if reportType == REPORT_TYPE.ARENA then
        app:triggerBuriedPoint(21610)
    elseif reportType == REPORT_TYPE.GLORY_TOWER then
        app:triggerBuriedPoint(21611)
    elseif reportType == REPORT_TYPE.GLORY_ARENA then
        app:triggerBuriedPoint(21612)
    elseif reportType == REPORT_TYPE.STORM_ARENA then
        app:triggerBuriedPoint(21614)
    elseif reportType == REPORT_TYPE.FIGHT_CLUB then
        app:triggerBuriedPoint(21615)
    end 
end

return QUIDialogTopAgainstRecordDetail

