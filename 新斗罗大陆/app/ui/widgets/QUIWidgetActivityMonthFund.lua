--[[	
	文件名称：QUIWidgetActivityMonthFund.lua
	创建时间：2017-01-18 14:24:19
	作者：nieming
	描述：QUIWidgetActivityMonthFund
]]

local QUIWidget = import(".QUIWidget") 
local QUIWidgetActivityMonthFund = class("QUIWidgetActivityMonthFund", QUIWidget)
local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIWidgetActivityMonthFund:ctor(options)
	local ccbFile = "Widget_yuejijin.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, QUIWidgetActivityMonthFund._onTriggerGo)},
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, QUIWidgetActivityMonthFund._onTriggerBuy)},
		{ccbCallbackName = "onTriggerPreview", callback = handler(self, QUIWidgetActivityMonthFund._onTriggerPreview)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetActivityMonthFund._onTriggerRule)},
	}
	QUIWidgetActivityMonthFund.super.ctor(self,ccbFile,callBacks,options)

   	if not options then
   		options = {}
   	end

    self._ccbOwner.node_btn:setPositionX(display.ui_width/2)
    self._ccbOwner.node_tf_time:setPositionY(-display.height/2)
    
    self.parent = options.parent
end

function QUIWidgetActivityMonthFund:setInfo(info)
	self._info = info
	local status = remote.activityMonthFund:getMonthFundStatus(info.activityId)
    if status == 0 then
    	-- 已购买
    	self._ccbOwner.alreadyBuyNode:setVisible(true)
    	self._ccbOwner.activeNode:setVisible(false)
    	self._ccbOwner.buyNode:setVisible(false)
    	self._ccbOwner.tf_buy:setString("")
    elseif status == 1 then
    	-- 待激活（跳转到月卡）
    	self._ccbOwner.alreadyBuyNode:setVisible(false)
    	self._ccbOwner.activeNode:setVisible(true)
    	self._ccbOwner.tf_buy:setString("激活双月卡可购买")
    	self._ccbOwner.buyNode:setVisible(false)
    else
    	-- 待购买（月卡已经激活）
    	self._ccbOwner.alreadyBuyNode:setVisible(false)
    	self._ccbOwner.activeNode:setVisible(false)
    	self._ccbOwner.buyNode:setVisible(true)
    end

    local fontSize = 18
    local color1 = ccc3(99, 9, 0)
    local color2 = ccc3(195, 26, 0)
    local richTextNode = QRichText.new(nil,450)
    richTextNode:setAnchorPoint(ccp(0, 1))
    if info.activityId == remote.activityMonthFund.TYPE_1 then
        QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("month_fund_title_268"))
    	richTextNode:setString({
            {oType = "font", content = "双月卡激活时，单笔充值",size = fontSize,color = color1},
            {oType = "font", content = "268元", size = fontSize,color = color2},
            {oType = "font", content = "，即可领取月基金（立即领取", size = fontSize,color = color1},
            {oType = "font", content = "5888钻", size = fontSize,color = color2},
            {oType = "font", content = "，累计", size = fontSize,color = color1},
            {oType = "font", content = "60倍", size = fontSize,color = color2},
            {oType = "font", content = "返利！）",size = fontSize,color = color1},
            {oType = "wrap"},
            {oType = "font", content = "单笔充值418元或648元可",size = fontSize,color = color1},
            {oType = "font", content = "同时激活", size = fontSize,color = color2},
            {oType = "font", content = "268月基金和168月基金！",size = fontSize,color = color1},
        })
        if status == 2 then
        	self._ccbOwner.tf_buy:setString("购买后可立即领取5888钻石奖励")
        end
	elseif info.activityId == remote.activityMonthFund.TYPE_2 then
        QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("month_fund_title_168"))
    	richTextNode:setString({
            {oType = "font", content = "双月卡激活时，单笔充值",size = fontSize,color = color1},
            {oType = "font", content = "168元", size = fontSize,color = color2},
            {oType = "font", content = "，即可领取月基金（立即领取", size = fontSize,color = color1},
            {oType = "font", content = "3888钻", size = fontSize,color = color2},
            {oType = "font", content = "，累计", size = fontSize,color = color1},
            {oType = "font", content = "57倍", size = fontSize,color = color2},
            {oType = "font", content = "返利！）",size = fontSize,color = color1},
            {oType = "wrap"},
            {oType = "font", content = "单笔充值418元或648元可",size = fontSize,color = color1},
            {oType = "font", content = "同时激活", size = fontSize,color = color2},
            {oType = "font", content = "268月基金和168月基金！",size = fontSize,color = color1},
        })
        if status == 2 then
        	self._ccbOwner.tf_buy:setString("购买后可立即领取3888钻石奖励")
        end
	end
	self._ccbOwner.richText:addChild(richTextNode)

	local curTime = q.serverTime()
	self._time = remote.activityMonthFund.awardStartTime - curTime

	self._schedulerID = scheduler.scheduleGlobal(handler(self, self._timeUpdate), 1)

	if self._time < 0 then
		self._time = 0
	end
	-- self._ccbOwner.leftTime:setString(string.format("活动倒计时：%s", q.timeToHourMinuteSecond(self._time)))
	self._ccbOwner.leftTime:setString(string.format("%s", self:timeToDayHourMinute(self._time)))

	self:showItem()
