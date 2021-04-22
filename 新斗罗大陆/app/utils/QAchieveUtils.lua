--
-- Author: wkwang
-- Date: 2014-11-15 18:17:28
-- 成就类
--
local QBaseModel = import("..models.QBaseModel")
local QAchieveUtils = class("QAchieveUtils",QBaseModel)

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QVIPUtil = import("..utils.QVIPUtil")

QAchieveUtils.MISSION_COMPLETE = 100	--标志任务完成并上交
QAchieveUtils.MISSION_DONE = 99	--标志任务完成并上交
QAchieveUtils.MISSION_NONE = 0	--标志任务没有任何进展

QAchieveUtils.EVENT_UPDATE = "EVENT_UPDATE"
QAchieveUtils.EVENT_STATE_UPDATE = "EVENT_STATE_UPDATE"

QAchieveUtils.DEFAULT = "DEFAULT" --默认的推荐类型
QAchieveUtils.TYPE_HERO = "TYPE_HERO" --魂师相关
QAchieveUtils.TYPE_INSTANCE = "TYPE_INSTANCE" --副本相关
QAchieveUtils.TYPE_ARENA = "TYPE_ARENA" --斗魂场相关
QAchieveUtils.TYPE_USER = "TYPE_USER" --玩家基本属性
QAchieveUtils.TYPE_INVASION = "TYPE_INVASION" --要塞远征
QAchieveUtils.TYPE_SILVER = "TYPE_SILVER" --魂兽森林
QAchieveUtils.TYPE_BLACKROCK = "TYPE_BLACKROCK" --黑石塔
QAchieveUtils.TYPE_MARITIME = "TYPE_MARITIME" --海商
QAchieveUtils.TYPE_SOULSPIRIT = "TYPE_SOULSPIRIT" --魂灵
QAchieveUtils.TYPE_GODARM = "TYPE_GODARM" --神器
QAchieveUtils.TYPE_TOTEMCHALLEGE = "TYPE_TOTEMCHALLEGE" --圣柱
QAchieveUtils.TYPE_OFFERREWARD = "TYPE_OFFERREWARD"	--宗门派遣

