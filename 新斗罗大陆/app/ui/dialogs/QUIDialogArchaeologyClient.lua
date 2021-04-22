--
-- Author: Kumo
-- Date: Mon Feb 29 15:20:10 2016
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArchaeologyClient = class("QUIDialogArchaeologyClient", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetArchaeologyMap = import("..widgets.QUIWidgetArchaeologyMap")
local QUIWidgetArchaeologyTitle = import("..widgets.QUIWidgetArchaeologyTitle")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QScrollView = import("...views.QScrollView")
local QUIViewController = import("..QUIViewController")
local QUIDialogAwardsAlert = import(".QUIDialogAwardsAlert")
local QUIDialogAwardsChoose = import(".QUIDialogAwardsChoose")
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")
-- local QUIWidgetInstanceProgress = import("..widgets.QUIWidgetInstanceProgress")

QUIDialogArchaeologyClient.NORMAL_SHOW = "NORMAL_SHOW"	--直接跳转到可以激活的关卡地图
QUIDialogArchaeologyClient.REWARD_SHOW = "REWARD_SHOW"	--直接跳转到最早一个可以领取魂师碎片却还未领取的关卡地图
QUIDialogArchaeologyClient.MAP_ID_SHOW = "MAP_ID_SHOW"	--直接跳转到指定mapID的地图，若该地图有可领取的碎片，弹出界面。

function QUIDialogArchaeologyClient:ctor(options)
	local ccbFile = "ccb/Dialog_ArchaeologyClient.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIDialogArchaeologyClient._onMapTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, QUIDialogArchaeologyClient._onMapTriggerRight)},
		{ccbCallbackName = "onTriggerShowBuff", callback = handler(self, QUIDialogArchaeologyClient._onTriggerShowBuff)},
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, QUIDialogArchaeologyClient._onTriggerBuy)},
		{ccbCallbackName = "onTriggerFragment1", callback = handler(self, QUIDialogArchaeologyClient._onTriggerFragment)},
		{ccbCallbackName = "onTriggerFragment2", callback = handler(self, QUIDialogArchaeologyClient._onTriggerFragment)},
		{ccbCallbackName = "onTriggerFragment3", callback = handler(self, QUIDialogArchaeologyClient._onTriggerFragment)},
		{ccbCallbackName = "onTriggerFragment4", callback = handler(self, QUIDialogArchaeologyClient._onTriggerFragment)},
		{ccbCallbackName = "onTriggerFragment5", callback = handler(self, QUIDialogArchaeologyClient._onTriggerFragment)}
	}
	
	QUIDialogArchaeologyClient.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
	-- page:setScalingVisible(false)
	page.topBar:showWithArchaeology()

    CalculateUIBgSize(self._ccbOwner.sp_bg)
    
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._options = options
	self._initShowType = options.initShowType or QUIDialogArchaeologyClient.REWARD_SHOW
	self:_madeMapTouchLayer()

	self:_init()
end

function QUIDialogArchaeologyClient:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogArchaeologyClient:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogArchaeologyClient:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogArchaeologyClient:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogArchaeologyClient:viewDidAppear()
	QUIDialogArchaeologyClient.super.viewDidAppear(self)
	self:addBackEvent()
	self:_enableTouchLayer()
	self:_showStarRain()
end

function QUIDialogArchaeologyClient:viewWillDisappear()
	QUIDialogArchaeologyClient.super.viewWillDisappear(self)
	self:removeBackEvent()
	self:_disableTouchLayer()

	for _, value in pairs(self._titleTbl) do
		value:removeAllEventListeners()
	end

	if self._currentPage then
		self._currentPage:removeAllEventListeners()
	end

	if self._archaeologyCardChoose then
		self._archaeologyCardChoose:removeAllEventListeners()
	end
end

function QUIDialogArchaeologyClient:_madeMapTouchLayer()
	self._mapSize = self._ccbOwner.map_size:getContentSize()
	self._mapSizePosition = ccp(self._ccbOwner.map_size:getPosition())
	self._mapContent = self._ccbOwner.map_content

	local layerColor = CCLayerColor:create(ccc4(0,0,0,150), self._mapSize.width, self._mapSize.height)
	local ccclippingNode = CCClippingNode:create()
	layerColor:setPosition(self._mapSizePosition)
	ccclippingNode:setStencil(layerColor)

	self._mapContent:removeFromParent()

	ccclippingNode:addChild(self._mapContent)
	self._ccbOwner.map_size:getParent():addChild(ccclippingNode)
