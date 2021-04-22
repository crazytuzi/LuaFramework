--
-- Author: wkwang
-- Date: 2014-05-05 14:22:52
--
local QUIDialog = import(".QUIDialog")
local QUIDialogInstance = class("QUIDialogInstance", QUIDialog)
local QUIWidgetAchievement = import("..widgets.QUIWidgetAchievement")
local QUIWidgetInstance = import("..widgets.QUIWidgetInstance")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetInstanceHead = import("..widgets.QUIWidgetInstanceHead")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QTutorialDirector = import("...tutorial.QTutorialDirector")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetHands = import("..widgets.QUIWidgetHands")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidget = import("..widgets.QUIWidget")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUserData = import("...utils.QUserData")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")

function QUIDialogInstance:ctor(options)
	local ccbFile = "ccb/Dialog_BigEliteChoose.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerPlot", callback = handler(self, self._onTriggerPlot)},
		{ccbCallbackName = "onTriggerPassAward", callback = handler(self, self._onTriggerPassAward)},
		{ccbCallbackName = "onTriggerMonthCard", callback = handler(self, self._onTriggerMonthCard)},
	}
	QUIDialogInstance.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page and page.__cname == "QUIPageMainMenu" then
		page:setManyUIVisible()
		page.topBar:showWithDungeon()
	end
	
	if options == nil then
		options = {}
		self:setOptions(options)
	else
		self._cloudInterludeCallBack = options.cloudInterludeCallBack
	end

	if options.instanceType == nil then
		options.instanceType = DUNGEON_TYPE.NORMAL
	end

	self.targetId = options.targetId
	self.targetNum = options.targetNum

	self._chest = QUIWidgetAchievement.new()
	self._ccbOwner.node_chest:addChild(self._chest)

	self:madeTouchLayer()

	self._instanceType = options.instanceType

	self._totalWidth = 0
	self._isExitFromBattle = false

	local node = self._ccbOwner.node_title
	node:setPositionX(node:getPositionX()+(UI_DESIGN_WIDTH - display.ui_width)/2)
	node:setPositionY(node:getPositionY() + (UI_DESIGN_WIDTH * display.ui_height / display.ui_width - UI_DESIGN_HEIGHT) / 2)
	setShadow5(self._ccbOwner.tf_star)
	setShadow5(self._ccbOwner.alreadyGetLabel)
	self.plotIndex = options.currentIndex

	self._ccbOwner.node_pass_award:setVisible(false)
	self:selectType(self._instanceType)
end

function QUIDialogInstance:hasPlotStartChapter(index)
	-- body
	if index == nil then return false end
	local hasplot = false
	local startPlot = app:getUserData():getUserValueForKey(index .. "_plot_start")
 	if startPlot and startPlot == QUserData.STRING_TRUE then
 		hasplot = false
    else
    	app:getUserData():setUserValueForKey(index .. "_plot_start", QUserData.STRING_TRUE)
    	hasplot = true
    end
    hasplot = true
    return hasplot
end

function QUIDialogInstance:viewDidAppear()
    QUIDialogInstance.super.viewDidAppear(self)
    self:addBackEvent()
    
    self._touchLayer:enable()
    self._touchLayer:setAttachSlide(true)

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

	self._instanceEventProxy = cc.EventProxy.new(remote.instance)
	self._instanceEventProxy:addEventListener(remote.instance.UPDATE_EGG_INFO, handler(self, self._updateEggInfo))

	if self.hasPlot then
		app:getNavigationManager():getController(app.mainUILayer):getTopPage():setBackHomeBtnVisible(false)
	end
end

function QUIDialogInstance:viewAnimationInHandler()
	self._cloudInterludeScheduler = scheduler.performWithDelayGlobal(function()
			if self:safeCheck() and self._cloudInterludeCallBack then
				self._cloudInterludeCallBack()
			end
		end, 0.2)
end

function QUIDialogInstance:viewWillDisappear()
    QUIDialogInstance.super.viewWillDisappear(self)
    self:_removePage()
	self:removeBackEvent()

	self._instanceEventProxy:removeAllEventListeners()

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
    if self._portalPlayer ~= nil and self._portalPlayer.disappear then
    	self._portalPlayer:disappear()
    	self._portalPlayer = nil
    end
	if self._passAwardAniScheduler then
        scheduler.unscheduleGlobal(self._passAwardAniScheduler)
        self._passAwardAniScheduler = nil
    end
    if self._cloudInterludeScheduler then
    	scheduler.unscheduleGlobal(self._cloudInterludeScheduler)
		self._cloudInterludeScheduler = nil
    end
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
end

function QUIDialogInstance:_exitFromBattle()
	self._isExitFromBattle = true
	if self._instanceType ~= nil then
		self:selectType(self._instanceType)
	end 
	local isAgain,dungeonId = remote.instance:getAgain()
	remote.instance:setAgain(false)
	if isAgain then
		local info = remote.instance:getDungeonById(dungeonId)
		self:enterDungeon(info, isAgain)
	end
end

