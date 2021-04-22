--
-- Kumo.Wang
-- 鼠年春节活动——抽福卡动画特效界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRatFestivalTavernAchieve = class("QUIDialogRatFestivalTavernAchieve", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogRatFestivalTavernAchieve:ctor(options)
	local ccbFile = "ccb/Dialog_RatFestival_Tavern_Achieve.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerAgain", callback = handler(self, self._onTriggerAgain)}
	}
	QUIDialogRatFestivalTavernAchieve.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
    if page.setBackBtnVisible then page:setBackBtnVisible(false) end
    if page.setHomeBtnVisible then page:setHomeBtnVisible(false) end

    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)
    
    self._ratFestivalModel = remote.activityRounds:getRatFestival()

	self._ccbOwner.sp_gold:setVisible(true)
	self._ccbOwner.node_buy_more:setVisible(false)
	
	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))

	if options.isSkipAnimation then
		self._animationManager:stopAnimation()
		self._animationManager:runAnimationsForSequenceNamed("2")
    	self._ccbOwner.node_buy_more:setVisible(true)
	else
		self._animationManager:runAnimationsForSequenceNamed("1")	
	end
end

function QUIDialogRatFestivalTavernAchieve:viewAnimationEndHandler(aniName)
	if aniName == "1" then
	    local fcaAnimation = QUIWidgetFcaAnimation.new("fca/tx_whd_gaojibg_effect", "res")
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

function QUIDialogRatFestivalTavernAchieve:viewDidAppear()
    QUIDialogRatFestivalTavernAchieve.super.viewDidAppear(self)

    self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.EVENT_RAT_FESTIVAL_TAVERN_UPDATE, self:safeHandler(handler(self, self._tavernUpdate)))

   	self:_initView()
end

function QUIDialogRatFestivalTavernAchieve:viewWillDisappear()
  	QUIDialogRatFestivalTavernAchieve.super.viewWillDisappear(self)
  	self._activityRoundsEventProxy:removeAllEventListeners()

  	if self._scheduler then
  		scheduler.unscheduleGlobal(self._scheduler)
  		self._scheduler = nil
  	end

  	if self._schedulerPlayAnimation then
  		scheduler.unscheduleGlobal(self._schedulerPlayAnimation)
  		self._schedulerPlayAnimation = nil
  	end
end

function QUIDialogRatFestivalTavernAchieve:_initView()
	local options = self:getOptions()
	self._prizes = clone(options.items)
	self._prizesNum = #self._prizes
	self._lastLuckyCardIds = options.lastLuckyCardIds
	self._againCallback = options.againCallback
	self._confirmCallback = options.confirmCallback
	self:_checkWholeLuckyCard()

	local moneyConfig = remote.items:getWalletByType(ITEM_TYPE.RAT_FESTIVAL_MONEY)
	QSetDisplayFrameByPath(self._ccbOwner.sp_gold, moneyConfig.alphaIcon)
	local moneyCount = remote.user[ITEM_TYPE.RAT_FESTIVAL_MONEY] or 0
	if self._prizesNum == 1 then
		self._ccbOwner.tf_btn_buy:setString("再抽一次")
		self._ccbOwner.tf_money:setString(moneyCount.."/1")
	else
		self._ccbOwner.tf_btn_buy:setString("再抽五次")
		self._ccbOwner.tf_money:setString(moneyCount.."/5")
	end	

	self._index = 1 

	self:getScheduler().performWithDelayGlobal(function()
		self:_showItemBoxEffects()
	end, 4.2)
end

function QUIDialogRatFestivalTavernAchieve:_tavernUpdate(event)
	if not event.options then
		return
	end
    self._ccbOwner.node_buy_more:setVisible(false)

	for i = 1, self._prizesNum do
		if self["_nodeItemBox"..i] then
			self["_nodeItemBox"..i]:removeFromParent()
			self["_nodeItemBox"..i] = nil
		end
	end
	self._itemEffects = nil

	local options = event.options
	self:getOptions().items = options.items
	self._prizes = clone(options.items)
	self._prizesNum = #self._prizes
	self._lastLuckyCardIds = options.lastLuckyCardIds
	self._againCallback = options.againCallback
	self._confirmCallback = options.confirmCallback
	self:_checkWholeLuckyCard()

	local moneyConfig = remote.items:getWalletByType(ITEM_TYPE.RAT_FESTIVAL_MONEY)
	QSetDisplayFrameByPath(self._ccbOwner.sp_gold, moneyConfig.alphaIcon)
	local moneyCount = remote.user[ITEM_TYPE.RAT_FESTIVAL_MONEY] or 0
	if self._prizesNum == 1 then
		self._ccbOwner.tf_btn_buy:setString("再抽一次")
		self._ccbOwner.tf_money:setString(moneyCount.."/1")
	else
		self._ccbOwner.tf_btn_buy:setString("再抽五次")
		self._ccbOwner.tf_money:setString(moneyCount.."/5")
	end	

	self._index = 1 
	self:_showItemBoxEffects()
end

-- @isNeedShowCard：是否顯示整卡。 @showLuckyCardId：顯示哪張整卡的id。@fragmentItemCount：if nil then it is real card else it is fragment_count。
function QUIDialogRatFestivalTavernAchieve:_checkWholeLuckyCard()
	for _, value in ipairs(self._prizes) do
		if value.id == self._ratFestivalModel:getLuckyCardFragmentItemId() then
			value.isNeedShowCard, value.showLuckyCardId, value.fragmentItemCount = self:_isWholeLuckyCard(nil, value.count)
		elseif self._ratFestivalModel:isLuckyCardId(value.id) then
			value.isNeedShowCard, value.showLuckyCardId, value.fragmentItemCount = self:_isWholeLuckyCard(value.id)
		else
			value.isNeedShowCard = false
			value.showLuckyCardId = nil
			value.fragmentItemCount = nil
		end
	end
end

-- 這裡支持ID檢測是否已經擁有，也支持碎片數量判斷是否是整張卡轉換成的碎片（前提是沒張卡轉換的碎片數量不一樣，並且直接抽到碎片數量也不一樣）
function QUIDialogRatFestivalTavernAchieve:_isWholeLuckyCard(luckyCardId, luckyCardFragmentItemCount)
	if luckyCardId then
		for _, id in ipairs(self._lastLuckyCardIds) do
			if luckyCardId == id then
				local config = db:getItemByID(id)
				local tbl = string.split(config.material_recycle, "^")
				if #tbl > 0 and tonumber(tbl[1]) == self._ratFestivalModel:getLuckyCardFragmentItemId() then
					return true, id, tonumber(tbl[2])
				end
				return false
			end
		end
		table.insert(self._lastLuckyCardIds, luckyCardId)
		return true, luckyCardId
	elseif luckyCardFragmentItemCount then
		return self._ratFestivalModel:isLuckyCardReplaceByItemCount(luckyCardFragmentItemCount)
	end
	
	return false
end

function QUIDialogRatFestivalTavernAchieve:_showItemBoxEffects()
	if self._index > self._prizesNum then return end

	self._info = clone(self._prizes[self._index])

	if self._info.isNeedShowCard then
    	self._showLuckyCardId = self._info.showLuckyCardId
	end

	self:_setItemBox()
end 

function QUIDialogRatFestivalTavernAchieve:_setItemBox() 
	self["_nodeItemBox"..self._index] = CCNode:create()
	self._ccbOwner.node_box:addChild(self["_nodeItemBox"..self._index])
	self["_itemBox"..self._index] = QUIWidgetItemsBox.new()
	if self._info.fragmentItemCount then
		-- 碎片
		self["_itemBox"..self._index]:setGoodsInfo(self._ratFestivalModel:getLuckyCardFragmentItemId(), ITEM_TYPE.ITEM, self._info.fragmentItemCount)
	else
		-- 整卡 or 其他
		local itemType = remote.items:getItemType(self._info.type)
		self["_itemBox"..self._index]:setGoodsInfo(self._info.id, itemType, self._info.count)
	end
	self["_itemBox"..self._index]:setNeedshadow( false )
	self["_itemBox"..self._index]:setPosition(ccp(0, -200))
	self["_nodeItemBox"..self._index]:addChild(self["_itemBox"..self._index])

	local itemInfo = db:getItemByID(self._info.id)
	if itemInfo and itemInfo.highlight == 1 then
		if itemInfo.colour == ITEM_QUALITY_INDEX.ORANGE then
			self["_itemBox"..self._index]:showBoxEffect("Widget_AchieveHero_light_orange.ccbi")
		elseif itemInfo.colour == ITEM_QUALITY_INDEX.RED then
			self["_itemBox"..self._index]:showBoxEffect("Widget_AchieveHero_light_red.ccbi")
		end
	end

	local maxNum = math.floor(self._prizesNum/2)
	local startPositionX = -290
	local startPositionY = 50
	local lineGap = 175
	local rowGap = 145

	local itemNum = self._index
	local lineNum = 1
	local posX = startPositionX + ((itemNum-1) * rowGap)
	local posY = startPositionY - ((lineNum-1) * lineGap)
	if self._prizesNum == 1 then
		posX = 0
		posY = 0
	end
	posY = 40

	self:_nodeRunAction(self["_itemBox"..self._index], posX, posY)
end

