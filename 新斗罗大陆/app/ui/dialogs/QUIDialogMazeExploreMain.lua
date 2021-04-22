-- @Author: liaoxianbo
-- @Date:   2020-07-31 15:24:42
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-20 17:25:42
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreMain = class("QUIDialogMazeExploreMain", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QMazeExplore = import(".QMazeExplore")

local ROTATIONS = {3,-2,-2,-3,-15,2}
QUIDialogMazeExploreMain.OPEN = 1 --开放状态
QUIDialogMazeExploreMain.UNLOCK = 2 --未解锁

function QUIDialogMazeExploreMain:ctor(options)
	local ccbFile = "ccb/Dialog_MazeExplore_main.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self,self._onTriggerRule)},
		{ccbCallbackName = "onTriggerMemoryAward", callback = handler(self,self._onTriggerMemoryAward)},
		{ccbCallbackName = "onTriggerExploreRecord", callback = handler(self,self._onTriggerExploreRecord)},
		{ccbCallbackName = "onTriggerShareSDK",	callback = handler(self,self._onTriggerShareSDK)},
		{ccbCallbackName = "onTriggerCheckpoint1", callback = handler(self, self._onTriggerCheckpoint1)},
		{ccbCallbackName = "onTriggerCheckpoint2", callback = handler(self, self._onTriggerCheckpoint2)},
		{ccbCallbackName = "onTriggerCheckpoint3", callback = handler(self, self._onTriggerCheckpoint3)},
		{ccbCallbackName = "onTriggerCheckpoint4", callback = handler(self, self._onTriggerCheckpoint4)},
		{ccbCallbackName = "onTriggerCheckpoint5", callback = handler(self, self._onTriggerCheckpoint5)},
		{ccbCallbackName = "onTriggerCheckpoint6", callback = handler(self, self._onTriggerCheckpoint6)},
		{ccbCallbackName = "onTriggerBox1", callback = handler(self,self._onTriggerBox1)},
		{ccbCallbackName = "onTriggerBox2", callback = handler(self,self._onTriggerBox2)},
		{ccbCallbackName = "onTriggerBox3", callback = handler(self,self._onTriggerBox3)},
		{ccbCallbackName = "onTriggerBox4", callback = handler(self,self._onTriggerBox4)},
    }
    QUIDialogMazeExploreMain.super.ctor(self, ccbFile, callBacks, options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page and page.setManyUIVisible then page:setManyUIVisible() end
	if page and page.setScalingVisible then page:setScalingVisible(false) end
	
    CalculateUIBgSize(self._ccbOwner.sp_bg)
    q.setButtonEnableShadow(self._ccbOwner.btn_share)
    q.setButtonEnableShadow(self._ccbOwner.btn_record)
    q.setButtonEnableShadow(self._ccbOwner.btn_memoryAward)

    self._totalBarWidth = self._ccbOwner.node_bar:getContentSize().width * self._ccbOwner.node_bar:getScaleX()
    self._totalBarPosY = self._ccbOwner.node_bar:getPositionY()
    self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.node_bar)

    self._commonExploreBarWidth = 124

	self._mazeExploreDataHandle = remote.activityRounds:getMazeExplore()

	self._mazeExploreDataHandle:getMazeExploreMainInfoRequset()

	app:getUserOperateRecord():recordeCurrentTime("activity_mazeExplore_Click")

	self._power = self._mazeExploreDataHandle:getMazeExplorePowers()
	self._num = self._mazeExploreDataHandle:getMazeExploreNum()
	self._score = self._mazeExploreDataHandle:getMazeExploreScore()	
	page.topBar:showMazeExplore(self._power)

	self._chapterState = {}

end

function QUIDialogMazeExploreMain:viewDidAppear()
	QUIDialogMazeExploreMain.super.viewDidAppear(self)
	print("------QUIDialogMazeExploreMain:viewDidAppear------")
	self._activityRoundsProxy = cc.EventProxy.new(remote.activityRounds)
	self._activityRoundsProxy:addEventListener(remote.activityRounds.MAZE_EXPLORE_UPDATE, handler(self, self.onEventUpdate))

	if self._mazeExploreDataHandle.isOpen == false then
		app.tip:floatTip("魂师大人，当前活动已结束")
		self:popSelf()
		return
	end

    self:initButton()
    self:initDungeonState()
    self:updateViewData()
    self:checkRedTips()
    self:checkSharedOpen()

	self:checkShowHand()
	
	self:addBackEvent(true)

	self:setTimeCountdown()

	app:getUserOperateRecord():setRecordByType("MAZE_EXPLORE_CLICK_"..(self._mazeExploreDataHandle.activityId or "activityId")..self._chapterState[1].chapterId,true)
end

function QUIDialogMazeExploreMain:viewWillDisappear()
  	QUIDialogMazeExploreMain.super.viewWillDisappear(self)

	self:removeBackEvent()

	if self._activityRoundsProxy then
		self._activityRoundsProxy:removeAllEventListeners()
	end
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end	
end

function QUIDialogMazeExploreMain:checkShowHand()
	
	local isFirst = self._mazeExploreDataHandle:checkIsFirstOpen("MAZE_EXPLORE_CLICK_"..(self._mazeExploreDataHandle.activityId or "activityId")..self._chapterState[1].chapterId)
	if not isFirst then
		local atkHndLight = CCBuilderReaderLoad("ccb/Widget_TutorialHandTouch.ccbi", CCBProxy:create(), {})
		self._ccbOwner.node_hands:addChild(atkHndLight)
		atkHndLight:setPosition(ccp(0,0))
		local atkHnd = CCBuilderReaderLoad("ccb/effects/jihuo_hand.ccbi", CCBProxy:create(), {})
		self._ccbOwner.node_hands:addChild(atkHnd)
		atkHnd:setPosition(ccp(40,-63))				
	end
end

function QUIDialogMazeExploreMain:setTimeCountdown()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end

	local endTime = self._mazeExploreDataHandle.endAt or 0

	local timeFunc
	timeFunc = function ( )
		local lastTime = endTime - q.serverTime()
		if self:safeCheck() then
			if lastTime > 0 then
				local timeStr = q.timeToDayHourMinute(lastTime)
				self._ccbOwner.tf_lastTime:setString(timeStr)
				if lastTime >= 30*60 then
		            color = GAME_COLOR_SHADOW.stress
		        else
		            color = GAME_COLOR_SHADOW.warning
		        end	
		        self._ccbOwner.tf_lastTime:setColor(color)			
			else 
				app.tip:floatTip("魂师大人，当前活动已结束")
				self:popSelf()
			end
		end
	end

	self._timeScheduler = scheduler.scheduleGlobal(timeFunc, 1)
	timeFunc()
end
function QUIDialogMazeExploreMain:onEventUpdate( )
	if self._mazeExploreDataHandle.isOpen == false then
		app.tip:floatTip("魂师大人，当前活动已结束")
		self:popSelf()
		return
	end

	self._power = self._mazeExploreDataHandle:getMazeExplorePowers()
	self._num = self._mazeExploreDataHandle:getMazeExploreNum()
	self._score = self._mazeExploreDataHandle:getMazeExploreScore()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page and page.topBar then page.topBar:showMazeExplore(self._power) end

	self:updateViewData()

	self:checkRedTips()
	
	self:checkSharedOpen()
end

function QUIDialogMazeExploreMain:checkRedTips( )
	self._ccbOwner.sp_record_tips:setVisible(false)
	local b = self._mazeExploreDataHandle:checkMemoryAwardTips()
	self._ccbOwner.sp_memoryAward_tips:setVisible(b)
end

function QUIDialogMazeExploreMain:checkSharedOpen( )
	if remote.shareSDK:checkIsOpen() then
		local b = self._mazeExploreDataHandle:checkAllDungeonPassed()
		self._ccbOwner.node_share:setVisible(b)
	else
		self._ccbOwner.node_share:setVisible(false)
	end
end
function QUIDialogMazeExploreMain:initButton( )
	for ii=1,6 do
		local btn = self._ccbOwner["maze_btn"..ii]
		if btn then
			q.setButtonEnableShadow(btn)
			btn:setAlphaTouchEnable(true)
		end
	end
end

function QUIDialogMazeExploreMain:initDungeonState()
	self._alldungeonConfig =self._mazeExploreDataHandle:getMazeExploreRoundInfo()
	for key,dungeonInfo in pairs(self._alldungeonConfig) do
		if not self._chapterState[key] then
			self._chapterState[key] = {}
		end
		self._chapterState[key].state = QUIDialogMazeExploreMain.UNLOCK
		self._chapterState[key].chapterId = dungeonInfo.chapter_id
		self._ccbOwner["tf_lock"..key]:setVisible(true)
		self._ccbOwner["tf_process"..key]:setVisible(false)
		self._ccbOwner["tf_finash"..key]:setVisible(false)
		self._ccbOwner["tf_checkPoint"..key]:setString(dungeonInfo.chapter_name or "天空之城")
		self._ccbOwner["tf_checkPoint"..key]:setVisible(false)
		if self._ccbOwner["node_glow_"..key] then
			self._ccbOwner["node_glow_"..key]:setVisible(false)
		end	
		local dungeonPic = QResPath("maze_explore_btnres")[key] or {}
		local mazeBtn = self._ccbOwner["maze_btn"..key]
		if q.isEmpty(dungeonPic) == false and mazeBtn then
			mazeBtn:setBackgroundSpriteFrameForState(QSpriteFrameByPath(dungeonPic[2]), CCControlStateNormal)
			mazeBtn:setBackgroundSpriteFrameForState(QSpriteFrameByPath(dungeonPic[2]), CCControlStateHighlighted)
			mazeBtn:setBackgroundSpriteFrameForState(QSpriteFrameByPath(dungeonPic[2]), CCControlStateDisabled)
		end
	end
end

function QUIDialogMazeExploreMain:updateViewData( )
	self:updateCollegeProgres()
	self:updateExploreProgres()
end

function QUIDialogMazeExploreMain:updateCollegeProgres( )
	local allNum = self._num or 0
	local num,unit = q.convertLargerNumber(allNum)
	self._ccbOwner.tf_allSevercollege:setString(num..(unit or ""))
	local progressAwardGot = self._mazeExploreDataHandle:getMazeExploreProgressAwardGot() 

	self._awardsData = self._mazeExploreDataHandle:getProgressAwards() 
	local progress = 0
	self._getDatas = {}
	self._totalScore = 1
	local finshNum = 0
	local ii=1
	for _, data in pairs(self._awardsData) do
		if self._totalScore < data.condition then
			self._totalScore = data.condition
		end		
		if data ~= nil then
    		local num,unit = q.convertLargerNumber(data.condition)
			self._ccbOwner["tf_"..ii]:setString(num..(unit or ""))
		end
		local isGet = false
		for _,index in ipairs(progressAwardGot or {}) do
			if index == data.id then
				isGet = true
				break
			end
		end
		if not self._getDatas[ii] then
			self._getDatas[ii] = {}
		end
		self._getDatas[ii].isGet = isGet
		self._getDatas[ii].id = data.id
		if isGet == true then
			self._ccbOwner["node_light"..ii]:setVisible(false)
			self._ccbOwner["node_close"..ii]:setVisible(false)
			self._ccbOwner["node_open"..ii]:setVisible(true)
		else
			self._ccbOwner["node_close"..ii]:setVisible(true)
			self._ccbOwner["node_open"..ii]:setVisible(false)
			self._ccbOwner["node_light"..ii]:setVisible(allNum >= data.condition)
		end
		if allNum >= data.condition then
			progress = progress + 1
		end
		ii = ii + 1
	end
	if progress >= #self._awardsData then
		progress = #self._awardsData
	end
	ii = 1
	for _, data in pairs(self._awardsData) do
		self._ccbOwner["node_"..ii]:setVisible(true)
		local averageProgress = self._totalScore / #self._awardsData * ii
		-- self._ccbOwner["node_"..ii]:setPositionY(data.condition/self._totalScore*self._totalBarWidth + self._totalBarPosY)
		self._ccbOwner["node_"..ii]:setPositionY(averageProgress / self._totalScore*self._totalBarWidth + self._totalBarPosY)
		ii = ii + 1
	end


	local stencil = self._percentBarClippingNode:getStencil()

	local posX = 0
	if progress >= #self._awardsData then
		posX = 0
	else
		local averageProgress = self._totalScore / #self._awardsData * progress
		local maxProgress = math.max(averageProgress,allNum)
		posX = -self._totalBarWidth + maxProgress/self._totalScore*self._totalBarWidth
	end
	stencil:setPositionX(posX)

	self._percentBarClippingNode:setRotation(-90)