function QUIDialogInstance:madeTouchLayer()
	-- self._size = self._ccbOwner.node_mask:getContentSize()
	self._pageWidth = display.width
	self._pageHeight = display.height
	self._mapNode = self._ccbOwner.node_map
	self._originalY = self._mapNode:getPositionY()
  	self._pageX = self._mapNode:getPositionX()
    CalculateBattleUIPosition(self._ccbOwner.node_map , true)

  	
	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
    self._touchLayer:attachToNode(self._ccbOwner.map_touchLayer,self._pageWidth,self._pageHeight,-self._pageWidth/2,-self._pageHeight/2, handler(self, self.onTouchEvent))
end

--根据副本类型显示副本内容
function QUIDialogInstance:selectType(instanceType)
	self:hideArrow()
	self:_removeAllMapInfo()

	-- [Kumo] 福利副本不需要下面的地图信息
	if instanceType == DUNGEON_TYPE.WELFARE then
		self._ccbOwner.map_info:setVisible(false)
		self._ccbOwner.btn_paihang:setVisible(false)
	else
		self._ccbOwner.map_info:setVisible(true)
		self._ccbOwner.btn_paihang:setVisible(true)
	end

	self._instanceType = instanceType
	local options = self:getOptions()
	options.instanceType = instanceType
	-- self._actionHandler = {}
  	self:_removePage()
	self._currentPage = nil
	self._ccbOwner.tf_welfareCount:setVisible(false)
	self._ccbOwner.btn_month_card:setVisible(false)
	self._ccbOwner.tf_welfareAddCount:setVisible(false)

	if self._instanceType == DUNGEON_TYPE.NORMAL then
		self._ccbOwner.normol_copy:setVisible(true)
		self._ccbOwner.elite_copy:setVisible(false)
		self._ccbOwner.welfare_copy:setVisible(false)
	elseif self._instanceType == DUNGEON_TYPE.ELITE then
		self._ccbOwner.normol_copy:setVisible(false)
		self._ccbOwner.elite_copy:setVisible(true)
		self._ccbOwner.welfare_copy:setVisible(false)
	elseif self._instanceType == DUNGEON_TYPE.WELFARE then
		self._ccbOwner.normol_copy:setVisible(false)
		self._ccbOwner.elite_copy:setVisible(false)
		self._ccbOwner.welfare_copy:setVisible(true)
		local leftCount = QVIPUtil:getWelfareCount() - remote.welfareInstance:getPassCount()
		if remote.activity:checkMonthCardActive(2) then
			leftCount = leftCount + 1
			self._ccbOwner.btn_month_card:setVisible(true)
		end
		if leftCount > QVIPUtil:getWelfareCount() then
			self._ccbOwner.tf_welfareAddCount:setVisible(true)
			self._ccbOwner.tf_welfareCount:setString("挑战次数：3   次")
		else
			self._ccbOwner.tf_welfareCount:setString(string.format("挑战次数：%d次", leftCount))
			self._ccbOwner.tf_welfareAddCount:setVisible(false)
		end
		self._ccbOwner.tf_welfareCount:setVisible(true)
	end

	if self._instanceType == DUNGEON_TYPE.WELFARE then
		-- self._totalIndex --全部可攻击的章节
		-- self._currentIndex -- 正在进行中的章节
		self._totalIndex = remote.welfareInstance:getTotalOpenedInstanceCount()
		self._currentIndex = options.currentIndex
		if options.selectIndex ~= nil then
			self._selectId = options.selectIndex
		else
			self._selectId = remote.welfareInstance:getCurrentDungeonID()
		end
		self._needPassID = remote.welfareInstance:getCurrentDungeonID()
		if not self._currentIndex then
			self._currentIndex = remote.welfareInstance:getCurrentInstanceIndex()
			options.currentIndex = self._currentIndex
		end
		if self._currentIndex ~= nil then
			self:showInstanceForData()
			-- if options.needPassId ~= nil then
			-- 	self:creatTutorialHands()
			-- end
		end

		if remote.welfareInstance:isFirstWin() and remote.welfareInstance:getBattleEnd() and remote.welfareInstance:isBattleWin() then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWelfareFirstWin", options = nil})

			remote.welfareInstance:setIsFirstWin(false)
			remote.welfareInstance:setBattleEnd(false)
			remote.welfareInstance:setBattleWin(false)
		end
	else
		if options.needPassId ~= nil then
			self._selectId = options.needPassId
		elseif options.selectIndex ~= nil then
			self._selectId = options.selectIndex
		else
			self._selectId = remote.instance:countNeedPassForType(self._instanceType)
		end
		if options.needPassId ~= nil then
			self._needPassID = options.needPassId
		else
			self._needPassID = remote.instance:countNeedPassForType(self._instanceType)
		end

		self._instanceData = remote.instance:getInstancesWithUnlockAndType(self._instanceType)
		self._totalIndex = #self._instanceData
		self._currentIndex = options.currentIndex
		if self._currentIndex == nil then
			for index,value in ipairs(self._instanceData) do
				for _,data in ipairs(value.data) do
					if data.dungeon_id == self._needPassID then
						self._currentIndex = index
						options.currentIndex = index
						break
					end
				end
				if self._currentIndex ~= nil then
					break
				end
			end
		end
		if self._currentIndex ~= nil then
			self:showInstanceForData()
			if options.needPassId ~= nil then
				self:creatTutorialHands()
			end
		end
	end

	-- xurui: set invasion boss info
	self:setInvasionBossInfo()

	-- zxs checkPassInfo
	self:checkPassAwardInfo()

	remote.instance:setLastPassId(nil)
end

function QUIDialogInstance:showInstanceForData()
	if self._totalIndex < self._currentIndex then
		return 
	end
	self._currentPage = self:madePageForIndex(self._currentIndex)
	self._currentPage:setPositionX(-self._pageWidth/2)
    self._currentPage:addEventListener(QUIWidgetInstanceHead.EVENT_CITY_CLICK, handler(self,self._headClickHandler))
    self._currentPage:addEventListener(QUIWidgetInstanceHead.EVENT_BOX_CLICK, handler(self,self._boxClickHandler))
	self._ccbOwner.map_content:addChild(self._currentPage)
	self:showMapInfo()
    self:checkButtonShow()
	self._totalWidth = self._currentPage:getWidth()
	local isFirst = self:checkFristPassMap()
	local head = self._currentPage:getLastDungeon(self._needPassID)
	local isNeedPass = true
	if head == nil then
		isNeedPass = false
		local dungeonId
		if self._instanceType == DUNGEON_TYPE.WELFARE then
			dungeonId = remote.welfareInstance:getWelfareInfo(self._currentIndex).dungeons[1].dungeon_id
			local dungeons = remote.welfareInstance:getWelfareInfo(self._currentIndex).dungeons
			for index, value in ipairs(dungeons) do
				dungeonId = value.dungeon_id
				if value.state == remote.welfareInstance.WEI_KAI_QI then
					break
				end
			end
		else
			dungeonId = self._instanceData[self._currentIndex].data[1].dungeon_id
			for index, value in ipairs(self._instanceData[self._currentIndex].data) do
				dungeonId = value.dungeon_id
				if value.info == nil then
					break
				end
			end
		end
		head = self._currentPage:getLastDungeon(dungeonId)
	end
	if head ~= nil then
		local p = head:getStarNode():convertToWorldSpaceAR(ccp(0,0))
		p = self._ccbOwner.node_arrow:getParent():convertToNodeSpaceAR(p)
		if isNeedPass == true then
			self._ccbOwner.node_arrow:setVisible(true)
			self._ccbOwner.node_arrow:setPosition(p)
		end
	end

	local selectHead = self._currentPage:getLastDungeon(self._selectId)
	if selectHead == nil then selectHead = head end

	-- 不是从战斗中回来，不是第一次全通过
	if not isFirst or not self._isExitFromBattle then
		if selectHead ~= nil then
			local p = selectHead:getStarNode():convertToWorldSpaceAR(ccp(0,0))
			p = self._ccbOwner.node_arrow:getParent():convertToNodeSpaceAR(p)
			self:moveTo(-p.x - self._mapNode:getPositionX() , false, true)
		else
			self:moveTo(-self._totalWidth - self._mapNode:getPositionX(), false, true)
		end
	end
	self._selectHead = selectHead
	self:checkDungeonAside()
end

function QUIDialogInstance:getSelectHead()
	return self._selectHead
end

function QUIDialogInstance:setInvasionBossInfo( ... )
	if self._instanceType == DUNGEON_TYPE.WELFARE then return end

	local invasions = clone(remote.invasion:getInvasions())
	if invasions == nil or #invasions == 0 or invasions[1].bossHp == 0 then 

	else
		local invasionBoss = QUIWidgetHeroHead.new()
		self._ccbOwner.node_invasion_boss:addChild(invasionBoss)
		invasionBoss:setHero(invasions[1].bossId)
		invasionBoss:setScale(0.6)
		invasionBoss:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onClickInvasionBoss))
	    if invasions[1].boss_type == 1 then
			invasionBoss:setBreakthrough(0)
	    elseif invasions[1].boss_type == 2 then
			invasionBoss:setBreakthrough(2)
	    elseif invasions[1].boss_type == 3 then
			invasionBoss:setBreakthrough(7)
	    else
			invasionBoss:setBreakthrough(12)
	    end
	end
end

