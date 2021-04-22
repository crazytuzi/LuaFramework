--[[
    Class name QBaseEffectView 
    Create by julian 
    This class is a base class of effect.
    Other effect class is inherit from this.
--]]
local QBaseEffectView = class("QBaseEffectView", function()
    return display.newNode()
end)

local QSoundEffect = import("..utils.QSoundEffect")
local QSkeletonViewController = import("..controllers.QSkeletonViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")

QBaseEffectView.CHILD_TAG_CLIP = 0

function QBaseEffectView.createEffectByID(effectID, attachedActorView, effectClass, options)
    if effectID == nil then
        return nil
    end

    if effectClass == nil then
        effectClass = QBaseEffectView
    end

    if options == nil then
        options = {}
    end

    local dataBase = QStaticDatabase.sharedDatabase()
    local frontEffectFile, backEffectFile = dataBase:getEffectFileByID(effectID)
    local soundId = dataBase:getEffectSoundIdById(effectID)
    local soundStop = dataBase:getEffectSoundStopByID(effectID)
    local delayTime = (dataBase:getEffectDelayByID(effectID) or 0)
    local config = dataBase:getEffectConfigByID(effectID)

    if options.time_scale then
        delayTime = delayTime * options.time_scale
    end

    local externalScale = options.externalScale or 1
    local externalRotate = options.externalRotate or 0

    local frontEffectView = nil
    if frontEffectFile ~= nil or (backEffectFile == nil and soundId ~= nil) then
        frontEffectView = effectClass.new(frontEffectFile, soundId, soundStop, {delay = delayTime, actorView = attachedActorView,
            sizeRenderTexture = options.size_render_texture, ignore_animation_scale = options.ignore_animation_scale or config.ignore_animation_scale, animation = config.animation})
    end

    local backEffectView = nil
    if backEffectFile ~= nil then
        local soundId__ = soundId
        if frontEffectView ~= nil then
            soundId__ = nil
        end
        backEffectView = effectClass.new(backEffectFile, soundId__, soundStop, {delay = delayTime, actorView = attachedActorView,
            sizeRenderTexture = options.size_render_texture, ignore_animation_scale = options.ignore_animation_scale or config.ignore_animation_scale, animation = config.animation})
    end

    local scale = dataBase:getEffectScaleByID(effectID)
    local playSpeed = dataBase:getEffectPlaySpeedByID(effectID)
    local rotation = options.rotation or dataBase:getEffectRotationByID(effectID)
    local filp = 1
    if config.filp then filp = -1 end

    if frontEffectView ~= nil and frontEffectView:getSkeletonView() ~= nil then
        local skeletonView = frontEffectView:getSkeletonView()
        skeletonView:setSkeletonScaleX(scale * externalScale * filp)
        skeletonView:setSkeletonScaleY(scale * externalScale)
        if skeletonView.isFca then
            skeletonView:setAnimationScale(playSpeed)
        else
            skeletonView:setAnimationScaleOriginal(playSpeed)
        end
        skeletonView:setPosition(dataBase:getEffectOffsetByID(effectID))
        skeletonView:setRotation(rotation + externalRotate)
        local effectConfig = dataBase:getEffectConfigByID(effectID)
    end

    if backEffectView ~= nil and backEffectView:getSkeletonView() ~= nil then
        local skeletonView = backEffectView:getSkeletonView()
        skeletonView:setSkeletonScaleX(scale * externalScale * filp)
        skeletonView:setSkeletonScaleY(scale * externalScale)
        if skeletonView.isFca then
            skeletonView:setAnimationScale(playSpeed)
        else
            skeletonView:setAnimationScaleOriginal(playSpeed)
        end
        skeletonView:setPosition(dataBase:getEffectOffsetByID(effectID))
        skeletonView:setRotation(rotation + externalRotate)
        local effectConfig = dataBase:getEffectConfigByID(effectID)
    end

    -- use for print log
    if frontEffectView then
        frontEffectView._effectID = effectID
        frontEffectView._frontAndBack = "front"
        frontEffectView._configScale = scale
        frontEffectView._isCalcOffset = config.is_calc_offset
    end
    if backEffectView then
        backEffectView._effectID = effectID
        backEffectView._frontAndBack = "back"
        backEffectView._configScale = scale
        backEffectView._isCalcOffset = config.is_calc_offset
    end

    if frontEffectView == nil and backEffectView == nil and soundId ~= nil then
        frontEffectView = effectClass.new(nil, soundId, soundStop, {delay = delayTime, actorView = attachedActorView})
    end

    -- hsi
    if config then
        if frontEffectView then
            frontEffectView._dummy_as_position = config.dummy_as_position
        end
        if backEffectView then
            backEffectView._dummy_as_position = config.dummy_as_position
        end
    end

    if config and config.is_hsi_enabled then
        local hue = config.hue or 0
        local saturation = config.saturation or 0
        local intensity = config.intensity or 0
        hue = math.floor((hue + 180) / 360 * 255)
        saturation = (saturation + 1.0) / 2 * 255
        intensity = (intensity + 1.0) / 2 * 255
        if QSkeletonView.setColor2 then
            if frontEffectView then
                setNodeShaderProgram(frontEffectView:getSkeletonView():getSkeletonAnimation(), qShader.Q_ProgramPositionTextureColorHSI)
                frontEffectView:getSkeletonView():setColor2(ccc4(hue, saturation, intensity, 0))
            end
            if backEffectView then
                setNodeShaderProgram(backEffectView:getSkeletonView():getSkeletonAnimation(), qShader.Q_ProgramPositionTextureColorHSI)
                backEffectView:getSkeletonView():setColor2(ccc4(hue, saturation, intensity, 0))
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

function QBaseEffectView.createCombinedEffectByID(effectID, attachedActorView, effectClass, options)
    local front, back = QBaseEffectView.createEffectByID(effectID, attachedActorView, effectClass, options)

    if front and back then
        front:addChild(back, -1)
        function front:playAnimation(name, isLoop, isReplace)
            QBaseEffectView.playAnimation(self, name, isLoop, isReplace)
            back:playAnimation(name, isLoop, isReplace)
        end
        function front:stopAnimation()
            QBaseEffectView.playAnimation(self)
            back:playAnimation()
        end
        return front
    else
        return front, back
    end
end

function QBaseEffectView:ctor(effectFile, audioId, audioStop, options)
    if effectFile ~= nil then
        local effectScale = 1.0
        if options == nil then
            options = {}
        end
        if options.scale ~= nil then
            effectScale = options.scale
        end
        
        self._animationFile = effectFile .. ".json"
        local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
        self._skeletonView = skeletonViewController:createSkeletonEffectWithFile(effectFile, options.actorView, options.sizeRenderTexture)
        local _self = self
        function self._skeletonView:getFollowActor()
            if _self.getFollowActor == nil then
                return nil
            end
            return _self:getFollowActor()
        end
        self._skeletonView:setScale(effectScale)

        if options.offsetX ~= nil and options.offsetY ~= nil then
            self._skeletonView:setPosition(ccp(options.offsetX, options.offsetY))
        end

        self._delayTime = 0
        if options.delay ~= nil then
            self._delayTime = options.delay
        end

        self:addChild(self._skeletonView:getNode())
        self._skeletonView:setVisible(false)
    end

    if options.animation == nil then
        self._animation = EFFECT_ANIMATION
    else
        self._animation = options.animation
    end

    self._audioEffect = nil
    if audioId ~= nil then
        self._audioEffect = QSoundEffect.new(audioId, {isInBattle = true, effectDelay = self._delayTime})
    end
    self._audioStop = audioStop
    self._isRunDelayAction = false
    self._isStoped = true
    self._ignoreAnimationScale = options.ignore_animation_scale
    self:setNodeEventEnabled(true)

    self._sizeScaleXs = {}
    self._sizeScaleYs = {}

    -- makeNodeColor(self._skeletonView, ccc3(0, 0, 255))
    -- self:setScissorRects(
    --         CCRect(0, 0, 0, 0),
    --         CCRect(0, 0, 0, 0),
    --         CCRect(0, 0, 0, 0),
    --         CCRect(0, 0, 0, 0))
    -- self:setScissorEnabled(true)
    -- self:setScissorColor(ccc3(0, 0, 255))
end

function QBaseEffectView:getSkeletonView()
    return self._skeletonView
end

function QBaseEffectView:onEnter()
    
end

function QBaseEffectView:onExit()
    if self._frameId then
        scheduler.unscheduleGlobal(self._frameId)
        self._frameId = nil
    end
end

function QBaseEffectView:onCleanup()
    if self._skeletonView ~= nil then
        QSkeletonViewController.sharedSkeletonViewController():removeSkeletonEffect(self._skeletonView)
    end
end

function QBaseEffectView:_onFrame(dt)
    if self._isStoped == true or app.battle == nil or type(self._lastTime) ~= "number" then
        return
    end

    local deltaTime
    if self._ignoreAnimationScale then
        deltaTime = dt
        self._timePassed = self._timePassed + deltaTime
        self._skeletonView:setAnimationScale(1.0)
    else
        local currentTime = app.battle:getTimeForEffect()
        deltaTime = currentTime - self._lastTime
        local scale = 1.0
        if self._skeletonView ~= nil then
            scale = self._skeletonView:getAnimationScale()
        end
        self._timePassed = self._timePassed + deltaTime * scale
        self._lastTime = currentTime

        if deltaTime == 0 and app.battle:isPausedBetweenWave() then
            deltaTime = dt
        end
    end

    if self._isRunDelayAction == true then
        if self._timePassed > self._delayTime then
            self._isRunDelayAction = false
            self._skeletonView:setVisible(true)
            self:_doPlayAnimation(self._animationName, self._isLoop)
            self:_doAnimationEventSignal()
        else
            return
        end
    else
        local skeletonView = self._skeletonView
        if skeletonView ~= nil and (not self._followActor or (not self._followActor:isInTimeStop() and not self._followActor:isInBulletTime()))then
            if app.battle:isInArena() then
                local actorView = self._actorView
                if not actorView or not actorView.getModel then
                    skeletonView:updateAnimation(deltaTime)
                elseif app.battle:getShowActor() == nil or app.battle:getShowActor() == actorView:getModel() then
                    skeletonView:updateAnimation(deltaTime)
                end
            else
                skeletonView:updateAnimation(deltaTime)
            end
        end
        if self._positionActor then
            local done = false
            local id = self._effectID
            if id then
                local config = db:getEffectConfigByID(id)
                if config then
                    if config.dummy_as_position then
                        local view = app.scene:getActorViewFromModel(self._positionActor)
                        if view and view.getBonePosition and view:getSkeletonActor():isBoneExist(config.dummy) then
                            local local_pos = view:getBonePosition(config.dummy)
                            local scene_pos = self._positionActor:getPosition()
                            self:setPosition(ccp(scene_pos.x, scene_pos.y))
                            self._skeletonView:setPosition(ccp(local_pos.x, local_pos.y))
                            done = true
                        end
                    end
                end
            end
            if not done then
                local pos = self._positionActor:getPosition()
                self:setPosition(ccp(pos.x, pos.y))       
                done = true
            end
        end
        if self._follow_scale_actor then
            local view = app.scene:getActorViewFromModel(self._follow_scale_actor)
            if view and view._skeletonActor.isFca then
                self:setSizeScale(view._skeletonActor:getRootScale(), self._follow_scale_actor)
            end
        end
    end

end

function QBaseEffectView:isRunDelayAction()
    return self._isRunDelayAction
end

function QBaseEffectView:playAnimation(name, isLoop, isReplace)
    if self._skeletonView == nil then
        return
    end

    if name == nil then
        return
    end
    
    if isLoop == nil then
        isLoop = false
    end

    if self._delayTime > 0 then
        self._isRunDelayAction = true
        self._skeletonView:setVisible(false)
    else
        self:_doPlayAnimation(name, isLoop)
    end
    self._animationName = name
    self._isLoop = isLoop
    self._lastTime = app.battle:getTimeForEffect()
    self._timePassed = 0
    self._isStoped = false
    self._isReplace = isReplace

    if self._frameId == nil then
        self._frameId = scheduler.scheduleUpdateGlobal(handler(self, self._onFrame))
    end
end

function QBaseEffectView:_doPlayAnimation(name, isLoop)
    if self._skeletonView == nil then
        return
    end

    self._skeletonView:setVisible(true)
    if self._skeletonView:playAnimation(name, isLoop) == false then
        printInfo(self._animationFile .. " can not find animation named: " .. name)
    end
    if self._skeletonView.isFca and self._skeletonView.skipFirstFrame then
        self._skeletonView:skipFirstFrame()
    end
    self._skeletonView:pauseAnimation()
end

function QBaseEffectView:stopAnimation()
    if self._isRunDelayAction == true then
        if self._callFuncParam ~= nil then
            self._callFuncParam()
        end
    else
        if self._skeletonView ~= nil then
            self._skeletonView:disconnectAnimationEventSignal()
            self._skeletonView:stopAnimation()
            if self._func ~= nil then
                self._func()
            end
        end
    end
    
    if self._audioStop then
        self:stopSoundEffect()
    end
    self._isStoped = true
end

function QBaseEffectView:_doAnimationEventSignal()
    if self._callFunc == nil then
        return
    end

    if self._callFuncParam == nil then
        local func = self._callFunc
        func()
    else
        local func = self._callFunc
        func(self._callFuncParam)
    end

    self._callFunc = nil
    self._callFuncParam = nil;
end

function QBaseEffectView:removeSelfAfterAnimationComplete()
    if self._isRunDelayAction == true then
        self._callFunc = handler(self, self._doRemoveSelfAfterAnimationComplete)
        self._callFuncParam = nil;
    else
        self:_doRemoveSelfAfterAnimationComplete()
    end
end

function QBaseEffectView:_doRemoveSelfAfterAnimationComplete()
    if self._skeletonView == nil then
        return
    end

    self._skeletonView:connectAnimationEventSignal(function(eventType, trackIndex, animationName, loopCount)
        if eventType == SP_ANIMATION_COMPLETE then
            self._skeletonView:disconnectAnimationEventSignal()
            self._isStoped = true
            if self._audioStop then
                self:stopSoundEffect()
            end
            app.battle:performWithDelay(function()
                self:removeFromParent()
            end, 0)
            
        end
    end)
end

function QBaseEffectView:afterAnimationComplete(func)
    if self._isRunDelayAction == true then
        self._callFunc = handler(self, self._doAfterAnimationComplete)
        self._callFuncParam = func;
    else
        self:_doAfterAnimationComplete(func)
    end
end

function QBaseEffectView:_doAfterAnimationComplete(func)
    if func == nil then
        return
    end

    if self._skeletonView == nil then
        self._isStoped = true
        if func ~= nil then
            func()
        end
        return
    end

    self._func = func

    self._skeletonView:connectAnimationEventSignal(function(eventType, trackIndex, animationName, loopCount)
        if eventType == SP_ANIMATION_COMPLETE then
            self._skeletonView:disconnectAnimationEventSignal()
            self._isStoped = true
            if self._audioStop then
                self:stopSoundEffect()
            end
            -- self:setVisible(false)
            app.battle:performWithDelay(function()
                if func ~= nil then
                    func()
                end
                self._func = nil
            end, 0)
        end
    end)
end

function QBaseEffectView:playSoundEffect(loop)
    if self._audioEffect ~= nil then
        self._audioEffect:play(loop)
    end
end

function QBaseEffectView:pauseSoundEffect()
    if self._audioEffect ~= nil then
        self._audioEffect:pause()
    end
end

function QBaseEffectView:resumeSoundEffect()
    if self._audioEffect ~= nil then
        self._audioEffect:resume()
    end
end

function QBaseEffectView:stopSoundEffect()
    if self._audioEffect ~= nil then
        self._audioEffect:stop()
    end
end

function QBaseEffectView:isLoopSoundEffect()
    if self._audioEffect ~= nil then
        return self._audioEffect:isLoop()
    else
        return false
    end
end

function QBaseEffectView:setScissorEnabled(enabled)
    if self._skeletonView.setScissorEnabled then
        self._skeletonView:setScissorEnabled(enabled)
    end
end

function QBaseEffectView:setScissorRects(mask1, grad1, grad2, mask2)
    if self._skeletonView.setScissorRects then
        self._skeletonView:setScissorRects(mask1, grad1, grad2, mask2)
    end
end

function QBaseEffectView:setOpacityActor(opacity)
    if self._skeletonView.setOpacityActor then
        self._skeletonView:setOpacityActor(opacity)
    end
end

function QBaseEffectView:setScissorBlendFunc(func)
    if self._skeletonView.setScissorBlendFunc then
        self._skeletonView:setScissorBlendFunc(func)
    end
end

function QBaseEffectView:setScissorColor(color)
    if self._skeletonView.setScissorColor then
        self._skeletonView:setScissorColor(color)
    end
end

function QBaseEffectView:setScissorOpacity(opacity)
    if self._skeletonView.setScissorOpacity then
        self._skeletonView:setScissorOpacity(opacity)
    end
end

function QBaseEffectView:setRenderTextureBlendFunc(func)
    if self._skeletonView.setRenderTextureBlendFunc then
        self._skeletonView:setRenderTextureBlendFunc(func)
    end
end

function QBaseEffectView:setFollowActor(followActor)
    self._followActor = followActor
end

function QBaseEffectView:getFollowActor()
    return self._followActor
end

function QBaseEffectView:setPositionActor(positionActor)
    self._positionActor = positionActor
end

function QBaseEffectView:setSizeScaleX(scale, reason)
    if not reason then
        self:setScaleX(scale)
    else
        self._sizeScaleXs[reason] = scale
        local result_scale = 1
        for _, sub_scale in pairs(self._sizeScaleXs) do
            result_scale = result_scale * sub_scale
        end
        self:setScaleX(result_scale)
    end
end

function QBaseEffectView:setSizeScaleY(scale, reason)
    if not reason then
        self:setScaleY(scale)
    else
        self._sizeScaleYs[reason] = scale
        local result_scale = 1
        for _, sub_scale in pairs(self._sizeScaleYs) do
            result_scale = result_scale * sub_scale
        end
        self:setScaleY(result_scale)
    end
end

function QBaseEffectView:setSizeScale(scale, reason)
    self:setSizeScaleX(scale, reason)
    self:setSizeScaleY(scale, reason)
end

function QBaseEffectView:setActorView(actorView)
    self._actorView = actorView
end

function QBaseEffectView:getActorView()
    return self._actorView
end

function QBaseEffectView:setClippingRect(rect)
    local clip = self:getChildByTag(QBaseEffectView.CHILD_TAG_CLIP)
    if rect then
        if clip == nil then
            local stencil = CCLayerColor:create(ccc4(0,0,0,150), 0, 0)
            local skeletonView = self._skeletonView
            clip = CCClippingNode:create()
            clip:setStencil(stencil)
            skeletonView:retain()
            skeletonView:removeFromParent()
            clip:addChild(skeletonView:getNode())
            skeletonView:release()
            self:addChild(clip, 0, QBaseEffectView.CHILD_TAG_CLIP)
        end
        clip:getStencil():setPosition(ccp(rect.origin.x, rect.origin.y))
        clip:getStencil():setContentSize(CCSizeMake(rect.size.width, rect.size.height))
    else
        if clip ~= nil then
            local skeletonView = self._skeletonView
            skeletonView:retain()
            skeletonView:removeFromParent()
            self:addChild(skeletonView:getNode())
            skeletonView:release()
            clip:removeFromParent()
            clip = nil
        end
    end
end

function QBaseEffectView:setFollowScaleActor(actor)
    self._follow_scale_actor = actor
end

function QBaseEffectView:getId()
    return self._effectID
end

function QBaseEffectView:getConfigScale()
    return self._configScale
end

function QBaseEffectView:getPlayAnimationName()
    return self._animation
end

function QBaseEffectView:isFcaEffect()
    return self._skeletonView.isFca
end

function QBaseEffectView:isCalcOffset()
    return self._isCalcOffset == true
end

return QBaseEffectView
