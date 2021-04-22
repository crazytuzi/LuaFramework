local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetShopTap = class("QUIWidgetShopTap", QUIWidget)

local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRemote = import("...models.QRemote")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetShopTap:ctor(options)
	local ccbFile = "ccb/Widget_tap2.ccbi"
	local callBacks = {
		{ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)}
	}
	QUIWidgetShopTap.super.ctor(self, ccbFile, callBacks, options)

	self._money = options.money or 0
	self:setString(math.ceil(self._money))

	if options ~= nil then
		self._currencyType = options.type
		self._havePlus = options.havePlus or false
	end

	self._currencyInfo = remote.items:getWalletByType(self._currencyType)

	self:setCurrencyIcon()

	self._moneyUpdate = QTextFiledScrollUtils.new()

	if self._havePlus == false then
		self._ccbOwner.plus:setVisible(false)
	end
end

function QUIWidgetShopTap:onEnter()
	self._remoteEventProxy = cc.EventProxy.new(remote.user)
	self._remoteEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.setMoney))
end

function QUIWidgetShopTap:onExit()
	self._remoteEventProxy:removeAllEventListeners()
	self._remoteEventProxy = nil
	self._moneyUpdate:stopUpdate()
end

function QUIWidgetShopTap:setCurrencyIcon()
	local path = self._currencyInfo.alphaIcon

	if path ~= nil then
		local icon = CCSprite:create()
		icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
		self._ccbOwner.icon_node:addChild(icon)
		self._ccbOwner.icon_node:setScale(0.8)
	end
end

function QUIWidgetShopTap:setMoney(money)
	if type(money) ~= number then
		money = remote.user[self._currencyInfo.name]
	end
	if money then
		local currentMoney = self._money
		self:showTipsAnimation(tonumber(money) - tonumber(currentMoney))
		self._moneyUpdate:addUpdate(tonumber(currentMoney), tonumber(money), function (value)
			self:setString(math.ceil(value))
		end, 2)
		self._money = money
	end
end

function QUIWidgetShopTap:setString(moneyNum)
	local wordLen = q.wordLen(moneyNum, 42, 21)
	local maxLen = 150
	if wordLen > maxLen then
		self._scale = maxLen/wordLen
		self._ccbOwner.CCLabelBMFont_MidNum:setScale(maxLen/wordLen)
	else
		self._scale = 1
		self._ccbOwner.CCLabelBMFont_MidNum:setScale(1)
	end
	self._ccbOwner.CCLabelBMFont_MidNum:setString(moneyNum)
end

function QUIWidgetShopTap:showTipsAnimation(value)
	local effectName = nil
	if value > 0 then
		effectName = "effects/Tips_add.ccbi"
	elseif value < 0 then
		effectName = "effects/Tips_Decrease.ccbi"
	end

	if effectName then
		local content = (value > 0) and ("+" .. value) or value
		local effect = QUIWidgetAnimationPlayer.new()
		self:addChild(effect)
		effect:setPosition(ccp(0, -60))
		effect:playAnimation(effectName, function(ccbOwner)
			ccbOwner.content:setString(content)
		end, function()
			effect:removeFromParentAndCleanup(true)
		end)
	end
end

function QUIWidgetShopTap:_onPlus()
	if self._currencyType == nil then return end

	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, self._currencyType)
end

return QUIWidgetShopTap