function QAchieveUtils:ctor()
	QAchieveUtils.super.ctor(self)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._achieves = {}
	self._achievesFuns = {}
	self.missedAchievements = {}
	self.achieveDone = false
	-- self.achievePoint = 0

	self._heroList = {1001, 1002, 1003, 1004, 1022, 1032, 1033, 1034, 1035, 1036, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047, 1048, 1100, 1110, 1120, 1190, 1140, 1150, 1151, 1160, 1081, 1086}
	self._instanceList = {1005, 1006, 1007, 1048}
	self._userList = {1011, 1012, 1013, 1014, 1015, 1016, 1009, 1010, 1030,	1031, 1029, 1019, 1020, 1018, 1017, 1021, 1025, 1026, 1027, 1028, 1024, 1083, 1084, 1085, 1130, 1310, 1320, 1330}
	self._invasionList = {1049, 1050}
	self._silverList = {1060}
	self._blackrockList = {1070, 1090}
	self._maritimeList = {1080}
	self._soulSpiritList = {1082,1088}
	self._godarmList = {1089}
	self._totemChallegeList = {1091,1092}
	self._offerRewardList = {1095}

	self:registerHandlerFun(1001, handler(self, self.heroCompositeHandler))
	self:registerHandlerFun(1002, handler(self, self.heroUpGradeHandler))
	self:registerHandlerFun(1003, handler(self, self.heroBreakthroughHandler))
	self:registerHandlerFun(1004, handler(self, self.heroGradeStarHandler))
	self:registerHandlerFun(1005, handler(self, self.instancePassHandler))
	self:registerHandlerFun(1006, handler(self, self.dungeonPassHandler))
	self:registerHandlerFun(1007, handler(self, self.dungeonPassHandler))
	self:registerHandlerFun(1009, handler(self, self.instancePassCountHandler))
	self:registerHandlerFun(1010, handler(self, self.eliteInstancePassCountHandler))
	self:registerHandlerFun(1011, handler(self, self.teamLevelHandler))
	self:registerHandlerFun(1012, handler(self, self.buyMoneyHandler))
	self:registerHandlerFun(1013, handler(self, self.buyEnergyHandler))
	self:registerHandlerFun(1014, handler(self, self.buySliverHandler))
	self:registerHandlerFun(1015, handler(self, self.buyGoldHandler))
	self:registerHandlerFun(1016, handler(self, self.buyTokenHandler))
	self:registerHandlerFun(1017, handler(self, self.arenaBattleTopRankHandler))
	self:registerHandlerFun(1018, handler(self, self.arenaBattleCountHandler))
	self:registerHandlerFun(1019, handler(self, self.thunderIntancePassCountHandler))
	self:registerHandlerFun(1020, handler(self, self.thunderIntanceStarHandler))
	self:registerHandlerFun(1021, handler(self, self.towerIntanceLayerHandler))
	self:registerHandlerFun(1022, handler(self, self.heroForceHandler))
	self:registerHandlerFun(1024, handler(self, self.vipLevelHandler))	
	self:registerHandlerFun(1025, handler(self, self.sunwellMoneyHandler))
	self:registerHandlerFun(1026, handler(self, self.unionMoneyHandler))
	self:registerHandlerFun(1027, handler(self, self.allMoneyHandler))	
	self:registerHandlerFun(1028, handler(self, self.allTokenHandler))	
	self:registerHandlerFun(1029, handler(self, self.timeMachineHandler))	
	self:registerHandlerFun(1030, handler(self, self.instanceAllStarHandler))
	self:registerHandlerFun(1031, handler(self, self.eliteInstanceAllStarHandler))
	self:registerHandlerFun(1032, handler(self, self.jewelry1StrengthHandler))	
	self:registerHandlerFun(1033, handler(self, self.jewelry1StrengthHandler))
	self:registerHandlerFun(1034, handler(self, self.jewelry2StrengthHandler))
	self:registerHandlerFun(1035, handler(self, self.jewelry2StrengthHandler))	
	self:registerHandlerFun(1036, handler(self, self.jewelry1BreakthroughHandler))
	self:registerHandlerFun(1037, handler(self, self.jewelry1BreakthroughHandler))
	self:registerHandlerFun(1038, handler(self, self.jewelry2BreakthroughHandler))
	self:registerHandlerFun(1039, handler(self, self.jewelry2BreakthroughHandler))	
	self:registerHandlerFun(1040, handler(self, self.jewelry1MagicHandler))	
	self:registerHandlerFun(1041, handler(self, self.jewelry1MagicHandler))	
	self:registerHandlerFun(1042, handler(self, self.jewelry2MagicHandler))	
	self:registerHandlerFun(1043, handler(self, self.jewelry2MagicHandler))	
	self:registerHandlerFun(1044, handler(self, self.equipmentMagicHandler))
	self:registerHandlerFun(1045, handler(self, self.equipmentMagicHandler))	
	self:registerHandlerFun(1046, handler(self, self.equipmentStrengthHandler))
	self:registerHandlerFun(1047, handler(self, self.equipmentStrengthHandler))	
	self:registerHandlerFun(1048, handler(self, self.teamForceHandler))	
	self:registerHandlerFun(1049, handler(self, self.invasionMaxHurtHandler))	
	self:registerHandlerFun(1050, handler(self, self.invasionAttackTotalHandler))	
	self:registerHandlerFun(1060, handler(self, self.silverMineTotalHandler))	
	self:registerHandlerFun(1070, handler(self, self.blackrockScoreHandler))
	self:registerHandlerFun(1080, handler(self, self.maritimeTransportHandler))
	self:registerHandlerFun(1081, handler(self, self.heroMagicHerbHandler))
	self:registerHandlerFun(1082, handler(self, self.soulSpiritHandler))
	self:registerHandlerFun(1088, handler(self, self.soulSpiritOccultHandler))
	self:registerHandlerFun(1083, handler(self, self.sotoTeamTopRankHandler))
	self:registerHandlerFun(1084, handler(self, self.sotoTeamFightCountHandler))
	self:registerHandlerFun(1085, handler(self, self.mountSoulGuideLevelHandler))
	self:registerHandlerFun(1090, handler(self, self.blackrockHelpHandler))
	self:registerHandlerFun(1100, handler(self, self.heroGlyphHandler))
	self:registerHandlerFun(1110, handler(self, self.heroZuoqiHandler))
	self:registerHandlerFun(1120, handler(self, self.artifactGradeHandler))
	self:registerHandlerFun(1130, handler(self, self.societyUnionDragonWarHandler))
	self:registerHandlerFun(1140, handler(self, self.heroSparLevelHandler))
	self:registerHandlerFun(1150, handler(self, self.heroSparGradeHandler))
	self:registerHandlerFun(1151, handler(self, self.heroSsSparGradeHandler))
	self:registerHandlerFun(1160, handler(self, self.heroGemstonesHandler))
	self:registerHandlerFun(1190, handler(self, self.artifactLevelHandler))
	self:registerHandlerFun(1310, handler(self, self.heroFullCorrectCountHandler)) 
	self:registerHandlerFun(1320, handler(self, self.heroTotalCorrectCountHandler))
	self:registerHandlerFun(1330, handler(self, self.metalCityTotalFightCountHandler))
	self:registerHandlerFun(1086, handler(self, self.heroSSGemstonesHandler))
	self:registerHandlerFun(1089, handler(self, self.godarmStrengthenCountHandler))
	self:registerHandlerFun(1091, handler(self, self.toteamChallegeHardCountHandler))
	self:registerHandlerFun(1092, handler(self, self.toteamChallegeCountHandler))
	self:registerHandlerFun(1095, handler(self, self.offerRewardChallegeCountHandler))
end

--初始化成就
function QAchieveUtils:init()
	local achieveConfig = clone(QStaticDatabase:sharedDatabase():getTask())
	for _,achieve in pairs(achieveConfig) do
		achieve.index = tostring(achieve.index)
		if achieve.module == "成就" then
			local achieveInfo = self:getAchieveById(achieve.index, true)
			achieveInfo.config = achieve
			if achieveInfo.state == nil then
				achieveInfo.state = QAchieveUtils.MISSION_NONE
				achieveInfo.stepNum = 0
			end
			if achieveInfo.isShow == nil then
				achieveInfo.isShow = false
			end
			self._achieves[achieve.index] = achieveInfo
		end
	end

	--默认第一个成就是可以显示
	for _,achieveInfo in pairs(self._achieves) do
		if self:getPreAchieveById(achieveInfo.config.index) == nil then
			achieveInfo.isShow = true
		end
	end

	self._remoteEventProxy = cc.EventProxy.new(remote)
    self._remoteEventProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.updateAchievesForHero))
    self._remoteEventProxy:addEventListener(remote.DUNGEON_UPDATE_EVENT, handler(self, self.updateAchievesForDungeon))

	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.updateAchievesForUser))

	self._invasionEventProxy = cc.EventProxy.new(remote.invasion)
    self._invasionEventProxy:addEventListener(remote.invasion.EVENT_UPDATE, handler(self, self.updateAchievesForInvasion))

	self._silverMineProxy = cc.EventProxy.new(remote.silverMine)
    self._silverMineProxy:addEventListener(remote.silverMine.MY_INFO_UPDATE, handler(self, self.updateSilverMineHandler))

	self._blackrockProxy = cc.EventProxy.new(remote.blackrock)
    self._blackrockProxy:addEventListener(remote.blackrock.EVENT_UPDATE_MYINFO, handler(self, self.updateBlackRockHandler))

	self._maritimeProxy = cc.EventProxy.new(remote.maritime)
    self._maritimeProxy:addEventListener(remote.maritime.EVENT_UPDATE_MYINFO, handler(self, self.updateMaritimeHandler))

    self._sparProxy = cc.EventProxy.new(remote.spar)
    self._sparProxy:addEventListener(remote.spar.EVENT_SPAR_UPDATE, handler(self, self.updateAchievesForHero))

    self._gemstoneProxy = cc.EventProxy.new(remote.gemstone)
    self._gemstoneProxy:addEventListener(remote.gemstone.EVENT_UPDATE, handler(self, self.updateAchievesForHero))

    self._mountProxy = cc.EventProxy.new(remote.mount)
    self._mountProxy:addEventListener(remote.mount.EVENT_UPDATE, handler(self, self.updateAchievesForHero))
    self._mountProxy:addEventListener(remote.mount.EVENT_MOUNT_GRADE_UPDATE, handler(self, self.updateAchievesForUser))

    self._magicHerbProxy = cc.EventProxy.new(remote.magicHerb)
    self._magicHerbProxy:addEventListener(remote.magicHerb.EVENT_MAGIC_HERB_ACHIEVE_UPDATE, handler(self, self.updateAchievesForHero))

    self._soulSpiritProxy = cc.EventProxy.new(remote.soulSpirit)
    self._soulSpiritProxy:addEventListener(remote.soulSpirit.EVENT_SOUL_SPIRIT_ACHIEVE_UPDATE, handler(self, self.updateSoulSpiritHandler))

    self._godardProxy = cc.EventProxy.new(remote.godarm)
    self._godardProxy:addEventListener(remote.godarm.GODARM_EVENT_UPDATE, handler(self, self.updateGodarmHandler))

    self._totemChallegeProxy = cc.EventProxy.new(remote.totemChallenge)
	self._totemChallegeProxy:addEventListener(remote.totemChallenge.UPDATE_ACHIEVEMENT_EVENT, handler(self, self.updateTotemChallegeHandler))
	
	self._offerRewardProxy = cc.EventProxy.new(remote.offerreward)
	self._offerRewardProxy:addEventListener(remote.offerreward.EVENT_REFRESH, handler(self, self.updateOfferRewardChallegeHandler))