end

function QUIDialogArchaeologyClient:_enableTouchLayer()
	self._mapTouchLayer = QUIGestureRecognizer.new()
	self._mapTouchLayer:attachToNode(self._mapContent:getParent(), self._mapSize.width, self._mapSize.height, 0, -self._mapSize.height,  handler(self, self._onMapTouchEvent))
	if self._mapTouchLayer ~= nil then
		self._mapTouchLayer:enable()
		self._mapTouchLayer:setAttachSlide(true)
	  	self._mapTouchLayer:addEventListener(QUIGestureRecognizer.EVENT_SWIPE_GESTURE, handler(self, self._onMapTouchEvent))
	end
end

function QUIDialogArchaeologyClient:_disableTouchLayer()
	if self._mapTouchLayer ~= nil then
		self._mapTouchLayer:removeAllEventListeners()
		self._mapTouchLayer:disable()
	  	self._mapTouchLayer:detach()
		self._mapTouchLayer = nil
	end
end

function QUIDialogArchaeologyClient:_onMapTouchEvent(event)
	local direction = event.direction
	if event.name == QUIGestureRecognizer.EVENT_SWIPE_GESTURE then
		if direction == QUIGestureRecognizer.SWIPE_RIGHT or direction == QUIGestureRecognizer.SWIPE_RIGHT_UP or direction == QUIGestureRecognizer.SWIPE_RIGHT_DOWN then
			self:_onMapTriggerLeft()
		elseif direction == QUIGestureRecognizer.SWIPE_LEFT or direction == QUIGestureRecognizer.SWIPE_LEFT_UP or direction == QUIGestureRecognizer.SWIPE_LEFT_DOWN then
			self:_onMapTriggerRight()
		end
	end
end

function QUIDialogArchaeologyClient:_onMapTriggerLeft()
	if self._isMapMoving == true then return end
	local curID = remote.archaeology:getCurrentMapID()
	if curID > 1 then
		app.sound:playSound("common_change")
		self._nextMapID = curID - 1
		self:_showMap(true)
	end
end

function QUIDialogArchaeologyClient:_onMapTriggerRight()
	if self._isMapMoving == true then return end
	local lastID = remote.archaeology:getLastMapID()
	local curID = remote.archaeology:getCurrentMapID()
	if curID < lastID then
		app.sound:playSound("common_change")
		self._nextMapID = curID + 1
		self:_showMap(true)
	end
end

function QUIDialogArchaeologyClient:_onTriggerShowBuff()
    app.sound:playSound("common_small")
	app:getClient():archaeologyInfoRequest(function(response)
		remote.archaeology:responseHandler(response)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArchaeologyBuff"}, {isPopCurrentDialog = true})
		end)
end

function QUIDialogArchaeologyClient:_init()
	self._isMapMoving = false
	self._isTitleMoving = false

	--[[
		锁定设置。
		当开始点亮考古碎片的时候，开始锁定！直到整个考古点亮流程完成解锁，或，点亮失败解锁。
		锁定期间，冻结【地图变更】【再次点亮】
	]]
	self:_unlock()

	self._totalTitleWidth = 50
	self._nameAni = "Default Timeline"

    self._titleTbl = {}

    app:getClient():archaeologyInfoRequest(self:safeHandler(function(response)
    	remote.archaeology:responseHandler(response)
    	self:_updateStatus()
    	self:_updateProgress()
    end))

    local mapID
	if self._initShowType == QUIDialogArchaeologyClient.REWARD_SHOW then
		local fragmentID = remote.archaeology:getFirstRewardID()
		if fragmentID then
			self._needChooseFragmentID = fragmentID
			local info = remote.archaeology:getFragmentInfoByID(fragmentID)
			mapID = info.map_id
		else
			mapID = remote.archaeology:getLastNeedEnableMapID()
		end
	elseif self._initShowType == QUIDialogArchaeologyClient.MAP_ID_SHOW then
		mapID = self._options.mapID or remote.archaeology:getLastNeedEnableMapID()
	else
		mapID = remote.archaeology:getLastNeedEnableMapID()
	end
	remote.archaeology:setCurrentMapID(mapID)

	self:initBtnListView()
	self:_showMap(true)
    self:refreshCurrentItem()
end

function QUIDialogArchaeologyClient:initBtnListView(  )
	local lastMapID = remote.archaeology:getLastMapID()
    if nil == self._btnListView then
    	local clickBtnItemHandler = handler(self, self._clickBtnHandler)
	    
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = index
	            if not item then
	                item = QUIWidgetArchaeologyTitle.new()
	                self._oneTitleWidth  = item:getWidth()
	                isCacheNode = false
	            end
	            item:setMapID(data)
	            info.item = item
	            info.size = item._ccbOwner.btn:getContentSize()

            	list:registerBtnHandler(index,"btn", clickBtnItemHandler)
	            return isCacheNode
	        end,
	        isVertical = false,
	        totalNumber = lastMapID,
	    }  
	    self._btnListView = QListView.new(self._ccbOwner.titleSheet,cfg)
	else
		self._btnListView:reload({totalNumber = lastMapID})
	end
end

function QUIDialogArchaeologyClient:_clickBtnHandler(x, y, touchNode, listView)
    app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    self:_onEvent({name = QUIWidgetArchaeologyTitle.EVENT_CLICK, mapID = touchIndex})
end

function QUIDialogArchaeologyClient:refreshCurrentItem()
	local currentMapID = remote.archaeology:getCurrentMapID()
    local oldItem
    if self._oldMapID then
    	oldItem = self._btnListView:getItemByIndex(self._oldMapID)
    end
    self._oldMapID = currentMapID
    local item = self._btnListView:getItemByIndex(currentMapID)
    if item then
    	item:select(true)
    end
    if oldItem then
    	oldItem:select(false)
    end
end

function QUIDialogArchaeologyClient:_titleSelected( event )
	-- printTable(event)
	self._nextMapID = event.mapID
	self:_showMap(true)
end

function QUIDialogArchaeologyClient:_showMap(isAutoMove)
	if self._isMapMoving or self._isLocking then return end

	local currentMapID = remote.archaeology:getCurrentMapID()
	if not self._currentPage then
		-- 初始化
		self._currentPage = self:_selectedMapByID( currentMapID )
		self._mapContent:addChild(self._currentPage)
		self:_updateArrow()
		self:_updateStatus()
		self:_updateProgress()

		if self._initShowType == QUIDialogArchaeologyClient.REWARD_SHOW then
			if self._needChooseFragmentID and not self._scheduler then
				self._scheduler = scheduler.performWithDelayGlobal(function ()
					local info = remote.archaeology:getFragmentInfoByID(self._needChooseFragmentID)
					local reward_index = info.reward_index
					self:_showCardChoose(self._needChooseFragmentID, reward_index)
					if self._scheduler then
						scheduler.unscheduleGlobal(self._scheduler)
						self._scheduler = nil
					end
				end, 0)
			end
		end
	else
		if not remote.archaeology:getMapInfoByID( self._nextMapID ) then
			return
		end
		if self._nextMapID == currentMapID then return end

		self:_removePageAction()

		self._nextPage = self:_selectedMapByID( self._nextMapID )

		if currentMapID < self._nextMapID then
			self._nextPage:setPositionX( self._mapSize.width )
		else
			self._nextPage:setPositionX( - self._mapSize.width )
		end
		self._mapContent:addChild(self._nextPage)
		self:_movePage()
	end
	if isAutoMove then
		self:_updateTitle(currentMapID, self._nextMapID)
	end
end

--[[
	一共左右2页，第一页显示不下就切到第二页，反之，当第一页可以显示下，就切到第一页
]]
function QUIDialogArchaeologyClient:_updateTitle( curMapID, nextMapID )
	local index = 1
	if nextMapID then
		index = nextMapID
	else
		index = curMapID
	end
	index = index - 4
	if index <= 0 then
		index = 1
	end
	self._btnListView:startScrollToIndex(index, false, 1000)
end

function QUIDialogArchaeologyClient:_selectedMapByID( mapID )
	return QUIWidgetArchaeologyMap.new( {mapID = mapID})
end

function QUIDialogArchaeologyClient:_movePage()
	self._isMapMoving = true

	local offsetX = - self._nextPage:getPositionX()
	self._nextActionHandler = self:_nodeRunAction(self._nextPage, offsetX, 0)
	self._currActionHandler = self:_nodeRunAction(self._currentPage, offsetX, 0, function ()
		self:_removePageAction()
	end)
end

