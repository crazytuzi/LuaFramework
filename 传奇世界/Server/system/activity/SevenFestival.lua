--SevenFestival.lua
--/*-----------------------------------------------------------------
--* Module:  SevenFestival.lua
--* Author:  Andy
--* Modified: 2016年05月27日
--* Purpose: 七日盛典
-------------------------------------------------------------------*/

require ("base.class")
SevenFestival = class()

local prop = Property(SevenFestival)
prop:accessor("roleID")
prop:accessor("roleSID")
prop:accessor("recheck", false)	--双周盛典重新检测达成条件
prop:accessor("battle", 0)
prop:accessor("updateDB", false)
prop:accessor("logIndex", 1)	--Tlog索引1、七日盛典 2、半月盛典

function SevenFestival:__init(roleID, roleSID, modelID, activityID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)

	self._modelID = modelID
	self._activityID = activityID
	self._loadFlag = false
	if modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
		prop(self, "logIndex", 2)
	end
	self._datas = {
		prog = {},		--需要记录的累计进度
		status = {},	--领取状态
	}

	self._luoxiaIndex = -1	-- -1代表参加落霞夺宝的时间索引
	self._baodiIndex = -2	-- -2代表参加全民宝地的时间索引
	self._updateCount = 0
	self:initialize()
end

function SevenFestival:initialize()
	for _, actType in pairs(ACTIVITY_ACT) do
		self._datas.prog[actType] = 0
	end
	self._datas.prog[self._luoxiaIndex] = 0
	self._datas.prog[self._baodiIndex] = 0
	local boxDrop = {}
	if self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL then
		boxDrop = ACTIVITY_BOX_DEOPID
	elseif self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
		boxDrop = ACTIVITY_BOX_DEOPID2
	end
	for index, _ in pairs(boxDrop) do
		self._datas.status[index] = 1
	end
	for index, config in pairs(g_DataMgr:getSevenLoginConfig() or {}) do
		if self:isValidDay(config.day) then
			self._datas.status[index] = 1
		end
	end
end

function SevenFestival:isValidDay(day)
	if self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL then
		if day > 0 and day <= ACTIVITY_SEVEN_FESTIVAL_DAY then
			return true
		end
	elseif self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
		if day > ACTIVITY_SEVEN_FESTIVAL_DAY and day <= ACTIVITY_SEVEN_FESTIVAL_DAY2 then
			return true
		end
	end
	return false
end

--是否累加类型的事件
function SevenFestival:isCumulativeType(actType)
	if actType == ACTIVITY_ACT.TULONG or actType == ACTIVITY_ACT.ZHAOLIN or actType == ACTIVITY_ACT.XUANSHUANG or actType == ACTIVITY_ACT.WINGTASK or 
		actType == ACTIVITY_ACT.GUARD or actType == ACTIVITY_ACT.DART or actType == ACTIVITY_ACT.ENVOY or actType == ACTIVITY_ACT.LOUXIA or 
		actType == ACTIVITY_ACT.PICKLUOXIA or actType == ACTIVITY_ACT.PRECIOUS or actType == ACTIVITY_ACT.MIXIANZHEN or actType == ACTIVITY_ACT.SHANGXIANG or
		actType == ACTIVITY_ACT.DIGMINE or actType == ACTIVITY_ACT.BAODI or actType == ACTIVITY_ACT.PVP or actType == ACTIVITY_ACT.GIVEWINE then
		return true
	end
	return false
end

function SevenFestival:redDot()
	local nowOpenDay = g_ActivityMgr:getNowOpenDay()
	for index, config in pairs(g_DataMgr:getSevenLoginConfig() or {}) do
		if self._datas.status[index] == 0 and self:isValidDay(config.day) and config.day <= nowOpenDay then
			return true
		end
	end
	local boxDrop = {}
	if self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL then
		boxDrop = ACTIVITY_BOX_DEOPID
	elseif self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
		boxDrop = ACTIVITY_BOX_DEOPID2
	end
	for index, _ in pairs(boxDrop) do
		if self._datas.status[index] == 0 then
			return true
		end
	end
	return false
end

function SevenFestival:playerLogout()
	local battle = self:getBattle()
	if battle > 0 then
		self:changeStatus(ACTIVITY_ACT.BATTLEUP, battle, true)
	end
	self:cast2DB()
end

function SevenFestival:update()
	local battle = self:getBattle()
	if battle > 0 or self:getUpdateDB() then
		self._updateCount = self._updateCount + 1
		if self._updateCount >= 6 then
			self._updateCount = 0
			if battle > 0 then
				self:changeStatus(ACTIVITY_ACT.BATTLEUP, battle, true)
				self:setBattle(0)
			end
			self:cast2DB()
		end
	elseif self._updateCount > 0 then
		self._updateCount = 0
	end
	if g_ActivityMgr:hasSeventFestival2() and not self:getRecheck() then
		local player = g_entityMgr:getPlayer(self:getRoleID())
		if player then
			self:setRecheck(true)
			self:setUpdateDB(true)
			self:changeStatus(ACTIVITY_ACT.LEVELUP, player:getLevel(), true)
			self:changeStatus(ACTIVITY_ACT.BATTLEUP, battle)
			g_ActivityMgr:equipmentUp(self:getRoleSID())
		end
	end
end

--七日盛典数据改变
function SevenFestival:changeStatus(actType, value, flag)
	if not self._loadFlag then
		if flag or actType == ACTIVITY_ACT.LOGIN then
			self._loadFlag = true
		else
			return
		end
	end
	if actType == ACTIVITY_ACT.BATTLEUP and not flag then
		self:setBattle(value)
		return
	end
	if self:isCumulativeType(actType) then
		if actType == ACTIVITY_ACT.LOUXIA then
			local timeTick = time.toedition("day")
			if self._datas.prog[self._luoxiaIndex] ~= timeTick then
				self._datas.prog[self._luoxiaIndex] = timeTick
			else
				return
			end
		elseif actType == ACTIVITY_ACT.BAODI then
			local timeTick = time.toedition("day")
			if self._datas.prog[self._baodiIndex] ~= timeTick then
				self._datas.prog[self._baodiIndex] = timeTick
			else
				return
			end
		end
		self._datas.prog[actType] = self._datas.prog[actType] + value
	elseif actType ~= ACTIVITY_ACT.LOGIN then
		if value <= self._datas.prog[actType] then
			return
		end
		self._datas.prog[actType] = value
	end
	local pushActivityList = false
	for index, config in pairs(g_DataMgr:getSevenLoginConfig() or {}) do
		if config.type == actType and self._datas.status[index] == 1 and self:isValidDay(config.day) then
			if actType == ACTIVITY_ACT.LOGIN then
				if config.day == g_ActivityMgr:getNowOpenDay() then
					self._datas.status[index] = 0
					pushActivityList = true
				end
			elseif self._datas.prog[actType] >= config.num then
				self._datas.status[index] = 0
				pushActivityList = true
			end
		end
	end
	local point = self:getPoint()
	local boxDrop = ACTIVITY_BOX_DEOPID
	if self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
		boxDrop = ACTIVITY_BOX_DEOPID2
	end
	for index, data in pairs(boxDrop) do
		if point >= data.point and self._datas.status[index] == 1 then
			self._datas.status[index] = 0
			pushActivityList = true
		end
	end
	self:setUpdateDB(true)
	if pushActivityList then
		local player = g_entityMgr:getPlayer(self:getRoleID())
		if player then
			g_tlogMgr:TlogQRSDFlow(player, self:getLogIndex(), actType, ACTIVITY_ACT_NAME[actType], self._datas.prog[actType], point)
		end
		g_ActivityMgr:getActivityList(self:getRoleID())
	end
end

function SevenFestival:getPoint()
	local point = 0
	local nowOpenDay = g_ActivityMgr:getNowOpenDay()
	for index, config in pairs(g_DataMgr:getSevenLoginConfig() or {}) do
		if self._datas.status[index] ~= 1 and self:isValidDay(config.day) and config.day <= nowOpenDay then
			point = point + 1
		end
	end
	return point
end

function SevenFestival:sendBoxInfo(player)
	local startTime = g_ActivityMgr:getStartTime()
	local tab = os.date("*t", startTime)
	local festivalDay = ACTIVITY_SEVEN_FESTIVAL_DAY
	if self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
		festivalDay = ACTIVITY_SEVEN_FESTIVAL_DAY2
	end
	local countdown = (startTime - tab.hour * 3600 - tab.min * 60 - tab.sec) + festivalDay * DAY_SECENDS - os.time()	 --倒计时
	local info = {}
	local boxDrop = ACTIVITY_BOX_DEOPID
	if self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
		boxDrop = ACTIVITY_BOX_DEOPID2
	end
	for index, data in pairs(boxDrop) do
		local tmp = {}
		tmp.index = index
		tmp.point = data.point
		tmp.status = self._datas.status[index]
		tmp.reward = g_ActivityMgr:filterReward(player, dropString(player:getSchool(), player:getSex(), data.dropID))
		table.insert(info, tmp)
	end
	local nowOpenDay = g_ActivityMgr:getNowOpenDay()
	local ret = {}
	ret.point = self:getPoint()
	ret.totalPoint = boxDrop[-4].point
	ret.countdown = countdown
	ret.countdown2 = countdown + DAY_SECENDS
	ret.info = info
	ret.day = nowOpenDay
	ret.redDot1 = false
	ret.redDot2 = false
	ret.redDot3 = false
	ret.redDot4 = false
	ret.redDot5 = false
	ret.redDot6 = false
	ret.redDot7 = false
	for index, config in pairs(g_DataMgr:getSevenLoginConfig() or {}) do
		local day = config.day
		if day <= nowOpenDay and self._datas.status[index] and self._datas.status[index] == 0 and self:isValidDay(day) then
			if day == 1 or day == 8 then
				ret.redDot1 = true
			elseif day == 2 or day == 9 then
				ret.redDot2 = true
			elseif day == 3 or day == 10 then
				ret.redDot3 = true
			elseif day == 4 or day == 11 then
				ret.redDot4 = true
			elseif day == 5 or day == 12 then
				ret.redDot5 = true
			elseif day == 6 or day == 13 then
				ret.redDot6 = true
			elseif day == 7 or day == 14 then
				ret.redDot7 = true
			end
		end
	end
	fireProtoMessage(player:getID(), ACTIVITY_SC_SEVEN_FESTIVAL, "ActivitySevenFestivalInfo", ret)
end

function SevenFestival:req(day)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return
	end
	local nowOpenDay, sevenFestival = g_ActivityMgr:getNowOpenDay(), {}
	if self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL then
		if day > nowOpenDay or day <= 0 or nowOpenDay > ACTIVITY_SEVEN_FESTIVAL_DAY + 1 then
			return
		end
	elseif self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
		if day > nowOpenDay or nowOpenDay <= ACTIVITY_SEVEN_FESTIVAL_DAY or nowOpenDay > ACTIVITY_SEVEN_FESTIVAL_DAY2 + 1 then
			return
		end
	end
	if day == 1 or day == ACTIVITY_SEVEN_FESTIVAL_DAY + 1 then
		self:sendBoxInfo(player)
	end
	for index, config in pairs(g_DataMgr:getSevenLoginConfig() or {}) do
		if config.day == day then
			local info = {}
			info.index = index
			if day <= nowOpenDay then
				info.status = self._datas.status[index]
			else
				info.status = 1
			end
			if config.type == ACTIVITY_ACT.LOGIN then
				if day <= nowOpenDay and self._datas.status[index] ~= 1 then
					info.prog = 1
				else
					info.prog = 0
				end
			else
				info.prog = self._datas.prog[config.type]
			end
			info.reward = g_ActivityMgr:filterReward(player, config.reward)
			table.insert(sevenFestival, info)
		end
	end
	local ret = {}
	ret.modelID = self._modelID
	ret.activityID = self._activityID
	ret.sevenFestival = sevenFestival
	fireProtoMessage(player:getID(), ACTIVITY_SC_RET, "ActivityRet", ret)
