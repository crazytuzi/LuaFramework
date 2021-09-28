-- Filename: FindTreasureTrialLayer.lua
-- Author: bzx
-- Date: 2014-12-18
-- Purpose: 寻龙试炼

module("FindTreasureTrialLayer", package.seeall)

require "script/libs/LuaCCLabel"
require "script/ui/hero/HeroPublicLua"

local _layer
local _zOrder
local _touchPriority
local _bossTableView
local _eventId
local _eventDb
local HERO_TAG = 12344
local _armyIds
local _curIndex
local _refreshNode
local _refreshNodeMenu 
local _mapInfo
local _mapDb
local _pointLabel
local _floorLabel
local _actLabel
local _hpLabel
local _hpProgress
local _actTitle 
local _hpBg
local _addActBtn
local _buyActCount
local _addHpBtn
local _buyActTotalGoldCount
local _topNameBg
local _topNameLabel
local _fightTip
local _starBg
local _curCostPointLabel
local _curGetPointLabel
local _drag_began_x
local _touch_began_x
local _cellSize
local _isWin
local _is_handle_touch
local _tableViewIsMoving
local _curIndexAtTouchBegan
local _isLook
local _buyHpGoldCount
local _closeCallback
local _menu
local _directWinItem
local _winGoldCount

function show(touchPriority, zOrder, eventId, isLook, closeCallback)
	_layer = create(touchPriority, zOrder, eventId, isLook, closeCallback)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function init( ... )
	_layer = nil 
	_bossTableView = nil
	_eventId = 0
	_armyIds = {}
	_curIndex = 0
	_mapInfo = {}
	_mapDb = {}
	_topNameLabel = nil
	_fightTip = nil
	_starBg = nil
	_curCostPointLabel = nil
	_curGetPointLabel = nil
	_tableViewIsMoving = false
	_pointLabel = nil
	_floorLabel = nil
	_actLabel = nil
	_hpLabel = nil
	_menu = nil   
	_directWinItem = nil
	_winGoldCount = 0
end

function initData(touchPriority, zOrder, eventId , isLook, closeCallback)
	_eventId = eventId
	_armyIds = FindTreasureData.getTrialArmyIds(_eventId)
	_mapInfo = FindTreasureData.getMapInfo()
	_mapDb = FindTreasureData.getMapDb()
	_eventDb = DB_Explore_long_event.getDataById(eventId)
	_cellSize = CCSizeMake(math.ceil(g_winSize.width / 3), 700 * MainScene.elementScale)
	_isLook  = isLook
	_closeCallback = closeCallback
	_touchPriority = touchPriority or -550
	_zOrder = zOrder or 1000
end

function create(touchPriority, zOrder, eventId, isLook, closeCallback )
	init()
	initData(touchPriority, zOrder, eventId, isLook, closeCallback)
	_layer = CCLayer:create()
	_layer:registerScriptHandler(onNodeEvent)
	loadBg()
	loadTopNameBg()
	loadRefreshNode()
	loadBosses()
	loadMenu()
	loadExtraAwardTip()
	return _layer
end

function loadBg( ... )
	local bg = CCSprite:create("images/recycle/recyclebg.png")
	_layer:addChild(bg)
	bg:setAnchorPoint(ccp(0.5, 0.5))
	bg:setPosition(ccpsprite(0.5, 0.5, _layer))
	bg:setScale(g_fBgScaleRatio)
end

function loadTopNameBg( ... )
	_topNameBg = CCScale9Sprite:create("images/common/bg/9s_purple.png")
	_layer:addChild(_topNameBg, 10)
	_topNameBg:setAnchorPoint(ccp(0.5, 0.5))
	_topNameBg:setPosition(ccpsprite(0.5, 0.8, _layer))
	_topNameBg:setPreferredSize(CCSizeMake(425, 56))
	_topNameBg:setScale(MainScene.elementScale)
end

function refreshTopName( ... )
	local topNameRichInfo = {}
	topNameRichInfo.labelDefaultFont = g_sFontPangWa
	topNameRichInfo.labelDefaultSize = 36
	topNameRichInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
	topNameRichInfo.defaultType = "CCRenderLabel"
	local indexNames = {"key_8440", "key_8441", "key_8442", "key_8443", "key_8444", "key_8445", "key_8446", "key_8447", "key_8448", "key_8449"}

	local heroDb = HeroUtil.getBossInfoByArmyId(_armyIds[_curIndex])
	topNameRichInfo.elements = {
		{
			text =  GetLocalizeStringBy(indexNames[_curIndex])
		},
		{
			text = HeroUtil.getBossInfoByArmyId(_armyIds[_curIndex]).name,
			color = HeroPublicLua.getCCColorByStarLevel(heroDb.potential)
		}
	}
	if _topNameLabel ~= nil then
		_topNameLabel:removeFromParentAndCleanup(true)
	end
	_topNameLabel = LuaCCLabel.createRichLabel(topNameRichInfo)
	_topNameBg:addChild(_topNameLabel)
	_topNameLabel:setAnchorPoint(ccp(0.5, 0.5))
	_topNameLabel:setPosition(ccpsprite(0.5, 0.5, _topNameBg))
end

function loadExtraAwardTip( ... )
	local richInfo = {}
	richInfo.labelDefaultFont = g_sFontPangWa
	richInfo.labelDefaultSize = 18
	richInfo.defaultType = "CCRenderLabel"
	richInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
	richInfo.elements = {
		{
			text = GetLocalizeStringBy("key_8439"),
			color = ccc3(0xff, 0xff, 0xff)
		}
	}
	local extraAwardTip = GetLocalizeLabelSpriteBy_2("key_8450", richInfo)
	_layer:addChild(extraAwardTip)
	extraAwardTip:setAnchorPoint(ccp(0.5, 0.5))
	extraAwardTip:setPosition(ccpsprite(0.5, 0.1, _layer))
	extraAwardTip:setScale(MainScene.elementScale)
end

function refreshFightTip( ... )
	if _isLook == true then
		return
	end
	if _fightTip ~= nil then
		_fightTip:removeFromParentAndCleanup(true)
	end
	local moveData = FindTreasureData.getMoveData()
	local fightedIndex = tonumber(moveData.other.defeated or -1) + 1
	if _curIndex <= fightedIndex then
		_fightTip = CCSprite:create("images/forge/fighted.png")
	elseif _curIndex == fightedIndex + 1 then
		_fightTip = CCMenu:create()
		_fightTip:ignoreAnchorPointForPosition(false)
		_fightTip:setContentSize(CCSizeMake(150, 150))
		_fightTip:setTouchPriority(_touchPriority - 10)
		local fightItem = CCMenuItemImage:create("images/forge/fight_n.png", "images/forge/fight_h.png")
		_fightTip:addChild(fightItem)
		fightItem:setAnchorPoint(ccp(0.5, 0.5))
		fightItem:setPosition(ccpsprite(0.5, 0.5, _fightTip))
		fightItem:registerScriptTapHandler(fightCallback)
	else
		local richInfo = {}
		richInfo.labelDefaultFont = g_sFontPangWa
		richInfo.labelDefaultSize = 30
		richInfo.defaultType = "CCRenderLabel"
		richInfo.elements = {
			{
				text = HeroUtil.getBossInfoByArmyId(_armyIds[_curIndex - 1]).name,
				color = ccc3(0xff, 0xf6, 0x00)
			}
		}
		_fightTip = GetLocalizeLabelSpriteBy_2("key_8451", richInfo)
	end
	_layer:addChild(_fightTip)
	_fightTip:setAnchorPoint(ccp(0.5, 0.5))
	_fightTip:setPosition(ccpsprite(0.5, 0.2, _layer))
	_fightTip:setScale(MainScene.elementScale)
end

function refreshStar( ... )
	--星星
	-- 星星底
	if _starBg == nil then
		_starBg = CCSprite:create("images/formation/stars_bg.png")
		_starBg:setAnchorPoint(ccp(0.5, 1))
		_starBg:setPosition(ccpsprite(0.5, 0.75, _layer))
		_layer:addChild(_starBg, 10)
		_starBg:setScale(MainScene.elementScale)
	end
	_starBg:removeAllChildrenWithCleanup(true)
	-- 星星们
	local starsXPositions = {0.5, 0.4, 0.6, 0.3, 0.7, 0.2, 0.8}
	local starsYPositions = {0.75, 0.74, 0.74, 0.71, 0.71, 0.68, 0.68}
	local starsXPositionsDouble = {0.45,0.55,0.35,0.65,0.25,0.75,0.8}
    local starsYPositionsDouble = {0.745,0.745,0.72,0.72,0.7,0.7,0.68}

    local starLv = HeroUtil.getBossInfoByArmyId(_armyIds[_curIndex]).star_lv
	for k = 1, starLv  do
		local starSprite = CCSprite:create("images/formation/star.png")
		starSprite:setAnchorPoint(ccp(0.5, 0.5))
		if ((starLv%2) ~= 0) then
			starSprite:setPosition(ccp(_starBg:getContentSize().width * starsXPositions[k], _starBg:getContentSize().height * starsYPositions[k]))
		else
			starSprite:setPosition(ccp(_starBg:getContentSize().width * starsXPositionsDouble[k], _starBg:getContentSize().height * starsYPositionsDouble[k]))
		end
		_starBg:addChild(starSprite)
	end
end

function loadBosses( ... )
	local cellSize = _cellSize
	local numberOfCells = #_armyIds + 2
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize
        elseif fn == "cellAtIndex" then
            r = createBossesCell(a1)
        elseif fn == "numberOfCells" then
            r = numberOfCells
        elseif fn == "cellTouched" then
        elseif (fn == "scroll") then
        	
        end
        return r
    end)
    _bossTableView = LuaTableView:createWithHandler(h, CCSizeMake(g_winSize.width, 700 * MainScene.elementScale))
    _layer:addChild(_bossTableView)
    _bossTableView:setAnchorPoint(ccp(0.5, 0.5))
    _bossTableView:setPosition(ccp(_layer:getContentSize().width * 0.5, g_winSize.height * 0.5))
    _bossTableView:ignoreAnchorPointForPosition(false)
    --_myTableView:setBounceable(true)
    _bossTableView:setDirection(kCCScrollViewDirectionHorizontal)
    _bossTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _bossTableView:setTouchPriority(_touchPriority - 10)
    _bossTableView:setTouchEnabled(false)
    local moveData = FindTreasureData.getMoveData()
    _curIndex = tonumber(moveData.other.defeated or -1) + 1
    local offset = _bossTableView:getContentOffset()
    if _curIndex > 0 or _curIndex < #_armyIds then
    	offset.x = -(_curIndex) * _cellSize.width
    	_bossTableView:setContentOffset(offset)
	end
    refreshBossCell()
end

function createBossesCell(index)
	local cellSize = _cellSize
	local cell = CCTableViewCell:create()
	cell:setContentSize(cellSize)
	if index == 0 or index == #_armyIds + 1 then
		return cell
	end
	--local node = CCLayerColor:create(ccc4(100, 0, 0, 100))
	local node = CCSprite:create()
	cell:addChild(node)
	node:setContentSize(CCSizeMake(213, 550))
	node:setAnchorPoint(ccp(0.5, 0.5))
	node:setPosition(ccpsprite(0.5, 0.5, cell))
	node:setTag(HERO_TAG)
	node:setScale(MainScene.elementScale)
	node:ignoreAnchorPointForPosition(false)
	node:setCascadeColorEnabled(true)

	local stage = CCSprite:create("images/olympic/kingChair.png")
	node:addChild(stage)
	stage:setAnchorPoint(ccp(0.5, 0.5))
	stage:setPosition(ccp(node:getContentSize().width * 0.5, 60))
	stage:setScale(1.2)

	local armyId = _armyIds[index]
	local hero = HeroUtil.getBossBoyImgByArmyId(armyId)
	node:addChild(hero)
	hero:setAnchorPoint(ccp(0.5, 0))
	hero:setPosition(ccp(node:getContentSize().width * 0.5, 75))
	hero:setScale(0.8)

	local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	node:addChild(nameBg)
	nameBg:setPreferredSize(CCSizeMake(258, 32))
	nameBg:setAnchorPoint(ccp(0.5, 0.5))
	nameBg:setPosition(ccp(node:getContentSize().width * 0.5, 90))

	local heroDb = HeroUtil.getBossInfoByArmyId(armyId)
	local name =  CCRenderLabel:create(heroDb.name, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
	node:addChild(name)
	name:setAnchorPoint(ccp(0.5, 0.5))
	name:setPosition(ccp(node:getContentSize().width * 0.5, 92))
	name:setColor(HeroPublicLua.getCCColorByStarLevel(heroDb.potential))

	return cell
end

function loadMenu( ... )
	_menu = CCMenu:create()
	_layer:addChild(_menu)
	_menu:setPosition(ccp(0, 0))
	_menu:setTouchPriority(_touchPriority - 5)

	local leaveItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150, 73), GetLocalizeStringBy("key_8452"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(leaveItem)
    leaveItem:setAnchorPoint(ccp(0.5, 0.5))
    leaveItem:setPosition(ccp(_layer:getContentSize().width * 0.5 + 128 * MainScene.elementScale, 44 * MainScene.elementScale))
    leaveItem:registerScriptTapHandler(leaveCallback)
    leaveItem:setScale(MainScene.elementScale)

    refreshdirectWinItem()
    -- todo
end

function refreshdirectWinItem(  )
	if _menu == nil then
		return
	end
	if _directWinItem ~= nil then
		_directWinItem:removeFromParentAndCleanup(true)
	end
	_winGoldCount = parseField(_eventDb.gold_boss, 1)[_curIndex]
	local normalRichTextInfo = {
		labelDefaultSize = 30,
		labelDefaultColor = ccc3(0xfe, 0xdb, 0x1c),
		defaultType = "CCRenderLabel",
		labelDefaultFont = g_sFontPangWa,
		lineAlignment = 2,
		elements = {
			{
				text = GetLocalizeStringBy("key_8545"),
			},
			{	
				type = "CCSprite",
				image = "images/common/gold.png"
			},
			{
				text = _winGoldCount
			}
		}
	}
	local disabledRichTextInfo = table.hcopy(normalRichTextInfo, {})
	disabledRichTextInfo.labelDefaultColor = ccc3(0x88, 0x88, 0x88)
	disabledRichTextInfo.elements[2] = {
		type = "CCNode",
		create = function()
			return BTGraySprite:create("images/common/gold.png")
		end
	}
	_directWinItem = LuaCC.create9ScaleMenuItemWithRichInfo("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", "images/common/btn/btn1_g.png", CCSizeMake(240, 73), normalRichTextInfo, nil, disabledRichTextInfo)
	_menu:addChild(_directWinItem)
	_directWinItem:setAnchorPoint(ccp(0.5, 0.5))
	_directWinItem:setPosition(ccp(_layer:getContentSize().width * 0.5 - 88 * MainScene.elementScale, 44 * MainScene.elementScale))
	_directWinItem:registerScriptTapHandler(directWinCallback)
	_directWinItem:setScale(MainScene.elementScale)
	local moveData = FindTreasureData.getMoveData()
	local fightedIndex = tonumber(moveData.other.defeated or -1) + 1
	if _curIndex == fightedIndex + 1 then
		_directWinItem:setEnabled(true)
	else
		_directWinItem:setEnabled(false)
	end
end

function directWinCallback( ... )
	if UserModel.getGoldNumber() < _winGoldCount then
        SingleTip.showTip(GetLocalizeStringBy("key_8122"))
        return
    end
    if _mapInfo.act < parseField(_eventDb.bosscost, 1)[_curIndex] then
        SingleTip.showTip(GetLocalizeStringBy("key_8135"))
    	return
    end
	FindTreasureService.directWin(handleDirectWin, {_eventId, _curIndex - 1}, _curIndex, _eventDb)
end


function leaveCallback( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if _isLook == true then
		close()
		return
	end
	local moveData = FindTreasureData.getMoveData()
	local fightedIndex = tonumber(moveData.other.defeated) + 1
	if fightedIndex >= #_armyIds then
		leave(true)
	else
		local richInfo = {}
		richInfo.elements = {
			{
				text = GetLocalizeStringBy("key_8453")
			}
		}
	    RichAlertTip.showAlert(richInfo, leave, true, nil, GetLocalizeStringBy("key_8129"))
	end
end

function leave( isConfirm )
	if isConfirm == false then
		return
	end
	FindTreasureService.dragonSkip(handleLeave, {_mapInfo.posid - 1})
end

function handleLeave()
	print("handleLeave=======")
	close()
end

function close( ... )
	if _closeCallback ~= nil then
		_closeCallback()
	end
	_layer:removeFromParentAndCleanup(true)
end

function onNodeEvent(event)
    if (event == "enter") then
        _layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _layer:setTouchEnabled(true)
    elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function onTouchesHandler(event, x, y)
	if _tableViewIsMoving == true then
		_is_handle_touch = false
		return true
	end
	local position = _bossTableView:convertToNodeSpace(ccp(x, y))
    if event == "began" then
        local rect = _bossTableView:boundingBox()
        if rect:containsPoint(_bossTableView:getParent():convertToNodeSpace(ccp(x, y))) then
            _drag_began_x = _bossTableView:getContentOffset().x
            _touch_began_x = position.x
            _curIndexAtTouchBegan = _curIndex
            beginRefreshBossCell()
            _is_handle_touch = true
        else
            _is_handle_touch = false
        end
        local offset = _bossTableView:getContentOffset()
        return true
    elseif event == "moved" then
        if _is_handle_touch == true then
            local distance = position.x - _touch_began_x
            local offsetDistance = _bossTableView:getContentOffset().x - _drag_began_x
       		if offsetDistance > 0 and offsetDistance > _cellSize.width then
       			return
       		elseif offsetDistance < 0 and offsetDistance < -_cellSize.width then
       			return
       		end
       		local offset = _bossTableView:getContentOffset()
       		offset.x = _drag_began_x + distance
       		local minX = -(#_armyIds - 1) * _cellSize.width
            if offset.x < minX then
                offset.x = minX
            elseif offset.x > 0 then
            	offset.x = 0
            end
            _bossTableView:setContentOffset(offset)
        end
    elseif event == "ended" or event == "cancelled" then
        if _is_handle_touch == true then
            local drag_ended_x = _bossTableView:getContentOffset().x
            local touchEndPosition = _bossTableView:getParent():convertToNodeSpace(ccp(x, y))
            local drag_distance = touchEndPosition.x - _touch_began_x
            local offset = _bossTableView:getContentOffset()
            offset.x = -(_curIndex - 1) * _cellSize.width
            _tableViewIsMoving = true
            --_bossTableView:setContentOffsetInDuration(offset, 0.15)
            local array = CCArray:create()
            --array:addObject(CCDelayTime:create(0.2))
            array:addObject(CCMoveTo:create(0.15, offset))
            local container = _bossTableView:getContainer()
            local endCallFunc = function()
            	_bossTableView:setContentOffset(offset)
            	refreshBossCell()
            	endRefreshBossCell()
                _tableViewIsMoving = false
            end
            array:addObject(CCCallFunc:create(endCallFunc))
            container:runAction(CCSequence:create(array))
            print("cellcount ======", container:getChildren():count())
        end
    end
end

function beginRefreshBossCell( ... )
	schedule(_layer, refreshBossCell, 1 / 60)
end

function endRefreshBossCell( ... )
	_layer:cleanup()
end

function refreshBossCell( ... )
	if _bossTableView ~= nil and _bossTableView:getContainer():getChildren():count() > 0  then
		local container = _bossTableView:getContainer()
		local cells = container:getChildren()
		local mainIndex = 0
		local maxScale = 0
		for i = 0, cells:count() - 1 do
			local cell = tolua.cast(cells:objectAtIndex(i), "CCTableViewCell")
			local hero = cell:getChildByTag(HERO_TAG)
			if hero ~= nil then
				local position = cell:convertToWorldSpace(ccp(hero:getPositionX(), hero:getPositionY()))
				local scale = 1 - math.abs(g_winSize.width * 0.5 - position.x) / g_winSize.width
				hero:setScale(MainScene.elementScale * scale)
				if scale > maxScale then
					mainIndex = cell:getIdx()
					maxScale = scale
				end
				container:reorderChild(cell, hero:getScale() * 10)
			end
		end
		for i=0, cells:count() - 1 do
			local cell = tolua.cast(cells:objectAtIndex(i), "CCTableViewCell")
			local hero = tolua.cast(cell:getChildByTag(HERO_TAG), "CCSprite")
			if hero ~= nil then
				if cell:getIdx() ~= mainIndex then
					hero:setColor(ccc3(0xad, 0xad, 0xad))
				else
					hero:setColor(ccc3(0xff, 0xff, 0xff))
				end
			end
		end
		if _curIndex ~= mainIndex and mainIndex ~= 0 and mainIndex ~= #_armyIds + 1 then
    		_curIndex = mainIndex
    		refreshTopName()
    		refreshFightTip()
    		refreshStar()
    		refreshCurCostAct()
    		refreshCurGetPoint()
    		refreshdirectWinItem()
		end
	end
end

function loadRefreshNode()
    _refreshNode = CCNode:create()
    _layer:addChild(_refreshNode, 10)
    _refreshNode:setAnchorPoint(ccp(0.5, 1))
    _refreshNode:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height - 15 * g_fScaleX))
    _refreshNode:setContentSize(CCSizeMake(640, 150))
    _refreshNodeMenu = CCMenu:create()
    _refreshNode:addChild(_refreshNodeMenu)
    _refreshNodeMenu:setPosition(ccp(0, 0))
    _refreshNodeMenu:setContentSize(_refreshNode:getContentSize())
    _refreshNodeMenu:setTouchPriority(_touchPriority - 10)
    _refreshNode:setScale(MainScene.elementScale)
    refreshFloor()
    refreshPoint()
    refreshAct()
    refreshHp()
end

function refreshCurCostAct( ... )
	if _curCostPointLabel ~= nil then
		_curCostPointLabel:removeFromParentAndCleanup(true)
	end
	local richInfo = {}
	richInfo.labelDefaultFont = g_sFontPangWa
	richInfo.labelDefaultSize = 18
	richInfo.defaultType = "CCRenderLabel"
	richInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
	richInfo.elements = {
		{
			text = parseField(_eventDb.bosscost, 1)[_curIndex],
			color = ccc3(0x00, 0xff, 0x18)
		}
	}
	_curCostPointLabel = GetLocalizeLabelSpriteBy_2("key_8454", richInfo)
	_layer:addChild(_curCostPointLabel)
	_curCostPointLabel:setAnchorPoint(ccp(0, 0.5))
	_curCostPointLabel:setPosition(ccpsprite(0.23, 0.14, _layer))
	_curCostPointLabel:setScale(MainScene.elementScale)
end

function refreshCurGetPoint( ... )
	if _curGetPointLabel ~= nil then
		_curGetPointLabel:removeFromParentAndCleanup(true)
	end
	local richInfo = {}
	richInfo.labelDefaultFont = g_sFontPangWa
	richInfo.labelDefaultSize = 18
	richInfo.defaultType = "CCRenderLabel"
	richInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
	richInfo.elements = {
		{
			text = parseField(_eventDb.bossscore, 1)[_curIndex],
			color = ccc3(0x00, 0xff, 0x18)
		}
	}
	_curGetPointLabel = GetLocalizeLabelSpriteBy_2("key_8455", richInfo)
	_layer:addChild(_curGetPointLabel)
	_curGetPointLabel:setAnchorPoint(ccp(0, 0.5))
	_curGetPointLabel:setPosition(ccpsprite(0.58, 0.14, _layer))
	_curGetPointLabel:setScale(MainScene.elementScale)
end


-- 刷新积分
function refreshPoint()
    if _pointLabel == nil then
        local pointTitle = CCSprite:create("images/forge/get_point.png")
        _refreshNode:addChild(pointTitle)
        pointTitle:setAnchorPoint(ccp(0, 0.5))
        pointTitle:setPosition(ccp(117, _refreshNode:getContentSize().height - 68))
        _pointLabel = CCRenderLabel:create(tostring(_mapInfo.point), g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
        _pointLabel:setAnchorPoint(ccp(0, 0.5))
        _pointLabel:setPosition(ccp(240, _refreshNode:getContentSize().height - 68))
        _pointLabel:setColor(ccc3(0x00, 0xff, 0x18))
        _refreshNode:addChild(_pointLabel)
    else
        _pointLabel:setString(tostring(_mapInfo.point))
    end
end

-- 刷新第几层
function refreshFloor()
	local text = GetLocalizeStringBy("key_8456")
    if _floorLabel == nil then
        local floorTitleBg = CCSprite:create("images/forge/floor_title_bg.png")
        _refreshNode:addChild(floorTitleBg)
        floorTitleBg:setAnchorPoint(ccp(0.5, 1))
        floorTitleBg:setPosition(ccp(_refreshNode:getContentSize().width * 0.5, _refreshNode:getContentSize().height - 5))
        _floorLabel = CCRenderLabel:create(text, g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_shadow)
        floorTitleBg:addChild(_floorLabel)
        _floorLabel:setColor(ccc3(0xff, 0xf6, 0x00))
        _floorLabel:setAnchorPoint(ccp(0.5, 0.5))
        _floorLabel:setPosition(ccp(floorTitleBg:getContentSize().width * 0.5, floorTitleBg:getContentSize().height * 0.5))
    else
    	_floorLabel:setString(text)
	end
end

-- 刷新行动力
function refreshAct()
     if _actLabel == nil then
        local actTitle = CCSprite:create("images/forge/act.png")
        _actTitle = actTitle
        _refreshNode:addChild(actTitle)
        actTitle:setAnchorPoint(ccp(0, 0.5))
        actTitle:setPosition(ccp(326, _refreshNode:getContentSize().height - 68))
        _actLabel = CCRenderLabel:create(tostring(_mapInfo.act) .. "/" .. DB_Explore_long.getDataById(1).beginAct, g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
        _refreshNode:addChild(_actLabel)
        _actLabel:setAnchorPoint(ccp(0, 0.5))
        _actLabel:setPosition(ccp(426, _refreshNode:getContentSize().height - 68))
        _actLabel:setColor(ccc3(0x00,0xff,0x18))
        local addActBtn = CCMenuItemImage:create("images/forge/add_h.png", "images/forge/add_n.png", "images/forge/add_n.png")
        _refreshNodeMenu:addChild(addActBtn)
        addActBtn:setAnchorPoint(ccp(0.5, 0.5))
        addActBtn:setPosition(ccp(512, _refreshNodeMenu:getContentSize().height - 68))
        addActBtn:registerScriptTapHandler(buyActCallback)
        _addActBtn = addActBtn
    else
        _actLabel:setString(tostring(_mapInfo.act) .. "/" .. DB_Explore_long.getDataById(1).beginAct)
    end
end

-- 购买行动力
function buyActCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local vipLimit = DB_Vip.getDataById(UserModel.getVipLevel() + 1).exploreLongActNum
    if _mapInfo.act >= 80 then
        SingleTip.showTip(GetLocalizeStringBy("key_8118"))
        return
    elseif _mapInfo.buyactnum == vipLimit then
        SingleTip.showTip(GetLocalizeStringBy("key_8119"))
        return
    end
    local args = {}
    args.title = GetLocalizeStringBy("key_8120")
    args.item_name = GetLocalizeStringBy("key_8121")
    args.count_limit = vipLimit  - _mapInfo.buyactnum
    if args.count_limit > 80 - _mapInfo.act then
        args.count_limit = 80 - _mapInfo.act
    end
    args.remain_count = vipLimit - _mapInfo.buyactnum
    args.getTotalPriceByCount = function(count)
        local totalGoldCount = 0
        for i = 1, count do
            local goldCount = _mapDb.actPay[1] + _mapDb.addActPay[1] * (_mapInfo.buyactnum + i - 1)
            if goldCount > _mapDb.addActPay[2] then
                goldCount = _mapDb.addActPay[2]
            end
            totalGoldCount = totalGoldCount + goldCount
        end
        return totalGoldCount
    end
    args.is_increase = true
    args.buyCallFunc = buyAct
    args.touchPriority = _touchPriority - 20
    SelecteBuyCountLayer.show(args)
end

-- 购买行动力
function buyAct(count, totalGoldCount)
    if UserModel.getGoldNumber() < totalGoldCount then
        SingleTip.showTip(GetLocalizeStringBy("key_8122"))
        return
    end
    FindTreasureService.dragonBuyAct(handleBuyAct, {0, count}, totalGoldCount, count)
    _buyActCount = count
    _buyActTotalGoldCount = totalGoldCount
end

-- 购买行动力网络回调
function handleBuyAct()
    refreshAct()
    SelecteBuyCountLayer.close()
    SingleTip.showTip(GetLocalizeStringBy("key_8123"))
end

-- 刷新血槽
function refreshHp()
    local maxHp = FindTreasureData.getFormationMaxHp()
    local mapDb = _mapDb
     if _hpLabel == nil then
        local hpBg = CCScale9Sprite:create("images/achie/exp.png")
        _hpBg = hpBg
        _refreshNode:addChild(hpBg)
        hpBg:setAnchorPoint(ccp(0, 0.5))
        hpBg:setPosition(ccp(212, _refreshNode:getContentSize().height - 118))
        hpBg:setContentSize(CCSizeMake(244, hpBg:getContentSize().height))
        local hpTitle = CCRenderLabel:create(GetLocalizeStringBy("key_8124"), g_sFontPangWa, 21, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
        _refreshNode:addChild(hpTitle)
        hpTitle:setColor(ccc3(0xff, 0xf6, 0x00))
        hpTitle:setAnchorPoint(ccp(0, 0.5))
        hpTitle:setPosition(ccp(115, _refreshNode:getContentSize().height - 118))
        _hpProgress = CCScale9Sprite:create("images/forge/hp_bar.png")
        _hpProgress:setAnchorPoint(ccp(0, 0))
        _hpProgress:setPosition(ccp(26, 4))
        hpBg:addChild(_hpProgress)
        _hpLabel = CCRenderLabel:create(tostring(math.floor(_mapInfo.hppool / maxHp * 100)) .. "%/" .. tostring(_mapDb.beginHp) .. "%" , g_sFontName, 20, 1, ccc3(0x00,0x00,0x00), type_shadow)
        hpBg:addChild(_hpLabel)
        _hpLabel:setAnchorPoint(ccp(0.5, 0))
        _hpLabel:setPosition(ccp(hpBg:getContentSize().width * 0.5, 5))
        _hpLabel:setColor(ccc3(0x00, 0xff, 0x18))
        local addHpBtn = CCMenuItemImage:create("images/forge/add_h.png", "images/forge/add_n.png", "images/forge/add_n.png")
        _refreshNodeMenu:addChild(addHpBtn)
        addHpBtn:setAnchorPoint(ccp(0.5, 0.5))
        addHpBtn:setPosition(ccp(482, _refreshNodeMenu:getContentSize().height - 118))
        addHpBtn:registerScriptTapHandler(buyHpCallback)
        _addHpBtn = addHpBtn
    else
        _hpLabel:setString(tostring(math.floor(_mapInfo.hppool / maxHp * 100)) .. "%/" .. tostring(_mapDb.beginHp) .. "%")
    end
    local progress = math.floor(_mapInfo.hppool / maxHp * 100)
    if progress > _mapDb.beginHp then
        progress = _mapDb.beginHp
    end
    if progress == 0 then
        _hpProgress:setVisible(false)
    else
        _hpProgress:setVisible(true)
        _hpProgress:setPreferredSize(CCSizeMake(192 * progress / _mapDb.beginHp, 23))
    end
end

function buyHpCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    _buyHpGoldCount = _mapDb.hpPay[1] + _mapDb.addHpPay[1] * _mapInfo.buyhpnum
    if _buyHpGoldCount > _mapDb.addHpPay[2] then
        _buyHpGoldCount = _mapDb.addHpPay[2]
    end
    AlertTip.showAlert(GetLocalizeStringBy("key_8131", _buyHpGoldCount, _mapDb.hpPay[2]), buyHp, true, nil, GetLocalizeStringBy("key_8129"))
end

-- 确认购买血的回调
function buyHp(isConfirm, _argsCB)
    if isConfirm == false then
        return
    end
    if UserModel.getGoldNumber() < _buyHpGoldCount then
        SingleTip.showTip(GetLocalizeStringBy("key_8122"))
        return
    end
    FindTreasureService.dragonBuyHp(handleBuyHp, {0}, _mapDb, _buyHpGoldCount)
end

function fightCallback()
	if FindTreasureData.getFormationHp() <= 0 then
        SingleTip.showTip(GetLocalizeStringBy("key_8136"))
        return
    end
	if _mapInfo.act < parseField(_eventDb.bosscost, 1)[_curIndex] then
        SingleTip.showTip(GetLocalizeStringBy("key_8135"))
    	return
    end

	FindTreasureService.dragonFightBoss(handleFightBoss, {_eventId, _curIndex - 1}, _curIndex, _eventDb)
end


-- 买血成功
function handleBuyHp()
    local mapDb = _mapDb
    refreshHp()
    if _mapInfo.hppool == 0 then
        SingleTip.showTip(string.format(GetLocalizeStringBy("key_8132"), mapDb.hpPay[2]))
    else
        SingleTip.showTip(string.format(GetLocalizeStringBy("key_8133"), mapDb.hpPay[2]))
    end
end

function handleDirectWin( dictData )
	UserModel.addGoldNumber(-_winGoldCount)
	require "script/ui/forge/FindTreasureFightResultLayer"
	_isWin = true
	local bossPoint = parseField(_eventDb.bossscore, 1)[_curIndex]
    local result_layer = FindTreasureFightResultLayer.getBattleReportLayer(_isWin, FindTreasureData.getDropItem(dictData), {}, bossPoint, backFromBattleLayerCallback, _touchPriority - 200, fightResultLayerToOtherLayerCallback, true)
	CCDirector:sharedDirector():getRunningScene():addChild(result_layer, 1000)
	local handle = function ( ... )
		_mapInfo = FindTreasureData.getMapInfo()
		refreshHp()
		refreshAct()
		refreshPoint()
		refreshTopName()
		refreshFightTip()
		refreshStar()
		refreshCurCostAct()
		refreshCurGetPoint()
	end
	FindTreasureService.dragonGetUserBf()
	FindTreasureService.dragonGetMap(handle)
end

function handleFightBoss(dictData)
	require "script/ui/forge/FindTreasureFightResultLayer"
	_isWin = dictData.ret.atkRet.server.appraisal ~= "E" and dictData.ret.atkRet.server.appraisal ~= "F"
	local bossPoint = parseField(_eventDb.bossscore, 1)[_curIndex]
    local result_layer = FindTreasureFightResultLayer.getBattleReportLayer(_isWin, FindTreasureData.getDropItem(dictData), {}, bossPoint, backFromBattleLayerCallback, _touchPriority - 200, fightResultLayerToOtherLayerCallback)
    require "script/battle/BattleLayer"
    BattleLayer.showBattleWithString(dictData.ret.atkRet.client, nil, result_layer, "xunlong.jpg",nil,nil,nil,nil,false)
	local handle = function ( ... )
		_mapInfo = FindTreasureData.getMapInfo()
		refreshHp()
		refreshAct()
		refreshPoint()
		refreshTopName()
		refreshFightTip()
		refreshStar()
		refreshCurCostAct()
		refreshCurGetPoint()
	end
	FindTreasureService.dragonGetUserBf()
	FindTreasureService.dragonGetMap(handle)
end

function backFromBattleLayerCallback( ... )
	local moveData = FindTreasureData.getMoveData()
	local fightedIndex = tonumber(moveData.other.defeated or -1) + 1
	if fightedIndex == #_armyIds then
		close()
	end
	reloadData()
end

function reloadData( ... )
	local contentOffset = _bossTableView:getContentOffset()
	_bossTableView:reloadData()
	if _isWin == true then
		contentOffset.x = contentOffset.x - _cellSize.width
		if contentOffset.x < -_bossTableView:getContentSize().width + _bossTableView:getViewSize().width then
        contentOffset.x = -_bossTableView:getContentSize().width + _bossTableView:getViewSize().width
    end
	end
	_bossTableView:setContentOffset(contentOffset)
	refreshBossCell()
end


function fightResultLayerToOtherLayerCallback( ... )
	close()
end