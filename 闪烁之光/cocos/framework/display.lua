--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local display = {}
display.DEFAULT_FPS = 60

local director = cc.Director:getInstance()
local view = director:getOpenGLView()

if not view then
    local width = 720
    local height = 1280
    if CC_DESIGN_RESOLUTION then
        if CC_DESIGN_RESOLUTION.width then
            width = CC_DESIGN_RESOLUTION.width
        end
        if CC_DESIGN_RESOLUTION.height then
            height = CC_DESIGN_RESOLUTION.height
        end
    end
    view = cc.GLViewImpl:createWithRect("Sy_Mhfx", cc.rect(0, 0, width, height))
    director:setOpenGLView(view)
end

-- 一些通用设置,在这里处理
director:setDisplayStats(CC_SHOW_FPS)
director:setProjection(cc.DIRECTOR_PROJECTION2_D)
director:setDepthTest(false)
director:setAnimationInterval(1.0 / display.DEFAULT_FPS)
cc.Device:setKeepScreenOn(true)

local framesize = view:getFrameSize()
local textureCache = director:getTextureCache()
local spriteFrameCache = cc.SpriteFrameCache:getInstance()
local animationCache = cc.AnimationCache:getInstance()

-- auto scale
local function checkResolution(r)
    r.width = checknumber(r.width)
    r.height = checknumber(r.height)
    r.autoscale = string.upper(r.autoscale)
    assert(r.width > 0 and r.height > 0,
        string.format("display - invalid design resolution size %d, %d", r.width, r.height))
end

local function setDesignResolution(r, framesize)
    if r.autoscale == "FILL_ALL" then
        view:setDesignResolutionSize(framesize.width, framesize.height, cc.ResolutionPolicy.FILL_ALL)
    else
        local scaleX, scaleY = framesize.width / r.width, framesize.height / r.height
        local width, height = framesize.width, framesize.height
        if r.autoscale == "FIXED_WIDTH" then
            width = framesize.width / scaleX
            height = framesize.height / scaleX
            view:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "FIXED_HEIGHT" then
            width = framesize.width / scaleY
            height = framesize.height / scaleY
            view:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "EXACT_FIT" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.EXACT_FIT)
        elseif r.autoscale == "NO_BORDER" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "SHOW_ALL" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.SHOW_ALL)
        else
            printError(string.format("display - invalid r.autoscale \"%s\"", r.autoscale))
        end
    end
end

local function setConstants()
    local sizeInPixels = view:getFrameSize()
    display.sizeInPixels = {width = sizeInPixels.width, height = sizeInPixels.height}

    local viewsize = director:getWinSize()
    display.contentScaleFactor = director:getContentScaleFactor()
    display.size               = {width = viewsize.width, height = viewsize.height}
    display.width              = display.size.width
    display.height             = display.size.height
    display.cx                 = display.width / 2
    display.cy                 = display.height / 2
    display.c_left             = -display.width / 2
    display.c_right            = display.width / 2
    display.c_top              = display.height / 2
    display.c_bottom           = -display.height / 2
    display.left               = 0
    display.right              = display.width
    display.top                = display.height
    display.bottom             = 0
    display.center             = cc.p(display.cx, display.cy)
    display.left_top           = cc.p(display.left, display.top)
    display.left_bottom        = cc.p(display.left, display.bottom)
    display.left_center        = cc.p(display.left, display.cy)
    display.right_top          = cc.p(display.right, display.top)
    display.right_bottom       = cc.p(display.right, display.bottom)
    display.right_center       = cc.p(display.right, display.cy)
    display.top_center         = cc.p(display.cx, display.top)
    display.top_bottom         = cc.p(display.cx, display.bottom)

    printInfo(string.format("# display.sizeInPixels         = {width = %0.2f, height = %0.2f}", display.sizeInPixels.width, display.sizeInPixels.height))
    printInfo(string.format("# display.size                 = {width = %0.2f, height = %0.2f}", display.size.width, display.size.height))
    printInfo(string.format("# display.contentScaleFactor   = %0.2f", display.contentScaleFactor))
    printInfo(string.format("# display.width                = %0.2f", display.width))
    printInfo(string.format("# display.height               = %0.2f", display.height))
    printInfo(string.format("# display.cx                   = %0.2f", display.cx))
    printInfo(string.format("# display.cy                   = %0.2f", display.cy))
    printInfo(string.format("# display.left                 = %0.2f", display.left))
    printInfo(string.format("# display.right                = %0.2f", display.right))
    printInfo(string.format("# display.top                  = %0.2f", display.top))
    printInfo(string.format("# display.bottom               = %0.2f", display.bottom))
    printInfo(string.format("# display.c_left               = %0.2f", display.c_left))
    printInfo(string.format("# display.c_right              = %0.2f", display.c_right))
    printInfo(string.format("# display.c_top                = %0.2f", display.c_top))
    printInfo(string.format("# display.c_bottom             = %0.2f", display.c_bottom))
    printInfo(string.format("# display.center               = {x = %0.2f, y = %0.2f}", display.center.x, display.center.y))
    printInfo(string.format("# display.left_top             = {x = %0.2f, y = %0.2f}", display.left_top.x, display.left_top.y))
    printInfo(string.format("# display.left_bottom          = {x = %0.2f, y = %0.2f}", display.left_bottom.x, display.left_bottom.y))
    printInfo(string.format("# display.left_center          = {x = %0.2f, y = %0.2f}", display.left_center.x, display.left_center.y))
    printInfo(string.format("# display.right_top            = {x = %0.2f, y = %0.2f}", display.right_top.x, display.right_top.y))
    printInfo(string.format("# display.right_bottom         = {x = %0.2f, y = %0.2f}", display.right_bottom.x, display.right_bottom.y))
    printInfo(string.format("# display.right_center         = {x = %0.2f, y = %0.2f}", display.right_center.x, display.right_center.y))
    printInfo(string.format("# display.top_center           = {x = %0.2f, y = %0.2f}", display.top_center.x, display.top_center.y))
    printInfo(string.format("# display.top_bottom           = {x = %0.2f, y = %0.2f}", display.top_bottom.x, display.top_bottom.y))
    printInfo("#")
