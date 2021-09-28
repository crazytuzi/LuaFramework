-- FileName: SelecteBuyCountLayer.lua
-- Author: bzx
-- Date: 14-6-22
-- Purpose: 选择购买的数量

module("SelecteBuyCountLayer", package.seeall)

require "script/ui/shop/ShopUtil"
require "script/ui/tip/AnimationTip"

local _bglayer 			= nil
local _goodsData 		= nil
local layerBg			= nil
local _numberLabel 		= nil
local _totalPriceLabel 	= nil
local _curNumber 		= 1
local _totalPrice 		= 0
local _args
local _touch_priority

local function init(args)
	_bglayer 			= nil
	layerBg				= nil
	_numberLabel 		= nil
	_totalPriceLabel 	= nil
	_curNumber 			= 1
	_totalPrice 		= 0
    _args = args
    _touch_priority = _args.touchPriority or -600
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bglayer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
		_bglayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bglayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
local function closeAction()
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bglayer:removeFromParentAndCleanup(true)
	_bglayer = nil
end 

-- 按钮响应
function buyAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    _args.buyCallFunc(_curNumber, _totalPrice)
end

-- 改变购买数量
function changeNumberAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == 10001) then
		-- -10
		_curNumber = _curNumber - 10
	elseif(tag == 10002) then
		-- -1
		_curNumber = _curNumber - 1 
	elseif(tag == 10003) then
		-- +1
		_curNumber = _curNumber + 1 
	elseif(tag == 10004) then
		-- +10
		_curNumber = _curNumber + 10 
	end
	if(_curNumber<=0)then
		_curNumber = 1
	end
    if _args.count_limit ~= nil then
        if(_curNumber > _args.count_limit) then
            _curNumber = _args.count_limit
        end
    end
    
	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp((170 - _numberLabel:getContentSize().width)/2, (65 + _numberLabel:getContentSize().height)/2) )
	-- 总价
    _totalPrice = _args.getTotalPriceByCount(_curNumber)
	_totalPriceLabel:setString(_totalPrice)
end

-- create 背景2
local function createInnerBg()
	-- 背景2
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(560, 330))
	innerBgSp:setAnchorPoint(ccp(0.5, 0))
	innerBgSp:setPosition(ccp(layerBg:getContentSize().width*0.5, 110))
	layerBg:addChild(innerBgSp)
	local innerSize = innerBgSp:getContentSize()
    local tips = {}
    -- 购买提示
    tips[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2853"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    tips[1]:setColor(ccc3(0xff, 0xff, 0xff))

    -- 物品名称
    tips[2] = CCRenderLabel:create(_args.item_name, g_sFontPangWa, 30, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    tips[2]:setColor(ccc3(0xfe, 0xdb, 0x1c))
    -- 购买提示2
    local text = GetLocalizeStringBy("key_2518")
    if _args.remain_count ~= nil then
        text = text .. string.format(GetLocalizeStringBy("key_8156"), _args.remain_count)
    end
    tips[3] = CCRenderLabel:create(text, g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    tips[3] :setColor(ccc3(0xff, 0xff, 0xff))
    require "script/utils/BaseUI"
    local tip_node = BaseUI.createHorizontalNode(tips)
    tips[2]:setPositionY(25)
    innerBgSp:addChild(tip_node)
    tip_node:setAnchorPoint(ccp(0.5, 0.5))
    tip_node:setPosition(ccp(innerSize.width * 0.5, 240))

---- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(_touch_priority - 1)
	innerBgSp:addChild(changeNumBar)

	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png", "images/shop/prop/btn_reduce10_h.png")
	reduce10Btn:setPosition(ccp(4, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, 10001)

	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
	reduce1Btn:setPosition(ccp(123, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, 10002)

	-- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170, 65))
	numberBg:setAnchorPoint(ccp(0.5, 0))
	numberBg:setPosition(ccp(innerBgSp:getContentSize().width*0.5, 110))
	innerBgSp:addChild(numberBg)
	-- 数量数字
	_numberLabel = CCRenderLabel:create("1", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    _numberLabel:setPosition(ccp( (numberBg:getContentSize().width - _numberLabel:getContentSize().width)/2, (numberBg:getContentSize().height + _numberLabel:getContentSize().height)/2) )
    numberBg:addChild(_numberLabel)

	-- +1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png", "images/shop/prop/btn_addition_h.png")
	reduce1Btn:setPosition(ccp(370, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, 10003)

	-- +10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png", "images/shop/prop/btn_addition10_h.png")
	reduce10Btn:setPosition(ccp(445, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, 10004)

	-- 总价
	local totalTipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1217"), g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    totalTipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    totalTipLabel:setPosition(ccp(190, 72) )
    innerBgSp:addChild(totalTipLabel)
    local goldSp_2 = CCSprite:create("images/common/gold.png")
	goldSp_2:setAnchorPoint(ccp(0,0))
	goldSp_2:setPosition(ccp(280, 35))
	innerBgSp:addChild(goldSp_2)
	
    _totalPrice = _args.getTotalPriceByCount(1)
	_totalPriceLabel = CCRenderLabel:create(_totalPrice, g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _totalPriceLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    _totalPriceLabel:setPosition(ccp(310, 70) )
    innerBgSp:addChild(_totalPriceLabel)


    -- 提示
    if _args.is_increase  == true then
    	local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1651"), g_sFontName, 25)
		tipLabel:setColor(ccc3(0xff, 0xe4, 0x00))
		tipLabel:setAnchorPoint(ccp(0.5, 0.5))
		tipLabel:setPosition(ccp(270, 30))
		innerBgSp:addChild(tipLabel)

		totalTipLabel:setPosition(ccp(190, 92) )
		goldSp_2:setPosition(ccp(280, 55))
		_totalPriceLabel:setPosition(ccp(310, 90) )
    end
end

-- create
function create( )
	-- 背景
	layerBg = CCScale9Sprite:create("images/formation/changeformation/bg.png")
	layerBg:setContentSize(CCSizeMake(610, 490))
	layerBg:setAnchorPoint(ccp(0.5, 0.5))
	layerBg:setPosition(ccp(_bglayer:getContentSize().width*0.5, _bglayer:getContentSize().height*0.5))
	_bglayer:addChild(layerBg)
	layerBg:setScale(g_fScaleX)	

	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(layerBg:getContentSize().width/2, layerBg:getContentSize().height*0.985))
	layerBg:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(_args.title, g_sFontPangWa, 30)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	layerBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(_touch_priority - 1)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(layerBg:getContentSize().width*0.97, layerBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	buyMenuBar:setTouchPriority(_touch_priority - 1)
	layerBg:addChild(buyMenuBar)

	-- 按钮
	local comfirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	comfirmBtn:setAnchorPoint(ccp(0, 0))
	comfirmBtn:setPosition(ccp(125, 35	))
	comfirmBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(comfirmBtn, 1, 10001)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0, 0))
	cancelBtn:setPosition(ccp(350, 35))
	cancelBtn:registerScriptTapHandler(closeAction)
	buyMenuBar:addChild(cancelBtn, 1, 10002)

end 

-- showPurchaseLayer
function show(args)
	init(args)
	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
    create()
	createInnerBg()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer, 1999)
end


function close()
    _bglayer:removeFromParentAndCleanup(true)
end