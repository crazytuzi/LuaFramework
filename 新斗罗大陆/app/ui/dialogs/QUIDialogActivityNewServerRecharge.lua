

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityNewServerRecharge = class("QUIDialogActivityNewServerRecharge", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QActivity = import("...utils.QActivity")
local QVIPUtil = import(".QVIPUtil")
local QPayUtil = import("...utils.QPayUtil")


QUIDialogActivityNewServerRecharge.STATE_DEFAULT = 0		--默认
QUIDialogActivityNewServerRecharge.STATE_GET = 1		--领取奖励
QUIDialogActivityNewServerRecharge.STATE_RECHARGE = 2		--重置
QUIDialogActivityNewServerRecharge.STATE_GETTEN = 3	--已领取


function QUIDialogActivityNewServerRecharge:ctor(options)
	local ccbFile = "ccb/Dialog_NewServerRecharge.ccbi"
	self._themeId = options.themeId 

	self._isSkin = options.themeId == remote.activity.THEME_ACTIVITY_NEW_SERVER_RECHARGE_SKINS
	if self._isSkin then
		ccbFile = "ccb/Dialog_NewServerRecharge_Skin.ccbi"
	end

	local callBacks = {
		{ccbCallbackName = "onTriggerRecharge", 				callback = handler(self, self._onTriggerRecharge)},
		{ccbCallbackName = "onTriggerGet", 				callback = handler(self, self._onTriggerGet)},
		{ccbCallbackName = "onTriggerExit", 				callback = handler(self, self._onTriggerExit)},
	}
	QUIDialogActivityNewServerRecharge.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self.isAnimation = true
	q.setButtonEnableShadow(self._ccbOwner.btn_recharge)
	q.setButtonEnableShadow(self._ccbOwner.btn_get)
	q.setButtonEnableShadow(self._ccbOwner.btn_exit)
    if options then
    	self._callBack = options.callback
    	self._endBack = options.endBack
    end

	self._proxyClass = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.NEW_SERVER_RECHARGE)
end

function QUIDialogActivityNewServerRecharge:viewDidAppear()
	QUIDialogActivityNewServerRecharge.super.viewDidAppear(self)
    self._activityRoundsProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsProxy:addEventListener(remote.activityRounds.NEW_SERVER_RECHARGE_UPDATE, handler(self, self.onEvent))

	self:setInfo()
end

function QUIDialogActivityNewServerRecharge:viewWillDisappear()
  	QUIDialogActivityNewServerRecharge.super.viewWillDisappear(self)
  	if self._seasonScheduler then
		scheduler.unscheduleGlobal(self._seasonScheduler)
		self._seasonScheduler = nil
	end
  	if self._activityRoundsProxy then
  		self._activityRoundsProxy:removeAllEventListeners()
		self._activityRoundsProxy = nil
  	end

end

function QUIDialogActivityNewServerRecharge:onEvent()
	if self._proxyClass.isOpen == false then
		app.tip:floatTip("魂师大人，当前活动已结束")
		self:popSelf()
		return
	end

	self:updateInfo()
end

function QUIDialogActivityNewServerRecharge:itemClickHandler(event)

 --  	local itemType = remote.items:getItemType(event.itemID) or ITEM_TYPE.ITEM
	-- app.tip:itemTip(itemType, event.itemID , true)
	if self._isSkin then
		local itemConfig = db:getItemByID(event.itemID)
		local contents = string.split(itemConfig.content, "^")
		if contents[2] then
			local skinId = tonumber(contents[2])
	    	local skinConfig = remote.heroSkin:getSkinConfigDictBySkinId(skinId)
	    	local actorId = tonumber(skinConfig.character_id)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookMain", 
				options = {herosID = {actorId} , pos = 1, showSkinId = skinId ,  swithType = 1 , selectSinkId = skinId , isItem = true}}, {isPopCurrentDialog = true}) 			
		end
	else
	    local itemType = remote.items:getItemType(event.itemID) or ITEM_TYPE.ITEM
		app.tip:itemTip(itemType, event.itemID , true)
	end
end

function QUIDialogActivityNewServerRecharge:setInfo()
	if self._proxyClass == nil then return end
	print("self._themeId	"..self._themeId)
	self._info = self._proxyClass:getNewServerRechargeConfigByThemeId(self._themeId)
	if self._info == nil then 
	print("self._info == nil ")
	
		return 
	end
	if not self._callBack then
		app:getUserOperateRecord():setActivityClicked(self._info.activity_id)
	end

	self:setAwardDisplay()
	self:updateInfo()
end


function QUIDialogActivityNewServerRecharge:updateInfo()
	self._svrData = self._proxyClass:getNewServerRechargeSvrDataByAtyId(self._info.activity_id)
	if self._svrData == nil then return end


 	self._state = QUIDialogActivityNewServerRecharge.STATE_DEFAULT
 	if not self._svrData.buyCount or self._svrData.buyCount <= 0 then

		self._endTime = self._svrData.endAt
 		self._endTime = self._endTime / 1000
 		
 		self._state = QUIDialogActivityNewServerRecharge.STATE_RECHARGE

 		self._ccbOwner.node_btn_recharge:setVisible(true)
 		self._ccbOwner.node_btn_get:setVisible(false)

		self:handlerTimer()
	elseif self._svrData.awardCount and self._svrData.awardCount < self._svrData.buyCount then

		self._endTime = self._svrData.endAt
 		self._endTime = self._endTime / 1000

 		self._state = QUIDialogActivityNewServerRecharge.STATE_GET
 		self._ccbOwner.node_btn_recharge:setVisible(false)
 		self._ccbOwner.node_btn_get:setVisible(true)
		self:handlerTimer()
 	else
 		self._state = QUIDialogActivityNewServerRecharge.STATE_GETTEN
		if self._seasonScheduler then
			scheduler.unscheduleGlobal(self._seasonScheduler)
			self._seasonScheduler = nil
		end
 		self._ccbOwner.tf_timer:setString("活动已经结束")
 		self._ccbOwner.node_btn_recharge:setVisible(false)
 		self._ccbOwner.node_btn_get:setVisible(false)

 	end

end


function QUIDialogActivityNewServerRecharge:setAwardDisplay()
	local awards = {}

	if self._info.reward_choose then
		local awardsTbl = string.split(self._info.reward_choose, ";")
	    for i, v in pairs(awardsTbl) do
	        if v ~= "" then
	            local reward = string.split(v, "^")
	            local itemType = ITEM_TYPE.ITEM
	            if tonumber(reward[1]) == nil then
	                itemType = remote.items:getItemType(reward[1])
	            end
	            table.insert(awards, {id = reward[1], typeName = itemType, count = tonumber(reward[2]) , isShowEffect = true})
	        end
	    end		
	end

	if self._info.reward_extra then
        local reward = string.split(self._info.reward_extra, "^")
        local itemType = ITEM_TYPE.ITEM
        if tonumber(reward[1]) == nil then
            itemType = remote.items:getItemType(reward[1])
        end
        table.insert(awards, {id = reward[1], typeName = itemType, count = tonumber(reward[2]) , isShowEffect = false})
	end

	for i,data in ipairs(awards) do
		local nodeIcon = self._ccbOwner["node_icon_"..i]
		if nodeIcon then
			local item = QUIWidgetItemsBox.new()
			item:setScale(1)
			nodeIcon:addChild(item)
			item:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self.itemClickHandler))
			item:setGoodsInfo(data.id, data.typeName, data.count)


			if self._isSkin then
				local skillNameTf = self._ccbOwner["tf_skin_name_"..i]
				if skillNameTf then
					local nameStr = item:getItemName()
					local nametbl = string.split(nameStr, "·")
					local name = nametbl[1] or nameStr
					skillNameTf:setString(name)
				end

				if data.isShowEffect then
					item:showBoxEffect("effects/DailySignIn_saoguang2.ccbi", true)
				end
			else
				if data.isShowEffect then
					item:showBoxEffect("effects/Auto_Skill_light.ccbi", true, 0, 0, 1.2)
				-- item:showBoxEffect("effects/leiji_light.ccbi",true, 0, 0, 0.5)
				end
			end
		end
	end
end

