--
-- Author: Kumo.Wang
-- Date: Sat Mar  5 18:30:36 2016
-- 海神岛数据管理（原太阳井）

local QBaseModel = import("...models.QBaseModel")
local QSunWar = class("QSunWar",QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")
local QActor = import("...models.QActor")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("...ui.QUIViewController")
 
QSunWar.UPDATE_MAP_EVENT = "UPDATE_MAP_EVENT"
QSunWar.UPDATE_PLAYER_EVENT = "UPDATE_PLAYER_EVENT"
QSunWar.UPDATE_CHEST_EVENT = "UPDATE_CHEST_EVENT"
QSunWar.UPDATE_MAP_INFO_EVENT = "UPDATE_MAP_INFO_EVENT"
QSunWar.REVIVE_COMPLETE_EVENT = "REVIVE_COMPLETE_EVENT"
QSunWar.CHEST_OPENED_EVENT = "CHEST_OPENED_EVENT"
QSunWar.CHEST_INSPECT_EVENT = "CHEST_INSPECT_EVENT"
QSunWar.REVIVE_EVENT = "REVIVE_EVENT"

QSunWar.ReviveCount = 1
QSunWar.BUFF_NAME = "BUFF_NAME"
QSunWar.BUFF_INSPECT_NAME = "BUFF_INSPECT_NAME"

function QSunWar:ctor()
	QSunWar.super.ctor(self)

    self._currentMapID = 1
    self._nextMapID = 0
    self._currentWaveID = 0
    self._reviveCount = 0
    self._canReviveCount = 0
	self._buyReviveCount = 0
    self._lastPassedWave = 0
    self._luckyDrawCritical = 0
    self._resetMode = 0
    self._startWaveID = 0

	self._isMapFirstAppearance = false
	self._isHeroFirstAppearance = false
	self._isChestFirstAppearance = false
	self._isNeedMapUpdate = true
	self._isNeedPlayerUpdate = true
	self._isNeedChestUpdate = true
	self._isNeedRedPointAtRevive = false
	self._isNeedRedPointAtChest = false
	self._isChestOpening = false
	self._isWaveFirstWin = false
	self._isChapterPass = false
	self._isBuffEffectPlaying = false
	self._isFirstInSunWar = true
	
    self._sunWarInfo = {}
    self._currentMapFighters = {}
    self._myHeroInfo = {}
    self._npcHeroInfo = {}
    self._chestInfo = {}
    self._todayPassedWaves = {}
    self._chestAwards = {}
    self._firstWinLuckyDraw = {}
    self._chaptersAwarded = {}

    self._dispatchTBl = {}
    
    self._lastWaveId = 0
end

function QSunWar:init()
	self._remoteProexy = cc.EventProxy.new(remote.user)
    self._remoteProexy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, function ()
        self:_checkSunWarUnlock()
    end)

	local maps = QStaticDatabase.sharedDatabase():getSunWarMapConfig()
	local waves = QStaticDatabase.sharedDatabase():getSunWarWaveConfig()
	local map = {}
	local wave = {}
	for _, value in pairs(maps) do
		map[value.chapter] = value
	end

	for _, value in pairs(waves) do
		local num = (value.wave%9)
		num = num == 0 and 9 or num
		if wave[value.chapter] == nil then
			wave[value.chapter] = {}
			wave[value.chapter][num] = value
		else
			wave[value.chapter][num] = value
		end

		if value.wave > self._lastWaveId then
			self._lastWaveId = value.wave
		end
	end
	
	for i = 1, #map do
		local tbl = wave[map[i].chapter]
		local j = 1
		local c = 0
		for _, v in pairs(tbl) do
			v.index = j
			if v.chest_id then c = c + 1 end
			j = j + 1
		end
		map[i].waves = tbl
		map[i].waveCount = j - 1
		map[i].chestCount = c

		self._sunWarInfo[map[i].chapter] = map[i]
	end
end

function QSunWar:disappear()
end

function QSunWar:loginEnd()
	if self:_checkSunWarUnlock() then
		app:getClient():sunwarGetSimpleInfoRequest(function( response )
			self:responseHandler(response)
		end)
	end
end

function QSunWar:newDayUpdate()
	-- print("[Kumo] QSunWar:newDayUpdate()")
	self._currentWaveID = 0
    self._reviveCount = 0
    self._canReviveCount = 0
	self._buyReviveCount = 0

    self._myHeroInfo = {}
    self._npcHeroInfo = {}
    self._chestInfo = {}
    self._todayPassedWaves = {}
    self._chestAwards = {}
    self._firstWinLuckyDraw = {}
    self._chaptersAwarded = {}

	if self:_checkSunWarUnlock() then
		app:getClient():sunwarInfoRequest(function( response )
			self:responseHandler(response)
		end)
	end
end

function QSunWar:openDialog()
	if app.unlock:checkLock("UNLOCK_SUNWELL", true) then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSunWar"})
	end
end

--------------数据储存--------------

--[[
	当前海神岛的id
]]
function QSunWar:setCurrentMapID( int, boo )
	if int == self._currentMapID or int == 0 then return end
	-- print("[Kumo] set cur_map_id : ", int, boo)
	self._currentMapID = int
end

function QSunWar:getCurrentMapID()
	return self._currentMapID
end

--[[
	当前海神岛的id
]]
function QSunWar:setNextMapID( int )
	-- print("[Kumo] set next_map_id : ", int, self._currentMapID, boo)
	if int == self._currentMapID or int == 0 then return end
	
	self._nextMapID = int
	self:setIsMapFirstAppearance(false)
	self:setIsNeedMapUpdate(true)
	self:setIsNeedPlayerUpdate(true)
	self:setIsNeedChestUpdate(true)
	table.insert(self._dispatchTBl, QSunWar.UPDATE_MAP_EVENT)
end

function QSunWar:getNextMapID()
	return self._nextMapID
end

--[[
	当前关卡id
]]
function QSunWar:setCurrentWaveID( int, boo )
	if int == self._currentWaveID or int == 0 then return end
	-- print("[Kumo] set cur_wave_id : ", int, boo)
	self._currentWaveID = int
	self:setIsHeroFirstAppearance(boo)
	self:setIsNeedPlayerUpdate(true)
	table.insert(self._dispatchTBl, QSunWar.UPDATE_PLAYER_EVENT)
end

function QSunWar:getCurrentWaveID()
	return self._currentWaveID
end

--[[
	当前关卡的敌人的攻击顺序(给QAIDPSARENA使用)
	返回一个array，或者nil
]]
function QSunWar:getCurrentWaveTargetOrder()
	local config = QStaticDatabase:sharedDatabase():getSunWarDungeonRageConfig(self._currentMapID, self._currentWaveID)
	if config and config.enemy_ai then
		local arr = string.split(config.enemy_ai, ",")
		for i, order in ipairs(arr) do
			arr[i] = tonumber(order)
		end
		return arr
	end
end

