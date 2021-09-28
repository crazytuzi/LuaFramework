-- FileName: TreasureRoomPreviewLayer.lua
-- Author: bzx
-- Date: 15-07-05
-- Purpose: 通关宝物奖励

module("CityTreasurePreviewLayer", package.seeall)

local _layer
local _dialog
local _touchPriority 
local _zOrder
local _timeTipLabel
local _tableView
local _cellSize
local _gropCopyId
local _rewardInfo

function show(p_gropCopyId, p_touchPriority, p_zOrder)
	_layer = create(p_gropCopyId, p_touchPriority, p_zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer)
end

function init( ... )
    _layer = nil
    _dialog = nil
    _touchPriority = 0
    _zOrder = 0
    _timeTipLabel = nil
    _tableView = nil
    _cellSize = CCSizeMake(490, 135)
end

function initData(p_gropCopyId, p_touchPriority, p_zOrder)
	_touchPriority = p_touchPriority or -700
	_zOrder = p_zOrder or 100
	_gropCopyId = p_gropCopyId
	_rewardInfo = GuildBossCopyData.getTomorrowBoxRewardInfoByGroupCopyId(_gropCopyId)
end

function create(p_gropCopyId, p_touchPriority, p_zOrder)
    init()
	initData(p_gropCopyId, p_touchPriority, p_zOrder)
	local dialogInfo = {}
    dialogInfo.title = GetLocalizeStringBy("key_10276")
    dialogInfo.callbackClose = nil
    dialogInfo.size = CCSizeMake(589, 694)
    dialogInfo.priority = _touchPriority - 1
    dialogInfo.swallowTouch = true
    _layer = LuaCCSprite.createDialog_1(dialogInfo)
    _dialog = dialogInfo.dialog
    loadTableView()
	loadMenu()
    --schedule(_dialog, refreshTimeTip, 1)
    --refreshTimeTip()
    return _layer
end

function refreshTimeTip( ... )
	if _timeTipLabel ~= nil then
		_timeTipLabel:removeFromParentAndCleanup(true)
	end
	local time = TimeUtil.getIntervalByTime("240000")
	local curTime = TimeUtil.getSvrTimeByOffset()
	local remainTime = time - curTime
	local labelInfo = {
		labelDefaultSize = 21,
		labelDefaultColor = ccc3(0x78, 0x25, 0x00),
		width = 420,
		linespace = 10,
		elements = {
			{
				["type"] = "CCRenderLabel",
				text = TimeUtil.getTimeString(remainTime),
				color = ccc3(0xe4, 0x00, 0xff),
			}
		}
	}
	_timeTipLabel = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10138"), labelInfo)
	_dialog:addChild(_timeTipLabel)
	_timeTipLabel:setAnchorPoint(ccp(0.5, 1))
	_timeTipLabel:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height - 62))
end

function loadTableView( ... )
	local tableViewBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _dialog:addChild(tableViewBg)
    tableViewBg:setAnchorPoint(ccp(0.5, 0))
    tableViewBg:setPosition(ccp(_dialog:getContentSize().width * 0.5, 108))
    tableViewBg:setContentSize(CCSizeMake(490, 490))

    local titleBg = CCSprite:create("images/common/red_2.png")
    tableViewBg:addChild(titleBg)
    titleBg:setAnchorPoint(ccp(0.5, 0.5))
    titleBg:setPosition(ccp(tableViewBg:getContentSize().width * 0.5, tableViewBg:getContentSize().height + 25))
    local title = CCRenderLabel:create(GetLocalizeStringBy("key_10139"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    titleBg:addChild(title)
    title:setAnchorPoint(ccp(0.5, 0.5))
    title:setPosition(ccpsprite(0.5, 0.51, titleBg))
    title:setColor(ccc3(0xff, 0xe4, 0x00))

    local count = #_rewardInfo
     local h = LuaEventHandler:create(function(fn, tableView, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = _cellSize
        elseif fn == "cellAtIndex" then
            r = createCell(a1 + 1)
        elseif fn == "numberOfCells" then
            r = math.ceil(count / 3)
        elseif fn == "cellTouched" then
        elseif (fn == "scroll") then
        end
        return r
    end)
    local x = 1
    _tableView = LuaTableView:createWithHandler(h, CCSizeMake(_cellSize.width, tableViewBg:getContentSize().height - 10))
    tableViewBg:addChild(_tableView)
    _tableView:setAnchorPoint(ccp(0.5, 0))
    _tableView:setPosition(ccp(tableViewBg:getContentSize().width * 0.5, 5))
    _tableView:ignoreAnchorPointForPosition(false)
    _tableView:setDirection(kCCScrollViewDirectionVertical)
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _tableView:setTouchPriority(_touchPriority - 10)
end

function createCell(p_index)
	local cell = CCTableViewCell:create()
	cell:setContentSize(_cellSize)
	local rewardInfo = _rewardInfo
	for i = 1, 3 do
		local boxIndex = (p_index - 1) * 3 + i
		local boxInfo = rewardInfo[boxIndex]
		if boxInfo == nil then
			break
		end
		local rewardInfo = string.format("%d|%d|%d", boxInfo[1], boxInfo[2], boxInfo[3])
		local itemData = ItemUtil.getItemsDataByStr(rewardInfo)
		local showDownMenu = function()
        	MainScene.setMainSceneViewsVisible(false,false,false)
    	end
		local icon,itemName,itemColor = ItemUtil.createGoodsIcon(itemData[1], _touchPriority - 2, _zOrder + 10, nil,showDownMenu,nil,nil,false)
    	cell:addChild(icon)
		icon:setAnchorPoint(ccp(0.5, 0))
		icon:setPosition(ccp(75 + (i - 1) * 171, 25))

		local countLabel = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_10140"), boxInfo[5], boxInfo[4]), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		icon:addChild(countLabel)
		countLabel:setAnchorPoint(ccp(0.5, 0.5))
		countLabel:setPosition(ccpsprite(0.5, -0.2, icon))
	end
	return cell
end

function loadMenu( ... )
	local menu = CCMenu:create()
	_dialog:addChild(menu)
	menu:setPosition(ccp(0, 0))
	menu:setContentSize(_dialog:getContentSize())
	menu:setTouchPriority(_touchPriority - 5)
	
	local closeItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png", CCSizeMake(150,70), GetLocalizeStringBy("key_10141"), ccc3(255,222,0))
    menu:addChild(closeItem)
    closeItem:setAnchorPoint(ccp(0.5, 0.5))
    closeItem:setPosition(ccp(_dialog:getContentSize().width * 0.5, 60))
    closeItem:registerScriptTapHandler(closeCallback)
end

function closeCallback( ... )
	close()
end

function close( ... )
	if _layer ~= nil then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
	end
end