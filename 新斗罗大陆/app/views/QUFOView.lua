local QUFOView = class("QUFOView", function()
    return display.newNode()
end)

local QBaseEffectView = import(".QBaseEffectView")

function QUFOView:ctor(ufo, params)
	self._ufo = ufo
	self._viewNode = QBaseEffectView.createEffectByID(params.effectID, nil, nil, params)
	self:addChild(self._viewNode)
	self._ufo:setViewDelegate(self:_createDelegate())
end

function QUFOView:_createDelegate()
	local view = self
	local delegate = {}
	function delegate:release()
		if view._viewNode then
			view._viewNode:removeFromParent()
			view._viewNode = nil
		end
	end
	function delegate:setPosition(x, y)
		view:setPosition(ccp(x, y))
	end
	function delegate:setDirection(direction)
		view:setScaleX(direction)
	end
	function delegate:playAnimation()
		view:playAnimation()
	end
	return delegate
end

function QUFOView:onCleanup()
	if self._viewNode then
		self._viewNode:removeFromParent()
		self._viewNode = nil
	end
end

function QUFOView:playAnimation()
	if self._viewNode then
		self._viewNode:playAnimation(self._viewNode:getPlayAnimationName(), true)
	end
end

return QUFOView
