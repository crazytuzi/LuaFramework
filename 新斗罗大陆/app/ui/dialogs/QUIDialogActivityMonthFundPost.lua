--
-- Kumo.Wang
-- 月基金弹脸界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityMonthFundPost = class("QUIDialogActivityMonthFundPost", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")

function QUIDialogActivityMonthFundPost:ctor(options)
	local ccbFile = "ccb/Dialog_MonthFund_Poster.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerGoTo", callback = handler(self, self._onTriggerGoTo)},
    }
    QUIDialogActivityMonthFundPost.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_goto)

    if options then
    	self._callback = options.callback
    	self._activityInfo = options.activityInfo
        self._endBack = options.endBack
    end

    self._awards = {}    
    self:setItemAwards()
end

function QUIDialogActivityMonthFundPost:viewDidAppear()
	QUIDialogActivityMonthFundPost.super.viewDidAppear(self)    
    self:setActivityInfo()
    self:setCountdown()
end

function QUIDialogActivityMonthFundPost:viewWillDisappear()
    QUIDialogActivityMonthFundPost.super.viewWillDisappear(self)

    if self._timeScheduler then
        scheduler.unscheduleGlobal(self._timeScheduler)
        self._timeScheduler = nil
    end
end

function QUIDialogActivityMonthFundPost:setItemAwards()
    self._awards = {}

    local data = {}
    if self._activityInfo.activityId == remote.activityMonthFund.TYPE_1 then
        data = remote.activityMonthFund:getAwardsList(remote.activityMonthFund.TYPE_1) or {}
    elseif self._activityInfo.activityId == remote.activityMonthFund.TYPE_2 then
        data = remote.activityMonthFund:getAwardsList(remote.activityMonthFund.TYPE_2) or {}
    end

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
    if self._activityInfo.activityId == remote.activityMonthFund.TYPE_1 then --268月基金
        getAwardFunc(#data)
        getAwardFunc(#data - 10)
        -- getAwardFunc(#data - 15)
    elseif self._activityInfo.activityId == remote.activityMonthFund.TYPE_2 then --168月基金
        getAwardFunc(#data)
        -- getAwardFunc(#data - 10)
    end

    for itemId, count in pairs(awards) do
        if #self._awards > 0 then
            table.insert(self._awards, {oType = "separate", id = "ui/Activity_game/zi_huo.png", width = 30})
        end
        table.insert(self._awards, {oType = "item", id = itemId, count = count})
    end
    self._ccbOwner.awardsName:setString("累积可领豪华奖励")

    self:showItem(data)
end

function QUIDialogActivityMonthFundPost:showItem()
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
                local isCacheNode = true
                local data = self._awards[index]
                local item = list:getItemFromCache(data.oType)
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
        self._itemListView = QListView.new(self._ccbOwner.itemListView, cfg)
    else
        self._itemListView:reload({totalNumber = #self._awards})
    end
end

function QUIDialogActivityMonthFundPost:setItemInfo( item, data ,index)
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

function QUIDialogActivityMonthFundPost:setActivityInfo()
    if self._activityInfo.activityId == remote.activityMonthFund.TYPE_1 then
        QSetDisplayFrameByPath(self._ccbOwner.sp_bg, QResPath("month_fund_poster_bg_268"))
        self._ccbOwner.sp_bg:setPosition(ccp(0, 10))

        self._ccbOwner.richText:removeAllChildren()
        local richTextNode = QRichText.new(nil, 450)
        richTextNode:setString({
            {oType = "font", content = "    双月卡激活时，单笔充值",size = 20,color = COLORS.a},
            {oType = "font", content = "268元", size = 20,color = COLORS.b},
            {oType = "font", content = "即可领取月基金（立即领取", size = 20,color = COLORS.a},
            {oType = "font", content = "5888钻", size = 20,color = COLORS.b},
            {oType = "font", content = "，累计", size = 20,color = COLORS.a},
            {oType = "font", content = "60倍", size = 20,color = COLORS.b},
            {oType = "font", content = "返利！）",size = 20,color = COLORS.a},
            {oType = "wrap"},
            {oType = "font", content = "单笔充值418元或648元可",size = 20,color = COLORS.a},
            {oType = "font", content = "同时激活", size = 20,color = COLORS.b},
            {oType = "font", content = "268月基金和168月基金！",size = 20,color = COLORS.a},
        })
        richTextNode:setAnchorPoint(ccp(0, 0))
        self._ccbOwner.richText:addChild(richTextNode)
    elseif self._activityInfo.activityId == remote.activityMonthFund.TYPE_2 then
        QSetDisplayFrameByPath(self._ccbOwner.sp_bg, QResPath("month_fund_poster_bg_168"))
        self._ccbOwner.sp_bg:setPosition(ccp(0, 0))

        self._ccbOwner.richText:removeAllChildren()
        local richTextNode = QRichText.new(nil, 450)
        richTextNode:setString({
            {oType = "font", content = "    双月卡激活时，单笔充值",size = 20,color = COLORS.a},
            {oType = "font", content = "168元", size = 20,color = COLORS.b},
            {oType = "font", content = "即可领取月基金（立即领取", size = 20,color = COLORS.a},
            {oType = "font", content = "3888钻", size = 20,color = COLORS.b},
            {oType = "font", content = "，累计", size = 20,color = COLORS.a},
            {oType = "font", content = "57倍", size = 20,color = COLORS.b},
            {oType = "font", content = "返利！）",size = 20,color = COLORS.a},
            {oType = "wrap"},
            {oType = "font", content = "单笔充值418元或648元可",size = 20,color = COLORS.a},
            {oType = "font", content = "同时激活", size = 20,color = COLORS.b},
            {oType = "font", content = "268月基金和168月基金！",size = 20,color = COLORS.a},
        })
        richTextNode:setAnchorPoint(ccp(0, 0))
        self._ccbOwner.richText:addChild(richTextNode)
    end
end

function QUIDialogActivityMonthFundPost:setCountdown(endTime)
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
    	local endTime = (self._activityInfo.awardStartAt or 0)/1000 - currTime

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

function QUIDialogActivityMonthFundPost:_onTriggerGoTo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_goto) == false then return end
    app.sound:playSound("common_small")

    self:popSelf()
    local themeId = self._activityInfo.subject or 1
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel",
        options = {themeId = themeId, curActivityID = self._activityInfo.activityId}}, {isPopCurrentDialog = true})
end

function QUIDialogActivityMonthFundPost:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogActivityMonthFundPost:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback(self._endBack)
	end
end


return QUIDialogActivityMonthFundPost
