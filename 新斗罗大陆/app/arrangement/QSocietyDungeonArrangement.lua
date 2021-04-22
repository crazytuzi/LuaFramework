--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QSocietyDungeonArrangement = class("QSocietyDungeonArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QUIWidget = import("..ui.widgets.QUIWidget")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")

function QSocietyDungeonArrangement:ctor(options)
	local heroIdList = {}
	for k, v in ipairs(remote.herosUtil:getHaveHero()) do
		table.insert(heroIdList, v)
	end
	QSocietyDungeonArrangement.super.ctor(self, heroIdList, options.teamKey or remote.teamManager.SOCIETYDUNGEON_ATTACK_TEAM)

	-- self._dungeonInfo = options.dungeonInfo
	self._chapter = options.chapter
	self._wave = options.wave
	self._bossId = options.bossId
	self._bossLevel = options.bossLevel
	self._bossHp = options.bossHp
	self._societyDungeonBuffList = {}
	self._robotCount = options.robotCount

	for _, buffId in pairs(options.activityBuffList or {}) do
		table.insert(self._societyDungeonBuffList, buffId)
	end

	if options.little_monster then
		self._little_monster = string.split(options.little_monster, ",")
		for i, id in ipairs(self._little_monster) do
			self._little_monster[i] = tonumber(id)
		end
	else
		self._little_monster = {}
	end
	self._force = remote.herosUtil:getMostHeroBattleForce(true) or 0
end

function QSocietyDungeonArrangement:startBattle(heroIdList)
	assert(ENABLE_UNION_DUNGEON == true or ENABLE_UNION_DUNGEON == nil, "宗门副本功能暂时不开放！")

	local mainActorIds = heroIdList[1]
	local subActorIds = heroIdList[2] or {}
	local activeSubActorId = heroIdList[3] and (heroIdList[3][1] or nil) or nil


	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.union:unionFightStartRequest(self._wave, self._chapter, battleFormation,
		function (data)
			self.super.setAllTeams(self, heroIdList)
			local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("rebel")
			config.bg = "map/gonghui_map.jpg"
	        -- config.verifyKey = data.battleVerify
	        config.verifyKey = data.gfStartResponse.battleVerify
			config.isPVPMode = false
			config.isSocietyDungeon = true

			local societyChapter = QStaticDatabase:sharedDatabase():getScoietyWave(self._wave, self._chapter)
			if societyChapter.color_type == 1 then
				config.bg = "ccb/map/gonghui.ccbi"
			elseif societyChapter.color_type == 2 then
				config.bg = "ccb/map/gonghui_yellow.ccbi"
			elseif societyChapter.color_type == 3 then
				config.bg = "ccb/map/gonghui_blue.ccbi"
			elseif societyChapter.color_type == 4 then
				config.bg = "ccb/map/gonghui_green.ccbi"
			end

			config.team1Name = remote.user.nickname
			config.team1Icon = remote.user.avatar
			if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
				config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
			end
			
			config.myTeam = heroIdList[1]
	        config.teamName = self._teamKey
	        config.consortiaMoney = remote.user.consortiaMoney
	        config.token = remote.user.token
	        
			config.heroRecords = remote.user.collectedHeros or {}

			config.force = self._force
			config.societyDungeonChapter = self._chapter
			config.societyDungeonWave = self._wave
			config.societyDungeonBossID = self._bossId
			config.societyDungeonBossLevel = self._bossLevel
			config.societyDungeonBossHp = self._bossHp
			config.societyDungeonLittleMonster = self._little_monster
			config.societyDungeonBuffList = self._societyDungeonBuffList
			config.battleFormation = battleFormation or {}

			config.isPlayerComeback = remote.playerRecall:isOpen()

			local isFinalBoss = remote.union:checkIsFinalWave(self._chapter, self._wave)
			if isFinalBoss then
				config.boss_hp_infinite = true
			end

    		self:_initDungeonConfig(config)

			remote.user:update({societyDungeonLastFightAt = q.serverTime() * 1000})

	   		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	   		-- app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	   		
	   		remote.union:setSocietyDungeonFightInfo(true, self._wave, self._chapter)
	       	local loader = QDungeonResourceLoader.new(config)
   			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}}) 
		end,function ()
		end
		)
end

-- test code for quick play
function QSocietyDungeonArrangement:startQuickBattle(success, fail, isSecretary)
	local heroIdList = self:_getHeroIdList()
    if not heroIdList or table.nums(heroIdList) == 0 then
        app.tip:floatTip("魂师大人，您没有出战阵容，无法扫荡～")
        return
    end

	self:doQuickBattle(heroIdList, success, fail, isSecretary)
