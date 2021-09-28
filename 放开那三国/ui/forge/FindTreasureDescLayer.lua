-- Filename: FindTreasureDescLayer.lua
-- Author: bzx
-- Date: 2014-06-12
-- Purpose: 寻龙探宝说明

module("FindTreasureDescLayer", package.seeall)

require "script/libs/LuaCCSprite"
require "db/DB_Explore_long"
require "db/DB_Help_tips"
require "script/libs/LuaCCLabel"

local _layer
local _dialog
local _touchPriority = -550
local _cellStatus
local _cellSizes = {}
local _normaCellSize
local _tableView
local SELECTED = 123
local NOT_SELECTED = 234

function show()
    create()
    CCDirector:sharedDirector():getRunningScene():addChild(_layer, 100)
end

function initData( ... )
    _cellStatus = {}
    for i = 1, 3 do
        _cellStatus[i] = NOT_SELECTED
    end
    _cellSizes = {CCSizeMake(640, 680), CCSizeMake(640, 360), CCSizeMake(640, 620)}
    _normaCellSize = CCSizeMake(640, 80)
end

function create()
    initData()
    _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
    _layer:registerScriptHandler(onNodeEvent)
    loadBg()
    loadTitle()
    loadTableView()
    -- local dialog_info = {}
    -- dialog_info.title = GetLocalizeStringBy("key_8101")
    -- dialog_info.callbackClose = closeCallback
    -- dialog_info.size = CCSizeMake(630, 830)
    -- dialog_info.priority = _touch_priority - 1
    -- _dialog = LuaCCSprite.createDialog_1(dialog_info)
    -- _layer:addChild(_dialog)
    -- _dialog:setAnchorPoint(ccp(0.5, 0.5))
    -- _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    -- _dialog:setScale(MainScene.elementScale)
    -- loadTips()
    -- loadTableView()
    return _layer
end

function onTouchesHandler(event)
    return true
end

function loadBg( ... )
    local bg = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
    _layer:addChild(bg)
    bg:setPreferredSize(CCSizeMake(g_winSize.width, g_winSize.height))
    bg:setAnchorPoint(ccp(0.5, 1))
    bg:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height - 60 * g_fScaleX))
end

function loadTitle( ... )
    local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
    topSprite:setScale(g_fScaleX)
    topSprite:setAnchorPoint(ccp(0.5, 1))
    topSprite:setPosition(ccp(g_winSize.width*0.5, g_winSize.height - 35 * g_fScaleX))
    _layer:addChild(topSprite, 2)

    -- 正常
    local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_8429"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp((topSprite:getContentSize().width)/2, topSprite:getContentSize().height*0.5 + 6))
    topSprite:addChild(titleLabel)

    local closeMenuBar = CCMenu:create()
    closeMenuBar:setPosition(ccp(0, 0))
    topSprite:addChild(closeMenuBar)

    -- 关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
    closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(topSprite:getContentSize().width*1.01, topSprite:getContentSize().height*0.54))
    closeBtn:registerScriptTapHandler(closeCallback)
    closeMenuBar:addChild(closeBtn)
    closeMenuBar:setTouchPriority(_touchPriority - 10)
    --MainScene.setMainSceneViewsVisible(false,false,true)
end

function loadTableView( ... )
    local indexTemp = 1
    local lastFunctionName
    local h = LuaEventHandler:create(function(functionName, tableView, index, cell)
        local ret = nil
        if functionName == "cellSize" then
            if lastFunctionName == "numberOfCells" then
                indexTemp = 1
            end
            print("cellSize===", indexTemp)
            ret = getCellSize(indexTemp)
            indexTemp = indexTemp + 1
        elseif functionName == "cellAtIndex" then
            indexTemp = index + 1
            print("cellAtIndex====", indexTemp)
            ret = creatCell(indexTemp, getCellSize(indexTemp))
        elseif functionName == "numberOfCells" then
            print("numberOfCells=====")
            ret = 3
        elseif functionName == "cellTouched" then
        elseif (functionName == "scroll") then
        end
        lastFunctionName = functionName
        return ret
    end)
    _tableView = LuaTableView:createWithHandler(h, CCSizeMake(640, g_winSize.height / g_fScaleX - 100 ))
    _layer:addChild(_tableView)
    _tableView:ignoreAnchorPointForPosition(false)
    _tableView:setAnchorPoint(ccp(0.5, 1))
    _tableView:setBounceable(true)
    _tableView:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height - 100 * g_fScaleX))
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _tableView:setTouchPriority(_touchPriority - 10)
    _tableView:setScale(g_fScaleX)
end

function getCellSize(index)
    if _cellStatus[index] == NOT_SELECTED then
        return _normaCellSize
    else
        return _cellSizes[index]
    end
end

function creatCell(index, cellSize)
    local cell = CCTableViewCell:create()
    cell:setContentSize(cellSize)
    local menu = CCMenu:create()
    cell:addChild(menu, 2)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touchPriority - 1)
    local menuItem = CCMenuItemImage:create("images/achie/0.png", "images/achie/1.png")
    menu:addChild(menuItem)
    menuItem:setAnchorPoint(ccp(0.5, 0.5))
    menuItem:setPosition(ccp(cell:getContentSize().width * 0.5, cell:getContentSize().height - 40))
    menuItem:registerScriptTapHandler(cellClickedCallback)
    menuItem:setTag(index)
    local titles = {GetLocalizeStringBy("key_8430"), GetLocalizeStringBy("key_8431"), GetLocalizeStringBy("key_8432")}
    local titleLabel = CCRenderLabel:create(titles[index], g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    menuItem:addChild(titleLabel)
    titleLabel:setAnchorPoint(ccp(0.5, 0.5))
    titleLabel:setPosition(ccpsprite(0.5, 0.54, menuItem))
    titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    if _cellStatus[index] == SELECTED then
        menuItem:selected()
        local fullRect = CCRectMake(0,0,75, 75)
        local insertRect = CCRectMake(30,30,15,15)
        local cellBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insertRect)
        cellBg:setPreferredSize(CCSizeMake(cellSize.width - 40, cellSize.height - 100))
        cell:addChild(cellBg)
        cellBg:setAnchorPoint(ccp(0.5, 1))
        cellBg:setPosition(ccp(cellSize.width * 0.5, cellSize.height - 85))
        if index == 1 then
            createDescCell(cellBg)
        elseif index == 2 then
            createItemCell(cellBg)
        elseif index == 3 then
            createEventCell(cellBg)
        end
    end
    return cell
end

function createDescCell(cellBg)
    local texts = string.split(DB_Help_tips.getDataById(1).tips, "|")
    local height = cellBg:getContentSize().height - 10
    for i = 1, #texts do
        local richInfo = {}
        richInfo.width = 540
        richInfo.labelDefaultSize = 21
        richInfo.elements = {
            {
                text = texts[i]
            }
        }

        local textLabel = LuaCCLabel.createRichLabel(richInfo)
        cellBg:addChild(textLabel)
        textLabel:setAnchorPoint(ccp(0, 1))
        textLabel:setPosition(50, height)
        
        local textNumberLabel = CCLabelTTF:create(tostring(i) .. ".", g_sFontName, 21)
        textLabel:addChild(textNumberLabel)
        textNumberLabel:setAnchorPoint(ccp(1, 1))
        textNumberLabel:setPosition(-textNumberLabel:getContentSize().width + 10, textLabel:getContentSize().height)
        --textNumberLabel:setColor(ccc3(0x78, 0x25, 0x00))
        height = height - textLabel:getContentSize().height - 9
    end
end

function createItemCell( cellBg )
    local items = parseField(DB_Explore_long.getDataById(1).itemPandect)
    local rowIconCount = 4
    local height =  math.ceil(#items / 4) * 120 - 45
    for i = 1, #items  do
       local goodsValues = {}
        goodsValues.type = "item"
        goodsValues.tid = items[i][1]
        goodsValues.num = 0
        local itemIcon = ItemUtil.createGoodsIcon(goodsValues, _touchPriority - 5, 1010, _touchPriority - 20, itemClickedCallback)
        cellBg:addChild(itemIcon)
        itemIcon:setAnchorPoint(ccp(0.5, 0.5))
        itemIcon:setPosition(ccp(90 + (itemIcon:getContentSize().width + 50) * ((i - 1)% rowIconCount), height))
        if i % rowIconCount == 0 then
            height = height - 120
        end
    end
end

function createEventCell( cellBg )
    local menu = BTSensitiveMenu:create()
    cellBg:addChild(menu)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touchPriority - 5)
    local rowIconCount = 4
    local mapDb = FindTreasureData.getMapDb()
    local eventCount = #mapDb.eventPandect
    local height = math.ceil(eventCount / 4) * 120 - 20
    for i=1, eventCount do
        local eventDb = DB_Explore_long_event.getDataById(mapDb.eventPandect[i])
        local image = "images/forge/treasure_icon/" .. eventDb.isIcon
        local eventItem = CCMenuItemImage:create(image, image)
        menu:addChild(eventItem)
        eventItem:setAnchorPoint(ccp(0.5, 0.5))
        eventItem:setPosition(ccp(90 + (90 + 50) * ((i - 1)% rowIconCount), height))
        eventItem:registerScriptTapHandler(eventCallback)
        eventItem:setTag(eventDb.id)
        local nameLabel = CCLabelTTF:create(eventDb.eventname, g_sFontName, 23)
        cellBg:addChild(nameLabel)
        nameLabel:setAnchorPoint(ccp(0.5, 0.5))
        nameLabel:setPosition(ccp(90 + (90 + 50) * ((i - 1)% rowIconCount), height - 55))
        nameLabel:setColor(ccc3(0x00, 0xff, 0x18))
        if i % rowIconCount == 0 then
            height = height - 120
        end
    end
end

function cellClickedCallback(tag, menuItem )
    local index = tag
    if _cellStatus[index] == NOT_SELECTED then
        menuItem:selected()
        _cellStatus[index] = SELECTED
    else
        _cellStatus[index] = NOT_SELECTED
    end
    _tableView:reloadData()
end

function eventCallback( tag, menuItem )
    local eventId = tag
    local eventDb = parseDB(DB_Explore_long_event.getDataById(eventId))
    TreasureDialog.previewTreasure(eventDb, false, nil, true, _touchPriority - 15)
end


-- 显示文字
function loadTips()
    local texts = string.split(DB_Help_tips.getDataById(1).tips, "|")
    local height = _dialog:getContentSize().height - 55
    for i = 1, #texts do
        local text = texts[i]
        local text_label = CCLabelTTF:create(text, g_sFontName, 21)
        _dialog:addChild(text_label)
        text_label:setAnchorPoint(ccp(0, 1))
        text_label:setPosition(50, height)
        text_label:setColor(ccc3(0x78, 0x25, 0x00))
        local dimensions_width = 540
        text_label:setDimensions(CCSizeMake(dimensions_width, 0))
        text_label:setHorizontalAlignment(kCCTextAlignmentLeft)
        local text_number_label = CCLabelTTF:create(tostring(i) .. ".", g_sFontName, 21)
        text_label:addChild(text_number_label)
        text_number_label:setAnchorPoint(ccp(1, 1))
        text_number_label:setPosition(-text_number_label:getContentSize().width + 10, text_label:getContentSize().height)
        text_number_label:setColor(ccc3(0x78, 0x25, 0x00))
        height = height - text_label:getContentSize().height - 5
    end
end

-- 宝物一览
function loadTableView1()
    local full_rect = CCRectMake(0,0,75, 75)
	local inset_rect = CCRectMake(30,30,15,15)
	local table_view_bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", full_rect, inset_rect)
	table_view_bg:setPreferredSize(CCSizeMake(580, 280))
    _dialog:addChild(table_view_bg)
    table_view_bg:setAnchorPoint(ccp(0.5, 0))
	table_view_bg:setPosition(ccp(_dialog:getContentSize().width * 0.5, 45))
    local cell_icon_count = 4
	local cell_size = CCSizeMake(479, 125)
    local items = parseDB(DB_Explore_long.getDataById(1)).itemPandect
	local h = LuaEventHandler:create(function(function_name, table_t, a1, cell)
		if function_name == "cellSize" then
			return cell_size
		elseif function_name == "cellAtIndex" then
			cell = CCTableViewCell:create()
			local start = a1 * cell_icon_count
			for i=1, 4 do
                local index = start + i
				if index <= #items then
                    local goodsValues = {}
                    goodsValues.type = "item"
                    goodsValues.tid = items[index][1]
                    goodsValues.num = 0
					local iconSprite = ItemUtil.createGoodsIcon(goodsValues, -435, 1010, -450, itemClickedCallback)
		            iconSprite:setAnchorPoint(ccp(0.5, 0.5))
		            iconSprite:setPosition(ccp(cell_size.width/cell_icon_count /2 + (i-1) * cell_size.width/cell_icon_count, cell_size.height * 0.5))
		            cell:addChild(iconSprite)
                end
			end
			return cell
		elseif function_name == "numberOfCells" then
			local count = #items
			return math.ceil(count / cell_icon_count )
		elseif function_name == "cellTouched" then
		elseif (function_name == "scroll") then
		end
	end)
	local item_table_view = LuaTableView:createWithHandler(h, CCSizeMake(500, 250))
    item_table_view:ignoreAnchorPointForPosition(false)
    item_table_view:setAnchorPoint(ccp(0.5, 1))
	item_table_view:setBounceable(true)
	item_table_view:setPosition(ccp(table_view_bg:getContentSize().width * 0.5, table_view_bg:getContentSize().height - 15))
	item_table_view:setVerticalFillOrder(kCCTableViewFillTopDown)
    item_table_view:setTouchPriority(_touch_priority - 2)
	table_view_bg:addChild(item_table_view)
    
    local title_bg = CCSprite:create("images/forge/floor_title_bg.png")
    table_view_bg:addChild(title_bg)
    title_bg:setAnchorPoint(ccp(0.5, 0.5))
    title_bg:setPosition(ccp(table_view_bg:getContentSize().width * 0.5, table_view_bg:getContentSize().height))
    
    local title_label = CCLabelTTF:create(GetLocalizeStringBy("key_8102"), g_sFontPangWa, 21)
    title_bg:addChild(title_label)
    title_label:setAnchorPoint(ccp(0.5, 0.5))
    title_label:setPosition(ccp(title_bg:getContentSize().width * 0.5, title_bg:getContentSize().height * 0.5))
    title_label:setColor(ccc3(0xff, 0xf6, 0x00))
    return table_view_bg
end

function itemClickedCallback()
end

function onNodeEvent(event)
    if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function closeCallback()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _layer:removeFromParentAndCleanup(true)
end