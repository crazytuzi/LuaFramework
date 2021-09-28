-- FileName: BuyMatchNum.lua 
-- Author: licong 
-- Date: 14-6-18 
-- Purpose: function description of module 


module("BuyMatchNum", package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemUtil"
require "script/utils/ItemDropUtil"
require "script/ui/item/ReceiveReward"
require "script/ui/bag/UseItemLayer"

------------------- 模块常量 --------------
local kConfirmTag 		= 1001
local kCancelTag		= 1002
local kAddOneTag		= 10001
local kAddTenTag 		= 10002
local kSubOneTag		= 10003
local kSubTenTag		= 10004

------------------- 模块变量 ---------------
local _bglayer 			= nil				
local _layerBg			= nil
local _numberLabel 		= nil			
local _totalPriceLabel  = nil
local _curNumber 		= 1
local _maxBuyNum 		= 1 
local _onePrice		    = 0
local _canBuyNum 		= 0
local _totalPrice 		= 0
local _matchPlace  		= nil

-- 初始化
local function init( )
	_bglayer 			= nil
	_layerBg			= nil
	_numberLabel 		= nil
	_curNumber 			= 1
	_maxBuyNum 			= 1
	_onePrice		    = 0
	_canBuyNum 			= 0
	_totalPrice 		= 0
	_totalPriceLabel    = nil
	_matchPlace  		= nil
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	return true
end

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bglayer:registerScriptTouchHandler(onTouchesHandler, false, -431, true)
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
	if(_bglayer)then
		_bglayer:removeFromParentAndCleanup(true)
		_bglayer = nil
	end
end 

-- 购买回调
local function useCallback()
	-- 扣除金币
	UserModel.addGoldNumber(-_totalPrice)
	-- 增加购买次数
	MatchData.addBuyNum(_curNumber)
	-- 刷新金币
	MatchLayer.refreshMatchGold()
	if(_matchPlace == "MatchPlace")then
		-- 刷新比武次数
		MatchPlace.refreshMatchNum()
	elseif(_matchPlace == "RestTimeLayer")then
		-- 刷新比武次数
		RestTimeLayer.refreshMatchNum()
	else
		print("on mark")
	end
	
end


-- 按钮响应
local function useAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/model/user/UserModel"
	if UserModel.getGoldNumber() < _totalPrice then
		-- 金币不足
		require "script/ui/tip/LackGoldTip"
    	LackGoldTip.showTip()
    	return
    end
	-- 按钮事件
	if(tag == kConfirmTag) then
		-- 关闭自己
		closeAction()
		-- 发请求
		MatchService.buyCompeteNum(_curNumber,useCallback)
	else
		closeAction()
	end
end

-- 改变兑换数量
function changeNumberAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == kSubTenTag) then
		-- -10
		_curNumber = _curNumber - 10
	elseif(tag == kSubOneTag) then
		-- -1
		_curNumber = _curNumber - 1 
	elseif(tag == kAddOneTag) then
		-- +1
		_curNumber = _curNumber + 1 
	elseif(tag == kAddTenTag) then
		-- +10
		_curNumber = _curNumber + 10 
	end
	if(_curNumber < 1)then
		_curNumber = 1
	end
	-- 上限
	if(_curNumber<=0)then
		_curNumber = 1
	end
	if(_curNumber>_canBuyNum) then
		_curNumber = _canBuyNum
	end

	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp( (170 - _numberLabel:getContentSize().width)/2, (65 + _numberLabel:getContentSize().height)/2) )

	-- 总价
	_totalPrice = _onePrice * _curNumber
	_totalPriceLabel:setString(_totalPrice)

end

-- create 背景2
local function createInnerBg()
	-- 背景2
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(560, 330))
	innerBgSp:setAnchorPoint(ccp(0.5, 0))
	innerBgSp:setPosition(ccp(_layerBg:getContentSize().width*0.5, 110))
	_layerBg:addChild(innerBgSp)

	local innerSize = innerBgSp:getContentSize()
    -- 购买提示
    local buyTipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1076"), g_sFontPangWa, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    buyTipLabel_1:setColor(ccc3(0xfe, 0xdb, 0x1c))
    buyTipLabel_1:setAnchorPoint(ccp(0.5,0.5))
    buyTipLabel_1:setPosition(ccp(innerBgSp:getContentSize().width*0.5,innerBgSp:getContentSize().height-60))
    innerBgSp:addChild(buyTipLabel_1)

---- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(-432)
	innerBgSp:addChild(changeNumBar)

	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png", "images/shop/prop/btn_reduce10_h.png")
	reduce10Btn:setPosition(ccp(4, 140))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, kSubTenTag)

	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
	reduce1Btn:setPosition(ccp(123, 140))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, kSubOneTag)

	-- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170, 65))
	numberBg:setAnchorPoint(ccp(0.5, 0))
	numberBg:setPosition(ccp(innerBgSp:getContentSize().width*0.5, 140))
	innerBgSp:addChild(numberBg)
	-- 数量数字
	_numberLabel = CCRenderLabel:create("1", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    _numberLabel:setPosition(ccp( (numberBg:getContentSize().width - _numberLabel:getContentSize().width)/2, (numberBg:getContentSize().height + _numberLabel:getContentSize().height)/2) )
    numberBg:addChild(_numberLabel)

	-- +1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png", "images/shop/prop/btn_addition_h.png")
	reduce1Btn:setPosition(ccp(370, 140))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, kAddOneTag)

	-- +10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png", "images/shop/prop/btn_addition10_h.png")
	reduce10Btn:setPosition(ccp(445, 140))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, kAddTenTag)

    -- 总价
	local totalTipLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1081"), g_sFontPangWa, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    totalTipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    totalTipLabel:setAnchorPoint(ccp(0,0.5))
    innerBgSp:addChild(totalTipLabel)

    local goldSp_2 = CCSprite:create("images/common/gold.png")
	goldSp_2:setAnchorPoint(ccp(0,0.5))
	innerBgSp:addChild(goldSp_2)

	_totalPrice = _curNumber * _onePrice
	_totalPriceLabel = CCLabelTTF:create(_totalPrice, g_sFontPangWa, 30 )
	_totalPriceLabel:setAnchorPoint(ccp(0,0.5))
    _totalPriceLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    innerBgSp:addChild(_totalPriceLabel)

    local posX = (innerBgSp:getContentSize().width-totalTipLabel:getContentSize().width-goldSp_2:getContentSize().width-_totalPriceLabel:getContentSize().width)/2
    totalTipLabel:setPosition(ccp(posX,90))
    goldSp_2:setPosition(ccp(totalTipLabel:getPositionX()+totalTipLabel:getContentSize().width,totalTipLabel:getPositionY()))
    _totalPriceLabel:setPosition(ccp(goldSp_2:getPositionX()+goldSp_2:getContentSize().width,totalTipLabel:getPositionY()))

    -- 提示
	local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1079"), g_sFontPangWa, 30, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    tipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    tipLabel:setAnchorPoint(ccp(0,0.5))
    innerBgSp:addChild(tipLabel)

	_canBuyNumLabel = CCLabelTTF:create(_canBuyNum .. GetLocalizeStringBy("lic_1086"), g_sFontPangWa, 30 )
	_canBuyNumLabel:setAnchorPoint(ccp(0,0.5))
    _canBuyNumLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    innerBgSp:addChild(_canBuyNumLabel)
    
    local posX = (innerBgSp:getContentSize().width-tipLabel:getContentSize().width-_canBuyNumLabel:getContentSize().width)/2
    tipLabel:setPosition(ccp(posX,40))
    _canBuyNumLabel:setPosition(ccp(tipLabel:getPositionX()+tipLabel:getContentSize().width,tipLabel:getPositionY()))

end

local function initBatchUseLayer( )
	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer, 1000)
	-- 背景
	_layerBg = CCScale9Sprite:create("images/formation/changeformation/bg.png")
	_layerBg:setContentSize(CCSizeMake(610, 490))
	_layerBg:setAnchorPoint(ccp(0.5, 0.5))
	_layerBg:setPosition(ccp(_bglayer:getContentSize().width*0.5, _bglayer:getContentSize().height*0.5))
	_bglayer:addChild(_layerBg)
	_layerBg:setScale(g_fScaleX)	

	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_layerBg:getContentSize().width/2, _layerBg:getContentSize().height*0.985))
	_layerBg:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1080"), g_sFontPangWa, 30)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	_layerBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-432)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(_layerBg:getContentSize().width*0.97, _layerBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-432)
	_layerBg:addChild(menuBar)

	-- 按钮
	local comfirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	comfirmBtn:setAnchorPoint(ccp(0, 0))
	comfirmBtn:setPosition(ccp(125, 35	))
	comfirmBtn:registerScriptTapHandler(useAction)
	menuBar:addChild(comfirmBtn, 1, kConfirmTag)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0, 0))
	cancelBtn:setPosition(ccp(350, 35))
	cancelBtn:registerScriptTapHandler(useAction)
	menuBar:addChild(cancelBtn, 1, kCancelTag)

	-- 创建二级背景
	createInnerBg()
end 


-- 参数
-- p_mark 	 入口标记 文件名 "MatchPlace" or "RestTimeLayer"
function showBatchUseLayer( p_mark )
	init()
	-- 入口标记
	_matchPlace = p_mark
	-- 最大购买次数，每次的价格
	_maxBuyNum,_onePrice = MatchData.getCanBuyMaxNum()
	-- 已购买的次数
	local haveBuyNum = MatchData.getBuyNum()
	-- 还可购买次数
	_canBuyNum = _maxBuyNum - haveBuyNum
	-- 创建背景
	initBatchUseLayer()
end


