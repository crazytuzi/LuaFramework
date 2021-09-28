-- Filename：	CardPackDescLayer.lua
-- Author：		zhz
-- Date：		2013-12-27
-- Purpose：		创建活动卡包描述的layer

module("CardPackDescLayer", package.seeall)


require "script/ui/rechargeActive/ActiveUtil"
require "script/ui/rechargeActive/ActiveCache"
require "script/audio/AudioUtil"
require "script/ui/main/MainScene"

local _bgLayer			-- 背景的layer
local _cardDescBg		-- 卡牌描述的背景

-- 
local function init( )
	_bgLayer = nil
	_cardDescBg= nil

end

function onTouchesHandler( eventType, x, y )
	return true
end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 关闭按钮
function closeCb()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

function showDesc( ... )
	
	_bgLayer= CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:registerScriptHandler(onNodeEvent)
  createBg()

	CCDirector:sharedDirector():getRunningScene():addChild(_bgLayer,799)
end

-- 创建bg
function createBg( )
	
    local myScale = MainScene.elementScale
	local mySize = CCSizeMake(514,420)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    _cardDescBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _cardDescBg:setContentSize(mySize)
    _cardDescBg:setScale(myScale)
    _cardDescBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _cardDescBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_cardDescBg)


	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-600)
    _cardDescBg:addChild(menu,99)

    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

   -- local content1= CCLabelTTF:create(GetLocalizeStringBy("key_3081"), g_sFontName, 24, CCSizeMake(443,100), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
   -- content1:setPosition(ccp(_cardDescBg:getContentSize().width/2,260))
   -- content1:setAnchorPoint(ccp(0.5,0))
   -- content1:setColor(ccc3(0x78,0x25,0x00))
   -- _cardDescBg:addChild(content1)

   local content2=  CCLabelTTF:create(GetLocalizeStringBy("key_2209"), g_sFontName, 24, CCSizeMake(443,100), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
   content2:setPosition(_cardDescBg:getContentSize().width/2,270)
   content2:setAnchorPoint(ccp(0.5,0))
   content2:setColor((ccc3(0x78,0x25,0x00)))
   _cardDescBg:addChild(content2)
   local content3 = CCLabelTTF:create(GetLocalizeStringBy("key_3323"),g_sFontName,24,CCSizeMake(443,100) ,kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    content3:setPosition(_cardDescBg:getContentSize().width/2,166)
   content3:setAnchorPoint(ccp(0.5,0))
   content3:setColor((ccc3(0x78,0x25,0x00)))
   _cardDescBg:addChild(content3)

    local content4 = CCLabelTTF:create(GetLocalizeStringBy("key_3241"),g_sFontName,24,CCSizeMake(443,100) ,kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    content4:setPosition(_cardDescBg:getContentSize().width/2,62)
   content4:setAnchorPoint(ccp(0.5,0))
   content4:setColor((ccc3(0x78,0x25,0x00)))
   _cardDescBg:addChild(content4)
 
end







