--
-- Kumo.Wang
-- 鼠年春节活动——抽福卡界面進度條組件
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRatFestivalTavernProgressBar = class("QUIWidgetRatFestivalTavernProgressBar", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetRatFestivalTavernProgressBarBox = import("..widgets.QUIWidgetRatFestivalTavernProgressBarBox")

QUIWidgetRatFestivalTavernProgressBar.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetRatFestivalTavernProgressBar:ctor(options)
	local ccbFile = "ccb/Widget_RatFestival_ProgressBar.ccbi"
	local callBacks = {}
	QUIWidgetRatFestivalTavernProgressBar.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._barWidth = self._ccbOwner.s9s_bar:getContentSize().width

	if not self._percentBarClippingNode then
		self._totalStencilPosition = self._ccbOwner.s9s_bar:getPositionX() -- 这个坐标必须s9s_bar节点的锚点为(0, 0.5)
		self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.s9s_bar)
		self._totalStencilWidth = self._ccbOwner.s9s_bar:getContentSize().width * self._ccbOwner.s9s_bar:getScaleX()
	end

	self:_initInfo()
end

function QUIWidgetRatFestivalTavernProgressBar:_initInfo()
	self._ratFestivalModel = remote.activityRounds:getRatFestival()

	if not self._ratFestivalModel then return end
	self:refreshInfo()
end

function QUIWidgetRatFestivalTavernProgressBar:_resetAll()
	self._ccbOwner.s9s_bar_bg:setVisible(true)
	self._ccbOwner.s9s_bar:setVisible(true)
	self._ccbOwner.node_box_container:setVisible(true)
	self._ccbOwner.node_box_container:removeAllChildren()
	self._ccbOwner.node_box_container:setPosition(self._ccbOwner.s9s_bar_bg:getPosition())
	self._ccbOwner.tf_score:setString("0")
end

function QUIWidgetRatFestivalTavernProgressBar:refreshInfo()
	self:_resetAll()

	if not self._ratFestivalModel then return end

	local scoreInfo = db:getStaticByName("activity_rat_festival_rewards")
	local serverInfo = self._ratFestivalModel:getServerInfo()
	local currentScore = serverInfo.score or 0
	
	self._ccbOwner.tf_score:setString(currentScore)
	local scale = self._ccbOwner.node_scors_size:getContentSize().width / self._ccbOwner.tf_score:getContentSize().width
	if scale > 1 then scale = 1 end
	self._ccbOwner.tf_score:setScale(scale)

	local barInfo, curProportion = self:_getBarInfo(currentScore, scoreInfo)

	for _, info in ipairs(barInfo) do
		local widgetBox = QUIWidgetRatFestivalTavernProgressBarBox.new()
		self._ccbOwner.node_box_container:addChild(widgetBox)

		widgetBox:setPosition(ccp(info.x, info.y))
		widgetBox:setInfo(info)
		if info.state ~= QUIWidgetRatFestivalTavernProgressBarBox.DONE then
			widgetBox:addEventListener(QUIWidgetRatFestivalTavernProgressBarBox.EVENT_CLICK, handler(self, self._clickBox))
		end
	end

	local stencil = self._percentBarClippingNode:getStencil()
    stencil:setPositionX(-self._totalStencilWidth + curProportion * self._totalStencilWidth)
end

function QUIWidgetRatFestivalTavernProgressBar:_clickBox(event)
	if not self._ratFestivalModel then return end

	local scoreInfo = db:getStaticByName("activity_rat_festival_rewards")
	local serverInfo = self._ratFestivalModel:getServerInfo()
	local currentScore = serverInfo.score or 0

	local index = event.index 
	local curInfo = scoreInfo[tostring(index)]
	local awards = {}

	if self._ratFestivalModel:checkAwardIsRecived(index) == false and curInfo.points and currentScore >= curInfo.points then
		if curInfo.rewards then
			local award = string.split(curInfo.rewards, "^")
			local id = tonumber(award[1])
			local num = tonumber(award[2])
		    local itemType = remote.items:getItemType(id) or ITEM_TYPE.ITEM
	    	awards = { {id = id, typeName = itemType, count = num} }
		end

		self._ratFestivalModel:ratFestivalGetScoreRewardRequest({index}, function()
		  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		    		options = {awards = awards}}, {isPopCurrentDialog = false} )
		    	dialog:setTitle("恭喜您获得奖励")

		    	if self:safeCheck() then
		    		self:refreshInfo()
		    	end
			end)		
	end
end

function QUIWidgetRatFestivalTavernProgressBar:_getBarInfo(currentScore, scoreInfo)
	local barInfo = {}
	local index = 1
	while true do
		local curInfo = scoreInfo[tostring(index)]
		if curInfo then
			local condition = curInfo.points
			if condition then
				local awardInfo = curInfo.rewards
				if awardInfo then
					local state = QUIWidgetRatFestivalTavernProgressBarBox.NONE --未達成
					if currentScore >= condition then
						if self._ratFestivalModel:checkAwardIsRecived(index) then
							state = QUIWidgetRatFestivalTavernProgressBarBox.DONE --已領取
						else
							state = QUIWidgetRatFestivalTavernProgressBarBox.RECEIVE --可領取
						end
					end
					local tbl = string.split(awardInfo, "^")
					local itemInfo = {id = tonumber(tbl[1]), type = remote.items:getItemType(tonumber(tbl[1])) or ITEM_TYPE.ITEM, count = tonumber(tbl[2])}
					table.insert(barInfo, {index = index, itemInfo = itemInfo, condition = condition, state = state, x = 0, y = 0, isLast = false})
				end
				index = index + 1
			else
				break
			end
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
	if curProportion > 1 then
		curProportion = 1
	end
	return barInfo, curProportion
end

return QUIWidgetRatFestivalTavernProgressBar