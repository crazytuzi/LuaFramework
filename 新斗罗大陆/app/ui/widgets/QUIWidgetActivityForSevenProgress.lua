--
-- Kumo.Wang
-- 1~14日活動進度條
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityForSevenProgress = class("QUIWidgetActivityForSevenProgress", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetActivityForSevenProgressBox = import("..widgets.QUIWidgetActivityForSevenProgressBox")

QUIWidgetActivityForSevenProgress.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetActivityForSevenProgress:ctor(options)
	local ccbFile = "ccb/Widget_SevenDayAcitivity_progress.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickHelp", callback = handler(self, self._onTriggerClickHelp)},
	}
	QUIWidgetActivityForSevenProgress.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._barWidth = self._ccbOwner.s9s_bar:getContentSize().width

	if not self._percentBarClippingNode then
		self._totalStencilPosition = self._ccbOwner.s9s_bar:getPositionX() -- 这个坐标必须s9s_bar节点的锚点为(0, 0.5)
		self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.s9s_bar)
		self._totalStencilWidth = self._ccbOwner.s9s_bar:getContentSize().width * self._ccbOwner.s9s_bar:getScaleX()
	end
end

function QUIWidgetActivityForSevenProgress:setInfo(curActivityType)
	self._curActivityType = curActivityType
	self:refreshInfo()
end

function QUIWidgetActivityForSevenProgress:_resetAll()
	self._ccbOwner.btn_help:setVisible(true)
	self._ccbOwner.s9s_bar_bg:setVisible(true)
	self._ccbOwner.s9s_bar:setVisible(true)
	self._ccbOwner.node_box_container:setVisible(true)
	self._ccbOwner.node_box_container:removeAllChildren()
	self._ccbOwner.node_box_container:setPosition(self._ccbOwner.s9s_bar_bg:getPosition())
end

function QUIWidgetActivityForSevenProgress:refreshInfo()
	if not self._curActivityType then return end
	self:_resetAll()

	local scoreInfo = db:getActivityForSevenScoreInfoById(self._curActivityType)
	local currentScore = remote.user.calnivalPoints or 0
	if self._curActivityType == 2 then
		currentScore = remote.user.celebration_points or 0
	end

	local barInfo, curProportion = self:_getBarInfo(currentScore, scoreInfo)

	for _, info in ipairs(barInfo) do
		local widgetBox = QUIWidgetActivityForSevenProgressBox.new()
		self._ccbOwner.node_box_container:addChild(widgetBox)

		widgetBox:setPosition(ccp(info.x, info.y))
		widgetBox:setInfo(info)
		if info.state ~= QUIWidgetActivityForSevenProgressBox.DONE then
			widgetBox:addEventListener(QUIWidgetActivityForSevenProgressBox.EVENT_CLICK, handler(self, self._clickBox))
		end
	end

	local stencil = self._percentBarClippingNode:getStencil()
    stencil:setPositionX(-self._totalStencilWidth + curProportion * self._totalStencilWidth)
end

function QUIWidgetActivityForSevenProgress:_clickBox(event)
	local scoreInfo = db:getActivityForSevenScoreInfoById(self._curActivityType)
	local currentScore = remote.user.calnivalPoints or 0
	if self._curActivityType == 2 then
		currentScore = remote.user.celebration_points or 0
	end

	local index = event.index 
	local awards = {}

	if self:_checkAwardIsRecived(index) == false and scoreInfo["points"..index] and currentScore >= scoreInfo["points"..index] then
		if scoreInfo["rewards"..index] then
			local award = string.split(scoreInfo["rewards"..index], "^")
			local id = tonumber(award[1])
			local num = tonumber(award[2])
		    local itemType = remote.items:getItemType(id) or ITEM_TYPE.ITEM
	    	awards = { {id = id, typeName = itemType, count = num} }
		end

		app:getClient():getSevenActivityIntegralReward(self._curActivityType, index, function()
		  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		    		options = {awards = awards}},{isPopCurrentDialog = false} )
		    	dialog:setTitle("恭喜您获得活动奖励")

		    	if self:safeCheck() then
		    		if self._curActivityType == 1 then
				        app.taskEvent:updateTaskEventProgress(app.taskEvent.ACTIVITY_CARNIVAL_PRIZE_EVENT, 1)
				    end
		    		self:refreshInfo()
		    	end
			end)		
	end
end

function QUIWidgetActivityForSevenProgress:_checkAwardIsRecived(index)
	local recivedAwards = remote.user.gotCalnivalPrizeIds or {}
	if self._curActivityType == 2 then
		recivedAwards = remote.user.gotCelebrationPrizeIds or {}
	end

	for _, value in pairs(recivedAwards) do
		if value == index then
			return true
		end
	end

	return false
end

function QUIWidgetActivityForSevenProgress:_getBarInfo(currentScore, scoreInfo)
	local barInfo = {}
	local index = 1
	while true do
		local condition = scoreInfo["points"..index]
		if condition then
			local awardInfo = scoreInfo["rewards"..index]
			if awardInfo then
				local state = QUIWidgetActivityForSevenProgressBox.NONE --未達成
				if currentScore >= condition then
					if self:_checkAwardIsRecived(index) then
						state = QUIWidgetActivityForSevenProgressBox.DONE --已領取
					else
						state = QUIWidgetActivityForSevenProgressBox.RECEIVE --可領取
					end
				end
				local tbl = string.split(scoreInfo["rewards"..index], "^")
				local itemInfo = {id = tonumber(tbl[1]), type = remote.items:getItemType(tonumber(tbl[1])) or ITEM_TYPE.ITEM, count = tonumber(tbl[2])}
				table.insert(barInfo, {index = index, itemInfo = itemInfo, condition = condition, state = state, x = 0, y = 0, isLast = false})
			end
			index = index + 1
		else
			break
		end
	end

	table.sort(barInfo, function(a, b)
		return a.condition < b.condition
	end)

	barInfo[#barInfo].isLast = true

	local maxCondition = scoreInfo.total_points or barInfo[#barInfo].condition
	for _, info in ipairs(barInfo) do
		info.x = info.condition/maxCondition*self._barWidth
	end

	local curProportion = currentScore/maxCondition
	return barInfo, curProportion
end

function QUIWidgetActivityForSevenProgress:getInfo()
	return self._curActivityType
end

function QUIWidgetActivityForSevenProgress:_onTriggerClickHelp(event)
	if tonumber(event) == CCControlEventTouchDown then
		local currentScore = remote.user.calnivalPoints or 0
		local day = 7
		if self._curActivityType == 2 then
			currentScore = remote.user.celebration_points or 0
			day = 14
		end
		local ccbOwner = {}
		self._tipWidget = CCBuilderReaderLoad("Widget_SevenDayAcitivity_tips.ccbi", CCBProxy:create(), ccbOwner)
		ccbOwner.tf_score:setString(currentScore.."分")
		if self._curActivityType == 2 then
			ccbOwner.tf_desc:setString("完成嘉年华任务可以领取奖励与积分。累积积分可领取S魂师大礼包")
		else
			ccbOwner.tf_desc:setString("完成嘉年华任务可以领取奖励与积分。累积积分可领取S魂师大礼包")
		end
		self._tipWidget:setPosition(150, 100)
		self:getView():addChild(self._tipWidget)
		self._ccbOwner.btn_help:setColor(ccc3(188, 188, 188))
	else
		if self._tipWidget then
			self._tipWidget:removeFromParent()
			self._tipWidget = nil
		end
		self._ccbOwner.btn_help:setColor(ccc3(255, 255, 255))
	end
end

return QUIWidgetActivityForSevenProgress