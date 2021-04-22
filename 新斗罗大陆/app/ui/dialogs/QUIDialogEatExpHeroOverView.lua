--
-- Author: xurui
-- Date: 2015-09-18 10:09:38
--
local QUIDialog = import(".QUIDialog")
local QUIDialogEatExpHeroOverView = class(".QUIDialogEatExpHeroOverView", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRemote = import("...models.QRemote")
local QUIWidgetHeroOverview = import("..widgets.QUIWidgetHeroOverview")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIViewController = import("..QUIViewController")
local QUIWidgetEatExpHeroFrame = import("..widgets.QUIWidgetEatExpHeroFrame")
local QTutorialDirector = import("...tutorial.QTutorialDirector")
local QQuickWay = import("...utils.QQuickWay")

QUIDialogEatExpHeroOverView.TOTAL_HERO_FRAME = 6
QUIDialogEatExpHeroOverView.TAB_ALL = "TAB_ALL"
QUIDialogEatExpHeroOverView.TAB_MAGIC = "TAB_MAGIC"
QUIDialogEatExpHeroOverView.TAB_HASTE = "TAB_HASTE"
QUIDialogEatExpHeroOverView.TAB_PHYSICAL = "TAB_PHYSICAL"
QUIDialogEatExpHeroOverView.TAB_ATTRITION = "TAB_ATTRITION"
--QUIDialogEatExpHeroOverView.TUTORIAL_HERO_UP_GRADE = "TUTORIAL_HERO_UP_GRADE"

-- 魂师总览界面
function QUIDialogEatExpHeroOverView:ctor(options)
	local ccbFile = "ccb/Dialog_HeroOverview.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerBack", 				callback = handler(self, QUIDialogEatExpHeroOverView._onTriggerBack)},
		{ccbCallbackName = "onTriggerTabAll", 				callback = handler(self, QUIDialogEatExpHeroOverView._onTriggerTabAll)},
		{ccbCallbackName = "onTriggerTabMagic", 			callback = handler(self, QUIDialogEatExpHeroOverView._onTriggerTabMagic)},
		{ccbCallbackName = "onTriggerTabHaste", 			callback = handler(self, QUIDialogEatExpHeroOverView._onTriggerTabHaste)},
		{ccbCallbackName = "onTriggerTabPhysical", 			callback = handler(self, QUIDialogEatExpHeroOverView._onTriggerTabPhysical)},
		{ccbCallbackName = "onTriggerTabAttrition",			callback = handler(self, QUIDialogEatExpHeroOverView._onTriggerTabeAttrition)},
		{ccbCallbackName = "onTriggerOpenTeamArrangement",	callback = handler(self, QUIDialogEatExpHeroOverView._onTriggerOpenTeamArrangement)}

	}
	QUIDialogEatExpHeroOverView.super.ctor(self,ccbFile,callBacks,options)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()
	-- self:setLock(true)                    --注释原因：快捷途径跳转后，会返回到主界面  Date:2015-6-24  Author:xurui

	-- 初始化中间魂师页面滑动框
	self:_initHeroPageSwipe()

	--初始化事件监听器
	self._eventProxy = QNotificationCenter.new()

	self._haveHerosID = remote.herosUtil:getHaveHero()
	self._actorIds = self._haveHerosID

	if options ~= nil then 
		self._itemId = options.itemId
	end

	-- 初始化右边的tabs
	if options ~= nil and options.tab ~= nil then
		self:_selectTab(options.tab)
	else 
		self:_selectTab(QUIDialogEatExpHeroOverView.TAB_ALL)
	end

	self._isFrist = false
	self._isMove = false

	self._scrollPosYMin = 171.0
	self._scrollPosYMax = -226.0
	self._ccbOwner.sprite_scroll_bar:setOpacity(0)
	self._ccbOwner.sprite_scroll_cell:setOpacity(0)

	self._ccbOwner.label_liupai_description1:setVisible(false)
	self._ccbOwner.label_liupai_description2:setVisible(false)
end

function QUIDialogEatExpHeroOverView:viewDidAppear()
	QUIDialogEatExpHeroOverView.super.viewDidAppear(self)

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
	self:addBackEvent()
end

function QUIDialogEatExpHeroOverView:viewWillDisappear()
	QUIDialogEatExpHeroOverView.super.viewWillDisappear(self)

	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
	self:removeBackEvent()
end

-- 更新魂师数据
function QUIDialogEatExpHeroOverView:_onHeroDataUpdate()
	self._nativeActorIds = remote.herosUtil:getHaveHero()
	self._actorIds = self._nativeActorIds
	self:_filterHerosByTalent()
	self._haveHerosID = {}
	for _,actorId in pairs(self._actorIds) do
		local heroInfo = remote.herosUtil:getHeroByID(actorId)
		if heroInfo ~= nil then
			table.insert(self._haveHerosID, actorId)
		end
	end
end

function QUIDialogEatExpHeroOverView:runTo(actorId)
	if self._page ~= nil then
		return self._page:runTo(actorId)
	end
	return false
end

-- 处理各种touch event
function QUIDialogEatExpHeroOverView:onTouchEvent(event)
	if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    	self._page:endMove(event.distance.y)
  	elseif event.name == "began" then
		self._isMove = false
	    if self._page:getIsMove() == true then
            self._isMove = true
	    	self._page:stopMove()
    		self:setHeroFrameMoveState(false)	
	    end
  		self._startY = event.y
  		self._pageY = self._page:getView():getPositionY()
  		self._page:starMove()
    elseif event.name == "moved" then
    	local offsetY = self._pageY + event.y - self._startY
        if math.abs(event.y - self._startY) > 10 then
    		self:setHeroFrameMoveState(true)
            self._isMove = true
        end
		self._page:getView():setPositionY(offsetY)
    elseif event.name == "ended" then
    	self._timeHandler = scheduler.performWithDelayGlobal(function()
    			self:setHeroFrameMoveState(false)
    		end, 0)
    end
end

function QUIDialogEatExpHeroOverView:setHeroFrameMoveState(state)
	if next(self._page._heroFrames) then
		for i = 1, #self._page._heroFrames, 1 do
			self._page._heroFrames[i]:setMoveState(state)
		end
	end
end

-- 处理各种touch event
function QUIDialogEatExpHeroOverView:onEvent(event)
	if event == nil or event.name == nil then
        return
    end
end

--切换table后调用
function QUIDialogEatExpHeroOverView:_updateCurrentPage()
	self:_onHeroDataUpdate()

	if self._page == nil then
		self._page = QUIWidgetHeroOverview.new({rows = 2, lines = 3, hgap = 0, vgap = 0, offsetX = 33, offsetY = -5, cls = "QUIWidgetEatExpHeroFrame", itemId = self._itemId})
		self._pageContent:addChild(self._page:getView())
	end
	self._page:displayHeros(self._actorIds)
	self._page:onMove()
end

-- 初始化中间的魂师选择框 swipe工能
function QUIDialogEatExpHeroOverView:_initHeroPageSwipe()
	self._pageWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._pageHeight = self._ccbOwner.sheet_layout:getContentSize().height
	self._pageContent = CCNode:create()

	local layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._pageWidth,self._pageHeight)
	local ccclippingNode = CCClippingNode:create()
	layerColor:setPositionX(self._ccbOwner.sheet_layout:getPositionX())
	layerColor:setPositionY(self._ccbOwner.sheet_layout:getPositionY())
	ccclippingNode:setStencil(layerColor)
	ccclippingNode:addChild(self._pageContent)

	self._ccbOwner.sheet:addChild(ccclippingNode)
	
	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:attachToNode(self._ccbOwner.sheet,self._pageWidth, self._pageHeight, 0, -self._pageHeight, handler(self, self.onTouchEvent))

	self._isAnimRunning = false
end

