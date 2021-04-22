local QRecordUserOperate = class("QRecordUserOperate")

QRecordUserOperate.RECORD_TYPES = {
	TOTEMCHALLENGE_FIGHT_TIME = "TOTEMCHALLENGE_FIGHT_TIME",
	SECRETARY_HERO_FRAME_NEW_HERO = "SECRETARY_HERO_FRAME_NEW_HERO",
	FULL_SCENE_TIPS = "FULL_SCENE_TIPS",
}

function QRecordUserOperate:ctor( )
	-- body
	self:resetRecord()
end

function QRecordUserOperate:resetRecord( ... )
	self:saveRecords()
	self._record = self:getRecords() or {}
	--清理垃圾数据标记
	self._cleanDirtyActivityClickedData = false
end

function QRecordUserOperate:getRecords()

	self._baseFileName = "recordUserOperate.json"
	local userName = app:getUserName() or "default"
	local group_id = remote.serverListGroupId or ""
	local opId = ""
	if remote.serverListOpId and remote.serverListOpId ~= "" then
		opId = "_"..remote.serverListOpId
	end

	-- 用zoneId保证玩家账号被合服以后本地记录继续保持 
	local zoneId = (remote.selectServerInfo and remote.selectServerInfo.zoneId) or ""
	--local serverId = (remote.selectServerInfo and remote.selectServerInfo.serverId) or ""
	local userName_Old = userName .. opId
	local noZoneIdUserName = userName .. opId
	userName = userName .. opId .. zoneId

	self._fileName = userName.."_"..self._baseFileName
	if fileExists(self._fileName) then
		local content = readFromBinaryFile(self._fileName)

		return json.decode(content)
	else
		--修改保存方式
		if fileExists(self._baseFileName) then
			local content = readFromBinaryFile(self._baseFileName)
			local record = json.decode(content)
			--修正之前代码bug
			if type(record[userName_Old]) == "table" then
				record[userName] = record[userName_Old]
				record[userName_Old] = nil
			end

			if type(record[userName]) ~= "table" then
				return {}
			end
			return record[userName]
		end
	end

	return {}
end

-- 公共设置
function QRecordUserOperate:setRecordByType( typeName, setInfo )
	self._record[typeName] = setInfo
	self:saveRecords()
end

function QRecordUserOperate:getRecordByType( typeName )
	return self._record[typeName]
end

-- 清掉一些记录
function QRecordUserOperate:removeRecordByTypes(recordTypes)
	if not type(recordTypes) == "table" then
		return
	end
	for i, recordType in pairs(recordTypes) do
		self._record[recordType] = nil
	end
	self:saveRecords()
end

-- 清掉所有记录
function QRecordUserOperate:clearAllRecords()
	self._record = {}
	self:saveRecords()
end

function QRecordUserOperate:saveRecords()
	if not q.isEmpty(self._record) then
		local jsonStr = json.encode(self._record)
		if jsonStr then
			writeToBinaryFile(self._fileName,jsonStr)
		end
	end
end

-- 获取宗门技能 今天是否点击过了
function QRecordUserOperate:isUnionSkillClickedToday(  )
	-- body
	local time = self._record["unionskill"] or 0
	if time > 0 then	
		local date1 = q.date("*t", time)
		local curTime = q.serverTime()
		local date2 = q.date("*t", q.serverTime())
		if date1 and date2 and date1.day == date2.day then
			
			return true
		end
	end
	return false
end

function QRecordUserOperate:setUnionSkillClickedTime(  )
	-- body
	if remote.union:checkUnionSkillRedTips() then
		self._record["unionskill"] = q.serverTime()
		self:saveRecords()
	end
end

-- 本地保存 争霸赛 邀请函显示
function QRecordUserOperate:getGloryArenaYaoqingInfo( )
	-- body
	local tbl = self._record["gloryarenayaoqing"] 
	if tbl then	
		local showtime = tbl.gloryarenaShowTime 
		local curTime = q.serverTime()
		--当前记录无效
		if not showtime then
			return false, 0 , 0
		else
			if curTime - showtime > 2*DAY then
				return false, 0 , 0
			else
				return true, tbl.gloryarenaRank or 0,tbl.gloryarenaFloor or 0
			end
		end
	end
	return false, 0 , 0
