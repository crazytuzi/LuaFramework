--
-- Author: xurui
-- Date: 2015-07-04 16:30:41
--
local QBattleDialog = import(".QBattleDialog")
local QDialogChooseCard = class("QDialogChooseCard", QBattleDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QDialogChooseCard:ctor(options, owner)
	local ccbFile = "ccb/Dialog_GloryTower_AchievementChard.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickCard1", callback = handler(self, self._onTriggerClickCard1)},
		{ccbCallbackName = "onTriggerClickCard2", callback = handler(self, self._onTriggerClickCard2)},
		{ccbCallbackName = "onTriggerClickCard3", callback = handler(self, self._onTriggerClickCard3)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
	}

	if owner == nil then
    	owner = {}
  	end
  	self._isDone = false
	QDialogChooseCard.super.ctor(self, ccbFile, owner, callBacks)

	if options ~= nil then
		self._rewrad = options.rewrad
	end
	self._index = 1 
	self._ccbOwner.btn_ok:setVisible(false)
	self:setCardInfo()
	self:cardAnimation()

	-- reward in format m^n;m^n;m^n, 3 rewards, first one is real
	print("rewards " .. self._rewrad)
	self._rewards = {}
	local rewards = string.split(self._rewrad, ";")
	for i = 1, 3 do
		if rewards[i] ~= nil then
			local reward = string.split(rewards[i], "^")
			table.insert(self._rewards, {type = reward[1], count = tonumber(reward[2])})
		else
			local reward = string.split(rewards[1], "^")
			table.insert(self._rewards, {type = reward[1], count = tonumber(reward[2])})
		end
	end
end

function QDialogChooseCard:setCardInfo()
	local ccbFile = "ccb/Widget_fanpai.ccbi"
	for i = 1, 3, 1 do
		self["_ccbOwner"..i] = {}
		local proxy = CCBProxy:create()
	    local ccbView = CCBuilderReaderLoad(ccbFile, proxy, self["_ccbOwner"..i])
	    self._ccbOwner["card"..i]:addChild(ccbView)
    	self["animationManager"..i] = tolua.cast(ccbView:getUserObject(), "CCBAnimationManager")
    	self["animationManager"..i]:runAnimationsForSequenceNamed("normal")

	end
end

function QDialogChooseCard:cardAnimation()
    local delayTime1 = CCDelayTime:create(0.15)
    local scale = CCScaleTo:create(0.1, 1.2)
    local scale1 = CCScaleTo:create(0.1, 1)
    local delayTime2 = CCDelayTime:create(0.15)
    local callFunc = CCCallFunc:create(function()
      if self._isDone == false then
      	if self._index >= 3 then
      		self._index = 1
      	else
      		self._index = self._index + 1 
      	end
      	self:cardAnimation()
      end
    end)
    local fadeAction = CCArray:create()
    fadeAction:addObject(delayTime1)
    fadeAction:addObject(scale)
    fadeAction:addObject(scale1)
    fadeAction:addObject(delayTime2)
    fadeAction:addObject(callFunc)
    local ccsequence = CCSequence:create(fadeAction)
    self._ccbOwner["card"..self._index]:runAction(ccsequence)
end

function QDialogChooseCard:_onTriggerClickCard1()
	if self._isDone == true then return end
    app.sound:playSound("common_menu")
  	local b = self:clickCard(1)
  	if b then app.sound:playSound("common_menu") end
end

function QDialogChooseCard:_onTriggerClickCard2()
	if self._isDone == true then return end
    app.sound:playSound("common_menu")
  	local b = self:clickCard(2)
  	if b then app.sound:playSound("common_menu") end
end

function QDialogChooseCard:_onTriggerClickCard3()
	if self._isDone == true then return end
  	local b = self:clickCard(3)
  	if b then app.sound:playSound("common_menu") end
end

function QDialogChooseCard:clickCard(index)
	if self._isClicked then return end
	remote.tower:towerReceiveAwardsRequest(self._rewrad, function(data)
			remote.tower:removeTowerAwards()
			self._isClicked = true
			self["animationManager"..index]:runAnimationsForSequenceNamed("click")
			self.scheduler = scheduler.performWithDelayGlobal(function()
					self:setItemInfo(index)
				end, 0.2)
			scheduler.performWithDelayGlobal(function()
					self:setRestItemInfo(index)
				end, 0.8)
		end)
	return true
end

function QDialogChooseCard:setItemInfo(index)
	local itemBox = QUIWidgetItemsBox.new()
	self["_ccbOwner"..index].item_node:addChild(itemBox)

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._rewards[1].type) or {}
	local itemType = ITEM_TYPE.ITEM
	local name = itemConfig.name or ""
	if tonumber(self._rewards[1].type) == nil then 
		itemType = self._rewards[1].type
		itemConfig = remote.items:getWalletByType(itemType)
		name = itemConfig.nativeName or ""
	end 
	itemBox:setGoodsInfo(self._rewards[1].type, itemType, self._rewards[1].count)
	self["_ccbOwner"..index].item_name:setString(name)
	self["_ccbOwner"..index].item_dec:setString(itemConfig.description)
end

function QDialogChooseCard:setRestItemInfo(index)
	local rIndex = 2
	for i = 1, 3 do 
		if i ~= index then
			self["animationManager"..i]:runAnimationsForSequenceNamed("click")
			local r = rIndex
			scheduler.performWithDelayGlobal(function()
					local itemBox = QUIWidgetItemsBox.new()
					local itemType = ITEM_TYPE.ITEM
					local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._rewards[r].type) or {}
					local name = itemConfig.name or ""
					if tonumber(self._rewards[r].type) == nil then 
						itemType = self._rewards[r].type
						itemConfig = remote.items:getWalletByType(itemType)
						name = itemConfig.nativeName or ""
					end 
					itemBox:setGoodsInfo(self._rewards[r].type, itemType, self._rewards[r].count)
					self["_ccbOwner"..i].item_node:addChild(itemBox)

					self["_ccbOwner"..i].item_name:setString(name)
					self["_ccbOwner"..i].item_dec:setString(itemConfig.description)
					self["_ccbOwner"..i].congrat:setVisible(false)
					if r == 3 then
						self._isDone = true
						-- self._ccbOwner.btn_ok:setVisible(true)
					end
				end, 0.2)
			rIndex = rIndex + 1
		end
	end
end

function QDialogChooseCard:_onTriggerConfirm()
	if self._isDone == false then return end
    self:_onTriggerClose()
end

function QDialogChooseCard:_backClickHandler()
	if self._isDone == false then return end
    self:_onTriggerClose()
end

function QDialogChooseCard:_onTriggerClose()  
  	-- if self.animationIsDone == true then
    	app.sound:playSound("common_item")
    	self._ccbOwner:onCloseCard()
  	-- end
end

return QDialogChooseCard 