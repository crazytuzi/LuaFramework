--
-- Author: wkwang
-- Date: 2014-08-14 15:26:46
-- 副本数据管理

local QBaseModel = import("..models.QBaseModel")
local QInstance = class("QInstance", QBaseModel)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QVIPUtil = import("..utils.QVIPUtil")
local QUIViewController = import("..ui.QUIViewController")

-- 副本彩蛋的最大章節號
QInstance.MAP_EGG_MAX_ID = 102001
QInstance.UPDATE_EGG_INFO = "UPDATE_EGG_INFO"

function QInstance:ctor(options)
	QInstance.super.ctor(self)
	self.passInfo = {}
	self.passAwardConfig = {}		-- 通关奖励配置
	self.normalInfo = {}
	self.eliteInfo = {}
	self.dropItem = {}
	self.passAwards = {}
	self._passInfo = nil
	
	self.isNewElite = true
	self.isShowInstanceRedPoint = false --主场景instance是否显示小红点
	self.showSkipBattle = true --本次登录是否显示战力压制
	self.battleType = 1 --可以进行战力压制时是否直接跳过战斗（1，进入战斗；2，跳过战斗）
	self.skipBattleCount = 0 --本次登录跳过关卡数量
	self.specialDungeonTip = 0 --本次登录是否弹过特殊剧情tip
	self.forceNoEnoughTip = 0  --本次登录是否弹过战力不足tip
	self.isIsBattle = false
end

function QInstance:init()
	self._remoteProexy = cc.EventProxy.new(remote.user)
	self._remoteProexy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, function ()
		self:checkEliteUnlock()
	end)
	self:setIsNew(false)

	-- 通关奖励配置
	self.passAwardConfig = {}
	local awardConfig = db:getStaticByName("dungeon_pass_awards") or {}
	for i, v in pairs(awardConfig) do
		table.insert(self.passAwardConfig, v)
	end
	table.sort(self.passAwardConfig, function(a, b)
		return tonumber(a.id) < tonumber(b.id)
	end)
end

function QInstance:loginEnd()
	app:getClient():getDungeonInfo(function(data)
			self:updateInstanceInfo()
		end)
end

function QInstance:disappear()
	if self._remoteProexy ~= nil then 
		self._remoteProexy:removeAllEventListeners()
		self._remoteProexy = nil
	end
	
	self.showSkipBattle = true --本次登录是否显示战力压制
	self.skipBattleCount = 0
	self.specialDungeonTip = 0
	self.forceNoEnoughTip = 0
	self.isIsBattle = false
end

--设置副本通过信息
-- "userId": "TEST005",
-- "dungeonId": "1-1-1",
-- "dungeonType": 1,
-- "firstPass": 1399635461937,
-- "lastPass": 1399635461937,
-- "todayPass": 32,
-- "star" : 3     
function QInstance:updateInstanceInfo(info)
    local need_initialization = #self.normalInfo == 0 or #self.eliteInfo == 0

	self.passCountInfo = {}
	self.passCountInfo["c_todayNormalPass"] = 0
	self.passCountInfo["c_todayElitePass"] = 0
	self.passCountInfo["c_allNormalPass"] = 0
	self.passCountInfo["c_allStarNormalPass"] = 0
	self.passCountInfo["c_allStarElitePass"] = 0
	self.passCountInfo["c_allStarCount"] = 0

	self._refreshTime = q.refreshTime(remote.user.c_systemRefreshTime) * 1000

	self.config = QStaticDatabase:sharedDatabase():getMaps()
	
	self._redTip = false
	if need_initialized then
		self.dropItem = {}
	end
	info = info or {}
	for id,value in pairs(info) do
		if value.id ~= nil then
			self.passInfo[value.id] = value
		end
	end
	if need_initialization then
		self.normalInfo = {}
		self.eliteInfo = {}
		local total = table.nums(self.config)
		for i=1,total,1 do
			local config = self.config[tostring(i)]
			config = q.cloneShrinkedObject(config)
			config.unlock_team_level = tonumber(config.unlock_team_level)
			if config.dungeon_type == DUNGEON_TYPE.ELITE then
				table.insert(self.eliteInfo, config)
			elseif config.dungeon_type == DUNGEON_TYPE.NORMAL then
				table.insert(self.normalInfo, config)
			end
		end
	end
	self:mergeDungeonInfo(self.normalInfo, need_initialization)
	self:mergeDungeonInfo(self.eliteInfo, need_initialization)
	self.isNewElite = false
	self:checkEliteUnlock(true)
	remote.user:update(self.passCountInfo)

	local _, normalBoo = self:getDungeonRedPointList(DUNGEON_TYPE.NORMAL)
	local _, eliteBoo = self:getDungeonRedPointList(DUNGEON_TYPE.ELITE)

	if normalBoo == true or eliteBoo == true then
		self.isShowInstanceRedPoint = true
	else
		self.isShowInstanceRedPoint = false
	end

	self:updatePassAwardsInfo()
end

function QInstance:checkEliteUnlock(isForce)
	if self._eliteUnlock == nil or isForce == true then
		self._eliteUnlock = app.unlock:getUnlockElite()
		if app.unlock:getUnlockElite() == false then
			for _,config in pairs(self.eliteInfo) do
				config.isLock = false
			end
		end
	elseif self._eliteUnlock == false and app.unlock:getUnlockElite() == true then
		self._eliteUnlock = app.unlock:getUnlockElite()
		for _,config in pairs(self.eliteInfo) do
			config.isLock = self:checkIsPassByDungeonId(config.unlock_dungeon_id)
		end
	end
end

function QInstance:mergeDungeonInfo(tbl, need_initialization)
	local instanceId 
	local instanceIndex = 0
	local dungeonIndex = 0
	local perDungeon = nil -- [Kumo] 上一个关卡
	if need_initialization then
		for _,config in pairs(tbl) do
			if instanceId == nil or instanceId ~= config.instance_id then
				instanceId = config.instance_id
				instanceIndex = instanceIndex + 1
				dungeonIndex = 1
			else
				dungeonIndex = dungeonIndex + 1
			end

			if perDungeon ~= nil and config.dungeon_type == perDungeon.dungeon_type then
				if config.unlock_dungeon_id == nil then
					config.unlock_dungeon_id = perDungeon.dungeon_id
				else
					config.unlock_dungeon_id = config.unlock_dungeon_id .. ","..perDungeon.dungeon_id
				end
			end
			if config.number == nil then
				config.number = instanceIndex.."-"..dungeonIndex -- [Kumo] “章节-关卡”
			end
			config.instanceIndex = instanceIndex
			perDungeon = config
			--预先添加可掉落物品集
			local dungeonConfig = QStaticDatabase:sharedDatabase():getDungeonConfigByID(config.dungeon_id)
			if dungeonConfig ~= nil then
				local items = string.split(dungeonConfig.drop_item,";")
				for _,itemId in pairs(items) do
					itemId = tonumber(itemId)
					if itemId ~= nil then
						if self.dropItem[itemId] == nil then
							self.dropItem[itemId] = {}
						end
						table.insert(self.dropItem[itemId], {map = config, dungeon = dungeonConfig})
					end
				end
			end
		end
	end
	local _passInfo = self.passInfo or {}
	for _,config in pairs(tbl) do
		config.isLock = self:checkIsPassByDungeonId(config.unlock_dungeon_id)
		local value = _passInfo[config.dungeon_id]
		if value then
			--如果新通关则标志为最新通关
			if config.info == nil or config.info.lastPassAt == nil then
				if self.isNewElite == false then self:setIsNew(true) end
			end
			config.info = value

			if config.dungeon_isboss and value.bossBoxOpened == false then
				self._redTip = true
			end

			--计算通关统计
			self:countPassInfo(config)
		end
	end
end