end

function QRecordUserOperate:setGloryArenaYaoqingInfo( rank, floor, time)
	-- body
	local tbl = self._record["gloryarenayaoqing"] or {}
	tbl.gloryarenaShowTime = time or q.serverTime()
	tbl.gloryarenaRank = rank
	tbl.gloryarenaFloor = floor
	self._record["gloryarenayaoqing"] = tbl
	self:saveRecords()
end


function QRecordUserOperate:getRushBuyRedTips( activityID, roundId )
	-- body
	
	local tbl = self._record["rushBuyTips"]
	if tbl then
		local status = tbl[activityID]
		if status then
			if status[roundId] then
				return false
			end
		end
	end
	return true
end


function QRecordUserOperate:setRushBuyRedTips( activityID, roundId )
	-- body
	
	local tbl = self._record["rushBuyTips"]
	if not tbl then
		tbl = {}
		self._record["rushBuyTips"] = tbl
	end
	local status = tbl[activityID]
	if not status then
		tbl = {}
		status = {}
		tbl[activityID] = status
		self._record["rushBuyTips"] = tbl
	end
	status[roundId] = true

	self:saveRecords()
end

--判断 activity的
function QRecordUserOperate:isActivityClicked( activityId )
	-- body
	local tbl = self._record["activityClicked"]
	if tbl then
		return tbl[activityId]
	end
end

function QRecordUserOperate:setActivityClicked( activityId )
	-- body
	if not activityId then
		return 
	end

	if not self._record["activityClicked"] then
		self._record["activityClicked"] = {}
	end

	local tbl = self._record["activityClicked"] 

	if not self._cleanDirtyActivityClickedData then
		local activity
		for _,activity in ipairs(remote.activity.activities or {}) do
			if tbl[activity.activityId] then
				tbl[activity.activityId] = 2
			end
		end

		for k, v in pairs(tbl) do
			if v == 2 then
				tbl[k] = 1
			else
				tbl[k] = nil
			end
		end
		self._cleanDirtyActivityClickedData = true
	end

	if not tbl[activityId] then
		tbl[activityId] = 1
		self:saveRecords()
		return true
	end
	return false
end

--[[
	xurui: 检查当前时间和记录时间的大小
	@param hour, 时间节点
	@return true, 当天时间节点之后到目前时间还没有点击过
]]
function QRecordUserOperate:compareCurrentTimeWithRecordeTime(timeType, hour)
	hour = hour == nil and 0 or hour
	local time = self._record[timeType] or 0
	if time > 0 then	
		local lastTime = q.date("*t", time)
		local currentTime = q.date("*t", q.serverTime())
		if lastTime and currentTime and lastTime.day == currentTime.day and currentTime.hour >= hour then
			return false
		end
	end
	return true
end

function QRecordUserOperate:recordeCurrentTime(timeType)
	self._record[timeType] = q.serverTime()
	self:saveRecords()
end

-- zxs 当前时间与上次记录时间是不是新的一天
function QRecordUserOperate:checkNewDayCompareWithRecordeTime(timeType, hour)
	hour = hour == nil and 0 or hour
	local time = self._record[timeType] or 0
	if time > 0 then
		-- 获取某个时间的天起始时间
		local lastFirstTime = q.getFirstTimeOfDay(time, hour)
		local curFirstTime = q.getFirstTimeOfDay(q.serverTime(), hour)
		if lastFirstTime and curFirstTime and curFirstTime <= lastFirstTime then
			return false
		end
	end
	return true
end

-- zxs 当前时间与上次记录时间是不是新的一周
function QRecordUserOperate:checkNewWeekCompareWithRecordeTime(timeType, hour)
	hour = hour == nil and 0 or hour
	local time = self._record[timeType] or 0
	if time > 0 then
		-- 获取某个时间的周起始时间
		local lastFirstTime = q.getFirstTimeOfWeek(time, hour)
		local curFirstTime = q.getFirstTimeOfWeek(q.serverTime(), hour)
		if lastFirstTime and curFirstTime and curFirstTime <= lastFirstTime then
			return false
		end
	end
	return true
end

--[[
	zxs: 小助手记录
]]
function QRecordUserOperate:setHelpRecordeCountByType(helpType, count)
	self._record[helpType] = count
	self:saveRecords()
end

function QRecordUserOperate:getHelpRecordeCountByType(helpType)
	return self._record[helpType] or 0
end

function QRecordUserOperate:setHelpRecordTime(date)
	self._record["helpRecordDate"] = date
	self:saveRecords()
end

function QRecordUserOperate:getHelpRecordTime()
	return self._record["helpRecordDate"]
end

--[[
	xurui: 保存洗炼的锁定状态
]]
function QRecordUserOperate:setRefineLockState(actorId, states)
	if self._record["refineLockState"] == nil then
		self._record["refineLockState"] = {}
	end
	self._record["refineLockState"][actorId] = states
	self:saveRecords()
end

function QRecordUserOperate:getRefineLockState(actorId)
	if self._record["refineLockState"] == nil then return {} end
	return self._record["refineLockState"][actorId] or {}
end

--[[
	xurui: 保存商店一键购买配置
]]
function QRecordUserOperate:setShopQuickBuyConfiguration(shopId, configuration)
	local configStr = ""
	for _, value in pairs(configuration) do
		for _, data in pairs(value) do
			if configStr == "" then
				configStr = data.id.."^"..data.moneyType.."^"..(data.moneyNum or 0)
			else
				configStr = configStr..";"..data.id.."^"..data.moneyType.."^"..(data.moneyNum or 0)
			end
		end
	end

	self._record["shopQuickBuy_"..shopId] = configStr
	self:saveRecords()
end

function QRecordUserOperate:getShopQuickBuyConfiguration(shopId)
	if self._record["shopQuickBuyResetRecord_"..shopId] == nil then
		self._record["shopQuickBuy_"..shopId] = ""
		self._record["shopQuickBuyResetRecord_"..shopId] = 1
		self:saveRecords()
	end
	local data = self._record["shopQuickBuy_"..shopId]
	if data == nil or data == "" then return {} end
	data = string.split(data, ";")

	local configuration = {}
	for _, value in pairs(data) do
		local config = string.split(value, "^")
		local id = tonumber(config[1])
		if id == nil then 
			id = config[1]
		end
		if configuration[id] == nil then
			configuration[id] = {}
			configuration[id][1] = {id = id, moneyType = config[2], moneyNum = config[3]}
		elseif configuration[id][2] == nil then
			configuration[id][2] = {id = id, moneyType = config[2], moneyNum = config[3]}
		elseif configuration[id][3] == nil then
			configuration[id][3] = {id = id, moneyType = config[2], moneyNum = config[3]}
		else
			configuration[id][4] = {id = id, moneyType = config[2], moneyNum = config[3]}
		end
	end

	return configuration or {}
end

-- vicentboo 记录魂师商店刷新的等级区间
function QRecordUserOperate:setTeamLevleInterval(teamLevelMin,teamLevelMax)
	if self._record["teamLevleInterval"] == nil then
		self._record["teamLevleInterval"] = {}
	end
	self._record["teamLevleInterval"].teamLevelMin = teamLevelMin
	self._record["teamLevleInterval"].teamLevelMax = teamLevelMax
	self:saveRecords()
end

function QRecordUserOperate:getTeamLevleInterval()
	if self._record["teamLevleInterval"] == nil then return nil end
	return self._record["teamLevleInterval"] or nil
end

function QRecordUserOperate:setShopLimitQuickBuyConfiguration(shopId, configuration)
	local configStr = ""
	for _, value in pairs(configuration) do
		if configStr == "" then
			configStr = configStr..value.gridId.."^"..value.itemId
		else
			configStr = configStr..";"..value.gridId.."^"..value.itemId
		end
	end

	self._record["shopQuickBuy_"..shopId] = configStr
	self:saveRecords()
end

function QRecordUserOperate:getShopLimitQuickBuyConfiguration(shopId)
	local data = self._record["shopQuickBuy_"..shopId]
	if data == nil or data == "" then
		return {} 
	end
	data = string.split(data, ";")
	local configuration = {}
	for _, value in pairs(data) do
		local config = string.split(value, "^")
		table.insert(configuration, {gridId = tonumber(config[1]), itemId = tonumber(config[2])})
	end
	return configuration