--[[
	当前关卡Fighter
]]
function QSunWar:setCurrentMapFighters( tbl, npcsHpMp )
	if not tbl then return end
	self._currentMapFighters = tbl

	for _, waveFighter in pairs(self._currentMapFighters) do
		local archaeologyProp = {}
		local avatarProp = {}
		local unionSkillProp = {}
		if waveFighter.archaeology then
			archaeologyProp = getArchaeologyPropByFragmentID(waveFighter.archaeology.last_enable_fragment_id)
		end
		avatarProp = QStaticDatabase:sharedDatabase():calculateAvatarProp(waveFighter.avatar, waveFighter.title)

        if waveFighter.consortiaSkillList then
        	unionSkillProp = remote.union:getUnionSkillProp(waveFighter.consortiaSkillList)
        end
        waveFighter.archaeologyProp = archaeologyProp
        waveFighter.avatarProp = avatarProp
        waveFighter.unionSkillProp = unionSkillProp
        -- if waveFighter.heros then
        --     for _, heroInfo in pairs(waveFighter.heros) do
        --     end
        -- end
        -- if waveFighter.subheros then
        --     for _, heroInfo in pairs(waveFighter.subheros) do
        --     end
        -- end
	end

	table.insert(self._dispatchTBl, QSunWar.UPDATE_PLAYER_EVENT)

	-- print("[Kumo] set cur_fighter_info : ")
	-- QPrintTable(self._currentMapFighters)
end

function QSunWar:getCurrentMapFighters()
	return self._currentMapFighters
end

--复活所有魂师
function QSunWar:rebronAllHeros()
	self._myHeroInfo = {}
end

--[[
	我方魂师的数据，HP,MP为初始状态的魂师不在列表里
	heroInfos = {
	{actorId = actorId, hp = hp, mp = mp},
	{actorId = actorId, hp = hp, mp = mp}
	}
	cooldownTime: 已经过去了多长时间
]]
function QSunWar:setMyHeroInfo( tbl )
	if tbl == nil then return end

	if self._myHeroInfo == nil then
		self._myHeroInfo = {}
	end

	for _, heroInfo in pairs(tbl) do
		self._myHeroInfo[heroInfo.actorId] = heroInfo
		-- heroInfo.hp = heroInfo.currHp
		-- heroInfo.mp = heroInfo.currMp
	end
	-- print("[Kumo] set cur_myhero_info : ")
	-- QPrintTable(self._myHeroInfo)
end

function QSunWar:getMyHeroInfo()
	return self._myHeroInfo
end

function QSunWar:getSunwarHeroInfo(actorId)
	if actorId == nil then
		return nil
	end

	return self._myHeroInfo[actorId]
end

function QSunWar:hasNoDeadHero()
    local heroInfo = self:getMyHeroInfo()
    -- printTable(heroInfo)
    if not heroInfo or table.nums(heroInfo) == 0 then 
        return true
    end
    local isFind = false
    for _, hero in pairs(heroInfo) do
        if hero.currHp ~= nil and hero.currHp <= 0 then
            isFind = true
        end
    end 

    if not isFind then
        return true
    end

    return false
end

--[[
	敌方魂师的数据，HP,MP为初始状态的魂师不在列表里
	heroInfos = {
	{actorId = actorId, hp = hp, mp = mp},
	{actorId = actorId, hp = hp, mp = mp}
	}
	cooldownTime: 已经过去了多长时间
]]
function QSunWar:setNpcHeroInfo( tbl )
	if tbl == nil then 
		self._npcHeroInfo = {}
		return 
	end

	if self._npcHeroInfo == nil then
		self._npcHeroInfo = {}
	end

	-- print("[Kumo] set cur_npchero_info : ")
	-- QPrintTable(tbl)

	for _, heroInfo in pairs(tbl) do
		self._npcHeroInfo[heroInfo.actorId] = heroInfo
	end

	local fighter = self:getWaveFigtherByWaveID(self._currentWaveID)
	for _, hero in ipairs(fighter.heros or {}) do
		for _, obj in ipairs(tbl) do
			if obj.actorId == hero.actorId then
				hero.currHp = obj.currHp
				hero.currMp = obj.currMp
				break
			end
		end
	end
	for _, hero in ipairs(fighter.subheros or {}) do
		for _, obj in ipairs(tbl) do
			if obj.actorId == hero.actorId then
				hero.currHp = obj.currHp
				hero.currMp = obj.currMp
				break
			end
		end
	end
	if fighter.soulSpirit then
		for _, obj in ipairs(tbl) do
			if fighter.soulSpirit.id == obj.actorId then
				fighter.soulSpirit.currHp = obj.currHp
				fighter.soulSpirit.currMp = obj.currMp
				break
			end
		end
	end
end

function QSunWar:getNpcHeroInfo()
	return self._npcHeroInfo
end

-- 海神之光血量buff
function QSunWar:getNpcHeroSkillHpBuff(hero)
	local skills = hero.heroSkillBonuses or {}
	local curBuff = 0
    for _, skillId in ipairs(skills) do
        local skillData = db:getSkillDataByIdAndLevel(skillId, 1)
		local index = 1
        while skillData["addition_type_"..index] do
        	if skillData["addition_type_"..index] == "hp_percent" then
        		curBuff = curBuff + (skillData["addition_value_"..index] or 0)
        	end
        	index = index + 1
        end
    end
    return curBuff
end