end

function QSocietyDungeonArrangement:doQuickBattle(heroIdList, success, fail, isSecretary)
	local mainActorIds = heroIdList[1]
	local subActorIds = heroIdList[2] or {}
	local activeSubActorId = heroIdList[3] and (heroIdList[3][1] or nil) or nil

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    remote.union:unionFightStartRequest(self._wave, self._chapter, battleFormation,
      	function(data) 
			self.super.setAllTeams(self, heroIdList)
			local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("rebel")
			config.bg = "map/gonghui_map.jpg"
	        -- config.verifyKey = data.battleVerify
	        config.verifyKey = data.gfStartResponse.battleVerify
			config.isPVPMode = false
			config.isSocietyDungeon = true
			config.isQuick = true
			config.isReplay = true

			local societyChapter = QStaticDatabase:sharedDatabase():getScoietyWave(self._wave, self._chapter)
			if societyChapter.color_type == 1 then
				config.bg = "ccb/map/gonghui.ccbi"
			elseif societyChapter.color_type == 2 then
				config.bg = "ccb/map/gonghui_yellow.ccbi"
			elseif societyChapter.color_type == 3 then
				config.bg = "ccb/map/gonghui_blue.ccbi"
			elseif societyChapter.color_type == 4 then
				config.bg = "ccb/map/gonghui_green.ccbi"
			end

			config.team1Name = remote.user.nickname
			config.team1Icon = remote.user.avatar
			if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
				config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
			end
		
			config.myTeam = heroIdList[1]
	        config.teamName = self._teamKey
	        config.consortiaMoney = remote.user.consortiaMoney
	        config.token = remote.user.token
	        
			config.heroRecords = remote.user.collectedHeros or {}

			config.force = self._force
			config.societyDungeonChapter = self._chapter
			config.societyDungeonWave = self._wave
			config.societyDungeonBossID = self._bossId
			config.societyDungeonBossLevel = self._bossLevel
			config.societyDungeonBossHp = self._bossHp
			config.societyDungeonLittleMonster = self._little_monster
			config.societyDungeonBuffList = self._societyDungeonBuffList
			
			local isFinalBoss = remote.union:checkIsFinalWave(self._chapter, self._wave)
			if isFinalBoss then
				config.boss_hp_infinite = true
			end
			
			config.isPlayerComeback = remote.playerRecall:isOpen()

	   		-- 初始化一些个人的基础信息，包括头像框之类的。跳过战斗必须设置
	   		self:_initDungeonConfig(config)

	   		remote.user:update({societyDungeonLastFightAt = q.serverTime() * 1000})

	   		remote.union:setSocietyDungeonFightInfo(true, self._wave, self._chapter)

			local buffer = self:_createReplayBuffer(config, data)
			writeToBinaryFile("last.reppb", buffer)

			remote.union:unionQuickFightEndRequest(self._wave, self._chapter, self._robotCount, isSecretary, data.gfStartResponse.battleVerify, success, fail)
  		end,function (data)
  			fail(data)
  		end)
end

function QSocietyDungeonArrangement:checkTeamIsEmpty(callback, callback2)
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
				if callback then
					callback()
				end
			else
				if callback2 then
					callback2()
				end
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
				if callback then
					callback()
				end
			else
				if callback2 then
					callback2()
				end
			end
		end}, true, true)
		return true
  	end

	local soulMaxNum = teamVO:getSpiritsMaxCountByIndex(1)
    if soulMaxNum > 0 and heroIdList[1].spiritIds ~= nil and #heroIdList[1].spiritIds < soulMaxNum then
        app:alert({content="有主力魂灵未上阵，确定开始战斗吗？",title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
				if callback then
					callback()
				end
			else
				if callback2 then
					callback2()
				end
			end
        end}, true, true)
        return true
    end

	return false
end

function QSocietyDungeonArrangement:_getHeroIdList()
  	local actorIds = self:getExistingHeroes()
	if #actorIds == 0 then
		local teams = remote.teamManager:getDefaultTeam(remote.teamManager.INSTANCE_TEAM)
	    remote.teamManager:updateTeamData(self:getTeamKey(), teams)
	end
	local teamVO = remote.teamManager:getTeamByKey(self:getTeamKey(), false)
	return teamVO:getAllTeam()
end

function QSocietyDungeonArrangement:_initHero(availableHeroIDs, existingHeros)
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

return QSocietyDungeonArrangement
