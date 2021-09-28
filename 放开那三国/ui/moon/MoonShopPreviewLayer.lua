-- Filename：	MoonShopPreviewLayer.lua
-- Author：		bzx
-- Date：		2015-04-27
-- Purpose：		水月之镜商店宝物预览

module("MoonShopPreviewLayer", package.seeall)

btimport "script/ui/moon/STMoonShopPreviewLayer"

local _layer
local _touchPriority
local _zOrder
local _cellSize
local _cellItemCount = 4

function show(touchPriority, zOrder)
	_layer = create(touchPriority, zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function create( touchPriority, zOrder )
	init(touchPriority, zOrder)
	_layer = STMoonShopPreviewLayer:create()
	_layer:setSwallowTouch(true)
	_layer:setTouchPriority(_touchPriority)
	_layer:setTouchEnabled(true)
	loadItemTableView()
	loadBtn()
	adaptive()
	return _layer
end

function init( touchPriority, zOrder )
	_touchPriority = touchPriority or -800
	_zOrder = zOrder or 190
end

function loadItemTableView( ... )
	local itemTableView = _layer:getMemberNodeByName("itemTableView")
	local itemIds = MoonData.getMoonShopPreviewItemIds()
	_cellSize = CCSizeMake(itemTableView:getContentSize().width, 135)
	local cellCount = math.ceil(#itemIds / _cellItemCount)
    local eventHandler = function ( functionName, tableView, index, cell )
        if functionName == "cellSize" then
            return _cellSize
        elseif functionName == "cellAtIndex" then
            return createItemCell(index)
        elseif functionName == "numberOfCells" then
            return cellCount
        end
    end
    itemTableView:setEventHandler(eventHandler)
    itemTableView:setTouchPriority(_touchPriority - 10)
    itemTableView:reloadData()
end

function createItemCell( index )
    local cell = STTableViewCell:create()
    cell:setContentSize(_cellSize)
    local itemIds = MoonData.getMoonShopPreviewItemIds()
    local startIndex = (index - 1) * _cellItemCount + 1
    local endIndex = startIndex + 3
    if endIndex > #itemIds then
        endIndex = #itemIds
    end
    for i = startIndex, endIndex do
        local itemId = itemIds[i]
        local itemData = ItemUtil.getItemsDataByStr(string.format("7|%d|1", itemId))
        local icon, itemName, itemColor = ItemUtil.createGoodsIcon(itemData[1], _touchPriority - 1, 9999, _touchPriority - 50, nil,nil,nil,false)
        cell:addChild(icon)
        icon:setAnchorPoint(ccp(0, 0.5))
        icon:setPosition(ccs.point(34 + (icon:getContentSize().width + 30)* math.floor((i - 1) % _cellItemCount), 0.51, cell))

        local itemNameLabel = CCRenderLabel:create(itemName, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
        itemNameLabel:setColor(itemColor)
        itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
        itemNameLabel:setPosition(icon:getContentSize().width*0.5,-icon:getContentSize().height*0.15)
        icon:addChild(itemNameLabel)
    end
    return cell
end

function loadBtn( ... )
	local closeBtn = _layer:getMemberNodeByName("closeBtn")
	closeBtn:setClickCallback(closeCallback)
	closeBtn:setTouchPriority(_touchPriority - 1)
end

function closeCallback( ... )
	_layer:removeFromParent()
end

function adaptive( ... )
	local bgLayer = _layer:getMemberNodeByName("bgLayer")
	bgLayer:setContentSize(g_winSize)
	local bgSprite = _layer:getMemberNodeByName("bgSprite")
	bgSprite:setScale(MainScene.elementScale)
end