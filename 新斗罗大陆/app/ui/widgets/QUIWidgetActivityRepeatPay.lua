local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityRepeatPay = class("QUIWidgetActivityRepeatPay", QUIWidget)
local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")
local QUIWidgetImageNum = import("..widgets.QUIWidgetImageNum")

function QUIWidgetActivityRepeatPay:ctor(options)
	local ccbFile = "ccb/Widget_Activity_kuanghuan.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerPay", callback = handler(self, QUIWidgetActivityRepeatPay._onTriggerPay)},
  		{ccbCallbackName = "onTriggerGet", callback = handler(self, QUIWidgetActivityRepeatPay._onTriggerGet)},
  		{ccbCallbackName = "onTriggerBox1", callback = handler(self, QUIWidgetActivityRepeatPay._onTriggerBox1)},
  		{ccbCallbackName = "onTriggerBox2", callback = handler(self, QUIWidgetActivityRepeatPay._onTriggerBox2)},
  		{ccbCallbackName = "onTriggerBox3", callback = handler(self, QUIWidgetActivityRepeatPay._onTriggerBox3)},
  		{ccbCallbackName = "onTriggerBox4", callback = handler(self, QUIWidgetActivityRepeatPay._onTriggerBox4)},
  		{ccbCallbackName = "onTriggerBox5", callback = handler(self, QUIWidgetActivityRepeatPay._onTriggerBox5)},
  		{ccbCallbackName = "onTriggerBox6", callback = handler(self, QUIWidgetActivityRepeatPay._onTriggerBox6)},
  	}
	QUIWidgetActivityRepeatPay.super.ctor(self,ccbFile,callBacks,options)
	self:_initChest()
	self._defaultWidth = self._ccbOwner.sp_bar_progress:getContentSize().width * self._ccbOwner.sp_bar_progress:getScaleX()

	self._tipRichText = QRichText.new(nil, 350, {autoCenter = true})
	self._tipRichText:setAnchorPoint(0.5, 0.5)
	self._ccbOwner.node_tip:addChild(self._tipRichText)

	self._targetItemBox = {}
	self._awardEffects = {}
	
	self._ccbOwner.node_tf_time:setPositionY(-display.height/2)
end

function QUIWidgetActivityRepeatPay:onExit() 
	QUIWidgetActivityRepeatPay.super.onExit(self)
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QUIWidgetActivityRepeatPay:setInfo(info)
	self._info = info
	self._openTarget = nil
	self._getTarget = nil
	self._finalTarget = nil
	self:_timeCountDown()
	self:_initChest()
	self:_countTargets()
end

--倒计时
function QUIWidgetActivityRepeatPay:_timeCountDown()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
	local str = ""
	local timeCount = self._info.end_at/1000 - q.serverTime()
	if timeCount > 0 then
		local day = math.floor(timeCount/DAY)
		timeCount = timeCount%DAY
		str = q.timeToHourMinuteSecond(timeCount)
		if day > 0 then
			str = day.."天 "..str
		end
		self._schedulerHandler = scheduler.performWithDelayGlobal(function ()
			self:_timeCountDown()
		end,1)
	end
	self._ccbOwner.tf_time:setString(str)
	local start_at = q.serverTime() - self._info.start_at / 1000
	self._startDay = math.floor(start_at/DAY)
end

--初始化宝箱
function QUIWidgetActivityRepeatPay:_initChest()
end

