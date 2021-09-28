-- FileName: ShowRecourceLayer.lua
-- Author: shengyixian
-- Date: 2016-03-03
-- Purpose: 显示资源面板

module("ShowResourceLayer",package.seeall)

local _titleLabel = nil
local _touchPriority = nil
local _layer = nil
local _tableView = nil
local _data = nil
local _viewSp = nil
local _giftNum = nil
-- 滚动视图高度
local _viewHeight = nil

function init( ... )
	-- body
	_titleLabel = nil
	_layer = nil
	_tableView = nil
	_viewSp = nil
	_giftNum = nil
	_viewHeight = nil
end

function showLayer(data,touchPriority,zOrder)
	-- body
	init()
	_data = data or {}
	_giftNum =  table.count(data)
	_touchPriority = touchPriority or -555
	zOrder = zOrder or 999
	local layer = createLayer()
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(layer,zOrder)
end

function createLayer( ... )
	-- body
	_layer = CCLayerColor:create(ccc4(11,11,11,166))
	_layer:registerScriptHandler(onNodeEvent)
	initView()
    return _layer
end

function initView( ... )
	local mySize = nil
	if (_giftNum > 4) then
		_viewHeight = 140*math.ceil(_giftNum/4)
		mySize = CCSizeMake(620,438 + 130*math.floor(_giftNum/4))
	else
		_viewHeight = 140
		mySize = CCSizeMake(620,438)
	end
	local myScale = MainScene.elementScale
	--背景
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local bg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    bg:setContentSize(mySize)
    bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    bg:setAnchorPoint(ccp(0.5,0.5))
    _layer:addChild(bg)
    AdaptTool.setAdaptNode(bg)
    --"说明"标题
    local titleBg= CCSprite:create("images/common/viewtitle1.png")
    titleBg:setPosition(ccp(bg:getContentSize().width*0.5,bg:getContentSize().height -6))
    titleBg:setAnchorPoint(ccp(0.5, 0.5))
    bg:addChild(titleBg)
    _titleLabel = CCRenderLabel:create (GetLocalizeStringBy("syx_1112"), g_sFontPangWa, 35, 1 , ccc3(0,0,0),type_stroke)
    _titleLabel:setPosition(ccp(titleBg:getContentSize().width/2, titleBg:getContentSize().height/2))
    _titleLabel:setAnchorPoint(ccp(0.5, 0.5))
    _titleLabel:setColor(ccc3( 0xff, 0xe4, 0x00))
    titleBg:addChild(_titleLabel)
	local explainLabel = CCLabelTTF:create(GetLocalizeStringBy("syx_1113"),g_sFontPangWa,25)
	explainLabel:setColor(ccc3( 0x78, 0x25, 0x00))
	explainLabel:setAnchorPoint(ccp(0,0))
	explainLabel:setPosition(ccp(37,mySize.height - 115))
	bg:addChild(explainLabel)
	local fullRect_1 = CCRectMake(0,0,75,75)
	local insetRect_1 = CCRectMake(20,20,45,45)
	_viewSp = CCScale9Sprite:create("images/online/item_back.png",fullRect_1,insetRect_1)
	_viewSp:setPreferredSize(CCSizeMake(550,_viewHeight + 20))
	_viewSp:setPosition(ccp(mySize.width*0.5,mySize.height - 138))
	_viewSp:setAnchorPoint(ccp(0.5,1))
	bg:addChild(_viewSp)
	--按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority - 5)
    bg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)
	--确定按钮
    local makeSureButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    makeSureButton:setAnchorPoint(ccp(0.5, 0.5))
    makeSureButton:setPosition(ccp(mySize.width/2, 80))
    makeSureButton:registerScriptTapHandler(closeCb)
    menu:addChild(makeSureButton)
    --动画
    local array = CCArray:create()
    local scale1 = CCScaleTo:create(0.08,1.2*myScale)
    local fade = CCFadeIn:create(0.06)
    local spawn = CCSpawn:createWithTwoActions(scale1,fade)
    local scale2 = CCScaleTo:create(0.07,0.9*myScale)
    local scale3 = CCScaleTo:create(0.07,1*myScale)
    array:addObject(scale1)
    array:addObject(scale2)
    array:addObject(scale3)
    local seq = CCSequence:create(array)
    bg:runAction(seq)
    createScrollView(bg)
end

function createScrollView(bg)
	if _data == nil then return end
	local itemInfoSpite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
    local itemNode = CCNode:create()
    if _giftNum <= 4 then
        itemInfoSpite:setContentSize(CCSizeMake(540,140))
    else
        itemInfoSpite:setContentSize(CCSizeMake(540,280))
    end
    itemNode:setContentSize(itemInfoSpite:getContentSize())
	local scrollView = CCScrollView:create()
    scrollView:setContentSize(CCSizeMake(540,_viewHeight))
    scrollView:setViewSize(CCSizeMake(itemInfoSpite:getContentSize().width,itemInfoSpite:getContentSize().height - 10 ))
    scrollView:ignoreAnchorPointForPosition(false)
    scrollView:setAnchorPoint(ccp(0,1))        
    scrollView:setPosition(5,itemInfoSpite:getContentSize().height + 10)
    scrollView:setTouchPriority(_touchPriority)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setContentOffset(ccp(0,scrollView:getViewSize().height - scrollView:getContentSize().height))
    _viewSp:addChild(scrollView)
    scrollView:addChild(itemNode)
    itemNode:setAnchorPoint(ccp(0,1))
    itemNode:setPosition(0,scrollView:getContentSize().height) 

    local col = 4
    local row = math.floor(_giftNum / col)
    local temp = _giftNum - row * col
    if (_giftNum == 4) then 
    	row = 0
    	temp = _giftNum 
   	end
	if (_giftNum > 4) then
		for i=row,1 do
			for j=1,col do
				local reward = createReward(_data[(i - 1) * 4 + j])
				reward:setPosition(ccp(140 * (j - 1),130 * i))
				itemNode:addChild(reward)
			end
		end
	end

	if temp ~= 0 then
		for i=1,temp do
			local reward = createReward(_data[row * 4 + i])
			reward:setPosition(ccp(140 * (i - 1),0))
			itemNode:addChild(reward)
		end
	end
end

function createReward(data)
	local cell = CCTableViewCell:create()
	local icon = nil
	if data.type == "silver" then
		icon = ItemUtil.createGoodsIcon(data,_touchPriority - 1,1000,_touchPriority - 3,nil,nil,nil,nil,false)
		--数量文本
		local numLabel =  CCRenderLabel:create( GetLocalizeStringBy("yr_6000",data.num / 10000) , g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
		numLabel:setColor(ccc3( 0x00, 0xff, 0x18))
		numLabel:setAnchorPoint(ccp(1,0))
		numLabel:setPosition(ccp(icon:getContentSize().width,0))
		icon:addChild(numLabel)
	else
		icon = ItemUtil.createGoodsIcon(data,_touchPriority - 1,1000,_touchPriority - 3)
	end

	icon:setAnchorPoint(ccp(0.5,0.5))
	icon:setPosition(ccp(65,85))
	cell:addChild(icon)
	return cell
end

function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
	end
end

function onNodeEvent( event )
	if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority + 1, true)
		_layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function closeCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if _layer then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
	end
end

function setTitle(title)
	-- body
	_titleLabel:setString(title)
end