--
-- Kumo.Wang
-- 嘉年華+半月慶典主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityForSeven = class("QUIDialogActivityForSeven", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QActivity = import("...utils.QActivity")
local QListView = import("...views.QListView")

local QUIWidgetActivityItemForSeven = import("..widgets.QUIWidgetActivityItemForSeven")
local QUIWidgetActivityExchangeForSeven = import("..widgets.QUIWidgetActivityExchangeForSeven")
local QUIWidgetActivityForSevenProgress = import("..widgets.QUIWidgetActivityForSevenProgress")
local QUIWidgetActivityForSevenButton = import("..widgets.QUIWidgetActivityForSevenButton")
local QUIWidgetActivitySevenRushBuy = import("..widgets.QUIWidgetActivitySevenRushBuy")

function QUIDialogActivityForSeven:ctor(options)
	local ccbFile = "ccb/Dialog_New_SevenDayAcitivity.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
        {ccbCallbackName = "onTriggerPointsClick", callback = handler(self, self._onTriggerPointsClick)},
        {ccbCallbackName = "onTriggerAwardView", callback = handler(self, self._onTriggerAwardView)},
    }
    QUIDialogActivityForSeven.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
	page:setScalingVisible(true)
    page.topBar:showWithMainPage()

	CalculateUIBgSize(self._ccbOwner.sp_background)
	self._ccbOwner.btn_renwu:setEnabled(false)

	self._virtualFrames = {}
	self._emptyFrames = {}

    if not options then
    	options = {}
    end

    self._selectDay = options.curselectDay
    self._selectNumber = options.curSelectNum
    self._curActivityType = options.curActivityType or 1
    self._isSelectPreviewDay = false            --是否选中明天的页签（预览奖励）

    self._jifenAwardsTbl = {}

    self._ccbOwner.btn_7dayBtn:setVisible(self._curActivityType == 1)
    self._ccbOwner.btn_14dayBtn:setVisible(self._curActivityType == 2)

    self:_initView()
    self:_initMenuData()
	self:_getData()
end

function QUIDialogActivityForSeven:viewDidAppear()
    QUIDialogActivityForSeven.super.viewDidAppear(self)
    self._activityProxy = cc.EventProxy.new(remote.activity)
    self._activityProxy:addEventListener(QActivity.EVENT_UPDATE, handler(self, self.onEvent))
    self._activityProxy:addEventListener(QActivity.EVENT_COMPLETE_UPDATE, handler(self, self.onEvent))
    self._activityProxy:addEventListener(QActivity.EVENT_CHANGE, handler(self, self.onEvent))
   	self._activityProxy:addEventListener(QActivity.EVENT_128RECHARGE_UPDATE, handler(self, self.refreshInfo))
    self:_updateInfo()
    -- self:_showProgressBar()
    self._ccbOwner.sp_jifen_tips:setVisible(self:checkJifenTips())
    
    self:addBackEvent(true)
end

function QUIDialogActivityForSeven:viewWillDisappear()
    QUIDialogActivityForSeven.super.viewWillDisappear(self)
    self._activityProxy:removeAllEventListeners()
   
    if self._timeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._timeHandler)
    end
    self:removeBackEvent()
end

function QUIDialogActivityForSeven:getCurSelectNumber(  )
	return self._selectNumber
end

function QUIDialogActivityForSeven:getCurActivityType(  )
	return self._curActivityType
end

function QUIDialogActivityForSeven:getContentListView(  )
    return self._contentListView
end

function QUIDialogActivityForSeven:_initView()
	if self._curActivityType == 1 then
	 	-- 1~7天
	 	QSetDisplayFrameByPath(self._ccbOwner.sp_avatar_img, QResPath("jianianhua_renwu_bg"))
	else 
		-- 8～14天
	 	QSetDisplayFrameByPath(self._ccbOwner.sp_avatar_img, QResPath("banyueqingdian_renwu_bg"))
	end
end

