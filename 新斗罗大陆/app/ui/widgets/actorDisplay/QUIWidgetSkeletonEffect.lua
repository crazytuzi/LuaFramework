

local QUIWidget = import("..QUIWidget")
local QUIWidgetSkeletonEffect = class("QUIWidgetSkeletonEffect", QUIWidget)

local QSoundEffect = import("....utils.QSoundEffect")
local QSkeletonViewController = import("....controllers.QSkeletonViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")

function QUIWidgetSkeletonEffect.createEffectByID(effectID, options)
    if effectID == nil then
        return nil
    end

    if options == nil then
        options = {}
    end

    if options.time_scale then
        delayTime = delayTime * options.time_scale
    end

    local dataBase = QStaticDatabase.sharedDatabase()
    local frontEffectFile, backEffectFile = dataBase:getEffectFileByID(effectID)
    local soundId = dataBase:getEffectSoundIdById(effectID)
    local soundStop = dataBase:getEffectSoundStopByID(effectID)
    local delayTime = (dataBase:getEffectDelayByID(effectID) or 0)
    local config = dataBase:getEffectConfigByID(effectID)

    local externalScale = options.externalScale or 1
    local externalRotate = options.externalRotate or 0

    local frontEffectView = nil
    if frontEffectFile ~= nil or (backEffectFile == nil and soundId ~= nil) then
        frontEffectView = QUIWidgetSkeletonEffect.new(frontEffectFile, soundId, soundStop, {delay = delayTime, animation = config.animation})
    end

    local backEffectView = nil
    if backEffectFile ~= nil then
        if frontEffectView ~= nil then
            backEffectView = QUIWidgetSkeletonEffect.new(backEffectFile, nil, soundStop, {delay = delayTime, animation = config.animation})
        else
            backEffectView = QUIWidgetSkeletonEffect.new(backEffectFile, soundId, soundStop, {delay = delayTime, animation = config.animation})
        end
    end

    local scale = dataBase:getEffectScaleByID(effectID)
    local playSpeed = dataBase:getEffectPlaySpeedByID(effectID)
    local rotation = dataBase:getEffectRotationByID(effectID)
    local config = dataBase:getEffectConfigByID(effectID)
    local filp = 1
    if config.filp then filp = -1 end

    if frontEffectView ~= nil and frontEffectView:getSkeletonView() ~= nil then
        frontEffectView:getSkeletonView():setSkeletonScaleX(scale * externalScale * filp)
        frontEffectView:getSkeletonView():setSkeletonScaleY(scale * externalScale)
        frontEffectView:getSkeletonView():setAnimationScaleOriginal(playSpeed)
        frontEffectView:getSkeletonView():setPosition(dataBase:getEffectOffsetByID(effectID))
        frontEffectView:getSkeletonView():setRotation(rotation + externalRotate)
    end

    if backEffectView ~= nil and backEffectView:getSkeletonView() ~= nil then
        backEffectView:getSkeletonView():setSkeletonScaleX(scale * externalScale * filp)
        backEffectView:getSkeletonView():setSkeletonScaleY(scale * externalScale)
        backEffectView:getSkeletonView():setAnimationScaleOriginal(playSpeed)
        backEffectView:getSkeletonView():setPosition(dataBase:getEffectOffsetByID(effectID))
        backEffectView:getSkeletonView():setRotation(rotation + externalRotate)
    end

    -- use for print log
    if frontEffectView then
        frontEffectView._effectID = effectID
        frontEffectView._frontAndBack = "front"
    end
    if backEffectView then
        backEffectView._effectID = effectID
        backEffectView._frontAndBack = "back"
    end

    -- hsi
    local config = dataBase:getEffectConfigByID(effectID)
    if config and config.is_hsi_enabled then
        local hue = config.hue or 0
        local saturation = config.saturation or 0
        local intensity = config.intensity or 0
        hue = math.floor((hue + 180) / 360 * 255)
        saturation = (saturation + 1.0) / 2 * 255
        intensity = (intensity + 1.9) / 2 * 255
        if QSkeletonView.setColor2 then
            if frontEffectView then
                setNodeShaderProgram(frontEffectView:getSkeletonView():getSkeletonAnimation(), qShader.Q_ProgramPositionTextureColorHSI)
                frontEffectView:getSkeletonView():setColor2(ccc4(hue, saturation, intensity, 0))
            end
            if backEffectView then
                setNodeShaderProgram(backEffectView:getSkeletonView():getSkeletonAnimation(), qShader.Q_ProgramPositionTextureColorHSI)
                frontEffectView:getSkeletonView():setColor2(ccc4(hue, saturation, intensity, 0))
            end
        else
            -- backward compatible
            if frontEffectView then
                if config.render_as_whole then
                    frontEffectView:setScissorRects(
                        CCRect(0, 0, 0, 0),
                        CCRect(0, 0, 0, 0),
                        CCRect(0, 0, 0, 0),
                        CCRect(0, 0, 0, 0)
                    )
                    frontEffectView:setScissorEnabled(true)
                    frontEffectView:getSkeletonView():getRenderTextureSprite():setColor(ccc3(hue, saturation, intensity))
                    frontEffectView:getSkeletonView():getRenderTextureSprite():setShaderProgram(qShader.Q_ProgramPositionTextureHSI)
                else
                    setNodeShaderProgram(frontEffectView:getSkeletonView():getSkeletonAnimation(), qShader.Q_ProgramPositionTextureHSI)
                    makeNodeColor(frontEffectView:getSkeletonView(), ccc3(hue, saturation, intensity))
                end
            end
            if backEffectView then
                if config.render_as_whole then
                    backEffectView:setScissorRects(
                        CCRect(0, 0, 0, 0),
                        CCRect(0, 0, 0, 0),
                        CCRect(0, 0, 0, 0),
                        CCRect(0, 0, 0, 0)
                    )
                    backEffectView:setScissorEnabled(true)
                    backEffectView:getSkeletonView():getRenderTextureSprite():setColor(ccc3(hue, saturation, intensity))
                    backEffectView:getSkeletonView():getRenderTextureSprite():setShaderProgram(qShader.Q_ProgramPositionTextureHSI)
                else
                    setNodeShaderProgram(backEffectView:getSkeletonView():getSkeletonAnimation(), qShader.Q_ProgramPositionTextureHSI)
                    makeNodeColor(backEffectView:getSkeletonView(), ccc3(hue, saturation, intensity))
                end
            end
        end
    end

    return frontEffectView, backEffectView
end

function QUIWidgetSkeletonEffect:ctor(effectFile, audioId, audioStop, options)
    if effectFile ~= nil then
        local effectScale = 1.0
        if options == nil then
            options = {}
        end
        if options.scale ~= nil then
            effectScale = options.scale
        end
        
        local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
        self._skeletonEffect = skeletonViewController:createSkeletonEffectWithFile(effectFile, nil, nil, false)
        self._skeletonEffect:setScale(effectScale)

        if options.offsetX ~= nil and options.offsetY ~= nil then
            self._skeletonEffect:setPosition(ccp(options.offsetX, options.offsetY))
        end

        self._delayTime = 0
        if options.delay ~= nil then
            self._delayTime = options.delay
        end

        self:addChild(self._skeletonEffect)
        self._skeletonEffect:setVisible(false)
    end

    self._audioEffect = nil
    if audioId ~= nil then
        self._audioEffect = QSoundEffect.new(audioId)
    end

    if options.animation == nil then
        self._animation = EFFECT_ANIMATION
    else
        self._animation = options.animation
        if  self._skeletonEffect.canPlayAnimation and not self._skeletonEffect:canPlayAnimation(self._animation) then
            SafeAssert(false,effectFile.. " can not find animation named: " .. self._animation)
        end
    end

    self._audioStop = audioStop
    self._isRunDelayAction = false
    self._isStoped = true

    self:setNodeEventEnabled(true)
end

function QUIWidgetSkeletonEffect:getSkeletonView()
    return self._skeletonEffect
end

function QUIWidgetSkeletonEffect:playAnimation(name, isLoop)
    if self._skeletonEffect == nil or name == nil then
        return
    end
    
    if isLoop == nil then
        isLoop = false
    end

    if self._delayTime > 0 then
        self._isRunDelayAction = true

        local array = CCArray:create()
        array:addObject(CCDelayTime:create(self._delayTime))
        array:addObject(CCCallFunc:create(function()
        	self:_doPlayAnimation(name, isLoop)
        	if self._callFunc ~= nil then
        		self._callFunc(self._callFuncParam)
        	end
        end))
        self:runAction(CCSequence:create(array))
    else
        self:_doPlayAnimation(name, isLoop)
    end

    if self._frameId == nil then
        self._frameId = scheduler.scheduleUpdateGlobal(handler(self, self._onFrame))
    end

    -- self._animationName = name
    -- self._isLoop = isLoop
    self._isStoped = false
end

function QUIWidgetSkeletonEffect:_doPlayAnimation(name, isLoop)
    if self._skeletonEffect == nil then
        return
    end

    self._skeletonEffect:setVisible(true)
    if self._skeletonEffect:playAnimation(name, isLoop) == false then
        --printInfo(self._animationFile .. " can not find animation named: " .. name)
    end
end

function QUIWidgetSkeletonEffect:afterAnimationComplete(callback)
    if self._isRunDelayAction == true then
        self._callFunc = handler(self, self._doAfterAnimationComplete)
        self._callFuncParam = callback;
    else
        self:_doAfterAnimationComplete(callback)
    end
end

function QUIWidgetSkeletonEffect:_doAfterAnimationComplete(callback)
    if self._skeletonEffect == nil then
        self._isStoped = true
        callback()
        return
    end

    self._skeletonEffect:connectAnimationEventSignal(function(eventType, trackIndex, animationName, loopCount)
        if eventType == SP_ANIMATION_COMPLETE then
            self._skeletonEffect:disconnectAnimationEventSignal()
            self._isStoped = true
            if self._audioStop then
                self:stopSoundEffect()
            end
            callback()
        end
    end)
end

function QUIWidgetSkeletonEffect:stopAnimation()
    if self._isRunDelayAction == true then
        self:stopAllActions()
    else
        if self._skeletonEffect ~= nil then
            self._skeletonEffect:disconnectAnimationEventSignal()
            self._skeletonEffect:stopAnimation()
        end
    end
    
    if self._audioStop then
        self:stopSoundEffect()
    end
    self._isStoped = true
end

function QUIWidgetSkeletonEffect:playSoundEffect(loop)
    if self._audioEffect ~= nil then
        self._audioEffect:play(loop)
    end
end

function QUIWidgetSkeletonEffect:stopSoundEffect()
    if self._audioEffect ~= nil then
        self._audioEffect:stop()
    end
end

function QUIWidgetSkeletonEffect:onExit()
    if self._frameId then
        scheduler.unscheduleGlobal(self._frameId)
        self._frameId = nil
    end
end

function QUIWidgetSkeletonEffect:onCleanup()
    local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
    skeletonViewController:removeSkeletonEffect(self._skeletonEffect)
end

function QUIWidgetSkeletonEffect:_onFrame(dt)
    if self._isStoped == true then
        return
    end

    if self._skeletonEffect and self._skeletonEffect.isFca then
        self._skeletonEffect:updateAnimation(dt)
    end
end

function QUIWidgetSkeletonEffect:setOpacity(opacity)
    CCNode.setOpacity(self, opacity)
    self._skeletonEffect:setOpacity(opacity)
end

function QUIWidgetSkeletonEffect:getPlayAnimationName()
    return self._animation
end

return QUIWidgetSkeletonEffect