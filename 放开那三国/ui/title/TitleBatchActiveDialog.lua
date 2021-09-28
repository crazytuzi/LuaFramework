-- Filename: TitleBatchActiveDialog.lua
-- Author: lgx
-- Date: 2016-05-16
-- Purpose: 批量使用(激活)称号界面

module("TitleBatchActiveDialog", package.seeall)
require "script/utils/BaseUI"

-------------- 模块常量 --------------
local kConfirmTag 		= 1001
local kCancelTag		= 1002
local kAddOneTag		= 10001
local kAddTenTag 		= 10002
local kSubOneTag		= 10003
local kSubTenTag		= 10004

local _limitNum 		= 20 		-- 批量使用限制最大次数
local _zOrder 			= 1000 		-- 显示层级

-------------- 模块变量 --------------
local _bgLayer 		 	= nil -- 背景层
local _layerBg			= nil -- 背景图
local _numberLabel 		= nil -- 购买数量Lab
local _itemData			= nil -- 物品详细数据
local _curNumber 		= 1	  -- 当前数量
local _maxUseNum 		= 1	  -- 大能使用的个数
local _comfirmCallback	= nil -- 确定回调

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
end

--[[
	@desc 	: 显示界面方法
	@param 	: pComfirmCallback 点击确定回调方法
	@param 	: pItemData 物品详细数据包括服务器和配置表数据
	@param 	: pMaxNum 最大能使用的个数
	@return : 
--]]
function showDialog( pComfirmCallback, pItemData, pMaxNum )
	init()

	-- 确定回调
	_comfirmCallback = pComfirmCallback

	-- 使用的物品数据
	_itemData = pItemData

	-- 可使用的个数
	_maxUseNum = tonumber(pMaxNum)

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

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1910"), g_sFontPangWa, 30)
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
	cancelBtn:registerScriptTapHandler(closeBtnCallback)
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
	local itemName = _itemData.itemDesc.name

	-- 一共拥有
	local totalLael = CCRenderLabel:create(GetLocalizeStringBy("key_3204") .. _maxUseNum .. GetLocalizeStringBy("key_2557"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    totalLael:setColor(ccc3(0xff, 0xff, 0xff))
    totalLael:setPosition(ccp( (innerSize.width-totalLael:getContentSize().width)/2, 295) )
    innerBgSp:addChild(totalLael)

    -- 兑换提示
    local buyTipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("key_3181"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_1:setColor(ccc3(0xff, 0xff, 0xff))
    innerBgSp:addChild(buyTipLabel_1)

    -- 物品名称
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa, 30, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    nameLabel:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2, 250) )
    innerBgSp:addChild(nameLabel)
    buyTipLabel_1:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2 -buyTipLabel_1:getContentSize().width , 240) )

    -- 兑换提示2
    local buyTipLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("key_2518"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_2:setColor(ccc3(0xff, 0xff, 0xff))
    buyTipLabel_2:setPosition(ccp( innerSize.width/2 + nameLabel:getContentSize().width/2, 240) )
    innerBgSp:addChild(buyTipLabel_2)

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
	_numberLabel = CCRenderLabel:create("1", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
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

	-- 提示
	local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1066").._limitNum..GetLocalizeStringBy("key_2557"), g_sFontName, 35, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    tipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    tipLabel:setAnchorPoint(ccp(0.5,0))
    tipLabel:setPosition(ccp(innerBgSp:getContentSize().width*0.5, 32))
    innerBgSp:addChild(tipLabel)

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
	if (_maxUseNum > _limitNum) then
		if (_curNumber > _limitNum) then
			_curNumber = _limitNum
		end
	else
		if (_curNumber > _maxUseNum) then
			_curNumber = _maxUseNum
		end
	end
	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp( (170 - _numberLabel:getContentSize().width)/2, (65 + _numberLabel:getContentSize().height)/2) )
end

--[[
	@desc 	: 确定按钮回调,使用称号
	@param 	: 
	@return : 
--]]
function comfirmBtnCallback()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 确认回调
	if (_comfirmCallback ~= nil) then
		_comfirmCallback(_curNumber)
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
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end
