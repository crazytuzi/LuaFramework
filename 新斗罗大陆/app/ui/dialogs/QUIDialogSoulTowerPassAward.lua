-- @Author: liaoxianbo
-- @Date:   2020-04-12 19:25:02
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-18 16:30:58
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulTowerPassAward = class("QUIDialogSoulTowerPassAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetSoulTowerPassAward = import("..widgets.QUIWidgetSoulTowerPassAward")

function QUIDialogSoulTowerPassAward:ctor(options)
	local ccbFile = "ccb/Dialog_SocietyDungeon_xingji.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSoulTowerPassAward.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("通关奖励")
	-- 初始化页面滑动框和遮罩层
	self._achieveBox = {}
	self._receivedChapterIds = {}
	self:_initPageSwipe()
end

function QUIDialogSoulTowerPassAward:viewDidAppear()
	QUIDialogSoulTowerPassAward.super.viewDidAppear(self)
end

function QUIDialogSoulTowerPassAward:viewWillDisappear()
  	QUIDialogSoulTowerPassAward.super.viewWillDisappear(self)
	self:_removeAction(self._itemContent)
end

function QUIDialogSoulTowerPassAward:update()
	if self._scrollView then
		self:_init()
	end
end

function QUIDialogSoulTowerPassAward:_initPageSwipe()
	self._itemWidth = self._ccbOwner.sheet_content:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_content:getContentSize().height
		
	self._scrollView = QScrollView.new(self._ccbOwner.item_sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setGradient(false)
	self._scrollView:setVerticalBounce(true)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))

	self:_init()
end

function QUIDialogSoulTowerPassAward:_init()
	if self._isMenuMove == true then return end
	self._scrollView:clear()	
	if self._buffer then
		for k, v in ipairs(self._buffer) do
			if v.removeAllEventListeners then v:removeAllEventListeners() end
		end
	end
	self._itemContentSize, self._buffer = self._scrollView:setCacheNumber(6, "widgets.QUIWidgetSoulTowerPassAward")
	for k, v in ipairs(self._buffer) do
		table.insert(self._achieveBox, v) 
		v:addEventListener(QUIWidgetSoulTowerPassAward.EVENT_CLICK, handler(self, self.itemClickHandler))
	end

	self:_initPage()
end

function QUIDialogSoulTowerPassAward:_initPage()
	--释放现有的BOX
	self._items = self:_sortItems()

	self._itemTotalHeight = 0
    local offsetX = 0
    local offsetY = 0
    for _, value in ipairs(self._items) do
        self._scrollView:addItemBox(offsetX, -self._itemTotalHeight-offsetY, value)
        self._itemTotalHeight = self._itemTotalHeight + self._itemContentSize.height + offsetY
    end

    self._scrollView:setRect(0, -self._itemTotalHeight - offsetY * 2, 0, self._itemContentSize.width)
end

function QUIDialogSoulTowerPassAward:_sortItems()
	local receivedChapterIds = remote.soultower:_anaylsisReceivedList()
	local passAwardsList = remote.soultower:getPassAwardsList()
	local tbl = {}
	local isReceivedTbl = {} --已领取
	local starRewardTbl = {} --可领取，未完成, 已领取

	for _, chapter in pairs(passAwardsList) do
		tbl[chapter.id] = {["id"] = chapter.id, ["floor"] = chapter.soul_tower_floor, ["lucky_draw"] = chapter.pass_reward, ["wave"] = chapter.soul_tower_wave}
	end
	for _, value in pairs(tbl) do
		if receivedChapterIds and receivedChapterIds[value.id]  then
			table.insert(isReceivedTbl, value)
		else
			table.insert(starRewardTbl, value)
		end
	end
	table.sort(starRewardTbl, function( a,b )
		return tonumber(a.id) < tonumber(b.id)
	end )	
	for _, value in pairs(isReceivedTbl) do
		table.insert(starRewardTbl, value)	
	end

	return starRewardTbl
end

function QUIDialogSoulTowerPassAward:moveTo(node, totalHeight, posY, isAnimation)
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

function QUIDialogSoulTowerPassAward:_contentRunAction(node, posY ,totalHeight)
	posX = self._runNode:getPositionX()
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveTo:create(0.3, ccp(posX,posY)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
    											self:_removeAction(node)
                                            end))
    local ccsequence = CCSequence:create(actionArrayIn)
    local actionHandler = self._runNode:runAction(ccsequence)
    return actionHandler
end

function QUIDialogSoulTowerPassAward:_removeAction(node)
	local actionHandler = nil
	if node == self._itemContent then
		actionHandler = self._itemActionHandler
		self._itemActionHandler = nil
	end
	if actionHandler ~= nil and node ~= nil then
		node:stopAction(actionHandler)		
	end
end


function QUIDialogSoulTowerPassAward:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogSoulTowerPassAward:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogSoulTowerPassAward:itemClickHandler(event)
	if self._isMoving == true then return end

	if event.state == QUIWidgetSoulTowerPassAward.WEI_WAN_CHENG then
		-- app.tip:floatTip("未达到指定星级，无法领取奖励。")
		return
	elseif event.state == QUIWidgetSoulTowerPassAward.DONE then
		-- go on
	elseif event.state == QUIWidgetSoulTowerPassAward.YI_LING_QU then
		return
	else
		return
	end

	app.sound:playSound("common_small")

	remote.soultower:soulTowerGetAwardsRequest({event.id}, function (data)
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

		    -- remote.user:update( wallet )
		    -- remote.items:setItems( items ) 

		    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		        options = {awards = awards, callBack = nil}}, {isPopCurrentDialog = false} )
		    dialog:setTitle("恭喜您获得通关奖励")

			-- remote.union:sendReceivedAwardSuccess()
			
			self:update()
        end)
end

function QUIDialogSoulTowerPassAward:_mergeAwards( awards )
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

function QUIDialogSoulTowerPassAward:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogSoulTowerPassAward:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulTowerPassAward:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulTowerPassAward
