
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMaskLayer = class("QUIWidgetMaskLayer", QUIWidget)

function QUIWidgetMaskLayer:ctor(options)
	QUIWidgetMaskLayer.super.ctor(self, nil, nil, options)
	self._layers = {}
	table.insert(self._layers, self:createLayer())
	table.insert(self._layers, self:createLayer())
	table.insert(self._layers, self:createLayer())
	table.insert(self._layers, self:createLayer())
end

function QUIWidgetMaskLayer:createLayer()
	local layer = CCLayerColor:create(ccc4(0,0,0,0), 1, 1)
	self:addChild(layer)
	return layer
end

function QUIWidgetMaskLayer:getPic()
	if nil == self.pic then
		self.pic = CCSprite:create()
		self:addChild(self.pic)
	end
	return self.pic
end

function QUIWidgetMaskLayer:setLayerColor(ccolor3)
	for _,layer in ipairs(self._layers) do
		layer:setColor(ccolor3)
	end
end

function QUIWidgetMaskLayer:setOpacity(a)
	for _,layer in ipairs(self._layers) do
		layer:setOpacity(a)
	end
end

function QUIWidgetMaskLayer:changeWidthAndHeight(layer, width, height)
	if width < 0 then
		width = 0
	end
	if height < 0 then
		height = 0
	end
	layer:changeWidthAndHeight(width, height)
end

function QUIWidgetMaskLayer:setPicSize(Size_width, Size_height , posX,posY)
	posX = math.floor(posX)
	posY = math.floor(posY)
	local picSize = {width = Size_width, height = Size_height}

	local topY = posY + picSize.height/2
	local bottomY = posY - picSize.height/2
	local rightX = posX + picSize.width/2
	local leftX = posX - picSize.width/2

	local layerTop = self._layers[1]
	self:changeWidthAndHeight(layerTop, display.width, display.height - topY)
	layerTop:setPosition(0, topY)

	local layerBottom = self._layers[2]
	self:changeWidthAndHeight(layerBottom, display.width, bottomY)
	layerBottom:setPosition(0, 0)

	local layerRight = self._layers[3]
	self:changeWidthAndHeight(layerRight, display.width - rightX, picSize.height)
	layerRight:setPosition(rightX, bottomY)

	local layerLeft = self._layers[4]
	self:changeWidthAndHeight(layerLeft, leftX, picSize.height)
	layerLeft:setPosition(0, bottomY)
	
end


function QUIWidgetMaskLayer:setPic(picPath, posX, posY)
	posX = math.floor(posX)
	posY = math.floor(posY)
	local picSize = {width = 0, height = 0}
	if picPath then
		local pic = self:getPic()
		self.pic:setTexture(CCTextureCache:sharedTextureCache():addImage(picPath))
		self.pic:setPosition(posX, posY)
		picSize = pic:getContentSize()
	end

	local topY = posY + picSize.height/2
	local bottomY = posY - picSize.height/2
	local rightX = posX + picSize.width/2
	local leftX = posX - picSize.width/2

	local layerTop = self._layers[1]
	self:changeWidthAndHeight(layerTop, display.width, display.height - topY)
	layerTop:setPosition(0, topY)

	local layerBottom = self._layers[2]
	self:changeWidthAndHeight(layerBottom, display.width, bottomY)
	layerBottom:setPosition(0, 0)

	local layerRight = self._layers[3]
	self:changeWidthAndHeight(layerRight, display.width - rightX, picSize.height)
	layerRight:setPosition(rightX, bottomY)

	local layerLeft = self._layers[4]
	self:changeWidthAndHeight(layerLeft, leftX, picSize.height)
	layerLeft:setPosition(0, bottomY)
end

return QUIWidgetMaskLayer