-- 通关提示
function QUIDialogInstance:checkPassAwardInfo()
	self._ccbOwner.node_pass_award:setVisible(false)
	if self._instanceType ~= DUNGEON_TYPE.NORMAL then
		return
	end

    local dungeonIntId = remote.instance:getLastPassDungeonIntId(DUNGEON_TYPE.NORMAL)
	local showAward = remote.instance:checkShowPassAwardById( dungeonIntId )
	if not showAward then
		return
	end
	
	self:updatePassAwardInfo(showAward)
	local callback = function()
		local passId = app:getUserOperateRecord():getRecordByType("dungeon_pass_award_id") or 0
		if showAward.id > tonumber(passId) then
			self._ccbOwner.node_pass_award:setVisible(false)
			local callback2 = function()
				app:getUserOperateRecord():setRecordByType("dungeon_pass_award_id", showAward.id)
				self:showPassAwardAni()
			end
			if not app.tutorial or not app.tutorial:isInTutorial() then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDungeonPassAward", 
					options = {awardInfo = showAward, callback = callback2}})
			end
		end
	end
	if self._isExitFromBattle then
		self._passAwardAniScheduler = scheduler.performWithDelayGlobal(function ()
	            callback()
	        end, 0.2)
	else
	    callback()
	end
end

function QUIDialogInstance:updatePassAwardInfo(showAward)
	self._ccbOwner.node_pass_award:setVisible(true)
	if showAward.title_icon then
		local icon = CCSprite:create(showAward.title_icon)
		icon:setScale(85/icon:getContentSize().width)
		icon:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
		self._ccbOwner.node_pass_icon:removeAllChildren()
		self._ccbOwner.node_pass_icon:addChild(icon)
		self._ccbOwner.node_pass_icon:setScaleX(-1)
	end
	if showAward.title_name then
		self._ccbOwner.tf_name:setString(showAward.title_name)
	end
	local isAllGet = remote.instance:getIsAllPassAwardsGet()
	self._ccbOwner.node_effect:setVisible(not isAllGet)
end

function QUIDialogInstance:showPassAwardAni()
	if self:safeCheck() == false then return end

	local posX, posY = self._ccbOwner.node_pass_award:getPosition()
	self._ccbOwner.node_pass_award:setVisible(true)
	self._ccbOwner.node_pass_award:setPosition(ccp(0, display.height/2-20))

	local moveTo = CCMoveTo:create(0.8, ccp(posX, posY))
	local array = CCArray:create()
	array:addObject(moveTo)
    array:addObject(CCCallFunc:create(function () 
    		self._ccbOwner.node_pass_award:setVisible(true)
        end))
    local sequence = CCSequence:create(array)
    self._ccbOwner.node_pass_award:runAction(sequence)
end

function QUIDialogInstance:_onClickInvasionBoss()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasion", options = {}})
end

--显示箭头
function QUIDialogInstance:showArrow(node)
	if node ~= nil then
		self._ccbOwner.node_arrow:setVisible(true)
		-- local size = node:getBg():getContentSize()
		local p = node:getStarNode():convertToWorldSpaceAR(ccp(0,0))
		p = self._ccbOwner.node_arrow:getParent():convertToNodeSpaceAR(p)
		-- p.y = p.y + size.height/2
		self._ccbOwner.node_arrow:setPosition(p)
	end
end

--隐藏箭头
function QUIDialogInstance:hideArrow()
	self._ccbOwner.node_arrow:setVisible(false)
	self._ccbOwner.node_pass_award:setVisible(false)
end

--根据index生成当前的page
function QUIDialogInstance:madePageForIndex()
	if self._instanceType == DUNGEON_TYPE.WELFARE then
		return QUIWidgetInstance.new({info = remote.welfareInstance:getWelfareInfo(self._currentIndex), instanceType = self._instanceType, index = self._currentIndex})
	else
		return QUIWidgetInstance.new({info = self._instanceData[self._currentIndex], instanceType = self._instanceType,  index = self._currentIndex})
	end
end

--显示当前副本的信息
function QUIDialogInstance:showMapInfo()
	if self._instanceType == DUNGEON_TYPE.WELFARE then
		self._ccbOwner.tf_title3:setString(remote.welfareInstance:getInstanceNameByIndex(self._currentIndex))
	else
		local info = self._instanceData[self._currentIndex]
		if info == nil then return end
		self._ccbOwner.tf_title1:setString(info.data[1].instance_name)
		self._ccbOwner.tf_title2:setString(info.data[1].instance_name)
		local totalStar,currentStar = 0, 0
		for _,value in pairs(info.data) do
			totalStar = totalStar + 3
			currentStar = currentStar + (value.info and (value.info.star or 0) or 0)
		end
		self._ccbOwner.tf_star:setString(currentStar.."/"..totalStar)
		if self._chest then
			self._chest:setVisible(true)
			self._chest:starDrop(info.data[1].instance_id, info.data[1].int_instance_id,currentStar,totalStar)
		end
	end

	local contentSize = self._ccbOwner.tf_title1:getContentSize()
	if self._instanceType == DUNGEON_TYPE.ELITE then
		contentSize = self._ccbOwner.tf_title2:getContentSize()
	elseif self._instanceType == DUNGEON_TYPE.WELFARE then
		contentSize = self._ccbOwner.tf_title3:getContentSize()
	end
	local bgSize = contentSize.width+40 + 60 
	self._ccbOwner.elite_title_bg:setContentSize(CCSize(bgSize,60))
	self._ccbOwner.welfare_title_bg:setContentSize(CCSize(bgSize,60))
	self._ccbOwner.normal_title_bg:setContentSize(CCSize(bgSize,60))
	local offsetX = contentSize.width-370
    self._ccbOwner.node_invasion_boss:setPositionX(offsetX)

    --显示彩蛋进度
    self:_updateEggInfo()