-- filter 魂师根据魂师的天赋
function QUIDialogEatExpHeroOverView:_filterHerosByTalent()
	if self.tab == QUIDialogEatExpHeroOverView.TAB_ALL then
		-- 显示全部魂师不做任何filter
		return 
	end

	if self._actorIds ~= nil then
		local result = {}

		local db = QStaticDatabase:sharedDatabase()
		for i, actorId in pairs(self._actorIds) do
			local _, genre = db:getHeroGenreById(actorId)

			if self.tab == QUIDialogEatExpHeroOverView.TAB_MAGIC then
				if genre == 1 then
					result[#result + 1] = actorId
				end
			elseif self.tab == QUIDialogEatExpHeroOverView.TAB_HASTE then
				if genre == 2 then
					result[#result + 1] = actorId
				end
			elseif self.tab == QUIDialogEatExpHeroOverView.TAB_PHYSICAL then
				if genre == 3 then
					result[#result + 1] = actorId
				end
			elseif self.tab == QUIDialogEatExpHeroOverView.TAB_ATTRITION then
				if genre == 4 then
					result[#result + 1] = actorId
				end
			end
		end
		self._actorIds = result
		return 
	end
	return 
end
 
-- 选择tab
function QUIDialogEatExpHeroOverView:_selectTab(tab, isSound)
	if isSound == true then
		app.sound:playSound("common_switch")
	end
	self._ccbOwner.node_hero_tab_all:setHighlighted(false)
	self._ccbOwner.node_hero_tab_magic:setHighlighted(false)
	self._ccbOwner.node_hero_tab_haste:setHighlighted(false)
	self._ccbOwner.node_hero_tab_physical:setHighlighted(false)
	self._ccbOwner.node_hero_tab_attrition:setHighlighted(false)

	self._ccbOwner.node_hero_tab_all:setEnabled(true)
	self._ccbOwner.node_hero_tab_magic:setEnabled(true)
	self._ccbOwner.node_hero_tab_haste:setEnabled(true)
	self._ccbOwner.node_hero_tab_physical:setEnabled(true)
	self._ccbOwner.node_hero_tab_attrition:setEnabled(true)

	self.tab = tab
	if tab == QUIDialogEatExpHeroOverView.TAB_ALL then
		self._ccbOwner.node_hero_tab_all:setHighlighted(true)
		self._ccbOwner.node_hero_tab_all:setEnabled(false)
	elseif tab == QUIDialogEatExpHeroOverView.TAB_MAGIC then
		self._ccbOwner.node_hero_tab_magic:setHighlighted(true)
		self._ccbOwner.node_hero_tab_magic:setEnabled(false)
	elseif tab == QUIDialogEatExpHeroOverView.TAB_HASTE then
		self._ccbOwner.node_hero_tab_haste:setHighlighted(true)
		self._ccbOwner.node_hero_tab_haste:setEnabled(false)
	elseif tab == QUIDialogEatExpHeroOverView.TAB_PHYSICAL  then
		self._ccbOwner.node_hero_tab_physical:setHighlighted(true)
		self._ccbOwner.node_hero_tab_physical:setEnabled(false)
	elseif tab == QUIDialogEatExpHeroOverView.TAB_ATTRITION  then
		self._ccbOwner.node_hero_tab_attrition:setHighlighted(true)
		self._ccbOwner.node_hero_tab_attrition:setEnabled(false)
	end

	self._isFrist = true
	self:_updateCurrentPage()
	self._isFrist = false
end

-- Tab 全部
function QUIDialogEatExpHeroOverView:_onTriggerTabAll(tag, menuItem)
	if self.tab ~= QUIDialogEatExpHeroOverView.TAB_ALL then
		self:_selectTab(QUIDialogEatExpHeroOverView.TAB_ALL, true)
	end
end

-- 选择tab 法术流
function QUIDialogEatExpHeroOverView:_onTriggerTabMagic(tag, menuItem)
	if self.tab ~= QUIDialogEatExpHeroOverView.TAB_MAGIC then
		self:_selectTab(QUIDialogEatExpHeroOverView.TAB_MAGIC, true)
	end
end

-- 选择tab 急速流
function QUIDialogEatExpHeroOverView:_onTriggerTabHaste(tag, menuItem)
	if self.tab ~= QUIDialogEatExpHeroOverView.TAB_HASTE then
		self:_selectTab(QUIDialogEatExpHeroOverView.TAB_HASTE, true)
	end
end

-- 选择tab 物理流
function QUIDialogEatExpHeroOverView:_onTriggerTabPhysical(tag, menuItem)
	if self.tab ~= QUIDialogEatExpHeroOverView.TAB_PHYSICAL then
		self:_selectTab(QUIDialogEatExpHeroOverView.TAB_PHYSICAL, true)
	end
end

-- 选择tab 恢复流
function QUIDialogEatExpHeroOverView:_onTriggerTabeAttrition(tag, menuItem)
	if self.tab ~= QUIDialogEatExpHeroOverView.TAB_ATTRITION then
		self:_selectTab(QUIDialogEatExpHeroOverView.TAB_ATTRITION, true)
	end
end

function QUIDialogEatExpHeroOverView:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogEatExpHeroOverView:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

-- 对话框退出
function QUIDialogEatExpHeroOverView:_onTriggerBack(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogEatExpHeroOverView:_onTriggerHome(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogEatExpHeroOverView:_resetPageIndex()
	self._pageJump:pageAt(self.displayTotalDisplayFramePageCount, self.displayFramePageIndex)
end

return QUIDialogEatExpHeroOverView
