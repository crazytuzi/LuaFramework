-- Filename: RedPocketInfoDialog.lua
-- Author: llp
-- Date: 2015-12-25
-- Purpose: 红包信息界面

module("RedPocketInfoDialog" , package.seeall)

local _masklayer 		= nil
local _dialogBgSprite 	= nil
local _packetView		= nil
local _packetData 		= nil
local _headSprite 		= nil
local _headIcon 		= nil
local _scaleBgSprite 	= nil
local _goldLabel 		= nil
local _touch_priority 	= -600
local _bestLuckIndex 	= 1
local _isRob 			= true
local isHaveRob 	    = false

function init()
	_masklayer 			= nil
	_dialogBgSprite 	= nil
	_packetView			= nil
	_packetData 		= nil
	_headSprite 		= nil
	_headIcon 			= nil
	_scaleBgSprite 		= nil
	_goldLabel 			= nil
	_touch_priority 	= -600
	_bestLuckIndex 		= 1
	_isRob 				= true
	isHaveRob 	    	= false
end

local function onTouchesHandlerMask( eventType, x, y )
	if (eventType == "began") then
		return true
	end
end

local function onNodeEventMask(event)
    if event == "enter" then
        _masklayer:registerScriptTouchHandler(onTouchesHandlerMask,false,_touch_priority,true)
        _masklayer:setTouchEnabled(true)
    elseif eventType == "exit" then
        _masklayer:unregisterScriptTouchHandler()
    end
end

function afterRemove( pInfo )
	RedPacketLayer.freshUI(pInfo)
	_masklayer:removeFromParentAndCleanup(true)
end

local function closeAction( ... )
	require "script/ui/redpacket/RedPacketController"
	RedPacketController.setEditBoxSize()
	RedPacketController.getInfo(afterRemove,RedPacketData.getClickTag())
end

local function createHeadIcon( pInfo )
	local headIcon = nil
	if(table.isEmpty(pInfo.dressInfo))then
		headIcon = HeroUtil.getHeroIconByHTID(tostring(pInfo.htid))
	else
		headIcon = HeroUtil.getHeroIconByHTID(tostring(pInfo.htid),pInfo.dressInfo["1"])
	end
		headIcon:setAnchorPoint(ccp(0,0))
		headIcon:setPosition(ccp(0,0))
	return headIcon
end

