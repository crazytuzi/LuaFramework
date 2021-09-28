-- FileName: BuyBattleTimes.lua 
-- Author: yangrui 
-- Date: 15-10-09
-- Purpose: function description of module 

module("BlackshopChargeAlert", package.seeall)

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
local _bglayer         = nil
local _layerBg         = nil
local _numberLabel     = nil  -- 兑换次数Label
local _curNumber       = 1    -- 当前需要兑换次数
local _canBuyNum       = 0    -- 当前能兑换的最大次数
local _goodsID         = nil

--[[
	@des    : 初始化
	@para   : 
	@return : 
 --]]
function init( ... )
	_bglayer         = nil
	_layerBg         = nil
	_numberLabel     = nil  -- 兑换次数Label
	_curNumber       = 1    -- 当前需要兑换次数
	_canBuyNum       = 0    -- 当前能兑换的最大次数
	_goodsID         = nil
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
		-- 判断是否有剩余兑换次数
		if _canBuyNum == 0 then
			AnimationTip.showTip(GetLocalizeStringBy("key_10314"))
			return
		end
	    -- 所需物品数量是否满足
	    local isCan = BlackshopUtil.isCanConvert(_goodsID,_curNumber)
	    if(isCan == false) then
	        AnimationTip.showTip(GetLocalizeStringBy("yr_1011"))
	        return
	    end
		-- 关闭自己
		closeFunc()
	    -- 兑换网络请求
	    BlackshopController.exchangeBlackshop(_goodsID,_curNumber)  -- _curNumber 默认为1
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
	local result,canConvertNum = BlackshopUtil.isCanConvert(_goodsID,_curNumber)
	print("===||===",result,canConvertNum)
	if not result then
		_curNumber = canConvertNum
	end
    if _curNumber <= 0 then
    	_curNumber = 1
    end
	-- 个数
	_numberLabel:setString(_curNumber)
end

--[[
	@des    : 创建二级UI
	@para   : 
	@return : 
--]]
function createInnerBg( ... )
	-- bg
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(560,280))
	innerBgSp:setAnchorPoint(ccp(0.5,0))
	innerBgSp:setPosition(ccp(_layerBg:getContentSize().width*0.5,110))
	_layerBg:addChild(innerBgSp)
	-- 内部size
	local innerSize = innerBgSp:getContentSize()
    -- 兑换说明
    local buyDesc = CCRenderLabel:create(GetLocalizeStringBy("yr_1017"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
    buyDesc:setColor(ccc3(0xfe,0xdb,0x1c))
    buyDesc:setAnchorPoint(ccp(0.5,0.5))
    buyDesc:setPosition(ccp(innerBgSp:getContentSize().width*0.5,innerBgSp:getContentSize().height-40))
    innerBgSp:addChild(buyDesc)
	-- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(-432)
	innerBgSp:addChild(changeNumBar)
	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png","images/shop/prop/btn_reduce10_h.png")
	reduce10Btn:setPosition(ccp(4,120))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn,1,kSubTenTag)
	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png","images/shop/prop/btn_reduce_h.png")
	reduce1Btn:setPosition(ccp(123,120))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn,1,kSubOneTag)
	-- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170,65))
	numberBg:setAnchorPoint(ccp(0.5,0))
	numberBg:setPosition(ccp(innerBgSp:getContentSize().width*0.5,120))
	innerBgSp:addChild(numberBg)
	-- 数量数字
	_numberLabel = CCRenderLabel:create("1",g_sFontPangWa,36,1,ccc3(0x49,0x00,0x00),type_stroke)
    _numberLabel:setColor(ccc3(0xff,0xff,0xff))
    _numberLabel:setPosition(ccp( (numberBg:getContentSize().width-_numberLabel:getContentSize().width)/2,(numberBg:getContentSize().height+_numberLabel:getContentSize().height)/2))
    numberBg:addChild(_numberLabel)
	-- +1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png","images/shop/prop/btn_addition_h.png")
	reduce1Btn:setPosition(ccp(370,120))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn,1,kAddOneTag)
	-- +10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png","images/shop/prop/btn_addition10_h.png")
	reduce10Btn:setPosition(ccp(449,120))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn,1,kAddTenTag)
    -- 提示   剩余兑换XX次
	_canBuyNumLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_1014",_canBuyNum),g_sFontPangWa,30,1,ccc3(0x49,0x00,0x00),type_stroke)
    _canBuyNumLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    _canBuyNumLabel:setAnchorPoint(ccp(0.5,0.5))
    _canBuyNumLabel:setPosition(ccp(innerBgSp:getContentSize().width*0.5,60))
    innerBgSp:addChild(_canBuyNumLabel)
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
	_layerBg:setContentSize(CCSizeMake(610,440))
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
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_1016"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
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
	@des    : 创建兑换次数Layer
	@para   : 
	@return : 
--]]
function showConvertLayer( pId )
	-- 初始化
	init()
	_goodsID = pId
	-- 最大兑换次数
	local maxBuyNum = BlackshopData.getMaxConvertTimes(_goodsID)
	-- 已兑换的次数
	local haveBuyNum = BlackshopData.getConvertedTimes(_goodsID)
	-- 还可兑换次数
	_canBuyNum = maxBuyNum-haveBuyNum

	print("===|||===|||===")
	print(_maxBuyNum,haveBuyNum,_canBuyNum)
	-- 创建背景
	createUI()
end