end

--[[
	Kumo: 保存一键扫荡的一些设置信息
]]
function QRecordUserOperate:setRobotSoulSetting( key, value )
	if self._record["robotSoul"] == nil then
		self._record["robotSoul"] = {}
	end
	self._record["robotSoul"][key] = value
	self:saveRecords()
end

function QRecordUserOperate:getRobotSoulSetting( key )
	if self._record["robotSoul"] == nil then return false end
	return self._record["robotSoul"][key] or false
end

function QRecordUserOperate:hasRobotSoulSetting()
	if self._record["robotSoul"] == nil then return false end
	return true
end

--[[
	Kumo: 保存一键扫荡材料的一些设置信息
]]
function QRecordUserOperate:setRobotMaterialSetting( key, value )
	if self._record["robotMaterial"] == nil then
		self._record["robotMaterial"] = {}
	end
	self._record["robotMaterial"][key] = value
	self:saveRecords()
end

function QRecordUserOperate:getRobotMaterialSetting( key )
	if self._record["robotMaterial"] == nil then return false end
	return self._record["robotMaterial"][key] or false
end

function QRecordUserOperate:hasRobotMaterialSetting()
	if self._record["robotMaterial"] == nil then return false end
	return true
end
--[[
	Kumo: 保存要塞扫荡的一些设置信息
]]
function QRecordUserOperate:setRobotInvasionSetting( key, value )
	if self._record["robotInvasion"] == nil then
		self._record["robotInvasion"] = {}
	end
	self._record["robotInvasion"][key] = value
	self:saveRecords()
end

function QRecordUserOperate:getRobotInvasionSetting( key )
	if self._record["robotInvasion"] == nil then return false end
	return self._record["robotInvasion"][key] or false
end

function QRecordUserOperate:hasRobotInvasionSetting()
	if self._record["robotInvasion"] == nil then return false end
	return true
end

--保存减负功能的解锁状态
function QRecordUserOperate:setReduceFunctionUnlockState(states)
	if self._record["reduceUnlockState"] == nil then
		self._record["reduceUnlockState"] = {}
	end
	local state = ""

	for key, value in pairs(states) do
		if state == "" then
			state = key.."^"..value.state
		else
			state = state..";"..key.."^"..value.state
		end
	end
	
	self._record["reduceUnlockState"] = state
	self:saveRecords()
end

function QRecordUserOperate:getReduceFunctionUnlockState()
	if self._record["reduceUnlockState"] == nil then return {} end

	local states = string.split(self._record["reduceUnlockState"], ";")
	local unlockState = {}
	for key, value in pairs(states) do
		local tempData = string.split(value, "^")
		unlockState[tempData[1]] = tonumber(tempData[2])
	end

	return unlockState
end

--[[
	保存埋点数据
]]
function QRecordUserOperate:setMaxBuriedPoint(point)
	self._record["maxBuriedPoint"] = point
	self:saveRecords()
end

function QRecordUserOperate:getmaxBuriedPoint()
	return self._record["maxBuriedPoint"] or 0
end

--[[
	保存手机网页链接小红点
]]
function QRecordUserOperate:setOpenUrlRedTip()
	self._record["openUrlRedTip"] = false
	self:saveRecords()
end

function QRecordUserOperate:getOpenUrlRedTip()
	return self._record["openUrlRedTip"] == nil and true or false
end


--[[
	Kumo: 雷电王座一件扫荡选择保存
]]
function QRecordUserOperate:setThunderRobot( key, value )
	if self._record["thunderRobot"] == nil then
		self._record["thunderRobot"] = {}
	end
	self._record["thunderRobot"][key] = value
	self:saveRecords()
end

function QRecordUserOperate:getThunderRobot( key )
	if self._record["thunderRobot"] == nil then return false end
	return self._record["thunderRobot"][key] or false
end

--[[
	Kumo: 魂兽入侵扫荡选择保存
]]
function QRecordUserOperate:setRobotRebelSetting( value )
	self._record.robotRebel = value
	self:saveRecords()
end

function QRecordUserOperate:getRobotRebelSetting()
	return self._record.robotRebel or false
end

