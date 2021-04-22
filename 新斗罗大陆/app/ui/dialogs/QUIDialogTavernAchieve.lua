--
-- Author: xurui
-- Date: 2015-04-07 09:42:51
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTavernAchieve = class("QUIDialogTavernAchieve", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogTavernAchieve:ctor(options)
	local ccbFile = "ccb/Dialog_AchieveHeroNew2.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerAgain", callback = handler(self, self._onTriggerAgain)}
	}
	QUIDialogTavernAchieve.super.ctor(self, ccbFile, callBacks, options)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setBackBtnVisible(false)
    page:setHomeBtnVisible(false)
    page:setScalingVisible(false)

    self._touchLastTime = nil
    self.hideAction = false
    self._luckyDrawCount = 30
    self._fcaAnimationRes = "fca/tx_whd_dijibg_effect"
    self._isGold = false
    if options.tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
		self._ccbOwner.node_gold_bg:setVisible(true)
		self._ccbOwner.node_sliver_bg:setVisible(false)
		self._ccbOwner.effect_gold:setVisible(true)
		self._ccbOwner.effect_sliver:setVisible(false)
		self._ccbOwner.sp_gold:setVisible(true)
		self._ccbOwner.sp_silver:setVisible(false)
		self._ccbOwner.sp_turntable:setVisible(false)
		self._fcaAnimationRes = "fca/tx_whd_gaojibg_effect"
		self._isGold = true
	elseif options.tavernType == TAVERN_SHOW_HERO_CARD.ORIENT_TAVERN_TYPE then
		self._ccbOwner.node_gold_bg:setVisible(false)
		self._ccbOwner.node_sliver_bg:setVisible(true)
		self._ccbOwner.effect_gold:setVisible(false)
		self._ccbOwner.effect_sliver:setVisible(true)
		self._ccbOwner.sp_gold:setVisible(false)
		self._ccbOwner.sp_silver:setVisible(false)
		self._ccbOwner.sp_turntable:setVisible(true)
	else
		self._ccbOwner.node_gold_bg:setVisible(false)
		self._ccbOwner.node_sliver_bg:setVisible(true)
		self._ccbOwner.effect_gold:setVisible(false)
		self._ccbOwner.effect_sliver:setVisible(true)
		self._ccbOwner.sp_gold:setVisible(false)
		self._ccbOwner.sp_silver:setVisible(true)
		self._ccbOwner.sp_turntable:setVisible(false)
	end

	self._ccbOwner.node_buy_more:setVisible(false)
	
	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))

	if options.hasShowAni then
		self._animationManager:stopAnimation()
		self._animationManager:runAnimationsForSequenceNamed("2")
    	self._ccbOwner.node_buy_more:setVisible(true)
	else

		self._animationManager:runAnimationsForSequenceNamed("1")	
	end
	
	self._isAgain = false
	self._isShow = true
	self._canAgain = true
end

function QUIDialogTavernAchieve:viewAnimationEndHandler(aniName)
	print("aniName=",aniName)
	if aniName == "1" then
	    local fcaAnimation = QUIWidgetFcaAnimation.new(self._fcaAnimationRes, "res")
		fcaAnimation:playAnimation("animation", false)
		fcaAnimation:setPositionY(-70)
		self._ccbOwner.node_boom_effect:addChild(fcaAnimation)
		fcaAnimation:setEndCallback(function( )
			fcaAnimation:removeFromParent()
		end)

		self._schedulerPlayAnimation = scheduler.performWithDelayGlobal(function()
			self._animationManager:stopAnimation()
			self._animationManager:runAnimationsForSequenceNamed("3")
	    	self._ccbOwner.node_buy_more:setVisible(false)

		    self._scheduler = scheduler.performWithDelayGlobal(function()
		            app.sound:playSound("common_bright")
		            scheduler.performWithDelayGlobal(function()
			            app.sound:playSound("common_energy")
			        end, 1.8)
		        end, 0.05)			            
	    end, 1.0)
	else
		self._ccbOwner.node_buy_more:setVisible(true)		
	end
end

function QUIDialogTavernAchieve:viewDidAppear()
    QUIDialogTavernAchieve.super.viewDidAppear(self)

    self._tavernProxy = cc.EventProxy.new(remote.items)
    self._tavernProxy:addEventListener(remote.items.EVENT_ITEMS_TAVERN_UPDATE, handler(self, self._tavernUpdate))

    self._itemsProxy = cc.EventProxy.new(remote.items)
	self._itemsProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self._onItemNumUpdate))

   	self:initView()
end

function QUIDialogTavernAchieve:viewWillDisappear()
  	QUIDialogTavernAchieve.super.viewWillDisappear(self)
  	self._tavernProxy:removeAllEventListeners()

  	if self._itemsProxy ~= nil then
		self._itemsProxy:removeAllEventListeners()
		self._itemsProxy = nil
	end

  	if self._scheduler then
  		scheduler.unscheduleGlobal(self._scheduler)
  		self._scheduler = nil
  	end

  	if self._schedulerPlayAnimation then
  		scheduler.unscheduleGlobal(self._schedulerPlayAnimation)
  		self._schedulerPlayAnimation = nil
  	end
	app.tip:delayAndCacheFloatForce(2)
end

function QUIDialogTavernAchieve:_onItemNumUpdate()
	if not self._isGold then return end
	local goldCardId = 24
	local cardNum = remote.items:getItemsNumByID(goldCardId)
	self:updatePrice(cardNum)
end

function QUIDialogTavernAchieve:updatePrice( cost )
	self:getOptions().cost = cost
	self.money = cost
	if self.prizeNum == 1 then
		self._ccbOwner.tf_money:setString(self.money.."/1")
	else
		self._ccbOwner.tf_money:setString(self.money.."/10")
	end	
end

function QUIDialogTavernAchieve:initView()
	
	local options = self:getOptions()
	self.prize = clone(options.items)
	self.againBack = options.againBack
	self.money = options.cost
	self.oldHeros = options.oldHeros
	self.tavernType = options.tavernType
	self.tokenType = options.tokenType
	self.prizeNum = #self.prize
	self.confirmBack = options.confirmBack
	self.hasShowAni = options.hasShowAni

    self._ccbOwner.sale:setVisible(false)
	if self.prizeNum == 1 then
		self._ccbOwner.buy_label:setString("再买一次")
		self._ccbOwner.tf_money:setString(self.money.."/1")
		self:showDiscount()
	else
		self._ccbOwner.buy_label:setString("再买十次")
		self._ccbOwner.tf_money:setString(self.money.."/10")
	end	

	self.index = 1 
	self.heros = {}

	if self.hideAction then
		self:setHeroHeadBoxEffects()
	elseif self.hasShowAni then
		self:setHeroHeadBox()
	else
		self:getScheduler().performWithDelayGlobal(function()
    		self:setHeroHeadBoxEffects()
    		options.hasShowAni = true
    	end, 4.2)
	end

  	self:setTitleByType()
end

function QUIDialogTavernAchieve:showDiscount()
	local halfTime = (remote.user.luckyAdvanceHalfPriceRefreshAt or 0)/1000
    local lastRefreshTime = q.date("*t", q.serverTime())
   	if lastRefreshTime.hour < 5 then
   		halfTime = halfTime + DAY
   	end
	lastRefreshTime.hour = 5
    lastRefreshTime.min = 0
    lastRefreshTime.sec = 0
    lastRefreshTime = q.OSTime(lastRefreshTime)

    if self:getOptions().tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
     	local isSetHalf = app:getUserOperateRecord():getTavernHalfBuySetting() or false
		if halfTime <= lastRefreshTime and isSetHalf then
			self._ccbOwner.sale:setVisible(true)
			self._ccbOwner.discountStr:setString("半价")
		end
	end
end

function QUIDialogTavernAchieve:_tavernUpdate(event)
	if not event.options then
		return
	end
    self._ccbOwner.node_buy_more:setVisible(false)

	for i = 1, self.prizeNum do
		if self["itemNode"..i] then
			self["itemNode"..i]:removeFromParent()
			self["itemNode"..i] = nil
		end
	end
	self._ccbOwner.node_count:removeAllChildren()
	self._itemEffects = nil

	local options = event.options
	self:getOptions().items = options.items
	self:getOptions().cost = options.cost
	self.prize = clone(options.items)
	self.againBack = options.againBack
	self.money = options.cost
	self.oldHeros = options.oldHeros
	self.tavernType = options.tavernType
	self.tokenType = options.tokenType
	self.prizeNum = #self.prize
	self.confirmBack = options.confirmBack

	self._isAgain = options.isAgain

	print("抽卡---------view",options.isAgain)

	self._isAnimation = true --是否在动画中

    self._ccbOwner.sale:setVisible(false)

	if self.prizeNum == 1 then
		self._ccbOwner.buy_label:setString("再买一次")
		self._ccbOwner.tf_money:setString(self.money.."/1")
		self:showDiscount()
	else
		self._ccbOwner.buy_label:setString("再买十次")
		self._ccbOwner.tf_money:setString(self.money.."/10")
	end	

	self.index = 1 
	self.heros = {}
	self:setHeroHeadBoxEffects()
  	self:setTitleByType()
