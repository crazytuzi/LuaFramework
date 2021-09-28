-- Filename: TreasureFuseView..lua
-- Author: lichenyang
-- Date: 2013-11-2
-- Purpose: 宝物合成界面

module("TreasureFuseView", package.seeall)

require "script/ui/treasure/TreasureData"
require "script/ui/treasure/TreasureUtil"
require "script/ui/item/ItemSprite"
require "script/ui/treasure/TreasureService"
require "script/ui/item/ItemSprite"
require "script/ui/treasure/oneKeyRob/OneKeyRobData"
local ImagePath 			= "images/treasure/"
local FormationPath 		= "images/formation/"

---------------------------[[ 模块常量 ]]--------------------------------
local kFragmentContainerTag 	= 101
local kFragmentBackgroundTag 	= 102

---------------------------[[ 模块变量 ]]--------------------------------
local mainLayer 			= nil
local layerSize 			= nil
local radioMenu				= nil
local treasureIds			= nil
local fragmentSprite_bg		= nil
local fragmentNumLabels 	= nil
local treasureType 			= 0
local selectTreasureId  	= nil
local fragmentCountLabel 	= nil
local guideFragmentButton   = nil
local fuseButton 			= nil
local fragmentContainer 	= nil
local fragmentButtonArray 	= nil
local iconItemSprite 		= nil
local itemScrollView 		= nil
local itemListBg			= nil
local listItemArray 		= nil
local moveLayer 			= nil
local fragmentSetArray 		= nil
local isPlayerEffect 		= false
local toucheNode 			= nil
local shieldLabel 			= nil
local updateTimer 			= nil
local _onekeyFuseButton     = nil -- 一键合成按钮
function init()
	mainLayer 				= nil
	layerSize 				= nil
	radioMenu				= nil
	treasureIds				= nil
	fragmentSprite_bg		= nil
	fragmentNumLabels 		= {}
	treasureType 			= 0
	selectTreasureId  		= nil
	fragmentCountLabel 		= nil
	guideFragmentButton   	= nil
	fuseButton 				= nil
	fragmentContainer		= nil
	fragmentButtonArray 	= {}
	iconItemSprite 			= nil
	itemScrollView 			= nil
	itemListBg				= nil
	listItemArray 			= {}
	moveLayer 				= nil
	fragmentSetArray 		= {}
	isPlayerEffect 			= false
	toucheNode				= nil
	shieldLabel				= nil
	_onekeyFuseButton     	= nil 
end
---------------------------[[ ui 记忆数据]]-------------------------------

local memoryTreasureId = {}
memoryTreasureId.horse = nil
memoryTreasureId.book  = nil


-----------------------------[[ 节点事件 ]]------------------------------
function registerNodeEvent( ... )
	mainLayer:registerScriptHandler(function ( nodeType )
		if(nodeType == "exit") then
			print(GetLocalizeStringBy("key_3085"))
			fragmentNumLabels 		= {}
			fragmentButtonArray 	= {}
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(updateTimer)
		end
	end)
end


----------------------------[[ ui创建 ]]----------------------------------
--[[
	@des 	:创建合成界面
	@param 	:treasureType 合成物品类型(kTreasureHorseType, kTreasureBookType)
			 p_layerSize  层的大小
	@retrun :CClayer
]]
function create( treasure_type, p_layerSize )
	print("TreasureFuseView create1", p_layerSize)
	init()
	mainLayer 		= CCLayer:create()
	layerSize		= p_layerSize
	treasureType 	= treasure_type
	print("TreasureFuseView create2", layerSize.height, layerSize)
	createItemList()

	createMoveLayer()
	toucheNode = CCNode:create()
	toucheNode:setContentSize(CCSizeMake(layerSize.width/MainScene.elementScale, layerSize.height/MainScene.elementScale))
	toucheNode:setPosition(ccp(0, 0))
	toucheNode:setAnchorPoint(ccp(0, 0))
	mainLayer:addChild(toucheNode)
	--设置默认选择的宝物
    setDefaultSelected()
	--创建合成按钮
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	mainLayer:addChild(menu, 15)

	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		fuseButton =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(170, 83),GetLocalizeStringBy("key_3367"),ccc3(0xfe, 0xdb, 0x1c),26,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		fuseButton =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(170, 83),GetLocalizeStringBy("key_3367"),ccc3(0xfe, 0xdb, 0x1c),42,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end
	fuseButton:setAnchorPoint(ccp(1, 0.5))
    fuseButton:setPosition(ccp(0.95*layerSize.width / MainScene.elementScale, 0.12*layerSize.height / MainScene.elementScale))
    fuseButton:registerScriptTapHandler(fuseButtonCallback)
	menu:addChild(fuseButton,15)
	menu:setTouchPriority(-600)
	
	_onekeyFuseButton =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(220, 83),GetLocalizeStringBy("lic_1258"),ccc3(0xfe, 0xdb, 0x1c),42,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_onekeyFuseButton:setAnchorPoint(ccp(1, 0.5))
    _onekeyFuseButton:setPosition(ccp(0.34*layerSize.width / MainScene.elementScale, 0.12*layerSize.height / MainScene.elementScale))
    _onekeyFuseButton:registerScriptTapHandler(onekeyFuseButtonCallback)
	menu:addChild(_onekeyFuseButton,15)
	-- 是否显示一键合成
	local isShowOneKey = TreasureData.isShowOneKeyButton()
	_onekeyFuseButton:setVisible(isShowOneKey)

	local onekeyRobButton = CCMenuItemImage:create("images/treasure/one_key_btn_n.png","images/treasure/one_key_btn_h.png")
	onekeyRobButton:setAnchorPoint(ccp(1, 0.5))
    onekeyRobButton:setPosition(ccp(0.95*layerSize.width / MainScene.elementScale, 0.93*layerSize.height / MainScene.elementScale))
    onekeyRobButton:registerScriptTapHandler(onekeyRobButtonCallback)
	menu:addChild(onekeyRobButton,15)
	
	if UserModel.getHeroLevel() < OneKeyRobData.getShowLevel() then
		onekeyRobButton:setVisible(false)
	end

	--免战剩余时间
	require "script/utils/TimeUtil"
	local shieldTimeString = GetLocalizeStringBy("key_2670") .. TimeUtil.getTimeString(TreasureData.getHaveShieldTime())
	shieldLabel = CCRenderLabel:create(shieldTimeString, g_sFontName, 24, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	shieldLabel:setColor(ccc3(0x36, 0xff, 0x00))
	shieldLabel:setAnchorPoint(ccp(0,1))
	shieldLabel:setPosition(ccp(10 * MainScene.elementScale, 0.95 *layerSize.height/MainScene.elementScale))
	mainLayer:addChild(shieldLabel)
	shieldLabel:setString(shieldTimeString)
	if(TreasureData.getHaveShieldTime() <= 0) then
		shieldLabel:setVisible(false)
	else
		shieldLabel:setVisible(true)
	end

	updateTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateShieldTime, 1, false)

	--注册抢夺推送通知
	TreasureService.registerPushSeize(function ( ... )
		updateFragmentNumLabel()
	end)

	--添加新手引导
	addNewGuide()
	addNewGuideStepSeven()
	registerNodeEvent()
	return mainLayer
end

--[[
	@des 	:创建宝物列表
	@param 	:
	@retrun :
]]
function createItemList( ... )
	itemListBg 	= CCSprite:create(FormationPath .. "topbg.png")
	itemListBg:setPosition(ccp(0, (layerSize.height + 5)/MainScene.elementScale))
	itemListBg:setAnchorPoint(ccp(0, 1))
	itemListBg:setScale(g_fScaleX/MainScene.elementScale)
	mainLayer:addChild(itemListBg, 15)

	--更新layerSize 的大小
	layerSize = CCSizeMake(layerSize.width, layerSize.height - itemListBg:getContentSize().height * g_fScaleX)
	-- setAdaptNode(fragmentSprite_bg)
	-- fragmentSprite_bg:setScale(fragmentSprite_bg:getScale() * 0.85 / MainScene.elementScale)
	-- fragmentSprite_bg:setPosition(ccp(0.5 * layerSize.width/MainScene.elementScale, 0.5 *layerSize.height/MainScene.elementScale))

	local leftArrow 	= CCSprite:create(FormationPath .. "btn_left.png")
	leftArrow:setAnchorPoint(ccp(0, 0.5))
	leftArrow:setPosition(ccpsprite(0, 0.5, itemListBg))
	itemListBg:addChild(leftArrow)

	local rightArrow 	= CCSprite:create(FormationPath .. "btn_right.png")
	rightArrow:setAnchorPoint(ccp(1, 0.5))
	rightArrow:setPosition(ccpsprite(1, 0.5, itemListBg))
	itemListBg:addChild(rightArrow)
	
	itemScrollView=  CCScrollView:create()
	itemScrollView:setTouchPriority(-1005)

	treasureIds = TreasureData.getTreasureList(treasureType)

	itemScrollView = CCScrollView:create()
	itemScrollView:setTouchEnabled(true)
	itemScrollView:setDirection(kCCScrollViewDirectionHorizontal)
	itemScrollView:setViewSize(CCSizeMake(itemListBg:getContentSize().width * 0.82, itemListBg:getContentSize().height))
	itemScrollView:setContentSize(CCSizeMake(100 * #treasureIds + 10, itemListBg:getContentSize().height))
	itemScrollView:setBounceable(true)
	itemScrollView:setAnchorPoint(ccp(0.5 ,0.5))
	itemScrollView:setPosition(ccpsprite(0.1, 0.2, itemListBg))
    itemListBg:addChild(itemScrollView,1, 2002)
    itemScrollView:retain()
    radioMenu = BTMenu:create()
    radioMenu:setStyle(kMenuRadio)
    radioMenu:setPosition(ccp(0, 0))
    radioMenu:setScrollView(itemScrollView)
    itemScrollView:addChild(radioMenu)

    for i=1,#treasureIds do
    	local normalIconSprite 	= ItemSprite.getItemSpriteByItemId(treasureIds[i])
    	local selectIconSprite 	= ItemSprite.getItemSpriteByItemId(treasureIds[i])
    	local highlightSprite 	= CCSprite:create("images/hero/quality/highlighted.png")
    	highlightSprite:setAnchorPoint(ccp(0.5, 0.5))
    	highlightSprite:setPosition(ccpsprite(0.5, 0.5, selectIconSprite))
    	selectIconSprite:addChild(highlightSprite, 1, i)

    	local menuItem = CCMenuItemSprite:create(normalIconSprite, selectIconSprite)
    	menuItem:setAnchorPoint(ccp(0, 0))
    	menuItem:setPosition(ccp((i-1)*100+7, 0))
    	menuItem:registerScriptTapHandler(treasureItemSelectCallfunc)
    	radioMenu:addChild(menuItem,1, treasureIds[i])

    	listItemArray[treasureIds[i]] = menuItem
    end
end

--[[
	@des: 		创建拖动层
]]
function createMoveLayer( ... )
	moveLayer = CCLayer:create()
	moveLayer:setTouchEnabled(true)
	mainLayer:addChild(moveLayer)
	moveLayer:registerScriptTouchHandler(onTouchCallFunc, false, 1, false)
	mainLayer:setContentSize(CCSizeMake(layerSize.width, layerSize.height))
	for i=1,#treasureIds do
		local fragmentSet = createTreasureFragmentSet(treasureIds[i])
		fragmentSet:setAnchorPoint(ccp(0.5, 0.5))
		fragmentSet:setPosition(ccp(0.5 * layerSize.width/MainScene.elementScale + (i-1) * layerSize.width/MainScene.elementScale, 0.5 *layerSize.height/MainScene.elementScale))
		moveLayer:addChild(fragmentSet, 10)
		setAdaptNode(fragmentSet)
		fragmentSet:setScale(fragmentSet:getScale() * 0.85 / MainScene.elementScale)
		fragmentSetArray[treasureIds[i]] = fragmentSet
	end

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
		if(isPlayerEffect == true) then
			return false
		end
	    local viewRect = getSpriteScreenRect(toucheNode)
	    print("viewRect(", viewRect.origin.x, viewRect.origin.y, viewRect.size.width, viewRect.size.height, ")")
	    if(viewRect:containsPoint(ccp(x, y))) then
	        return true
	    else
	        return false
	    end
	elseif(eventType == "moved") then
		local movePrevious = x - lastMove
		lastMove = x
		moveLayer:setPosition(moveLayer:getPositionX() + movePrevious,moveLayer:getPositionY())
	else
		--得到当前页的偏移量
		print("layerSize.width = ",layerSize.width/MainScene.elementScale)
		local m_pageCount = #treasureIds
	    local nowPageOffset = moveLayer:getPositionX() + selectIndex * layerSize.width/MainScene.elementScale
	    if (nowPageOffset <= - layerSize.width/MainScene.elementScale/5 and selectIndex ~= m_pageCount-1) then
	        selectIndex = selectIndex + 1
	        local           moveDis = -selectIndex* layerSize.width/MainScene.elementScale
	        local        	move    = CCMoveTo:create(0.3, ccp(moveDis, 0))
	        local 			ease    = CCEaseElastic:create(move)
	        moveLayer:runAction(ease)
	    elseif(nowPageOffset >= layerSize.width/MainScene.elementScale/5 and selectIndex ~= 0) then 
	        selectIndex = selectIndex - 1
	        local           moveDis = -selectIndex* layerSize.width/MainScene.elementScale
	        local        	move    = CCMoveTo:create(0.3, ccp(moveDis, 0))
	        local 			ease    = CCEaseElastic:create(move)
	        moveLayer:runAction(ease)
	    else
	        local           moveDis = -selectIndex* layerSize.width/MainScene.elementScale
	        local        	move    = CCMoveTo:create(0.3, ccp(moveDis, 0))
	        local 			ease    = CCEaseElastic:create(move)
	        moveLayer:runAction(ease)
	    end
		radioMenu:setMenuSelected(listItemArray[treasureIds[selectIndex+1]])
		updateScrollViewContainerPosition(listItemArray[treasureIds[selectIndex+1]])
		selectTreasureId = treasureIds[selectIndex+1]
		fragmentSprite_bg = fragmentSetArray[selectTreasureId]
		fragmentContainer = tolua.cast(fragmentSetArray[selectTreasureId]:getChildByTag(kFragmentContainerTag), "CCNode")
	end
end



--[[
	@des:	创建一个宝物碎片的盘子
	@param:	treasure_id宝物id
	@return: ccsprite 宝物碎片集合的盘子
]]
function createTreasureFragmentSet( treasure_id )
	local fragmentBackground = CCSprite:create(ImagePath .. "dish_bg.png")

	--闪电特效添加
	local lightning = CCLayerSprite:layerSpriteWithName(CCString:create(ImagePath .. "effect/light"), -1,CCString:create(""))
    lightning:setAnchorPoint(ccp(0.5, 0.5))
    lightning:setPosition(fragmentBackground:getContentSize().width/2,fragmentBackground:getContentSize().height*0.5)
    fragmentBackground:addChild(lightning,1)
	
	local fragment_Container = CCNode:create()
	fragment_Container:setContentSize(CCSizeMake(fragmentBackground:getContentSize().width, fragmentBackground:getContentSize().height))
	fragment_Container:setAnchorPoint(ccp(0.5, 0.5))
	fragment_Container:setPosition(ccpsprite(0.5, 0.5, fragmentBackground))
	fragmentBackground:addChild(fragment_Container, 0, kFragmentContainerTag)

	fragment_Container:removeAllChildrenWithCleanup(true)
	--添加宝物名称
	local nameBg = CCSprite:create(ImagePath .. "name_bg.png")
	nameBg:setPosition(ccpsprite(0.5, 0.3, fragment_Container))
	nameBg:setAnchorPoint(ccp(0.5, 0.5))
	fragment_Container:addChild(nameBg, 100)

	local nameLabel = CCRenderLabel:create(TreasureData.getTreasureName(treasure_id), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setAnchorPoint(ccp(0.5, 0.5))
	nameLabel:setPosition(ccpsprite(0.5, 0.5, nameBg))
	nameBg:addChild(nameLabel)
	nameLabel:setColor(TreasureUtil.getTreasureColor(treasure_id))

	--添加碎片
	local fragments = TreasureData.getTreasureFragments(treasure_id)
	local count = table.count(fragments)
    local ox,oy = fragmentBackground:getContentSize().width/2,fragmentBackground:getContentSize().height/2

    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0, 0))
    menu:setPosition(ccp(0, 0))
    fragment_Container:addChild(menu, 11)
    menu:setTouchPriority(-530)

    --添加大图标
    local bigMenu = BTMenu:create()
    bigMenu:setPosition(ccp(0, 0))
    bigMenu:setAnchorPoint(ccp(0, 0))
    fragment_Container:addChild(bigMenu)

	local iconSprite1 = TreasureUtil.getTreasureBigIcon(treasure_id)
	local iconSprite2 = TreasureUtil.getTreasureBigIcon(treasure_id)
	iconItemSprite = CCMenuItemSprite:create(iconSprite1, iconSprite2)
	iconItemSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconItemSprite:setPosition(ccpsprite(0.5, 0.5, fragment_Container))
	iconItemSprite:registerScriptTapHandler(function ( ... )
		-- 宝物信息
		require "script/ui/item/TreasureInfoLayer"
		local treasInfoLayer = TreasureInfoLayer:createWithTid(treasure_id, TreasInfoType.CONFIRM_TYPE)
		treasInfoLayer:show(-621, 1010)
		treasInfoLayer:registerCallback( function ( ... )
				iconItemSprite:setEnabled(true)
			end )

		iconItemSprite:setEnabled(false)

	end)
	bigMenu:addChild(iconItemSprite)

    -- 清除数字label 数组
    fragmentNumLabels[treasure_id] 	= {}
    -- 清除碎片图标数组
    fragmentButtonArray[treasure_id]	= {}
	local i = 0
	for k,v in pairs(fragments) do
	    local rotation =math.rad(i * 360/count + 90) 
   		local moveDis = -212
	    local nx = math.cos(rotation) 	* moveDis + ox
    	local ny = - math.sin(rotation) * moveDis + oy

    	 -- 按钮外框
    	local iconBgSprite 		= CCSprite:create("images/common/equipborder.png")
    	iconBgSprite:setAnchorPoint(ccp(0.5, 0.5))
    	iconBgSprite:setPosition(ccp(nx, ny))
    	fragment_Container:addChild(iconBgSprite, 10)

    	local normalIconSprite	= ItemSprite.getItemSpriteByItemId(v)
    	local selectIconSprite 	= ItemSprite.getItemSpriteByItemId(v)
    	local highlightSprite 	= CCSprite:create("images/hero/quality/highlighted.png")
    	highlightSprite:setAnchorPoint(ccp(0.5, 0.5))
    	highlightSprite:setPosition(ccpsprite(0.5, 0.5, selectIconSprite))
    	selectIconSprite:addChild(highlightSprite, 1, i)

    	local menuItem = CCMenuItemSprite:create(normalIconSprite, selectIconSprite)
    	menuItem:registerScriptTapHandler(fragmentDetailCallback)
    	menuItem:setAnchorPoint(ccp(0.5, 0.5))
    	menuItem:setPosition(ccp(nx, ny))
    	menu:addChild(menuItem, 1, v)
    	local item = {}
    	item.button = menuItem
    	item.tid 	= v
    	table.insert(fragmentButtonArray[treasure_id], item)

    	local numBg = CCSprite:create(ImagePath .. "num_back.png")
    	numBg:setAnchorPoint(ccp(0.5, 0.5))
    	numBg:setPosition(ccpsprite(0.9, 0.1, menuItem))
    	menuItem:addChild(numBg)
    	
    	local numbLabel = CCLabelTTF:create(tostring(TreasureData.getFragmentNum(v)), g_sFontPangWa, 22)
    	numbLabel:setPosition(ccpsprite(0.5, 0.5, numBg))
    	numbLabel:setAnchorPoint(ccp(0.5, 0.5))
    	numBg:addChild(numbLabel)
    	if(TreasureData.getFragmentNum(v) == 0) then
			numbLabel:setColor(ccc3(0xff,0x1d,0x1d))
			nodeTintBlack(menuItem, ccc3(100,100,100))
		end
    	--保存数字引用
    	fragmentNumLabels[treasure_id][tostring(v)] = numbLabel
    	i = i + 1
    	--保存新手引导按钮
    	if(i == 2 and treasure_id == treasureIds[1]) then
    		guideFragmentButton = menuItem
    		if(NewGuide.guideClass == ksGuideRobTreasure and RobTreasureGuide.stepNum <6) then
    			numbLabel:setString(tostring(TreasureData.getFragmentNum(v) - 1))
    			if(TreasureData.getFragmentNum(v) - 1 == 0) then
					numbLabel:setColor(ccc3(0xff,0x1d,0x1d))
					nodeTintBlack(menuItem, ccc3(100,100,100))
				end
    		end
    	end
	end
	return fragmentBackground
end

-----------------------------[[ 更新ui方法]] ------------------------------
--[[
	@des:	设置默认选择的宝物
]]
function setDefaultSelected( ... )

	local isContainer = function ( treaId )
		for k,v in pairs(treasureIds) do
			if(tonumber(v) == tonumber(treaId)) then
				return true
			end
		end
		return false
	end
	local selectItemId = nil
	if(treasureType == kTreasureHorseType) then
		if(memoryTreasureId.horse == nil or isContainer(memoryTreasureId.horse) == false) then
			treasureItemSelectCallfunc(treasureIds[1])
			selectItemId = treasureIds[1]
		else
			local button = tolua.cast(radioMenu:getChildByTag(memoryTreasureId.horse), "CCMenuItem")
			treasureItemSelectCallfunc(memoryTreasureId.horse)
			selectItemId = memoryTreasureId.horse
		end
	elseif(treasureType == kTreasureBookType) then
		if(memoryTreasureId.book == nil or isContainer(memoryTreasureId.book) == false) then
			treasureItemSelectCallfunc(treasureIds[1])
			selectItemId = treasureIds[1]
		else
			local button = tolua.cast(radioMenu:getChildByTag(memoryTreasureId.book), "CCMenuItem")
			treasureItemSelectCallfunc(memoryTreasureId.book)
			selectItemId = memoryTreasureId.book
		end
	end
	radioMenu:setMenuSelected(listItemArray[selectItemId])
	updateScrollViewContainerPosition(listItemArray[selectItemId], 0)
	selectTreasureId = selectItemId
	fragmentSprite_bg = fragmentSetArray[selectTreasureId]
	fragmentContainer = tolua.cast(fragmentSetArray[selectTreasureId]:getChildByTag(kFragmentContainerTag), "CCNode")
end

--[[
	@des:	更新scrollView位置
]]
function updateScrollViewContainerPosition( selectNode,time )

	local posX = selectNode:getPositionX() - itemScrollView:getViewSize().width/2
	local lnx,px,vw = 0,selectNode:getPositionX(),itemScrollView:getViewSize().width
	if(px+ selectNode:getContentSize().width< vw ) then
		lnx = 0
	else
		lnx = px - vw*0.5 + selectNode:getContentSize().width/2
		if(lnx > px + selectNode:getContentSize().width  - vw) then
			lnx = px + selectNode:getContentSize().width - vw
		end
	end
	print("lnx = ", lnx)
	itemScrollView:setContentOffsetInDuration(ccp(-lnx, 0), time or 0.5)
end


--[[
	@des:	更新宝物碎片数量
]]
function updateFragmentNumLabel( ... )
	--刷新当前ui宝物碎片数量
	for i=1,#treasureIds do
		local fragmentsNew = TreasureData.getTreasureFragments(treasureIds[i])
		if(fragmentNumLabels[treasureIds[i]] == nil) then
			break
		end

		for k,v in pairs(fragmentNumLabels[treasureIds[i]]) do
			local num = TreasureData.getFragmentNum(k)
			fragmentNumLabels[treasureIds[i]][k]:setString(tostring(num))
			if(tonumber(num) == 0) then
				fragmentNumLabels[treasureIds[i]][k]:setColor(ccc3(0xff,0x1d,0x1d))
			end
		end				
	
		-- 碎为0 的图标变灰
		for k,v in pairs(fragmentButtonArray[treasureIds[i]]) do
			local num = TreasureData.getFragmentNum(v.tid)
			if(tonumber(num) == 0) then
				nodeTintBlack(v.button, ccc3(100,100,100))
			else
				nodeTintBlack(v.button, ccc3(255,255,255))
			end
		end	
	end


	--刷新当前碎片总数量
	-- fragmentCountLabel:setString(tostring(TreasureData.getFragmentCount(treasureType)))
end

--[[
	@des:		更新宝物列表
]]
function updateTreasureList( ... )

	itemListBg:removeAllChildrenWithCleanup(true)

	local leftArrow 	= CCSprite:create(FormationPath .. "btn_left.png")
	leftArrow:setAnchorPoint(ccp(0, 0.5))
	leftArrow:setPosition(ccpsprite(0, 0.5, itemListBg))
	itemListBg:addChild(leftArrow)

	local rightArrow 	= CCSprite:create(FormationPath .. "btn_right.png");
	rightArrow:setAnchorPoint(ccp(1, 0.5))
	rightArrow:setPosition(ccpsprite(1, 0.5, itemListBg))
	itemListBg:addChild(rightArrow)

    itemScrollView=  CCScrollView:create()
	itemScrollView:setTouchPriority(-1005)

	treasureIds = TreasureData.getTreasureList(treasureType)

	itemScrollView = CCScrollView:create()
	itemScrollView:setTouchEnabled(true)
	itemScrollView:setDirection(kCCScrollViewDirectionHorizontal)
	itemScrollView:setViewSize(CCSizeMake(itemListBg:getContentSize().width * 0.8, itemListBg:getContentSize().height))
	itemScrollView:setContentSize(CCSizeMake(100 * #treasureIds, itemListBg:getContentSize().height))
	itemScrollView:setBounceable(true)
	itemScrollView:setAnchorPoint(ccp(0.5 ,0.5))
	itemScrollView:setPosition(ccpsprite(0.1, 0.2, itemListBg))
    itemListBg:addChild(itemScrollView,1, 2002)
    -- itemScrollView:retain()
    radioMenu = BTMenu:create()
    radioMenu:setStyle(kMenuRadio)
    radioMenu:setPosition(ccp(0, 0))
    radioMenu:setScrollView(itemScrollView)
    itemScrollView:addChild(radioMenu)

    listItemArray = {}
    for i=1,#treasureIds do
    	local normalIconSprite 	= ItemSprite.getItemSpriteByItemId(treasureIds[i])
    	local selectIconSprite 	= ItemSprite.getItemSpriteByItemId(treasureIds[i])
    	local highlightSprite 	= CCSprite:create("images/hero/quality/highlighted.png")
    	highlightSprite:setAnchorPoint(ccp(0.5, 0.5))
    	highlightSprite:setPosition(ccpsprite(0.5, 0.5, selectIconSprite))
    	selectIconSprite:addChild(highlightSprite, 1, i)

    	local menuItem = CCMenuItemSprite:create(normalIconSprite, selectIconSprite)
    	menuItem:setAnchorPoint(ccp(0, 0))
    	menuItem:setPosition(ccp((i-1)*100, 0))
    	menuItem:registerScriptTapHandler(treasureItemSelectCallfunc)
    	radioMenu:addChild(menuItem,1, treasureIds[i])
    	listItemArray[treasureIds[i]] = menuItem
    end
    --更新moveLayer
    recreateMoveLayer()

    --设置默认选择的宝物
    setDefaultSelected()
end

--[[
	@des:		更新moveLayer到宝物位置
]]
function updateMoveLayer( treasure_id )
	
	for i,v in ipairs(treasureIds) do
		if(v == treasure_id) then
			selectIndex = i -1
			break
		end
	end
	print("updateMoveLayer selectIndex =", selectIndex)
	if(moveLayer ~= nil) then
		moveLayer:setPosition(-layerSize.width/MainScene.elementScale * selectIndex, 0)
	end
end

--[[
	@des:		刷新免战时间定时器
]]
function updateShieldTime( ... )
	local shieldTimeString = GetLocalizeStringBy("key_2670") .. TimeUtil.getTimeString(TreasureData.getHaveShieldTime())
	
	if(TreasureData.getHaveShieldTime() <= 0) then
		shieldLabel:setVisible(false)
	else
		shieldLabel:setVisible(true)
	end
	shieldLabel:setString(shieldTimeString)
end

function recreateMoveLayer( ... )
	moveLayer:removeAllChildrenWithCleanup(true)

	for i=1,#treasureIds do
		local fragmentSet = createTreasureFragmentSet(treasureIds[i])
		fragmentSet:setAnchorPoint(ccp(0.5, 0.5))
		fragmentSet:setPosition(ccp(0.5 * layerSize.width/MainScene.elementScale + (i-1) * layerSize.width/MainScene.elementScale, 0.5 *layerSize.height/MainScene.elementScale))
		moveLayer:addChild(fragmentSet, 10)
		setAdaptNode(fragmentSet)
		fragmentSet:setScale(fragmentSet:getScale() * 0.85 / MainScene.elementScale)
		fragmentSetArray[treasureIds[i]] = fragmentSet
	end
end

----------------------------[[ 回调事件 ]]----------------------------------
--[[
	@des 	:选择宝物回调事件
	@param	:tag 宝物模板id
]]
function treasureItemSelectCallfunc( tag, sender )

	print("seizerInfoData")
	print_t(TreasureData.seizerInfoData)

	print("treasureItemSelectCallfunc tag =", tag)
	selectTreasureId = tag
	if(treasureType == kTreasureHorseType) then
		memoryTreasureId.horse = selectTreasureId
	elseif(treasureType == kTreasureBookType) then
		memoryTreasureId.book = selectTreasureId
	end
	--
	fragmentSprite_bg = fragmentSetArray[selectTreasureId]
	fragmentContainer = tolua.cast(fragmentSetArray[selectTreasureId]:getChildByTag(kFragmentContainerTag), "CCNode")
	updateMoveLayer(selectTreasureId)
end

--[[
	@des 	:碎片合成按钮事件
	@param	:tag 宝物模板id
]]
function fuseButtonCallback( tag,sender, p_isOneKeyFuse, p_onekeyFuseNum )
  	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	--是否背包满
	if(ItemUtil.isTreasBagFull(true, nil) == true) then
		return
	end
	--新手引导
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideRobTreasure) then
		RobTreasureGuide.changLayer(0)
	end

	--判断是否拥有该碎片
	local fragments = TreasureData.getTreasureFragments(selectTreasureId)
	local isHave = true
	for k,v in pairs(fragments) do
		if(TreasureData.getFragmentNum(v) == 0) then
			isHave = false
			print(GetLocalizeStringBy("key_2066"), v)
		end
	end
	if(isHave == false) then
		--没有对应的碎片
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1229"))
		return
	end

	--屏蔽按钮事件
	isPlayerEffect = true
	fuseButton:setEnabled(false)
	_onekeyFuseButton:setEnabled(false)
	iconItemSprite:setEnabled(false)
	for k,v in pairs(fragmentButtonArray[selectTreasureId]) do
		v.button:setEnabled(false)
	end
	require "script/utils/BaseUI"
	local maskLayer = BaseUI.createMaskLayer(-5000, nil, nil, 0)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(maskLayer, 2000)


	local callbackFunc = function ( isSuccess )
		if(isSuccess == false) then
			--合成失败
			AnimationTip.showTip(GetLocalizeStringBy("key_2635"))
			--放开事件屏蔽
			fuseButton:setEnabled(true)
			_onekeyFuseButton:setEnabled(true)
			iconItemSprite:setEnabled(true)
			isPlayerEffect = false
			for k,v in pairs(fragmentButtonArray[selectTreasureId]) do
				v.button:setEnabled(true)
			end
			maskLayer:removeFromParentAndCleanup(true)
			return
		end

		print(GetLocalizeStringBy("key_3248"))
		if(p_isOneKeyFuse == nil)then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_1034") .. TreasureData.getTreasureName(selectTreasureId) .. GetLocalizeStringBy("key_3128"))
		end
		updateFragmentNumLabel()
		--合成特效播放
		local lightning = CCLayerSprite:layerSpriteWithNameAndCount(ImagePath .. "effect/bsqdE", 1,CCString:create(""))
	    lightning:setAnchorPoint(ccp(0.5, 0.5));
	    lightning:setPosition(fragmentSprite_bg:getContentSize().width/2,fragmentSprite_bg:getContentSize().height*0.5);
	    fragmentSprite_bg:addChild(lightning,80);

	    -- 宝物信息
		local closeCallFunc = function ( ... )
			--新手引导
	   	 	addNewGuideStepEight()
		end
		print("lightningEndedCallFunc")
		function lightningEndedCallFunc(  )
			if(p_isOneKeyFuse)then
				require "script/ui/treasure/OneKeyFuseOverDailog"
				OneKeyFuseOverDailog.showTip(selectTreasureId,p_onekeyFuseNum)
			else
				require "script/ui/item/TreasureInfoLayer"
				local treasInfoLayer = TreasureInfoLayer:createWithTid(selectTreasureId, TreasInfoType.CONFIRM_TYPE)
				treasInfoLayer:show(-621, 1010)
				treasInfoLayer:registerCallback( closeCallFunc )

			    addNewGuideStepTreasureInfo()
			end

		    --放开事件屏蔽
		    isPlayerEffect = false
		    fuseButton:setEnabled(true)
		    _onekeyFuseButton:setEnabled(true)
		    iconItemSprite:setEnabled(true)
			for k,v in pairs(fragmentButtonArray[selectTreasureId]) do
				v.button:setEnabled(true)
			end
			maskLayer:removeFromParentAndCleanup(true)
			--更新宝物列表
			updateTreasureList()
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
			if(p_isOneKeyFuse)then
				TreasureService.fuse(selectTreasureId,p_onekeyFuseNum,callbackFunc)
			else
				TreasureService.fuse(selectTreasureId, 1,callbackFunc)
			end
			isExcuteService = true
		end
	end
	local ox,oy = fragmentSprite_bg:getContentSize().width/2,fragmentSprite_bg:getContentSize().height/2

	for k,v in pairs(fragmentButtonArray[selectTreasureId]) do
		local sprite 	= ItemSprite.getItemSpriteByItemId(v.tid)
		sprite:setAnchorPoint(ccp(0.5, 0.5))
		sprite:setPosition(ccp(v.button:getPositionX(), v.button:getPositionY()))
		fragmentContainer:addChild(sprite, 30)
		local move 		= CCMoveTo:create(0.8, ccp(ox, oy))
		local actions = CCArray:create()
		actions:addObject(move)
		actions:addObject(CCCallFunc:create(function ( ... )
			sprite:removeFromParentAndCleanup(true)
			goOkFunc()
			actions:release()
		end))
		actions:retain()

        local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/astro/zhanxingbao"), -1,CCString:create(""));
        appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
        appearEffectSprite:setPosition(ccp(v.button:getPositionX(), v.button:getPositionY()));
        fragmentContainer:addChild(appearEffectSprite,99999);

        appearEffectSprite:retain()
       	local delegate = BTAnimationEventDelegate:create()
        delegate:registerLayerEndedHandler(function ( ... )
        	print(GetLocalizeStringBy("key_1037"))
        	local seqAction = CCSequence:create(actions)
        	sprite:runAction(seqAction)
			-- appearEffectSprite:retain()
			-- appearEffectSprite:autorelease()
        	appearEffectSprite:removeFromParentAndCleanup(true)
        	appearEffectSprite:release()

        end)
        appearEffectSprite:setDelegate(delegate)

        print("合成特效 = ", k)
	end
end

--[[
	@des 	:一键合成按钮事件
	@param	:tag 宝物模板id
]]
function onekeyFuseButtonCallback( tag,sender )
	-- 功能开启判断
	local isOpen, needLeve, needVip = TreasureData.getIsOpenOneKeyFuse()
	if(isOpen == false)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(string.format(GetLocalizeStringBy("lic_1273"),needVip,needLeve))
		return
	end
	--是否背包满
	if(ItemUtil.isTreasBagFull(true, nil) == true) then
		return
	end
 	-- 一键合成最多能合成的个数
	local maxFuseNum = TreasureData.getCanFuseNum(selectTreasureId)
	local onekeyCanFuseNum = 0
	if(maxFuseNum > 10)then
		onekeyCanFuseNum = 10
	else
		onekeyCanFuseNum = maxFuseNum
	end
	if(onekeyCanFuseNum > 0)then
		require "script/ui/treasure/OneKeyFuseDailog"
		OneKeyFuseDailog.showTip(selectTreasureId,onekeyCanFuseNum)
	else
		--没有对应的碎片
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1229"))
	end
end

--[[
	@des :一键夺宝按钮回调
--]]
function onekeyRobButtonCallback( pTag, pSender )
	if UserModel.getHeroLevel() < OneKeyRobData.getUseLevel() then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1996", OneKeyRobData.getUseLevel()))
		return 
	end
	require "script/ui/treasure/oneKeyRob/OneKeyRobTipDialog"
	OneKeyRobTipDialog.show(selectTreasureId)
end

--[[
	@des 	:碎片详情回调事件
	@param	:tag 碎片模板id
]]
function fragmentDetailCallback( tag,sender )
	print("fragmentDetailCallback", GetLocalizeStringBy("key_1751"), tag)
	require "script/ui/treasure/TreasureFragmentInfoView"
	TreasureFragmentInfoView.show(tag, nil, TreasureFragmentInfoView.kFragmentInfoRob)
end

----------------------------[[ 新手引导 ]]----------------------------------
--[[
	@des:	得到新手引导的碎片图标
]]
function getGuideButton( ... )
	return guideFragmentButton
end

--[[
	@des:	得到合成按钮
]]
function getFuseButton( ... )
	return fuseButton
end

--[[
	@des:	添加引导层方法
]]
function addNewGuide( ... )
	local guideFunc = function ( ... )
		require "script/guide/RobTreasureGuide"
	    if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 1) then
	       	require "script/ui/active/ActiveList"
	        local robTreasure = getGuideButton(4)
	        local touchRect   = getSpriteScreenRect(robTreasure)
	        RobTreasureGuide.show(2, touchRect)
	    end
	end
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			guideFunc()
	end))
	mainLayer:runAction(seq)

	local guideFunc = function ( ... )
		require "script/guide/RobTreasureGuide"
	    if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 12) then
	       	require "script/ui/active/ActiveList"
	        RobTreasureGuide.show(13, nil)
	    end
	end
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			guideFunc()
	end))
	mainLayer:runAction(seq)

end

--[[
    @des:   宝物合成按钮引导
]]
function addNewGuideStepSeven( ... )
    local guideFunc = function ( ... )
        require "script/guide/RobTreasureGuide"
        if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 6) then
            RobTreasureGuide.changLayer()
            local robTreasure = getFuseButton()
            local touchRect   = getSpriteScreenRect(robTreasure)
            RobTreasureGuide.show(7, touchRect)
        end
    end
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0),CCCallFunc:create(function ( ... )
            guideFunc()
    end))
    mainLayer:runAction(seq)
end

--[[
	@des:	阵容按钮就引导 
]]
function addNewGuideStepEight( ... )
	local guideFunc = function ( ... )
		require "script/ui/main/MenuLayer"
	    require "script/guide/RobTreasureGuide"
        if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 7.5) then
        	RobTreasureGuide.changLayer()
            local robTreasure =  MenuLayer.getMenuItemNode(2)
            local touchRect   = getSpriteScreenRect(robTreasure)
            RobTreasureGuide.show(8, touchRect)
        end
    end
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0),CCCallFunc:create(function ( ... )
            guideFunc()
    end))
    mainLayer:runAction(seq)
end
--[[
	@des:	宝物详情引导
]]
function addNewGuideStepTreasureInfo( ... )
	local guideFunc = function ( ... )
		require "script/ui/main/MenuLayer"
	    require "script/guide/RobTreasureGuide"
        if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 7) then
            require "script/ui/item/TreasureInfoLayer"
            local robTreasure =  TreasureInfoLayer.getGuideObject_2()
            local touchRect   = getSpriteScreenRect(robTreasure)
            RobTreasureGuide.show(7.5, touchRect)
        end
    end
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0),CCCallFunc:create(function ( ... )
            guideFunc()
    end))
    mainLayer:runAction(seq)
end

--------------------------------[[ 工具方法 ]]-------------------------------
--[[
	@des:		把node 已经其子节点setColor 为color颜色
	@param:		sprite_node: 节点 color颜色 ccc3格式
]]
function nodeTintBlack( sprite_node, color )
	local sprite_node = tolua.cast(sprite_node, "CCNodeRGBA")
	if(sprite_node == nil) then
		return
	end
	sprite_node:setColor(color)
	local chidlArray = sprite_node:getChildren()
	if(chidlArray == nil or chidlArray:count() <= 0) then
		return
	end
	for i=0,chidlArray:count()-1 do
		local childNode = chidlArray:objectAtIndex(i)
		nodeTintBlack(childNode, color)
	end
end



