local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogOPPOGameCenter = class("QUIDialogOPPOGameCenter", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QActivity = import("...utils.QActivity")

QUIDialogOPPOGameCenter.STATE_DEFAULT = 0		--默认
QUIDialogOPPOGameCenter.STATE_GET = 1		--领取奖励
QUIDialogOPPOGameCenter.STATE_GOTO = 2		--前往
QUIDialogOPPOGameCenter.STATE_GETTEN = 3	--已领取

QUIDialogOPPOGameCenter.TAG_OFFSIDE = -82



QUIDialogOPPOGameCenter.ATY_TYPE_LOGIN = 1
QUIDialogOPPOGameCenter.ATY_TYPE_CARNIVAL_DAY = 2
QUIDialogOPPOGameCenter.ATY_TYPE_REAL_NAME = 3



function QUIDialogOPPOGameCenter:ctor(options)
	local ccbFile = "ccb/Dialog_OPPO_GameCenter.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
		{ccbCallbackName = "onTriggerGoto", callback = handler(self, self._onTriggerGoto)},
		{ccbCallbackName = "onTriggerRealName", callback = handler(self, self._onTriggerRealName)},
		{ccbCallbackName = "onTriggerCarnivalDay", callback = handler(self, self._onTriggerCarnivalDay)},
		{ccbCallbackName = "onTriggerLogin", callback = handler(self, self._onTriggerLogin)},
    }
    
    QUIDialogOPPOGameCenter.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	q.setButtonEnableShadow(self._ccbOwner.btn_get)
	q.setButtonEnableShadow(self._ccbOwner.btn_goto)
	q.setButtonEnableShadow(self._ccbOwner.btn_real_name)
	q.setButtonEnableShadow(self._ccbOwner.btn_carnival_day)
	q.setButtonEnableShadow(self._ccbOwner.btn_login)
	self.isAnimation = true --是否动画显示
	self._state = QUIDialogOPPOGameCenter.STATE_DEFAULT 
	self._platformId = options.platformId or 8
	self._atyType = QUIDialogOPPOGameCenter.ATY_TYPE_LOGIN 
	self.items = {}
end

function QUIDialogOPPOGameCenter:viewDidAppear()
	QUIDialogOPPOGameCenter.super.viewDidAppear(self)
	self:setInfo()
end

function QUIDialogOPPOGameCenter:viewWillDisappear()
  	QUIDialogOPPOGameCenter.super.viewWillDisappear(self)

	if self._seasonScheduler then
		scheduler.unscheduleGlobal(self._seasonScheduler)
		self._seasonScheduler = nil
	end

end

function QUIDialogOPPOGameCenter:resetAll()
	self._ccbOwner.node_get:setVisible(false)
	self._ccbOwner.node_goto:setVisible(false)
	self._ccbOwner.node_getten:setVisible(false)
	self._ccbOwner.node_prize:setVisible(false)
	self._ccbOwner.tf_timer:setVisible(false)
	self._ccbOwner.sp_desc_up:setVisible(false)
	self._ccbOwner.sp_desc_bottom:setVisible(false)
	self._ccbOwner.tf_timer_desc:setVisible(false)

end

function QUIDialogOPPOGameCenter:setInfo()
	self:updateInfo()
end

function QUIDialogOPPOGameCenter:updateInfo()
	self._atyType = QUIDialogOPPOGameCenter.ATY_TYPE_LOGIN 
	self._isCarnivalDay , self._endTime  =  remote.activity:getActivityChannelTimeDatById(QActivity.ACTIVITY_CHANNEL.CARNIVAL_DAY_OPPO)
	if self._isCarnivalDay then
		self._atyType = QUIDialogOPPOGameCenter.ATY_TYPE_CARNIVAL_DAY
		self._ccbOwner.node_carnival_day:setVisible(true)
		self._ccbOwner.node_carnival_day:setPositionY(0)
		self._ccbOwner.node_login:setPositionY(QUIDialogOPPOGameCenter.TAG_OFFSIDE)
		self._ccbOwner.node_real_name:setPositionY( QUIDialogOPPOGameCenter.TAG_OFFSIDE * 2 )
		self:handlerTimer()
	else
		self._ccbOwner.node_carnival_day:setVisible(false)
		self._ccbOwner.node_login:setPositionY(0)
		self._ccbOwner.node_real_name:setPositionY( QUIDialogOPPOGameCenter.TAG_OFFSIDE )
		self._ccbOwner.node_carnival_day:setPositionY( QUIDialogOPPOGameCenter.TAG_OFFSIDE * 2 )
	end

	--判断是否实名制
	local checkRealName = remote.activity:checkGettenAwardByById(QActivity.ACTIVITY_CHANNEL.REAL_NAME_OPPO)
	self._ccbOwner.node_real_name:setVisible(not checkRealName)

	self:updateInfoByTag()
end

function QUIDialogOPPOGameCenter:updateInfoByTag()
	self:resetAll()
	QSetDisplayFrameByPath(self._ccbOwner.sp_title,QResPath("oppo_title_sp")[self._atyType])
	if self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_LOGIN then

		self._channelConfig = remote.activity:getActivityTargetChannelConfigById(QActivity.ACTIVITY_CHANNEL.GAME_CENTER_OPPO)
		if self._channelConfig == nil then
			return
		end

		self:_showLoginGameCenter()
	elseif  self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_CARNIVAL_DAY then
		self._channelConfig = remote.activity:getActivityTargetChannelConfigById(QActivity.ACTIVITY_CHANNEL.CARNIVAL_DAY_OPPO)
		if self._channelConfig == nil then
			return
		end

		self:_showCarnivalDay()
	elseif  self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_REAL_NAME then
		self._channelConfig = remote.activity:getActivityTargetChannelConfigById(QActivity.ACTIVITY_CHANNEL.REAL_NAME_OPPO)
		if self._channelConfig == nil then
			return
		end
		self:_showRealName()
	end

	self:updateBtn()
	self:setPrize()
end

function QUIDialogOPPOGameCenter:updateBtn()
	self._ccbOwner.btn_login:setHighlighted(self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_LOGIN)
	self._ccbOwner.btn_carnival_day:setHighlighted(self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_CARNIVAL_DAY)
	self._ccbOwner.btn_real_name:setHighlighted(self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_REAL_NAME)

	local colorT = 	ccc3(78, 50, 46)
	local colorF =  ccc3(208, 177, 106)

	self._ccbOwner.tf_login:setColor(self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_LOGIN and colorT or colorF )
	self._ccbOwner.tf_carnival_day:setColor(self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_CARNIVAL_DAY and colorT or colorF )
	self._ccbOwner.tf_real_name:setColor(self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_REAL_NAME and colorT or colorF )
end

function QUIDialogOPPOGameCenter:_showLoginGameCenter()

	local getten = remote.activity:checkGettenAwardByById(self._channelConfig.id)
	local getB = FinalSDK.isFromGameCenter()
	if getten then
		self._state = QUIDialogOPPOGameCenter.STATE_GETTEN
	elseif getB then
		self._state = QUIDialogOPPOGameCenter.STATE_GET
	else
		self._state = QUIDialogOPPOGameCenter.STATE_GOTO
	end
	QSetDisplayFrameByPath(self._ccbOwner.sp_desc_up,QResPath("oppo_text_sp")[3])
	QSetDisplayFrameByPath(self._ccbOwner.sp_desc_bottom,QResPath("oppo_text_sp")[1])
	local prizePosY = 0

	prizePosY= self._ccbOwner.node_bottom_pos:getPositionY()
	self._ccbOwner.tf_timer_desc:setVisible(false)	
	self._ccbOwner.node_prize:setVisible(true)

	if self._state == QUIDialogOPPOGameCenter.STATE_GET then
		self._ccbOwner.node_get:setVisible(true)
		self._ccbOwner.sp_desc_up:setVisible(true)
		self._ccbOwner.tf_timer_desc:setVisible(true)

	elseif self._state == QUIDialogOPPOGameCenter.STATE_GOTO then
		self._ccbOwner.node_goto:setVisible(true)
		self._ccbOwner.sp_desc_bottom:setVisible(true)
		prizePosY= self._ccbOwner.node_up_pos:getPositionY()
	elseif self._state == QUIDialogOPPOGameCenter.STATE_GETTEN then
		self._ccbOwner.node_getten:setVisible(true)
		self._ccbOwner.sp_desc_up:setVisible(true)
		self._ccbOwner.tf_timer_desc:setVisible(true)

	else
		self._ccbOwner.node_goto:setVisible(true)		
		self._ccbOwner.sp_desc_up:setVisible(true)
		self._ccbOwner.tf_timer_desc:setVisible(true)

	end
	self._ccbOwner.node_prize:setPositionY(prizePosY)	

