--
-- Author: wk -todo need rebuild
-- Date: 2015-01-23 09:57:47
--
local QBaseModel = import("..models.QBaseModel")
local QArena = class("QArena",QBaseModel)
local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QTutorialDirector = import("..tutorial.QTutorialDirector")

QArena.EVENT_UPDATE = "QARENA_EVENT_UPDATE"
QArena.EVENT_UPDATE_WORSHIP = "EVENT_UPDATE_WORSHIP"
QArena.EVENT_UPDATE_SELF = "QARENA_EVENT_UPDATE_SELF"
QArena.EVENT_UPDATE_TEAM = "QARENA_EVENT_UPDATE_TEAM"
QArena.EVENT_SELF_RANK = "EVENT_SELF_RANK"
QArena.EVENT_SCORE_CHANGE = "EVENT_SCORE_CHANGE"
QArena.EVENT_SELF_RANK_UP = "EVENT_SELF_RANK_UP"
QArena.EVENT_SELF_RANK_UPDATE = "EVENT_SELF_RANK_UPDATE"
QArena.EVENT_COUNT_UPDATE = "EVENT_COUNT_UPDATE"

function QArena:ctor(options)
	QArena.super.ctor(self)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._pageTips = false
    self._dialogTips = false
    self._needRefresh = false	--同步阵容的特殊判断
	self.info = {}
	self.myInfo = {}
end

--创建时初始化事件
function QArena:didappear()
    self._markProxy = cc.EventProxy.new(remote.mark)
    self._markProxy:addEventListener(remote.mark.EVENT_UPDATE, handler(self, self.markUpdateHandler))
    if self._countScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._countScheduler)
    end
    self._totalCount = QStaticDatabase:sharedDatabase():getConfiguration().ARENA_FREE_FIGHT_COUNT.value
    self._cdTime = QStaticDatabase:sharedDatabase():getConfiguration().ARENA_CD.value
end

function QArena:disappear()
	if self._selfClockHandler ~= nil then
		scheduler.unscheduleGlobal(self._selfClockHandler)
		self._selfClockHandler = nil
	end
    if self._markProxy then
        self._markProxy:removeAllEventListeners()
    end
end

--设置本地默认防守阵容
function QArena:checkArenaDefenseTeam()
    -- body
    local actorIds = remote.teamManager:getActorIdsByKey(remote.teamManager.ARENA_DEFEND_TEAM)
    if q.isEmpty(actorIds) then
        local team = remote.teamManager:getDefaultTeam(remote.teamManager.ARENA_DEFEND_TEAM)
        local battleFormation = remote.teamManager:encodeBattleFormation(team)
        self:requestSetDefenseHero(battleFormation)

        local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.ARENA_DEFEND_TEAM)
        teamVO:setTeamDataWithBattleFormation(battleFormation) 
    end   
end

function QArena:openArena(defaultPos)
  --浮动提示条
  	if app.unlock:getUnlockArena(true) then
	    self:requestArenaInfo(function(data)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArena", 
				options = {arenaResponse = data.arenaResponse, defaultPos = defaultPos}}, {isPopCurrentDialog = true})
		end)
		return true
  	end
  	return false
end

--设置防御阵容
function QArena:requestSetDefenseHero(battleFormation, callback)
	app:getClient():setDefenseHero(battleFormation, function(data)
		self:checkSelfInWorship()
		self:dispatchEvent({name = QArena.EVENT_UPDATE_TEAM, data = self:madeReciveData("self")})
		if callback ~= nil then callback(data) end
	end)
end

--购买斗魂场次数
function QArena:requestBuyFighterCount(callBack)
	app:getClient():buyFightCountRequest(function (data)
		app.taskEvent:updateTaskEventProgress(app.taskEvent.ARENA_BUY_FIGHT_COUNT_EVENT, 1)
		if data.arenaResponse ~= nil and data.arenaResponse.mySelf ~= nil then
			self:updateSelf(data.arenaResponse.mySelf)
		end
		self:dispatchEvent({name = QArena.EVENT_UPDATE_SELF, data = self:madeReciveData("self")})
		if callBack ~= nil then callBack(data) end
	end)
end

--请求斗魂场全部信息
function QArena:requestArenaInfo(callBack, isManualRefresh)
	self.myInfo = {}
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
	local teamData = teamVO:getAllTeam()
	if q.isEmpty(teamData) then
		teamData = remote.teamManager:getDefaultTeam(remote.teamManager.ARENA_DEFEND_TEAM)
	end
	
	local responseFun = function (data)
		if data.arenaResponse ~= nil and data.arenaResponse.mySelf ~= nil then
			self:updateSelf(data.arenaResponse.mySelf)
		end
		if data.arenaResponse ~= nil and data.arenaResponse.worshipFighter ~= nil then
			self.worshipFighter = data.arenaResponse.worshipFighter
		end
		if data.arenaResponse ~= nil and data.arenaResponse.rivals ~= nil then
			self:updateRivals(data.arenaResponse.rivals)
		end
		if data.arenaResponse.arenaRefreshTimes ~= nil then
			self.arenaRefreshTimes = data.arenaResponse.arenaRefreshTimes
		end
		if data.arenaResponse.token ~= nil then
			remote.user:update({token = data.arenaResponse.token})
		end
		local data = self:madeReciveData()
		self:checkSelfInWorship()
		self:dispatchEvent({name = QArena.EVENT_UPDATE, data = data})
		if callBack ~= nil then callBack(data) end
	end
	self.isManualRefresh = isManualRefresh
	--2016/02/17改为每次打开都向后台请求对手信息，是否刷新交给后台判断
	
	local battleFormation = remote.teamManager:encodeBattleFormation(teamData)
	app:getClient():arenaRefresh(isManualRefresh, battleFormation, responseFun)
end



function QArena:getNeedRefreshMark()
	return self._needRefresh
end

function QArena:setNeedRefreshMark(needRefresh)
	self._needRefresh = needRefresh
end

--[[
	清空斗魂场对手
	再次调用斗魂场打开方法的时候如果没有对手信息就会重新刷新斗魂场
]]
-- function QArena:clearRivals()
-- 	self.rivals = nil
-- end

--[[
	获取刷新次数
]]
function QArena:getArenaRefreshCount()
	return self.arenaRefreshTimes or 0
end

function QArena:arenaWorshipRequest(userId, pos, callBack)
	app:getClient():arenaWorshipRequest(userId, pos, function (data)
		remote.user:addPropNumForKey("todayArenaWorshipCount")
        app.taskEvent:updateTaskEventProgress(app.taskEvent.ARENA_WORSHIP_EVENT, 1)
		remote.activity:updateLocalDataByType(708, 1)
		self.myInfo.todayWorshipPos = data.arenaWorshipResponse.todayWorshipPos
		callBack(data)
	end)
end

function QArena:updateWorship(data)
	remote.user:addPropNumForKey("money", data.arenaWorshipResponse.money)
	for _,fighter in ipairs(data.arenaWorshipResponse.fighter) do
		for index,fighter2 in ipairs(self.worshipFighter.fighter) do
			if fighter.userId == fighter2.userId then
				for key,value in pairs(fighter) do
					fighter2[key] = value
				end
				break
			end
		end
	end
	local data = self:madeReciveData()
	self:dispatchEvent({name = QArena.EVENT_UPDATE_WORSHIP, data = data})
end

function QArena:updateSelf(data)
	--保存老的排名信息
	if self.myInfo ~= nil and table.nums(self.myInfo) > 0 then
		self._oldSelf = clone(self.myInfo)
	end
	for key,value in pairs(data) do
		self.myInfo[key] = value
	end
	if self._oldSelf == nil and self.myInfo ~= nil and table.nums(self.myInfo) > 0 then
		self._oldSelf = clone(self.myInfo)
	end
	--如果排名更新则通知界面
	if self._oldSelf ~= nil and self._oldSelf.rank ~= nil and table.nums(self._oldSelf) > 0 then
		if self._oldSelf.rank < self.myInfo.rank then
			self._pageTips = true
			self._dialogTips = true
			self:dispatchEvent({name = QArena.EVENT_SELF_RANK})
		elseif self._oldSelf.rank > self.myInfo.rank then
			self:dispatchEvent({name = QArena.EVENT_SELF_RANK_UP, rank = self.myInfo.rank})
		end

		if self._oldSelf.rank <= self.myInfo.rank then
			self:dispatchEvent({name = QArena.EVENT_SELF_RANK_UPDATE, rank = self.myInfo.rank})
		end
	end
	--更新斗魂场排名到user信息中
	if self.myInfo.topRank ~= remote.user.arenaTopRank then
		remote.user:update({arenaTopRank = self.myInfo.topRank})
	end
	remote.user:update({arenaRank = self.myInfo.rank})
	if self._countScheduler ~= nil then
		scheduler.unscheduleGlobal(self._countScheduler)
		self._countScheduler = nil
	end
	self:setDailyScore(self.myInfo.arenaRewardIntegral)
	self:setDailyRewardInfo(self.myInfo.arenaRewardInfo)
	--更新斗魂场可攻打次数
	self._haveCount = false
	if (self.myInfo.fightCount or 0) < (self._totalCount+self.myInfo.fightBuyCount) then
		local passTime = (self.myInfo.lastFrozenTime or 0)/1000 + self._cdTime - q.serverTime()
		if passTime > 0 and self.myInfo.fightCount > 0 then
			self._countScheduler = scheduler.performWithDelayGlobal(function ()
				self._countScheduler = nil
				self._haveCount = true
				self:dispatchEvent({name = QArena.EVENT_COUNT_UPDATE})
			end, passTime)
		else
			if passTime <= 0 or (self.myInfo.fightCount or 0) == 0 then
				self._haveCount = true
				self:dispatchEvent({name = QArena.EVENT_COUNT_UPDATE})
			end
		end
	end
	--保存防守阵容 -- todo
    if self.myInfo then
    	local teamData = {{actorIds = {}, spiritIds = {}}, {actorIds = {}, skill = {}}, {actorIds = {}, skill = {}}, {actorIds = {}, skill = {}},{godarmIds = {}}}
        for k, v in pairs(self.myInfo.heros or {}) do 
        	table.insert(teamData[remote.teamManager.TEAM_INDEX_MAIN].actorIds, v.actorId)
        end
        for k, v in pairs(self.myInfo.subheros or {}) do 
        	table.insert(teamData[remote.teamManager.TEAM_INDEX_HELP].actorIds, v.actorId)
        end
        for k, v in pairs(self.myInfo.sub2heros or {}) do 
        	table.insert(teamData[remote.teamManager.TEAM_INDEX_HELP2].actorIds, v.actorId)
        end
        for k, v in pairs(self.myInfo.sub3heros or {}) do 
        	table.insert(teamData[remote.teamManager.TEAM_INDEX_HELP3].actorIds, v.actorId)
        end
        
        for k, v in pairs(self.myInfo.soulSpirit or {}) do 
        	table.insert(teamData[remote.teamManager.TEAM_INDEX_MAIN].spiritIds, v.id)
        end
        
        for k,v in pairs(self.myInfo.godArm1List or {}) do
        	table.insert(teamData[remote.teamManager.TEAM_INDEX_GODARM].godarmIds,v.id)
        end 
        -- if self.myInfo.soulSpirit ~= nil then
        -- 	table.insert(teamData[remote.teamManager.TEAM_INDEX_MAIN].spiritIds, self.myInfo.soulSpirit.id)
        -- end
        if self.myInfo.activeSubActorId ~= nil then
        	table.insert(teamData[remote.teamManager.TEAM_INDEX_SKILL].skill, self.myInfo.activeSubActorId)
        end
        if self.myInfo.activeSub2ActorId ~= nil then
        	table.insert(teamData[remote.teamManager.TEAM_INDEX_SKILL2].skill, self.myInfo.activeSub2ActorId)
        end
        if self.myInfo.activeSub3ActorId ~= nil then
        	table.insert(teamData[remote.teamManager.TEAM_INDEX_SKILL3].skill, self.myInfo.activeSub3ActorId)
        end
        local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.ARENA_DEFEND_TEAM)
        teamVO:setTeamData(teamData)
    end
end

--[[
	检查自己是不是在膜拜阵容里面
]]
function QArena:checkSelfInWorship()
	if self.worshipFighter ~= nil and self.worshipFighter.fighter ~= nil then
		for _,fighter in ipairs(self.worshipFighter.fighter) do
			if fighter.userId == self.myInfo.userId then
				fighter.heros = self.myInfo.heros
				fighter.subheros = self.myInfo.subheros
				fighter.sub2heros = self.myInfo.sub2heros
				fighter.sub3heros = self.myInfo.sub3heros
				fighter.soulSpirit = self.myInfo.soulSpirit
				fighter.force = self.myInfo.force
			end
		end
	end
end

--[[
	更新挑战对手
]]
function QArena:updateRivals(rivals)
	self.oldRivals = self.rivals
	self.rivals = rivals
end

--设置是否从战斗中出来
function QArena:setInBattle(b)
	self._isInBattle = b
end

--查询是否从战斗中出来
function QArena:getInBattle()
	return self._isInBattle == true
end

--[[
	设置最新的最高排名
]]
function QArena:setTopRankUpdate(rankInfo, rivalId)
	self.rankInfo = rankInfo
	self.rivalId = rivalId
end

--[[
	获取最新的最高排名
]]
function QArena:getTopRankUpdate()
	return self.rankInfo, self.rivalId
end

--[[
	初始化自己的排序
]]
function QArena:requestSelfInfo()
	if app.unlock:getUnlockArena() == true then
		app:getClient():arenaQueryFighterRequest(remote.user.userId, function (data)
			self:updateSelf(data.arenaResponse.fighter)
		end)
	end
end

--[[
	重置刷新时间
]]
function QArena:arenaClearFrozenTimeRequest(callBack)
	app:getClient():arenaClearFrozenTimeRequest(function (data)
		if data.arenaClearFrozenTimeResponse ~= nil then
			remote.user:update({token = data.arenaClearFrozenTimeResponse.token})
			self:updateSelf(data.arenaClearFrozenTimeResponse.fighter)
			self:dispatchEvent({name = QArena.EVENT_UPDATE_SELF, data = self:madeReciveData("self")})
		end
		if callBack ~= nil then
			callBack()
		end
	end)
end

--[[
	重置刷新时间
]]
function QArena:arenaSetDeclarationRequest(word, callBack)
	app:getClient():arenaSetDeclarationRequest(word, function (data)
		if data.arenaSetDeclarationResponse ~= nil then
			self:updateSelf(data.arenaSetDeclarationResponse.fighter)
		end
		if callBack ~= nil then
			callBack(data)
		end
	end)
end

--[[
	设置提示小红点
]]
function QArena:setTips(isPage, b)
	if isPage == true then
		if self._pageTips ~= b then
			self._pageTips = b
			self:dispatchEvent({name = QArena.EVENT_SELF_RANK})
		end
	else
		if self._dialogTips ~= b then
			self._dialogTips = b
			self:dispatchEvent({name = QArena.EVENT_SELF_RANK})
		end
	end
end

function QArena:getTips(isPage)
	if isPage == true then
		if self._haveCount == true then return true end
		return self._pageTips
	else
		return self._dialogTips
	end
end

-- 斗魂场小红点只取斗魂场挑战次数和可调整状态   --Author: xurui    --Date: 2015/10/27
function QArena:getArenaTips()
	local tips = false
	if remote.stores:checkFuncShopRedTips(SHOP_ID.arenaShop) then
		tips = true
	end
	if tips == true then return tips end

	tips = self:dailyRewardCanGet()
	if tips == true then return tips end
	
	tips = not remote.teamManager:checkTeamStormIsFull(remote.teamManager.ARENA_DEFEND_TEAM)
	return tips
end

--更新标志位后 拉取个人信息
--2016-4-5修改为拉取所有斗魂场信息
function QArena:markUpdateHandler()
    if remote.mark:getMark(remote.mark.MARK_ARENA) == 1 then
		-- app:getClient():arenaQueryFighterRequest(remote.user.userId, function (data)
		-- 	self:updateSelf(data.arenaResponse.fighter)
		-- end)
		self:requestArenaInfo()
    end
end

function QArena:updateArenaMoney(count)
	if self.myInfo ~= nil then
		self.myInfo.arenaMoney = count
	end
end

function QArena:madeReciveData(type)
	local data = {}
	data.arenaResponse = {}
	data.arenaResponse.worshipFighter = self.worshipFighter
	if type == nil or type == "self" then
		data.arenaResponse.mySelf = self.myInfo
	end
	if type == nil or type == "rivals" then
		-- data.arenaResponse.rivals = self.rivals
		data.arenaResponse.rivals = {}
		for _,fighter in ipairs(self.rivals) do
			table.insert(data.arenaResponse.rivals, fighter)
		end
		table.insert(data.arenaResponse.rivals, self.myInfo)
		table.sort(data.arenaResponse.rivals, function (a,b)
			if a.rank and b.rank and a.rank ~= b.rank then
				return a.rank < b.rank
			end
			return a.userId > b.userId
		end)
	end

	data.arenaResponse.oldRivals = {}
	if self.oldRivals ~= nil then
		for _,fighter in ipairs(self.oldRivals) do
			table.insert(data.arenaResponse.oldRivals, fighter)
		end
		if self._oldSelf.userId and self._oldSelf.rank then
			table.insert(data.arenaResponse.oldRivals, self._oldSelf)
		end
		table.sort(data.arenaResponse.oldRivals, function (a,b)
			if a.rank ~= b.rank then
				return a.rank < b.rank
			end
			return a.userId > b.userId
		end)
	end
	data.arenaResponse.isManualRefresh = self.isManualRefresh
	return data
end

--[[
	刷新对手玩家的宣言
]]
function QArena:refreshWordById(userId, word)
	for _,value in ipairs(self.rivals) do
		if value.userId == userId then
			value.declaration = word
		end
	end
end

--设置每日积分
function QArena:setDailyScore(score)
	self._dailyScore = score
end

--获取每日积分
function QArena:getDailyScore()
	return self._dailyScore or 0
end

--设置每日积分奖励领取信息
function QArena:setDailyRewardInfo(arenaRewardInfo)
	self._arenaRewardInfo = arenaRewardInfo
	self:dispatchEvent({name = QArena.EVENT_SCORE_CHANGE})
end
--设置每日积分奖励领取信息
function QArena:resetDailyRewardInfo()
	self.myInfo.arenaRewardInfo = {}
	self:setDailyRewardInfo(self.myInfo.arenaRewardInfo)
end

--获取每日积分奖励领取信息
function QArena:dailyRewardInfoIsGet(rewardId)
	if self._arenaRewardInfo ~= nil then
		for _,id in ipairs(self._arenaRewardInfo) do
			if id == rewardId then
				return true
			end
		end
	end
	return false
end

--每日积分是否有可领取的
function QArena:dailyRewardCanGet()
	local configs = QStaticDatabase:sharedDatabase():getArenaScoreAwardsByLevel(remote.user.dailyTeamLevel)
	for _,value in ipairs(configs) do
		if self:dailyRewardInfoIsGet(value.ID) == false and value.condition <= self:getDailyScore() then
			return true
		end
	end
	return false
end

--请求领取每日积分奖励
function QArena:ArenaIntegralRewardRequest(box_ids, success, fail)
    local request = {api = "ARENA_INTEGRAL_REWARD", arenaIntegralRewardRequest = {box_ids = box_ids}}
    app:getClient():requestPackageHandler("ARENA_INTEGRAL_REWARD", request, success, fail)
end

--计算挑战该对手自己获取多少斗魂场币
function QArena:getArenaMoneyByRivals(pos, rank)
	if pos == nil then return end
	rank = math.min(rank, (self.myInfo.rank or 10009))
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	if config["ARENA_NPC"..pos] ~= nil then
		local rate = config["ARENA_NPC"..pos].value
		local rankItemInfo = QStaticDatabase:sharedDatabase():getAreanRewardConfigByRank(rank, remote.user.level)
		local arenaMoney = math.floor(rankItemInfo.victory * rate)
		arenaMoney = math.floor(arenaMoney + 1 * ((math.floor((remote.user.level - 10) / 20)) * 5 + 30))
		return math.floor(arenaMoney * 2)
	end
	return 0
end

--战斗开始前检查排名
function QArena:arenaFightStartCheckRequest(selfUserId, selfPos, rivalUserId, rivalPos, success, fail)
	local arenaFightStartCheckRequest = {selfUserId = selfUserId, selfPos = selfPos, rivalUserId = rivalUserId, rivalPos = rivalPos}
	local gfStartCheckRequest = {battleType = BattleTypeEnum.ARENA,arenaFightStartCheckRequest = arenaFightStartCheckRequest}	
	local request = {api = "GLOBAL_FIGHT_START_CHECK", gfStartCheckRequest = gfStartCheckRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START_CHECK", request, success, fail)
end

return QArena