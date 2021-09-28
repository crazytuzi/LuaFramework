--[[
文件名：ui.lua
描述：该文件中存放创建UI控件的辅助函数，比如创建label、button...
创建人：liaoyuangang
创建时间：2016.03.30
-- ]]

ui ={}
-- 原始定义在 Cocos2dConstants.lua 文件中定义
ui.TEXT_ALIGN_LEFT    = cc.TEXT_ALIGNMENT_LEFT
ui.TEXT_ALIGN_CENTER  = cc.TEXT_ALIGNMENT_CENTER
ui.TEXT_ALIGN_RIGHT   = cc.TEXT_ALIGNMENT_RIGHT
ui.TEXT_VALIGN_TOP    = cc.VERTICAL_TEXT_ALIGNMENT_TOP
ui.TEXT_VALIGN_CENTER = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
ui.TEXT_VALIGN_BOTTOM = cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM

-- 定义ListView action type
ui.LISTVIEW_ACTION_NONE = 0
ui.LISTVIEW_ACTION_LEFTTORIGHT = 1
ui.LISTVIEW_ACTION_LEFT1RIGHT2 = 2
ui.LISTVIEW_ACTION_RIGHT1LEFT2 = 3

-- 释放缓存资源
local director = cc.Director:getInstance()
if not director.__default_purgeCachedData then
    director.__default_purgeCachedData = director.purgeCachedData
end
director.purgeCachedData = function()
    require("common.SkeletonAnimation")
    SkeletonCache:clear()
    director:__default_purgeCachedData()
end

-- 需要使用 Scale9Sprite 创建的图片信息列表
scale9Infos = {
    -- 公共图片
    ["c_18.png"] = {capRect = cc.rect(80, 52, 1, 1)},
    ["c_19.png"] = {capRect = cc.rect(320, 70, 1, 1)},
    ["c_25.png"] = {capRect = cc.rect(138, 27, 1, 1)},
    ["c_64.png"] = {capRect = cc.rect(40, 18, 1, 1)},
    ["c_65.png"] = {capRect = cc.rect(150, 65, 1, 1)},

    ["c_30.png"] = {capRect = cc.rect(200, 70, 1, 1)},
    ["c_37.png"] = {capRect = cc.rect(90, 65, 2, 2)},
    ["c_54.png"] = {capRect = cc.rect(85, 64, 1, 1)},
    ["c_69.png"] = {capRect = cc.rect(180, 52, 1, 1)},
    ["c_103.png"] = {capRect = cc.rect(78, 20, 1, 1)},
    ["c_155.png"] = {capRect = cc.rect(50, 25, 1, 1)},

    -- 队伍和装备模块
    ["zb_05.png"] = {capRect = cc.rect(75, 148, 1, 1)},
    ["zb_07.png"] = {capRect = cc.rect(153, 16, 1, 1)},

    -- 副本和战斗模块
    ["fb_28.png"] = {capRect = cc.rect(134, 21, 1, 1)},
    ["fb_29.png"] = {capRect = cc.rect(114, 21, 1, 1)},
    ["zdjs_05.png"] = {capRect = cc.rect(320, 25, 1, 1)},
    ["zdjs_06.png"] = {capRect = cc.rect(320, 25, 1, 1)},

    -- 挑战和修炼模块
    ["sc_19.png"] = {capRect = cc.rect(150, 15, 1, 1)},
    ["bsxy_03.png"] = {capRect = cc.rect(130, 50, 1, 1)},
    ["wldh_28.png"] = {capRect = cc.rect(75, 19, 1, 1)},

    -- 其他模块
    ["mrjl_01.png"] = {capRect = cc.rect(240, 20, 1, 1)},
    ["mrjl_02.png"] = {capRect = cc.rect(260, 280, 1, 1)},
    ["kfbp_23.jpg"] = {capRect = cc.rect(320, 70, 1, 1)},
    ["bp_22.png"] = {capRect = cc.rect(350, 50, 1, 1)},
    ["jrhd_06.png"] = {capRect = cc.rect(150, 30, 1, 1)},
    ["bpz_37.png"] = {capRect = cc.rect(30, 15, 1, 1)},
    ["jqg_4.png"] = {capRect = cc.rect(190, 120, 1, 1)},
}

-- 标准按钮大小
ButtonSize = {
    [1] = cc.size(127, 55),
    [2] = cc.size(127, 55),
    [3] = cc.size(127, 55),
    [4] = cc.size(127, 55),
}

local shareTextureCache = cc.Director:getInstance():getTextureCache()

-- 覆写 TextureCache:addImage
-- 检查display.TEXTURES_PIXEL_FORMAT是否对该图片已经指定绘制方式
-- 对未指定格式的jpg图片使用cc.TEXTURE2_D_PIXEL_FORMAT_RG_B888
if not shareTextureCache.__defalut_addImage then
    shareTextureCache.__defalut_addImage = shareTextureCache.addImage
end
shareTextureCache.addImage = function(_, filename)
    local ret
    local alphoFormat = display.TEXTURES_PIXEL_FORMAT[filename]
    if not alphoFormat and string.lower(filename):match("[^%s+]%.jpg") then
        alphoFormat = cc.TEXTURE2_D_PIXEL_FORMAT_RG_B888
    end
    if alphoFormat then
        cc.Texture2D:setDefaultAlphaPixelFormat(alphoFormat)
        ret = shareTextureCache:__defalut_addImage(filename)
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    else
        ret = shareTextureCache:__defalut_addImage(filename)
    end

   return ret
end

-- 覆写 cc.Sprite:create
-- 检查display.TEXTURES_PIXEL_FORMAT是否对该图片已经指定绘制方式
-- 对未指定格式的jpg图片使用cc.TEXTURE2_D_PIXEL_FORMAT_RG_B888
if not cc.Sprite.__defalut_create then
    cc.Sprite.__defalut_create = cc.Sprite.create
end
cc.Sprite.create = function(_, filename)
    local sprite
    if not filename then
        sprite = cc.Sprite:__defalut_create(filename)
    else
        sprite = ui.newSprite(filename)
    end
    return sprite
end

--- 获取图片的大小
--[[
-- 参数
    filename: 图片文件名 或 图像帧名称 当 textureResType == ccui.TextureResType.plistType 时为图像帧名称，否则为图片文件名
    textureResType : 图片资源的类型（ccui.TextureResType = {localType = 0, plistType = 1,}），默认为 ccui.TextureResType.localType (图片文件)
    texturePlist : 图像帧资源对应的plist文件, 只有 textureResType == ccui.TextureResType.plistType 时，该参数有效
 ]]
function ui.getImageSize(filename, textureResType, texturePlist)
    local frameCache = cc.SpriteFrameCache:getInstance()
    local frame = frameCache:getSpriteFrame(filename)
    if textureResType == ccui.TextureResType.plistType then
        if not frame then
            if not texturePlist then
                print("ui.getImageSize not found SpriteFrame:", filename)
                return cc.size(0, 0)
            end
            frameCache:addSpriteFrames(texturePlist)
            frame = frameCache:getSpriteFrame(filename)
        end
        return frame:getOriginalSizeInPixels()
    else
        if frame then
            return frame:getOriginalSizeInPixels()
        else
            return shareTextureCache:addImage(filename):getContentSizeInPixels()
        end
    end
end

--[[
-- 创建一个图像帧对象。
-- 参数：
－   frameName：图像帧名称

-- 返回 SpriteFrameCache 对象
]]
function ui.newSpriteFrame(frameName)
    local tempFrameCache = cc.SpriteFrameCache:getInstance()
    local frame = tempFrameCache:getSpriteFrame(frameName)
    if not frame then
        printError("Display.newSpriteFrame() - invalid frameName %s", tostring(frameName))
    end
    return frame
end

--[[
-- 参数
    filename: 图片文件名 或 图像帧名称 当 textureResType == ccui.TextureResType.plistType 时为图像帧名称，否则为图片文件名
    textureResType : 图片资源的类型（ccui.TextureResType = {localType = 0, plistType = 1,}），默认为 ccui.TextureResType.localType (图片文件)
    texturePlist : 图像帧资源对应的plist文件, 只有 textureResType == ccui.TextureResType.plistType 时，该参数有效
 ]]
function ui.newSprite(filename, textureResType, texturePlist)
    local spriteClass_create = function(...)
        local create = cc.Sprite.__defalut_create or cc.Sprite.create
        return create(cc.Sprite, ...)
    end

    local sprite
    if textureResType == ccui.TextureResType.plistType then
        local frameCache = cc.SpriteFrameCache:getInstance()
        local frame = frameCache:getSpriteFrame(filename)
        if not frame then
            if not texturePlist then
                print("ui.getImageSize not found SpriteFrame:", filename)
                return
            end
            frameCache:addSpriteFrames(texturePlist)
        end
        sprite = cc.Sprite:createWithSpriteFrameName(filename)
    else
        local alphoFormat = display.TEXTURES_PIXEL_FORMAT[filename]
        if alphoFormat then
            cc.Texture2D:setDefaultAlphaPixelFormat(alphoFormat)
            sprite = spriteClass_create(filename)
            cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
        else
            sprite = spriteClass_create(filename)
        end
    end

    return sprite
end

--[[
-- 参数
    filename：图片名称
    contentSize: 需要拉伸的大小
 ]]
function ui.newScale9Sprite(filename, contentSize)
    local sprite
    local tempInfo = scale9Infos[filename]
    local srcSize = shareTextureCache:addImage(filename):getContentSizeInPixels()
    if tempInfo then
        sprite = ccui.Scale9Sprite:create(filename, cc.rect(0, 0, srcSize.width, srcSize.height), tempInfo.capRect)
    else
        sprite = ccui.Scale9Sprite:create(filename)
    end
    if contentSize then
        sprite:setContentSize(contentSize)
    end

    return sprite
end

--[[
-- 创建 ccui.Button
-- 参数params中各个字段为：
    {
        normalImage      : 正常图片，必须提供
        lightedImage     : 按下图片，可选设置，默认为normal
        disabledImage    : 不可用时图片，可选设置，默认为normal
        textureResType   : 图片资源的类型（ccui.TextureResType = {localType = 0, plistType = 1,}）
        texturePlist     : 图片资源对应的plist文件
        size        : 按钮大小，可选设置,默认在1-4个字的情况下可不传
        position    : 按钮位置, 可选设置，默认为(0，0)点
        clickAction : 点击事件，可选设置
        clickAudio  : 点击音效(clickAction有效)，默认为ButtonAudio.normal, 设置为""可取消音效
        text        : 显示的字符串(必须和fontSize同时提供)，可选设置
        fontSize    : 显示的字符串字体大小(必须和text同时提供)，可选设置
        fontName    : 字体名，可选设置，默认为 _FONT_BUTTON
        textColor   : 字体颜色，可选设置
        textWidth   : 显示文字的宽度，设置该值后可以自动换行
        fixedSize   : [BOOL]: 按钮是否使用原图固定尺寸, 默认不固定, true则固定使用原图尺寸

        shadowColor = nil,  -- 阴影的颜色，可选设置，不设置表示不需要阴影
        outlineColor = nil, -- 描边的颜色，可选设置，不设置表示不需要描边
        outlineSize = 2,    -- 描边的大小，可选设置，如果 outlineColor 为nil，该参数无效，默认为 2

        titleImage  : 按钮上的图片，可选设置
        anchorPoint : 可选设置
        scale       : 可选设置

        titlePosRateX   : title图片或文字的X坐标相对按钮宽度的比例，默认为0.5
        titlePosRateY   : title图片或文字的Y坐标相对按钮高度的比例，默认为0.5
    }
]]
function ui.newButton(params)
    if not params or not params.normalImage then
        return
    end
    if params.textureResType and params.texturePlist and params.texturePlist ~= "" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(params.texturePlist)
    end

    local lightedImage = params.lightedImage or params.selectedImage or params.normalImage
    local disabledImage = params.disabledImage or ""
    local button = ccui.Button:create(params.normalImage, lightedImage, disabledImage, params.textureResType or ccui.TextureResType.localType)
    button:setPressedActionEnabled(true)

    if params.size then
        button:setScale9Enabled(true)
        button:setContentSize(params.size)
    else
        -- if params.text and not params.fixedSize then
        --     local textCount = string.utf8len(params.text)
        --     local size = ButtonSize[textCount]
        --     if size then
        --         button:setScale9Enabled(true)
        --         button:setContentSize(size)
        --     end
        -- end
    end

    local titlePosRateX = params.titlePosRateX or 0.5
    local titlePosRateY = params.titlePosRateY or 0.5
    local buttonSize = button:getContentSize()

    button:getExtendNode2():setPosition(buttonSize.width/2, buttonSize.height/2)

    -- 判断是否带字符串显示·
    if params.text then
        local tempStr = params.text
        if string.utf8len(tempStr) == 2 then
            tempStr = string.utf8sub(params.text, 1, 1) .. " " .. string.utf8sub(params.text, 2, 2)
        end
        local outlineColor = Enums.Color.eBlack
        if params.normalImage == "c_28.png" then
            outlineColor = cc.c3b(0x8e, 0x4f, 0x03)
        elseif params.normalImage == "c_33.png" then
            outlineColor = cc.c3b(0x18, 0x7e, 0x6d)
        elseif params.normalImage == "c_59.png" then
            outlineColor = cc.c3b(0xc0, 0x49, 0x4b)
        end
        local titleLabel = ui.newLabel({
            text = tempStr,
            font = params.fontName or Enums.Font.eDefault,
            size = params.fontSize or Enums.Fontsize.eBtnDefault,
            color = params.textColor or Enums.Color.eBtnText,
            shadowColor = params.shadowColor,
            --outlineColor = params.outlineColor or Enums.Color.eBlack,
            outlineColor = params.outlineColor or outlineColor,
            outlineSize = params.outlineSize or 2,
            x = buttonSize.width * (titlePosRateX - 0.5),
            y = buttonSize.height * (titlePosRateY - 0.5),
            dimensions = params.textWidth and cc.size(params.textWidth, 0),
        })
        titleLabel:setAnchorPoint(cc.p(0.5, 0.5))

        button:getExtendNode2():addChild(titleLabel, 2)
        button.mTitleLabel = titleLabel
    end

    -- 创建title image
    if params.titleImage then
        button.titleSprite = ui.newSprite(params.titleImage)
        button.titleSprite:setPosition(buttonSize.width * (titlePosRateX - 0.5), buttonSize.height * (titlePosRateY - 0.5))
        button:getExtendNode2():addChild(button.titleSprite, 1)
    end

    -- 修改titleImage
    button.setTitleImage = function(target, titleImage)
        if target.titleSprite == nil then
            target.titleSprite = ui.newSprite(titleImage)
            target:getExtendNode2():addChild(target.titleSprite, 1)
        else
            target.titleSprite:setTexture(titleImage)
        end
    end

    -- 设置位置
    if params.position then
        button:setPosition(params.position)
    end

    -- 设置缩放
    if params.scale then
        button:setScale(params.scale)
    end

    -- 设置瞄点
    if params.anchorPoint then
        button:setAnchorPoint(params.anchorPoint)
    end
    --是否设置透明区域可穿透
    -- 修改Label
    function button:setTitleText(text)
        if self.mTitleLabel then
            local tempStr = text
            if string.utf8len(tempStr) == 2 then
                tempStr = string.utf8sub(text, 1, 1) .. " " .. string.utf8sub(text, 2, 2)
            end

            self.mTitleLabel:setString(tempStr)
        end
    end

    -- 修改颜色
    function button:setTitleColor(color)
        if self.mTitleLabel then
            self.mTitleLabel:setTextColor(color)
        end
    end

    function button:setTitleRateY(posRateY)
        local size  = button:getContentSize()
        local y = size.height * (posRateY - 0.5)
        self.mTitleLabel:setPositionY(y)
    end

    -- 定位
    function button:align(anchorPoint, x, y)
        if anchor then
            self:setAnchorPoint(anchor)
        end
        if x and y then
            self:setPosition(x, y)
        end
        return self
    end

    -- 点击事件
    function button:setClickAction(clickAction)
        self.mClickAction = clickAction
    end

    -- 设置点击事件
    button:setClickAction(params.clickAction)

    button:addTouchEventListener(function(sender, event)

        if event == ccui.TouchEventType.began then
            button.mBeginPos = sender:getTouchBeganPosition()
        elseif event == ccui.TouchEventType.ended then
            local beginPos = button.mBeginPos
            local endPos = sender:getTouchEndPosition()
            local distance = math.sqrt(math.pow(endPos.x - beginPos.x, 2) + math.pow(endPos.y - beginPos.y, 2))
            if distance < (40 * Adapter.MinScale) then
                if not params.clickAudio then
                    if params.normalImage == "c_29.png" then
                        MqAudio.playEffect("tanchuang_close.mp3")
                    end
                    MqAudio.playEffect("tongyong_dianji.mp3")
                elseif params.clickAudio ~= "" then
                    MqAudio.playEffect(params.clickAudio)
                end

                if button.mClickAction then
                    button.mClickAction(button)
                end
            end
        end
    end)

    button.normalImage = params.normalImage
    return button
end
--[[
    创建触摸层模拟Button
-- 参数params中各个字段为：
    {
        normalImage      : 正常图片，必须提供
        titleImage  : 标题图片
        bgImage     : 标题背景图片
        position    : 按钮位置, 可选设置，默认为(0，0)点
        clickAction: 点击事件回调
    }
]]
function ui.newButtonEx(params)
    if not params or not params.normalImage then
        return
    end
    params.position = params.position or cc.p(0, 0)
    params.bgImage = params.bgImage or "tz_01.png"

    local touchLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
    local tempSprite = ui.newSprite(params.normalImage)
    local size = tempSprite:getContentSize()
    touchLayer:setContentSize(size)
    tempSprite:setPosition(size.width / 2, size.height / 2)
    touchLayer:addChild(tempSprite)
    touchLayer:setAnchorPoint(0.5, 0.5)
    touchLayer:setPosition(params.position)
    touchLayer:setIgnoreAnchorPointForPosition(false)

    if params.titleImage then
        -- 标题背景
        local titleBg = ui.newSprite(params.bgImage)
        titleBg:setPosition(0, size.height / 2 - 15)
        titleBg:setRotation(270)
        titleBg:setScale(0.3)
        tempSprite:addChild(titleBg)
        -- 标题
        local titleSprite = ui.newSprite(params.titleImage)
        titleSprite:setPosition(0, size.height / 2)
        tempSprite:addChild(titleSprite)
    end

    local startPoint = {x = 0, y = 0}
    local endPoint = {x = 0, y = 0}

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- 计算是否点击的是透明区域
            local image = cc.Image:new()
            image:initWithImageFile(params.normalImage)
            local p = tempSprite:getParent():convertToNodeSpace(cc.p(x, y))
            local alpha = image:getPixelColor(p)
            if alpha == 0 then
                return false
            else
                startPoint.x = p.x
                startPoint.y = p.y
                touchLayer:setScale(1.03)
                return true
            end
        elseif eventType == "moved" then
        elseif eventType == "ended" then
            touchLayer:setScale(1.0)
            if params.clickAction then
                params.clickAction()
            end
        elseif eventType == "cancelled" then
            touchLayer:setScale(1.0)
        end
    end

    local touchInfos =
    {
        node = touchLayer,
        allowTouch = true,
        beganEvent = function(touch, event)
            local p = touch:getLocation()
            if  ui.touchInNode(touch, touchLayer) then
                return onTouch("began", p.x, p.y)
            end
        end,
        movedEvent = function(touch, event)
            local p = touch:getLocation()
            onTouch("moved", p.x, p.y)
        end,
        endedEvent = function(touch, event)
            local p = touch:getLocation()
            if  ui.touchInNode(touch, touchLayer) then
                onTouch("ended", p.x, p.y)
            else
                onTouch("cancelled", p.x, p.y)
            end
        end,
    }

    ui.registerSwallowTouch(touchInfos)

    return touchLayer
end

-- 创建 LabelTTF 文字显示对象
--[[
    params:
    Table params:
    {
        text = "",          -- 显示的内容
        font = nil,         -- 显示的字体, 默认为 _FONT_DEFAULT. 当设置为xxx.png时使用createWithCharMap创建.
        size = 22,          -- 显示字体的大小,默认为22号字
        scale = 1,          -- 设置label的字体和dimensions的缩放，默认为1
        color = nil,        -- 显示的颜色，默认为 Enums.Color.eWhite
        shadowColor = nil,  -- 阴影的颜色，可选设置，不设置表示不需要阴影
        outlineColor = nil, -- 描边的颜色，可选设置，不设置表示不需要描边
        outlineSize = 2,    -- 描边的大小，可选设置，如果 outlineColor 为nil，该参数无效，默认为 2
        align = nil,        -- 水平对齐方式, 默认为 cc.TEXT_ALIGNMENT_LEFT
        valign = nil,       -- 垂直对齐方式，默认为 cc.VERTICAL_TEXT_ALIGNMENT_CENTER
        x = 0,              -- x坐标， 默认为0
        y = 0,              -- y坐标，默认为0
        anchorPoint         -- 锚点，默认为cc.p(0.5, 0.5)
        dimensions = nil,   -- 显示区域大小，默认不设置大小, dimensions.height = 0 的时候，自动计算高度

        charCount = nil,     -- 当font为png时有效，图片上字符的个数
        startChar = nil,    -- 当font为png时有效，图片中开始字符
    }
--]]
function ui.newLabel(params)
    if not params then params = NULL end

    local text       = tostring(params.text) or ""
    local font       = params.font or Enums.Font.eDefault
    local size       = params.size or Enums.Fontsize.eDefault
    local textAlign  = params.align or cc.TEXT_ALIGNMENT_LEFT
    local textValign = params.valign or cc.VERTICAL_TEXT_ALIGNMENT_CENTER

    -- 初始化设置label大小
    local dimensions = params.dimensions
    if not dimensions then
        dimensions = cc.size(0, 0)
    end

    local label
    local extension = font:match("%.([^%.]+)$")
    local fontImageMark = text:find(".ttf") or text:find("{[%w_/]+%.[jpngJPNG]+}")
         -- or text:find("#%x%x%x%x%x%x") or text:find("{%x+ ?,? ?[%w-%.]*}")
    if not extension and not fontImageMark then
        label = cc.Label:createWithSystemFont(text, font, size, dimensions, textAlign, textValign)
    else
        extension = extension and string.lower(extension)
        if extension == "ttf" or fontImageMark then
            label = require("common.RichTextEx"):create({
                text = text,
                align = textAlign,
                valign = textValign,
                dimensions = dimensions,

                formatInfo = {
                    font = font,
                    fontSize = size,
                    color = params.color,

                    needBold = false,
                    needUnderline = false,
                    needStrikethrough = false,

                    needUrl = false,
                    url = "",

                    needOutLine = params.outlineColor ~= nil,
                    outlineColor = params.outlineColor,
                    outlineSize = params.outlineSize,

                    needShadow = params.shadowColor ~= nil,
                    shadowColor = params.shadowColor,
                    shadowOffset = nil,
                    shadowBlurRadius = nil,

                    needeGlow = false,
                    glowColor = nil,
                },
            })
            label.isRichText = true
        elseif extension == "fnt" then
            label = cc.Label:createWithBMFont(font, text, textAlign, 0, cc.p(0, 0))
        elseif extension == "png" then
            label = ui.newNumberLabel({
                text = text,
                imgFile = font,
                charCount = params.charCount,
                startChar = params.startChar,
            })
        end
    end

    -- system label参数设置
    if not label.isRichText then
        if params.color then
            label:setColor(params.color)
        end
        if params.outlineColor then
            label:enableOutline(params.outlineColor, params.outlineSize or 2)
        end
        if params.shadowColor then
            label:enableShadow(cc.c4b(params.shadowColor.r,params.shadowColor.g,params.shadowColor.b,255))
        end
        if params.scale then
            label:setSystemFontSize(size * params.scale)
            if params.dimensions then
                label:setDimensions(dimensions.width * params.scale, dimensions.height * params.scale)
            end
        end
    end

    if params.x and params.y then
        label:setPosition(params.x, params.y)
    end
    if params.anchorPoint then
        label:setAnchorPoint(cc.p(params.anchorPoint))
    end
    return label
end

-- 根据数字图片创建显示数字的label(0123456789)
--[[
-- 参数
    params = {
        text = "123", -- 需要显示数字
        imgFile = "c_49.png", -- 数字图片名
        charCount = 10, -- 数字图片上字符个数, 默认 10 个 (0123456789)
        startChar = '0', -- 开始的字符，默认为 '0'（即 48）
    }
 ]]
function ui.newNumberLabel(params)
    local temptexture = shareTextureCache:addImage(params.imgFile or "c_49.png")

    local tempSize = temptexture:getContentSize()
    local itemWidth = tempSize.width / (params.charCount or 10)
    local itemHeight = tempSize.height

    local tempLabel = cc.Label:createWithCharMap(temptexture, itemWidth, tempSize.height, params.startChar or 48)

    tempLabel._originSetString = tempLabel.setString
    tempLabel.setString = function (imageLabel, text)
        text = string.gsub(text, TR("万"), ":")
        text = string.gsub(text, TR("亿"), ";")
        imageLabel:_originSetString(text)
    end

    tempLabel:setString(params.text)
    return tempLabel
end


-- 创建 cc.CheckBox
--[[
    params:
    Table params:
    {
        normalImage : 正常状态图片，必须提供
        selectImage : 选中状态图片，必须提供
        imageScale  : 图片缩放比例，可选设置，默认是1
        isRevert    : 是否把文字放到复选框前面，默认false
        text        : 描述文字，可选设置
        textColor   : 字体颜色，可选设置，默认白色
        fontSize    : 字体大小，可选设置，默认20号
        font        : 字体，可选设置，默认系统字体
        outlineColor: 描边颜色，可选设置，默认无描边
        outlineSize : 描边宽度，可选设置，默认无描边
        callback    : 点击回调，可选参数
    }
    说明：

    getCheckState()          : 获取选中状态
    setCheckState(true/false): 设置选中状态
--]]
function ui.newCheckbox(params)
    params = params or {}
    local isRevert = params.isRevert
    local normalImage = params.normalImage or "c_60.png"
    local selectImage = params.selectImage or "c_61.png"

    local retNode = display.newNode()
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setAnchorPoint(cc.p(0.5, 0.5))
    retNode.selected = false

    local tempBtn = ui.newButton({
        normalImage = normalImage,
        clickAction = function()
            retNode:setCheckState(not retNode.selected)
            -- 回调函数
            if params.callback then
                params.callback(retNode.selected)
            end
        end
    })
    retNode.button = tempBtn
    retNode:addChild(tempBtn)

    local tempLabel = ui.newLabel({
        text = params.text,
        font = params.font,
        size = params.fontSize,
        color = params.textColor,
        outlineColor = params.outlineColor,
        outlineSize = params.outlineSize,
        align = isRevert and cc.TEXT_ALIGNMENT_RIGHT or cc.TEXT_ALIGNMENT_LEFT,
    })
    tempLabel:setAnchorPoint(cc.p(isRevert and 1 or 0, 0.5))
    retNode.label = tempLabel
    retNode:addChild(tempLabel)

    --设置按钮可点击
    retNode.setTouchEnabled = function(pSender, isEnabled)
        if type(isEnabled) ~= "boolean" then
            return
        end
        retNode.button:setTouchEnabled(isEnabled)
    end

    -- 设置选择状态
    retNode.setCheckState = function(pSender, state)
        retNode.selected = state
        local tempImg = state and selectImage or normalImage
        retNode.button:loadTextures(tempImg, tempImg)
    end

    -- 获取选中状态
    retNode.getCheckState = function(pSender)
        return retNode.selected
    end

    -- 设置显示文字
    retNode.setString = function(pSender, text)
        retNode.label:setString(text)

        local btnSize = retNode.button:getContentSize()
        local labelSize = retNode.label:getContentSize()

        local tempSize = cc.size(btnSize.width + labelSize.width + 10, math.max(btnSize.height, labelSize.height))
        retNode:setContentSize(tempSize)
        retNode.label:setPosition(isRevert and labelSize.width or (btnSize.width + 10), tempSize.height / 2)
        retNode.button:setPosition( btnSize.width / 2 + (isRevert and labelSize.width + 10 or 0), tempSize.height / 2)
    end

    retNode:setString(params.text)

    return retNode
end