function QRecordUserOperate:isFirstInPlunderToday()
	local time = self._record["firstPlunder"] or 0
	if time > 0 then	
		local lastTime = q.date("*t", time)
		local currentTime = q.date("*t", q.serverTime())
		if lastTime and currentTime and lastTime.day == currentTime.day and currentTime.hour >= 0 then
			return false
		end
	end
	return true
end

function QRecordUserOperate:recordeInPlunder()
	self._record["firstPlunder"] = q.serverTime()
	self:saveRecords()
end

--[[
	商店自动出售金币兑换功能
]]
function QRecordUserOperate:setStoreAutoSellItem(state)
	if state then
		self._record.storeAutoSellItem = q.serverTime()	
	else
		self._record.storeAutoSellItem = 0
	end
	self:saveRecords()
end

function QRecordUserOperate:getStoreAutoSellItem()
	local time = self._record.storeAutoSellItem or 0
	if time == 0 then
		return false
	else
		local lastTime = q.date("*t", time)
		local currentTime = q.date("*t", q.serverTime())
		if currentTime.hour >= 5 and (lastTime.hour < 5 or lastTime.day ~= currentTime.day) then
			return false
		end
	end

	return true
end


-- 魂兽入侵扫荡选择保存
function QRecordUserOperate:setInvasionFastFightSetting(key, value )
	self._record["invasion_fast_fight"..key] = value
	self:saveRecords()
end

function QRecordUserOperate:getInvasionFastFightSetting(key)
	return self._record["invasion_fast_fight"..key]
end

-- 武魂殿半价
function QRecordUserOperate:setTavernHalfBuySetting( state )
	self._record["tavern_half_buy"] = state
	self:saveRecords()
end

function QRecordUserOperate:getTavernHalfBuySetting()
	return self._record["tavern_half_buy"]
end

-- 魂师皮肤分享次数和时间
function QRecordUserOperate:setHeroSkinShareTimes()
	self._record["heroSkinShareCount"] = (self._record["heroSkinShareCount"] or 0) + 1
	self._record["heroSkinShareTime"] = q.serverTime()

	if self._record["heroSkinShareCount"] > 5 then
		self._record["heroSkinShareCount"] = 1
	end
	
	self:saveRecords()
end

function QRecordUserOperate:getHeroSkinShareTimes()
	local canShare = true

	local count = self._record["heroSkinShareCount"] or 0
	local time = self._record["heroSkinShareTime"] or 0

	local lastTime = time + (5 * MIN) - q.serverTime()
	if count >= 5 and lastTime > 0 then
		canShare = false
		local tip = "5分钟之内只能分享5次，%s后可分享"
		app.tip:floatTip(string.format(tip, q.timeToHourMinuteSecond(lastTime)))
	end

	return canShare
end

-- 龙战排行榜显示状态
function QRecordUserOperate:setDragonWarRankStated( stated )
	self._record["dragon_war_rank_stated"] = stated
	self:saveRecords()
end

function QRecordUserOperate:getDragonWarRankStated()
	return self._record["dragon_war_rank_stated"]
end

-- 龙战祝福加成
function QRecordUserOperate:setDragonWarBuffTipTime( time )
	self._record["dragon_war_buff_tip_time"] = time
	self:saveRecords()
end

function QRecordUserOperate:getDragonWarBuffTipTime()
	return self._record["dragon_war_buff_tip_time"]
end

-- 龙战祝福加成
function QRecordUserOperate:setStoreSelectQuickBuyStated( shopId, stated )
	self._record["store_select_quick_buy_stated"..shopId] = stated
	self:saveRecords()
end

function QRecordUserOperate:getStoreSelectQuickBuyStated(shopId)
	return self._record["store_select_quick_buy_stated"..shopId]
end

-- 精英赛
function QRecordUserOperate:setSanctuaryShowAnnouce( type, stated )
	self._record["sanctuary_show_type_"..type] = stated
	self:saveRecords()
end

function QRecordUserOperate:getSanctuaryShowAnnouce(type)
	return self._record["sanctuary_show_type_"..type]
end

--一键强化保存记录
function QRecordUserOperate:setOneClickStrengthen(stated )
	self._record["yijianqianghua_max"] = stated
	self:saveRecords()
end

function QRecordUserOperate:getOneClickStrengthen()
	return self._record["yijianqianghua_max"]
end

--一键强化仙品保存记录
function QRecordUserOperate:setMagicOneClickStrengthen(stated )
	self._record["magic_yijianqianghua_max"] = stated
	self:saveRecords()
end

function QRecordUserOperate:getMagicOneClickStrengthen()
	return self._record["magic_yijianqianghua_max"]
end

--一键强化保存记录
function QRecordUserOperate:setGemstoneOneClickStrengthen(stated )
	self._record["gemstone_yijianqianghua_max"] = stated
	self:saveRecords()
end

function QRecordUserOperate:getGemstoneOneClickStrengthen()
	return self._record["gemstone_yijianqianghua_max"]
end

--外附魂骨一键强化保存记录
function QRecordUserOperate:setSparOneClickStrengthen(stated )
	self._record["spar_yijianqianghua_max"] = stated
	self:saveRecords()
end

function QRecordUserOperate:getSparOneClickStrengthen()
	return self._record["spar_yijianqianghua_max"]
end

--饰品一键保存记录
function QRecordUserOperate:setJewelryOneClickStrengthen(onClickKey, stated )
	if onClickKey == nil then return end

	self._record["jewelry_yijian_max_"..onClickKey] = stated
	self:saveRecords()
end

function QRecordUserOperate:getJewelryOneClickStrengthen(onClickKey)
	if onClickKey == nil then return false end
	return self._record["jewelry_yijian_max_"..onClickKey]
end

-- zxs 小秘书设置保存记录
function QRecordUserOperate:setSecretarySetting( setting )
	self._record["secretary"] = setting
	self:saveRecords()
end

function QRecordUserOperate:getSecretarySetting( )
	return self._record["secretary"] or ""
end

-- lxb 冰火两仪设置保存记录
function QRecordUserOperate:setMonoplySetting( setting )
	self._record["monoply"] = setting
	self:saveRecords()
end

function QRecordUserOperate:getMonoplySetting( )
	return self._record["monoply"] or ""
end

function QRecordUserOperate:setMonoplyOneSetting(setting)
	self._record["monoply_one"] = setting
	self:saveRecords()
end

function QRecordUserOperate:getMonoplyOneSetting( )
	return self._record["monoply_one"] or ""
end
--xurui: 记录传灵塔上次进入章节
function QRecordUserOperate:setBlackRockChapterSetting( setting )
	self._record["blackRockLastChapter"] = setting
	self:saveRecords()
end

function QRecordUserOperate:getBlackRockChapterSetting( )
	return self._record["blackRockLastChapter"]
end

--记录传灵塔队伍筛选设置
function QRecordUserOperate:setBlackRockTeamSetInfo( setting )
	self._record["blackRockTeamSelect"] = setting
	self:saveRecords()
end

function QRecordUserOperate:getBlackRockTeamSetInfo(  )
	return self._record["blackRockTeamSelect"]
end

--记录魂师商店自动刷新次数
function QRecordUserOperate:setStoreQuickRefreshCount(count)
	self._record["storeQuickRefreshCount"] = count
	self:saveRecords()
end

function QRecordUserOperate:getStoreQuickRefreshCount(  )
	return self._record["storeQuickRefreshCount"]
end

--记录训练关上阵信息
function QRecordUserOperate:setCollegeTrainTeam(heroList,chapterId)
	self._record["TEAM_COLLEGE_TRAIN_"..chapterId] = heroList
	self:saveRecords()
end

function QRecordUserOperate:getCollegeTrainTeam(chapterId)
	return self._record["TEAM_COLLEGE_TRAIN_"..chapterId] or {}
end

-- 同步阵容 单队
function QRecordUserOperate:setSyncFormationSingleSetting( setting )
	self._record["syncFormationSingle"] = setting
	self:saveRecords()
end

function QRecordUserOperate:getSyncFormationSingleSetting( )
	return self._record["syncFormationSingle"] or ""
end

-- 同步阵容 双队
function QRecordUserOperate:setSyncFormationDoubleSetting( setting )
	self._record["syncFormationDouble"] = setting
	self:saveRecords()
end

function QRecordUserOperate:getSyncFormationDoubleSetting( )
	return self._record["syncFormationDouble"] or ""
end

return QRecordUserOperate