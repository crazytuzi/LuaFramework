-- @Author: xurui
-- @Date:   2018-11-18 17:56:41
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-05-27 16:54:50
local QBattleDialog = import(".QBattleDialog")
local QPVPMultipleFightInfo = class("QPVPMultipleFightInfo", QBattleDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetAgainstRecordDetail = import("..widgets.QUIWidgetAgainstRecordDetail")

QPVPMultipleFightInfo.PAGE_MARGIN = 40
QPVPMultipleFightInfo.EVENT_RESPOND_IGNORE = 0.3
local REPLAY_CD_LIMIT = "%d分钟内只允许发送%d条战报，%s后可以发送"
local REPLAY_CD = 5 -- 5m
local REPLAY_COUNT = 5

function QPVPMultipleFightInfo:ctor(options)
    local ccbFile = "ccb/Dialog_StormArena_battlerecordinfo.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QPVPMultipleFightInfo._onTriggerClose)},
    }

    --设置该节点启用enter事件
    self:setNodeEventEnabled(true)
    QPVPMultipleFightInfo.super.ctor(self,ccbFile, {}, callBacks)

    self:_initData(options.info)

    if options.replayType == REPORT_TYPE.STORM_ARENA then
        self:setStormArenaScoreList(options.info)
    else
        self:setScoreList(options.info)
    end
end

function QPVPMultipleFightInfo:_initData(data)
  
    self._ccbOwner.team1Score1:setDisplayFrame(QSpriteFrameByPath(QResPath("StormArena_S")[data.attackScore+1]))
    self._ccbOwner.team2Score2:setDisplayFrame(QSpriteFrameByPath(QResPath("StormArena_S")[data.defenseScore+1]))      
    local meAsDefense = false
    if data.result == (data.attackScore < data.defenseScore) then
        meAsDefense = true
    end
    local me = meAsDefense and "right" or "left"
    local rival = meAsDefense and "left" or "right"
    -- local teams = meAsDefense and remote.teamManager:getAllTeams(remote.teamManager.STORM_ARENA_DEFEND_TEAM) or remote.teamManager:getAllTeams(remote.teamManager.STORM_ARENA_ATTACK_TEAM)
    local meNickName = tostring(remote.user.nickname)
    local rivalNickName = tostring(data.name)
    local meAvatar = remote.user.avatar
    local rivalAvatar = data.avatar
    if meAsDefense then
        self._ccbOwner.team2Name:setString(meNickName)
        self._ccbOwner.team1Name:setString(rivalNickName)
        local head1 = QUIWidgetAvatar.new(meAvatar)
        head1:setSilvesArenaPeak(remote.user.championCount)
        self._ccbOwner.team2Head:addChild(head1)
        local head2 = QUIWidgetAvatar.new(rivalAvatar)
        head2:setSilvesArenaPeak(data.championCount)
        self._ccbOwner.team1Head:addChild(head2)
    else
        self._ccbOwner.team1Name:setString(meNickName)
        self._ccbOwner.team2Name:setString(rivalNickName)
        local head1 = QUIWidgetAvatar.new(meAvatar)
        head1:setSilvesArenaPeak(remote.user.championCount)
        self._ccbOwner.team1Head:addChild(head1)
        local head2 = QUIWidgetAvatar.new(rivalAvatar)
        head2:setSilvesArenaPeak(data.championCount)
        self._ccbOwner.team2Head:addChild(head2)
    end
end