-- 快捷创建星级图片
--[[
-- 参数:
    starLevel: -- 必选参数，物品的星级
    space: -- 星星之间的间距，默认是2
    starImg: -- 星星图片，默认使用 c_75.png
    exStarLevel: 额外显示星星与普通星星的总和, 默认为 nil
    exStarImg: 额外显示星星的图片， 默认为nil
-- 返回值
    Node对象，多个星星图片的 parent， 该node提供方法 retNode.setStarLevel(starLevel)
--]]
function ui.newStarLevel(starLevel, starImg, space, exStarLevel, exStarImg)
    local retNode = cc.Node:create()
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setAnchorPoint(cc.p(0.5, 0.5))

    starImg = starImg or "c_75.png"

    space = space or 2
    local imgSize = ui.getImageSize(exStarImg or starImg)
    retNode.setStarLevel = function(starLv, exStarLv)
        retNode:removeAllChildren()
        local tempCount = math.max(starLv, exStarLevel or 0)
        for i = 1, tempCount do
            local tempPosX,tempPosY

            tempPosX = imgSize.width / 2 + (i - 1) * (imgSize.width + space)
            tempPosY = imgSize.height / 2

            -- 创建总星数
            if exStarLv and exStarLv > 0 and exStarImg and exStarImg ~= "" then
                local tempSprite =  ui.newSprite(exStarImg)
                tempSprite:setPosition(tempPosX, tempPosY)
                retNode:addChild(tempSprite)
                -- 采用正常星星的灰色图片
                tempSprite:setGray(true)
            end

            -- 创建当前进度
            if i <= starLv or not exStarImg or exStarImg == "" then
                local tempSprite = ui.newSprite(starImg)
                tempSprite:setPosition(tempPosX, tempPosY)
                retNode:addChild(tempSprite)
            end
        end

        retNode:setContentSize(cc.size(tempCount * imgSize.width + (tempCount - 1) * space, imgSize.height))
    end
    if (starLevel ~= nil) then
        retNode.setStarLevel(starLevel, exStarLevel)
    end
    return retNode
end

--- 设置Label的数字变化的效果
--[[
-- 参数
    label: 需要设置效果的Label
    fromNumber: 初始需要的数字
    toNumber: 最终需要显示的数字
    formatStr: label上需要显示内容的格式字符串，如: "血量: %d", “战力: %d”, "%d" 等，默认为："%d"
 ]]
function ui.setLabelNumberChangeEffect(label, fromNumber, toNumber, formatStr)
    if not label then
        return
    end
    formatStr = formatStr or "%d"

    -- 设置变化效果
    local changeCount = math.min(math.abs(toNumber - fromNumber), 30)
    local changeDelaytime = changeCount < 10 and 0.1 or  changeCount < 20 and 0.05 or 0.03
    local changeIndex = 1
    label:stopAllActions()
    label:runAction(cc.Repeat:create(cc.Sequence:create({
        cc.CallFunc:create(function()
            local tempNumber = (changeIndex == changeCount) and toNumber or (fromNumber + math.ceil((toNumber - fromNumber) * changeIndex / changeCount))
            label:setString(string.format(formatStr, tempNumber))
            changeIndex = changeIndex + 1
        end),

        cc.DelayTime:create(changeDelaytime),
    }), changeCount))
end

--- 创建带背景的文字显示, label的parent为背景图(背景图和文字的位置关系在X方向上可以通过参数任意调整)
--[[
-- 参数params中的各个字段
    {
        bgFilename = nil,   -- 背景图片的文件名
        bgSize = nil,       -- 背景图显示大小，默认为图片大小
        labelStr = nil,     -- 需要显示的字符串
        fontSize = nil,     -- 字体大小(可选参数), 默认为24
        fontName = nil,     -- 显示文字的字体(可选参数), 默认为_FONT_DEFAULT
        color = nil,        --  label显示的颜色(可选参数)， 默认为 display.COLOR_WHITE
        outlineColor = nil, -- 显示字符串的描边颜色
        outlineSize = nil,  -- 描边的边框大小
        alignType = nil,    --  label X 方向与背景图的对齐方式(可选参数)，默认为左对齐(ui.TEXT_ALIGN_LEFT)
        offset = nil,       --  label X坐标相对图片的偏移量(可选参数), 默认为0
        offsetRate = nil,   --  如果offset为nil，那么偏移为bgWidth * offsetRate，(可选参数)
        dimensions = nil    -- 文字显示区域大小，默认不设置大小, dimensions.height = 0 的时候，自动计算高度
        valignType = nil,    --  label Y 方向与背景图的对齐方式(可选参数)，默认为中间对齐(ui.TEXT_VALIGN_CENTER)
        offsetY = nil,       --  label Y坐标相对图片的偏移量(可选参数), 默认为0
        offsetRateY = nil,   --  如果offsetY为nil，那么偏移为bgHeight * offsetRateY，(可选参数)
    }
-- 返回值
    第一个返回值：背景sprite
    第二个返回值：label
 ]]
function ui.createLabelWithBg(params)
    if (not params or not params.bgFilename) then
        return
    end

    local fontSize = params.fontSize or Enums.Fontsize.eDefault
    local fontName = params.fontName or Enums.Font.eDefault
    local bgSize = params.bgSize or ui.getImageSize(params.bgFilename)

    local bgSprite = params.bgSize and ui.newScale9Sprite(params.bgFilename, params.bgSize) or ui.newSprite(params.bgFilename)
    bgSprite:setCascadeOpacityEnabled(true)

    local labelPosX, labelPosY = 0, bgSize.height / 2
    local align, valign = ui.TEXT_ALIGN_LEFT, ui.TEXT_VALIGN_CENTER
    local anchorPointX, anchorPointY = 0, 0.5
    if params.alignType == ui.TEXT_ALIGN_CENTER then
        align = ui.TEXT_ALIGN_CENTER
        anchorPointX = 0.5
        labelPosX = bgSize.width / 2
    elseif params.alignType == ui.TEXT_ALIGN_RIGHT then
        align = ui.TEXT_ALIGN_RIGHT
        anchorPointX = 1
        labelPosX = bgSize.width
    end
    if params.valignType == ui.TEXT_VALIGN_TOP then
        valign = ui.TEXT_VALIGN_TOP
        anchorPointY = 1
        labelPosY = bgSize.height
    elseif params.valignType == ui.TEXT_VALIGN_BOTTOM then
        valign = ui.TEXT_VALIGN_BOTTOM
        anchorPointY = 0
        labelPosY = 0
    end

    local tempOffsetX = params.offset or params.offsetRate and params.offsetRate * bgSize.width or 0
    local tempOffsetY = params.offsetY or params.offsetRateY and params.offsetRateY * bgSize.height or 0
    local tempDimensions = params.dimensions

    local tempLabel = ui.newLabel({
        text = params.labelStr,
        font = fontName,
        size = fontSize,
        color = params.color or Enums.Color.eWhite,
        outlineColor = params.outlineColor,
        outlineSize = params.outlineSize,
        align = align,
        valign = valign,
        dimensions = tempDimensions,
        x = labelPosX + tempOffsetX,
        y = labelPosY + tempOffsetY,
    })
    tempLabel:setAnchorPoint(cc.p(anchorPointX, anchorPointY))
    bgSprite:addChild(tempLabel)
    bgSprite:setCascadeOpacityEnabled(true)

    function bgSprite:setString(str)
        tempLabel:setString(str)
    end

    return bgSprite, tempLabel
end

--- 创建图片＋提示文字(支持文字在图片上，文字在图片前面，文字在图片后面)
--[[
-- 参数 params 中的各项为：
    {
        imgName: 图片名字
        scale9Size: 图片拉升后的大小，当为nil时不使用scale9拉伸，默认使用为 nil
        labelStr: 提示文字字符串
        fontSize: 字体大小, 默认为24
        fontColor: 文字的颜色， 默认为 Enums.Color.eWhite
        shadowColor = nil,  -- 阴影的颜色，可选设置，不设置表示不需要阴影
        outlineColor = nil, -- 描边的颜色，可选设置，不设置表示不需要描边
        outlineSize = 1,    -- 描边的大小，可选设置，如果 outlineColor 为nil，该参数无效，默认为 1
        alignType: 文字和图片的排列方式，传值如下，默认为 ui.TEXT_ALIGN_CENTER
            ui.TEXT_ALIGN_LEFT: 文字在图片左边
            ui.TEXT_ALIGN_CENTER: 文字在图片中间
            ui.TEXT_ALIGN_RIGHT: 文字在图片右边
        pos = nil,门派任务奇怪的需求
    }
-- 返回值：
    第一个返回值：用于管理Sprite和label的node, setAnchorPoint 为 cc.p(0.5, 0.5)，提供 retNode:setString(labelStr, imgName) 函数
    第二个返回值：用于显示提示信息的 label
    第三个返回值：用于显示提示信息的背景图片
]]
function ui.createSpriteAndLabel(params)
    params = params or {}

    local retNode = display.newNode()
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setAnchorPoint(cc.p(0.5, 0.5))

    local alignType = params.alignType or ui.TEXT_ALIGN_CENTER
    -- 创建物品的图片
    local tempSprite
    if string.isImageFile(params.imgName) then
        if params.scale9Size then
            tempSprite = ui.newScale9Sprite(params.imgName, params.scale9Size)
        else
            tempSprite = ui.newSprite(params.imgName)
        end
        retNode:addChild(tempSprite)
    end

    -- 创建物品的数量
    local retLabel = ui.newLabel({
        text = "",
        size = params.fontSize,
        color = params.fontColor or Enums.Color.eWhite,
        shadowColor = params.shadowColor,
        outlineColor = params.outlineColor,
        outlineSize = params.outlineSize,
    })
    retNode:addChild(retLabel)
    if alignType == ui.TEXT_ALIGN_LEFT then
        retLabel:setAnchorPoint(cc.p(0, 0.5))
    elseif alignType == ui.TEXT_ALIGN_CENTER then
        retLabel:setAnchorPoint(cc.p(0.5, 0.5))
    elseif alignType == ui.TEXT_ALIGN_RIGHT then
        retLabel:setAnchorPoint(cc.p(0, 0.5))
    end

    -- 设置label显示文字的函数
    retNode.setString = function (target, labelStr, imgName)
        retLabel:setString(labelStr or "")
        if imgName and tempSprite then
            tempSprite:setTexture(imgName)
        end

        local imgSize = tempSprite and tempSprite:getContentSize() or cc.size(0, 0)
        local labelSize = retLabel:getContentSize()

        local nodeHeight = math.max(imgSize.height, labelSize.height)
        local nodeWidth = imgSize.width + labelSize.width
        if alignType == ui.TEXT_ALIGN_CENTER then
            nodeWidth = math.max(imgSize.width, labelSize.width)
        end
        target:setContentSize(cc.size(nodeWidth, nodeHeight))

        local tempPosY = nodeHeight / 2
        if alignType == ui.TEXT_ALIGN_LEFT then
            if tempSprite then
                tempSprite:setPosition(labelSize.width + imgSize.width / 2, tempPosY)
            end
            retLabel:setPosition(0, tempPosY)
        elseif alignType == ui.TEXT_ALIGN_CENTER then
            if tempSprite then
                tempSprite:setPosition(nodeWidth / 2, tempPosY)
            end
            if params.pos then
                retLabel:setPosition(params.pos)
            else
                retLabel:setPosition(nodeWidth / 2, tempPosY)
            end
        elseif alignType == ui.TEXT_ALIGN_RIGHT then
            if tempSprite then
                tempSprite:setPosition(imgSize.width / 2, tempPosY)
            end
            retLabel:setPosition(imgSize.width, tempPosY)
        end
    end
    retNode:setString(params.labelStr)

    return retNode, retLabel, tempSprite
end

-- 修改当前label为滚动显示
--[[
    params:
    Table params:
    {
        label: 需要修改的滚动label
        dimensions: label滚动的显示大小
        anchorPoint: 如不指定默认为label的anchor point
        position: 如不指定默认为label的anchor point
        forceClip: 是否强制创建clip node, 默认为false。当label内容需要变化时可设置为true
    }
    return: 返回创建的父结点layout
--]]
function ui.createLabelClipRoll(params)
    local originLabel = params.label
    if not params or not originLabel or not params.dimensions then
        return
    end

    -- 创建截取Node
    local labelSize = originLabel:getContentSize()
    if params.dimensions.width < labelSize.width or params.forceClip then
        local cPos = params.position or cc.p(originLabel:getPosition())
        local cAnchor = params.anchorPoint
        if not cAnchor then
            -- label如以前为cc.p(0.5, 0.5), 需要一定修正
            cAnchor = cc.p(originLabel:getAnchorPoint())
            cPos.x = cPos.x - params.dimensions.width /2
            cPos.y = cPos.y - params.dimensions.height /2
        end

        -- 将原label加入到裁剪node中
        local clipLayout = ccui.Layout:create()
        clipLayout:setContentSize(params.dimensions)
        clipLayout:setClippingEnabled(true)
        clipLayout:setAnchorPoint(cAnchor)
        clipLayout:setPosition(cPos)
        originLabel:getParent():addChild(clipLayout)
        originLabel:removeFromParent()
        -- 滚动前设置位置（放在设置的滚动区域的中间 防止位置还是原来父页面的坐标）
        originLabel:setPosition(cc.p(params.dimensions.width/2, 0))
        clipLayout:addChild(originLabel)

        -- label滚动动画
        originLabel:setAnchorPoint(cc.p(0,0))
        local speed = 2
        clipLayout:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function ()
            local x,y = originLabel:getPosition()
            if x + labelSize.width - speed < 0 then
                originLabel:setPosition(cc.p(params.dimensions.width, 0))
                x = params.dimensions.width
            end
            originLabel:setPosition(cc.p(x - speed, 0))
        end))))
        clipLayout.label = originLabel
        return clipLayout
    end
    return originLabel
end

--- 创建代币图片数量显示
--[[
-- 参数 params 中的每项为
    {
        resourceTypeSub: 玩家资源类型枚举，在“EnumsConfig.lua”文件中的 “ResourcetypeSub”定义
        goodsModelId: 如果类型不是玩家属性，则需要传入模型Id
        number: 资源数量
        showOwned: 可选的参数，是否显示已拥有的数量，默认为false
        fontSize: label显示的字体大小，默认22
        fontColor: label显示的颜色(可选参数)， 默认根据拥有的数量判断（充足为白色，不足为红色）
        outlineColor: 字体描边颜色,
        outlineSize: 字体描边大小，
        bgImg: 背景图片，默认为nil, 表示不需要
        bgIsScale9: 如果使用背景图片，是否采用 scale9 拉伸的方式
    }
-- 返回值
    第一个返回值：用于管理Sprite和label的node, setAnchorPoint 为 cc.p(0.5, 0.5)，提供 retNode.setNumber(number) 函数
    第二个返回值：用于显示 数量的 label
]]
function ui.createDaibiView(params)
    local retNode = display.newNode()
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setAnchorPoint(cc.p(0.5, 0.5))

    -- 创建背景图
    if params.bgImg and params.bgImg ~= "" then
        if params.bgIsScale9 then
            retNode.bgSprite = ui.newScale9Sprite(params.bgImg)
        else
            retNode.bgSprite = ui.newSprite(params.bgImg)
        end
        retNode:addChild(retNode.bgSprite)
    end

    local resType = params.resourceTypeSub or params.resourcetypeSub

    -- 创建物品的图片
    local tempImg = Utility.getDaibiImage(resType, params.goodsModelId)
    local imgSize = ui.getImageSize(tempImg)
    local tempSprite = ui.newSprite(tempImg)
    tempSprite:setPosition(imgSize.width / 2, imgSize.height / 2)
    retNode:addChild(tempSprite)
    retNode.daibiSprite = tempSprite

    -- 创建物品的数量
    local retLabel = ui.newLabel({
        text = "",
        size = params.fontSize,
        color = params.fontColor,
        outlineColor = params.outlineColor,
        outlineSize = params.outlineSize,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
    })
    retLabel:setAnchorPoint(cc.p(0, 0.5))
    retLabel:setPosition(imgSize.width, imgSize.height / 2)
    retNode:addChild(retLabel)

    function retNode.setNumber(number)
        local tempCount = Utility.getOwnedGoodsCount(resType, params.goodsModelId)
        retLabel:setTextColor(params.fontColor or tempCount < number and cc.c3b(0xfe, 0x1c, 0x46) or cc.c3b(0x24, 0x90, 0x29)) -- eNormalGreen

        local ownStr = Utility.numberWithUnit(tempCount)
        local needStr = Utility.numberWithUnit(number)
        local tempStr = params.showOwned and string.format("%s/%s", ownStr, needStr) or needStr
        retLabel:setString(tempStr)
        local labelSize = retLabel:getContentSize()
        local tempSize = cc.size(imgSize.width + labelSize.width, imgSize.height)
        retNode:setContentSize(tempSize)
        if retNode.bgSprite then
            retNode.bgSprite:setAnchorPoint(cc.p(0, 0.5))
            retNode.bgSprite:setPosition(imgSize.width, imgSize.height / 2)
            if params.bgIsScale9 then
                retNode.bgSprite:setContentSize(labelSize)
            end
        end
    end
    retNode.setNumber(params.number or params.num or params.count or params.Count)

    return retNode, retLabel
