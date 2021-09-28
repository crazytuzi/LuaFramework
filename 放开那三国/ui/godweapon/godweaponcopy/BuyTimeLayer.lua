-- FileName: BuyTimeLayer.lua
-- Author: 	LLp
-- Date: 14-1-31
-- Purpose: 购买次数界面

module("BuyTimeLayer", package.seeall)

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
local _costArray = nil

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
	_maxNum = 1
	_costArray = nil
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
		local _cost = _costArray[_buyNum]
		if(tonumber(_cost) <= UserModel.getGoldNumber())then
			_callBack(_buyNum)
			closeAction()
		else
			require "script/ui/tip/LackGoldTip"
			LackGoldTip.showTip()
					--AnimationTip.showTip(GetLocalizeStringBy("key_1300") .. BagUtil.getNextOpenPropGridPrice() .. GetLocalizeStringBy("key_1911"))
		end
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

	if _buyNum > 50 then
		_buyNum = 50
	end

	-- 个数
	_numberLabel:setString(_buyNum)

	-- 总价
	-- for i = 1,_needInfoNum do
	-- 	local totalNum = tonumber(_needInfo[i].price)*_buyNum
	local cost = 0
	local _copyInfo = GodWeaponCopyData.getCopyInfo()
	for i=tonumber(_copyInfo.buy_num)+1,tonumber(_copyInfo.buy_num)+_buyNum do
		cost = cost+tonumber(_costArray[i])
	end

	tolua.cast(_innerBgSp:getChildByTag(1):getChildByTag(1),"CCRenderLabel"):setString(cost)
	-- end
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
    -- local nameLabel = CCRenderLabel:create(_itemName,g_sFontPangWa,30,1,ccc3(0x49,0x00,0x00),type_stroke)
    -- nameLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local tipLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("key_3113"),g_sFontName,24,1,ccc3(0x49,0x00,0x00),type_stroke)
    tipLabel_2:setColor(ccc3(0xff,0xff,0xff))

    local connectNode = BaseUI.createHorizontalNode({tipLabel_1,nameLabel,tipLabel_2})
    connectNode:setAnchorPoint(ccp(0.5,0))
    connectNode:setPosition(ccp(innerSize.width*0.5,innerSize.height - 70))
    _innerBgSp:addChild(connectNode)

	-- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(_touchPriority - 1)
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
	_numberLabel = CCRenderLabel:create(1,g_sFontPangWa,36,1,ccc3(0x49,0x00,0x00),type_stroke)
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
 		local yPos = 35 + 35
 		local needLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("llp_165"),g_sFontName,36,1,ccc3(0x49,0x00,0x00),type_stroke)
 		needLabel_1:setColor(ccc3(0xfe,0xdb,0x1c))
 		local itemSprite = CCSprite:create("images/common/gold.png")

 		-- local innerConnectNode = BaseUI.createHorizontalNode({needLabel_1,itemSprite})
 		-- innerConnectNode:setAnchorPoint(ccp(0,0))
 		-- innerConnectNode:setPosition(ccp(150,yPos))
 		-- _innerBgSp:addChild(innerConnectNode)
 		local totalPriceLabel = nil
 		local _copyInfo = GodWeaponCopyData.getCopyInfo()
 		if(tonumber(_copyInfo.buy_num)>1)then
 			totalPriceLabel = CCRenderLabel:create(_costArray[tonumber(tonumber(_copyInfo.buy_num)+1)],g_sFontName,36,1,ccc3(0x49,0x00,0x00),type_stroke)
 		else
 			totalPriceLabel = CCRenderLabel:create(_costArray[tonumber(1+tonumber(_copyInfo.buy_num))],g_sFontName,36,1,ccc3(0x49,0x00,0x00),type_stroke)
 		end

 		totalPriceLabel:setColor(ccc3(0xfe,0xdb,0x1c))
 		-- totalPriceLabel:setAnchorPoint(ccp(0,0))
 		-- totalPriceLabel:setPosition(ccp(350,yPos))
 		-- _innerBgSp:addChild(totalPriceLabel,1,i)

 		local innerConnectNode = BaseUI.createHorizontalNode({needLabel_1,itemSprite,totalPriceLabel})
 		innerConnectNode:setAnchorPoint(ccp(0.5,0))
 		innerConnectNode:setPosition(ccp(_innerBgSp:getContentSize().width*0.5,yPos))
 		_innerBgSp:addChild(innerConnectNode)
 		innerConnectNode:setTag(i)
 		totalPriceLabel:setTag(i)

 		local headLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_167"),g_sFontName,36,1,ccc3(0x49,0x00,0x00),type_stroke)
 		headLabel:setColor(ccc3(0xfe,0xdb,0x1c))


 		local count = table.count(_costArray)-tonumber(_copyInfo.buy_num)
 		local bodyLabel = CCRenderLabel:create(count,g_sFontName,36,1,ccc3(0x49,0x00,0x00),type_stroke)
 		bodyLabel:setColor(ccc3(0xfe,0xdb,0x1c))

 		local endLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_166"),g_sFontName,36,1,ccc3(0x49,0x00,0x00),type_stroke)
 		endLabel:setColor(ccc3(0xfe,0xdb,0x1c))

 		local innerConnectNodeDown = BaseUI.createHorizontalNode({headLabel,bodyLabel,endLabel})
 		innerConnectNodeDown:setAnchorPoint(ccp(0.5,0))
 		innerConnectNodeDown:setPosition(ccp(_innerBgSp:getContentSize().width*0.5,yPos-35))
 		_innerBgSp:addChild(innerConnectNodeDown)
 		innerConnectNodeDown:setTag(i+1)
 		bodyLabel:setTag(i+1)
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

function showBuyTimeLayer(p_param,p_callBack,p_touchPriority,p_zOrder,p_costArray)
	init()

	_titleName = p_param.title
	_firstString = p_param.first
	_maxNum = p_param.max
	_itemName = p_param.name
	_needInfo = p_param.need
	_callBack = p_callBack
	_costArray = p_costArray
	-- if _needInfo ~= nil then
	_needInfoNum = 1
	-- end
	-- local _copyInfo = GodWeaponCopyData.getCopyInfo()
	-- _buyNum = tonumber(_copyInfo.buy_num)
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