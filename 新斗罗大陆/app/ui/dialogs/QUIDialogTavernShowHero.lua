-- @Author: xurui
-- @Date:   2017-10-16 14:33:02
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-10 18:30:15
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTavernShowHero = class("QUIDialogTavernShowHero", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetTavernShowHeroAvatar = import("..widgets.QUIWidgetTavernShowHeroAvatar")
local QUIWidgetTavernScoreAward = import("..widgets.QUIWidgetTavernScoreAward")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText")
local QUIDialogPreview = import("..dialogs.QUIDialogPreview")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")

function QUIDialogTavernShowHero:ctor(options)
	local ccbFile = "ccb/Dialog_tavern_page.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerBuyOne", callback = handler(self, self._onTriggerBuyOne)},
		{ccbCallbackName = "onTriggerBuyTen", callback = handler(self, self._onTriggerBuyTen)},
		{ccbCallbackName = "onTriggerBuyHalf", callback = handler(self, self._onTriggerBuyHalf)},
		{ccbCallbackName = "onTriggerPreview", callback = handler(self, self._onTriggerPreview)},
		{ccbCallbackName = "onTriggerConditionInfo", callback = handler(self, self._onTriggerConditionInfo)},
    }
    QUIDialogTavernShowHero.super.ctor(self, ccbFile, callBacks, options)
	self._page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._page:setScalingVisible(true)
    -- page.topBar:showWithMainPage()

    CalculateUIBgSize(self._ccbOwner.node_gold_bg, 1280)
    CalculateUIBgSize(self._ccbOwner.node_sliver_bg, 1280)
    
 	-- self._touchWidth = self._ccbOwner.sheet_layout:getContentSize().width
	-- self._touchHeight = self._ccbOwner.sheet_layout:getContentSize().height
 	-- self._touchLayer = QUIGestureRecognizer.new()
	-- self._touchLayer:setSlideRate(0.3)
	-- self._touchLayer:setAttachSlide(true)
	-- self._touchLayer:attachToNode(self._ccbOwner.sheet, self._touchWidth, self._touchHeight, self._ccbOwner.sheet_layout:getPositionX(),
	-- self._ccbOwner.sheet_layout:getPositionY(), handler(self, self.onTouchEvent))
  
    self._heroAvatar = {}
    self._silverCardId = 23
    self._goldCardId = 24
    self._scale = 0.8
    self._normalColor = ccc3(255, 255, 255)
    self._blackColor = ccc3(40, 40, 40)
    self._avatarOffsetX = 70
	self._isHalf = false
    self._luckyDrawCount = 30

    self._tavernType = options.tavernType or TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE
    if self._tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
    	self._page.topBar:showWithTavernAdvance()
		self._ccbOwner.node_gold_bg:setVisible(true)
		self._ccbOwner.node_sliver_bg:setVisible(false)
		self._ccbOwner.node_gold_bg:setScale(1.05)	
		self:initScoreAward()
	else
		self._page.topBar:showWithTavernNormal()
		self._ccbOwner.node_gold_bg:setVisible(false)
		self._ccbOwner.node_sliver_bg:setVisible(true)
		self._ccbOwner.node_sliver_bg:setScale(1.05)		
    	self._ccbOwner.sale:setVisible(false)
	end

    -- self:initHeroCardList()
end

function QUIDialogTavernShowHero:viewDidAppear()
	QUIDialogTavernShowHero.super.viewDidAppear(self)
	
    -- self._touchLayer:enable()
    -- self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
	-- self:stopAutoMove()
	-- self:startAutoMove()
	self._itemsProxy = cc.EventProxy.new(remote.items)
	self._itemsProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self._onItemNumUpdate))

	self:setClientInfo()
	self:addBackEvent(false)

    local array = CCArray:create()
    array:addObject(CCScaleTo:create(0.15, 1.0))
    if self._tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
    	self._ccbOwner.node_gold_bg:runAction(CCScaleTo:create(0.15, 1.0))
    else
    	self._ccbOwner.node_sliver_bg:runAction(CCScaleTo:create(0.15, 1.0))	
    end
	
end

function QUIDialogTavernShowHero:viewWillDisappear()
  	QUIDialogTavernShowHero.super.viewWillDisappear(self)

 	-- self._touchLayer:removeAllEventListeners()
	-- self._touchLayer:disable()
	-- self._touchLayer:detach()
	-- self:stopAutoMove()

	if self._itemsProxy ~= nil then
		self._itemsProxy:removeAllEventListeners()
		self._itemsProxy = nil
	end

	self:removeBackEvent()
end

function QUIDialogTavernShowHero:_onItemNumUpdate()
	local isGold = self._tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE
	if not isGold then return end
	self._cardNum = remote.items:getItemsNumByID(self._goldCardId)
	local isFree, oneText, tenText = self:checkGoldMoneyState()
	self._ccbOwner.tf_money:setString(oneText)
	self._ccbOwner.tf_money_ten:setString(tenText)
end

function QUIDialogTavernShowHero:initHeroCardList()
    self._heroList = QStaticDatabase:sharedDatabase():getTavernOverViewInfoByTavernType("1")
    if self._tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
    	self._heroList = QStaticDatabase:sharedDatabase():getTavernOverViewInfoByTavernType("2")
    end
    self._heroList = string.split(self._heroList.hero_1, ";")

    local count = #self._heroList
    self._diffX = 260
    self._listSize = self._diffX*count 
    if self._listSize < display.width+self._diffX then
    	self._listSize = display.width+self._diffX 
    end
    self._offsetX = -display.width/2

	for i = 1, count do
		self._heroAvatar[i] = QUIWidgetTavernShowHeroAvatar.new(self._tavernType)
		self._heroAvatar[i]:setHero(self._heroList[i])
		self._heroAvatar[i]:setPositionX(self._diffX*i+self._offsetX)
		self._heroAvatar[i]:addEventListener(QUIWidgetTavernShowHeroAvatar.EVENT_AVATAR_CLICK, handler(self, self._cellClickHandler))
		self._ccbOwner.node_hero:addChild(self._heroAvatar[i])
	end
end

function QUIDialogTavernShowHero:stopAutoMove()
	if self._heroMoveHandler then
		scheduler.unscheduleGlobal(self._heroMoveHandler)
		self._heroMoveHandler = nil
	end
end

function QUIDialogTavernShowHero:startAutoMove()
	self._heroMoveHandler = scheduler.scheduleGlobal(function ()
		self:autoMove()
	end, 0.01)
end

function QUIDialogTavernShowHero:autoMove()
	for i = 1, #self._heroList do
		local posX = self._heroAvatar[i]:getPositionX()
		if posX < -display.width/2 - self._diffX/2 then
			posX = posX + self._listSize
		elseif posX > display.width/2 + self._diffX/2 then
			posX = posX - self._listSize
		end
		posX = posX+1
		self._heroAvatar[i]:setPositionX(posX)
		self._heroAvatar[i]:setTouchEnabled(true)
	end
end

function QUIDialogTavernShowHero:moveTo(offsetX)
	for i = 1, #self._heroList do
		local posX = self._heroAvatar[i]:getPositionX()
		if posX+offsetX < -display.width/2 - self._diffX/2 then
			posX = posX + self._listSize
		elseif posX+offsetX > display.width/2 + self._diffX/2 then
			posX = posX - self._listSize
		end
		self._heroAvatar[i]:setPositionX(posX+offsetX)
		if self._isMoving then
			self._heroAvatar[i]:setTouchEnabled(false)
		end
	end
end

function QUIDialogTavernShowHero:onTouchEvent(event)
	if event == nil or event.name == nil then
        return
    end
    
    if event.name == "began" then
    	self:stopAutoMove()
  		self._startX = event.x
  		self._start = event.x
    elseif event.name == "moved" then
    	local offsetX = event.x - self._startX
    	self._startX = event.x
    	if math.abs(event.x - self._start) > 10 then
    		self._isMoving= true
    	end
		self:moveTo(offsetX, false)
	elseif event.name == "ended" then
		self._isMoving= false
		self:startAutoMove()
    end
end


