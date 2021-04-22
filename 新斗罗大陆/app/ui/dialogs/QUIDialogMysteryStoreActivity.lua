
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMysteryStoreActivity = class("QUIDialogMysteryStoreActivity", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMysteryStoreActivity = import("..widgets.QUIWidgetMysteryStoreActivity")
local QListView = import("...views.QListView")
local QActivity = import("...utils.QActivity")
local QVIPUtil = import(".QVIPUtil")
local QPayUtil = import("...utils.QPayUtil")


QUIDialogMysteryStoreActivity.DESC_ATY_FRONT ="神秘商店活动："
QUIDialogMysteryStoreActivity.DESC_ATY_BEHIND ="(开服满14日的服务器可参与)"


function QUIDialogMysteryStoreActivity:ctor(options)
	local ccbFile = "ccb/Dialog_MysteryStore_Activity.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    
    QUIDialogMysteryStoreActivity.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	q.setButtonEnableShadow(self._ccbOwner.frame_btn_close)
	self.isAnimation = true --是否动画显示
	self._themeId = remote.activity.THEME_ACTIVITY_QIANSHITANGSAN
	self._activityId = options.activityId or 0
	self._fun = nil
	self._callBack = options.callback

end

function QUIDialogMysteryStoreActivity:viewDidAppear()
	QUIDialogMysteryStoreActivity.super.viewDidAppear(self)
    self._activityProxy = cc.EventProxy.new(remote.activity)
    self._activityProxy:addEventListener(QActivity.EVENT_QIANSHITANGSAN_UPDATE, handler(self, self.onEvent))

	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.refreshByDaliy))

	self:handleData()
	self:sortData()
	self:initListView()
	self:setInfo()

end


function QUIDialogMysteryStoreActivity:viewWillDisappear()
  	QUIDialogMysteryStoreActivity.super.viewWillDisappear(self)
    self._activityProxy:removeAllEventListeners()
    self._userEventProxy:removeAllEventListeners()

    if self._rechargeProgress then
    	scheduler.unscheduleGlobal(self._rechargeProgress)
    	self._rechargeProgress = nil
    end    
    if self._timerScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._timerScheduler)
    	self._timerScheduler = nil
    end

end

function QUIDialogMysteryStoreActivity:viewAnimationInHandler()
	--代码
	self:initListView()
end

function QUIDialogMysteryStoreActivity:onEvent(event)
    print("------onEvent------------",event.name)
	self:sortData()
	self:initListView()
end


function QUIDialogMysteryStoreActivity:refreshByDaliy(event)
    print("------refreshByDaliy------------name ",event.name)
	if event.time == nil or event.time == 0 then
    	print("------refreshByDaliy------------time。",event.time)
		local curTime = q.serverTime()
		local endTime = (self._activity.end_at or 0) / 1000
		if endTime > curTime then
			self:handleData()
			self:sortData()
			self:initListView()
		else
			app.tip:floatTip("当前活动时间已经结束")
			self:_onTriggerClose()
		end
	end
end

function QUIDialogMysteryStoreActivity:setInfo()
	self._ccbOwner.tf_during_time:setString("")
	self._ccbOwner.tf_endTime:setString("")

	if q.isEmpty(self._activity) then return end 
	remote.activity:setActivityClicked(self._activity)
	local startTimeTbl = q.date("*t", (self._activity.start_at or 0)/1000)
    local endTimeTbl = q.date("*t", (self._activity.end_at or 0)/1000)
    local timeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", 
        startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, 
        endTimeTbl.month, endTimeTbl.day, endTimeTbl.hour, endTimeTbl.min)
	self._ccbOwner.tf_during_time:setString(timeStr)
	self._ccbOwner.tf_desc_behind:setPositionX(self._ccbOwner.tf_during_time:getPositionX() + self._ccbOwner.tf_during_time:getContentSize().width)

	self:handlerTimer()
end

function QUIDialogMysteryStoreActivity:handlerTimer()
	if self._fun == nil then
	    self._fun = function ()
	    	local currTime = q.serverTime()
	    	local endTime =  (self._activity.end_at or 0) / 1000
	    
			endTime = endTime - currTime
			if endTime > 0 then
	    		self._ccbOwner.tf_endTime:setString(q.converFun(endTime))
	    	else
	    		if self._timerScheduler then
	    			scheduler.unscheduleGlobal(self._timerScheduler)
	    			self._timerScheduler = nil
	    		end
	    		self._ccbOwner.tf_endTime:setString("活动结束")
				app.tip:floatTip("当前活动时间已经结束")
				local arr = CCArray:create()
				arr:addObject(CCDelayTime:create(0.1))
				arr:addObject(CCCallFunc:create(function()
					self:_onTriggerClose()
				end))
				self._ccbOwner.tf_endTime:stopAllActions()
	        	self._ccbOwner.tf_endTime:runAction(CCSequence:create(arr))
	    	end
	    end
	end
	
	if self._timerScheduler == nil then
    	self._timerScheduler = scheduler.scheduleGlobal(self._fun, 1)
	end
    self._fun()
end


function QUIDialogMysteryStoreActivity:handleData()
	self._items= {}
	local activities = remote.activity:getActivityByTheme(self._themeId)
	self._activity = activities[1] or {}
	for k,v in pairs(activities or {}) do
		if v.activityId == self._activityId then
			self._activity = v
			break
		end
	end

	if q.isEmpty(self._activity) then return end 
	-- QPrintTable(self._activity)

	for i,target in ipairs(self._activity.targets or {} ) do
		-- if target.activityTargetId ~= remote.activity.ACTIVITY_TARGET_TYPE.USE_TO_SHOW_AWARD then
		if tonumber(target.type) == tonumber(remote.activity.ACTIVITY_TARGET_TYPE.FREE_GET_DALIY)
			or tonumber(target.type) == tonumber(remote.activity.ACTIVITY_TARGET_TYPE.FREE_RECHARGE_DALIY)
			or tonumber(target.type) == tonumber(remote.activity.ACTIVITY_TARGET_TYPE.RECHARGE_PURCHASE)
		 then
			table.insert(self._items,target)
		end
	end
	


end

function QUIDialogMysteryStoreActivity:sortData()
	if q.isEmpty(self._items) then return end

	table.sort(self._items, function (target1, target2)
		local progressData1 = remote.activity:getActivityTargetProgressDataById(target1.activityId, target1.activityTargetId)
		local progressData2 = remote.activity:getActivityTargetProgressDataById(target2.activityId, target2.activityTargetId)
		local complete1 = 1
		local complete2 = 1
		if progressData1 then
			complete1 = progressData1.complete and 1 or 2
			if complete1 == 2 and tonumber(progressData1.completeCount or 0) > tonumber(progressData1.awardCount or 0) then
				complete1 = 3
			end
		end
		if progressData2 then
			complete2 = progressData2.complete and 1 or 2
			if complete2 == 2 and tonumber(progressData2.completeCount or 0) > tonumber(progressData2.awardCount or 0) then
				complete2 =  3
			end			
		end
		if complete1 == complete2 then
			return target1.index < target2.index
		else
			return complete1 > complete2
		end

	end)	

end


function QUIDialogMysteryStoreActivity:initListView()
	if self._listViewLayout then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_layout:getContentSize())
		self._listViewLayout:resetTouchRect()
	end
	
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
	        curOriginOffset = 7,
	        contentOffsetX = 0,
	        curOffset = 0,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 0,
	      	spaceX = 10,
	      	isVertical = true ,
	        totalNumber = #self._items,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listViewLayout:reload({totalNumber = #self._items})
	end
end


function QUIDialogMysteryStoreActivity:_renderItemCallBack(list, index, info )
	local function showItemInfo(x, y, itemBox, listView)
		app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
	end

    local isCacheNode = true
  	local data = self._items[index]
    local item = list:getItemFromCache()
    if not item then
		item = QUIWidgetMysteryStoreActivity.new()
		item:addEventListener(QUIWidgetMysteryStoreActivity.EVENT_GET_REWARD, handler(self,self.onClickGetHandler))
		item:addEventListener(QUIWidgetMysteryStoreActivity.EVENT_CLICK, handler(self, self.onClickBuyHandler))
    	isCacheNode = false
    end
    item:setInfo(data)
    info.item = item
    info.size = item:getContentSize()
    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_get", "_onTriggerGet", nil, "true")
    list:registerBtnHandler(index, "btn_buy", "_onTriggerBuy", nil, "true")

    return isCacheNode

end

function QUIDialogMysteryStoreActivity:onClickGetHandler(event)
	local info = event.info
	if not info then
		return
	end
    app.sound:playSound("common_small")
    local awardString = info.awards
    local awardsTbl = {}
    local awardType = QUIWidgetMysteryStoreActivity.AWARD_TYPE_OR
	if string.find(awardString, "#") then
		awardsTbl = string.split(info.awards, "#")
		awardType = QUIWidgetMysteryStoreActivity.AWARD_TYPE_OR
	else
		awardsTbl = string.split(info.awards, ";")
		awardType = QUIWidgetMysteryStoreActivity.AWARD_TYPE_AND
	end

    self._awards = {}

    for i, v in pairs(awardsTbl) do
        if v ~= "" then
            local reward = string.split(v, "^")
            local itemType = ITEM_TYPE.ITEM
            if tonumber(reward[1]) == nil then
                itemType = remote.items:getItemType(reward[1])
            end
            table.insert(self._awards, {id = reward[1], typeName = itemType, count = tonumber(reward[2])})
        end
    end


	local activityTargetId = info.activityTargetId
	local activityId = info.activityId
	if awardType ==  QUIWidgetMysteryStoreActivity.AWARD_TYPE_OR then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
	        options = { awards = self._awards,  explainStr = "获得以下奖励", titleText = "奖   励",confirmText = "领 取", maxOpenNum = 1,
	            okCallback = function ( chooseIndexs , selectCount)
	          		if not chooseIndexs then
						chooseIndexs = {}
					end
					local chooseIndex = chooseIndexs[1]
	            	if not chooseIndex or chooseIndex <= 0 then
	            		app.tip:floatTip("请选择")
	            		return false
	            	end
	            	local chooseAward = self._awards[chooseIndex]
	            	if type(chooseAward) == "table" then
	                	local chooseAwardStr = chooseAward.id.."^"..chooseAward.count
	                	print("activityId :"..activityId.."  activityTargetId :"..activityTargetId.."  chooseAwardStr :"..chooseAwardStr.." selectCount :"..selectCount)
	                	-- QPrintTable(chooseAward)
	                	local awardsData = {}
	            		table.insert(awardsData, chooseAward)
	                	-- QPrintTable(awardsData)
						app:getClient():activityCompleteRequest(activityId, activityTargetId, chooseAwardStr, selectCount, function ()
								local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
								options = {awards = awardsData}},{isPopCurrentDialog = false} )
							dialog:setTitle("恭喜您获得活动奖励")
							remote.activity:setCompleteDataById(activityId, activityTargetId, count)
							if self:safeCheck() then
								self:sortData()
								self:initListView()
							end
						end)
	                	return true
	                end
	                return true
	            end}}, {isPopCurrentDialog = false})

	else
		app:getClient():activityCompleteRequest(activityId, activityTargetId, nil, nil, 
			function ()
				local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
					options = {awards = self._awards}},{isPopCurrentDialog = false} )
				dialog:setTitle("恭喜您获得活动奖励")
				remote.activity:setCompleteDataById(activityId, activityTargetId, count)
					if self:safeCheck() then
						self:sortData()
						self:initListView()
					end
			end
		)
	end

end

function QUIDialogMysteryStoreActivity:onClickBuyHandler(event)
	local info = event.info
	if not info then
		return
	end
    app.sound:playSound("common_small")
	self:buyByInfo(info)
end

function QUIDialogMysteryStoreActivity:buyByInfo(info)
	if info == nil then return end
	local rechargeConfig = remote.activity:getRechargeConfigByRechargeBuyProductId(info.value3)
	if rechargeConfig == nil then
		return
	end
    -- QPrintTable(rechargeConfig)

	if ENABLE_CHARGE_BY_WEB and CHARGE_WEB_URL then
		QPayUtil.payOffine(rechargeConfig.RMB, rechargeConfig.type, rechargeConfig.recharge_buy_productid)
	else
		app:showLoading()
	    if self._rechargeProgress then
	    	scheduler.unscheduleGlobal(self._rechargeProgress)
	    	self._rechargeProgress = nil
	    end
		self._rechargeProgress = scheduler.performWithDelayGlobal(function ( ... )
			app:hideLoading()
		end, 5)
		if FinalSDK.isHXIOS() then
			QPayUtil:hjPayOffline(rechargeConfig.RMB, rechargeConfig.type, rechargeConfig.recharge_buy_productid)
		else
			QPayUtil:pay(rechargeConfig.RMB, rechargeConfig.type, rechargeConfig.recharge_buy_productid)
		end
	end
end


function QUIDialogMysteryStoreActivity:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMysteryStoreActivity:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMysteryStoreActivity:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end


return QUIDialogMysteryStoreActivity