end

function QUIDialogMazeExploreMain:updateExploreProgres( )
	local dungeonDataList = self._mazeExploreDataHandle:getMazeExploreDungeonDataList()

	for key,dungeonInfo in pairs(self._alldungeonConfig) do
		for _,v in pairs(dungeonDataList or {}) do
			if v.dungeonId == dungeonInfo.chapter_id then
				if self._score >= dungeonInfo.unlock_condition and v.isOpen then 
					self._chapterState[key].state = QUIDialogMazeExploreMain.OPEN
					self._chapterState[key].chapterId = dungeonInfo.chapter_id
					self._ccbOwner["tf_lock"..key]:setVisible(false)
					if v.progress == 1 then
						self._ccbOwner["tf_process"..key]:setVisible(false)
						self._ccbOwner["tf_finash"..key]:setVisible(true)
						self._ccbOwner["tf_finash"..key]:setString("100%")
					else
						self._ccbOwner["tf_process"..key]:setVisible(true)
						self._ccbOwner["tf_finash"..key]:setVisible(false)
						self._ccbOwner["tf_process"..key]:setString(math.floor((v.progress)*100).."%")
					end
					if self._ccbOwner["node_glow_"..key] then
						self._ccbOwner["node_glow_"..key]:setVisible(true)
					end	
					self._ccbOwner["tf_checkPoint"..key]:setVisible(true)	

					local dungeonPic = QResPath("maze_explore_btnres")[key] or {}
					local mazeBtn = self._ccbOwner["maze_btn"..key]
					if q.isEmpty(dungeonPic) == false and mazeBtn then
						mazeBtn:setBackgroundSpriteFrameForState(QSpriteFrameByPath(dungeonPic[1]), CCControlStateNormal)
						mazeBtn:setBackgroundSpriteFrameForState(QSpriteFrameByPath(dungeonPic[1]), CCControlStateHighlighted)
						mazeBtn:setBackgroundSpriteFrameForState(QSpriteFrameByPath(dungeonPic[1]), CCControlStateDisabled)
					end	
				end					
			end
		end
	end

end

function QUIDialogMazeExploreMain:_onTriggerRule()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMazeExploreRule"})
end


function QUIDialogMazeExploreMain:_onTriggerMemoryAward()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMazeExploreMemoryAwards"})
end

function QUIDialogMazeExploreMain:_onTriggerExploreRecord()
	app.sound:playSound("common_small") 
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMazeExploreRecord"})
end

function QUIDialogMazeExploreMain:_onTriggerShareSDK( )
	local shareId = self._mazeExploreDataHandle:getPassedShareId()
	if shareId then 
	    local shareInfo = remote.shareSDK:getShareInfoById(shareId)
	    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogShareSDK", 
	        options = {shareInfo = shareInfo}}, {isPopCurrentDialog = false}) 
	else
		app.tip:floatTip("分享配置不正确！")
	end
end

function QUIDialogMazeExploreMain:checkpointTriggerHandler(index)

	if self._chapterState[index].state == QUIDialogMazeExploreMain.UNLOCK then
		app.tip:floatTip("需要先通过上一个关卡哦~")
		return
	end
	local goToMapFuc = function( )
		self._mazeExploreDataHandle:MazeExploreDungeonGridRequest(self._chapterState[index].chapterId,function()
			
			self._mazeExploreDataHandle:setJoinDungeonId(self._chapterState[index].chapterId)

			local info = {chapterId = self._chapterState[index].chapterId}
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMazeExploreMap",options ={info = info},{isPopCurrentDialog = false}})
		end)
	end

	local isFirst = self._mazeExploreDataHandle:checkIsFirstOpen("MAZE_EXPLORE_CLICK_"..(self._mazeExploreDataHandle.activityId or "activityId")..(self._chapterState[index].chapterId or 0))
	if not isFirst then
		local roundInfo = self._mazeExploreDataHandle:getMazeExploreDungeonInfoByChapterID(self._chapterState[index].chapterId)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMazeExploreFirstPlot",options = {dungenonInfo = roundInfo,callBack=function()
			goToMapFuc()
		end }})
	else
		goToMapFuc()
	end

end

function QUIDialogMazeExploreMain:_onTriggerCheckpoint1()
    app.sound:playSound("common_small")
	self:checkpointTriggerHandler(1)
end

function QUIDialogMazeExploreMain:_onTriggerCheckpoint2()
    app.sound:playSound("common_small")
	self:checkpointTriggerHandler(2)
end

function QUIDialogMazeExploreMain:_onTriggerCheckpoint3()
    app.sound:playSound("common_small")
	self:checkpointTriggerHandler(3)
end

function QUIDialogMazeExploreMain:_onTriggerCheckpoint4()
    app.sound:playSound("common_small")
	self:checkpointTriggerHandler(4)
end

function QUIDialogMazeExploreMain:_onTriggerCheckpoint5()
    app.sound:playSound("common_small")
	self:checkpointTriggerHandler(5)
end

function QUIDialogMazeExploreMain:_onTriggerCheckpoint6()
    app.sound:playSound("common_small")
	self:checkpointTriggerHandler(6)
end

function QUIDialogMazeExploreMain:boxTriggerHandler(index)
	local data = nil
	for _,v in pairs(self._awardsData) do
		if self._getDatas[index].id == v.id then
			data = v 
			break
		end
	end
	if q.isEmpty(data) then return end
	local reward_id = data.reward_id
	local allNum = self._num
	if self._getDatas[index].isGet == false and allNum >= data.condition then
		--请求获取
		self._mazeExploreDataHandle:MazeExploreGotProgressRewardRequest(self._getDatas[index].id, function (data)
			self:updateCollegeProgres()
			local awards = {}
			local luckyDraw = db:getLuckyDraw(reward_id)
			if luckyDraw ~= nil then
				local index = 1
		        while true do
		            if luckyDraw["type_"..index] ~= nil then
		                if luckyDraw["probability_"..index] == -1 then
		                    if not db:checkItemShields(luckyDraw["id_"..index]) then
		                        table.insert(awards, {id = luckyDraw["id_"..index], typeName = luckyDraw["type_"..index], count = luckyDraw["num_"..index]})
		                    end
		                end
		            else
		                break
		            end
		            index = index + 1
		        end
			end

	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    			options = {awards = awards, callBack = function ()
    				remote.redpacket:openFreeTimeAlert(function()
    						remote.user:checkTeamUp()
    					end, true)
	    		end}},{isPopCurrentDialog = false} )
	    	dialog:setTitle("恭喜您获得全服收集奖励")
		end)
	else
		local num,unit = q.convertLargerNumber(data.condition)
		local tips = {
            {oType = "font", content = "领取条件：全服收集记忆碎片累计达到",size = 20,color = ccc3(114,82,63)},
            {oType = "font", content = num..(unit or ""),size = 20,color = ccc3(109,57,29)},
        }
		app:luckyDrawAlert(data.reward_id, tips, nil, false)
	end
end

function QUIDialogMazeExploreMain:_onTriggerBox1(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(1)
end

function QUIDialogMazeExploreMain:_onTriggerBox2(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(2)
end

function QUIDialogMazeExploreMain:_onTriggerBox3(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(3)
end

function QUIDialogMazeExploreMain:_onTriggerBox4(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(4)
end

function QUIDialogMazeExploreMain:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMazeExploreMain:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMazeExploreMain
