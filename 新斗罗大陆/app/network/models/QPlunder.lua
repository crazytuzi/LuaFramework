--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林数据管理

local QBaseModel = import("...models.QBaseModel")
local QPlunder = class("QPlunder", QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")

QPlunder.NEW_DAY = "QPLUNDER_NEW_DAY"
QPlunder.MY_INFO_UPDATE = "QPLUNDER_MY_INFO_UPDATE"
QPlunder.CAVE_UPDATE = "QPLUNDER_CAVE_UPDATE"
QPlunder.MINE_UPDATE = "QPLUNDER_MINE_UPDATE"

QPlunder.CLOCK = "PLUNDER_INVEST_CLOCK"

function QPlunder:ctor()
	QPlunder.super.ctor(self)

	self.isOpen = false -- 是否开启（即可以进入）宗门战
	self.isActive = false -- 是否可以进行宗门战活动（即可以狩猎、掠夺等行为）
	self._isCanChooseCard = true -- 游戏第一次进二级界面的时候，有翻牌可以翻牌
	self.isRecordRedTip = false  -- 战报小红点
end

function QPlunder:init()
	self._remoteProexy = cc.EventProxy.new(remote.user)
    self._remoteProexy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, function ()
        self:checkPlunderUnlock()
    end)

    self.caves = {}
    self.mines = {}
    self._dispatchTBl = {}
    self._lock = false -- 魂兽森林防止频繁操作的统一的锁。
    self._lockByTime = false -- 锁，但是不受response解锁
    self._aniLock = false -- 锁，用于播放动画的时候，自动解锁的时间较长，一般动画播放完解锁
    self._isWaitShowChangeAni = false
    self._isNeedShowMineId = 0

    self.curCavePage = PLUNDER_TYPE.IRON
end

function QPlunder:disappear()

end

function QPlunder:loginEnd()
	if self:checkPlunderUnlock() then
		local _, _, _, isOpen, isToday = self:updateTime()
		if isOpen then
    		self:plunderGetMyInfoRequest()
    	end

    	local investInfo = self:getInvestInfo()
	    if not investInfo or #investInfo == 0 then return end
	    -- print("QPlunder:loginEnd() clock ", isToday)
	    if isToday then
	    	for index, info in ipairs(investInfo) do
	    		local h = info[1]
	    		local hour = q.date("%H", q.serverTime())
	    		if hour < h then
		    		local time = q.getTimeForHMS(h, 0, 0)
		    		-- print("QPlunder:loginEnd() clock ", index, time)
		    		app:getAlarmClock():createNewAlarmClock(QPlunder.CLOCK..index, time, function()
		    				local firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
		    				-- print("QPlunder:loginEnd() clock ", app.battle, firstDialog.class.__cname)
	    					if app.battle == nil and firstDialog ~= nil and (firstDialog.class.__cname == "QUIDialogPlunderMap" or firstDialog.class.__cname == "QUIDialogPlunderMain") then
		    					app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderInvest"}, {isPopCurrentDialog = false})
	    					else
		    					remote.plunder.needInvestClock = true
		    				end
		    			end)
		    	end
	    	end
	    end
    end
end



function QPlunder:newDayUpdate()
	self.lootCnt = QStaticDatabase.sharedDatabase():getConfigurationValue("GHKZ_LD_TIMES")
	self:setCaveRegion( PAGE_NUMBER.ONE, true )
	self:dispatchEvent( { name = QPlunder.NEW_DAY } )
	self:addInvestClock()
end

--------------数据储存--------------

-- 设置魂兽区
function QPlunder:setCaveRegion( caveRegion, isForce ) 
	if not self.caveRegion or isForce or self.caveRegion ~= caveRegion then
		self.caveRegion = caveRegion
		self:_changeCaveRegion()
	end
end

-- 获取魂兽区
function QPlunder:getCaveRegion()
	return self.caveRegion
end

-- 获取掠夺次数
function QPlunder:getLootCnt()
	return self.lootCnt or QStaticDatabase.sharedDatabase():getConfigurationValue("GHKZ_LD_TIMES")
end

-- 获取防守阵容
function QPlunder:getDefenseArmy()
	return self.defenseArmy or {}
end

-- 获取防守战力
function QPlunder:getDefenseForce()
	return self.defenseForce or 0
end

-- 设置二级界面的当前页码
function QPlunder:setCurCavePage( int )
	self.curCavePage = int
end
-- 获取二级界面的当前页码
function QPlunder:getCurCavePage()
	return self.curCavePage or PAGE_NUMBER.ONE
end

function QPlunder:setShareTime( time )
	self._shareTime = time
end

function QPlunder:getShareTime()
	return self._shareTime or 0
end

function QPlunder:setIsShareRedTips( boo )
	self._isShareRedTips = boo
end

function QPlunder:getIsShareRedTips()
	return self._isShareRedTips
end

function QPlunder:setIsNeedShowMineId( int )
	self._isNeedShowMineId = int
end

function QPlunder:getIsNeedShowMineId()
	if self._isNeedShowMineId and self._isNeedShowMineId > 0 then
		if self.myOccupy and table.nums(self.myOccupy) > 0 then
			if self.myOccupy.mineId ~= self._isNeedShowMineId then
				self._isNeedShowMineId = 0
			end
		else
			self._isNeedShowMineId = 0
		end
	end
	
	return self._isNeedShowMineId or 0
end

function QPlunder:setIsNeedShowChangeAni( boo )
	self._isNeedShowChangeAni = boo
end

function QPlunder:getIsNeedShowChangeAni()
	return self._isNeedShowChangeAni
end

function QPlunder:getMines()
	return self.mines or {}
end

function QPlunder:getMyScore()
	return self.myScore or 0
end

function QPlunder:getConsortiaScore()
	return self.consortiaScore or 0
end

function QPlunder:getMyMineId()
	return self.myMineId
end

function QPlunder:getMyRank()
	return self.myRank or 0
end

function QPlunder:getConsortiaRank()
	return self.consortiaRank or 0
end

function QPlunder:getBuyLootCnt()
	return self.buyLootCnt or 0
end

function QPlunder:getMyMaxScore()
	return self.myMaxScore or 0
end

function QPlunder:getConsortiaMaxScore()
	return self.consortiaMaxScore or 0
end

function QPlunder:getMyScoreAwards()
	return self.myScoreAwards or {}
end

function QPlunder:getConsortiaScoreAwards()
	return self.consortiaScoreAwards or {}
end

function QPlunder:getPlunderProportion()
	return QStaticDatabase.sharedDatabase():getConfigurationValue("LD_BILI")
end


function QPlunder:getPlunderTime()
	return QStaticDatabase.sharedDatabase():getConfigurationValue("sect_hunting_time")
end


function QPlunder:getLootRandomAward()
	return self.lootRandomAward
end

function QPlunder:getMaxMineId()
	return self.maxMineId or 201010001
end

-- 获取投放冰髓的弹框信息
function QPlunder:getInvestInfo()
	if not self._investInfo or #self._investInfo == 0 then
		-- GH_KZ_JICHU_NEW
		self._investInfo = {}
		local config = QStaticDatabase.sharedDatabase():getConfigurationValue("GH_KZ_JICHU_NEW")
		local tbls = string.split(config or {}, ";")
		for _, value in ipairs(tbls) do
			local tbl = string.split(value, ",")
			table.insert(self._investInfo, tbl)
		end
	end

	return self._investInfo
end

function QPlunder:getCurInvestIndex()
	local investInfo = self:getInvestInfo()
	if investInfo == nil or #investInfo == 0 then return 0 end

	local hour = q.date("%H", q.serverTime())
	local curIndex = 1
	while true do
		local info = investInfo[curIndex]
		if info then
			if hour < info[1] then
				curIndex = curIndex - 1
				break
			else
				curIndex = curIndex + 1
			end
		else
			curIndex = curIndex - 1
			break
		end
	end

	return curIndex, investInfo
end

--------------调用素材--------------

-- 获取小锤子动画
function QPlunder:getHammer()
	return {x = 50, y = -30}, "ccb/effects/kuangtong_gxps.ccbi"
end

-- 获取我的魂兽区的光效动画
function QPlunder:getGuang()
	return {x = 0, y = 0}, "ccb/effects/Arena_one_guang10.ccbi"
end

-- 获取狩猎特效
function QPlunder:getWin()
	return {x = 0, y = 0}, "ccb/Widget_SilverMine_holdwin.ccbi"
end

-- 获取结算动画
-- function QPlunder:getFinish( index )
-- 	return {x = 0, y = 0}, "ccb/effects/yinkuangzhan_baoshi_"..index..".ccbi"
-- end

--------------便民工具--------------

function QPlunder:addLock( isNotAutoRemove )
	if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end

	self._lock = true
	if isNotAutoRemove then
	    if self._scheduler then
	        scheduler.unscheduleGlobal(self._scheduler)
	        self._scheduler = nil
       	end
	else
		self._scheduler = scheduler.performWithDelayGlobal(function ()
		        self:removeLock()
		    end, 0.5)
    end
end

function QPlunder:isLock()
	return self._lock 
end

function QPlunder:removeLock()
	if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end
    self._lock = false
end

function QPlunder:addLockByTime()
	if self._lockByTimescheduler then
        scheduler.unscheduleGlobal(self._lockByTimescheduler)
        self._lockByTimescheduler = nil
    end

	self._lockByTime = true
    self._lockByTimescheduler = scheduler.performWithDelayGlobal(function ()
	        self:removeLockByTime()
	    end, 0.5)
end

function QPlunder:isLockByTime()
	return self._lockByTime 
end

function QPlunder:removeLockByTime()
	if self._lockByTimescheduler then
        scheduler.unscheduleGlobal(self._lockByTimescheduler)
        self._lockByTimescheduler = nil
    end
    self._lockByTime = false
end

function QPlunder:addAniLock()
	if self._aniScheduler then
        scheduler.unscheduleGlobal(self._aniScheduler)
        self._aniScheduler = nil
    end

	self._aniLock = true
    self._aniScheduler = scheduler.performWithDelayGlobal(function ()
	        self:removeAniLock()
	    end, 3)
end

function QPlunder:isAniLock()
	return self._aniLock 
end

function QPlunder:removeAniLock()
	if self._aniScheduler then
        scheduler.unscheduleGlobal(self._aniScheduler)
        self._aniScheduler = nil
    end
    self._aniLock = false
end

-- 小红点
function QPlunder:checkPlunderRedTip()
	local _, _, isActive, isOpen = self:updateTime()
	if self:checkPlunderUnlock() == false or isOpen == false then 
		return false
	end

	if self:getLootCnt() > 0 and isActive then
		return true
	end

	if self:checkPersonalAwardTips() or self:checkUnionAwardTips() then
		return true
	end

	return false
end

function QPlunder:checkPersonalAwardTips()
	local buyAwards = self:getMyScoreAwards()
	local isDone = function (id)
		for _, value in pairs(buyAwards) do
			if value == id then
				return true
			end
		end
		return false
    end

    local personalCondition = self:getMyMaxScore()
    local personalAwards = QStaticDatabase:sharedDatabase():getPlunderTargetReward(1)
    local ids = {}
    for i = 1, #personalAwards do
    	if personalAwards[i].target_score <= personalCondition and isDone(personalAwards[i].id) == false then
    		return true
    	end
    end
    return false
end

function QPlunder:checkUnionAwardTips()
	local buyAwards = self:getConsortiaScoreAwards()
	local isDone = function (id)
		for _, value in pairs(buyAwards) do
			if value == id then
				return true
			end
		end
		return false
    end

    local unionCondition = self:getConsortiaMaxScore()
    local unionAwards = QStaticDatabase:sharedDatabase():getPlunderTargetReward(2)
    local ids = {}
    for i = 1, #unionAwards do
    	if unionAwards[i].target_score <= unionCondition and isDone(unionAwards[i].id) == false then
    		return true
    	end
    end
    return false
end

-- 根据cave_region 获取魂兽森林的配置
function QPlunder:getCaveConfigByCaveRegion( caveRegion )
	local tbl = {}
	local caveConfigs = QStaticDatabase.sharedDatabase():getPlunderCaveConfigs()
	for _, config in pairs(caveConfigs) do
		if tonumber(config.cave_region) == tonumber(caveRegion) then
			table.insert(tbl, config)
		end
	end
	table.sort(tbl, function(a, b) return a.cave_id < b.cave_id end)
	return tbl
end

-- 根据cave_id 获取魂兽森林的配置
function QPlunder:getCaveConfigByCaveId( caveId )
	local caveConfigs = QStaticDatabase.sharedDatabase():getPlunderCaveConfigs()
	for _, config in pairs(caveConfigs) do
		if config.cave_id == caveId then
			return config
		end
	end
	return nil
end

-- 根据cave_id和mine_id 获取巢穴的配置
function QPlunder:getMineConfigByMineId( mineId )
	local mineConfigs = QStaticDatabase.sharedDatabase():getPlunderMineConfigs()
	if mineConfigs and table.nums(mineConfigs) > 0 then
		for _, config in pairs(mineConfigs) do
			if tonumber(config.mine_id) == tonumber(mineId) then
				return config
			end
		end
	end

	-- 后面的垃圾魂兽区堆，通过mineId找不到对应的配置，统一取这个巢穴的第一个魂兽区的配置
	local caveId = tonumber(string.sub(mineId, 1, 4))
	local caveConfig = self:getCaveConfigByCaveId(caveId)
	if not caveConfig or table.nums(caveConfig) == 0 then return end
	local mineIdList = string.split(caveConfig.mine_ids, ";")
	if mineIdList[1] then
		return self:getMineConfigByMineId( mineIdList[1] )
	end

	return nil
end

-- 根据mine_id 获取cave的配置
function QPlunder:getCaveConfigByMineId( mineId )
	local caveId = tonumber(string.sub(mineId, 1, 4))
	local caveConfig = self:getCaveConfigByCaveId(caveId)
	if caveConfig and table.nums(caveConfig) > 0 then
		local mines = caveConfig.mine_ids
		local isFind = string.find(mines, mineId)
		if isFind then
			return caveConfig
		else
			if caveConfig.cave_bonus == 0 then
				-- 废魂兽区配置的mineId可能出现这样的情况，属于正常
				return caveConfig
			else
				app.tip:floatTip("魂兽森林id配置有误")
				return caveConfig
			end
		end
	end

	local caveConfigs = QStaticDatabase.sharedDatabase():getPlunderCaveConfigs()
	for _, config in pairs(caveConfigs) do
		local mines = config.mine_ids
		local isFind = string.find(mines, mineId)
		if isFind then
			return config
		end
	end

	return nil
end

function QPlunder:getCaveInfoByCaveId( caveId )
	if not self.caves or table.nums(self.caves) == 0 then return nil end
	return self.caves[caveId]
end

function QPlunder:getMineInfoByMineId( mineId )
	if not self.mines or table.nums(self.mines) == 0 then return nil end
	return self.mines[mineId]
end

function QPlunder:getMyConsortiaId()
	local myConsortiaId = remote.user.userConsortia.consortiaId
	if not myConsortiaId and self.myOccupy and self.myOccupy.consortiaId then
		myConsortiaId = self.myOccupy.consortiaId
	end
	return myConsortiaId or ""
end

function QPlunder:getMyUserId()
	return remote.user:getPropForKey("userId")
end

function QPlunder:getActorById( actorId )
	local character = QStaticDatabase.sharedDatabase():getCharacterByID(actorId)
	return character
end

-- mineId转成caveId
function QPlunder:getCaveIdByMineId( mineId )
	local caveConfig = self:getCaveConfigByMineId( mineId )
	local caveId = caveConfig.cave_id

	return caveId
end

-- 根据不同魂兽区的品质，计算出十分钟产量（包含狩猎等级加成、宗门加成）
-- mineId 魂兽区的id。 （必须参数）
-- myConsortiaId 如果需要预计我狩猎后的产出，这时就需要把我狩猎后可能产生的宗门加成算进去的话，就需要传值。否则不用传值  （可选参数，仅仅做我的预计时使用）
-- ownerConsortiaId 如果需要计算的产出是别人的魂兽区，这里需要传入他人的宗门ID，用来计算他人的宗门加成情况。这里没有值，默认以我的宗门id来判断  （可选参数，计算他人产出时为必须）
function QPlunder:getOutPutByMineId( mineId, myConsortiaId, ownerConsortiaId )
	local scoreOutputBase = self:getBaseOutputByMineId( mineId )
	local scoreOutputSocietyUp = self:getSocietyBuff( mineId, myConsortiaId, ownerConsortiaId )
	local scoreOutput = scoreOutputBase + scoreOutputSocietyUp

	return scoreOutput
end

-- 获取基础十分钟产量
function QPlunder:getBaseOutputByMineId( mineId )
	local mineConfig = self:getMineConfigByMineId( mineId )
	local scoreOutput = mineConfig.jifen_chanchu
	return scoreOutput
end

-- 返回宗门对产出的加成值
function QPlunder:getSocietyBuff( mineId, myConsortiaId, ownerConsortiaId )
	local caveId = self:getCaveIdByMineId( mineId )
	local societyCount = 0
	local isBuff, member, consortiaId = self:getSocietyBuffInfoByCaveId(caveId, myConsortiaId, mineId)
	if isBuff then
		if ownerConsortiaId then
			if consortiaId == ownerConsortiaId then
				societyCount = member
			end
		elseif consortiaId == self:getMyConsortiaId() then
			societyCount = member
		end
	end
	local scoreOutputSocietyUp = QStaticDatabase.sharedDatabase():getConfigurationValue("kfyk_jiacheng_"..societyCount) or 0

	return scoreOutputSocietyUp
end

-- 根据caveId计算这个cave的宗门加成一些信息，如果没有宗门加成，则isBuff为false
-- mineId为玩家点开的魂兽区的id
-- myConsortiaId 如果需要预计我狩猎后的产出，这时就需要把我狩猎后可能产生的宗门加成算进去的话，就需要传值。否则不用传值  （可选参数，仅仅做我的预计时使用）
function QPlunder:getSocietyBuffInfoByCaveId( caveId, myConsortiaId, mineId )
	local societyTbl = {}
	local isBuff = false
	local member = 0
	local consortiaId = ""
	local consortiaName = ""

	local caveConfig = self:getCaveConfigByCaveId( caveId )
	if caveConfig and caveConfig.cave_bonus == 1 then
		local caveInfo = self:getCaveInfoByCaveId( caveId )
		if caveInfo and caveInfo.occupies and table.nums(caveInfo.occupies) > 0 then
			for _, occupy in pairs(caveInfo.occupies) do
				if occupy.consortiaId and occupy.consortiaId ~= "" then
					if not societyTbl[occupy.consortiaId] then
						societyTbl[occupy.consortiaId] = {}
						if myConsortiaId and myConsortiaId ~= "" and myConsortiaId == occupy.consortiaId then
							-- 初始为1，因为如果我狩猎了之后，我算1，用于查看别人的魂兽区时，预先计算我拿下之后的产出
							-- 但是这个要减去2个特殊情况。1，我也占据了其中一个魂兽区了。2，我点的是我宗门的人的魂兽区
							societyTbl[occupy.consortiaId].count = 1
						else
							societyTbl[occupy.consortiaId].count = 0
						end
					end

					societyTbl[occupy.consortiaId].name = occupy.consortiaName
					societyTbl[occupy.consortiaId].count = societyTbl[occupy.consortiaId].count + 1

					if myConsortiaId then
						if occupy.ownerId == self:getMyUserId() then
							-- 1，我也占据了其中一个魂兽区了。
							societyTbl[occupy.consortiaId].count = societyTbl[occupy.consortiaId].count - 1
						end

						if occupy.mineId == mineId and occupy.consortiaId == myConsortiaId then
							-- 2，我点的是我宗门的人的魂兽区
							societyTbl[occupy.consortiaId].count = societyTbl[occupy.consortiaId].count - 1
						end
					end

					if societyTbl[occupy.consortiaId].count >= 3 then
						if myConsortiaId then
							if myConsortiaId == occupy.consortiaId then
								isBuff = true
								member = societyTbl[occupy.consortiaId].count
								consortiaId = occupy.consortiaId
								consortiaName = occupy.consortiaName
							end
						else
							isBuff = true
							member = societyTbl[occupy.consortiaId].count
							consortiaId = occupy.consortiaId
							consortiaName = occupy.consortiaName
						end
					end
				end
			end
		end
	end

	return isBuff, member, consortiaId, consortiaName, societyTbl
end

-- 根据品质等级，转换成中文的品质
function QPlunder:getMineCNNameByQuality( quality )
    if quality == PLUNDER_TYPE.IRON then
        return "百年魂兽区"
    elseif quality == PLUNDER_TYPE.COPPER then
        return "五百年魂兽区"
    elseif quality == PLUNDER_TYPE.SILVER then
        return "千年魂兽区"
    elseif quality == PLUNDER_TYPE.RICH_SILVER then
        return "五千年魂兽区"
    elseif quality == PLUNDER_TYPE.GOLD then
        return "万年魂兽区"
    elseif quality == PLUNDER_TYPE.RICH_GOLD then
        return "五万年魂兽区"
    elseif quality == PLUNDER_TYPE.DIAMOND then
        return "十万年魂兽区"
    else
        return ""
    end
end

-- 根绝mineId返回狩猎倒计时
function QPlunder:updateTime()
	-- GHKZ_OPEN_TIME
	local str = QStaticDatabase.sharedDatabase():getConfigurationValue("GHKZ_OPEN_TIME")
	local tbl = string.split(str, ",")
	local day = tonumber(tbl[1]) or 4
	local startHour = tonumber(tbl[2]) or 12
	local endHour = tonumber(tbl[3]) or 22
	local closeTime = tonumber(tbl[4]) or 10
	local timeStr = ""
	local color = ccc3(255, 255, 255) -- 白色
	local isToday = false
	local curTimeTbl = q.date("*t", q.serverTime())
	-- print("#日期："..curTimeTbl.year.."/"..curTimeTbl.month.."/"..curTimeTbl.day.."#星期："..(curTimeTbl.wday - 1).."#时间："..curTimeTbl.hour..":"..curTimeTbl.min..":"..curTimeTbl.sec)
	-- print("#开启时间：星期"..day.."#开始时间："..startHour..":00#结束时间："..endHour..":00#等待关闭小时："..closeTime.."小时")
	local d,h,m,s = 0,0,0,0
	m = 59 - curTimeTbl.min
	s = 60 - curTimeTbl.sec
	d = curTimeTbl.wday - 1
	local closeHour = endHour + closeTime
	local closeDay = day
	if closeHour >= 24 then
		closeHour = closeHour - 24
		closeDay = closeDay + 1
	end
	if d < day then
		self.isActive = false
		self.isOpen = false
	elseif d == day then
		-- 先判断日期对不对
		isToday = true
		if curTimeTbl.hour >= startHour and curTimeTbl.hour < endHour then
			h = (endHour - 1) - curTimeTbl.hour
			timeStr = string.format("%02d:%02d:%02d", h, m, s)
			if h == 0 then
				color = ccc3(255, 63, 0) -- 红色
			else
				color = ccc3(255, 255, 255)
			end
			self.isActive = true
			self.isOpen = true
			return timeStr, color, self.isActive, self.isOpen, isToday
		end

		self.isActive = false

		if d == closeDay then
			if curTimeTbl.hour < closeHour and curTimeTbl.hour >= startHour then
				self.isOpen = true
			else
				self.isOpen = false
			end
		else
			-- d < closeDay
			if curTimeTbl.hour >= startHour then
				self.isOpen = true
			else
				self.isOpen = false
			end
		end
	else
		self.isActive = false
		if d < closeDay then
			self.isOpen = true
		elseif d == closeDay then
			if curTimeTbl.hour < closeHour then
				self.isOpen = true
			else
				self.isOpen = false
			end
		else
			self.isOpen = false
		end
	end

	if self.isOpen == false then
		local offsetDay = 0
		if d <= day then
			offsetDay = day - d 
		else
			offsetDay = 7 - (d - day)
		end
		h = (startHour - 1) - curTimeTbl.hour + offsetDay * 24
		timeStr = string.format("%02d:%02d:%02d", h, m, s)
	end

	return timeStr, color, self.isActive, self.isOpen, isToday
end

-- 将秒为单位的数字转换成 00：00：00格式
function QPlunder:formatSecTime( sec )
	local h = math.floor((sec/3600)%24)
	local m = math.floor((sec/60)%60)
	local s = math.floor(sec%60)

	return h, m, s
end

-- awardStr : consortia_money^730; consortia_money; 23^73; 23
function QPlunder:getItemBoxParaMetet( awardStr )
	local idOrType = ""
	local count = 0
	local itemType = -1

	local s, e = string.find(awardStr, "%^")
    if s then
        local a = string.sub(awardStr, 1, s - 1)
        local b = string.sub(awardStr, e + 1)
        idOrType = a
        count = tonumber(b)
    else
        idOrType = awardStr
        count = 0
    end
    local n = tonumber(idOrType)
    if n then
        -- 数字， item
       	itemType = self:getItemTypeById( idOrType )
   	 	if itemType == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
            return idOrType, ITEM_TYPE.GEMSTONE_PIECE, count
        elseif itemType == ITEM_CONFIG_TYPE.GEMSTONE then
        	return idOrType, ITEM_TYPE.GEMSTONE, count
        else
        	return idOrType, ITEM_TYPE.ITEM, count
        end
    end
    -- 字母，resource
    return nil, idOrType, count
end

-- 根据item的id返回item的type
function QPlunder:getItemTypeById( itemId )
	local itemConfig = QStaticDatabase.sharedDatabase():getItemByID( itemId )
	if not itemConfig then
		app.tip:floatTip("没有id["..itemId.."]的配置，请策划检查量表")
		return 1
	end
	return itemConfig.type
end

-- 根据awardStr获取货品的中文名字
function QPlunder:getGoodsNameByAwardStr( awardStr )
	local id, type, count = self:getItemBoxParaMetet( awardStr )
	if id then
		--item
		local itemConfig = QStaticDatabase.sharedDatabase():getItemByID( id )
		return itemConfig.name
	else
		--recource
		local itemType = remote.items:getItemType( type )
		local wallet = remote.items:getWalletByType( itemType )
		return wallet.nativeName
	end
end

-- 根据物品的品质做降序排列，如果同品质，按照item>resource排序，同品质item按照id降序排序，同品质resource不排序
-- awardStrTbl : { consortia_money^730, consortia_money, 23^73, 23 }
-- awardTbl : { type: item, count: 9999, id: 123 }
function QPlunder:arrangeByQuality( awardStrTbl, awardTbl )
	local isStrTbl = true
	local tbl = {}
	if awardStrTbl then
		isStrTbl = true
		tbl = awardStrTbl
	else
		isStrTbl = false
		tbl = awardTbl
	end

	if table.nums(tbl) < 2 then return end

	table.sort(tbl, function( a, b ) 
			local id1, type1, id2, type2, item1, item2 = nil, nil, nil, nil, nil, nil
			local color1, color2 = 0, 0

			if isStrTbl then
				id1, type1 = self:getItemBoxParaMetet(a)
				id2, type2 = self:getItemBoxParaMetet(b)
			else
				id1 = a.id
				type1 = a.typeName or a.type
				id2 = b.id
				type2 = b.typeName or b.type
			end
			
			if id1 then
				item1 = QStaticDatabase.sharedDatabase():getItemByID(id1)
				color1 = item1.colour or 0
			else
				res = QStaticDatabase.sharedDatabase():getResource()
				for _, value in pairs(res) do
					if value.name == type1 then
						color1 = value.colour or 0
					else
						local cnames = string.split(value.cname, ",")
						for _, name in pairs(cnames) do
							if name == type1 then
								color1 = value.colour or 0
							end
						end
					end
				end
			end

			if id2 then
				item2 = QStaticDatabase.sharedDatabase():getItemByID(id2)
				color2 = item2.colour or 0
			else
				res = QStaticDatabase.sharedDatabase():getResource()
				for _, value in pairs(res) do
					if value.name == type2 then
						color2 = value.colour or 0
					else
						local cnames = string.split(value.cname, ",")
						for _, name in pairs(cnames) do
							if name == type2 then
								color2 = value.colour or 0
							end
						end
					end
				end
			end

			-- print("--------------")
			-- print(id1, id2)
			-- print(item1, item2)
			-- print(type1, type2)
			-- print(color1, color2)

			if color1 > color2 then
				return true
			elseif color1 == color2 then
				-- 同品质
				if not item1 then
					return false
				else
					if not item2 then
						return true
					else
						-- if type1 == ITEM_TYPE.GEMSTONE_PIECE then
						if item1.gemstone_quality then
							-- if type2 ~= ITEM_TYPE.GEMSTONE_PIECE then
							if not item2.gemstone_quality then
								return true
							else
								-- print("=================================")
								-- print(id1, type1, item1.gemstone_quality)
								-- print(id2, type2, item2.gemstone_quality)
								if tonumber(item1.gemstone_quality) > tonumber(item2.gemstone_quality) then
									-- print("true")
									return true 
								else
									-- print("false")
									return false
								end
							end
						else
							-- if type2 == ITEM_TYPE.GEMSTONE_PIECE then
							if item2.gemstone_quality then
								return false
							else
								-- print("---------------------------------")
								-- print(id1, type1)
								-- print(id2, type2)
								if tonumber(id1) > tonumber(id2) then
									-- print("true")
									return true 
								else
									-- print("false")
									return false
								end
							end
						end
					end
				end
			else
				return false
			end
		end)
end

function QPlunder:setIsCanChooseCard( boo )
	self._isCanChooseCard = boo
end

function QPlunder:getIsCanChooseCard()
	return self._isCanChooseCard
end

function QPlunder:getOwnerIdByMineId( mineId )
	if self.mines[mineId] then
		return self.mines[mineId].ownerId
	else
		for _, mine in pairs(self.mines) do
			if mine.mineId == mineId then
				return mine.ownerId
			end
		end
	end
end

function QPlunder:getOccupyPrice()
	-- local freeOccupyTimes = QStaticDatabase.sharedDatabase():getConfigurationValue("GHKZ_ZK_TIMES")
	-- local totalOccupyTimes = freeOccupyTimes + (self.buyOccupyCnt or 0)
	-- local usedOccupyTimes = totalOccupyTimes - (self.occupyCnt or freeOccupyTimes)
	local price = 0
	if not self.occupyCnt or self.occupyCnt > 0  then return price end
	local times = (self.buyOccupyCnt or 0) + 1
	while true do
		local tbl = QStaticDatabase.sharedDatabase():getTokenConsume("gh_ykz_zk_times", times)
		if not tbl then
			times = times - 1
		else
			price = tbl.money_num
			break
		end
	end

	return price
end

function QPlunder:canBuyOccupyCnt()
	local myVipLevel = QVIPUtil:VIPLevel()
	local vipInfos = QStaticDatabase:sharedDatabase():getVIP()
	local vipInfo = vipInfos[tostring(myVipLevel)]
	local maxTimes = vipInfo.gh_kz_times
	if self.buyOccupyCnt >= maxTimes then
		return false
	end

	return true
end

-- 计算狩猎者的类型
function QPlunder:getLordTypeByMineId( mineId )
	local mineInfo = self:getMineInfoByMineId( mineId )
	if mineInfo then
		if self.myMineId and self.myMineId == mineId then
			-- 自己的魂兽区
			return LORD_TYPE.SELF
		else
			-- 他人的魂兽区
			if mineInfo.consortiaId == self:getMyConsortiaId() then
				-- 宗门成员
				return LORD_TYPE.SOCIETY
			else
				-- 其他玩家
				return LORD_TYPE.NORMAL
			end
		end
	else
		-- BOSS的魂兽区
		return LORD_TYPE.BOSS
	end
end

function QPlunder:addMineId( mineId, caveId )
	-- local index = string.gsub(mineId, caveId, "") -- 100110001, 1001 => 10001
	local index = string.sub(mineId, 5) -- 100110001, 1001 => 10001
	-- print( mineId, caveId, index )
	index = tonumber(index) 
	index = index + 1
	return caveId..index
end

function QPlunder:checkUnionState()
	if (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then	
		app:alert({content = "您被移出宗门！", title = "系统提示", callback = function (status)
				if status == ALERT_TYPE.CONFIRM then
	                app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
	            end
            end},false,true)
		return true
	end
end

function QPlunder:checkBurstIn()
	if self:checkUnionState() then return true end

	local myMineId = self:getMyMineId()
	if not myMineId or myMineId == 0 then 
		app.tip:floatTip("魂师大人，你没有参加本次极北之地")
		return true
	end
	local _, _, isActive = self:updateTime()
	if isActive == false then
		app.tip:floatTip("魂师大人，本次极北之地已经结束了，请尽快领奖")
		return true
	end

	return false
end

-- 添加物资发放的闹钟
function QPlunder:addInvestClock()
	if self:checkPlunderUnlock() then
    	local investInfo = self:getInvestInfo()
	    if not investInfo or #investInfo == 0 then return end
	    local _, _, _, _, isToday = self:updateTime()
	    if isToday then
	    	for index, info in ipairs(investInfo) do
	    		app:getAlarmClock():deleteAlarmClock(QPlunder.CLOCK..index)
	    		local h = info[1]
	    		local hour = q.date("%H", q.serverTime())
	    		if hour < h then
		    		local time = q.getTimeForHMS(h, 0, 0)
		    		-- print("QPlunder:addInvestClock() clock ", index, time)
		    		app:getAlarmClock():createNewAlarmClock(QPlunder.CLOCK..index, time, function()
		    				local firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
		    				-- print("QPlunder:addInvestClock() clock ", app.battle, firstDialog.class.__cname)
	    					if app.battle == nil and firstDialog ~= nil and (firstDialog.class.__cname == "QUIDialogPlunderMap" or firstDialog.class.__cname == "QUIDialogPlunderMain") then
		    					app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderInvest"}, {isPopCurrentDialog = false})
		    				else
		    					remote.plunder.needInvestClock = true
		    				end
		    			end)
		    	end
	    	end
	    end
    end
end

--------------数据处理--------------

function QPlunder:responseHandler( response, successFunc, failFunc )
	-- QPrintTable( response )
	if response.kuafuMineGetMyInfoResponse then
		local myInfo = response.kuafuMineGetMyInfoResponse.myInfo
		self:_updateMyInfo( myInfo )
		local myOccupy = response.kuafuMineGetMyInfoResponse.myOccupy
		self:_updateMyOccupy( myOccupy )
		table.insert(self._dispatchTBl, QPlunder.MY_INFO_UPDATE)
	end

	if response.kuafuMineBuyOccupyCntResponse then
		self.occupyCnt = response.kuafuMineBuyOccupyCntResponse.occupyCnt
		self.buyOccupyCnt = response.kuafuMineBuyOccupyCntResponse.buyOccupyCnt
		table.insert(self._dispatchTBl, QPlunder.MY_INFO_UPDATE)
	end

	if response.kuafuMineBuyLootCntResponse then
		self.lootCnt = response.kuafuMineBuyLootCntResponse.lootCnt
		self.buyLootCnt = response.kuafuMineBuyLootCntResponse.buyLootCnt
		table.insert(self._dispatchTBl, QPlunder.MY_INFO_UPDATE)
	end

	if response.kuafuMineGetMyScoreAwardResponse then
		local myInfo = response.kuafuMineGetMyScoreAwardResponse.myInfo
		self:_updateMyInfo( myInfo )
		table.insert(self._dispatchTBl, QPlunder.MY_INFO_UPDATE)
	end

	if response.kuafuMineGetConsortiaScoreAwardResponse then
		local myInfo = response.kuafuMineGetConsortiaScoreAwardResponse.myInfo
		self:_updateMyInfo( myInfo )
		table.insert(self._dispatchTBl, QPlunder.MY_INFO_UPDATE)
	end

	if response.kuafuMineGetCaveListResponse then
		local mineCaves = response.kuafuMineGetCaveListResponse.mineCaves
		self:_updateCaveInfo( mineCaves )
		table.insert(self._dispatchTBl, QPlunder.CAVE_UPDATE)
	end

	if response.kuafuMineGetCaveInfoResponse then
		local mineCave = response.kuafuMineGetCaveInfoResponse.mineCave
		self:_updateMineInfo( mineCave )
		table.insert(self._dispatchTBl, QPlunder.MINE_UPDATE)
	end

	if response.gfEndResponse and response.gfEndResponse.kuafuMineOccupyFightEndResponse then
	    -- optional PbFightLock fightLock = 1;                                         //战斗锁
	    -- optional PbUserKuafuMine myInfo = 2;                                        //玩家银魂兽区本信息
	    -- optional PbKuafuMineOccupy myOccupy = 3;                                    //玩家的狩猎信息
	    -- optional int64 fightReportId =4;                                            //战报ID
	    local myInfo = response.gfEndResponse.kuafuMineOccupyFightEndResponse.myInfo
		self:_updateMyInfo( myInfo )
		local myOccupy = response.gfEndResponse.kuafuMineOccupyFightEndResponse.myOccupy
		self:_updateMyOccupy( myOccupy )
		
		table.insert(self._dispatchTBl, QPlunder.MY_INFO_UPDATE)
	end

	if response.gfEndResponse and response.gfEndResponse.kuafuMineLootFightEndResponse then
		-- optional PbFightLock fightLock = 1;                                         //战斗锁
		-- optional PbUserKuafuMine myInfo = 2;                                        //玩家银魂兽区本信息
		-- optional PbKuafuMineOccupy myOccupy = 3;                                    //玩家的狩猎信息
		-- optional int64 fightReportId =4;                                            //战报ID
		local myInfo = response.gfEndResponse.kuafuMineLootFightEndResponse.myInfo
		self:_updateMyInfo( myInfo )
		local myOccupy = response.gfEndResponse.kuafuMineLootFightEndResponse.myOccupy
		self:_updateMyOccupy( myOccupy )
		table.insert(self._dispatchTBl, QPlunder.MY_INFO_UPDATE)
	end

	-- print("=========start=========")
	-- QPrintTable(self.caves)
	-- print("=======================")
	-- QPrintTable(self.mines)
	-- print("=======================")
	-- QPrintTable(self.myOccupy)
	-- print("==========end==========")
	self:_calculateForce()

	if successFunc then 
        successFunc(response) 
        self:_dispatchAll()
        self:removeLock()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    self:_dispatchAll()
    self:removeLock()
end

function QPlunder:pushHandler( data )
    -- QPrintTable(data)
    if data.messageType == "KUAFU_MINE_CAVE_BE_ATTACK" then
    	self.isRecordRedTip = true
    	self:plunderGetMyInfoRequest(function()
    		if self.myMineId then
        		local caveConfig = self:getCaveConfigByMineId( self.myMineId )
        		if caveConfig and caveConfig.cave_id then
        			self:plunderGetCaveInfoRequest(caveConfig.cave_id)
        		end
        		if caveConfig and caveConfig.cave_region then
        			self:plunderGetCaveListRequest(caveConfig.cave_region)
        		end
        	end	        	
    	end)
    end
end

 --[[
 	//宗门战API定义
    KUAFU_MINE_GET_MY_INFO                      = 8001;                     //跨服魂兽森林-获取我的信息 无参数 返回 KuafuMineGetMyInfoResponse
    KUAFU_MINE_BUY_OCCUPY_CNT                   = 8002;                     //跨服魂兽森林-购买狩猎次数Request,KuafuMineBuyOccupyCntRequest
    KUAFU_MINE_BUY_LOOT_CNT                     = 8003;                     //跨服魂兽森林-购买掠夺次数Request,KuafuMineBuyLootCntRequest
    KUAFU_MINE_GET_LOOT_RANDOM_AWARD            = 8004;                     //跨服魂兽森林-获取掠夺随机奖励Request,KuafuMineGetLootRandomAwardRequest
    KUAFU_MINE_GET_MY_SCORE_AWARD               = 8005;                     //跨服魂兽森林-领取个人积分奖励Request,KuafuMineGetMyScoreAwardRequest
    KUAFU_MINE_GET_CONSORTIA_SCORE_AWARD        = 8006;                     //跨服魂兽森林-领取宗门积分奖励Request,KuafuMineGetConsortiaScoreAwardRequest
    KUAFU_MINE_GET_CAVE_LIST                    = 8007;                     //跨服魂兽森林-获取魂兽森林列表Request,KuafuMineGetCaveListRequest
    KUAFU_MINE_GET_CAVE_INFO                    = 8008;                     //跨服魂兽森林-获取魂兽森林信息Request,KuafuMineGetCaveInfoRequest
    GLOBAL_FIGHT_END                 = 8011;                     //跨服魂兽森林-狩猎战斗结束Request,KuafuMineOccupyFightEndRequest
    GLOBAL_FIGHT_END                   = 8013;                     //跨服魂兽森林-抢夺战斗结束Request,KuafuMineLootFightEndRequest
    KUAFU_MINE_FIGHT_REPORT_UPLOAD              = 8014;                     //跨服魂兽森林-狩猎、抢夺战报的内容和出战魂师信息上传Request,KuafuMineFightReportUploadRequest
    KUAFU_MINE_GET_FIGHT_REPORT_DATA            = 8015;                     //跨服魂兽森林-获取狩猎、抢夺战报的战报内容Request,KuafuMineGetFightReportDataRequest
    KUAFU_MINE_GET_FIGHT_REPORT_LIST            = 8016;                     //跨服魂兽森林-获个人战报列表Request,KuafuMineGetFightReportListRequest
    KUAFU_MINE_GET_MINE_FIGHT_REPORT_LIST       = 8017;                     //跨服魂兽森林-获取跨服魂兽区战报列表Request,KuafuMineGetMineFightReportListRequest
    KUAFU_MINE_QUERY_FIGHTER                    = 8018;                     //跨服魂兽森林，查询玩家信息,参数:KuafuMineQueryFighterRequest 返回 KuafuMineQueryFighterResponse
    KUAFU_MINE_GET_USER_CAVE_INFO               = 8019;                     //跨服魂兽森林-获取玩家魂兽森林信息(用于复仇寻洞)Request,KuafuMineGetUserCaveInfoRequest
    KUAFU_MINE_CHANGE_DEFENSE_HEROS             = 8020;                     //跨服魂兽森林-设置防守阵容  request BattleFormation 返回 KuafuMineChangeDefenseHerosResponse
    KUAFU_MINE_GET_MINE_SCORE_RANK_INFO         = 8021;                     //跨服魂兽森林-宗门战入口显示排名或进入 无参数 返回 KuafuMineGetMineScoreRankInfoResponse
    KUAFU_MINE_GET_LAST_CAVE_INFO               = 8022;                     //跨服魂兽森林-最后一个废魂兽区的详细魂兽森林信息 参数 KuafuMineGetLastCaveInfoRequest 返回 KuafuMineGetCaveInfoResponse
    KUAFU_MINE_QUICK_FIND_LOOT_MINE             = 8023;                     //跨服魂兽森林-一键找魂兽区, 返回KuafuMineQuickFindLootMineResponse
]]

-- 获取我的信息
function QPlunder:plunderGetMyInfoRequest(success, fail, status)
    local request = { api = "KUAFU_MINE_GET_MY_INFO" }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_MY_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 购买狩猎次数
function QPlunder:plunderBuyOccupyCntRequest(success, fail, status)
    local request = { api = "KUAFU_MINE_BUY_OCCUPY_CNT" }
    app:getClient():requestPackageHandler("KUAFU_MINE_BUY_OCCUPY_CNT", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 购买掠夺次数
function QPlunder:plunderBuyLootCntRequest(success, fail, status)
    local request = { api = "KUAFU_MINE_BUY_LOOT_CNT" }
    app:getClient():requestPackageHandler("KUAFU_MINE_BUY_LOOT_CNT", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 获取掠夺随机奖励
function QPlunder:plunderGetLootRandomAwardRequest(success, fail, status)
    local request = { api = "KUAFU_MINE_GET_LOOT_RANDOM_AWARD" }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_LOOT_RANDOM_AWARD", request, function (response)
    	self.lootRandomAward = nil
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 领取个人积分奖励
-- repeated int32 rewardIds = 1;                                               //奖励ID
-- function QPlunder:plunderGetMyScoreAwardRequest(rewardIds, success, fail, status)
-- 	local kuafuMineGetMyScoreAwardRequest = { rewardIds = rewardIds }
--     local request = { api = "KUAFU_MINE_GET_MY_SCORE_AWARD", kuafuMineGetMyScoreAwardRequest = kuafuMineGetMyScoreAwardRequest }
--     app:getClient():requestPackageHandler("KUAFU_MINE_GET_MY_SCORE_AWARD", request, function (response)
--         self:responseHandler(response, success)
--     end, function (response)
--         self:responseHandler(response, nil, fail)
--     end)
-- end

-- -- 领取宗门积分奖励
-- -- repeated int32 rewardIds = 1;                                               //奖励ID
-- function QPlunder:plunderGetConsortiaScoreAwardRequest(rewardIds, success, fail, status)
-- 	local kuafuMineGetConsortiaScoreAwardRequest = {rewardIds = rewardIds}
--     local request = { api = "KUAFU_MINE_GET_CONSORTIA_SCORE_AWARD", kuafuMineGetConsortiaScoreAwardRequest = kuafuMineGetConsortiaScoreAwardRequest }
--     app:getClient():requestPackageHandler("KUAFU_MINE_GET_CONSORTIA_SCORE_AWARD", request, function (response)
--         self:responseHandler(response, success)
--     end, function (response)
--         self:responseHandler(response, nil, fail)
--     end)
-- end

-- 获取魂兽森林列表
-- optional int32 mineRegion = 1;                                              //魂兽区
function QPlunder:plunderGetCaveListRequest(mineRegion, success, fail, status)
	local kuafuMineGetCaveListRequest = {mineRegion = mineRegion}
    local request = { api = "KUAFU_MINE_GET_CAVE_LIST", kuafuMineGetCaveListRequest = kuafuMineGetCaveListRequest }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_CAVE_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 获取魂兽森林信息
-- optional int32 caveId = 1;                                                  //魂兽森林ID
function QPlunder:plunderGetCaveInfoRequest(caveId, success, fail, status)
	local kuafuMineGetCaveInfoRequest = {caveId = caveId}
    local request = { api = "KUAFU_MINE_GET_CAVE_INFO", kuafuMineGetCaveInfoRequest = kuafuMineGetCaveInfoRequest }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_CAVE_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- -- 战斗开始前校验
-- -- optional int32 mineId = 1;                                                  //待狩猎或抢夺的魂兽区的ID
-- function QPlunder:plunderFightStartCheckRequest(mineId, success, fail, status)
-- 	local kuafuMineFightStartCheckRequest = { mineId = mineId }
--     local request = { api = "KUAFU_MINE_FIGHT_START_CHECK", kuafuMineFightStartCheckRequest = kuafuMineFightStartCheckRequest }
--     app:getClient():requestPackageHandler("KUAFU_MINE_FIGHT_START_CHECK", request, function (response)
--         self:responseHandler(response, success)
--     end, function (response)
--         self:responseHandler(response, nil, fail)
--     end)
-- end

-- -- 狩猎战斗开始
-- -- optional int32 mineId = 1;                                                  //待狩猎的魂兽区的ID,BattleFormation设置攻击部队
-- -- optional string mineOwnerId = 2;                                            //魂兽区的狩猎者,为空表示没人狩猎
-- function QPlunder:plunderOccupyFightStartRequest(mineId, mineOwnerId, success, fail, status)
-- 	local kuafuMineOccupyFightStartRequest = { mineId = mineId, mineOwnerId = mineOwnerId }
--     local request = { api = "KUAFU_MINE_OCCUPY_FIGHT_START", kuafuMineOccupyFightStartRequest = kuafuMineOccupyFightStartRequest }
--     app:getClient():requestPackageHandler("KUAFU_MINE_OCCUPY_FIGHT_START", request, function (response)
--         self:responseHandler(response, success)
--     end, function (response)
--         self:responseHandler(response, nil, fail)
--     end)
-- end

-- 狩猎战斗结束
-- optional int32 mineId = 1;                                                  //待狩猎的魂兽区的ID
-- optional string mineOwnerId = 2;                                            //魂兽区的占有者,为空表示没人占
-- optional string fightReportData = 3;                                        //战报内容
-- optional string battleVerify = 4;                                           //战斗校验key
-- optional bool isWin = 5;                                                    //是否胜利
-- optional bool isQuick = 6;                                                  //快速开始战斗:true表示快速开始战斗,先结算后战斗;false表示按照之前的流程走
function QPlunder:plunderOccupyFightEndRequest(mineId, mineOwnerId, fightReportData, battleKey, isWin, isQuick, battleFormation, success, fail, status)
	local battleVerify = q.battleVerifyHandler(battleKey)
	local kuafuMineOccupyFightEndRequest = { mineId = mineId, mineOwnerId = mineOwnerId, battleVerify = battleVerify, isWin = isWin, isQuick = isQuick }
   	local gfEndRequest = {battleType = BattleTypeEnum.KUAFU_MINE, battleVerify = battleVerify, isQuick = false, isWin = nil,
                         fightReportData = fightReportData, battleFormation = battleFormation, kuafuMineOccupyFightEndRequest = kuafuMineOccupyFightEndRequest}
    local request = { api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}

    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
    	if response.gfEndResponse and response.gfEndResponse.kuafuMineOccupyFightEndResponse then
    		local caveConfig = self:getCaveConfigByMineId( mineId )
    		if caveConfig and caveConfig.cave_bonus and caveConfig.cave_bonus == 1 then
    			self._isShareRedTips = true
    		end
    		self._isNeedShowMineId = tonumber(mineId)
    	end
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


function QPlunder:plunderFightStartRequest(battleType, battleFormation,success,fail)
    local gfStartRequest = {battleType = battleType,battleFormation = battleFormation}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail)
end

-- -- 掠夺战斗开始
-- -- optional int32 mineId = 1;                                                  //待抢夺的魂兽区的ID,BattleFormation设置攻击部队
-- -- optional string mineOwnerId = 2;                                            //魂兽区的狩猎者,为空表示没人狩猎
-- function QPlunder:plunderLootFightStartRequest(mineId, mineOwnerId, success, fail, status)
-- 	local kuafuMineLootFightStartRequest = { mineId = mineId, mineOwnerId = mineOwnerId }
--     local request = { api = "KUAFU_MINE_LOOT_FIGHT_START", kuafuMineLootFightStartRequest = kuafuMineLootFightStartRequest }
--     app:getClient():requestPackageHandler("KUAFU_MINE_LOOT_FIGHT_START", request, function (response)
--         self:responseHandler(response, success)
--     end, function (response)
--         self:responseHandler(response, nil, fail)
--     end)
-- end

-- 掠夺战斗结束
-- optional int32 mineId = 1;                                                  //待狩猎的魂兽区的ID
-- optional string mineOwnerId = 2;                                            //魂兽区的占有者,为空表示没人占
-- optional string fightReportData = 3;                                        //战报内容
-- optional string battleVerify = 4;                                           //战斗校验key
-- optional bool isWin = 5;                                                    //是否胜利
-- optional bool isQuick = 6;                                                  //快速开始战斗:true表示快速开始战斗,先结算后战斗;false表示按照之前的流程走
function QPlunder:plunderLootFightEndRequest(mineId, mineOwnerId, fightReportData, battleKey, isWin, isQuick, battleFormation, success, fail, status)
	local battleVerify = q.battleVerifyHandler(battleKey)
	local kuafuMineLootFightEndRequest = { mineId = mineId, mineOwnerId = mineOwnerId, battleVerify = battleVerify, isWin = isWin, isQuick = isQuick }
	local gfEndRequest = {battleType = BattleTypeEnum.KUAFU_MINE, battleVerify = battleVerify, isQuick = false, isWin = nil,
                         fightReportData = fightReportData,battleFormation = battleFormation, kuafuMineLootFightEndRequest = kuafuMineLootFightEndRequest}
    local request = { api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 狩猎、掠夺战报的内容和出战魂师信息上传
-- optional int64 fightReportId = 1;                                           //战报ID
-- optional string fightReportData = 2;                                        //战报内容
-- optional string fightersData = 3;                                           //战斗魂师数据信息
function QPlunder:plunderFightReportUploadRequest(fightReportId, fightReportData, fightersData, success, fail, status)
	local kuafuMineFightReportUploadRequest = { fightReportId = fightReportId, fightReportData = fightReportData, fightersData = fightersData }
    local request = { api = "KUAFU_MINE_FIGHT_REPORT_UPLOAD", kuafuMineFightReportUploadRequest = kuafuMineFightReportUploadRequest }
    app:getClient():requestPackageHandler("KUAFU_MINE_FIGHT_REPORT_UPLOAD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 获取狩猎、掠夺战报的战报内容
-- optional int64 fightReportId = 1;                                           //战报ID
function QPlunder:plunderGetFightReportDataRequest(fightReportId, success, fail, status)
	local kuafuMineGetFightReportDataRequest = { fightReportId = fightReportId }
    local request = { api = "KUAFU_MINE_GET_FIGHT_REPORT_DATA", kuafuMineGetFightReportDataRequest = kuafuMineGetFightReportDataRequest }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_FIGHT_REPORT_DATA", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 获取狩猎、掠夺战报的出战魂师信息
-- optional int64 fightReportId = 1;                                           //战报ID
-- function QPlunder:plunderGetFightReportFighterDataRequest(fightReportId, success, fail, status)
-- 	local kuafuMineGetFightReportFighterDataRequest = { fightReportId = fightReportId }
--     local request = { api = "KUAFU_MINE_GET_FIGHT_REPORT_FIGHTER_DATA", kuafuMineGetFightReportFighterDataRequest = kuafuMineGetFightReportFighterDataRequest }
--     app:getClient():requestPackageHandler("KUAFU_MINE_GET_FIGHT_REPORT_FIGHTER_DATA", request, function (response)
--         self:responseHandler(response, success)
--     end, function (response)
--         self:responseHandler(response, nil, fail)
--     end)
-- end

-- 获取（个人/宗门）战报列表
-- optional int32 type = 1;                                                   //是否获取自己的战报（1: 个人战报，2：宗门战报）
function QPlunder:plunderGetFightReportListRequest(reportType, success, fail, status)
	local kuafuMineGetFightReportListRequest = {}
    local request = { api = "KUAFU_MINE_GET_FIGHT_REPORT_LIST", kuafuMineGetFightReportListRequest = kuafuMineGetFightReportListRequest }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_FIGHT_REPORT_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 获取魂兽森林战报列表
function QPlunder:plunderGetMineFightReportListRequest(success, fail, status)
    local request = { api = "KUAFU_MINE_GET_MINE_FIGHT_REPORT_LIST" }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_MINE_FIGHT_REPORT_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 查询魂师
-- required string userId   = 1;
function QPlunder:plunderQueryFighterRequest(userId, success, fail, status)
	local kuafuMineQueryFighterRequest = { userId = userId }
    local request = { api = "KUAFU_MINE_QUERY_FIGHTER", kuafuMineQueryFighterRequest = kuafuMineQueryFighterRequest }
    app:getClient():requestPackageHandler("KUAFU_MINE_QUERY_FIGHTER", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 获取玩家魂兽森林信息
-- optional int32 userId = 1;                                                  //用户ID
function QPlunder:plunderGetUserCaveInfoRequest(userId, success, fail, status)
	local kuafuMineGetUserCaveInfoRequest = { userId = userId }
    local request = { api = "KUAFU_MINE_GET_USER_CAVE_INFO", kuafuMineGetUserCaveInfoRequest = kuafuMineGetUserCaveInfoRequest }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_USER_CAVE_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 设置防守阵容
-- repeated int32 mainHeroIds = 1;                         //主将集合
-- repeated int32 sub1HeroIds = 2;                         //副将1集合
-- optional int32 activeSub1HeroId = 3;                    //激活援助技能的副将1集合中的魂师
-- repeated int32 sub2HeroIds = 4;                         //副将2集合
-- optional int32 activeSub2HeroId = 5;                    //激活援助技能的副将2集合中的魂师
function QPlunder:plunderChangeDefenseHerosRequest(team, success, fail, status)
	local battleFormation = remote.teamManager:encodeBattleFormation(team)
    local request = { api = "KUAFU_MINE_CHANGE_DEFENSE_HEROS", battleFormation = battleFormation }
    app:getClient():requestPackageHandler("KUAFU_MINE_CHANGE_DEFENSE_HEROS", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 宗门战入口显示排名或进入
function QPlunder:plunderGetMineScoreRankInfoRequest(success, fail, status)
    local request = { api = "KUAFU_MINE_GET_MINE_SCORE_RANK_INFO" }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_MINE_SCORE_RANK_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 最后一个废魂兽区的详细魂兽森林信息
-- optional int32 mineId = 1;                                                  //最后一个魂兽森林中(任意一个)魂兽区的ID
function QPlunder:plunderGetLastCaveInfoRequest(mineId, success, fail, status)
	local kuafuMineGetLastCaveInfoRequest = { mineId = mineId }
    local request = { api = "KUAFU_MINE_GET_LAST_CAVE_INFO", kuafuMineGetLastCaveInfoRequest = kuafuMineGetLastCaveInfoRequest }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_LAST_CAVE_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 领取个人积分奖励
-- optional int32 mineId = 1;                                                  //最后一个魂兽森林中(任意一个)魂兽区的ID
function QPlunder:plunderGetPersonalAwardRequest(rewardIds, success, fail, status)
	local kuafuMineGetMyScoreAwardRequest = { rewardIds = rewardIds }
    local request = { api = "KUAFU_MINE_GET_MY_SCORE_AWARD", kuafuMineGetMyScoreAwardRequest = kuafuMineGetMyScoreAwardRequest }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_MY_SCORE_AWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 领取宗门积分奖励
-- optional int32 mineId = 1;                                                  //最后一个魂兽森林中(任意一个)魂兽区的ID
function QPlunder:plunderGetUnionAwardRequest(rewardIds, success, fail, status)
	local kuafuMineGetConsortiaScoreAwardRequest = { rewardIds = rewardIds }
    local request = { api = "KUAFU_MINE_GET_CONSORTIA_SCORE_AWARD", kuafuMineGetConsortiaScoreAwardRequest = kuafuMineGetConsortiaScoreAwardRequest }
    app:getClient():requestPackageHandler("KUAFU_MINE_GET_CONSORTIA_SCORE_AWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 一键找魂兽区
function QPlunder:plunderQuickFindLootMineRequest(success, fail, status)
    local request = { api = "KUAFU_MINE_QUICK_FIND_LOOT_MINE" }
    app:getClient():requestPackageHandler("KUAFU_MINE_QUICK_FIND_LOOT_MINE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具--------------

function QPlunder:checkPlunderUnlock(isTips)
	local isUnlock = false
	if remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
		-- 玩家有宗门
		local unlockLevel = QStaticDatabase.sharedDatabase():getConfigurationValue("GH_KZ_KAIQI")
		if remote.union.consortia and remote.union.consortia.level and remote.union.consortia.level >= unlockLevel then
			-- 玩家宗门的等级满足开启条件
			isUnlock = app.unlock:getUnlockPlunder(isTips) -- 判断玩家的战队等级是否满足开启条件
		else
			if isTips then
				app.tip:floatTip("宗门等级达到5级后开启极北之地")
			end
		end
	end
	return isUnlock
end

function QPlunder:_changeCaveRegion()
	self.mines = {}
    self._dispatchTBl = {}
    self._lock = false
	self:plunderGetCaveListRequest( self.caveRegion )
end

function QPlunder:_calculateForce()
	if not self.defenseArmy or table.nums(self.defenseArmy) == 0 then 
		self.defenseForce = 0 
		return 
	end

    local tbl = {}
    local force = 0
    local index = 1

    if self.defenseArmy.mainHeroIds then
    	tbl = self.defenseArmy.mainHeroIds
    else
    	self.defenseForce = 0
    	return 
    end

   	for _, id in pairs(tbl) do
		local heroProp = remote.herosUtil:createHeroPropById(id)
		if heroProp then
			force = force + heroProp:getBattleForce(true)
		end
	end

	-- print("[Kumo] QPlunder:_calculateForce() 主力防守战力：", force)

	while true do
		tbl = self.defenseArmy["sub"..index.."HeroIds"]
		if tbl then
			for _, id in pairs(tbl) do
				local heroProp = remote.herosUtil:createHeroPropById(id)
				if heroProp then
					force = force + heroProp:getBattleForce(true)
				end
			end
			index = index + 1
		else
			break
		end
    end

	if self.defenseArmy.soulSpiritId then
		local soulForce = remote.soulSpirit:countForceBySpiritIds(self.defenseArmy.soulSpiritId)
		force = force + soulForce
	end

	if self.defenseArmy.godArmIdList then
		local soulForce = remote.godarm:countForceByGodarmIds(self.defenseArmy.godArmIdList)
		force = force + soulForce
	end

    self.defenseForce = force
    -- print("[Kumo] QPlunder:_calculateForce() 防守战力：", self.defenseForce)
end

function QPlunder:_dispatchAll()
	if not self._dispatchTBl or table.nums(self._dispatchTBl) == 0 then return end
	local tbl = {}
	for _, name in pairs(self._dispatchTBl) do
		if not tbl[name] then
			self:dispatchEvent({name = name})
			tbl[name] = 0
		end
	end
	self._dispatchTBl = {}
end

function QPlunder:_updateTeam()
	local defenseArmy = self.defenseArmy
	if defenseArmy then
		local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.PLUNDER_DEFEND_TEAM)
		teamVO:setTeamDataWithBattleFormation(defenseArmy)
	end
end

--[[
 	optional int32 occupyCnt = 1;                                               //剩余狩猎次数
    optional int32 buyOccupyCnt = 2;                                            //已购买狩猎次数
    optional int32 lootCnt = 3;                                                 //剩余抢魂兽区次数
    optional int32 buyLootCnt = 4;                                              //已购买抢魂兽区次数
    optional string lootRandomAward = 5;                                        //抢魂兽区随机奖励
    repeated int32 myScoreAwards = 6;                                           //已领取的个人积分奖励
    repeated int32 consortiaScoreAwards = 7;                                    //已领取的宗门积分奖励
    optional int32 myScore = 8;                                                 //个人当前积分
    optional int32 myMaxScore = 9;                                              //个人最高积分(用于个人目标奖励)
    optional int32 consortiaScore = 10;                                         //宗门当前积分
    optional int32 consortiaMaxScore = 11;                                      //宗门最高积分(用于宗门目标奖励)
    optional int32 myMineId = 12;                                               //狩猎的魂兽区ID
    optional int32 myRank = 13;                                                 //个人积分排名
    optional int32 consortiaRank = 14;                                          //宗门积分排名
    optional string defenseArmy = 15;                                           //我的防守阵容
    optional int32 maxMineId = 16;                                              //最大魂兽区ID
]]
function QPlunder:_updateMyInfo( data )
	if data and table.nums(data) > 0 then
		self.occupyCnt            = data.occupyCnt
		self.buyOccupyCnt         = data.buyOccupyCnt
		self.lootCnt              = data.lootCnt
		self.buyLootCnt           = data.buyLootCnt
		self.lootRandomAward	  = data.lootRandomAward
		self.myScoreAwards        = data.myScoreAwards
		self.consortiaScoreAwards = data.consortiaScoreAwards
		self.myScore              = data.myScore
		self.myMaxScore           = data.myMaxScore
		self.consortiaScore       = data.consortiaScore
		self.consortiaMaxScore    = data.consortiaMaxScore
		self.myMineId             = data.myMineId
		self.myRank               = data.myRank
		self.consortiaRank        = data.consortiaRank
		self.defenseArmy          = data.defenseArmy
		self.maxMineId            = data.maxMineId
	end

	if self.defenseArmy then
		self:_updateTeam()
	end
end

--[[
 	optional int32 caveId = 1;                                                  //魂兽森林ID
    optional int32 mineCount = 2;                                               //魂兽区数量
    repeated PbKuafuMineOccupy occupies = 3;                                    //被狩猎点列表
]]
function QPlunder:_updateCaveInfo( data )
	if data and table.nums(data) > 0 then
		for _, cave in pairs(data) do
			local key = cave.caveId
			local tbl = {}
			tbl.caveId = cave.caveId
			tbl.occupies = cave.occupies or {}
			self.caves[key] = tbl
		end
	end
end

--[[
 	optional int32  mineId = 1;                                                 //魂兽区ID
    optional int32  occupyScore = 3;                                            //狩猎积分
    optional int32  lootedCnt = 4;                                              //被抢夺次数
    optional string ownerId = 5;                                                //狩猎者ID
    optional string ownerName = 6;                                              //狩猎者名称
    optional string consortiaId = 7;                                            //宗门ID
    optional string consortiaName = 8;                                          //宗门名称
    optional int32  defenseForce = 9;                                           //守魂兽区部队的战斗力
    optional string gameAreaName = 10;                                         //区服名称
]]
function QPlunder:_updateMineInfo( data )
	if data and table.nums(data) > 0 then
		for _, mine in pairs(data.occupies or {}) do
			local key = mine.mineId
			local tbl = {}
			tbl.mineId        = mine.mineId
			-- tbl.mineName = mine.mineName
			tbl.occupyScore   = mine.occupyScore
			tbl.lootScore     = mine.lootScore
			tbl.ownerId       = mine.ownerId
			tbl.ownerName     = mine.ownerName
			tbl.consortiaId   = mine.consortiaId
			tbl.consortiaName = mine.consortiaName
			tbl.defenseForce  = mine.defenseForce
			tbl.gameAreaName  = mine.gameAreaName

			self.mines[key] = tbl
		end
	end
end

--[[
	optional int32  mineId = 1;                                                 //魂兽区ID
    optional int32  occupyScore = 3;                                            //狩猎积分
    optional int32  lootedCnt = 4;                                              //被抢夺次数
    optional string ownerId = 5;                                                //狩猎者ID
    optional string ownerName = 6;                                              //狩猎者名称
    optional string consortiaId = 7;                                            //宗门ID
    optional string consortiaName = 8;                                          //宗门名称
    optional int32  defenseForce = 9;                                           //守魂兽区部队的战斗力
]]
function QPlunder:_updateMyOccupy( data )
	self.myOccupy = data
end

return QPlunder
