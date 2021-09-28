-- Filename: PreviewShopLayer.lua
-- Author: zhangqiang
-- Date: 2014-10-10
-- Purpose: 周末版神秘商店下一次随机商品预览

module("PreviewShopLayer", package.seeall)

require "script/ui/shopall/weekendShop/ShopClosedLayer"

local kAdaptSize = CCSizeMake(640, g_winSize.height/g_fScaleX)
local kPanelSize = CCSizeMake(572,kAdaptSize.height-380)
local kTableBgSize = CCSizeMake(kPanelSize.width-50, kPanelSize.height-143)
local kMainPriority = -480
local kMenuPriority = -485

local _mainLayer = nil

--[[
	@desc :	初始化
	@param:
	@ret  :
--]]
function init( ... )
	_mainLayer = nil
end

--[[
	@desc :	创建面板
	@param:
	@ret  :
--]]
function createPanel( ... )
	local panel = CCScale9Sprite:create(CCRectMake(60,60,93,51),"images/battle/report/bg.png")
	panel:setPreferredSize(kPanelSize)

	--标题背景
	local titleBg = CCSprite:create("images/battle/report/title_bg.png")
	titleBg:setAnchorPoint(ccp(0.5,0.5))
	titleBg:setPosition(kPanelSize.width*0.5, kPanelSize.height-6)
	panel:addChild(titleBg)

	--标题
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_110"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(158,31)
	titleBg:addChild(titleLabel)

	--预览描述
	local descLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_120"), g_sFontPangWa, 21)
	descLabel:setColor(ccc3(0x78,0x25,0x00))
	descLabel:setDimensions(CCSizeMake(457,60))
	descLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
	descLabel:setVerticalAlignment(kCCVerticalTextAlignmentTop)
	descLabel:setAnchorPoint(ccp(0.5,1))
	descLabel:setPosition(kPanelSize.width*0.5, kPanelSize.height-45)
	panel:addChild(descLabel)

	--创建tableView
	local tableView = createTableView()
	tableView:setAnchorPoint(ccp(0.5,0))
	tableView:setPosition(kPanelSize.width*0.5,36)
	panel:addChild(tableView)

	local menu = CCMenu:create()
	menu:setTouchPriority(kMenuPriority)
	menu:setPosition(0,0)
	panel:addChild(menu)
	--关闭按钮
	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeBtn:registerScriptTapHandler(tapCloseBtnCb)
	closeBtn:setAnchorPoint(ccp(0.5,0.5))
	closeBtn:setPosition(kPanelSize.width-20,kPanelSize.height-20)
	menu:addChild(closeBtn)

	return panel
end

--[[
	@desc :	创建TableView
	@param:
	@ret  :
--]]
function createTableView( ... )
	local tableBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	tableBg:setPreferredSize(kTableBgSize)

	--tableView
	require "script/ui/replaceSkill/CreateUI"
	local tableSize = CCSizeMake(kTableBgSize.width-60,kTableBgSize.height-30)
	--local cellCount = math.ceil(#WeekendShopData.getCurShopAllGoods()/4)
	local tableView = CreateUI.createTableView(0, tableSize, CCSizeMake(tableSize.width,128), nil, createCell, function ()
		return math.ceil(#WeekendShopData.getCurShopAllGoods()/4)
	end)
	tableView:setTouchPriority(kMenuPriority)
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setAnchorPoint(ccp(0.5,0.5))
	tableView:setPosition(kTableBgSize.width*0.5, kTableBgSize.height*0.5)
	tableBg:addChild(tableView)

	return tableBg
end

--[[
	@desc :	创建商品预览表的单元格
	@param:
	@ret  :
--]]
function createCell( pCellIndex )
	local cell = CCTableViewCell:create()
	local index = pCellIndex*4
	local positionX = 8
	for i = index-3,index do
		local goodData = WeekendShopData.getCurShopAllGoods()[i]
		if goodData ~= nil then
			local icon = ShopClosedLayer.createIcon(goodData.good.type, goodData.config.isHot, goodData.good.tid, goodData.good.num, kMenuPriority+2, kMenuPriority-2)
			icon:setAnchorPoint(ccp(0,1))
			icon:setPosition(positionX,118)
			cell:addChild(icon)
			positionX = positionX + 115
		end
	end

	return cell
end

--[[
	@desc :	创建层
	@param:
	@ret  :
--]]
function createLayer( ... )
	init()

	--创建层
	_mainLayer = CCLayerColor:create(ccc4(0x00,0x00,0x00,0x83))
	_mainLayer:setContentSize(kAdaptSize)
	_mainLayer:registerScriptHandler(onNodeEvent)
	_mainLayer:setScale(g_fScaleX)

	--创建面板
	local panel = createPanel()
	panel:setAnchorPoint(ccp(0.5,0.5))
	panel:setPosition(320,kAdaptSize.height*0.5)
	_mainLayer:addChild(panel)

	return _mainLayer
end

--[[
	@desc :	显示层
	@param:
	@ret  :
--]]
function showLayer( ... )
	local mainLayer = createLayer()
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(mainLayer,999)
end

-----------------------------------------------------[[ 回调函数 ]]---------------------------------------------------------------------
--[[
	@desc :	创建层时的回调
	@param:
	@ret  :
--]]
function onNodeEvent( pEventType )
	if pEventType == "enter" then
		_mainLayer:registerScriptTouchHandler(touchMainLayerCb, false, kMainPriority, true)
		_mainLayer:setTouchEnabled(true)
	elseif pEventType == "exit" then
		_mainLayer:unregisterScriptTouchHandler()
	else

	end
end

--[[
	@desc :	触摸层的回调
	@param:
	@ret  :
--]]
function touchMainLayerCb( pEventType, pTouchX, pTouchY )
	if pEventType == "began" then
		return true
	elseif pEventType == "moved" then

	elseif pEventType == "cancelled" then

	else
		-- pEventType = "ended"
	end
end

--[[
	@desc :	点击关闭按钮的回调
	@param:
	@ret  :
--]]
function tapCloseBtnCb( pTag, pItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.map3")

	if _mainLayer ~= nil then
		_mainLayer:removeFromParentAndCleanup(true)
		_mainLayer = nil
	end
end