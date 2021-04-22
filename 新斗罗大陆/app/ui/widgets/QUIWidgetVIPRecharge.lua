--
-- Author: Qinyuanji
-- Date: 2015-1-20
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetVIPRecharge = class("QUIWidgetVIPRecharge", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QPayUtil = import("...utils.QPayUtil")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")

local QRichText = import("...utils.QRichText")

function QUIWidgetVIPRecharge:ctor(options)
	local ccbFile = "ccb/Widget_VIP_arena.ccbi"
	local callBacks = {
	}
	QUIWidgetVIPRecharge.super.ctor(self, ccbFile, callBacks, options)

	self:setInfo(options)

end

function QUIWidgetVIPRecharge:onEnter( ... )
	self.super.onEnter(self)

    self._ccbOwner.background:setTouchEnabled(true)
    self._ccbOwner.background:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._ccbOwner.background:setTouchSwallowEnabled(false)
    self._ccbOwner.background:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetVIPRecharge._onTriggerClick))
end

function QUIWidgetVIPRecharge:onExit( ... )
	self.getOptions = nil
    self._ccbOwner.background:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)

    if self._rechargeProgress then
    	scheduler.unscheduleGlobal(self._rechargeProgress)
    	self._rechargeProgress = nil
    end

	self.super.onExit(self)
end

function QUIWidgetVIPRecharge:setInfo(options)
	self:setOptions(options)
	-- self._ccbOwner.buyNode:setVisible(options.type == 1)
	-- self._ccbOwner.monthlyNode:setVisible(options.type == 2)
	self._ccbOwner.recommend:setVisible(options.type == 2)
	self._ccbOwner.monthlyNode:setVisible(false)
	self._ccbOwner.remainingDays:setVisible(false)
	self._ccbOwner.node_cost:setVisible(true)

	self._ccbOwner.firstRecharge:setVisible(options.type == 1 and options.boughtCount == 0)

	local frame = display.newSpriteFrame(options.icon)
	if frame then
		self._ccbOwner.node_icon:setDisplayFrame(frame)
	end

	-- frame = display.newSpriteFrame(options.icon2)
	-- if frame then
	-- 	self._ccbOwner.presentCount:setDisplayFrame(frame)
	-- end


	if not self._labelRichText then
		self._labelRichText = QRichText.new(nil, 200, {autoCenter = true})
		self._ccbOwner.labelRichText:addChild(self._labelRichText)
		self._labelRichText:setPositionY(-10)
	end

	if options.isHighLight then
		self._ccbOwner.highLight:setVisible(true)
	else
		self._ccbOwner.highLight:setVisible(false)
	end

	QStaticDatabase:sharedDatabase():getItemByID(self._itemID)

	if options.type == 1 then
		local extraDiamond = options.extra[options.boughtCount + 1] or options.extra[#options.extra]
		local extraAwardsStr = options.extraAward[options.boughtCount + 1] 
		local extraAwards = {}
		if extraAwardsStr then
			local items = string.split(extraAwardsStr, ";") 
			local count = #items
			for i=1,count,1 do
	            local obj = string.split(items[i], "^")
	            if #obj == 2 then
	            	local resouce = remote.items:getWalletByType(obj[1])
	            	if resouce ~= nil then
	            		if obj[2] == "1" then
	            			table.insert(extraAwards, resouce.nativeName)
	            		else
	            			table.insert(extraAwards, obj[2]..resouce.nativeName)
	            		end
	            	else
		            	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(obj[1])
		            	if itemInfo then
		            		if obj[2] == "1" then
		            			table.insert(extraAwards, itemInfo.name)
		            		else
		            			table.insert(extraAwards, itemInfo.name.."x"..obj[2])
		            		end
		            	end
		            end
	            end
			end
		end

		local cfg = {}
		if options.boughtCount == 0 then
			if #extraAwards ~= 0 then
				table.insert(cfg, {oType = "bmfont",scale = 0.7, fontName = "font/FontYellowTips1.fnt", content = "首冲双倍,另赠"})
				if extraAwards[1] then
					table.insert(cfg, {oType = "bmfont",scale = 0.7, fontName = "font/FontYellowTips2.fnt", content = extraAwards[1], offset = ccp(0,-2)})
				end
				if extraAwards[2] then
					table.insert(cfg, {oType = "bmfont",scale = 0.7, fontName = "font/FontYellowTips1.fnt", content = "和"})
					table.insert(cfg, {oType = "bmfont",scale = 0.7, fontName = "font/FontYellowTips2.fnt", content = extraAwards[2], offset = ccp(0,-2)})
				end
				table.insert(cfg, {oType = "bmfont",scale = 0.7, fontName = "font/FontYellowTips1.fnt", content = "道具"})
			else
				--临时修改
				table.insert(cfg, {oType = "font", content = "额外赠 "..string.format("%d",options.presentCount or 0).." 钻石", size = 19})
			end
		else
			table.insert(cfg, {oType = "font", content = "额外赠 "..string.format("%d", extraDiamond).." 钻石", size = 19})

		end
		self._labelRichText:setString(cfg)
		self._ccbOwner.presentCount:setString((options.presentCount or 0) .. "钻石")
	else
		local remainingDays = 0
		local rmb = tonumber(options.cost) or 0
		local cardType = 1
        if rmb == 25 then
        	cardType = 1
            remainingDays = (remote.recharge.monthCard1EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(DAY)
            self._ccbOwner.presentCount:setString("普通月卡")
        else
        	cardType = 2
            remainingDays = (remote.recharge.monthCard2EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(DAY)
        	self._ccbOwner.presentCount:setString("至尊月卡")
        end
        
		local cfg = {}	
		table.insert(cfg, {oType = "font", content = "每日赠 "..string.format("%d", options.dailyPresent).."钻石 ", size = 19})
		local needReturn = false

		local maxDays = QStaticDatabase:sharedDatabase():getConfigurationValue("month_card_date")
		remainingDays = remainingDays - 1      --显示的时间比实际时间少一天
		if remainingDays >= maxDays then
			self._ccbOwner.monthlyNode:setVisible(true)
			self._ccbOwner.remainingDays:setVisible(true)
			self._ccbOwner.node_cost:setVisible(false)
			self._ccbOwner.remainingDays:setString(string.format("已购买(剩余%d天)", (remainingDays or 0)))
			self._ccbOwner.recommend:setVisible(false)
			self._ccbOwner.background_an:setVisible(true)
			self._ccbOwner.background:setVisible(false)
			self._ccbOwner.btn_money:setVisible(false)
			self._clickImpl = function ( ... ) 
				-- app.tip:floatTip(global.already_subscribed_tip)
				local taskIndex = nil
				if cardType == 1 then
					taskIndex = "200001"
				else
					taskIndex = "200002"
				end
				if remote.task:checkTaskisDone(taskIndex) == true then
					remote.task:drawCard(taskIndex)
				else
					app.tip:floatTip("您已领取今日奖励钻石")
				end
			end
		elseif remainingDays >= 0 and remainingDays < maxDays then
			cfg = {}
			table.insert(cfg, {oType = "font", content = "立即获得 "..string.format("%d", options.presentCount).."钻石 ", size = 19})
			self._ccbOwner.monthlyNode:setVisible(true)
			self._ccbOwner.recommend:setVisible(false)
			self._ccbOwner.remainingDays:setVisible(true)
			self._ccbOwner.remainingDays:setString(string.format("已购买(剩余%d天)", (remainingDays or 0)))
			self._ccbOwner.remainingDays:setPositionY(-10)
			self._ccbOwner.remainingDays:setFontSize(18)
			needReturn = true
		else
			self._ccbOwner.monthlyNode:setVisible(false)
		end
		self._labelRichText:setString(cfg)
	end
	if needReturn then
		return
	end

	if self._costText == nil then
       	self._costText = QRichText.new(nil, 170, {stringType = 1, autoCenter = true})
        self._costText:setAnchorPoint(ccp(0.5, 0.5))
	    local strTable = {
	       	{oType = "img", fileName = "ui/Vip_Chongzhi/vip_money.png", skewX = 0, scale = 1, offsetY = 1.5},
	       	{oType = "font", content = options.cost or 0, size = 28, color = ccc3(255, 254, 235), strokeColor = ccc3(196, 105, 4)},
	    }
	    self._costText:setString(strTable)
	    self._ccbOwner.node_cost:addChild(self._costText)
	end

	local currentRecharged = QVIPUtil:recharged()
	local currentVIPLevel = QVIPUtil:VIPLevel()

	self._clickImpl = function ( )
		if ENABLE_CHARGE_BY_WEB and CHARGE_WEB_URL then
			QPayUtil.payOffine(self:getOptions().cost, self:getOptions().type)
		else
			app:showLoading()
		    if self._rechargeProgress then
		    	scheduler.unscheduleGlobal(self._rechargeProgress)
		    	self._rechargeProgress = nil
		    end
			self._rechargeProgress = scheduler.performWithDelayGlobal(function ( ... )
				app:hideLoading()
			end, 10)
			if FinalSDK.isHXIOS() then
				QPayUtil:hjPayOffline(self:getOptions().cost, self:getOptions().type, nil)
			else
				QPayUtil:pay(self:getOptions().cost, self:getOptions().type, nil)
			end
		end
	end
end

function QUIWidgetVIPRecharge:_onTriggerClick(event)
	local parent = self:getOptions().parent
	if event.name == "began" then
		self._ccbOwner.widgetRootNode:setScale(0.95)
		self._isScale = true
	elseif event.name == "moved" then
		if  parent and (parent._isMoving or parent:isScrollViewMoving()) then
			if self._isScale then
				self._ccbOwner.widgetRootNode:setScale(1)
				self._isScale = nil
			end
		end
	elseif event.name == "ended" then
		if  parent and not parent._isMoving and not parent:isScrollViewMoving() then
	    	app.sound:playSound("common_small")
			self._clickImpl()
		end
		if self._isScale then
			self._ccbOwner.widgetRootNode:setScale(1)
			self._isScale = nil
		end
	end
	
end

function QUIWidgetVIPRecharge:getContentSize()
	return self._ccbOwner.background:getContentSize()
end

return QUIWidgetVIPRecharge