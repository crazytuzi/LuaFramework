--
-- zxs
-- fca播放动画
--

local QUIWidget = import("..QUIWidget")
local QSkeletonViewController = import("....controllers.QSkeletonViewController")
local QUIWidgetSkeletonEffect = import(".QUIWidgetSkeletonEffect")
local QStaticDatabase = import("....controllers.QStaticDatabase")

local QUIWidgetFcaAnimation = class("QUIWidgetFcaAnimation", QUIWidget)

QUIWidgetFcaAnimation.ANIMATION_FINISHED_EVENT = "ANIMATION_FINISHED_EVENT"

function QUIWidgetFcaAnimation:ctor(fcaFile, cat, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options == nil then options = {} end
	QUIWidgetFcaAnimation.super.ctor(self, nil, nil, options)

    -- cat = nil or res res
    -- cat = actor      res/actor
    -- cat = effect     res/effect
    self._fcaFile = string.sub(fcaFile, string.find(fcaFile, "[^/]+$"))
    if string.find(fcaFile, "fca/", 1, true) then
        if QFcaSkeletonView_cpp ~= nil and ENABLE_FCA_CPP then
            self._actorView = QFcaSkeletonView_cpp:createFcaSkeletonView(self._fcaFile, cat, true)
        else
            self._actorView = app.FcaActorCreate(self._fcaFile, cat)
        end
        self._actorView.isFca = true
    else
        local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
        self._actorView = skeletonViewController:createUISkeletonActorWithFile(fcaFile, false)
        self:attachEffectToDummy(options.backSoulShowEffect)
    end
	self:addChild(self._actorView)

    if cat == "actor" then
	    self:playAnimation(ANIMATION.STAND, true)
    else
        self:playAnimation(EFFECT_ANIMATION, true)
    end
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()
end

function QUIWidgetFcaAnimation:getSkeletonView()
    return self._actorView
end

function QUIWidgetFcaAnimation:getCurAnimation()
    return self._currentAnimation
end

function QUIWidgetFcaAnimation:setScale( scale )
    self._actorView:setScale( scale )
end

function QUIWidgetFcaAnimation:setScaleX( scaleX )
    self._actorView:setScaleX( scaleX )
end

function QUIWidgetFcaAnimation:setScaleY( scaleY )
    self._actorView:setScaleY( scaleY )
end

function QUIWidgetFcaAnimation:setOpacity( ... )
    self._actorView:setOpacity( ... )
end

function QUIWidgetFcaAnimation:setTransformColor( color )
    if self._actorView.setTransformColor then
        self._actorView:setTransformColor( color )
    end
end

function QUIWidgetFcaAnimation:resetTransformColor()
    if self._actorView.resetTransformColor then
        self._actorView:resetTransformColor()
    end
end

function QUIWidgetFcaAnimation:setEndCallback( callback )
    self._endCallback = callback
end

function QUIWidgetFcaAnimation:setAnimationScale( scale )
    self._actorView:setAnimationScale( scale )
end

function QUIWidgetFcaAnimation:onEnter()
    self._actorView:connectAnimationEventSignal(handler(self, self._onActorAnimationEvent))
end

function QUIWidgetFcaAnimation:onExit()
    self._actorView:disconnectAnimationEventSignal()
end

function QUIWidgetFcaAnimation:_onActorAnimationEvent(eventType, trackIndex, animationName, loopCount)
    if eventType == SP_ANIMATION_END then
        
    elseif eventType == SP_ANIMATION_COMPLETE then
        self:animationEnd()
    elseif eventType == SP_ANIMATION_START then
        self._currentAnimation = animationName
    end
end

function QUIWidgetFcaAnimation:animationEnd()
    if self._endCallback then
        self._endCallback()
        self._endCallback = nil
    end
end

function QUIWidgetFcaAnimation:resetAnimation()
	self._actorView:resetActorWithAnimation(ANIMATION.STAND, true)
end

function QUIWidgetFcaAnimation:pauseAnimation()
    self._actorView:pauseAnimation()
end

function QUIWidgetFcaAnimation:playAnimation(animation, isLoop)
	if animation == nil then
		return
	end

    if isLoop == nil then
        isLoop = false
    end

	if isLoop == false and (animation == ANIMATION.STAND or animation == ANIMATION.WALK) then
		isLoop = true
	end

    self._isLoop = isLoop
	self._actorView:playAnimation(animation, isLoop)
	self._currentAnimation = animation
    
    self:update(0)
end

function QUIWidgetFcaAnimation:_onFrame(dt)
    self:update(dt)
end

function QUIWidgetFcaAnimation:update(dt)
	self._actorView:update(dt)
end

function QUIWidgetFcaAnimation:attachEffectToDummy(backSoulShowEffect)
    if not backSoulShowEffect or self._actorView.isFca then return end
    
    local effectIdList = string.split(backSoulShowEffect, ";")
    for _, effectId in ipairs(effectIdList) do
        local effectView = QUIWidgetSkeletonEffect.createEffectByID(effectId, {}) 
        if effectView then
            local dummy = db:getEffectDummyByID(effectId, false)
            local bonePosition = self._actorView:getBonePosition(dummy)
            local posx, posy = effectView:getSkeletonView():getPosition()
            effectView:getSkeletonView():setPosition(bonePosition.x + posx, bonePosition.y + posy)
            effectView:playAnimation(effectView:getPlayAnimationName(), true)
            self._actorView:attachNodeToBone(dummy, effectView, false, true)
        end
    end
end

return QUIWidgetFcaAnimation