--计算活动目标
function QUIWidgetActivityRepeatPay:_countTargets()
	local targets = self._info.targets
	local todayTargetId = remote.activity:getDayChargeByAcitivityId(self._info.activityId)

	local newCompleteIndex = 0
	local autoisActivity = remote.crystal:checkTodayIsActivity()
	local newRecharge = remote.crystal:getNewTurnAutoPay()
	local isSixValueRepay = false
	for _, target in ipairs(targets) do
		if target.value2 == 6 then 
			isSixValueRepay = true
			break
		end
	end

	local completeTable = {}
	if autoisActivity and isSixValueRepay and not newRecharge then
		for _, target in ipairs(targets) do
			if target.completeNum == 3 or target.completeNum == 2  and target.index ~= 6 and todayTargetId ~= target.activityTargetId then
				table.insert(completeTable,target)
			end
		end
		table.sort( completeTable, function(a,b)
			return a.index > b.index
		end )
		QPrintTable(completeTable)
		if next(completeTable) ~= nil then
			todayTargetId = completeTable[1].activityTargetId
			newCompleteIndex = completeTable[1].index
		end
	end
	print("newCompleteIndex=",newCompleteIndex)
	if newCompleteIndex > 0 then
		for _, target in ipairs(targets) do
			if target.completeNum == 2 and target.index > newCompleteIndex then 
				target.completeNum = 1
			end
		end
	end


	local completeIndex = 1 
	local completeTarget = nil
	print("todayTargetId=",todayTargetId)
	for _, target in ipairs(targets) do
		local awards = string.split(target.awards, ";")
		local item = string.split(awards[1], "^")
		local itemType = remote.items:getItemType(item[1])
		if itemType == nil then
			itemType = ITEM_TYPE.ITEM
		end

		if self._targetItemBox[target.index] == nil then
			self._targetItemBox[target.index] = QUIWidgetItemsBox.new()
			self._ccbOwner["node_item_"..target.index]:addChild(self._targetItemBox[target.index])
		end
		self._targetItemBox[target.index]:setGoodsInfo(tonumber(item[1]), itemType, tonumber(item[2]))

		if todayTargetId ~= nil then
			if todayTargetId == target.activityTargetId then
				self._openTarget = target
			end
		else
			if (target.completeNum == 2 or target.completeNum == 3) and (self._openTarget == nil or target.index > self._openTarget.index) then
				self._openTarget = target
			end
		end
		if target.completeNum == 2 and self._getTarget == nil then
			self._getTarget = target
			completeIndex = target.index - 1
		end

		self._ccbOwner["sp_done_"..target.index]:setVisible(false)
		makeNodeFromGrayToNormal(self._ccbOwner["node_item_"..target.index])
		if self._ccbOwner["node_effect_"..target.index] then
			self._ccbOwner["node_effect_"..target.index]:setVisible(true)
		end
		if self._awardEffects[target.index] ~= nil then
			self._awardEffects[target.index]:removeFromParent()
			self._awardEffects[target.index] = nil
		end
		if target.completeNum == 3 then
			makeNodeFromNormalToGray(self._ccbOwner["node_item_"..target.index])
			self._ccbOwner["sp_done_"..target.index]:setVisible(true)
			if self._ccbOwner["node_effect_"..target.index] then
				self._ccbOwner["node_effect_"..target.index]:setVisible(false)
			end
		elseif target.completeNum == 2 then
			if target.index ~= 6 then
				self._awardEffects[target.index] = QUIWidgetAnimationPlayer.new()
				self._awardEffects[target.index]:playAnimation("Widget_AchieveHero_light_orange.ccbi", nil, nil, false)
				self._ccbOwner["node_item_"..target.index]:addChild(self._awardEffects[target.index], -1)
			end
		end

		if target.index == 6 then
			self._finalTarget = target
		end

		if target.completeNum == 3 then
			completeTarget = target
		end
	end

	if self._openTarget == nil then
		self._openTarget = completeTarget
	end
	if self._getTarget == nil then 
		self._getTarget = self._openTarget
	end

	if self._openTarget and self._openTarget.index < self._startDay then
		self._startDay = self._openTarget.index
	end

	if self._getTarget ~= nil then
		if self._getTarget.completeNum == 3 then
			completeIndex = self._getTarget.index
		else
			completeIndex = self._getTarget.index - 1
		end
	else
		app.tip:floatTip("没有找到活动目标，可能是服务器改动时间导致，请找一个没有调过时间的服务器！谢谢配合！")
		return
	end

	if self._openTarget.completeNum == 3 and self._openTarget.index == 5 then
		self._openTarget = self._finalTarget
	end

	if self._dayNum == nil then
		self._dayNum = QUIWidgetImageNum.new()
		self._ccbOwner.node_day:addChild(self._dayNum)
	end 
	self._dayNum:setString(5)

	local payNum = 6
	for _, value in ipairs(targets) do
		if value.value2 ~= nil and value.value2 > 0 then
			payNum = value.value2
			break
		end
	end
	if self._payNum == nil then
		self._payNum = QUIWidgetImageNum.new()
		self._ccbOwner.node_pay:addChild(self._payNum)
	end
	self._payNum:setString(payNum)

	if self._openTarget ~= nil then
		local todayRecharge = remote.user.todayRecharge or 0
		local needRecharge = (self._openTarget.value2 or 0) - todayRecharge
		needRecharge = math.max(needRecharge,0)
		if self._openTarget.index > 5 or (self._openTarget.index == 5 and self._openTarget.completeNum == 3) then
			self._tipRichText:setString({
		            {oType = "font", content = "活动奖励已全部完成请点击领取", size = 20,color = UNITY_COLOR_LIGHT.white},
	            })
		else			
			self._tipRichText:setString({
		            {oType = "font", content = "今日已充", size = 20,color = UNITY_COLOR_LIGHT.white},
		            {oType = "font", content = todayRecharge, size = 20,color = UNITY_COLOR_LIGHT.green},
		            {oType = "font", content = "元，再充",size = 20,color = UNITY_COLOR_LIGHT.white},
		            {oType = "font", content = needRecharge, size = 20,color = UNITY_COLOR_LIGHT.green},
		            {oType = "font", content = "元即可获取", size = 20,color = UNITY_COLOR_LIGHT.white},
		        })
		end
	end
	self._ccbOwner.node_btn_get:setVisible(false)
	self._ccbOwner.node_btn_pay:setVisible(false)
	self._ccbOwner.sp_done:setVisible(false)
	
	if self._openTarget.index == 6 and self._openTarget.completeNum == 1 then
		self._openTarget.completeNum = 2
	end

	if self._openTarget ~= nil then
		self._ccbOwner.node_btn_get:setVisible(self._openTarget.completeNum == 2)
		self._ccbOwner.node_btn_pay:setVisible(self._openTarget.completeNum == 1)
		self._ccbOwner.sp_done:setVisible(self._openTarget.completeNum == 3)
		self._ccbOwner.node_awards:removeAllChildren()
		local awards = string.split(self._openTarget.awards, ";")
		local numW = (#awards - 1) * 120
		self._items = {}
		for _,award in ipairs(awards) do
			local item = string.split(award, "^")
			local itemType = remote.items:getItemType(item[1])
			local itemId = nil
			if itemType == nil then
				itemId = tonumber(item[1])
				itemType = ITEM_TYPE.ITEM
			end
			table.insert(self._items, {itemId = itemId, itemType = itemType, count = tonumber(item[2])})
		end

		for index,item in ipairs(self._items) do
			local itemBox = QUIWidgetItemsBox.new()
			itemBox:setPromptIsOpen(true)
			itemBox:setGoodsInfo(item.itemId, item.itemType, item.count)
			itemBox:setPositionX(-numW/2 + (index-1) * 120)
			self._ccbOwner.node_awards:addChild(itemBox)
		end
	end
	local targetNode = nil
	completeIndex = completeIndex + 1
	completeIndex = math.min(completeIndex, 6)
	targetNode = self._ccbOwner["node"..completeIndex]
	self._ccbOwner.sp_bar_progress:setScaleX((targetNode:getPositionX() - self._ccbOwner.sp_bar_progress:getPositionX())/self._defaultWidth)
end

function QUIWidgetActivityRepeatPay:_openBox(index)
    app.sound:playSound("common_small")
    if self._isOpeningBox then
    	return
    end
    
	local targets = self._info.targets
	local clickTarget = nil
	for _,target in ipairs(targets) do
		if target.index == index then
			clickTarget = target
		end
	end
	if clickTarget ~= nil then
		local awards = {}
		local objs = string.split(clickTarget.awards, ";")
		for _,obj in ipairs(objs) do
			local item = string.split(obj, "^")
			local typeName = remote.items:getItemType(item[1])
			local id = nil
			if typeName == nil then
				id = tonumber(item[1])
				typeName = ITEM_TYPE.ITEM
			end
			table.insert(awards, {id = id, typeName = typeName, count = tonumber(item[2])})
		end
		
		if clickTarget.completeNum ~= 2 or remote.activity:checkCompleteByTargetId(clickTarget) then
			if #awards > 1 then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsBoxAlert",
			        options = {awards = awards, isGet = false}},{isPopCurrentDialog = false} )
			else
				app.tip:itemTip(awards[1].typeName, awards[1].id, true)
			end
		else
			if remote.activity:checkIsActivityAward(self._info.activityId) == false then
				app.tip:floatTip("不在活动时间段内!")
				return
			end
			self._isOpeningBox = true
			app:getClient():activityCompleteRequest(self._info.activityId, clickTarget.activityTargetId, nil, nil, function (data)
				self._isOpeningBox = false
		  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		    		options = {awards = awards}},{isPopCurrentDialog = false} )
				dialog:setTitle("恭喜您获得活动奖励")
				remote.activity:setCompleteDataById(self._info.activityId, clickTarget.activityTargetId)
			end, function (data)
				self._isOpeningBox = false
			end)
		end
	end
end

-----------------------event----------------------

function QUIWidgetActivityRepeatPay:_onTriggerPay(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_pay) == false then return end
    app.sound:playSound("common_small")
    if ENABLE_CHARGE() then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
    end
end

function QUIWidgetActivityRepeatPay:_onTriggerGet(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_get) == false then return end
    app.sound:playSound("common_small")
	if self._openTarget ~= nil then 
		local awards = {}
		local objs = string.split(self._openTarget.awards, ";")
		for _,obj in ipairs(objs) do
			local item = string.split(obj, "^")
			local typeName = remote.items:getItemType(item[1])
			local id = nil
			if typeName == nil then
				id = tonumber(item[1])
				typeName = ITEM_TYPE.ITEM
			end
			table.insert(awards, {id = id, typeName = typeName, count = tonumber(item[2])})
		end

		if remote.activity:checkIsActivityAward(self._info.activityId) == false then
			app.tip:floatTip("不在活动时间段内!")
			return
		end
		app:getClient():activityCompleteRequest(self._info.activityId, self._info.targets[1].activityTargetId, nil, nil, function (data)
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	    		options = {awards = awards}},{isPopCurrentDialog = false} )
			dialog:setTitle("恭喜您获得活动奖励")
			remote.activity:setCompleteDataById(self._info.activityId, self._info.targets[1].activityTargetId)
		end)
	end
end

function QUIWidgetActivityRepeatPay:_onTriggerBox1()
	self:_openBox(1)
end

function QUIWidgetActivityRepeatPay:_onTriggerBox2()
	self:_openBox(2)
end

function QUIWidgetActivityRepeatPay:_onTriggerBox3()
	self:_openBox(3)
end

function QUIWidgetActivityRepeatPay:_onTriggerBox4()
	self:_openBox(4)
end

function QUIWidgetActivityRepeatPay:_onTriggerBox5()
	self:_openBox(5)
end

function QUIWidgetActivityRepeatPay:_onTriggerBox6()
	self:_openBox(6)
end

return QUIWidgetActivityRepeatPay