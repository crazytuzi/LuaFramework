-- @Author: xurui
-- @Date:   2016-11-08 18:54:06
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-09-29 14:32:45
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPersonalActiveClient = class("QUIWidgetPersonalActiveClient", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 
local QUIViewController = import("..QUIViewController")
local QUIWidgetPersonalActiveClientCell = import("..widgets.QUIWidgetPersonalActiveClientCell")

function QUIWidgetPersonalActiveClient:ctor(options)
	local ccbFile = "ccb/Widget_society_gerenhuoyue.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerBox1", callback = handler(self, self._onTriggerBox1)},
		{ccbCallbackName = "onTriggerBox2", callback = handler(self, self._onTriggerBox2)},
		{ccbCallbackName = "onTriggerBox3", callback = handler(self, self._onTriggerBox3)},
		{ccbCallbackName = "onTriggerBox4", callback = handler(self, self._onTriggerBox4)},
	}
	QUIWidgetPersonalActiveClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetPersonalActiveClient:onEnter()
	self:initScrollView()
	self:setClientInfo()
	self:setChestInfo()
end

function QUIWidgetPersonalActiveClient:onExit()
end

function QUIWidgetPersonalActiveClient:initScrollView()
	local sheetSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, sheetSize, {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setGradient(true)

	self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._scrollViewMoveState))
	self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._scrollViewMoveState))
end

function QUIWidgetPersonalActiveClient:setClientInfo()
	self._scrollView:clear()

	local tasks = {}
	for _, value in pairs(remote.union.unionActive:getActiveTask()) do
		tasks[#tasks+1] = value
	end
	table.sort( tasks, function(a, b)
			if a.isComplete ~= b.isComplete then
				return a.isComplete == true
			else
				return a.index < b.index
			end
		end )

	local itemContentSize, buffer = self._scrollView:setCacheNumber(5, "..widgets.QUIWidgetPersonalActiveClientCell")
	for k, v in ipairs(buffer) do
		v:addEventListener(QUIWidgetPersonalActiveClientCell.EVENT_CLICK, handler(self, self._clickEvent))
	end
	local line = 0
	local totalHeight = 0 
	local offsetX = 5
	local haveTask = false
	for _, task in pairs(tasks) do
		-- 战队等级不足，不显示
		if task.show_level == nil or task.show_level <= remote.user.level then
			local positionX = offsetX
			local positionY = line * itemContentSize.height
			self._scrollView:addItemBox(positionX, -positionY, {task = task})

			line = line + 1
			haveTask = true
		end
	end
	totalHeight = line * itemContentSize.height
	self._scrollView:setRect(0, -totalHeight, 0, itemContentSize.width)

	-- set taks is complete
	self._ccbOwner.node_complete:setVisible(not haveTask)
end

function QUIWidgetPersonalActiveClient:setChestInfo()
	local currentPoint = remote.union.unionActive:getUnionActivePoint()
	self._chestAwards = remote.union.unionActive:getActiveAwards()

	self._ccbOwner.tf_scroe:setString(currentPoint or 0)

	for i = 1, 4 do
		if self._chestAwards[i] then
			if self._chestAwards[i].isDone == true then
				self._ccbOwner["node_light"..i]:setVisible(false)
			else
				self._ccbOwner["node_light"..i]:setVisible(self._chestAwards[i].isComplete)
			end
			self._ccbOwner["node_open"..i]:setVisible(self._chestAwards[i].isDone)
			self._ccbOwner["node_close"..i]:setVisible(not self._chestAwards[i].isDone)
			self._ccbOwner["tf_"..i]:setString(self._chestAwards[i].condition.."积分")
		else
			self._ccbOwner["node_light"..i]:setVisible(false)
		end
	end

	local scaleX = 1/4
	for i = 1, 4 do
		if self._chestAwards[i+1] == nil then
			scaleX = currentPoint/self._chestAwards[i].condition
		elseif currentPoint >= self._chestAwards[i].condition and currentPoint < self._chestAwards[i+1].condition then
			scaleX = scaleX + ( currentPoint-self._chestAwards[i].condition ) / ( self._chestAwards[i+1].condition - self._chestAwards[i].condition ) * 1/4
			break
		elseif currentPoint < self._chestAwards[i].condition then
			scaleX = currentPoint/self._chestAwards[i].condition * 1/4
			break
		end
		scaleX = scaleX + 1/4
	end
	
	scaleX = scaleX > 1 and 1 or scaleX
	self._ccbOwner.node_bar:setScaleX(scaleX)
end

function QUIWidgetPersonalActiveClient:clickChestBox(index)
	if index == nil then return end
	if self._chestAwards[index] == nil then return end

	if self._chestAwards[index] and self._chestAwards[index].isComplete == true and self._chestAwards[index].isDone == false then
		--请求获取
		remote.union.unionActive:requestPersonalActiveChest(self._chestAwards[index].ID, function (data)
			self:setChestInfo()
			local awards = {}
			local prizes = data.prizes or {}
			for _,item in pairs(prizes) do
	            local typeName = remote.items:getItemType(item.type)
	            table.insert(awards, {typeName = typeName, id = item.id, count = item.count})
			end
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    			options = {awards = awards, callBack = function ()
					remote.user:checkTeamUp()
	    		end}},{isPopCurrentDialog = false} )
	    	dialog:setTitle("恭喜您获得个人活跃任务积分奖励")
		end)
	else
		local tips = {
            {oType = "font", content = "领取条件：当个人活跃累计达到",size = 26,color = ccc3(134,85,55)},
            {oType = "font", content = self._chestAwards[index].condition,size = 24,color = COLORS.k},
            {oType = "font", content = "积分",size = 26,color = ccc3(134,85,55)},
        }
		app:luckyDrawAlert(self._chestAwards[index].reward_id, tips)
	end
end

function QUIWidgetPersonalActiveClient:_clickEvent(event)
    if event.info == nil or self._isMoving then return end
    app.sound:playSound("common_small")

	if event.name == QUIWidgetPersonalActiveClientCell.EVENT_CLICK then
		remote.union.unionActive:requestPersonalActiveComplete(event.info.index, function (data)
				remote.union.unionActive:updateActiveTaskCompleteId(event.info.task_type, event.info.index)
				if self.class then
					self:setClientInfo()
					self:setChestInfo()
				end

				local awards = {{typeName = ITEM_TYPE.UNION_TASK_POINT, id = nil, count = event.info.meiri_points}}
		  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	    			options = {awards = awards}},{isPopCurrentDialog = false} )
		    	dialog:setTitle("恭喜您获得个人活跃任务奖励")
			end)
	end
end

function QUIWidgetPersonalActiveClient:_scrollViewMoveState(event)
	if event.name == QScrollView.GESTURE_MOVING then
		self._isMoving = true
	elseif event.name == QScrollView.GESTURE_BEGAN then
		self._isMoving = false
	end
end

function QUIWidgetPersonalActiveClient:_onTriggerBox1()
    app.sound:playSound("common_small")

    self:clickChestBox(1)
end

function QUIWidgetPersonalActiveClient:_onTriggerBox2()
    app.sound:playSound("common_small")

    self:clickChestBox(2)
end

function QUIWidgetPersonalActiveClient:_onTriggerBox3()
    app.sound:playSound("common_small")

    self:clickChestBox(3)
end

function QUIWidgetPersonalActiveClient:_onTriggerBox4()
    app.sound:playSound("common_small")

    self:clickChestBox(4)
end

return QUIWidgetPersonalActiveClient