LoadingLayer = {}
local LAYER_TAG = 123456
local _layer
local _visible = false
local netErrorWaitingTime = 20
local init = function ()
	local _shaderLayer = CCLayerColor:create(cc.c4b(100, 100, 100, 0), display.width, display.height)
	_shaderLayer._anim = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "jiazai",
	isRetain = false,
	finishFunc = function ()
	end
	})
	
	local layer = tolua.cast(_shaderLayer,"cc.Layer")
	layer:setSwallowsTouches(true)
	layer:setTouchSwallowEnabled(true)
	layer:registerScriptTouchHandler(function (eventName, x, y)
		return true
	end)
	
	_shaderLayer._anim:setPosition(display.cx, display.cy)
	_shaderLayer:addChild(_shaderLayer._anim, 1000)
	_shaderLayer._anim:setVisible(false)
	_shaderLayer:setTouchEnabled(true)
	_shaderLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event, x, y)
		if "began" == event.name then
			return true
		end
	end,
	1)
	_shaderLayer:retain()
	_shaderLayer.tmpNode = display.newNode()
	_shaderLayer:addChild(_shaderLayer.tmpNode)
	return _shaderLayer
end
function LoadingLayer.delayCall(f)
	if _layer and _layer.tmpNode then
		_layer.tmpNode:performWithDelay(function ()
			if f then
				f()
			end
		end,
		0.001)
	elseif f then
		f()
	end
end
function LoadingLayer.start(time, timeoutFunc)
	if _layer then
		LoadingLayer.hide()
	end
	if _layer == nil then
		_layer = init()
	end
	_visible = true
	_layer:setTouchEnabled(true)
	_layer:setVisible(_visible)
	_layer.tmpNode:stopAllActions()
	local _time = time or 1.5
	_layer.tmpNode:performWithDelay(function ()
		if _visible then
			_layer._anim:setVisible(true)
		end
	end,
	tonumber(_time))
	_layer.timeoutFunc = timeoutFunc
	_layer:performWithDelay(function ()
		if _layer.timeoutFunc then
			_layer.timeoutFunc()
		end
		LoadingLayer.hide()
	end,
	netErrorWaitingTime)
	if _layer:getParent() == nil then
		_layer:setTag(LAYER_TAG)
		display.getRunningScene():addChild(_layer, TOP_LAYER_TAG + 1)
	end
	_layer:setPosition(display.cx - _layer:getContentSize().width / 2, display.cy - _layer:getContentSize().height / 2)
	return _layer
end
function LoadingLayer.hide(callback)
	if _visible then
		_visible = false
		if _layer then
			_layer:stopAllActions()
			if _layer._anim:isVisible() then
				_layer.tmpNode:stopAllActions()
				_layer._anim:setVisible(false)
			end
			_layer:setVisible(_visible)
			_layer:removeFromParentAndCleanup(false)
		end
	end
	if callback then
		callback()
	end
end

function LoadingLayer.destroy()
	if _visible then
		LoadingLayer.hide()
	end
	_layer:release()
	_layer = nil
end

return LoadingLayer