end

function QUIDialogTavernAchieve:setHeroHeadBox()
	for index, info in pairs(self.prize) do
		if info.type == "HERO" then
			if self:checkIsHave(info.id) then		
				local config = db:getGradeByHeroActorLevel(info.id, 0)
		        info.type = ITEM_TYPE.ITEM
		        info.id = config.soul_gem
		        if self.tavernType == TAVERN_SHOW_HERO_CARD.ORIENT_TAVERN_TYPE then
		        	info.count = config.soul_gem_count
		        else
		        	info.count = config.soul_second_hero
		        end
		    end
		end

		if self["itemNode"..index] then
			self["itemNode"..index]:removeFromParent()
		end

		self["itemNode"..index] = CCNode:create()
		self:getView():addChild(self["itemNode"..index])

		self["heroHeadBox"..index] = QUIWidgetItemsBox.new()
		local itemType = remote.items:getItemType(info.type)
		self["heroHeadBox"..index]:setGoodsInfo(info.id, itemType, info.count)
		self["heroHeadBox"..index]:setNeedshadow( false )
		self["heroHeadBox"..index]:setPromptIsOpen(true)
		self["heroHeadBox"..index]:showItemName()

		local positionY = -50
		if self.tavernType == TAVERN_SHOW_HERO_CARD.ORIENT_TAVERN_TYPE then
			positionY = 0
		elseif self.tavernType == TAVERN_SHOW_HERO_CARD.SILVER_TAVERN_TYPE or self.tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
			positionY = -200
		end
		self["heroHeadBox"..index]:setPosition(ccp(0, positionY))

		self["itemNode"..index]:addChild(self["heroHeadBox"..index])

		local maxNum = math.floor(self.prizeNum/2)
		local startPositionX = maxNum == 3 and -135 or -290
		local startPositionY = 50
		local lineGap = 175
		local rowGap = 145

		local itemNum = index > maxNum and index-maxNum or index
		local lineNum = index > maxNum and 2 or 1
		local posX = startPositionX + ((itemNum-1) * rowGap)
		local posY = startPositionY - ((lineNum-1) * lineGap)
		if self.prizeNum == 1 then
			posX = 0
			posY = 0
		end
		posY = posY + 60

		self["heroHeadBox"..index]:setPosition(posX, posY)
		
		local itemEffects2 = QUIWidgetAnimationPlayer.new()
		self["heroHeadBox"..index]:addChild(itemEffects2)
		itemEffects2:playAnimation("effects/chouka_3.ccbi", nil, nil, false)
	end
	self.index = self.prizeNum+1
end

function QUIDialogTavernAchieve:setHeroHeadBoxEffects()
	if self.index > self.prizeNum then return end

	self.isHero = false
	self.info = clone(self.prize[self.index])

	if self.info.type == "HERO" then
		self.isHero = true
    	self._showHeroId = self.info.id
		self:showHeroCard()
	else
		self:_setItemBox()
	end
end 

function QUIDialogTavernAchieve:checkIsHave(id)
	--检查购买前是否拥有该魂师
	for k, value in pairs(self.oldHeros) do
		if id == value then
			return true
		end
	end
	return false
end

