--
-- Author: Kumo
-- Date: 2014-07-17 14:08:11
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogWin = class("QUIDialogWin", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogWin:ctor(options) 
	assert(options ~= nil, "alert dialog options is nil !")
 	local ccbFile = "ccb/Dialog_GloryTower_zhandoushengli.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogWin._onTriggerClose)},
	    {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogWin._onTriggerConfirm)},
	}
	QUIDialogWin.super.ctor(self, ccbFile, callBacks, options)

	self.isAnimation = options.isAnimation == nil and true or false
	-- self._colorful = options.colorful
	self._callBack = options.callback
	self._closeCallback = options.closeCallback
	self._awards = options.awards or {}
	self._bonusAwards = options.bonusAwards or {}
    self._addScore = options.addScore or 0
    self._userComeBackRatio = options.userComeBackRatio or 1
    self._activityYield = options.activityYield or 1
	self._yield = options.yield or 1
	self._text = options.text

	if not self._text then
		self._text = "魂师大人，本次战斗您不费吹灰之力就战胜了对手，以下是您的奖励哟～"
	end
	self._ccbOwner.tf_txt:setString(self._text)

	local itemBoxs = {}
	local index = 1
	local width = 0
	local gap = 30
	local contentSize
	for _, award in pairs(self._awards) do
		itemBoxs[index] = QUIWidgetItemsBox.new()
		-- QPrintTable(award)
		if award.id then
			itemBoxs[index]:setGoodsInfo(tonumber(award.id), award.typeName, tonumber(award.count))
		else
			itemBoxs[index]:setGoodsInfo(nil, award.typeName, tonumber(award.count))
		end
		itemBoxs[index]:setPromptIsOpen(true)
		itemBoxs[index]:showEffect()
		itemBoxs[index]:setGloryTowerType(false)
		self._ccbOwner.node_item:addChild( itemBoxs[index] )

		contentSize = itemBoxs[index]:getContentSize()
		itemBoxs[index]:setPositionX(width)
		width = width + contentSize.width + gap
		index = index + 1
	end
	if self._addScore > 0 then
		itemBoxs[index] = QUIWidgetItemsBox.new()
		itemBoxs[index]:setGoodsInfo(nil, ITEM_TYPE.TOWER_INTEGRAL, tonumber(self._addScore))
		itemBoxs[index]:setPromptIsOpen(true)
		itemBoxs[index]:showEffect()
		itemBoxs[index]:setGloryTowerType(false)
		self._ccbOwner.node_item:addChild( itemBoxs[index] )

		contentSize = itemBoxs[index]:getContentSize()
		itemBoxs[index]:setPositionX(width)
		width = width + contentSize.width + gap
		index = index + 1
	end
	for _, award in pairs(self._bonusAwards) do
		itemBoxs[index] = QUIWidgetItemsBox.new()
		-- QPrintTable(award)
		if award.id then
			itemBoxs[index]:setGoodsInfo(tonumber(award.id), award.typeName, tonumber(award.count))
		else
			itemBoxs[index]:setGoodsInfo(nil, award.typeName, tonumber(award.count))
		end
		itemBoxs[index]:setPromptIsOpen(true)
		itemBoxs[index]:showEffect()
		if award.isShowGloryTowerType == 1 then
			itemBoxs[index]:setGloryTowerType(true)
		end
		self._ccbOwner.node_item:addChild( itemBoxs[index] )

		contentSize = itemBoxs[index]:getContentSize()
		itemBoxs[index]:setPositionX(width)
		width = width + contentSize.width + gap
		index = index + 1
	end

	-- 翻倍处理
	if self._userComeBackRatio > 0 then
		self._activityYield = (self._activityYield - 1) + (self._userComeBackRatio - 1) + 1
	end
	if self._yield > 0 then
		self._activityYield = self._activityYield * self._yield
	end
	if self._activityYield > 1 then
		for i = 1, #itemBoxs do
			local itemType = itemBoxs[i]:getItemType()
			if itemType == ITEM_TYPE.SUNWELL_MONEY or
				itemType == ITEM_TYPE.TOWER_MONEY or
				itemType == ITEM_TYPE.MARITIME_MONEY then
				itemBoxs[i]:setRateActivityState(true, self._activityYield)
			end
		end
	end

	local posX = self._ccbOwner.node_item:getPositionX()
	self._ccbOwner.node_item:setPositionX(posX - width/2 + (contentSize.width + gap)/2)
end

function QUIDialogWin:setDesc(desc)
	self._ccbOwner.tf_txt:setString(desc)
end

function QUIDialogWin:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogWin:_onTriggerClose()
	if self._closeCallback then
		self._closeCallback()
	end
	self:playEffectOut()
end

function QUIDialogWin:viewAnimationOutHandler()
	local callBack = self._callBack
	self:popSelf()
	if callBack ~= nil then
		callBack()
	end
end

return QUIDialogWin