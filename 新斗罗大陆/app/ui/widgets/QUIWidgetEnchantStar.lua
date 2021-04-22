--
-- Author: qinyuanji
-- Date: 2015-11-24 11:43:02
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEnchantStar = class("QUIWidgetEnchantStar", QUIWidget)

function QUIWidgetEnchantStar:ctor(options)
	local ccbFile = "ccb/Widget_Enchant_star.ccbi"
	local callBacks = {}
	QUIWidgetEnchantStar.super.ctor(self, ccbFile, callBacks, options)

	self:setStar(options.number)
end

function QUIWidgetEnchantStar:setStar(number)
	number = math.floor(number)
	local owner = self._ccbOwner
	local sprite = nil
	if number <= 0 then
		self:setVisible(false)
		return
	else
		self:setVisible(true)
	end
	if number <= 5 then
		owner.star_light_node:setVisible(true)
		owner.bigStar:setVisible(false)
		for i = 1, 5 do
			sprite = owner["star_light"..i]
			sprite:setVisible(i <= number)
			if i <= number then
			    QSetDisplayFrameByPath(sprite, "ui/common/zuan_s.png")
			end
		end
	elseif number <= 10 then
		number = number - 5
		owner.star_light_node:setVisible(true)
		owner.bigStar:setVisible(false)
		for i = 1, 5 do
			sprite = owner["star_light"..i]
			sprite:setVisible(i <= number)
			if i <= number then
				QSetDisplayFrameByPath(sprite, "ui/common/one_moon.png")
			end
		end
	elseif number <= 15 then
		number = number - 10
		owner.star_light_node:setVisible(true)
		owner.bigStar:setVisible(false)
		for i = 1, 5 do
			sprite = owner["star_light"..i]
			sprite:setVisible(i <= number)
			if i <= number then
				QSetDisplayFrameByPath(sprite, "ui/common/one_sun.png")
			end
		end
	else
		number = number - 10
		owner.star_light_node:setVisible(false)
		owner.bigStar:setVisible(true)
	    QSetDisplayFrameByPath(owner.star_big, "ui/common/sun_g_big.png")
	end

	self._ccbOwner["bigStar"]:setVisible(number > 5)
	self._ccbOwner["star_light_node"]:setVisible(number <= 5)
	if number <= 5 then
		for i = 1, 5 do
			self._ccbOwner["star_light" .. i]:setVisible(i <= number)
		end

		self._ccbOwner["star_light_node"]:setPositionY(self._ccbOwner["bigStar"]:getPositionY() - (number - 1) * 12 - 5)
	else
		self._ccbOwner["bigNum"]:setString(number)
	end
end

return QUIWidgetEnchantStar