--
-- Author: wkwang
-- Date: 2014-11-24 11:35:03
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAchievement = class("QUIDialogAchievement", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetAchievementItem = import("..widgets.QUIWidgetAchievementItem")
local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetSelectBtn = import("..widgets.QUIWidgetSelectBtn")
local QScrollView = import("...views.QScrollView") 
local QListView = import("...views.QListView")

QUIDialogAchievement.MAX_SHOW_NUM = 5

function QUIDialogAchievement:ctor(options)
	local ccbFile = "ccb/Dialog_Achievement.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTabDefault", 				callback = handler(self, self._onTriggerTabDefault)},
		{ccbCallbackName = "onTriggerTabHero", 					callback = handler(self, self._onTriggerTabHero)},
		{ccbCallbackName = "onTriggerTabInstance", 				callback = handler(self, self._onTriggerTabInstance)},
		{ccbCallbackName = "onTriggerTabArena", 				callback = handler(self, self._onTriggerTabArena)},
		{ccbCallbackName = "onTriggerTabOther", 				callback = handler(self, self._onTriggerTabOther)},
        {ccbCallbackName = "onTriggerOneGet", 					callback = handler(self, self._onTriggerOneGet)},
        {ccbCallbackName = "onTriggerAchievemenCollege",		callback = handler(self, self._onTriggerAchievemenCollege)},
	}
	QUIDialogAchievement.super.ctor(self,ccbFile,callBacks,options)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()

	self._itemBoxAniamtion = false

	q.setButtonEnableShadow(self._ccbOwner.btn_achievement)

	-- 初始化页面滑动框和遮罩层
	self._achieveBox = {}
	self._items = {}
	self._allItems = {}
	local btnList = {
		{id = 1, btnName = "推 荐", achieveType = remote.achieve.DEFAULT},
		{id = 2, btnName = "魂 师", achieveType = remote.achieve.TYPE_HERO},
		{id = 3, btnName = "副 本", achieveType = remote.achieve.TYPE_INSTANCE},
		{id = 4, btnName = "斗魂场", achieveType = remote.achieve.TYPE_ARENA},
		{id = 5, btnName = "其 他", achieveType = remote.achieve.TYPE_USER},
	}
	self._btnList = btnList
	self._ccbOwner.frame_tf_title:setString("成   就")
	self:_initPageSwipe()

	remote.achievementCollege:getMyInfoCollection(function( )
		if self:safeCheck() then
			local redTips = remote.achievementCollege:checkEntranceRedTips()
			self._ccbOwner.sp_achiement_red_tips:setVisible(redTips)
		end
	end)
end

function QUIDialogAchievement:viewDidAppear()
	QUIDialogAchievement.super.viewDidAppear(self)

    self._achieveProxy = cc.EventProxy.new(remote.achieve)
    self._achieveProxy:addEventListener(remote.achieve.EVENT_UPDATE, handler(self, self._achievementsInfoUpdate))

	self:addBackEvent()

	self:showOrHideBtnOne()
end

function QUIDialogAchievement:showOrHideBtnOne()
	if not app.unlock:checkLock("UNLOCK_TASKS_YIJIANLINGQU", false) then
		self._ccbOwner.btn_one:setVisible(false)
	else
		local oneItems = remote.achieve:getAllAchieveList()
		if next(oneItems) ~= nil then
			self._ccbOwner.btn_one:setVisible(true)
			self._ccbOwner.node_one_effect:setVisible(not app:getUserData():getValueForKey("UNLOCK_TASKS_YIJIANLINGQU"..remote.user.userId))
		else
			self._ccbOwner.btn_one:setVisible(false)
		end
	end
end

