--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QSunwarArrangement = class("QSunwarArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QUIWidget = import("..ui.widgets.QUIWidget")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")

QSunwarArrangement.MIN_LEVEL = 0

function QSunwarArrangement:ctor(options)
	local heroIdList = {}
	for k, v in ipairs(remote.herosUtil:getHaveHero()) do
		if remote.herosUtil:getHeroByID(v).level >= QSunwarArrangement.MIN_LEVEL then
			table.insert(heroIdList, v)
		end
	end

	QSunwarArrangement.super.ctor(self, heroIdList, options.teamKey or remote.teamManager.SUNWAR_ATTACK_TEAM)

	self._dungeonInfo = options.dungeonInfo
	self._force = remote.herosUtil:getMostHeroBattleForce(true) or 0
end

function QSunwarArrangement:viewDidAppear()
	remote.sunWar:addBuff(true, "SunwarArrangement")
end

function QSunwarArrangement:viewWillDisappear()
	remote.sunWar:removeBuff(true, "SunwarArrangement")
end

-- Sunwell team arrangement needs to show hero states to decide if can go on fighting
function QSunwarArrangement:showHeroState()
	return true
end

function QSunwarArrangement:availableHeroPrompt( ... )
	return false
end

function QSunwarArrangement:handlerDialog(dialog)
    local buff = remote.sunWar:getBuffUpValue()
    if buff and buff > 0 then
		dialog._ccbOwner.node_buff_up:setVisible(true)
		dialog._ccbOwner.node_buff_up:setPositionX(150)
		dialog._ccbOwner.tf_buff_num:setString(buff.."%")
		dialog._ccbOwner.sp_battle_force_bg:setVisible(true)
		local fire1 = QUIWidget.new("ccb/Widget_up_icon.ccbi")
		dialog._ccbOwner.node_up:addChild(fire1)
		local fire2 = QUIWidget.new("ccb/effects/zhanchang_fire.ccbi")
		dialog._ccbOwner.node_fire:addChild(fire2)
	else
		dialog._ccbOwner.node_buff_up:setVisible(false)
		dialog._ccbOwner.sp_battle_force_bg:setVisible(false)
    end
end

function QSunwarArrangement:startBattle(heroIdList)
	local mainActorIds = heroIdList[1]
	local subActorIds = heroIdList[2] or {}
	local activeSubActorId = heroIdList[3] and (heroIdList[3][1] or nil) or nil
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
	        config.battleFormation = battleFormation or {}
	        
			config.heroRecords = remote.user.collectedHeros or {}
			config.pvpRivalHeroRecords = self._dungeonInfo.collectedHero or {}

			-- 战场技能
			config.heroSkillBonuses = self._dungeonInfo.heroSkillBonuses or {}

    		self:_initDungeonConfig(config, self._dungeonInfo)
		    for actorId, heroInfoInSunwell in pairs(remote.sunWar:getMyHeroInfo()) do
		    	for i, heroInfo in ipairs(config.heroInfos or {}) do
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

	   		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

	       	local loader = QDungeonResourceLoader.new(config)
   			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}}) 

       		-- app:getNavigationManager():getController(app.mainUILayer):getTopPage():loadBattleResources()
			
		end,function ()
			
		end
		)
end

function QSunwarArrangement:startAutoFight(success, fail)
	local heroIdList = self:_getHeroIdList()
	if heroIdList == nil or heroIdList[1] == nil or next(heroIdList[1].actorIds) == nil then
        app.tip:floatTip("魂师大人，当前没有魂师上阵，快去设置上阵吧~")
        return
    end

	local isAllDead = true
    if heroIdList[1] then
    	for _, actorId in pairs(heroIdList[1].actorIds) do
	        local heroInfo = remote.sunWar:getMyHeroInfoByActorID(actorId)
	        if heroInfo == nil or heroInfo.currHp == nil or heroInfo.currHp > -1 then
	            isAllDead = false
	            break
	        end
	    end
    end
    if isAllDead then
    	app.tip:floatTip("魂师大人，当前上阵魂师已经死亡，请调整魂师或者复活他们继续战斗~")
    	return 
    end

    if self:teamValidity(heroIdList[1].actorIds) == false then
        return
    end

    local callback = function ()
    	self:autoFightEnd(heroIdList, success, fail)
    end
    if self:checkCanBeginAutoFight(heroIdList,callback) == false then
    	return
    end
    self:autoFightEnd(heroIdList, success, fail)
end

function QSunwarArrangement:checkCanBeginAutoFight(heroIdList,comfirm)
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SUNWAR_ATTACK_TEAM, false)
    local isUnlockSoul = app.unlock:getUnlockSoulSpirit()
    local isUnlockHelper = app.unlock:getUnlockHelperDisplay()
    local isUnlockHelper2 = app.unlock:getUnlockTeamHelp5()
    local isUnlockHelper3 = app.unlock:getUnlockTeamHelp9()
    local str = "确定开始战斗吗？"

    local teamHeroNum = teamVO:getHerosMaxCountByIndex(1)
    if heroIdList[1].actorIds ~= nil and #heroIdList[1].actorIds < teamHeroNum then--and #heros - (helpTeam + eroIdList[1].actorIds  + helpTeam2) > 0 then
        app:alert({content="有主力英雄未上阵，"..str,title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                comfirm()
            end
        end})
        return false
    end

    local soulMaxNum = teamVO:getSpiritsMaxCountByIndex(1)
    if isUnlockSoul and heroIdList[1].spiritIds ~= nil and #heroIdList[1].spiritIds < soulMaxNum then--and #heros - (mainTeam + helpTeam + helpTeam2) > 0 then
        app:alert({content="有主力魂灵未上阵，"..str,title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                comfirm()
            end
        end})
        return false
    end

    teamHeroNum = teamVO:getHerosMaxCountByIndex(2)
    if isUnlockHelper and heroIdList[2].actorIds ~= nil and #heroIdList[2].actorIds < teamHeroNum then--and #heros - (mainTeam + helpTeam + helpTeam2) > 0 then
        app:alert({content="有援助1英雄未上阵，"..str,title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                comfirm()
            end
        end})
        return false
    end

    teamHeroNum = teamVO:getHerosMaxCountByIndex(3)
    if isUnlockHelper2 and heroIdList[3].actorIds ~= nil and #heroIdList[3].actorIds < teamHeroNum then--and #heros - (mainTeam + helpTeam + helpTeam2) > 0 then
        app:alert({content="有援助2英雄未上阵，"..str,title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                comfirm()
            end
        end})
        return false
    end

    teamHeroNum = teamVO:getHerosMaxCountByIndex(4)
    if isUnlockHelper3 and heroIdList[4].actorIds ~= nil and #heroIdList[4].actorIds < teamHeroNum then--and #heros - (mainTeam + helpTeam + helpTeam2) > 0 then
        app:alert({content="有援助3英雄未上阵，"..str,title="系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                comfirm()
            end
        end})
        return false
    end
end

function QSunwarArrangement:autoFightEnd(heroIdList, success, fail)
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
			config.battleFormation = battleFormation or {}
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

		    app:getClient():sunwarFightEndRequest(nil, {}, {}, config.verifyKey, config.fightWave, true, false, function (data)
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
			
		end
	)
end


function QSunwarArrangement:_getHeroIdList()
	local teamVO = remote.teamManager:getTeamByKey(self:getTeamKey(), false)

	return teamVO:getAllTeam()
end

function QSunwarArrangement:getPrompt()
	return QSunwarArrangement.MIN_LEVEL.."级以上魂师方可参加海神岛战斗"
end

--获取魂师状态
function QSunwarArrangement:getHeroInfoById(actorId)
	return remote.sunWar:getMyHeroInfoByActorID(actorId)
end

function QSunwarArrangement:getMaxHp(maxHp)
    local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
    if globalConfig.SUNWELL_MAX_HEALTH_COEFFICIENT ~= nil and globalConfig.SUNWELL_MAX_HEALTH_COEFFICIENT.value ~= nil then
        maxHp = maxHp * globalConfig.SUNWELL_MAX_HEALTH_COEFFICIENT.value 
    end
    return maxHp
end

function QSunwarArrangement:getHeroes()
	local heroIdList = {}
	for k, v in ipairs(remote.herosUtil:getHaveHero()) do
		if remote.herosUtil:getHeroByID(v).level >= QSunwarArrangement.MIN_LEVEL then
			table.insert(heroIdList, v)
		end
	end
	return heroIdList
end

return QSunwarArrangement
