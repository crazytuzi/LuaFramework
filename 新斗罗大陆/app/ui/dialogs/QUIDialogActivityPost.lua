-- @Author: xurui
-- @Date:   2018-06-13 18:16:29
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-25 16:05:17
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityPost = class("QUIDialogActivityPost", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")

function QUIDialogActivityPost:ctor(options)
	local ccbFile = "ccb/Dialog_FirstValue2.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerHeroIntroduce", callback = handler(self, self._onTriggerHeroIntroduce)},
		{ccbCallbackName = "onTriggerPreview", callback = handler(self, self._onTriggerPreview)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
        {ccbCallbackName = "onTriggerGoTo", callback = handler(self, self._onTriggerGoTo)},
        {ccbCallbackName = "onTriggerGo6", callback = handler(self, self._onTriggerGo)},
    }
    QUIDialogActivityPost.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callback
    	self._activityInfo = options.activityInfo
    	self._activityType = options.activityType
        self._endBack = options.endBack
    end
    self._ccbOwner.btn_close:setVisible(false)

    self._awards = {}    
    self:changePublicizeImage()
    self:setItemAwards()
end

function QUIDialogActivityPost:changePublicizeImage()
    if q.isEmpty(self._activityInfo) then return end
    if self._activityType == 7 then
       local newWeekFund = remote.activityRounds:getNewServiceFund()
        if newWeekFund and tonumber(newWeekFund.luckyDrawId) == 3 then
            local path = "ui/Dialog_FirstValue/Value_xfhsjj.png"
            QSetDisplayFrameByPath(self._ccbOwner.sp_7,path)
        end
    end
end

function QUIDialogActivityPost:viewDidAppear()
	QUIDialogActivityPost.super.viewDidAppear(self)    
    self:setActivityInfo()
    self:setCountdown()
end

