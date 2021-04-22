-- @Author: liaoxianbo
-- @Date:   2020-07-31 11:02:06
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-25 14:31:04
local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QMazeExplore = class("QMazeExplore",QActivityRoundsBaseChild)

local QNotificationCenter = import("..controllers.QNotificationCenter")
local QVIPUtil = import(".QVIPUtil")
local QActivity = import(".QActivity")
local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")
local QMazeExploreArrangement = import("..arrangement.QMazeExploreArrangement")

QMazeExplore.DEBUG_ONOFF = false

QMazeExplore.GRID_EVENT_USE_PORTAL_SVR = "GRID_EVENT_USE_PORTAL_SVR"
QMazeExplore.GRID_EVENT_USE_PORTAL = "GRID_EVENT_USE_PORTAL"

QMazeExplore.GRID_INFO_UPDATE = "GRID_INFO_UPDATE"
QMazeExplore.FALL_ROCK_FAIL = "FALL_ROCK_FAIL"
QMazeExplore.STOP_TIMER = "STOP_TIMER"
QMazeExplore.CONTINUE_TIMER = "CONTINUE_TIMER"

QMazeExplore.CONTINUE_WALK = "CONTINUE_WALK"
QMazeExplore.PLAY_EFFECT = "PLAY_EFFECT"  --走到终点播放特效

------------------------------event---------------------------------------------
--格子事件

QMazeExplore.ENUMERATE_GRID_EVENT = {	
	GRID_EVENT_NORMAL = 0,                       	--普通格子
	GRID_EVENT_FIXAWARDS = 1,                    	--固定奖励
	GRID_EVENT_RANDAWARDS = 2,                   	--随机奖励
	GRID_EVENT_EVENTAWARDS = 3,                  	--事件奖励
	GRID_EVENT_CHESTAWARDS = 4,						--宝箱奖励
	GRID_EVENT_ACTORSPECK = 5,						--半身像对话
	GRID_EVENT_TXTSPECK	= 6,						--文本剧情
	GRID_EVENT_PORTAL = 7,							--传送门
	GRID_EVENT_SECRET_ONOFF = 8,					--暗格开/关
	GRID_EVENT_SECRET_BE = 9,						--暗格对象
	GRID_EVENT_LIGHTHOUSE = 10,						--灯塔
	GRID_EVENT_ROCKS = 11,							--落石
	GRID_EVENT_SOLDIERS = 12,						--追兵
	GRID_EVENT_REMOVE = 13,							--解除
	GRID_EVENT_LIFTS_ONOFF = 14,					--升降台升/降
	GRID_EVENT_LIFTS_BE = 15,						--升降台对象
	GRID_EVENT_TOSTAB = 16,							--地刺
	GRID_EVENT_FINGERGAME = 17,						--猜拳
	GRID_EVENT_DICE = 18,							--掷骰子
	GRID_EVENT_BOSS = 19,							--BOSS
	GRID_EVENT_ENDPOINT = 20,						--关卡终点
	GRID_EVENT_STARTPOINT = 21,						--关卡起点
}
--------------------------------------------------------------------------------

function QMazeExplore:ctor(luckType)
    QMazeExplore.super.ctor(self,luckType)
    cc.GameObject.extend(self)
    self._mazeExploreChapterConfigs = db:getStaticByName("maze_explore_chapter")
    self._mazeExploreRoundConfigs = db:getStaticByName("maze_explore_round")
    self._gridEventList = {
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_NORMAL, eventFun = handler(self, self._eventNomal)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FIXAWARDS, eventFun = handler(self, self._eventFixAwards)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_RANDAWARDS, eventFun = handler(self, self._eventRandomAwards)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_EVENTAWARDS, eventFun = handler(self, self._eventAwards)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_CHESTAWARDS, eventFun = handler(self, self._eventChestAwards)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ACTORSPECK, eventFun = handler(self, self._eventActorSpeck)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TXTSPECK, eventFun = handler(self, self._eventTxtSpeck)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_PORTAL, eventFun = handler(self, self._eventPortal)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_ONOFF, eventFun = handler(self, self._eventSecretOne)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SECRET_BE, eventFun = handler(self, self._eventSecretTwo)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIGHTHOUSE, eventFun = handler(self, self._eventLightHouse)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ROCKS, eventFun = handler(self, self._eventRocks)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SOLDIERS, eventFun = handler(self, self._eventSoldiers)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_REMOVE, eventFun = handler(self, self._eventRemove)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_ONOFF, eventFun = handler(self, self._eventLiftsOne)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_LIFTS_BE, eventFun = handler(self, self._eventLiftsTwo)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TOSTAB, eventFun = handler(self, self._eventToStab)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_FINGERGAME, eventFun = handler(self, self._eventFingergame)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_DICE, eventFun = handler(self, self._eventDice)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_BOSS, eventFun = handler(self, self._eventFightBoss)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ENDPOINT, eventFun = handler(self, self._eventEndPoint)},
    	{eventID = QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_STARTPOINT, eventFun = handler(self, self._eventStartPoint)},
	}
	self:resetData()
end

function QMazeExplore:resetData( )

	self._mazeExploreMemoryAwardList = {} --记忆奖励
	self._curChapterGrids = {}
	self._mazeExploreFightReward = {} --战斗奖励	
	self._power = 0
	self._moveCount = 0
	self._score = 0
	self._keyCount = 0
	self._progressAwardGot = {}
	self._scoreAwardGot = {}
	self._dungeonDataList = {}
	self._num = 0
	self._buyCount = 0
	self._exploredTextGrids = {} --探索记录
	self._topDialogCloseCallBack = nil
end
-----------------------------------量表数据相关------------------------------------------------------------
function QMazeExplore:getMazeExploreChapterConfigs()
	return self._mazeExploreChapterConfigs or nil 
end

function QMazeExplore:getMazeExploreConfigsByChapterId(chapterId)
	local returnTbl = {}
    for _, config in pairs(self._mazeExploreChapterConfigs) do
        if tonumber(config.chapter_id) == tonumber(chapterId) then
			returnTbl[tonumber(config.id)] = config
        end
    end
    return returnTbl
end

function QMazeExplore:getMazeExploreConfigsById(gridID)
    for _, config in pairs(self._mazeExploreChapterConfigs) do
        if config.id == gridID then
			return config
        end
    end
    return nil
end

function QMazeExplore:getMazeExploreRoundInfo()
	local returnTbl = self._mazeExploreRoundConfigs[tostring(self.rowNum)] or {}

    table.sort( returnTbl, function( a,b )
    	return a.chapter_id < b.chapter_id
    end )

    return returnTbl
end

function QMazeExplore:getPassedShareId( )
	local allConfig = self:getMazeExploreRoundInfo()
	for _,v in pairs(allConfig) do
		if v.share_id then
			return v.share_id
		end
	end
	return nil
end

function QMazeExplore:getMazeExploreDungeonInfoByChapterID(chapterId )
	local allConfig = self:getMazeExploreRoundInfo()
	for _,v in pairs(allConfig) do
		if v.chapter_id == chapterId then
			return v
		end
	end

	return nil
end

function QMazeExplore:getAwardPreviewData( chapterId)
	local returnTbl = {}
    for _, config in pairs(self._mazeExploreChapterConfigs) do
        if config.chapter_id == chapterId and config.lucky_draw_id then
        	if config.event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_EVENTAWARDS then
        		table.insert(returnTbl,"maze_explore_random_1")
        	else
				table.insert(returnTbl,config.lucky_draw_id)
			end
        end
    end

    return returnTbl
end
--获取记忆奖励
function QMazeExplore:getMazeExploreMemoryAwardList()
	if q.isEmpty(self._mazeExploreMemoryAwardList) then
		local awardsConfig = db:getStaticByName("maze_explore_memerypiece_reward")
		for _,awards in pairs(awardsConfig) do
			if self.rowNum and self.rowNum == awards.row_num then
				table.insert(self._mazeExploreMemoryAwardList,awards)
			end
		end
		table.sort( self._mazeExploreMemoryAwardList, function( a,b )
			return tonumber(a.id) < tonumber(b.id)
		end )		
	end

	return self._mazeExploreMemoryAwardList
end

function QMazeExplore:getMazeExploreRecordConfigById(id)

	local recordConfig = db:getStaticByName("maze_explore_record")
	for _,config in pairs(recordConfig) do
		if config.id == id then
			return config
		end
	end
	return nil
end

function QMazeExplore:getProgressAwards()
    local tbl = {}
    local mazeExploreReward = db:getStaticByName("maze_explore_progress_reward")
    for _, awards in pairs(mazeExploreReward) do
    	if self.rowNum and awards.row_num == self.rowNum then
        	tbl[awards.id] = awards
        end
    end

    return tbl
end

function QMazeExplore:getMazeExploreFightReward( )
	if q.isEmpty(self._mazeExploreFightReward) then
		local fightRewards = db:getStaticByName("maze_explore_fight_reward")
		for _,v in pairs(fightRewards) do
			if self.rowNum and v.row_num == self.rowNum then
				table.insert(self._mazeExploreFightReward,v)
			end
		end

		table.sort( self._mazeExploreFightReward, function( a,b )
			return tonumber(a.pass_time) < tonumber(b.pass_time)
		end )	
	end

	return self._mazeExploreFightReward
end

function QMazeExplore:getMazeExploreFightDesByStar(starNum)
	local fightRewards = self:getMazeExploreFightReward()
	for _,v in pairs(fightRewards) do
		if starNum == v.battle_star then
			return string.format("战斗生存%d秒",v.pass_time or 60) 
		end
	end

	return "战斗生存60秒"
end
-----------------------------------------------------------------------------------------------------------
function QMazeExplore:timeRefresh( event )
	-- body
	if event.time and event.time == 0 then
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.MAZE_EXPLORE_UPDATE})
	end
end

function QMazeExplore:activityShowEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.MAZE_EXPLORE_UPDATE})
end

function QMazeExplore:activityEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.MAZE_EXPLORE_UPDATE})
end

function QMazeExplore:handleOnLine( )
	-- body
	if self:checkMazeExploreIsOpen() then
		self:_loadActivity()
	end
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.MAZE_EXPLORE_UPDATE})
end

function QMazeExplore:handleOffLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.MAZE_EXPLORE_UPDATE})
end

function QMazeExplore:removeSelf( )
	QMazeExplore.super.removeSelf(self)
	self:resetData()
end

function QMazeExplore:getActivityInfoWhenLogin( success, fail )
	if self:checkMazeExploreIsOpen() then
		self:getMazeExploreMainInfoRequset()
		self:_loadActivity()

	end	
end

function QMazeExplore:checkMazeExploreIsOpen()
	-- return true
	return self.isOpen
end

function QMazeExplore:checkProgressAwardTips()
	local progressAwardGot = self._progressAwardGot or {}
	local awardsData = self:getProgressAwards() 
	for _, data in pairs(awardsData) do
		local isGet = false
		for _,index in ipairs(progressAwardGot or {}) do
			if index == data.id then
				isGet = true
				break
			end
		end

		if isGet == false and self._num >= data.condition then
			return true
		end
	end
	return false
end

function QMazeExplore:checkMemoryAwardTips( )
	local receivedChapterIds = self:_anaylsisReceivedMemoryList()
	local passAwardsList = self:getMazeExploreMemoryAwardList()
	local tbl = {}
	local isReceivedTbl = {} --已领取
	local starRewardTbl = {} --可领取

	for _, chapter in pairs(passAwardsList) do
		tbl[chapter.id] = {["id"] = chapter.id, award = chapter.reward_id, memeryPieceNum = chapter.memery_piece_num}
	end

	for _, value in pairs(tbl) do
		if receivedChapterIds and receivedChapterIds[value.id]  then
			table.insert(isReceivedTbl, value)
		elseif value.memeryPieceNum <= self:getMazeExploreScore() then
			table.insert(starRewardTbl, value)
		end
	end

	if q.isEmpty(starRewardTbl) == false then
		return true
	end

	return false
end


function QMazeExplore:checkRedTips()
	if not self:checkMazeExploreIsOpen() then
		return false
	end

	if self:checkProgressAwardTips() then
		return true
	end

	if self:checkMemoryAwardTips() then
		return true
	end

	return app:getUserOperateRecord():compareCurrentTimeWithRecordeTime("activity_mazeExplore_Click") 

end

function QMazeExplore:checkIsFirstOpen(keyStr)
	return app:getUserOperateRecord():getRecordByType(keyStr) == true 
end

function QMazeExplore:checkIsFirstEnterChapter(chapterId)
	return app:getUserOperateRecord():getRecordByType("MAZE_EXPLORE_ENTER_FIRST_CHAPTER_id_"..chapterId..tostring(remote.user.userId)) == nil 
	-- return  app:getUserData():getValueForKey("MAZE_EXPLORE_ENTER_FIRST_CHAPTER_id_"..chapterId..tostring(remote.user.userId)) == nil
end


function QMazeExplore:setFirstEnterChapter(chapterId)
	app:getUserOperateRecord():setRecordByType("MAZE_EXPLORE_ENTER_FIRST_CHAPTER_id_"..chapterId..tostring(remote.user.userId),true)
	-- app:getUserData():setValueForKey("MAZE_EXPLORE_ENTER_FIRST_CHAPTER_id_"..chapterId..tostring(remote.user.userId), "true")
end

-- 加入到活動數據裡，讓主界面顯示icon
function QMazeExplore:_loadActivity()
    if self:checkMazeExploreIsOpen() then
        local activities = {}
        local themeInfo = db:getActivityThemeInfoById(QActivity.THEME_ACTIVITY_MAZE_EXPLORE) or {}
        table.insert(activities, {
        	activityId = self.activityId, 
        	title = "破碎位面", 
        	start_at = self.startAt * 1000, 
        	end_at = self.endAt * 1000,
        	award_at = self.startAt * 1000, 
        	award_end_at = self.showEndAt * 1000, 
        	weight = 20, 
        	targets = {}, 
        	subject = QActivity.THEME_ACTIVITY_MAZE_EXPLORE
            })
        remote.activity:setData(activities)
    else
        remote.activity:removeActivity(self.activityId)
    end
end

--判断是否全部通关
function QMazeExplore:checkAllDungeonPassed()
	return self._isComplete or false
end

------------------------------event Fun---------------------------------------------

function QMazeExplore:switchTimeToStar( passTime )
	if not passTime then return 0 end
	local fightRewards = self:getMazeExploreFightReward()
	local starNum = 0
	for _,v in pairs(fightRewards) do
		if passTime >= v.pass_time*1000 then
			starNum = math.max(starNum,v.battle_star)
		end
	end

	return starNum
end

function QMazeExplore:switchAwards(prizes,gridInfo)
	QPrintTable(prizes)
    local awards = {}
    for _,value in ipairs(prizes or {}) do	   	
    	local typeName = value.typeName
    	if value.typeName then
    		typeName = value.typeName 
    	end
    	if value.type then
    		typeName = value.type 
    	end
    	if value.id ~= 0 then
        	table.insert(awards, {id = value.id, typeName = typeName, count = value.count})
        else
        	table.insert(awards, {id = nil, typeName = typeName, count = value.count})
        end
    end
    if gridInfo and gridInfo.memory_pieces and gridInfo.memory_pieces  > 0 then
    	table.insert(awards, {id = nil, typeName = ITEM_TYPE.MAZE_EXPLORE_MEROY, count = gridInfo.memory_pieces})
    end

    if gridInfo and gridInfo.key_count and gridInfo.key_count > 0 then
    	table.insert(awards, {id = nil, typeName = ITEM_TYPE.MAZE_EXPLORE_KEY, count = gridInfo.key_count})
    end
    return awards
end

function QMazeExplore:checkEnergyEnough( gridInfo )
	if gridInfo.energy and self._power < gridInfo.energy then
		-- app.tip:floatTip("精神力不足。")
		return false
	end

	return true
end
function QMazeExplore:EventTriggerByGridInfo( gridInfo,needRequest )
	if q.isEmpty(gridInfo) then return end
	--地刺事件独立判断精神力
	if gridInfo.energy and self._power < gridInfo.energy and gridInfo.event_type == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_TOSTAB then
		app.tip:floatTip("精神力不足。")
		return
	end
	for _,v in pairs(self._gridEventList) do
		if v.eventID == gridInfo.event_type then
			if self._topDialg then
				self._topDialogCloseCallBack = function( )
					v.eventFun(gridInfo,needRequest)
				end 
			else
				v.eventFun(gridInfo,needRequest)
			end
			return
		end
	end
end

function QMazeExplore:dialogColseCallBack( )
	self._topDialg = nil
	if self._topDialogCloseCallBack then
		self._topDialogCloseCallBack()
		self._topDialogCloseCallBack = nil
	end
end

--普通格子
function QMazeExplore:_eventNomal(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("普通格子")
	end
	-- self:mazeExploreMoveRequest(gridInfo.id)
end

--固定奖励
function QMazeExplore:_eventFixAwards(gridInfo ,needRequest)
	if q.isEmpty(gridInfo) then return end
	self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.INVALID,nil,function( response)
	    local awards = self:switchAwards(response.prizes,gridInfo)
        if q.isEmpty(awards) == false then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreGainReward", 
				options = {awards = awards,des = gridInfo.des}})
		end
	end)
end

--随机奖励
function QMazeExplore:_eventRandomAwards( gridInfo,needRequest )
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("随机奖励")
	end
	if q.isEmpty(gridInfo) then return end
	self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.INVALID,nil,function(response)
	    local awards = self:switchAwards(response.prizes,gridInfo)
        if q.isEmpty(awards) == false then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreGainReward", 
				options = {awards = awards,des = gridInfo.des}})
		end
	end)
end

--事件奖励
function QMazeExplore:_eventAwards( gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("事件选项奖励")
	end
	if q.isEmpty(gridInfo) then return end
	local des = {
        {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
    }
	local luckydrawids = string.split(gridInfo.lucky_draw_id, ";")
	local answerdesTbl = string.split(gridInfo.answer_des,";")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
		options = {textContent = des,tfleftBtn = gridInfo.option_des_1 or "", tfrightBtn = gridInfo.option_des_2 or "",leftCallBack = function( )
			local awards = self:switchAwards(db:getluckyDrawById(luckydrawids[1]),gridInfo)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreGainReward", 
				options = {awards = awards ,des = answerdesTbl[1] or "",callBack = function( )
					self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.DEFAULT,luckydrawids[1])
				end}})
		end, rightCallBack =function( )
			local awards = self:switchAwards(db:getluckyDrawById(luckydrawids[2]),gridInfo)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreGainReward", 
				options = {awards = awards,des = answerdesTbl[2] or "",callBack = function( )
					self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.DEFAULT,luckydrawids[2])
				end}})
		end, callBack = function( )
		
		end}})
end

--宝箱奖励
function QMazeExplore:_eventChestAwards( gridInfo ,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("宝箱奖励")
	end
	local des = {
        {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
    }
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
		options = {textContent = des, tfleftBtn = "离 开", tfrightBtn = "开 启",isShowCost = true, allKeyCount = self:getMazeExploreKeyCount(),costKeyCount= gridInfo.parameter or 1,walletType=ITEM_TYPE.MAZE_EXPLORE_KEY,
			costDes = "消耗钥匙数量",pic = QResPath("maze_explore_eventIcon")[tostring(gridInfo.event_type)],leftCallBack = function( )
			-- self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.DEFAULT)
		end, rightCallBack =function( )
			local costKeyCount = gridInfo.parameter or 1
			if costKeyCount > self:getMazeExploreKeyCount() then
				-- self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.DEFAULT)
				app.tip:floatTip("钥匙不足")
				return
			end
			self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.INVALID,nil,function(response )
				local awards = self:switchAwards(response.prizes,gridInfo)
		        -- for _,value in ipairs(response.prizes) do
		        --     table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
		        -- end	
		        if q.isEmpty(awards) == false then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreGainReward", 
						options = {awards = awards,des = "开启宝箱获得以下奖励"}})	
				end
			end)
		end}})		
end

--半身像对话
function QMazeExplore:_eventActorSpeck( gridInfo ,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("半身像对话")
	end
	if q.isEmpty(gridInfo) then return end 
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBustdialogue", 
		options = {gridInfo = gridInfo,callBack = function( )
			self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.INVALID,nil,function(response )

		    local awards = self:switchAwards(response.prizes,gridInfo)
	        if q.isEmpty(awards) == false then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreGainReward", 
					options = {awards = awards,des = gridInfo.answer_des}})
			end
			end)
		end}})		
end

--文本剧情
function QMazeExplore:_eventTxtSpeck(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("文本剧情")
	end
	if q.isEmpty(gridInfo) then return end 
	local des = {
        {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
    }	
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
		options = {tfOkBtn = "确 定",textContent = des,callBack = function( )
			self:MazeExploreSetGridStatusRequest(gridInfo.id,nil,nil,function(response )
			    local awards = self:switchAwards(response.prizes,gridInfo)
		        if q.isEmpty(awards) == false then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreGainReward", 
						options = {awards = awards,des = gridInfo.des}})
				end
			end)
		end}})
end

--传送门
function QMazeExplore:_eventPortal(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("传送门")
	end
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QMazeExplore.GRID_EVENT_USE_PORTAL_SVR , config = gridInfo })
end

--暗格开/关
function QMazeExplore:_eventSecretOne(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("暗格开/关")
	end
	local des = {
        {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
    }		
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
		options = {textContent = des, tfleftBtn = "离 开", tfrightBtn = "确 定",leftCallBack = function( )
			-- self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.DEFAULT)
		end, rightCallBack =function( )
			if not self:checkEnergyEnough(gridInfo) then 
				app.tip:floatTip("精神力不足。")
				return
			end
			self:MazeExploreSetGridStatusRequest(gridInfo.id)
		end}})		
end

--暗格对象
function QMazeExplore:_eventSecretTwo(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("暗格对象")
	end
end

--灯塔
function QMazeExplore:_eventLightHouse(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("灯塔")
	end
	if needRequest then

		local canOpen = true
		local tipStr = "成功点亮了面前的圣柱"
		local parma = string.split(gridInfo.parameter or "", ";")
		local gridIds = string.split(parma[1] or "", ",")
		if tonumber(gridIds[1]) ~= 0 and self:getGridsStatusById(gridIds[1]) == 1 then
			canOpen = false
			tipStr = "点亮圣柱的顺序错了，瞬间所有圣柱都熄灭了"
		end
		if canOpen and tonumber(parma[2]) ~= 0 then
			tipStr = "点亮了所有的圣柱，前方出现了一条新的路线"
		end

		local des = {
	        {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
	    }		
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
			options = {textContent = des, pic = QResPath("maze_explore_eventIcon")[tostring(gridInfo.event_type)],tfleftBtn = "不点亮", tfrightBtn = "点 亮",leftCallBack = function( )
				-- self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.DEFAULT)
			end, rightCallBack =function( )
				if not self:checkEnergyEnough(gridInfo) then 
					app.tip:floatTip("精神力不足。")
					return
				end			
				self:MazeExploreSetGridStatusRequest(gridInfo.id,nil,nil,function(data)
					app.tip:floatTip(tipStr)
				end)
			end}})	
	end
end

--落石
function QMazeExplore:_eventRocks(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("落石")
	end
	if q.isEmpty(gridInfo) then return end 
	local des = {
        {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
    }	
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
		options = {tfOkBtn = "确 定", textContent = des,callBack = function( )
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreTimeDown", 
				options = {gridInfo = gridInfo, callBack = function(isTrue)
					QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QMazeExplore.FALL_ROCK_FAIL , isTrue = isTrue ,id = gridInfo.id })
					self:MazeExplorePowerDamageRequest(gridInfo.id,not isTrue)
				end}})
		end}})
end

--追兵
function QMazeExplore:_eventSoldiers(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("追兵")
	end
	self:MazeExplorePowerDamageRequest(gridInfo.id,true,function( )
		local des = {
	         {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
		}		    	
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
			options = {tfOkBtn = "确 定",pic = QResPath("maze_explore_eventIcon")[tostring(gridInfo.event_type)], textContent = des,callBack = function()
				
			end}})		
	end)
end

--解除
function QMazeExplore:_eventRemove(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("解除")
	end
	local des = {
        {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
    }		
    local tipStr = nil
    if gridInfo.parameter == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_SOLDIERS then
    	tipStr = "现在走到巡逻路线格子不会再有巡逻者了"
    elseif gridInfo.parameter == QMazeExplore.ENUMERATE_GRID_EVENT.GRID_EVENT_ROCKS then
    	tipStr = "现在走到落石格子不会再有落石掉下来了"
    end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
		options = {textContent = des, tfleftBtn = "离 开", tfrightBtn = "解 除",leftCallBack = function( )
		end, rightCallBack =function( )
			if not self:checkEnergyEnough(gridInfo) then 
				app.tip:floatTip("精神力不足。")
				return
			end			
			self:MazeExploreSetGridStatusRequest(gridInfo.id,nil,nil,function()
				if tipStr then
					app.tip:floatTip(tipStr)
				end
			end)
		end}})		
end

--升降台升/降
function QMazeExplore:_eventLiftsOne(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("升降台升/降")
	end
	local des = {
        {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
    }	

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
		options = {pic = QResPath("maze_explore_eventIcon")[tostring(gridInfo.event_type)],textContent = des, tfleftBtn = "离 开", tfrightBtn = "确 定",leftCallBack = function( )

		end, rightCallBack =function( )
			if not self:checkEnergyEnough(gridInfo) then 
				app.tip:floatTip("精神力不足。")
				return
			end			
			self:MazeExploreSetGridStatusRequest(gridInfo.id)
		end}})	

end

--升降台对象
function QMazeExplore:_eventLiftsTwo(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("升降台对象")
	end
end

--地刺
function QMazeExplore:_eventToStab(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("地刺")
	end

	if not self:checkEnergyEnough(gridInfo) then 
		app.tip:floatTip("精神力不足。")
		return
	end	

	remote.activityRounds:dispatchEvent({name = QMazeExplore.STOP_TIMER })
	local des = {
        {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
    }		
	self._topDialg = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
		options = {tfOkBtn = "确 定", pic = QResPath("maze_explore_eventIcon")[tostring(gridInfo.event_type)], textContent = des,callBack = function()
			self:dialogColseCallBack()
			self:MazeExplorePowerDamageRequest(gridInfo.id,true,function()
				remote.activityRounds:dispatchEvent({name = QMazeExplore.CONTINUE_TIMER })
			end,function()
				self:dialogColseCallBack()
				remote.activityRounds:dispatchEvent({name = QMazeExplore.CONTINUE_TIMER })
			end)
		end}})
	
end

--猜拳
function QMazeExplore:_eventFingergame(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("猜拳")
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventFinger", 
		options = {gridInfo=gridInfo,power = self._power,callBack = function(isWin)

			local gridState = isWin and GridStatus.INVALID or GridStatus.DEFAULT
			self:MazeExploreSetGridStatusRequest(gridInfo.id,gridState,nil,function( response )
			    local awards = self:switchAwards(response.prizes,gridInfo)
		        if q.isEmpty(awards) == false then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreGainReward", 
						options = {awards = awards,des = gridInfo.des}})
				end
			end) 
		end}})
end

--掷骰子
function QMazeExplore:_eventDice(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("掷骰子")
	end 
	-- local des = {
 --        {oType = "font", content = "即使身处绝境，也要再来一把。如果你投两颗骰子，点数之和【",size = 22,color = ccc3(255,215,172)},
 --        {oType = "font", content = "大于"..dicePoints, size = 22,color = ccc3(255, 93, 93),strokeColor = ccc3(87, 59, 46)},
 --        {oType = "font", content = "】，我就让你通过，怎么样？", size = 22,color = ccc3(255,215,172)},
	-- }

	local dicePoints = db:getConfigurationValue("maze_dice_points") or 8
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreThrowDice", 
			options = {gridInfo = gridInfo,power = self._power,callBack = function(diceNum)
				local gridState = GridStatus.INVALID
				if diceNum <= dicePoints then
					gridState = GridStatus.DEFAULT
				end
				self:MazeExploreSetGridStatusRequest(gridInfo.id,gridState,nil,function(response)
				    local awards = self:switchAwards(response.prizes,gridInfo)
			        if q.isEmpty(awards) == false and diceNum > dicePoints then
						app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreGainReward", 
							options = {awards = awards,des = gridInfo.des}})
					end
				end)
			end}})	

end

--BOSS
function QMazeExplore:_eventFightBoss(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("BOSS")
	end

	-- local des = {
 --        {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
 --    }		
    local callBack = function()     
        local mazeExploreArrangement = QMazeExploreArrangement.new({gridInfo=gridInfo,teamKey = remote.teamManager.MAZE_EXPLORE_TEAM})
        mazeExploreArrangement:setIsLocal(true)
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
            options = {arrangement = mazeExploreArrangement}})
    end	
    callBack()
	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
	-- 	options = {textContent = des, tfleftBtn = "离 开", tfrightBtn = "挑 战",leftCallBack = function( )
	-- 		remote.activityRounds:dispatchEvent({name = QMazeExplore.CONTINUE_WALK }) 
	-- 	end, rightCallBack =function( )
	-- 		callBack()
	-- 	end}})
end

--终点
function QMazeExplore:_eventEndPoint(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("终点")
	end
	QPrintTable(gridInfo)
	print("走到终点------needRequest=",needRequest)

	local endPointFun = function()
		self:MazeExploreGetAwardInfoRequest(gridInfo.chapter_id,function(response)
			local awards = {}
			local progress = 0
			if response.mazeExploreGetAwardInfoResponse then
				awards = self:switchAwards(response.mazeExploreGetAwardInfoResponse.prizes) 
				progress = response.mazeExploreGetAwardInfoResponse.progress
				if response.mazeExploreGetAwardInfoResponse.progress then
					self._progress = response.mazeExploreGetAwardInfoResponse.progress
				end
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEndPointInfo", 
				options = {progress = progress,awrds = awards}})	 
		end)
		-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEndPointInfo", 
		-- 	options = {progress = 0.5}})			
	end
	if needRequest then
		local des = {
	        {oType = "font", content = gridInfo.des, size = 22,color = ccc3(255,215,172)},
	    }	
	    local dungeonInfo = self:getMazeExploreDungeonInfoByChapterID(gridInfo.chapter_id)
	    if dungeonInfo and dungeonInfo.share_id then --有share_id的关卡表示最后一关  	
			endPointFun()	    	
	    else
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEventResponse", 
				options = {textContent = des, tfleftBtn = "离 开", tfrightBtn = "开 启",isShowCost = true, allKeyCount = self:getMazeExploreScore(),costKeyCount= gridInfo.parameter or 1,walletType=ITEM_TYPE.MAZE_EXPLORE_MEROY,
				costDes = "开启需要记忆碎片数量",leftCallBack = function( )
					-- remote.activityRounds:dispatchEvent({name = QMazeExplore.CONTINUE_WALK }) 
					-- self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.DEFAULT)
				end, rightCallBack =function( )
					local costKeyCount = gridInfo.parameter or 1
					if costKeyCount > self:getMazeExploreScore() then
						-- self:MazeExploreSetGridStatusRequest(gridInfo.id,GridStatus.DEFAULT)
						app.tip:floatTip("记忆碎片不足")
						return
					end		
					remote.activityRounds:dispatchEvent({name = QMazeExplore.PLAY_EFFECT,gridInfo = gridInfo}) 
				end}})	    	
	    end
	else
		--直接弹进度框
		endPointFun()	
	end
end

--起点
function QMazeExplore:_eventStartPoint(gridInfo,needRequest)
	if QMazeExplore.DEBUG_ONOFF then
		app.tip:floatTip("起点")
	end
end

function QMazeExplore:moveToFindPosEvent(gridInfo)
	self:MazeExploreGetAwardInfoRequest(gridInfo.chapter_id,function(response)
		local awards = {}
		local progress = 0
		if response.mazeExploreGetAwardInfoResponse then
			awards = self:switchAwards(response.mazeExploreGetAwardInfoResponse.prizes) 
			progress = response.mazeExploreGetAwardInfoResponse.progress
			if response.mazeExploreGetAwardInfoResponse.progress then
				self._progress = response.mazeExploreGetAwardInfoResponse.progress
			end
		end		
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEndPointInfo", 
			options = {progress = progress,awrds = awards,callBack = function( )
				self:MazeExploreSetGridStatusRequest(gridInfo.id)
			end}})	 
	end)
	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreEndPointInfo", 
	-- 	options = {progress = 0.5,awrds = nil,callBack = function( )
	-- 		self:MazeExploreSetGridStatusRequest(gridInfo.id)
	-- 	end}})	

end
------------------------------------------------------------------------------------

function QMazeExplore:_anaylsisReceivedMemoryList()
	local receivedMemoryIds = {}
	if q.isEmpty(self._scoreAwardGot) then return nil end
	for _, value in pairs(self._scoreAwardGot) do
		if tonumber(value) then
			receivedMemoryIds[tonumber(value)] = true
		end
	end
	return receivedMemoryIds
end

function QMazeExplore:_changeGridsBySvrData(changedGrids)
	for k,v in pairs(changedGrids or {}) do
		self._curChapterGrids[v.gridId] = v.gridStatus
	end
end

function QMazeExplore:getGridsStatusById(id)
	if self._curChapterGrids[tonumber(id)] then
		return self._curChapterGrids[tonumber(id)]
	end

	return 1
end


function QMazeExplore:_resetGridsBySvrData()
	self._curChapterGrids = {}
end

function QMazeExplore:getMazeExploreCurChapterGrids()
	return self._curChapterGrids
end

function QMazeExplore:getMazeExploreChangeChapterGrids()
	return self._changedGrids
end

function QMazeExplore:getMazeExplorePowers()
	return self._power or 0
end

function QMazeExplore:getMazeExploreMoveCount()
	return self._moveCount or 0
end

function QMazeExplore:getMazeExploreScore()
	return self._score or 0
end

function QMazeExplore:getMazeExploreKeyCount()
	return self._keyCount or 0
end

function QMazeExplore:getMazeExploreDungeonId()
	return self._dungeonId
end

function QMazeExplore:getMazeExploreGridId()
	return self._currGridId
end

function QMazeExplore:getMazeExploreProgressAwardGot()
	return self._progressAwardGot or {}
end

function QMazeExplore:getMazeExploreScoreAwardGot()
	return self._scoreAwardGot or {}
end

function QMazeExplore:getMazeExploreDungeonDataList()
	return self._dungeonDataList or {}
end

function QMazeExplore:getMazeExploreNum()
	return self._num or 0
end

function QMazeExplore:setJoinDungeonId(dungeonId )
	self._dungeonId = dungeonId
end

function QMazeExplore:getJoinDungeonId()
	return self._dungeonId
end

function QMazeExplore:getMazeExploreProgress()
	return self._progress or 0
end


function QMazeExplore:getPassStarByDungeonId(dungeonId)

	if q.isEmpty(self._dungeonDataList) then return 0 end
	for _,dungeonInfo in pairs(self._dungeonDataList) do
		if dungeonInfo.dungeonId == dungeonId then
			return self:switchTimeToStar(dungeonInfo.bossFightPassTime)
		end
	end

	return 0
end

function QMazeExplore:updateBossFightPassTime( passTime,addScore)
	self._score = self._score + (addScore or 0)
	if q.isEmpty(self._dungeonDataList) == false then 
		for _,dungeonInfo in pairs(self._dungeonDataList) do
			if dungeonInfo.dungeonId == self._dungeonId then
				dungeonInfo.bossFightPassTime = passTime
			end
		end
	end
end

function QMazeExplore:getTotalBuyNum()
	if not self:checkMazeExploreIsOpen() then
		return 0
	end
	local days = db:getConfigurationValue("initial_power_buy_times")
    local nowTimeForMsec = q.serverTime() - self.startAt
    days = days + math.floor(nowTimeForMsec/DAY)

    return days
end

function QMazeExplore:getFinshBuyNum( )
	return self._buyCount
end

--获取已经走过的探索记录ID集合
function QMazeExplore:getExploredTextGrids( )
	return self._exploredTextGrids
end
-------------------------------request----------------------------------------------
function QMazeExplore:responseDataHandler( response, successFunc, failFunc )
	local needUpdateMap = false
	if response.mazeExploreMainInfoResponse then
		self._power = response.mazeExploreMainInfoResponse.power
		self._num = response.mazeExploreMainInfoResponse.num
		self._score = response.mazeExploreMainInfoResponse.score
		self._dungeonDataList = response.mazeExploreMainInfoResponse.dungeonDataList
		self._scoreAwardGot = response.mazeExploreMainInfoResponse.scoreAwardGot
		self._progressAwardGot = response.mazeExploreMainInfoResponse.progressAwardGot
		self._buyCount = response.mazeExploreMainInfoResponse.buyCount
		self._exploredTextGrids = response.mazeExploreMainInfoResponse.exploredTextGrids
		self._isComplete = response.mazeExploreMainInfoResponse.isComplete
	end

	if response.mazeExploreDungeonGridResponse then
		self:_resetGridsBySvrData()
		self:_changeGridsBySvrData(response.mazeExploreDungeonGridResponse.passedGrids)
		self._currGridId = response.mazeExploreDungeonGridResponse.currGridId
		self._moveCount = response.mazeExploreDungeonGridResponse.moveCount
		self._keyCount = response.mazeExploreDungeonGridResponse.keyCount
		if response.mazeExploreDungeonGridResponse.progress then
			self._progress = response.mazeExploreDungeonGridResponse.progress
		end
	end

	if response.mazeExploreSetGridStatusResponse then
		if response.mazeExploreSetGridStatusResponse.changedGrids then
			self._changedGrids = response.mazeExploreSetGridStatusResponse.changedGrids
			self:_changeGridsBySvrData(response.mazeExploreSetGridStatusResponse.changedGrids)
			needUpdateMap=true
		end
		if response.mazeExploreSetGridStatusResponse.progress then
			self._progress = response.mazeExploreSetGridStatusResponse.progress
		end
		self._power = response.mazeExploreSetGridStatusResponse.power
		self._score = response.mazeExploreSetGridStatusResponse.score
		if response.mazeExploreSetGridStatusResponse.keyCount then
			self._keyCount = response.mazeExploreSetGridStatusResponse.keyCount
		end
	end

	if response.mazeExploreSavePosResponse then
		self._dungeonId = response.mazeExploreSavePosResponse.dungeonId
		self._currGridId = response.mazeExploreSavePosResponse.currGridId
		self._moveCount = response.mazeExploreSavePosResponse.moveCount
	end
	
	if response.mazeExploreBuyPowerResponse then
		self._power = response.mazeExploreBuyPowerResponse.power
		self._buyCount = response.mazeExploreBuyPowerResponse.buyCount
	end

	if response.mazeExploreMoveResponse then
		self._currGridId = response.mazeExploreMoveResponse.currGridId
		self._moveCount = response.mazeExploreMoveResponse.moveCount
		self._power = response.mazeExploreMoveResponse.power
		if response.mazeExploreMoveResponse.progress then
			self._progress = response.mazeExploreMoveResponse.progress
		end
		if response.mazeExploreMoveResponse.exploredTextGrids then
			self._exploredTextGrids = response.mazeExploreMoveResponse.exploredTextGrids
		end
		if response.mazeExploreMoveResponse.changedGrid then
			self._changedGrids= {}
			table.insert(self._changedGrids , response.mazeExploreMoveResponse.changedGrid)
			self:_changeGridsBySvrData(self._changedGrids)
			needUpdateMap=true
		end
	end
	if response.mazeExplorePowerDamageResponse then
		self._power = response.mazeExplorePowerDamageResponse.power
		if response.mazeExplorePowerDamageResponse.changedGrid then
			self._changedGrids= {}
			table.insert(self._changedGrids , response.mazeExplorePowerDamageResponse.changedGrid)
			self:_changeGridsBySvrData(self._changedGrids)
			needUpdateMap=true
		end
	end

	if response.mazeExploreGotScoreRewardResponse then
		self._scoreAwardGot = response.mazeExploreGotScoreRewardResponse.scoreAwardGot
	end
	if response.mazeExploreGotProgressRewardResponse then
		self._progressAwardGot = response.mazeExploreGotProgressRewardResponse.progressAwardGot
	end

	remote.activityRounds:dispatchEvent({name = remote.activityRounds.MAZE_EXPLORE_UPDATE})

	if needUpdateMap then
		remote.activityRounds:dispatchEvent({name = QMazeExplore.GRID_INFO_UPDATE })
	end

    if successFunc then 
        successFunc(response) 
        return
    end

    if failFunc then 
        failFunc(response)
    end
end

function QMazeExplore:checkAppClientRequset(api,request,success,fail)
	if app:getClient() then
		app:getClient():requestPackageHandler(api,request,function( response )
			self:responseDataHandler(response, success, nil, true)
		end,function( response )
			self:responseDataHandler(response, nil, fail)
		end)
	end
end

-- optional MazeExploreMoveRequest mazeExploreMoveRequest = 760; //MAZE_EXPLORE_MOVE
-- optional MazeExploreSetGridStatusRequest mazeExploreSetGridStatusRequest = 761; //MAZE_EXPLORE_SET_GRID_STATUS
-- optional MazeExploreSavePosRequest mazeExploreSavePosRequest = 762; //MAZE_EXPLORE_SAVE_POS
-- optional MazeExplorePowerDamageRequest mazeExplorePowerDamageRequest = 763; //MAZE_EXPLORE_POWER_DAMAGE
-- optional MazeExploreGotScoreRewardRequest mazeExploreGotScoreRewardRequest = 764; //MAZE_EXPLORE_GOT_SCORE_REWARD
-- optional MazeExploreGotProgressRewardRequest mazeExploreGotProgressRewardRequest = 765; //MAZE_EXPLORE_GOT_PROGRESS_REWARD
function QMazeExplore:getMazeExploreMyInfoRequset( success,fail )
    local request = {api = "MAZE_EXPLORE_GET_MY_INFO"}
    self:checkAppClientRequset(request.api,request,success,fail)  
end

function QMazeExplore:getMazeExploreMainInfoRequset( success,fail )
    local request = {api = "MAZE_EXPLORE_GET_MAIN_INFO"}
    self:checkAppClientRequset(request.api,request,success,fail)  
end

function QMazeExplore:mazeExploreMoveRequest(toGridId, success,fail )
	local mazeExploreMoveRequest = {toGridId = toGridId}
    local request = {api = "MAZE_EXPLORE_MOVE",mazeExploreMoveRequest = mazeExploreMoveRequest}
    self:checkAppClientRequset(request.api,request,success,fail)  
end

function QMazeExplore:MazeExploreDungeonGridRequest(dungeonId, success,fail)
	local mazeExploreDungeonGridRequest = {dungeonId = dungeonId}
    local request = {api = "MAZE_EXPLORE_GET_DUNGEON_INFO",mazeExploreDungeonGridRequest = mazeExploreDungeonGridRequest}

    self:checkAppClientRequset(request.api,request,success,fail)  
end

function QMazeExplore:MazeExploreSetGridStatusRequest(gridId,gridStatus,awardId, success,fail )
	local mazeExploreSetGridStatusRequest = {gridId = gridId,gridStatus = gridStatus,awardId = awardId}
    local request = {api = "MAZE_EXPLORE_SET_GRID_STATUS",mazeExploreSetGridStatusRequest = mazeExploreSetGridStatusRequest}
 
	self:checkAppClientRequset(request.api,request,success,fail)      
end

function QMazeExplore:MazeExploreSavePosRequest(dungeonId,currGridId,moveCount, success,fail )
	local mazeExploreSavePosRequest = {dungeonId = dungeonId,currGridId=currGridId,moveCount = moveCount}
    local request = {api = "MAZE_EXPLORE_SAVE_POS",mazeExploreSavePosRequest = mazeExploreSavePosRequest}

	self:checkAppClientRequset(request.api,request,success,fail)  	
end

function QMazeExplore:MazeExplorePowerDamageRequest(gridId,isDamaged,success,fail )
	local mazeExplorePowerDamageRequest = {gridId = gridId,isDamaged = isDamaged}
    local request = {api = "MAZE_EXPLORE_POWER_DAMAGE",mazeExplorePowerDamageRequest = mazeExplorePowerDamageRequest}

    self:checkAppClientRequset(request.api,request,success,fail)  
end

function QMazeExplore:MazeExploreGotScoreRewardRequest(awardId,success,fail )
	local mazeExploreGotScoreRewardRequest = {awardId = awardId}
    local request = {api = "MAZE_EXPLORE_GET_SCORE_REWARD",mazeExploreGotScoreRewardRequest = mazeExploreGotScoreRewardRequest}
 
    self:checkAppClientRequset(request.api,request,success,fail)  
end

function QMazeExplore:MazeExploreGotProgressRewardRequest(awardId,success,fail )
	local mazeExploreGotProgressRewardRequest = {awardId = {awardId}}
    local request = {api = "MAZE_EXPLORE_GET_PROGRESS_REWARD",mazeExploreGotProgressRewardRequest = mazeExploreGotProgressRewardRequest}
    self:checkAppClientRequset(request.api,request,success,fail)    
end

function QMazeExplore:MazeExploreFightStartRequest(dungenId, battleFormation, success, fail)
	local mazeExploreFightStartRequest = {dungeonId = dungenId}
    local gfStartRequest = {battleType = BattleTypeEnum.MAZE_EXPLORE, battleFormation = battleFormation, mazeExploreFightStartRequest = mazeExploreFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
	self:checkAppClientRequset(request.api,request,success,fail)    
end

function QMazeExplore:MazeExploreFightEndRequest(dungenId, battleKey, success, fail)   
    local mazeExploreFightEndRequest = {dungeonId = dungenId}

    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.MAZE_EXPLORE, battleVerify = battleVerify,fightReportData  = fightReportData,
                                 mazeExploreFightEndRequest = mazeExploreFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
 
    self:checkAppClientRequset(request.api,request,success,fail)
end

function QMazeExplore:MazeExploreBuyPowerRequest(buyCount,success,fail )
	local mazeExploreBuyPowerRequest = {buyCount = buyCount}
    local request = {api = "MAZE_EXPLORE_BUY_POWER",mazeExploreBuyPowerRequest = mazeExploreBuyPowerRequest}
    self:checkAppClientRequset(request.api,request,success,fail)    
end

function QMazeExplore:MazeExploreGetAwardInfoRequest(dungeonId,success,fail )
	local mazeExploreGetAwardInfoRequest = {dungeonId = dungeonId}
    local request = {api = "MAZE_EXPLORE_GET_AWARD_INFO",mazeExploreGetAwardInfoRequest = mazeExploreGetAwardInfoRequest}
    self:checkAppClientRequset(request.api,request,success,fail)    
end

return QMazeExplore