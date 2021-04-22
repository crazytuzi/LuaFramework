-- @Author: liaoxianbo
-- @Date:   2020-05-06 17:56:15
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-20 18:00:52
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityCarnivalPoints = class("QUIDialogActivityCarnivalPoints", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QActivity = import("...utils.QActivity")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")

local QUIWidgetActivityCarnivalPoints = import("..widgets.QUIWidgetActivityCarnivalPoints")

function QUIDialogActivityCarnivalPoints:ctor(options)
	local ccbFile = "ccb/Dialog_AcitivityCarnival_Points.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerTaskClick", callback = handler(self, self._onTriggerTaskClick)},
		{ccbCallbackName = "onTriggerLockSpecial", callback = handler(self,self._onTriggerLockSpecial)},
		{ccbCallbackName = "onTriggerAwardView", callback = handler(self,self._onTriggerAwardView)},
    }
    QUIDialogActivityCarnivalPoints.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	CalculateUIBgSize(self._ccbOwner.sp_background)
	self._ccbOwner.btn_jifen:setEnabled(false)
	q.setButtonEnableShadow(self._ccbOwner.btn_buySpecial)
	q.setButtonEnableShadow(self._ccbOwner.btn_renwu)

    self._curActivityType = options.curActivityType or 1

    self._ccbOwner.btn_7dayBtn:setVisible(self._curActivityType == 1)
    self._ccbOwner.btn_14dayBtn:setVisible(self._curActivityType == 2)

	self._allSpecialItems = {} --特权所有奖励
	self._availableItems = {} --可立即获得的特权奖励
	
    self:initData()
	self:_initView()
end

function QUIDialogActivityCarnivalPoints:viewDidAppear()
	QUIDialogActivityCarnivalPoints.super.viewDidAppear(self)

    self._activityProxy = cc.EventProxy.new(remote.activity)
    self._activityProxy:addEventListener(remote.activity.EVENT_128RECHARGE_UPDATE, handler(self, self.refreshInfo))

	self:addBackEvent(true)
	self:_updateInfo()
end

function QUIDialogActivityCarnivalPoints:viewWillDisappear()
  	QUIDialogActivityCarnivalPoints.super.viewWillDisappear(self)

    if self._activityProxy ~= nil then 
        self._activityProxy:removeAllEventListeners()
        self._activityProxy = nil
    end	

    if self._timeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._timeHandler)
    end

	self:removeBackEvent()
end

function QUIDialogActivityCarnivalPoints:_updateInfo()
	local activityType = QActivity.TYPE_ACTIVITY_FOR_SEVEN 
  
	local readTips = remote.activity:checkIsComplete(remote.activity.TYPE_ACTIVITY_FOR_SEVEN)
	local awardTime = QActivity.TIME2
	if self._curActivityType == 2 then
		activityType = QActivity.TYPE_ACTIVITY_FOR_SEVEN_2
		awardTime = QActivity.TIME5
		readTips = remote.activity:checkIsComplete(remote.activity.TYPE_ACTIVITY_FOR_SEVEN_2)
	end
    self._unlockDay = remote.activity:getActivitySevenUnlockDay(activityType)

    self._ccbOwner.sp_jifen_tips:setVisible(readTips)
    
    self._openTime = (remote.user.openServerTime or 0)/1000

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


function QUIDialogActivityCarnivalPoints:_initView()
	if self._curActivityType == 1 then
	 	-- 1~7天
	 	QSetDisplayFrameByPath(self._ccbOwner.sp_avatar_img, QResPath("jianianhua_jifen_bg"))
	 	QSetDisplayFrameByPath(self._ccbOwner.sp_title_banner, QResPath("jianianhua_jifen_title"))
	else 
		-- 8～14天
	 	QSetDisplayFrameByPath(self._ccbOwner.sp_avatar_img, QResPath("banyueqingdian_jifen_bg"))
	 	QSetDisplayFrameByPath(self._ccbOwner.sp_title_banner, QResPath("banyueqingdian_jifen_title"))
	end

	self._ccbOwner.node_lable:removeAllChildren()
	local richText1 = QRichText.new(nil, 623)
	richText1:setString({
   						{oType = "font", content = "完成任务获取积分即可领取奖励。购买",size = 18,color = ccc3(193, 144, 96)},
   						{oType = "font", content = "特权", size = 18,color = ccc3(255, 108, 43)},
   						{oType = "font", content = "可获得额外专属奖励！", size = 18,color = ccc3(193, 144, 96)},
   						})
   	richText1:setAnchorPoint(ccp(0, 0.5))
	self._ccbOwner.node_lable:addChild(richText1)