function QPVPMultipleFightInfo:setScoreList(data)
    if data.scoreList[1] ~= nil then
        local options = {}
        options.index = 1
        options.isWin = data.scoreList[1]
        options.heroFighter = data.replayInfo.fighter1 and data.replayInfo.fighter1[i]
        options.heroSubFighter = data.replayInfo.sub1Fighter1
        options.enemyFighter = data.replayInfo.fighter2 and data.replayInfo.fighter2[i]
        options.enemySubFighter = data.replayInfo.sub1Fighter2

        local fightWidget = QUIWidgetAgainstRecordDetail.new(options)
        self._ccbOwner.node_fight_1:addChild(fightWidget)
    end
    if data.scoreList[2] ~= nil then
        local options = {}
        options.index = 2
        options.isWin = data.scoreList[2]
        options.heroFighter = data.replayInfo.sub1Fighter1 and data.replayInfo.sub1Fighter1[i]
        options.heroSubFighter = data.replayInfo.team2Sub1Fighter1
        options.enemyFighter = data.replayInfo.sub1Fighter2 and data.replayInfo.sub1Fighter2[i]
        options.enemySubFighter = data.replayInfo.team2Sub1Fighter2
        
        local fightWidget = QUIWidgetAgainstRecordDetail.new(options)
        self._ccbOwner.node_fight_2:addChild(fightWidget)
    end
    if data.scoreList[3] ~= nil then
        local options = {}
        options.index = 2
        options.isWin = data.scoreList[2]
        options.heroFighter = data.replayInfo.sub2Fighter1 and data.replayInfo.sub2Fighter1[i]
        options.heroSubFighter = data.replayInfo.team2Sub1Fighter1
        options.enemyFighter = data.replayInfo.sub2Fighter2 and data.replayInfo.sub2Fighter2[i]
        options.enemySubFighter = data.replayInfo.team2Sub1Fighter2
        
        local fightWidget = QUIWidgetAgainstRecordDetail.new(options)
        self._ccbOwner.node_fight_3:addChild(fightWidget)
    end
end

function QPVPMultipleFightInfo:setStormArenaScoreList(data)
    if data.scoreList[1] ~= nil then
        local options = {}
        options.index = 1
        options.isWin = data.scoreList[1]
        options.heroFighter = data.replayInfo.fighter1
        options.heroSubFighter = data.replayInfo.sub1Fighter1
        options.enemyFighter = data.replayInfo.fighter2
        options.enemySubFighter = data.replayInfo.sub1Fighter2

        local fightWidget = QUIWidgetAgainstRecordDetail.new(options)
        self._ccbOwner.node_fight_1:addChild(fightWidget)
    end
    if data.scoreList[2] ~= nil then
        local options = {}
        options.index = 2
        options.isWin = data.scoreList[2]
        options.heroFighter = data.replayInfo.team2HeroInfoes
        options.heroSubFighter = data.replayInfo.team2Sub1Fighter1
        options.enemyFighter = data.replayInfo.team2Rivals
        options.enemySubFighter = data.replayInfo.team2Sub1Fighter2
        
        local fightWidget = QUIWidgetAgainstRecordDetail.new(options)
        self._ccbOwner.node_fight_2:addChild(fightWidget)
    end
    if data.scoreList[3] ~= nil then
        local options = {}
        options.index = 3
        options.isWin = data.scoreList[3]
        options.heroFighter = data.replayInfo.fighter1
        options.heroSubFighter = data.replayInfo.sub1Fighter1
        options.enemyFighter = data.replayInfo.team2Rivals
        options.enemySubFighter = data.replayInfo.team2Sub1Fighter2
        if data.scoreList[1] == true then
            options.heroFighter = data.replayInfo.team2HeroInfoes
            options.heroSubFighter = data.replayInfo.team2Sub1Fighter1
            options.enemyFighter = data.replayInfo.fighter2
            options.enemySubFighter = data.replayInfo.sub1Fighter2
        end
        local fightWidget = QUIWidgetAgainstRecordDetail.new(options)
        self._ccbOwner.node_fight_3:addChild(fightWidget)
    end
end

function QPVPMultipleFightInfo:getTeamHeros(mainHeros, helpHeros)
    local heros = {}
    if mainHeros then
        for _, value in ipairs(mainHeros) do
            heros[#heros+1] = value
        end
    end
    if helpHeros then
        for _, value in ipairs(helpHeros) do
            heros[#heros+1] = value
        end
    end

    return heros
end

function QPVPMultipleFightInfo:_backClickHandler()
	self:_onTriggerClose()
end

function QPVPMultipleFightInfo:_onTriggerClose()
    app.sound:playSound("common_cancel")
    self:_close()
end

function QPVPMultipleFightInfo:_close()
    QPVPMultipleFightInfo.super.close(self)
end

return QPVPMultipleFightInfo
