
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogAgainstRecordDetail = class("QUIDialogAgainstRecordDetail", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QScrollView = import("...views.QScrollView")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetAgainstRecordDetail = import("..widgets.QUIWidgetAgainstRecordDetail")

function QUIDialogAgainstRecordDetail:ctor(options)
    local ccbFile = "ccb/Dialog_StormArena_battlerecordinfo.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogAgainstRecordDetail._onTriggerClose)},
    }
    QUIDialogAgainstRecordDetail.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self:initData(options.info)
    self:setScoreList(options.info)
end

function QUIDialogAgainstRecordDetail:initData(data)
    local attackScore = 0
    local defenseScore = 0
    for i, v in pairs(data.scoreList or {}) do
        if v == true then
            attackScore = attackScore + 1
        else
            defenseScore = defenseScore + 1
        end
    end
    
    -- self._ccbOwner.team1Score1:setDisplayFrame(QSpriteFrameByPath(QResPath("StormArena_S")[attackScore+1]))
    -- self._ccbOwner.team2Score2:setDisplayFrame(QSpriteFrameByPath(QResPath("StormArena_S")[defenseScore+1])) 
    self._ccbOwner.team1Score1:setString(attackScore)
    self._ccbOwner.team2Score2:setString(defenseScore)
    
    local isInitiative = data.isInitiative or false
    local name1, name2, avatar1, avatar2, championCount1, championCount2
    if isInitiative then
        name1 = remote.user.nickname
        name2 = data.fighter.name
        avatar1 = remote.user.avatar
        championCount1 = remote.user.championCount
        avatar2 = data.fighter.avatar
        championCount2 = data.fighter.championCount
    else
        name1 = data.fighter.name
        name2 = remote.user.nickname
        avatar1 = data.fighter.avatar
        championCount1 = data.fighter.championCount
        avatar2 = remote.user.avatar
        championCount2 = remote.user.championCount
    end
    self._ccbOwner.team1Name:setString(name1)
    self._ccbOwner.team2Name:setString(name2)
    local head1 = QUIWidgetAvatar.new(avatar1)
    head1:setSilvesArenaPeak(championCount1)
    self._ccbOwner.team1Head:addChild(head1)
    local head2 = QUIWidgetAvatar.new(avatar2)
    head2:setSilvesArenaPeak(championCount2)
    head2:setScaleX(-1)
    self._ccbOwner.team2Head:addChild(head2)
end

function QUIDialogAgainstRecordDetail:setScoreList(data)
    if data.scoreList[1] ~= nil then
        local options = {}
        options.index = 1
        options.isWin = data.scoreList[1]
        options.heroFighter = data.replayInfo.fighter1
        options.heroAlternateFighter = data.replayInfo.userAlternateInfos
        options.heroSubFighter = data.replayInfo.sub1Fighter1
        options.heroSoulSpirit = data.replayInfo.team1HeroSoulSpirits
        options.enemyFighter = data.replayInfo.fighter2
        options.enemyAlternateFighter = data.replayInfo.enemyAlternateInfos
        options.enemySubFighter = data.replayInfo.sub1Fighter2
        options.enemySoulSpirit = data.replayInfo.team1EnemySoulSpirits
        options.heroGodarmList = data.replayInfo.team1GodarmList
        options.enemyGodarmList = data.replayInfo.team1EnemyGodarmList

        local fightWidget = QUIWidgetAgainstRecordDetail.new(options)
        self._ccbOwner.node_fight_1:addChild(fightWidget)
    end
    if data.scoreList[2] ~= nil then
        local options = {}
        options.index = 2
        options.isWin = data.scoreList[2]
        options.heroFighter = data.replayInfo.team2HeroInfoes
        options.heroSubFighter = data.replayInfo.team2Sub1Fighter1
        options.heroSoulSpirit = data.replayInfo.team2HeroSoulSpirits
        options.enemyFighter = data.replayInfo.team2Rivals
        options.enemySubFighter = data.replayInfo.team2Sub1Fighter2
        options.enemySoulSpirit = data.replayInfo.team2EnemySoulSpirits

        options.heroGodarmList = data.replayInfo.team2GodarmList
        options.enemyGodarmList = data.replayInfo.team2EnemyGodarmList

        local fightWidget = QUIWidgetAgainstRecordDetail.new(options)
        self._ccbOwner.node_fight_2:addChild(fightWidget)
    end
    if data.scoreList[3] ~= nil then
        local options = {}
        options.index = 3
        options.isWin = data.scoreList[3]
        if data.scoreList[1] == true then
            options.heroFighter = data.replayInfo.team2HeroInfoes
            options.heroSubFighter = data.replayInfo.team2Sub1Fighter1
            options.heroSoulSpirit = data.replayInfo.team2HeroSoulSpirits
            options.enemyFighter = data.replayInfo.fighter2
            options.enemySubFighter = data.replayInfo.sub1Fighter2
            options.enemySoulSpirit = data.replayInfo.team1EnemySoulSpirits
            options.heroGodarmList = data.replayInfo.team2GodarmList
            options.enemyGodarmList = data.replayInfo.team1EnemyGodarmList            
        else
            options.heroFighter = data.replayInfo.fighter1
            options.heroSubFighter = data.replayInfo.sub1Fighter1
            options.heroSoulSpirit = data.replayInfo.team1HeroSoulSpirits
            options.enemyFighter = data.replayInfo.team2Rivals
            options.enemySubFighter = data.replayInfo.team2Sub1Fighter2
            options.enemySoulSpirit = data.replayInfo.team2EnemySoulSpirits
            options.heroGodarmList = data.replayInfo.team1GodarmList
            options.enemyGodarmList = data.replayInfo.team2EnemyGodarmList            
        end
        local fightWidget = QUIWidgetAgainstRecordDetail.new(options)
        self._ccbOwner.node_fight_3:addChild(fightWidget)
    end
end

function QUIDialogAgainstRecordDetail:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogAgainstRecordDetail:_onTriggerClose()
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogAgainstRecordDetail