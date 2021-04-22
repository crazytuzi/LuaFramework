--
-- Author: xurui
-- Date: 2016-04-06 15:16:25
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGemstoneTavernAchieve = class("QUIDialogGemstoneTavernAchieve", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogGemstoneTavernAchieve:ctor(options)
	local ccbFile = "ccb/effects/hungu_baoxiang_huode.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogGemstoneTavernAchieve._onTriggerConfirm)},
	}
	QUIDialogGemstoneTavernAchieve.super.ctor(self, ccbFile, callBacks, options)
	
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(false)

    self._ccbOwner.node_buy:setVisible(false)
    self._step = 0
    self._stepFinish = false
end

function QUIDialogGemstoneTavernAchieve:viewDidAppear()
    QUIDialogGemstoneTavernAchieve.super.viewDidAppear(self)
   	self:initView()
end

function QUIDialogGemstoneTavernAchieve:viewWillDisappear()
  	QUIDialogGemstoneTavernAchieve.super.viewWillDisappear(self)
  	if self._scheduler then
  		scheduler.unscheduleGlobal(self._scheduler)
  		self._scheduler = nil
  	end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(true)
end

function QUIDialogGemstoneTavernAchieve:initView()
	local options = self:getOptions()
	self._callback = options.callback
	self.prize = clone(options.items)
	self.prizeNum = #self.prize

	self.index = 1 
	self:setItemBoxEffects()
  	if self._scheduler then
  		scheduler.unscheduleGlobal(self._scheduler)
  		self._scheduler = nil
  	end
    self._scheduler = scheduler.performWithDelayGlobal(function()
    		self._ccbOwner.node_buy:setVisible(true)
			-- makeNodeCascadeOpacityEnabled(self._ccbOwner.item_node, true)
			-- local num = self.prizeNum%10
			-- if self.prizeNum - self._step > 10 then
			-- 	num = 10
			-- end
			-- for i = 1, num do
			-- 	self["heroHeadBox"..i]:setOpacity(0.2)
			-- 	self["heroHeadBox"..i]:runAction(CCFadeTo:create(1/15, 255))
			-- end
    	end, 0.8)	
end

function QUIDialogGemstoneTavernAchieve:setItemBoxEffects()
	if self.index > self._step+10 then
		self._step = self._step+10
		self._stepFinish = true
		return
	end
	if self.index > self.prizeNum then return end

	self.isHero = false
	self.info = clone(self.prize[self.index])
	self:_setItemBox()
end 

function QUIDialogGemstoneTavernAchieve:_setItemBox() 
	local info = self.info

	self["_headBoxNode"..self.index] = CCNode:create()
	self["_headEffectNode"..self.index] = CCNode:create()
	self._ccbOwner.item_node:addChild(self["_headBoxNode"..self.index])
	self._ccbOwner.item_node:addChild(self["_headEffectNode"..self.index])

	local itemType = remote.items:getItemType(info.type)
	self["heroHeadBox"..self.index] = QUIWidgetItemsBox.new()
	self["heroHeadBox"..self.index]:setGoodsInfo(info.id, itemType, info.count)
	self["heroHeadBox"..self.index]:showItemName()
	self["heroHeadBox"..self.index]:setPromptIsOpen(true)
	self["heroHeadBox"..self.index]:setNeedshadow( false )
	
	if itemType == ITEM_TYPE.ITEM then
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(info.id)
		if itemInfo.highlight == 1 then
			self["heroHeadBox"..self.index]:showEffect()
		elseif itemInfo.colour == ITEM_QUALITY_INDEX.ORANGE then
			self["heroHeadBox"..self.index]:showBoxEffect("Widget_AchieveHero_light_orange.ccbi")
		elseif itemInfo.colour == ITEM_QUALITY_INDEX.RED then
			self["heroHeadBox"..self.index]:showBoxEffect("Widget_AchieveHero_light_red.ccbi")
		end
	end
	self["_headBoxNode"..self.index]:addChild(self["heroHeadBox"..self.index])

	local index = self.index-self._step
	local maxNum = 5
	local startPositionX = -135*2
	local itemNum = (index-1)%maxNum
	local lineNum = math.floor((index-1)/maxNum)
	local posX = startPositionX + itemNum * 135
	local posY = 80 - lineNum * 160
	if self.prizeNum == 1 then
		posX = 0
		posY = 30
	end

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

function QUIDialogGemstoneTavernAchieve:_showShineEffects()
	-- self._ccbOwner.node_buy:setVisible(true)
	local num = self.prizeNum%10
	if self.prizeNum - self._step > 10 then
		num = 10
	end
	for i = 1, num do
		local itemEffects = QUIWidgetAnimationPlayer.new()
		self["_headEffectNode"..i]:addChild(itemEffects)
		itemEffects:playAnimation("effects/Item_box_shine2.ccbi", function()
			end)
	end
end 

function QUIDialogGemstoneTavernAchieve:_onTriggerConfirm(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_back) == false then return end
	if self.index <= self.prizeNum then 
		if self._stepFinish then
			self._stepFinish = false
			self._ccbOwner.item_node:removeAllChildren()
			self:setItemBoxEffects()
		end
	 	return 
	end

	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	if self._callback then
		self._callback()
	end
end

return QUIDialogGemstoneTavernAchieve