function QUIDialogActivityNewServerRecharge:handlerTimer()
	if self._fun == nil then
	    self._fun = function ()
	    	local currTime = q.serverTime()
	    	local endTime = self._endTime - currTime
			if endTime > 0 then
	    		self._ccbOwner.tf_timer:setString((q.converFun(endTime)).."后礼包消失")
	    	else
	    		if self._seasonScheduler then
	    			scheduler.unscheduleGlobal(self._seasonScheduler)
	    			self._seasonScheduler = nil
	    		end
	    		self._ccbOwner.tf_timer:setString("活动已经结束")
	    		
				local arr = CCArray:create()
				arr:addObject(CCDelayTime:create(0.1))
				arr:addObject(CCCallFunc:create(function()
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

function QUIDialogActivityNewServerRecharge:_onTriggerGet(e)
	app.sound:playSound("common_small")
	local awards = {}

	if self._info.reward_choose then
		local awardsTbl = string.split(self._info.reward_choose, ";")
	    for i, v in pairs(awardsTbl) do
	        if v ~= "" then
	            local reward = string.split(v, "^")
	            local itemType = ITEM_TYPE.ITEM
	            if tonumber(reward[1]) == nil then
	                itemType = remote.items:getItemType(reward[1])
	            end
	            table.insert(awards, {id = reward[1], typeName = itemType, count = tonumber(reward[2])})
	        end
	    end		
	end

	local activityId = self._info.activity_id


	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
	        options = { awards = awards ,  explainStr = "获得以下奖励", titleText = "奖   励",confirmText = "领 取", maxOpenNum = 1,
	            okCallback = function ( chooseIndexs , selectCount)
	          		if not chooseIndexs then
						chooseIndexs = {}
					end
					local chooseIndex = chooseIndexs[1]
	            	if not chooseIndex or chooseIndex <= 0 then
	            		app.tip:floatTip("请选择")
	            		return false
	            	end
	            	local chooseAward = awards[chooseIndex]
	            	if type(chooseAward) == "table" then
	                	local awardsData = {}
	            		table.insert(awardsData, chooseAward)
						if self._info.reward_extra then
					        local reward = string.split(self._info.reward_extra, "^")
					        local itemType = ITEM_TYPE.ITEM
					        if tonumber(reward[1]) == nil then
					            itemType = remote.items:getItemType(reward[1])
					        end
					        table.insert(awardsData, {id = reward[1], typeName = itemType, count = tonumber(reward[2])})
						end
	                	QPrintTable(awardsData)


	                	local success = function ( ... )
							local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
								options = {awards = awardsData,callback = function()
								if self:safeCheck() then 
									self:delayToDestory() 
								end
								end}},{isPopCurrentDialog = false} )
							dialog:setTitle("恭喜您获得活动奖励")
	                	end
	                	local fail = function ( ... )
	                	end
						self._proxyClass:newServerRechargeGetRewardRequest(activityId, chooseIndex,  success,fail)
	                	return true
	                end
	                return true
	            end}}, {isPopCurrentDialog = false})

end



function QUIDialogActivityNewServerRecharge:delayToDestory()
	if self._seasonScheduler then
		scheduler.unscheduleGlobal(self._seasonScheduler)
		self._seasonScheduler = nil
	end
	if self._seasonScheduler == nil then
    	self._seasonScheduler = scheduler.scheduleGlobal(handler(self, self.viewAnimationOutHandler), 0.5)
	end
end


function QUIDialogActivityNewServerRecharge:_onTriggerExit(e)
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogActivityNewServerRecharge:_onTriggerRecharge(e)
	app.sound:playSound("common_small")
	self:buyByInfo()
end


function QUIDialogActivityNewServerRecharge:buyByInfo()
	if self._info == nil then return end
	local rechargeConfig = remote.activity:getRechargeConfigByRechargeBuyProductId(self._info.recharge_buy_productid)
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

function QUIDialogActivityNewServerRecharge:_backClickHandler()
 	app.sound:playSound("common_close")
	self:viewAnimationOutHandler()
end

function QUIDialogActivityNewServerRecharge:viewAnimationOutHandler()
	local callback = self._callBack
	
	self:popSelf()
	if callback then
		callback(self._endBack)
	end

end


return QUIDialogActivityNewServerRecharge