function QUIDialogTavernShowHero:setClientInfo()
	print("QUIDialogTavernShowHero:setClientInfo()")
	local isGold = self._tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE

	self._ccbOwner.sp_silver_one:setVisible(not isGold)
	self._ccbOwner.sp_silver_ten:setVisible(not isGold)
	self._ccbOwner.sp_gold_one:setVisible(isGold)
	self._ccbOwner.sp_gold_ten:setVisible(isGold)
	self._ccbOwner.node_choujiangCount:setVisible(false)

	self._cardNum = remote.items:getItemsNumByID(self._silverCardId)
	local isFree, oneText, tenText = self:checkSilverMoneyState()
	if isGold then
		self._cardNum = remote.items:getItemsNumByID(self._goldCardId)
		isFree, oneText, tenText = self:checkGoldMoneyState()
	end
	self._isFree = isFree

	self._ccbOwner.tf_money:setString(oneText)
	self._ccbOwner.tf_money_ten:setString(tenText)

	if isFree then
		self._ccbOwner.node_free_tf:setPositionX(-50)
	else
		self._ccbOwner.node_free_tf:setPositionX(0)
	end

	local oneContent1, oneContent2, oneContent3 = "", "次后必送", ""
	local tenContent1, tenContent2, tenContent3 = "", "次十连后必送", ""

	if isGold then
		oneContent1 = 10 - (remote.user.totalLuckyDrawAdvanceCount or 0)%10
		if app.tutorial:isTutorialFinished() == false and app.tutorial:getStage().forced == 1 then
			oneContent1, oneContent2, oneContent3 = "", "", ""
    		tenContent1, tenContent2, tenContent3 = "", "", ""
		else
			tenContent1 = math.ceil((self._luckyDrawCount - (remote.user.totalLuckyDrawAdvanceCount or 0)%self._luckyDrawCount) / 10)

			tenContent3 = "##pA+##f或##yS##f魂师"
	        if math.ceil((self._luckyDrawCount - (remote.user.totalLuckyDrawAdvanceCount or 0)%self._luckyDrawCount)/10) == 1 then
				oneContent3 = "##pA+##f或##yS##f魂师"
	        else
				oneContent3 = "##pA、A+##f或##yS##f魂师"
			end
		end

		self:updateActivityCount()
	else
		if app.tutorial:isTutorialFinished() == false and app.tutorial:getStage().forced == 1 then
			oneContent1, oneContent2, oneContent3 = "", "", ""
        else
        	oneContent3 = "##pA或A+##f魂师碎片"
        	oneContent1 = 10 - (remote.user.totalLuckyDrawNormalCount or 0)%10
        end
    	tenContent1, tenContent2, tenContent3 = "", "", ""
	end

	self._ccbOwner.node_tf_one_content:removeAllChildren()
	self._ccbOwner.node_tf_ten_content:removeAllChildren()

	local str = "##q"..oneContent1.."##f"..oneContent2..oneContent3
   	local richText1 = QRichText.new(str, 320, {autoCenter = true, stringType = 1})
   	richText1:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_tf_one_content:addChild(richText1)

    str = "##q"..tenContent1.."##f"..tenContent2..tenContent3
   	local richText2 = QRichText.new(str, 320, {autoCenter = true, stringType = 1})
   	richText2:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_tf_ten_content:addChild(richText2)
end

function QUIDialogTavernShowHero:updateActivityCount()
	local activityInfo = remote.activity:getActivityDataByTagetId(508)
	if activityInfo and activityInfo.targets then
		self._ccbOwner.node_choujiangCount:setVisible(true)
		local count = 0
		local maxCount = 0
		for _,info in pairs(activityInfo.targets) do
			local infoCount = remote.activity:getTypeNum(info) or 0
			count = math.max(count,infoCount) 
			maxCount = math.max(maxCount,(info.value or 0))
		end
		if maxCount ~= 0 and count >= maxCount then
			self._ccbOwner.tf_choujiang_name:setString("已达成活动招募目标")
			self._ccbOwner.tf_choujiang_count:setString("")
		else
			self._ccbOwner.tf_choujiang_count:setString(count)
			self._ccbOwner.tf_choujiang_name:setString("活动期间招募次数：")
		end
		q.autoLayerNode({self._ccbOwner.tf_choujiang_name,self._ccbOwner.tf_choujiang_count},"x",0)		
	else
		self._ccbOwner.node_choujiangCount:setVisible(false)
	end
end

function QUIDialogTavernShowHero:checkSilverMoneyState()
	local isFree = false
	local oneText = ""
	local tenText = ""

	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	local silverCount = config.LUCKY_DRAW_COUNT.value or 0 -- 白银宝箱的次数
	local CDTime = (config.LUCKY_DRAW_TIME.value or 0) * 60 -- 白银宝箱的CD时间
	local lastTime = (remote.user.luckyDrawRefreshedAt or 0)/1000

	local freeSilverCount = remote.user.todayLuckyDrawFreeCount or 0

	if q.refreshTime(remote.user.c_systemRefreshTime) > lastTime then
		freeSilverCount = silverCount
	else
		freeSilverCount = silverCount - freeSilverCount
	end

	self._ccbOwner.node_half:setVisible(false)
	self._ccbOwner.btn_shuoming:setVisible(false)
	self._ccbOwner.sale:setVisible(false)
	if freeSilverCount == silverCount or (freeSilverCount > 0 and (q.serverTime() - lastTime) >= CDTime) then
		isFree = true
		oneText = "本次免费："..freeSilverCount.."/"..silverCount
		self._ccbOwner.sale:setVisible(true)
		self._ccbOwner.discountStr:setString("免费")
	else
		isFree = false
		oneText = self._cardNum.."/1"
	end
	tenText = self._cardNum.."/10"

	return isFree, oneText, tenText
end

function QUIDialogTavernShowHero:checkGoldMoneyState()
	print("[QUIDialogTavernShowHero:checkGoldMoneyState()]")
	local isFree = false
	local oneText = ""
	local tenText = ""

	local lastTime = (remote.user.luckyDrawAdvanceRefreshedAt or 0)/1000
	local halfTime = (remote.user.luckyAdvanceHalfPriceRefreshAt or 0)/1000

    local lastRefreshTime = q.date("*t", q.serverTime())
   	if lastRefreshTime.hour < 5 then
   		lastTime = lastTime + DAY
   		halfTime = halfTime + DAY
   	end
	lastRefreshTime.hour = 5
    lastRefreshTime.min = 0
    lastRefreshTime.sec = 0
    lastRefreshTime = q.OSTime(lastRefreshTime)

    self._isHalf = false

    -- 高級召喚這裡作廢不用了
    -- self._isSetHalf = app:getUserOperateRecord():getTavernHalfBuySetting() or false
	-- self._ccbOwner.sp_no_half_select:setVisible(not self._isSetHalf)
	-- self._ccbOwner.sp_half_select:setVisible(self._isSetHalf)
	-- self._ccbOwner.node_half:setVisible(halfTime <= lastRefreshTime)
	self._isSetHalf = true
	self._ccbOwner.node_half:setVisible(false)

	self._ccbOwner.btn_shuoming:setVisible(true)
    self._ccbOwner.sale:setVisible(false)

    print("halfTime = ", halfTime, "lastRefreshTime = ", lastRefreshTime, "lastTime = ", lastTime)
    if halfTime <= lastRefreshTime and self._isSetHalf then
    	-- 这里把判断半价优惠的条件单独出来，它本来就和免费次数无关
		self._isHalf = true
    end

	if lastTime <= lastRefreshTime then
		isFree = true
		oneText = "本次免费：1/1"
		-- self._ccbOwner.sale:setVisible(true)
		-- self._ccbOwner.discountStr:setString("免费")
	-- elseif halfTime <= lastRefreshTime and self._isSetHalf then
		-- isFree = false
		-- oneText = "本次半价：1/1"
		-- oneText = self._cardNum.."/1"
		-- self._ccbOwner.sale:setVisible(true)
		-- self._ccbOwner.discountStr:setString("半价")
	else
		isFree = false
		oneText = self._cardNum.."/1"
	end
	tenText = self._cardNum.."/10"

    self:updateTopBarEffect()

	return isFree, oneText, tenText
end

function QUIDialogTavernShowHero:updateTopBarEffect()
	local bar = self._page.topBar:getBarForType(TOP_BAR_TYPE.TAVERN_ADVANCE_MONEY)
	local bubbleNode = bar:getBubbleNode()
	bubbleNode:removeAllChildren()

	if self._isHalf then
		if not self._bubbleSprite then
			local path = QResPath("shoucibanjia")
			self._bubbleSprite = CCSprite:create(path)
			if self._bubbleSprite then
				self._bubbleSprite:setPosition(ccp(30, -30))
				bubbleNode:addChild(self._bubbleSprite)
				bubbleNode:setVisible(true)
			else
				bubbleNode:setVisible(false)
			end

			local actions = CCArray:create()
			actions:addObject(CCDelayTime:create(3))
			actions:addObject(CCFadeOut:create(0.15))
    		actions:addObject(CCCallFunc:create(function()
				self._bubbleSprite:setVisible(false)
            end))
    		actions:addObject(CCRemoveSelf:create(true))
        	self._bubbleSprite:runAction(CCSequence:create(actions))
		end
	else
		bubbleNode:setVisible(false)
	end
end

function QUIDialogTavernShowHero:fristBuyHandler()
	if self._isFrist == true then
		if self._tavernType == TAVERN_SHOW_HERO_CARD.SILVER_TAVERN_TYPE then
			remote.flag:set(remote.flag.FLAG_FRIST_SILVER_CHEST, 1)
		else
			remote.flag:set(remote.flag.FLAG_FRIST_GOLD_CHEST, 1)
		end
	end
end

function QUIDialogTavernShowHero:initScoreAward()
	self._scoreAward = QUIWidgetTavernScoreAward.new()
	self._ccbOwner.node_score:addChild(self._scoreAward)
	self._scoreAward:setPosition(ccp(100, -60))
end

function QUIDialogTavernShowHero:updateTavernScore()
	self._scoreAward:updateInfo()
end

function QUIDialogTavernShowHero:_onTriggerBuyHalf(event)
	app.sound:playSound("common_small")
	app:getUserOperateRecord():setTavernHalfBuySetting(not self._isSetHalf)

	local isFree, oneText, tenText = self:checkGoldMoneyState()
	self._ccbOwner.tf_money:setString(oneText)
	self._ccbOwner.tf_money_ten:setString(tenText)

	if isFree or self._isHalf then
		self._ccbOwner.node_free_tf:setPositionX(-50)
	else
		self._ccbOwner.node_free_tf:setPositionX(0)
	end
end

function QUIDialogTavernShowHero:_onTriggerBuyOne(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy_one) == false then return end
	app.sound:playSound("common_small")
	if self._tavernType == TAVERN_SHOW_HERO_CARD.SILVER_TAVERN_TYPE then
		self:silverBuyHandler(1, handler(self, self._onTriggerBuyOne), event.isAgain)
	else
		local goldCost = QStaticDatabase:sharedDatabase():getConfigurationValue("ADVANCE_LUCKY_DRAW_TOKEN_COST") -- 黄金宝箱购买所需代币数量
		self:goldBuyHandler(1, goldCost, handler(self, self._onTriggerBuyOne), event.isAgain)
	end
end

function QUIDialogTavernShowHero:_onTriggerBuyTen(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy_ten) == false then return end
	app.sound:playSound("common_small")
	if self._tavernType == TAVERN_SHOW_HERO_CARD.SILVER_TAVERN_TYPE then
		self:silverBuyHandler(10, handler(self, self._onTriggerBuyTen), event.isAgain)
	else
		local goldCost = QStaticDatabase:sharedDatabase():getConfigurationValue("ADVANCE_LUCKY_DRAW_10_TIMES_TOKEN_COST") -- 黄金宝箱购买所需代币数量
		self:goldBuyHandler(10, goldCost, handler(self, self._onTriggerBuyTen), event.isAgain)
	end
end

function QUIDialogTavernShowHero:silverBuyHandler(count, callback, isAgain)
	self._oldHeros = clone(remote.herosUtil:getHaveHero())
	if self._cardNum >= count or (count == 1 and self._isFree == true) then 
		local oldMoney = remote.user.money
		app.tip:delayAndCacheFloatForce(1)
		app:getClient():luckyDraw(count, function(data)
				if self:safeCheck() then
					remote.user:addPropNumForKey("addupLuckydrawCount",count)
					remote.user:addPropNumForKey("todayLuckyDrawAnyCount",count)  
					remote.activity:updateLocalDataByType(507,1)

            		app.taskEvent:updateTaskEventProgress(app.taskEvent.SILVER_CHEST_BUY_EVENT, count, false, false)

					if count == 1 and  oldMoney ~= remote.user.money then
						self:fristBuyHandler()
					end
					self:setClientInfo()
					local itemType = ITEM_TYPE.SUMMONCARD_NORMAL

					remote.items:getRewardItemsTips(data.prizes, self._oldHeros, self._cardNum, callback, itemType, nil, TAVERN_SHOW_HERO_CARD.SILVER_TAVERN_TYPE, nil, isAgain)
				end
			end)
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._silverCardId, count, nil, false)
	end
end

function QUIDialogTavernShowHero:gotoBuy(isHalf)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernExchange", 
		options={isHalf = isHalf, callback = function()
			local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
			if dialog.class.__cname == "QUIDialogTavernAchieve" and dialog.updatePrice then
				if dialog:safeCheck() then
					local cardNum = remote.items:getItemsNumByID(24)
					dialog:updatePrice(cardNum)
				end
			elseif dialog.class.__cname == "QUIDialogTavernShowHero" and dialog.setClientInfo and dialog.updateTopBarEffect then
				if dialog:safeCheck() then
					dialog:setClientInfo()
					dialog:updateTopBarEffect()
				end
			end
		end}}, {isPopCurrentDialog = false})
end

function QUIDialogTavernShowHero:goldBuyHandler(count, cost, callback, isAgain)
	self._oldHeros = clone(remote.herosUtil:getHaveHero())

	local cardNum = remote.items:getItemsNumByID(24)
	if cardNum >= count or (count == 1 and self._isFree) then
		self:buyGoldItem(count, callback, isAgain)
	else
		self:gotoBuy(self._isHalf)
	end
end

function QUIDialogTavernShowHero:buyGoldItem(count, callback, isAgain, isHalf)
	local oldMoney = remote.user.token
	app.tip:delayAndCacheFloatForce(1)
	app:getClient():luckyDrawAdvance(count, isHalf,function(data)
		if self.class ~= nil then
			remote.user:addPropNumForKey("addupLuckydrawAdvanceCount",count)
			remote.user:addPropNumForKey("todayLuckyDrawAnyCount",count)  
			remote.user:addPropNumForKey("todayAdvancedDrawCount",count)  
			remote.activity:updateLocalDataByType(508,count)

            app.taskEvent:updateTaskEventProgress(app.taskEvent.GOLD_CHEST_BUY_EVENT, count, false, false)

			if count == 10 then
				remote.activity:updateLocalDataByType(550,1)
			end
			if count == 1 and oldMoney ~= remote.user.token and self.fristBuyHandler ~= nil then
				self:fristBuyHandler()
			end  
			self:setClientInfo()
			local realCost = self._cardNum
			local itemType = ITEM_TYPE.SUMMONCARD_ADVANCED
			local confirmBack = function()
				self:setClientInfo()
				self:updateTavernScore()
				self:updateTopBarEffect()
			end
			remote.items:getRewardItemsTips(data.prizes, self._oldHeros, realCost, callback, itemType, self._freeGoldCount, TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE, confirmBack, isAgain)
		end
	end)
end

function QUIDialogTavernShowHero:_onTriggerPreview()
    if e ~= nil then app.sound:playSound("common_small") end

    local noSuperAndAPlusHero = true
    if self._tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
		noSuperAndAPlusHero = false
    end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPreview", 
		options = {noSuperAndAPlusHero = noSuperAndAPlusHero}},{isPopCurrentDialog = false})
end

function QUIDialogTavernShowHero:_onTriggerConditionInfo()
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernHelp"})
end

function QUIDialogTavernShowHero:_cellClickHandler(event)
	if event.actorId then
		app.sound:playSound("common_small")
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroImageCard", 
            options = {actorId = event.actorId}}) 
	end
end

function QUIDialogTavernShowHero:onTriggerBackHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 返回主界面
function QUIDialogTavernShowHero:onTriggerHomeHandler(tag, menuItem)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogTavernShowHero