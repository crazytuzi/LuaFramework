-- Filename: HeroDestineyBuyLayer.lua
-- Author: zhangqiang
-- Date: 2016-05-16
-- Purpose: 批量购买天命副本攻打次数界面

module("HeroDestineyBuyLayer", package.seeall)
require "script/utils/BaseUI"

-------------- 模块常量 --------------
local kConfirmTag 		= 1001
local kCancelTag		= 1002
local kAddOneTag		= 10001
local kAddTenTag 		= 10002
local kSubOneTag		= 10003
local kSubTenTag		= 10004

local _zOrder 			= 1000 		-- 显示层级

-------------- 模块变量 --------------
local _bgLayer 		 	= nil -- 背景层
local _layerBg			= nil -- 背景图
local _numberLabel 		= nil -- 购买数量Lab
local _itemData			= nil -- 物品详细数据
local _curNumber 		= 1	  -- 当前数量
local _maxUseNum 		= 1	  -- 大能使用的个数
local _comfirmCallback	= nil -- 确定回调
local _fnGetTotalCost   = nil -- 计算总花费的回调
local _fnDidClose       = nil -- 界面已经关闭后的回调

--UI
local _lbGoldNum = nil        --总价
local _lbLeftMaxNum = nil     --剩余的最大购买次数
local _lbLeftMaxUnit = nil

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_bgLayer 		= nil
	_layerBg		= nil
	_numberLabel 	= nil
	_itemData		= nil
	_curNumber 		= 1
	_maxUseNum 		= 1

	_lbGoldNum     = nil
	_lbLeftMaxNum  = nil
	_lbLeftMaxUnit = nil
end

--[[
	@desc 	: 显示界面方法
	@param 	: pComfirmCallback 点击确定回调方法
	@param 	: pItemData 物品详细数据包括服务器和配置表数据
	@param 	: pMaxNum 最大能使用的个数
	@param  : pFnGetTotalCost   计算总花费的方法
	@return : 
--]]
function showDialog( pComfirmCallback, pItemData, pMaxNum, pFnGetTotalCost)
	init()

	-- 确定回调
	_comfirmCallback = pComfirmCallback

	--计算总花费的回调
	_fnGetTotalCost = pFnGetTotalCost

	-- 使用的物品数据
	_itemData = pItemData

	-- 可使用的个数
	_maxUseNum = tonumber(pMaxNum)
	--当最大次数为0时，当前购买次数默认显示成0
	if _maxUseNum > 0 then
		_curNumber = 1
	else
		_curNumber = 0
	end

	-- 创建背景
	local layer = createDialog()
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

--[[
	@desc 	: 背景层触摸回调
	@param 	: eventType 事件类型 x,y 触摸点
	@return : 
--]]
local function layerToucCallback( eventType, x, y )
	return true
end

--[[
	@desc 	: 回调onEnter和onExit事件
	@param 	: event 事件名
	@return : 
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,-431,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil

		--界面关闭后调用
		if _fnDidClose then
			_fnDidClose()
		end
	end
end

--[[
	@desc 	: 创建Dialog及UI
	@param 	: 
	@return : 
--]]
function createDialog()

	-- 背景层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 背景
	_layerBg = CCScale9Sprite:create("images/formation/changeformation/bg.png")
	_layerBg:setContentSize(CCSizeMake(610, 490))
	_layerBg:setAnchorPoint(ccp(0.5, 0.5))
	_layerBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(_layerBg)
	_layerBg:setScale(g_fScaleX)	

	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_layerBg:getContentSize().width/2, _layerBg:getContentSize().height*0.985))
	_layerBg:addChild(titleSp)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zq_0009"), g_sFontPangWa, 30)
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
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeBtnCallback)
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(_layerBg:getContentSize().width*0.97, _layerBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-432)
	_layerBg:addChild(menuBar)

	-- 确定按钮
	local comfirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	comfirmBtn:setAnchorPoint(ccp(0, 0))
	comfirmBtn:setPosition(ccp(125, 35	))
	comfirmBtn:registerScriptTapHandler(comfirmBtnCallback)
	menuBar:addChild(comfirmBtn, 1, kConfirmTag)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0, 0))
	cancelBtn:setPosition(ccp(350, 35))
	cancelBtn:registerScriptTapHandler(function ( ... )
	    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	    closeBtnCallback()
	end)
	menuBar:addChild(cancelBtn, 1, kCancelTag)

	-- 创建物品信息
	createItemInfo()

	return _bgLayer
