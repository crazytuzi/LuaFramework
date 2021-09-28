-- FileName: ForgeViewLayer.lua 
-- Author: licong 
-- Date: 14-6-12 
-- Purpose: 锻造材料显示界面


module("ForgeViewLayer", package.seeall)

require "script/ui/forge/ForgeData"
require "script/ui/forge/ForgeService"
require "script/ui/item/ItemSprite"

---------------------------[[ 模块变量 ]]--------------------------------
local _bgLayer 				= nil
local _layerSize 			= nil
local _radioMenu			= nil
local _equipIds				= nil
local _fragmentContainer	= nil
local _equipType 			= nil
local _selectEquipId  		= nil
local _fuseButton 			= nil
local _itemScrollView 		= nil
local _itemListBg			= nil
local _listItemArray 		= nil
local _moveLayer 			= nil
local _fragmentSetArray 	= nil
local _isPlayerEffect 		= false
local _toucheNode 			= nil
local _costFont 			= nil
local _refreshLabelArr 		= nil
local _forgeNumLabelArr 	= nil
local _showListData 		= nil
local _selectShowIndex 		= nil
local _leftArrowSp 			= nil
local _rightArrowSp 		= nil

function init()
	_bgLayer 				= nil
	_layerSize 				= nil
	_radioMenu				= nil
	_equipIds				= nil
	_fragmentContainer		= nil
	_equipType 				= nil
	_selectEquipId  		= nil
	_fuseButton 			= nil
	_itemScrollView 		= nil
	_itemListBg				= nil
	_listItemArray 			= {}
	_moveLayer 				= nil
	_fragmentSetArray 		= {}
	_isPlayerEffect 		= false
	_toucheNode				= nil
	_costFont 				= nil
	_refreshLabelArr 		= {}
	_forgeNumLabelArr 		= {}
	_showListData 			= {}
	_selectShowIndex 		= nil
	_leftArrowSp 			= nil
	_rightArrowSp 			= nil
end

-- 查看物品信息返回回调 为了显示下排按钮
function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, false, true)
end

-- 得到铸造费用显示
-- 1魂玉，2金币，3银币
local function getCostUI( p_type, num )
	local fileTab = {"soul_jade.png","gold.png","coin.png"}
	local sprite = CCSprite:create("images/common/" .. fileTab[p_type])
	local numLabel = CCLabelTTF:create(num,g_sFontName,21)
	numLabel:setColor(ccc3(0xff,0xf6,0x00))
	numLabel:setAnchorPoint(ccp(0,0.5))
	numLabel:setPosition(ccp(sprite:getContentSize().width+2,sprite:getContentSize().height*0.5))
	sprite:addChild(numLabel)
	return sprite
end

-- 箭头的动画
local function arrowAction( arrow)
    local arrActions_2 = CCArray:create()
    arrActions_2:addObject(CCFadeOut:create(1))
    arrActions_2:addObject(CCFadeIn:create(1))
    local sequence_2 = CCSequence:create(arrActions_2)
    local action_2 = CCRepeatForever:create(sequence_2)
    arrow:runAction(action_2)
end

-- 可滑动提示
function showDragTip()
    local drag_tip = CCSprite:create("images/forge/drag_tip.png")
    _bgLayer:addChild(drag_tip)
    drag_tip:setAnchorPoint(ccp(1, 0.5))
    drag_tip:setPosition(ccp(0.97*_layerSize.width / MainScene.elementScale, 0.91*_layerSize.height / MainScene.elementScale))
    drag_tip:setScale(g_fScaleX/MainScene.elementScale)
    local hand = CCSprite:create("images/forge/shou.png")
    drag_tip:addChild(hand)
    hand:setAnchorPoint(ccp(0.5, 1))
    local begin_point = ccp(140, 0)
    local end_point = ccp(-70, 0)
    local drag_time = 1.5
    hand:setPosition(begin_point)
    local args = CCArray:create()
    args:addObject(CCMoveBy:create(drag_time, end_point))
    args:addObject(CCPlace:create(begin_point))
    args:addObject(CCMoveBy:create(drag_time, end_point))
    local moveEndCallFunc = function()
        drag_tip:removeFromParentAndCleanup(true)
    end
    args:addObject(CCCallFunc:create(moveEndCallFunc))
    hand:runAction(CCSequence:create(args))
end

----------------------------[[ ui创建 ]]----------------------------------
--[[
	@des 	:创建合成界面
	@param 	:p_type 合成物品类型(kNormalEquipType, kSpecialEquipType)
			 p_layerSize  层的大小
	@retrun :CClayer
]]
function createForgeViewLayer( p_type, p_layerSize )
	init()
	_bgLayer 		= CCLayer:create()
	-- _bgLayer = CCLayerColor:create(ccc4(0,255,0,111))

	_layerSize		= p_layerSize
	_equipType 		= p_type

	-- 上边列表
	createItemList()
	-- 滑动合成界面
	createMoveLayer()
	_toucheNode = CCNode:create()
	_toucheNode:setContentSize(CCSizeMake(_layerSize.width/MainScene.elementScale, _layerSize.height/MainScene.elementScale))
	_toucheNode:setPosition(ccp(0, 0))
	_toucheNode:setAnchorPoint(ccp(0, 0))
	_bgLayer:addChild(_toucheNode)

	--创建合成按钮
	local buttonBg = CCSprite:create("images/forge/buttonBg.png")
	buttonBg:setAnchorPoint(ccp(0.5,0.5))
	buttonBg:setPosition(ccp(0.5*_layerSize.width / MainScene.elementScale, 0.12*_layerSize.height/ MainScene.elementScale))
	_bgLayer:addChild(buttonBg)
	buttonBg:setScale(g_fScaleX/MainScene.elementScale)
	
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	buttonBg:addChild(menu, 15)

	_fuseButton =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(207, 76),GetLocalizeStringBy("lic_1058"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_fuseButton:setAnchorPoint(ccp(0.5, 0.5))
    _fuseButton:setPosition(ccp(buttonBg:getContentSize().width*0.5, buttonBg:getContentSize().height*0.6))
    _fuseButton:registerScriptTapHandler(tipCallFun)
	menu:addChild(_fuseButton,15)
	menu:setTouchPriority(-600)

	-- 锻造花费
	_costFont = CCLabelTTF:create(GetLocalizeStringBy("lic_1067"),g_sFontName,21)
	_costFont:setAnchorPoint(ccp(1,0.5))
	_costFont:setColor(ccc3(0xff,0xf6,0x00))
	_costFont:setPosition(ccp(0.5*_layerSize.width / MainScene.elementScale, 0.05*_layerSize.height / MainScene.elementScale))
	_bgLayer:addChild(_costFont)
	_costFont:setScale(g_fScaleX/MainScene.elementScale)

	-- 箭头
    -- 左箭头
    _leftArrowSp = CCSprite:create( "images/common/left_big.png")
    _leftArrowSp:setAnchorPoint(ccp(0,0.5))
    _leftArrowSp:setPosition(0,0.5*_layerSize.height / MainScene.elementScale)
    _bgLayer:addChild(_leftArrowSp,1, 101)
    _leftArrowSp:setVisible(false)
    _leftArrowSp:setScale(g_fScaleX/MainScene.elementScale)


    -- 右箭头
    _rightArrowSp = CCSprite:create( "images/common/right_big.png")
    _rightArrowSp:setAnchorPoint(ccp(1,0.5))
    _rightArrowSp:setPosition(_layerSize.width / MainScene.elementScale, 0.5*_layerSize.height / MainScene.elementScale)
    _bgLayer:addChild(_rightArrowSp,1, 102)
    _rightArrowSp:setVisible(true)
    _rightArrowSp:setScale(g_fScaleX/MainScene.elementScale)

    -- arrowAction(_leftArrowSp)
    -- arrowAction(_rightArrowSp)

    -- 可滑动提示
    showDragTip()

	--设置默认选择合成的配方
    setDefaultSelected()

    -- 清空选择的装备数据
    ForgeData.cleanChooseListData()

	return _bgLayer
end

--[[
	@des 	:创建宝物列表
	@param 	:
	@retrun :
]]
function createItemList( ... )
	local fullRect = CCRectMake(0,0,73,75)
	local insetRect = CCRectMake(29,31,20,10)
	_itemListBg = CCScale9Sprite:create("images/forge/top_bg.png", fullRect, insetRect)
	_itemListBg:setContentSize(CCSizeMake(640,145))
	_itemListBg:setPosition(ccp(0,(_layerSize.height+10)/MainScene.elementScale))
	_itemListBg:setAnchorPoint(ccp(0, 1))
	_itemListBg:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(_itemListBg, 15)

	--更新layerSize 的大小
	_layerSize = CCSizeMake(_layerSize.width, _layerSize.height - _itemListBg:getContentSize().height * g_fScaleX)

	local leftArrow 	= CCSprite:create("images/formation/btn_left.png")
	leftArrow:setAnchorPoint(ccp(0, 0.5))
	leftArrow:setPosition(ccpsprite(0, 0.5, _itemListBg))
	_itemListBg:addChild(leftArrow)

	local rightArrow 	= CCSprite:create("images/formation/btn_right.png")
	rightArrow:setAnchorPoint(ccp(1, 0.5))
	rightArrow:setPosition(ccpsprite(1, 0.5, _itemListBg))
	_itemListBg:addChild(rightArrow)
	
	_itemScrollView=  CCScrollView:create()
	_itemScrollView:setTouchPriority(-1005)

	_equipIds = ForgeData.getFoundryMethodByType(_equipType)
	-- print("_equipIds==")
	-- print_t(_equipIds)
	_showListData = ForgeData.getShowMethoodDataId(_equipIds)
	-- print("_showListData==")
	-- print_t(_showListData)

	_itemScrollView = CCScrollView:create()
	_itemScrollView:setTouchEnabled(true)
	_itemScrollView:setDirection(kCCScrollViewDirectionHorizontal)
	_itemScrollView:setViewSize(CCSizeMake(_itemListBg:getContentSize().width * 0.82, _itemListBg:getContentSize().height))
	_itemScrollView:setContentSize(CCSizeMake(100 * #_equipIds + 10, _itemListBg:getContentSize().height))
	_itemScrollView:setBounceable(true)
	_itemScrollView:setAnchorPoint(ccp(0.5 ,0.5))
	_itemScrollView:setPosition(ccpsprite(0.1, 0.1, _itemListBg))
    _itemListBg:addChild(_itemScrollView,1, 2002)
    -- _itemScrollView:retain()
    _radioMenu = BTMenu:create()
    _radioMenu:setStyle(kMenuRadio)
    _radioMenu:setPosition(ccp(0, 0))
    _radioMenu:setScrollView(_itemScrollView)
    _itemScrollView:addChild(_radioMenu)

    for i=1,#_equipIds do
    	local normalIconSprite 	= ItemSprite.getItemSpriteByItemId(tonumber(_equipIds[i].orangeId))
    	local selectIconSprite 	= ItemSprite.getItemSpriteByItemId(tonumber(_equipIds[i].orangeId))
    	local highlightSprite 	= CCSprite:create("images/hero/quality/highlighted.png")
    	highlightSprite:setAnchorPoint(ccp(0.5, 0.5))
    	highlightSprite:setPosition(ccpsprite(0.5, 0.5, selectIconSprite))
    	selectIconSprite:addChild(highlightSprite, 1, i)

    	local menuItem = CCMenuItemSprite:create(normalIconSprite, selectIconSprite)
    	menuItem:setAnchorPoint(ccp(0, 0.5))
    	menuItem:setPosition(ccp((i-1)*100+7, _itemListBg:getContentSize().height*0.5))
    	menuItem:registerScriptTapHandler(equipItemSelectCallfunc)
    	_radioMenu:addChild(menuItem,1, tonumber(_equipIds[i].id))

    	-- 目标物品名字
		local desItemData = ItemUtil.getItemById(tonumber(_equipIds[i].orangeId))
	    local nameColor = HeroPublicLua.getCCColorByStarLevel(desItemData.quality)
		local desItemName = CCRenderLabel:create(desItemData.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
		desItemName:setColor(nameColor)
		desItemName:setAnchorPoint(ccp(0.5,1))
		desItemName:setPosition(ccp(menuItem:getContentSize().width*0.5 ,0))
		menuItem:addChild(desItemName,10)

    	_listItemArray[_equipIds[i].id] = menuItem

    	-- -- 可以合成的个数
    	-- local canNum = ForgeData.getCanForgeNumByMethoodId(_equipIds[i].id)
    	-- local numberLabel = CCLabelTTF:create( canNum, g_sFontPangWa,18)
    	-- numberLabel:setAnchorPoint(ccp(1,0))
	    -- numberLabel:setColor(ccc3(0x00,0xff,0x18))
	    -- numberLabel:setPosition(ccp(menuItem:getContentSize().width-5,5))
	    -- menuItem:addChild(numberLabel,10)

	    -- _forgeNumLabelArr[_equipIds[i].id] = numberLabel
    end
end

--[[
	@des: 		创建拖动层
]]
function createMoveLayer( ... )
	_moveLayer = CCLayer:create()
	_moveLayer:setTouchEnabled(true)
	_bgLayer:addChild(_moveLayer)
	_moveLayer:registerScriptTouchHandler(onTouchCallFunc, false, 1, false)
	_bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))
	for i=1,#_showListData do
		local fragmentSet = createEquipFragmentSet(_showListData[i].methoodId,_showListData[i].needItemId,_showListData[i].showIndex)
		fragmentSet:setAnchorPoint(ccp(0.5, 0.5))
		fragmentSet:setPosition(ccp(0.5 * _layerSize.width/MainScene.elementScale + (i-1) * _layerSize.width/MainScene.elementScale, 0.5 * _layerSize.height/MainScene.elementScale))
		_moveLayer:addChild(fragmentSet, 10, _showListData[i].showIndex)
		setAdaptNode(fragmentSet)
		fragmentSet:setScale(fragmentSet:getScale()*0.85 / MainScene.elementScale)
		_fragmentSetArray[_showListData[i].showIndex] = fragmentSet
	end
	-- print("_refreshLabelArr")
	-- print_t(_refreshLabelArr)
end

--[[
	@des:		moveLayer touch 事件
]]
local moveDis 		= 0
local lastMove	 	= 0
local selectIndex 	= 0
function onTouchCallFunc( eventType, x, y )
	if(eventType == "began") then
		lastMove = x
		if(_isPlayerEffect == true) then
			return false
		end
	    local viewRect = getSpriteScreenRect(_toucheNode)
	    -- print("viewRect(", viewRect.origin.x, viewRect.origin.y, viewRect.size.width, viewRect.size.height, ")")
	    if(viewRect:containsPoint(ccp(x, y))) then
	        return true
	    else
	        return false
	    end
	elseif(eventType == "moved") then
		local movePrevious = x - lastMove
		lastMove = x
		_moveLayer:setPosition(_moveLayer:getPositionX() + movePrevious,_moveLayer:getPositionY())
	else
		--得到当前页的偏移量
		-- print("_layerSize.width = ",_layerSize.width/MainScene.elementScale)
		local m_pageCount = #_showListData
	    local nowPageOffset = _moveLayer:getPositionX() + selectIndex * _layerSize.width/MainScene.elementScale
	    if (nowPageOffset <= - _layerSize.width/MainScene.elementScale/5 and selectIndex ~= m_pageCount-1) then
	        selectIndex = selectIndex + 1
	        local           moveDis = -selectIndex* _layerSize.width/MainScene.elementScale
	        local        	move    = CCMoveTo:create(0.3, ccp(moveDis, 0))
	        local 			ease    = CCEaseElastic:create(move)
	        _moveLayer:runAction(ease)
	        -- 更新花费费用
			updateForgeCostNum(_showListData[selectIndex+1].methoodId,_showListData[selectIndex+1].needItemId)
	        -- 切换配方 清除选择的数据
	        updateChooseEquipIcon()
	    elseif(nowPageOffset >= _layerSize.width/MainScene.elementScale/5 and selectIndex ~= 0) then 
	        selectIndex = selectIndex - 1
	        local           moveDis = -selectIndex* _layerSize.width/MainScene.elementScale
	        local        	move    = CCMoveTo:create(0.3, ccp(moveDis, 0))
	        local 			ease    = CCEaseElastic:create(move)
	        _moveLayer:runAction(ease)
	        -- 更新花费费用
			updateForgeCostNum(_showListData[selectIndex+1].methoodId,_showListData[selectIndex+1].needItemId)
	        -- 切换配方 清除选择的数据
	        updateChooseEquipIcon()
	    else
	        local           moveDis = -selectIndex* _layerSize.width/MainScene.elementScale
	        local        	move    = CCMoveTo:create(0.3, ccp(moveDis, 0))
	        local 			ease    = CCEaseElastic:create(move)
	        _moveLayer:runAction(ease)
	    end
		_radioMenu:setMenuSelected(_listItemArray[_showListData[selectIndex+1].methoodId])
		updateScrollViewContainerPosition(_listItemArray[_showListData[selectIndex+1].methoodId])
		_selectEquipId = _showListData[selectIndex+1].methoodId
		_selectShowIndex = _showListData[selectIndex+1].showIndex
		_fragmentContainer = tolua.cast(_fragmentSetArray[_selectShowIndex], "CCNode")

		-- 箭头
		if(selectIndex == 0)then
			_leftArrowSp:setVisible(false)
			_rightArrowSp:setVisible(true)
		elseif(selectIndex == m_pageCount-1)then
			_leftArrowSp:setVisible(true)
			_rightArrowSp:setVisible(false)
		else
			_leftArrowSp:setVisible(true)
			_rightArrowSp:setVisible(true)
		end
	end
end



--[[
	@des:	创建一个配方的盘子
	@param:	p_id配方id, p_needItemId:需要的id, p_showMark:显示标签
	@return: ccsprite 配方的盘子
]]
function createEquipFragmentSet( p_id, p_needItemId, p_showMark )
	
	local fragment_Container = CCNode:create()
	-- local fragment_Container = CCLayerColor:create(ccc4(255,0,0,111))
	-- fragment_Container:ignoreAnchorPointForPosition(false) 
	-- print("_layerSize --->",_layerSize.width,_layerSize.height)
	fragment_Container:setContentSize(CCSizeMake(640, 590))
	fragment_Container:removeAllChildrenWithCleanup(true)

	-- 按钮
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0, 0))
    menu:setPosition(ccp(0, 0))
    fragment_Container:addChild(menu, 11)
    menu:setTouchPriority(-530)

    --  配方数据
    local methoodData = ForgeData.getDBdataByMethoodId(p_id)

    -- 需要物品框
	local needMenuItemBg = CCSprite:create("images/forge/src_bg.png")
	needMenuItemBg:setAnchorPoint(ccp(0.5, 0.5))
	needMenuItemBg:setPosition(ccp(fragment_Container:getContentSize().width*0.3, fragment_Container:getContentSize().height*0.9))
	fragment_Container:addChild(needMenuItemBg, 10)
	local needItemIcon = ItemSprite.getItemSpriteById(p_needItemId, nil, showDownMenu, nil, -530, 1010, -535)
	needItemIcon:setAnchorPoint(ccp(0.5, 0.5))
	needItemIcon:setPosition(ccp(needMenuItemBg:getContentSize().width*0.5, needMenuItemBg:getContentSize().height*0.5))
	needMenuItemBg:addChild(needItemIcon)
	-- 需要物品名字
	local needItemData = ItemUtil.getItemById(p_needItemId)
    local needNameColor = HeroPublicLua.getCCColorByStarLevel(needItemData.quality)
	local needItemName = CCRenderLabel:create(needItemData.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	needItemName:setColor(needNameColor)
	needItemName:setAnchorPoint(ccp(0.5,1))
	needItemName:setPosition(ccp(needMenuItemBg:getContentSize().width*0.5 ,7))
	needMenuItemBg:addChild(needItemName)

	-- 箭头
	local rightSp = CCSprite:create("images/common/right.png")
	rightSp:setAnchorPoint(ccp(0.5,0.5))
	rightSp:setPosition(ccp(fragment_Container:getContentSize().width*0.5, fragment_Container:getContentSize().height*0.9))
	fragment_Container:addChild(rightSp, 10)

	-- 目标物品框
	local desMenuItemBg = CCSprite:create("images/forge/des_bg.png")
	desMenuItemBg:setAnchorPoint(ccp(0.5, 0.5))
	desMenuItemBg:setPosition(ccp(fragment_Container:getContentSize().width*0.7, fragment_Container:getContentSize().height*0.9))
	fragment_Container:addChild(desMenuItemBg, 10)
	local desItemIcon = ItemSprite.getItemSpriteById(methoodData.orangeId, nil, showDownMenu, nil, -530, 1010, -535)
	desItemIcon:setAnchorPoint(ccp(0.5, 0.5))
	desItemIcon:setPosition(ccp(desMenuItemBg:getContentSize().width*0.5, desMenuItemBg:getContentSize().height*0.5))
	desMenuItemBg:addChild(desItemIcon)
	-- 目标物品名字
	local desItemData = ItemUtil.getItemById(methoodData.orangeId)
    local nameColor = HeroPublicLua.getCCColorByStarLevel(desItemData.quality)
	local desItemName = CCRenderLabel:create(desItemData.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	desItemName:setColor(nameColor)
	desItemName:setAnchorPoint(ccp(0.5,1))
	desItemName:setPosition(ccp(desMenuItemBg:getContentSize().width*0.5 ,7))
	desMenuItemBg:addChild(desItemName)

	-- 目标特效
	local lightning = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/duanzaoyiguang/duanzaoyiguang"), -1,CCString:create(""))
    lightning:setAnchorPoint(ccp(0.5, 0.5))
    lightning:setPosition(desMenuItemBg:getContentSize().width*0.5,desMenuItemBg:getContentSize().height*0.5)
    desMenuItemBg:addChild(lightning,-1)

	-- 选择物品框
	local srcMenuItemBg = CCSprite:create("images/forge/src_bg.png")
	srcMenuItemBg:setAnchorPoint(ccp(0.5, 0.5))
	srcMenuItemBg:setPosition(ccp(fragment_Container:getContentSize().width*0.5, fragment_Container:getContentSize().height*0.6))
	fragment_Container:addChild(srcMenuItemBg, 10)
	local addIcon = ItemSprite.createAddSprite()
	local addMenuItem = CCMenuItemSprite:create(addIcon,addIcon)
	addMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	addMenuItem:setPosition(ccp(srcMenuItemBg:getPositionX()+2, srcMenuItemBg:getPositionY()-1))
	menu:addChild(addMenuItem)
	-- 注册回调
	addMenuItem:registerScriptTapHandler(addMenuItemAction)

	-- 放入 装备名字
	local font1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1062"), g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	font1:setColor(ccc3(0xff,0xff,0xff))
	font1:setAnchorPoint(ccp(0,0))
	srcMenuItemBg:addChild(font1)
	local font2 = CCRenderLabel:create( needItemData.name,  g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	font2:setAnchorPoint(ccp(0,0))
	font2:setColor(needNameColor)
	srcMenuItemBg:addChild(font2)
	local posX = (srcMenuItemBg:getContentSize().width-font1:getContentSize().width-font2:getContentSize().width)/2
	font1:setPosition(ccp(posX,srcMenuItemBg:getContentSize().height))
	font2:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width,font1:getPositionY()))

	-- 保存srcIcon
	_refreshLabelArr[p_showMark] = {}
	_refreshLabelArr[p_showMark].needItemId = needItemId
	_refreshLabelArr[p_showMark].addMenuItem = addMenuItem
	_refreshLabelArr[p_showMark].materials = {}
	--添加材料
	local fragments = ForgeData.getMaterialsByMethoodIdAndSrcId(p_id,p_needItemId)
	local fragmentsCount = table.count(fragments)
	local posX = nil
	local posY = nil
	if(fragmentsCount == 5)then
		posX = {0.15,0.15,0.5,0.85,0.85}
		posY = {0.6,0.35,0.35,0.6,0.35}
	elseif(fragmentsCount == 6)then
		posX = {0.15,0.15,0.385,0.615,0.85,0.85}
		posY = {0.6,0.35,0.35,0.35,0.6,0.35}
	else
		print("fragmentsCount is not 5 or 6")
	end
	for i=1,fragmentsCount do
	    local nx = fragment_Container:getContentSize().width*posX[i]
    	local ny = fragment_Container:getContentSize().height*posY[i]

    	-- 材料 按钮外框
    	local iconBgSprite  = CCSprite:create("images/everyday/headBg1.png")
    	iconBgSprite:setAnchorPoint(ccp(0.5, 0.5))
    	iconBgSprite:setPosition(ccp(nx, ny))
    	fragment_Container:addChild(iconBgSprite, 10)
    	-- 材料icon
    	local iconSprite = ItemSprite.getItemSpriteById(fragments[i].tid, nil, showDownMenu, nil, -530, 1010, -610)
    	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
    	iconSprite:setPosition(ccp(iconBgSprite:getContentSize().width*0.5, iconBgSprite:getContentSize().height*0.5))
    	iconBgSprite:addChild(iconSprite)
    	-- 材料 名字
    	local itemData = ItemUtil.getItemById(fragments[i].tid)
	    local nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
		local itemName = CCRenderLabel:create(itemData.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
		itemName:setColor(nameColor)
		itemName:setAnchorPoint(ccp(0.5,1))
		itemName:setPosition(ccp(iconBgSprite:getContentSize().width*0.5 ,-2))
		iconBgSprite:addChild(itemName)
		-- 材料数量/需要数量
		local needNumberLabel = CCLabelTTF:create( "/" .. fragments[i].needNum, g_sFontPangWa,18)
	    needNumberLabel:setAnchorPoint(ccp(1,0))
	    needNumberLabel:setColor(ccc3(0x00,0xff,0x18))
	    iconBgSprite:addChild(needNumberLabel,10)
	    needNumberLabel:setPosition(ccp(iconBgSprite:getContentSize().width-5,5))

		local numColor = nil
        if( fragments[i].haveNum >= fragments[i].needNum )then
            numColor = ccc3(0x00,0xff,0x18)
        else
            numColor = ccc3(0xff,0x00,0x00)
        end
	    local numberLabel =  CCLabelTTF:create( fragments[i].haveNum, g_sFontPangWa,18)
	    numberLabel:setAnchorPoint(ccp(1,0))
	    numberLabel:setColor(numColor)
	    iconBgSprite:addChild(numberLabel,10)
	    numberLabel:setPosition(ccp(needNumberLabel:getPositionX()-needNumberLabel:getContentSize().width,5))

	    -- 保存数量显示label
	    _refreshLabelArr[p_showMark].materials[fragments[i].tid] = {}
	    _refreshLabelArr[p_showMark].materials[fragments[i].tid].haveNum = fragments[i].haveNum
	    _refreshLabelArr[p_showMark].materials[fragments[i].tid].needNum = fragments[i].needNum
	    _refreshLabelArr[p_showMark].materials[fragments[i].tid].numberLabel = numberLabel
	end
	
	return fragment_Container
end

-----------------------------[[ 更新ui方法]] ------------------------------
--[[
	@des:	设置默认选择的宝物
]]
function setDefaultSelected( ... )

	local isContainer = function ( treaId )
		for k,v in pairs(_equipIds) do
			if(tonumber(v.id) == tonumber(treaId)) then
				return true
			end
		end
		return false
	end
	local selectItemId = nil
	if(_equipType == ForgeLayer.kNormalEquipType) then
		equipItemSelectCallfunc(_equipIds[1].id)
		selectItemId = _equipIds[1].id
	elseif(_equipType == ForgeLayer.kSpecialEquipType) then
		equipItemSelectCallfunc(_equipIds[1].id)
		selectItemId = _equipIds[1].id
	end
	_radioMenu:setMenuSelected(_listItemArray[selectItemId])
	updateScrollViewContainerPosition(_listItemArray[selectItemId], 0)
	_selectEquipId = selectItemId
	_selectShowIndex = _showListData[1].showIndex
	_fragmentContainer = tolua.cast(_fragmentSetArray[_selectShowIndex], "CCNode")
	-- 默认费用
	updateForgeCostNum(_showListData[_selectShowIndex].methoodId,_showListData[_selectShowIndex].needItemId)
end

--[[
	@des:	更新scrollView位置
]]
function updateScrollViewContainerPosition( selectNode,time )

	local posX = selectNode:getPositionX() - _itemScrollView:getViewSize().width/2
	local lnx,px,vw = 0,selectNode:getPositionX(),_itemScrollView:getViewSize().width
	if(px+ selectNode:getContentSize().width< vw ) then
		lnx = 0
	else
		lnx = px - vw*0.5 + selectNode:getContentSize().width/2
		if(lnx > px + selectNode:getContentSize().width  - vw) then
			lnx = px + selectNode:getContentSize().width - vw
		end
	end
	-- print("lnx = ", lnx)
	_itemScrollView:setContentOffsetInDuration(ccp(-lnx, 0), time or 0.5)
end


--[[
	@des:	更新拥有材料数量
]]
function updateFragmentNumLabel( ... )
	-- print("updateFragmentNumLabel")
	-- 更新材料数量
	for k,v in pairs(_refreshLabelArr) do
		local newData = ForgeData.getMaterialsByMethoodIdAndSrcId(_showListData[k].methoodId,_showListData[k].needItemId)
		for tid,v_old in pairs(v.materials) do
			for i,v_new in pairs(newData) do
				if(tonumber(tid) == tonumber(v_new.tid))then
					-- print("tid",tid,"v_old.haveNum",v_old.haveNum,"v_new.haveNum",v_new.haveNum)
					v_old.haveNum = v_new.haveNum
					v_old.needNum = v_new.needNum
					local strLabel = tolua.cast(v_old.numberLabel,"CCLabelTTF")
					strLabel:setString(v_old.haveNum)
			        if( v_old.haveNum >= v_new.needNum )then
			           strLabel:setColor(ccc3(0x00,0xff,0x18))
			        else
			           strLabel:setColor(ccc3(0xff,0x00,0x00))
			        end
			        break
				end
			end
		end
	end
end

-- 更新铸造费用方法
function updateForgeCostNum( p_methoodId, p_needItemId )
	-- 更新花费费用
	if(_costFont:getChildByTag(121) ~= nil)then
		_costFont:removeChildByTag(121,true)
	end
	local costType,costNum = ForgeData.getCostDataByMethoodId(p_methoodId,p_needItemId)
	local  costSp = getCostUI(costType,costNum)
	costSp:setAnchorPoint(ccp(0,0.5))
	costSp:setPosition(ccp(_costFont:getContentSize().width+2,_costFont:getContentSize().height*0.5))
	_costFont:addChild(costSp,1,121)
end

--[[
	@des:		更新宝物列表
]]
function updateTreasureList( ... )
	-- -- 更新所有的可以合成的数字
	-- for k,v in pairs(_forgeNumLabelArr) do
	-- 	local num = ForgeData.getCanForgeNumByMethoodId(k)
	-- 	local label = tolua.cast(v,"CCLabelTTF")
	-- 	label:setString(num)
	-- end
end

--[[
	@des:		更新moveLayer位置
]]
function updateMoveLayer( p_showIndex )
	-- print("updateMoveLayer selectIndex =", selectIndex)
	selectIndex = p_showIndex - 1
	-- 箭头
	if(selectIndex == 0)then
		_leftArrowSp:setVisible(false)
		_rightArrowSp:setVisible(true)
	elseif(selectIndex == #_showListData -1)then
		_leftArrowSp:setVisible(true)
		_rightArrowSp:setVisible(false)
	else
		_leftArrowSp:setVisible(true)
		_rightArrowSp:setVisible(true)
	end
	if(_moveLayer ~= nil) then
		_moveLayer:setPosition(-_layerSize.width/MainScene.elementScale * selectIndex, 0)
	end
end

-- 清除选择的装备图标和选择的数据
function updateChooseEquipIcon( ... )
	-- 清除选择的数据
	ForgeData.cleanChooseListData()
	-- 清除选择的图标
	for k,v in pairs(_refreshLabelArr) do
		local srcMenuItem = tolua.cast(v.addMenuItem,"CCMenuItemSprite")
		-- 当前页面添加选择装备icon
		if(srcMenuItem:getChildByTag(110) ~= nil)then
			srcMenuItem:removeChildByTag(110,true)
		end
	end
end

----------------------------[[ 回调事件 ]]----------------------------------
--[[
	@des 	:选择宝物回调事件
	@param	:tag 宝物模板id
]]
function equipItemSelectCallfunc( tag, sender )

	-- print("equipItemSelectCallfunc tag =", tag)
	for i=1,#_showListData do
		if( tag == _showListData[i].methoodId )then
			_selectShowIndex = _showListData[i].showIndex
			break
		end
	end
	_selectEquipId = tag
	-- print("_selectShowIndex:",_selectShowIndex)
	_fragmentContainer = tolua.cast(_fragmentSetArray[_selectShowIndex], "CCNode")
	updateMoveLayer(_selectShowIndex)

	-- 更新费用
	updateForgeCostNum(_showListData[_selectShowIndex].methoodId,_showListData[_selectShowIndex].needItemId)
end

-- 添加装备回调
function addMenuItemAction( tag, sender )
	local needItemId = _showListData[_selectShowIndex].needItemId
	require "script/ui/forge/ChooseViewLayer"
	ChooseViewLayer.showChooseViewLayer(needItemId)
end

-- 选择完装备回调方法
function choosedEquipCallFun( ... )
	local srcTab = ForgeData.getChooseListData()
	local srcMenuItem = tolua.cast(_refreshLabelArr[_selectShowIndex].addMenuItem,"CCMenuItemSprite")
	if(table.isEmpty(srcTab))then
		if(srcMenuItem:getChildByTag(110) ~= nil)then
			srcMenuItem:removeChildByTag(110,true)
		end
		return
	end
	-- print("srcItemId",srcTab[1])
	-- 当前页面添加选择装备icon
	if(srcMenuItem:getChildByTag(110) ~= nil)then
		srcMenuItem:removeChildByTag(110,true)
	end
	local srcItemData = ItemUtil.getFullItemInfoByGid(srcTab[1])
	local srcIcon = ItemSprite.getItemSpriteByItemId(srcItemData.item_template_id)
	srcIcon:setAnchorPoint(ccp(0.5, 0.5))
	srcIcon:setPosition(ccp(srcMenuItem:getContentSize().width*0.5, srcMenuItem:getContentSize().height*0.5))
	srcMenuItem:addChild(srcIcon,10,110)
	-- 选择物品名字
    local nameColor = HeroPublicLua.getCCColorByStarLevel(srcItemData.itemDesc.quality)
	local srcItemName = CCRenderLabel:create(srcItemData.itemDesc.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	srcItemName:setColor(nameColor)
	srcItemName:setAnchorPoint(ccp(0.5,1))
	srcItemName:setPosition(ccp(srcIcon:getContentSize().width*0.5 ,0))
	srcIcon:addChild(srcItemName)
	-- 强化等级
	local lvSprite = CCSprite:create("images/base/potential/lv_" .. srcItemData.itemDesc.quality .. ".png")
	lvSprite:setAnchorPoint(ccp(0,1))
	lvSprite:setPosition(ccp(-1, srcIcon:getContentSize().height))
	srcIcon:addChild(lvSprite)
	local lvLabel =  CCRenderLabel:create(srcItemData.va_item_text.armReinforceLevel , g_sFontName, 18, 1, ccc3( 0, 0, 0), type_stroke)
    lvLabel:setColor(ccc3(255,255,255))
    lvLabel:setAnchorPoint(ccp(0.5,0.5))
    lvLabel:setPosition(ccp( lvSprite:getContentSize().width*0.5, lvSprite:getContentSize().height*0.5))
    lvSprite:addChild(lvLabel)
end


-- 铸造条件判断 和 返回强化费用提示
function tipCallFun( tag, sender )
  	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 选择的装备
	local itemIdTab = ForgeData.getChooseListData()
	if(table.isEmpty(itemIdTab))then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1074"))
		return
	end
	local srcItemData = ItemUtil.getFullItemInfoByGid(itemIdTab[1])
	-- 返回的费用
	local retCostNum = tonumber(srcItemData.va_item_text.armReinforceCost)

	--是否背包满
	if(ItemUtil.isEquipBagFull(true, nil) == true) then
		return
	end
	--判断是否可以合成 材料是否足够
	local isCan = ForgeData.getCanForgeNumByMethoodId(_selectEquipId,srcItemData.item_template_id)
	if(isCan == false)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1065"))
		return
	end
	-- 费用是否足够
	local costType,costNum = ForgeData.getCostDataByMethoodId(_selectEquipId, srcItemData.item_template_id)
	local isEnough = ForgeData.isEnoughForForge(costType,costNum)
	if(isEnough == false)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1068"))
		return
	end
	if( retCostNum > 0)then
		local methoodData = ForgeData.getDBdataByMethoodId(_selectEquipId)
		local disData = ItemUtil.getItemById( methoodData.orangeId )
		require "script/ui/forge/ForgeTipLayer"
		ForgeTipLayer.showTipLayer(srcItemData,disData,sender,fuseButtonCallback)
	else
		fuseButtonCallback( sender )
	end
end

--[[
	@des 	:碎片合成按钮事件
	@param	:sender 合成按钮
]]
function fuseButtonCallback( sender )
	-- 选择的装备
	local itemIdTab = ForgeData.getChooseListData()
	if(table.isEmpty(itemIdTab))then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1074"))
		return
	end
	local srcItemData = ItemUtil.getFullItemInfoByGid(itemIdTab[1])
	-- 返回的费用
	local retCostNum = tonumber(srcItemData.va_item_text.armReinforceCost)

	-- --是否背包满
	-- if(ItemUtil.isEquipBagFull(true, nil) == true) then
	-- 	return
	-- end
	-- --判断是否可以合成 材料是否足够
	-- local isCan = ForgeData.getCanForgeNumByMethoodId(_selectEquipId,srcItemData.item_template_id)
	-- if(isCan == false)then
	-- 	require "script/ui/tip/AnimationTip"
	-- 	AnimationTip.showTip(GetLocalizeStringBy("lic_1065"))
	-- 	return
	-- end
	-- 费用是否足够
	-- local costType,costNum = ForgeData.getCostDataByMethoodId(_selectEquipId, srcItemData.item_template_id)
	-- local isEnough = ForgeData.isEnoughForForge(costType,costNum)
	-- if(isEnough == false)then
	-- 	require "script/ui/tip/AnimationTip"
	-- 	AnimationTip.showTip(GetLocalizeStringBy("lic_1068"))
	-- 	return
	-- end

	--屏蔽按钮事件
	_isPlayerEffect = true
	sender:setEnabled(false)

	require "script/utils/BaseUI"
	local maskLayer = BaseUI.createMaskLayer(-5000, nil, nil, 0)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(maskLayer, 2000)


	local callbackFunc = function ( isSuccess )
		if(isSuccess == false) then
			--合成失败
			AnimationTip.showTip(GetLocalizeStringBy("key_2635"))
			--放开事件屏蔽
			sender:setEnabled(true)
			_isPlayerEffect = false
		
			maskLayer:removeFromParentAndCleanup(true)
			return
		end

		-- 删除选择的装备icon
		local srcMenuItem = tolua.cast(_refreshLabelArr[_selectShowIndex].addMenuItem,"CCMenuItemSprite")
		if(srcMenuItem:getChildByTag(110) ~= nil)then
			srcMenuItem:removeChildByTag(110,true)
		end
		
		--合成特效播放
		local lightning = CCLayerSprite:layerSpriteWithNameAndCount("images/base/effect/dzchzh/dzchzh", 1,CCString:create(""))
	    lightning:setAnchorPoint(ccp(0.5, 0.5));
	    lightning:setPosition(_fragmentContainer:getContentSize().width/2,_fragmentContainer:getContentSize().height*0.5)
	    _fragmentContainer:addChild(lightning,80)

		local function lightningEndedCallFunc()
			-- 装备信息板子
			local methoodData = ForgeData.getDBdataByMethoodId(_selectEquipId)
			-- 获取装备数据
			require "db/DB_Item_arm"
			local equip_desc = DB_Item_arm.getDataById(methoodData.orangeId)
			local equipInfoLayer = nil
			if(equip_desc.jobLimit and equip_desc.jobLimit > 0)then
				-- 套装
				equipInfoLayer = SuitInfoLayer.createLayer(methoodData.orangeId ,  nil, nil, nil, nil, showDownMenu,nil, nil, -600)
			else
				-- 非套装
				equipInfoLayer = EquipInfoLayer.createLayer(methoodData.orangeId ,  nil, nil, nil, nil, showDownMenu, nil, nil, -600)
			end
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:addChild(equipInfoLayer, 1000)
			
			-- 清除选择的装备数据
			ForgeData.cleanChooseListData()
			-- 扣除铸造费用
			local costType,costNum = ForgeData.getCostDataByMethoodId(_selectEquipId, srcItemData.item_template_id)
			ForgeData.deductForgeCost(costType,costNum)
			-- 更新宝物列表
			-- updateTreasureList()
			-- 更新材料数量
			updateFragmentNumLabel()

			-- 返回强化费用提示
			if(retCostNum > 0)then 
				-- 加银币
        		UserModel.addSilverNumber(retCostNum)
			end
			
		    --放开事件屏蔽
		    _isPlayerEffect = false
		    sender:setEnabled(true)
		
			maskLayer:removeFromParentAndCleanup(true)

	    end

     	lightning:retain()
        local lightningDelegate = BTAnimationEventDelegate:create()
        lightningDelegate:registerLayerEndedHandler(function ( ... )
    	    lightningEndedCallFunc()
    		-- lightning:release()
        end)
        lightning:setDelegate(lightningDelegate)
	end
	--融合前特效
	local isExcuteService = false
	local goOkFunc = function ( ... )
		if(isExcuteService == false) then
			-- print("send ..")
			
			ForgeService.compose(_selectEquipId,srcItemData.item_id, callbackFunc)
			isExcuteService = true
		end
	end
	-- 开始
	goOkFunc()
end