function QUIDialogActivityPost:setItemAwards()
    self._awards = {}
    if self._activityType == 4 then
        local data = remote.activityMonthFund:getAwardsList(remote.activityMonthFund.TYPE_1) or {}
        if not next(data) then
            return
        end

        local awards = {}
        local getAwardFunc = function(index)
            if data[index] then
                local showItems = data[index]
                local awardId = showItems.award.id or showItems.award.type
                local num = showItems.award.count 
                local info = QStaticDatabase:sharedDatabase():getItemByID( awardId )
                if info and info.content then
                    local award = string.split(info.content, ";") or {}
                    for _, value in pairs(award) do
                        local itemInfo = string.split(value, "^")
                        local itemId = tonumber(itemInfo[1])
                        local itemCount = tonumber(itemInfo[2])
                        if not awards[itemId] then
                            awards[itemId] = itemCount
                        else
                            awards[itemId] = awards[itemId] + itemCount
                        end
                    end
                else
                    if not awards[awardId] then
                        awards[awardId] = num
                    else
                        awards[awardId] = awards[awardId] + num
                    end
                end
            end
        end
        getAwardFunc(#data)
        getAwardFunc(#data - 5)

        for itemId, count in pairs(awards) do
            if #self._awards > 0 then
                table.insert(self._awards, {oType = "separate", id = "ui/Activity_game/zi_huo.png", width = 30})
            end
            table.insert(self._awards, {oType = "item", id = itemId, count = count})
        end
        self._ccbOwner.awardsName:setString("累积可领豪华奖励")
    elseif self._activityType == 5 then
        local awardInfo = self._activityInfo.showAwardInfo or ""
        if string.find(awardInfo, "#") then
            local awards = string.split(awardInfo, "#") or {}
            for k, v in pairs(awards) do
                local itemInfo = string.split(v, "^")
                if #itemInfo == 2 then
                    local itemId = itemInfo[1]
                    local itemCount = tonumber(itemInfo[2])
                    table.insert(self._awards, {oType = "item", id = itemId, count = itemCount})
                end
                if k ~= #awards then
                    table.insert(self._awards, {oType = "separate", id = "ui/Activity_game/zi_huo.png", width = 30})
                end
            end
        else
            local awards = string.split(awardInfo, ";") or {}
            for k, v in pairs(awards) do
                local itemInfo = string.split(v, "^")
                if #itemInfo == 2 then
                    local itemId = itemInfo[1]
                    local itemCount = tonumber(itemInfo[2])
                    table.insert(self._awards, {oType = "item", id = itemId, count = itemCount})
                end
            end
        end
        self._ccbOwner.awardsName:setString("")
    end

    self:showItem(data)
end

function QUIDialogActivityPost:viewWillDisappear()
  	QUIDialogActivityPost.super.viewWillDisappear(self)

	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
end

function QUIDialogActivityPost:setActivityInfo()
	self._ccbOwner.node_activity_1:setVisible(self._activityType == 1)
    self._ccbOwner.node_activity_2:setVisible(self._activityType == 2)
    self._ccbOwner.node_activity_3:setVisible(self._activityType == 3)
    self._ccbOwner.node_activity_45:setVisible(self._activityType == 4 or self._activityType == 5)
    self._ccbOwner.sp_4:setVisible(self._activityType == 4)
    self._ccbOwner.sp_5:setVisible(self._activityType == 5)
    self._ccbOwner.node_activity_67:setVisible(self._activityType == 6 or self._activityType == 7)
    self._ccbOwner.sp_6:setVisible(self._activityType == 6)
    self._ccbOwner.sp_7:setVisible(self._activityType == 7)
    self._ccbOwner.node_activity_8:setVisible(self._activityType == 8)
	self._ccbOwner.node_skill:setVisible(self._activityType == 1 or self._activityType == 3)
    self._ccbOwner.btn_go:setPositionY(-120)
    self._ccbOwner.node_item:setVisible(false)
    self._ccbOwner.btn_item_preview:setVisible(false)

	if self._activityType == 2 then
        local activities = QStaticDatabase:sharedDatabase():getActivityForce()
        local targets = {}
        for _,activity in pairs(activities) do
            table.insert(targets, activity)
        end
        table.sort( targets, function (a,b)
            return a.ID < b.ID
        end )

        self._target = targets or {}
        local awards = remote.items:analysisServerItem(targets[1].awards, awards)
		self:setItemBox(awards)
        self._ccbOwner.node_time:setPosition(255, -232)
        self._ccbOwner.btn_go:setPositionY(-160)
	end
    if self._activityType == 3 then
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
        self._ccbOwner.btn_go:setPositionY(-160)
        self._ccbOwner.btn_go:setVisible(true)
    end
    if self._activityType == 4 then
        self._ccbOwner.node_time:setPosition(316, -159)
        self._ccbOwner.btn_go:setVisible(false)
        local richTextNode = QRichText.new(nil,420)
        richTextNode:setString({
            {oType = "font", content = "    双月卡魂师",size = 21,color = UNITY_COLOR.white},
            {oType = "font", content = "仅单笔充值268元", size = 21,color = UNITY_COLOR.yellow},
            {oType = "font", content = "即可领取月基金（立即返利", size = 21,color = UNITY_COLOR.white},
            {oType = "font", content = "5888钻石", size = 21,color = UNITY_COLOR.yellow},
            {oType = "font", content = "，活动期间可累计获得价值", size = 21,color = UNITY_COLOR.white},
            {oType = "font", content = "45倍", size = 21,color = UNITY_COLOR.yellow},
            {oType = "font", content = "的资源返利！）",size = 21,color = UNITY_COLOR.white},
        })
        self._ccbOwner.richText:addChild(richTextNode)
    end
    if self._activityType == 5 then
        self._ccbOwner.node_time:setPosition(316, -159)
        self._ccbOwner.btn_go:setVisible(false)
        local moneyStr = self:getMoneyString(self._activityInfo.money or 418)
        local richTextNode = QRichText.new(nil,420)
        richTextNode:setString({
            {oType = "font", content = "单笔充值", size = 21, color = UNITY_COLOR.white},
            {oType = "font", content = moneyStr, size = 21, color = UNITY_COLOR.yellow},
            {oType = "font", content = "，", size = 21, color = UNITY_COLOR.white},
            {oType = "font", content = "7", size = 21, color = UNITY_COLOR.yellow},
            {oType = "font", content = "日内可每日领取奖励（购买后立即领取第一天奖励，活动期间可累计获得", size = 21, color = UNITY_COLOR.white},
            {oType = "font", content = tostring(self._activityInfo.rebate or 30), size = 21, color = UNITY_COLOR.yellow},
            {oType = "font", content = "倍资源返利!）", size = 21, color = UNITY_COLOR.white},
        })
        self._ccbOwner.richText:addChild(richTextNode)
    end
    if self._activityType == 6 or self._activityType == 7 then
        self._ccbOwner.node_time:setPosition(310, -175)
        self._ccbOwner.btn_go:setVisible(false)
        self._ccbOwner.node_item:setVisible(false)
        self._ccbOwner.node_skill:setVisible(false)
    end
    if self._activityType == 8 then  --嘉年华弹脸
        self._ccbOwner.node_item:setVisible(false)
        self._ccbOwner.node_time:setPosition(80, -270)
        self._ccbOwner.btn_go:setVisible(false)
        self._ccbOwner.node_skill:setVisible(false)
    end
end

function QUIDialogActivityPost:getMoneyString(money)
    if tonumber(money) == 98 then
        return "98元或168元,268元,418元,648元"
    elseif tonumber(money) == 418 then
        return "418元或648元"
    else
        return tostring(money).."元"
    end
end

function QUIDialogActivityPost:setItemBox(awards)
    self._ccbOwner.node_item:setVisible(true)
    self._ccbOwner.btn_item_preview:setVisible(true)
	for i = 1, 4 do
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
    
    if index <= 4 then 
        local itemGap = 112
        self._ccbOwner.node_item:setPositionX( 50 + (5-index) * itemGap / 2 )
    end
end

function QUIDialogActivityPost:setCountdown(endTime)
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
        if self._activityType == 4 then
            endTime = (self._activityInfo.awardStartAt or 0)/1000 - currTime
        elseif self._activityType == 5 then
            -- local buyDayNum = remote.activityRounds:getWeekFund():getActiveDayNum()
            -- endTime = (self._activityInfo.startAt or 0)/1000 + buyDayNum*DAY - currTime
            local buyEndAt = remote.activityRounds:getWeekFund():getBuyEndAt()
            endTime = buyEndAt - currTime
        elseif self._activityType == 6 or self._activityType == 7 then
            local buyDayNum = remote.activityRounds:getNewServiceFund():getActiveDayNum()
            endTime = (self._activityInfo.start_at or 0)/1000 + buyDayNum*DAY - currTime
            if self._activityType == 7 then
                self._ccbOwner.tf_time_title:setString("激活倒计时：")
            else
                self._ccbOwner.tf_time_title:setString("购买倒计时：")
            end
        elseif self._activityType == 8 then
            endTime = (remote.user.openServerTime or 0)/1000 + remote.activity.TIME1 * DAY - currTime
        else
            endTime = (self._activityInfo.end_at or 0)/1000 - currTime
        end
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

function QUIDialogActivityPost:_onTriggerHeroIntroduce(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_introduce) == false then return end
    app.sound:playSound("common_small")

    if self._activityType == 1 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroduce",
            options = {bossId = 3587, enemyTips = 1000}})
    elseif self._activityType == 3 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroduce",
            options = {bossId = 1016, enemyTips = 1002}})
    end
end

function QUIDialogActivityPost:_onTriggerPreview()
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
        options = {chooseType = 2, awards = self._awards,  explainStr = "获得以下奖励", titleText = "奖   励"}},{isPopCurrentDialog = false})
end

function QUIDialogActivityPost:_onTriggerGoTo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_goto) == false then return end

    self:_onTriggerGo()
end

function QUIDialogActivityPost:_onTriggerGo( event, target )
    if q.buttonEventShadow(event, self._ccbOwner.btn_goto_6) == false then return end

    if target == self._ccbOwner.btn_go then
        if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
    end
    app.sound:playSound("common_small")

    self:popSelf()

    local themeId = self._activityInfo.subject or 1
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel",
        options = {themeId = themeId, curActivityID = self._activityInfo.activityId}}, {isPopCurrentDialog = true})
end

function QUIDialogActivityPost:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogActivityPost:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogActivityPost:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback(self._endBack)
	end
end

function QUIDialogActivityPost:showItem()
    local count = #self._awards
    local width = 0
    for i, v in pairs(self._awards) do
        width = width + (v.width or 100)
    end

    local posX = 220-width/2
    if posX < 0 then 
        posX = 0 
    end
    self._ccbOwner.node_listView:setPositionX(posX)
    
    if not self._itemListView then
        local function showItemInfo(x, y, itemBox, listView)
            app.tip:itemTip(itemBox._itemType, itemBox._itemID)
        end

        local cfg = {
            renderItemCallBack = function( list, index, info )
                -- body
                local isCacheNode = true
                local data = self._awards[index]
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetQlistviewItem.new()
                    isCacheNode = false
                end
                self:setItemInfo(item,data,index)
                info.item = item
                info.size = item._ccbOwner.parentNode:getContentSize()

                --注册事件
                if data.oType == "item" then
                    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)
                end

                return isCacheNode
            end,
            spaceX = 4,
            isVertical = false,
            enableShadow = false,
            totalNumber = #self._awards,
        }  
        self._itemListView = QListView.new(self._ccbOwner.itemListView,cfg)
    else
        self._itemListView:reload({totalNumber = #self._awards})
    end
end

function QUIDialogActivityPost:setItemInfo( item, data ,index)
    if data.oType == "separate" then
        if not item._separate then
            local sprite = CCSprite:create(data.id)
            item._separate = sprite
            item._ccbOwner.parentNode:addChild(sprite)
        else
            local frame  = QSpriteFrameByPath(data.id)
            if frame then
                item._separate:setDisplayFrame(frame)
            end
        end

        local width = data.width or 30
        item._ccbOwner.parentNode:setContentSize(CCSizeMake(width,110))
        item._separate:setPosition(width/2, 55)
    else
        if not item._itemBox then
            item._itemBox = QUIWidgetItemsBox.new()
            item._itemBox:showBoxEffect("effects/leiji_light.ccbi", true, 0, 0, 0.6)
            item._itemBox:setPosition(ccp(50,57))
            item._itemBox:setPromptIsOpen(true)
            item._ccbOwner.parentNode:addChild(item._itemBox)
            item._ccbOwner.parentNode:setContentSize(CCSizeMake(100,110))
        end
        item._itemBox:setGoodsInfoByID(data.id, data.count)
    end
end

return QUIDialogActivityPost