end

function QUIDialogActivityCarnivalPoints:initData( )
	local scoreInfo = db:getStaticByName("activity_carnival_new_reward") or {}
	local awardsTbl = {}
	self._commonAwards = {}
	for _,value in pairs(scoreInfo) do
		if value.type == self._curActivityType then
			table.insert(awardsTbl,value)
			if value.common_reward then
				local rewardTbl = string.split(value.common_reward, "^")
				table.insert(self._commonAwards,{id=rewardTbl[1],typeName = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM, count= tonumber(rewardTbl[2])})
			end				
		end
	end
	self._itemData = awardsTbl
	table.sort( self._itemData, function( a,b)
		return a.condition < b.condition
	end )
	self:refreshInfo()
end

function QUIDialogActivityCarnivalPoints:refreshInfo( )
	if q.isEmpty(self._itemData) then return end

	if self._specialDialog then
        self._specialDialog:popSelf()
        self._specialDialog = nil
    end

	self._allSpecialItems = {}
	self._availableItems = {}

	local isShowLock = remote.user.calnivalPrizeIsActive or false
	local curtentPoints = remote.user.calnivalPoints or 0
	if self._curActivityType == 2 then
		curtentPoints = remote.user.celebration_points or {}
		isShowLock = remote.user.celebrationPrizeIsActive or false
	end

	self._ccbOwner.btn_buySpecial:setVisible(not isShowLock)
	self._ccbOwner.sp_tequanyijihuo:setVisible(isShowLock)
	
	for key,v in pairs(self._itemData) do
		if self:_checkAwardIsRecived(v.id) and self:_checkSpecialAwardIsRecived(v.id) then
			v.isFinash = true
		else
			v.isFinash = false
		end

		if self:_checkAwardIsRecived(v.id) then
			v.isNormRecived = true
		else
			v.isNormRecived = false
		end


		if v.special_reward then
			local rewardTbl = string.split(v.special_reward, "^")
			table.insert(self._allSpecialItems,{id=rewardTbl[1],typeName = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM, count= tonumber(rewardTbl[2])})
			if curtentPoints >= v.condition then
				table.insert(self._availableItems,{id=rewardTbl[1],typeName = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM, count= tonumber(rewardTbl[2])})
			end
		end		
	end

	-- table.sort( self._itemData, function( a,b)
	-- 	if curtentPoints > a.condition and curtentPoints > b.condition then
	-- 		if a.isNormRecived ~= b.isNormRecived then
	-- 			return a.isNormRecived == false
	-- 		elseif a.isSpecialRecived ~= b.isSpecialRecived then
	-- 			return a.isSpecialRecived == false
	-- 		else
	-- 			return a.condition < b.condition
	-- 		end
	-- 	else
	-- 		if a.condition ~= b.condition then
	-- 			return a.condition < b.condition
	-- 		end
	-- 	end
	-- end )
	table.sort( self._itemData, function( a,b)
		if a.isFinash ~= b.isFinash then
			return a.isFinash == false
		elseif a.condition ~= b.condition then
			return a.condition < b.condition
		end
	end )
	self._headIndex = nil
	if not isShowLock then
		for key,v in pairs(self._itemData) do
			if v.isNormRecived == false and curtentPoints >= v.condition then
				self._headIndex = self._headIndex and math.min(self._headIndex,key) or key	
			end
		end
	end
	if self._headIndex and self._headIndex > 1 then
		self._headIndex = self._headIndex - 1
	end
	self:_initListView()
end

function QUIDialogActivityCarnivalPoints:getContentListView( )
	return self._contentListView
