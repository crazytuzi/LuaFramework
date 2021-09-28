-- Filename: ChooseGoldDialog.lua
-- Author: llp
-- Date: 2015-12-25
-- Purpose: 选择红包金币数量小弹板

module("ChooseGoldDialog" , package.seeall)

local kAddTenTag		= 10001
local kAddHundredTag 	= 10002
local kAddThousandTag	= 10003
local _curNumber 		= 1
local limitNum 			= 500 
local _priority  	 	= nil
local _bgSprite 		= nil
local _numberLabel		= nil
local _masklayer 		= nil

local function init()
	_curNumber 			= ActiveCache.getRedPacketMinGold()
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
	RedPacketController.freshGoldCount(_numberLabel:getString())
	closeAction()
end

local function clearAction( ... )
	-- body
	_curNumber = tonumber(ActiveCache.getRedPacketMinGold())
	_numberLabel:setString(ActiveCache.getRedPacketMinGold())
end

-- 改变兑换数量
function changeNumberAction( tag, itemBtn )
	-- 音效
	local packetData = RedPacketData.getRedPacketData()
	maxUseNum = tonumber(packetData.canSendToday)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == kAddTenTag) then
		-- +10
		_curNumber = _curNumber + 10 
	elseif(tag == kAddHundredTag)then
		-- +100
		_curNumber = _curNumber + 100
	elseif(tag == kAddThousandTag)then
		-- +1000
		_curNumber = _curNumber + 1000
	end
	-- 上限
	if(_curNumber > maxUseNum)then
		_curNumber = maxUseNum
	end
	-- 个数
	_numberLabel:setString(_curNumber)
end

function createDialog()
	init()

	_masklayer =  CCLayerColor:create(ccc4(11,11,11,166))
    _masklayer:registerScriptHandler(onNodeEventMask)

	_bgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _bgSprite:setContentSize(CCSizeMake(620,450))
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
	--中间行按钮和数字
	local operateMenu = CCMenu:create()
		  operateMenu:setTouchPriority(_priority-1)
		  operateMenu:setPosition(ccp(0,0))
	_bgSprite:addChild(operateMenu)

	-- +10
	local tSprite = {normal="images/common/btn/anniu_red_btn_n.png",selected="images/common/btn/anniu_red_btn_h.png"}
    local tLabel = {text="+10",fontsize=30,color=ccc3(0xff,0xf6,0x00)}
	local add10Btn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
		  add10Btn:setAnchorPoint(ccp(0.5,0))
		  add10Btn:setPosition(ccp(_bgSprite:getContentSize().width*0.25, sureMenuItem:getPositionY()+sureMenuItem:getContentSize().height*1.5))
		  add10Btn:registerScriptTapHandler(changeNumberAction)
	operateMenu:addChild(add10Btn,1,kAddTenTag)
	-- +100
	local tSprite = {normal="images/common/btn/anniu_red_btn_n.png",selected="images/common/btn/anniu_red_btn_h.png"}
    local tLabel = {text="+100",fontsize=30,color=ccc3(0xff,0xf6,0x00)}
	local add100Btn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
		  add100Btn:setAnchorPoint(ccp(0.5,0))
		  add100Btn:setPosition(ccp(_bgSprite:getContentSize().width*0.5, sureMenuItem:getPositionY()+sureMenuItem:getContentSize().height*1.5))
		  add100Btn:registerScriptTapHandler(changeNumberAction)
	operateMenu:addChild(add100Btn,1,kAddHundredTag)
	-- +1000
	local tSprite = {normal="images/common/btn/anniu_red_btn_n.png",selected="images/common/btn/anniu_red_btn_h.png"}
    local tLabel = {text="+1000",fontsize=30,color=ccc3(0xff,0xf6,0x00)}
	local add1000Btn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
		  add1000Btn:setAnchorPoint(ccp(0.5,0))
		  add1000Btn:setPosition(ccp(_bgSprite:getContentSize().width*0.75, sureMenuItem:getPositionY()+sureMenuItem:getContentSize().height*1.5))
		  add1000Btn:registerScriptTapHandler(changeNumberAction)
	operateMenu:addChild(add1000Btn,1,kAddThousandTag)

	-- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
		  numberBg:setContentSize(CCSizeMake(170, 65))
		  numberBg:setAnchorPoint(ccp(0.5, 0))
		  numberBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5, add1000Btn:getPositionY()+add100Btn:getContentSize().height*1.5))
	_bgSprite:addChild(numberBg)
	-- 数量数字
	local minGoldNum = ActiveCache.getRedPacketMinGold()
	_numberLabel = CCLabelTTF:create(minGoldNum, g_sFontPangWa, 36)
    _numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    _numberLabel:setAnchorPoint(ccp(0.5,0.5))
    _numberLabel:setPosition(ccp(numberBg:getContentSize().width*0.5, numberBg:getContentSize().height*0.5))
    numberBg:addChild(_numberLabel)

    --清空
   	local clearMenu = CCMenu:create()
   		  clearMenu:setTouchPriority(_priority-1)
   		  clearMenu:setPosition(ccp(0,0))
   	_bgSprite:addChild(clearMenu)
   	local clearMenuItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("llp_276"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  clearMenuItem:setAnchorPoint(ccp(0,0))
		  clearMenuItem:setPosition(ccp(numberBg:getPositionX()+numberBg:getContentSize().width*0.5+clearMenuItem:getContentSize().width*0.5, numberBg:getPositionY()))
		  clearMenuItem:registerScriptTapHandler(clearAction)
	clearMenu:addChild(clearMenuItem)

	-- 请选择红包个数
	local pleaseChooseCountLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_277",minGoldNum)..GetLocalizeStringBy("llp_278"),g_sFontPangWa,25)
		  pleaseChooseCountLabel:setAnchorPoint(ccp(0.5,0))
		  pleaseChooseCountLabelYPos = clearMenuItem:getPositionY()+clearMenuItem:getContentSize().height+pleaseChooseCountLabel:getContentSize().height*0.5
		  pleaseChooseCountLabel:setPosition(ccp(_bgSprite:getContentSize().width*0.5,pleaseChooseCountLabelYPos))
    	  pleaseChooseCountLabel:setColor(ccc3(0xc3, 0x1c, 0x00))
    _bgSprite:addChild(pleaseChooseCountLabel)
    return _masklayer
end