end

function SevenFestival:reward(index)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	local nowOpenDay = g_ActivityMgr:getNowOpenDay()
	if not self._datas.status[index] or self._datas.status[index] ~= 0 or not player or
		(self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL and nowOpenDay > ACTIVITY_SEVEN_FESTIVAL_DAY + 1) or
		(self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL2 and nowOpenDay > ACTIVITY_SEVEN_FESTIVAL_DAY2 + 1) then
		return
	end
	local itemMgr = player:getItemMgr()
	if not itemMgr then
		return
	end
	local roleSID = self:getRoleSID()
	local config = g_DataMgr:getSevenLoginConfig()
	local reward = {}
	if index < 0 then
		local dropID = ACTIVITY_BOX_DEOPID[index].dropID
		if self._modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
			dropID = ACTIVITY_BOX_DEOPID2[index].dropID
		end
		reward = dropString(player:getSchool(), player:getSex(), dropID)
		g_tlogMgr:TlogQRSDRewardFlow(player, self:getLogIndex(), 0, 0, dropID, serialize(reward))
	else
		reward = config[index].reward
		local actType = config[index].type
		if actType then
			g_tlogMgr:TlogQRSDRewardFlow(player, self:getLogIndex(), actType, self._datas.prog[actType], index, serialize(reward))
		end
	end
	reward = g_ActivityMgr:filterReward(player, reward)
	local emptySize = itemMgr:getEmptySize(Item_BagIndex_Bag)
	if #reward > emptySize then
		g_ActivityMgr:sendRewardByEmail(roleSID, reward, 101)
	else
		for _, item in pairs(reward) do
			itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind)
			g_ActivityMgr:writeLog(roleSID, 1, 101, item.itemID, item.count, item.bind, player)
		end
		g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_SUCCESS, 0, {})
	end
	self._datas.status[index] = 2
	self:setUpdateDB(true)
	self:cast2DB()
	self:sendBoxInfo(player)
	if index > 0 then
		self:req(config[index].day)
	end
	g_ActivityMgr:getActivityList(self:getRoleID())
	g_logManager:writeOpactivities(roleSID, ACTIVITY_SEVEN_FESTIVAL_ID, index, 2)
end

function SevenFestival:loadDBdata(datas)
	local data = protobuf.decode("ActivitySevenFestivalProtocol", datas)
	if type(data) == "table" then
		for _, tmp in pairs(data.allProg or {}) do
			self._datas.prog[tmp.index] = tmp.status
		end
		for _, tmp in pairs(data.allStatus or {}) do
			self._datas.status[tmp.index] = tmp.status
		end
	end
	self:setRecheck(data.recheck)
	self._loadFlag = true
end

function SevenFestival:cast2DB()
	if self:getUpdateDB() then
		self:setUpdateDB(false)
		local data, allProg, allStatus = {}, {}, {}
		for actType, status in pairs(self._datas.prog) do
			local tmp = {index = actType, status = status}
			table.insert(allProg, tmp)
		end
		for index, status in pairs(self._datas.status) do
			local tmp = {index = index, status = status}
			table.insert(allStatus, tmp)
		end
		data.allProg = allProg
		data.allStatus = allStatus
		data.recheck = self:getRecheck()
		local datas = protobuf.encode("ActivitySevenFestivalProtocol", data)
		g_ActivityMgr:cast2Cache(self:getRoleSID(), self._modelID, self._activityID, datas)
	end
end