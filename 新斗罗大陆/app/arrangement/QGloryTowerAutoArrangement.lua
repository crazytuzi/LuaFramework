--
-- Author: Kumo
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QGloryTowerAutoArrangement = class("QGloryTowerAutoArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")


function QGloryTowerAutoArrangement:ctor(options)
	QGloryTowerAutoArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.GLORY_TEAM)

	self._rivalInfo = options.rivalInfo
	self._towerData = options.towerData
	self._callback = options.callback
	self._isReady = false
	self._config = {}
	self:_checkTeamReady()
end

function QGloryTowerAutoArrangement:isReady()
	return self._isReady
end

function QGloryTowerAutoArrangement:getConfig()
	return self._config 
end

function QGloryTowerAutoArrangement:_checkTeamReady()
	local heroIdList = self:_getHeroIdList()
	if not heroIdList or table.nums(heroIdList) == 0 then
        app.tip:floatTip("魂师大人，您没有出战阵容，自动战斗功能无法使用～")
        if self._callback then
			self._callback()
		end
        return
    end
    local teamVO = remote.teamManager:getTeamByKey(self:getTeamKey(), false)
	local soulMaxNum = teamVO:getSpiritsMaxCountByIndex(1)
    if soulMaxNum > 0 and heroIdList[1].spiritIds ~= nil and #heroIdList[1].spiritIds < soulMaxNum then
        app:alert({content="有主力魂灵未上阵，确定开始战斗吗？",title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
				self:_makeReplayBuffer(heroIdList)
			else
				if self._callback then
					self._callback()
				end
            end
        end})
    else
    	self:_makeReplayBuffer(heroIdList)
    end
end

function QGloryTowerAutoArrangement:_makeReplayBuffer(heroIdList)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	self._config.battleFormation = battleFormation
	self.super.setAllTeams(self, heroIdList)

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("tower")
	config.isPVPMode = true
	config.isArena = true
	config.isGlory = true

	config.team1Name = remote.user.nickname
	config.team1Icon = remote.user.avatar
	if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
		config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end
	config.team2Name = self._rivalInfo.name
	config.team2Icon = self._rivalInfo.avatar
	if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
		config.team2Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end

	config.teamName = self._teamKey
	-- config.pvp_archaeology = self._rivalInfo.apiArchaeologyInfoResponse
	config.rivalsInfo = self._rivalInfo
	config.selfHeros = heroIdList[1].actorIds
	config.score = self._towerData.score
	config.towerMoney = remote.user.towerMoney
	config.token = remote.user.token
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}
	config.rivalId = self._rivalInfo.userId
	-- config.myInfo = self._myInfo
	
	config.battleDT = 1 / 30
	config.battleFormation = battleFormation
	config.forceAuto = true
    
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}

    self:_initDungeonConfig(config, self._rivalInfo)

    self._config = config

	local buffer, record = self:_createReplayBuffer(config)
	writeToBinaryFile("last.reppb", buffer)
	self._isReady = true
	remote.tower:towerFightStartRequest(self._rivalInfo.userId, battleFormation, 
        function(data) 
            self:onAutoFighterHandlerEnd(data.gfStartResponse.battleVerify)
        end, function()
        	if self._callback then
				self._callback()
			end
	    end)
end


function QGloryTowerAutoArrangement:onAutoFighterHandlerEnd(battleVerifyKey)
    print("[Kumo] 战报已经生成完毕！")
    local fighterInfo = {}
    local selfInfo = {}
    for _,value in pairs(self._rivalInfo.heros) do
        local result = {actor_id = value.actorId, showed_at = 10, died_at = 50}
        table.insert(fighterInfo, result)
    end
    for _,actorId in pairs(self._config.selfHeros) do
        local result = {actor_id = actorId, showed_at = 10, died_at = nil}
        table.insert(selfInfo, result)
    end

    local myInfo = {name = remote.user.nickname, avatar = remote.user.avatar, level = remote.user.level}
    myInfo.heros = self:_constructGloryAttackHero()

    local oldTowerMoney = remote.user.towerMoney
    local oldTowerScore = remote.tower:getTowerInfo().score
    remote.tower:setOldTowerFloor(remote.tower:getTowerInfo().floor)
    --分数显示
    if self._towerData.score then
        self._oldScore = self._towerData.score
    end
    local battleFormation = self._config.battleFormation
    remote.tower:towerFightEndRequest(self._rivalInfo.userId, {selfHerosStatus = selfInfo, rivalHerosStatus = fighterInfo}, {}, battleVerifyKey, true, battleFormation, function (data)
            local isWin = 1
            if data.isTowerFightWin or data.gfEndResponse.isWin then
                isWin = 1
                local addScore = remote.tower:getTowerInfo().score - oldTowerScore
                if addScore < 0 then addScore = 0 end
                local addTowerMoney = remote.user.towerMoney - oldTowerMoney
                if addTowerMoney < 0 then addTowerMoney = 0 end
                local bonusTbl = self:_getBonusAward(data.gfEndResponse.towerFightEndResponse.fightAward)
                local awards = {}
                local bonusAwards = {}

                if data.extraExpItem and type(data.extraExpItem) == "table" then
                    for _, value in pairs(data.extraExpItem or {}) do
                        table.insert(awards, {id = value.id or 0, typeName = value.type, count = value.count or 0})
                    end
                end
                if addTowerMoney > 0 then
                    table.insert(awards, {id = nil, typeName = ITEM_TYPE.TOWER_MONEY, count = addTowerMoney})
                end
                if bonusTbl then
                    if tonumber(bonusTbl[1]) then
                        table.insert(bonusAwards, {id = bonusTbl[1], typeName = ITEM_TYPE.ITEM, count = bonusTbl[2]})
                    else
                        table.insert(bonusAwards, {id = nil, typeName = bonusTbl[1], count = bonusTbl[2]})
                    end
                end

                remote.user:update(data.wallet)
                if data.items then remote.items:setItems(data.items) end
                local activityYield = remote.activity:getActivityMultipleYield(611)
                local userComeBackRatio = data.userComeBackRatio or 1
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWin", 
                    options = {awards = awards, bonusAwards = bonusAwards, addScore = addScore, activityYield = activityYield, userComeBackRatio = userComeBackRatio, callback = function()
                        if self._callback then
							self._callback()
						end
                    end}}, {isPopCurrentDialog = true})
            else
                isWin = 2
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogLose", options = {callback = function()
                       	if self._callback then
							self._callback()
						end
                    end}}, {isPopCurrentDialog = true})
            end
            local replayInfo = QReplayUtil:generateReplayInfo(myInfo, self._rivalInfo, isWin, remote.teamManager.GLORY_TEAM)
            QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, nil, nil, REPORT_TYPE.GLORY_TOWER)   
        end, function(data)
            local errorCode = QStaticDatabase:sharedDatabase():getErrorCode(data.error)
            local errorStr = "很遗憾，本次战斗数据出错！"
            if errorCode ~= nil then
                errorStr = errorCode.desc or errorStr
            end
            if self._callback then
				self._callback()
			end
            app:alert({content = errorStr, title = "系统提示"}, nil, true)
        end)
end

function QGloryTowerAutoArrangement:_constructGloryAttackHero()
    local attackHeroInfo = {}
    for k, v in ipairs(remote.teamManager:getActorIdsByKey(remote.teamManager.GLORY_TEAM, remote.teamManager.TEAM_INDEX_MAIN)) do
        local heroInfo = remote.herosUtil:getHeroByID(v)
        table.insert(attackHeroInfo, heroInfo)
    end

    return attackHeroInfo
end

function QGloryTowerAutoArrangement:_getBonusAward( awardStr )
    if not awardStr or awardStr == "" then return nil end
    local tbl = string.split(awardStr, "^")
    return tbl
end


function QGloryTowerAutoArrangement:_getHeroIdList()
	local actorIds = self:getExistingHeroes()
	if #actorIds == 0 then
		local teams = remote.teamManager:getDefaultTeam(remote.teamManager.INSTANCE_TEAM)
		remote.teamManager:updateTeamData(self:getTeamKey(), teams)
	end
	local teamVO = remote.teamManager:getTeamByKey(self:getTeamKey(), false)

    if remote.godarm:checkGodArmUnlock() then
        local godarmIds = teamVO:getTeamGodarmByIndex(remote.teamManager.TEAM_INDEX_GODARM)
        for _, godarmId in ipairs(godarmIds) do
            local godarmInfo = remote.godarm:getGodarmById(godarmId) or {}
            if q.isEmpty(godarmInfo) then
                teamVO:delGodarmsIndex(remote.teamManager.TEAM_INDEX_GODARM, godarmId)
            end
        end
    end
            
	return teamVO:getAllTeam()
end

function QGloryTowerAutoArrangement:_checkHelpSkill(help, skill)
    if help == nil or help[1] == nil then 
        return nil
    end

    local haveSkillHero = false
    for _, value in pairs(help) do
        if value == skill then
            haveSkillHero = true
            break
        end
    end
    if haveSkillHero then
        return skill
    else
        return help[1]
    end
end

function QGloryTowerAutoArrangement:_initHero(availableHeroIDs, existingHeros)
    local availableHero = {}

    for i, actorId in pairs(availableHeroIDs) do
        local characher = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)

        local heroType = 1
        local hatred = characher.hatred
        if characher.func == 't' then
            heroType = 't'
        elseif characher.func == 'health' then
            heroType = 'h'
        elseif characher.func == 'dps' and characher.attack_type == 1 then
            heroType = 'pd'
        elseif characher.func == 'dps' and characher.attack_type == 2 then
            heroType = 'md'
        end
        availableHero[actorId] = {actorId = actorId, type = heroType, hatred = hatred, index = 0, force = remote.herosUtil:createHeroPropById(actorId):getBattleForce(true)}
        -- availableHero[actorId].arrangement = self._arrangement
    end

    if existingHeros then
        for index,teams in pairs(existingHeros) do
            if index ~= 3 and index ~= 5 then  -- 第三、五个保存的是技能槽
                for k, v in ipairs(teams) do
                    if availableHero[v] then
                        availableHero[v].index = index
                    end
                end
            end
        end
    end

    return availableHero
end

return QGloryTowerAutoArrangement
