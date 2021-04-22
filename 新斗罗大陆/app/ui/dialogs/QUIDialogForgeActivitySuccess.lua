-- @Author: xurui
-- @Date:   2019-04-16 17:35:02
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-04-18 18:53:43
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogForgeActivitySuccess = class("QUIDialogForgeActivitySuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogForgeActivitySuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Activity_Achievement.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerAgain", callback = handler(self, self._onTriggerAgain)},
    }
    QUIDialogForgeActivitySuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._activeStatus = options.activeStatus
    	self._awards = options.awards or {}
    	self._isSuccess = options.isSuccess
    end

    self._effectIsEnd = false
	self._oForgeActivity = remote.activityRounds:getForge()
	self._tCritAward = QStaticDatabase:sharedDatabase():getLuckyDraw("forge_lucky_draw3")

    local animationName = "1"
    self._delayTime = 1.3
    local soundDealyTime = 0.6
    if self._activeStatus == 3 then
    	animationName = "2"
    	self._delayTime = 2.3
    	soundDealyTime = 0.3
    end

	self:getScheduler().performWithDelayGlobal(function()
  			app.sound:playSound("forge1")
    	if self._activeStatus == 3 then
			self:getScheduler().performWithDelayGlobal(function()
	  			app.sound:playSound("forge2")
			end, 1)
    	end
	end, soundDealyTime)
	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	self._animationManager:runAnimationsForSequenceNamed(animationName)
end

function QUIDialogForgeActivitySuccess:viewDidAppear()
	QUIDialogForgeActivitySuccess.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogForgeActivitySuccess:viewWillDisappear()
  	QUIDialogForgeActivitySuccess.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogForgeActivitySuccess:setInfo()
	self._forgeNum = #self._awards

	if self._forgeNum == 1 then
		self._ccbOwner.node_success:setVisible(self._isSuccess)
		self._ccbOwner.node_success_title:setVisible(self._isSuccess)
		self._ccbOwner.node_done_title:setVisible(false)
		self._ccbOwner.node_loss:setVisible(not self._isSuccess)
	else
		self._ccbOwner.node_success:setVisible(true)
		self._ccbOwner.node_done_title:setVisible(true)
		self._ccbOwner.node_success_title:setVisible(false)
		self._ccbOwner.node_loss:setVisible(false)
	end


	local maxCount, itemInfo = self._oForgeActivity:getCurrentForgeCount(true)
	self._ccbOwner.tf_forge_count:setString(string.format("还可锻造%s次", maxCount))

	if self._forgeNum == 1 then
		self._ccbOwner.tf_again:setString("锻造")
	else
		local numStr = q.numToWord(self._forgeNum)
		self._ccbOwner.tf_again:setString(string.format("锻造%s次", numStr))
	end

	self:setAwardsItem()
end

function QUIDialogForgeActivitySuccess:setAwardsItem()
	self.index = 1

	self:getScheduler().performWithDelayGlobal(function()
		self:_setItemBox()
	end, self._delayTime)
end

function QUIDialogForgeActivitySuccess:_setItemBox() 
	local info = self._awards[self.index]
	self["itemNode"..self.index] = CCNode:create()
	self._ccbOwner.node_icon:addChild(self["itemNode"..self.index])

	self["itemBox"..self.index] = QUIWidgetItemsBox.new()
	local itemType = remote.items:getItemType(info.type)
	self["itemBox"..self.index]:setGoodsInfo(info.id, itemType, info.count)
	if info.id == self._tCritAward.id_1 and itemType == self._tCritAward.type_1 then
		self["itemBox"..self.index]:showBoxEffect("effects/Auto_Skill_light.ccbi", true, 0, 0, 1.2)
	end
	self["itemBox"..self.index]:setNeedshadow( false )
	if itemType == ITEM_TYPE.ITEM then
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(info.id)
		if itemInfo.colour == ITEM_QUALITY_INDEX.PURPLE then
			self["itemBox"..self.index]:showBoxEffect("Widget_AchieveHero_light_purple.ccbi")
		elseif itemInfo.colour == ITEM_QUALITY_INDEX.ORANGE then
			self["itemBox"..self.index]:showBoxEffect("Widget_AchieveHero_light_orange.ccbi")
		end
	end
	if itemType == ITEM_TYPE.HERO or itemType == ITEM_TYPE.ZUOQI then
		local itemConfig = db:getCharacterByID(tonumber(info.id))
		self["itemBox"..self.index]:showSabc(remote.gemstone:getSABC(itemConfig.aptitude).lower)
	end

	local positionY = -100
	if self.tavernType == TAVERN_SHOW_HERO_CARD.ORIENT_TAVERN_TYPE then
		positionY = 0
	end
	self["itemBox"..self.index]:setPosition(ccp(0, positionY))

	self["itemNode"..self.index]:addChild(self["itemBox"..self.index])

	local maxNum = 5
	local rowGap = 145

	local itemNum = self.index > maxNum and self.index-maxNum or self.index
	local posX = -290 + ((itemNum-1) * rowGap)
	if self._forgeNum == 1 then
		posX = 0
	end
	self:_nodeRunAction(self["itemBox"..self.index], posX)
end

-- 移动到指定位置
function QUIDialogForgeActivitySuccess:_nodeRunAction(node, posX)
    self._isMove = true
    local actionTime = 0.125
    node:setScale(0)

    app.sound:playSound("common_award")

    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveTo:create(actionTime, ccp(posX, 0)))
    actionArrayIn:addObject(CCScaleTo:create(actionTime, 1, 1))
    actionArrayIn:addObject(CCRotateBy:create(actionTime, -360))
    actionArrayIn:addObject(CCCallFunc:create(function() 
			local itemEffects = QUIWidgetAnimationPlayer.new()
			node:addChild(itemEffects)
			itemEffects:playAnimation("effects/Item_box_shine.ccbi", function()
				end)
    	end))

    local array = CCArray:create()
    array:addObject(CCSpawn:create(actionArrayIn))
    array:addObject(CCCallFunc:create(function() 
                        self.index = self.index + 1 
                        if self.index > self._forgeNum then
							for i = 1, self._forgeNum do
								self["itemBox"..i]:setPromptIsOpen(true)
							end

							self._effectIsEnd = true
                        else
                        	self:_setItemBox()
                    	end
						node:showItemName()
                    end))
    self._actionHandler = node:runAction(CCSequence:create(array))
end

function QUIDialogForgeActivitySuccess:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
	self:_onTriggerClose()
end

function QUIDialogForgeActivitySuccess:_onTriggerAgain(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_again) == false then return end
	self._isAgain = true
	self:_onTriggerClose()
end

function QUIDialogForgeActivitySuccess:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogForgeActivitySuccess:_onTriggerClose()
  	app.sound:playSound("common_close")

  	if self._effectIsEnd  then		
		self:playEffectOut()
	end
end

function QUIDialogForgeActivitySuccess:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback(self._isAgain, self._forgeNum)
	end
end

return QUIDialogForgeActivitySuccess
