--
-- Author: Kumo.Wang
-- Date: Fri Mar 11 13:03:07 2016
-- 魂力试炼气泡
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulTrialBubble = class("QUIWidgetSoulTrialBubble", QUIWidget)

function QUIWidgetSoulTrialBubble:ctor(options)
	local ccbFile = "ccb/Widget_SoulTrial_Bubble.ccbi"
	local callBacks = {}
	QUIWidgetSoulTrialBubble.super.ctor(self, ccbFile, callBacks, options)

	self._config = options.config

	self._ccbOwner.node_normalPoint:setVisible(false)
	self._ccbOwner.node_bossPoint:setVisible(false)

	self:_init()
end

function QUIWidgetSoulTrialBubble:onEnter()
end

function QUIWidgetSoulTrialBubble:onExit()
end

function QUIWidgetSoulTrialBubble:_init()
	if self._config.boss == 1 then
		self._ccbOwner.node_title:removeAllChildren()
		if self._config and self._config.title_icon1 and self._config.title_icon2 then
			local kuang = CCSprite:create(self._config.title_icon2)
			if kuang then
				self._ccbOwner.node_title:addChild(kuang)
			end
			local sprite = CCSprite:create(self._config.title_icon1)
			if sprite then
				self._ccbOwner.node_title:addChild(sprite)
			end
			self._ccbOwner.node_bossPoint:setVisible(true)
		end
	else
		if self._config.reward then
			local tbl = string.split(self._config.reward, "^")
			-- local resourceConfig = remote.soulTrial:getResourceByName(tbl[1])
			local resourceConfig = remote.items:getWalletByType(tbl[1])
			if resourceConfig then
				local frame = QSpriteFrameByPath(resourceConfig.alphaIcon)
				if frame then
					self._ccbOwner.sp_icon:setDisplayFrame(frame)
				end
			end
			self._ccbOwner.tf_num:setString("x"..tostring(tbl[2] or 0))
			self._ccbOwner.node_normalPoint:setVisible(true)
		end
	end
end

return QUIWidgetSoulTrialBubble