local function createLabel( pInfo,pIndex )
	-- body
	local isBestLuck = false

	local headIcon = createHeadIcon(pInfo)
	local packetLabel = CCRenderLabel:create(pInfo.uname,g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		  packetLabel:setColor(ccc3(255,255,0))
		  packetLabel:setAnchorPoint(ccp(0,0.5))
		  packetLabel:setPosition(ccp(headIcon:getContentSize().width+20,headIcon:getContentSize().height*0.5))
	headIcon:addChild(packetLabel)
	local goldLabel = CCRenderLabel:create(pInfo.gold..GetLocalizeStringBy("lic_1508"),g_sFontName,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		  goldLabel:setAnchorPoint(ccp(1,0.5))
		  goldLabel:setPosition(ccp(615,headIcon:getContentSize().height*0.5))
	headIcon:addChild(goldLabel)
	if(tonumber(_packetData.leftNum)==0 and pIndex==_bestLuckIndex)then
		local bestLuckSprite = CCSprite:create("images/redpacket/bestluck.png")
		  	  bestLuckSprite:setAnchorPoint(ccp(1,0.5))
		  	  bestLuckSprite:setPosition(ccp(-20,goldLabel:getContentSize().height*0.5))
		goldLabel:addChild(bestLuckSprite)
	else
		print("未产生运气最佳")
	end
	local lineSprite = CCSprite:create("images/chat/line.png")
		  lineSprite:setScaleX(2)
		  lineSprite:setAnchorPoint(ccp(0.5,0))
		  lineSprite:setPosition(ccp(320,-20))
	headIcon:addChild(lineSprite)

	return headIcon
end

local function createPacketView( ... )
	for i,v in ipairs(_packetData.rankList) do
		if(tonumber(_packetData.rankList[_bestLuckIndex].gold)<=tonumber(v.gold))then
			_bestLuckIndex = i
		end
	end
	local cell_size = CCSizeMake(640,125*g_fScaleX)
	h = LuaEventHandler:create(function(function_name, table_t, a1, cell)
		if function_name == "cellSize" then
			return cell_size
		elseif function_name == "cellAtIndex" then
			cell = CCTableViewCell:create()
			cell:setScale(g_fScaleX)
			local packetInfoLabel = createLabel(_packetData.rankList[a1+1],a1+1)
			cell:addChild(packetInfoLabel)
			return cell
		elseif function_name == "numberOfCells" then
			local x = table.count(_packetData.rankList)
			return x
		elseif function_name == "cellTouched" then
			print("a1=====", a1:getIdx())
		elseif (function_name == "scroll") then
		end
	end)
	local masklayerHeight = g_winSize.height
	local scaleBgSpriteHeight = _scaleBgSprite:getContentSize().height*g_fElementScaleRatio
	local headSpriteHeight = _headSprite:getContentSize().height*g_fScaleX
	local tableHeight = masklayerHeight-headSpriteHeight-scaleBgSpriteHeight-15
	if(isHaveRob)then
		tableHeight = masklayerHeight-headSpriteHeight-scaleBgSpriteHeight-15-_goldLabel:getContentSize().height*g_fElementScaleRatio
	end
	_packetView = LuaTableView:createWithHandler(h, CCSizeMake(g_winSize.width, tableHeight))
    _packetView:ignoreAnchorPointForPosition(false)
    _packetView:setAnchorPoint(ccp(0, 0))
	_packetView:setBounceable(true)
	_packetView:setPosition(ccp(0, 0))
	_packetView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _packetView:setTouchPriority(_touch_priority - 2)
	_masklayer:addChild(_packetView)
	return viewBg
end

local function createPacketNumStatusLabel()
	local numString = ""
	if(tonumber(_packetData.leftNum)==0)then
		numString = GetLocalizeStringBy("llp_287")
	else
		numString = GetLocalizeStringBy("llp_288").._packetData.leftNum..GetLocalizeStringBy("llp_289")
	end
	local packetNumStatusLabel = CCLabelTTF:create(_packetData.shareNum..GetLocalizeStringBy("llp_286")..numString,g_sFontName,25)
		  packetNumStatusLabel:setColor(ccc3(0x78,0x25,0x00))
	return packetNumStatusLabel
end

local function whetherGetPacketLabel()
	local robBySelf = false
	local robBySelfInfo = nil
	for k,packetInfo in pairs(_packetData.rankList)do
		if(packetInfo.uid==uid)then
			robBySelf = true
			robBySelfInfo = packetInfo
			break
		else

		end
	end
	local robLabel = nil
	local labelNode = nil
	if(robBySelf)then
		robLabel = CCLabelTTF:create(robBySelfInfo.gold,g_sFontName,20)
		robLabel:setColor(ccc3(0xff,0xeb,0xa3))
		robLabel:setAnchorPoint(ccp(0,0))
		robLabel:setPosition(ccp(0,0))
		labelNode:addChild(robLabel)
		local goldSprite = CCSprite:create("images/common/gold.png")
			  goldSprite:setAnchorPoint(ccp(1,0))
			  goldSprite:setPosition(ccp(0,0))
		labelNode:addChild(goldSprite)
		return labelNode
	else
		robLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_290"),g_sFontName,20)
		robLabel:setColor(ccc3(0xff,0xeb,0xa3))
		robLabel:setAnchorPoint(ccp(0.5,0))
		if(_isRob)then
			robLabel:setVisible(false)
		end
		return robLabel
	end
end

local function createLeavingMessageNode(  )
	local leavingNode = CCNode:create()
	local messageLabel = CCLabelTTF:create(_packetData.msg,g_sFontName,23)
		  messageLabel:setAnchorPoint(ccp(0.5,0))
		  messageLabel:setPosition(ccp(leavingNode:getContentSize().width*0.5,messageLabel:getContentSize().height*1.2))
	leavingNode:addChild(messageLabel)
	local packetFromWholabel = CCRenderLabel:create(_packetData.uname..GetLocalizeStringBy("llp_304"),g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		  packetFromWholabel:setColor(ccc3(255,255,0))
		  packetFromWholabel:setAnchorPoint(ccp(0.5,0))
		  packetFromWholabel:setPosition(ccp(messageLabel:getPositionX(),_headIcon:getPositionY()-_headIcon:getContentSize().height-packetFromWholabel:getContentSize().height))
	leavingNode:addChild(packetFromWholabel)
	return leavingNode
end

function createDialog( pInfo,pIsRob )
	-- body
	init()
	_isRob = pIsRob
	local goldNum = 0
	for index,robinfo in ipairs(pInfo.rankList) do
		if(tonumber(robinfo.uid)==UserModel.getUserUid() and tonumber(robinfo.gold)~=0)then
			isHaveRob =  true
			goldNum = robinfo.gold
			break
		end
	end
	_packetData = pInfo
	_masklayer =  CCLayerColor:create(ccc4(11,11,11,166))
    _masklayer:registerScriptHandler(onNodeEventMask)

    _dialogBgSprite = CCSprite:create("images/redpacket/openbg.png")
    _dialogBgSprite:setScale(g_fBgScaleRatio)
    _dialogBgSprite:setAnchorPoint(ccp(0.5,0.5))
    _dialogBgSprite:setPosition(ccp(_masklayer:getContentSize().width * 0.5,_masklayer:getContentSize().height * 0.5))
    _masklayer:addChild(_dialogBgSprite)

    local closeMenu = CCMenu:create()
		  closeMenu:setTouchPriority(_touch_priority-1)
		  closeMenu:setPosition(ccp(0,0))
	_masklayer:addChild(closeMenu,2)
	local closeMenuItem = LuaMenuItem.createItemImage("images/redpacket/close.png", "images/redpacket/close.png" )
		  closeMenuItem:setAnchorPoint(ccp(1,1))
		  closeMenuItem:setScale(MainScene.elementScale)
		  closeMenuItem:setPosition(ccp(_masklayer:getContentSize().width, _masklayer:getContentSize().height))
		  closeMenuItem:registerScriptTapHandler(closeAction)
	closeMenu:addChild(closeMenuItem)

    _headSprite = CCSprite:create("images/redpacket/packethead.png")
    _headSprite:setScale(g_fScaleX)
    _headSprite:setAnchorPoint(ccp(0.5,1))
    _headSprite:setPosition(ccp(_masklayer:getContentSize().width*0.5,_masklayer:getContentSize().height))
    _masklayer:addChild(_headSprite)

    _headIcon = createHeadIcon(pInfo)
    _headIcon:setAnchorPoint(ccp(0.5,1))
    _headIcon:setPosition(ccp(_headSprite:getContentSize().width*0.5,_headSprite:getContentSize().height))
    _headSprite:addChild(_headIcon)

    _goldLabel = CCLabelTTF:create(goldNum,g_sFontName,72)
    _goldLabel:setAnchorPoint(ccp(0.5,0))
    _goldLabel:setColor(ccc3(0x78,0x25,0x00))
    _goldLabel:setPosition(ccp(_headSprite:getContentSize().width*0.5,-_goldLabel:getContentSize().height))
    local goldLabelHeight = _goldLabel:getContentSize().height
    if(not isHaveRob)then
    	_goldLabel:setVisible(false)
    	goldLabelHeight = 0
    end
    _headSprite:addChild(_goldLabel)
    local goldWordLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1508"),g_sFontName,36)
    	  goldWordLabel:setAnchorPoint(ccp(0,0))
    	  goldWordLabelYPos = -_goldLabel:getContentSize().height+goldWordLabel:getContentSize().height*0.3
    	  goldWordLabel:setPosition(ccp(_headSprite:getContentSize().width*0.5+_goldLabel:getContentSize().width*0.5,goldWordLabelYPos))
    	  goldWordLabel:setColor(ccc3(0x78,0x25,0x00))
    if(not isHaveRob)then
    	goldWordLabel:setVisible(false)
    end
    _headSprite:addChild(goldWordLabel)

    local sizelabel = CCLabelTTF:create("111",g_sFontName,20)
    _scaleBgSprite = CCScale9Sprite:create(CCRectMake(100, 60, 10, 20),"images/redpacket/scalebg.png")
    _scaleBgSprite:setScale(g_fElementScaleRatio)
    _scaleBgSprite:setContentSize(CCSizeMake(_masklayer:getContentSize().width,sizelabel:getContentSize().height))
    _scaleBgSprite:setAnchorPoint(ccp(0.5,1))
    _scaleBgSpriteYPos = _masklayer:getContentSize().height -goldLabelHeight*g_fElementScaleRatio - _headSprite:getContentSize().height*g_fScaleX-10
    _scaleBgSprite:setPosition(ccp(_masklayer:getContentSize().width * 0.5,_scaleBgSpriteYPos))
    _masklayer:addChild(_scaleBgSprite)

    local numStatusLabel = createPacketNumStatusLabel()
    	  numStatusLabel:setScale(g_fElementScaleRatio)
    	  numStatusLabel:setAnchorPoint(ccp(0,1))
    	  numStatusLabel:setPosition(ccp(10*g_fElementScaleRatio,_scaleBgSprite:getPositionY()+10))
    _masklayer:addChild(numStatusLabel)

    local tableView = createPacketView()
    local whetherGetPacketlabel = whetherGetPacketLabel()
    local LeavingMessageNode = createLeavingMessageNode()
    	  LeavingMessageNode:setAnchorPoint(ccp(0.5,0))
    	  LeavingMessageNode:setPosition(ccp(_headSprite:getContentSize().width*0.5,0))
    _headSprite:addChild(LeavingMessageNode)

    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(_masklayer,999,343)
end