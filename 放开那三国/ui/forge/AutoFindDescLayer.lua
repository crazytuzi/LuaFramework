-- Filename: AutoFindDescLayer.lua
-- Author: bzx
-- Date: 2014-07-22
-- Purpose: 自动探宝说明

module("AutoFindDescLayer", package.seeall)

require "script/libs/LuaCCSprite"
require "db/DB_Explore_long"
require "db/DB_Help_tips"

local _layer
local _dialog
local _touch_priority = -600

function show()
    create()
    CCDirector:sharedDirector():getRunningScene():addChild(_layer, 100)
end

function create()
    _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
    _layer:registerScriptHandler(onNodeEvent)
    local dialog_info = {}
    dialog_info.title = GetLocalizeStringBy("key_8157")
    dialog_info.callbackClose = closeCallback
    dialog_info.size = CCSizeMake(630, 530)
    dialog_info.priority = _touch_priority - 1
    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    _layer:addChild(_dialog)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _dialog:setScale(MainScene.elementScale)
    local bg = _dialog:getChildByTag(1)
    bg = tolua.cast(bg, "CCScale9Sprite")
    loadTips()
    return _layer
end

function onTouchesHandler(event)
    return true
end

-- 显示文字
function loadTips()
    local texts = string.split(DB_Help_tips.getDataById(2).tips, "|")
    local y = _dialog:getContentSize().height - 55
    local height = 0
    for i = 1, #texts do
        local text = texts[i]
        local text_label = CCLabelTTF:create(text, g_sFontName, 21)
        _dialog:addChild(text_label)
        text_label:setAnchorPoint(ccp(0, 1))
        text_label:setPosition(50, y)
        text_label:setColor(ccc3(0x78, 0x25, 0x00))
        local dimensions_width = 540
        text_label:setDimensions(CCSizeMake(dimensions_width, 0))
        text_label:setHorizontalAlignment(kCCTextAlignmentLeft)
        local text_number_label = CCLabelTTF:create(tostring(i) .. ".", g_sFontName, 21)
        text_label:addChild(text_number_label)
        text_number_label:setAnchorPoint(ccp(1, 1))
        text_number_label:setPosition(-text_number_label:getContentSize().width + 10, text_label:getContentSize().height)
        text_number_label:setColor(ccc3(0x78, 0x25, 0x00))
        height = height + text_label:getContentSize().height + 5
        y = y - text_label:getContentSize().height - 5
    end
    return height
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