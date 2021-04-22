
local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroHeadSketch = class("QUIWidgetHeroHeadSketch", QUIWidget)

function QUIWidgetHeroHeadSketch:ctor(options)
	local ccbFile = "ccb/Widget_HeroHead_Sketch.ccbi"
	local callBacks = {}
	QUIWidgetHeroHeadSketch.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end
 
function QUIWidgetHeroHeadSketch:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_head_sketch, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_frame, self._glLayerIndex)

	return self._glLayerIndex
end

function QUIWidgetHeroHeadSketch:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetHeroHeadSketch:getHeroSprite()
	return self._ccbOwner.sp_head_sketch
end

return QUIWidgetHeroHeadSketch
