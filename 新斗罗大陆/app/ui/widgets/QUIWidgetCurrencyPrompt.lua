--
-- Author: xurui
-- Date: 2015-05-18 18:15:57
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetCurrencyPrompt = class("QUIWidgetCurrencyPrompt", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetCurrencyPrompt:ctor(options)
	local ccbFile = "ccb/Widget_DialySignIn_GlodPrompt.ccbi"
	local callBacks = {}
	QUIWidgetCurrencyPrompt.super.ctor(self, ccbFile, callBacks, options)

	local typeName = remote.items:getItemType(options.type)
	if typeName == ITEM_TYPE.ENERGY then 
	    self.word = "挑战副本需要消耗的体力。"
	elseif typeName == ITEM_TYPE.VIP then
 		self.word = "领取后可以获得相应的VIP等级。"
	elseif typeName == ITEM_TYPE.TEAM_EXP then
 		self.word = "领取后可以增加相应的战队经验。"
	elseif typeName == ITEM_TYPE.ACHIEVE_POINT then
 		self.word = "完成成就获得的奖励。"
	else
		local currencyInfo = remote.items:getWalletByType(typeName)
		self.word = currencyInfo.description
	end
	self._ccbOwner.content:setString(self.word or "")
	local wordSize = self._ccbOwner.content:getContentSize()

	local oldSize = self._ccbOwner.itme_bg:getContentSize()
	self._ccbOwner.itme_bg:setContentSize(CCSize(wordSize.width + 30, oldSize.height))
	local contentSzie = self._ccbOwner.itme_bg:getContentSize()
	self.size = CCSize(wordSize.width + 30, contentSzie.height)
end

function QUIWidgetCurrencyPrompt:getCurrencyDescription(typeName)
	local wallet = QStaticDatabase:sharedDatabase():getResource()
	for _, value in pairs(wallet) do
		if value.name == typeName then
			return value.description
		end
	end
end

return QUIWidgetCurrencyPrompt