--[[--
	初始化自定义控件

	--By: yun.bo
	--2013/11/27
]]
require('TFFramework.luacomponents.common.TFBagCtrl')
require('TFFramework.luacomponents.common.TFScrollText')
require('TFFramework.luacomponents.common.TFIconLabel')
require('TFFramework.luacomponents.common.TFNPC')
require('TFFramework.luacomponents.common.TFTree')
require('TFFramework.luacomponents.common.TFBigMap')
require('TFFramework.luacomponents.common.TFTableViewEx')

function luaComponentsCopyProperties(obj, objBeCloned)
	obj:setEnabled(objBeCloned:isEnabled())
	obj:setVisible(objBeCloned:isVisible())
	obj:setBright(objBeCloned:isBright())
	obj:setTouchEnabled(objBeCloned:isTouchEnabled())
	obj:setZOrder(objBeCloned:getZOrder())
	obj:setTag(objBeCloned:getTag())
	obj:setName(objBeCloned:getName())
	obj:setSizeType(objBeCloned:getSizeType())
	obj:setSize(objBeCloned:getSize())
	obj:setSizePercent(ccp(objBeCloned:getSizePercentWidth(), objBeCloned:getSizePercentHeight()))
	obj:setPositionType(objBeCloned:getPositionType())
	obj:setPositionPercent(objBeCloned:getPositionPercent())
	obj:setPosition(objBeCloned:getPosition())
	obj:setAnchorPoint(objBeCloned:getAnchorPoint())
	obj:setScaleX(objBeCloned:getScaleX())
	obj:setScaleY(objBeCloned:getScaleY())
	obj:setRotation(objBeCloned:getRotation())
	obj:setRotationX(objBeCloned:getRotationX())
	obj:setRotationY(objBeCloned:getRotationY())
	obj:setFlipX(objBeCloned:isFlipX())
	obj:setFlipY(objBeCloned:isFlipY())
	obj:setColor(objBeCloned:getColor())
	obj:setOpacity(objBeCloned:getOpacity())
	obj:setCascadeOpacityEnabled(objBeCloned:isCascadeOpacityEnabled())
	obj:setCascadeColorEnabled(objBeCloned:isCascadeColorEnabled())

	luaComponentsCopyLayoutMsg(obj, objBeCloned)
end

function luaComponentsCopyLayoutMsg(myWidget, BeCloneWidget)
	local param
	param = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_LINEAR)
	if (param ~= nil) then
		local LinearParam = TFLinearLayoutParameter:create()
		local widgetLinear = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_LINEAR)
		LinearParam:setMargin(widgetLinear:getMargin())
		LinearParam:setGravity(widgetLinear:getGravity())
		myWidget:setLayoutParameter(LinearParam)
		param = nil
	end
	param = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
	if (param ~= nil) then
		local RelativeParam = TFRelativeLayoutParameter:create()
		local widgetRelative = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
		-- name special
		RelativeParam:setRelativeName(BeCloneWidget:getName())
		RelativeParam:setRelativeToWidgetName(widgetRelative:getRelativeToWidgetName())
		RelativeParam:setMargin(widgetRelative:getMargin())
		RelativeParam:setAlign(widgetRelative:getAlign())
		myWidget:setLayoutParameter(RelativeParam)
		param = nil
	end
	param = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_GRID)
	if (param ~= nil) then
		local RelativeParam = TFGridLayoutParameter:create()
		local widgetRelative = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_GRID)
		-- name special
		myWidget:setLayoutParameter(RelativeParam)
	end
end
