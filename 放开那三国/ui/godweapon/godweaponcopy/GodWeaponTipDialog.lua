-- Filename：	GodWeaponTipDialog.lua
-- Author：		LiuLiPeng
-- Date：		2016-2-2
-- Purpose：		过关斩将扫荡提示面板

module ("GodWeaponTipDialog", package.seeall)

require "script/libs/LuaCCSprite"
require "db/DB_Explore_long"
require "db/DB_Help_tips"

local _layer
local _dialog
local _curNumber        = 0
local _maxNum           = 0
local _touch_priority   = -600
local _timeLable        = nil
local _chestBgSprite    = nil
local _buffBgSprite     = nil
local _curChooseType    = nil
local _isChoose         = false
local _isSweep 			= false
local kAddOneTag        = 10001
local kSubOneTag        = 10002

function init( ... )
    _curNumber          = 0
    _maxNum             = 0
    _isChoose           = false
    _isSweep 			= false
    _timeLable          = nil
    _chestBgSprite      = nil
    _buffBgSprite       = nil
    _curChooseType      = nil
end

function show(pIsSweep)
    create(pIsSweep)
    CCDirector:sharedDirector():getRunningScene():addChild(_layer, 100)
end

function challengeAction( tag,item )
	-- body
	closeCallback()
	if(_isSweep)then
		require "script/ui/godweapon/godweaponcopy/GodWeaponSweepDialog"
		GodWeaponSweepDialog.show()
	else
		require "script/ui/godweapon/godweaponcopy/ChooseChallengerLayer"
    	ChooseChallengerLayer.showLayer()
	end
end

function create(pIsSweep)
    init()
    _isSweep = pIsSweep
    _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
    _layer:registerScriptHandler(onNodeEvent)

    local dialog_info = {}
          dialog_info.title = GetLocalizeStringBy("key_3158")
          dialog_info.callbackClose = closeCallback
          dialog_info.size = CCSizeMake(530, 400)
          dialog_info.priority = _touch_priority - 1

    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _dialog:setScale(MainScene.elementScale)
    _layer:addChild(_dialog)

    local tipLabel = CCLabelTTF:create(string.gsub(GetLocalizeStringBy("llp_339"), "\\n", "\n"),g_sFontName,28,CCSizeMake(_dialog:getContentSize().width*0.8,_dialog:getContentSize().height*0.8),kCCTextAlignmentLeft)
    	  tipLabel:setAnchorPoint(ccp(0.5,1))
    	  tipLabel:setColor(ccc3( 0x78, 0x25, 0x00))
    	  tipLabel:setPosition(ccp(_dialog:getContentSize().width*0.5,_dialog:getContentSize().height*0.8))
    	  tipLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
    	  -- tipLabel:setDimensions(CCSizeMake(_dialog:getContentSize().width-90,0))
    _dialog:addChild(tipLabel)

    local challengeMenu = CCMenu:create()
    	  challengeMenu:setTouchPriority(_touch_priority - 1)
    	  challengeMenu:setPosition(ccp(0,0))
    local challengeItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png",CCSizeMake(198,73),GetLocalizeStringBy("llp_340"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
          challengeItem:setAnchorPoint(ccp(0.5,0))
          challengeItem:setPosition(ccp(_dialog:getContentSize().width*0.5,_dialog:getContentSize().height*0.1))
          challengeItem:registerScriptTapHandler(challengeAction)
    challengeMenu:addChild(challengeItem)
    _dialog:addChild(challengeMenu)

    return _layer
end

function onTouchesHandler(event)
    return true
end

function onNodeEvent(event)
    if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
        _layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function closeCallback()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _layer:removeFromParentAndCleanup(true)
end