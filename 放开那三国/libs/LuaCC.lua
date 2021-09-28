-- Filename: LuaCC.lua
-- Author: fang
-- Date: 2013-06-28
-- Purpose: 该文件用于在lua中封装CCObject对象

module ("LuaCC", package.seeall)

require "script/libs/LuaCCLabel"


-- createSpriteOfNumbers，用于创建带仅包含数字的精灵，0－9数字每个对应一张图
-- dirPath: 数字图片对应图径
-- numStr: 数字对应字符串
function createSpriteOfNumbers(dirPath, numStr, numberWidth)
	local sprite = nil
	local width=0
	numStr = "" .. numStr
	for i=1, #numStr do
		local tmpSprite = CCSprite:create(dirPath .. "/"..string.char(string.byte(numStr, i))..".png")
		tmpSprite:setContentSize(CCSizeMake(numberWidth, tmpSprite:getContentSize().height))
		tmpSprite:setAnchorPoint(ccp(0, 0.5))
        tmpSprite:setCascadeOpacityEnabled(true)
		if sprite == nil then
			sprite = tmpSprite
		else
			width = width + tmpSprite:getContentSize().width
			tmpSprite:setPosition(width, sprite:getContentSize().height/2)
			sprite:addChild(tmpSprite)
		end
	end

	return sprite
end

function createNodeOfNumbers(dirPath, numStr, numberWidth)
	local sprite = nil
	local node = CCNode:create()
	local width=0
	local needLength = 0
	local height = 0
	numStr = "" .. numStr
	for i=1, #numStr do
		local tmpSprite = CCSprite:create(dirPath .. "/"..string.char(string.byte(numStr, i))..".png")
		tmpSprite:setContentSize(CCSizeMake(numberWidth, tmpSprite:getContentSize().height))
		tmpSprite:setAnchorPoint(ccp(0, 0.5))
        tmpSprite:setCascadeOpacityEnabled(true)
        needLength = tmpSprite:getContentSize().width + needLength
        if height == 0 then
        	height = tmpSprite:getContentSize().height
        end

		if sprite == nil then
			sprite = tmpSprite
		else
			width = width + tmpSprite:getContentSize().width
			tmpSprite:setPosition(width, sprite:getContentSize().height/2)
			sprite:addChild(tmpSprite)
		end
	end

	node:setContentSize(CCSizeMake(needLength,height))
	sprite:setAnchorPoint(ccp(0,0))
	sprite:setPosition(ccp(0,0))
	node:addChild(sprite)
	return node
end

-- createSpriteOfNumbers，用于创建带仅包含数字的精灵，0－9数字每个对应一张图
-- dirPath: 数字图片对应图径
-- numStr: 数字对应字符串
-- add by DJN 20141024 为月签到用
-- 之前的createSpriteOfNumbers()返回sprite宽度在我这里用有问题
function createSpriteOfNumbersForMonthSign(dirPath, numStr, numberWidth)
	local sprite = nil
	local width=0
	numStr = "" .. numStr
	for i=1, #numStr do
		local tmpSprite = CCSprite:create(dirPath .. "/"..string.char(string.byte(numStr, i))..".png")
		tmpSprite:setContentSize(CCSizeMake(numberWidth, tmpSprite:getContentSize().height))
		tmpSprite:setAnchorPoint(ccp(0, 0.5))
        tmpSprite:setCascadeOpacityEnabled(true) 

		if sprite == nil then
			sprite = tmpSprite
		else

			tmpSprite:setPosition(width, sprite:getContentSize().height/2)
			sprite:addChild(tmpSprite)
		end
		width = width + tmpSprite:getContentSize().width
		
	end
    sprite:setContentSize(CCSizeMake(width,sprite:getContentSize().height))
	return sprite
end
function createNumberSprite02(dirPath, num)
	local numStr = num .. ""
	local numContent = CCSprite:create()
	local width  = 0
	local height = 0
	for i=1,string.len(numStr) do
		local singleChar = string.char(string.byte(numStr,i))
		local numSprite = CCSprite:create(dirPath .. "/".. singleChar .. ".png")
		numSprite:setAnchorPoint(ccp(0, 0.5))
		numSprite:setPosition(width, 23)
		numContent:addChild(numSprite)
		width = width + numSprite:getContentSize().width
		if(numSprite:getContentSize().height > height) then
			height = numSprite:getContentSize().height
		end
	end
    numContent:setCascadeOpacityEnabled(true)
	numContent:setContentSize(CCSizeMake(width,46))
	return numContent
end

-- createNumberSprite，用于创建带仅包含数字的精灵，0－9数字每个对应一张图
-- dirPath: 数字图片对应图径
-- num: 数字
function createNumberSprite(dirPath, num)
	local numStr = num .. ""
	local numContent = CCNode:create()
	local width  = 0
	local height = 0
	for i=1,string.len(numStr) do
		local singleChar = string.char(string.byte(numStr,i))
		local numSprite = CCSprite:create(dirPath .. "/".. singleChar .. ".png")
		numSprite:setAnchorPoint(ccp(0,0))
		numSprite:setPosition(width, 0)
		numContent:addChild(numSprite)
		width = width + numSprite:getContentSize().width
		if(numSprite:getContentSize().height > height) then
			height = numSprite:getContentSize().height
		end
	end
	numContent:setContentSize(CCSizeMake(width,height))
	return numContent
end

-- createMenuWithItems，用于创建N个菜单项的菜单
-- sBgFilename: 背景图片
-- tItems: menu_item数据结构
function createMenuWithItems(tItems)
	-- 建一空菜单容器
	local menu = CCMenu:create()
	local item
	for k,v in pairs(tItems) do
		if v.disable then
			item = CCMenuItemImage:create(v.normal, v.highlighted, v.disable)
		else
			item=CCMenuItemImage:create(v.normal, v.highlighted)
		end
		-- 是否选中
		if v.focus then
			item:selected()
		end
		item:setPosition(ccp(v.pos_x, v.pos_y))
		item:registerScriptTapHandler(v.cb)
		tItems[k].ccObj = item
		local tag = v.tag or -1
		menu:addChild(item, 0, tag)
	end

	return menu
end

-- createMenuWithSpriteFile, 用于创建用CCSprite为菜单项的菜单
-- tItems: menu_item数据结构
function createMenuWithSpriteFile(tItems)
	local menu = CCMenu:create()
	local item
	for k,v in pairs(tItems) do
		local normal = CCSprite:create(v.file.."_n.png")
		local highlighted = CCSprite:create(v.file.."_h.png")
		local disabled = BTGraySprite:create(v.file.."_n.png")
		item = CCMenuItemSprite:create(normal, highlighted, disabled)
		item:setPosition(ccp(v.pos_x, v.pos_y))
		if v.cb then
			item:registerScriptTapHandler(v.cb)
		end
		tItems[k].ccObj = item
		local tag = v.tag or -1
		menu:addChild(item, 0, tag)
	end
	return menu
end

-- createMenuWithSprite, 用于创建用CCSprite为菜单项的菜单
-- tItems: menu_item数据结构
function createMenuWithSprite(tItems)
	local menu = CCMenu:create()
	local item
	for k,v in pairs(tItems) do
		item = CCMenuItemSprite:create(v.normal, v.highlighted, v.disabled)
		item:setPosition(ccp(v.pos_x, v.pos_y))
		item:registerScriptTapHandler(v.cb)
		tItems[k].ccObj = item
		local tag = v.tag or -1
		menu:addChild(item, 0, tag)
	end
	return menu
end

-- 用于创建有背景的N个菜单项的菜单
function createMenuWithItemsOnBg(tBg, tItems)
	-- 菜单背景
	local menu_bg = CCSprite:create(tBg.filename)
	
	local menu = createMenuWithItems(tItems)
	menu:setPosition(ccp(tBg.menu_x, tBg.menu_y))
	menu_bg:addChild(menu, 0, tBg.menu_tag)

	return menu_bg
end

-- 创建带标题的图片（标题在图片的中心）
function createSpriteWithLabel(bgfile, tLabel, pSize)
	local ccSprite = CCScale9Sprite:create(bgfile)
	if pSize then
		ccSprite:setContentSize(pSize)
	end
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

	if tLabel.pos then
		ccLabel:setPosition(tLabel.pos)
	end

	if tLabel.anchor then
		ccLabel:setAnchorPoint(tLabel.anchor)
	end

	if (tLabel.tag) then
		ccSprite:addChild(ccLabel, 0, tLabel.tag)
	else
		ccSprite:addChild(ccLabel)
	end

	return ccSprite
end

-- 创建带标题的图片（标题在图片的中心）
function createSpriteWithRenderLabel(bgfile, tLabel)
	local ccSprite = CCSprite:create(bgfile)
	local spriteSize = ccSprite:getContentSize()
	local ccLabel = CCRenderLabel:create(tLabel.text, g_sFontName, tLabel.fontsize, tLabel.stroke_size, tLabel.stroke_color, type_stroke)
	ccLabel:setSourceAndTargetColor(tLabel.sourceColor, tLabel.targetColor)

--	ccLabel:setAnchorPoint(ccp(0.5, 0.5))
	local x = spriteSize.width/2
	local y = spriteSize.height/2
	if tLabel.vOffset then
		y = y + tLabel.vOffset+20
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

-- 创建带标题的图片（标题在图片的中心），图片为9宫格
function create9SpriteWithRenderLabel(tNGInfo, tLabel)
	local ccSprite = CCScale9Sprite:create(tNGInfo.file, tNGInfo.rect, tNGInfo.rectInsets)
	ccSprite:setContentSize(tNGInfo.preferredSize)
	local spriteSize = ccSprite:getContentSize()
--	local ccLabel = CCLabelTTF:create (tLabel.text, g_sFontName, tLabel.fontsize)

	local ccLabel = CCRenderLabel:create(tLabel.text, g_sFontName, tLabel.fontsize, tLabel.stroke_size, tLabel.stroke_color, type_stroke)
	ccLabel:setSourceAndTargetColor(tLabel.sourceColor, tLabel.targetColor)

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

-- 创建9宫格底，上附文字Sprite
function create9SpriteWithLabel(tNGInfo, tLabel)
	local ccSprite = CCScale9Sprite:create(tNGInfo.file, tNGInfo.rect, tNGInfo.rectInsets)
	ccSprite:setContentSize(tNGInfo.preferredSize)
	local spriteSize = ccSprite:getContentSize()
	local ccLabel = CCLabelTTF:create (tLabel.text, g_sFontName, tLabel.fontsize)

--	local ccLabel = CCRenderLabel:create(tLabel.text, g_sFontName, tLabel.fontsize, tLabel.stroke_size, tLabel.stroke_color, type_stroke)
--	ccLabel:setSourceAndTargetColor(tLabel.sourceColor, tLabel.targetColor)
	if tLabel.color then
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

-- 创建图片中带图片的Sprite，子图片在背景图片中心
function createSpriteWithSprite(sBGFile, sSubFile)
	local bg = CCSprite:create(sBGFile)
	local sub = CCSprite:create(sSubFile)
	sub:setPosition(ccp(bg:getContentSize().width/2, bg:getContentSize().height/2))
	sub:setAnchorPoint(ccp(0.5, 0.5))
	bg:addChild(sub)

	return bg
end

-- 创建九宫格按键
-- return CCMenuSprite
-- sample:LuaCC.create9ScaleMenuItem("images/battle/btn_1.png","images/battle/btn_2.png",CCSizeMake(200,70),GetLocalizeStringBy("key_1331"),ccc3(255,222,0))
function create9ScaleMenuItem(normalFileName,selectedFileName,itemSize,labelString,labelColor,labelSize,font,strokeSize,strokeColor,labelOffset,normalCapInsets,selectedCapInsets)
    
    local selectedScale = 0.93
    
    -- init texture
    local normalTexture = CCTextureCache:sharedTextureCache():addImage(normalFileName)
    --normalTexture:retain()
    
    selectedFileName = selectedFileName==nil and normalTexture or selectedFileName
    local selectedTexture = CCTextureCache:sharedTextureCache():addImage(selectedFileName)
    --selectedTexture:retain()
    
    itemSize = itemSize==nil and normalTexture:getContentSize() or itemSize
    
    -- init capInsets
    normalCapInsets = normalCapInsets==nil and CCRectMake(normalTexture:getContentSize().width*0.4, normalTexture:getContentSize().height*0.4, normalTexture:getContentSize().width*0.1, normalTexture:getContentSize().height*0.1) or normalCapInsets
    selectedCapInsets = selectedCapInsets==nil and CCRectMake(selectedTexture:getContentSize().width*0.4, selectedTexture:getContentSize().height*0.4, selectedTexture:getContentSize().width*0.1, selectedTexture:getContentSize().height*0.1) or selectedCapInsets
    
    -- init nodes
    local normalNode = CCScale9Sprite:create(normalCapInsets,normalFileName)
    normalNode:setContentSize(itemSize);
    normalNode:setPosition(0,0)
    normalNode:setAnchorPoint(ccp(0,0))

    local selectedNode = CCScale9Sprite:create(selectedCapInsets,selectedFileName)
    selectedNode:setContentSize(CCSizeMake(itemSize.width*selectedScale,itemSize.height*selectedScale))
    selectedNode:setPosition(itemSize.width*(1-selectedScale)/2,itemSize.height*(1-selectedScale)/2)
    selectedNode:setAnchorPoint(ccp(0,0))
    
    local disableNode = CCScale9Sprite:create(normalCapInsets,normalFileName)
    disableNode:setColor(ccc3(111,111,111))
    disableNode:setContentSize(itemSize);
    disableNode:setPosition(0,0)
    disableNode:setAnchorPoint(ccp(0,0))
    --disableNode = tolua.cast(disableNode,"CCNodeRGBA")
    --disableNode:setCascadeColorEnabled(true)

    -- init menuItem
    local menuItem = CCMenuItemSprite:create(normalNode,selectedNode,disableNode)
    
    -- init label
    labelSize = labelSize==nil and itemSize.height*0.45 or labelSize
    strokeSize = strokeSize==nil and labelSize*0.05 or strokeSize
    strokeColor = strokeColor==nil and ccc3(0,0,0) or strokeColor
    font = font==nil and g_sFontPangWa or font
    labelOffset = labelOffset==nil and ccp(0,0) or labelOffset
    
    local normalLabel = CCRenderLabel:create(labelString, font, labelSize, strokeSize, strokeColor)
    normalLabel:setColor(labelColor)
    normalLabel:setPosition((itemSize.width-normalLabel:getContentSize().width)/2 + labelOffset.x,itemSize.height-(itemSize.height-normalLabel:getContentSize().height)/2 + labelOffset.y)
    normalNode:addChild(normalLabel,1)
    
    local selectedLabel = CCRenderLabel:create(labelString, font, labelSize*selectedScale, strokeSize*selectedScale, strokeColor)
    selectedLabel:setColor(labelColor)
    selectedLabel:setPosition((itemSize.width-normalLabel:getContentSize().width)/2 + labelOffset.x,itemSize.height*selectedScale-(itemSize.height*selectedScale-normalLabel:getContentSize().height)/2 + labelOffset.y)
    selectedNode:addChild(selectedLabel,1)
    
    local disableLabel = CCRenderLabel:create(labelString, font, labelSize, strokeSize, strokeColor)
    disableLabel:setColor(ccc3(labelColor.r*111/255,labelColor.g*111/255,labelColor.b*111/255))
    disableLabel:setPosition((itemSize.width-normalLabel:getContentSize().width)/2 + labelOffset.x,itemSize.height-(itemSize.height-normalLabel:getContentSize().height)/2 + labelOffset.y)
    disableNode:addChild(disableLabel,1)
    
    -- release texture
    --normalTexture:release()
    --selectedTexture:release()
    
    return menuItem
end

--[[
	@desc: 		创建带有富文本的按钮
	@return:	CCMenuItemSprite
--]]
function create9ScaleMenuItemWithRichInfo( p_normalFileName, p_selectedFileName, p_disabledFileName, p_itemSize, p_normalRichInfo, p_selectedRichInfo, p_disabledRichInfo)
	local menuItem = create9ScaleMenuItemWithoutLabel(p_normalFileName, p_selectedFileName, p_disabledFileName, p_itemSize)
	p_selectedRichInfo = p_selectedRichInfo or p_normalRichInfo
	p_disabledRichInfo = p_disabledRichInfo or p_normalRichInfo
	
	local normalRichLabel = LuaCCLabel.createRichLabel(p_normalRichInfo)
	local normal = menuItem:getNormalImage()
	normal:addChild(normalRichLabel)
	normalRichLabel:setAnchorPoint(ccp(0.5, 0.5))
	normalRichLabel:setPosition(ccpsprite(0.5, 0.5, normal))

	local selectedRichLabel = LuaCCLabel.createRichLabel(p_selectedRichInfo)
	local selected = menuItem:getSelectedImage()
	selected:addChild(selectedRichLabel)
	selectedRichLabel:setAnchorPoint(ccp(0.5, 0.5))
	local selectedScale = selected:getContentSize().width / p_itemSize.width
	selectedRichLabel:setPosition(ccpsprite(0.5, 0.5, selected))
	selectedRichLabel:setScale(selectedScale)

	local disabledRichLabel = LuaCCLabel.createRichLabel(p_disabledRichInfo)
	local disabled = menuItem:getDisabledImage()
	disabled:addChild(disabledRichLabel)
	disabledRichLabel:setAnchorPoint(ccp(0.5, 0.5))
	disabledRichLabel:setPosition(ccpsprite(0.5, 0.5, disabled))
	return menuItem
end

--创建九宫格按键，李攀添加 ---不带label的 button
function create9ScaleMenuItemWithoutLabel(normalFileName,selectedFileName,disabledFileName,itemSize)
	local selectedScale = 0.93
    
    -- init texture
    local normalTexture = CCTextureCache:sharedTextureCache():addImage(normalFileName)
    --normalTexture:retain()
    
    selectedFileName = selectedFileName==nil and normalFileName or selectedFileName
    local selectedTexture = CCTextureCache:sharedTextureCache():addImage(selectedFileName)

	disabledFileName = disabledFileName==nil and normalFileName or disabledFileName
    local disabledTexture = CCTextureCache:sharedTextureCache():addImage(disabledFileName)
    --selectedTexture:retain()
    
    itemSize = itemSize==nil and normalTexture:getContentSize() or itemSize
    
    -- init capInsets
    normalCapInsets = normalCapInsets==nil and CCRectMake(normalTexture:getContentSize().width*0.4, normalTexture:getContentSize().height*0.4, normalTexture:getContentSize().width*0.1, normalTexture:getContentSize().height*0.1) or normalCapInsets
    selectedCapInsets = selectedCapInsets==nil and CCRectMake(selectedTexture:getContentSize().width*0.4, selectedTexture:getContentSize().height*0.4, selectedTexture:getContentSize().width*0.1, selectedTexture:getContentSize().height*0.1) or selectedCapInsets
    disabledCapInsets = disabledCapInsets== nil and CCRectMake(disabledTexture:getContentSize().width*0.4, disabledTexture:getContentSize().height*0.4, disabledTexture:getContentSize().width*0.1, disabledTexture:getContentSize().height*0.1) or disabledCapInsets

    -- init nodes
    local normalNode = CCScale9Sprite:create(normalCapInsets,normalFileName)
    normalNode:setContentSize(itemSize);
    normalNode:setPosition(0,0)
    normalNode:setAnchorPoint(ccp(0,0))

    local selectedNode = CCScale9Sprite:create(selectedCapInsets,selectedFileName)
    selectedNode:setContentSize(CCSizeMake(itemSize.width*selectedScale,itemSize.height*selectedScale))
    selectedNode:setPosition(itemSize.width*(1-selectedScale)/2,itemSize.height*(1-selectedScale)/2)
    selectedNode:setAnchorPoint(ccp(0,0))
    
    local disableNode = CCScale9Sprite:create(disabledCapInsets, disabledFileName)
    disableNode:setColor(ccc3(111,111,111))
    disableNode:setContentSize(itemSize);
    disableNode:setPosition(0,0)
    disableNode:setAnchorPoint(ccp(0,0))
    --disableNode = tolua.cast(disableNode,"CCNodeRGBA")
    --disableNode:setCascadeColorEnabled(true)

    -- init menuItem
    local menuItem = CCMenuItemSprite:create(normalNode,selectedNode,disableNode)

    return menuItem
end

-- 创建九宫格按键，并加入SPRITE
-- return CCMenuSprite
-- sample:LuaCC.create9ScaleMenuItemWithSpriteName("images/astrology/astro_btn_l.png","images/astrology/astro_btn_l.png",CCSizeMake(105,116),"astro_btnbg.png")
function create9ScaleMenuItemWithSpriteName(normalFileName,selectedFileName,itemSize,spriteName,labelOffset,normalCapInsets,selectedCapInsets)
    
    local selectedScale = 0.93
    
    -- init texture
    local normalTexture = CCTextureCache:sharedTextureCache():addImage(normalFileName)
    normalTexture:retain()
    
    selectedFileName = selectedFileName==nil and normalTexture or selectedFileName
    local selectedTexture = CCTextureCache:sharedTextureCache():addImage(selectedFileName)
    selectedTexture:retain()
    
    itemSize = itemSize==nil and normalTexture:getContentSize() or itemSize
    
    -- init capInsets
    normalCapInsets = normalCapInsets==nil and CCRectMake(normalTexture:getContentSize().width*0.4, normalTexture:getContentSize().height*0.4, normalTexture:getContentSize().width*0.1, normalTexture:getContentSize().height*0.1) or normalCapInsets
    selectedCapInsets = selectedCapInsets==nil and CCRectMake(selectedTexture:getContentSize().width*0.4, selectedTexture:getContentSize().height*0.4, selectedTexture:getContentSize().width*0.1, selectedTexture:getContentSize().height*0.1) or selectedCapInsets
    
    -- init nodes
    local normalNode = CCScale9Sprite:create(normalCapInsets,normalFileName)
    normalNode:setContentSize(itemSize);
    normalNode:setPosition(0,0)
    normalNode:setAnchorPoint(ccp(0,0))
    
    local selectedNode = CCScale9Sprite:create(selectedCapInsets,selectedFileName)
    selectedNode:setContentSize(CCSizeMake(itemSize.width*selectedScale,itemSize.height*selectedScale))
    selectedNode:setPosition(itemSize.width*(1-selectedScale)/2,itemSize.height*(1-selectedScale)/2)
    selectedNode:setAnchorPoint(ccp(0,0))
    
    local disableNode = CCScale9Sprite:create(normalCapInsets,normalFileName)
    disableNode:setContentSize(itemSize);
    disableNode:setPosition(0,0)
    disableNode:setAnchorPoint(ccp(0,0))
    
    -- init menuItem
    local menuItem = CCMenuItemSprite:create(normalNode,selectedNode,disableNode)
    
    if(spriteName~=nil and spriteName~="")then
        -- init label
        labelOffset = labelOffset==nil and ccp(0,0) or labelOffset
        
        local normalLabel = CCSprite:create(spriteName)
        normalLabel:setAnchorPoint(ccp(0.5,0.5))
        normalLabel:setPosition(normalNode:getContentSize().width*0.5+labelOffset.x,normalNode:getContentSize().height*0.5+labelOffset.y)
        --normalLabel:setPosition((itemSize.width-normalLabel:getContentSize().width)/2 + labelOffset.x,itemSize.height-(itemSize.height-normalLabel:getContentSize().height)/2 + labelOffset.y)
        normalNode:addChild(normalLabel,1)
        
        local selectedLabel = CCSprite:create(spriteName)
        selectedLabel:setAnchorPoint(ccp(0.5,0.5))
        selectedLabel:setPosition(selectedNode:getContentSize().width*0.5+labelOffset.x,selectedNode:getContentSize().height*0.5+labelOffset.y)
        selectedLabel:setScale(selectedScale)
        --selectedLabel:setPosition((itemSize.width-normalLabel:getContentSize().width)/2 + labelOffset.x,itemSize.height*selectedScale-(itemSize.height*selectedScale-normalLabel:getContentSize().height)/2 + labelOffset.y)
        selectedNode:addChild(selectedLabel,1)
        
        local disableLabel = CCSprite:create(spriteName)
        disableLabel:setAnchorPoint(ccp(0.5,0.5))
        disableLabel:setPosition(disableNode:getContentSize().width*0.5+labelOffset.x,disableNode:getContentSize().height*0.5+labelOffset.y)
        --disableLabel:setPosition((itemSize.width-normalLabel:getContentSize().width)/2 + labelOffset.x,itemSize.height-(itemSize.height-normalLabel:getContentSize().height)/2 + labelOffset.y)
        disableNode:addChild(disableLabel,1)
    end
    
    -- release texture
    normalTexture:release()
    selectedTexture:release()
    
    return menuItem
end

-- 创建紧跟label的sprite
-- example:
-- 	local tLabel = {text="100", fontsize=23, color=ccc3(0xef, 0xf6, 0), vOffset=-4, hOffset=0}
-- 	local tSprite = {file="images/common/lv.png",
-- 			pos_x = 20, pos_y=300,
-- 		}
--  local tObjs = LuaCC.createSpriteHeelLabel(tSprite, tLabel)
function createSpriteHeelLabel(tSprite, tLabel)
	local tObjs = {}
	local ccSpriteObj = CCSprite:create(tSprite.file)
	if tSprite.pos_x and tSprite.pos_y then
		ccSpriteObj:setPosition(ccp(tSprite.pos_x, tSprite.pos_y))
	end
	local spriteSize = ccSpriteObj:getContentSize()
	local ccLabelObj = CCLabelTTF:create(tLabel.text, g_sFontName, tLabel.fontsize)
	local x = spriteSize.width
	local y = 0
	if tLabel.hOffset then
		x = x + tLabel.hOffset
	end
	if tLabel.vOffset then
		y = y + tLabel.vOffset
	end
	ccLabelObj:setPosition(ccp(x, y))
	ccLabelObj:setAnchorPoint(ccp(0, 0))
	if tLabel.color then
		ccLabelObj:setColor(tLabel.color)
	end
	if tLabel.tag then
		ccSpriteObj:addChild(ccLabelObj, 0, tLabel.tag)
	else
		ccSpriteObj:addChild(ccLabelObj)
	end

	tObjs.ccSpriteObj = ccSpriteObj
	tObjs.ccLabelObj = ccLabelObj
	return tObjs
end

-- 创建进度条
-- 例子：主界面中“经验值”，“体力”经验条显示
function createProgressBarWithLabel(tProgress, tLabel)
	local tObjs = {}
    local ccBgObj = CCSprite:create(tProgress.bg.file)
    local ccProgressObj = CCSprite:create(tProgress.progress.file)
    ccProgressObj:setPosition(ccp(0, 0))
    ccProgressObj:setAnchorPoint(ccp(0, 0))
    ccBgObj:addChild(ccProgressObj)

    local ccLabelObj = nil
    if tLabel then
    	ccLabelObj = CCLabelTTF:create(tLabel.text, g_sFontName, tLabel.fontsize)
    	local x = ccBgObj:getContentSize().width/2
    	local y = ccBgObj:getContentSize().height/2
    	if tLabel.vOffset then
    		y = y + tLabel.vOffset
    	end
    	if tLabel.hOffset then
    		x = x + tLabel.hOffset
    	end
    	ccLabelObj:setPosition(ccp(x, y))
    	ccLabelObj:setAnchorPoint(ccp(0.5, 0.5))
    	ccBgObj:addChild(ccLabelObj)
    end
    tObjs.ccBgObj = ccBgObj
    tObjs.ccProgressObj = ccProgressObj
    tObjs.ccLabelObj = ccLabelObj

	return tObjs
end

-- 创建（带文字的）进度条，9宫格图片
-- 例子：武将强化界面，“卡牌强化”项
function createScale9ProgressBarWithLabel(tProgress, tLabel)
	local tObjs = {}
    local ccBgObj = CCScale9Sprite:create(tProgress.bg.file, tProgress.bg.fullRect, tProgress.bg.insetRect)
    ccBgObj:setPreferredSize(tProgress.bg.preferredSize)
    local ccProgressObj = CCScale9Sprite:create(tProgress.progress.file, tProgress.progress.fullRect, tProgress.progress.insetRect)
    ccProgressObj:setPosition(ccp(0, 0))
    ccProgressObj:setAnchorPoint(ccp(0, 0))
    if tProgress.progress.preferredSize then
    	ccProgressObj:setPreferredSize(tProgress.progress.preferredSize)
    end
    ccBgObj:addChild(ccProgressObj)

    local ccLabelObj = nil
    if tLabel then
    	ccLabelObj = CCLabelTTF:create(tLabel.text, g_sFontName, tLabel.fontsize)
    	ccLabelObj:setAnchorPoint(ccp(0.5, 0.5))
    	ccLabelObj:setPosition(ccp(tProgress.bg.preferredSize.width/2, tProgress.bg.preferredSize.height/2))
    	ccBgObj:addChild(ccLabelObj)
    end
    tObjs.ccBgObj = ccBgObj
    tObjs.ccProgressObj = ccProgressObj
    tObjs.ccLabelObj = ccLabelObj

	return tObjs
end
-- 普通标签类型
m_ksTypeLabel=1
-- 精灵类型
m_ksTypeSprite=2
-- 描边类型
m_ksTypeRenderLabel=3
-- 创建CCNode对象，这些节点在同一行中
function createCCNodesOnHorizontalLine(tArrData)
	local tObjs = {}
	local y = 0
	local x = 0
	local fontsize = 23
	local text = ""
	local ccObjFirst = nil
	local tag=-1
	local fontname=g_sFontName
	-- RenderLabel特有
	local strokeSize = 2
	local strokeColor = ccc3(0x6b, 0, 0)
	local color = ccc3(0xff, 0xf6, 0)
	for i=1, #tArrData do
		local ccObj=nil
		local v = tArrData[i]
		x = v.x or x
		y = v.y or y
		fontname = v.fontname or fontname
		fontsize = v.fontsize or fontsize
		-- CCLabel类型
		if v.ctype == m_ksTypeLabel then
			text = v.text or "lack of text!"
			ccObj=CCLabelTTF:create(text, fontname, fontsize)
		-- CCSprite类型
		elseif v.ctype == m_ksTypeSprite then
			ccObj=CCSprite:create(v.file)
		elseif v.ctype == m_ksTypeRenderLabel then
			text = v.text or "lack of text!"
			strokeSize = v.strokeSize or strokeSize
			strokeColor = v.strokeColor or strokeColor
			ccObj=CCRenderLabel:create(text, fontname, fontsize, strokeSize, strokeColor, type_stroke)
			ccObj:setColor(v.color)
		else
			tObjs = {}
			break
		end
		if v.hOffset then
			x = x + v.hOffset
		end
		if v.vOffset then
			y = y + v.vOffset
		end
		ccObj:setPosition(ccp(x, y))
		if v.color then
			ccObj:setColor(v.color)
		end
		if v.scale then
			ccObj:setScale(v.scale)
		end
		x = x + ccObj:getContentSize().width

		if not ccObjFirst then
			ccObjFirst = ccObj
		else
			tag = v.tag or -1
			ccObjFirst:addChild(ccObj, 0, tag)
		end

		tObjs[i] = ccObj
	end

	return tObjs
end
-- 在水平方向以第一个CCNode为参照物排版其它CCNodes
function hAlignCCNodesAsFirst(tCCNodes)
	if #tCCNodes == 0 then
		return false
	end
	local ccFirst = tCCNodes[1].ccObj
	local x, y=ccFirst:getPosition()
	local tSizeFirst = ccFirst:getContentSize()
	local xOffset = 0
	local yOffset = 0
	local anchorPoint = ccp(0, 0)

	x = x + tSizeFirst.width
	for i=2, #tCCNodes do
		local tElements = tCCNodes[i]
		local tSizeEle = tElements.ccObj:getContentSize()
		anchorPoint = tElements.anchorPoint or anchorPoint
		tElements.ccObj:setAnchorPoint(anchorPoint)
		if tElements.xOffset then
			x = x + tElements.xOffset
		end
		tElements.ccObj:setPosition(ccp(x, y+(tSizeFirst.height-tSizeEle.height)/2))
		x = x + tSizeEle.width
	end
	return true
end


-- 释放模块占用资源
function release()
	LuaCC = nil
	for k, v in pairs(package.loaded) do
		local s, e = string.find(k, "/LuaCC")
		if s and e == string.len(k) then
			package.loaded[k] = nil
		end
	end
end

