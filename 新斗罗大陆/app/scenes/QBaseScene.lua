--[[
    Class name: QBaseScene
    Create by Julian
    QBaseScene is a base scene that affort some base function and event bind
--]]

--require "CCBReaderLoad"

local QBaseScene = class("QBaseScene", function()
    return display.newScene("QBaseScene")
end)

--[[
    member of QBaseScene:
    _ccbProxy: a instance of CCBProxy
    _touchLayer: handle touch event if touch enabled
    _skeletonLayer: display skeleton views
    _dragLineLayer: display drag line
    _uiLayer: display ui on scene
    _overlayLayer: over lay
    _dialogLayer: display dialog
--]]

--[[
    options is a table. Valid key below:
    ccbi : the ccbi file that need loaded
--]]
function QBaseScene:ctor( options )
    if options ~= nil and type(options) == "table" and table.nums(options) > 0 then
        self:parseOptions(options)
    end

    self._backgroundOverLayer = CCLayerColor:create(ccc4(0, 0, 0, 0), display.width * 2, display.height * 2)
    self._backgroundOverLayer:setVisible(false)
    -- self:addChild(self._backgroundOverLayer)

    self._backgroundLayer = display.newNode()
    self._trackLineLayer = display.newNode()
    self._skeletonLayer = display.newNode()
    self._damageLayer = display.newNode()
    self._hpLayer = display.newNode()
    self._dragLineLayer = display.newNode() -- drag or select hero and enemy
    self._overSkeletonLayer = display.newNode()
    self._uiLayer = display.newNode()
    self._overlayLayer = display.newNode()
    self._dialogLayer = display.newNode()
    
    self._rootLayer = display.newNode()
    self._rootLayer:addChild(self._backgroundLayer)
    self._rootLayer:addChild(self._trackLineLayer)
    self._rootLayer:addChild(self._skeletonLayer)
    self._rootLayer:addChild(self._dragLineLayer)
    self._rootLayer:addChild(self._overSkeletonLayer)
    self._rootLayer:addChild(self._hpLayer)
    self._rootLayer:addChild(self._damageLayer)
    self._rootLayer:addChild(self._uiLayer)
    self._rootLayer:addChild(self._overlayLayer)
    self._rootLayer:addChild(self._dialogLayer)

    self:calculatePosition()

    self:addChild(self._rootLayer)

    local scale = UI_DESIGN_WIDTH / BATTLE_SCREEN_WIDTH
    self._backgroundLayer:setScale(scale)
    self._trackLineLayer:setScale(scale)
    self._skeletonLayer:setScale(scale)
    self._damageLayer:setScale(scale)
    self._hpLayer:setScale(scale)
    self._dragLineLayer:setScale(scale)
    self._overSkeletonLayer:setScale(scale)

    self:addSkeletonContainer(self._backgroundOverLayer)

    self:setNodeEventEnabled(true)
end

function QBaseScene:calculatePosition()
    local gapWidth = self:getGapWidth()
    local resolutionDY = self:getGapHeight()
    self._backgroundLayer:setPositionY(resolutionDY)
    self._trackLineLayer:setPositionY(resolutionDY)
    self._skeletonLayer:setPositionY(resolutionDY)
    self._skeletonLayer:setPositionX(gapWidth * 0.5)
    self._backgroundOverLayer:setPositionX(-gapWidth)
    self._damageLayer:setPositionY(resolutionDY)
    self._hpLayer:setPositionY(resolutionDY)
    self._dragLineLayer:setPositionY(resolutionDY)
    self._dragLineLayer:setPositionX(gapWidth * 0.5)
    self._overSkeletonLayer:setPositionY(resolutionDY) 
    self._backgroundOverLayer:setPositionY(-resolutionDY)
end

function QBaseScene:getGapWidth()
    local gapWidth = 0
    if display.width > UI_DESIGN_WIDTH then
        gapWidth = (display.width - UI_DESIGN_WIDTH)
    end

    return gapWidth
end

function QBaseScene:getGapHeight()
    local gapHeight = 0
    if display.height > BATTLE_SCREEN_HEIGHT then
        gapHeight = (display.height - BATTLE_SCREEN_HEIGHT) 
    end

    return gapHeight
end

function QBaseScene:setSceneScale(duration, _scale)
    local back = self._ccbNode
    local skeleton = self._skeletonLayer
    local hp = self._hpLayer
    local scale = display.width / BATTLE_SCREEN_WIDTH
    back:setAnchorPoint(ccp(1, 0.5))
    local contentScaleFactor = 1
    if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH_AND_HEIGHT" then
        contentScaleFactor = math.min(display.contentScaleFactor, 1.125) -- max width is 1280 , so i don't konw why?
    end

    skeleton:setAnchorPoint(ccp(1, 0.5))
    skeleton:setContentSize(CCSize(BATTLE_SCREEN_WIDTH * contentScaleFactor, BATTLE_SCREEN_HEIGHT * contentScaleFactor))
    local x, y = skeleton:getPosition()
    skeleton:setPosition(ccp(x + BATTLE_SCREEN_WIDTH * scale, y + BATTLE_SCREEN_HEIGHT * 0.5 * scale))

    hp:setAnchorPoint(ccp(1, 0.5))
    hp:setContentSize(CCSize(BATTLE_SCREEN_WIDTH * contentScaleFactor, BATTLE_SCREEN_HEIGHT * contentScaleFactor))
    local x, y = hp:getPosition()
    hp:setPosition(ccp(x + BATTLE_SCREEN_WIDTH * scale, y + BATTLE_SCREEN_HEIGHT * 0.5 * scale))

    skeleton:runAction(self:_getScaleAction(duration, _scale))
    back:runAction(self:_getScaleAction(duration, _scale))
    hp:runAction(self:_getScaleAction(duration, _scale))
end

function QBaseScene:resetSceneScale()
    self._skeletonLayer:stopAllActions()
    self._ccbNode:stopAllActions()
    self._hpLayer:stopAllActions()

    self._skeletonLayer:setAnchorPoint(ccp(0, 0))
    self._skeletonLayer:setScale(UI_DESIGN_WIDTH / BATTLE_SCREEN_WIDTH)
    self._skeletonLayer:setPositionX(self:getGapWidth() * 0.5)
    self._skeletonLayer:setPositionY(self:getGapHeight())

    self._hpLayer:setAnchorPoint(ccp(0, 0))
    self._hpLayer:setScale(UI_DESIGN_WIDTH / BATTLE_SCREEN_WIDTH)
    self._hpLayer:setPositionX(self:getGapWidth() * 0.5)
    self._hpLayer:setPositionY(self:getGapHeight())

    self._ccbNode:setScale(1)
    self._ccbNode:setAnchorPoint(ccp(0.5, 0.5))
end

function QBaseScene:_getScaleAction(duration, scale)
    local arr = CCArray:create()
    -- arr:addObject(CCDelayTime:create(3.0))
    arr:addObject(CCScaleBy:create(duration, scale))
    return CCSequence:create(arr)
end

function QBaseScene:getSkeletonLayer()
    return self._skeletonLayer
end

function QBaseScene:getBackgroundParent()
    return self._backgroundLayer:getParent()
end

function QBaseScene:showSkeleton()
    self._backgroundLayer:setVisible(true)
    self._trackLineLayer:setVisible(true)
    self._skeletonLayer:setVisible(true)
    self._damageLayer:setVisible(true)
    self._hpLayer:setVisible(true)
    self._overSkeletonLayer:setVisible(true)
end

function QBaseScene:hideSkeleton()
    self._backgroundLayer:setVisible(false)
    self._trackLineLayer:setVisible(false)
    self._skeletonLayer:setVisible(false)
    self._damageLayer:setVisible(false)
    self._hpLayer:setVisible(false)
    self._overSkeletonLayer:setVisible(false)
end

--[[
    the option is from ctor
--]]
function QBaseScene:parseOptions( options )
    if options["ccbi"] ~= nil and type(options["ccbi"]) == "string" then
        printInfo("create scene " .. self.name .. " from " .. options["ccbi"])

--      load ccbi and add root node to self
        local ccbi = options["ccbi"]
        self._ccbProxy = CCBProxy:create()
        self._ccbOwner = options.owner
        local node = CCBuilderReaderLoad(ccbi, self._ccbProxy, self._ccbOwner)
        self._ccbNode = node
        self:addChild(node)

    end
end

function QBaseScene:setOnExitCallback(cb)
    self._onExitCallback = cb
end

function QBaseScene:onEnter()
    if device.platform == "android" then
        local layer = CCLayer:create()
        self:addChild(layer)
        layer:setKeypadEnabled(true)
        layer:addKeypadEventListener(function(event)
            if event == "back" then 
                app:onClickBackButton()
            end
        end)
    end
end

function QBaseScene:onExit()
    if self._onExitCallback then
        self._onExitCallback()
        self._onExitCallback = nil
    end
end

function QBaseScene:addSkeletonContainer(container)
    if container == nil then
        return
    end
    self._skeletonLayer:addChild(container)
end

function QBaseScene:addHpAndDamageContainer(containerHp, containerDamage)
    if containerHp then
        self._hpLayer:addChild(containerHp)
    end
    if containerDamage then
        self._damageLayer:addChild(containerDamage)
    end
end

function QBaseScene:addDragLine(dragLine)
    if dragLine == nil then
        return
    end
    self._dragLineLayer:addChild(dragLine)
end

function QBaseScene:addTrackLine(trackLine)
    if trackLine == nil then
        return
    end
    self._trackLineLayer:addChild(trackLine)
end

function QBaseScene:addUI(uiView, noRestPos, isRight)
    if uiView == nil then
        return
    end
    local tag = 0
    if noRestPos ~= false then
        CalculateBattleUIPosition(uiView, isRight)
        tag = 1
        if isRight ~= nil then
            tag = 2
        end
    end
    self._uiLayer:addChild(uiView, 0, tag)
end

function QBaseScene:addOverlay(overlay)
    assert(overlay ~= nil)
    self._overlayLayer:addChild(overlay)
end

function QBaseScene:addDialog(dlg)
    assert(dlg ~= nil)
    self._dialogLayer:addChild(dlg)
end

function QBaseScene:getBackgroundOverLayer()
    return self._backgroundOverLayer
end

function QBaseScene:shakeScreen(value, duration, repeat_count)
    value = value or 20
    duration = duration and (duration / 8) or 0.05
    repeat_count = repeat_count or 1

    if self._posBeforeShake == nil then
        self._posBeforeShake = {x = self:getPositionX(), y = self:getPositionY()}
    end
    self:stopAllActions()
    self:setPosition(self._posBeforeShake.x, self._posBeforeShake.y)
    local arr = CCArray:create()
    -- how shake looks like
    -- ______
    -- \    /|
    -- |\  / | 
    -- | \/  |
    -- | /\  |
    -- |/  \ |
    -- /____\|
    arr:addObject(CCMoveBy:create(duration / 2, ccp(-value / 2, value / 2)))
    arr:addObject(CCMoveBy:create(duration, ccp(value, 0)))
    arr:addObject(CCMoveBy:create(duration, ccp(-value, -value)))
    arr:addObject(CCMoveBy:create(duration, ccp(value, 0)))
    arr:addObject(CCMoveBy:create(duration, ccp(-value, value)))
    arr:addObject(CCMoveBy:create(duration, ccp(0, -value)))
    arr:addObject(CCMoveBy:create(duration, ccp(value, value)))
    arr:addObject(CCMoveBy:create(duration, ccp(0, -value)))
    arr:addObject(CCMoveBy:create(duration / 2, ccp(-value / 2, value / 2)))
    self:runAction(CCRepeat:create(CCSequence:create(arr), repeat_count))
end

function QBaseScene:hibernate(...)
    if CCNode.hibernate then
        CCNode.hibernate(self, ...)
    end
end

function QBaseScene:wakeup(...)
    if CCNode.wakeup then
        CCNode.wakeup(self, ...)
    end
end

function QBaseScene.createTipCache()
    local _tips_inuse = {}
    local _tips_available = {}
    local _stop_return = false
    -- local _tips_available_number = 0
    local function getTip(ccb_name)
        local _available = _tips_available[ccb_name]
        local _inuse = _tips_inuse[ccb_name]
        if not _available then
            _available = {}
            _tips_available[ccb_name] = _available
        end
        if not _inuse then
            _inuse = {}
            _tips_inuse[ccb_name] = _inuse
        end

        local it = next(_available)
        local tip
        if it then
            tip = it
            _available[it] = nil
            -- _tips_available_number = _tips_available_number - 1
            -- printInfo("_tips_available_number = %d", _tips_available_number)
            _inuse[it] = tip
        else
            local ccbOwner = {}
            tip = CCBuilderReaderLoad(ccb_name, CCBProxy:create(), ccbOwner)
            tip.ccbOwner = ccbOwner
            tip.need_return = true
            tip.ccb_name = ccb_name
            tip:retain()
            _inuse[tip] = tip 
        end
        -- print("----111 - getTip",ccb_name, tip:retainCount(),tip:getParent())
        return tip
    end
    local function returnTip(tip)
        local _available = _tips_available[tip.ccb_name]
        local _inuse = _tips_inuse[tip.ccb_name]

        if _inuse[tip] and (not _available or not _available[tip]) then
            _inuse[tip] = nil
            if not _stop_return and _available then
                _available[tip] = tip
            else
                tip:release()
            end
            -- _tips_available_number = _tips_available_number + 1
            -- printInfo("_tips_available_number = %d", _tips_available_number)
        end
    end
    local function stopCache()
        _stop_return = true
        local tip, _available, _inuse, ccbiFile
        for ccbiFile, _available in pairs(_tips_available) do
             
            for _, tip in pairs(_available) do
                -- print("-----1-QBaseScene  stopCache   _available have not release tip",ccbiFile, tip:retainCount(), retainCount)
                -- local animationManager = tolua.cast(tip:getUserObject(), "CCBAnimationManager")
                -- if animationManager then
                --     animationManager:stopAnimation();
                -- end
                QCleanNode(tip)
                tip:release()
            end
        end

        -- 防止  被中断动画  导致returnTip 没有被调用的情况下 可能会导致泄露
        -- for ccbiFile, _inuse in pairs(_tips_inuse) do
        --     for _, tip in pairs(_inuse) do
        --         local node = tolua.cast(tip, "CCNode")
        --         if node then
        --             local parent = node:getParent()
        --             local retainCount = node:retainCount()
        --             if (not parent and retainCount >= 1) then
        --                 tip:release()
        --             end
        --         end
        --     end
        -- end

        _tips_available = {}
    end
    local function startCache()
        _stop_return = false
    end
    local function makeRoom(ccb_name, count)
        local arr = {}
        for i = 1, count do
            table.insert(arr, getTip(ccb_name))
        end
        for i = 1, count do
            returnTip(arr[i])
        end
        arr = nil
    end
    return {getTip = getTip, returnTip = returnTip, stopCache = stopCache, startCache = startCache, makeRoom = makeRoom}
end

return QBaseScene