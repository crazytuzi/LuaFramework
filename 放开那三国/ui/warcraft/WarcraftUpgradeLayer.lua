-- Filename: WarcraftUpgradeLayer.lua
-- Author: bzx
-- Date: 2014-11-20
-- Purpose: 阵法升级

module("WarcraftUpgradeLayer", package.seeall)

require "script/ui/warcraft/WarcraftData"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/libs/LuaCCLabel"


local _layer 
local _curWarcraftIndex
local _touchPriority
local _zOrder
local _warcraftDatas
local _warcraftDatasMap
local _costDB
local _itemIsLack
local _silverIsLack
local _silverTip
local _curWarcraftInfo 
local _nextWarcraftIndex
local _arrow
local _warcraftTableView
local _is_handle_touch
local _drag_began_x
local _touch_began_x
local _cell_size
local _itemTableView
local _effect
local _warcraftTableViewBg
local _descLabel
local _isMenuVisible
local _isAvatarVisible
local _isBulletinVisible

function show(touchPriority, zOrder, warcraftIndex)
	_layer = create(touchPriority, zOrder, warcraftIndex)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
	--MainScene.changeLayer(_layer, "DressRoomLayer")
	--MainScene.setMainSceneViewsVisible(false, false, false)
end

function init(touchPriority, zOrder, warcraftIndex )
	_touchPriority = touchPriority or -600
	_zOrder = zOrder or 1000
	_warcraftDatas = WarcraftData.getWarcraftDatas()
	_warcraftDatasMap = WarcraftData.getWarcraftDatasMap()
	_curWarcraftIndex = warcraftIndex
	_silverTip = nil
	_curWarcraftInfo = nil
	_nextWarcraftInfo = nil
	_arrow = nil
	_effect = nil
	_cell_size = CCSizeMake(515, 88)
	_descLabel = nil
	_isMenuVisible = MainScene.isMenuVisible()
	_isAvatarVisible = MainScene.isAvatarVisible()
	_isBulletinVisible = MainScene.isBulletinVisible()
	initCostDB()
end

function create(touchPriority, zOrder, warcraftIndex)

	init(touchPriority, zOrder, warcraftIndex)
	_layer = CCLayer:create()
	_layer:registerScriptHandler(onNodeEvent)
	MainScene.setMainSceneViewsVisible(false, false, false)
	loadBg()
	loadTitle()
	loadWarcraftTableView()
	loadItemTableView()
	loadMenu()
	refreshWarcraft()
	refreshSilverTip()
	refreshEffect()
	refreshDesc()
	return _layer
end

function loadBg( ... )
	local bg = CCSprite:create("images/boss/boss_bg.jpg")
	_layer:addChild(bg, -2)
	bg:setAnchorPoint(ccp(0.5, 0.5))
	bg:setPosition(ccpsprite(0.5, 0.5, _layer))
	bg:setScale(g_fBgScaleRatio)
end

function loadTitle( ... )
	local title = CCSprite:create("images/warcraft/warcraft_up_title.png")
	_layer:addChild(title)
	title:setAnchorPoint(ccp(0.5, 1))
	title:setPosition(ccpsprite(0.5, 0.99, _layer))
	title:setScale(MainScene.elementScale)
end

function refreshSilverTip()
	if _silverTip ~= nil then
		_silverTip:removeFromParentAndCleanup(true)
	end
	local richInfo = {}
	richInfo.labelDefaultSize = 23
	richInfo.labelDefaultFont = g_sFontPangWa
	richInfo.elements = {
		{
			["type"] = "CCRenderLabel",
			["text"] = GetLocalizeStringBy("key_8418"),
			["color"] = ccc3(0x0, 0xff, 0x18)

		},
		{
			["type"] = "CCSprite",
			["image"] = "images/common/coin_silver.png",
		},
		{
			["type"] = "CCRenderLabel",
			["text"] = tostring(_costDB.costsilver)
		}
	}
	if _costDB.costsilver > UserModel.getSilverNumber() then
		_silverIsLack = true
	else
		_silverIsLack = false
	end
	_silverTip = LuaCCLabel.createRichLabel(richInfo)
	_layer:addChild(_silverTip)
	_silverTip:setAnchorPoint(ccp(0.5, 0.5))
	_silverTip:setPosition(ccpsprite(0.5, 0.12, _layer))
	_silverTip:setScale(MainScene.elementScale)
end


function loadItemTableView( ... )
	local bg = CCScale9Sprite:create("images/common/bg/9s_1.png")
	_layer:addChild(bg)
	bg:setAnchorPoint(ccp(0.5, 0.5))
	bg:setPosition(ccpsprite(0.5, 0.213, _layer))
	bg:setPreferredSize(CCSizeMake(622, 126))
	bg:setScale(MainScene.elementScale)
	local arrowLeft = CCSprite:create("images/formation/btn_left.png")
	bg:addChild(arrowLeft)
	arrowLeft:setAnchorPoint(ccp(0, 0.5))
	arrowLeft:setPosition(4, bg:getContentSize().height * 0.5)

	local arrowRight = CCSprite:create("images/formation/btn_right.png")
	bg:addChild(arrowRight)
	arrowRight:setAnchorPoint(ccp(1, 0.5))
	arrowRight:setPosition(ccp(bg:getContentSize().width - 4, bg:getContentSize().height * 0.5))

	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(105, 100)
		elseif (fn == "cellAtIndex") then
			r = createItemCell(a1 + 1)
		elseif (fn == "numberOfCells") then
			r = #_costDB.costitems
			print("numberOfCells===", r)
		end
		return r
	end)
	-- 创建卡牌、物品显示tableview
	_itemTableView = LuaTableView:createWithHandler(handler, CCSizeMake(512, 102))
	bg:addChild(_itemTableView)
	_itemTableView:setAnchorPoint(ccp(0.5, 0.5))
	_itemTableView:ignoreAnchorPointForPosition(false)
	_itemTableView:setPosition(ccpsprite(0.5, 0.5, bg))
	_itemTableView:setTouchPriority(_touchPriority - 10)
	_itemTableView:setBounceable(true)
	_itemTableView:setDirection(kCCScrollViewDirectionHorizontal)
	_itemTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

function initCostDB( ... ) 
	local warcraftData = WarcraftData.getWarcraftDataByIndex(_curWarcraftIndex)
	if WarcraftData.isMaxLevel(warcraftData) == true then
		_costDB = {}
		_costDB.costsilver = 0
		_costDB.costitems = {}
	else
		_costDB = WarcraftData.getCostDB(warcraftData.level)
	end
end

function refreshWarcraftAncCost( ... )
	initCostDB()
	refreshWarcraft()
	refreshSilverTip()
	refreshEffect()
	local offset = _warcraftTableView:getContentOffset()
	_warcraftTableView:reloadData()
	_warcraftTableView:setContentOffset(offset)
	_itemTableView:reloadData()
end

function refreshEffect( ... )
	local warcraftData = WarcraftData.getWarcraftDataByIndex(_curWarcraftIndex)
	local warcraftDB = parseDB(DB_Method.getDataById(warcraftData.id))
	if warcraftDB.needmethodlv <= warcraftData.level then
		if _effect ~= nil then
			_effect:removeFromParentAndCleanup(true)
		end
		_effect = WarcraftLayer.createWarcraftEffect(warcraftData.id)
		_layer:addChild(_effect, -1)
		_effect:setAnchorPoint(ccp(0.5, 0.5))
		_effect:setPosition(ccpsprite(0.5, 0.62, _layer))
		_effect:setScale(0.78 * MainScene.elementScale)
	end
end

function createItemCell(index)
	local costitem = _costDB.costitems[index]
	local cell = CCTableViewCell:create()

	local headIcon = ItemSprite.getItemSpriteById( costitem[1], nil, nil, nil, _touchPriority - 5, nil, _touchPriority - 20)
	-- ItemSprite.createCommonIcon(5, costitem[1], 1)
	local realCount = ItemUtil.getCacheItemNumBy(costitem[1])
	local needCount = costitem[2]

	cell:addChild(headIcon, 1, 10001)
	local ccRenderLabelCount = CCRenderLabel:create( string.format("%d/%d", realCount, needCount), g_sFontName, 21, 1, ccc3(0, 0, 0), type_stroke)
	if realCount < needCount then
		ccRenderLabelCount:setColor(ccc3(0xff, 0, 0))
		_itemIsLack = true
	else
		ccRenderLabelCount:setColor(ccc3(0, 0xff, 0x18))
		_itemIsLack = false
	end
	ccRenderLabelCount:setPosition(headIcon:getContentSize().width/2, ccRenderLabelCount:getContentSize().height/2+2)
	ccRenderLabelCount:setAnchorPoint(ccp(0.5, 0.5))
	headIcon:addChild(ccRenderLabelCount)

	return cell
end


function loadWarcraftTableView( ... )
	local bg = CCScale9Sprite:create("images/common/bg/9s_1.png")
	_layer:addChild(bg)
	bg:setAnchorPoint(ccp(0.5, 0.5))
	bg:setPosition(ccpsprite(0.5, 0.805, _layer))
	bg:setPreferredSize(CCSizeMake(622, 200))
	bg:setScale(MainScene.elementScale)
	_warcraftTableViewBg = bg
	local arrowLeft = CCSprite:create("images/formation/btn_left.png")
	bg:addChild(arrowLeft)
	arrowLeft:setAnchorPoint(ccp(0, 0.5))
	arrowLeft:setPosition(4, bg:getContentSize().height - 45)

	local arrowRight = CCSprite:create("images/formation/btn_right.png")
	bg:addChild(arrowRight)
	arrowRight:setAnchorPoint(ccp(1, 0.5))
	arrowRight:setPosition(ccp(bg:getContentSize().width - 4, bg:getContentSize().height - 45))

	-- local descTitle = CCRenderLabel:create("说明：", g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- bg:addChild(descTitle)
	-- descTitle:setColor(ccc3(0xff, 0xf6, 0x00))
	-- descTitle:setAnchorPoint(ccp(0, 0.5))
	-- descTitle:setPosition(ccp(30, 80))

	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = _cell_size
		elseif (fn == "cellAtIndex") then
			r = createWarcraftCell(a1 + 1)
		elseif (fn == "numberOfCells") then
			r = #_warcraftDatas
		end
		return r
	end)
	_warcraftTableView = LuaTableView:createWithHandler(handler, CCSizeMake(512, 102))
	bg:addChild(_warcraftTableView)
	_warcraftTableView:setAnchorPoint(ccp(0.5, 0.5))
	_warcraftTableView:ignoreAnchorPointForPosition(false)
	_warcraftTableView:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height - 60))
	_warcraftTableView:setBounceable(true)
	_warcraftTableView:setDirection(kCCScrollViewDirectionHorizontal)
	_warcraftTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_warcraftTableView:setTouchEnabled(false)
	local offset = _warcraftTableView:getContentOffset()
	offset.x = -_cell_size.width * (_curWarcraftIndex - 1)
	_warcraftTableView:setContentOffset(offset)
end

function onNodeEvent(event)
    if (event == "enter") then
        _layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority - 2, true)
        _layer:setTouchEnabled(true)
    elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function onTouchesHandler(event, x, y)
	local position = _warcraftTableView:getParent():convertToNodeSpace(ccp(x, y))
    if event == "began" then
        local rect = _warcraftTableView:boundingBox()
        if rect:containsPoint(position) then
            _warcraftTableView:setBounceable(true)
            _drag_began_x = _warcraftTableView:getContentOffset().x
            _touch_began_x = position.x
            _is_handle_touch = true
        else
            _is_handle_touch = false
        end
        return true
    elseif event == "moved" then
        if _is_handle_touch == true then
            local offset = _warcraftTableView:getContentOffset()
            offset.x = _drag_began_x + position.x - _touch_began_x
            _warcraftTableView:setContentOffset(offset)
        end
    elseif event == "ended" or event == "cancelled" then
        if _is_handle_touch == true then
            local drag_ended_x = _warcraftTableView:getContentOffset().x
            local drag_distance = drag_ended_x - _drag_began_x
            local offset = _warcraftTableView:getContentOffset()
            if drag_distance >= 100 then
                offset.x = _drag_began_x + _cell_size.width
            elseif drag_distance <= -100 then
                offset.x = _drag_began_x - _cell_size.width
            else
                offset.x = _drag_began_x
            end
            _warcraftTableView:setBounceable(false)
            if offset.x > 0 then
                offset.x = 0
            end
            local container = _warcraftTableView:getContainer()
            if offset.x < -container:getContentSize().width + _warcraftTableView:getViewSize().width then
                offset.x = -container:getContentSize().width + _warcraftTableView:getViewSize().width
            end
            _layer:setTouchEnabled(false)
            local array = CCArray:create()
            array:addObject(CCMoveTo:create(0.3, offset))
            local endCallFunc = function()
                _layer:setTouchEnabled(true)
                local curWarcraftIndex = math.floor((-offset.x) / _cell_size.width) + 1
                if curWarcraftIndex ~= _curWarcraftIndex then
                	_curWarcraftIndex = curWarcraftIndex
                	refreshWarcraftAncCost()
                	refreshDesc()
            	end
            end
            array:addObject(CCCallFunc:create(endCallFunc))
            container:runAction(CCSequence:create(array))
        end
    end
end

function createWarcraftCell(index)
	local warcraftData = WarcraftData.getWarcraftDataByIndex(index)
	local cellSize = CCSizeMake(515, 88)
	local cell = CCTableViewCell:create()
	cell:setContentSize(cellSize)
	local bg = CCScale9Sprite:create(CCRectMake(16, 18, 4, 5), "images/warcraft/warcraft_bg.png")
	cell:addChild(bg)
	bg:setPreferredSize(CCSizeMake(487, 88))
	bg:setAnchorPoint(ccp(0.5, 0.5))
	bg:setPosition(ccpsprite(0.5, 0.5, cell))

	local warcraftIcon = WarcraftLayer.createWarcraftIcon(_warcraftDatas[index])
	bg:addChild(warcraftIcon)
	warcraftIcon:setAnchorPoint(ccp(0.5, 0.5))
	warcraftIcon:setPosition(ccp(82, bg:getContentSize().height * 0.5))

	local warcraftName = WarcraftLayer.createWarcraftName(_warcraftDatas[index])
	bg:addChild(warcraftName)
	warcraftName:setAnchorPoint(ccp(0.5, 0.5))
	warcraftName:setPosition(ccp(222, bg:getContentSize().height * 0.5))

	local level = CCSprite:create("images/boss/LV.png")
	bg:addChild(level)
	level:setAnchorPoint(ccp(0, 0.5))
	level:setPosition(ccp(321, bg:getContentSize().height * 0.5))

	local levelCount = CCRenderLabel:create(tostring(warcraftData.level), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	bg:addChild(levelCount)
	levelCount:setAnchorPoint(ccp(0, 0.5))
	levelCount:setPosition(ccp(371, bg:getContentSize().height * 0.5))
	levelCount:setColor(ccc3(0xff, 0xf6, 0x00))

	return cell
end

function refreshDesc( ... )
	 -- todo
	local warcraftData = WarcraftData.getWarcraftDataByIndex(_curWarcraftIndex)
	local warcraftDB = parseDB(DB_Method.getDataById(warcraftData.id))
	if _descLabel ~= nil then
		_descLabel:removeFromParentAndCleanup(true)
	end
	local richInfo = {}
	richInfo.width = 500
	richInfo.defaultType = "CCRenderLabel"
	richInfo.labelDefaultSize = 18
	richInfo.elements = {
		{
			text = warcraftDB.info
		}
	}
	_descLabel = LuaCCLabel.createRichLabel(richInfo)
	_warcraftTableViewBg:addChild(_descLabel)
	_descLabel:setAnchorPoint(ccp(0, 1))
	_descLabel:setPosition(ccp(80, 88))
end

function refreshWarcraft( ... )

	if _curWarcraftInfo ~= nil then
		_curWarcraftInfo:removeFromParentAndCleanup(true)
		if _nextWarcraftInfo ~= nil then
			_nextWarcraftInfo:removeFromParentAndCleanup(true)
			_nextWarcraftInfo = nil
		end
	end

	local curWarcraftData = _warcraftDatasMap[_warcraftDatas[_curWarcraftIndex]]
	_curWarcraftInfo = createWarcraftInfo(curWarcraftData, true)
	_layer:addChild(_curWarcraftInfo)
	_curWarcraftInfo:setAnchorPoint(ccp(0.5, 0.5))
	_curWarcraftInfo:setPosition(ccpsprite(0.23, 0.485, _layer))
	_curWarcraftInfo:setScale(MainScene.elementScale)

	if WarcraftData.isMaxLevel(curWarcraftData) == false then 
		local nextWarcraftData = table.hcopy(curWarcraftData, {})
		nextWarcraftData.level = nextWarcraftData.level + 1
		_nextWarcraftInfo = createWarcraftInfo(nextWarcraftData, false)
		_layer:addChild(_nextWarcraftInfo)
		_nextWarcraftInfo:setAnchorPoint(ccp(0.5, 0.5))
		_nextWarcraftInfo:setPosition(ccpsprite(0.77, 0.485, _layer))
		_nextWarcraftInfo:setScale(MainScene.elementScale)
	end

	if arrow == nil then
		_arrow = CCSprite:create("images/hero/transfer/arrow.png")
		_layer:addChild(_arrow)
		_arrow:setAnchorPoint(ccp(0.5, 0.5))
		_arrow:setPosition(ccpsprite(0.5, 0.485, _layer))
		_arrow:setScale(0.7 * MainScene.elementScale)
	end
end

function createWarcraftInfo(warcraftData, isCur)
	local bg = CCScale9Sprite:create(CCRectMake(50,43,16,6), "images/everyday/cell_bg.png")
	bg:setPreferredSize(CCSizeMake(293, 381))

	local name = WarcraftLayer.createWarcraftName(warcraftData.id)
	bg:addChild(name)
	name:setAnchorPoint(ccp(0.5, 0.7))
	name:setPosition(ccpsprite(0.5, 1, bg))

	local levelBg = CCSprite:create("images/warcraft/di2.png")
	bg:addChild(levelBg)
	levelBg:setAnchorPoint(ccp(0, 0.5))
	levelBg:setPosition(ccp(75, 310))

	local warcraftIcon = WarcraftLayer.createWarcraftIcon(warcraftData.id)
	bg:addChild(warcraftIcon)
	warcraftIcon:setAnchorPoint(ccp(0, 0.5))
	warcraftIcon:setPosition(ccp(35, 310))

	local level = CCSprite:create("images/boss/LV.png")
	bg:addChild(level)
	level:setAnchorPoint(ccp(0, 0.5))
	level:setPosition(ccp(110, 310))

	local levelCount = CCRenderLabel:create(tostring(warcraftData.level), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	bg:addChild(levelCount)
	levelCount:setAnchorPoint(ccp(0, 0.5))
	levelCount:setPosition(ccp(165, 310))
	levelCount:setColor(ccc3(0xff, 0xf6, 0x00))

	local affixBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	bg:addChild(affixBg)
	affixBg:setPreferredSize(CCSizeMake(256, 225))
	affixBg:setAnchorPoint(ccp(0.5, 0))
	affixBg:setPosition(ccpsprite(0.5, 0.1, bg))

	local affixType = WarcraftData.getAffixType(warcraftData.id, warcraftData.level)
	local affixValue = WarcraftData.getAffixValue(warcraftData.id, warcraftData.level)

	for i = 1, 6 do
		if affixType[i] ~= nil then
			local affixIcon = createAffixIcon(affixType[i], affixValue[i], isCur)
			affixBg:addChild(affixIcon)
			affixIcon:setAnchorPoint(ccp(0.5, 0.5))
			affixIcon:setPosition(ccp(45 + (i - 1) % 3 * 82, 170 - math.floor((i - 1) / 3) * 100))
		end
	end
	return bg
end

function createAffixIcon(type, value, isCur)
	local bg = CCSprite:create("images/warcraft/warcraft_icon_bg.png")
	local affixNameImages = {"atk_title.png", "def_title.png", "hp_title.png"}
	local affixName = CCSprite:create("images/warcraft/" .. affixNameImages[type])
	bg:addChild(affixName)
	affixName:setAnchorPoint(ccp(0.5, 0.5))
	affixName:setPosition(ccpsprite(0.5, 0.65, bg))

	local affixValue = CCRenderLabel:create("+" .. tostring(value), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	bg:addChild(affixValue)
	affixValue:setAnchorPoint(ccp(0.5, 0.5))
	affixValue:setPosition(ccpsprite(0.5, 0.3, bg))
	if isCur == false then
		affixValue:setColor(ccc3(0x0, 0xff, 0x18))
	end
	return bg
end

function loadMenu( ... )
	local menu = CCMenu:create()
	_layer:addChild(menu)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 300)

	local backItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(190, 73), GetLocalizeStringBy("key_8419"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	menu:addChild(backItem)
	backItem:setAnchorPoint(ccp(0.5, 0.5))
	backItem:registerScriptTapHandler(backCallback)
	backItem:setPosition(ccp(g_winSize.width * 0.3, 60 * MainScene.elementScale))
	backItem:setScale(MainScene.elementScale)

	local upgradeItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png", CCSizeMake(190, 73), GetLocalizeStringBy("key_8420"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	menu:addChild(upgradeItem)
	upgradeItem:setAnchorPoint(ccp(0.5, 0.5))
	upgradeItem:registerScriptTapHandler(upgradeCallback)
	upgradeItem:setPosition(ccp(g_winSize.width * 0.7, 60 * MainScene.elementScale))	
	upgradeItem:setScale(MainScene.elementScale)
end


function backCallback( ... )
	_layer:removeFromParentAndCleanup(true)
	MainScene.setMainSceneViewsVisible(_isMenuVisible, _isAvatarVisible, _isBulletinVisible)
end

function upgradeCallback( ... )	
	if _silverIsLack == true then
		AnimationTip.showTip(GetLocalizeStringBy("key_8421"))
		return
	end
	if _itemIsLack == true then
		AnimationTip.showTip(GetLocalizeStringBy("key_8422"))
		return
	end

	local warcraftData = _warcraftDatasMap[_warcraftDatas[_curWarcraftIndex]]
	if WarcraftData.isMaxLevel(warcraftData) then
		AnimationTip.showTip(GetLocalizeStringBy("key_8423"))
		return
	end
	local handleLevelup = function()
		WarcraftData.initAffixes()
		refreshWarcraftAncCost()
		WarcraftLayer.refresh()
		local ccDelegate=BTAnimationEventDelegate:create()
		ccDelegate:registerLayerEndedHandler(function (actionName, xmlSprite)
		end)
		ccDelegate:registerLayerChangedHandler(function (index, xmlSprite)
			if index+3 == 34 then
				require "script/audio/AudioUtil"
				AudioUtil.playEffect("audio/effect/zhuanshengchenggong.mp3")
				CCDirector:sharedDirector():getTouchDispatcher():setDispatchEvents(true)
				local warcraftData = _warcraftDatasMap[_warcraftDatas[_curWarcraftIndex]]
				require "script/ui/warcraft/WarcraftUpgradeEffectLayer"
				WarcraftUpgradeEffectLayer.show(warcraftData)

			end
		end)
		CCDirector:sharedDirector():getTouchDispatcher():setDispatchEvents(false)
		local sImgPath=CCString:create("images/base/effect/hero/transfer/zhuangchang")
		local clsEffect=CCLayerSprite:layerSpriteWithNameAndCount(sImgPath:getCString(), 1, CCString:create(""))
		clsEffect:setFPS_interval(1/60)
		clsEffect:setDelegate(ccDelegate)
		clsEffect:setScale(MainScene.elementScale)
		clsEffect:setPosition(ccp(g_winSize.width / MainScene.elementScale * 0.5 - 320, g_winSize.height))
		_layer:addChild(clsEffect)
	end
	WarcraftData.craftLevelup(_warcraftDatas[_curWarcraftIndex], handleLevelup)
end


