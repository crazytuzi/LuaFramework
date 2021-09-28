-- Filename: WarcraftLayer.lua
-- Author: bzx
-- Date: 2014-11-15
-- Purpose: 阵法

module("WarcraftLayer", package.seeall)

require "db/DB_Method"
require "script/ui/warcraft/WarcraftData"
require "script/libs/LuaCCLabel"
require "script/guide/NewGuide"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"

SHOW_TAG_GOD_WEAPON = 124	-- 神兵
SHOW_TAG_DEFAULT 	= 125	-- 默认

local _layer
local _warcraftDatas
local _warcraftDatasMap
local _usedWarcraftIndex
local _selectedWarcraftItem
local _selectedWarcraftIndex
local _touchPriority
local _warcraftInfoBg
local _heros
local _seats
local _touchBeganPoint
local _heroBeganPoint
local _beganIndex
local _endIndex
local _dragHero
local _useItem
local _isNewGuide
local _bottomTip
local _showTag

function show(touchPriority, zOder, showTag)
	touchPriority = touchPriority or -500
	_layer = create(touchPriority, zOder, showTag)
	_layer:setAnchorPoint(ccp(0.5, 0.5))
	_layer:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
	_layer:setScale(MainScene.elementScale)

	local layer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 190))
	_layer:addChild(layer, -1)
	layer:setAnchorPoint(ccp(0.5, 0.5))
	layer:ignoreAnchorPointForPosition(false)
	layer:setPosition(ccpsprite(0.5, 0.5, _layer))
	layer:setScale(1 / _layer:getScale())

	local menu = CCMenu:create()
	layer:addChild(menu)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 10)
	local closeCallback = function ( ... )
		_layer:removeFromParentAndCleanup(true)
	end

	require "script/ui/main/MainScene"
	closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(1, 1))
	closeMenuItem:registerScriptTapHandler(closeCallback)
	closeMenuItem:setPosition(ccp(g_winSize.width * 0.99, g_winSize.height * 0.95-20))
	closeMenuItem:setScale(MainScene.elementScale)
	menu:addChild(closeMenuItem)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOder)
end

function setNewGuide( isNewGuide )
	_isNewGuide = isNewGuide
end

function init( touchPriority, zOder, showTag )
	_touchPriority = touchPriority or -400
	_zOder = zOder or 500
	_warcraftDatas = WarcraftData.getWarcraftDatas()
	_warcraftDatasMap = WarcraftData.getWarcraftDatasMap()
	_selectedWarcraftItem = nil
	_selectedWarcraftIndex = WarcraftData.getUsedIndex() or 1
	_usedWarcraftIndex = nil
	_warcraftInfoBg = nil
	_touchBeganPoint = nil
	_beganIndex = nil
	_endIndex = nil
	_dragHero = nil
	_heroBeganPoint = nil
	_isNewGuide = NewGuide.guideClass ==  ksGuideWarcraft
	_bottomTip = nil
	_showTag = showTag or SHOW_TAG_DEFAULT
end

function create(touchPriority, zOder, showTag)
	init(touchPriority, zOder, showTag)
	--_layer = CCLayerColor:create(ccc4(255, 0, 0, 100))
	_layer = CCLayer:create()
	_layer:registerScriptHandler(onNodeEvent)
	_layer:setContentSize(CCSizeMake(640, 650))
	_layer:ignoreAnchorPointForPosition(false)
	_layer:setAnchorPoint(ccp(0.5, 0.5))
	_layer:setPosition(ccp(g_winSize.width * 0.5, (g_winSize.height - 310 * g_fScaleX) * 0.5 + 15 * g_fScaleX))
	local scaleY = (g_winSize.height - 310 * g_fScaleX) / 650
	local scaleX = (g_winSize.width / 640)
	local scale = scaleX > scaleY and scaleY or scaleX
	_layer:setScale(1 / MainScene.elementScale * scale)
	loadTip()
	loadMenu()
	loadWarcraftTableView()
	refreshBottomTip()

	-- 新手引导
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		-- 阵法新手引导3
		addGuideWarcraftGuide3()
	end))
	_layer:runAction(seq)

	return _layer
end

function loadMenu( ... )
 	local menu = CCMenu:create()
 	_layer:addChild(menu)
 	menu:setPosition(ccp(0, 0))
 	menu:setTouchPriority(_touchPriority - 10)

 	local upLevelItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png", CCSizeMake(190, 73), GetLocalizeStringBy("zzh_1295"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	menu:addChild(upLevelItem)
	upLevelItem:setAnchorPoint(ccp(0.5, 0.5))
	upLevelItem:registerScriptTapHandler(upLevelCallback)
	upLevelItem:setPosition(ccp(640 * 0.2, 40))

	local normal = CCScale9Sprite:create("images/common/btn/btn1_d.png")
	normal:setPreferredSize(CCSizeMake(190, 73))
	local textNormal = CCRenderLabel:create(GetLocalizeStringBy("key_8412"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	normal:addChild(textNormal)
	textNormal:setAnchorPoint(ccp(0.5, 0.5))
	textNormal:setPosition(ccpsprite(0.5, 0.5, normal))
	textNormal:setColor(ccc3(0xfe, 0xdb, 0x1c))

	local selected = CCScale9Sprite:create("images/common/btn/btn1_n.png")
	selected:setPreferredSize(CCSizeMake(190, 73))
	selected:setScale(0.93)
	local textSelected = CCRenderLabel:create(GetLocalizeStringBy("key_8413"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	selected:addChild(textSelected)
	textSelected:setAnchorPoint(ccp(0.5, 0.5))
	textSelected:setPosition(ccpsprite(0.5, 0.5, selected))
	textSelected:setColor(ccc3(0xfe, 0xdb, 0x1c))

	local disabled = CCScale9Sprite:create("images/common/btn/btn1_g.png")
	disabled:setPreferredSize(CCSizeMake(190, 73))
	local textDisabled = CCRenderLabel:create(GetLocalizeStringBy("key_8414"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	disabled:addChild(textDisabled)
	textDisabled:setAnchorPoint(ccp(0.5, 0.5))
	textDisabled:setPosition(ccpsprite(0.5, 0.5, disabled))
	textDisabled:setColor(ccc3(0x7d, 0x7d, 0x7d))

	local useItem = CCMenuItemSprite:create(normal, selected, disabled)
	selected:setAnchorPoint(ccp(0.5, 0.5))
	selected:setPosition(ccpsprite(0.5, 0.5, useItem))
	menu:addChild(useItem)
	useItem:setAnchorPoint(ccp(0.5, 0.5))
	useItem:registerScriptTapHandler(useCallback)
	useItem:setPosition(ccp(640 * 0.6, 40))
	useItem:setEnabled(false)
	_useItem = useItem

	local descItem = CCMenuItemImage:create("images/warcraft/desc_n.png", "images/warcraft/desc_h.png")
	menu:addChild(descItem)
	descItem:setAnchorPoint(ccp(0.5, 0.5))
	descItem:setPosition(ccp(640 * 0.9, 40))
	descItem:registerScriptTapHandler(descCallback)
end

function getGuideWarcraftCell( ... )
	return _tableView:cellAtIndex(1)
end

function getUseItem( ... )
	return _useItem
end

function descCallback( ... )
	require "script/ui/warcraft/WarcraftDescLayer"
	WarcraftDescLayer.show(_touchPriority - 20)
end

function upLevelCallback( ... )
	require "script/ui/warcraft/WarcraftUpgradeLayer"
	WarcraftUpgradeLayer.show(_touchPriority - 20, _zOder + 10, _selectedWarcraftIndex)
end

function useCallback( ... )
	---[==[阵法 新手引导屏蔽层
	---------------------新手引导---------------------------------
	require "script/guide/NewGuide"
	require "script/guide/WarcraftGuide"
	if(NewGuide.guideClass == ksGuideWarcraft and WarcraftGuide.stepNum == 4) then
		WarcraftGuide.changLayer()
	end
	---------------------end-------------------------------------
	--]==]
	local handleSetCurWarcraft = function ( ... )
		if _usedWarcraftIndex ~= nil then
			_tableView:updateCellAtIndex(_usedWarcraftIndex - 1)
		end
		_tableView:updateCellAtIndex(_selectedWarcraftIndex - 1)
		_useItem:setEnabled(false)

		-- 阵法引导第5步
		addGuideWarcraftGuide5()
	end
	WarcraftData.setCurWarcraft(_warcraftDatas[_selectedWarcraftIndex], handleSetCurWarcraft)
end

function loadTip( ... )
	local tip = CCRenderLabel:create(GetLocalizeStringBy("key_8415"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_layer:addChild(tip)
	tip:setAnchorPoint(ccp(0.5, 0.5))
	tip:setPosition(ccp(320, 640))
end

function refreshBottomTip( ... )

	if _bottomTip ~= nil then
		_bottomTip:removeFromParentAndCleanup(true)
		_bottomTip = nil
	end
	local richInfo = {}
	richInfo.width = 560
	richInfo.labelDefaultSize = 18
	richInfo.defaultRenderType = 2
	richInfo.alignment = 2
	--richInfo.labelDefaultColor = ccc3(0x00, 0xff, 0x18)
	richInfo.elements = {}
	local element = {}
	element.type = "CCRenderLabel"
	if WarcraftData.getAllAddtion() > 0 then
		element.text = GetLocalizeStringBy("key_8416", WarcraftData.getAllAddtion() * 100)
	else
		element.text = ""
	end
	table.insert(richInfo.elements, element)
	local curGoalData = WarcraftData.getCurGoalData()
	if curGoalData ~= nil then
		if curGoalData.textanother ~= nil then
			local element = {
				["type"] = "CCRenderLabel",
				["text"] = curGoalData.textanother or "",
				["color"] = ccc3(0x00, 0xff, 0x18),--ccc3(0xff, 0x00, 0xe1),
				["newLine"] = true
			}
			table.insert(richInfo.elements, element)
		end
	end
	_bottomTip = LuaCCLabel.createRichLabel(richInfo)
	_layer:addChild(_bottomTip)
	_bottomTip:setAnchorPoint(ccp(0.5, 0.5))
	_bottomTip:setPosition(ccp(320, 100))
end



function loadWarcraftTableView( ... )
	local bg = CCScale9Sprite:create(CCRectMake(16, 18, 4, 5), "images/warcraft/warcraft_bg.png")
	_layer:addChild(bg)
	bg:setPreferredSize(CCSizeMake(172, 480))
	bg:setAnchorPoint(ccp(0, 0.5))
	bg:setPosition(ccp(-15, 365))

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(147, 89)
		elseif fn == "cellAtIndex" then
			a2 = createWarcraftCell(a1 + 1)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_warcraftDatas
		elseif fn == "scroll" then
			-- refreshHeroArrows()
		end
		return r
	end)

	require "script/ui/mergeServer/accumulate/AccumulateActivity"
 	_tableView = LuaTableView:createWithHandler(h, CCSizeMake(153, 457))
 	bg:addChild(_tableView)
 	_tableView:setDirection(kCCScrollViewDirectionHorizontal)
 	_tableView:setAnchorPoint(ccp(0.5, 0.5))
 	_tableView:ignoreAnchorPointForPosition(false)
 	_tableView:setPosition(ccp(bg:getContentSize().width * 0.5 + 5, bg:getContentSize().height * 0.5))
 	_tableView:setDirection(kCCScrollViewDirectionVertical)
 	_tableView:setTouchPriority(_touchPriority - 10)
 	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
 	_tableView:reloadData()

 	local tableViewTitle = CCSprite:create("images/warcraft/warcraft_list_title.png")
	bg:addChild(tableViewTitle)
	tableViewTitle:setAnchorPoint(ccp(0.5, 0))
	tableViewTitle:setPosition(ccp(90, 462))
end

function createWarcraftCell(index)
	local warcraftId = _warcraftDatas[index]
	local warcraftData = _warcraftDatasMap[warcraftId]
	local methodDB = DB_Method.getDataById(warcraftId)

	local cellSize = CCSizeMake(152, 100)
	local cell = CCTableViewCell:create()
	cell:setContentSize(cellSize)

	local menu = BTSensitiveMenu:create()
	cell:addChild(menu)
	menu:setContentSize(cellSize)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 1)

	local menuItemSize = CCSizeMake(150, 83)
	local normal = CCScale9Sprite:create("images/warcraft/warcraft_cell_bg_n.png")
	normal:setPreferredSize(menuItemSize)

	local selected = CCScale9Sprite:create("images/warcraft/warcraft_cell_bg_h.png")
	selected:setPreferredSize(menuItemSize)

	local disabled = CCScale9Sprite:create("images/warcraft/warcraft_cell_bg_h.png")
	disabled:setPreferredSize(menuItemSize)

	local cellItem = CCMenuItemSprite:create(normal, selected, disabled)
	menu:addChild(cellItem)
	cellItem:setAnchorPoint(ccp(0.5, 0))
	cellItem:setPosition(ccpsprite(0.5, 0, menu))
	cellItem:setTag(index)
	cellItem:registerScriptTapHandler(warcraftCellCallback)

	local warcraftIcon = createWarcraftIcon(warcraftId)
	cellItem:addChild(warcraftIcon)
	warcraftIcon:setAnchorPoint(ccp(0.5, 0.5))
	warcraftIcon:setPosition(ccp(40, cellItem:getContentSize().height * 0.5))

	local warcraftName = CCRenderLabel:create(methodDB.name, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	cellItem:addChild(warcraftName)
	warcraftName:setColor(ccc3(0xe4, 0x00, 0xff))
	warcraftName:setAnchorPoint(ccp(0.5, 0.5))
	warcraftName:setPosition(ccp(107, 57))

	local levelSprite = CCSprite:create("images/common/lv.png")
	cellItem:addChild(levelSprite)
	levelSprite:setAnchorPoint(ccp(0, 0.5))
	levelSprite:setPosition(ccp(75, 28))

	local level = CCRenderLabel:create(tostring(warcraftData.level), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	cellItem:addChild(level)
	level:setAnchorPoint(ccp(0, 0.5))
	level:setPosition(ccp(108, 27))
	level:setColor(ccc3(0xff, 0xf6, 0x00))
	if WarcraftData.isUsed(methodDB.id) then
		_usedWarcraftIndex = index
		local usedTagBg = CCSprite:create("images/warcraft/red_bg.png")
		cellItem:addChild(usedTagBg)
		usedTagBg:setAnchorPoint(ccp(1, 1))
		usedTagBg:setPosition(ccp(menuItemSize.width + 3, menuItemSize.height + 10))
		local usedTagLabel = CCLabelTTF:create(GetLocalizeStringBy("key_8417"), g_sFontName, 18)
		usedTagBg:addChild(usedTagLabel)
		usedTagLabel:setAnchorPoint(ccp(0.5, 0.5))
		usedTagLabel:setPosition(ccpsprite(0.5, 0.5, usedTagBg))
		usedTagLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	end

	if index == _selectedWarcraftIndex then
		warcraftCellCallback(index, cellItem)
	end

	return cell
end

function refresh( ... )
	refreshWarcraftInfo()
	refreshBottomTip()
	local offset = _tableView:getContentOffset()
	_tableView:reloadData()
	_tableView:setContentOffset(offset)
end

function refreshWarcraftInfo( ... )
	if _warcraftInfoBg ~= nil then
		_warcraftInfoBg:removeFromParentAndCleanup(true)
	end
	_warcraftInfoBg = CCScale9Sprite:create("images/warcraft/warcraft_formation_bg.png")
	_layer:addChild(_warcraftInfoBg)
	_warcraftInfoBg:setPreferredSize(CCSizeMake(476, 480))
	_warcraftInfoBg:setAnchorPoint(ccp(1, 0.5))
	_warcraftInfoBg:setPosition(ccp(635, 365))

	if _isNewGuide == false then
		local name = createWarcraftName(_warcraftDatas[_selectedWarcraftIndex])
		_warcraftInfoBg:addChild(name, 20)
		name:setAnchorPoint(ccp(0.5, 0.7))
		name:setPosition(ccpsprite(0.5, 1, _warcraftInfoBg))
	end

	_heros = {}
	_seats = {}
	local formationInfo = nil
	if _showTag == SHOW_TAG_DEFAULT then
		formationInfo = DataCache.getFormationInfo()
	elseif _showTag == SHOW_TAG_GOD_WEAPON then
		formationInfo = GodWeaponCopyData.getFormationInfo()
	end
	local warcraftDB = parseDB(DB_Method.getDataById(_warcraftDatas[_selectedWarcraftIndex]))
	local warcraftData = _warcraftDatasMap[warcraftDB.id]
	local affixType = WarcraftData.getAffixType(warcraftData.id)
	local affixValue = WarcraftData.getAffixValue(warcraftData.id)

	if warcraftDB.needmethodlv <= warcraftData.level then
		local effect = createWarcraftEffect(_warcraftDatas[_selectedWarcraftIndex])
		_warcraftInfoBg:addChild(effect)
		effect:setAnchorPoint(ccp(0.5, 0.5))
		effect:setPosition(ccpsprite(0.5, 0.53, _warcraftInfoBg))
		effect:setScale(0.78)
		effect:setCascadeColorEnabled(true)
		effect:setColor(ccc3(100, 100, 100))
	else
		local tip = CCRenderLabel:create(warcraftDB.text, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		_warcraftInfoBg:addChild(tip)
		tip:setAnchorPoint(ccp(0.5, 0.5))
		tip:setPosition(ccpsprite(0.5, 0.06, _warcraftInfoBg))
	end

	for i=1, 6 do
		local light = CCSprite:create("images/warcraft/di.png")
		_warcraftInfoBg:addChild(light)
		light:setAnchorPoint(ccp(0.5, 0))
		light:setPosition(ccp(80 + (i - 1) % 3 * 156, 285 - math.floor((i - 1) / 3) * 210))

		local box = CCSprite:create("images/forge/hero_bg.png")
		_warcraftInfoBg:addChild(box)
		box:setAnchorPoint(ccp(0.5, 0.5))
		box:setPosition(ccp(80 + (i - 1) % 3 * 156, 380 - math.floor((i - 1) / 3) * 210))
		box:setScale(0.7)

		if _isNewGuide == false then
			if warcraftDB.frame[i] ~= nil then
				local affixBgImages = {"atk_bg.png", "def_bg.png", "hp_bg.png"}
				local affixNameImages = {"atk_title.png", "def_title.png", "hp_title.png"}
				local affixBg = CCSprite:create("images/warcraft/" .. affixBgImages[affixType[i]])
				_warcraftInfoBg:addChild(affixBg, 20)
				affixBg:setAnchorPoint(ccp(0.5, 0.5))
				affixBg:setPosition(ccp(93 + (i - 1) % 3 * 156, 270 - math.floor((i - 1) / 3) * 210))
				local richInfo = {}
				richInfo.lineAlignment = 2
				richInfo.elements = {
					{
				 		["type"] = "CCSprite",
				 		["image"] = "images/warcraft/" .. affixNameImages[affixType[i]]
					},
					{
						["type"] = "CCRenderLabel",
						["text"] = "+" .. tostring(affixValue[i]),
						["size"] = 18,
						["renderType"] = 2,
						["deltaPoint"] = ccp(-3, 0)
					}
				}
				local affix = LuaCCLabel.createRichLabel(richInfo)
				affixBg:addChild(affix)
				affix:setAnchorPoint(ccp(0.5, 0.5))
				affix:setPosition(ccpsprite(0.3, 0.5, affixBg))
			end
		end


		local seat = CCNode:create()--CCLayerColor:create(ccc4(0xff, 0x00, 0x00, 0xff))
		_warcraftInfoBg:addChild(seat, 24)
		seat:setContentSize(CCSizeMake(box:getContentSize().width * box:getScaleX(), box:getContentSize().height * box:getScaleY()))
		seat:setAnchorPoint(box:getAnchorPoint())
		seat:ignoreAnchorPointForPosition(false)
		seat:setPosition(box:getPosition())
		_seats[i] = seat

		local hid = formationInfo[tostring(i - 1)] or formationInfo[tonumber(i - 1)]
		if hid ~= nil and hid > 0 then
			local hero = HeroSprite.createHeroSprite(hid, i - 1)
			_warcraftInfoBg:addChild(hero)
			hero:setAnchorPoint(ccp(0.5, 0.5))
			hero:setPosition(ccp(box:getPositionX(), box:getPositionY() - 12))
			hero:setScale(0.7)
			_heros[i] = hero
		end
	end

	if WarcraftData.isUsed(warcraftDB.id) then
		_useItem:setEnabled(false)
	else
		_useItem:setEnabled(true)
	end

	-- 阵法引导第4步
	addGuideWarcraftGuide4()
end


function warcraftCellCallback(tag, menuItem)
	---[==[阵法 新手引导屏蔽层
	---------------------新手引导---------------------------------
	require "script/guide/NewGuide"
	require "script/guide/WarcraftGuide"
	if(NewGuide.guideClass == ksGuideWarcraft and WarcraftGuide.stepNum == 3) then
		WarcraftGuide.changLayer()
	end
	---------------------end-------------------------------------
	--]==]
	if tolua.cast(_selectedWarcraftItem, "CCMenuItemSprite") ~= nil then
		_selectedWarcraftItem:setEnabled(true)
	end
	if _isNewGuide == false then
		menuItem:setEnabled(false)
	end
	_selectedWarcraftItem = menuItem
	_selectedWarcraftIndex = tag
	refreshWarcraftInfo()
end


function createWarcraftIcon(warcraftId)
	local warcraftDB = DB_Method.getDataById(warcraftId)
	local bg = CCSprite:create("images/warcraft/warcraft_icon_bg.png")
	local icon = CCSprite:create("images/warcraft/icon/" .. warcraftDB.icon)
	bg:addChild(icon)
	icon:setAnchorPoint(ccp(0.5, 0.5))
	icon:setPosition(ccpsprite(0.5, 0.5, bg))
	return bg
end

function createWarcraftName(warcraftId)
	local warcraftDB = DB_Method.getDataById(warcraftId)
	local name = CCSprite:create(string.format("images/warcraft/name/%s", warcraftDB.printname))
	return name
end

function createWarcraftEffect(warcraftId)
	local warcraftDB = DB_Method.getDataById(warcraftId)
	local effect = CCLayerSprite:layerSpriteWithName(CCString:create(string.format("images/warcraft/effect/%s/%s", warcraftDB.effect, warcraftDB.effect)), -1, CCString:create(""))
	return effect
end

function onTouchesHandler( eventType, x, y )
	if eventType == "began" then
		_dragHero = nil
		local seatIndex = getSeatIndex(x, y)
		if seatIndex ~= nil then
			_beganIndex = seatIndex
			_dragHero = _heros[seatIndex]
			if _dragHero ~= nil then
				_warcraftInfoBg:reorderChild(_dragHero, 30);
				_touchBeganPoint = ccp(x, y)
				_heroBeganPoint = ccp(_dragHero:getPositionX(), _dragHero:getPositionY())
			end
		end
		return true
	elseif eventType == "moved" then
		if _dragHero ~= nil then
			local deltaX = x - _touchBeganPoint.x
			local deltaY = y - _touchBeganPoint.y
			local newPosition = ccp(_heroBeganPoint.x + deltaX / MainScene.elementScale, _heroBeganPoint.y + deltaY / MainScene.elementScale)
			_dragHero:setPosition(newPosition)
		end
	else
		if _dragHero ~= nil then
			local seatIndex = getSeatIndex(x, y)
			if seatIndex ~= nil then
				local handleSetFormationInfo = function()
					moveTo(_dragHero, ccp(_seats[seatIndex]:getPositionX(), _seats[seatIndex]:getPositionY() - 15), seatIndex)
					if _heros[seatIndex] ~= nil then
						moveTo(_heros[seatIndex], _heroBeganPoint, _beganIndex)
					end
					local heroTemp = _heros[_beganIndex]
					_heros[_beganIndex] = _heros[seatIndex]
					_heros[seatIndex] = heroTemp
				end
				WarcraftData.setFormationInfo(_beganIndex, seatIndex, handleSetFormationInfo, _showTag)
			else
				_dragHero:setPosition(_heroBeganPoint)
			end
		end
	end
end

function moveTo(hero, position, seatIndex)
	local actions = CCArray:create()
	actions:addObject(CCMoveTo:create(0.2, position))
	local moveEndCallFunc = function ( ... )
		hero:getParent():reorderChild(hero, seatIndex)
	end
	actions:addObject(CCCallFunc:create(moveEndCallFunc))
	hero:stopAllActions()
	hero:runAction(CCSequence:create(actions))
end


function getSeatIndex(x, y)
	local position = _warcraftInfoBg:convertToNodeSpace(ccp(x, y))
	for i = 1, #_seats do
		local seat = _seats[i]
		if seat:boundingBox():containsPoint(position) == true then
			return i
		end
	end
	return nil
end

function onNodeEvent( event )
	if event == "enter" then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_layer:setTouchEnabled(true)
	elseif event == "exit" then
		_layer:unregisterScriptTouchHandler()
	end
end

---[==[阵法 第3步
---------------------新手引导---------------------------------
function addGuideWarcraftGuide3( ... )
	require "script/guide/NewGuide"
	require "script/guide/WarcraftGuide"
    if(NewGuide.guideClass ==  ksGuideWarcraft and WarcraftGuide.stepNum == 2) then
        local button = getGuideWarcraftCell()
        local touchRect   = getSpriteScreenRect(button)
        touchRect.size.height = touchRect.size.height - 10
        WarcraftGuide.show(3, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

---[==[阵法 第4步
---------------------新手引导---------------------------------
function addGuideWarcraftGuide4( ... )
	require "script/guide/NewGuide"
	require "script/guide/WarcraftGuide"
    if(NewGuide.guideClass ==  ksGuideWarcraft and WarcraftGuide.stepNum == 3) then
        local button = getUseItem()
        local touchRect   = getSpriteScreenRect(button)
        WarcraftGuide.show(4, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

---[==[阵法 第5步
---------------------新手引导---------------------------------
function addGuideWarcraftGuide5( ... )
	require "script/guide/NewGuide"
	require "script/guide/WarcraftGuide"
    if(NewGuide.guideClass ==  ksGuideWarcraft and WarcraftGuide.stepNum == 4) then
        WarcraftGuide.show(5, nil)
    end
end
---------------------end-------------------------------------
--]==]
