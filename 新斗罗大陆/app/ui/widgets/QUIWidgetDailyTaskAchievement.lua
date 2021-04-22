local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetDailyTaskAchievement = class("QUIWidgetDailyTaskAchievement", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

local WEEKLY_TASK_OFFSIDE = 8


function QUIWidgetDailyTaskAchievement:ctor(options)
	local ccbFile = "ccb/Widget_achievement_2.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerBox1", 				callback = handler(self, QUIWidgetDailyTaskAchievement._onTriggerBox1)},
		{ccbCallbackName = "onTriggerBox2", 				callback = handler(self, QUIWidgetDailyTaskAchievement._onTriggerBox2)},
		{ccbCallbackName = "onTriggerBox3", 				callback = handler(self, QUIWidgetDailyTaskAchievement._onTriggerBox3)},
		{ccbCallbackName = "onTriggerBox4", 				callback = handler(self, QUIWidgetDailyTaskAchievement._onTriggerBox4)},
	}
	QUIWidgetDailyTaskAchievement.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._totalBarWidth = self._ccbOwner.node_bar:getContentSize().width * self._ccbOwner.node_bar:getScaleX()
    self._totalBarPosX = self._ccbOwner.node_bar:getPositionX()

    self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.node_bar)
    if app.unlock:getUnlockDailyTask() then
    	local integralPosY = self._ccbOwner.node_integral:getPositionY()
    	self._ccbOwner.node_integral:setPositionY(integralPosY+26)
    end

    self._task_type = 0
end

function QUIWidgetDailyTaskAchievement:updateInfo()
	self._task_type = 1
	local teamLevel = remote.user.dailyTeamLevel or 1
	self._awardsData = QStaticDatabase:sharedDatabase():getDaliyTaskScoreAwardsByLevel(teamLevel, 1)
	self._getDatas = {}
	self._dailyTaskRewardInfo = remote.user.dailyTaskRewardInfo or {}
	self._dailyTaskRewardIntegral = remote.user.dailyTaskRewardIntegral or 0
	self._ccbOwner.tf_scroe:setString(self._dailyTaskRewardIntegral)
	self._totalScore = 1
	local progress = 0
	for i = 1, #self._awardsData do
		local data = self._awardsData[i]
		if self._totalScore < data.condition then
			self._totalScore = data.condition
		end
		if data ~= nil then
			self._ccbOwner["tf_"..i]:setString(data.condition.."积分")
		end
		local isGet = false
		for _,index in ipairs(self._dailyTaskRewardInfo) do
			if index == i then
				isGet = true
				break
			end
		end
		self._getDatas[i] = isGet
		if isGet == true then
			self._ccbOwner["node_light"..i]:setVisible(false)
			self._ccbOwner["node_close"..i]:setVisible(false)
			self._ccbOwner["node_open"..i]:setVisible(true)
		else
			self._ccbOwner["node_close"..i]:setVisible(true)
			self._ccbOwner["node_open"..i]:setVisible(false)
			self._ccbOwner["node_light"..i]:setVisible(self._dailyTaskRewardIntegral >= data.condition)
		end
		if self._dailyTaskRewardIntegral >= data.condition then
			progress = i
		end
	end
	for i = 1, #self._awardsData do
		self._ccbOwner["node_"..i]:setVisible(true)
		self._ccbOwner["node_"..i]:setPositionX(self._awardsData[i].condition/self._totalScore*self._totalBarWidth + self._totalBarPosX)
	end
	local posX = 0
	local stencil = self._percentBarClippingNode:getStencil()
	if progress == 4 then
		posX = 0
	else
		posX = -self._totalBarWidth + self._dailyTaskRewardIntegral/self._totalScore*self._totalBarWidth
	end
	stencil:setPositionX(posX)
end



