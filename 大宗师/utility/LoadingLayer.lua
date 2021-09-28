--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-6-19
-- Time: 上午11:05
-- To change this template use File | Settings | File Templates.
--

LoadingLayer = {}
local LAYER_TAG = 123456

local _layer = nil
local _visible = false
--
--ccb = ccb or {}
--ccb["loadingCtrl"] = {}

local function init()
    local _shaderLayer = CCLayerColor:create(ccc4(100, 100, 100, 0), display.width, display.height)
    _shaderLayer._anim = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT,
        armaName = "jiazai",
        isRetain = false,
        finishFunc = function()

        end
    })
    _shaderLayer._anim:setPosition(display.cx, display.cy)
    _shaderLayer:addChild(_shaderLayer._anim, 1000)

    _shaderLayer._anim:setVisible(false)
    _shaderLayer:setTouchEnabled(true)
    _shaderLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,
        function(event, x, y)
            if "began" == event.name then
                return true
            end
        end, 1)
    _shaderLayer:retain()

    _shaderLayer.tmpNode = display.newNode()
    _shaderLayer:addChild(_shaderLayer.tmpNode)
    return _shaderLayer
end

function LoadingLayer.delayCall(f)
    if _layer and _layer.tmpNode then
        printf("performWithDelay")
        _layer.tmpNode:performWithDelay(function()
            printf("performWithDelay")
            if f then
                f()
            end
        end, 0.001)
    else
        if f then
            f()
        end
    end
end

function LoadingLayer.start()
    if _layer then
        LoadingLayer.hide()
    end
    if _layer == nil then
        _layer = init()
    end
    _visible = true
    _layer:setTouchEnabled(true)
    _layer:setVisible(_visible)

    printf("======== show loadinglayer ========")
    _layer.tmpNode:stopAllActions()
    _layer.tmpNode:performWithDelay(function()
        if _visible then
            printf("=============== show anim ============")
            _layer._anim:setVisible(true)
        end
    end, 1.5)

    if _layer:getParent() == nil then
        _layer:setTag(LAYER_TAG)
        game.runningScene:addChild(_layer, TOP_LAYER_TAG + 1)
    end
    _layer:setPosition(display.cx - _layer:getContentSize().width / 2, display.cy - _layer:getContentSize().height / 2)
    return _layer
end

function LoadingLayer.hide(callback)

    if _visible then
        _visible = false
        if _layer then
            if _layer._anim:isVisible() then
                _layer.tmpNode:stopAllActions()
                _layer._anim:setVisible(false)
                _layer:setVisible(_visible)
                _layer:removeFromParentAndCleanup(false)
            else
                _layer:setVisible(_visible)
                _layer:removeFromParentAndCleanup(false)
            end
        end

    end

    if (callback) then
        callback()
    end
end

function LoadingLayer.destroy()
    if _visible then
        LoadingLayer.hide()
    end
    _layer:release()
    printf("======== destroy loadinglayer ========")
end

return LoadingLayer