function QUIDialogActivityForSeven:_getData()
	local tbl = {}
    if self._curActivityType == 1 then
		tbl[remote.activity.TYPE_ACTIVITY_FOR_SEVEN] = 1
	elseif self._curActivityType == 2 then
		tbl[remote.activity.TYPE_ACTIVITY_FOR_SEVEN_2] = 1
	end
    self._data = remote.activity:getActivityData(tbl)
    
    if self._data ~= nil then
    	for _,value in pairs(self._data) do
    		if value.params ~= nil then
    			local dayValues = string.split(value.params, ",")
    			value.day = tonumber(dayValues[1])
    			value.number = tonumber(dayValues[2])
    			value.paramsValue = dayValues
    		end
    	end
    end
    -- QPrintTable(self._data)
end

function QUIDialogActivityForSeven:checkJifenTips()
	return remote.activity:checkActivitySevenAwrdsTip(self._curActivityType)
end

function QUIDialogActivityForSeven:getLockDay()
	local activityType = QActivity.TYPE_ACTIVITY_FOR_SEVEN 
	if self._curActivityType == 2 then
		activityType = QActivity.TYPE_ACTIVITY_FOR_SEVEN_2
	end
	return remote.activity:getActivitySevenUnlockDay(activityType)
end

function QUIDialogActivityForSeven:refreshInfo( )
	local activityType = QActivity.TYPE_ACTIVITY_FOR_SEVEN 
	local awardTime = QActivity.TIME2
	if self._curActivityType == 2 then
		activityType = QActivity.TYPE_ACTIVITY_FOR_SEVEN_2
		awardTime = QActivity.TIME5
	end
    self._unlockDay = self:getLockDay()

	if self._specialDialog then
        self._specialDialog:popSelf()
        self._specialDialog = nil
    end

    self:_checkDayTips()
    self:_selectDayHandler(self._selectDay or self._unlockDay)
end
function QUIDialogActivityForSeven:_updateInfo()
	local activityType = QActivity.TYPE_ACTIVITY_FOR_SEVEN 
	local awardTime = QActivity.TIME2
	if self._curActivityType == 2 then
		activityType = QActivity.TYPE_ACTIVITY_FOR_SEVEN_2
		awardTime = QActivity.TIME5
	end
    self._unlockDay = self:getLockDay()

    self:_checkDayTips()
    self:_selectDayHandler(self._selectDay or self._unlockDay)

    self._openTime = (remote.user.openServerTime or 0)/1000
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
    	local endTime = self._openTime + remote.activity.TIME1 * DAY - currTime
    	local activityEndTime = self._openTime + remote.activity.TIME2 * DAY
    	local awardTime = (remote.activity.TIME1 - remote.activity.TIME2) * DAY
    	if self._curActivityType == 2 then
    		endTime = self._openTime + remote.activity.TIME5 * DAY - currTime
    		activityEndTime = self._openTime + remote.activity.TIME6 * DAY
    		awardTime = (remote.activity.TIME5 - remote.activity.TIME6) * DAY
    	end

	    if currTime > activityEndTime then
	    	self._ccbOwner.tf_time_desc:setString("活动领奖时间：")
	    	awardTime = 0
	    else
	    	self._ccbOwner.tf_time_desc:setString("活动结束时间：")
		end

		if endTime > 0 then
			local time = endTime - awardTime
			local timeStr = q.timeToDayHourMinute(time)
			self._ccbOwner.tf_hour:setString(timeStr)
    		-- self._ccbOwner.tf_hour:setString(self._converFun(time))
    		-- self._ccbOwner.tf_day:setString(math.floor(time/DAY))
    	else
    		if self._timeHandler then
    			scheduler.unscheduleGlobal(self._timeHandler)
    			self._timeHandler = nil
    		end
    		self._ccbOwner.tf_hour:setString("已结束")
    	end
    end
    self._timeHandler = scheduler.scheduleGlobal(self._fun, 1)
    self._fun()
end

function QUIDialogActivityForSeven:_showProgressBar()
	if self._widgetProgress then
		if self._widgetProgress.getInfo then
			local widgetActivityType = self._widgetProgress:getInfo()
			if widgetActivityType == self._curActivityType then
				if self._widgetProgress.refreshInfo then
					self._widgetProgress:refreshInfo()
					return
				end
			else
				if self._widgetProgress.setInfo then
					self._widgetProgress:setInfo(self._curActivityType)
					return
				end
			end
		end
	end

	self._ccbOwner.node_progress:removeAllChildren()
	self._widgetProgress = QUIWidgetActivityForSevenProgress.new()
	self._widgetProgress:setInfo(self._curActivityType)
	self._ccbOwner.node_progress:addChild(self._widgetProgress)
end


function QUIDialogActivityForSeven:_initMenuData()
	self._menuData = {}
	local startIndex = 1
	local endIndex = 7
	if self._curActivityType == 1 then
		startIndex = 1
		endIndex = 7
	else
		startIndex = 8
		endIndex = 14
	end
	for i = startIndex, endIndex, 1 do
		table.insert(self._menuData, i)
	end
	table.sort(self._menuData, function(a, b)
		return a < b
	end)
	self:_initMenuListView()
end

function QUIDialogActivityForSeven:_initMenuListView()
	if not self._menuBtnListView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local itemData = self._menuData[index]
	            local item = list:getItemFromCache()
	            if not item then
            		item = QUIWidgetActivityForSevenButton.new()
            		item:addEventListener(QUIWidgetActivityForSevenButton.EVENT_CLICK, handler(self, self._menuBtnClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            local lockDay = self:getLockDay()
	            item:setPreviewStated(lockDay + 1 == itemData)
	            info.item = item
	            info.size = item:getContentSize()
                list:registerBtnHandler(index, "btn_click", "onTriggerClick")
	            return isCacheNode
	        end,
	        isVertical = true,
	        enableShadow = false,
	      	ignoreCanDrag = false,
	        totalNumber = #self._menuData,
		}
		self._menuBtnListView = QListView.new(self._ccbOwner.node_menu_list_view, cfg)
	else
		self._menuBtnListView:reload({totalNumber = #self._menuData})
	end
end

function QUIDialogActivityForSeven:_menuBtnClickHandler(event)
	app.sound:playSound("common_small")
	self._selectNumber = 1
	self:_selectDayHandler(event.day)
end

function QUIDialogActivityForSeven:_setMenuBtnStated(selectDay)
	if not self._menuBtnListView then return end

	local index = 1
	while true do
		local item = self._menuBtnListView:getItemByIndex(index)
		if item then
			item:setSelect(false)
			if item.getInfo and item:getInfo() == selectDay then
				if item.setSelect then
					item:setSelect(true)
				end
			end
			index = index + 1
		else
			break
		end
	end
end

--列表按鈕小紅點和解鎖狀態
function QUIDialogActivityForSeven:_checkDayTips()
	if not self._menuBtnListView or not self._unlockDay then return end

	local index = 1
	while true do
		local item = self._menuBtnListView:getItemByIndex(index)
		if item then
			local day = item:getInfo()
			if day > self._unlockDay then
				item:setRedTips(false)
			else
				item:setRedTips(remote.activity:checkActivitySevenDayIsComplete(day))
			end
			item:setUnlock(day > (self._unlockDay + 1))
			index = index + 1
		else
			break
		end
	end
end

--選擇列表按鈕
function QUIDialogActivityForSeven:_selectDayHandler(day)
	if self._unlockDay + 1 < day then
		self:_setMenuBtnStated(self._selectDay)
        app.tip:floatTip(string.format("开服第%s天开启!", day)) 
		return
	else
    	self:_setMenuBtnStated(day)
	end
	self._isSelectPreviewDay = (self._unlockDay + 1 == day)
	local selectNum = nil
	self._selectDay = day
	local index = 1
	while true do
		local data = self:getActivityByDayAndNumber(self._selectDay, index)
		if data then
			local node = self._ccbOwner["node_btn_"..index]
			if node then
				node:setVisible(true)
			end
			if selectNum == nil then
				selectNum = index
			else
				selectNum = math.min(selectNum,index)
			end
			self._ccbOwner["btn_"..index]:setTitleForState(CCString:create(data.title), CCControlStateNormal)
			self._ccbOwner["btn_"..index]:setTitleForState(CCString:create(data.title), CCControlStateHighlighted)
			self._ccbOwner["btn_"..index]:setTitleForState(CCString:create(data.title), CCControlStateDisabled)
			index = index + 1
		else
			local node = self._ccbOwner["node_btn_"..index]
			if node then
				node:setVisible(false)
				index = index + 1
			else
				break
			end
		end
	end

	self:autoSunMenuBtnLayerOut()
	if self:checkMenuBtnIsVisible(self._selectNumber) then
		self:selectActivityType(self._selectNumber)
	else
		self:selectActivityType(selectNum)
	end
end

function QUIDialogActivityForSeven:checkMenuBtnIsVisible(index)
	if index == nil then return false end
	local node = self._ccbOwner["node_btn_"..index]
	if node then
		return node:isVisible()
	end

	return false
end

function QUIDialogActivityForSeven:autoSunMenuBtnLayerOut( )
	local index = 1
	for ii=1,4 do
		local node = self._ccbOwner["node_btn_"..ii]
		if node and node:isVisible() then
			node:setPositionX(-32 + (index - 1)*127)
			index = index + 1
		end
	end
end

function QUIDialogActivityForSeven:checkAvtivityTime( )
	local openTime = (remote.user.openServerTime or 0)/1000
	local currTime = q.serverTime()
	local endTime = openTime + remote.activity.TIME1 * DAY - currTime
	if self._curActivityType == 2 then
		endTime = openTime + remote.activity.TIME5 * DAY - currTime
	end

	if endTime <= 0 then
		return false
	else
		return true
	end
end

function QUIDialogActivityForSeven:selectActivityType(number)
	self._selectNumber = number

	if not self:checkAvtivityTime() then
		app.tip:floatTip("活动已结束！")
		return
	end
	local index = 1
	while true do
		local btn = self._ccbOwner["btn_"..index]
		if btn then
			btn:setEnabled(number ~= index)
			self._ccbOwner["sp_tips_"..index]:setVisible(false)
			self._ccbOwner["sp_done_"..index]:setVisible(false)
			if self._selectDay <= self._unlockDay then
				local isComplete = remote.activity:checkActivitySevenDayMenuIsComplete(self._selectDay, index)
				self._ccbOwner["sp_tips_"..index]:setVisible(isComplete)
				if not isComplete then
					local data = self:getActivityByDayAndNumber(self._selectDay, index)
					if q.isEmpty(data) == false then
						self._ccbOwner["sp_done_"..index]:setVisible(data.isAllTargetsComplete)
					end
				end
			end

			index = index + 1
		else
			break
		end
	end
	if self._selectNumber == 4 then
    	app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITY_SEVEN_CONSUME..self._selectDay)
    	self:_checkDayTips()
    end

	self:getOptions().curselectDay  = self._selectDay
	self:getOptions().curSelectNum  = self._selectNumber
	self:getOptions().curActivityType  = self._curActivityType

	self._virtualFrames = {}
	self._emptyFrames = {}
	self._dayInfo = clone(self:getActivityByDayAndNumber(self._selectDay, number))
	if q.isEmpty(self._dayInfo) == false then
		for _, value in ipairs(self._dayInfo.targets) do
			local points = value.calnival_points
			local typeName = ITEM_TYPE.CALNIVAL_POINTS
			if self._curActivityType == 2 then
				points = value.celebration_points
				typeName = ITEM_TYPE.CELEBRATION_POINTS
			end
			if points and typeName then
				value.awards = value.awards..";"..typeName.."^"..points
			end
		end

		remote.activity:setActivityTipEveryDay(self._dayInfo)

	    --生成子内容
	    if self._dayInfo.targets == nil then return end
	    
	    local curActivityTargetId = self:getOptions().curActivityTargetId
        local activityTargetHeadIndex = 1
        if curActivityTargetId then
            for k, v in pairs(self._dayInfo.targets) do
                if v.activityTargetId == curActivityTargetId and v.completeNum and v.completeNum ~= 3 then
                    activityTargetHeadIndex = k
                    break
                end
            end
        end

        if self._dayInfo.paramsValue and tonumber(self._dayInfo.paramsValue[2]) == 4 then -- 超值抢购排序
        	table.sort( self._dayInfo.targets, function(a,b)
        		if a.is_free and b.is_free and a.is_free ~= b.is_free then 
        			return a.is_free < b.is_free
        		elseif a.value2 and b.value2 and a.value2 ~= b.value2 then 
        			return a.value2 < b.value2
        		end
        	end)
        end

        self:_initListView()
	   
    	if self._halfBuyWidget then
    		self._halfBuyWidget:setVisible(false)
    	end
    	self._contentListView:setVisible(true)
	end
end

function QUIDialogActivityForSeven:_initListView()
	if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local data = self._dayInfo.targets[index] or {}
	            local  tag
	         	if remote.activity:isExchangeActivity(data.type or 0) then
	                tag = "exchange"
	                if self._dayInfo.paramsValue and tonumber(self._dayInfo.paramsValue[2]) == 4 then
	                	tag = "rushBuy"
	                end
	            end
	            local item = list:getItemFromCache(tag)

	            if not item then
	                if tag then
	                    if tag == "exchange" then
	                        item = QUIWidgetActivityExchangeForSeven.new()   
	                    elseif tag == "rushBuy" then
	                    	item = QUIWidgetActivitySevenRushBuy.new() 	
	                    end
	                else
	                    item = QUIWidgetActivityItemForSeven.new()
	                    
	                end
	                isCacheNode = false
	            end
	            
	            info.item = item
	            info.tag = tag
	            info.size = item:getContentSize()
				item:setInfo(self._dayInfo.activityId, data, self)
				item:setPreviewStated(self._isSelectPreviewDay)
	            if tag then
	                if tag == "exchange" then
	                    list:registerTouchHandler(index,"onTouchListView")
	                    list:registerBtnHandler(index, "btnExchange", "onTriggerExchange", nil, true)
	                elseif tag == "rushBuy" then
	                	list:registerTouchHandler(index,"onTouchListView")
	                	list:registerBtnHandler(index,"btn_ok", "_onTriggerConfirm", nil, true)
	                	list:registerBtnHandler(index,"btn_go", "_onTriggerConfirm", nil, true)
	                end
	            else
	                list:registerTouchHandler(index,"onTouchListView")
	                if data.completeNum == 1 and remote.activity:isRechargeActivity(data.type) then
	                    list:registerBtnHandler(index,"btn_ok2", "gotoRecharge", nil, true)
	                else
	                    list:registerBtnHandler(index,"btn_ok", "_onTriggerConfirm", nil, true)
	                    list:registerBtnHandler(index,"btn_go", "_onTriggerGo", nil, true)
	                end
	               
	            end
	            return isCacheNode
	        end,
	        headIndex = activityTargetHeadIndex,
	        ignoreCanDrag = true,
	        -- enableShadow = true,
	        totalNumber = #self._dayInfo.targets,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.content_sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._dayInfo.targets, headIndex = activityTargetHeadIndex})

	end
end

--通过天数获取当天的数据
function QUIDialogActivityForSeven:getActivityByDay(day)
	local daysValue = {}
	for _,value in pairs(self._data) do
		if value.day ~= nil and value.day == day then
			table.insert(daysValue, value)
		end
	end
	return daysValue
end

--通过天数和编号获取当天的数据
function QUIDialogActivityForSeven:getActivityByDayAndNumber(day, number)
	local daysValue = {}
	for _,value in pairs(self._data) do
		if value.day ~= nil and value.day == day and value.number == number then
			return value
		end
	end
	return nil
end


function QUIDialogActivityForSeven:onEvent(event)
    if event.name == QActivity.EVENT_UPDATE then
    	self:_getData()
        if self._selectDay ~= nil then
            self:_selectDayHandler(self._selectDay)
        end
    elseif event.name == QActivity.EVENT_COMPLETE_UPDATE then
        if self._selectDay ~= nil then
            self:_selectDayHandler(self._selectDay)
        end
        -- self:_showProgressBar()
        self._ccbOwner.sp_jifen_tips:setVisible(self:checkJifenTips())
    elseif event.name == QActivity.EVENT_CHANGE then
        self:_checkDayTips()
    end
end

function QUIDialogActivityForSeven:_onTriggerClick(event, target)
    app.sound:playSound("common_menu")
    local index = 1
	while true do
		local btn = self._ccbOwner["btn_"..index]
		if btn then
			if btn == target then
				self:selectActivityType(index)
			end
			index = index + 1
		else
			break
		end
	end
end

function QUIDialogActivityForSeven:_onTriggerPointsClick(event)
	app.sound:playSound("common_menu")

	if not self:checkAvtivityTime() then
		app.tip:floatTip("活动已结束！")
		return
	end

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityCarnivalPoints",options = {curActivityType = self._curActivityType}})
end

function QUIDialogActivityForSeven:_onTriggerAwardView(event)
	if tonumber(event) == CCControlEventTouchDown then
		self._ccbOwner.sp_jlyl:setScale(1.05)
	else
		self._ccbOwner.sp_jlyl:setScale(1)
	end	
	if q.buttonEventShadow(event, self._ccbOwner.btn_awards) == false then return end	
	app.sound:playSound("common_small")
	if not self:checkAvtivityTime() then
		app.tip:floatTip("活动已结束！")
		return
	end	
	local heroStr = "SS魂师碎片4选1，魂师皮肤"
	if self._curActivityType == 2 then
		heroStr = "SS天青龙牛天碎片，魂师皮肤"
	end
	local allSpecialItems = {}
	local commonAwards = {}
	local scoreInfo = db:getStaticByName("activity_carnival_new_reward") or {}
	for _,value in pairs(scoreInfo) do
		if value.type == self._curActivityType then
			if value.common_reward then
				local rewardTbl = string.split(value.common_reward, "^")
				table.insert(commonAwards,{id=rewardTbl[1],typeName = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM, count= tonumber(rewardTbl[2])})
			end	
			if value.special_reward then
				local rewardTbl = string.split(value.special_reward, "^")
				table.insert(allSpecialItems,{id=rewardTbl[1],typeName = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM, count= tonumber(rewardTbl[2])})
			end								
		end
	end
	self._specialDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSpecialAwards",
		options = {bigTitle = "积分奖励预览",curActivityType = self._curActivityType,allSpecialItems = commonAwards,availableItems = allSpecialItems,
		title1 = "任务积分免费获得",title2 = "积分特权30倍返利获得",closeCallback = function()
			self._specialDialog = nil
		end,
		subTitle1 = {{oType = "font", content = "S魂师11选1碎片",size = 20,color = ccc3(87, 47, 9)},},
   		subTitle2 = {{oType = "font", content = heroStr,size = 20,color = ccc3(255, 108, 43)},
   					 {oType = "font", content = "和海量钻石", size = 20,color = ccc3(87, 47, 9)},}}})
end

--嘉年华任务界面点击返回按钮直接退到主界面
function QUIDialogActivityForSeven:onTriggerBackHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogActivityForSeven
