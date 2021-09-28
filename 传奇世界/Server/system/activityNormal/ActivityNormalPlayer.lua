--ActivityNormalPlayer.lua
--/*-----------------------------------------------------------------
--* Module:  ActivityNormalPlayer.lua
--* Author:  Andy
--* Modified: 2016年06月07日
--* Purpose: Implementation of the class ActivityNormalPlayer
-------------------------------------------------------------------*/

ActivityNormalPlayer = class()

local prop = Property(ActivityNormalPlayer)

prop:accessor("roleSID")
prop:accessor("roleID")
prop:accessor("integral", 0)		--当前活跃度总积分
prop:accessor("actvienessTime", 0)	--当前完成活跃度的时间

prop:accessor("updataDB", false)

function ActivityNormalPlayer:__init(roleSID, roleID)
	prop(self, "roleSID", roleSID)
	prop(self, "roleID", roleID)

	self._activenessInfo = {}		--活跃度记录{[type]=times}
	self._activenessState = {}		--活跃度领奖状态
	self._findActivity = {}			--找回奖励次数
	self:initializeActiveness()
end

function ActivityNormalPlayer:initializeActiveness()
	self._activenessInfo = {}
	local normalConfig = g_normalMgr:getNormalConfig()
	for _, config in pairs(normalConfig) do
		self._activenessInfo[config.type] = 0
	end
	for integral, _ in pairs(ACTIVENESS_DROPID) do
		self._activenessState[integral] = 1
	end
	self:setIntegral(0)
	self:setActvienessTime(time.toedition("day"))
end

function ActivityNormalPlayer:getActivenessTimes(type)
	return self._activenessInfo[type] or 0
end

function ActivityNormalPlayer:getActivenessState(integral)
	return self._activenessState[integral] or 1
end

--是否领过活跃度
function ActivityNormalPlayer:isReward()
	for _, state in pairs(self._activenessState) do
		if state == 2 then
			return true
		end
	end
	return false
end

function ActivityNormalPlayer:activenessReward(integral)
	if self._activenessState[integral] == 0 then
		self._activenessState[integral] = 2
		self:cast2DB()
		return true
	end
	return false
end

function ActivityNormalPlayer:finishActiveness(type, count)
	local config = g_normalMgr:getNormalConfigByType(type)
	if not config then
		return
	end
	count = count or 1
	local updataDB = false
	--奖励找回
	if config.findTimes > 0 then
		if not self._findActivity[type] then
			self._findActivity[type] = {}
			self._findActivity[type].times = 0
			self._findActivity[type].lastFreshDay = os.time()
			self._findActivity[type].flag = 0
			self._findActivity[type].lastTotalFinishTimes = 0
			self._findActivity[type].lastFinishTimes = 0
			self._findActivity[type].lastFinishDay = os.time()
		end
		local dayInterval = dayBetween(os.time(), self._findActivity[type].lastFinishDay)
		if dayInterval >= 1 then
			self._findActivity[type].lastTotalFinishTimes = self._findActivity[type].lastTotalFinishTimes + self._findActivity[type].lastFinishTimes
			self._findActivity[type].lastFinishTimes = 0
		end
		self._findActivity[type].lastFinishTimes = self._findActivity[type].lastFinishTimes + count
		self._findActivity[type].lastFinishDay = os.time()
		if type == ACTIVENESS_TYPE.SMELT or type == ACTIVENESS_TYPE.KILL_MONSTER or type == ACTIVENESS_TYPE.KILL_ELITE then
			self:setUpdataDB(true)
		else
			updataDB = true
		end
	end
	--活跃度
	local totalTimes, finishTimes = config.times, self._activenessInfo[type] or 0
	if finishTimes < totalTimes then
		self._activenessInfo[type] = finishTimes + count
		if self._activenessInfo[type] > totalTimes then
			self._activenessInfo[type] = totalTimes
		end
		local point = 0
		if type == ACTIVENESS_TYPE.SMELT or type == ACTIVENESS_TYPE.KILL_MONSTER or type == ACTIVENESS_TYPE.KILL_ELITE then
			if self._activenessInfo[type] == totalTimes then
				point = config.integral
			else
				self:setUpdataDB(true)
				return
			end
		else
			point = math.floor(config.integral / totalTimes) * (self._activenessInfo[type] - finishTimes)
		end
		self:setIntegral(self:getIntegral() + point)
		local nowIntegral = self:getIntegral()
		for integral, _ in pairs(ACTIVENESS_DROPID) do
			if self._activenessState[integral] == 1 and nowIntegral >= integral then
				self._activenessState[integral] = 0
			end
		end
		updataDB = true
		g_normalMgr:pushActiveness(self:getRoleID())
		self:fireCompetition()
		local player = g_entityMgr:getPlayer(self:getRoleID())
		if player then
			g_tlogMgr:TlogNewActivityFlow(player, type, ACTIVENESS_TYPE_NAME[type], point, nowIntegral)
		end
	end
	if updataDB then
		self:cast2DB()
	end
