-- @Author: zhouxiaoshu
-- @Date:   2019-08-29 19:24:53
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-09-09 12:34:17
--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QSunwarSecretaryArrangement = class("QSunwarSecretaryArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QUIWidget = import("..ui.widgets.QUIWidget")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")

QSunwarSecretaryArrangement.MIN_LEVEL = 0

function QSunwarSecretaryArrangement:ctor(options)
	local heroIdList = {}
	for k, v in ipairs(remote.herosUtil:getHaveHero()) do
		if remote.herosUtil:getHeroByID(v).level >= QSunwarSecretaryArrangement.MIN_LEVEL then
			table.insert(heroIdList, v)
		end
	end

	QSunwarSecretaryArrangement.super.ctor(self, heroIdList, options.teamKey or remote.teamManager.SUNWAR_ATTACK_TEAM)

	self._dungeonInfo = options.dungeonInfo
	self._callback = options.callback
	self._force = remote.herosUtil:getMostHeroBattleForce(true) or 0
end

function QSunwarSecretaryArrangement:viewDidAppear()
	remote.sunWar:addBuff(true, "SunwarArrangement")
end

function QSunwarSecretaryArrangement:viewWillDisappear()
	remote.sunWar:removeBuff(true, "SunwarArrangement")
end

-- Sunwell team arrangement needs to show hero states to decide if can go on fighting
function QSunwarSecretaryArrangement:showHeroState()
	return true
end

function QSunwarSecretaryArrangement:availableHeroPrompt( ... )
	return false
end

function QSunwarSecretaryArrangement:startBattle(heroIdList)
	self.super.setAllTeams(self, heroIdList)
	if self._callback then
		self._callback()
	end
end

function QSunwarSecretaryArrangement:startAutoFight(success, fail)
	local heroIdList = self:_getHeroIdList()
    if self:teamValidity(heroIdList[1].actorIds) == false then
    	fail()
        return
    end

	local isAllDead = true
	for _, actorId in pairs(heroIdList[1].actorIds) do
        local heroInfo = remote.sunWar:getMyHeroInfoByActorID(actorId)
        if heroInfo == nil or heroInfo.currHp == nil or heroInfo.currHp > -1 then
            isAllDead = false
            break
        end
    end
    if isAllDead then
    	app.tip:floatTip("魂师大人，当前上阵魂师已经死亡，请调整魂师或者复活他们继续战斗~")
    	fail()
    	return 
    end

    self:autoFightEnd(heroIdList, success, fail)
end

function QSunwarSecretaryArrangement:autoFightEnd(heroIdList, success, fail)
	local fightWave = remote.sunWar:getCurrentWaveID()
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)

	app:getClient():sunwarFightStartRequest(fightWave, battleFormation,
		function (data)
			remote.sunWar:responseHandler(data)
			if self._teamKey == remote.teamManager.SUNWAR_ATTACK_TEAM then
				local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SUNWAR_ATTACK_SECOND_TEAM, false)
				if teamVO ~= nil then
					teamVO:setTeamData(heroIdList)
				end
			end
			self.super.setAllTeams(self, heroIdList)
			local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("sunwell")
	        -- config.verifyKey = data.battleVerify
	        config.verifyKey = data.gfStartResponse.battleVerify
			config.isPVPMode = true
			config.isSunwell = true

			config.team1Name = remote.user.nickname
			config.team1Icon = remote.user.avatar
			if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
				config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
			end
			config.team2Name = self._dungeonInfo.name
			config.team2Icon = self._dungeonInfo.avatar
			if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
				config.team2Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
			end

			config.dungeonInfo = self._dungeonInfo
			config.myTeam = heroIdList[1]
	        config.teamName = self._teamKey
	        config.fightWave = fightWave
			config.forceAuto = true
			config.heroRecords = remote.user.collectedHeros or {}
			config.pvpRivalHeroRecords = self._dungeonInfo.collectedHero or {}

			-- 战场技能
			config.heroSkillBonuses = self._dungeonInfo.heroSkillBonuses or {}

    		self:_initDungeonConfig(config, self._dungeonInfo)
		    for actorId, heroInfoInSunwell in pairs(remote.sunWar:getMyHeroInfo()) do
		    	for i, heroInfo in ipairs(config.heroInfos) do
		    		heroInfo = clone(heroInfo)
		    		config.heroInfos[i] = heroInfo
		    		if heroInfo.actorId == actorId then
		    			heroInfo.heroInfoInSunwell = clone(heroInfoInSunwell)
		    			heroInfo.heroInfoInSunwell.actorId = nil
		    			break
		    		end
		    	end
		    	for i, souSpiritInfo in ipairs(config.userSoulSpirits or {}) do
		    		if souSpiritInfo.id == actorId then
		    			config.userSoulSpirits[i].currMp = heroInfoInSunwell.currMp
		    			break
		    		end
		    	end
		    end

			config.force = self._force
			config.sunwarChapter = remote.sunWar:getCurrentMapID()
			config.sunwarWave = remote.sunWar:getCurrentWaveID()
			config.sunwarTodayPassedWaveCount = #(remote.sunWar:getTodayPassedWaves() or {})
			config.sunwarBonusForDefender = self._dungeonInfo.battleFieldBonus

			remote.user:update({sunwarLastFightAt = q.serverTime() * 1000})

			-- 保存战报至last.reppb
			local buffer, record = self:_createReplayBuffer(config)
			writeToBinaryFile("last.reppb", buffer)

		    app:getClient():sunwarFightEndRequest(nil, {}, {}, config.verifyKey, config.fightWave, true, true, function (data)
		        remote.sunWar:responseHandler(data)
		   		if success then
		   			success(data)
		   		end

		    end, function(data)
		   		if fail then
		   			fail(data)
		   		end
		    end)
	 	end,
	 	function ()
			if fail then
	   			fail(data)
	   		end
		end
	)
end


function QSunwarSecretaryArrangement:_getHeroIdList()
	local teamVO = remote.teamManager:getTeamByKey(self:getTeamKey(), false)

	return teamVO:getAllTeam()
end

function QSunwarSecretaryArrangement:getPrompt()
	return QSunwarSecretaryArrangement.MIN_LEVEL.."级以上魂师方可参加海神岛战斗"
end

--获取魂师状态
function QSunwarSecretaryArrangement:getHeroInfoById(actorId)
	return remote.sunWar:getMyHeroInfoByActorID(actorId)
end

function QSunwarSecretaryArrangement:getMaxHp(maxHp)
    local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
    if globalConfig.SUNWELL_MAX_HEALTH_COEFFICIENT ~= nil and globalConfig.SUNWELL_MAX_HEALTH_COEFFICIENT.value ~= nil then
        maxHp = maxHp * globalConfig.SUNWELL_MAX_HEALTH_COEFFICIENT.value 
    end
    return maxHp
end

function QSunwarSecretaryArrangement:getHeroes()
	local heroIdList = {}
	for k, v in ipairs(remote.herosUtil:getHaveHero()) do
		if remote.herosUtil:getHeroByID(v).level >= QSunwarSecretaryArrangement.MIN_LEVEL then
			table.insert(heroIdList, v)
		end
	end
	return heroIdList
end

return QSunwarSecretaryArrangement

