
local QUIWidget = import(".QUIWidget")
local QUIWidgetLoginAvata = class("QUIWidgetLoginAvata", QUIWidget)

local QSkeletonViewController = import("...controllers.QSkeletonViewController")

function QUIWidgetLoginAvata:ctor(options)
	QUIWidgetLoginAvata.super.ctor(self, nil, nil, options)

	self._rootNode = CCNode:create()
	self:addChild(self._rootNode)
	self._rootNode:setPosition(0, 0)
	
	------------------------------------------
	if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "whjx_239" then
		self._aosika_view = self:_createActor("yueguan", "animation", 290, 10, self._rootNode)
	else
		self._aosika_view = self:_createActor("yueguan", "animation", 230, 10, self._rootNode)
    end
	self._aosika_view:setScale(1)

	self._aosika_view = self:_createActor("huliena", "animation", 360, -140, self._rootNode)
	self._aosika_view:setScale(1)

	self._daimubai_view = self:_createActor("qianrenxue", "animation", 205, -430, self._rootNode)
	self._daimubai_view:setScale(1)


	
	if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "whjx_239" then
		self._aosika_view = self:_createActor("dengrujiemian_mahongjun", "stand", -240, -70, self._rootNode)
	else
		self._aosika_view = self:_createActor("dengrujiemian_mahongjun", "stand", -180, -70, self._rootNode)
    end
	self._aosika_view:setScale(1)

	self._aosika_view = self:_createActor("dengrujiemian_xiaowu", "stand", -330, -100, self._rootNode)
	self._aosika_view:setScale(1)

	self._aosika_view = self:_createActor("dengrujiemian_tangsan", "animation", -170, -420, self._rootNode)
	self._aosika_view:setScale(1)
end

function QUIWidgetLoginAvata:_createActor(file, animation, x, y, parent)
	local actorView = QSkeletonActor:create(file)
	if parent then
		parent:addChild(actorView)
	end
	actorView:setPosition(x, y)
	actorView:playAnimation(animation, true)
	return actorView
end

function QUIWidgetLoginAvata:_createEffect(file, x, y, parent)
	local effectView = QSkeletonView:create(file)
	if parent then
		parent:addChild(effectView)
	end
	effectView:setPosition(x, y)
	effectView:playAnimation("animation", true)
	return effectView
end

function QUIWidgetLoginAvata:onCleanup()
	scheduler.performWithDelayGlobal(function()
		app:cleanTextureCache()
	end, 0)
end

return QUIWidgetLoginAvata