end

function QAchieveUtils:disappear()
	if self._remoteEventProxy ~= nil then
    	self._remoteEventProxy:removeAllEventListeners()
    	self._remoteEventProxy = nil
    end
	if self._userEventProxy ~= nil then
    	self._userEventProxy:removeAllEventListeners()
    	self._userEventProxy = nil
    end
	if self._invasionEventProxy ~= nil then
    	self._invasionEventProxy:removeAllEventListeners()
    	self._invasionEventProxy = nil
    end
	if self._silverMineProxy ~= nil then
    	self._silverMineProxy:removeAllEventListeners()
    	self._silverMineProxy = nil
    end
    if self._maritimeProxy ~= nil then
    	self._maritimeProxy:removeAllEventListeners()
    	self._maritimeProxy = nil
    end
	if self._sparProxy ~= nil then
    	self._sparProxy:removeAllEventListeners()
    	self._sparProxy = nil
    end
    if self._gemstoneProxy ~= nil then
    	self._gemstoneProxy:removeAllEventListeners()
    	self._gemstoneProxy = nil
    end
    if self._mountProxy ~= nil then
    	self._mountProxy:removeAllEventListeners()
    	self._mountProxy = nil
    end
    if self._magicHerbProxy ~= nil then
    	self._magicHerbProxy:removeAllEventListeners()
    	self._magicHerbProxy = nil
    end

    if self._soulSpiritProxy ~= nil then
    	self._soulSpiritProxy:removeAllEventListeners()
    	self._soulSpiritProxy = nil
    end

    if self._godardProxy ~= nil then
    	self._godardProxy:removeAllEventListeners()
    	self._godardProxy = nil
    end  

    if self._totemChallegeProxy ~= nil then
    	self._totemChallegeProxy:removeAllEventListeners()
    	self._totemChallegeProxy = nil
	end     
	
	if self._offerRewardProxy ~= nil then
		self._offerRewardProxy:removeAllEventListeners()
    	self._offerRewardProxy = nil
	end
end

