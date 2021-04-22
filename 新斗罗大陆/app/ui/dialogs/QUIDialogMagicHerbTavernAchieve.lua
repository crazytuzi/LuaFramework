--
-- Author: zxs
-- 仙品宝箱爆炸
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbTavernAchieve = class("QUIDialogMagicHerbTavernAchieve", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogMagicHerbTavernAchieve:ctor(options)
	local ccbFile = "ccb/effects/xianpin_baoxiang_huode.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerAgain", callback = handler(self, self._onTriggerAgain)}
	}
	QUIDialogMagicHerbTavernAchieve.super.ctor(self, ccbFile, callBacks, options)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(false)
end

function QUIDialogMagicHerbTavernAchieve:viewDidAppear()
    QUIDialogMagicHerbTavernAchieve.super.viewDidAppear(self)
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)

   	self:initView()
end

function QUIDialogMagicHerbTavernAchieve:viewWillDisappear()
  	QUIDialogMagicHerbTavernAchieve.super.viewWillDisappear(self)
  	self.prompt:removeItemEventListener()
  	if self._scheduler then
  		scheduler.unscheduleGlobal(self._scheduler)
  		self._scheduler = nil
  	end
  	if self._scheduler1 then
  		scheduler.unscheduleGlobal(self._scheduler1)
  		self._scheduler1 = nil
  	end
  	
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(true)
end

function QUIDialogMagicHerbTavernAchieve:initView(options)
	local options = self:getOptions()
	self.prize = clone(options.items)
	self.againBack = options.againBack
	self.money = options.cost
	self.oldHeros = options.oldHeros
	self.tavernType = options.tavernType
	self.tokenType = options.tokenType
	self.prizeNum = #self.prize
	self.confirmBack = options.confirmBack

	self._ccbOwner.tf_money:setString(self.money)
	
	if self.prizeNum == 1 then
		self._ccbOwner.buy_label:setString("再召一次")
	else
		self._ccbOwner.buy_label:setString("再召十次")
	end	

	self.index = 1 
	self.heros = {}
	self:setItemBoxEffects()
    self:setTitleByType()

  	if self._scheduler then
  		scheduler.unscheduleGlobal(self._scheduler)
  		self._scheduler = nil
  	end


    self._scheduler = scheduler.performWithDelayGlobal(function()
			-- makeNodeCascadeOpacityEnabled(self._ccbOwner.item_node, true)
			for i = 1, self.prizeNum do
				self["heroHeadBox"..i]:setOpacity(0.2)
				self["heroHeadBox"..i]:runAction(CCFadeTo:create(1/15, 255))
			end
    	end, 4/3)	
end

function QUIDialogMagicHerbTavernAchieve:setItemBoxEffects()
	if self.index > self.prizeNum then return end

	self.isHero = false
	self.info = clone(self.prize[self.index])
	if self.info.type == "HERO" then
		self.isHero = true
		self:showHeroCard()
	else
		self:_setItemBox()
	end
end 

function QUIDialogMagicHerbTavernAchieve:showHeroCard()
	self.isHave = false

	--检查购买前是否拥有该魂师
	if next(self.oldHeros) then
		for k, value in pairs(self.oldHeros) do
			if self.info.id == value then
				self.isHave = true
			end
		end
	end

	--检查本次奖励的魂师中是否有该魂师
	if self.isHave == false and next(self.heros) then
		for k, value in pairs(self.heros) do 
			if value.id == self.info.id then
				self.isHave = true
			end
		end
	end
	table.insert(self.heros, self.info)
	
	local heroInfo = db:getCharacterByID(self.info.id)
	if heroInfo ~= nil and heroInfo.grade ~= nil then
		self.info.grade = heroInfo.grade
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernShowHeroCard", 
	        options={actorId = self.info.id, callBack = handler(self, self.checkPrizeHero)}}, {isPopCurrentDialog = false})
end

