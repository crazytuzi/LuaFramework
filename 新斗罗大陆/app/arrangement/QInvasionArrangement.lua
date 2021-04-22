--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QInvasionArrangement = class("QInvasionArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")

function QInvasionArrangement:ctor(options)
	QInvasionArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.INVASION_TEAM)

    local maxLevel = QStaticDatabase:sharedDatabase():getIntrusionMaximumLevel(options.actorId)
    local level = math.min(options.level, maxLevel)
    local displayLevel = options.level

	self._rebelID = options.actorId
	self._rebelLevel = level
	self._rebelDisplayLevel = displayLevel
	self._rebelHP = options.hp
	self._type = options.type
	self._invasion = options.invasion
	self.token = options.token or 1
	self._attackPercent = options.type == 1 and 1 or 2.5
end

function QInvasionArrangement:startBattle(heroIdList)
	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("rebel")
	-- TOFIX: SHRINK
	config = q.cloneShrinkedObject(config)

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    remote.invasion:invasionStartRequest(self._type, self._invasion.userId, battleFormation, nil,
      	function(data) 
			self.super.setAllTeams(self, heroIdList)
			local invasion = remote.invasion:getSelfInvasion()
	        config.awards = data.awards
	        config.awards2 = data.awards2
	        config.teamName = self._teamKey
	        -- config.verifyKey = data.battleVerify
          	config.verifyKey = data.gfStartResponse.battleVerify
	        config.isInRebelFight = true
	        config.rebelID = self._rebelID
	        config.rebelLevel = self._rebelLevel
	        config.rebelDisplayLevel = self._rebelDisplayLevel
	        config.rebelHP =  data.gfStartResponse.intrusionFightStartResponse.bossHp
	        config.rebelAttackPercent = self._attackPercent 
	        config.rebelToken = self.token
	        config.rebelMeritRank = invasion.allHurtRank
	        config.rebelDamageRank = invasion.maxHurtRank
	        config.invasion = self._invasion
			config.heroRecords = remote.user.collectedHeros or {}
			config.rebelScoreRate = 1
			config.battleFormation = battleFormation or {}
			
		    local hour = q.date("%H", q.serverTime())
		    local value = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_HURT_DOUBLE"].value
		    local minHours = string.split(value,"#")
		    if tonumber(hour) >= tonumber(minHours[1]) and tonumber(hour) < tonumber(minHours[2]) then
		        config.rebelScoreRate = 2
		    end

    		self:_initDungeonConfig(config)

		  	if data.heros ~= nil then
		  		remote.teamManager:checkIsNoNeedHero(data.heros)
		  	end

       		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

	       	local loader = QDungeonResourceLoader.new(config)
       		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
       		remote.invasion:setAfterBattle(true)
  		end,function (data)
  			-- self._invasion.bossId = 0
  			-- remote.invasion:getInvasionRequest()
  			if data.error == "INTRUSION_BOSS_NOT_EXIST" then
  				self._invasion.bossId = 0 
  				remote.invasion:getInvasionRequest()
  			else
  				remote.invasion:setInvasionUpdate(true)
  			end
  		end)
end

-- test code for quick play
function QInvasionArrangement:startQuickBattle(success, fail)
	local heroIdList = self:_getHeroIdList()
	if not heroIdList or table.nums(heroIdList) == 0 then
        app.tip:floatTip("魂师大人，您没有出战阵容，无法扫荡～")
        return
    end
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    remote.invasion:invasionStartRequest(self._type, self._invasion.userId, battleFormation, nil,
      	function(data) 
			self.super.setAllTeams(self, heroIdList)
		  	
			remote.activity:updateLocalDataByType(531, 1)
			remote.user:addPropNumForKey("c_fortressFightCount")
       		remote.invasion:setAfterBattle(true)

            app.taskEvent:updateTaskEventProgress(app.taskEvent.INVATION_EVENT, 1, false, true) 

			local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("rebel")
			config = q.cloneShrinkedObject(config)

			local invasion = remote.invasion:getSelfInvasion()
		    config.awards = data.awards
		    config.awards2 = data.awards2
		    config.teamName = self._teamKey
		    -- config.verifyKey = data.battleVerify
        	config.verifyKey = data.gfStartResponse.battleVerify
		    config.isInRebelFight = true
		    config.rebelID = self._rebelID
		    config.rebelLevel = self._rebelLevel
		    config.rebelDisplayLevel = self._rebelDisplayLevel
		    config.rebelHP =  data.gfStartResponse.intrusionFightStartResponse.bossHp
		    config.rebelAttackPercent = self._attackPercent 
		    config.rebelToken = self.token
		    config.rebelMeritRank = invasion.allHurtRank
		    config.rebelDamageRank = invasion.maxHurtRank
		    config.invasion = self._invasion
			config.heroRecords = remote.user.collectedHeros or {}
			config.rebelScoreRate = 1
			config.battleFormation = battleFormation or {}

		    local hour = q.date("%H", q.serverTime())
		    local value = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_HURT_DOUBLE"].value
		    local minHours = string.split(value,"#")
		    if tonumber(hour) >= tonumber(minHours[1]) and tonumber(hour) < tonumber(minHours[2]) then
		        config.rebelScoreRate = 2
		    end

            self:_initDungeonConfig(config)

            if data.heros ~= nil then
		  		remote.teamManager:checkIsNoNeedHero(data.heros)
		  	end

			local buffer = self:_createReplayBuffer(config, data)
			writeToBinaryFile("last.reppb", buffer)

			remote.invasion:invasionEndRequest(nil, config.invasion.userId, data.gfStartResponse.battleVerify, true, success, fail)
  		end,function (data)
  			if data.error == "INTRUSION_BOSS_NOT_EXIST" then
  				self._invasion.bossId = 0 
  				remote.invasion:getInvasionRequest()
  			else
  				remote.invasion:setInvasionUpdate(true)
  			end
  		end)
end

-- test code for quick play
function QInvasionArrangement:startFastFight(autoConsumeToken, isAllOut, autoShare, success, fail)
	local heroIdList = self:_getHeroIdList()
	if not heroIdList or table.nums(heroIdList) == 0 then
        app.tip:floatTip("魂师大人，您没有出战阵容，无法扫荡～")
        return
    end
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    remote.invasion:invasionStartRequest(self._type, self._invasion.userId, battleFormation, nil,
      	function(data) 
			self.super.setAllTeams(self, heroIdList)
		  	
       		remote.invasion:setAfterBattle(true)

			local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("rebel")
			config = q.cloneShrinkedObject(config)

			local invasion = remote.invasion:getSelfInvasion()
		    config.awards = data.awards
		    config.awards2 = data.awards2
		    config.teamName = self._teamKey
		    -- config.verifyKey = data.battleVerify
        	config.verifyKey = data.gfStartResponse.battleVerify
		    config.isInRebelFight = true
		    config.rebelID = self._rebelID
		    config.rebelLevel = self._rebelLevel
		    config.rebelDisplayLevel = self._rebelDisplayLevel
		    config.rebelHP =  data.gfStartResponse.intrusionFightStartResponse.bossHp
		    config.rebelAttackPercent = self._attackPercent 
		    config.rebelToken = self.token
		    config.rebelMeritRank = invasion.allHurtRank
		    config.rebelDamageRank = invasion.maxHurtRank
		    config.invasion = self._invasion
			config.heroRecords = remote.user.collectedHeros or {}
			config.rebelScoreRate = 1

		    local hour = q.date("%H", q.serverTime())
		    local value = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_HURT_DOUBLE"].value
		    local minHours = string.split(value,"#")
		    if tonumber(hour) >= tonumber(minHours[1]) and tonumber(hour) < tonumber(minHours[2]) then
		        config.rebelScoreRate = 2
		    end

            self:_initDungeonConfig(config)

            if data.heros ~= nil then
		  		remote.teamManager:checkIsNoNeedHero(data.heros)
		  	end

			local buffer = self:_createReplayBuffer(config, data)
			writeToBinaryFile("last.reppb", buffer)

			remote.invasion:invasionFastFightEndRequest(self._invasion.userId, autoConsumeToken, isAllOut, autoShare, data.gfStartResponse.battleVerify, success, fail)
  		end,function (data)
  			if data.error == "INTRUSION_BOSS_NOT_EXIST" then
  				self._invasion.bossId = 0 
  				remote.invasion:getInvasionRequest()
  			else
  				remote.invasion:setInvasionUpdate(true)
  			end
  		end)
end

-- test code for quick play
function QInvasionArrangement:makeFightReportData( callback )
		local heroIdList = self:_getHeroIdList()
		if not heroIdList or table.nums(heroIdList) == 0 then
			app.tip:floatTip("魂师大人，您没有出战阵容，无法扫荡～")
			return
		end
		local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)

		remote.invasion:invasionStartRequest(self._type, self._invasion.userId, battleFormation, true, function(data) 
			self.super.setAllTeams(self, heroIdList)
			-- remote.activity:updateLocalDataByType(531, 1)
			-- remote.user:addPropNumForKey("c_fortressFightCount")
			remote.invasion:setAfterBattle(true)

			local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("rebel")
			-- TOFIX: SHRINK
			config = q.cloneShrinkedObject(config)
			local invasion = remote.invasion:getSelfInvasion()
			-- config.verifyKey = data.battleVerify
			config.isInRebelFight = true
			config.rebelID = self._rebelID
			config.rebelLevel = self._rebelLevel
			config.rebelDisplayLevel = self._rebelDisplayLevel
			-- config.rebelHP =  data.intrusionFightStartResponse.bossHp
			config.rebelAttackPercent = self._attackPercent 
			config.rebelToken = self._token
			config.rebelMeritRank = invasion.allHurtRank
			config.rebelDamageRank = invasion.maxHurtRank
			config.invasion = self._invasion
			config.heroRecords = remote.user.collectedHeros or {}
			config.teamName = self._teamKey
			
			self:_initDungeonConfig(config)
			local buffer = self:_createReplayBuffer(config)
			writeToBinaryFile("last.reppb", buffer)

			if callback then
				callback(battleFormation, data.gfStartResponse.battleVerify)
			end
		end)
end

function QInvasionArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

function QInvasionArrangement:checkTeamIsEmpty(callback)
	local heroIdList = self:_getHeroIdList()
	if not self:teamValidity(heroIdList[1].actorIds) then
 		-- print("全是治疗")
 		return true
 	end
 	
	local mainTeamHeros = heroIdList[1].actorIds or {}
	local helpTeamHeros = heroIdList[2].actorIds or {}
	local helpTeamHeros2 = heroIdList[3].actorIds or {}
	local helpTeamHeros3 = heroIdList[4].actorIds or {}
 	local mainTeamNum = #mainTeamHeros
 	local helpTeamNum = #helpTeamHeros
 	local helpTeamNum2 = #helpTeamHeros2
 	local helpTeamNum3 = #helpTeamHeros3
 	
 	local totalTeamNum = mainTeamNum + helpTeamNum + helpTeamNum2 + helpTeamNum3
 	local heros = remote.herosUtil:getHaveHero()
 	local teamVO = remote.teamManager:getTeamByKey(self:getTeamKey(), false)
  	local mainMaxNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
  	if mainTeamNum < mainMaxNum and #heros - totalTeamNum > 0 then
		app:alert({content = string.format("有主力魂师未上阵，确定吗？"), title = "系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				callback()
			end
		end}, true, true)
		return true
  	end

  	local helpMaxNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_HELP)
  	local helpMaxNum2 = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_HELP2)
  	local helpMaxNum3 = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_HELP3)
  	if (helpTeamNum < helpMaxNum) or (helpTeamNum2 < helpMaxNum2) or (helpTeamNum3 < helpMaxNum3) and #heros - totalTeamNum > 0 then
		app:alert({content = string.format("有援助魂师未上阵，确定开始战斗吗？", numStr), title = "系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				callback()
			end
		end}, true, true)
		return true
  	end
	return false
end

function QInvasionArrangement:_getHeroIdList()
  local actorIds = self:getExistingHeroes()
  if #actorIds == 0 then
    local teams = remote.teamManager:getDefaultTeam(remote.teamManager.INSTANCE_TEAM)
    remote.teamManager:updateTeamData(self:getTeamKey(), teams)
  end
  local teamVO = remote.teamManager:getTeamByKey(self:getTeamKey(), false)
  return teamVO:getAllTeam()
end

function QInvasionArrangement:_initHero(availableHeroIDs, existingHeros)
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

return QInvasionArrangement