function QUIDialogAchievement:viewWillDisappear()
  	QUIDialogAchievement.super.viewWillDisappear(self)

    self._achieveProxy:removeAllEventListeners()
	self:removeBackEvent()
	self:_removeAction(self._itemContent)

	if self._checkItemScheduler ~= nil then
		scheduler.unscheduleGlobal(self._checkItemScheduler)
		self._checkItemScheduler = nil
	end

	if self._timeScheduler1 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler1)
		self._timeScheduler1 = nil
	end

	if self._timeScheduler2 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler2)
		self._timeScheduler2 = nil
	end
end

function QUIDialogAchievement:_initPageSwipe()
	self._itemWidth = self._ccbOwner.sheet_content:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_content:getContentSize().height

 	local achieveType = remote.achieve.DEFAULT
	for i, v in pairs(self._btnList) do
		local isTips = remote.achieve:checkAchieveDoneForType(v.achieveType)
		if isTips then
			achieveType = v.achieveType
			break
		end
	end
	self._tab = nil
	self:_selectTab(achieveType)
end

function QUIDialogAchievement:initBtnListView()
	for i, v in pairs(self._btnList) do
		v.isSelected = self._tab == v.achieveType
		v.isTips = remote.achieve:checkAchieveDoneForType(v.achieveType)
	end
	-- body
	if not self._btnlistViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._btnList[index]
	            local item = list:getItemFromCache()
	            if not item then
            		item = QUIWidgetSelectBtn.new()
            		item:addEventListener(QUIWidgetSelectBtn.EVENT_CLICK, handler(self, self.btnItemClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()
                list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
	            return isCacheNode
	        end,
	        curOriginOffset = 5,
	        curOffset = 10,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 5,
	        totalNumber = #self._btnList,
		}
		self._btnlistViewLayout = QListView.new(self._ccbOwner.sheet_menu,cfg)
	else
		self._btnlistViewLayout:reload({totalNumber = #self._btnList})
	end
end

function QUIDialogAchievement:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._items[index]
	            local item = list:getItemFromCache()
	            if not item then
            		item = QUIWidgetAchievementItem.new()
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()
                list:registerBtnHandler(index,"btn_get", handler(self, self.itemClickHandler), nil, "true")

	            return isCacheNode
	        end,
	        curOriginOffset = 6,
	        contentOffsetX = 5,
	        curOffset = 5,
	        enableShadow = true,
	      	ignoreCanDrag = true,
	      	spaceY = -2,
	        totalNumber = #self._items,
	        contentOffsetX = 10 ,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_content,cfg)
	else
		self._listViewLayout:reload({totalNumber = #self._items})
	end
end

--@date 2015/6/9 不显示按钮上已完成和总数 @钱萌萌 
-- function QUIDialogAchievement:achievementUiUpdate()
	-- self._ccbOwner.tf_number:setString("成就点数: "..remote.achieve.achievePoint)
-- end

function QUIDialogAchievement:_selectTab(tab, isForceFresh)
	if self._isMenuMove == true then return end
	if tab ~= self._tab or isForceFresh == true then
		self._tab = tab
		self._items = remote.achieve:getAchieveListByType(self._tab)
		self:initBtnListView()
		if self._listViewLayout then 
			self._listViewLayout:clear(true)
			self._listViewLayout = nil
		end
	
		self:initListView()
		if not isForceFresh then
			if self._checkItemScheduler ~= nil then
				scheduler.unscheduleGlobal(self._checkItemScheduler)
				self._checkItemScheduler = nil
			end

			if self._timeScheduler1 ~= nil then
				scheduler.unscheduleGlobal(self._timeScheduler1)
				self._timeScheduler1 = nil
			end

			if self._timeScheduler2 ~= nil then
				scheduler.unscheduleGlobal(self._timeScheduler2)
				self._timeScheduler2 = nil
			end
			self:achievementBoxRunOutAction()
		end
	end
end

function QUIDialogAchievement:achievementBoxRunOutAction()
	self._listViewLayout:setCanNotTouchMove(true)
	self._itemBoxAniamtion = true
	local index = 1
	for index = 1,QUIDialogAchievement.MAX_SHOW_NUM do
		local itemBox1
		if self._listViewLayout then
			itemBox1 = self._listViewLayout:getItemByIndex(index)
		end
		if itemBox1 ~= nil then
			local posx,posy = itemBox1:getPosition()
			itemBox1:setPosition(ccp(posx,posy-self._itemHeight))	
		end
	end

	self.func1 = function()
		self._checkItemScheduler = scheduler.performWithDelayGlobal(function()
			if self:safeCheck() then
				self:achievementBoxRunInAction()
			end
		end, 0.01)
	end
	self.func1()
end 

function QUIDialogAchievement:achievementBoxRunInAction()
	self._itemBoxAniamtion = true
	self.time = 0.12
	local index = 1
	self.func2 = function()
		if index <= QUIDialogAchievement.MAX_SHOW_NUM then
			local itemBox1 = self._listViewLayout:getItemByIndex(index)
			if itemBox1 ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						makeNodeFadeToOpacity(itemBox1, self.time)
				    end))
				array1:addObject(CCEaseSineOut:create(CCMoveBy:create(self.time, ccp(0,self._itemHeight))))

				local array2 = CCArray:create()
				array2:addObject(CCSpawn:create(array1))
				itemBox1:runAction(CCSequence:create(array2))
			end
			index = index + 1
			self._timeScheduler2 = scheduler.performWithDelayGlobal(self.func2, 0.04)
		else
			self.func3 = function()
				self._timeScheduler1 = scheduler.performWithDelayGlobal(function()
					if self:safeCheck() then
						self._itemBoxAniamtion = false
						self._listViewLayout:setCanNotTouchMove(false)
					end
				end, 0.08)
			end
			self.func3()

		end
	end
	self.func2()
end 


function QUIDialogAchievement:moveTo(node, totalHeight, posY, isAnimation)
	self._ccbOwner.sprite_scroll_cell:stopAllActions()
	self._ccbOwner.sprite_scroll_bar:stopAllActions()
	if 	totalHeight <= self._itemHeight or (math.abs(posY) < 1 and self._scrollShow == false) then
		self._ccbOwner.sprite_scroll_cell:setOpacity(0)
		self._ccbOwner.sprite_scroll_bar:setOpacity(0)
	else
		self._ccbOwner.sprite_scroll_cell:setOpacity(255)
		self._ccbOwner.sprite_scroll_bar:setOpacity(255)
		self._scrollShow = true
	end
	if isAnimation == false then
		node:setPositionY(posY)
		return 
	end

	local contentY = node:getPositionY()
	local targetY = 0
	if totalHeight <= self._itemHeight then
		targetY = 0
	elseif contentY + posY > totalHeight - self._itemHeight then
		targetY = totalHeight - self._itemHeight
	elseif contentY + posY < 0 then
		targetY = 0
	else
		targetY = contentY + posY
	end
	self._runNode = node
	return self:_contentRunAction(node, targetY, totalHeight)
end

function QUIDialogAchievement:_contentRunAction(node, posY ,totalHeight)
	local posX = self._runNode:getPositionX()
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveTo:create(0.3, ccp(posX,posY)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
		self:_removeAction(node)
		if 	totalHeight > self._itemHeight and self._scrollShow == true then
			self._ccbOwner.sprite_scroll_cell:runAction(CCFadeOut:create(0.3))
			self._ccbOwner.sprite_scroll_bar:runAction(CCFadeOut:create(0.3))
			self._scrollShow = false
		end
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    local actionHandler = self._runNode:runAction(ccsequence)
    return actionHandler
end

function QUIDialogAchievement:_removeAction(node)
	local actionHandler = nil
	if node == self._itemContent then
		actionHandler = self._itemActionHandler
		self._itemActionHandler = nil
	end
	if actionHandler ~= nil and node ~= nil then
		node:stopAction(actionHandler)		
	end
end

function QUIDialogAchievement:_achievementsInfoUpdate()
	self:_selectTab(self._tab , true)
end

function QUIDialogAchievement:onTriggerBackHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogAchievement:onTriggerHomeHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogAchievement:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogAchievement:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogAchievement:_onTriggerAchievemenCollege( event)
	remote.achievementCollege:openDialog()
end

function QUIDialogAchievement:_onTriggerOneGet(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_combination) == false then return end
	app.sound:playSound("common_small")
	if not app:getUserData():getValueForKey("UNLOCK_TASKS_YIJIANLINGQU"..remote.user.userId) then
		app:getUserData():setValueForKey("UNLOCK_TASKS_YIJIANLINGQU"..remote.user.userId, "true")
        self._ccbOwner.node_one_effect:setVisible(false)
	end	
	local ids = {}
	local awards = {}
	local oneItems = remote.achieve:getAllAchieveList()
	for _,value in ipairs(oneItems) do
    	local taskInfo = remote.achieve:getAchieveById(value.config.index)
    	if taskInfo.state == remote.achieve.MISSION_DONE then
			if taskInfo.config.id_1 ~= nil or taskInfo.config.type_1 ~= nil then
				table.insert(awards, {id = taskInfo.config.id_1, typeName = taskInfo.config.type_1, count = taskInfo.config.num_1})
			end
			if taskInfo.config.id_2 ~= nil or taskInfo.config.type_2 ~= nil  then
				table.insert(awards, {id = taskInfo.config.id_2, typeName = taskInfo.config.type_2, count = taskInfo.config.num_2})
			end
			if taskInfo.config.count ~= nil then
				table.insert(awards, {id = nil, typeName = ITEM_TYPE.ACHIEVE_POINT, count = taskInfo.config.count})
			end
    		table.insert(ids, value.config.index)
    	end
	end
	if #ids == 0 then
			app.tip:floatTip("没有可领取的成就")
		return
	end
	local fishNum = #ids
	local titleStr = string.format("恭喜您完成了%d项成就",fishNum)
	app:getClient():achieveComplete(ids, function (data)
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards}},{isPopCurrentDialog = false} )
   		dialog:setTitle(titleStr)
   		self:showOrHideBtnOne()
	end)
end

function QUIDialogAchievement:btnItemClickHandler(event)
	local info = event.info or {}
	local achieveType = remote.achieve.DEFAULT
	for i, v in pairs(self._btnList) do
		if v.id == info.id then
			achieveType = v.achieveType
			break
		end
	end
	self:_selectTab(achieveType)
end

function QUIDialogAchievement:itemClickHandler(x, y, touchNode, listView)
    local touchIndex = listView:getCurTouchIndex()
    local info = self._items[touchIndex]
    local taskInfo = remote.achieve:getAchieveById(info.config.index)
	if taskInfo.state == remote.achieve.MISSION_COMPLETE then
		return 
	end
	app.sound:playSound("common_small")
	if taskInfo.state ~= remote.achieve.MISSION_DONE then
		app.tip:floatTip("成就尚未完成")
		return
	end
	local awards = {}
	if taskInfo.config.id_1 ~= nil or taskInfo.config.type_1 ~= nil then
		table.insert(awards, {id = taskInfo.config.id_1, typeName = taskInfo.config.type_1, count = taskInfo.config.num_1})
	end
	if taskInfo.config.id_2 ~= nil or taskInfo.config.type_2 ~= nil  then
		table.insert(awards, {id = taskInfo.config.id_2, typeName = taskInfo.config.type_2, count = taskInfo.config.num_2})
	end
	if taskInfo.config.count ~= nil then
		table.insert(awards, {id = nil, typeName = ITEM_TYPE.ACHIEVE_POINT, count = taskInfo.config.count})
	end
	app:getClient():achieveComplete({info.config.index}, function ()
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards}},{isPopCurrentDialog = false} )
   		dialog:setTitle("恭喜您获得成就奖励")
   		self:showOrHideBtnOne()
	end)

end

return QUIDialogAchievement