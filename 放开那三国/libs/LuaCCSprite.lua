-- Filename: LuaCCSprite.lua
-- Author: fang
-- Date: 2013-08-02
-- Purpose: 该文件用于在lua中封装cocos2d-x中CCSprite及CCScale9Sprite对象

module("LuaCCSprite", package.seeall)


-- 创建带标题的图片（标题在图片的中心）
function createSpriteWithRenderLabel(bgfile, tLabel)
	local ccSprite = CCSprite:create(bgfile)
	local spriteSize = ccSprite:getContentSize()
    local font = tLabel.font or g_sFontName
	local ccLabel = CCRenderLabel:create(tLabel.text, font, tLabel.fontsize, tLabel.stroke_size, tLabel.stroke_color, type_stroke)
	ccLabel:setSourceAndTargetColor(tLabel.sourceColor, tLabel.targetColor)

	local x = spriteSize.width/2
	local y = spriteSize.height/2
	if tLabel.vOffset then
		y = y + tLabel.vOffset
	end
	if tLabel.hOffset then
		x = x + tLabel.hOffset
	end

	ccLabel:setPosition(ccp(x, y))
	if tLabel.tag then
		ccSprite:addChild(ccLabel, 0, tLabel.tag)
	else
		ccSprite:addChild(ccLabel)
	end
	-- 真奇怪！应该是CCRenderLabel类有bug，否则不该是ccp(1, 0)
	if tLabel.anchorPoint then
		ccLabel:setAnchorPoint(tLabel.anchorPoint)
	end
	return ccSprite
end
-- 创建带标题的图片（标题在图片的中心）
function createSpriteWithLabel(bgfile, tLabel)
	local ccSprite = CCSprite:create(bgfile)
	local spriteSize = ccSprite:getContentSize()
	local fontname = tLabel.fontname or g_sFontName
	local ccLabel = CCLabelTTF:create (tLabel.text, fontname, tLabel.fontsize)
	if (tLabel.color) then
		ccLabel:setColor(tLabel.color)
	end
	ccLabel:setAnchorPoint(ccp(0.5, 0.5))
	local x = spriteSize.width/2
	local y = spriteSize.height/2
	if tLabel.vOffset then
		y = y + tLabel.vOffset
	end
	if tLabel.hOffset then
		x = x + tLabel.hOffset
	end

	ccLabel:setPosition(ccp(x, y))
	if (tLabel.tag) then
		ccSprite:addChild(ccLabel, 0, tLabel.tag)
	else
		ccSprite:addChild(ccLabel)
	end

	return ccSprite
end

-- 创建统一标题栏（上面带有菜单按钮）
-- in: tParam, 输入参数，应该是个数组
-- out: 返回一个CCSprite对象。该对象上包含着menu(tag为10001)，
-- menu中包含着CCMenuItem对象数组(默认tag以1001为起始值，如果参数中带有tag的话则以参数为准)
-- t_needExpend  add by DJN 有一些顶端的meubBar宽度已经超出屏幕宽度 需要做成scrollview的形式 所以棕色背景的宽度也要随之拉宽 这个参数就是决定是否需要这种扩展
function createTitleBar(tParam,p_scale,p_touchProirity,t_needExpend )
    local scale = p_scale or 1
    local needExpend = t_needExpend or false
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--标题背景
	local cs9Bg = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	cs9Bg:setPreferredSize(CCSizeMake(640, 108))
	
	local menu = CCMenu:create()
    if(p_touchProirity)then
        menu:setTouchPriority(p_touchProirity)
    end
	menu:setPosition(ccp(10, 10))
	cs9Bg:addChild(menu, 0, 10001)
    local menuWidth = 0
	for i=1, #tParam do
		local item=tParam[i]
		-- 普通文本以默认
		local nFontsize = item.nFontsize or 36
        -- 越南版本
        if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
            nFontsize = item.nFontsize or 28
        end
		local nColor = item.nColor or ccc3(0xff, 0xe4, 0)
		local pFontname = item.fontname or g_sFontPangWa
		local vOffset = item.vOffset or -4
		local tNormalLabel = {text=item.text, color=nColor, fontsize=nFontsize, fontname=pFontname, vOffset=vOffset}
		local sNormalImage = item.normalN or "images/active/rob/btn_title_n.png"
		local csNormal = createSpriteWithLabel(sNormalImage, tNormalLabel)
		
		local hFontsize = item.hFontsize or 30
        -- 越南版本
        if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
            hFontsize = item.hFontsize or 24
        end
		local hColor = item.hColor or ccc3(0x48, 0x85, 0xb5)
		local tHighlightedLabel = {text=item.text, color=hColor, fontsize=hFontsize, fontname=pFontname, vOffset=vOffset}
		local sHighlightedImage = item.normalH or "images/active/rob/btn_title_h.png"
		local csHighlighted = createSpriteWithLabel(sHighlightedImage, tHighlightedLabel)
		local nTagOfItem = item.tag or 1000+i
		local cmis = CCMenuItemSprite:create(csNormal, csHighlighted)
        cmis:setScale(scale)
		local x=item.x or 0
		local y=item.y or 0
		cmis:setPosition(x, y)
		if item.handler then
			cmis:registerScriptTapHandler(item.handler)
		end
		menu:addChild(cmis, 0, nTagOfItem)
        menuWidth = menuWidth + cmis:getContentSize().width
	end
    if(needExpend and menuWidth > cs9Bg:getContentSize().width)then
        cs9Bg:setPreferredSize(CCSizeMake(menuWidth, 108))
    end

	return cs9Bg
end

--[[
    @des    :得到选择按钮为图片的选择背景菜单
    @param  :$ p_param         : 参数table
               p_param格式
               p_param
               (
                    下标
                    (
                        x           -- x坐标 默认为0
                        y           -- y坐标 默认为0
                        tag         -- 按钮tag值 默认为 1000 + 下标
                        handler     -- 按钮回调函数
                        normalImg   -- 按钮普通图
                        highImg     -- 按钮高亮图
                    )

               )
    @param  :$ p_menuTag       : 背景menu的tag值，默认为10001
    @return :创建好的选择背景菜单
--]]
function createTitleSpriteBar(p_param,p_menuTag)
    local fullRect = CCRectMake(0,0,58,99)
    local insetRect = CCRectMake(20,20,18,59)

    --menu层的tag
    local menuTag = p_menuTag or 10001

    --背景菜单
    local bgSprite = CCScale9Sprite:create("images/common/menubg.png",fullRect,insetRect)
    bgSprite:setPreferredSize(CCSizeMake(640,108))
    --菜单层
    local menu = CCMenu:create()
    menu:setPosition(ccp(10,10))
    bgSprite:addChild(menu,0,menuTag)
    --循环创建
    for i = 1,#p_param do
        --当前要处理的元素
        local paramItem = p_param[i]
        --坐标
        local x = paramItem.x or 0
        local y = paramItem.y or 0
        --tag值
        local itemTag = paramItem.tag or 1000 + i
        --按钮
        local menuItem = CCMenuItemImage:create(paramItem.normalImg,paramItem.lightImg)
        menuItem:setPosition(ccp(x,y))
        menuItem:registerScriptTapHandler(paramItem.handler)
        menu:addChild(menuItem,0,itemTag)
    end

    return bgSprite
end

function createTitleBarCpy(tParam)
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--标题背景
	local cs9Bg = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	cs9Bg:setPreferredSize(CCSizeMake(640, 108))
	
	local menu = CCMenu:create()
	menu:setPosition(ccp(10, 10))
	cs9Bg:addChild(menu, 0, 10001)
	return cs9Bg
end

--[[
dialog_info = {
    title 对话框标题
    callbackClose 关闭按钮的回调
    size 对话框尺寸
    priority 对话框优先级
    swallowTouch = false
    isRunning 
}
--]]
-- 创建一个对话框
function createDialog_1(dialog_info)
    local dialog = nil
    if dialog_info.swallowTouch == true then
        dialog = CCLayerColor:create(ccc4(0, 0, 0, 155))
        local onTouchesHandler = function( eventType, x, y )
            return true
        end
        local onNodeEvent = function( event )
            if (event == "enter") then
                dialog:registerScriptTouchHandler(onTouchesHandler, false, dialog_info.priority, true)
                dialog:setTouchEnabled(true)
                dialog_info.isRunning = true
            elseif (event == "exit") then
                dialog:unregisterScriptTouchHandler()
                dialog_info.isRunning = false
            end
        end
        dialog:registerScriptHandler(onNodeEvent)
    else
        dialog = CCNode:create()
        dialog:setContentSize(dialog_info.size)
    end
    local bg = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20), "images/common/viewbg1.png")
    dialog_info.dialog = bg
    bg:setContentSize(dialog_info.size)
    bg:setAnchorPoint(ccp(0,0))
    bg:setPosition(0,0)
    dialog:addChild(bg)
    bg:setTag(1)

    if dialog_info.swallowTouch == true then
        dialog_info.dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
        dialog_info.dialog:setAnchorPoint(ccp(0.5, 0.5))
        dialog_info.dialog:setScale(MainScene.elementScale)
    end


    -- 标题
    if dialog_info.title ~= nil then
        local title_bg = CCSprite:create("images/formation/changeformation/titlebg.png")
       	bg:addChild(title_bg)
        title_bg:setTag(2)
    	title_bg:setAnchorPoint(ccp(0.5,0.5))
    	title_bg:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height - 6))

    	local title_label = CCLabelTTF:create(dialog_info.title, g_sFontPangWa, 33)
        title_bg:addChild(title_label)
    	title_label:setColor(ccc3(0xff, 0xe4, 0x00))
    	title_label:setAnchorPoint(ccp(0.5, 0.5))
    	title_label:setPosition(ccp(title_bg:getContentSize().width * 0.5, title_bg:getContentSize().height * 0.5))
	end
    -- 按钮Bar
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(dialog_info.priority - 1)
    bg:addChild(menu, 10)
    
    -- 关闭按钮
    if dialog_info.callbackClose == nil then
        dialog_info.callbackClose = function()
            dialog:removeFromParentAndCleanup(true)
        end
    end
    if dialog_info.close ~= false then
        local close_btn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
        close_btn:setAnchorPoint(ccp(1, 1))
        close_btn:setPosition(bg:getContentSize().width + 10, bg:getContentSize().height + 15)
        menu:addChild(close_btn)
        close_btn:registerScriptTapHandler(dialog_info.callbackClose)
    end

    return dialog
end

-- 创建一个吞噬触摸事情的layer
function createMaskLayer(p_color, p_touchProirity)
    local layer = CCLayerColor:create(p_color)
    local onTouchesHandler = function ( event, x, y )
        return true
    end
    local onNodeEvent = function( event )
        if (event == "enter") then
            layer:registerScriptTouchHandler(onTouchesHandler, false, p_touchProirity or -180, true)
            layer:setTouchEnabled(true)
        elseif (event == "exit") then
            layer:unregisterScriptTouchHandler()
        end
    end
    layer:registerScriptHandler(onNodeEvent)
    return layer
end

--[[
local radio_data = {
    touch_priority      -- 触摸优先级
    space               -- 按钮间距
    callback            -- 按钮回调
    direction           -- 方向 1为水平，2为竖直
    items = {
        {normal = "images/chat/wei_n.png", selected = "images/chat/wei_h.png"},
            ...
    }
}
--]]
-- 创建选项卡的按钮
function createRadioMenu(radio_data)
    local item_count = #radio_data.items
    local items = {}
    for i  = 1, item_count do
        local item_data = radio_data.items[i]
        local item = CCMenuItemImage:create(item_data.normal, item_data.selected, item_data.selected)
        table.insert(items, item)
    end
    radio_data.items = items
    local menu = createRadioMenuWithItems(radio_data)
    return menu
end


--[[
local radio_data = {
    touch_priority      -- 触摸优先级
    space               -- 按钮间距
    callback            -- 按钮回调
    direction           -- 方向 1为水平，2为竖直
    defaultIndex         -- 默认选择的index
    items = {
        CCMenuItem,
        CCMenuItem,
        ...
    }
}
--]]
-- 创建选项卡的按钮
function createRadioMenuWithItems(radio_data)
    radio_data.defaultIndex = radio_data.defaultIndex or 1
    local menu = CCMenu:create()
    menu:ignoreAnchorPointForPosition(false)
    menu:setTouchPriority(radio_data.touch_priority)
    local space = radio_data.space
    local item_count = #radio_data.items
    local callback = function(tag, item)
        item:setEnabled(false)
        if radio_data.last_item ~= nil then
            radio_data.last_item:setEnabled(true)
        end
        radio_data.last_item = item
        radio_data.callback(tag, item)
    end
    radio_data.reallyCallback = callback
    local item_size = nil
    local menuContentSize = CCSizeMake(0, 0)
    for i = 1, item_count do
        local item = radio_data.items[i]
        menu:addChild(item)
        item:registerScriptTapHandler(callback)
        item:setTag(i)
        if i == radio_data.defaultIndex then
            callback(i, item)
        end
        local item_size = item:getContentSize()
        if i == 1 then
            if radio_data.direction == 2 then
                menuContentSize.width = item_size.width
            else
                menuContentSize.height = item_size.height
            end
        end
        if radio_data.direction == 2 then
            menuContentSize.height = menuContentSize.height + item_size.height
            if i < item_count then
                menuContentSize.height = menuContentSize.height + space
            end
        else
            menuContentSize.width = menuContentSize.width + item_size.width
            if i < item_count then
                menuContentSize.width = menuContentSize.width + space
            end
        end
    end
    local y = menuContentSize.height
    local x = 0
    for i = 1, item_count do
        local item = radio_data.items[i]
        item:setAnchorPoint(ccp(0.5, 0))
        local item_size = item:getContentSize()
        if radio_data.direction == 2 then
            item:setPosition(ccp(menuContentSize.width * 0.5, y - item_size.height))
        else
            item:setPosition(ccp(x + item_size.width * 0.5, 0))
        end
        y = y - item_size.height - space
        x = x + item_size.width + space
    end
    menu:setContentSize(menuContentSize)

    return menu
end

--[[
data = {
    normal 正常状态的图片
    selected 按下状态的图片
    disabled 不可点击时的图片
    size = 按钮尺寸
    icon = 数字前的小图标
    text = 按钮上的文字
    text_size = 文字的尺寸
    number = 数字 string类型的
    number_size = 数字尺寸
}
--]]
-- 创建带数字的按钮
function createNumberMenuItem(data)
    if data.disabled == nil then
        data.disabled = data.selected
    end
    local menu_item = LuaCC.create9ScaleMenuItemWithoutLabel(data.normal, data.selected, data.disabled, data.size)
    local label = {}
    data.text_size = data.text_size or 35
    label[1] = CCRenderLabel:create(data.text, g_sFontPangWa, data.text_size, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    label[1]:setColor(ccc3(0xfe, 0xdb, 0x1c))
    if data.number ~= "0" then
        label[2] = CCSprite:create(data.icon)
        data.number_size = data.number_size or 25
        label[3] = CCLabelTTF:create(data.number, g_sFontPangWa, data.number_size)
        label[3]:setColor(ccc3(0xfe, 0xdb, 0x1c))
        data.number_label = label[3]
    end
    label_node = BaseUI.createHorizontalNode(label)
    label_node:setAnchorPoint(ccp(0.5, 0.5))
    label_node:setPosition(ccp(data.size.width * 0.5, data.size.height * 0.5))
    menu_item:addChild(label_node)
    return menu_item
end

-- 创建提示的小红点
function createTipSpriteWithNum(num)
	require "script/ui/rechargeActive/ActiveCache"
	local tip_sprite= CCSprite:create("images/common/tip_2.png")
	tip_sprite:setAnchorPoint(ccp(0.5, 0.5))
	if num > 0 then
        local num_label = CCLabelTTF:create(tostring(num), g_sFontName, 17)
        tip_sprite:addChild(num_label)
		num_label:setAnchorPoint(ccp(0.5, 0.5))
        num_label:setPosition(ccp(tip_sprite:getContentSize().width * 0.5, tip_sprite:getContentSize().height * 0.5))
	end
	return tip_sprite
end


-- 释放模块占用资源
function release()
	LuaCCSprite = nil
	for k, v in pairs(package.loaded) do
		local s, e = string.find(k, "/LuaCCSprite")
		if s and e == string.len(k) then
			package.loaded[k] = nil
		end
	end
end
--窗口弹出后放大再缩小的效果
--add by DJN 2014/10/20
function runShowAction( p_node )
   
    local thisScale = p_node:getScale()
    p_node:setScale(0)
    local array = CCArray:create()
    local scale1 = CCScaleTo:create(0.08,1.2*thisScale)
    local fade = CCFadeIn:create(0.06)
    local spawn = CCSpawn:createWithTwoActions(scale1,fade)
    local scale2 = CCScaleTo:create(0.07,0.9*thisScale)
    local scale3 = CCScaleTo:create(0.07,1*thisScale)
    array:addObject(scale1)
    array:addObject(scale2)
    array:addObject(scale3)
    local seq = CCSequence:create(array)
    p_node:runAction(seq)
end

function removeChildrenByTag(node, tag)
    local children = node:getChildren()
    local willRemoveChildren = {} 
    for i = 0, children:count() - 1 do
        local child = tolua.cast(children:objectAtIndex(i), "CCNode")
        if child:getTag() == tag then
            table.insert(willRemoveChildren, child)
        end
    end
    for i = 1, #willRemoveChildren do
        willRemoveChildren[i]:removeFromParentAndCleanup(true)
    end
end

function reserveChildrenByTag(node, tag)
    local children = node:getChildren()
    local willRemoveChildren = {} 
    for i = 0, children:count() - 1 do
        local child = tolua.cast(children:objectAtIndex(i), "CCNode")
        if child:getTag() ~= tag then
            table.insert(willRemoveChildren, child)
        end
    end
    for i = 1, #willRemoveChildren do
        willRemoveChildren[i]:removeFromParentAndCleanup(true)
    end
end

--[[
    @author:            bzx
    @desc:              创建一个列表的标题栏
    @p_titleInfo:       标题栏信息
    {   
        insetRect = CCRectMake(34, 18, 4, 1)   
        bgImage = "images/battle/battlefield_report/bar.png",               -- 背景图片
        lineImage = "images/battle/battlefield_report/cutting_line.png",    -- 分割线
        width = 564                                                         -- 标题栏宽度
        height = 默认为图片的高度                                             -- 标题栏高度
        titlePositionY = 37                                                 -- 标题栏中的文字的y
        linePositionY = 40                                                  -- 分割线的y
        colInfos = {
            {
                image = "",                                                 -- 这列的标题图片
                positionX = 默认居中                                         -- 标题图片的x
                width = 100                                                 -- 这列的宽度
            }
            {
                ...
            }
        }
    }
--]]
function createTableTitleBar(p_titleInfo)
    p_titleInfo.bgImage = p_titleInfo.bgImage or "images/battle/battlefield_report/bar.png"
    p_titleInfo.insetRect = p_titleInfo.insetRect or CCRectMake(34, 18, 4, 1)
    p_titleInfo.lineImage = p_titleInfo.lineImage or "images/battle/battlefield_report/cutting_line.png"
    p_titleInfo.width = p_titleInfo.width or 564
    p_titleInfo.titleInfo = p_titleInfo.colInfos or {}
    local bar = CCScale9Sprite:create(p_titleInfo.insetRect, p_titleInfo.bgImage)
    p_titleInfo.height = p_titleInfo.height or bar:getContentSize().height
    p_titleInfo.titlePositionY = p_titleInfo.titlePositionY or 37
    p_titleInfo.linePositionY = p_titleInfo.linePositionY or 40
    bar:setPreferredSize(CCSizeMake(p_titleInfo.width, p_titleInfo.height))
    local x = 0
    for i = 1, #p_titleInfo.colInfos do
        local colInfo = p_titleInfo.colInfos[i]
        colInfo.positionX = colInfo.positionX or x + colInfo.width * 0.5
        local title = CCSprite:create(colInfo.image)
        bar:addChild(title)
        title:setAnchorPoint(ccp(0.5, 0.5))
        title:setPosition(ccp(colInfo.positionX, p_titleInfo.titlePositionY))
        local titleWidth = title:getContentSize().width
        if colInfo.width < titleWidth then
            title:setScale(colInfo.width / titleWidth)
        end
        x = x + colInfo.width
        if i < #p_titleInfo.colInfos then
            local line = CCSprite:create(p_titleInfo.lineImage)
            bar:addChild(line)
            line:setAnchorPoint(ccp(0.5, 0.5))
            line:setPosition(ccp(x, p_titleInfo.linePositionY))
        end
    end
    return bar
end