function QAchieveUtils:getAllAchieveList()
	local list = {}
	local heroList = self:getAchieveListByType(QAchieveUtils.TYPE_HERO)
	local instanceList = self:getAchieveListByType(QAchieveUtils.TYPE_INSTANCE)
	local arenaList = self:getAchieveListByType(QAchieveUtils.TYPE_ARENA)
	local userList = self:getAchieveListByType(QAchieveUtils.TYPE_USER)
	local defaultList = self:getAchieveListByType(QAchieveUtils.DEFAULT)
	if heroList and next(heroList) ~= nil then
		for _,v in ipairs(heroList) do
			table.insert(list, v)
		end
	end

	if instanceList and next(instanceList) ~= nil then
		for _,v in ipairs(instanceList) do
			table.insert(list, v)
		end
	end

	if arenaList and next(arenaList) ~= nil then
		for _,v in ipairs(arenaList) do
			table.insert(list, v)
		end
	end

	if userList and next(userList) ~= nil then
		for _,v in ipairs(userList) do
			table.insert(list, v)
		end
	end

	if defaultList and next(defaultList) ~= nil then
		for _,v in ipairs(defaultList) do
			table.insert(list, v)
		end
	end
	
    --去重
    local finalList = {}
    for k,v in ipairs(list) do
        if(#finalList == 0) then
            finalList[1]=v;
        else
            local index = 0
            for i=1,#finalList do
                if(v.config.index == finalList[i].config.index) then
                    break
                end
                index = index + 1
            end
            if(index == #finalList) then
                finalList[#finalList + 1] = v;
            end
        end
    end

	return finalList
end

--获取成就列表通过类型
function QAchieveUtils:getAchieveListByType(type)
	local list = {}
	local label = ""
	if type == QAchieveUtils.TYPE_HERO then
		label = "魂师"
	elseif type == QAchieveUtils.TYPE_INSTANCE then
		label = "副本"
	elseif type == QAchieveUtils.TYPE_ARENA then
		label = "斗魂场"
	elseif type == QAchieveUtils.TYPE_USER then
		label = "其他"
	end

	for _,achieveInfo in pairs(self._achieves) do
		if app.unlock:checkLevelUnlock(achieveInfo.config.show_level) and app.unlock:checkDungeonUnlock(achieveInfo.config.unlock) then
			if type ~= QAchieveUtils.DEFAULT and achieveInfo.isShow == true then
				if achieveInfo.config.label == label then
					table.insert(list, achieveInfo)
				end
			else
				if app.unlock:checkLevelUnlock(achieveInfo.config.display_level) and achieveInfo.isShow == true  and achieveInfo.state ~= QAchieveUtils.MISSION_COMPLETE then
					table.insert(list, achieveInfo)
				end
			end
		end
	end
	table.sort(list,function (a,b)
			if a.state ~= b.state then
	        	if a.state == remote.achieve.MISSION_DONE or b.state == remote.achieve.MISSION_COMPLETE then
	        		return true
        		elseif b.state == remote.achieve.MISSION_DONE or a.state == remote.achieve.MISSION_COMPLETE then
        			return false
	        	end
	        end
	        return a.config.index < b.config.index
        end)
	return list
end

--获取成就列表已完成数量和总数
function QAchieveUtils:getAchieveNumByType(type)
	local label = ""
	if type == QAchieveUtils.TYPE_HERO then
		label = "魂师"
	elseif type == QAchieveUtils.TYPE_INSTANCE then
		label = "副本"
	elseif type == QAchieveUtils.TYPE_ARENA then
		label = "斗魂场"
	elseif type == QAchieveUtils.TYPE_USER then
		label = "其他"
	end
	local completeNum = 0
	local totalNum = 0
	for _,achieveInfo in pairs(self._achieves) do
		if app.unlock:checkLevelUnlock(achieveInfo.config.show_level) and app.unlock:checkDungeonUnlock(achieveInfo.config.unlock) then
			if type ~= QAchieveUtils.DEFAULT and achieveInfo.isShow == true then
				if achieveInfo.config.label == label then
					if achieveInfo.state == remote.achieve.MISSION_COMPLETE then
						completeNum = completeNum + 1
					end
					totalNum = totalNum + 1
				end
			else
				if app.unlock:checkLevelUnlock(achieveInfo.config.display_level) and achieveInfo.isShow == true  and achieveInfo.state ~= QAchieveUtils.MISSION_COMPLETE then
					if achieveInfo.state == remote.achieve.MISSION_COMPLETE then
						completeNum = completeNum + 1
					end
					totalNum = totalNum + 1
				end
			end
		end
	end
	return completeNum,totalNum
end

--[[
	更新成就完成
	如果某成就已经完成则该成就的下一个成就变为可显示
]]
function QAchieveUtils:updateComplete(data)
	local completeList = data or {}
	local isUpdate = false
	-- self.achievePoint = 0
	for _,value in pairs(completeList) do
		value = tostring(value)
		if value ~= "" and self._achieves[value] ~= nil then
			-- self:getAchieveById(value, false) --防止为空
			self._achieves[value].state = QAchieveUtils.MISSION_COMPLETE
			self.missedAchievements[tostring(value)] = nil
			-- self.achievePoint = self.achievePoint + (self._achieves[value].config.count or 0)
			local nextAchieveInfo = self:getNextAchieveById(value)
			if nextAchieveInfo ~= nil then
				nextAchieveInfo.isShow = true
			end
			isUpdate = true
		end
	end
	if isUpdate == true then
		self:dispatchEvent({name = QAchieveUtils.EVENT_UPDATE})
		self:checkAllAchieve()
	end
end

--[[
	更新成就已经达到的
]]
function QAchieveUtils:setMissedAchievements(missedAchievements)
	self.missedAchievements = {}
	for _,id in ipairs(missedAchievements) do
		self.missedAchievements[tostring(id)] = true
	end
	self:dispatchEvent({name = QAchieveUtils.EVENT_UPDATE})
end

--根据ID获取前一个成就配置
function QAchieveUtils:getPreAchieveById(id)
	local achieveInfo = self:getAchieveById(id)
	local preAchieveInfo = self:getAchieveById(tostring(tonumber(achieveInfo.config.index) - 1))
	if preAchieveInfo ~= nil and preAchieveInfo.config.task_type == achieveInfo.config.task_type then
		return preAchieveInfo
	end
	return nil
end

--根据ID获取后一个成就配置
function QAchieveUtils:getNextAchieveById(id)
	local achieveInfo = self:getAchieveById(id)
	local preAchieveInfo = self:getAchieveById(tostring(tonumber(achieveInfo.config.index) + 1))
	if preAchieveInfo ~= nil and preAchieveInfo.config.task_type == achieveInfo.config.task_type then
		return preAchieveInfo
	end
	return nil
end

--根据taskType获取该类别的所有成就
function QAchieveUtils:getAchieveListByTaskType(taskType)
	local list = {}
	for _,achieveInfo in pairs(self._achieves) do
		if achieveInfo.config.task_type == taskType then
			table.insert(list, achieveInfo)
		end
	end
	return list
end

--获取成就信息通过成就ID
function QAchieveUtils:getAchieveById(id, isCreat)
	if self._achieves[id] == nil and isCreat == true then
		self._achieves[id] = {}
	end
	return self._achieves[id]
end

--检查是否有完成的成就 如果有则中断检查 抛出事件
function QAchieveUtils:checkAllAchieve()
	for _,achieveInfo in pairs(self._achieves) do
		if achieveInfo.state == QAchieveUtils.MISSION_DONE then
			self:setAchieveDone(true)
			return true
		end
	end
	self:setAchieveDone(false)
	return false
end

--检查某类别下的成就是否完成
function QAchieveUtils:checkAchieveDoneForType(type)
	local label = ""
	if type == QAchieveUtils.TYPE_HERO then
		label = "魂师"
	elseif type == QAchieveUtils.TYPE_INSTANCE then
		label = "副本"
	elseif type == QAchieveUtils.TYPE_ARENA then
		label = "斗魂场"
	elseif type == QAchieveUtils.TYPE_USER then
		label = "其他"
	end

	for _,achieveInfo in pairs(self._achieves) do
		if app.unlock:checkLevelUnlock(achieveInfo.config.show_level) and app.unlock:checkDungeonUnlock(achieveInfo.config.unlock) then
			if type ~= QAchieveUtils.DEFAULT then
				if achieveInfo.config.label == label and achieveInfo.state == QAchieveUtils.MISSION_DONE then
					return true
				end
			else
				if app.unlock:checkLevelUnlock(achieveInfo.config.display_level) and achieveInfo.isShow == true and achieveInfo.state == QAchieveUtils.MISSION_DONE then
					return true
				end
			end
		end
	end
	return false
end

--获取成就是否完成
function QAchieveUtils:getAchieveIsDone(id)
	local achieveInfo = self:getAchieveById(id)
	if achieveInfo == nil then return false end
	return achieveInfo.state ~= QAchieveUtils.MISSION_NONE
end

--设置是否有成就完成
function QAchieveUtils:setAchieveDone(isDone)
	if self.achieveDone ~= isDone then
		self.achieveDone = isDone
		self:dispatchEvent({name = QAchieveUtils.EVENT_STATE_UPDATE})
	end
end

-----------------------------------------------------------------成就处理模块------------------------------------------------------------------

--[[
	注册成就的检查函数
]]
function QAchieveUtils:registerHandlerFun(taskType, handlerFun)
	self._achievesFuns[taskType] = handlerFun
end

-- 更新魂师相关成就
function QAchieveUtils:updateAchievesForHero()
	self:updateAchievesForType(QAchieveUtils.TYPE_HERO)
	self:checkAllAchieve()
end

-- 更新副本相关成就
function QAchieveUtils:updateAchievesForDungeon()
	self:updateAchievesForType(QAchieveUtils.TYPE_INSTANCE)
end

-- 更新用户属性相关成就
function QAchieveUtils:updateAchievesForUser()
	self:updateAchievesForType(QAchieveUtils.TYPE_USER)
end

-- 更新要塞相关成就
function QAchieveUtils:updateAchievesForInvasion()
	self:updateAchievesForType(QAchieveUtils.TYPE_INVASION)
end

-- 更新银魂兽区相关成就
function QAchieveUtils:updateSilverMineHandler( ... )
	self:updateAchievesForType(QAchieveUtils.TYPE_SILVER)
end

-- 更新黑石相关成就
function QAchieveUtils:updateBlackRockHandler( ... )
	self:updateAchievesForType(QAchieveUtils.TYPE_BLACKROCK)
end

-- 更新海商相关成就
function QAchieveUtils:updateMaritimeHandler( ... )
	self:updateAchievesForType(QAchieveUtils.TYPE_MARITIME)
end

-- 更新金属之城相关成就
function QAchieveUtils:updateMetalCityHandler( ... )
	self:updateAchievesForType(QAchieveUtils.TYPE_MARITIME)
end

-- 更新魂靈相关成就
function QAchieveUtils:updateSoulSpiritHandler( ... )
	self:updateAchievesForType(QAchieveUtils.TYPE_SOULSPIRIT)
end

-- 更新神器相关成就
function QAchieveUtils:updateGodarmHandler( ... )
	self:updateAchievesForType(QAchieveUtils.TYPE_GODARM)
end

-- 更新圣柱相关成就
function QAchieveUtils:updateTotemChallegeHandler( ... )
	self:updateAchievesForType(QAchieveUtils.TYPE_TOTEMCHALLEGE)
end

-- 更新宗门派遣成就
function QAchieveUtils:updateOfferRewardChallegeHandler( ... )
	self:updateAchievesForType(QAchieveUtils.TYPE_OFFERREWARD)
end

--[[
	通过自定义类别成就处理
]]
function QAchieveUtils:updateAchievesForType(type)
	local list = {}
	if type == QAchieveUtils.TYPE_HERO then
		list = self._heroList
	elseif type == QAchieveUtils.TYPE_INSTANCE then
		list = self._instanceList
	elseif type == QAchieveUtils.TYPE_USER then
		list = self._userList
	elseif type == QAchieveUtils.TYPE_INVASION then
		list = self._invasionList
	elseif type == QAchieveUtils.TYPE_SILVER then
		list = self._silverList
	elseif type == QAchieveUtils.TYPE_BLACKROCK then
		list = self._blackrockList
	elseif type == QAchieveUtils.TYPE_MARITIME then
		list = self._maritimeList
	elseif type == QAchieveUtils.TYPE_SOULSPIRIT then
		list = self._soulSpiritList
	elseif type == QAchieveUtils.TYPE_GODARM then
		list = self._godarmList
	elseif type == QAchieveUtils.TYPE_TOTEMCHALLEGE then
		list = self._totemChallegeList
	elseif type == QAchieveUtils.TYPE_OFFERREWARD then
		list = self._offerRewardList
	end
	for _,taskType in pairs(list) do
		self._achievesFuns[taskType](taskType)
	end
end

--根据配置中的Num判定是否完成
function QAchieveUtils:achieveDoneForNum(id)
	local achieveInfo = self:getAchieveById(id)
	if achieveInfo.state ~= QAchieveUtils.MISSION_COMPLETE then
		if app.unlock:checkLevelUnlock(achieveInfo.config.show_level) and app.unlock:checkDungeonUnlock(achieveInfo.config.unlock) then
			if self.missedAchievements[tostring(achieveInfo.config.index)] ~= nil or (achieveInfo.stepNum or 0) >= (achieveInfo.config.num or 0) then
				if achieveInfo.config.task_type ~= 1081 then
					-- 仙品成就不加入missedAchievements，因為可以重生，需要MISSION_DONE和MISSION_NONE之前切換
					self.missedAchievements[tostring(achieveInfo.config.index)] = true
				end
				achieveInfo.state = QAchieveUtils.MISSION_DONE
				achieveInfo.isShow = true
				self:setAchieveDone(true)
				return true
			end
		end
		achieveInfo.state = QAchieveUtils.MISSION_NONE
		local perAchieve = self:getPreAchieveById(achieveInfo.config.index)
		if perAchieve ~= nil and perAchieve.state ~= QAchieveUtils.MISSION_COMPLETE then
			achieveInfo.isShow = false
		end
	end
	return false
end

--魂师召唤
function QAchieveUtils:heroCompositeHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = #remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--魂师升级
function QAchieveUtils:heroUpGradeHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local heroInfo = remote.herosUtil:getHeroByID(actorId)
				if heroInfo.level >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--魂师突破
function QAchieveUtils:heroBreakthroughHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local heroInfo = remote.herosUtil:getHeroByID(actorId)
				if heroInfo.breakthrough >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--魂师升星
function QAchieveUtils:heroGradeStarHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local heroInfo = remote.herosUtil:getHeroByID(actorId)
				if heroInfo.grade >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--魂师战斗力
function QAchieveUtils:heroForceHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,actorId in pairs(heroList) do
		local heroInfo = remote.herosUtil:getHeroByID(actorId)
		local force = heroInfo.force or 0
		if force >= stepNum then
			stepNum = force
		end
	end
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--通关副本
function QAchieveUtils:instancePassHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local condition = ""
	local stepNum = 0
	for _,achieveInfo in pairs(list) do
		if condition ~= achieveInfo.config.condition then
			condition = achieveInfo.config.condition
			stepNum = 0
			local instanceList = remote.instance:getInstancesById(condition)
			for _,dungeonInfo in pairs(instanceList) do
				if dungeonInfo.info ~= nil and dungeonInfo.info.lastPassAt ~= nil and dungeonInfo.info.lastPassAt > 0 then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--通关关卡
function QAchieveUtils:dungeonPassHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local condition = ""
	local stepNum = 0
	local isPass = true
	for _,achieveInfo in pairs(list) do
		if condition ~= achieveInfo.config.condition then
			condition = achieveInfo.config.condition
			stepNum = 0
			isPass = remote.instance:checkIsPassByDungeonId(condition)
		end
		if isPass == true then
			stepNum = achieveInfo.config.num
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--累计普通副本通关次数
function QAchieveUtils:instancePassCountHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("addupDungeonPassCount")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--累计精英副本通关次数
function QAchieveUtils:eliteInstancePassCountHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("addupDungeonElitePassCount")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--普通本累计星星获得数量
function QAchieveUtils:instanceAllStarHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("c_allStarNormalPass")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--精英本累计星星获得数量
function QAchieveUtils:eliteInstanceAllStarHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("c_allStarElitePass")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--挑战雷电王座胜利次数
function QAchieveUtils:thunderIntancePassCountHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("thunderFightCount")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--挑战雷电王座最高星数
function QAchieveUtils:thunderIntanceStarHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("thunderHistoryMaxStar")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--挑战魂师大赛
function QAchieveUtils:towerIntanceLayerHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("towerMaxFloor")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--斗魂场挑战次数
function QAchieveUtils:arenaBattleCountHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("addupArenaFightCount")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--斗魂场排名
function QAchieveUtils:arenaBattleTopRankHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("arenaTopRank") or 0
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		local achieveInfo = self:getAchieveById(achieveInfo.config.index)
		if achieveInfo.state ~= QAchieveUtils.MISSION_COMPLETE then
			if achieveInfo.stepNum > 0 and achieveInfo.stepNum <= (achieveInfo.config.num or 0) then
				achieveInfo.state = QAchieveUtils.MISSION_DONE
				achieveInfo.isShow = true
				self:setAchieveDone(true)
			end
		end
	end
end

--活动试炼战斗胜利次数
function QAchieveUtils:timeMachineHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("allActivityDungeonFightCount")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--累计获得决战太阳井币
function QAchieveUtils:sunwellMoneyHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("allSunwellMoney")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--宗门累计获得宗门币
function QAchieveUtils:unionMoneyHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("allConsortiaMoney")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end


--战队等级
function QAchieveUtils:teamLevelHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("level")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--钻石换金
function QAchieveUtils:buyMoneyHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("addupBuyMoneyCount")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--购买能量
function QAchieveUtils:buyEnergyHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("addupBuyEnergyCount")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--购买银宝箱
function QAchieveUtils:buySliverHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("addupLuckydrawCount")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--购买金宝箱
function QAchieveUtils:buyGoldHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("addupLuckydrawAdvanceCount")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--累计充值
function QAchieveUtils:buyTokenHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("addupPurchasedToken")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--VIP等级
function QAchieveUtils:vipLevelHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = QVIPUtil:VIPLevel()
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--金魂币累计
function QAchieveUtils:allMoneyHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("allMoney")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--钻石累计
function QAchieveUtils:allTokenHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("giftToken") + remote.user:getPropForKey("getToken")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--戒指强化
function QAchieveUtils:jewelry1StrengthHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local uiHero = remote.herosUtil:getUIHeroByID(actorId)
				local equipmenInfo = uiHero:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1)
				if equipmenInfo ~= nil and (equipmenInfo.info.level or 0) >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--项链强化
function QAchieveUtils:jewelry2StrengthHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local uiHero = remote.herosUtil:getUIHeroByID(actorId)
				local equipmenInfo = uiHero:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY2)
				if equipmenInfo ~= nil and (equipmenInfo.info.level or 0) >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--戒指突破
function QAchieveUtils:jewelry1BreakthroughHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local uiHero = remote.herosUtil:getUIHeroByID(actorId)
				local equipmenInfo = uiHero:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1)
				if equipmenInfo ~= nil and (equipmenInfo.breakLevel or 0) >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--项链突破
function QAchieveUtils:jewelry2BreakthroughHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local uiHero = remote.herosUtil:getUIHeroByID(actorId)
				local equipmenInfo = uiHero:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY2)
				if equipmenInfo ~= nil and (equipmenInfo.breakLevel or 0) >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--戒指觉醒
function QAchieveUtils:jewelry1MagicHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local uiHero = remote.herosUtil:getUIHeroByID(actorId)
				local equipmenInfo = uiHero:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1)
				if equipmenInfo ~= nil and (equipmenInfo.info.enchants or 0) >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--项链觉醒
function QAchieveUtils:jewelry2MagicHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local uiHero = remote.herosUtil:getUIHeroByID(actorId)
				local equipmenInfo = uiHero:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY2)
				if equipmenInfo ~= nil and (equipmenInfo.info.enchants or 0) >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--装备觉醒
function QAchieveUtils:equipmentMagicHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local uiHero = remote.herosUtil:getUIHeroByID(actorId)
				for _,equipmentName in pairs(EQUIPMENT_TYPE) do
					if equipmentName ~= EQUIPMENT_TYPE.JEWELRY1 and equipmentName ~= EQUIPMENT_TYPE.JEWELRY2 then
						local equipmenInfo = uiHero:getEquipmentInfoByPos(equipmentName)
						if equipmenInfo ~= nil and (equipmenInfo.info.enchants or 0) >= conNum then
							stepNum = stepNum + 1
						end
					end
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--装备强化
function QAchieveUtils:equipmentStrengthHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local uiHero = remote.herosUtil:getUIHeroByID(actorId)
				for _,equipmentName in pairs(EQUIPMENT_TYPE) do
					if equipmentName ~= EQUIPMENT_TYPE.JEWELRY1 and equipmentName ~= EQUIPMENT_TYPE.JEWELRY2 then
						local equipmenInfo = uiHero:getEquipmentInfoByPos(equipmentName)
						if equipmenInfo ~= nil and (equipmenInfo.info.level or 0) >= conNum then 
							stepNum = stepNum + 1
						end
					end
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--小队战斗力
function QAchieveUtils:teamForceHandler(taskType)
	local stepNum = 0
	local heroList, count, maxForce = remote.herosUtil:getMaxForceHeros()
	stepNum = maxForce
	local list = self:getAchieveListByTaskType(taskType)
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--要塞中单次伤害达到
function QAchieveUtils:invasionMaxHurtHandler(taskType)
	local stepNum = 0
	local list = self:getAchieveListByTaskType(taskType)
	local selfInvasion = remote.invasion:getSelfInvasion()
	if selfInvasion ~= nil and selfInvasion.historyMaxHurt ~= nil then
		stepNum = selfInvasion.historyMaxHurt 
	end
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--要塞中攻打次数
function QAchieveUtils:invasionAttackTotalHandler(taskType)
	local stepNum = 0
	local list = self:getAchieveListByTaskType(taskType)
	local selfInvasion = remote.invasion:getSelfInvasion()
	if selfInvasion ~= nil and selfInvasion.allFightCount ~= nil then
		stepNum = selfInvasion.allFightCount  
	end
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--狩猎大师
function QAchieveUtils:silverMineTotalHandler(taskType)
	local stepNum = 0
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.silverMine:getTotalOccupySecs()
	stepNum = math.floor(stepNum/HOUR)
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--黑石塔
function QAchieveUtils:blackrockScoreHandler(taskType)
	local stepNum = 0
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.blackrock:getTotalScore()
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

function QAchieveUtils:blackrockHelpHandler(taskType)
	local stepNum = 0
	local list = self:getAchieveListByTaskType(taskType)
	local blackrockMyInfo = remote.blackrock:getMyInfo()
	local stepNum = 0
	if blackrockMyInfo ~= nil then
		stepNum = blackrockMyInfo.totalHelpPassCount or 0
	end
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--海商
function QAchieveUtils:maritimeTransportHandler(taskType)
	local stepNum = 0
	local list = self:getAchieveListByTaskType(taskType)
	local info = remote.maritime:getMyMaritimeInfo() or {}
	local stepNum = info.allMaritimeCount or 0
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

-- 体技
function QAchieveUtils:heroGlyphHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,actorId in pairs(heroList) do
		local heroInfo = remote.herosUtil:getHeroByID(actorId)
		for _, glyph in pairs(heroInfo.glyphs or {}) do
			stepNum = stepNum + glyph.level
		end
	end
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

-- 暗器
function QAchieveUtils:heroZuoqiHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local mounts = remote.mount:getMountList()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _, zuoqi in pairs(mounts) do
				if zuoqi.enhanceLevel >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

-- 武魂真身
function QAchieveUtils:artifactGradeHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,actorId in pairs(heroList) do
		local heroInfo = remote.herosUtil:getHeroByID(actorId)
		if heroInfo.artifact and heroInfo.artifact.artifactBreakthrough then
			stepNum = stepNum + heroInfo.artifact.artifactBreakthrough
		end
	end
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

function QAchieveUtils:artifactLevelHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local heroList = remote.herosUtil:getHaveHero()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,actorId in pairs(heroList) do
				local artifact = remote.herosUtil:getHeroByID(actorId).artifact
				if artifact and (artifact.artifactLevel or 0) >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

-- 巨龙之战
function QAchieveUtils:societyUnionDragonWarHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("allDragonWarMoney")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end	
end

-- 晶石强化
function QAchieveUtils:heroSparLevelHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local sparList = remote.spar:getAllSpars()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,spar in pairs(sparList) do
				if spar.level >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

-- 晶石升星
function QAchieveUtils:heroSparGradeHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local sparList = remote.spar:getAllSpars()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,spar in pairs(sparList) do
				local sparInfo = db:getItemByID(spar.itemId)
				if sparInfo.gemstone_quality >= remote.spar.SPAR_SS_QUALITY then
					-- SS及以上外骨
					if spar.grade >= conNum * 5 then
						stepNum = stepNum + 1
					end
				else
					-- 普通外骨
					if spar.grade + 1 >= conNum then
						stepNum = stepNum + 1
					end
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

-- SS晶石升星
function QAchieveUtils:heroSsSparGradeHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local sparList = remote.spar:getAllSpars()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,spar in pairs(sparList) do
				local sparInfo = db:getItemByID(spar.itemId)
				if sparInfo.gemstone_quality >= remote.spar.SPAR_SS_QUALITY then
					-- SS及以上外骨
					if spar.grade >= conNum * 5 then
						stepNum = stepNum + 1
					end
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

-- 宝石
function QAchieveUtils:heroGemstonesHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local gemstoneList = remote.gemstone:getAllGemstones()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,gemstone in pairs(gemstoneList) do
				if gemstone.level >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--SS魂骨成就
function QAchieveUtils:heroSSGemstonesHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local gemstoneList = remote.gemstone:getGemstonesByQuality(APTITUDE.S)
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,gemstone in pairs(gemstoneList) do
				if (gemstone.godLevel or 0) >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--神器强化等级成就
function QAchieveUtils:godarmStrengthenCountHandler(taskType )
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0	
	local godarmList = remote.godarm:getHaveGodarmList()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition
			stepNum = 0
			for _,godarmInfo in pairs(godarmList) do
				if (godarmInfo.level or 0) >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)		
	end
end

-- 宗门派遣
function QAchieveUtils:offerRewardChallegeCountHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.offerreward:getCompleteCount()
	for _, achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--圣柱挑战成就
function QAchieveUtils:toteamChallegeCountHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = 0
	local totemChallegeInfo = remote.totemChallenge:getTotemUserDungeonInfo()
	if totemChallegeInfo then
		stepNum = totemChallegeInfo.fightSuccessCount or 0
	end
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end	
end
--圣柱挑战困难成就
function QAchieveUtils:toteamChallegeHardCountHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = 0
	local totemChallegeInfo = remote.totemChallenge:getTotemUserDungeonInfo()
	if totemChallegeInfo then
		stepNum = totemChallegeInfo.hardCount or 0
	end
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end	
end
-- 仙品
function QAchieveUtils:heroMagicHerbHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local aptitude = 0
	local grade = 0
	local stepNum = 0
	local magicHerbItemList = remote.magicHerb:getMagicHerbItemList()
	for _, achieveInfo in pairs(list) do
		local conditionTbl = string.split(achieveInfo.config.condition, ";")
		if aptitude ~= tonumber(conditionTbl[1]) or grade ~= tonumber(conditionTbl[2]) then
			aptitude = tonumber(conditionTbl[1])
			grade = tonumber(conditionTbl[2])
			stepNum = 0
			for _, magicHerbItem in ipairs(magicHerbItemList) do
				local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItem.itemId)
				if magicHerbConfig.aptitude >= aptitude and magicHerbItem.grade >= grade then
					stepNum = stepNum + 1
				end
			end
			-- if stepNum > 0 then
			-- 	print(achieveInfo.config.desc, aptitude, grade, stepNum, achieveInfo.config.num, stepNum >= achieveInfo.config.num)
			-- end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

-- 魂灵
function QAchieveUtils:soulSpiritHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local mySoulSpiritHistoryList = remote.soulSpirit:getMySoulSpiritHistoryList()
	for _, achieveInfo in pairs(list) do
		local stepNum = 0
		for _, soulSpirit in ipairs(mySoulSpiritHistoryList) do
			if soulSpirit.level >= achieveInfo.config.condition then
				stepNum = stepNum + 1
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--魂灵秘术
function QAchieveUtils:soulSpiritOccultHandler( taskType )
	local list = self:getAchieveListByTaskType(taskType)
	local mySoulSpiritHistoryList = remote.soulSpirit:getMySoulSpiritHistoryList()
	for _, achieveInfo in pairs(list) do
		local stepNum = 0
		for _, soulSpirit in ipairs(mySoulSpiritHistoryList) do
			stepNum = stepNum + 1
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)		
	end
end
--云顶之战排名
function QAchieveUtils:sotoTeamTopRankHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("sotoTeamTopRank") or 0
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		local achieveInfo = self:getAchieveById(achieveInfo.config.index)
		if achieveInfo.state ~= QAchieveUtils.MISSION_COMPLETE then
			if achieveInfo.stepNum > 0 and achieveInfo.stepNum <= (achieveInfo.config.num or 0) then
				achieveInfo.state = QAchieveUtils.MISSION_DONE
				achieveInfo.isShow = true
				self:setAchieveDone(true)
			end
		end
	end
end

--云顶之战挑战次数
function QAchieveUtils:sotoTeamFightCountHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local stepNum = remote.user:getPropForKey("totalSotoTeamFightCount")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

--魂导科技点数
function QAchieveUtils:mountSoulGuideLevelHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = 0
	local mounts = remote.mount:getMountList()
	for _,achieveInfo in pairs(list) do
		if conNum ~= achieveInfo.config.condition then
			conNum = achieveInfo.config.condition or 0
			stepNum = 0
			for _, mount in pairs(mounts) do
				if mount.aptitude == APTITUDE.SS and (mount.grade + 1) >= conNum then
					stepNum = stepNum + 1
				end
			end
		end
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

-- 5次全对次数
function QAchieveUtils:heroFullCorrectCountHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = remote.question:getFullCorrectCount()
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

-- 回答正确数字
function QAchieveUtils:heroTotalCorrectCountHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = remote.question:getTotalCorrectCount()
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end


-- 
function QAchieveUtils:metalCityTotalFightCountHandler(taskType)
	local list = self:getAchieveListByTaskType(taskType)
	local conNum = 0
	local stepNum = remote.user:getPropForKey("totalMetalCityFightCount")
	for _,achieveInfo in pairs(list) do
		achieveInfo.stepNum = stepNum
		self:achieveDoneForNum(achieveInfo.config.index)
	end
end

return QAchieveUtils