function QUIDialogTavernAchieve:showHeroCard()
	self.isHave = self:checkIsHave(self.info.id)

	--检查本次奖励的魂师中是否有该魂师
	if self.isHave == false and next(self.heros) then
		for k, value in pairs(self.heros) do 
			if value.id == self.info.id then
				self.isHave = true
			end
		end
	end
	table.insert(self.heros, self.info)
	
	local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self.info.id)
	if heroInfo ~= nil and heroInfo.grade ~= nil then
		self.info.grade = heroInfo.grade
	end
	local count = 0
	local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self.info.id , self.info.grade or 0)
    if self.tavernType == TAVERN_SHOW_HERO_CARD.ORIENT_TAVERN_TYPE then
    	count = config.soul_gem_count
    else
    	count = config.soul_second_hero
    end

 	if self.isHave == false then
        self:_setItemBox()
	else
		local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self.info.id , self.info.grade or 0)
        self.info.type = ITEM_TYPE.ITEM
        self.info.id = config.soul_gem
        if self.tavernType == TAVERN_SHOW_HERO_CARD.ORIENT_TAVERN_TYPE then
        	self.info.count = config.soul_gem_count
        else
        	self.info.count = config.soul_second_hero
        end
		self:_setItemBox(true)
	end
end

function QUIDialogTavernAchieve:checkPrizeHero()
    if self.isHave == false then
        self:_setItemBox()
	else
		local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self.info.id , self.info.grade or 0)
        self.info.type = ITEM_TYPE.ITEM
        self.info.id = config.soul_gem
        if self.tavernType == TAVERN_SHOW_HERO_CARD.ORIENT_TAVERN_TYPE then
        	self.info.count = config.soul_gem_count
        else
        	self.info.count = config.soul_second_hero
        end
		self:_setItemBox(true)
	end
end

function QUIDialogTavernAchieve:_setItemBox(isHave) 
	local info = self.info
	if self["itemNode"..self.index] then
		self["itemNode"..self.index]:removeFromParent()
	end

	self["itemNode"..self.index] = CCNode:create()
	self._ccbOwner.node_box:addChild(self["itemNode"..self.index])

	self["heroHeadBox"..self.index] = QUIWidgetItemsBox.new()
	local itemType = remote.items:getItemType(info.type)
	self["heroHeadBox"..self.index]:setGoodsInfo(info.id, itemType, info.count)
	self["heroHeadBox"..self.index]:setNeedshadow( false )

	local positionY = -50
	if self.tavernType == TAVERN_SHOW_HERO_CARD.ORIENT_TAVERN_TYPE then
		positionY = 0
	elseif self.tavernType == TAVERN_SHOW_HERO_CARD.SILVER_TAVERN_TYPE or self.tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
		positionY = -200
	end
	self["heroHeadBox"..self.index]:setPosition(ccp(0, positionY))

	self["itemNode"..self.index]:addChild(self["heroHeadBox"..self.index])

	local maxNum = math.floor(self.prizeNum/2)
	local startPositionX = maxNum == 3 and -135 or -290
	local startPositionY = 50
	local lineGap = 175
	local rowGap = 145

	local itemNum = self.index > maxNum and self.index-maxNum or self.index
	local lineNum = self.index > maxNum and 2 or 1
	local posX = startPositionX + ((itemNum-1) * rowGap)
	local posY = startPositionY - ((lineNum-1) * lineGap)
	if self.prizeNum == 1 then
		posX = 0
		posY = 0
	end
	posY = posY + 60

	self:_nodeRunAction(self["heroHeadBox"..self.index], posX, posY)
end

-- 移动到指定位置
function QUIDialogTavernAchieve:_nodeRunAction(node, posX, posY, isHave)
    app.sound:playSound("common_award")

	self._itemPosX = posX
	self._itemPosY = posY
	self._currentNode = node
    self._isMove = true

	node:setBoxScale(0)
    node:setPosition(ccp(posX,posY))

    if self.isHero and self._showHeroId then
    	if self._itemEffects and self._itemEffects.disappear then 
			self._itemEffects:disappear()
			self._itemEffects = nil
		end

	    local callback = function()
	    	if self:safeCheck() then
	    		if self._itemEffects then
	    			self._itemEffects:resumeAnimation()
	    		end
	    		local arrayIn = CCArray:create()
	    		if not self.hideAction then
					arrayIn:addObject(CCDelayTime:create(0.2))
				end
			    arrayIn:addObject(CCCallFunc:create(function() 
						node:setBoxScale(1)
						node:showItemName()
						self:setHeroEffect()
			    	end))

	    		node:runAction(CCSequence:create(arrayIn))
				self.index = self.index + 1 
        	end
		end

    	local aniFunc = function()
	    	self._itemEffects = QUIWidgetAnimationPlayer.new()
			node:addChild(self._itemEffects)
			self._itemEffects:setScale(1.2)
			self._itemEffects:playAnimation("effects/whd_shilian_1.ccbi", nil, function()
					self._itemEffects = nil
				end, false)

			local itemEffects2 = QUIWidgetAnimationPlayer.new()
			node:addChild(itemEffects2)
			itemEffects2:playAnimation("effects/chouka_3.ccbi", nil, nil, false)
		end

    	local arrayIn = CCArray:create()
    	if not self.hideAction then
			arrayIn:addObject(CCDelayTime:create(0.2))
		end
	    arrayIn:addObject(CCCallFunc:create(function() 
	    		if self._itemEffects then
	    			self._itemEffects:pauseAnimation()
	    		end
	    		if self._showHeroId then
		    		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernShowHeroCard", 
		        		options={actorId = self._showHeroId, tavernType = self.tavernType, callBack = callback}})
		    	else
		    		callback()
		    	end
	    	end))

	    local actionArrayIn = CCArray:create()
	    if not self.hideAction then
	    	actionArrayIn:addObject(CCCallFunc:create(aniFunc))
	    end
	    actionArrayIn:addObject(CCSequence:create(arrayIn))
    	node:runAction(CCSpawn:create(actionArrayIn))
    else
	    local arrayIn = CCArray:create()
	    if not self.hideAction then
			arrayIn:addObject(CCDelayTime:create(0.35))
		end
	    arrayIn:addObject(CCCallFunc:create(function() 
				node:setBoxScale(1)
	    	end))

	    local actionArrayIn = CCArray:create()
	    actionArrayIn:addObject(CCSequence:create(arrayIn))
	    if not self.hideAction then
		    actionArrayIn:addObject(CCCallFunc:create(function() 
		    		local itemEffects = QUIWidgetAnimationPlayer.new()
					node:addChild(itemEffects)
					itemEffects:setScale(1.2)
					itemEffects:playAnimation("effects/whd_shilian_1.ccbi", nil, nil, false)

					local itemEffects2 = QUIWidgetAnimationPlayer.new()
					node:addChild(itemEffects2)
					itemEffects2:playAnimation("effects/chouka_3.ccbi", nil, nil, false)
		    	end))
		end

	    local array = CCArray:create()
	    array:addObject(CCSpawn:create(actionArrayIn))
	    array:addObject(CCCallFunc:create(function() 
			    self.index = self.index + 1 
			    self:checkNextItem()
				node:showItemName()
			end))

    	node:runAction(CCSequence:create(array))
    end
end

function QUIDialogTavernAchieve:setHeroEffect()
	local time = 0.2
	self._heroAvatar = CCSprite:create()
	self._ccbOwner.node_box:addChild(self._heroAvatar)
	self._heroAvatar:setPositionX(-292.8)
	self._heroAvatar:setScaleX(-1)

	local action1 = CCArray:create()
	action1:addObject(CCScaleTo:create(time, -1.5, 1.5))
	action1:addObject(CCMoveTo:create(time, ccp(0, 0)))

	local action2 = CCArray:create()
	action2:addObject(CCScaleTo:create(time, 0.0))
	action2:addObject(CCMoveTo:create(time, ccp(self._itemPosX, self._itemPosY)))
	action2:addObject(CCFadeOut:create(time))

	local ccArray = CCArray:create()
	ccArray:addObject(CCSpawn:create(action1))
	ccArray:addObject(CCSpawn:create(action2))
	ccArray:addObject(CCCallFunc:create(function()
			self._heroAvatar:removeFromParent()
			self._heroAvatar = nil

			local itemEffects1 = QUIWidgetAnimationPlayer.new()
			self._currentNode:addChild(itemEffects1)
			itemEffects1:setScale(0.8)
			itemEffects1:playAnimation("effects/chouka_2.ccbi", function()
				end)
			local itemEffects2 = QUIWidgetAnimationPlayer.new()
			self._currentNode:addChild(itemEffects2)
			itemEffects2:playAnimation("effects/Item_box_shine.ccbi", function()
				end, function ()
					self:checkNextItem()
				end, true)
		end))

	self._heroAvatar:runAction(CCSequence:create(ccArray))
end

function QUIDialogTavernAchieve:checkNextItem()
    self._showHeroId = nil
    if self.index > self.prizeNum then
		for i = 1, self.prizeNum do
			self["heroHeadBox"..i]:setPromptIsOpen(true)
		end
		self._ccbOwner.node_buy_more:setVisible(true)
		self._ccbOwner.title_node:setVisible(true)
		self._isAnimation = false

		self:showTavernSroreAni()
    else
    	self:setHeroHeadBoxEffects()
	end
end

function QUIDialogTavernAchieve:setTitleByType()
	self._ccbOwner.node_next_tips:setVisible(true)

	local content1, content2, content3, content4 = "", "", "", ""
	if self.tavernType == TAVERN_SHOW_HERO_CARD.SILVER_TAVERN_TYPE then
		if app.tutorial:isTutorialFinished() == false and app.tutorial:getStage().forced == 1 then
			content2 = 1
        else
        	content2 = 10 - (remote.user.totalLuckyDrawNormalCount or 0)%10
        end
        content1, content3, content4 = "成功购买中级经验药剂，并赠送：", " 次后必送", "##pA##f魂师碎片"
        if self.prizeNum > 1 then
        	content1, content2, content3, content4 = "成功购买10瓶中级经验药剂，并赠送：", " ", "", ""
		end
	elseif self.tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
		if app.tutorial:isTutorialFinished() == false and app.tutorial:getStage().forced == 1 then
			content2 = 1
        else
        	if self.prizeNum == 1 then
        		content2 = 10 - (remote.user.totalLuckyDrawAdvanceCount or 0)%10
        	else
        		content2 = math.ceil((self._luckyDrawCount - (remote.user.totalLuckyDrawAdvanceCount or 0)%self._luckyDrawCount) / 10)
        	end
    	end
        if math.ceil((self._luckyDrawCount - (remote.user.totalLuckyDrawAdvanceCount or 0)%self._luckyDrawCount)/10) == 1 or self.prizeNum ~= 1 then
			content4 = "##pA+##f或##yS##f魂师"
        else
			content4 = "##pA、A+##f或##yS##f魂师"
		end
		if self.prizeNum == 1 then
			content1, content3 = "成功购买高级经验药剂，并赠送：", "次后必送"
		else
			content1, content3 = "成功购买10瓶高级经验药剂，并赠送：", "次十连后必送"
		end
	end		

	local str = "##q"..content2.."##f"..content3..content4
	local richText = QRichText.new(str, 320, {autoCenter = true, stringType = 1})
    richText:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_count:addChild(richText)
end

function QUIDialogTavernAchieve:showTavernSroreAni()
	local count = remote.user.totalLuckyDrawAdvanceCount or 0
	if self.tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE and count > 0 then
		local score = 10*self.prizeNum
		local scoreEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_effect:removeAllChildren()
		self._ccbOwner.node_effect:addChild(scoreEffect)
		scoreEffect:playAnimation("effects/Peiyang_tips.ccbi", function(ccbOwner)
				ccbOwner.tf_name:setString("招募积分+"..score)
			end)
	end
end

function QUIDialogTavernAchieve:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_back) == false then return end
	if self.index <= self.prizeNum then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	
  	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
    page:setBackBtnVisible(true)
    page:setScalingVisible(true)
    if dialog.class.__cname == "QUIDialogMall" then
    	page.topBar:showWithEnchantOrient()
    else
    	 if self:getOptions().tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
	    	page.topBar:showWithTavernAdvance()
		else
			page.topBar:showWithTavernNormal()
		end
	end
    page:checkGuiad()

    if self.confirmBack then
    	self.confirmBack()
    end
end

function QUIDialogTavernAchieve:_onTriggerAgain(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy) == false then return end
	if self.index <= self.prizeNum then return end
    app.sound:playSound("common_small")
    
    self._touchLastTime = nil
    self.hideAction = false

	if self.againBack then
		self.againBack({isAgain = true})
	end
end

function QUIDialogTavernAchieve:_backClickHandler()
	if self.hideAction then
		return
	end
	if self._touchLastTime == nil then
		self._touchTimes = 1
	elseif q.serverTime() - self._touchLastTime < 1 then
		self._touchTimes = self._touchTimes + 1
	else
		self._touchTimes = 1
	end
	if self._touchTimes > 1 then
		self.hideAction = true 
	end
	print("self._touchTimes----",self._touchTimes)
	self._touchLastTime = q.serverTime()   
end

return QUIDialogTavernAchieve