-- 移动到指定位置
function QUIDialogArchaeologyClient:_nodeRunAction(node, posX, posY, callFunc)
	local actionArrayIn = CCArray:create()
	actionArrayIn:addObject(CCMoveBy:create(0.3, ccp(posX, posY)))
	actionArrayIn:addObject(CCCallFunc:create(function () if callFunc ~= nil then callFunc() end end))
	local ccsequence = CCSequence:create(actionArrayIn)
	return node:runAction(ccsequence)
end

function QUIDialogArchaeologyClient:_removePage( page )
	if page ~= nil then
		page:removeFromParent()
	end
end

function QUIDialogArchaeologyClient:_removePageAction()
	if self._currActionHandler ~= nil then
		self._currentPage:stopAction(self._currActionHandler)
		self._currActionHandler = nil
		self._currentPage:removeFromParent()
	end
	if self._nextActionHandler ~= nil then
		self._nextPage:stopAction(self._nextActionHandler)
		self._nextActionHandler = nil
		self._currentPage = self._nextPage
		remote.archaeology:setCurrentMapID(self._nextMapID)
		self._nextPage = nil
		self._nextMapID = 0
	end

	-- for _, widget in pairs(self._titleTbl) do
	-- 	widget:update()
	-- end
    self:refreshCurrentItem()

	self:_updateArrow()
	self:_updateStatus()
	self:_updateProgress()
	self._isMapMoving = false
end

function QUIDialogArchaeologyClient:_enableSuccessed()
	self._currentPage:addEventListener(QUIWidgetArchaeologyMap.EVENT_ENABLE_COMPLETE, handler(self, self._onEvent))
	self._currentPage:enableFragmentByID()	
end

function QUIDialogArchaeologyClient:_showBuffEffect( int )
	local pos, ccbFile = remote.archaeology:getShowBuffURL( int )
	local effectShow = QUIWidgetAnimationPlayer.new()
	self:getView():addChild(effectShow)
	--effectShow:setPosition(ccp(display.width/2, display.height/2))

	local dstPos = self._ccbOwner.btn_showBuff:convertToWorldSpace(ccp(-display.width/2, -display.height/2))
	dstPos.x = dstPos.x + 50
	dstPos.y = dstPos.y + 50

	local effectFun1 = function()
		effectShow:playAnimation(ccbFile, function(ccbOwner)
			local lastID = remote.archaeology:getLastEnableFragmentID()
			local currentMapID = remote.archaeology:getCurrentMapID()
			local buff = remote.archaeology:getFragmentBuffNameAndValueByID(lastID, currentMapID)
			ccbOwner.buff_icon:setPosition(dstPos)

			local arr1 = CCArray:create()
			arr1:addObject(CCMoveTo:create(0.2, dstPos))
			arr1:addObject(CCScaleTo:create(0.2, 0.4))
			local arr = CCArray:create()
		    arr:addObject(CCDelayTime:create(1.6))
		    arr:addObject(CCSpawn:create(arr1))
		    arr:addObject(CCScaleTo:create(0.01, 0))
			ccbOwner.node_buff:runAction(CCSequence:create(arr))

			local i = 1
			for name, value in pairs(buff) do
				if ccbOwner["text_buff_"..i] then
					if ccbOwner["di_"..i] then
						ccbOwner["di_"..i]:setVisible(true)
					end
					if value < 1 then
						value = "+"..(value*100).."%"
					else
						value = "+"..value
					end
					ccbOwner["text_buff_"..i]:setString(name..value)
					i = i + 1
				else
					break
				end
			end

			while true do
				if ccbOwner["di_"..i] then
					ccbOwner["di_"..i]:setVisible(false)
					ccbOwner["text_buff_"..i]:setString("")
					i = i + 1
				else
					break
				end
			end
		end, function()
			self:_unlock()
			local currentMapID = remote.archaeology:getCurrentMapID()
			local lastNeedEnableMapID = remote.archaeology:getLastNeedEnableMapID()
			if currentMapID ~= lastNeedEnableMapID then
				self:_onMapTriggerRight()
			end
		end)
	end

	local effectFun2 = function()
		effectShow:playAnimation(ccbFile, function(ccbOwner)
			local lastID = remote.archaeology:getLastEnableFragmentID()
			local currentMapID = remote.archaeology:getCurrentMapID()
			local buff = remote.archaeology:getFragmentBuffNameAndValueByID(lastID, currentMapID)
			ccbOwner.buff_icon:setPosition(dstPos)

			local arr1 = CCArray:create()
			arr1:addObject(CCMoveTo:create(0.2, dstPos))
			arr1:addObject(CCScaleTo:create(0.2, 0.4))
			local arr = CCArray:create()
		    arr:addObject(CCDelayTime:create(1.6))
		    arr:addObject(CCSpawn:create(arr1))
		    arr:addObject(CCScaleTo:create(0.01, 0))
			ccbOwner.node_buff:runAction(CCSequence:create(arr))
			
			local i = 1
			for name, value in pairs(buff) do
				if ccbOwner["text_buff_"..i] then
					if ccbOwner["di_"..i] then
						ccbOwner["di_"..i]:setVisible(true)
					end
					local str = ""
					if string.find(name, "加伤") then
						str = "斗魂场、海神岛、大魂师赛等玩家对战玩法中，伤害增加"..(value*100).."%"
					elseif string.find(name, "减伤") then
						str = "斗魂场、海神岛、大魂师赛等玩家对战玩法中，伤害降低"..(value*100).."%"
					end
					ccbOwner["text_buff_"..i]:setString(str)
					i = i + 1
					break
				else
					break
				end
			end

			while true do
				if ccbOwner["di_"..i] then
					ccbOwner["di_"..i]:setVisible(false)
					ccbOwner["text_buff_"..i]:setString("")
					i = i + 1
				else
					break
				end
			end
		end, function()
			self:_unlock()
			local currentMapID = remote.archaeology:getCurrentMapID()
			local lastNeedEnableMapID = remote.archaeology:getLastNeedEnableMapID()
			if currentMapID ~= lastNeedEnableMapID then
				self:_onMapTriggerRight()
			end
		end)
	end

	if int == 2 then
		effectFun2()
	else
		effectFun1()
	end
end

--[[
	archaeologyId = int, award_index = str
]]
function QUIDialogArchaeologyClient:_showCardChoose( int, str )
	-- print("[Kumo] _showCardChoose ", int, str)
	self._archaeologyCardChoose = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsChoose", 
		options = {archaeologyId = int, award_index = str}}, {isPopCurrentDialog = false} )
	self._archaeologyCardChoose:addEventListener(QUIDialogAwardsChoose.EVENT_CHOOSE, handler(self, QUIDialogArchaeologyClient._onEvent))
	self._archaeologyCardChoose:addEventListener(QUIDialogAwardsChoose.EVENT_NO_CHOOSE, handler(self, QUIDialogArchaeologyClient._onEvent))
end

function QUIDialogArchaeologyClient:_showAwards( luckyDrawData, id )
	-- 播放获得物品
	if luckyDrawData ~= nil and luckyDrawData.prizes ~= nil then
		local awards = {}
		for _,value in ipairs(luckyDrawData.prizes) do
			table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
		end

		self._archaeologyAwardsAlert = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", options = {awards = awards, id = id,
			callBack = function (id)
			local lastID = remote.archaeology:getLastEnableFragmentID()
			if lastID == id then
				self:_unlock()
				local currentMapID = remote.archaeology:getCurrentMapID()
				local lastNeedEnableMapID = remote.archaeology:getLastNeedEnableMapID()
				if currentMapID ~= lastNeedEnableMapID then
					self:_onMapTriggerRight()
				end
			else
				self._currentPage:updateRedFlagInfo()
			end
			end}}, {isPopCurrentDialog = false} )

		self._archaeologyAwardsAlert:setTitle("恭喜您获得斗罗武魂奖励")
		if luckyDrawData.items ~= nil then
			remote.items:setItems(luckyDrawData.items)
		end
	end
end

function QUIDialogArchaeologyClient:_updateArrow()
	local currentMapID = remote.archaeology:getCurrentMapID()
	local lastMapID = remote.archaeology:getLastMapID()
	if currentMapID == 1 then
		self._ccbOwner.arrowLeft:setVisible(false)
	elseif currentMapID == lastMapID then
		self._ccbOwner.arrowRight:setVisible(false)
	else
		self._ccbOwner.arrowLeft:setVisible(true)
		self._ccbOwner.arrowRight:setVisible(true)
	end
end

function QUIDialogArchaeologyClient:_updateStatus()
	if remote.archaeology:isAllEnable() then
		self._ccbOwner.status_buy:setVisible(false)
		self._ccbOwner.status_text:setVisible(true)
		self._ccbOwner.activated:setVisible(true)
		self._ccbOwner.not_activated:setVisible(false)
		return
	end

	local lastNeedEnableMapID = remote.archaeology:getLastNeedEnableMapID()
	local currentMapID = remote.archaeology:getCurrentMapID()
	if currentMapID == lastNeedEnableMapID then
		self._ccbOwner.status_buy:setVisible(true)
		self._ccbOwner.status_text:setVisible(false)
		local money = remote.archaeology:getArchaeologyMoney()
		local cost = remote.archaeology:getEnableCost()

		if tonumber(money) >= tonumber(cost) then
			self._ccbOwner.tf_price:setColor(COLORS.v)
		else
			self._ccbOwner.tf_price:setColor(ccc3(255, 0, 0))
		end
		
		self._ccbOwner.tf_price:setString( money .. " / " .. cost )
		self._ccbOwner.tf_price:setVisible(true)
	else
		self._ccbOwner.status_buy:setVisible(false)
		self._ccbOwner.status_text:setVisible(true)
		if currentMapID < lastNeedEnableMapID then
			self._ccbOwner.activated:setVisible(true)
			self._ccbOwner.not_activated:setVisible(false)
		else
			self._ccbOwner.activated:setVisible(false)
			self._ccbOwner.not_activated:setVisible(true)
		end
	end
end

function QUIDialogArchaeologyClient:_updateProgress()
	local isAllEnable = remote.archaeology:isAllEnable()

	if isAllEnable then
		local lastMapID = remote.archaeology:getLastMapID()
		self._ccbOwner.tf_enableNum:setString(lastMapID)
		local color = nil
		if lastMapID < 2 then
			color = QIDEA_QUALITY_COLOR.WHITE
		elseif lastMapID < 7 then
			color = QIDEA_QUALITY_COLOR.GREEN
		elseif lastMapID < 10 then
			color = QIDEA_QUALITY_COLOR.PURPLE
		else
			color = QIDEA_QUALITY_COLOR.ORANGE
		end
		self._ccbOwner.tf_enableNum:setColor( color )
	else
		local lastNeedEnableMapID = remote.archaeology:getLastNeedEnableMapID()
		local cur = 0
		if lastNeedEnableMapID == 0 then
			cur = 0
		else
			cur = lastNeedEnableMapID - 1
		end
		self._ccbOwner.tf_enableNum:setString(cur)
		local color = nil
		if cur < 2 then
			color = QIDEA_QUALITY_COLOR.WHITE
		elseif cur < 7 then
			color = QIDEA_QUALITY_COLOR.GREEN
		elseif cur < 10 then
			color = QIDEA_QUALITY_COLOR.PURPLE
		else
			color = QIDEA_QUALITY_COLOR.ORANGE
		end
		self._ccbOwner.tf_enableNum:setColor( color )
	end
end

function QUIDialogArchaeologyClient:_showStarRain()
	local ccbFile = remote.archaeology:getStarRainURL()
	local proxy = CCBProxy:create()
	local aniCcbOwner = {}
	local aniCcbView = CCBuilderReaderLoad(ccbFile, proxy, aniCcbOwner)
	self._ccbOwner.map_content:addChild(aniCcbView, -1)
end

function QUIDialogArchaeologyClient:_lock()
	if self._isLocking then return end

	self._isLocking = true
	self._ccbOwner.arrowLeft:setVisible(false)
	self._ccbOwner.arrowRight:setVisible(false)
	makeNodeFromNormalToGray(self._ccbOwner.btn_buy)
	makeNodeFromNormalToGray(self._ccbOwner.tf_buy)
	self._ccbOwner.btn_buy:setEnabled(false)
	self._ccbOwner.tf_buy:disableOutline() 
end

function QUIDialogArchaeologyClient:_unlock()
	if not self._isLocking then return end

	self._isLocking = false
	self._ccbOwner.arrowLeft:setVisible(true)
	self._ccbOwner.arrowRight:setVisible(true)
	self:_updateArrow()
	makeNodeFromGrayToNormal(self._ccbOwner.btn_buy)
	makeNodeFromGrayToNormal(self._ccbOwner.tf_buy)
	self._ccbOwner.btn_buy:setEnabled(true)
	self._ccbOwner.tf_buy:enableOutline() 
end

function QUIDialogArchaeologyClient:_onTriggerBuy(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_buy) == false then return end
	if self._isLocking or self._isMapMoving then return end
    app.sound:playSound("common_small")

	if remote.archaeology:isAllEnable() then
		app:alert({content="恭喜你已完成了全部考古内容！", title="考古毕业"})
		return
	end

	local needMapID = remote.archaeology:getLastNeedEnableMapID()
	local currentMapID = remote.archaeology:getCurrentMapID()
	if currentMapID ~= needMapID then
		self._nextMapID = needMapID
		self:_showMap(true)
	end

	local money = remote.archaeology:getArchaeologyMoney()
	local cost = remote.archaeology:getEnableCost()
	if money < cost then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.ARCHAEOLOGY_MONEY)
		return
	end

	self:_lock()

	app:getClient():archaeologyEnableFragmentRequest(function(response)
			remote.archaeology:responseHandler(response)
			self:_updateStatus()
			self:_enableSuccessed()
			remote.herosUtil:updateHeros(remote.herosUtil.heros)
        	remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
		end, function()
			self:_unlock()
		end)
end

function QUIDialogArchaeologyClient:_onTriggerFragment(event, target)
	if self._isMapMoving then return end
    app.sound:playSound("common_small")

	local mapID = remote.archaeology:getCurrentMapID()
	local mapInfo = remote.archaeology:getMapInfoByID(mapID)
	local index = 0
	for i = 1, #mapInfo, 1 do
		if target == self._ccbOwner["btn_fragment_"..i] then
			index = i
		end
	end

	if index > 0 then
		self._currentPage:addEventListener(QUIWidgetArchaeologyMap.EVENT_SHOW_CHOOSE, handler(self, self._onEvent))
		self._currentPage:clickFragmentByIndex(index)
		
	end
end

function QUIDialogArchaeologyClient:_onEvent( event, target )
	if self._isMoving == true then return end

	if event.name == QUIWidgetArchaeologyTitle.EVENT_CLICK then
		self._nextMapID = event.mapID
		self:_showMap(true)
		-- event.target:removeEventListener(event.name)
		return
	end
	
	if event.name == QUIWidgetArchaeologyMap.EVENT_ENABLE_COMPLETE then
		local lastID = remote.archaeology:getLastEnableFragmentID()
		local tbl = remote.archaeology:getFragmentBuffNameAndValueByID(lastID)
		if table.nums(tbl) == 0 then
			local info = remote.archaeology:getFragmentInfoByID(lastID)
			local reward_index = info.reward_index
			self:_showCardChoose(lastID, reward_index)
		else
			local index = remote.archaeology:getLastEnableIndexByID(lastID)
			if index == 5 then
				self:_showBuffEffect(2)
			else
				self:_showBuffEffect(1)
			end
		end
		event.target:removeEventListener(event.name)
		return
	end

	if event.name == QUIWidgetArchaeologyMap.EVENT_SHOW_CHOOSE then
		local info = remote.archaeology:getFragmentInfoByID(event.fragmentID)
		local rewardIndex = info.reward_index
		self:_showCardChoose(event.fragmentID, rewardIndex)
		event.target:removeEventListener(event.name)
		return
	end

	if event.name == QUIDialogAwardsChoose.EVENT_CHOOSE then
		app:getClient():archaeologyGetLuckyDrawRequest(event.archaeologyId, event.itemId, function( response )
			remote.archaeology:responseHandler(response)
			self:_showAwards( response.archaeologyGetLuckyDrawResponse.luckyDraw, event.archaeologyId )
		end)
		if self._archaeologyCardChoose then
			self._archaeologyCardChoose:removeEventListener(event.name)
			self._archaeologyCardChoose = nil
		end
		return
	end

	if event.name == QUIDialogAwardsChoose.EVENT_NO_CHOOSE then
		local lastID = remote.archaeology:getLastEnableFragmentID()

		if lastID == event.archaeologyId then
			self:_unlock()
			local currentMapID = remote.archaeology:getCurrentMapID()
			local lastNeedEnableMapID = remote.archaeology:getLastNeedEnableMapID()
			if currentMapID ~= lastNeedEnableMapID then
				self:_onMapTriggerRight()
			end
		end
		if self._archaeologyCardChoose then
			self._archaeologyCardChoose:removeEventListener(event.name)
			self._archaeologyCardChoose = nil
		end
		return
	end
end

function QUIDialogArchaeologyClient:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogArchaeologyClient:_onScrollViewBegan()
	self._isMoving = false
end

return QUIDialogArchaeologyClient