end

--- 创建弹泡泡组合显示(建议直接使用ui.createAutoBubble)
--[[
-- 参数 params 的每项为：
    {
        imgName = "",       -- 泡泡的图片名
        needFlash = false,  -- 是否需要动画
        position = cc.p(x, y),  -- 相对于parent的位置
    }
-- 返回的Sprite对象提供的成员函数
    runFlash : 执行动画效果（就是上下跳动的效果）
    stopFlash : 停止动画效果
-- 返回值
    第一个返回值：显示泡泡的sprite
 ]]
function ui.createBubble(params)
    local tempSprite = ui.newSprite(params and params.imgName or "c_85.png")
    if params and params.position then
        tempSprite:setPosition(params.position)
    end

    -- 执行上下跳动的动画效果
    tempSprite.runFlash = function(self)
        self.needFlash = true

        local array = {
            cc.MoveBy:create(0.2, cc.p(0, 10)),
            cc.MoveBy:create(0.3, cc.p(0, -10)),
            cc.DelayTime:create(2),
            cc.CallFunc:create(function()
                if not self.needFlash then
                    self:stopAllActions()
                end
            end)
        }
        self:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))
    end

    -- 停止上下跳动的效果
    tempSprite.stopFlash = function(self)
        self.needFlash = false
    end

    if not params or params.needFlash ~= false then
        tempSprite:runFlash()
    end
    return tempSprite
end

-- 创建自动更新弹泡泡组合
--[[
    params:
    table params
    {
        refreshFunc,            -- 更新函数，一般用于小红点的隐藏与显示
        eventName,              -- 自动更新事件名，如(Player.Events.eRedDotPrefix .. moduleId)
        parent,                 -- 父结点，默认父结点大小计算位置
        position=cc.p(0.8, 0.8),-- 可选参数，父结点大小相对位置
        imgName = "",           -- 可选参数，小红点的图片名， 默认为 "ui/c_36.png"
        needFlash = ture,       -- 可选参数，是否需要小红点弹跳效果,默认是需要
        isNew = false,          -- 是否是New的效果，为true时自动显示new的图片及位置动画
    }

-- 返回的Sprite对象提供的成员函数
    runFlash : 执行动画效果（就是上下跳动的效果）
    stopFlash : 停止动画效果
-- 返回值：显示泡泡的sprite
 ]]
function ui.createAutoBubble(params)
    if not params.parent or not params.refreshFunc or not params.eventName then
        printError("Warning: node/func/event may not valid!")
        return
    end
    local tempSprite = nil
    local tempSize = params.parent:getContentSize()
    if params.isNew then
        -- 创建new
        local relPos = params.position or cc.p(0.2, 0.8)
        params.pos = cc.p(tempSize.width * relPos.x, tempSize.height * relPos.y)
        tempSprite = ui.createNewSprite(params)
    else
        -- 默认创建小红点
        local relPos = params.position or cc.p(0.8, 0.8)
        params.position = cc.p(tempSize.width * relPos.x, tempSize.height * relPos.y)
        tempSprite = ui.createBubble(params)
        params.parent:addChild(tempSprite)
    end
    -- 注册更新事件
    Notification:registerAutoObserver(tempSprite, params.refreshFunc, params.eventName)
    -- 初始手动调用一次
    params.refreshFunc(tempSprite)
    return tempSprite
end

--- 创建“new”标识
--[[
-- 参数
    params中各项为：
    {
        parent = nil, -- 如果为nil，则需要调用设置其parent
        scale = nil, -- 缩放参数，默认为1
        pos = nil, -- 位置cc.p(x, y),如果为nil，则需要调用者设置
    }
-- 返回值
    返回显示new标识的Sprite对象
 ]]
function ui.createNewSprite(params)
    local scale = params and params.scale or 1
    local tempSprite = cc.Sprite:create("c_115.png")
    tempSprite:setScale(scale)
    if params and params.pos then
        tempSprite:setPosition(params.pos)
    end
    if params and params.parent then
        params.parent:addChild(tempSprite)
    end

    local array = {
        cc.Spawn:create({
            cc.ScaleTo:create(0.5, scale * 0.9),
            -- cc.FadeTo:create(0.5, 160)
        }),
        cc.Spawn:create({
            cc.ScaleTo:create(0.2, scale * 0.85),
            -- cc.FadeTo:create(0.2, 120)
        }),
        cc.DelayTime:create(0.1),
        cc.Spawn:create({
            cc.ScaleTo:create(0.2, scale * 0.9),
            -- cc.FadeTo:create(0.2, 160)
        }),
        cc.Spawn:create({
            cc.ScaleTo:create(0.5, scale),
            -- cc.FadeTo:create(0.5, 255)
        }),
        cc.DelayTime:create(0.2),
    }
    tempSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))

    return tempSprite
end

--- 创建闪烁动画图片
--[[
-- 参数
    params中各项为：
    {
        filename = "", --
        parent = nil, -- 如果为nil，则需要调用设置其parent
        position = nil, -- 位置cc.p(x, y),如果为nil，则需要调用者设置
        actionScale = 1.2, -- 闪烁动画放大的scale
    }
-- 返回值
    返回显示标识的Sprite对象
 ]]
function ui.createGlitterSprite(params)
    params = params or {}
    local tempSprite = cc.Sprite:create(params.filename or "c_25.png")
    tempSprite:setPosition(params.position or cc.p(0, 0))
    if params.parent then
        params.parent:addChild(tempSprite)
    end

    tempSprite:setOpacity(100)
    -- 执行动画
    local array = {
        cc.Spawn:create({
            cc.ScaleTo:create(1, params.actionScale or 1.2),
            cc.FadeTo:create(1, 255)
        }),
        cc.Spawn:create({
            cc.ScaleTo:create(1, 1),
            cc.FadeTo:create(1, 100)
        }),
    }
    tempSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))

    return tempSprite
end

-- 创建图片的浮动效果
--[[
-- 参数
    imgName： 图片名称
    position: 位置
-- 返回值
    返回 sprite对象
]]
function ui.createFloatSprite(imgName, position)
    local retSprite = ui.newSprite(imgName)
    retSprite:setPosition(position)

    -- 图片浮动效果
    local moveAction1 = cc.MoveTo:create(1.3, cc.p(position.x, position.y + 20))
    local moveAction2 = cc.MoveTo:create(1.3, cc.p(position.x, position.y + 10))
    local moveAction3 = cc.MoveTo:create(1.3, cc.p(position.x, position.y))
    retSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.EaseSineIn:create(moveAction2),
        cc.EaseSineOut:create(moveAction1),
        cc.EaseSineIn:create(moveAction2),
        cc.EaseSineOut:create(moveAction3)
    )))

    return retSprite
end

-- 创建浮动物体的背景气泡粒子效果
--[[
-- 参数
    colorLv: 颜色等级
-- 返回值
    返回 ParticleSystemQuad 对象
]]
function ui.createFloatParticle(colorLv)
    local quadColor = {
        cc.c4f(255/255 , 254/255, 223/255, 1),
        cc.c4f(63/255 , 224/255, 36/255, 1),
        cc.c4f(51/255 , 199/255, 255/255, 1),
        cc.c4f(255/255 , 53/255, 250/255, 1),
        cc.c4f(255/255 , 167/255, 19/255, 1),
        cc.c4f(255/255 , 30/255, 30/255, 1),
        cc.c4f(255/255 , 255/255, 0/255, 1),
    }

    local tempColor = quadColor[colorLv] or quadColor[1]
    local retQuad = cc.ParticleSystemQuad:create("effect_ui_particle_shop.plist")
    retQuad:setPosVar(cc.p(160, 30))
    retQuad:setStartColor(tempColor)
    retQuad:setEndColor(tempColor)
    retQuad:setLife(1)
    retQuad:setLifeVar(0.5)
    retQuad:resetSystem()

    return retQuad
end

-- 显示喷射的粒子特效
--[[
-- 参数
    imageFile: 喷射的图片
    duration: 持续的时间
]]
function ui.createSprayParticle(imageFile, duration)
    local Mode = {
        GRAVITY = 0,
        RADIUS = 1,
    }

    local retParticle = cc.ParticleSystemQuad:create()
    -- 设置为重力加速模式。
    retParticle:setEmitterMode(Mode.GRAVITY)
    -- 设置重力加速度值。
    retParticle:setGravity(cc.p(0, -1000))

    -- 设置速度及其用于随机初始化的范围值。
    retParticle:setSpeed(680)
    retParticle:setSpeedVar(180)

    -- 设置半径变化值及其用于随机初始化的范围值。
    retParticle:setRadialAccel(0)
    retParticle:setRadialAccelVar(0)

    retParticle:setTangentialAccel(0)
    retParticle:setTangentialAccelVar(0)

    -- 设置起始角度及其用于随机初始化的范围值。
    retParticle:setAngle(90)
    retParticle:setAngleVar(45)

    retParticle:setStartSpin(0)
    retParticle:setStartSpinVar(360)
    retParticle:setEndSpin(0)
    retParticle:setEndSpinVar(360)

    -- 粒子的生命值及其用于随机初始化的范围值。
    retParticle:setLife(3.0)
    retParticle:setLifeVar(0.5)

    retParticle:setStartColor(cc.c4b(255, 255, 255, 255))
    retParticle:setStartColorVar(cc.c4b(0, 0, 0, 0))
    retParticle:setEndColor(cc.c4b(255, 255, 255, 255))
    retParticle:setEndColorVar(cc.c4b(0, 0, 0, 0))
    -- 起始大小及其用于随机初始化的范围值，终止大小指定与起始大小相同，即在更新时不变化。
    retParticle:setStartSize(50)
    retParticle:setStartSizeVar(0)
    retParticle:setEndSize(-1)
    retParticle:setEndSizeVar(0)
    -- 不使用加亮模式。
    retParticle:setBlendAdditive(false)
    -- 发射器的发射速率。
    retParticle:setEmissionRate(60)

    -- 设置发射时间
    retParticle:setDuration(duration or 2.5)
    if imageFile and imageFile ~= "" then
        local shareTextureCache = cc.Director:getInstance():getTextureCache()
        retParticle:setTexture(shareTextureCache:addImage(imageFile))
    end
    retParticle:resetSystem()

    return retParticle
end

--[[
-- 飘窗提示，支持带背景的文字提示，也可以不要背景只提示文字. 提示的内容可以是图片文件名，也可以是字符串内容
-- 参数params中各个字段
    {
        parent = nil,       -- 飘窗的parent(默认为当前scene)
        image = nil,        -- 飘窗的图片
        scale = nil,        -- 缩放比例
        text = nil,         -- 显示的文字
        textColor = nil,    -- 显示文字的颜色(默认为白色)
        textSize = nil,     -- 显示文字的大小(默认为24)
        fontName = nil, -- 显示文字的字体(可选参数), 默认为_FONT_DEFAULT
        beginPos = nil,     -- 飘窗的开始位置(默认为屏幕的中央)
        delayTime = nil,    -- 飘窗开始的延迟时间(默认为 0)
        duration = nil,     -- 飘窗的持续时间(默认为1秒)
        scale9Size = nil    --飘窗的大小
        callback = nil,     -- 提示完成后的回调操作
        pos = nil,          --门派特殊处理
    }
]]
function ui.showFlashView(params)
    if not params then
        params = NULL
    elseif type(params) == "string" then
        params = {text= params}
    end

    local parent = params.parent or display.getRunningScene()
    local beginPos = params.beginPos or cc.p(display.cx, display.cy)

    -- 如果params.image传入空字符串表示不需要背景图
    local actionControl = nil
    if params.image and params.image == "" then
        actionControl = ui.newLabel({
            text = params.text,
            font = params.fontName,
            size = (params.textSize or 24) * Adapter.MinScale,
            color = params.textColor or Enums.Color.eNormalWhite,
        })
        actionControl:setPosition(beginPos)
        parent:addChild(actionControl, 256)
    else
        local tempNode = ui.createSpriteAndLabel({
            imgName = params.image or "mrjl_01.png",
            scale9Size = params.scale9Size or cc.size(640, 50),
            labelStr = params.text,
            fontColor = Enums.Color.eNormalWhite,
            alignType = ui.TEXT_ALIGN_CENTER,
            pos = params.pos,
        })
        tempNode:setPosition(beginPos)
        tempNode:setScale(params.scale or Adapter.MinScale)
        parent:addChild(tempNode, 256)
        actionControl = tempNode
    end

    -- 执行动画
    actionControl:setVisible(false)
    local array = {}
    if params.delayTime then
        table.insert(array, cc.DelayTime:create(params.delayTime))
    end
    table.insert(array, cc.CallFunc:create(function() actionControl:setVisible(true) end))
    table.insert(array, cc.ScaleTo:create(0.1, (params.scale or Adapter.MinScale) + 0.5))
    table.insert(array, cc.ScaleTo:create(0.1, params.scale or Adapter.MinScale))
    table.insert(array, cc.MoveBy:create(params.duration or 1.3, cc.p(0, 50)))
    table.insert(array, cc.CallFunc:create(function()
        actionControl:removeFromParent()
        if params.callback then
            params.callback()
        end
    end))

    actionControl:runAction(cc.Sequence:create(array))
end

-- 创建一个文字输入框，并返回 EditBox 对象。
--[[
-- 说明：请使用getText/setText函数获取/修改编辑框的文字，或者通过 editNode.editBox 来访问editbox的全部接口
-- 参数 params 中各项为：
    {
        image   : 背景图片，必须提供
        size        : 按钮大小，必须提供

        maxLength   : 最大字符长度，可选参数，默认不设立
        multiLines  : 是否允许多行, 可选参数, 默认为false
        anchor      : 锚点位置，可选设置
        position    : 按钮位置, 可选设置，默认为(0，0)点
        fontName    : 字体名，可选设置，默认为 _FONT_DEFAULT
        fontSize    : 字体大小，可选设置（默认30）
        fontColor   : 字体颜色，可选设置
        placeHolder : 提示文字，可选设置
        placeColor  : 提示文字的颜色，可选设置
    }
]]
function ui.newEditBox(params)
    local imageNormal = params.image
    local isMultiLines = params.multiLines or false
    local imagePressed = params.imagePressed
    local imageDisabled = params.imageDisabled
    local labelAlignment = params.labelAlignment or ui.TEXT_ALIGN_LEFT
    local fontSize = params.fontSize or 30

    if type(imageNormal) == "string" then
        imageNormal = ccui.Scale9Sprite:create(imageNormal)
    end
    if type(imagePressed) == "string" then
        imagePressed = ccui.Scale9Sprite:create(imagePressed)
    end
    if type(imageDisabled) == "string" then
        imageDisabled = ccui.Scale9Sprite:create(imageDisabled)
    end

    local editbox = ccui.EditBox:create(params.size, imageNormal, imagePressed, imageDisabled)
    if editbox then
        -- 设置默认回调函数
        params.listener = params.listener or function(event, editbox) end
        editbox:registerScriptEditBoxHandler(params.listener)
        if params.x and params.y then
            editbox:setPosition(params.x, params.y)
        end

        if params.fontSize then
            editbox:setFont(_FONT_DEFAULT, params.fontSize)
            editbox:setPlaceholderFontSize(params.fontSize)
        end
        Utility.performWithDelay(editbox, function ()
            editbox:setFontSize(fontSize)
        end, 0.5)

        if params.fontColor then
            editbox:setFontColor(params.fontColor)
        end
        if params.placeColor then
            editbox:setPlaceholderFontColor(params.placeColor)
        end
        if params.placeHolder then
            editbox:setPlaceHolder(params.placeHolder)
        end
    end

    --保存下背景图
    editbox.imageNormal = imageNormal

    return editbox
end

--播放特效
--[[
-- 参数 params中各项为：
    {
        parent         父节点(可选)
        zorder          排序
        effectName     动画效果
        position       坐标（可选）
        scale          缩放（可选）
        loop           是否循环（可选）
        animation      动作名（可选）
        speed          播放速度（可选）
        skin           皮肤（可选）
        rotationY      翻转
        startListener  动作开始回调
        endListener    动作结束回调
        completeListener 动作完成回调
        eventListener  事件回调
        endRelease     结束时释放
        async          异步模式（函数）
    }
]]
function ui.newEffect(params)
    require("common.SkeletonAnimation")
    if not params.effectName then
        --dump("------ERROR--------")
        return
    end

    if params.endRelease == nil then
        params.endRelease = true
    end

    --循环
    params.loop = params.loop or false
    --缩放
    params.scale = (params.scale or 1)
    --动作名
    params.animation = params.animation or "animation"

    local function setup( effect )
        local startListener = nil
        local endListener = nil
        local completeListener = nil
        local eventListener = nil
        if params.startListener then
            startListener = function(p)
                p.self = effect
                params.startListener(p)
            end
        end

        endListener = function(p)
            if params.endListener then
                p.self = effect
                params.endListener(p)
            end
            if params.endRelease then
                effect:removeFromParent()
            end
        end

        if params.completeListener then
            completeListener = function(p)
                p.self = effect
                params.completeListener(p)
            end
        end
        if params.eventListener then
            eventListener = function(p)
                p.self = effect
                params.eventListener(p)
            end
        end
        SkeletonAnimation.action({
            skeleton = effect , action = params.animation , loop = params.loop,
            startListener = startListener,
            endListener = endListener,
            completeListener = completeListener,
            eventListener = eventListener,
        })

        if (params.speed) then
            SkeletonAnimation.update({skeleton = effect , speed = params.speed})
        end

        if (params.skin) then
            SkeletonAnimation.update({skeleton = effect , skin = params.skin})
        end

        if (params.rotationY) then
            effect:setRotationSkewY(180)
        end

        if (params.rotation) then
            effect:setRotation(params.rotation)
        end
    end

    if params.async then
        SkeletonAnimation.create({
            file = params.effectName ,
            parent = params.parent ,
            zorder = params.zorder,
            position = params.position ,
            scale = params.scale ,
            async = function( effect )
                setup(effect)
                params.async(effect)
            end
        })
    else
        local effect =  SkeletonAnimation.create({
            file = params.effectName ,
            parent = params.parent ,
            zorder = params.zorder,
            position = params.position ,
            scale = params.scale ,
        })
        setup(effect)
        return effect
    end
end

-- 花落飘落效果
--[[
-- 参数 params 中各项为
    {
        file       -- 文件名
        parent     -- 父节点
        zOrder     -- 层级
        action {
            downtime,  --花瓣下落的时间
            roTime,    --花瓣单向摆动一次时间
            fAngle1,   --花瓣逆时针摆动角度
            fAngle2,   --顺时针摆动角度
            minX,      -- 随机x方向的起点
            maxX,      -- 随机x方向的终点
            minY,      -- 随机y方向的起点
            maxY,      -- 随机y方向的终点
        }
    }
]]
function ui.newPetalDropEffect(param)
    local playAction
    local cratePetal

    cratePetal = function()
        local randPosX = (math.random(param.action.minX, param.action.maxX))
        local randPosY = (math.random(param.action.minY, param.action.maxY))

        local petal = cc.Sprite:create(param.file)
        petal:setAnchorPoint(cc.p(0.5, 3))
        petal:setPosition(cc.p(randPosX, randPosY))
        param.parent:addChild(petal, param.zOrder)
        return petal
    end

    local function reset(sender)
        sender:removeFromParent(true)
        local petal = cratePetal(param)
        playAction(petal, param.action) --//重置后的树叶再次执行飘落动作
    end

    playAction = function(self, action)
        --随机生成花瓣横向偏移值
        local iRandPos = math.random(param.action.minX, param.action.maxX)
        --花瓣所运动到的位置
        local moveTo = cc.MoveTo:create(param.action.downtime, cc.p(iRandPos, 30))
        local actDone = cc.CallFunc:create(reset)
        local putdown = cc.Sequence:create(moveTo, actDone)
        --花瓣旋转动作
        local rotaBy1 = cc.RotateBy:create(param.action.roTime, param.action.fAngle1)
        local rotaBy2 = cc.RotateBy:create(param.action.roTime, param.action.fAngle2)
        --花瓣翻转动作
        self:setPositionZ(60) --设置深度抬高60，避免出现使用CCOrbitCamera实现空间翻转时产生错位和遮挡等问题
        local orbit = cc.OrbitCamera:create(8, 1, 0, 0, 360, 45, 0)
        --让花瓣精灵始终执行三维翻转的动作
        local fz3d = cc.RepeatForever:create(orbit) --无限循环执行叶片翻转的动作
        --用CCEaseInOut包装落叶摆动的动作，让花瓣的进入、出现更自然（淡入淡出效果）
        local ease1 = cc.EaseInOut:create(rotaBy1, 3)
        local ease2 = cc.EaseInOut:create(rotaBy2, 3)
        --摆动动作合成
        local seq2 = cc.Sequence:create(ease1, ease2)--依次执行顺时针、逆时针摆动
        local baidong = cc.Repeat:create(seq2, 1024)--摆动合成

        --动作执行:同时执行所有动作
        self:runAction(cc.Spawn:create(putdown, baidong, fz3d))
    end

    local petal = cratePetal(param.file)
    playAction(petal, param.action)
end

-- 遮罩动画
--[[
-- 参数 params 中各项为：
    {
        parent:     父节点
        maskSprite:  蒙版
        lightSprite:  刀光
        fromPos:      刀光开始位置
        toPos:        刀光结束位置
        time:         移动时间
        callback:     回调函数
        rotation:     高光图旋转
    }
]]
function ui.showMaskEffect(parmas)
    local clippingNode = cc.ClippingNode:create()
    clippingNode:setAlphaThreshold(0.5)
    parmas.parent:addChild(clippingNode)


    local blade1 = cc.Sprite:create(parmas.maskSprite)
    blade1:setPosition(0, 0)
    clippingNode:setStencil(blade1)

    --
    local light1 = cc.Sprite:create(parmas.lightSprite)
    clippingNode:addChild(light1)

    if parmas.rotation then
        light1:setRotation(parmas.rotation)
    end

    local posx, posy = blade1:getPosition()
    local actionArray = {
        cc.CallFunc:create(function() light1:setPosition(parmas.fromPos) end),
        cc.MoveTo:create(parmas.time, parmas.toPos),
        cc.CallFunc:create(function()
            if parmas.callback then parmas.callback() end
        end)
    }
    light1:runAction(cc.RepeatForever:create(cc.Sequence:create(actionArray)))

    return clippingNode
end

-- 设置控件的摇动动画
--[[
-- 参数
    waveNode: 抖动主体
    digress: 抖动角度，默认7.5
    needFlash: 是否需要背后闪光效果， 默认为 true
    flashPos: 闪光位置，可根据实际效果调节, 默认 cc.p(30, 45)
--]]
function ui.setWaveAnimation(waveNode, digress, needFlash, flashPos)
    if not waveNode then
        --dump("动作主体waveNode不存在，请检查参数!")
        return
    end

    digress = digress or 7.5
    -- 抖动效果
    local actList = {
        cc.RotateTo:create(0.1, -digress),
        cc.RotateTo:create(0.1, digress),
        cc.RotateTo:create(0.1, -digress),
        cc.RotateTo:create(0.1, digress),
        cc.RotateTo:create(0.1, -digress),
        cc.RotateTo:create(0.05, 0),
        cc.DelayTime:create(1.2),
    }
    waveNode:stopAllActions()
    waveNode:runAction(cc.RepeatForever:create(cc.Sequence:create(actList)))

    -- 光效果
    if needFlash ~= false then
        local tempSprite = waveNode.flashNode
        --if not tempSprite then
            tempSprite = cc.Sprite:create("cdjh_62.png")
            waveNode:addChild(tempSprite, -1)
            waveNode.flashNode = tempSprite
        --end

        local spawn1 = cc.Spawn:create(cc.RotateBy:create(2.0, 360),
            cc.FadeTo:create(1, 255 * 0.8))
        local spawn2 = cc.Spawn:create(cc.RotateBy:create(2.0, 360),
            cc.FadeTo:create(1, 255 * 1))

        tempSprite:stopAllActions()
        tempSprite:setPosition(flashPos or cc.p(48, 48))
        tempSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(spawn1, spawn2)))
    elseif waveNode.flashNode then
        waveNode.flashNode:removeFromParent()
        waveNode.flashNode = nil
    end
end

--注册屏蔽下层点击事件的方法
--[[
    params:
    Table params:
    {
        node: 需要屏蔽下层的结点
        allowTouch: 可选参数，是否屏蔽下层触摸
        beganEvent: 可选参数，TOUCH_BEGAN事件回调
        movedEvent: 可选参数，TOUCH_MOVED事件回调
        endedEvent: 可选参数，TOUCH_ENDED事件回调
        cancellEvent: 可选参数，TOUCH_CANCELLED事件回调
    }
--]]
function ui.registerSwallowTouch(params)
    local allowTouch = params.allowTouch ~= false

    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(allowTouch)
    listenner:registerScriptHandler(function(touch, event)
        if params.beganEvent then
            return params.beganEvent(touch, event)
        end
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
        if params.movedEvent then
            params.movedEvent(touch, event)
        end
    end,cc.Handler.EVENT_TOUCH_MOVED )
    listenner:registerScriptHandler(function(touch, event)
        if params.endedEvent then
            params.endedEvent(touch, event)
        end
    end,cc.Handler.EVENT_TOUCH_ENDED )
    listenner:registerScriptHandler(function()
        if params.cancellEvent then
            params.cancellEvent(touch, event)
        end
    end,cc.Handler.EVENT_TOUCH_CANCELLED)


    local eventDispatcher = params.node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, params.node)
    return listenner
end

-- 判断点击位置是否在某node对象内
--[[
-- 参数
    touch: 屏幕点击位置对象
    node: 需要判断的node
]]
function ui.touchInNode(touch, node)
    if not touch or tolua.isnull(node) then
        return false
    end
    local parentNode = node:getParent()
    if not parentNode then
        return false
    end

    local nodePos = parentNode:convertToWorldSpace(cc.p(node:getPosition()))
    local nodeSize = node:getContentSize()
    local nodeAnchor = cc.p(node:getAnchorPoint())
    local scaleX, scaleY = node:getScaleX(), node:getScaleY()
    local tempRect = cc.rect(
        nodePos.x - nodeSize.width * nodeAnchor.x * scaleX,
        nodePos.y - nodeSize.height * nodeAnchor.y * scaleY,
        nodeSize.width * scaleX,
        nodeSize.height * scaleY
    )
    return cc.rectContainsPoint(tempRect, touch:getLocation())
end

-- 全屏屏蔽页
function ui.createSwallowLayer(opacity)
    local layout = display.newLayer(cc.c4b(0, 0, 0, opacity or 0))
    layout:setContentSize(640, 1136)
    layout:setAnchorPoint(0, 0)
    layout:setPosition(0, 0)
    ui.registerSwallowTouch({node = layout})
    return layout
end

-- 显示已领取奖励的窗体
--[[
-- 参数
    baseGetGameResourceList： 服务端返回的基础掉落标准结构数据
    isFlashStyle: 是否飘窗样式，默认为true
    isTouchEnable: 是否点击空白区域移除飘窗
    time: 飘窗停留时间
 ]]
function ui.ShowRewardGoods(baseGetGameResourceList, isFlashStyle, isTouchEnable, time, callBack)
    if not baseGetGameResourceList then
        return
    end

    if isFlashStyle ~= false then
        -- 因为获取物品的页面需要显示在新手引导页面的上面，所以需要设置ZOrder，
        -- 如果使用“LayerManager.addLayer”，设置之后会影响后续addLayer的ZOrder，导致后面添加layer的ZOrder比新手引导页面的大
        -- 所以该页面不用LayerManager管理
        local currScene = LayerManager.getMainScene()
        local tempData = {baseDrop = baseGetGameResourceList, isTouchEnable = isTouchEnable, stayTime = time, endCallBack = callBack}
        local newLayer = require("commonLayer.FlashDropLayer").new(tempData)
        currScene:addChild(newLayer, Enums.ZOrderType.eDrapReward)
    else
        MsgBoxLayer.addGameDropLayer(baseGetGameResourceList, nil, TR("获得以下物品"), TR("奖励"))
    end
end

-- 显示已领取奖励的飘窗窗体
--[[
-- 参数
    resourceList: 自定义物品列表
    isTouchEnable: 是否点击空白区域移除飘窗
    time: 飘窗停留时间
 ]]
function ui.ShowRewardFlash(resourceList, isTouchEnable, time, callBack)
    if not resourceList then
        return
    end

    -- 因为获取物品的页面需要显示在新手引导页面的上面，所以需要设置ZOrder，
    -- 如果使用“LayerManager.addLayer”，设置之后会影响后续addLayer的ZOrder，导致后面添加layer的ZOrder比新手引导页面的大
    -- 所以该页面不用LayerManager管理
    local currScene = LayerManager.getMainScene()
    local tempData = {resourceList = resourceList, isTouchEnable = isTouchEnable, stayTime = time, endCallBack = callBack}
    local newLayer = require("commonLayer.FlashDropLayer").new(tempData)
    currScene:addChild(newLayer, Enums.ZOrderType.eDrapReward)
end

-- 创建显示物品卡牌列表的
--[[
-- 参数 params 中的各项为：
    {
        maxViewWidth = 300, -- 显示的最大宽度
        viewHeight = 120, -- 显示的高度，默认为120
        space = 10, -- 卡牌之间的间距, 默认为 10
        cardDataList = {
            {
                resourceTypeSub = nil, -- 资源类型
                modelId = nil,  -- 模型Id
                num = nil, -- 资源数量
                instanceData = {}, -- 卡牌的具体数据
                needGray: 是否需要显示为灰色， 默认为false
                cardShowAttrs = {}, -- 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合
                onClickCallback = nil, --点击回调函数，默认为卡牌点击展示其属性
            },
        }
        cardShape: 卡牌的形状，取值在Enums.lua 文件的 Enums.CardShape中定义，默认为：Enums.CardShape.eSquare
        cardNameColor = nil, -- 卡牌名字的颜色，默认为: Enums.Color.eCoffee
        allowClick = false, --是否可点击, 默认为false
        isSwallow = true    --listView是否吞噬事件，默认为true 吞噬

        needAction = false, -- 是否需要动画显示列表, 默认为false
        needArrows = false, -- 当需要滑动显示时是否需要左右箭头, 默认为false
    }
-- 返回值 node 对象，并且提供 node.getCardNodeList() 函数 和 node.refreshList(cardDataList) 函数
]]
function ui.createCardList(params)
    local cellSize = cc.size(120, params.viewHeight or 120)
    local cardSize = ui.getImageSize("c_04.png")
    local space = params.space or 0
    local maxViewWidth = params.maxViewWidth or 300
    local swallow = params.isSwallow == nil and true or params.isSwallow

    local ret = ccui.Layout:create()
    ret:setIgnoreAnchorPointForPosition(false)

    --
    local cardNodeList = {}
    -- 刷新数据函数
    ret.refreshList = function(cardDataList)
        ret:removeAllChildren()
        cardNodeList = {}

        local cardCount = cardDataList and #cardDataList or 0
        local tempWidth = cardCount * (cellSize.width + space) - space
        local viewSize = cc.size(math.min(tempWidth, maxViewWidth), cellSize.height)
        ret:setContentSize(viewSize)
        local needListView = tempWidth > viewSize.width

        -- 如果最大显示宽度不能显示所有cardnode，则需要滑动
        local listView
        if needListView then
            listView = ccui.ListView:create()
            listView:setDirection(ccui.ScrollViewDir.horizontal)
            listView:setItemsMargin(space)
            listView:setBounceEnabled(true)
            listView:setSwallowTouches(swallow)
            listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
            listView:setContentSize(viewSize)
            ret:addChild(listView)
        end

        local cardPosY = cellSize.height - cardSize.height / 2
        for index, item in ipairs(cardDataList or {}) do
            local tempParent, tempPos
            if needListView then
                tempParent = ccui.Layout:create()
                tempParent:setContentSize(cellSize)
                listView:pushBackCustomItem(tempParent)

                tempPos = cc.p(cellSize.width / 2, cardPosY)
            else
                tempParent = ret
                tempPos = cc.p(cellSize.width / 2 + (index - 1) * (cellSize.width + space), cardPosY)
            end
            -- 创建卡牌
            local tempCard = CardNode:create({
                cardShape = params.cardShape,
                allowClick = params.allowClick,
                nameColor = params.cardNameColor,
                onClickCallback = params.onClickCallback,
            })
            tempCard:setCardData(item)
            tempCard:setPosition(tempPos)
            tempParent:addChild(tempCard)
            table.insert(cardNodeList, tempCard)
        end

        -- 如果需要动画效果
        if params.needAction and #cardNodeList > 0 then
            for _, cardNode in pairs(cardNodeList) do
                cardNode:setVisible(false)
            end

            local index = 1
            Utility.schedule(ret, function()
                if index > #cardNodeList then
                    ret:stopAllActions()
                    return
                end

                local tempCard = cardNodeList[index]
                tempCard:setVisible(true)
                tempCard:setScale(1.3)
                local actionList = {
                    cc.ScaleTo:create(1/30 * 7, 0.7),
                    cc.ScaleTo:create(1/30 * 2, 1.0),
                }
                if needListView then
                    table.insert(actionList, cc.CallFunc:create(function()
                        local tempWidth = (index - 1) * (cellSize.width + space) - space
                        if tempWidth > viewSize.width then
                            listView:getInnerContainer():setPositionX(viewSize.width - tempWidth)
                        end
                    end))
                end
                tempCard:runAction(cc.Sequence:create(actionList))
                index = index + 1
            end, 0.3)
        end

        -- 如果需要左右箭头
        if params.needArrows and needListView then
            -- 左箭头
            local leftSprite = ui.newSprite("c_26.png")
            leftSprite:setPosition(-5, cellSize.height - cardSize.height / 2)
            leftSprite:setScaleX(-1)
            ret:addChild(leftSprite)

            -- 右箭头
            local rightSprite = ui.newSprite("c_26.png")
            rightSprite:setPosition(params.maxViewWidth+5, cellSize.height - cardSize.height / 2)
            ret:addChild(rightSprite)
        end
    end
    ret.refreshList(params.cardDataList)

    ret.getCardNodeList = function()
        return cardNodeList
    end

    return ret
end

-- 屏蔽层的引用计数
local lockCounter = 0

function ui.lockLayer()
    LayerManager.showLoading()
    lockCounter = lockCounter + 1
    --dump(lockCounter, "添加屏蔽页面=")
end

function ui.unlockLayer()
    lockCounter = lockCounter - 1
    if lockCounter == 0 then
        --dump(lockCounter, "移除屏蔽页=")
        LayerManager.hideLoading()
    else
        --dump(lockCounter, "lockCounter=")
    end
end

-- 创建列表为空时的提示信息
--[[
-- 参数
    hintStr: 提示信息，可以是文字，也可以是图片名
-- 返回值
    第一个参数是提示信息的背景图，
    第二个参数是显示提示信息的控件，如果传入参数为文字，则是 label；如果传入参数为图片名，则是 sprite
]]
function ui.createEmptyHint(hintStr)
    local tempContentSprite = ui.newSprite("c_84.png")
    local bgSize = tempContentSprite:getContentSize()
    local hintNode
    -- 提示信息
    if string.isImageFile(hintStr) then
        hintNode = ui.newSprite(hintStr)
        hintNode:setPosition(bgSize.width / 2, 85)
        tempContentSprite:addChild(hintNode)
    else
        hintNode = ui.newLabel({
            text = hintStr,
            size = 22,
            color = Enums.Color.eNormalWhite,
            outlineColor = Enums.Color.eBlack,
            align = cc.TEXT_ALIGNMENT_CENTER,
            dimensions = cc.size(250, 0),
        })
        hintNode:setAnchorPoint(cc.p(0, 0.5))
        hintNode:setPosition(bgSize.width * 0.1, 70)
        tempContentSprite:addChild(hintNode)
    end

    return tempContentSprite, hintNode
end

-- 创建与设计尺寸相同大小的Layer，并设置在设计尺寸的位置 （640, 1136）
-- 并对该node左分辨率适配处理
function ui.newStdLayer()
    local tempLayer = display.newLayer()
    tempLayer:setContentSize(cc.size(640, 1136))
    tempLayer:setPosition(display.cx, display.cy)
    tempLayer:setIgnoreAnchorPointForPosition(false)
    tempLayer:setAnchorPoint(cc.p(0.5, 0.5))
    tempLayer:setScale(Adapter.MinScale)

    return tempLayer
end

-- 创建title栏中玩家物品数量显示（比如页面顶部的体力、耐力、铜币、元宝....）
--[[
-- 参数
    resourcetypeSub: 资源子类型，一般是玩家属性，如果传入其他类型则需要对应的ModelId
    needAddBtn: 是否需要获取该物品的添加按钮
    modelId: 模型Id
]]
function ui.createResCount(resourcetypeSub, needAddBtn, modelId)
    -- 是否需要显示最大值
    local needMaxRes = {
        [ResourcetypeSub.eVIT] = true, -- 体力
        [ResourcetypeSub.eSTA] = true, -- 耐力
    }
    local needViewMax = needMaxRes[resourcetypeSub] or false

    local bgSize = ui.getImageSize("c_23.png")
    -- 用于返回的node
    local retNode = cc.Node:create()
    retNode:setContentSize(bgSize)
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setAnchorPoint(cc.p(0.5, 0.5))

    local tempSprite = ui.newSprite("c_23.png")
    tempSprite:setPosition(bgSize.width / 2, bgSize.height / 2)
    retNode:addChild(tempSprite)

    if needAddBtn and (not Utility.isNeedShield()) then
        -- 添加点击按钮
        local tempBtn = ui.newButton({
            normalImage = "sy_31.png",
            clickAction = function()
                if resourcetypeSub == ResourcetypeSub.eDiamond then  -- 元宝
                    LayerManager.showSubModule(ModuleSub.eCharge)
                elseif resourcetypeSub == ResourcetypeSub.eGold then -- 铜币
                    MsgBoxLayer.addGetGoldHintLayer()
                end
            end
        })
        tempBtn:setPosition(bgSize.width, bgSize.height / 2)
        retNode:addChild(tempBtn)
    end

    -- 物品图片标识
    local tempStr = Utility.getDaibiImage(resourcetypeSub, modelId)
    tempSprite = ui.newSprite(tempStr)
    tempSprite:setAnchorPoint(cc.p(1, 0.5))
    tempSprite:setPosition(30, bgSize.height / 2)
    retNode:addChild(tempSprite)

    -- 物品数量的label
    local tempLabel = ui.newLabel({
        text = "",
        size = 18,
        color = Enums.Color.eWhite,
    })
    tempLabel:setAnchorPoint(cc.p(0, 0.5))
    tempLabel:setPosition(30, bgSize.height / 2)
    retNode:addChild(tempLabel)
    retNode.Label = tempLabel
    local function setLabelStr()
        if Utility.isGoods(resourcetypeSub) then
            local tempCount = GoodsObj:getCountByModelId(modelId)
            tempLabel:setString(Utility.numberWithUnit(tempCount))
        else
            local tempCount = PlayerAttrObj:getPlayerAttr(resourcetypeSub)
            if needViewMax then
                local maxCount = 999
                if ResourcetypeSub.eVIT == resourcetypeSub then  -- 体力
                    maxCount = VitConfig.items[1].maxNum
                elseif ResourcetypeSub.eSTA == resourcetypeSub then  -- 耐力
                    maxCount = PlayerAttrObj:getPlayerAttrByName("STAMaxNum")
                end
                tempLabel:setString(string.format("%s/%d", Utility.numberWithUnit(tempCount), maxCount))
            else
                tempLabel:setString(Utility.numberWithUnit(tempCount))
            end
        end
    end
    setLabelStr()
    -- 自动刷新注册
    local eventName, maxEventName
    if Utility.isGoods(resourcetypeSub) then
        eventName = EventsName.ePropRedDotPrefix .. tostring(modelId)
    else
        eventName = EventsName.getNameByResType(resourcetypeSub)
        if ResourcetypeSub.eSTA == resourcetypeSub then  -- 耐力
            maxEventName = EventsName.ePropRedDotPrefix .. EventsName.eSTAMaxNum
        end
    end
    if eventName then
        Notification:registerAutoObserver(tempLabel, setLabelStr, {eventName, maxEventName})
    end

    return retNode
end

-- 创建SliderTableView, 参数请参考SliderTableView内定义
function ui.newSliderTableView(params)
    return require("common.SliderTableView").new(params)
end

-- 创建TabLayer, 参数请参考TabView内定义
function ui.newTabLayer(params)
    return require("common.TabView").new(params)
end

-- 获取控件在屏幕中的区域
function ui.getControlWorldSpaceRect(aNode)
    local ret = cc.rect(0, 0, 0, 0)
    if not aNode or not aNode:getParent() then
        print("ui.getControlWorldSpaceRect aNode is nil, so return nil")
        return nil
    end

    local scene = display.getRunningScene()

    local nodePos = aNode:getParent():convertToWorldSpace(cc.p(aNode:getPosition()))
    local nodeAnchorPoint = cc.p(aNode:getAnchorPoint())
    local nodeSize = aNode:getContentSize()

    local nodeScaleX, nodeScaleY = 1, 1
    local n = aNode
    repeat
        local x, y = n:getScaleX(), n:getScaleY()
        nodeScaleX = nodeScaleX * x
        nodeScaleY = nodeScaleY * y

        n = n:getParent()
    until (n == nil or n == scene)

    ret.width = nodeSize.width * nodeScaleX
    ret.height = nodeSize.height * nodeScaleY
    ret.x = nodePos.x - ret.width * nodeAnchorPoint.x
    ret.y = nodePos.y - ret.height * nodeAnchorPoint.y

    return ret
end

--- 获取控件的根父控件
function ui.getNodeRootParent(node)
    if not node then
        return nil
    end
    local ret = node:getParent()
    while ret do
        local tempParent = ret:getParent()
        if tempParent then
            ret = tempParent
        else
            break
        end
    end
    return ret
end