function QSunWar:getNpcHeroMaxHp(actorId, waveFighter)
	local enemies = {}
	local supportEnemies = {}
	local pvp_rivals = {}
	local pvp_rivals2 = {}
	local pvp_rivals3 = {}
	local pvp_rivals4 = {}
	
    local additionalInfos = QReplayUtil:getFighterAdditionalInfos(waveFighter)
    local extraProp = app.extraProp:getExtraPropByFighter(waveFighter)

	remote.herosUtil:addPeripheralSkills(waveFighter.subheros)
	remote.herosUtil:addPeripheralSkills(waveFighter.sub2heros)
	remote.herosUtil:addPeripheralSkills(waveFighter.sub3heros)

	for _, info in ipairs(waveFighter.heros or {}) do
		local dead = false
		for _, hpmp in ipairs(self._npcHeroInfo) do
			if hpmp.actorId == info.actorId and hpmp.currHp and hpmp.currHp <= 0 then
				dead = true
				break
			end
		end
		if not dead then
			pvp_rivals[#pvp_rivals + 1] = info
		end
	end
	for _, info in ipairs(waveFighter.subheros or {}) do
		local dead = false
		for _, hpmp in ipairs(self._npcHeroInfo) do
			if hpmp.actorId == info.actorId and hpmp.currHp and hpmp.currHp <= 0 then
				dead = true
				break
			end
		end
		if not dead then
			pvp_rivals2[#pvp_rivals2 + 1] = info
		end
	end
	for _, info in ipairs(waveFighter.sub2heros or {}) do
		local dead = false
		for _, hpmp in ipairs(self._npcHeroInfo) do
			if hpmp.actorId == info.actorId and hpmp.currHp and hpmp.currHp <= 0 then
				dead = true
				break
			end
		end
		if not dead then
			pvp_rivals3[#pvp_rivals3 + 1] = info
		end
	end
	for _, info in ipairs(waveFighter.sub3heros or {}) do
		local dead = false
		for _, hpmp in ipairs(self._npcHeroInfo) do
			if hpmp.actorId == info.actorId and hpmp.currHp and hpmp.currHp <= 0 then
				dead = true
				break
			end
		end
		if not dead then
			pvp_rivals4[#pvp_rivals4 + 1] = info
		end
	end

    local skillHpBuff = self:getNpcHeroSkillHpBuff( waveFighter )
    for _, hero in ipairs(pvp_rivals or {}) do
        local actor = app:createHeroWithoutCache(hero, nil, additionalInfos, nil, nil, nil, nil, nil, extraProp)
        actor:insertExtralProp("hp_percent", (waveFighter.battleFieldBonus or 0))
        actor:insertExtralProp("hp_percent", skillHpBuff)
        local hp_percent = actor:_getActorNumberPropertyValue("hp_percent")
        table.insert(enemies, actor)
    end

    -- 副将 pvp初始化
    local supportRivals = pvp_rivals2 or {}
    for _, hero in ipairs(supportRivals) do
        local actor = app:createHeroWithoutCache(hero, nil, additionalInfos, nil, nil, nil, nil, nil, extraProp)
        table.insert(supportEnemies, actor)
    end
    -- 副将 pvp初始化
    local supportRivals = pvp_rivals3 or {}
    for _, hero in ipairs(supportRivals) do
        local actor = app:createHeroWithoutCache(hero, nil, additionalInfos, nil, nil, nil, nil, nil, extraProp)
        table.insert(supportEnemies, actor)
    end
    -- 副将 pvp初始化
    local supportRivals = pvp_rivals4 or {}
    for _, hero in ipairs(supportRivals) do
        local actor = app:createHeroWithoutCache(hero, nil, additionalInfos, nil, nil, nil, nil, nil, extraProp)
        table.insert(supportEnemies, actor)
    end

    for _, supp in ipairs(supportEnemies) do
        local hp_value = supp:_getActorNumberPropertyValue("hp_value") -- ignore pvp coefficient
        local hp_percent = supp:_getActorNumberPropertyValue("hp_percent") -- ignore pvp coefficient
        for _, enemy in ipairs(enemies) do
        	enemy:insertPropertyValue("hp_value_support", supp, "+", (hp_value * (1 + hp_percent)) / 4)
        end
    end

    local config = QStaticDatabase:sharedDatabase():getConfiguration()
    for _, enemy in ipairs(enemies) do
    	if enemy:getActorID() == actorId then
    		return enemy:getMaxHp(false, true) * (config.SUNWELL_MAX_HEALTH_COEFFICIENT.value or 1)
    	end
    end

    for _, enmey in ipairs(supportEnemies) do
    	if enemy and enemy:getActorID() == actorId then
    		return enemy:getMaxHp(false, true) * (config.SUNWELL_MAX_HEALTH_COEFFICIENT.value or 1)
    	end
    end

    return -1
end

--[[
	已经使用的复活次数
]]
function QSunWar:setHeroReviveCnt( int, boo )
	-- print("[Kumo] set cur_revive_count : ", int)
	self._reviveCount = int
	if boo then 
		table.insert(self._dispatchTBl, QSunWar.REVIVE_COMPLETE_EVENT)
	end
	table.insert(self._dispatchTBl, QSunWar.UPDATE_MAP_INFO_EVENT)
end

function QSunWar:getHeroReviveCnt()
	return self._reviveCount or 0
end

function QSunWar:getHeroBuffPropTable()
	-- if self._reviveCount and self._reviveCount > 2 then
	if self._reviveCount then
		local count = self._reviveCount
		local config, id = QStaticDatabase:sharedDatabase():getSunWarBuffConfigByCount(count)
		if config then
			return config, id
		end
	end
	return {}
end

--[[
	购买的复活次数
]]
function QSunWar:setHeroReviveBuyCnt( int )
	-- print("[Kumo] set cur_revive_buy_count : ", int)
	self._buyReviveCount = int
	table.insert(self._dispatchTBl, QSunWar.UPDATE_MAP_INFO_EVENT)
end

function QSunWar:getHeroReviveBuyCnt()
	return self._buyReviveCount or 0
end

--[[
	判断NPC是否初次登场
]]
function QSunWar:setIsHeroFirstAppearance( boo )
	self._isHeroFirstAppearance = boo
end

function QSunWar:getIsHeroFirstAppearance()
	-- return true -- 测试用
	return self._isHeroFirstAppearance
end

--[[
	判断地图是否首次更新
]]
function QSunWar:setIsMapFirstAppearance( boo )
	self._isMapFirstAppearance = boo
end

function QSunWar:getIsMapFirstAppearance()
	-- return true -- 测试用
	return self._isMapFirstAppearance
end

--[[
	判断宝箱是否首次更新
]]
function QSunWar:setIsChestFirstAppearance( boo )
	self._isChestFirstAppearance = boo
end

function QSunWar:getIsChestFirstAppearance()
	-- return true -- 测试用
	return self._isChestFirstAppearance
end

--[[
	保存宝箱被开启的关卡id —— waveID
]]
function QSunWar:setChestInfo( tbl )
	if not tbl then return end
	if table.nums(tbl) ~= table.nums(self._chestInfo) then 
		self:setIsNeedChestUpdate(true)
		self._chestInfo = tbl
		table.insert(self._dispatchTBl, QSunWar.UPDATE_PLAYER_EVENT)
	else
		self._chestInfo = tbl
	end
	-- print("[Kumo] set cur_chest_info : ")
	-- QPrintTable(self._chestInfo)
end

function QSunWar:getChestInfo()
	return self._chestInfo
end

--[[
	是否需要更新，防止无用的刷新
]]
function QSunWar:setIsNeedMapUpdate( boo )
	self._isNeedMapUpdate = boo
end

function QSunWar:getIsNeedMapUpdate()
	return self._isNeedMapUpdate
end

--[[
	是否需要更新，防止无用的刷新
]]
function QSunWar:setIsNeedPlayerUpdate( boo )
	self._isNeedPlayerUpdate = boo
end

function QSunWar:getIsNeedPlayerUpdate()
	return self._isNeedPlayerUpdate
end

--[[
	是否需要更新，防止无用的刷新
]]
function QSunWar:setIsNeedChestUpdate( boo )
	self._isNeedChestUpdate = boo
end

function QSunWar:getIsNeedChestUpdate()
	return self._isNeedChestUpdate
end

--[[
	记录最后一个打过的关卡，用来判断最后一章最后一关的判断
]]
function QSunWar:setLastPassedWave( int )
	self._lastPassedWave = int
	app.taskEvent:updateTaskEventProgress(app.taskEvent.SUN_WAR_ACTIVE_EVENT, 1, false, false, {compareNum = self._lastPassedWave})
end

function QSunWar:getLastPassedWave()
	return self._lastPassedWave
end

function QSunWar:checkIsLastPassedWave()
	local lastPassedWave = self:getLastPassedWave()
	if self._lastWaveId == tonumber(lastPassedWave) then
		return true
	end

	return false
end

--[[
	今日打过的关卡id
]]
function QSunWar:setTodayPassedWaves( tbl )
	if not tbl then return end

	self._todayPassedWaves = tbl
end

function QSunWar:getTodayPassedWaves()
	return self._todayPassedWaves
end

--[[
	海神岛重置模式
]]
function QSunWar:setResetMode( int )
	if not int then int = 0 end

	self._resetMode = int
end

function QSunWar:getResetMode()
	return self._resetMode
end

--[[
	每日海神岛开始的关卡ID
]]
function QSunWar:setStartWaveID( int )
	if not int then int = 0 end

	self._startWaveID = int
end

function QSunWar:getStartWaveID()
	return self._startWaveID
end

--[[
	历史挑战最高海神岛的关卡ID
]]
function QSunWar:setfurthestFightingWaveID( int )
	if not int then int = 0 end

	self._furthestFightingWaveID = int
end

function QSunWar:getfurthestFightingWaveID()
	return self._furthestFightingWaveID or 1
end

--[[
	记录宝箱是不是正在打开，从请求后台成功开始到点掉奖励页面
]]
function QSunWar:setIsChestOpening( boo )
	self._isChestOpening = boo
end

function QSunWar:getIsChestOpening()
	return self._isChestOpening
end

function QSunWar:setChestAwards( tbl )
	self._chestAwards = tbl
end

function QSunWar:getChestAwards()
	return self._chestAwards
end

function QSunWar:setIsWaveFirstWin( boo )
	self._isWaveFirstWin = boo
end

function QSunWar:getIsWaveFirstWin()
	return self._isWaveFirstWin
end

function QSunWar:setFirstWinLuckyDraw( tbl, userComeBackRatio )
	self._firstWinLuckyDraw = tbl
	self._userComeBackRatio = userComeBackRatio or 1
end

function QSunWar:getFirstWinLuckyDraw()
	return self._firstWinLuckyDraw, self._userComeBackRatio
end

function QSunWar:setLuckyDrawCritical( int )
	self._luckyDrawCritical = int
end

function QSunWar:getLuckyDrawCritical()
	return self._luckyDrawCritical
end

function QSunWar:setLuckyDrawActivityYeild(yeild)
    self.luckDrawActivityYield = yeild
end

function QSunWar:getLuckyDrawActivityYeild()
    return self.luckDrawActivityYield or 1
end

function QSunWar:setIsChapterPass( boo )
	self._isChapterPass = boo
end

function QSunWar:getIsChapterPass()
	return self._isChapterPass
end

function QSunWar:setChaptersAwarded( tbl )
	if not tbl or table.nums(tbl) == 0 then return end

	self._chaptersAwarded = tbl
end

function QSunWar:getChaptersAwarded()
	return self._chaptersAwarded
end

function QSunWar:setIsBuffEffectPlaying( boo )
	self._isBuffEffectPlaying = boo
end

function QSunWar:getIsBuffEffectPlaying()
	return self._isBuffEffectPlaying
end

--------------调用素材--------------

--[[
	获取切换地图时，过场动画 —— 云和全屏烟花
	返回：坐标，路径
]]
function QSunWar:getCloudAniURL()
	return nil, "ccb/Widget_SunWar_Yun.ccbi"
end

--[[
	宝箱出现
	返回：坐标，路径
]]
function QSunWar:getChestAppearURL( color )
	if color == 1 then
		--绿色
		return nil, "ccb/effects/chest/sunwar_green_appear.ccbi"
	elseif color == 2 then
		--蓝色
		return nil, "ccb/effects/chest/sunwar_blue_appear.ccbi"
	else
		--金色
		return nil, "ccb/effects/chest/sunwar_gold_appear.ccbi"
	end
end

--[[
	宝箱静止
	返回：坐标，路径
]]
function QSunWar:getChestStaticURL( color )
	if color == 1 then
		--绿色
		return nil, "ccb/effects/chest/sunwar_green_static.ccbi"
	elseif color == 2 then
		--蓝色
		return nil, "ccb/effects/chest/sunwar_blue_static.ccbi"
	else
		--金色
		return nil, "ccb/effects/chest/sunwar_gold_static.ccbi"
	end
end

--[[
	宝箱跳动
	返回：坐标，路径
]]
function QSunWar:getChestJumpURL( color )
	if color == 1 then
		--绿色
		return nil, "ccb/effects/chest/sunwar_green_jump.ccbi"
	elseif color == 2 then
		--蓝色
		return nil, "ccb/effects/chest/sunwar_blue_jump.ccbi"
	else
		--金色
		return nil, "ccb/effects/chest/sunwar_gold_jump.ccbi"
	end
end

--[[
	宝箱打开
	返回：坐标，路径
]]
function QSunWar:getChestOpenURL( color )
	if color == 1 then
		--绿色
		return nil, "ccb/effects/chest/sunwar_green_opening.ccbi"
	elseif color == 2 then
		--蓝色
		return nil, "ccb/effects/chest/sunwar_blue_opening.ccbi"
	else
		--金色
		return nil, "ccb/effects/chest/sunwar_gold_opening.ccbi"
	end
end

--[[
	宝箱已开
	返回：坐标，路径
]]
function QSunWar:getChestDisappearURL( color )
	if color == 1 then
		--绿色
		return nil, "ccb/effects/chest/sunwar_green_opened.ccbi"
	elseif color == 2 then
		--蓝色
		return nil, "ccb/effects/chest/sunwar_blue_opened.ccbi"
	else
		--金色
		return nil, "ccb/effects/chest/sunwar_gold_opened.ccbi"
	end
end

--[[
	交战状态的一对小剑
	返回：坐标，路径
]]
function QSunWar:getBattleIngURL()
	return nil, "ccb/effects/battle_ing.ccbi"
end

--[[
	boss魔化的状态效果
	返回：坐标，路径
]]
function QSunWar:getBossBuffURL()
	return nil, "ccb/effects/zhanchang_fx_1.ccbi"
end

--[[
	复活后的提示标语
	返回：坐标，路径
]]
function QSunWar:getReviveTipsURL()
	return nil, "ccb/effects/zhanchang_fuhuo.ccbi"
end

--[[
	BUFF特效中火焰
	返回：坐标，路径
]]
function QSunWar:getBuffFireURL()
	return nil, "ccb/effects/zhanchang_fire_guang.ccbi"
end

--[[
	BUFF特效中火焰文字效果
	返回：坐标，路径
]]
function QSunWar:getBuffTextToFireURL()
	return nil, "ccb/effects/zhanchang_fire2.ccbi"
end

--[[
	top bar 战力上的曝光效果
	返回：坐标，路径
]]
function QSunWar:getFireBoomURL()
	return nil, "ccb/effects/zhanchang_fire_boom.ccbi"
end

--------------便民工具--------------

--[[
	根据海神岛的id，返回海神岛地图的美术资源
	@int 海神岛id
	return table
]]
function QSunWar:getMapURLByID( int )
	local mapID = int or self:getCurrentMapID()

	local tbl = {}
	local config = self._sunWarInfo[mapID]
	-- printTable(config)
	local i = 1
	while(true) do
		if config ~= nil and config["map_"..i] then
			tbl[i] = {url = config["map_"..i], scale = config["map_"..i.."_scale"]}
			i = i + 1
		else
			break
		end
	end

	return tbl
end

function QSunWar:getMapInfoByMapID( int )
	return self._sunWarInfo[int]
end

function QSunWar:getMaxMapID()
	return #self._sunWarInfo
end

function QSunWar:getAvatarHeroInfoByWaveID( int )
	local tbl = self:getCurrentMapFighters()
	local waveID = int or self:getCurrentWaveID()

	-- QPrintTable(tbl)
	-- print(waveID, int)
	-- QPrintTable(self:getWaveInfoByWaveID(waveID))
	local info = self:getWaveInfoByWaveID(waveID)
	if info == nil then return nil end
	local index = info.index

	if not tbl[ index ] or not tbl[ index ].waveFighter then return nil end

	local heroInfo = tbl[ index ].waveFighter
	
	if not heroInfo then return nil end
	
	return remote.herosUtil:getMaxForceByHeros(heroInfo)
end

function QSunWar:getPlayerNameByWaveID( int )
	local tbl = self:getCurrentMapFighters()
	-- print(index, int)
	-- QPrintTable(tbl)
	-- QPrintTable(self:getWaveInfoByWaveID(int))
	local waveInfo = self:getWaveInfoByWaveID(int)
	if waveInfo == nil then
		return ""
	end
	local index = waveInfo.index


	if not tbl[ index ] or not tbl[ index ].waveFighter then return "" end

	local heroInfo = {}

	if tbl[ index ].waveId == int then
		heroInfo = tbl[ index ].waveFighter
	elseif tbl[ #tbl ].waveId == int then
		heroInfo = tbl[ #tbl ].waveFighter
	else
		return ""
	end

	if not heroInfo then return "" end

	return heroInfo.name
end

function QSunWar:getPlayerForceByWaveID( int )
	local tbl = self:getCurrentMapFighters()
	local index = self:getWaveInfoByWaveID(int).index

	if not tbl[ index ] or not tbl[ index ].waveFighter then return "" end

	local heroInfo = {}

	if tbl[ index ].waveId == int then
		heroInfo = tbl[ index ].waveFighter
	elseif tbl[ #tbl ].waveId == int then
		heroInfo = tbl[ #tbl ].waveFighter
	else
		return ""
	end
	
	if not heroInfo then return "" end
	
	return heroInfo.force
end

function QSunWar:getWaveFigtherByWaveID( int )
	local tbl = self:getCurrentMapFighters()
	local index = self:getWaveInfoByWaveID(int).index

	if not tbl[ index ] or not tbl[ index ].waveFighter then return nil end

	local heroInfo = {}

	if tbl[ index ].waveId == int then
		heroInfo = tbl[ index ].waveFighter
	elseif tbl[ #tbl ].waveId == int then
		heroInfo = tbl[ #tbl ].waveFighter
	else
		return nil
	end
	
	if not heroInfo then return nil end
	
	return heroInfo
end

function QSunWar:getMyHeroInfoByActorID( int )
	local info = self:getMyHeroInfo()
	return info[tostring(int)] or info[int]
end

function QSunWar:getCanReviveCount()
	local reviveCount = self:getHeroReviveCnt()
	local buyReviveCount = self:getHeroReviveBuyCnt()
	self._canReviveCount = QSunWar.ReviveCount - reviveCount + buyReviveCount
	return  self._canReviveCount
end

function QSunWar:getWaveInfoByWaveID( int, isInSunWar )
	if isInSunWar == nil then isInSunWar = true end
	--[[
		因为海神岛实际的map切换，不仅仅要看wave的id还要判断当前海神岛的宝箱是否全部开启。而海神岛之外的排行榜，是不需要判断宝箱的状态的。
	]]
	local mapID = 0
	if isInSunWar then
		-- 多为海神岛内部的调用，会根据关卡id和宝箱开启情况来调整地图id
		mapID = self:_getMapIDByWaveID(int)
	else
		-- 多为海神岛之外的调用，直接根据关卡id搜寻地图id
		mapID = self:getMapIDWithLastWaveID(int)
	end

	if mapID == 0 then return nil end

	local mapInfo = self:getMapInfoByMapID(mapID)
	for _, value in pairs(mapInfo.waves) do
		if value.wave == int then
			return value
		end
	end

	return nil
end

--[[
	返回：table
]]
function QSunWar:getLuckyDrawByWaveID( int )
	local waveInfo = self:getWaveInfoByWaveID(int)
	local awards = QStaticDatabase.sharedDatabase():getluckyDrawById( waveInfo.lucky_draw_id )

	return awards
end

function QSunWar:getIsChestOpenedByWaveID( int )
	local chestInfo = self:getChestInfo()
	if not chestInfo or table.nums(chestInfo) == 0 then return false end

	for _, waveID in pairs(chestInfo) do
		if waveID == int then
			return true
		end
	end

	return false
end

function QSunWar:mergeAwards( awards )
	if not awards or table.nums(awards) == 0 then return end

	local tbl = {}
	for _, value in pairs( awards ) do
		local key = value.type or value.typeName
		if key == string.lower(ITEM_TYPE.ITEM) or key == string.upper(ITEM_TYPE.ITEM) then
			key = tostring(value.id)
		end
		if not tbl[key] then
			tbl[key] = {id = value.id, typeName = value.type or value.typeName, count = value.count}
		else
			tbl[key].count = tbl[key].count + value.count
		end
	end

	-- printTable(tbl, "#")
	return tbl
end

function QSunWar:clearRedPointAtRevive()
	self._isNeedRedPointAtRevive = false
end

function QSunWar:clearRedPointAtChest()
	self._isNeedRedPointAtChest = false
end

function QSunWar:isShowRedPointAtMainPage()
	if remote.stores:checkFuncShopRedTips(SHOP_ID.sunwellShop) then
		return true
	end
	
	if self._isNeedRedPointAtChest then
		return true
	end

	return false
end

function QSunWar:checkSunWarCanRevive()
	if self._isNeedRedPointAtRevive then
		return true
	end

	return false
end

function QSunWar:getMaxWaveID( int )
	local mapInfo = {}
	local maxMapID = self:getMaxMapID()
	local maxIndex = 0

	local getMaxIndex = function ( int )
		mapInfo = self:getMapInfoByMapID( int )
		return table.nums(mapInfo.waves)
	end

	while(true) do
		maxIndex = getMaxIndex( maxMapID )
		-- print("[Kumo] QSunWar:getMaxWaveID while : ", maxMapID, maxIndex)
		if maxIndex ~= 0 then
			-- print(maxIndex)
			break
		else
			maxMapID = maxMapID - 1
			if maxMapID == 0 then
				return nil
			end
		end
	end
	
	-- print("[Kumo] QSunWar:getMaxWaveID end : ", maxMapID, maxIndex)
	local id = mapInfo.waves[ maxIndex ].wave
	return id
end

function QSunWar:isLastMapLastWaveByWaveID( int )
	local maxWaveID = self:getMaxWaveID()
	-- print("[Kumo] QSunWar:isLastMapLastWaveByWaveID : ", maxWaveID, int)
	if maxWaveID == int then
		return true
	end

	return false
end

function QSunWar:getAvatarHeightByActorID( int )
	local tbl = QStaticDatabase.sharedDatabase():getCharacterByID( int )
	return tbl.selected_rect_height * tbl.actor_scale + 30
end

function QSunWar:addBuff( boo , name)
	if name == nil then name = QSunWar.BUFF_NAME end
	remote.herosUtil:removeExtendsProp( name )
	local buffLevel = self:getHeroReviveCnt()
	local tbl = QStaticDatabase.sharedDatabase():getSunWarBuffConfigByCount( buffLevel )
	remote.herosUtil:addExtendsProp( tbl, name, boo )
end

function QSunWar:removeBuff( boo , name)
	if name == nil then name = QSunWar.BUFF_NAME end
	remote.herosUtil:removeExtendsProp( name, boo )
end

--[[
	购买复活，并且使用之后，有可能获得BUFF加成。
	返回 获得BUFF以后，总战力提升的百分比。
]]
function QSunWar:getBuffUpValue()
	self:removeBuff( false )
	local teamKey = self:getSunWarTeamKey()
	local oldBattleForce = remote.teamManager:getBattleForceForAllTeam(teamKey, true, true)
	self:addBuff( false )
	local newBattleForce = remote.teamManager:getBattleForceForAllTeam(teamKey, true, true)
	local v = (newBattleForce - oldBattleForce) / oldBattleForce * 100
	-- print("[Kumo] getBuffUpValue ", math.floor(v), v, oldBattleForce, newBattleForce)
	return (v < 1 and v ~= 0) and 1 or math.floor(v)
end

function QSunWar:getInspectBuffUpValue()
	local maxVipConfig = QStaticDatabase.sharedDatabase():getMaxVipContnent()
	local buffLevel = self:getHeroReviveCnt() + 1
	-- print("getInspectBuffUpValue" , buffLevel, maxVipConfig.battlefield_revive_times)
	if buffLevel > maxVipConfig.battlefield_revive_times + QSunWar.ReviveCount then
		-- vip 对应的购买次数 + “QSunWar.ReviveCount” 次每日赠送的免费复活
		return 0
	end

	self:removeBuff( false )
	remote.herosUtil:removeExtendsProp( QSunWar.BUFF_INSPECT_NAME, false )
	local teamKey = self:getSunWarTeamKey()
	local oldBattleForce = remote.teamManager:getBattleForceForAllTeam(teamKey, true, true)
	-- local buffLevel = self:getHeroReviveCnt() + 1 - QSunWar.ReviveCount
	local tbl = QStaticDatabase.sharedDatabase():getSunWarBuffConfigByCount( buffLevel )
	remote.herosUtil:addExtendsProp( tbl, QSunWar.BUFF_INSPECT_NAME, false )
	local newBattleForce = remote.teamManager:getBattleForceForAllTeam(teamKey, true, true)
	local v = (newBattleForce - oldBattleForce) / oldBattleForce * 100
	-- print("[Kumo] getInspectBuffUpValue ", math.floor(v), v, oldBattleForce, newBattleForce)
	local returnValue = (v < 1 and v ~= 0) and 1 or math.floor(v)
	remote.herosUtil:removeExtendsProp( QSunWar.BUFF_INSPECT_NAME, false )
	self:addBuff( false )
	return returnValue
end

function QSunWar:getSunWarTeamKey( ... )
    local teamKey = remote.teamManager.SUNWAR_ATTACK_TEAM
    local __heros = self:getMyHeroInfo()
    for _,hero in pairs(__heros) do
        if hero.currHp ~= nil then
            teamKey = remote.teamManager.SUNWAR_ATTACK_SECOND_TEAM
            break
        end
    end
    return teamKey
end

--[[
	判断章节的宝箱是否全部开启
	@int 需要判断宝箱状态的章节后面一个章节
]]
function QSunWar:isMapChestAllOpened( int )
	-- print("[Kumo] QSunWar:isMapChestAllOpened : ", int)
	if not int or int == 0 then return false end

	local mapID = int
	local mapInfo = self:getMapInfoByMapID(mapID)
	local chestInfo = self:getChestInfo()

	if mapInfo.chestCount > table.nums(chestInfo) then return false end

	local tbl = {}
	for _, waveInfo in pairs(mapInfo.waves) do
		if waveInfo.chest_id then
			tbl[waveInfo.wave] = 0
		end
	end
	local count = 0
	for _, chest in pairs(chestInfo) do
		if tbl[chest] then
			count = count + 1
		end
	end

	if count == mapInfo.chestCount then
		return true
	else
		return false 
	end
end

function QSunWar:IsChaptersAwardedByMapID( int )
	local tbl = self:getChaptersAwarded()
	if not tbl or table.nums(tbl) == 0 then return false end
	
	for _, mapID in pairs(tbl) do
		if mapID == int then
			return true
		end
	end

	return false
end

function QSunWar:getNPCInitMpByWaveID( waveID )
	local config = QStaticDatabase.sharedDatabase():getSunWarDungeonRageConfig(nil, waveID)
	if config then
		return config.enter_rage
	else
		return 500
	end
end

function QSunWar:sendInspectChestAwardEvent( waveID )
	if not waveID then return end
	self:dispatchEvent({name = QSunWar.CHEST_INSPECT_EVENT, waveID = waveID})
end

function QSunWar:sendReviveEvent()
	table.insert(self._dispatchTBl, QSunWar.REVIVE_EVENT)
end

function QSunWar:getMapIDWithLastWaveID( waveID )
	local lastWaveID = waveID or self:getLastPassedWave()
	if not lastWaveID or lastWaveID == 0 or lastWaveID == 1 then return 1 end

	for _, map in pairs(self._sunWarInfo) do
		local tbl = map.waves
		local minID = tbl[1].wave
		local maxID = tbl[#tbl].wave
		
		if lastWaveID >= minID  and lastWaveID <= maxID then
			-- print("[Kumo] ###", minID, maxID, lastWaveID, map.chapter)
			return map.chapter
		end
	end

	return 1
end

function QSunWar:getLastPassChapterWithLastWaveID()
	local lastWaveID = self:getLastPassedWave()
	if not lastWaveID or lastWaveID == 0 or lastWaveID == 1 then return 0 end

	local lastPassChapter = 0
	local isPass = false
	local _maxId = 0
	for _, map in pairs(self._sunWarInfo) do
		local tbl = map.waves
		local minID = tbl[1].wave
		local maxID = tbl[#tbl].wave
		if lastWaveID >= minID and lastWaveID <= maxID then
			_maxId = maxID
			lastPassChapter = map.chapter
		end
		if lastWaveID == maxID and self:isMapChestAllOpened(lastPassChapter) then
			isPass = true
		end
	end
	print(lastWaveID, self:isMapChestAllOpened(lastPassChapter), _maxId, isPass, lastPassChapter)
	if isPass then
		return lastPassChapter
	else
		return lastPassChapter - 1
	end
end

function QSunWar:updateSunwarInfo( data )
	if not data then
		return
	end
	if data.chaptersAwarded then
		self:setChaptersAwarded(data.chaptersAwarded)
	end
	if data.wavesAwarded then
		self:setChestInfo(data.wavesAwarded)
	end
	if data.wave then
		local mapID = self:_getMapIDByWaveID(data.wave)
		self:setNextMapID(mapID)
		self:setCurrentWaveID(data.wave)
	end
	if data.wavesFighter then
		self:setCurrentMapFighters(data.wavesFighter)
	end
	if data.heroReviveCnt then
		self:setHeroReviveCnt(data.heroReviveCnt)
	end
	if data.heroReviveBuyCnt then
		self:setHeroReviveBuyCnt(data.heroReviveBuyCnt)
	end
	self:setMyHeroInfo(data.herosHpMp)
	self:setNpcHeroInfo(data.npcsHpMp)
	if data.lastPassedWave then
		self:setLastPassedWave(data.lastPassedWave)
	end
	if data.todayPassedWaves then
		self:setTodayPassedWaves(data.todayPassedWaves)
	end
	if data.resetMode then
		self:setResetMode(data.resetMode)
	end
	if data.startWave then
		self:setStartWaveID(data.startWave)
	end
	if data.furthest_fighting_wave then
		self:setfurthestFightingWaveID(data.furthest_fighting_wave)
	end
end
--------------数据处理--------------

--[[
	optional int32				    wave = 1;                    // 当前所在的海神岛关卡ID
    repeated int32				    todayPassedWaves = 2;        // 今日通关的关卡
    optional int32				    lastPassedWave = 3;          // 最近一次通过的的海神岛关卡ID
    repeated int32				    wavesAwarded = 4;            // 已经领取过关奖励的关卡ID
    repeated BattlefieldWaveFighter wavesFighter = 5;            // 关卡对手信息
    repeated HeroHpMpInfo		    herosHpMp = 6;               // 我方各魂师当前血量值和怒气值
    repeated HeroHpMpInfo		    npcsHpMp = 7;                // NPC各魂师当前血量值和怒气值
    optional int32				    heroReviveCnt = 8;           // 魂师复活次数
    optional int32				    heroReviveBuyCnt = 9;        // 购买的魂师复活次数

]]
function QSunWar:responseHandler( response )
	if not response then
		return
	end
	if response.api == "BATTLEFIELD_GET_WAVE_AWARD" and response.error == "NO_ERROR" then
		app.taskEvent:updateTaskEventProgress(app.taskEvent.SUN_WAR_REWARD_COUNT_EVENT, 1)
    end
	-- printTableWithColor(PRINT_FRONT_COLOR_DARK_GREEN, nil, response)
	if response.battlefieldGetInfoResponse then
		self._isFirstInSunWar = false
		local data = response.battlefieldGetInfoResponse.userBattlefield
		self:updateSunwarInfo( data )
	end

	if response.gfStartResponse and response.gfStartResponse.battlefieldFightStartResponse then
		-- 这里暂时不做数据更新，因为战斗开始不会有什么数据变化，仅仅供一些状态判断留着
		local data = response.gfStartResponse.battlefieldFightStartResponse.userBattlefield
		self:updateSunwarInfo( data )
		self:setIsNeedMapUpdate(true)
		self:setIsNeedPlayerUpdate(true)
		self:setLuckyDrawCritical( 0 )
	end

	if response.gfEndResponse and response.gfEndResponse.battlefieldFightEndResponse then
		local data = response.gfEndResponse.battlefieldFightEndResponse.userBattlefield
		self:updateSunwarInfo( data )

		local waveFirstWin = response.gfEndResponse.battlefieldFightEndResponse.waveFirstWin
		local firstWinLuckyDraw = response.gfEndResponse.battlefieldFightEndResponse.firstWinLuckyDraw
		local luckyDrawCritical = response.gfEndResponse.battlefieldFightEndResponse.luckyDrawCritical
		local chapterPass = response.gfEndResponse.battlefieldFightEndResponse.chapterPass

		self:setIsWaveFirstWin( waveFirstWin )
		self:setFirstWinLuckyDraw( firstWinLuckyDraw, response.userComeBackRatio)
		self:setLuckyDrawCritical( luckyDrawCritical )
		self:setLuckyDrawActivityYeild(response.gfEndResponse.battlefieldFightEndResponse.activity_yield)
		self:setIsChapterPass( chapterPass )

		local luckyDraw = {}
		if response.gfEndResponse.battlefieldFightEndResponse.luckyDraw then
			luckyDraw = response.gfEndResponse.battlefieldFightEndResponse.luckyDraw
		end

		if luckyDraw.items then remote.items:setItems(luckyDraw.items) end
		
		-- luckyDraw = firstWinLuckyDraw
		-- remote.user:update({luckyDraw = luckyDraw})
	end

	if response.gfQuickResponse and response.gfQuickResponse.battlefieldQuickFightResponse then
		local data = response.gfQuickResponse.battlefieldQuickFightResponse.userBattlefield
		self:updateSunwarInfo( data )

		local luckyDrawCritical = response.gfQuickResponse.battlefieldQuickFightResponse.luckyDrawCritical
		local chapterPass = response.gfQuickResponse.battlefieldQuickFightResponse.chapterPass

		self:setLuckyDrawCritical( luckyDrawCritical )
		self:setLuckyDrawActivityYeild(response.gfQuickResponse.battlefieldQuickFightResponse.activity_yield)
		self:setIsChapterPass( chapterPass )

		local luckyDraw = {}
		if response.gfQuickResponse.battlefieldQuickFightResponse.luckyDraw then
			luckyDraw = response.gfQuickResponse.battlefieldQuickFightResponse.luckyDraw
		end

		if luckyDraw.items then remote.items:setItems(luckyDraw.items) end
		
		-- luckyDraw = firstWinLuckyDraw
		-- remote.user:update({luckyDraw = luckyDraw})
	end

	if response.battlefieldBuyReviveCountResponse then
		local data = response.battlefieldBuyReviveCountResponse.userBattlefield
		self:updateSunwarInfo( data )
	end

	if response.battlefieldHerosReviveResponse then
		local data = response.battlefieldHerosReviveResponse.userBattlefield
		self:updateSunwarInfo( data )
	end

	if response.battlefieldGetWaveAwardResponse then
		self:setIsChestOpening(true)
		table.insert(self._dispatchTBl, QSunWar.CHEST_OPENED_EVENT)
		local data = response.battlefieldGetWaveAwardResponse.userBattlefield
		self:updateSunwarInfo( data )

		local awards = {}
	    local tbl = {}
	    local wallet = {}

	    if response ~= nil and response.prizes ~= nil then
	        tbl = self:mergeAwards(response.prizes)
	    end
	    
	    for _,value in pairs(tbl) do
	        table.insert(awards, {id = value.id, typeName = value.type or value.typeName, count = value.count})
	        if value.typeName == "SUNWELL_MONEY" then
	            wallet["sunwellMoney"] = remote.user:getPropForKey("sunwellMoney") + value.count
	        end
	    end
	    remote.user:update( wallet )

	    self:setChestAwards( awards )
	end

	if response.battlefieldGetSimpleInfoResponse then
		local data = response.battlefieldGetSimpleInfoResponse.userBattlefield
		self:updateSunwarInfo( data )

		self:_checkIsNeedRedPointAtChest()
		self:_checkIsNeedRedPointAtRevive()
	end

	if response.battlefieldGetChapterAwardResponse then
		local data = response.battlefieldGetChapterAwardResponse.userBattlefield
		self:updateSunwarInfo( data )

		local wallet = {}
		if response.wallet then
			wallet = response.wallet
		end

		remote.user:update({wallet = wallet})
		if response.items then remote.items:setItems(response.items) end
	end

	if response.battlefieldSetResetModeResponse then
		local data = response.battlefieldSetResetModeResponse.userBattlefield
		self:updateSunwarInfo( data )
	end

	self:_dispatchAll()
end

--------------本地工具--------------


function QSunWar:_getMapIDByWaveID( int )
	if not int or int == 0 or int == 1 then return 1 end

	local waveID = int
	-- local lastPassedWave = self:getLastPassedWave()
	for _, map in pairs(self._sunWarInfo) do
		local tbl = map.waves
		local minID = tbl[1].wave
		local maxID = tbl[#tbl].wave
		
		if waveID == minID then
			--[[
				关卡在某章节第一关的时候，需要判断，前面一章地图是否宝箱全部领取。
				如果全领取了，则返回新一章节；如果未全部领取，则返回前一章节
			]]
			if (self:isMapChestAllOpened(map.chapter - 1) and self:IsChaptersAwardedByMapID(map.chapter - 1)) or self._isFirstInSunWar or self:getStartWaveID() == waveID then
				return map.chapter 
			else
				return map.chapter - 1
			end
		elseif waveID > minID and waveID <= maxID then
			return map.chapter
		end
	end
end

function QSunWar:_dispatchAll()
	if not self._dispatchTBl or table.nums(self._dispatchTBl) == 0 then return end
	-- local p = {curMapID = self._currentMapID, nextMapID = self._nextMapID, waveID = self._currentWaveID, event = self._dispatchTBl}
	-- QPrintTable(p)
	local tbl = {}
	for _, name in pairs(self._dispatchTBl) do
		if not tbl[name] then
			self:dispatchEvent({name = name})
			tbl[name] = 0
		end
	end
	self._dispatchTBl = {}
end

function QSunWar:_checkSunWarUnlock()
	return app.unlock:getUnlockSunWar()
end

--[[
	xurui: 检查某个关卡是否可以扫荡
]]
function QSunWar:checkSunWarWaveCanFastFight(waveId)
	local startWave = self:getStartWaveID()
	local lastWaveID = self:getfurthestFightingWaveID()
	local currentWaveID = self:getCurrentWaveID()
    -- local isMaxWave = remote.sunWar:isLastMapLastWaveByWaveID( lastWaveID )
	-- if isMaxWave then
	-- 	return true 
	-- end
	if lastWaveID - startWave >= 9 then
		if startWave + 9 > waveId and waveId >= currentWaveID then
			return true 
		end
	end
	return false
end

--[[
	xurui: 检查某个关卡是否可以自动战斗
]]
function QSunWar:checkSunWarWaveCanAutoFight()
	return app.unlock:checkLock("UNLOCK_BATTLE_CLEANOUT")
end

--[[
	是否显示复活小红点, 这个逻辑只有登入拉数据的时候，【【【跑一次】】】。
]]
function QSunWar:_checkIsNeedRedPointAtRevive()
	local count = self:getCanReviveCount()

	if count == 0 then 
		self._isNeedRedPointAtRevive = false 
		return
	end

	local heroInfo = self:getMyHeroInfo()
    for _, hero in pairs(heroInfo) do
        if hero.currHp ~= nil and hero.currHp <= 0 then
        	self._isNeedRedPointAtRevive = true
        	return
        end
    end 

	self._isNeedRedPointAtRevive = false
end

--[[
	是否显示宝箱小红点, 这个逻辑只有登入拉数据的时候，【【【跑一次】】】。
]]
function QSunWar:_checkIsNeedRedPointAtChest()
	local lastPassedWave = self:getLastPassedWave()
	local mapID = self:_getMapIDByWaveID(lastPassedWave)
	local mapInfo = self:getMapInfoByMapID( mapID )
	local chestInfo = self:getChestInfo()

	local totalCount = 0
	local openCount = 0
	for _, w in pairs( mapInfo.waves ) do
		if w.wave <= lastPassedWave then
			if w.chest_id then
				totalCount = totalCount + 1
				for _, id in pairs( chestInfo ) do
					if id == w.wave then
						openCount = openCount + 1
						break
					end
				end
			end
		end
	end
	-- print(openCount, totalCount)
	if openCount < totalCount then
		-- 最后一个箱子不能领取
		if mapID == 200 and openCount == 2 then
	    	self._isNeedRedPointAtChest = false
		else
	    	self._isNeedRedPointAtChest = true
	    end
	else
		self._isNeedRedPointAtChest = false
	end
end

------------------------------ 协议 ------------------------------

function QSunWar:requestSunWarFastFight(battleType, fightWave, isSecretary, success, fail)
	local battlefieldQuickFightRequest = {fightWave = fightWave, isSecretary = isSecretary}
	local gfQuickRequest = {battleType = battleType,battlefieldQuickFightRequest = battlefieldQuickFightRequest}
	local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
	app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, function(response)
			if response then
				self:responseHandler(response)
			end
			if success then
				success(response)
			end
		end, function (response)
			if fail then
				fail(response)
			end
		end)
end

return QSunWar