end


function QUIDialogOPPOGameCenter:_showCarnivalDay()
	local getten = remote.activity:checkGettenAwardByById(self._channelConfig.id)
	if getten then
		self._state = QUIDialogOPPOGameCenter.STATE_GETTEN
	else
		self._state = QUIDialogOPPOGameCenter.STATE_GET
	end
	QSetDisplayFrameByPath(self._ccbOwner.sp_desc_up,QResPath("oppo_text_sp")[2])
	self._ccbOwner.sp_desc_up:setVisible(true)
	self._ccbOwner.tf_timer:setVisible(true)	
	self._ccbOwner.node_prize:setVisible(true)	
	if self._state == QUIDialogOPPOGameCenter.STATE_GETTEN then
		self._ccbOwner.node_getten:setVisible(true)
	else
		self._ccbOwner.node_get:setVisible(true)
	end
	self._ccbOwner.node_prize:setPositionY(self._ccbOwner.node_bottom_pos:getPositionY())	

end

function QUIDialogOPPOGameCenter:_showRealName()
	local getten = remote.activity:checkGettenAwardByById(self._channelConfig.id)
	local notReal = remote.activity:checkChannelHasRealName(8)
	if not notReal then
		self._state = QUIDialogOPPOGameCenter.STATE_GOTO
	elseif getten then
		self._state = QUIDialogOPPOGameCenter.STATE_GETTEN
	else
		self._state = QUIDialogOPPOGameCenter.STATE_GET
	end
	QSetDisplayFrameByPath(self._ccbOwner.sp_desc_up,QResPath("oppo_text_sp")[4])
	self._ccbOwner.sp_desc_up:setVisible(true)
	self._ccbOwner.node_prize:setVisible(true)
	if self._state == QUIDialogOPPOGameCenter.STATE_GETTEN then
		self._ccbOwner.node_getten:setVisible(true)
	elseif self._state == QUIDialogOPPOGameCenter.STATE_GOTO then
		self._ccbOwner.node_goto:setVisible(true)		
	else
		self._ccbOwner.node_get:setVisible(true)
	end

	self._ccbOwner.node_prize:setPositionY(self._ccbOwner.node_bottom_pos:getPositionY())	
end

function QUIDialogOPPOGameCenter:handlerTimer()
	if self._fun == nil then
	    self._fun = function ()
	    	local currTime = q.serverTime()
	    	local endTime = self._endTime - currTime
			if endTime > 0 then
	    		self._ccbOwner.tf_timer:setString("活动剩余时间："..(q.converFun(endTime)))
	    	else
	    		if self._seasonScheduler then
	    			scheduler.unscheduleGlobal(self._seasonScheduler)
	    			self._seasonScheduler = nil
	    		end
	    		self._ccbOwner.tf_timer:setString("活动已经结束")
	    		
				local arr = CCArray:create()
				arr:addObject(CCDelayTime:create(0.1))
				arr:addObject(CCCallFunc:create(function()
					self._ccbOwner.node_login:setPositionY(0)
					self._ccbOwner.node_real_name:setPositionY( QUIDialogOPPOGameCenter.TAG_OFFSIDE )
					self._ccbOwner.node_carnival_day:setPositionY( QUIDialogOPPOGameCenter.TAG_OFFSIDE * 2 )
					self._atyType = QUIDialogOPPOGameCenter.ATY_TYPE_LOGIN
					self:updateInfoByTag() 
				end))
				self._ccbOwner.tf_timer:stopAllActions()
	        	self._ccbOwner.tf_timer:runAction(CCSequence:create(arr))
	    	end
	    end
	end
	
	if self._seasonScheduler == nil then
    	self._seasonScheduler = scheduler.scheduleGlobal(self._fun, 1)
	end
    self._fun()
end



function QUIDialogOPPOGameCenter:itemClickHandler(event)
    local itemType = remote.items:getItemType(event.itemID) or ITEM_TYPE.ITEM
	app.tip:itemTip(itemType, event.itemID , true)
end

