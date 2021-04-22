--帮助对话框
--
local QHelpUtil = class("QHelpUtil")
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QHelpUtil:ctor(  )
	-- body
	self.checkFunc = {
		-- resource type
		tili = { helpFunction = handler(self, self.checkResouceIsFull)},
		rongyao_shop = { helpFunction = handler(self, self.checkResouceIsFull)},
		jinji_shop = { helpFunction = handler(self, self.checkResouceIsFull)},
		zhanchang_shop = { helpFunction = handler(self, self.checkResouceIsFull)},
		leidian_shop = { helpFunction = handler(self, self.checkResouceIsFull)},
		gonghui_shop = { helpFunction = handler(self, self.checkResouceIsFull)},
		yaosai_shop = { helpFunction = handler(self, self.checkResouceIsFull)},
		baoshi_shop = { helpFunction = handler(self, self.checkResouceIsFull)},
		fengbao_shop = { helpFunction = handler(self, self.checkResouceIsFull)},
		haishang_shop = { helpFunction = handler(self, self.checkResouceIsFull)},
		longzhan_shop = { helpFunction = handler(self, self.checkResouceIsFull)},
		jingshi_shop = { helpFunction = handler(self, self.checkResouceIsFull)},
		baoshi_up = { helpFunction = handler(self, self.checkResouceIsFull)},
		hero_glyphs = { helpFunction = handler(self, self.checkResouceIsFull)},
		equipment_up = { helpFunction = handler(self, self.checkResouceIsFull)},
		hero_train = { helpFunction = handler(self, self.checkResouceIsFull)},
		ronghuo_shop = { helpFunction = handler(self, self.checkResouceIsFull)},

		-- item type
		zuoqi_up = { helpFunction = handler(self, self.checkItemIsFull)},
		yingxiong_shop = { helpFunction = handler(self, self.checkItemIsFull)},

		-- special type
		zhanchang = { helpFunction = handler(self, self.checkSunwarRebornNum)},
		yuangujulong = { helpFunction = handler(self, self.checkWorldBossOpenTime)},
		jingjichang = { helpFunction = handler(self, self.checkArenaFightNum)},
		fengbao = { helpFunction = handler(self, self.checkStormArenaFightNum)},
		haishang = { helpFunction = handler(self, self.checkMaritimeDoubleAwardsTime)},
		ronghuo = { helpFunction = handler(self, self.checkBlackRockDoubleAwardsTime)},
		hero_up = { helpFunction = handler(self,self.checkHeroCanUpgrade)},
		hero_skills = { helpFunction = handler(self, self.checkHeroSkillCanUpgrade)},
		break_through = { helpFunction = handler(self, self.checkHeroEquipCanEvolve)},
		daily_quest = { helpFunction = handler(self, self.checkDailyTaskCanComplete)},
		knapsack_box = { helpFunction = handler(self, self.checkHaveGiftItems)},
		hero_ornament = { helpFunction = handler(self, self.checkJewelryCanLevelUp)},
	}
end

function QHelpUtil:init()
	self._helpList = {}
	self._strongerList = {}
	self._helpData = db:getStaticByName("help_function")
end

function QHelpUtil:getHeroList( )
	local heroList = {}
	local heroInfos,count = remote.herosUtil:getMaxForceHeros()
	for i=1,count do
		if heroInfos[i] and heroInfos[i].id then
			table.insert(heroList, heroInfos[i].id)
		end
	end

	return heroList
end

function QHelpUtil:getStrongerTalkList( )
	return self._strongerList
end

function QHelpUtil:getHelpShowCountToday(helpType)
	local isReset = true
	local saveDate = app:getUserOperateRecord():getHelpRecordTime()
	local curDate = q.date("*t", q.serverTime())
	if saveDate then	
		if saveDate.day ~= curDate.day then
			app:getUserOperateRecord():setHelpRecordTime(curDate)
		elseif curDate.hour >= 5 then
			isReset = false
		end
	else
		app:getUserOperateRecord():setHelpRecordTime(curDate)
	end

	local saveCount = app:getUserOperateRecord():getHelpRecordeCountByType("HELP_TYPE_"..helpType) or 0
	if isReset then
		saveCount = 0
		app:getUserOperateRecord():setHelpRecordeCountByType("HELP_TYPE_"..helpType, saveCount)
	end

	return saveCount
end

function QHelpUtil:setCurrentTimeByHelpType(helpType, index)
	local saveCount = self:getHelpShowCountToday(helpType)
	app:getUserOperateRecord():setHelpRecordeCountByType("HELP_TYPE_"..helpType, saveCount+1)
	table.remove(self._helpList, index)
end

function QHelpUtil:checkCanShowHelp()
	for i = #self._helpList, 1, -1 do
		-- 引导限制
		local value = self._helpList[i]
		if self.checkFunc[value.help_function] and self.checkFunc[value.help_function].helpFunction(value) == false then
			table.remove(self._helpList, i)
		end
	end
	if next(self._helpList) then
		return self._helpList
	end

	self._strongerList = {}
	for _, value in pairs(self._helpData) do
		if value.help_type == "stronger" then
			local helpInfo = clone(value)
			helpInfo.talkTbl = {}
			local talkTbl = string.split(value.help_content, ";")
			for i, v in pairs(talkTbl or {}) do
				if v ~= "" then
					table.insert(helpInfo.talkTbl, v)
				end
			end
			table.insert(self._strongerList, helpInfo)
		else
			local isUnlock = true
			if value.key then
				isUnlock = app.unlock:checkLock(value.key, false)
			end
			local closeLevel = value.closing_condition or 120
			local showCount = self:getHelpShowCountToday(value.help_function)
			local mostTime = value.most_time or 1

			-- 解锁条件，展示次数，等级限制
			if isUnlock and showCount < mostTime and remote.user.level < closeLevel then
				-- 引导限制
				if self.checkFunc[value.help_function] and self.checkFunc[value.help_function].helpFunction(value) then
					local helpInfo = clone(value) 
					helpInfo.showCount = showCount
					table.insert(self._helpList, helpInfo)
				end
			end
		end
	end
	table.sort( self._helpList, function(a, b)
		if a.weight and a.weight then
			return a.weight < b.weight
		end
	end)

	return self._helpList
end

function QHelpUtil:checkResouceIsFull(helpData)
	if helpData == nil or next(helpData) == nil then return false end

	local resouceName = remote.items:getItemType(helpData.help_type)
	if resouceName == nil then return false end

	local needResource = remote.user[resouceName] or 0
	if helpData.type_num <= needResource then
		return true
	end

	return false
end

function QHelpUtil:checkItemIsFull(helpData)
	if helpData == nil then return false end

	local needItem = remote.items:getItemsNumByID(helpData.help_type)

	if helpData.type_num <= needItem then
		return true
	end

	return false
end

function QHelpUtil:checkSunwarRebornNum()
    local count = remote.sunWar:getCanReviveCount() or 0

	return count >= 1
end

function QHelpUtil:checkWorldBossOpenTime()
	--TODO
	return remote.worldBoss:checkWorldBossIsUnlock()
end

function QHelpUtil:checkArenaFightNum()
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	local totalCount = config.ARENA_FREE_FIGHT_COUNT.value or 0
	local myInfo = remote.arena:madeReciveData("self").arenaResponse.mySelf
	local count = (totalCount + (myInfo.fightBuyCount or 0))-(myInfo.fightCount or 0)
	
	local isShow = false
	if count >=5 and count <= 10 then
		isShow = true
	end

	return isShow
end

function QHelpUtil:checkStormArenaFightNum()
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	local totalCount = config.STORM_ARENA_FREE_FIGHT_COUNT.value or 0
	local myInfo = remote.stormArena.stormArenaMyInfo
	local count = (totalCount + (myInfo.fightBuyCount or 0))-(myInfo.fightCount or 0)

	local isShow = false
	if count >=5 and count <= 10 then
		isShow = true
	end

	return isShow
end

function QHelpUtil:checkMaritimeDoubleAwardsTime(helpData)
	local isShow = false
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	local doubleTime = configuration["maritime_double_time"].value
	local clickTime = app:getUserOperateRecord():getRecordeTime("HELP_TYPE_"..helpData.help_function)

	if remote.maritime:checkMaritimeTransportTips() and self:checkIsDoubleTime(doubleTime, clickTime) then
		isShow = true
	end

	return isShow
end

function QHelpUtil:checkBlackRockDoubleAwardsTime(helpData)
	local isShow = false
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	local doubleTime = configuration["blackrock_double_reward"].value
	local clickTime = app:getUserOperateRecord():getRecordeTime("HELP_TYPE_"..helpData.help_function)

	local count = remote.blackrock:getAwardCount()
	if count > 0 and self:checkIsDoubleTime(doubleTime, clickTime) then
		isShow = true
	end

	return isShow
end

function QHelpUtil:checkIsDoubleTime(doubleTime, clickTime)
	if doubleTime == nil then return false end

	doubleTime = string.split(doubleTime, ";")
	local nowTime = q.date("*t", q.serverTime())
	clickTime = q.date("*t", clickTime)
	
	for _, value in pairs(doubleTime) do
		local time = string.split(value, ",")
		if nowTime.hour >= tonumber(time[1]) and nowTime.hour < tonumber(time[2]) then
			if clickTime.hour < tonumber(time[1]) or clickTime.hour > tonumber(time[2]) then
				return true
			end
		end
	end
	return false
end

-------------------------- old func ------------------------

--检查魂师升级
function QHelpUtil:checkHeroCanUpgrade( ... )
	-- body
	local expItems = QStaticDatabase:sharedDatabase():getItemsByProp("exp")
	if expItems ~= nil or #expItems ~= 0 then
		for k, v in pairs(expItems) do
			if remote.items:getItemsNumByID(v.id) > 0 then
				-- Check if any hero can upgrade
				for _, v in ipairs(self:getHeroList()) do
					if remote.herosUtil:heroCanUpgrade2(v) == true then
					
    					return true,{actorId=v}
					end
				end
				break
			end
		end
	else
		return false
	end

	return false
end

--检查技能升级
function QHelpUtil:checkHeroSkillCanUpgrade(  )
	-- body
	-- local config = QStaticDatabase:sharedDatabase():getConfiguration()
	if app.unlock:getUnlockSkill() == false then
        return false, {}
    end

    -- Check if skill upgrade is available and glyph is enough
    for _, v in ipairs(self:getHeroList()) do 
		if remote.herosUtil:checkHerosSkillByID(v) then
			return true,{actorId=v}
		end
	end
	return false, {}
end

--检查装备是否可以强化
function QHelpUtil:checkHerosEquipCanEnhance( )
	-- body
	if app.unlock:getUnlockEnhance() == false then
        return false
    end

    for _, v in ipairs(self:getHeroList()) do 
    	local equpmentId = remote.herosUtil:checkHerosEnhanceByID(v)
    	if equpmentId then
    		return true,{actorId=v,equipmentId = equpmentId}
    	end
    end
end
--检查装备是否可以突破
function QHelpUtil:checkHeroEquipCanEvolve(  )
	-- body
	for _, v in ipairs(self:getHeroList()) do 
    	local equpmentId = remote.herosUtil:getHerosEvolutionIdByActorId(v)
    	if equpmentId then
    		return true,{actorId=v,equipmentId = equpmentId}
    	end
    end

    return false
end

--检查魂师培养
function QHelpUtil:checkHeroCanTraining(helpData)
	-- body
	local curTrainMoney  = remote.user.trainMoney  or 0
	if curTrainMoney < (helpData.type_num or 100) then
		return false
	end 

	for _, v in ipairs(self:getHeroList()) do 
    	if remote.herosUtil:checkHeroCanTraining(v) then
    		return true,{actorId=v}
    	end
    end

    return false
end

--检查 每日任务是否有任务可以去完成
function QHelpUtil:checkDailyTaskCanComplete( )
	-- body
	return remote.task:checkAllTaskCanComplete()
end

--

function QHelpUtil:checkHaveGiftItems( )
	-- body
	local itemID = remote.items:checkHaveGiftItems()
	if itemID then
		return true, {itemID = itemID}
	end
	return false, {}
end

function QHelpUtil:checkJewelryCanLevelUp( )
	-- body
	if not app.unlock:getUnlockEnhanceAdvanced()  then
		return false
	end

	local jewelryExp1 = 0
	local jewelryExp2 = 0
	local itemInfo1 = QStaticDatabase:sharedDatabase():getItemByID(31)
	local exp1 = remote.items:getItemsNumByID(31) * itemInfo1.enhance_exp1
	local itemInfo2 = QStaticDatabase:sharedDatabase():getItemByID(32)
	local exp2 = remote.items:getItemsNumByID(32) * itemInfo2.enhance_exp1
	local itemInfo3 = QStaticDatabase:sharedDatabase():getItemByID(33)
	local exp3 = remote.items:getItemsNumByID(33) * itemInfo3.enhance_exp1

	jewelryExp1 = exp1 + exp2 + exp3

	itemInfo1 = QStaticDatabase:sharedDatabase():getItemByID(36)
	exp1 = remote.items:getItemsNumByID(36) * itemInfo1.enhance_exp2
	itemInfo2 = QStaticDatabase:sharedDatabase():getItemByID(37)
	exp2 = remote.items:getItemsNumByID(37) * itemInfo2.enhance_exp2
	itemInfo3 = QStaticDatabase:sharedDatabase():getItemByID(38)
	exp3 = remote.items:getItemsNumByID(38) * itemInfo3.enhance_exp2
	jewelryExp2 = exp1 + exp2 + exp3


	for _, v in ipairs(self:getHeroList()) do 
    	local ret , equpmentId= remote.herosUtil:checkJewelryCanLevelUp(v, EQUIPMENT_TYPE.JEWELRY1, jewelryExp1) 

    	if ret then
    		return ret,{actorId=v, equipmentId = equpmentId, equipPos = EQUIPMENT_TYPE.JEWELRY1}
    	end
    end
    if  app.unlock:getUnlockGAD() then
		for _, v in ipairs(self:getHeroList()) do 
	    	local ret , equpmentId= remote.herosUtil:checkJewelryCanLevelUp(v, EQUIPMENT_TYPE.JEWELRY2, jewelryExp2) 
	    	if ret then
	    		return ret,{actorId=v, equipmentId = equpmentId, equipPos = EQUIPMENT_TYPE.JEWELRY2}
	    	end
	    end
	end
end


return QHelpUtil