end

--[[
	@desc 	: 创建物品信息UI
	@param 	: 
	@return : 
--]]
function createItemInfo()
	-- 物品信息背景
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(560, 330))
	innerBgSp:setAnchorPoint(ccp(0.5, 0))
	innerBgSp:setPosition(ccp(_layerBg:getContentSize().width*0.5, 110))
	_layerBg:addChild(innerBgSp)

	local innerSize = innerBgSp:getContentSize()
---- 准备数据
	-- 物品名字
	-- local itemName = _itemData.itemDesc.name

	-- 一共拥有
	local lbTopDesc = CCRenderLabel:create(GetLocalizeStringBy("zq_0008"), g_sFontPangWa, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    lbTopDesc:setColor(ccc3(255, 228, 0))
    lbTopDesc:setPosition(ccp( (innerSize.width-lbTopDesc:getContentSize().width)/2, 265) )
    innerBgSp:addChild(lbTopDesc)

---- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(-432)
	innerBgSp:addChild(changeNumBar)

	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png", "images/shop/prop/btn_reduce10_h.png")
	reduce10Btn:setPosition(ccp(4, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberCallback)
	changeNumBar:addChild(reduce10Btn, 1, kSubTenTag)

	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
	reduce1Btn:setPosition(ccp(123, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberCallback)
	changeNumBar:addChild(reduce1Btn, 1, kSubOneTag)

	-- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170, 65))
	numberBg:setAnchorPoint(ccp(0.5, 0))
	numberBg:setPosition(ccp(innerBgSp:getContentSize().width*0.5, 110))
	innerBgSp:addChild(numberBg)

	-- 数量数字
	_numberLabel = CCRenderLabel:create(tostring(_curNumber), g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    _numberLabel:setPosition(ccp( (numberBg:getContentSize().width - _numberLabel:getContentSize().width)/2, (numberBg:getContentSize().height + _numberLabel:getContentSize().height)/2) )
    numberBg:addChild(_numberLabel)

	-- +1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png", "images/shop/prop/btn_addition_h.png")
	reduce1Btn:setPosition(ccp(370, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberCallback)
	changeNumBar:addChild(reduce1Btn, 1, kAddOneTag)

	-- +10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png", "images/shop/prop/btn_addition10_h.png")
	reduce10Btn:setPosition(ccp(445, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberCallback)
	changeNumBar:addChild(reduce10Btn, 1, kAddTenTag)

 	--金币花费
 	local lbTotalDesc = CCRenderLabel:create(GetLocalizeStringBy("zq_0011"), g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_stroke)   --“总价”
 	lbTotalDesc:setColor(ccc3(255, 228, 0))
 	lbTotalDesc:setAnchorPoint(ccp(0, 0))
 	lbTotalDesc:setPosition(200, 42)
 	innerBgSp:addChild(lbTotalDesc, 1)

 	local imgGold = CCSprite:create("images/common/gold.png")
	imgGold:setAnchorPoint(ccp(0,0))
	imgGold:setPosition(ccp(lbTotalDesc:getPositionX() + lbTotalDesc:getContentSize().width + 5, 45))
	innerBgSp:addChild(imgGold)

	_lbGoldNum = CCRenderLabel:create("0", g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_stroke)
	_lbGoldNum:setColor(ccc3(255, 228, 0))
 	_lbGoldNum:setAnchorPoint(ccp(0, 0))
 	_lbGoldNum:setPosition(imgGold:getPositionX() + imgGold:getContentSize().width + 5, 42)
 	innerBgSp:addChild(_lbGoldNum, 1)

 	--今日还可购买次数
 	local lbLeftMaxDesc = CCRenderLabel:create(GetLocalizeStringBy("zq_0010", 0), g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_stroke)
 	lbLeftMaxDesc:setColor(ccc3(255, 228, 0))
 	lbLeftMaxDesc:setAnchorPoint(ccp(0, 0))
 	lbLeftMaxDesc:setPosition(150, 5)
 	innerBgSp:addChild(lbLeftMaxDesc, 1)

 	_lbLeftMaxNum = CCRenderLabel:create("0", g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_stroke)
 	_lbLeftMaxNum:setColor(ccc3(0, 255, 0))
 	_lbLeftMaxNum:setAnchorPoint(ccp(0, 0))
 	_lbLeftMaxNum:setPosition(lbLeftMaxDesc:getPositionX()+lbLeftMaxDesc:getContentSize().width+5, 5)
 	innerBgSp:addChild(_lbLeftMaxNum, 1)

 	--次
 	_lbLeftMaxUnit = CCRenderLabel:create(GetLocalizeStringBy("zq_0012", 0), g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_stroke)
 	_lbLeftMaxUnit:setColor(ccc3(255, 228, 0))
 	_lbLeftMaxUnit:setAnchorPoint(ccp(0, 0))
 	_lbLeftMaxUnit:setPosition(_lbLeftMaxNum:getPositionX()+_lbLeftMaxNum:getContentSize().width+5, 5)
 	innerBgSp:addChild(_lbLeftMaxUnit, 1)

 	--刷新
 	refreshTotalCost()
 	refreshLeftMaxNum()
end

function refreshTotalCost( ... )
	local nGoldCostNum = getTotalCost()

	if not tolua.isnull(_lbGoldNum) then
		_lbGoldNum:setString(tostring(nGoldCostNum))
	end
end

function refreshLeftMaxNum( ... )
	-- local nLeftMaxNum = _maxUseNum - _curNumber

	if not tolua.isnull(_lbLeftMaxNum) then
		_lbLeftMaxNum:setString(_maxUseNum)
	end

	--重新设置单位的位置
	if not tolua.isnull(_lbLeftMaxUnit) and not tolua.isnull(_lbLeftMaxNum) then
		_lbLeftMaxUnit:setPosition(_lbLeftMaxNum:getPositionX()+_lbLeftMaxNum:getContentSize().width+5, 5)
	end
end

--[[
	@desc 	: +/-按钮回调,改变兑换数量
	@param 	: pTag 按钮tag pItem 按钮
	@return : 
--]]
function changeNumberCallback( pTag, pItem )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if (pTag == kSubTenTag) then
		-- -10
		_curNumber = _curNumber - 10
	elseif(pTag == kSubOneTag) then
		-- -1
		_curNumber = _curNumber - 1 
	elseif(pTag == kAddOneTag) then
		-- +1
		_curNumber = _curNumber + 1 
	elseif(pTag == kAddTenTag) then
		-- +10
		_curNumber = _curNumber + 10 
	end
	if (_curNumber < 1) then
		_curNumber = 1
	end

	-- 上限
	if (_curNumber > _maxUseNum) then
		_curNumber = _maxUseNum
	end

	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp( (170 - _numberLabel:getContentSize().width)/2, (65 + _numberLabel:getContentSize().height)/2) )

	--刷新总花费
	refreshTotalCost()
end

--[[
	@desc 	: 获取总花费
	@param 	: 
	@return : 
--]]
function getTotalCost( ... )
	local nTotalCost = 0

	if _fnGetTotalCost ~= nil then
		local nCurNumber = tonumber(_curNumber or 0)
		nTotalCost = _fnGetTotalCost(nCurNumber)
	end
	nTotalCost = nTotalCost == nil and 0 or nTotalCost

	return nTotalCost
end

--[[
	@desc 	: 确定按钮回调,使用称号
	@param 	: 
	@return : 
--]]
function comfirmBtnCallback()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if _maxUseNum ~= nil and tonumber(_maxUseNum) <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("zq_0013"))
		return
	end

	-- 确认回调
	if (_comfirmCallback ~= nil) then
		_comfirmCallback(_curNumber, _maxUseNum)
	end

	-- 关闭界面
	closeBtnCallback()
end

--[[
	@desc 	: 关闭按钮回调,关闭界面
	@param 	: 
	@return : 
--]]
function closeBtnCallback()
	if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

----------回调注册-------------
--[[
	@desc 	: 界面关闭后调用
	@param 	: 
	@return : 
--]]
function registerDidCloseHandler( pFnDidClose )
	_fnDidClose = pFnDidClose
end