function QUIDialogMagicHerbTavernAchieve:checkPrizeHero()
    if self.isHave == false then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernShowHeroCard", 
	        options={actorId = self.info.id, callBack = handler(self, self._setItemBox)}}, {isPopCurrentDialog = false})
	else
		local config = db:getGradeByHeroActorLevel(self.info.id , self.info.grade or 0)
        self.info.type = ITEM_TYPE.ITEM
        self.info.id = config.soul_gem
        self.info.count = config.soul_second_hero
		self:_setItemBox()
	end
end

function QUIDialogMagicHerbTavernAchieve:_setItemBox() 
	local info = self.info

	self["_headBoxNode"..self.index] = CCNode:create()
	self["_headEffectNode"..self.index] = CCNode:create()
	self._ccbOwner.item_node:addChild(self["_headBoxNode"..self.index])
	self._ccbOwner.item_node:addChild(self["_headEffectNode"..self.index])

	self["heroHeadBox"..self.index] = QUIWidgetItemsBox.new()
	local itemType = remote.items:getItemType(info.type)
	self["heroHeadBox"..self.index]:setGoodsInfo(info.id, itemType, info.count)
	self["heroHeadBox"..self.index]:setNeedshadow( false )
	
	if itemType == ITEM_TYPE.ITEM then
		local itemInfo = db:getItemByID(info.id)
		if itemInfo.highlight == 1 then
			self["heroHeadBox"..self.index]:showEffect()
		elseif itemInfo.colour == ITEM_QUALITY_INDEX.ORANGE then
			self["heroHeadBox"..self.index]:showBoxEffect("Widget_AchieveHero_light_orange.ccbi")
		elseif itemInfo.colour == ITEM_QUALITY_INDEX.RED then
			self["heroHeadBox"..self.index]:showBoxEffect("Widget_AchieveHero_light_red.ccbi")
		end
	end

	self["heroHeadBox"..self.index]:showItemName()
	self["heroHeadBox"..self.index]:setPromptIsOpen(true)
	self["_headBoxNode"..self.index]:addChild(self["heroHeadBox"..self.index])

	local maxNum = math.floor(self.prizeNum/2)
	local startPositionX = maxNum == 3 and -135 or -270
	local itemNum = self.index > maxNum and self.index-maxNum or self.index
	local lineNum = self.index > maxNum and 2 or 1
	local posX = startPositionX + ((itemNum-1) * 135)
	local posY = 40 - ((lineNum-1) * 160)
	if self.prizeNum == 1 then
		posX = 0
		posY = 0
	end
	posY = posY + 30

	self["heroHeadBox"..self.index]:setPosition(ccp(posX, posY))
	self["heroHeadBox"..self.index]:setOpacity(0)
	self["_headEffectNode"..self.index]:setPosition(ccp(posX, posY))

    self.index = self.index + 1 
    if self.index <= self.prizeNum then
    	self:setItemBoxEffects()
    else
    	app.sound:playSound("common_end")
    end
end

function QUIDialogMagicHerbTavernAchieve:setTitleByType()
	local maxNum = 1
	if self.prizeNum == 10 then maxNum = 10 end
    self._ccbOwner.tf_money:setString((self.money or 0).."/"..maxNum)
    
    if self.money ~= nil then
        self._ccbOwner.node_buy:setVisible(true)
    else    
        self._ccbOwner.btn_ok:setVisible(true)
    end
end

function QUIDialogMagicHerbTavernAchieve:_showShineEffects()
	for i = 1, self.prizeNum do
		local itemEffects = QUIWidgetAnimationPlayer.new()
		self["_headEffectNode"..i]:addChild(itemEffects)
		itemEffects:playAnimation("effects/Item_box_shine2.ccbi", function()
			end)
	end
end 

function QUIDialogMagicHerbTavernAchieve:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_back) == false then return end
	if self.index <= self.prizeNum then return end
    if self.confirmBack ~= nil then
    	self.confirmBack()
    end
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMagicHerbTavernAchieve:_onTriggerAgain(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_again) == false then return end
	if self.index <= self.prizeNum then return end
	local againBack = self.againBack
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

	if againBack ~= nil then
		againBack({isAgain = true})
	end
end

return QUIDialogMagicHerbTavernAchieve