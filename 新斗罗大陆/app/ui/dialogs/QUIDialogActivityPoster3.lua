--
-- Kumo.Wang
-- 活動彈臉三
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityPoster3 = class("QUIDialogActivityPoster3", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogActivityPoster3:ctor(options)
	local ccbFile = "ccb/Dialog_Activity_Poster_3.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerHeroIntroduce", callback = handler(self, self._onTriggerHeroIntroduce)},
		{ccbCallbackName = "onTriggerPreview", callback = handler(self, self._onTriggerPreview)},
		{ccbCallbackName = "onTriggerGoto", callback = handler(self, self._onTriggerGoto)},
    }
    QUIDialogActivityPoster3.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callback = options.callback
    	self._activityInfo = options.activityInfo
        self._endBack = options.endBack
    end

    self._awards = {}    
end

function QUIDialogActivityPoster3:viewDidAppear()
	QUIDialogActivityPoster3.super.viewDidAppear(self)    
    self:setActivityInfo()
    self:setCountdown()
end

function QUIDialogActivityPoster3:viewWillDisappear()
  	QUIDialogActivityPoster3.super.viewWillDisappear(self)

	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
end

function QUIDialogActivityPoster3:setActivityInfo()
    self._ccbOwner.node_item:setVisible(false)
    self._ccbOwner.btn_item_preview:setVisible(false)
    self._ccbOwner.node_skill:setVisible(false)

    local awards1, awards2 = {}, {}
    local targets = {}
    for _,target in pairs(self._activityInfo.targets) do
        table.insert(targets, target)
    end
    table.sort( targets, function (a,b)
        return (a.value2 or 0) < (b.value2 or 0)
    end )
    remote.items:analysisServerItem(targets[1].awards, awards1)
    remote.items:analysisServerItem(targets[2].awards, awards2)
    local checkRepeat = function(award)
        local find = false
        for _, v in ipairs(awards1) do
            if (v.id and v.id == award.id) or (v.id == nil and v.typeName == award.typeName) then
                v.count = v.count + award.count
                find = true
                break
            end
        end

        if find == false then
            table.insert(awards1, award)
        end
    end
    for _, v in ipairs(awards2) do
        checkRepeat(v)
    end

    self:setItemBox(awards1)
end

function QUIDialogActivityPoster3:setItemBox(awards)
    self._ccbOwner.node_item:setVisible(true)
    self._ccbOwner.btn_item_preview:setVisible(true)
	for i = 1, 2 do
        if self._ccbOwner["node"..i] then
            self._ccbOwner["node"..i]:setVisible(false)
        end
    end

    local index = 1
    for k, v in ipairs(awards) do
        if self._ccbOwner["node"..index] then
            local itemId = v.id
            local itemCount = v.count
            local itemType = v.typeName

            local box = QUIWidgetItemsBox.new()
            box:setGoodsInfo(tonumber(itemId), itemType, itemCount, true)
            self._ccbOwner["node"..index]:addChild(box, -1)
            self._ccbOwner["node"..index]:setVisible(true)
            index = index + 1
            table.insert(self._awards, {oType = "item", id = itemId, type = itemType, count = itemCount})
        end
    end
end

function QUIDialogActivityPoster3:setCountdown(endTime)
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end

	self._converFun = function (time)
    	local str = ""
    	time = time%DAY
    	local hour = math.floor(time/HOUR)
    	hour = hour < 10 and "0"..hour or hour
    	time = time%HOUR
    	local min = math.floor(time/MIN)
    	min = min < 10 and "0"..min or min
    	time = time%MIN
    	local sec = math.floor(time)
    	sec = sec < 10 and "0"..sec or sec
    	str = hour..":"..min..":"..sec

    	return str
    end
    self._fun = function ()
    	local currTime = q.serverTime()
    	local endTime = 0
        endTime = (self._activityInfo.end_at or 0)/1000 - currTime

		if endTime > 0 then
    		self._ccbOwner.tf_time:setString(math.floor(endTime/DAY).."天 "..self._converFun(endTime))
    	else
    		if self._timeScheduler then
    			scheduler.unscheduleGlobal(self._timeScheduler)
    			self._timeScheduler = nil
    		end
    		self:_backClickHandler()
    	end
    end
    self._timeScheduler = scheduler.scheduleGlobal(self._fun, 1)
    self._fun()
end

function QUIDialogActivityPoster3:_onTriggerHeroIntroduce(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_introduce) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroduce",
        options = {bossId = 1016, enemyTips = 1002}})
end

function QUIDialogActivityPoster3:_onTriggerPreview()
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
        options = {chooseType = 2, awards = self._awards,  explainStr = "获得以下奖励", titleText = "奖   励"}},{isPopCurrentDialog = false})
end

function QUIDialogActivityPoster3:_onTriggerGoto(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_goto) == false then return end
    app.sound:playSound("common_small")

    self:popSelf()

    local themeId = self._activityInfo.subject or 1
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel",
        options = {themeId = themeId, curActivityID = self._activityInfo.activityId}}, {isPopCurrentDialog = true})
end

function QUIDialogActivityPoster3:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogActivityPoster3:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_close) == false then return end
    if e then
        app.sound:playSound("common_close")
    end
	self:playEffectOut()
end

function QUIDialogActivityPoster3:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback(self._endBack)
	end
end

return QUIDialogActivityPoster3