end

function display.setAutoScale(configs)
    if type(configs) ~= "table" then return end

    checkResolution(configs)
    if type(configs.callback) == "function" then
        local c = configs.callback(framesize)
        for k, v in pairs(c or {}) do
            configs[k] = v
        end
        checkResolution(configs)
    end

    setDesignResolution(configs, framesize)

    printInfo(string.format("# design resolution size       = {width = %0.2f, height = %0.2f}", configs.width, configs.height))
    printInfo(string.format("# design resolution autoscale  = %s", configs.autoscale))
    setConstants()
end

if type(CC_DESIGN_RESOLUTION) == "table" then
    display.setAutoScale(CC_DESIGN_RESOLUTION)
end

display.COLOR_WHITE = cc.c3b(255, 255, 255)
display.COLOR_BLACK = cc.c3b(0, 0, 0)
display.COLOR_RED   = cc.c3b(255, 0, 0)
display.COLOR_GREEN = cc.c3b(0, 255, 0)
display.COLOR_BLUE  = cc.c3b(0, 0, 255)

display.AUTO_SIZE      = 0
display.FIXED_SIZE     = 1
display.LEFT_TO_RIGHT  = 0
display.RIGHT_TO_LEFT  = 1
display.TOP_TO_BOTTOM  = 2
display.BOTTOM_TO_TOP  = 3

display.CENTER        = cc.p(0.5, 0.5)
display.LEFT_TOP      = cc.p(0, 1)
display.LEFT_BOTTOM   = cc.p(0, 0)
display.LEFT_CENTER   = cc.p(0, 0.5)
display.RIGHT_TOP     = cc.p(1, 1)
display.RIGHT_BOTTOM  = cc.p(1, 0)
display.RIGHT_CENTER  = cc.p(1, 0.5)
display.CENTER_TOP    = cc.p(0.5, 1)
display.CENTER_BOTTOM = cc.p(0.5, 0)

display.SCENE_TRANSITIONS = {
    CROSSFADE       = {cc.TransitionCrossFade},
    FADE            = {cc.TransitionFade, cc.c3b(0, 0, 0)},
    FADEBL          = {cc.TransitionFadeBL},
    FADEDOWN        = {cc.TransitionFadeDown},
    FADETR          = {cc.TransitionFadeTR},
    FADEUP          = {cc.TransitionFadeUp},
    FLIPANGULAR     = {cc.TransitionFlipAngular, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    FLIPX           = {cc.TransitionFlipX, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    FLIPY           = {cc.TransitionFlipY, cc.TRANSITION_ORIENTATION_UP_OVER},
    JUMPZOOM        = {cc.TransitionJumpZoom},
    MOVEINB         = {cc.TransitionMoveInB},
    MOVEINL         = {cc.TransitionMoveInL},
    MOVEINR         = {cc.TransitionMoveInR},
    MOVEINT         = {cc.TransitionMoveInT},
    PAGETURN        = {cc.TransitionPageTurn, false},
    ROTOZOOM        = {cc.TransitionRotoZoom},
    SHRINKGROW      = {cc.TransitionShrinkGrow},
    SLIDEINB        = {cc.TransitionSlideInB},
    SLIDEINL        = {cc.TransitionSlideInL},
    SLIDEINR        = {cc.TransitionSlideInR},
    SLIDEINT        = {cc.TransitionSlideInT},
    SPLITCOLS       = {cc.TransitionSplitCols},
    SPLITROWS       = {cc.TransitionSplitRows},
    TURNOFFTILES    = {cc.TransitionTurnOffTiles},
    ZOOMFLIPANGULAR = {cc.TransitionZoomFlipAngular},
    ZOOMFLIPX       = {cc.TransitionZoomFlipX, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    ZOOMFLIPY       = {cc.TransitionZoomFlipY, cc.TRANSITION_ORIENTATION_UP_OVER},
}

display.TEXTURES_PIXEL_FORMAT = {}

display.DEFAULT_TTF_FONT        = "Arial"
display.DEFAULT_TTF_FONT_SIZE   = 32


local PARAMS_EMPTY = {}
local RECT_ZERO = cc.rect(0, 0, 0, 0)

local sceneIndex = 0
function display.newScene(name, params)
    params = params or PARAMS_EMPTY
    sceneIndex = sceneIndex + 1
    local scene
    if not params.physics then
        scene = cc.Scene:create()
    else
        scene = cc.Scene:createWithPhysics()
    end
    scene.name_ = string.format("%s:%d", name or "<unknown-scene>", sceneIndex)

    if params.transition then
        scene = display.wrapSceneWithTransition(scene, params.transition, params.time, params.more)
    end

    return scene
end

function display.wrapScene(scene, transition, time, more)
    local key = string.upper(tostring(transition))

    if key == "RANDOM" then
        local keys = table.keys(display.SCENE_TRANSITIONS)
        key = keys[math.random(1, #keys)]
    end

    if display.SCENE_TRANSITIONS[key] then
        local t = display.SCENE_TRANSITIONS[key]
        local cls = t[1]
        time = time or 0.2
        more = more or t[2]
        if more ~= nil then
            scene = cls:create(time, scene, more)
        else
            scene = cls:create(time, scene)
        end
    else
        error(string.format("display.wrapScene() - invalid transition %s", tostring(transition)))
    end
    return scene
end

function display.runScene(newScene, transition, time, more)
    if director:getRunningScene() then
        if transition then
            newScene = display.wrapScene(newScene, transition, time, more)
        end
        director:replaceScene(newScene)
    else
        director:runWithScene(newScene)
    end
end

function display.getRunningScene()
    return director:getRunningScene()
end

function display.newNode()
    return cc.Node:create()
end

function display.newLayer(...)
    local params = {...}
    local c = #params
    local layer
    if c == 0 then
        -- /** creates a fullscreen black layer */
        -- static Layer *create();
        layer = cc.Layer:create()
    elseif c == 1 then
        -- /** creates a Layer with color. Width and height are the window size. */
        -- static LayerColor * create(const Color4B& color);
        layer = cc.LayerColor:create(cc.convertColor(params[1], "4b"))
    elseif c == 2 then
        -- /** creates a Layer with color, width and height in Points */
        -- static LayerColor * create(const Color4B& color, const Size& size);
        --
        -- /** Creates a full-screen Layer with a gradient between start and end. */
        -- static LayerGradient* create(const Color4B& start, const Color4B& end);
        local color1 = cc.convertColor(params[1], "4b")
        local p2 = params[2]
        assert(type(p2) == "table" and (p2.width or p2.r), "display.newLayer() - invalid paramerter 2")
        if p2.r then
            layer = cc.LayerGradient:create(color1, cc.convertColor(p2, "4b"))
        else
            layer = cc.LayerColor:create(color1, p2.width, p2.height)
        end
    elseif c == 3 then
        -- /** creates a Layer with color, width and height in Points */
        -- static LayerColor * create(const Color4B& color, GLfloat width, GLfloat height);
        --
        -- /** Creates a full-screen Layer with a gradient between start and end in the direction of v. */
        -- static LayerGradient* create(const Color4B& start, const Color4B& end, const Vec2& v);
        local color1 = cc.convertColor(params[1], "4b")
        local p2 = params[2]
        local p2type = type(p2)
        if p2type == "table" then
            layer = cc.LayerGradient:create(color1, cc.convertColor(p2, "4b"), params[3])
        else
            layer = cc.LayerColor:create(color1, p2, params[3])
        end
    end
    return layer
end

function display.newSprite(source, x, y, params)
    local spriteClass = cc.Sprite
    local scale9 = false

    if type(x) == "table" and not x.x then
        -- x is params
        params = x
        x = nil
        y = nil
    end

    local params = params or PARAMS_EMPTY
    if params.scale9 or params.capInsets then
        spriteClass = ccui.Scale9Sprite
        scale9 = true
        params.capInsets = params.capInsets or RECT_ZERO
        params.rect = params.rect or RECT_ZERO
    end

    local sprite
    while true do
        -- create sprite
        if not source then
            sprite = spriteClass:create()
            break
        end

        local sourceType = type(source)
        if sourceType == "string" then
            if string.byte(source) == 35 then -- first char is #
                -- create sprite from spriteFrame
                if not scale9 then
                    sprite = spriteClass:createWithSpriteFrameName(string.sub(source, 2))
                else
                    sprite = spriteClass:createWithSpriteFrameName(string.sub(source, 2), params.capInsets)
                end
                break
            end

            -- create sprite from image file
            if display.TEXTURES_PIXEL_FORMAT[source] then
                cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[source])
            end
            if not scale9 then
                sprite = spriteClass:create(source)
            else
                sprite = spriteClass:create(source, params.rect, params.capInsets)
            end
            if display.TEXTURES_PIXEL_FORMAT[source] then
                cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_BGR_A8888)
            end
            break
        elseif sourceType ~= "userdata" then
            error(string.format("display.newSprite() - invalid source type \"%s\"", sourceType), 0)
        else
            sourceType = tolua.type(source)
            if sourceType == "cc.SpriteFrame" then
                if not scale9 then
                    sprite = spriteClass:createWithSpriteFrame(source)
                else
                    sprite = spriteClass:createWithSpriteFrame(source, params.capInsets)
                end
            elseif sourceType == "cc.Texture2D" then
                sprite = spriteClass:createWithTexture(source)
            else
                error(string.format("display.newSprite() - invalid source type \"%s\"", sourceType), 0)
            end
        end
        break
    end

    if sprite then
        if x and y then sprite:setPosition(x, y) end
        if params.size then sprite:setContentSize(params.size) end
    else
        error(string.format("display.newSprite() - create sprite failure, source \"%s\"", tostring(source)), 0)
    end

    return sprite
end

function display.newSpriteFrame(source, ...)
    local frame
    if type(source) == "string" then
        if string.byte(source) == 35 then -- first char is #
            source = string.sub(source, 2)
        end
        frame = spriteFrameCache:getSpriteFrame(source)
        if not frame then
            error(string.format("display.newSpriteFrame() - invalid frame name \"%s\"", tostring(source)), 0)
        end
    elseif tolua.type(source) == "cc.Texture2D" then
        frame = cc.SpriteFrame:createWithTexture(source, ...)
    else
        error("display.newSpriteFrame() - invalid parameters", 0)
    end
    return frame
end

function display.isSpriteFramesWithFileLoaded(plist)
    if spriteFrameCache.isSpriteFramesWithFileLoaded then
        return spriteFrameCache:isSpriteFramesWithFileLoaded(plist)
    else
        return false
    end
end

function display.newFrames(pattern, begin, length, isReversed)
    local frames = {}
    local step = 1
    local last = begin + length - 1
    if isReversed then
        last, begin = begin, last
        step = -1
    end

    for index = begin, last, step do
        local frameName = string.format(pattern, index)
        local frame = spriteFrameCache:getSpriteFrame(frameName)
        if not frame then
            error(string.format("display.newFrames() - invalid frame name %s", tostring(frameName)), 0)
        end
        frames[#frames + 1] = frame
    end
    return frames
end

local function newAnimation(frames, time)
    local count = #frames
    assert(count > 0, "display.newAnimation() - invalid frames")
    time = time or 1.0 / count
    return cc.Animation:createWithSpriteFrames(frames, time),
           cc.Sprite:createWithSpriteFrame(frames[1])
end

function display.newAnimation(...)
    local params = {...}
    local c = #params
    if c == 2 then
        -- frames, time
        return newAnimation(params[1], params[2])
    elseif c == 4 then
        -- pattern, begin, length, time
        local frames = display.newFrames(params[1], params[2], params[3])
        return newAnimation(frames, params[4])
    elseif c == 5 then
        -- pattern, begin, length, isReversed, time
        local frames = display.newFrames(params[1], params[2], params[3], params[4])
        return newAnimation(frames, params[5])
    else
        error("display.newAnimation() - invalid parameters")
    end
end

function display.loadImage(imageFilename, callback)
    if not callback then
        return textureCache:addImage(imageFilename)
    else
        textureCache:addImageAsync(imageFilename, callback)
    end
end

local fileUtils = cc.FileUtils:getInstance()
function display.getImage(imageFilename)
    local fullpath = fileUtils:fullPathForFilename(imageFilename)
    return textureCache:getTextureForKey(fullpath)
end

function display.removeImage(imageFilename)
    textureCache:removeTextureForKey(imageFilename)
end

function display.loadSpriteFrames(dataFilename, imageFilename, callback)
    local async = type(callback) == "function"
    local asyncHandler = nil
    if async then
        asyncHandler = function()
            local texture = textureCache:getTextureForKey(imageFilename)
            -- assert(texture, string.format("The texture %s, %s is unavailable.", dataFilename, imageFilename))
            spriteFrameCache:addSpriteFrames(dataFilename, imageFilename)
            callback(dataFilename, imageFilename)
        end
    end

    if display.TEXTURES_PIXEL_FORMAT[imageFilename] then
        cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[imageFilename])
    end

    if async then
        textureCache:addImageAsync(imageFilename, asyncHandler)
    else
        spriteFrameCache:addSpriteFrames(dataFilename, imageFilename)
    end

    if display.TEXTURES_PIXEL_FORMAT[imageFilename] then
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_BGR_A8888)
    end
end

function display.removeSpriteFrames(dataFilename, imageFilename)
    spriteFrameCache:removeSpriteFramesFromFile(dataFilename)
    if imageFilename then
        display.removeImage(imageFilename)
    end
end

function display.removeSpriteFrame(imageFilename)
    spriteFrameCache:removeSpriteFrameByName(imageFilename)
end

function display.setTexturePixelFormat(imageFilename, format)
    display.TEXTURES_PIXEL_FORMAT[imageFilename] = format
end

function display.setAnimationCache(name, animation)
    animationCache:addAnimation(animation, name)
end

function display.getAnimationCache(name)
    return animationCache:getAnimation(name)
end

function display.removeAnimationCache(name)
    animationCache:removeAnimation(name)
end

function display.removeUnusedSpriteFrames()
    spriteFrameCache:removeUnusedSpriteFrames()
    textureCache:removeUnusedTextures()
end

function display.removeUnusedTextures()
    cc.SkeletonCache:getInstance():disposeAllCache()
    textureCache:removeUnusedTextures()
end

-- 移除暂时没有使用的spine缓存数据
function display.removeUnusedSpine()
    cc.SkeletonCache:getInstance():disposeAllCache()
end

-- 检测一个spine缓存数据是否存在
function display.isPrefixExist(prefix)
    local isExist = cc.SkeletonCache:getInstance():isPrefixExist(prefix)
    return isExist
end

--==============================--
--desc:获取适配之后最大的缩放尺寸,用于背景图缩放(因为现在开率到，固定高度，那么缩放比只要根据宽度去处理就好了)
--time:2017-12-18 03:47:42
--@return 
--==============================--
function display.getMaxScale()
    local max_scale = 1
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_HEIGHT" then

    else
        local winSize = display.size
        local designSize = cc.size(CC_DESIGN_RESOLUTION.width, CC_DESIGN_RESOLUTION.height)
        local k1 = winSize.width / designSize.width
        local k2 = winSize.height / designSize.height
        max_scale = math.max( k1, k2 )
    end
    return max_scale
end

function display.getMinScale()
    local min_scale = 1
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_HEIGHT" then

    else
        local winSize = display.size
        local designSize = cc.size(CC_DESIGN_RESOLUTION.width, CC_DESIGN_RESOLUTION.height)
        local k1 = winSize.width / designSize.width
        local k2 = winSize.height / designSize.height
        min_scale = math.min(k1, k2)
    end
    return min_scale
end


--[[
    @desc:以宽度为准的情况下， 
    author:{author}
    time:2018-05-03 14:56:30
    return
]]
function display.getScale()
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_HEIGHT" then
        return 1
    else
        return display.width / CC_DESIGN_RESOLUTION.width
    end
end

--==============================--
--desc:获取屏幕地步的位置
--time:2017-12-18 04:37:05
--@obj:
--@return 
--==============================--
function display.getBottom(obj)
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_HEIGHT" then
        return 0
    else
        local height = CC_DESIGN_RESOLUTION.height
        if not tolua.isnull(obj) then 
            height = obj:getContentSize().height
        end
        local safe_size = cc.rect(0,0, display.width, display.height)
        local safe_y = 0
        if PLATFORM == cc.PLATFORM_OS_IPHONE or PLATFORM == cc.PLATFORM_OS_MAC then
            safe_size = display.getSafeAreaRect()
            if safe_size.y ~= 0 then
                safe_y = safe_size.y * 0.5
            end
        end
        return ( height - display.height ) * 0.5 + safe_y
    end
end

--==============================--
--desc:(只针对居中屏幕的处理)
--time:2017-12-18 05:25:11
--@obj:
--@return 
--==============================--
function display.getTop(obj)
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_HEIGHT" then
        return CC_DESIGN_RESOLUTION.height
    else
        local height = CC_DESIGN_RESOLUTION.height 
        if not tolua.isnull(obj) then
            height = obj:getContentSize().height 
        end
        local safe_size = cc.rect(0,0, display.width, display.height)
        local safe_y = 0
        if PLATFORM == cc.PLATFORM_OS_IPHONE or PLATFORM == cc.PLATFORM_OS_MAC then
            safe_size = display.getSafeAreaRect()
            if safe_size.y ~= 0 then
                safe_y = safe_size.y * 1.4
            end
        elseif PLATFORM == cc.PLATFORM_OS_ANDROID then -- 安卓的需要判断是否是留海,安卓写死上面留50像素,这里有一些特殊机型要做一下安全区域判定
            if hasNotchInScreen() == true then
                local device_name = device.getDeviceName()
                safe_y = -50
                if device_name and device_name ~= "" then
                    if device_name == " HONOR_HWOXF(OXF-AN00)" or device_name == "HUAWEI_HWVCE(VCE-AL00)" or device_name == "HONOR_HWPCT(PCT-AL10)" then
                        safe_y = -65
                    end
                end
            end
        end
        return safe_y + safe_size.height - ( display.height - height ) * 0.5
    end
end

--==============================--
--desc:适配了屏幕最右边坐标,适配了iphonex
--time:2018-01-03 10:23:44
--@obj:
--@return 
--==============================--
function display.getRight(obj )
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_HEIGHT" then
        return CC_DESIGN_RESOLUTION.width
    else
        local width = CC_DESIGN_RESOLUTION.width 
        if not tolua.isnull(obj) then
            width = obj:getContentSize().width 
        end
        local winSize = director:getWinSize()
        return ( width + winSize.width ) * 0.5
    end
end

--==============================--
--desc:适配时候屏幕最坐标坐标位置,适配了iphonex
--time:2018-01-03 10:22:30
--@obj:
--@return 
--==============================--
function display.getLeft(obj)
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_HEIGHT" then
        return 0
    else
        local width = CC_DESIGN_RESOLUTION.width 
        if not tolua.isnull(obj) then
            width = obj:getContentSize().width 
        end
        local winSize = director:getWinSize()
        return ( width - winSize.width ) * 0.5
    end
end

--==============================--
--desc:安全区域,针对ios有用
--time:2018-01-03 09:56:09
--@return 
--==============================--
function display.getSafeAreaRect()
    if display.safe_size == nil then
        display.safe_size = director:getSafeAreaRect()
    end
    return display.safe_size
end

function display.getScreenWH(obj,is_scene)
    if tolua.isnull(obj) then 
        return display.width,display.height
    end
    local height = display.getTop(obj) - display.getBottom(obj)
    local width = display.getRight(obj,is_scene) - display.getLeft(obj,is_scene)
    return width,height
end

--[[
    @desc:有一些ui是按照宽度去设计的。就是说设计的是720，这个时候就不能按照 getMaxScale 去做适配了，因为比如说2：1的分辨率，他们是不需要做缩放的
    author:{author}
    time:2018-05-17 21:12:54
    return
]]
function display.specialScale()
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_WIDTH" then
        return display.getMinScale()
    elseif CC_DESIGN_RESOLUTION.autoscale == "FIXED_HEIGHT" then
        return 1
    end
    return 1
end


return display

