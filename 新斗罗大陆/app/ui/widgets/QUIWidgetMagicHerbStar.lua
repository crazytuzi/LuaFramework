--
-- Author: Kumo
-- 仙品养成的小星星
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbStar = class("QUIWidgetMagicHerbStar", QUIWidget)

function QUIWidgetMagicHerbStar:ctor(options)
	local ccbFile = "ccb/Widget_MagicHerb_Star.ccbi"
	local callBacks = {}
	QUIWidgetMagicHerbStar.super.ctor(self, ccbFile, callBacks, options)

	local num = 0
	if options then
		num = options.number or 0
	end
	self:setStar(num)
end

function QUIWidgetMagicHerbStar:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_light_node, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_light5, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_light4, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_light3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_light2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_light1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.bigStar, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_big, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.bigNum, self._glLayerIndex)
	return self._glLayerIndex
end

function QUIWidgetMagicHerbStar:setStar(number)
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
			QSetDisplayFrameByPath(sprite, "ui/common/one_star.png")
			self._oneWidth = sprite:getContentSize().width
			-- if i > number then
			--     makeNodeFromNormalToGray(sprite)
			-- else
			-- 	makeNodeFromGrayToNormal(sprite)
			-- end
		end
	elseif number <= 10 then
		number = number - 5
		owner.star_light_node:setVisible(true)
		owner.bigStar:setVisible(false)
		for i = 1, 5 do
			sprite = owner["star_light"..i]
			sprite:setVisible(i <= number)
			QSetDisplayFrameByPath(sprite, "ui/common/one_moon.png")
			self._oneWidth = sprite:getContentSize().width
			-- if i > number then
			--     makeNodeFromNormalToGray(sprite)
			-- else
			-- 	makeNodeFromGrayToNormal(sprite)
			-- end
		end
	elseif number <= 15 then
		number = number - 10
		owner.star_light_node:setVisible(true)
		owner.bigStar:setVisible(false)
		for i = 1, 5 do
			sprite = owner["star_light"..i]
			sprite:setVisible(i <= number)
			QSetDisplayFrameByPath(sprite, "ui/common/one_sun.png")
			self._oneWidth = sprite:getContentSize().width
			-- if i > number then
			--     makeNodeFromNormalToGray(sprite)
			-- else
			-- 	makeNodeFromGrayToNormal(sprite)
			-- end
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
		if number == 1 then
			self._ccbOwner["star_light_node"]:setPositionX(54)
		elseif number == 2 then
			self._ccbOwner["star_light_node"]:setPositionX(41)
		elseif number == 3 then
			self._ccbOwner["star_light_node"]:setPositionX(27)
		elseif number == 4 then
			self._ccbOwner["star_light_node"]:setPositionX(14)
		else
			self._ccbOwner["star_light_node"]:setPositionX(0)
		end
	else
		self._ccbOwner["bigNum"]:setString(number)
	end
end

return QUIWidgetMagicHerbStar