end

--触发拼战
function ActivityNormalPlayer:fireCompetition()
	if FIRE_COMPETITION then
		local player = g_entityMgr:getPlayer(self:getRoleID())
		if player then
			local roleSID = player:getSerialID()
			local mark = self:getIntegral()
			if mark >= FIRE_COMPETITION[1] then
				g_competitionMgr:checkCompetitionActive(roleSID,1,4)
			elseif mark >= FIRE_COMPETITION[2] then
				g_competitionMgr:checkCompetitionActive(roleSID,1,3)
			elseif mark >= FIRE_COMPETITION[3] then
				g_competitionMgr:checkCompetitionActive(roleSID,1,2)
			elseif mark >= FIRE_COMPETITION[4] then
				g_competitionMgr:checkCompetitionActive(roleSID,1,1)
			end
		end
	end
end

function ActivityNormalPlayer:checkFindReward()
	local nowDay = time.toedition("yday")
	for _, type in pairs(ACTIVENESS_TYPE) do
		if self._findActivity[type] and 1 == self._findActivity[type].flag then
			if nowDay ~= self._findActivity[type].lastFinishDay then
				self._findActivity[type].lastTotalFinishTimes = self._findActivity[type].lastTotalFinishTimes + self._findActivity[type].lastFinishTimes
				self._findActivity[type].lastFinishTimes = 0
				self._findActivity[type].lastFinishDay = os.time()
			end
			
			local dayInterval = dayBetween(os.time(), self._findActivity[type].lastFreshDay)
			if dayInterval >= 1 then
				local interval = dayBetween(self._findActivity[type].lastFinishDay, self._findActivity[type].lastFreshDay)
				--print("222222222222222222222222222222:" .. nowDay .. "interval:" .. interval)
				if interval >= 1 then
					local config = g_normalMgr:getNormalConfigByType(type)
					if config and 0 < config.findTimes then
						local totalTimes = interval * config.times
						--print("33333333333333333333333:" .. " totalTimes:" .. totalTimes .. " config.times:" .. config.times .. "interval:" .. interval)
						if totalTimes > self._findActivity[type].lastTotalFinishTimes then
							local addTimes = totalTimes - self._findActivity[type].lastTotalFinishTimes
							--print("444444444444444444444444444444444:" .. " addTimes:" .. addTimes)
							self._findActivity[type].times = self._findActivity[type].times + addTimes
							if self._findActivity[type].times > config.findTimes then
								self._findActivity[type].times = config.findTimes
							end
						end
						self._findActivity[type].lastFreshDay = os.time()
						self._findActivity[type].lastTotalFinishTimes = 0
					end
				end
			end
		end
	end
	self:cast2DB()
end

function ActivityNormalPlayer:playerSetLevel(level)
	local save = false
	local nowDay = time.toedition("yday")
	for _, i in pairs(ACTIVENESS_TYPE) do
		local config = g_normalMgr:getNormalConfigByType(i)
		if config and 0 < config.findTimes then
			--print("ccccccccccccccccccccccccccccccc:" .. level .. ":" .. config.level .. ":")
			if not self._findActivity[i] then
				self._findActivity[i] = {}
				self._findActivity[i].flag = 0
			end
			if level >= config.level and 0 == self._findActivity[i].flag then	
				self._findActivity[i].times = 0
				self._findActivity[i].lastFreshDay = os.time()
				self._findActivity[i].flag = 1
				self._findActivity[i].lastTotalFinishTimes = 0
				self._findActivity[i].lastFinishTimes = 0
				self._findActivity[i].lastFinishDay = os.time()
				save = true
--				print("1111111111111111111111111111111111111")
			end
		end
	end
	if save then
		self:cast2DB()
	end
end

--返回可以获取找回奖励的列表
function ActivityNormalPlayer:getCanGetFindReward()
--	self:checkFindReward()
	local reward = {}
	for type, findReward in pairs(self._findActivity) do
		if findReward.times and 0 ~= findReward.times then
			local config = g_normalMgr:getNormalConfigByType(type)
			if config then
				local tmp = {}
				tmp.id = config.id
				tmp.times = findReward.times or 0
				table.insert(reward, tmp)
			end
		end
	end
	return reward
end

--获取找回奖励
function ActivityNormalPlayer:getFindRewardById(player, id, costType, dropIdListBuf)
	local byEmail = false
	local config = g_normalMgr:getNormalConfigById(id)
	if not config then
		return false
	end
	local reward = self._findActivity[config.type]
	if not reward then
		return false
	end
	if 0 == reward.times then
		return false
	end
	local dropId = nil
	if 1 == costType then
		dropId = config.findMoneyDropID
	elseif 2 == costType then
		dropId = config.findIngotDropID
	end
	if not dropId then
		return false
	end
	local dropItem = dropString(player:getSchool(), player:getSex(), dropId)
	local itemMgr = player:getItemMgr()
	if 1 == costType then
		if not costMoney(player, config.findMoney, 221) then
			return false
		end
	end
	local str=""
	for _, item in pairs(dropItem) do
		str = str .. tostring(g_configMgr:getItemProto(item.itemID).name or "") .. "*" .. item.count
	end
	if itemMgr:getEmptySize(Item_BagIndex_Bag) < table.size(dropItem) then
		byEmail = true
		if not dropIdListBuf then
			g_entityMgr:dropItemToEmail(player:getSerialID(), dropId, 85, 232, 0, false, "")
		else
			dropIdListBuf:pushInt(dropId)
		end
	else
		for _, item in pairs(dropItem) do
			itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind, 0, 0, item.strength)
		end
	end
	reward.times = reward.times - 1;
	self:cast2DB()
	return true, str, byEmail
end

function ActivityNormalPlayer:getFindRewardCostMoney(reward)
	local money = 0
	for _ ,r in pairs(reward) do
		local config = g_normalMgr:getNormalConfigById(r.id)
		if config then
			money = money + r.times * config.findMoney
		end
	end
	return money
end

function ActivityNormalPlayer:getFindRewardCostGot(reward)
	local got = 0
	for _ ,r in pairs(reward) do
		local config = g_normalMgr:getNormalConfigById(r.id)
		if config then
			got = got + r.times * config.findIngot
		end
	end
	return got
end

function ActivityNormalPlayer:getFindReward2(player, id)
	local config = g_normalMgr:getNormalConfigById(id)
	if not config then
		return false
	end
	local reward = self._findActivity[config.type]
	if not reward then
		return false
	end
	if 0 == reward.times then
		return false
	end
	local dropId = nil
	dropId = config.findIngotDropID
	if not dropId then
		return false
	end
	local itemMgr = player:getItemMgr()
	if not isIngotEnough(player, config.findIngot) then
			return false
	else
		local context = { all = false, reward_id = id}
		local ret = g_tPayMgr:TPayScriptUseMoney(player, config.findIngot, 221, "", 0, 0, "ActivityNormalManager.DoYuanBaoFindRewardPray", serialize(context)) 
		if ret ~= 0 then
			print("ActivityNormalPlayer:getFindReward2: g_tPayMgr:TPayScriptUseMoney return ~0, playerID:", player:getID())
			return false
		end
		return true
	end
end

function ActivityNormalPlayer:getAllFindReward(player, costType)
	local byEmail = false
	local reward = self:getCanGetFindReward()
	if not reward then
		return true
	end
	if 1 == costType then
		local money = self:getFindRewardCostMoney(reward)
		if not isMoneyEnough(player, money) then
			return false
		end
	elseif 2 == costType then
		local got = self:getFindRewardCostGot(reward)
		if not isIngotEnough(player, got) then
			return false
		else
			local context = { all = true,}
			local ret = g_tPayMgr:TPayScriptUseMoney(player, got, 221, "", 0, 0, "ActivityNormalManager.DoYuanBaoFindRewardPray", serialize(context)) 
			if ret ~= 0 then
				print("ActivityNormalPlayer:getAllFindReward: g_tPayMgr:TPayScriptUseMoney return ~0, playerID:", player:getID())
				return false
			end
			return true
		end
	else
		return false
	end
	local str = ""
	local res = false
	local dropIdListBuf = LuaMsgBuffer:new()
	for _, r in pairs(reward) do
		local times = 1
		while (times <= r.times)
		do
			local str1
			res, str1 = self:getFindRewardById(player, r.id, costType, dropIdListBuf)
			if not res then
				return false, str
			end
			times = times + 1
			if str1 then
				str = str .. str1
			end
		end
	end
	if 0 ~= dropIdListBuf:size() then
		g_entityMgr:dropItemListToEmail(player:getSerialID(), dropIdListBuf, 85, 232, 0, false, "")
		byEmail = true
	end
	dropIdListBuf:delete()
	self:cast2DB()
	return true, str, byEmail
end

function ActivityNormalPlayer:initFindData()
	for _, i in pairs(ACTIVENESS_TYPE) do
		local config = g_normalMgr:getNormalConfigByType(i)
		if config and 0 < config.findTimes then
			self._findActivity[i] = {}
			self._findActivity[i].times = 0
			self._findActivity[i].lastFreshDay = os.time()
			self._findActivity[i].flag = 0
			self._findActivity[i].lastTotalFinishTimes = 0
			self._findActivity[i].lastFinishTimes = 0
			self._findActivity[i].lastFinishDay = os.time()
		end
	end
end

function ActivityNormalPlayer:loadDBData(cache_buf)
	self:initFindData()
	local datas = protobuf.decode("ActivityNormal", cache_buf)
	if type(datas) ~= "table" then
		return
	end
	self:setIntegral(datas.integral)
	self:setActvienessTime(datas.actvienessTime)
	for _, activeness in pairs(datas.activeness) do
		self._activenessInfo[activeness.actType] = activeness.times
	end
	for _, rewardState in pairs(datas.state) do
		self._activenessState[rewardState.integral] = rewardState.state
	end
	for _, findReward in pairs(datas.findReward) do
		self._findActivity[findReward.activityType] = {}
		self._findActivity[findReward.activityType].times = findReward.times or 0
		self._findActivity[findReward.activityType].lastFreshDay = findReward.lastFreshDay or os.time()
		self._findActivity[findReward.activityType].flag = findReward.flag or 0
		self._findActivity[findReward.activityType].lastTotalFinishTimes = findReward.lastTotalFinishTimes or 0
		self._findActivity[findReward.activityType].lastFinishTimes = findReward.lastFinishTimes or 0
		self._findActivity[findReward.activityType].lastFinishDay = findReward.lastFinishDay or os.time()
	end
	self:checkFindReward()
	local timeTick = time.toedition("day")
	if timeTick ~= self:getActvienessTime() then
		self:initializeActiveness()
	end
end

function ActivityNormalPlayer:checkCast2DB()
	if self:getUpdataDB() then
		self:setUpdataDB(false)
		self:cast2DB()
	end
end

function ActivityNormalPlayer:cast2DB()
	local activeness, state, findReward = {}, {}, {}
	for actType, times in pairs(self._activenessInfo) do
		local tmp = {actType = actType, times = times}
		table.insert(activeness, tmp)
	end
	for integral, _ in pairs(ACTIVENESS_DROPID) do
		local tmp = {integral = integral, state = self._activenessState[integral]}
		table.insert(state, tmp)
	end
	for _, i in pairs(ACTIVENESS_TYPE) do
		if self._findActivity[i] then
			local tmp = {}
			tmp.activityType = i
			tmp.times = self._findActivity[i].times or 0
			tmp.lastFreshDay = self._findActivity[i].lastFreshDay or os.time()
			tmp.flag = self._findActivity[i].flag or 0
			tmp.lastTotalFinishTimes = self._findActivity[i].lastTotalFinishTimes or 0
			tmp.lastFinishTimes = self._findActivity[i].lastFinishTimes or 0
			tmp.lastFinishDay = self._findActivity[i].lastFinishDay or os.time()
			table.insert(findReward, tmp)
		end
	end
	local dbData = {
		integral = self:getIntegral(),
		actvienessTime = self:getActvienessTime(),
		activeness = activeness,
		state = state,
		findReward = findReward,
	}
	local cache_buff = protobuf.encode("ActivityNormal", dbData)
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_ACTIVITY_NORMAL, cache_buff, #cache_buff)
end

function ActivityNormalPlayer:payFindRewardCallback(player, ret, callBackContext)
	local context = unserialize(callBackContext)
	local all = context.all
	if 0 ~= ret then
		if all then
			fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_GET_ALL_FIND_REWARD_RET, "ActivityNormalGetAllFindRewardRet", {type = 2, result = 1})
		else
			fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_GET_FIND_REWARD_RET, "ActivityNormalGetFindRewardRet", {id = context.reward_id, type = 2, result = 1})
		end
		return
	end
	if all then
		local byEmail = false
		local reward = self:getCanGetFindReward()
		local str = ""
		local res = false
		local result = 0
		local dropIdListBuf = LuaMsgBuffer:new()
		for _, r in pairs(reward) do
			local exit = false
			local times = 1
			while (times <= r.times)
			do
				local str1
				res, str1 = self:getFindRewardById(player, r.id, 2, dropIdListBuf)
				if not res then
					result = 1
					exit = true
					break
				end
				times = times + 1
				if str1 then
					str = str .. str1
				end
			end
			if exit then
				break
			end
		end
		if 0 ~= dropIdListBuf:size() then
			g_entityMgr:dropItemListToEmail(player:getSerialID(), dropIdListBuf, 85, 232, 0, false, "")
			byEmail = true
		end
		dropIdListBuf:delete()

		fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_GET_ALL_FIND_REWARD_RET, "ActivityNormalGetAllFindRewardRet", {type = 2, result = result})
		_sendFindRewardList(player)
		if str and string.len(str) ~= 0 then
			--str = "奖励领取成功！"
			if not byEmail then
				g_normalMgr:sendErrMsg2Client(player:getID(), ACTIVITY_NORMAL_GET_ALL_FIND_REWARE_TIPS, 0, {})
			else
				g_normalMgr:sendErrMsg2Client(player:getID(), ACTIVITY_EMAIL_GET_FIND_REWARE_TIPS, 0, {})
			end
		end
	else
		local id = context.reward_id
		local byEmail = false
		local reward = self:getCanGetFindReward()
		local str = ""
		local res = false
		local result = 0
		local dropIdListBuf = LuaMsgBuffer:new()
		res, str = self:getFindRewardById(player, id, 2, dropIdListBuf)
		if not res then
			result = 1
		end
		if 0 ~= dropIdListBuf:size() then
			g_entityMgr:dropItemListToEmail(player:getSerialID(), dropIdListBuf, 85, 232, 0, false, "")
			byEmail = true
		end
		dropIdListBuf:delete()
		fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_GET_FIND_REWARD_RET, "ActivityNormalGetFindRewardRet", {id = id, type = 2, result = result})
		_sendFindRewardList(player)
		if str and string.len(str) ~= 0 then
			if not byEmail then
				g_normalMgr:sendErrMsg2Client(player:getID(), ACTIVITY_NORMAL_GET_FIND_REWARE_TIPS, 1, {str})
			else
				g_normalMgr:sendErrMsg2Client(player:getID(), ACTIVITY_EMAIL_GET_FIND_REWARE_TIPS, 0, {})
			end
		end
	end
	self:cast2DB()
	return TPAY_SUCESS
end