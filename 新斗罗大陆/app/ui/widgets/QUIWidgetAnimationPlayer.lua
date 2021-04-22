--
-- Author: wkwang
-- Date: 2014-10-10 18:29:18
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetAnimationPlayer = class("QUIWidgetAnimationPlayer", QUIWidget)

function QUIWidgetAnimationPlayer:ctor(options)
	QUIWidgetAnimationPlayer.super.ctor(self, nil, nil, options)
end

function QUIWidgetAnimationPlayer:onExit()
    QUIWidgetAnimationPlayer.super.onExit(self)
    self:stopAnimation()
end

function QUIWidgetAnimationPlayer:playAnimation(ccbFile, playPreCall, playEndCall, isAutoDisappear, name)
	local proxy = CCBProxy:create()
    if self._ccbView ~= nil then
        self:disappear()
    end
    if isAutoDisappear == nil then
        isAutoDisappear = true
    end
    self.isAutoDisappear = isAutoDisappear
	self._ccbOwner = {}
    self._ccbView = CCBuilderReaderLoad(ccbFile, proxy, self._ccbOwner)
    self:addChild(self._ccbView)
    if playPreCall ~= nil then
    	playPreCall(self._ccbOwner, self._ccbView)
    end
    self._playEndCall = playEndCall
    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
    self._animationManager:connectScriptHandler(function(name)
        if self.isAutoDisappear == true then
            self:disappear()
        end
        if self._playEndCall ~= nil then
            local playCall = self._playEndCall
            self._playEndCall = nil
            playCall()
        end
    end)
    if name ~= nil then
        self._animationManager:runAnimationsForSequenceNamed(name)
    end

    return self._ccbOwner
end

function QUIWidgetAnimationPlayer:playAnimation2(ccbView, ccbOwner, playPreCall, playEndCall, isAutoDisappear, name)
    local proxy = CCBProxy:create()
    if self._ccbView ~= nil then
        self:disappear()
    end
    if isAutoDisappear == nil then
        isAutoDisappear = true
    end
    self.isAutoDisappear = isAutoDisappear
    self._ccbOwner = ccbOwner
    self._ccbView = ccbView
    self:addChild(self._ccbView)
    if playPreCall ~= nil then
        playPreCall(self._ccbOwner, self._ccbView)
    end
    self._playEndCall = playEndCall
    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
    self._animationManager:connectScriptHandler(function(name)
        if self.isAutoDisappear == true then
            self:disappear()
        end
        if self._playEndCall ~= nil then
            self._playEndCall()
            self._playEndCall = nil
        end
    end)
    if name ~= nil then
        self._animationManager:runAnimationsForSequenceNamed(name)
    end
end

function QUIWidgetAnimationPlayer:playByName(name, playPreCall, playEndCall, isAutoDisappear)
    if playPreCall ~= nil then
        playPreCall(self._ccbOwner, self._ccbView)
    end
    if playEndCall ~= nil then
        self._playEndCall = playEndCall
    end
    if isAutoDisappear ~= nil then
        self.isAutoDisappear = isAutoDisappear
    end
    if self._animationManager ~= nil then
        self._animationManager:runAnimationsForSequenceNamed(name)
    end
end

function QUIWidgetAnimationPlayer:stopAnimation()
    if self._animationManager then
        self._animationManager:stopAnimation()
        self:disappear()
    end
end

function QUIWidgetAnimationPlayer:pauseAnimation()
	if self._animationManager then
        self._animationManager:pauseAnimation()
    end
end

function QUIWidgetAnimationPlayer:resumeAnimation()
    if self._animationManager then
        self._animationManager:resumeAnimation()
    end
end

function QUIWidgetAnimationPlayer:disappear()
    if self._ccbView ~= nil then
        self:removeChild(self._ccbView, true)
        self._ccbOwner = nil
        self._ccbView = nil
        self._animationManager = nil
    end
end

return QUIWidgetAnimationPlayer