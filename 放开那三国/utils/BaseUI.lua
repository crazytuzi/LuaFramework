--Filename:BaseUI.lua
--Author：Babeltme
--Date：2013/8/13
--Purpose:创建基本的UI组建

require "script/libs/LuaCCLabel" 

module("BaseUI",package.seeall)


-- 创建一个通用的9格sprite，以 imageFile 为纹理
-- arg: point, 以左上角为原点, 需要保留4角contentSize, 实际需要拉伸的大小
function create9gridBg(imageFile, rectInsets, contentSize)
    local spt = CCSprite:create(imageFile)
    local rect = CCRectMake(0, 0, spt:getContentSize().width, spt:getContentSize().height)  -- imageFile 实际size    
    local bg = CCScale9Sprite:create(imageFile,rect,rectInsets)
    bg:setAnchorPoint(ccp(0.5, 0.5))
    bg:setContentSize(contentSize)
    return bg
end


-- 创建一个通用的9格sprite，以 y_9s_bg.png 为纹理 
function createYellowBg(contentSize)
    local rectInsets = CCRectMake(33, 33, 15, 50) --9格中间区域
    return create9gridBg("images/common/bg/y_9s_bg.png", rectInsets, contentSize)
end

-- 创建一个通用的9格sprite，以 y_9s_bg.png 为纹理 
function createYellowSelectBg(contentSize)
    local rectInsets = CCRectMake(33, 33, 15, 50) --9格中间区域
    return create9gridBg("images/common/bg/y_9s_bg_h.png", rectInsets, contentSize)
end

-- 创建一个通用的9格sprite，以 viewbg1.png 为纹理 
function createViewBg(contentSize)
    local rectInsets = CCRectMake(100, 80, 10, 20) --9格中间区域
    return create9gridBg("images/common/viewbg1.png", rectInsets, contentSize)
end


-- 创建一个通用的9格sprite，以 bg_ng.png 为纹理 
function createNoBorderViewBg(contentSize)
    local rectInsets = CCRectMake(61, 80, 46, 36) --9格中间区域
    return create9gridBg("images/common/bg/bg_ng.png", rectInsets, contentSize)
end

-- 创建一个通用的9格sprite，以 menubg.png 为纹理 
function createTopMenuBg(contentSize)
    local rectInsets = CCRectMake(20,20,18,59) --9格中间区域
    return create9gridBg("images/common/menubg.png", rectInsets, contentSize)
end

-- 创建一个通用的9格sprite，以 bg_ng_attr.png 为纹理 
function createContentBg(contentSize)
    local rectInsets = CCRectMake(30, 30, 15, 10) --9格中间区域
    return create9gridBg("images/common/bg/bg_ng_attr.png", rectInsets, contentSize)
end

-- 创建一个通用的9格sprite，以 search_bg.png 为纹理 
function createSearchBg(contentSize)
    local rectInsets = CCRectMake(20,20,1,1) --9格中间区域
    return create9gridBg("images/common/bg/search_bg.png", rectInsets, contentSize)
end

-- 创建一个在顶部的分页按钮控件 将使用 common/btn_title_n.png common/btn_title_h.png 来创建
-- nameArray: 存储标题数据的数组 ex:{"name1" ,"name2"} 将创建一个有连个按钮的tabLayer 按钮的分别标题是name1 ,name2
-- normal_font_size,select_font_size, 两种字体状态的大小
-- font_name 字体名称
-- normal_color,select_color两种字体颜色
function createTopTabLayer( nameArray, normal_font_size, select_font_size, font_name, normal_color, select_color )
    local array1 = CCArray:create()
    local array2 = CCArray:create()
    local array3 = CCArray:create()

    for i=1,#nameArray do
        array1:addObject(CCString:create("images/common/btn_title_n.png"))      
        array2:addObject(CCString:create("images/common/btn_title_h.png"))      
        array3:addObject(CCString:create("images/common/btn_title_h.png"))    
    end
    local tabLayer = BTTabLayer:create(array1,array2,array3)
    for i=1,#nameArray do
        local size = tabLayer:buttonOfIndex(i-1):getContentSize()
        -- 投影字体
        local normalLable = LuaCCLabel.createShadowLabel(nameArray[i], font_name ,normal_font_size or 25)
        normalLable:setPosition(size.width/2, size.height/2 - 5)
        normalLable:setAnchorPoint(ccp(0.5, 0.5))
        normalLable:setColor(normal_color or ccc3(255,255,255))
        local tabLayerButton = tolua.cast(tabLayer:buttonOfIndex(i-1),"CCMenuItemSprite")
        tabLayerButton:getNormalImage():addChild(normalLable)

        local selectLable = CCLabelTTF:create(nameArray[i], font_name ,select_font_size or 25)
        selectLable:setPosition(size.width/2, size.height/2 - 5)
        selectLable:setAnchorPoint(ccp(0.5, 0.5))
        selectLable:setColor(select_color or ccc3(255,255,255))
        tabLayerButton:getSelectedImage():addChild(selectLable)

        local disableLable = CCLabelTTF:create(nameArray[i], font_name ,select_font_size or 25)
        disableLable:setPosition(size.width/2, size.height/2 - 5)
        disableLable:setAnchorPoint(ccp(0.5, 0.5))
        disableLable:setColor(select_color or ccc3(255,255,255))
        tabLayerButton:getDisabledImage():addChild(disableLable)
    end
    return tabLayer
end

-- 创建一个在顶部的分页按钮控件 将使用 common/btn_title_n.png common/btn_title_h.png 来创建
-- nameArray: 存储标题数据的数组 ex:{"name1" ,"name2"} 将创建一个有连个按钮的tabLayer 按钮的分别标题是name1 ,name2
-- normal_font_size,select_font_size, 两种字体状态的大小
-- font_name 字体名称
-- normal_color,select_color两种字体颜色
-- btnContentSize:按钮大小
function createSpriteTopTabLayer( nameArray, normal_font_size, select_font_size, font_name, normal_color, select_color,btnContentSize )
    local array1 = CCArray:create()
    local array2 = CCArray:create()
    local array3 = CCArray:create()

    for i=1,#nameArray do
        local normalSprite  =CCScale9Sprite:create("images/common/btn_title_n.png")
        normalSprite:setContentSize(btnContentSize)
        local selectSprite  =CCScale9Sprite:create("images/common/btn_title_h.png")
        selectSprite:setContentSize(btnContentSize)
        local disableSprite =CCScale9Sprite:create("images/common/btn_title_h.png")
        disableSprite:setContentSize(btnContentSize)

        array1:addObject(normalSprite)      
        array2:addObject(selectSprite)      
        array3:addObject(disableSprite)    
    end
    local tabLayer = BTTabLayer:createWithSpriteArray(array1,array2,array3)
    for i=1,#nameArray do
        local size = tabLayer:buttonOfIndex(i-1):getContentSize()
        -- 投影字体
        -- print("createSpriteTopTabLayer .. " .. nameArray[i])
        local tabLayerButton = tolua.cast(tabLayer:buttonOfIndex(i-1),"CCMenuItemSprite")
        -- print( "tabLayer:buttonOfIndex(i-1) = ", tabLayerButton)
        -- print( "tabLayerButton:getNormalImage() = ",  tabLayerButton:getNormalImage())
        local normalLable = LuaCCLabel.createShadowLabel(nameArray[i], font_name ,normal_font_size or 25)
        normalLable:setPosition(size.width/2, size.height/2 - 5)
        normalLable:setAnchorPoint(ccp(0.5, 0.5))
        normalLable:setColor(normal_color or ccc3(255,255,255))
        tabLayerButton:getNormalImage():addChild(normalLable)


        local selectLable = CCLabelTTF:create(nameArray[i], font_name ,select_font_size or 25)
        selectLable:setPosition(size.width/2, size.height/2 - 5)
        selectLable:setAnchorPoint(ccp(0.5, 0.5))
        selectLable:setColor(select_color or ccc3(255,255,255))
        tabLayerButton:getSelectedImage():addChild(selectLable)

        local disableLable = CCLabelTTF:create(nameArray[i], font_name ,select_font_size or 25)
        disableLable:setPosition(size.width/2, size.height/2 - 5)
        disableLable:setAnchorPoint(ccp(0.5, 0.5))
        disableLable:setColor(select_color or ccc3(255,255,255))
        tabLayerButton:getDisabledImage():addChild(disableLable)
    end
    return tabLayer
end


function createButton( p_normalImage, p_higImage, p_grayImage )
    
end


--[[
    @des:把参数中的所有节点按水平方向排开，并加到一个node上
    @parm:node_table 节点table
    @parm:p_touchPriority 如果节点中存在Menuitem，那么就是他的优先级
    @parm:如果父节点是个srollerView ,那么需要把父节点传进来
    @parm:每个节点之间的间距
    @ret:ret 描述
--]]
function createHorizontalNode( node_table, p_touchPriority, p_parentScrollview, pMargeSize )
    local width = 0
    local height = 0
    local margeSize = pMargeSize or 0
    for k,v in pairs(node_table) do
        width = width + v:getContentSize().width * v:getScaleX()
        if(v:getContentSize().height * v:getScaleY() > height) then
            height = v:getContentSize().height * v:getScaleY()
        end
    end

    local nodeContent = CCSprite:create()
    local margeLength = margeSize * (table.count(node_table) - 1)
    nodeContent:setContentSize(CCSizeMake(width+ margeLength, height))

    local menu = nil
    if p_parentScrollview then
        menu = BTMenu:create(true)
        menu:setAnchorPoint(ccp(0, 0))
        menu:setPosition(0, 0)
        menu:setTouchPriority(p_touchPriority or -256)
        menu:setScrollView(p_parentScrollview)
        nodeContent:addChild(menu)
    else
        menu = CCMenu:create()
        menu:setAnchorPoint(ccp(0, 0))
        menu:setPosition(0, 0)
        menu:setTouchPriority(p_touchPriority or -256)
        nodeContent:addChild(menu)
    end

    local tempWidth = 0
    local n = 0
    for k,v in pairs(node_table) do
        v:setAnchorPoint(ccp(0, 0.5))
        v:setPosition(ccp(tempWidth, 0.5 * height))
        if(tolua.type(v) == "CCMenuItemLabel" or tolua.type(v) == "CCMenuItem" or tolua.type(v) == "CCMenuItemImage" or tolua.type(v) == "CCMenuItemSprite") then
            menu:addChild(v, 1, v:getTag())
        else
            nodeContent:addChild(v,1,v:getTag())
        end
        n = n + 1
        tempWidth = tempWidth + v:getContentSize().width * v:getScaleX()
        if n < table.count(node_table) then
            tempWidth = tempWidth + margeSize
        end
    end
    return nodeContent
end

--把参数中的所有节点按垂直方向排开，并加到一个node上
function createVerticalNode( node_table, p_touchPriority )
    local width = 0
    local height = 0
    for k,v in pairs(node_table) do
        height = height + v:getContentSize().height * v:getScaleX()
        if(v:getContentSize().width * v:getScaleX() > width) then
            width = v:getContentSize().width * v:getScaleX()
        end
    end

    local nodeContent = CCSprite:create()
    nodeContent:setContentSize(CCSizeMake(width, height))

    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0, 0))
    menu:setPosition(0, 0)
    menu:setTouchPriority(p_touchPriority or -256)
    nodeContent:addChild(menu)

    local tempheight = 0
    for k,v in pairs(node_table) do
        v:setAnchorPoint(ccp(0.5, 0.5))
        v:setPosition(ccp(width*0.5, height - tempheight))
        if(tolua.type(v) == "CCMenuItemLabel" or tolua.type(v) == "CCMenuItem" or tolua.type(v) == "CCMenuItemImage" or tolua.type(v) == "CCMenuItemSprite") then
            menu:addChild(v, 1, v:getTag())
        else
            nodeContent:addChild(v,1,v:getTag())
        end
        tempheight = tempheight + v:getContentSize().height * v:getScaleX()
    end
    return nodeContent
end