-- 创建一个属性的标题函数（样式为：“图片 提示文字 图片”）
--[[
-- 参数 params 中的各项为：
    {
        leftImg: 左边的图片
        rightImg: 右边的图片，默认使用 leftImg X方向反转
        titleStr: 提示信息
        color: 提示信息的颜色
        outlineColor: 提示信息的描边颜色
        fontSize: 字体大小
    }
]]
function ui.createAttrTitle(params)
    params = params or {}
    local retNode = display.newNode()
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setAnchorPoint(cc.p(0.5, 0.5))

    local tempLabel = ui.newLabel({
        text = params.titleStr,
        color = params.color or Enums.Color.eBrown,
        size = params.fontSize,
        outlineColor = params.outlineColor
    })
    tempLabel:setAnchorPoint(cc.p(0, 0.5))
    retNode:addChild(tempLabel)

    --
    local leftSprite = ui.newSprite(params.leftImg)
    retNode:addChild(leftSprite)
    --
    local rightSprite = ui.newSprite(params.rightImg or params.leftImg)
    if not params.rightImg or params.rightImg == "" then
        rightSprite:setScaleX(-1)
    end
    retNode:addChild(rightSprite)

    local labelSize = tempLabel:getContentSize()
    local leftSize = leftSprite:getContentSize()
    local rightSize = rightSprite:getContentSize()
    local tempSize = cc.size(labelSize.width + leftSize.width + rightSize.width + 20,
        math.max(labelSize.height, leftSize.height, rightSize.height))
    retNode:setContentSize(tempSize)
    leftSprite:setPosition(leftSize.width / 2, tempSize.height / 2)
    tempLabel:setPosition(leftSize.width + 10, tempSize.height / 2)
    rightSprite:setPosition(tempSize.width - rightSize.width / 2, tempSize.height / 2)

    return retNode
end

-- 创建外功秘籍的属性雷达图
--[[
-- 参数
    pet     -- 可选参数，外功秘籍实例Id 或实例对象
            -- 为空则创建属性样品草图
--]]
function ui.createPetRadarChart(pet)
    -- 根据实例Id获取外功秘籍相关信息
    local petInfo = type(pet) == "table" and pet or PetObj:getPet(pet)
    -- 不是外功秘籍实体，则返回一个属性草图
    if not petInfo or not Utility.isEntityId(petInfo.Id) then
        -- 背景图
        local bgSprite = ui.newSprite("cw_16.png")
        local bgSize = bgSprite:getContentSize()

        -- 属性线条
        local hpPos = cc.p(-0.5 * 93, 0)
        local apPos = cc.p(0, 0.5 * 93)
        local defPos = cc.p(0, -0.5 * 93)
        local spdPos = cc.p(0.5 * 93, 0)
        local points = {hpPos, apPos, spdPos, defPos}

        local drawNode = cc.DrawNode:create()
        drawNode:setPosition(bgSize.width * 0.5 - 6, bgSize.height * 0.5)
        bgSprite:addChild(drawNode)
        drawNode:drawPolygon(points, #points, cc.c4f(1, 1, 1, 0), 2, cc.c4f(223 / 255, 87 / 255, 40 / 255, 1))

        return bgSprite
    end

    -- 背景图
    local bgSprite = ui.newSprite("cw_2.png")
    local bgSize = bgSprite:getContentSize()

    -- 显示雷达图
    local hpPos = cc.p(-petInfo.PetHPQua / 1000 * 93, 0)
    local apPos = cc.p(0, petInfo.PetAPQua / 1000 * 93)
    local defPos = cc.p(0, -petInfo.PetDEFQua / 1000 * 93)
    local spdPos = cc.p(petInfo.PetFSPQua / 1000 * 93, 0)
    local points = {hpPos, apPos, spdPos, defPos}

    local drawNode = cc.DrawNode:create()
    drawNode:setPosition(bgSize.width * 0.5 - 6, bgSize.height * 0.5)
    bgSprite:addChild(drawNode)
    drawNode:drawPolygon(points, #points, cc.c4f(1, 1, 1, 0), 2, cc.c4f(223 / 255, 87 / 255, 40 / 255, 1))

    -- 显示数字
    local numberItems = {
        [1] = {value = petInfo.PetHPQua,  pos = cc.p(hpPos.x, 0)},
        [2] = {value = petInfo.PetAPQua,  pos = cc.p(0, apPos.y)},
        [3] = {value = petInfo.PetDEFQua, pos = cc.p(0, defPos.y)},
        [4] = {value = petInfo.PetFSPQua, pos = cc.p(spdPos.x, 0)}
    }
    local halfWidth, halfHeight = bgSize.width * 0.5, bgSize.height * 0.5
    for i, v in ipairs(numberItems) do
        local tmpX, tmpY = v.pos.x, v.pos.y
        local posX, posY = tmpX, tmpY
        if (tmpX ~= 0) then
            if (math.abs(tmpX) < 10) then
                if (posX > 0) then
                    posX = tmpX + 20
                else
                    posX = tmpX - 20
                end
            elseif (math.abs(tmpX) > 83) then
                if (posX > 0) then
                    posX = tmpX - 20
                else
                    posX = tmpX + 20
                end
            end
        end
        if (tmpY ~= 0) then
            if (math.abs(tmpY) < 10) then
                if (posY > 0) then
                    posY = tmpY + 20
                else
                    posY = tmpY - 20
                end
            elseif (math.abs(tmpY) > 83) then
                if (posY > 0) then
                    posY = tmpY - 20
                else
                    posY = tmpY + 20
                end
            end
        end

        local textColor = (params and params.textColor) and params.textColor or cc.c3b(3, 115, 19)
        local label = ui.newLabel({
            text = v.value,
            color = textColor,
            align = ui.TEXT_ALIGN_CENTER
        })
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPosition(posX + halfWidth - 6, posY + halfHeight)
        bgSprite:addChild(label)
    end

    return bgSprite
end

-- 设置listview的某个条目在显示区域类型
--[[
-- 参数
    listView: listView对象
    itemIndex: 需要设置到显示区域item的index，编号从 1 开始计数
]]
function ui.setListviewItemShow(listView, itemIndex)
    if tolua.isnull(listView) then
        return
    end
    local itemNode = listView:getItem(itemIndex - 1)
    if tolua.isnull(itemNode) then
        return
    end
    local listSize = listView:getContentSize()
    local itemSize = itemNode:getContentSize()
    -- local itemPos = listView:convertToNodeSpace(cc.p(itemNode:getPosition()))
    local itemPos = cc.p(itemNode:getPosition())
    local itemAnchor = itemNode:getAnchorPoint()
    local direction = listView:getDirection()

    local tempWidthMax = itemPos.x + itemSize.width * (1 - itemAnchor.x)
    local tempWidthMin = itemPos.x - itemSize.width * itemAnchor.x
    local tempHeightMax = itemPos.y +  itemSize.height * (1 - itemAnchor.y)
    local tempHeightMin = itemPos.y -  itemSize.height * itemAnchor.y

    if direction == ccui.ScrollViewDir.horizontal then
        print("itemAnchor.x  == "..itemAnchor.x)
        print("tempWidthMax == "..tempWidthMax.." listSize.width == "..listSize.width.." tempWidthMin == "..tempWidthMin)
        if tempWidthMax > listSize.width or tempWidthMin <= 0 then
            listView:forceDoLayout()

            local percentX = 0
            if tempWidthMax > listSize.width then
                percentX = (listSize.width - itemSize.width * (1 - itemAnchor.x)) / listSize.width
            else
                percentX = itemSize.width * itemAnchor.x / listSize.width
            end
            listView:jumpToItem(itemIndex - 1, cc.p(percentX, 0), itemAnchor)
        end

    elseif direction == ccui.ScrollViewDir.vertical then
        if tempHeightMax > listSize.height or tempHeightMin <= 0 then
            listView:forceDoLayout()

            local percentY = 0
            if tempHeightMax > listSize.height then
                percentY = (listSize.height - itemSize.height * (1 - itemAnchor.y)) / listSize.height
            else
                percentY = itemSize.height * itemAnchor.y / listSize.height
            end
            listView:jumpToItem(itemIndex - 1, cc.p(0, percentY), itemAnchor)
        end
    end
end

-- 创建战力显示
--[[
-- 参数
    FAP: 需要显示的战力值
    needPlus: 是否需要显示加减号
-- 返回值
    第一个返回值：显示战力值背景 sprite ，该对象提供函数 retSprite.setFAP(newFAP)
    第二个返回值：显示战力值的label
]]
function ui.newFAPView(FAP, needPlus)
    -- 创建卡槽的战力
    local FAPBgSprite = ui.newSprite("c_53.png")
    local FAPLabel = ui.newLabel({
        text = "",
        size = 24,
        outlineColor = Enums.Color.eOutlineColor,
    })
    FAPLabel:setAnchorPoint(cc.p(0.5, 0.5))
    FAPLabel:setPosition(130, 28)
    FAPBgSprite:addChild(FAPLabel)

    -- 重新设置显示的战力值
    FAPBgSprite.setFAP = function(newFAP)
        if type(newFAP) == "string" then
            FAPLabel:setString(newFAP)
        else
            local tempStr = Utility.numberFapWithUnit(newFAP or 0, nil, needPlus)
            FAPLabel:setString(tempStr)
        end
    end
    FAPBgSprite.setFAP(FAP)

    return FAPBgSprite, FAPLabel
end

-- 创建带背景的字符串角标
--[[
-- 参数
    imgFile: 角标背景
    hintText: 角标的提示文字
    hintColor: 提示文字的颜色, 默认为 Enums.Color.eYellow
    hintSize: 提示文字的大小，默认为 18
    hintPos: 提示文字想对与背景图片等位置，默认为：cc.p(27, 47)
    outColor:文字的描边颜色,默认为Enums.Color.eOutlineColor
-- 返回值
    第一个：sprite对象
    第二个：label对象
]]
function ui.createStrImgMark(imgFile, hintText, hintColor, hintSize, hintPos, outColor)
    -- 标签的背景
    local tempSprite = ui.newSprite(imgFile ~= "" and imgFile or "c_62.png")
    -- 标签的label
    local tempLabel = ui.newLabel({text = hintText,
        color = hintColor or Enums.Color.eWhite,
        size = hintSize or 18,
        outlineColor = outColor or cc.c3b(0xea, 0x30, 0x0b),
        outlineSize = 2,
    })
    tempLabel:setPosition(hintPos or cc.p(27, 47))
    tempLabel:setRotation(-45)
    tempSprite:addChild(tempLabel)

    return tempSprite, tempLabel
end

-- 创建试登录暗门控件
--[[
-- 密码：4个4
]]
function ui.createTestTrapdoor()
    local testLayer = ui.newStdLayer()

    local initBeginTime, initTouchIndex = 0, 1
    local beginTouchTime = initBeginTime
    local touchIndex = initTouchIndex  -- 点击位置序号信息
    -- 判断点击区域是否在当前暗门点击区域内
    local function touchInTrapdoorRect(touch)
        local tempIndex = touchIndex - initTouchIndex + 1
        local tempRect = {}
        if tempIndex < 5 then
            tempRect = cc.rect(0, 1016, 120, 120)
        elseif tempIndex < 9 then
            tempRect = cc.rect(520, 1016, 120, 120)
        elseif tempIndex < 13 then
            tempRect = cc.rect(520, 0, 120, 120)
        elseif tempIndex < 17 then
            tempRect = cc.rect(0, 0, 120, 120)
        else
            return false
        end

        local touchPos = testLayer:convertToNodeSpace(touch:getLocation()) -- 当前点击的位置
        return cc.rectContainsPoint(tempRect, touchPos)
    end

    --
    ui.registerSwallowTouch({
        node = testLayer,
        allowTouch = false,
        beganEvent = function(touch, event)
            if not touchInTrapdoorRect(touch) then
                beginTouchTime = initBeginTime
                touchIndex = initTouchIndex
                return false
            end
            if beginTouchTime == initBeginTime then
                beginTouchTime = os.time()
            end

            return true
        end,
        endedEvent = function(touch, event)
            -- 暗门点击事件需在一分钟内完成
            if os.time() > beginTouchTime + 30 then -- 超时了，之前输入的都不算了
                beginTouchTime = initBeginTime
                touchIndex = initTouchIndex
                return
            end

            touchIndex = touchIndex + 1
            if touchIndex == initTouchIndex + 16 then  -- 输入暗门成功
                beginTouchTime = initBeginTime
                touchIndex = initTouchIndex

                -- 打开试登录页面
                LayerManager.addLayer({name = "login.TestLoginLayer",})
            end
        end,
    })

    return testLayer
end

-- 创建打开调试信息开关页面
--[[
-- 密码：4个5
]]
function ui.createDebugLayer()
    local testLayer = ui.newStdLayer()

    local initBeginTime, initTouchIndex = 0, 1
    local beginTouchTime = initBeginTime
    local touchIndex = initTouchIndex  -- 点击位置序号信息
    -- 判断点击区域是否在当前暗门点击区域内
    local function touchInTrapdoorRect(touch)
        local tempIndex = touchIndex - initTouchIndex + 1
        local tempRect = {}
        if tempIndex < 6 then
            tempRect = cc.rect(0, 1016, 120, 120)
        elseif tempIndex < 11 then
            tempRect = cc.rect(520, 1016, 120, 120)
        elseif tempIndex < 16 then
            tempRect = cc.rect(520, 0, 120, 120)
        elseif tempIndex < 21 then
            tempRect = cc.rect(0, 0, 120, 120)
        else
            return false
        end

        local touchPos = testLayer:convertToNodeSpace(touch:getLocation()) -- 当前点击的位置
        return cc.rectContainsPoint(tempRect, touchPos)
    end

    --
    ui.registerSwallowTouch({
        node = testLayer,
        allowTouch = false,
        beganEvent = function(touch, event)
            if not touchInTrapdoorRect(touch) then
                beginTouchTime = initBeginTime
                touchIndex = initTouchIndex
                return false
            end
            if beginTouchTime == initBeginTime then
                beginTouchTime = os.time()
            end

            return true
        end,
        endedEvent = function(touch, event)
            -- 暗门点击事件需在一分钟内完成
            if os.time() > beginTouchTime + 40 then -- 超时了，之前输入的都不算了
                beginTouchTime = initBeginTime
                touchIndex = initTouchIndex
                return
            end

            touchIndex = touchIndex + 1
            if touchIndex == initTouchIndex + 20 then  -- 输入暗门成功
                beginTouchTime = initBeginTime
                touchIndex = initTouchIndex

                -- 打开调试信息开关页面
                require("commonLayer.MsgBoxLayer")
                require("Guide.GuideInit")
                MsgBoxLayer.addDIYLayer({
                    title = TR("提示"),
                    msgText = TR("勾选选中框打开调试信息开关"),
                    needTouchClose = true,
                    closeBtnInfo = {},
                    btnInfos = {},
                    DIYUiCallback = function(layerObj, bgSprite, bgSize)
                        -- 重新设置提示信息的位置
                        layerObj.mMsgLabel:setPositionY(bgSize.height - 100)

                        -- 打开调试信息开关按钮
                        local checkBox = ui.newCheckbox({
                            normalImage = "c_60.png",
                            selectImage = "c_61.png",
                            text = TR("打开调试信息"),
                            textColor = Enums.Color.eDarkGreen,
                        })
                        checkBox:setCheckState(ShowTracebackMsg)
                        checkBox:setPosition(bgSize.width * 0.5, bgSize.height * 0.58)
                        bgSprite:addChild(checkBox)

                        -- 跳过引导开关
                        local guideCheckBox = ui.newCheckbox({
                            normalImage = "c_60.png",
                            selectImage = "c_61.png",
                            text = TR("跳过主引导"),
                            textColor = Enums.Color.eDarkGreen,
                        })
                        guideCheckBox:setCheckState(not Guide.config.IF_OPEN)
                        guideCheckBox:setPosition(bgSize.width * 0.5, bgSize.height * 0.43)
                        bgSprite:addChild(guideCheckBox)

                        -- 确定按钮
                        local tempBtn = ui.newButton({
                            normalImage = "c_28.png",
                            text = TR("确定"),
                            clickAction = function()
                                ShowTracebackMsg = checkBox.getCheckState()
                                Guide.config.IF_OPEN = not guideCheckBox.getCheckState()
                                LayerManager.removeLayer(layerObj)
                            end
                        })
                        tempBtn:setPosition(bgSize.width * 0.5, 60)
                        bgSprite:addChild(tempBtn)
                    end
                })
            end
        end,
    })

    return testLayer
end

-- 创建一个带标题的Node背景
--[[
-- 参数
    parent: 必选参数，父窗体
    size: 必选参数，背景框大小
    title: 可选参数，标题文字
    pos: 可选参数，显示位置
    anchor: 可选参数，锚点设置
-- 返回值
    第一个返回值：创建好的背景框
    第二个返回值：创建好的文字Label
]]
function ui.newNodeBgWithTitle(parent, size, title, pos, anchor)
    local bgMinSize = ui.getImageSize("c_54.png")
    local tmpBgSize = size
    if (tmpBgSize.width < bgMinSize.width) then
        tmpBgSize.width = bgMinSize.width
    end
    if (tmpBgSize.height < bgMinSize.height) then
        tmpBgSize.height = bgMinSize.height
    end

    -- 显示背景
    local tempTitleLabel = nil
    local tempBgSprite = ui.newScale9Sprite("c_54.png", tmpBgSize)
    if (anchor ~= nil) then
        tempBgSprite:setAnchorPoint(anchor)
    end
    if (pos ~= nil) then
        tempBgSprite:setPosition(pos)
    end
    tempBgSprite.rawText = title or ""
    tempBgSprite.clearAllChildren = function (target)
        target:removeAllChildren()

        -- 显示标题
        tempTitleLabel = ui.newLabel({
            text = target.rawText,
            size = 24,
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x72, 0x25, 0x13),
            outlineSize = 2,
        })
        tempTitleLabel.rawText = target.rawText
        tempTitleLabel:setPosition(tmpBgSize.width / 2, tmpBgSize.height - 22)
        tempBgSprite:addChild(tempTitleLabel)
    end
    tempBgSprite:clearAllChildren()
    parent:addChild(tempBgSprite)

    return tempBgSprite, tempTitleLabel
end

-- 执行弹出动画（多用于对话框）
function ui.showPopAction(parent, time)
    local oldScale = parent:getScale()
    parent:setScale(0)
    parent:runAction(cc.ScaleTo:create((time or 0.2), oldScale))
    -- 弹出框添加统一音效
    MqAudio.playEffect("tanchuang_open.mp3")
end

-- ListView控件中条目改变后，恢复到原来的显示位置
function ui:restoreListViewPos(listViewObj, oldInnerSize, oldInnerPos)
    -- 如果原来的位置就在对底部，那列表数据改变后还是需要在底部
    if oldInnerPos.y > -5 then  -- 5像素的误差
        listViewObj:jumpToBottom()
        return
    end

    listViewObj:doLayout()
    local listViewSize = listViewObj:getContentSize()
    local newInnerSize = listViewObj:getInnerContainerSize()
    local newInnerPos = cc.p(oldInnerPos.x, oldInnerPos.y - (newInnerSize.height - oldInnerSize.height))
    newInnerPos.y = math.max(listViewSize.height - newInnerSize.height, math.min(0, newInnerPos.y))
    listViewObj:setInnerContainerPosition(newInnerPos)
end

-- 添加手指和光圈特效
-- pos: 手指和光圈位置
-- showCircle: 是否显示光圈，默认为true
function ui.addGuideArrowEffect(parent, pos, showCircle)
    -- 点击提示光圈
    if showCircle ~= false then
        local flashCircle = ui.newEffect({
            parent     = parent,
            position   = pos,
            effectName = "effect_ui_xinshouyindao",
            animation  = "dianji",
            loop       = true,    -- 是否循环显示
            endRelease = false
        })
    end
    -- 添加手指
    local arrowSprite = ui.newSprite("xsyd_02.png")
    arrowSprite:setAnchorPoint(cc.p(0.05, 1))
    arrowSprite:setPosition(pos)
    -- 新手引导时，手指大小适配
    arrowSprite:setScale(showCircle and Adapter.MinScale or 1)
    parent:addChild(arrowSprite)

    local scaleAction = cc.RepeatForever:create(
        cc.Sequence:create(
            cc.ScaleBy:create(0.3, 1.2),
            cc.ScaleBy:create(0.3, 0.8333333)
        )
    )
    arrowSprite:runAction(scaleAction)
    return arrowSprite
end

--创建线段
--[[
    参数：startPoint: 起始点
        endPoint: 终点
        color:颜色 (cc.c4f(0, 0, 0, 1))
    返回值 line节点
--]]
function ui.createLine(startPoint, endPoint, color)
    local line = cc.DrawNode:create()
    line:setPosition(startPoint)
    local endPosInNode = line:convertToNodeSpace(endPoint)
    line:drawSegment(cc.p(0, 0), endPosInNode, 3, color)

    return line
end

-- 创建人物转生等级
--[[
-- 参数
    rebornLvModelId: 转身等级模型Id，取值为 RebornLvModel 配置表的ID字段
-- 返回值
    node: 可调用 node.setLevel(lvModelId) 重新设置
]]
function ui.createRebornLevel(rebornLvModelId)
    -- 背景
    local retSprite = ui.newSprite("jm_30.png")

    retSprite.setLevel = function(lvModelId)
        retSprite:removeAllChildren()

        local rebornLvModel = RebornLvModel.items[lvModelId]
        retSprite:setVisible(rebornLvModel ~= nil)
        if not rebornLvModel then
            return 
        end
        -- 背景图的大小
        local bgSize = retSprite:getContentSize()

        -- 创建显示重数的label
        local rebornNumLabel = ui.newNumberLabel({
            text = Utility.getNumPicChar(rebornLvModel.rebornNum),
            imgFile = "nl_17.png",
            charCount = 11,
            startChar = 48,
        })
        rebornNumLabel:setPosition(bgSize.width / 2 + 2, bgSize.height - 23)
        retSprite:addChild(rebornNumLabel)

        local stepImgList = {
            "jm_31.png", "jm_32.png", "jm_33.png", "jm_34.png", 
            "jm_35.png", "jm_36.png", "jm_37.png", "jm_38.png"
        }
        local tempImgName = stepImgList[rebornLvModel.step] or "jm_49.png"
        local tempSprite = ui.newSprite(tempImgName)
        tempSprite:setPosition(bgSize.width / 2 + 2, 70)
        retSprite:addChild(tempSprite)
    end

    -- 初始化
    retSprite.setLevel(rebornLvModelId)

    return retSprite
end


-- 创建闪烁的图标显示
--[[
-- 参数[]
    moduleId=,                 -- 刷新的模块ID，必填
    imgName = "mjrq_11.png",   -- 图标名
    position = cc.p(0.8, 0.8), -- 偏移位置
    anchor = cc.p(0, 0)        -- 缩放点
    parent = ,      -- 父结点
    clickAction = ,            -- 点击事件
-- 返回值
    创建的图标sprite
]]
function ui.createFlashAutoIcon(params)
    local iconModuleId = params.moduleId
    local relPos = params.position or cc.p(0.8, 0.8)
    local relAnchor = params.anchor or cc.p(0, 0)
    local function dealIconVisible(redDotSprite)
        redDotSprite:setVisible(RedDotInfoObj:isValid(iconModuleId))
    end
    local btnSize = params.parent:getContentSize()
    -- 创建闪烁图标
    local retBtn = ui.newButton({normalImage = params.imgName or "mjrq_11.png", clickAction = params.clickAction})
    retBtn:setPosition(cc.p(btnSize.width * relPos.x, btnSize.height * relPos.y))
    retBtn:setAnchorPoint(relAnchor)
    params.parent:addChild(retBtn)
    retBtn:runAction(cc.RepeatForever:create(cc.Sequence:create({
        cc.ScaleTo:create(0.7, 0.5),
        cc.ScaleTo:create(0.7, 1),
        })))
    -- 添加图标事件
    Notification:registerAutoObserver(retBtn, dealIconVisible, RedDotInfoObj:getEvents(iconModuleId))
    -- 自动调用一次
    dealIconVisible(retBtn)
    return retBtn
end

-- 创建名望的标题显示
--[[
-- 参数[]
    titleId,                 -- 当前的名望等级
-- 返回值
    创建的node，可能为nil
]]
function ui.createTitleNode(titleId)
    local titleInfo = TitleModel.items[titleId or 0]
    if (titleInfo == nil) or (titleInfo.pic == nil) then
        return nil
    end

    -- 特效列表
    local titleEffectList = {
        [2] = "effect_ui_chenghao_lv",
        [3] = "effect_ui_chenghao_lan",
        [4] = "effect_ui_chenghao_zi",
        [5] = "effect_ui_chenghao_cheng",
        [6] = "effect_ui_chenghao_hong",
        [7] = "effect_ui_chenghao_jin",
    }

    -- 创建称号图片
    local titleSprite = ui.newSprite(titleInfo.pic .. ".png")
    local titleSize = titleSprite:getContentSize()

    -- 父节点
    local titleParent = cc.Node:create()
    titleParent:setContentSize(titleSize)
    titleParent:setAnchorPoint(cc.p(0.5, 0.5))

    -- 创建下层特效(绿色品质没有这个特效)
    if titleInfo.valueLv > 2 then
        ui.newEffect({
            parent = titleParent,
            effectName = titleEffectList[titleInfo.valueLv],
            position = cc.p(titleSize.width*0.5, titleSize.height*0.5),
            animation = "xia",
            loop = true,
        })
        ui.newEffect({
            parent = titleParent,
            effectName = titleEffectList[titleInfo.valueLv],
            position = cc.p(titleSize.width*0.5, titleSize.height*0.5),
            animation = "shang",
            loop = true,
        })
    end

    -- 添加称号图片
    titleSprite:setPosition(cc.p(titleSize.width*0.5, titleSize.height*0.5))
    titleParent:addChild(titleSprite)

    -- 创建裁剪区
    local clippingNode = cc.ClippingNode:create()
    clippingNode:setAlphaThreshold(0.5)
    clippingNode:setPosition(cc.p(titleSize.width*0.5, titleSize.height*0.5))
    titleParent:addChild(clippingNode)

    -- 创建遮罩特效
    local zhezhaoEffect = ui.newEffect({
            parent = clippingNode,
            effectName = titleEffectList[titleInfo.valueLv],
            animation = "zhezhao",
            loop = true,
        })
    -- 创建模版
    local stencilNode = ui.newSprite(titleInfo.pic .. ".png")
    clippingNode:setStencil(stencilNode)

    return titleParent
end

-- 创建会员显示
--[[
-- 参数[]
    vipLv,                 -- 默认0
-- 返回值
    创建的node
]]
function ui.createVipNode(vipLv)
    -- vip图片
    local vipTexture = "c_48.png"
    local vipNumTexture = "c_49.png"
    local showVipLv = vipLv

    -- 如果vip等级大于26，则为尊贵vip
    local lvStep = Utility.getVipStep()
    if showVipLv > lvStep then
        vipTexture = "sy_46.png"
        showVipLv = showVipLv - lvStep
    end

    -- 父节点
    local parentNode = cc.Node:create()
    parentNode:setAnchorPoint(cc.p(0, 0.5))

    local width = 0
    local height = 0

    -- 会员图片
    local vipSprite =  ui.newSprite(vipTexture)
    parentNode:addChild(vipSprite)

    width = width + vipSprite:getContentSize().width
    height = vipSprite:getContentSize().height

    vipSprite:setAnchorPoint(cc.p(0, 0.5))
    vipSprite:setPosition(0, height*0.5)
    parentNode.vipSprite = vipSprite

    -- 等级文本
    local vipLabel = ui.newNumberLabel({
        text = tostring(showVipLv or 0),
        imgFile = vipNumTexture,
        charCount = 10,
    })
    vipLabel:setAnchorPoint(cc.p(0, 0.5))
    vipLabel:setPosition(width, height*0.5)
    parentNode:addChild(vipLabel)
    parentNode.vipLabel = vipLabel

    width = width + vipLabel:getContentSize().width

    -- 设置节点大小
    parentNode:setContentSize(cc.size(width, height))

    return parentNode
end


-- 快捷创建珍兽星级显示
--[[
-- 参数:
    starLevel: -- 必选参数，物品的星级
-- 返回值
    Node对象，多个星星图片的 parent， 该node提供方法 retNode.setStarLevel(starLevel)
--]]
function ui.newZhenshouStar(starLevel)
    local retNode = cc.Node:create()
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setAnchorPoint(cc.p(0.5, 0.5))

    local starImg = "c_75.png"
    -- space = space or 2
    local imgSize = ui.getImageSize(starImg)
    retNode.setStarLevel = function(starLv)
        retNode:removeAllChildren()
        if starLv <= 0 then
            return
        end
        
        local count = math.mod(starLv, 5) == 0 and 5 or math.mod(starLv, 5)

        if starLv <= 5 then
            starImg = "c_75.png"
        elseif starLv > 5 and starLv <= 10 then 
            starImg = "zs_04.png"
        end

        for i = 1, count do
            local tempPosX,tempPosY

            tempPosX = imgSize.width / 2 + (i - 1) * (imgSize.width + 2)
            tempPosY = imgSize.height / 2

            -- 创建
            local tempSprite = ui.newSprite(starImg)
            tempSprite:setPosition(tempPosX, tempPosY)
            retNode:addChild(tempSprite)
        end

        retNode:setContentSize(cc.size(count * imgSize.width + (count - 1) * 2, imgSize.height))
    end
    if (starLevel ~= nil) then
        retNode.setStarLevel(starLevel)
    end
    return retNode
end

return ui
