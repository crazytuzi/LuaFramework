--
-- Kumo
-- Date: Sat Jun  4 10:57:28 2016
-- 宗门副本通关奖励主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSocietyDungeonAward = class("QUIDialogSocietyDungeonAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetSocietyDungeonAward = import("..widgets.QUIWidgetSocietyDungeonAward")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView") 
-- local QUIWidgetSmallAwardsAlert = import("..widgets.QUIWidgetSmallAwardsAlert")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogSocietyDungeonAward:ctor(options)
	local ccbFile = "ccb/Dialog_SocietyDungeon_xingji.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSocietyDungeonAward._onTriggerClose)},
	}
	QUIDialogSocietyDungeonAward.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示
    self._ccbOwner.frame_tf_title:setString("通关奖励")

	-- 初始化页面滑动框和遮罩层
	self._achieveBox = {}
	self._receivedChapterIds = {}
	self:_initPageSwipe()
end

function QUIDialogSocietyDungeonAward:viewDidAppear()
	QUIDialogSocietyDungeonAward.super.viewDidAppear(self)
end

function QUIDialogSocietyDungeonAward:viewWillDisappear()
  	QUIDialogSocietyDungeonAward.super.viewWillDisappear(self)
	self:_removeAction(self._itemContent)
end

function QUIDialogSocietyDungeonAward:update()
	if self._scrollView then
		self:_init()
	end
end

function QUIDialogSocietyDungeonAward:_initPageSwipe()
	self._itemWidth = self._ccbOwner.sheet_content:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_content:getContentSize().height
		
	-- Initialize achievement part scroll
	self._scrollView = QScrollView.new(self._ccbOwner.item_sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setGradient(false)
	self._scrollView:setVerticalBounce(true)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))

	-- self._itemTotalHeight = 0
	-- self._cellH = self._ccbOwner.sprite_scroll_cell:getContentSize().height
	-- self._scrollH = self._ccbOwner.sprite_scroll_bar:getContentSize().height - self._cellH

	self:_init()
end

function QUIDialogSocietyDungeonAward:_init()
	if self._isMenuMove == true then return end
	self._scrollView:clear()	
	if self._buffer then
		for k, v in ipairs(self._buffer) do
			if v.removeAllEventListeners then v:removeAllEventListeners() end
		end
	end
	self._itemContentSize, self._buffer = self._scrollView:setCacheNumber(6, "widgets.QUIWidgetSocietyDungeonAward")
	for k, v in ipairs(self._buffer) do
		table.insert(self._achieveBox, v) -- for new player guide
		v:addEventListener(QUIWidgetSocietyDungeonAward.EVENT_CLICK, handler(self, self.itemClickHandler))
	end

	self:_initPage()
end

function QUIDialogSocietyDungeonAward:_initPage()
	--释放现有的BOX
	self._items = self:_sortItems()
	-- local count = 0
	-- local offsetY = -10
	-- self._itemTotalHeight = 0
	-- for _, value in pairs(self._items) do
	-- 	self._scrollView:addItemBox(10, offsetY - count * (self._itemContentSize.height + 5), value)
	-- 	count = count + 1
	-- 	self._itemTotalHeight = self._itemTotalHeight + self._itemContentSize.height - (offsetY / 4)
	-- end
	
	-- self._scrollView:setRect(10, -self._itemTotalHeight, 0, self._itemWidth)


	self._itemTotalHeight = 0
    local offsetX = 0
    local offsetY = 0
    for _, value in ipairs(self._items) do
        self._scrollView:addItemBox(offsetX, -self._itemTotalHeight-offsetY, value)
        self._itemTotalHeight = self._itemTotalHeight + self._itemContentSize.height + offsetY
    end

    self._scrollView:setRect(0, -self._itemTotalHeight - offsetY * 2, 0, self._itemContentSize.width)
end

function QUIDialogSocietyDungeonAward:_sortItems()
	local receivedChapterIds = self:_anaylsisReceivedList()
	local scoietyChapter = QStaticDatabase.sharedDatabase():getAllScoietyChapter()
	local tbl = {}
	local isReceivedTbl = {} --已领取
	local starRewardTbl = {} --可领取，未完成, 已领取

	for _, chapter in pairs(scoietyChapter) do
		tbl[chapter[1].chapter] = {["chapter"] = chapter[1].chapter, ["lucky_draw"] = chapter[1].lucky_draw, ["name"] = chapter[1].chapter_name}
	end
	-- QPrintTable(tbl)

	for _, value in pairs(tbl) do
		if receivedChapterIds and receivedChapterIds[value.chapter]  then
			table.insert(isReceivedTbl, value)
		else
			table.insert(starRewardTbl, value)
		end
	end
	for _, value in pairs(isReceivedTbl) do
		table.insert(starRewardTbl, value)	
	end
	QPrintTable(starRewardTbl)
	return starRewardTbl
end

function QUIDialogSocietyDungeonAward:_anaylsisReceivedList()
	local receivedChapterIds = {}

	local userConsortia = remote.user:getPropForKey("userConsortia")
	local tbl = userConsortia.consortia_chapter_reward

	if not tbl or #tbl == 0 then return nil end

	for _, value in pairs(tbl) do
		receivedChapterIds[value] = true
	end
	-- QPrintTable(receivedChapterIds)
	return receivedChapterIds
end

function QUIDialogSocietyDungeonAward:moveTo(node, totalHeight, posY, isAnimation)
	-- self._ccbOwner.sprite_scroll_cell:stopAllActions()
	-- self._ccbOwner.sprite_scroll_bar:stopAllActions()
	-- if 	totalHeight <= self._itemHeight or (math.abs(posY) < 1 and self._scrollShow == false) then
	-- 	self._ccbOwner.sprite_scroll_cell:setOpacity(0)
	-- 	self._ccbOwner.sprite_scroll_bar:setOpacity(0)
	-- else
	-- 	self._ccbOwner.sprite_scroll_cell:setOpacity(255)
	-- 	self._ccbOwner.sprite_scroll_bar:setOpacity(255)
	-- 	self._scrollShow = true
	-- end
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

function QUIDialogSocietyDungeonAward:_contentRunAction(node, posY ,totalHeight)
	posX = self._runNode:getPositionX()
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveTo:create(0.3, ccp(posX,posY)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
    											self:_removeAction(node)
												-- if 	totalHeight > self._itemHeight and self._scrollShow == true then
												-- 	self._ccbOwner.sprite_scroll_cell:runAction(CCFadeOut:create(0.3))
												-- 	self._ccbOwner.sprite_scroll_bar:runAction(CCFadeOut:create(0.3))
												-- 	self._scrollShow = false
												-- end
                                            end))
    local ccsequence = CCSequence:create(actionArrayIn)
    local actionHandler = self._runNode:runAction(ccsequence)
    return actionHandler
end

function QUIDialogSocietyDungeonAward:_removeAction(node)
	-- if node ~= self._runNode then return end
	local actionHandler = nil
	if node == self._itemContent then
		actionHandler = self._itemActionHandler
		self._itemActionHandler = nil
	end
	if actionHandler ~= nil and node ~= nil then
		node:stopAction(actionHandler)		
	end
end

-- function QUIDialogSocietyDungeonAward:onTriggerBackHandler()
-- 	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
-- end

-- function QUIDialogSocietyDungeonAward:onTriggerHomeHandler()
-- 	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
-- end

function QUIDialogSocietyDungeonAward:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogSocietyDungeonAward:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogSocietyDungeonAward:itemClickHandler(event)
	if self._isMoving == true then return end

	if event.state == QUIWidgetSocietyDungeonAward.WEI_WAN_CHENG then
		-- app.tip:floatTip("未达到指定星级，无法领取奖励。")
		return
	elseif event.state == QUIWidgetSocietyDungeonAward.DONE then
		-- go on
	elseif event.state == QUIWidgetSocietyDungeonAward.YI_LING_QU then
		return
	else
		return
	end

	app.sound:playSound("common_small")
	
	remote.union:unionGetChapterRewardRequest(event.chapter, function (data)
		-- QPrintTable(data)
			local awards = {}
		    local tbl = {}
		    local wallet = {}
		    local items = {}

		    if data and data.wallet then
				wallet = data.wallet
			end

			if data and data.items then 
		    	items = data.items
		    end

		    if data ~= nil and data.prizes ~= nil then
		        tbl = self:_mergeAwards(data.prizes)
		    end
		    for _,value in pairs(tbl) do
		        table.insert(awards, {id = value.id, typeName = value.type or value.typeName, count = value.count})
		    end

		    remote.user:update( wallet )
		    remote.items:setItems( items ) 

		    -- local awardsAlert = QUIWidgetSmallAwardsAlert.new({awards = awards, title = "恭喜您获得宗门副本通关奖励"})
			-- app.tutorialNode:addChild(awardsAlert)
			-- awardsAlert:setPosition(ccp(display.width/2, display.height/2))
		    -- app.tip:awardsTip(awards,"恭喜您获得宗门副本通关奖励", nil)

		    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		        options = {awards = awards, callBack = nil}}, {isPopCurrentDialog = false} )
		    dialog:setTitle("恭喜您获得通关奖励")

			remote.union:sendReceivedAwardSuccess()
			
			self:update()
        end)
end

function QUIDialogSocietyDungeonAward:_mergeAwards( awards )
	if not awards or table.nums(awards) == 0 then return end

	local tbl = {}
	for _, value in pairs( awards ) do
		local key = value.type or value.typeName
		if key == string.lower(ITEM_TYPE.ITEM) or key == string.upper(ITEM_TYPE.ITEM) then
			key = tostring(value.id)
		end
		if not tbl[key] then
			tbl[key] = {id = value.id, typeName = value.type or value.typeName, count = value.count}
		else
			tbl[key].count = tbl[key].count + value.count
		end
	end

	return tbl
end

function QUIDialogSocietyDungeonAward:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogSocietyDungeonAward:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_close")
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if callback ~= nil then
    	callback()
    end
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.class.__cname == "QUIPageMainMenu" then
		printInfo("call QUIPageMainMenu function checkGuiad()")
		page:checkGuiad()
	end
end

return QUIDialogSocietyDungeonAward