--创建一个吃touch的半透明layer
--priority : touch 权限级别,默认为-1024
--touchRect: 在touchRect 区域会放行touch事件 若touchRect = nil 则全屏吃touch
--touchCallback: 屏蔽层touch 回调
function createMaskLayer( priority,touchRect ,touchCallback, layerOpacity,highRect)
    local layer = CCLayer:create()
    layer:setPosition(ccp(0, 0))
    layer:setAnchorPoint(ccp(0, 0))
    layer:setTouchEnabled(true)
    layer:setTouchPriority(priority or -1024)
    layer:registerScriptTouchHandler(function ( eventType,x,y )
        if(eventType == "began") then
            if(touchRect == nil) then
                if(touchCallback ~= nil) then
                    touchCallback()
                end
                return true
            else
                if(touchRect:containsPoint(ccp(x,y))) then
                    return false
                else
                    if(touchCallback ~= nil) then
                        touchCallback()
                    end
                    return true
                end
            end
        end
        print(eventType)
    end,false, priority or -1024, true)

    local gw,gh = g_winSize.width, g_winSize.height
    if(touchRect == nil) then
        local layerColor = CCLayerColor:create(ccc4(0,0,0,layerOpacity or 150),gw,gh)
        layerColor:setPosition(ccp(0,0))
        layerColor:setAnchorPoint(ccp(0,0))
        layer:addChild(layerColor)
        return layer
    else
        local ox,oy,ow,oh = touchRect.origin.x, touchRect.origin.y, touchRect.size.width, touchRect.size.height
        local layerColor = CCLayerColor:create(ccc4(0, 0, 0, layerOpacity or 150 ), gw, gh)
        local clipNode = CCClippingNode:create();
        clipNode:setInverted(true)
        clipNode:addChild(layerColor)

        local stencilNode = CCNode:create()
        -- stencilNode:retain()

        local node = CCScale9Sprite:create("images/guide/rect.png");
        node:setContentSize(CCSizeMake(ow, oh))
        node:setAnchorPoint(ccp(0, 0))
        node:setPosition(ccp(ox, oy))
        stencilNode:addChild(node)

        if(highRect ~= nil) then
            local highNode = CCScale9Sprite:create("images/guide/rect.png");
            highNode:setContentSize(CCSizeMake(highRect.size.width, highRect.size.height))
            highNode:setAnchorPoint(ccp(0, 0))
            highNode:setPosition(ccp(highRect.origin.x, highRect.origin.y))
            stencilNode:addChild(highNode)
        end

        clipNode:setStencil(stencilNode)
        clipNode:setAlphaThreshold(0.5)
        layer:addChild(clipNode)
     end
    return layer
end

--[[
    @des:       截取当前屏幕图片
    @ret:       截取的图片路径
]]
function getScreenshots( ... )
    local size = CCDirector:sharedDirector():getWinSize()
    local in_texture = CCRenderTexture:create(size.width, size.height,kCCTexture2DPixelFormat_RGBA8888)
    in_texture:getSprite():setAnchorPoint( ccp(0.5,0.5) )
    in_texture:setPosition( ccp(size.width/2, size.height/2) )
    in_texture:setAnchorPoint( ccp(0.5,0.5) )

    local runingScene = CCDirector:sharedDirector():getRunningScene()
    in_texture:begin()
    runingScene:visit()
    in_texture:endToLua()

    local picPath = CCFileUtils:sharedFileUtils():getWritablePath() .. "shareTempScreenshots.jpg"
    print(GetLocalizeStringBy("key_2636"),in_texture:saveToFile(picPath))
    return picPath
end

--[[
    @des:创建一个带文字的按钮
--]]
function createMenuItem(normalString, selectedString, disabledString, size)
    local norSprite = CCScale9Sprite:create("images/common/btn/btn1_d.png")
    norSprite:setContentSize(size)
    local norTitle  =  CCRenderLabel:create(normalString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    norTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
    norTitle:setPosition(ccpsprite(0.5, 0.5, norSprite))
    norTitle:setAnchorPoint(ccp(0.5, 0.5))
    norSprite:addChild(norTitle)
    
    local higSprite = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    higSprite:setContentSize(size)
    selectedString = selectedString or normalString
    local higTitle  =  CCRenderLabel:create(selectedString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    higTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
    higTitle:setPosition(ccpsprite(0.5, 0.5, higSprite))
    higTitle:setAnchorPoint(ccp(0.5, 0.5))
    higSprite:addChild(higTitle)
    
    local graySprite = CCScale9Sprite:create("images/common/btn/btn1_g.png")
    graySprite:setContentSize(size)
    disabledString = disabledString or normalString
    local grayTitle  =  CCRenderLabel:create(disabledString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    grayTitle:setColor(ccc3(78, 78, 78))
    grayTitle:setPosition(ccpsprite(0.5, 0.5, graySprite))
    grayTitle:setAnchorPoint(ccp(0.5, 0.5))
    graySprite:addChild(grayTitle)
    
    local button = CCMenuItemSprite:create(norSprite, higSprite, graySprite)
    return button
end

