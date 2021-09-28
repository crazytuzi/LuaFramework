-- Filename: OpenRedPacketDialog.lua
-- Author: llp
-- Date: 2015-12-25
-- Purpose: 拆红包界面
require "script/ui/redpacket/RedPacketData"
module("OpenRedPacketDialog" , package.seeall)
local _masklayer 	 	= nil
local _dialogBgSprite	= nil
local _dialogHeadSprite = nil
local _lookMenuItemLabel= nil
local _openMenuItem		= nil
local _packetStatusLabel= nil
local _singlePacketData = nil
local _whetherHaveLabel = nil
local _haveRedPacket 	= true
local _isRob 			= false
local _packetStatus		= 1
local _priority 		= -550
local _isOpen 			= true
local openString		= {GetLocalizeStringBy("llp_280"),GetLocalizeStringBy("llp_281")}

local function init( ... )
	_masklayer 			= nil
	_dialogBgSprite		= nil
	_dialogHeadSprite 	= nil
	_lookMenuItemLabel	= nil
	_openMenuItem		= nil
	_packetStatusLabel	= nil
	_singlePacketData 	= nil
	_whetherHaveLabel 	= nil
	_isOpen 			= true
	_haveRedPacket 		= true
	_isRob 				= false
	_packetStatus		= 1
	_priority 			= -550
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

function afterClose( pInfo )
	RedPacketLayer.freshUI(pInfo)
end

local function closeAction( ... )
	require "script/ui/redpacket/RedPacketController"
	_masklayer:removeFromParentAndCleanup(true)
	RedPacketController.getInfo(afterClose,RedPacketData.getClickTag())
end

function afterCloseForOpen( pInfo )
	require "script/ui/redpacket/RedPocketInfoDialog"
	RedPocketInfoDialog.createDialog(pInfo,_isRob)
	_masklayer:removeFromParentAndCleanup(true)
end

function playEffect( pInfo )
	-- body
	_openMenuItem:setVisible(false)
	local effect = XMLSprite:create("images/redpacket/effect/chaihongbao")
	effect:setAnchorPoint(ccp(0.5,0.5))
	effect:setPosition(ccp(_openMenuItem:getPositionX(),_openMenuItem:getPositionY()))
	_dialogBgSprite:addChild(effect, 200)
	-- effect:setScale(g_fElementScaleRatio)
	effect:registerEndCallback(function ( ... )
		effect:removeFromParentAndCleanup(true)
		effect = nil
		afterCloseForOpen(pInfo)
	end)
end

local function closeForOpen(  )
	require "script/ui/redpacket/RedPacketController"
	if(_isOpen)then
		RedPacketController.getSingleRedPacketInfo(playEffect,_singlePacketData.eid)
	else
		RedPacketController.getSingleRedPacketInfo(afterCloseForOpen,_singlePacketData.eid)
	end
end

local function openAction( pTag,pItem )
	_isOpen = true
	local endtime = tonumber(_singlePacketData.sendTime) + tonumber(ActivityConfig.ConfigCache.envelope.data[1].time)
	local serverTime = tonumber(TimeUtil.getSvrTimeByOffset())
	if(serverTime>=endtime)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_312"))
		return
	end

	require "script/ui/redpacket/RedPacketController"
	_isRob = true
	local isHaveRob = RedPacketData.isHaveRob()
	if(isHaveRob)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_305"))
	else
		RedPacketController.openRedPacket(closeForOpen,_singlePacketData.eid)
	end
end

local function lookAction( ... )
	_isRob = false
	_isOpen = false
	closeForOpen()
end

--看看大家手气多少点击label
local function createLookPacketInfoLabel( ... )
	local lookMenu = CCMenu:create()
		  lookMenu:setPosition(ccp(0,0))
		  lookMenu:setTouchPriority(_priority-1)
	local label = CCRenderLabel:create(GetLocalizeStringBy("llp_302"),g_sFontName,28,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_lookMenuItemLabel = CCMenuItemLabel:create( label )
	_lookMenuItemLabel:setAnchorPoint(ccp(0.5,0))
	_lookMenuItemLabel:setPosition(ccp(_dialogBgSprite:getContentSize().width*0.5,_lookMenuItemLabel:getContentSize().height*2.5))
    _lookMenuItemLabel:registerScriptTapHandler(lookAction)
	lookMenu:addChild(_lookMenuItemLabel, 1, 1)
	_dialogBgSprite:addChild(lookMenu)
	return lookMenu
end

--抢红包按钮
local function createOpenPacketButton( ... )
	local openMenu = CCMenu:create()
		  openMenu:setPosition(ccp(0,0))
		  openMenu:setTouchPriority(_priority-1)
	_openMenuItem = CCMenuItemImage:create("images/redpacket/open.png", "images/redpacket/open.png")
	_openMenuItem:setAnchorPoint(ccp(0.5,0.5))
	_openMenuItem:setPosition(ccp(_dialogBgSprite:getContentSize().width*0.5,_lookMenuItemLabel:getPositionY()+_lookMenuItemLabel:getContentSize().height*2+_openMenuItem:getContentSize().height*0.5))
	_openMenuItem:registerScriptTapHandler(openAction)
	openMenu:addChild(_openMenuItem,1,1)
	_dialogBgSprite:addChild(openMenu)

	return openMenu
end

local function createPacketStatusLabel( ... )
	_packetStatusLabel = CCLabelTTF:create(openString[_packetStatus], g_sFontName, 25)
	_packetStatusLabel:setColor(ccc3(0xff,0xeb,0xa3))
	_packetStatusLabel:setAnchorPoint(ccp(0.5,0))
	_packetStatusLabel:setPosition(ccp(_dialogBgSprite:getContentSize().width*0.5,_openMenuItem:getPositionY()+_openMenuItem:getContentSize().height+_packetStatusLabel:getContentSize().height*3))
	_dialogBgSprite:addChild(_packetStatusLabel)
	return _packetStatusLabel
end

local function createGoodLuckLabel( ... )
	local goodLuckLabel = CCLabelTTF:create(_singlePacketData.msg, g_sFontName, 25)
	goodLuckLabel:setAnchorPoint(ccp(0.5,0))
	goodLuckLabel:setPosition(ccp(_dialogBgSprite:getContentSize().width*0.5,_openMenuItem:getPositionY()+_openMenuItem:getContentSize().height+_packetStatusLabel:getContentSize().height))
	_dialogBgSprite:addChild(goodLuckLabel)
	return goodLuckLabel
end

local function createWhetherGetPacketLable( ... )
	local str = ""
	if(_haveRedPacket)then
		str = _singlePacketData.uname
	else
		str = _singlePacketData.uname..GetLocalizeStringBy("llp_283")
	end
	_whetherHaveLabel = CCRenderLabel:create(str,g_sFontPangWa,40,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_whetherHaveLabel:setColor(ccc3(255,255,0))
	_whetherHaveLabel:setAnchorPoint(ccp(0.5,0))
	_whetherHaveLabel:setPosition(ccp(_dialogBgSprite:getContentSize().width*0.5,_packetStatusLabel:getPositionY()+_packetStatusLabel:getContentSize().height*2))
	_dialogBgSprite:addChild(_whetherHaveLabel)
	return _whetherHaveLabel
end

local function createCloseButton( ... )
	--关闭
	local closeMenu = CCMenu:create()
		  closeMenu:setTouchPriority(_priority-1)
		  closeMenu:setPosition(ccp(0,0))
	_dialogBgSprite:addChild(closeMenu)
	local closeMenuItem = LuaMenuItem.createItemImage("images/redpacket/close.png", "images/redpacket/close.png" )
		  closeMenuItem:setAnchorPoint(ccp(1,1))
		  closeMenuItem:setPosition(ccp(_dialogBgSprite:getContentSize().width-closeMenuItem:getContentSize().width, _dialogBgSprite:getContentSize().height-closeMenuItem:getContentSize().height))
		  closeMenuItem:registerScriptTapHandler(closeAction)
	closeMenu:addChild(closeMenuItem)
end

local function createHeadIcon( ... )
	local headIcon = nil
	if(table.isEmpty(_singlePacketData.dressInfo))then
		headIcon = HeroUtil.getHeroIconByHTID(tostring(_singlePacketData.htid))
	else
		headIcon = HeroUtil.getHeroIconByHTID(tostring(_singlePacketData.htid),_singlePacketData.dressInfo["1"])
	end
		  headIcon:setAnchorPoint(ccp(0.5,0))
		  headIcon:setPosition(ccp(_whetherHaveLabel:getPositionX(),_whetherHaveLabel:getPositionY()+_whetherHaveLabel:getContentSize().height))
	_dialogBgSprite:addChild(headIcon)
end

function createDialog( pInfo )
	_singlePacketData = pInfo

	_masklayer =  CCLayerColor:create(ccc4(11,11,11,166))
    _masklayer:registerScriptHandler(onNodeEventMask)
    require "script/ui/redpacket/RedPacketUtil"
    _haveRedPacket,_packetStatus = RedPacketUtil.weatherHaveRedPacket(tonumber(pInfo.leftNum))

	_dialogBgSprite = CCSprite:create("images/redpacket/redpacketbg.png")
	_dialogBgSprite:setAnchorPoint(ccp(0.5,0.5))
	_dialogBgSprite:setPosition(ccp(_masklayer:getContentSize().width*0.5,_masklayer:getContentSize().height*0.5))
	_dialogBgSprite:setScale(0)

	createLookPacketInfoLabel()
	createOpenPacketButton()
	createPacketStatusLabel()
	createWhetherGetPacketLable()
	createCloseButton()
	createHeadIcon()

	if(_haveRedPacket)then
		createGoodLuckLabel()
	end

	local actionArray = CCArray:create()
	      actionArray:addObject(CCScaleTo:create(0.2, g_fScaleX))
	      actionArray:addObject(CCDelayTime:create(0.2))
	      
	_masklayer:addChild(_dialogBgSprite)
	_dialogBgSprite:runAction(CCSequence:create(actionArray))
	_runningScene = CCDirector:sharedDirector():getRunningScene()
    _runningScene:addChild(_masklayer,999,343)
end