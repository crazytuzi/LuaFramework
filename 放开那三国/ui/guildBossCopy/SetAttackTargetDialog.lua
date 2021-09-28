-- FileName: SetAttackTargetDialog.lua
-- Author: bzx
-- Date: 15-04-01
-- Purpose: 设置攻打目标

module("SetAttackTargetDialog", package.seeall)

local _layer
local _dialog
local _touchPriority 
local _zOrder
local _cellSize
local _copyTableView
local __lastselectedCellIndex

function show(p_touchPriority, p_zOrder)
	_layer = create(p_touchPriority, p_zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer)
end

function init( ... )
    _layer = nil
    _dialog = nil
    _touchPriority = 0
    _zOrder = 0
    _cellSize = CCSizeMake(580, 150)
    _copyTableView = nil
end

function initData(p_touchPriority, p_zOrder)
	_touchPriority = p_touchPriority or -700
	_zOrder = p_zOrder or 100
end

function create( p_touchPriority, p_zOrder)
    init()
	initData(p_touchPriority, p_zOrder)
	local dialogInfo = {}
    dialogInfo.title = GetLocalizeStringBy("key_10120")
    dialogInfo.callbackClose = close
    dialogInfo.size = CCSizeMake(640, 700)
    dialogInfo.priority = _touchPriority - 1
    dialogInfo.swallowTouch = true
    _layer = LuaCCSprite.createDialog_1(dialogInfo)
    _dialog = dialogInfo.dialog
    loadTableView()
    loadBottomTip()
    return _layer
end

function loadTableView( ... )
    local tableViewBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _dialog:addChild(tableViewBg)
    tableViewBg:setAnchorPoint(ccp(0.5, 0))
    tableViewBg:setPosition(ccp(_dialog:getContentSize().width * 0.5, 77))
    tableViewBg:setContentSize(CCSizeMake(583, 559))

     local h = LuaEventHandler:create(function(fn, tableView, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = _cellSize
        elseif fn == "cellAtIndex" then
            r = createCell(a1 + 1)
        elseif fn == "numberOfCells" then
            r = table.count(DB_GroupCopy.GroupCopy)
        elseif fn == "cellTouched" then
        elseif (fn == "scroll") then
        end
        return r
    end)
    local x = 1
    _copyTableView = LuaTableView:createWithHandler(h, CCSizeMake(_cellSize.width, tableViewBg:getContentSize().height - 10))
    tableViewBg:addChild(_copyTableView)
    _copyTableView:setAnchorPoint(ccp(0.5, 0))
    _copyTableView:setPosition(ccp(tableViewBg:getContentSize().width * 0.5, 5))
    _copyTableView:ignoreAnchorPointForPosition(false)
    _copyTableView:setDirection(kCCScrollViewDirectionVertical)
    _copyTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _copyTableView:setTouchPriority(_touchPriority - 10)
end

function loadBottomTip( ... )
    local bottomTip = CCLabelTTF:create(GetLocalizeStringBy("key_10121"), g_sFontName, 18)
    _dialog:addChild(bottomTip)
    bottomTip:setAnchorPoint(ccp(0.5, 0.5))
    bottomTip:setPosition(ccp(_dialog:getContentSize().width * 0.5, 60))
    bottomTip:setColor(ccc3(0x78, 0x25, 0x00))

    local previewTip = CCRenderLabel:create(GetLocalizeStringBy("key_10277"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    _dialog:addChild(previewTip)
    previewTip:setAnchorPoint(ccp(0.5, 0.5))
    previewTip:setPosition(ccp(_dialog:getContentSize().width * 0.5, 35))
    previewTip:setColor(ccc3(0x00, 0xff, 0x00))
end

function createCell( p_index )
    local groupCopyId = p_index
    local groupCopyDb = DB_GroupCopy.getDataById(groupCopyId)
    local cell = CCTableViewCell:create()
    cell:setContentSize(_cellSize)
    local cellBg = CCScale9Sprite:create("images/common/bg/change_bg.png", CCRectMake(0,0,116,124), CCRectMake(52,44,6,4))
    cell:addChild(cellBg)
    cellBg:setContentSize(_cellSize)

    local menu = BTSensitiveMenu:create()
    cell:addChild(menu)
    menu:setContentSize(_cellSize)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touchPriority - 5)

    local cityNormalSprite = BossCopyCitySprite:getCitySprite(groupCopyId)
    local citySelectedSprite = BossCopyCitySprite:getCitySprite(groupCopyId)
    local cityBtn = CCMenuItemSprite:create(cityNormalSprite, citySelectedSprite)
    menu:addChild(cityBtn, 1, p_index)
    cityBtn:setAnchorPoint(ccp(0.5, 0.5))
    cityBtn:setPosition(ccp(96, 80))
    cityBtn:registerScriptTapHandler(cityCallback)

    local name = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_10122"), groupCopyId, groupCopyDb.des), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    cell:addChild(name)
    name:setAnchorPoint(ccp(0, 0.5))
    name:setPosition(ccp(184, 126))
    name:setColor(ccc3(0xff, 0xf6, 0x00))

    local infoBg = CCScale9Sprite:create("images/common/s9_3.png")
    cell:addChild(infoBg)
    infoBg:setContentSize(CCSizeMake(233, 86))
    infoBg:setPosition(ccp(176, 27))

    local tipFightForce = CCRenderLabel:create(GetLocalizeStringBy("key_10123"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    infoBg:addChild(tipFightForce)
    tipFightForce:setColor(ccc3(0xff, 0x8a, 0x00))
    tipFightForce:setAnchorPoint(ccp(0.5, 0.5))
    tipFightForce:setPosition(ccp(116, 58))

    local tipFightForceValue = CCRenderLabel:create(groupCopyDb.destwo, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    infoBg:addChild(tipFightForceValue)
    tipFightForceValue:setAnchorPoint(ccp(0.5, 0.5))
    tipFightForceValue:setPosition(ccp(116, 26))
    local lastGroupCopyId = groupCopyId - 1
    if groupCopyId == 1 or GuildBossCopyData.isPassedGroupCopy(lastGroupCopyId) then
        local normal = CCScale9Sprite:create("images/common/s9_4.png")
        normal:setPreferredSize(CCSizeMake(53, 48))
        local selecteItem = CCMenuItemSprite:create(normal, normal)
        menu:addChild(selecteItem)
        selecteItem:setTag(groupCopyId)
        selecteItem:setAnchorPoint(ccp(0.5, 0.5))
        selecteItem:setPosition(ccp(487, 88))
        selecteItem:registerScriptTapHandler(selectedCallback)
        if GuildBossCopyData.isNextTargetGroupCopy(groupCopyId) then
            addSelectedTag(selecteItem)
            _lastselectedCellIndex = p_index - 1
        end

        local timeTip = CCRenderLabel:create(GetLocalizeStringBy("key_10124"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
        cell:addChild(timeTip)
        timeTip:setAnchorPoint(ccp(0.5, 0.5))
        timeTip:setPosition(ccp(487, 41))
    else
        local groupCopyDb = DB_GroupCopy.getDataById(lastGroupCopyId)
        local conditionTip = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_10125"), groupCopyDb.des), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
        cell:addChild(conditionTip)
        conditionTip:setAnchorPoint(ccp(0.5, 0.5))
        conditionTip:setPosition(ccp(486, 70))
        conditionTip:setColor(ccc3(0xff, 0x8a, 0x00))
    end
    return cell
end

function cityCallback( p_tag, p_menuItem )
    btimport "script/ui/guildBossCopy/CityTreasurePreviewLayer"
    local groupCopyId = p_tag
    CityTreasurePreviewLayer.show(groupCopyId)
end

function selectedCallback( p_tag, p_menuItem )
    -- 判断官职 军团长 副军团长才能发 0为平民，1为会长，2为副会长
    if GuildDataCache.getMineMemberType() ~= 1 then
        AnimationTip.showTip(GetLocalizeStringBy("key_10119"))
        return
    end  
    local setTargetCallFunc = function ( ... )
        _copyTableView:updateCellAtIndex(_lastselectedCellIndex)
        local curSelectedCellIndex = p_tag - 1
        _copyTableView:updateCellAtIndex(curSelectedCellIndex)
    end
    local groupCopyId = p_tag
    if GuildBossCopyData.isNextTargetGroupCopy(groupCopyId) then
        return
    end
    GuildBossCopyService.setTarget(setTargetCallFunc, groupCopyId)
end

function addSelectedTag( p_menuItem )
    local selecteTagSprite = CCSprite:create("images/common/checked.png")
    p_menuItem:addChild(selecteTagSprite)
    selecteTagSprite:setAnchorPoint(ccp(0.5, 0.5))
    selecteTagSprite:setPosition(ccpsprite(0.5, 0.5, p_menuItem))
end

function close( ... )
    if _layer ~= nil then
        _layer:removeFromParentAndCleanup(true)
        _layer = nil
    end
end