-- 移动到指定位置
function QUIDialogRatFestivalTavernAchieve:_nodeRunAction(node, posX, posY)
    app.sound:playSound("common_award")

	self._itemPosX = posX
	self._itemPosY = posY
	self._currentNode = node
    self._isMove = true

	node:setBoxScale(0)
    node:setPosition(ccp(posX, posY))

    if self._showLuckyCardId then
    	if self._itemEffects then
			self._itemEffects:disappear()
			self._itemEffects = nil
		end

	    local callback = function()
	    	if self:safeCheck() then
	    		if self._itemEffects then
	    			self._itemEffects:resumeAnimation()
	    		end
	    		local arrayIn = CCArray:create()
				arrayIn:addObject(CCDelayTime:create(0.2))
			    arrayIn:addObject(CCCallFunc:create(function() 
						node:setBoxScale(1)
						local itemEffects1 = QUIWidgetAnimationPlayer.new()
						self._currentNode:addChild(itemEffects1)
						itemEffects1:setScale(0.8)
						itemEffects1:playAnimation("effects/chouka_2.ccbi", nil)
						local itemEffects2 = QUIWidgetAnimationPlayer.new()
						self._currentNode:addChild(itemEffects2)
						itemEffects2:playAnimation("effects/Item_box_shine.ccbi", function()
							end, function ()
								self._index = self._index + 1 
								self:_checkNextItem()
								node:showItemName()
							end, true)

			    	end))

	    		node:runAction(CCSequence:create(arrayIn))
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
		arrayIn:addObject(CCDelayTime:create(0.2))
	    arrayIn:addObject(CCCallFunc:create(function() 
	    		if self._itemEffects then
	    			self._itemEffects:pauseAnimation()
	    		end
	    		if self._info.isNeedShowCard then
		    		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalTavernShowCard", 
		        		options={showLuckyCardId = self._info.showLuckyCardId, callback = callback}})
		    	else
		    		callback()
		    	end
	    	end))

	    local actionArrayIn = CCArray:create()
	    actionArrayIn:addObject(CCCallFunc:create(aniFunc))
	    actionArrayIn:addObject(CCSequence:create(arrayIn))
    	node:runAction(CCSpawn:create(actionArrayIn))
    else
	    local arrayIn = CCArray:create()
		arrayIn:addObject(CCDelayTime:create(0.35))
	    arrayIn:addObject(CCCallFunc:create(function() 
				node:setBoxScale(1)
	    	end))

	    local actionArrayIn = CCArray:create()
	    actionArrayIn:addObject(CCSequence:create(arrayIn))
	    actionArrayIn:addObject(CCCallFunc:create(function() 
	    		local itemEffects = QUIWidgetAnimationPlayer.new()
				node:addChild(itemEffects)
				itemEffects:setScale(1.2)
				itemEffects:playAnimation("effects/whd_shilian_1.ccbi", nil, nil, false)

				local itemEffects2 = QUIWidgetAnimationPlayer.new()
				node:addChild(itemEffects2)
				itemEffects2:playAnimation("effects/chouka_3.ccbi", nil, nil, false)
	    	end))

	    local array = CCArray:create()
	    array:addObject(CCSpawn:create(actionArrayIn))
	    array:addObject(CCCallFunc:create(function() 
			    self._index = self._index + 1 
			    self:_checkNextItem()
				node:showItemName()
			end))

    	node:runAction(CCSequence:create(array))
    end
end

function QUIDialogRatFestivalTavernAchieve:_checkNextItem()
    self._showLuckyCardId = nil
    if self._index > self._prizesNum then
		for i = 1, self._prizesNum do
			self["_itemBox"..i]:setPromptIsOpen(true)
		end
		self._ccbOwner.node_buy_more:setVisible(true)
		self:_showTavernSroreAni()
    else
    	self:_showItemBoxEffects()
	end
end

function QUIDialogRatFestivalTavernAchieve:_showTavernSroreAni()
	local score = db:getConfigurationValue("RAT_FESTIVAL_INTEGRAL")
	if score and score > 0 then
		local totalScore = score * self._prizesNum
		local scoreEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_effect:removeAllChildren()
		self._ccbOwner.node_effect:addChild(scoreEffect)
		scoreEffect:playAnimation("effects/Peiyang_tips.ccbi", function(ccbOwner)
				ccbOwner.tf_name:setString("获得福气值 +"..totalScore)
			end)
	end
end

function QUIDialogRatFestivalTavernAchieve:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_back) == false then return end
	if self._index <= self._prizesNum then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	
  	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.setBackBtnVisible then page:setBackBtnVisible(true) end
    if page.setHomeBtnVisible then page:setHomeBtnVisible(true) end
    if page.setScalingVisible then page:setScalingVisible(true) end
    if page.setManyUIVisible then page:setManyUIVisible() end
    if page.topBar then page.topBar:showWithRatFestival() end

    if self._confirmCallback then
    	self._confirmCallback()
    end
end

function QUIDialogRatFestivalTavernAchieve:_onTriggerAgain(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy) == false then return end
	if self._index <= self._prizesNum then return end
    app.sound:playSound("common_small")

	if self._againCallback then
		self._againCallback({isAgain = true})
	end
end

return QUIDialogRatFestivalTavernAchieve