function QUIWidgetDailyTaskAchievement:updateWeeklyInfo()
	self._task_type = 2
	local teamLevel = remote.user.level or 1
	self._awardsWeeklyData = QStaticDatabase:sharedDatabase():getDaliyTaskScoreAwardsByLevel(teamLevel, 3)
	-- QPrintTable(self._awardsWeeklyData)
	self._getDatas = {}
	self._weeklyTaskRewardInfo = remote.task.weeklyTaskRewardInfo or {}
	self._weeklyTaskRewardIntegral = remote.task.weeklyTaskRewardIntegral or 0
	self._ccbOwner.tf_scroe:setString(self._weeklyTaskRewardIntegral)
	self._totalScore = 1
	local progress = 0
	for k,v in pairs(self._awardsWeeklyData) do
		local i = tonumber(k) - WEEKLY_TASK_OFFSIDE
		local data = v
		if self._totalScore < data.condition then
			self._totalScore = data.condition
		end
		if data ~= nil then
			self._ccbOwner["tf_"..i]:setString(data.condition.."积分")
		end
		local isGet = false
		for s,index in pairs(self._weeklyTaskRewardInfo) do
			if tonumber(index) == tonumber(k) then
				isGet = true
				break
			end
		end

		self._getDatas[i] = isGet
		if isGet == true then
			self._ccbOwner["node_light"..i]:setVisible(false)
			self._ccbOwner["node_close"..i]:setVisible(false)
			self._ccbOwner["node_open"..i]:setVisible(true)
		else
			self._ccbOwner["node_close"..i]:setVisible(true)
			self._ccbOwner["node_open"..i]:setVisible(false)
			self._ccbOwner["node_light"..i]:setVisible(self._weeklyTaskRewardIntegral >= data.condition)
		end
		if self._weeklyTaskRewardIntegral >= data.condition and progress < i then
			progress = i
		end
	end
	for i = 1, 4 do
		self._ccbOwner["node_"..i]:setVisible(false)
	end

	for k,v in pairs(self._awardsWeeklyData) do
		local i = tonumber(k) - WEEKLY_TASK_OFFSIDE
		if i <= 4 then
			self._ccbOwner["node_"..i]:setVisible(true)
			self._ccbOwner["node_"..i]:setPositionX(self._awardsWeeklyData[k].condition/self._totalScore*self._totalBarWidth + self._totalBarPosX)
		end
	end
	local posX = 0
	local stencil = self._percentBarClippingNode:getStencil()
	if progress == 4 then
		posX = 0
	else
		local cur_score = self._weeklyTaskRewardIntegral
		if cur_score > self._totalScore then
			cur_score = self._totalScore
		end
		posX = -self._totalBarWidth + cur_score/self._totalScore*self._totalBarWidth
	end
	print("progress  "..progress.."   posX  "..posX.."   self._totalScore. "..self._totalScore)
	stencil:setPositionX(posX)
end


function QUIWidgetDailyTaskAchievement:boxTriggerHandler(index)
	if self._task_type == 1 then
		self:dailyBoxTriggerHandler(index)
	elseif self._task_type == 2 then
		self:weeklyBoxTriggerHandler(index)
	end
end


function QUIWidgetDailyTaskAchievement:dailyBoxTriggerHandler(index)
	local data = self._awardsData[index]
	if self._getDatas[index] == false and self._dailyTaskRewardIntegral >= data.condition then
		--请求获取
		app:getClient():dailyTaskRewardRequest(index, function (data)
			self:updateInfo()
			local awards = {}
			local prizes = data.prizes or {}
			for _,item in pairs(prizes) do
	            local typeName = remote.items:getItemType(item.type)
	            table.insert(awards, {typeName = typeName, id = item.id, count = item.count})
			end
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    			options = {awards = awards, callBack = function ()
    				remote.redpacket:openFreeTimeAlert(function()
    						remote.user:checkTeamUp()
    					end, true)
	    		end}},{isPopCurrentDialog = false} )
	    	dialog:setTitle("恭喜您获得每日任务积分奖励")
		end)
	else
		local tips = {
            {oType = "font", content = "领取条件：当每日任务累计达到",size = 20,color = ccc3(114,82,63)},
            {oType = "font", content = data.condition,size = 20,color = ccc3(109,57,29)},
            {oType = "font", content = "积分",size = 20,color = ccc3(114,82,63)},
        }
        local isShowRedpacketTips = false
        if index == 4 then
        	isShowRedpacketTips = true
        end
		app:luckyDrawAlert(data.reward_id, tips, nil, isShowRedpacketTips)
	end
end

function QUIWidgetDailyTaskAchievement:weeklyBoxTriggerHandler(index)
	local _index = index + WEEKLY_TASK_OFFSIDE
	local data = self._awardsWeeklyData[_index]
	if self._getDatas[index] == false and self._weeklyTaskRewardIntegral >= data.condition then
		--请求获取
		app:getClient():weeklyTaskRewardRequest(_index, function (data)
			self:updateWeeklyInfo()
			local awards = {}
			local prizes = data.prizes or {}
			for _,item in pairs(prizes) do
	            local typeName = remote.items:getItemType(item.type)
	            table.insert(awards, {typeName = typeName, id = item.id, count = item.count})
			end
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    			options = {awards = awards, callBack = function ()
    				remote.redpacket:openFreeTimeAlert(function()
    						remote.user:checkTeamUp()
    					end, true)
	    		end}},{isPopCurrentDialog = false} )
	    	dialog:setTitle("恭喜您获得每周任务积分奖励")
		end)
	else
		local tips = {
            {oType = "font", content = "领取条件：当每周任务累计达到",size = 20,color = ccc3(114,82,63)},
            {oType = "font", content = data.condition,size = 20,color = ccc3(109,57,29)},
            {oType = "font", content = "积分",size = 20,color = ccc3(114,82,63)},
        }
        local isShowRedpacketTips = false
        -- if index == 4 then
        -- 	isShowRedpacketTips = true
        -- end
		app:luckyDrawAlert(data.reward_id, tips, nil, isShowRedpacketTips)
	end
end

function QUIWidgetDailyTaskAchievement:_onTriggerBox1(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(1)
end

function QUIWidgetDailyTaskAchievement:_onTriggerBox2(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(2)
end

function QUIWidgetDailyTaskAchievement:_onTriggerBox3(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(3)
end

function QUIWidgetDailyTaskAchievement:_onTriggerBox4(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(4)
end

return QUIWidgetDailyTaskAchievement