end
function QUIDialogActivityCarnivalPoints:_initListView()
	if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local data = self._itemData[index] or {}

	            local item = list:getItemFromCache(tag)

	            if not item then
	                item = QUIWidgetActivityCarnivalPoints.new()
	                item:addEventListener(QUIWidgetActivityCarnivalPoints.GETAWARDS_EVENT_SUCESS, handler(self, self.refreshInfo))
	                isCacheNode = false
	            end
	            
	            info.item = item
	            info.tag = tag
	            info.size = item:getContentSize()
				item:setInfo(index,self._curActivityType,data)
	
				list:registerBtnHandler(index,"btn_ok", "_onTriggerConfirm", nil, true)
				list:registerBtnHandler(index,"btn_click1", "_onTriggerClickNormal")
				list:registerBtnHandler(index,"btn_click2", "_onTriggerClickSpecial")

	            return isCacheNode
	        end,
	        ignoreCanDrag = true,
	        headIndex = self._headIndex or 1,
	        totalNumber = #self._itemData,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.content_sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._itemData,headIndex = self._headIndex or 1})

	end
end

function QUIDialogActivityCarnivalPoints:_checkAwardIsRecived(index)
	local recivedAwards = remote.user.gotCommonCalnivalPrizeIds or {}
	if self._curActivityType == 2 then
		recivedAwards = remote.user.gotCommonCelebrationPrizeIds or {}
	end

	for _, value in pairs(recivedAwards) do
		if tonumber(value) == tonumber(index) then
			return true
		end
	end

	return false
end

function QUIDialogActivityCarnivalPoints:_checkSpecialAwardIsRecived(index)
	local recivedAwards = remote.user.gotSpecialCalnivalPrizeIds or {}
	if self._curActivityType == 2 then
		recivedAwards = remote.user.gotSpecialCelebrationPrizeIds or {}
	end

	for _, value in pairs(recivedAwards) do
		if tonumber(value) == tonumber(index) then
			return true
		end
	end

	return false
end

function QUIDialogActivityCarnivalPoints:_onTriggerTaskClick(event)
	app.sound:playSound("common_small")
	self._activityTaskDialog = app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityForSeven",options = {curActivityType = self._curActivityType}})
end

function QUIDialogActivityCarnivalPoints:_onTriggerLockSpecial()
	app.sound:playSound("common_small")
	self._specialDialog =  app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSpecialAwards",
		options = {bigTitle = "特权购买", curActivityType = self._curActivityType,allSpecialItems = self._allSpecialItems,availableItems = self._availableItems,
		title1 = "购买128后获得以下额外奖励",title2 = "现在购买立即获得以下奖励",closeCallback = function( )
			self._specialDialog = nil
		end}})
end

function QUIDialogActivityCarnivalPoints:_onTriggerAwardView(event)
	if tonumber(event) == CCControlEventTouchDown then
		self._ccbOwner.sp_jlyl:setScale(1.05)
	else
		self._ccbOwner.sp_jlyl:setScale(1)
	end		
	if q.buttonEventShadow(event, self._ccbOwner.btn_awards) == false then return end	
	app.sound:playSound("common_small")	
	local heroStr = "SS魂师碎片4选1，魂师皮肤"
	if self._curActivityType == 2 then
		heroStr = "SS天青龙牛天碎片，魂师皮肤"
	end	
	self._specialDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSpecialAwards",
		options = {bigTitle = "积分奖励预览",curActivityType = self._curActivityType,allSpecialItems = self._commonAwards,availableItems = self._allSpecialItems,
		title1 = "任务积分免费获得",title2 = "积分特权30倍返利获得", closeCallback = function( )
			self._specialDialog = nil
		end,
		subTitle1 = {{oType = "font", content = "S魂师11选1碎片",size = 20,color = ccc3(87, 47, 9)},},
   		subTitle2 = {{oType = "font", content = heroStr,size = 20,color = ccc3(255, 108, 43)},
   					 {oType = "font", content = "和海量钻石", size = 20,color = ccc3(87, 47, 9)},}}})
end

--嘉年华积分界面点击返回按钮直接退到主界面
function QUIDialogActivityCarnivalPoints:onTriggerBackHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogActivityCarnivalPoints
