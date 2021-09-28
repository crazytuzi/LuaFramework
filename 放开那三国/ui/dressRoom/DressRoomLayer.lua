-- Filename：	DressRoomLayer.lua
-- Author：		bzx
-- Date：		2014-11-04
-- Purpose：		时装屋

module("DressRoomLayer", package.seeall)

require "script/ui/dressRoom/DressRoomCache"
require "script/ui/dressRoom/DressRoomPreviewLayer"
require "script/ui/dressRoom/DressGetInfoDialog"
require "script/model/utils/HeroUtil"
require "db/DB_Affix"
require "script/utils/LevelUpUtil"

local _layer
local _silverLabel
local _goldLabel
local _dressDatas
local _tableView
local _arrow_left
local _arrow_right
local _isEnterFashion = false
local _showActiveEffect = false
local _activeDressId
local _willUpdateCell
local _oldWearCell
local _lastLayerName 

local EFFECT_TAG = 123

function show(p_lastLayerName)
	_layer = create()
	_lastLayerName = p_lastLayerName
    MainScene.changeLayer(_layer, "DressRoomLayer")
end

function init( ... )
	_dressDatas = DressRoomCache.getDressDatas()
	_tableView = nil
	_arrow_right = nil
	_arrow_left = nil
	_willUpdateCell = nil
	_oldWearCell = nil
	_lastLayerName = nil
end

function create( ... )
	init()
	_layer = CCLayer:create()
	_layer:registerScriptHandler(onNodeEvent)
	loadBg()
	loadTop()
	loadTableView()
	loadButtomTip()
	return _layer
end

function loadBg( ... )
	local bg = CCScale9Sprite:create("images/recharge/mystery_merchant/bg.png",
                                CCRectMake(0, 0, 55, 50),
                                CCRectMake(26, 30, 6, 4))
    _layer:addChild(bg)
    bg:setPreferredSize(CCSizeMake(640, 960))
    bg:setScale(MainScene.bgScale)
    
    -- 上面的花边
    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local border_filename = "images/recharge/mystery_merchant/border.png"
    local border_top = CCSprite:create(border_filename)
    _layer:addChild(border_top)
    border_top:setAnchorPoint(ccp(0, 0))
    border_top:setScale(g_fScaleX)
    border_top:setScaleY(-g_fScaleX)
    local border_top_y = g_winSize.height - 75 * g_fScaleX
    border_top:setPosition(0, border_top_y)
end

function loadTop( ... )
	loadPlayerInfo()
	local menu = CCMenu:create()
	_layer:addChild(menu)
	menu:setPosition(ccp(0, 0))

	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	menu:addChild(backItem)
	backItem:setScale(MainScene.elementScale)
    backItem:registerScriptTapHandler(backCallback)
    backItem:setScale(MainScene.elementScale)
    backItem:setPosition(ccp(g_winSize.width - 100 * MainScene.elementScale, g_winSize.height - 160 * g_fScaleX))

    local title = CCSprite:create("images/dress_room/title.png")
    _layer:addChild(title)
    title:setAnchorPoint(ccp(0.5, 1))
    title:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height - 110 * g_fScaleX))
    title:setScale(MainScene.elementScale)
end

function loadPlayerInfo( )
	require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
	------------------------------------change by DJN 2014/11/13 新改版，用zihang封装的方法创建
    local _topBg = HeroUtil.createNewAttrBgSprite(userInfo.level,UserModel.getUserName(),UserModel.getVipLevel(),userInfo.silver_num,userInfo.gold_num)
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0, _layer:getContentSize().height - BulletinLayer.getLayerHeight()*g_fScaleX)
    _topBg:setScale(g_fScaleX)
    _layer:addChild(_topBg, 1, 19876)
	return _topBg
end

function loadButtomTip( ... )
	local tip = CCLabelTTF:create(GetLocalizeStringBy("key_8345"), g_sFontName, 21)
	_layer:addChild(tip)
	tip:setAnchorPoint(ccp(0.5, 0.5))
	tip:setPosition(ccp(g_winSize.width * 0.5, 150 * g_fScaleX))
	tip:setScale(g_fScaleX)
	-- tip:setColor(ccc3(0x78, 0x25, 0x00))
end

function backCallback( ... )
	if _lastLayerName == "MainBaseLayer" then
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
	else
		_isEnterFashion = true
	    MainScene.getAvatarLayerObj():setVisible(false)
	    require "script/ui/fashion/FashionLayer"
	    local mark = FashionLayer.getMark()
	    local fashionLayer = FashionLayer:createFashion()
	    MainScene.changeLayer(fashionLayer, "FashionLayer")
	    FashionLayer.setMark(mark)
	end
end

function loadTableView( ... )
	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(300, 680)
		elseif fn == "cellAtIndex" then
			a2 = createCell(a1)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_dressDatas
		elseif fn == "scroll" then
			refreshHeroArrows()
		end
		return r
	end)

	require "script/ui/mergeServer/accumulate/AccumulateActivity"
 	_tableView = LuaTableView:createWithHandler(h, CCSizeMake(600, 650))
 	_layer:addChild(_tableView)
 	_tableView:setDirection(kCCScrollViewDirectionHorizontal)
 	_tableView:setAnchorPoint(ccp(0.5, 0.5))
 	_tableView:ignoreAnchorPointForPosition(false)
 	_tableView:setPosition(ccp(g_winSize.width * 0.5, (g_winSize.height -  200 * g_fScaleX) * 0.5 + 130 * g_fScaleX))
 	_tableView:reloadData()
 	_tableView:setScale(MainScene.elementScale)

 	-- 向上的箭头
	_arrow_left = CCSprite:create( "images/common/arrow_up_h.png")
    _layer:addChild(_arrow_left)
	_arrow_left:setPosition(10, g_winSize.height * 0.5)
	_arrow_left:setAnchorPoint(ccp(0.5,1))
	_arrow_left:setVisible(false)
	_arrow_left:setRotation(-90)
	_arrow_left:setScale(MainScene.elementScale)

	-- 向下的箭头
	_arrow_right = CCSprite:create( "images/common/arrow_down_h.png")
    _layer:addChild(_arrow_right)
	_arrow_right:setPosition(g_winSize.width - 10, g_winSize.height * 0.5)
	_arrow_right:setAnchorPoint(ccp(0.5,0))
	_arrow_right:setVisible(true)
	_arrow_right:setRotation(270)
	_arrow_right:setScale(MainScene.elementScale)

	arrowAction(_arrow_left)
	arrowAction(_arrow_right)
end

function arrowAction( arrow)
	local arrActions_2 = CCArray:create()
	arrActions_2:addObject(CCFadeOut:create(1))
	arrActions_2:addObject(CCFadeIn:create(1))
	local sequence_2 = CCSequence:create(arrActions_2)
	local action_2 = CCRepeatForever:create(sequence_2)
	arrow:runAction(action_2)
end

function refreshHeroArrows()
    if _tableView == nil then
        return
    end
    local offset = _tableView:getContentSize().width + _tableView:getContentOffset().x - _tableView:getViewSize().width
	if _arrow_right ~= nil then
		if offset > 1 or offset < -1 then
			_arrow_right:setVisible(true)
		else
			_arrow_right:setVisible(false)
		end
	end

	if _arrow_left ~= nil  then
		if _tableView:getContentOffset().x < 0 then
			_arrow_left:setVisible(true)
		else
			_arrow_left:setVisible(false)
		end
	end
end

function createCell(index, oldCell)
	local isUpdateEffect = true
	local cell = oldCell
	if cell ~= nil then
		local children = cell:getChildren()
		local willRemoveChildren = {} 
		for i = 0, children:count() - 1 do
			local child = tolua.cast(children:objectAtIndex(i), "CCNode")
			if child:getTag() ~= EFFECT_TAG then
				table.insert(willRemoveChildren, child)
			end
		end
		for i = 1, #willRemoveChildren do
			willRemoveChildren[i]:removeFromParentAndCleanup(true)
		end
	else
		cell = CCTableViewCell:create()
		cell:setTag(index)
	end

	local cellSize = CCSizeMake(300, 660)
	cell:setContentSize(cellSize)
	local bg = CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/recharge/vip_benefit/vipBB.png")
	cell:addChild(bg)
	bg:setPreferredSize(CCSizeMake(292, 600))
	bg:setAnchorPoint(ccp(0.5, 0))
	bg:setPosition(ccpsprite(0.5, 0, cell))
	
	local dressData = _dressDatas[index + 1]
	local dressDB = parseDB(DB_Item_dress.getDataById(dressData.id))
	local genderId = UserModel.getUserSex()
	if dressData.id == DressRoomCache.getWearDressId() then
		_oldWearCell = cell
	end

	local nameBg = CCScale9Sprite:create(CCRectMake(86, 30, 4, 8), "images/dress_room/name_bg.png")
	bg:addChild(nameBg, 10)
	nameBg:setPreferredSize(CCSizeMake(258, 68))
	nameBg:setAnchorPoint(ccp(0.5, 0.5))
	nameBg:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height - 3))

	local name = CCLabelTTF:create(dressDB.name[genderId][2], g_sFontPangWa, 30)
	nameBg:addChild(name)
	name:setAnchorPoint(ccp(0.5, 0.5))
	name:setPosition(ccpsprite(0.5, 0.5, nameBg))
	name:setColor(ccc3(0xff, 0xf6, 0x00))
	local bgSize = bg:getContentSize()
	local lightDatas = {
		{image = "bg.png", anchorPoint = ccp(0.5, 1), position = ccp(bgSize.width * 0.5, bgSize.height)},
		{image = "bg_light.png", anchorPoint = ccp(0.5, 0), position = ccp(bgSize.width * 0.5, bgSize.height - 290)},
		{image = "stage.png", anchorPoint = ccp(0.5, 0), position = ccp(bgSize.width * 0.5 - 2, bgSize.height - 322)},
		{image = "big_light.png", anchorPoint = ccp(0, 1), position = ccp(8, bgSize.height - 8)},
		{image = "big_light.png", anchorPoint = ccp(0, 1), position = ccp(bgSize.width - 8, bgSize.height - 8), scaleX = -1},
		{image = "small_light.png", anchorPoint = ccp(0, 1), position = ccp(80, bgSize.height - 10)},
		{image = "small_light.png", anchorPoint = ccp(0, 1), position = ccp(bgSize.width - 80, bgSize.height - 10), scaleX = -1},
	}

	for i = 1, #lightDatas do
		local lightData = lightDatas[i]
		if dressData.as == DressRoomCache.NOT_ACTIVED then
			lightData.image = "gray_" .. lightData.image
		end
		local light = CCSprite:create("images/dress_room/" .. lightData.image)
		bg:addChild(light)
		light:setAnchorPoint(lightData.anchorPoint)
		light:setPosition(lightData.position)
		if lightData.scaleX ~= nil then
			light:setScaleX(lightData.scaleX)
		end
	end

	if oldCell == nil then
		local star = CCSprite:create("images/dress_room/effect.png")
		cell:addChild(star, 8, EFFECT_TAG)
		star:setAnchorPoint(ccp(0.5, 0.5))
		star:setPosition(ccpsprite(0.5, 0.835, bg))
		local action_args = CCArray:create()
	    action_args:addObject(CCMoveBy:create(0.8, ccp(0, 10)))
	    action_args:addObject(CCMoveBy:create(0.8, ccp(0, -10)))
	    action = CCRepeatForever:create(CCSequence:create(action_args))
	    star:runAction(action)

		local dressImage = "images/base/fashion/big/" .. dressDB.icon_big[genderId][2]
		local dress = nil
		local notGetTag = nil
		if dressData.gs ~= DressRoomCache.GET then
			dress = BTGraySprite:create(dressImage)
			notGetTag = CCSprite:create("images/dress_room/not_get.png")
		else
			dress = CCSprite:create(dressImage)
		end
		cell:addChild(dress, 9, EFFECT_TAG)
		dress:setScale(0.8)
		dress:setAnchorPoint(ccp(0.5, 0.5))
		dress:setPosition(ccpsprite(0.5, 0.72, bg))

		local action_args = CCArray:create()
	    action_args:addObject(CCMoveBy:create(0.8, ccp(0, 10)))
	    action_args:addObject(CCMoveBy:create(0.8, ccp(0, -10)))
	    action = CCRepeatForever:create(CCSequence:create(action_args))
	    dress:runAction(action)
	end
    if _showActiveEffect == true then
    	local activeEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/huanzhuangjh/huanzhuangjh"), -1,CCString:create(""))
		cell:addChild(activeEffect, 11)
		activeEffect:setAnchorPoint(ccp(0.5, 0))
		activeEffect:setPosition(ccp(bgSize.width * 0.5, 380))
        local animationEnd = function(actionName,xmlSprite)
            activeEffect:removeFromParentAndCleanup(true)

            local affixInfos ={}
			local dressDB = parseDB(DB_Item_dress.getDataById(dressData.id))
			if dressDB.additionalAffix ~= nil then
				for i=1, #dressDB.additionalAffix do
					local affix = dressDB.additionalAffix[i]
					local affixDB = DB_Affix.getDataById(affix[1])
					local affixInfo  = {}
					affixInfo.txt = affixDB.displayName
					affixInfo.num = affix[2]
					if affixDB.type == 2 then
						affixInfo.num = math.floor(affixInfo.num / 100)
					end
					table.insert(affixInfos, affixInfo)
				end
				LevelUpUtil.showFlyText(affixInfos)
			end
        end
        
        local animationFrameChanged = function(frameIndex,xmlSprite)
        end
        local delegate = BTAnimationEventDelegate:create()
        delegate:registerLayerEndedHandler(animationEnd)
        delegate:registerLayerChangedHandler(animationFrameChanged)
        activeEffect:setDelegate(delegate)
	end


	if notGetTag ~= nil then
		bg:addChild(notGetTag)
		notGetTag:setAnchorPoint(ccp(0.5, 0.5))
		notGetTag:setPosition(ccp(bgSize.width * 0.5, bgSize.height - 190))
	end

	if dressDB.additionalAffix ~= nil then
		local textBg = nil
		if dressData.gs == DressRoomCache.GET then
			textBg = CCScale9Sprite:create("images/dress_room/attribute_bg.png")
		else
			textBg = CCScale9Sprite:create("images/dress_room/gray_attribute_bg.png")
		end
		bg:addChild(textBg)
		textBg:setPreferredSize(CCSizeMake(255, 139))
		textBg:setAnchorPoint(ccp(0.5, 0))
		textBg:setPosition(ccp(bgSize.width * 0.5, 90))

		local textTitleBg = CCScale9Sprite:create("images/common/astro_labelbg.png")
		textBg:addChild(textTitleBg)
		textTitleBg:setAnchorPoint(ccp(0.5, 0.5))
		textTitleBg:setPosition(ccpsprite(0.5, 1, textBg))
		textTitleBg:setPreferredSize(CCSizeMake(211, 40))

		local textTitle = CCLabelTTF:create(GetLocalizeStringBy("key_8347"), g_sFontPangWa, 25)
		textTitleBg:addChild(textTitle)
		textTitle:setAnchorPoint(ccp(0.5, 0.5))
		textTitle:setPosition(ccpsprite(0.5, 0.53, textTitleBg))
		textTitle:setColor(ccc3(0xff, 0xf6, 0x00))
		for i=1, #dressDB.additionalAffix do
			local affixDB = DB_Affix.getDataById(dressDB.additionalAffix[i][1])
			local affixName = CCLabelTTF:create(affixDB.displayName, g_sFontName, 21)
			textBg:addChild(affixName)
			affixName:setAnchorPoint(ccp(0, 0.5))
			affixName:setPosition(ccp(10 + math.mod(i + 1, 2) * 125, textBg:getContentSize().height - 35 -  math.floor((i-1) / 2) * 27))

			local affix = dressDB.additionalAffix[i][2]
			if affixDB.type == 2 then
				affix = math.floor(affix / 100)
			end
			local affixValue = CCLabelTTF:create("+" .. tostring(affix), g_sFontName, 21)
			textBg:addChild(affixValue)
			affixValue:setAnchorPoint(ccp(0, 0.5))
			affixValue:setPosition(ccp(affixName:getPositionX() + 60, affixName:getPositionY()))

			if dressData.gs ~= DressRoomCache.GET then
				affixName:setColor(ccc3(0x82, 0x82, 0x82))
				affixValue:setColor(ccc3(0x82, 0x82, 0x82))
			end
		end
	end



	local menu = CCMenu:create()
	bg:addChild(menu)
	menu:setPosition(ccp(0, 0))

	local checkDressInfoItem = CCMenuItemImage:create("images/olympic/checkbutton/check_btn_h.png", "images/olympic/checkbutton/check_btn_n.png")
	menu:addChild(checkDressInfoItem)
	checkDressInfoItem:setPosition(ccp(50, 530))
	checkDressInfoItem:setAnchorPoint(ccp(0.5, 0.5))
	checkDressInfoItem:registerScriptTapHandler(checkDressInfoCallback)
	checkDressInfoItem:setTag(tonumber(dressData.id))

	require "script/libs/LuaCC"
	if dressData.gs == DressRoomCache.GET then
		if dressData.as == DressRoomCache.NOT_ACTIVED then
			local activeItem = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png", CCSizeMake(134, 64), GetLocalizeStringBy("key_8346"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			menu:addChild(activeItem, 1, index + 1)
			activeItem:setAnchorPoint(ccp(0.5, 0.5))
			activeItem:registerScriptTapHandler(activeCallback)
			activeItem:setPosition(ccp(bgSize.width * 0.5, bgSize.height - 320))
		else
			if dressDB.additionalAffix ~= nil then
				local activedTag = CCSprite:create("images/dress_room/activated.png")
				cell:addChild(activedTag, 20)
				activedTag:setAnchorPoint(ccp(0.5, 0.5))
				activedTag:setPosition(ccp(bgSize.width * 0.78, bgSize.height - 60))
			end
			if oldCell == nil then
				local activedEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/huanzhuangxh/huanzhuangxh"), -1,CCString:create(""))
				cell:addChild(activedEffect, 10, EFFECT_TAG)
				activedEffect:setAnchorPoint(ccp(0.5, 0))
				activedEffect:setPosition(ccp(bgSize.width * 0.5 - 2, 350))
			end
		end
		if dressData.id == DressRoomCache.getWearDressId() then
			local curDress = CCSprite:create("images/dress_room/cur_tag.png")
			bg:addChild(curDress)
			curDress:setAnchorPoint(ccp(0.5, 0.5))
			curDress:setPosition(ccp(bgSize.width * 0.5, 50))
		else
			local changeItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73), GetLocalizeStringBy("key_8344"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			menu:addChild(changeItem, 1, index + 1)
			changeItem:setAnchorPoint(ccp(0.5, 0.5))
			changeItem:registerScriptTapHandler(changeCallback)
			changeItem:setPosition(ccp(bgSize.width * 0.5, 50))
		end
		-- if dressDB.additionalAffix ~= nil then
		-- 	local tip = CCLabelTTF:create(GetLocalizeStringBy("key_8345"), g_sFontName, 21)
		-- 	bg:addChild(tip)
		-- 	tip:setAnchorPoint(ccp(0.5, 0.5))
		-- 	tip:setPosition(ccp(bgSize.width * 0.5, 35))
		-- 	tip:setColor(ccc3(0x78, 0x25, 0x00))
		-- end
	else
		local getItem = CCMenuItemImage:create("images/dress_room/get_n.png", "images/dress_room/get_h.png")
		menu:addChild(getItem, 1, index + 1)
		getItem:setAnchorPoint(ccp(0.5, 0.5))
		getItem:setPosition(ccp(bgSize.width - 60, bgSize.height - 60))
		getItem:registerScriptTapHandler(getCallback)

		local tryItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73), GetLocalizeStringBy("key_8343"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		menu:addChild(tryItem, 1, index + 1)
		tryItem:setAnchorPoint(ccp(0.5, 0.5))
		tryItem:registerScriptTapHandler(tryCallback)
		tryItem:setPosition(ccp(bgSize.width * 0.5, 50))
	end
	return cell
end

function onNodeEvent( event )
	if event == "enter" then
	elseif event == "exit" then
		_tableView = nil
		if _lastLayerName ~= "MainBaseLayer" then
			if _isEnterFashion == false then
				FashionLayer.stopBgm()
			else
				_isEnterFashion = false
			end
		end
	end
end

-- 查看时装信息
function checkDressInfoCallback( p_tag )
	require "script/ui/fashion/FashionInfo"
	local dressId = p_tag
	FashionInfo.create(dressId, nil, nil, nil, nil, -500, 1000)
end

function activeCallback(tag)
	local dressData = _dressDatas[tag]
	local handleActive = function( ... )
		_showActiveEffect = true
		_tableView:updateCellAtIndex(tag - 1)
		--updateCell(_tableView:cellAtIndex(tag - 1))
		_showActiveEffect = false
	end
	DressRoomCache.activeDress(dressData.id, handleActive)
end

function getCallback(tag)
	local dressData = _dressDatas[tag]
	DressGetInfoDialog.show(dressData.id)
end

function tryCallback(tag)
	local dressData = _dressDatas[tag]
	DressRoomPreviewLayer.show(dressData.id)
end

function changeCallback(tag)
	local dressData = _dressDatas[tag]
	local handleChange = function( ... )
		if tolua.cast(_oldWearCell, "CCTableViewCell") ~= nil then
			updateCell(_oldWearCell)
		end
		updateCell(_tableView:cellAtIndex(tag - 1))
	end
	DressRoomCache.changeDress(dressData.id, handleChange)
end

function updateCell(cell)
	createCell(cell:getTag(), cell)
end


function reloadData()
	local offset = _tableView:getContentOffset()
	_tableView:reloadData()
	_tableView:setContentOffset(offset)
end