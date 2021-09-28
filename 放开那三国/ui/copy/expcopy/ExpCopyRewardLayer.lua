-- Filename: ExpCopyRewardLayer.lua
-- Author: lichenyang
-- Date: 2015-04-07
-- Purpose: 主角经验副本战斗结算面板


module("ExpCopyRewardLayer", package.seeall)


local colorLayer      = nil
local copyTable     = nil
local rewardList      = nil
local rewardCountNum  = nil
local pageLayer       = nil
local updataTimerFunc = nil
local slideIcons      = nil
local slideNode       = nil
local _priority       = nil
local _zOrder 		  = nil
local _background 	  = nil
local _itemArray 	  = nil
----------------------------[[ ui创建 ]]----------------------------------

function init( )
	colorLayer      = nil
	copyTable     = nil
	rewardList      = nil
	rewardCountNum  = nil
	pageLayer       = nil
	updataTimerFunc = nil
	background 		= nil
	slideIcons      = {}
	slideNode       = nil
end

function show( p_Priority, p_zOrder, p_itemArray )
 	local zOrder = p_zOrder or 2000
	local layer = ExpCopyRewardLayer.create(p_Priority, zOrder, p_itemArray)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(layer, zOrder)
end

function create(p_Priority, p_zOrder, p_itemArray)

	init()
	_itemArray = p_itemArray or {}
	_priority = p_Priority or - 485
	_zOrder = p_zOrder
	colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	colorLayer:setPosition(ccp(0, 0))
	-- added by zhz
	colorLayer:registerScriptTouchHandler(layerToucCb,false,_priority - 5,true)
	colorLayer:setTouchEnabled(true)
	colorLayer:setAnchorPoint(ccp(0, 0))
	
	local g_winSize = CCDirector:sharedDirector():getWinSize()

	_background = CCScale9Sprite:create("images/common/viewbg1.png")
	_background:setContentSize(CCSizeMake(520, 560))
	_background:setAnchorPoint(ccp(0.5, 0.5))
	_background:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	colorLayer:addChild(_background)
	AdaptTool.setAdaptNode(_background)

	--标题
	local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(_background:getContentSize().width/2, _background:getContentSize().height - 7 )
	_background:addChild(titlePanel)

	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1322"), g_sFontPangWa, 35, 1, ccc3(0,0,0))
	titleLabel:setColor(ccc3(0xff , 0xe4, 0x00))
	local x = (titlePanel:getContentSize().width - titleLabel:getContentSize().width)/2
	local y = titlePanel:getContentSize().height - (titlePanel:getContentSize().height - titleLabel:getContentSize().height)/2
	titleLabel:setPosition(ccp(x , y))
	titlePanel:addChild(titleLabel)


	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	menu:setTouchPriority(-486)
	_background:addChild(menu)

	--关闭按钮
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setPosition(_background:getContentSize().width * 0.95, _background:getContentSize().height * 0.96)
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	local tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	tableBackground:setContentSize(CCSizeMake(460, 450))
	tableBackground:setAnchorPoint(ccp(0.5, 0))
	tableBackground:setPosition(ccp(_background:getContentSize().width*0.5, 40))
	_background:addChild(tableBackground)

	local scrollView = CCScrollView:create()
    scrollView:setTouchPriority(-504)
    scrollView:setContentSize(CCSizeMake(420,450))
    scrollView:setViewSize(CCSizeMake(420,450))
    scrollView:setBounceable(true)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setAnchorPoint(ccp(0,0))
    scrollView:setPosition(ccp(0,0))
    tableBackground:addChild(scrollView)


    local startX = 40
	local startY = scrollView:getContentSize().height - 110

	local intervalX = 142
	local intervalY = 120

	local columnNum = 3

	require "script/ui/item/ItemSprite"
    require "script/ui/item/ItemUtil"
    for i=1,#_itemArray do
        local item = ItemSprite.getItemSpriteById(tonumber(_itemArray[i]),nil,nil,nil,_priority - 100, _zOrder + 100, _priority - 200 )
        item:setAnchorPoint(ccp(0,1))
        item:setPosition(startX + (i-1)%columnNum * intervalX, startY -math.floor((i-1)/columnNum)*intervalY)
        scrollView:addChild(item)

        local dbItem = ItemUtil.getItemById(tonumber(_itemArray[i]))
        if(dbItem~=nil and dbItem.name~=nil)then
            local itemNameLabel = CCRenderLabel:create(dbItem.name, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
            itemNameLabel:setColor(ccc3( 0xff, 0xf6, 0x00))
            itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
            itemNameLabel:setPosition(item:getContentSize().width*0.5,-item:getContentSize().height*0.15)
            item:addChild(itemNameLabel)
        end
    end
    
	return colorLayer
end

-- layerTouch 的回调函数
function layerToucCb(eventType, x, y)
	return true
end

----------------------------[[ 回调事件 ]]----------------------------------
--领取单行

--关闭模块
function closeButtonCallback( tag, sender )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	closeLayer()
end

function closeLayer()
	colorLayer:removeFromParentAndCleanup(true)
	colorLayer = nil
end

function attack( p_copyInfo )
	ExpCopyService.doBattle()
end