end

function QUIWidgetActivityMonthFund:_timeUpdate(  )
	self._time = self._time - 1
	if self._time < 0 then
		self._time = 0
	end
	self._ccbOwner.leftTime:setString(string.format("%s", self:timeToDayHourMinute(self._time)))
end


function QUIWidgetActivityMonthFund:timeToDayHourMinute(time)
    local day = math.floor(time/(DAY))
    time = time % (DAY)
    return day.."天"..q.timeToHourMinuteSecond(time)
end

function QUIWidgetActivityMonthFund:showItem()
	local data = remote.activityMonthFund:getAwardsList(self._info.activityId)
	if data == nil or #data  == 0 then return end

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
    if self._info.activityId == remote.activityMonthFund.TYPE_1 then --268月基金
        getAwardFunc(#data)
        getAwardFunc(#data - 10)
        -- getAwardFunc(#data - 15)
    elseif self._info.activityId == remote.activityMonthFund.TYPE_2 then --168月基金
        getAwardFunc(#data)
        -- getAwardFunc(#data - 10)
    end    
    
    self._awards = {}
    for itemId, count in pairs(awards) do
        if #self._awards > 0 then
            table.insert(self._awards, {oType = "separate", id = QResPath("activity_huo"), width = 30})
        end
        table.insert(self._awards, {oType = "item", id = itemId, count = count})
    end
	if not self._itemListView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
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
                list:registerItemBoxPrompt(index, 1, item._itemBox)
	         
	            return isCacheNode
	        end,
	        spaceX = 4,
	        isVertical = false,
            autoCenter = true,
	        enableShadow = false,
	        totalNumber = #self._awards,

	    }  
    	self._itemListView = QListView.new(self._ccbOwner.itemListView,cfg)
	else
		self._itemListView:reload({totalNumber = #self._awards})
	end

end

function QUIWidgetActivityMonthFund:setItemInfo( item, data ,index)
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

function QUIWidgetActivityMonthFund:_onTriggerGo(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
	app.sound:playSound("common_small")
	if self.parent then
		self.parent:jumpTo("a_yueka")
	end
end

function QUIWidgetActivityMonthFund:_onTriggerBuy(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy) == false then return end
	app.sound:playSound("common_small")
	local str = ""
    if self._info.activityId == remote.activityMonthFund.TYPE_1 then
    	str = "268"
	elseif self._info.activityId == remote.activityMonthFund.TYPE_2 then
		str = "168"
	end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge", options={highLightValues={[str] = true}}})

end

function QUIWidgetActivityMonthFund:_onTriggerPreview()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityMonthFundPreview", options = {activityId = self._info.activityId}})

end

function QUIWidgetActivityMonthFund:_onTriggerRule()
	app.sound:playSound("common_small")
    local helpType = "activity_monthfund"
    if self._info.activityId == remote.activityMonthFund.TYPE_1 then
        helpType = "activity_monthfund"
    elseif self._info.activityId == remote.activityMonthFund.TYPE_2 then
        helpType = "activity_monthfund2"
    end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityMonthFundHelp", 
        options = {helpType = helpType}})
end

function QUIWidgetActivityMonthFund:onEnter()
end

function QUIWidgetActivityMonthFund:onExit()
	if self._schedulerID then
		scheduler.unscheduleGlobal(self._schedulerID)
		self._schedulerID  = nil
	end
end

return QUIWidgetActivityMonthFund
