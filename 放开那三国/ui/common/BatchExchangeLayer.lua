-- FileName: BatchExchangeLayer.lua 
-- Author: 	Zhang Zihang 
-- Date: 14-12-15
-- Purpose: 批量兑换界面

module("BatchExchangeLayer", package.seeall)

require "script/audio/AudioUtil"
require "script/utils/BaseUI"

local _bglayer
local _touchPriority
local _zOrder
local _layerBgSprite
local _titleName
local _firstString
local _maxNum
local _itemName
local _numberLabel
local _needInfo
local _needInfoNum
local _buyNum
local _callBack
local kSureTag = 10001
local kCancelTag = 10002
local kMinusTen = 20001
local kMinusOne = 20002
local kAddOne = 20003
local kAddTen = 20004
local _maxLimitNum --最大购买数量

function init()
	_bglayer = nil
	_touchPriority = nil
	_zOrder = nil
	_layerBgSprite = nil
	_titleName = nil
	_firstString = nil
	_maxNum = nil
	_itemName = nil
	_numberLabel = nil
	_callBack = nil
	_needInfoNum = 0
	_buyNum = 1
	_maxLimitNum = 0
end

function onTouchesHandler()
	return true
end

function onNodeEvent(p_event)
	if (p_event == "enter") then
		_bglayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bglayer:setTouchEnabled(true)
	elseif (p_event == "exit") then
		_bglayer:unregisterScriptTouchHandler()
	end
end

function closeAction()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bglayer:removeFromParentAndCleanup(true)
	_bglayer = nil
end

function buyAction(tag)
	if tag == kCancelTag then
		closeAction()
	else
		_callBack(_buyNum)
		closeAction()
	end
end

function changeNumberAction(tag)
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if tag == kMinusTen then
		-- -10
		_buyNum = _buyNum - 10
	elseif tag == kMinusOne then
		-- -1
		_buyNum = _buyNum - 1 
	elseif tag == kAddOne then
		-- +1
		_buyNum = _buyNum + 1 
	elseif tag == kAddTen then
		-- +10
		_buyNum = _buyNum + 10 
	end
	if _buyNum <= 0 then
		_buyNum = 1
	end
	if _buyNum >_maxNum then
		_buyNum = _maxNum
	end

	if _buyNum > _maxLimitNum then
		_buyNum = _maxLimitNum
	end

	-- 个数
	_numberLabel:setString(_buyNum)

	-- 总价
	for i = 1,_needInfoNum do
		local totalNum
		if _needInfo[i].minus ~= nil then
			totalNum = tonumber(_needInfo[i].price) - tonumber(_needInfo[i].minus)*_buyNum
		else
			totalNum = tonumber(_needInfo[i].price)*_buyNum
		end
		tolua.cast(_innerBgSp:getChildByTag(i),"CCRenderLabel"):setString(totalNum)
	end
end

function createInnerBg()
	-- 背景2
	local innerHeight = (_needInfoNum == 0) and 330 or (330 + (_needInfoNum - 1)*30)

	_innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_innerBgSp:setContentSize(CCSizeMake(560,innerHeight))
	_innerBgSp:setAnchorPoint(ccp(0.5,0))
	_innerBgSp:setPosition(ccp(_layerBgSprite:getContentSize().width*0.5,110))
	_layerBgSprite:addChild(_innerBgSp)

	local innerSize = _innerBgSp:getContentSize()

    local tipLabel_1 = CCRenderLabel:create(_firstString,g_sFontName,24,1,ccc3(0x49,0x00,0x00),type_stroke)
    tipLabel_1:setColor(ccc3(0xff,0xff,0xff))
    local nameLabel = CCRenderLabel:create(_itemName,g_sFontPangWa,30,1,ccc3(0x49,0x00,0x00),type_stroke)
    nameLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local tipLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("key_3113"),g_sFontName,24,1,ccc3(0x49,0x00,0x00),type_stroke)
    tipLabel_2:setColor(ccc3(0xff,0xff,0xff))

    local connectNode = BaseUI.createHorizontalNode({tipLabel_1,nameLabel,tipLabel_2})
    connectNode:setAnchorPoint(ccp(0.5,0))
    connectNode:setPosition(ccp(innerSize.width*0.5,innerSize.height - 70))
    _innerBgSp:addChild(connectNode)

	-- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(_touchPriority - 5)
	_innerBgSp:addChild(changeNumBar)

	local posY = innerSize.height - 190

	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png", "images/shop/prop/btn_reduce10_h.png")
	reduce10Btn:setPosition(ccp(4,posY))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn,1,kMinusTen)

	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
	reduce1Btn:setPosition(ccp(123,posY))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn,1,kMinusOne)

	--数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170,65))
	numberBg:setAnchorPoint(ccp(0.5,0))
	numberBg:setPosition(ccp(_innerBgSp:getContentSize().width*0.5,posY))
	_innerBgSp:addChild(numberBg)
	--数量数字
	_numberLabel = CCRenderLabel:create(_buyNum,g_sFontPangWa,36,1,ccc3(0x49,0x00,0x00),type_stroke)
	_numberLabel:setAnchorPoint(ccp(0.5,0.5))
    _numberLabel:setColor(ccc3(0xff,0xff,0xff))
    _numberLabel:setPosition(ccp(numberBg:getContentSize().width*0.5,numberBg:getContentSize().height*0.5))
    numberBg:addChild(_numberLabel)

	-- +1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png","images/shop/prop/btn_addition_h.png")
	reduce1Btn:setPosition(ccp(370,posY))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn,1,kAddOne)

	-- +10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png","images/shop/prop/btn_addition10_h.png")
	reduce10Btn:setPosition(ccp(445,posY))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn,1,kAddTen)

 	for i = 1,_needInfoNum do
 		local labelSize = _needInfo[i].size or 36
 		local posX_1 = _needInfo[i].x_1 or 150
 		local posX_2 = _needInfo[i].x_2 or 350
 		local yPos = 35 + 35*(i-1)
 		local needLabel_1 = CCRenderLabel:create(_needInfo[i].needName,g_sFontName,labelSize,1,ccc3(0x49,0x00,0x00),type_stroke)
 		local labelColor = _needInfo[i].color or ccc3(0xfe,0xdb,0x1c)
 		needLabel_1:setColor(labelColor)
 		local itemSprite = nil
 		if(_needInfo[i].sprite)then
 			itemSprite = CCSprite:create(_needInfo[i].sprite)
 		else
 			itemSprite = CCSprite:create()
 			itemSprite:setContentSize(CCSizeMake(0,0))
 		end

 		local innerConnectNode = BaseUI.createHorizontalNode({needLabel_1,itemSprite})
 		innerConnectNode:setAnchorPoint(ccp(0,0))
 		innerConnectNode:setPosition(ccp(posX_1,yPos))
 		_innerBgSp:addChild(innerConnectNode)

 		local priceString
 		if _needInfo[i].minus ~= nil then
 			priceString = _needInfo[i].price - _needInfo[i].minus
 		else
 			priceString = _needInfo[i].price
 		end

 		local totalPriceLabel = CCRenderLabel:create(priceString,g_sFontName,labelSize,1,ccc3(0x49,0x00,0x00),type_stroke)
 		totalPriceLabel:setColor(labelColor)
 		totalPriceLabel:setAnchorPoint(ccp(0,0))
 		totalPriceLabel:setPosition(ccp(posX_2,yPos))
 		_innerBgSp:addChild(totalPriceLabel,1,i)
 	end
end

function createBg( )
	local bgHeight = (_needInfoNum == 0) and 490 or (490 + (_needInfoNum - 1)*30)
	-- 背景
	_layerBgSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png")
	_layerBgSprite:setContentSize(CCSizeMake(610,bgHeight))
	_layerBgSprite:setAnchorPoint(ccp(0.5, 0.5))
	_layerBgSprite:setPosition(ccp(_bglayer:getContentSize().width*0.5,_bglayer:getContentSize().height*0.5))
	_layerBgSprite:setScale(g_fScaleX)	
	_bglayer:addChild(_layerBgSprite)

	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_layerBgSprite:getContentSize().width*0.5,_layerBgSprite:getContentSize().height*0.985))
	_layerBgSprite:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(_titleName,g_sFontPangWa,30)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width*0.5,titleSp:getContentSize().height*0.5))
	titleSp:addChild(titleLabel)

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0,0))
	closeMenuBar:setTouchPriority(_touchPriority - 1)
	_layerBgSprite:addChild(closeMenuBar)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png","images/common/btn_close_h.png",closeAction)
	closeBtn:setAnchorPoint(ccp(0.5,0.5))
    closeBtn:setPosition(ccp(_layerBgSprite:getContentSize().width*0.97, _layerBgSprite:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	buyMenuBar:setTouchPriority(_touchPriority - 1)
	_layerBgSprite:addChild(buyMenuBar)

	-- 按钮
	local comfirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(140,70),GetLocalizeStringBy("key_1985"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	comfirmBtn:setAnchorPoint(ccp(0,0))
	comfirmBtn:setPosition(ccp(125,35))
	comfirmBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(comfirmBtn,1,kSureTag)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(140,70),GetLocalizeStringBy("key_1202"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	cancelBtn:setAnchorPoint(ccp(0,0))
	cancelBtn:setPosition(ccp(350,35))
	cancelBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(cancelBtn,1,kCancelTag)
end 

function showBatchLayer(p_param,p_callBack,p_touchPriority,p_zOrder)
	init()
     print("show111111111")
	_titleName = p_param.title
	_firstString = p_param.first
	_maxNum = p_param.max
	_itemName = p_param.name
	_needInfo = p_param.need
	_maxLimitNum = p_param.maxLimit or 50
	_callBack = p_callBack

	if _needInfo ~= nil then
		_needInfoNum = #_needInfo
	end

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer,_zOrder)

	--创建背景
	createBg()
	--创建二级背景
	createInnerBg()
end