--计算需要挑战的副本
function QInstance:countNeedPassForType(type)
	local infoTable
	if type == DUNGEON_TYPE.NORMAL then
		infoTable = self.normalInfo
	elseif type == DUNGEON_TYPE.ELITE then
		infoTable = self.eliteInfo
	end
	if infoTable == nil then return end

	local lastPassId = nil
	for _,value in pairs(infoTable) do
		if value.dungeon_type == type then 
			if value.info ~= nil then
				lastPassId = value.dungeon_id
			end
		end
	end

	for _,value in pairs(infoTable) do
		if value.dungeon_type == type then 
			if (value.info == nil or (value.info.lastPassAt or 0) <= 0) and (value.unlock_team_level or 0) <= remote.user.level and value.isLock == true then
				return value.dungeon_id
			end
		end
	end
	return lastPassId
end

--根据ID获取该关卡的通关信息
function QInstance:getPassInfoForDungeonID(id)
	for _,value in pairs(self.passInfo) do
		if id == value.id then
			return value
		end
	end
end

--根据ID获取该关卡之后的关卡
function QInstance:getNextIDForDungeonID(id, type)
	local isFind = false
	local findID = nil
	local infoTable
	if type == DUNGEON_TYPE.NORMAL then
		infoTable = self.normalInfo
	elseif type == DUNGEON_TYPE.ELITE then
		infoTable = self.eliteInfo
	end
	if infoTable == nil then return id end
	for _,value in pairs(infoTable) do
	    if isFind == true then
	      return value.dungeon_id
	    end
		if value.dungeon_id == id then 
			isFind = true
		end
	end
	return id
end

-- 获取所有已解锁副本集合
-- {
-- 	id:"instanceId",
-- 	data:
-- 	{
-- 		instance_id: "map1_1",
-- 		instance_name: "哀嚎上",
-- 		instance_icon: "icon/head/anacondra.png",
-- 		dungeon_id: "wailing_caverns_1",
-- 		dungeon_type: "1",
-- 		attack_num: 99,
-- 		dungeon_isboss: false,
-- 		dungeon_icon: "icon/head/ectoplasm.png",
-- 		file: "ccb/Widget_EliteMap.ccbi",
-- 		info:
-- 		{
-- 			"userId": "TEST005",
--             "dungeonId": "1-1-1",
--             "dungeonType": 1,
--             "firstPass": 1399635461937,
--             "dungeonDifficulty": 1,
--             "lastPass": 1399635461937,
--             "todayPass": 32
-- 		}
-- 	}
-- }
function QInstance:getInstancesWithUnlockAndType(type)
	local tbl = {} -- [Kumo] 保存一级地图上所有章节的表
	local instanceId
	local instanceLock
	local tblValue = {} -- [Kumo] 保存单个章节的信息的表，id、星、数据表
	local infoTable
	if type == DUNGEON_TYPE.NORMAL then
		infoTable = self.normalInfo
	elseif type == DUNGEON_TYPE.ELITE then
		infoTable = self.eliteInfo
	end
	if infoTable == nil then
		return tbl
	end
	
	for _,value in pairs(infoTable) do
		if value.dungeon_type == type then
			if instanceId == nil or instanceId ~= value.instance_id then
				tblValue = {}
				tbl[#tbl+1] = tblValue
				instanceId = value.instance_id
				instanceLock = (value.isLock and (remote.user.level >= value.unlock_team_level or 0)) or false
				tblValue.id = instanceId
				tblValue.star = 0
				tblValue.data = {}
			end 
			if instanceLock == true then
				if value.info ~= nil then
					tblValue.star = (tblValue.star or 0) + (value.info.star or 0)
				end
				table.insert(tblValue.data, value)
			else
				tbl[#tbl] = nil
				break
			end
		end
	end
	return tbl
end

--根据ID查询副本信息
function QInstance:getInstancesById(id)
	local list = {}
	for _,value in pairs(self.normalInfo) do
		if id == value.instance_id or id == value.int_instance_id then
			table.insert(list, value)
		end
	end
	for _,value in pairs(self.eliteInfo) do
		if id == value.instance_id or id == value.int_instance_id then
			table.insert(list, value)
		end
	end
	return list
end

--根据index查询副本信息
function QInstance:getInstancesByIndex(index, type)
	local infoTable
	if type == DUNGEON_TYPE.NORMAL then
		infoTable = self.normalInfo
	elseif type == DUNGEON_TYPE.ELITE then
		infoTable = self.eliteInfo
	end
	if infoTable == nil then return end
	local instanceId = nil
	local _index = 0
	local tbl ={}
	for _,info in ipairs(infoTable) do
		if info.instance_id ~= instanceId then
			instanceId = info.instance_id
			_index = _index + 1
		end
		if _index == index then
			table.insert(tbl, info)
		elseif _index > index then
			break
		end
	end
	return tbl
end

--根据ID查询关卡信息
function QInstance:getDungeonById(id)
	for _,value in pairs(self.normalInfo) do
		if id == value.dungeon_id then
			return value
		end
	end
	for _,value in pairs(self.eliteInfo) do
		if id == value.dungeon_id then
			return value
		end
	end
	return nil
end

--获取指定ID的失败次数
function QInstance:getLostCountById(id)
	local config = self:getDungeonById(id)
	if config ~= nil and config.info ~= nil then
		return config.info.failCount or 0
	end
	return 0
end

--设置指定ID的失败次数
function QInstance:addLostCountById(id)
	local config = self:getDungeonById(id)
	if config ~= nil then
		if config.info == nil then 
			config.info = {}
		end
		if config.info.failCount == nil then
			config.info.failCount = 1
		else
			config.info.failCount = config.info.failCount + 1
		end
	end
end

--检查关卡是否显示星星信息
function QInstance:checkDungeonIsShowStar(dungeonId)
	local dungeonInfo = self:getDungeonById(dungeonId)
	if dungeonInfo == nil then
		return false
	end
	local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
	if globalConfig.DUNGEON_STAR_SHOW ~= nil and globalConfig.DUNGEON_STAR_SHOW.value ~= nil then
		local starDungeonConfig = self:getDungeonById(globalConfig.DUNGEON_STAR_SHOW.value)
		if starDungeonConfig ~= nil and starDungeonConfig.id > dungeonInfo.id then
			return false
		end
	end
	return true
end

--[[
	更新副本宝箱信息
]]
function QInstance:updateDropBoxInfoById(mapStars)
	for id,value in pairs(mapStars) do
	    self:setDropBoxInfoById(value.mapId,value)
	end
end

--[[
	设置副本领取宝箱信息
]]
function QInstance:setDropBoxInfoById(id,data)
	if self._dropInfo == nil then 
		self._dropInfo = {}
	end
	self._dropInfo[id] = data
end

--[[
	根据副本ID查询星星宝箱掉落信息
]]
function QInstance:getDropBoxInfoById(id,callBack)
	if self._dropInfo == nil then 
		self._dropInfo = {}
	end
	callBack(self._dropInfo[id] or {})
end

--[[
	根据物品ID查询掉落信息
]]
function QInstance:getDropInfoByItemId(id, type)
	local dungeonInfo = {}
	if id == nil or type == nil then
		return dungeonInfo
	end
	local dropInfo = self.dropItem[id]
	if dropInfo == nil or #dropInfo == 0 then
		return dungeonInfo
	end
	if type == DUNGEON_TYPE.ALL then
		return dropInfo
	end
	for _,value in pairs(dropInfo) do
		if value.map.dungeon_type == type then
			table.insert(dungeonInfo, value)
		end
	end
	return dungeonInfo
end

--检查一组副本ID是否通过 "id1,id2,id3"
function QInstance:checkIsPassByDungeonId(id)
	if id == nil then return true end
	local ids = string.split(id, ",")
	local isFind = false
	local _passInfo = self.passInfo or {}
	local value
	for _,id in ipairs(ids) do 
		isFind = false
		value = _passInfo[id]
		if value and value.lastPassAt > 0 then
			isFind = true
		end
		if isFind == false then
			return false
		end
	end
	return true
end

function QInstance:checkDungeonType(dungeonType)
	if 	dungeonType == DUNGEON_TYPE.NORMAL or 
		dungeonType == DUNGEON_TYPE.ELITE or 
		dungeonType == DUNGEON_TYPE.WELFARE then
		return true
	end
	return false
end

--设置或获取最近新通关副本
function QInstance:setIsNew(b)
	app:setObject("local_data_isFristBattle",b)
end

function QInstance:getIsNew()
	return app:getObject("local_data_isFristBattle") or false
end

--第一次打副本的时候前端模拟info信息
function QInstance:setDungeonStartFrist(dungeonId)
	local dungeonInfo = self:getDungeonById(dungeonId)
	if dungeonInfo ~= nil and dungeonInfo.info == nil then
		dungeonInfo.info = {}
	end
end

--get dungeon today fight count by dungeon id
function QInstance:getFightCountBydungeonId(dungeonId)
	local todayPass = 0
	local info = self:getDungeonById(dungeonId)
	if info.info ~= nil and info.info.todayPass ~= nil then
		if info.info.lastPassAt ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) <= (info.info.lastPassAt/1000) then
			todayPass = info.info.todayPass
		end
	end
	return info.attack_num - todayPass
end

--计算副本的通关统计
-- self._todayNormalPass 今天普通关卡通关次数
-- self._todayElitePass 今天精英关卡通关次数
-- self._allStarNormalPass 所有三星的普通关卡
-- self._allStarElitePass 所有三星的经验关卡
-- self._allStarCount 所有星星数量
function QInstance:countPassInfo(config)
	if config.info ~= nil then
		local passCount = 0
		local starCount = 0
		if config.info.lastPassAt > self._refreshTime then
			passCount = config.info.todayPass + (config.info.todayReset or 0) * config.attack_num
		end
		if config.info.star > 2 then
			starCount = 1
		end

		self.passCountInfo["c_allStarCount"] = self.passCountInfo["c_allStarCount"] + (config.info.star or 0)
		if config.dungeon_type == DUNGEON_TYPE.ELITE then
			self.passCountInfo["c_todayElitePass"] = self.passCountInfo["c_todayElitePass"] + passCount
			self.passCountInfo["c_allStarElitePass"] = self.passCountInfo["c_allStarElitePass"] + (config.info.star or 0)
		elseif config.dungeon_type == DUNGEON_TYPE.NORMAL then
			self.passCountInfo["c_todayNormalPass"] = self.passCountInfo["c_todayNormalPass"] + passCount
			self.passCountInfo["c_allStarNormalPass"] = self.passCountInfo["c_allStarNormalPass"] + (config.info.star or 0)
		end
	end
end

-- @qinyuanji
-- get lastpass date of dungeon
function QInstance:dungeonLastPassAt(dungeon_id)
	if self.passInfo ~= nil then
		for _, v in pairs(self.passInfo) do 
			if v.id == dungeon_id and v.lastPassAt > 0 then
				return v.lastPassAt
			end
		end
	end

	return -1
end

-- @xurui
-- 检查指定副本总星数是否足够
function QInstance:checkEliteBox()
	return self._redTip
end

--[[
	设置刚刚通关的副本
]]
function QInstance:setLastPassId(id)
	self._lastPassId = id
end

--[[
	获取刚刚通关的副本
]]
function QInstance:getLastPassId()
	return self._lastPassId
end

--[[
    功能：计算普通副本一级地图里小红点
    返回类型：table, boolean
]]
function QInstance:getDungeonRedPointList( instanceType )
	local info = {}
	if instanceType == DUNGEON_TYPE.NORMAL then
		if not self.normalInfo or #self.normalInfo == 0 then return nil, false end
		info = self.normalInfo
	elseif instanceType == DUNGEON_TYPE.ELITE then
	 	if not self.eliteInfo or #self.eliteInfo == 0 then return nil, false end
		info = self.eliteInfo
	else
		return nil, false 
	end

	local tbl = {} 
	local index = 0
	local instanceID = ""
	local instanceIDs = {}
	local isShowDungeonBtnPoint = false

	for _, dungeon in pairs(info) do
		-- 遍历检查BOSS宝箱是否有未开启的
		if dungeon.instance_id ~= instanceID then
			if not instanceIDs[dungeon.instance_id] then
				instanceID = dungeon.instance_id
				index = index + 1
				instanceIDs[instanceID] = {}
				instanceIDs[instanceID]["int_instance_id"] = dungeon.int_instance_id
				instanceIDs[instanceID]["index"] = index
				instanceIDs[instanceID]["number"] = 1 -- 记录一个章节里面有多少关卡
				instanceIDs[instanceID]["stars"] = 0 -- 记录一个章节获得多少星
				tbl[index] = false
			else
				instanceID = dungeon.instance_id
				index = instanceIDs[instanceID]["index"]
				instanceIDs[instanceID]["number"] = instanceIDs[instanceID]["number"]  + 1
			end
		else
			instanceIDs[instanceID]["number"] = instanceIDs[instanceID]["number"]  + 1
		end
		if dungeon.info ~= nil and dungeon.info.lastPassAt ~= nil and dungeon.info.lastPassAt > 0 then
			instanceIDs[instanceID]["stars"] = instanceIDs[instanceID]["stars"]  + tonumber(dungeon.info.star)
			if dungeon.info.bossBoxOpened == false and dungeon.dungeon_isboss == true and dungeon.info.star > 0 then
				tbl[index] = true
				self.isShowInstanceRedPoint = true
				isShowDungeonBtnPoint = true
			end
		end
	end

	-- print("检查星级宝箱是否有未开启的")
	for id, data in pairs(instanceIDs) do
		-- 检查星级宝箱是否有未开启的
		if data["stars"] ~= 0 then
			local dropInfo = {}
			local isRedTips = false
			if self._dropInfo and table.nums(self._dropInfo) > 0  then 
				dropInfo = self._dropInfo[data.int_instance_id] or {}
			end
			local achievementConfig = QStaticDatabase:sharedDatabase():getMapAchievement( id )
			if achievementConfig ~= nil then
				if data["stars"] >= achievementConfig.box1 and dropInfo["isDraw1"] ~= true  then 
					isRedTips = true
				elseif data["stars"] >= achievementConfig.box2 and dropInfo["isDraw2"] ~= true  then 
					isRedTips = true
				elseif data["stars"] >= achievementConfig.box3 and dropInfo["isDraw3"] ~= true  then 
					isRedTips = true
				end
			end
			if tbl[data["index"]] ~= true then
				tbl[data["index"]] = isRedTips
			end
			if isRedTips then
				self.isShowInstanceRedPoint = isRedTips
				isShowDungeonBtnPoint = isRedTips
			end
		end
	end

	return tbl, isShowDungeonBtnPoint
end

function QInstance:isShowRedPoint()
	local _, normalBoo = self:getDungeonRedPointList(DUNGEON_TYPE.NORMAL)
	local _, eliteBoo = self:getDungeonRedPointList(DUNGEON_TYPE.ELITE)
	if normalBoo == true or eliteBoo == true then
		self.isShowInstanceRedPoint = true
	else
		self.isShowInstanceRedPoint = false
	end

	return self.isShowInstanceRedPoint 
end

--是否再来一次
function QInstance:setAgain(isAgain, dungeonId)
	self._isAgain = isAgain
	self._againDungeonId = dungeonId
end

function QInstance:getAgain()
	return self._isAgain == true, self._againDungeonId
end

--[[
	判断次数
	return 1 次数足够
	return 0 次数不够
	return 2 次数不够可以提示VIP
	return 3 次数不够可以提示购买
]]
function QInstance:checkCount(dungeonId, dungeonType)
	if dungeonType == DUNGEON_TYPE.WELFARE then
		if remote.welfareInstance:canBattle() then
			return 1 
		else
			if not remote.activity:checkMonthCardActive(2) then
    			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege", options = {isSuper = true}})
			else
				app.tip:floatTip("今日史诗副本次数不足")
			end
			return 0
		end
	end
	
	if remote.instance:getFightCountBydungeonId(dungeonId) > 0 then
		return 1
	end
	if dungeonType == DUNGEON_TYPE.ELITE then
		local info = remote.instance:getDungeonById(dungeonId)
		local dungeonCountConfig = QStaticDatabase:sharedDatabase():getTokenConsume("dungeon_elite", info.info.todayReset + 1)
		if dungeonCountConfig == nil then
	    	app.tip:floatTip("本关卡战斗次数已达本日上限！")
		else
		    if info.info.todayReset >= QVIPUtil:getResetEliteDungeonCount() then
		    	return 2
			else
				return 3
			end
		end
	else
    	app.tip:floatTip("本关卡战斗次数已达本日上限！")
	end
	return 0
end

--[[
    功能：获得最前面可以开启但未开启的星级宝箱的章节ID
    返回类型：instanceID or nil
]]
function QInstance:getDungeonBoxInstanceID( instanceType )
	local info = {}

	if instanceType == DUNGEON_TYPE.NORMAL then
		if not self.normalInfo or #self.normalInfo == 0 then return nil, false end
		info = self.normalInfo
	elseif instanceType == DUNGEON_TYPE.ELITE then
		if not self.eliteInfo or #self.eliteInfo == 0 then return nil, false end
		info = self.eliteInfo
	else
		return nil, false
	end

	local tbl = {}
	local index = 0
	local instanceID = ""
	local instanceIDs = {}

	for _, dungeon in pairs(info) do
		-- 遍历检查BOSS宝箱是否有未开启的
		if dungeon.instance_id ~= instanceID then
			if not instanceIDs[dungeon.instance_id] then
				instanceID = dungeon.instance_id
				index = index + 1
				instanceIDs[instanceID] = {}
				instanceIDs[instanceID]["index"] = index
				instanceIDs[instanceID]["number"] = 1 -- 记录一个章节里面有多少关卡
				instanceIDs[instanceID]["stars"] = 0 -- 记录一个章节获得多少星
			else
				instanceID = dungeon.instance_id
				index = instanceIDs[instanceID]["index"]
				instanceIDs[instanceID]["number"] = instanceIDs[instanceID]["number"]  + 1
			end
		else
			instanceIDs[instanceID]["number"] = instanceIDs[instanceID]["number"]  + 1
		end
		if dungeon.info and table.nums(dungeon.info) > 0 then
			instanceIDs[instanceID]["stars"] = (instanceIDs[instanceID]["stars"] or 0)  + tonumber(dungeon.info.star or 0)
		end
	end
	
	-- print("检查星级宝箱是否有未开启的")
	for id, data in pairs(instanceIDs) do
		-- 检查星级宝箱是否有未开启的
		if data["stars"] ~= 0 then
			if self._dropInfo and table.nums(self._dropInfo) > 0  and self._dropInfo[id] then
				if self._dropInfo[id]["isDraw1"] == false then 
					if self._dropInfo[id]["isDraw2"] == true then 
						tbl[ data["index"] ] = true
					elseif self._dropInfo[id]["isDraw3"] == true then 
						tbl[ data["index"] ] = true
					end
				else
					if self._dropInfo[id]["isDraw2"] == false and self._dropInfo[id]["isDraw3"] == true then 
						tbl[ data["index"] ] = true
					end

					local achievementConfig = QStaticDatabase:sharedDatabase():getMapAchievement( id )
					if self._dropInfo[id]["isDraw2"] == false then 
						if data["stars"] >= achievementConfig.box2 then 
							tbl[ data["index"] ] = true
						end
					elseif self._dropInfo[id]["isDraw3"] == false then 
						if data["stars"] >= achievementConfig.box3 then 
							tbl[ data["index"] ] = true
						end
					end
				end
			else
				local achievementConfig = QStaticDatabase:sharedDatabase():getMapAchievement( id )
				if achievementConfig ~= nil and data["stars"] >= achievementConfig.box1 then 
					tbl[ data["index"] ] = true
				end
			end
		end
	end

	if table.nums(tbl) == 0 then return nil, false end
	index = 1
	while(true) do
		if tbl[tostring(index)] or tbl[index] then
			break
		else
			index = index + 1
		end
	end	
	return index, true
end

function QInstance:setChapterPassInfo( passInfo )
	self._passInfo = passInfo
end

function QInstance:getChapterPassInfo()
	return self._passInfo
end

-- 获取最大通关关卡
function QInstance:getLastPassDungeon(type)
	local infoTable
	if type == DUNGEON_TYPE.NORMAL then
		infoTable = self.normalInfo
	elseif type == DUNGEON_TYPE.ELITE then
		infoTable = self.eliteInfo
	end

	local lastPassDungeon = nil
	for _,value in pairs(infoTable or {}) do
		if value.dungeon_type == type then 
			if value.info ~= nil and value.info.star and value.info.star > 0 then
				lastPassDungeon = value
			end
		end
	end
	return lastPassDungeon
end

--获得最大dungeon的intId
function QInstance:getLastPassDungeonIntId(dungeonType)
    local dungeonInfo = remote.instance:getLastPassDungeon(dungeonType)
    if dungeonInfo then
    	return dungeonInfo.int_dungeon_id
    else
    	return 0
    end
end

-- intId当前目标关卡,是否所有领取
function QInstance:checkCurPassAwardAllGet( intId, passAward)
	-- 通过未领取或者没有全部通过
    local isAllGet = true
    local awardCondition = string.split(passAward.conditions, ";")
    local isAllComplete = true
    for i, condition in pairs(awardCondition) do
        local isComplete = intId >= tonumber(condition)
        local isGet = self:checkIsPassAwardGet(passAward.id, i)
        if isComplete and not isGet then
        	isAllGet = false
        	break
        end
        if not isComplete then
        	isAllComplete = false
        end
    end
    if not isAllComplete then
        isAllGet = false
    end
    return isAllGet
end

-- 需要展示的奖励，intId当前目标关卡
function QInstance:checkShowPassAwardById( intId )
	for i, passAward in pairs(self.passAwardConfig) do
		if tonumber(passAward.type) == 1 then
			if passAward.show_int_id <= intId and intId < passAward.award_int_id then
				return passAward
			end
		elseif passAward.show_int_id <= intId then
			local isAllGet = self:checkCurPassAwardAllGet( intId, passAward)
	        if not isAllGet then
	            return passAward
	        end
	    end
	end
	return nil
end

-- 更新领取记录
function QInstance:updatePassAwardsInfo()
	local passAwards = remote.user.dungeonPassAwards or {}
	for i, passAward in pairs(passAwards) do
		local awardTbl = string.split(passAward, "^")
		if awardTbl[1] and awardTbl[2] then
			local posTbl = string.split(awardTbl[2], ";")
			self.passAwards[tonumber(awardTbl[1])] = posTbl
		end
	end
end

-- 指定关卡位置是否领取
function QInstance:checkIsPassAwardGet( passId, pos )
	local getList = self.passAwards[tonumber(passId)] or {}
    for i, v in pairs(getList) do
        if pos == tonumber(v) then
            return true
        end
    end
    return false
end

-- 是否通关奖励全部领取
function QInstance:getIsAllPassAwardsGet( )
	local dungeonIntId = remote.instance:getLastPassDungeonIntId(DUNGEON_TYPE.NORMAL)
	for _, passAward in pairs(self.passAwardConfig) do
		if tonumber(passAward.type) == 2 and dungeonIntId >= passAward.show_int_id then
	        local awardCondition = string.split(passAward.conditions, ";")
	        for i, condition in pairs(awardCondition) do
	            local isComplete = dungeonIntId >= tonumber(condition)
	            local isGet = self:checkIsPassAwardGet(passAward.id, i)
	            if isComplete and not isGet then
	            	return false
	            end
	        end
	    end
	end
	return true
end

-- 斗魂场引导
function QInstance:checkTheThirdGuidance()
	local asideNum = remote.flag:getLocalData(remote.flag.FLAG_DUNGEON_ASIDE)
	local flagIndex = tonumber(asideNum) or 0
	if flagIndex == 3 then
		local instanceData = self:getInstancesWithUnlockAndType(DUNGEON_TYPE.NORMAL)
		local data = instanceData[flagIndex]
		if data and data.star == 0 then
			return true
		end
	end
	return false
end

function QInstance:sentEvent(event, params)
	if event == nil then return end
	
	self:dispatchEvent({name = event, params = params})
end

-- 领取通关奖励
function QInstance:dungeonGetPassAwardsRequest(awardId, index, success, fail)
	local dungeonGetPassAwardsRequest = {awardId = awardId, index = index}
    local request = {api = "DUNGEON_GET_PASS_AWARDS", dungeonGetPassAwardsRequest = dungeonGetPassAwardsRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	self:updatePassAwardsInfo()
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

return QInstance
