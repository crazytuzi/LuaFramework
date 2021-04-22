-- @Author: liaoxianbo
-- @Date:   2020-08-06 16:08:49
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-26 10:22:00
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreMemoryAwards = class("QUIDialogMazeExploreMemoryAwards", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView")
local QUIWidgetMazeExploreMemoryAwardCell = import("..widgets.QUIWidgetMazeExploreMemoryAwardCell")

function QUIDialogMazeExploreMemoryAwards:ctor(options)
	local ccbFile = "ccb/Dialog_SocietyDungeon_xingji.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMazeExploreMemoryAwards.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("记忆奖励")

	self._mazeExploreDataHandle = remote.activityRounds:getMazeExplore()

	self._achieveBox = {}

	self:_initPageSwipe()

end

function QUIDialogMazeExploreMemoryAwards:viewDidAppear()
	QUIDialogMazeExploreMemoryAwards.super.viewDidAppear(self)

end

function QUIDialogMazeExploreMemoryAwards:viewWillDisappear()
  	QUIDialogMazeExploreMemoryAwards.super.viewWillDisappear(self)

end

function QUIDialogMazeExploreMemoryAwards:update()
	if self._scrollView then
		self:_init()
	end
end

function QUIDialogMazeExploreMemoryAwards:_initPageSwipe()
	self._itemWidth = self._ccbOwner.sheet_content:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_content:getContentSize().height
		
	self._scrollView = QScrollView.new(self._ccbOwner.item_sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setGradient(false)
	self._scrollView:setVerticalBounce(true)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))

	self:_init()
end

function QUIDialogMazeExploreMemoryAwards:_init()
	if self._isMenuMove == true then return end

	if not self._scrollView then return end
	
	self._scrollView:clear()	
	if self._buffer then
		for k, v in ipairs(self._buffer) do
			if v.removeAllEventListeners then v:removeAllEventListeners() end
		end
	end
	self._itemContentSize, self._buffer = self._scrollView:setCacheNumber(6, "widgets.QUIWidgetMazeExploreMemoryAwardCell")
	for k, v in ipairs(self._buffer) do
		table.insert(self._achieveBox, v) 
		v:addEventListener(QUIWidgetMazeExploreMemoryAwardCell.EVENT_CLICK, handler(self, self.itemClickHandler))
	end

	self:_initPage()
end

function QUIDialogMazeExploreMemoryAwards:_initPage()
	--释放现有的BOX
	self._items = self:_sortItems()

	self._itemTotalHeight = 0
    local offsetX = -3
    local offsetY = 0
    for _, value in ipairs(self._items) do
        self._scrollView:addItemBox(offsetX, -self._itemTotalHeight-offsetY, value)
        self._itemTotalHeight = self._itemTotalHeight + self._itemContentSize.height + offsetY
    end

    self._scrollView:setRect(-3, -self._itemTotalHeight - offsetY * 2, 0, self._itemContentSize.width)
end

function QUIDialogMazeExploreMemoryAwards:_sortItems()
	local receivedChapterIds = self._mazeExploreDataHandle:_anaylsisReceivedMemoryList()
	local passAwardsList = self._mazeExploreDataHandle:getMazeExploreMemoryAwardList()
	local tbl = {}
	local isReceivedTbl = {} --已领取
	local starRewardTbl = {} --可领取，未完成, 已领取

	for _, chapter in pairs(passAwardsList) do
		tbl[chapter.id] = {["id"] = chapter.id, award = chapter.reward_id, memeryPieceNum = chapter.memery_piece_num}
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



function QUIDialogMazeExploreMemoryAwards:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogMazeExploreMemoryAwards:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogMazeExploreMemoryAwards:itemClickHandler(event)
	if self._isMoving == true then return end

	if event.state == QUIWidgetMazeExploreMemoryAwardCell.WEI_WAN_CHENG then
		-- app.tip:floatTip("未达到指定星级，无法领取奖励。")
		return
	elseif event.state == QUIWidgetMazeExploreMemoryAwardCell.DONE then
		-- go on
	elseif event.state == QUIWidgetMazeExploreMemoryAwardCell.YI_LING_QU then
		return
	else
		return
	end

	app.sound:playSound("common_small")

	self._mazeExploreDataHandle:MazeExploreGotScoreRewardRequest({event.id}, function (data)
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
		        options = {awards = event.items, callBack = function( )
					if self:safeCheck() then
						self:update()
					end
		        end}}, {isPopCurrentDialog = false} )
		    dialog:setTitle("恭喜您获得记忆奖励")

			-- remote.union:sendReceivedAwardSuccess()
        end)
end

function QUIDialogMazeExploreMemoryAwards:_mergeAwards( awards )
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

function QUIDialogMazeExploreMemoryAwards:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMazeExploreMemoryAwards:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMazeExploreMemoryAwards:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMazeExploreMemoryAwards
