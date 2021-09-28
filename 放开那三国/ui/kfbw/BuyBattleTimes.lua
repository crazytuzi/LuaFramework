-- FileName: BuyBattleTimes.lua 
-- Author: yangrui 
-- Date: 15-10-09
-- Purpose: function description of module 

module("BuyBattleTimes", package.seeall)

require "script/ui/item/ItemUtil"
require "script/utils/ItemDropUtil"
require "script/ui/item/ReceiveReward"
require "script/ui/bag/UseItemLayer"

------------------- 模块常量 --------------
local kConfirmTag 	   = 1001
local kCancelTag	   = 1002

local kAddOneTag	   = 10001
local kAddTenTag 	   = 10002
local kSubOneTag	   = 10003
local kSubTenTag	   = 10004

------------------- 模块变量 ---------------
local _bglayer                    = nil
local _layerBg                    = nil
local _numberLabel                = nil  -- 购买次数Label
local _totalPriceLabel            = nil  -- 总价
local _curNumber                  = 1    -- 当前需要购买次数
local _maxBuyNum                  = 1    -- 最大购买次数
local _onePrice                   = 0    -- 单价
local _canBuyNum                  = 0    -- 当前能购买的最大次数
local _totalPrice                 = 0    -- 总价

--[[
	@des    : 初始化
	@para   : 
	@return : 
 --]]
function init( ... )
	_bglayer                    = nil
	_layerBg                    = nil
	_numberLabel                = nil  -- 购买次数Label
	_totalPriceLabel            = nil  -- 总价
	_curNumber                  = 1    -- 当前需要购买次数
	_maxBuyNum                  = 1    -- 最大购买次数
	_onePrice                   = 0    -- 单价
	_canBuyNum                  = 0    -- 当前能购买的最大次数
	_totalPrice                 = 0    -- 总价
end

--[[
	@des    : 处理touches事件
	@para   : 
	@return : 
 --]]
function onTouchesHandler( eventType, x, y )
	return true
end

--[[
	@des    : 回调onEnter和onExit
	@para   : 
	@return : 
 --]]
function onNodeEvent( event )
	if ( event == "enter" ) then
		_bglayer:registerScriptTouchHandler(onTouchesHandler,false,-431,true)
		_bglayer:setTouchEnabled(true)
	elseif ( event == "exit" ) then
		_bglayer:unregisterScriptTouchHandler()
	end
end

--[[
	@des    : 关闭自己fangfa
	@para   : 
	@return : 
--]]
function closeFunc( ... )
	if ( _bglayer ) then
		_bglayer:removeFromParentAndCleanup(true)
		_bglayer = nil
	end
end

--[[
	@des    : 关闭自己
	@para   : 
	@return : 
--]]
function closeAction( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	closeFunc()
end 

--[[
	@des    : 按钮回调
	@para   : 
	@return : 
--]]
function btnFunc( tag, itemBtn )
	-- 按钮事件
	if ( tag == kConfirmTag) then
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		-- 判断是否有剩余购买次数
		if _canBuyNum == 0 then
			AnimationTip.showTip(GetLocalizeStringBy("key_10314"))
			return
		end
		-- 判断金币是否满足
		require "script/model/user/UserModel"
		if UserModel.getGoldNumber() < _totalPrice then
			require "script/ui/tip/LackGoldTip"
	    	LackGoldTip.showTip()
	    	return
	    end
		-- 关闭自己
		closeFunc()
		-- 网络请求
	    KuafuController.buyAtkNum(_curNumber,_totalPrice)
	else
		closeAction()
	end
end

--[[
	@des    : 改变兑换数量
	@para   : 
	@return : 
--]]
function changeNumberAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if ( tag == kSubTenTag ) then
		-- -10
		_curNumber = _curNumber-10
	elseif ( tag == kSubOneTag) then
		-- -1
		_curNumber = _curNumber-1 
	elseif ( tag == kAddOneTag ) then
		-- +1
		_curNumber = _curNumber+1 
	elseif ( tag == kAddTenTag ) then
		-- +10
		_curNumber = _curNumber+10 
	end
	-- 下限
	if ( _curNumber < 1 ) then
		_curNumber = 1
	end
	-- 上限
	if ( _curNumber <= 0 ) then
		_curNumber = 1
	end
	if ( _curNumber > _canBuyNum) then
		if _canBuyNum ~= 0 then
			_curNumber = _canBuyNum
		end
	end
	-- 总价
	_totalPrice = KuafuData.getTotalCostByBuyTimes(_curNumber)
	print("changeNumberAction===")
	print(_totalPrice)
	print(_curNumber)
	-- 如果金币不足只展示能购买的数量
	require "script/model/user/UserModel"
	local userHaveGoldNum = UserModel.getGoldNumber()
	if userHaveGoldNum < _totalPrice then
		_curNumber = KuafuData.getMaxBuyChallengeTimesByGoldNum(userHaveGoldNum)
		print("===|BuyBattleTimes|===")
		print(userHaveGoldNum,_curNumber)
    end
    if _curNumber <= 0 then
    	AnimationTip.showTip(GetLocalizeStringBy("key_10159"))
    	return
    end
	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp((170-_numberLabel:getContentSize().width)/2,(65+_numberLabel:getContentSize().height)/2))
	-- 总价
	_totalPrice = KuafuData.getTotalCostByBuyTimes(_curNumber)
	_totalPriceLabel:setString(_totalPrice)
end

--[[
	@des    : 创建二级UI
	@para   : 
	@return : 
--]]
function createInnerBg( ... )
	-- bg
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(560,330))
	innerBgSp:setAnchorPoint(ccp(0.5,0))
	innerBgSp:setPosition(ccp(_layerBg:getContentSize().width*0.5,110))
	_layerBg:addChild(innerBgSp)
	-- 内部size
	local innerSize = innerBgSp:getContentSize()
    -- 购买说明
    local buyDesc = CCRenderLabel:create(GetLocalizeStringBy("yr_2012"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
    buyDesc:setColor(ccc3(0xfe,0xdb,0x1c))
    buyDesc:setAnchorPoint(ccp(0.5,0.5))
    buyDesc:setPosition(ccp(innerBgSp:getContentSize().width*0.5,innerBgSp:getContentSize().height-40))
    innerBgSp:addChild(buyDesc)
    -- 购买提示
    local buyTipLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_2016"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
    buyTipLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    buyTipLabel:setAnchorPoint(ccp(0.5,0.5))
    buyTipLabel:setPosition(ccp(innerBgSp:getContentSize().width*0.5,innerBgSp:getContentSize().height-90))
    innerBgSp:addChild(buyTipLabel)
	-- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(-432)
	innerBgSp:addChild(changeNumBar)
	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png","images/shop/prop/btn_reduce10_h.png")
	reduce10Btn:setPosition(ccp(4,140))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn,1,kSubTenTag)
	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png","images/shop/prop/btn_reduce_h.png")
	reduce1Btn:setPosition(ccp(123,140))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn,1,kSubOneTag)
	-- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170,65))
	numberBg:setAnchorPoint(ccp(0.5,0))
	numberBg:setPosition(ccp(innerBgSp:getContentSize().width*0.5,140))
	innerBgSp:addChild(numberBg)
	-- 数量数字
	_numberLabel = CCRenderLabel:create("1",g_sFontPangWa,36,1,ccc3(0x49,0x00,0x00),type_stroke)
    _numberLabel:setColor(ccc3(0xff,0xff,0xff))
    _numberLabel:setPosition(ccp( (numberBg:getContentSize().width-_numberLabel:getContentSize().width)/2,(numberBg:getContentSize().height+_numberLabel:getContentSize().height)/2))
    numberBg:addChild(_numberLabel)
	-- +1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png","images/shop/prop/btn_addition_h.png")
	reduce1Btn:setPosition(ccp(370,140))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn,1,kAddOneTag)
	-- +10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png","images/shop/prop/btn_addition10_h.png")
	reduce10Btn:setPosition(ccp(449,140))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn,1,kAddTenTag)
    -- 总价
	local totalTipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1217"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
    totalTipLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    totalTipLabel:setAnchorPoint(ccp(0,0.5))
    innerBgSp:addChild(totalTipLabel)
    -- 金币Sp
    local goldSp = CCSprite:create("images/common/gold.png")
	goldSp:setAnchorPoint(ccp(0,0.5))
	innerBgSp:addChild(goldSp)
	-- 总价
	_totalPrice = KuafuData.getTotalCostByBuyTimes(_curNumber)
	print("===|_totalPrice|===", _totalPrice)
	_totalPriceLabel = CCLabelTTF:create(_totalPrice,g_sFontPangWa,30)
	_totalPriceLabel:setAnchorPoint(ccp(0,0.5))
    _totalPriceLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    innerBgSp:addChild(_totalPriceLabel)
    local posX = (innerBgSp:getContentSize().width-totalTipLabel:getContentSize().width-goldSp:getContentSize().width-_totalPriceLabel:getContentSize().width)/2
    totalTipLabel:setPosition(ccp(posX,90))
    goldSp:setPosition(ccp(totalTipLabel:getPositionX()+totalTipLabel:getContentSize().width,totalTipLabel:getPositionY()))
    _totalPriceLabel:setPosition(ccp(goldSp:getPositionX()+goldSp:getContentSize().width,totalTipLabel:getPositionY()))
    -- 提示
	local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_2014"),g_sFontPangWa,30,1,ccc3(0x49,0x00,0x00),type_stroke)
    tipLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    tipLabel:setAnchorPoint(ccp(0,0.5))
    innerBgSp:addChild(tipLabel)
    -- 还可购买XX次
	_canBuyNumLabel = CCLabelTTF:create(_canBuyNum .. GetLocalizeStringBy("yr_2015"),g_sFontPangWa,30)
	_canBuyNumLabel:setAnchorPoint(ccp(0,0.5))
    _canBuyNumLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    innerBgSp:addChild(_canBuyNumLabel)
    local posX = (innerBgSp:getContentSize().width-tipLabel:getContentSize().width-_canBuyNumLabel:getContentSize().width)/2
    tipLabel:setPosition(ccp(posX,40))
    _canBuyNumLabel:setPosition(ccp(tipLabel:getPositionX()+tipLabel:getContentSize().width,tipLabel:getPositionY()))
end

--[[
	@des    : 创建UI
	@para   : 
	@return : 
--]]
function createUI( ... )
	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer,1000)
	-- bg
	_layerBg = CCScale9Sprite:create("images/common/viewbg1.png")
	_layerBg:setContentSize(CCSizeMake(610,490))
	_layerBg:setAnchorPoint(ccp(0.5,0.5))
	_layerBg:setPosition(ccp(_bglayer:getContentSize().width*0.5,_bglayer:getContentSize().height*0.5))
	_layerBg:setScale(g_fScaleX)
	_bglayer:addChild(_layerBg)
	-- title bg
	local titleSp = CCSprite:create("images/common/viewtitle1.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_layerBg:getContentSize().width/2,_layerBg:getContentSize().height*0.985))
	_layerBg:addChild(titleSp)
	-- title
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_2013"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2,titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)
	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0,0))
	_layerBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-432)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png","images/common/btn_close_h.png",closeAction)
	closeBtn:setAnchorPoint(ccp(0.5,0.5))
    closeBtn:setPosition(ccp(_layerBg:getContentSize().width*0.97,_layerBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)
	-- 确定 取消bar
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-432)
	_layerBg:addChild(menuBar)
	-- 确定
	local comfirmBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(140,70),GetLocalizeStringBy("key_1985"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	comfirmBtn:setAnchorPoint(ccp(0,0))
	comfirmBtn:setPosition(ccp(125,30))
	comfirmBtn:registerScriptTapHandler(btnFunc)
	menuBar:addChild(comfirmBtn,1,kConfirmTag)
	-- 取消
	local cancelBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(140,70),GetLocalizeStringBy("key_1202"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	cancelBtn:setAnchorPoint(ccp(0,0))
	cancelBtn:setPosition(ccp(350,30))
	cancelBtn:registerScriptTapHandler(btnFunc)
	menuBar:addChild(cancelBtn,1,kCancelTag)
	-- 创建二级UI
	createInnerBg()
end 

--[[
	@des    : 创建购买挑战次数Layer
	@para   : 
	@return : 
--]]
function showBatchBuyLayer( ... )
	-- 初始化
	init()
	-- 最大购买次数
	_maxBuyNum = KuafuData.getBuyChallengeTimesLimit()
	-- 每次的价格
	_onePrice = KuafuData.getCurBuyChallengeTimesCost()
	-- 已购买的次数
	local haveBuyNum = KuafuData.getBuyAtkNum()
	-- 还可购买次数
	_canBuyNum = _maxBuyNum-haveBuyNum

	print("===|||===|||===")
	print(_maxBuyNum,_onePrice,haveBuyNum,_canBuyNum)
	-- 创建背景
	createUI()
end