function QUIDialogOPPOGameCenter:setPrize()

    local awardsTbl = string.split(self._channelConfig.reward, ";")
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

	for i=1,3 do
		local data = self._awards[i]
		self._ccbOwner["node_prize_"..i]:setVisible(false)
		if data then
			self._ccbOwner["node_prize_"..i]:setVisible(true)
			local item = self.items[i]
			if item == nil then
				item = QUIWidgetItemsBox.new()
				item:setScale(0.7)
				self._ccbOwner["node_prize_icon_"..i]:addChild(item)
				item:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self.itemClickHandler))
				self.items[i] = item
			end
			item:setGoodsInfo(data.id, data.typeName, data.count)
			if data.effect then
				item:showBoxEffect("effects/leiji_light.ccbi",true, 0, 0, 0.6)
			else
				item:removeEffect()
			end

			local nameStr = item:getItemName()
			self._ccbOwner["tf_prize_name_"..i]:setString(nameStr)

		end
	end


	local prizeNum  = #self._awards
	if prizeNum >= 3 then
		self._ccbOwner.node_prize_1:setPositionX(-148)
		self._ccbOwner.node_prize_2:setPositionX(0)
		self._ccbOwner.node_prize_3:setPositionX(148)
	elseif prizeNum == 2 then
		self._ccbOwner.node_prize_1:setPositionX(-74)
		self._ccbOwner.node_prize_2:setPositionX(74)
	elseif prizeNum == 1 then
		self._ccbOwner.node_prize_1:setPositionX(0)
	end
end


function QUIDialogOPPOGameCenter:_onTriggerGet(event)
    app.sound:playSound("common_small")
    print("_onTriggerGet")
    remote.activity:activityChannelGetRewardRequest(self._channelConfig.id ,function(data)
		if self:safeCheck() then
    		self:updateInfoByTag()
    	end
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
			options = {awards = self._awards}},{isPopCurrentDialog = false} )
    end )
end

function QUIDialogOPPOGameCenter:_onTriggerGoto(event)
    app.sound:playSound("common_small")
    print("_onTriggerGoto")

	if self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_LOGIN then
    	FinalSDK:openGameCenter()
    	self:_onTriggerClose()
	elseif  self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_CARNIVAL_DAY then
	elseif  self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_REAL_NAME then
    	FinalSDK:gotoRealName(function(err)	
			scheduler.performWithDelayGlobal(function()

				if self:safeCheck() then
					self:updateInfoByTag()
				end
			end, 0.1)
		end) 
	end

end

-- QUIDialogOPPOGameCenter.ATY_TYPE_LOGIN = 1
-- QUIDialogOPPOGameCenter.ATY_TYPE_CARNIVAL_DAY = 2
-- QUIDialogOPPOGameCenter.ATY_TYPE_REAL_NAME = 3
function QUIDialogOPPOGameCenter:_onTriggerLogin(event)
	if self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_LOGIN then
		self._ccbOwner.btn_login:setHighlighted(true)
		return
	end
	app.sound:playSound("common_menu")
	self._atyType = QUIDialogOPPOGameCenter.ATY_TYPE_LOGIN
	self:updateInfoByTag()
end

function QUIDialogOPPOGameCenter:_onTriggerCarnivalDay(event)
	if self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_CARNIVAL_DAY then
		self._ccbOwner.btn_carnival_day:setHighlighted(true)
		return
	end
	app.sound:playSound("common_menu")
	self._atyType = QUIDialogOPPOGameCenter.ATY_TYPE_CARNIVAL_DAY
	self:updateInfoByTag()
end

function QUIDialogOPPOGameCenter:_onTriggerRealName(event)
	if self._atyType == QUIDialogOPPOGameCenter.ATY_TYPE_REAL_NAME then
		self._ccbOwner.btn_real_name:setHighlighted(true)
		return
	end
	app.sound:playSound("common_menu")
	self._atyType = QUIDialogOPPOGameCenter.ATY_TYPE_REAL_NAME
	self:updateInfoByTag()
end

function QUIDialogOPPOGameCenter:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogOPPOGameCenter:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogOPPOGameCenter:viewAnimationOutHandler()
	local callback = self._callBack
	
	self:popSelf()
	if callback then
		callback()
	end

end


return QUIDialogOPPOGameCenter