end

function QUIDialogInstance:_updateEggInfo(event)
    self._ccbOwner.node_egg:setVisible(false)
    if self._instanceType ~= DUNGEON_TYPE.NORMAL then return end
    local currentInfo = self._instanceData[self._currentIndex] or {}
    local mapId = (currentInfo.data[1].int_instance_id or 9999999)
	if currentInfo.data and mapId <= remote.instance.MAP_EGG_MAX_ID then
    	self._ccbOwner.node_egg:setVisible(true)

    	local currentNum = 0
		remote.instance:getDropBoxInfoById(mapId, function(data)
				if data.easterEggs then
					currentNum = #data.easterEggs
				end
				self._ccbOwner.tf_egg_num:setString(string.format("%s/3", currentNum))
			end)

		if event then
			if self._eggEffect == nil then
				self._eggEffect = QUIWidgetAnimationPlayer.new()
				self._ccbOwner.node_egg:addChild(self._eggEffect)
			end
			self._eggEffect:setPositionX(95)
			self._eggEffect:setPositionY(5)
			self._eggEffect:setScale(0.7)
			self._eggEffect:playAnimation("effects/Tips_add.ccbi", function(ccbOwner)
				ccbOwner.content:setString("+1")
			end, function()
	        	self._eggEffect:disappear()
	        end)
		end
	end


end

function QUIDialogInstance:checkButtonShow()
	if self._needPassID ~= nil then
		self:showArrow(self._currentPage:getLastDungeon(self._needPassID))
	end
end

--检查是否第一次通关该副本
function QUIDialogInstance:checkFristPassMap()
	local isFirst = false
	local isPass = true
	if self._instanceType == DUNGEON_TYPE.WELFARE then
		isPass = remote.welfareInstance:isThisInstanceAllPass(self._currentIndex)
		local name = remote.welfareInstance:getInstanceNameByIndex(self._currentIndex)
		if isPass == true then
			remote.flag:get({remote.flag.FLAG_WELFARE_MAP}, function (tbl)
				local effectIndex = tonumber(tbl[remote.flag.FLAG_WELFARE_MAP])
				if effectIndex ~= nil and effectIndex == self._currentIndex then
					self:portalHandler(true)
					isFirst = true
				else
					self:portalHandler()
				end
			end)
		end
	else
		local info = self._instanceData[self._currentIndex]
		for _,value in pairs(info.data) do
			if value.info == nil or value.info.star == nil or value.info.star <= 0 then
				isPass = false
				break
			end
		end
		if isPass == true and self.isQuickWay ~= true then
			if self._instanceType == DUNGEON_TYPE.ELITE then
				remote.flag:get({remote.flag.FLAG_ELITE_MAP}, function (tbl)
					local effectIndex = tonumber(tbl[remote.flag.FLAG_ELITE_MAP])
					if effectIndex ~= nil and effectIndex == self._currentIndex then
						self:portalHandler(true)
						isFirst = true
					else
						self:portalHandler()
					end
				end)
			else
				remote.flag:get({remote.flag.FLAG_MAP}, function (tbl)
					local effectIndex = tonumber(tbl[remote.flag.FLAG_MAP])
					if effectIndex ~= nil and effectIndex == self._currentIndex then
						self:portalHandler(true)
						isFirst = true
					else
						self:portalHandler()
					end
				end)
			end
		end
	end

	-- 记录战斗前是否全通过
	self:getOptions().isNotPass = not isPass
	return isFirst
end

function QUIDialogInstance:showPassAniEnd()
	local callback = function ()
		local head = nil
		if self._currentPage then
			head = self._currentPage:getLastHead()
		end
		if head ~= nil then
			self:checkConveyTutorial()
			self._portalPlayer = QUIWidgetAnimationPlayer.new()
			self._portalPlayer:playAnimation("ccb/effects/chuansong.ccbi",nil, function ()
				self._portalPlayer = nil
				self:portalHandler()
				self._isShowFire = false
			end)
			head:addChild(self._portalPlayer)
		end
		remote.instance:setChapterPassInfo(nil)
	end
	
	local passInfo = remote.instance:getChapterPassInfo()
	-- QPrintTable(passInfo)
	if passInfo and passInfo.currentIndex < 20 then
		passInfo.callback = callback
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDungeonChapterPassSuccess", 
			options = passInfo}, {isPopCurrentDialog = false})
	else
		callback()
	end
end

function QUIDialogInstance:showPassAni()
	local targetX = -(self._totalWidth - self._pageWidth)
	self._mapNode:setPositionX(0)

	self._isShowFire = true
	local curveMove = CCMoveTo:create(3.1, ccp(targetX, self._originalY))
	local actionArrayIn = CCArray:create()
	actionArrayIn:addObject(curveMove)
    actionArrayIn:addObject(CCCallFunc:create(function () 
			self:showPassAniEnd()
        end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._mapNode:runAction(ccsequence)

	local ccbFile = "ccb/effects/lajintou_yanhua.ccbi"
    local proxy = CCBProxy:create()
    local ccbOwner = {}        
    local node = CCBuilderReaderLoad(ccbFile, proxy, ccbOwner)
    self._mapNode:addChild(node)
    for i = 1, 3 do
	    local facEffect = tolua.cast(ccbOwner["fca_view"..i], "QFcaSkeletonView_cpp")
	    facEffect:stopAnimation()
	    facEffect:playAnimation(string.split(facEffect:getAvailableAnimationNames(), ";")[1], false)
  	end
end

function QUIDialogInstance:portalHandler(isEffect)
	local head = self._currentPage:getLastHead()
	if head ~= nil then
		local isNotPass = self:getOptions().isNotPass 
		-- 全通过，从战斗中回来，之前没有全通过
		if isEffect and self._isExitFromBattle and isNotPass then
			self:showPassAni()
		else
		  	local callBacks = {
	      		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIDialogInstance._onTriggerBack)},
			  	}
			local portalWidget = QUIWidget.new("ccb/effects/chuansong2.ccbi", callBacks)
			head:addChild(portalWidget)
		end
	end
end

function QUIDialogInstance:checkConveyTutorial()
	if app.tutorial and app.tutorial:isTutorialFinished() == false then
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		page:buildLayer()
		local haveTutorial = false
	    if app.tutorial:getStage().convey == app.tutorial.Guide_Start then
	       	haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_22_UnlockConvey)
	    end
		if haveTutorial == false then
			page:cleanBuildLayer()
		end
	end
end

function QUIDialogInstance:creatTutorialHands()
	self:hideArrow()

	local node = self._currentPage:getLastDungeon(self._needPassID)
	if node ~= nil then
		self._hands = QUIWidgetHands.new()
		self._CP = node:convertToWorldSpaceAR(ccp(0,0))
		self._CP = self._ccbOwner.map_content:convertToNodeSpaceAR(self._CP)
		self._hands:setPosition(self._CP.x, self._CP.y)
		self._ccbOwner.map_content:addChild(self._hands)
	end
end

function QUIDialogInstance:removeTutorialHands()
	if self._hands ~= nil then
		self._hands:removeFromParent()
		self._hands = nil

		local options = self:getOptions()
		options.targetId = nil
		options.targetNum = nil
		options.needPassId = nil
		self:showArrow(self._currentPage:getLastDungeon(self._needPassID))
	end
end

function QUIDialogInstance:_nodeRunHideAction(node,name)
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCFadeOut:create(0.3))
    actionArrayIn:addObject(CCFadeIn:create(0.5))
    actionArrayIn:addObject(CCCallFunc:create(function () 
    		self._actionHandler[name] = nil
    	end))
    self._actionHandler[name] = node:runAction(CCSequence:create(actionArrayIn))
end

function QUIDialogInstance:_removeAllMapInfo()
	self._ccbOwner.tf_title1:setString("")
	self._ccbOwner.tf_title2:setString("")
	self._ccbOwner.tf_title3:setString("")
	self._ccbOwner.tf_star:setString("")
	if self._chest then
		self._chest:setVisible(false)
	end
end

function QUIDialogInstance:_removePage()
	if self._currentPage ~= nil then
    	self._currentPage:removeAllEventListeners()
    	self._currentPage:removeFromParent()
    	self._currentPage = nil
	end
end


function QUIDialogInstance:onTouchEvent(event)
	if event == nil or event.name == nil then
        return
    end
    
    -- or not self.canTouch

    -- if self.hasPlot and self._plot then
    -- 	if event.name == "ended" then
    -- 		self:clearPlotDialgue()
    -- 	end
    -- 	return
    -- end
    if self._isShowFire then 
    	return
    end

    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		self:moveTo(event.distance.x, true, true)
  	elseif event.name == "began" then
  		self:_removeAction()
  		self._startX = event.x
  		self._pageX = self._mapNode:getPositionX()
    elseif event.name == "moved" then
    	if not self._startX then return end
    	local offsetX = self._pageX + event.x - self._startX
        if math.abs(event.x - self._startX) > 10 then
            self._isMove = true
        end
		if self._totalWidth > self._pageWidth then
			if offsetX < -(self._totalWidth - self._pageWidth) then
				offsetX = -(self._totalWidth - self._pageWidth)
			elseif offsetX > 0 then
				offsetX = 0
			end
			self:moveTo(offsetX, false)
		end
	elseif event.name == "ended" then
    	scheduler.performWithDelayGlobal(function ()
    		self._isMove = false
    		end,0)
    end
end

function QUIDialogInstance:_removeAction()
	if self._actionHandler ~= nil then
		self._mapNode:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
end

function QUIDialogInstance:moveTo(posX, isAnimation, isCheck)
	local targetX = posX
	if isCheck == true then
		local contentX = self._mapNode:getPositionX()
		if self._totalWidth <= self._pageWidth then
			targetX = 0
		elseif contentX + posX < -(self._totalWidth - self._pageWidth) then
			targetX = -(self._totalWidth - self._pageWidth)
		elseif contentX + posX > 0 then
			targetX = 0
		else
			targetX = contentX + posX
		end
	end
	if isAnimation == false then
		self._mapNode:setPositionX(targetX)
		return 
	end
	self:_contentRunAction(targetX, self._originalY)
end

function QUIDialogInstance:_contentRunAction(posX,posY)
    local actionArrayIn = CCArray:create()
    local curveMove = CCMoveTo:create(0.5, ccp(posX,posY))
	local speed = CCEaseExponentialOut:create(curveMove)
	actionArrayIn:addObject(speed)
    actionArrayIn:addObject(CCCallFunc:create(function () 
    											self:_removeAction()
                                            end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._actionHandler = self._mapNode:runAction(ccsequence)
end

function QUIDialogInstance:_headClickHandler(event)
	if self._isMove then
		return
	end
	if self._instanceType == DUNGEON_TYPE.WELFARE then
		local leftCount = QVIPUtil:getWelfareCount() - remote.welfareInstance:getPassCount()
		if remote.activity:checkMonthCardActive(2) then
			leftCount = leftCount + 1
		end
		if leftCount <= 0 then
			if not remote.activity:checkMonthCardActive(2) then
    			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege", options = {isSuper = true}})
			else
				app.tip:floatTip("今日史诗副本次数不足")
			end
			return
		end
	end
	app.sound:playSound("battle_level")
	self:enterDungeon(event.info)
	self:removeTutorialHands()
end

function QUIDialogInstance:_boxClickHandler(event)
	if self._isMove then
		return
	end
	local info = event.info
	local isOpen = event.isOpen
	local isPass = event.isPass
	local box = event.box
	if isOpen == false and isPass == true then
		if info.dungeon_type == DUNGEON_TYPE.WELFARE then
			remote.welfareInstance:openWelfareBossBoxRequest(info.int_dungeon_id, function (data)
				    if data.apiDungeonBossBoxResponse.luckyDraw ~= nil and data.apiDungeonBossBoxResponse.luckyDraw.items then
				        remote.items:setItems(data.apiDungeonBossBoxResponse.luckyDraw.items)
				    end
					local awards = {}
					local prizes = data.apiDungeonBossBoxResponse.luckyDraw.prizes or {}
					for _,item in pairs(prizes) do
			            local typeName = remote.items:getItemType(item.type)
			            table.insert(awards, {typeName = typeName, id = item.id, count = item.count})
					end
			  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
			    		options = {awards = awards}},{isPopCurrentDialog = false} )
			    	dialog:setTitle("恭喜您获得副本BOSS宝箱奖励")
			    	app.sound:playSound("battle_starbox")
					box:addChestBox()
				end)
		else
			app:getClient():apiDungeonBossBoxRequest(info.int_dungeon_id, function (data)
				    if data.apiDungeonBossBoxResponse.luckyDraw ~= nil and data.apiDungeonBossBoxResponse.luckyDraw.items then
				        remote.items:setItems(data.apiDungeonBossBoxResponse.luckyDraw.items)
				    end
					local awards = {}
					local prizes = data.apiDungeonBossBoxResponse.luckyDraw.prizes or {}
					for _,item in pairs(prizes) do
			            local typeName = remote.items:getItemType(item.type)
			            table.insert(awards, {typeName = typeName, id = item.id, count = item.count})
					end
			  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
			    		options = {awards = awards}},{isPopCurrentDialog = false} )
			    	dialog:setTitle("恭喜您获得副本BOSS宝箱奖励")
			    	app.sound:playSound("battle_starbox")
					box:addChestBox()
					QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_ELITE_BOX_SUCCESS})
				end)
		end
	else
		local dungeonConfig = QStaticDatabase:sharedDatabase():getDungeonConfigByID(info.dungeon_id)
		app:luckyDrawAlert(dungeonConfig.boss_box)
	end
end

function QUIDialogInstance:enterDungeon(info, isAgain, pos)
	local options = self:getOptions()
	if isAgain == true then
		local result = remote.instance:checkCount(info.dungeon_id, info.dungeon_type)
		if result == 1 and remote.instance.arrangement ~= nil then
			local instanceOption = self:getOptions()
			local dungeonArrangement = remote.instance.arrangement
			local dungeonOptions = {info = info, targetId = options.targetId, targetNum = options.targetNum, isQuickWay = self.isQuickWay, parentOptions = self:getOptions()}
			app:getNavigationManager():pushDialogInOrder(app.mainUILayer, {
		      {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogDungeon", options = dungeonOptions}}, 
		      {{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement", options = {arrangement = dungeonArrangement}}}, 
	      	})
		    return
		end
	end
	local needTeamLevel = info.unlock_team_level or 0
	if info.info ~= nil and (info.info.lastPassAt or 0) > 0 then
		options.selectIndex = info.dungeon_id
	else
		options.selectIndex = nil
	end
	if needTeamLevel <= remote.user.level then
		local ccbFile = ""
		if self._instanceType == DUNGEON_TYPE.WELFARE then
			ccbFile = remote.welfareInstance:getWelfareInfo(self._currentIndex).file
		else
			ccbFile = self._instanceData[self._currentIndex].data[1].file
		end
		local pos = ccp(self._currentPage:getParent():getParent():getPosition())
		print("posX = "..pos.x.." posY = "..pos.y)
 		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogDungeon", 
			options = {info = info, ccbFile = ccbFile, pos = pos, targetId = options.targetId, targetNum = options.targetNum, isQuickWay = self.isQuickWay, parentOptions = self:getOptions(), isAgain = isAgain}})

		-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogDungeon", 
		-- 	options = {info = info, targetId = options.targetId, targetNum = options.targetNum, isQuickWay = self.isQuickWay, parentOptions = self:getOptions(), isAgain = isAgain}})
	else
		app.tip:floatTip(string.format("该副本需要战队等级%d解锁",needTeamLevel))
	end
end

function QUIDialogInstance:checkDungeonAside()
	if self._instanceType == DUNGEON_TYPE.NORMAL then
		self._instanceData = remote.instance:getInstancesWithUnlockAndType(self._instanceType)
		self._currentIndex = self:getOptions().currentIndex
		if self._currentIndex >= 20 then return end
		local asideNum = remote.flag:getLocalData(remote.flag.FLAG_DUNGEON_ASIDE)
		local data = self._instanceData[self._currentIndex]
		local plotConfigs = db:getDungeonSummaryPlot(self._currentIndex)
		local flagIndex = tonumber(asideNum) or 0

		-- 检测引导
		local callback = function()
			if app.tutorial and app.tutorial:isTutorialFinished() == false then
				app.tutorial:checkTutorialStage()
			end
		end
		if data and data.star == 0 and self._currentIndex > flagIndex then
			local titleName = data.data[1].instance_name
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDungeonAside", 
				options = {text = plotConfigs.start_plot, title = titleName, config = plotConfigs, index = self._currentIndex, isSay = true, callback = callback}})
		end
	end
end

function QUIDialogInstance:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogInstance:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogInstance:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogInstance:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogInstance:_onTriggerRank()

    app.sound:playSound("common_small")
	if self._instanceType == DUNGEON_TYPE.NORMAL then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
			options = {initRank = "Instance", initChildRank = 1}}, {isPopCurrentDialog = false})
	elseif self._instanceType == DUNGEON_TYPE.ELITE then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
			options = {initRank = "Instance", initChildRank = 2}}, {isPopCurrentDialog = false})
	end
end
function QUIDialogInstance:_onTriggerPlot()
	if self._plot and self._plot:getSaying() then
		self._plot:showAllWords()
		return
	end
	if self.hasPlot and self._plot then
		self:clearPlotDialgue()
    	return
    end
end

function QUIDialogInstance:_onTriggerMonthCard()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

function QUIDialogInstance:_onTriggerPassAward()
    if self._isShowFire then 
    	return
    end
    local dungeonIntId = remote.instance:getLastPassDungeonIntId(DUNGEON_TYPE.NORMAL)
	local awardInfo = remote.instance:checkShowPassAwardById( dungeonIntId )

	local callback = function()
		local awardInfo = remote.instance:checkShowPassAwardById( dungeonIntId )
		if not awardInfo then
			return
		end
		self:updatePassAwardInfo(awardInfo)
	end
	local getCallback
	getCallback = function(isShowAni)
		self._ccbOwner.node_pass_award:setVisible(false)
		local awardInfo = remote.instance:checkShowPassAwardById( dungeonIntId )
		if not awardInfo then
			return
		end
		self:updatePassAwardInfo(awardInfo)

		-- 设置关闭后是否做动画
		local passId = app:getUserOperateRecord():getRecordByType("dungeon_pass_award_id") or 0
		if awardInfo.id > tonumber(passId) then
			app:getUserOperateRecord():setRecordByType("dungeon_pass_award_id", awardInfo.id)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDungeonPassAward", 
				options = {awardInfo = awardInfo, getCallback = getCallback, isSetShowAni = true}})
		-- isShowAni 做收的动画
		elseif isShowAni then
			self:showPassAwardAni()
		end
	end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDungeonPassAward", 
			options = {awardInfo = awardInfo, getCallback = getCallback, callback = callback}})
end

function QUIDialogInstance:clearPlotDialgue()
	if self._plot ~= nil then
		self._plot:removeFromParent()
		self._plot = nil
	end
	self.hasPlot = false
    -- app:getUserData():setUserValueForKey(self.plotIndex .. "_plot_start", QUserData.STRING_TRUE)

	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setBackHomeBtnVisible(true)
	self._ccbOwner.main_node:setVisible(true)
	self._ccbOwner.node_plot:setVisible(false)
end

return QUIDialogInstance
