-- Filename: ChooseCountDialog.lua
-- Author: llp
-- Date: 2015-12-25
-- Purpose: 选择红包数量小弹板

module("ChooseCountDialog" , package.seeall)

local kAddOneTag		= 10001
local kAddTenTag 		= 10002
local kSubOneTag		= 10003
local kSubTenTag		= 10004
local _maxUseNum 		= 0
local _curNumber 		= 1
local limitNum 			= 50 
local _priority  	 	= nil
local _bgSprite 		= nil
local _numberLabel		= nil
local _masklayer 		= nil

local function init()
	_maxUseNum 			= ActiveCache.getRedPacketMacCount()
	_curNumber 			= 1
	_priority  	 		= -600
	_bgSprite 			= nil
	_numberLabel		= nil
	_masklayer 			= nil
end

local function onTouchesHandlerMask( eventType, x, y )
	if (eventType == "began") then
		return true
	end
end

local function onNodeEventMask(event)
    if event == "enter" then
        _masklayer:registerScriptTouchHandler(onTouchesHandlerMask,false,_priority,true)
        _masklayer:setTouchEnabled(true)
    elseif eventType == "exit" then
        _masklayer:unregisterScriptTouchHandler()
    end
end

local function closeAction( ... )
	require "script/ui/redpacket/RedPacketController"
	RedPacketController.setEditBoxSize()
	_masklayer:removeFromParentAndCleanup(true)
end

local function sureAction( pTag,pItem )
	require "script/ui/redpacket/RedPacketController"
	RedPacketController.setEditBoxSize()
	RedPacketController.freshCount(_numberLabel:getString())
	closeAction()
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
	if(_curNumber > _maxUseNum)then
		_curNumber = _maxUseNum
	end
	-- 个数
	_numberLabel:setString(_curNumber)
end

function createDialog()
	init()

	_masklayer =  CCLayerColor:create(ccc4(11,11,11,166))
    _masklayer:registerScriptHandler(onNodeEventMask)

	_bgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _bgSprite:setContentSize(CCSizeMake(620,300))
    _bgSprite:setScale(MainScene.elementScale)
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_masklayer:getContentSize().width * 0.5,_masklayer:getContentSize().height * 0.5))
    _masklayer:addChild(_bgSprite)
   	--确定
   	local sureMenu = CCMenu:create()
   		  sureMenu:setTouchPriority(_priority-1)
   		  sureMenu:setPosition(ccp(0,0))
   	_bgSprite:addChild(sureMenu)
   	local sureMenuItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  sureMenuItem:setAnchorPoint(ccp(0.5,0))
		  sureMenuItem:setPosition(ccp(_bgSprite:getContentSize().width*0.5, sureMenuItem:getContentSize().height*0.5))
		  sureMenuItem:registerScriptTapHandler(sureAction)
	sureMenu:addChild(sureMenuItem)
	--关闭
	local closeMenu = CCMenu:create()
		  closeMenu:setTouchPriority(_priority-1)
		  closeMenu:setPosition(ccp(0,0))
	_bgSprite:addChild(closeMenu)
	local closeMenuItem = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
		  closeMenuItem:setAnchorPoint(ccp(1,1))
		  closeMenuItem:setPosition(ccp(_bgSprite:getContentSize().width+10, _bgSprite:getContentSize().height+15))
		  closeMenuItem:registerScriptTapHandler(closeAction)
	closeMenu:addChild(closeMenuItem)
	--(最多**个)数量读表
	local maxCountLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_273",_maxUseNum)..GetLocalizeStringBy("llp_274"),g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		  maxCountLabel:setAnchorPoint(ccp(0.5,0))
		  maxCountLabel:setPosition(ccp(_bgSprite:getContentSize().width*0.5,sureMenuItem:getPositionY()+sureMenuItem:getContentSize().height))
	_bgSprite:addChild(maxCountLabel)
	--中间行按钮和数字
	local operateMenu = CCMenu:create()
		  operateMenu:setTouchPriority(_priority-1)
		  operateMenu:setPosition(ccp(0,0))
	_bgSprite:addChild(operateMenu)
	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png", "images/shop/prop/btn_reduce10_h.png")
		  reduce10Btn:setPosition(ccp(14, maxCountLabel:getPositionY()+maxCountLabel:getContentSize().height))
	      reduce10Btn:registerScriptTapHandler(changeNumberAction)
	operateMenu:addChild(reduce10Btn, 1, kSubTenTag)

	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
		  reduce1Btn:setPosition(ccp(reduce10Btn:getPositionX()+reduce10Btn:getContentSize().width+10, maxCountLabel:getPositionY()+maxCountLabel:getContentSize().height))
		  reduce1Btn:registerScriptTapHandler(changeNumberAction)
	operateMenu:addChild(reduce1Btn, 1, kSubOneTag)

	-- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
		  numberBg:setContentSize(CCSizeMake(170, 65))
		  numberBg:setAnchorPoint(ccp(0.5, 0))
		  numberBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5, maxCountLabel:getPositionY()+maxCountLabel:getContentSize().height))
	_bgSprite:addChild(numberBg)
	-- 数量数字
	_numberLabel = CCLabelTTF:create("1", g_sFontPangWa, 36)
    _numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    _numberLabel:setAnchorPoint(ccp(0.5,0.5))
    _numberLabel:setPosition(ccp(numberBg:getContentSize().width*0.5, numberBg:getContentSize().height*0.5))
    numberBg:addChild(_numberLabel)

	-- +1
	local add1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png", "images/shop/prop/btn_addition_h.png")
		  add1Btn:setPosition(ccp(numberBg:getPositionX()+numberBg:getContentSize().width*0.5+15, maxCountLabel:getPositionY()+maxCountLabel:getContentSize().height))
		  add1Btn:registerScriptTapHandler(changeNumberAction)
	operateMenu:addChild(add1Btn, 1, kAddOneTag)

	-- +10
	local add10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png", "images/shop/prop/btn_addition10_h.png")
		  add10Btn:setPosition(ccp(add1Btn:getPositionX()+add1Btn:getContentSize().width+10, maxCountLabel:getPositionY()+maxCountLabel:getContentSize().height))
		  add10Btn:registerScriptTapHandler(changeNumberAction)
	operateMenu:addChild(add10Btn, 1, kAddTenTag)

	-- 请选择红包个数
	local pleaseChooseCountLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_275"),g_sFontPangWa,25)
		  pleaseChooseCountLabel:setAnchorPoint(ccp(0.5,0))
		  pleaseChooseCountLabelYPos = add10Btn:getPositionY()+add10Btn:getContentSize().height+pleaseChooseCountLabel:getContentSize().height*0.5
		  pleaseChooseCountLabel:setPosition(ccp(_bgSprite:getContentSize().width*0.5,pleaseChooseCountLabelYPos))
    	  pleaseChooseCountLabel:setColor(ccc3(0xc3, 0x1c, 0x00))
    _bgSprite:addChild(pleaseChooseCountLabel)
    return _masklayer
end