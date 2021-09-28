-- Filename：	DescLayer.lua
-- Author：		bzx
-- Date：		2015-9-9
-- Purpose：		说明界面

module ("DescLayer", package.seeall)

require "script/libs/LuaCCSprite"
require "db/DB_Help_tips"

local _layer
local _dialog
local _touchPriority = -600
local _zOrder = 300
local _descId = nil

function show(p_title, p_descId, p_touchPriority, p_zOrder)
    create(p_title, p_descId, p_touchPriority)
    CCDirector:sharedDirector():getRunningScene():addChild(_layer, p_zOrder or 400)
end

function create(p_title, p_descId, p_touchPriority)
    _descId = p_descId
    _touchPriority = p_touchPriority or _touchPriority
    _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
    _layer:registerScriptHandler(onNodeEvent)
    local tipsSprite = createTipsSprite()

    local dialog_info = {}
    dialog_info.title = p_title
    dialog_info.size = CCSizeMake(630, tipsSprite:getContentSize().height + 100)
    dialog_info.callbackClose = closeCallback
    dialog_info.priority = _touchPriority - 1
    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    _layer:addChild(_dialog)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _dialog:setScale(MainScene.elementScale)
    _dialog:addChild(tipsSprite)
    tipsSprite:setAnchorPoint(ccp(0.5, 0))
    tipsSprite:setPosition(ccp(_dialog:getContentSize().width * 0.5, 40))
    local bg = _dialog:getChildByTag(1)
    bg = tolua.cast(bg, "CCScale9Sprite")
    return _layer
end

function onTouchesHandler(event)
    return true
end

-- 显示文字
function createTipsSprite()
    local tipsSprite = CCSprite:create()
    local texts = string.split(DB_Help_tips.getDataById(_descId).tips, "|")
    local y = 0
    local dimensions_width = 540
    for i = #texts, 1, -1 do
        local richInfo = {
            width = dimensions_width,
            alignment = 1,
            labelDefaultColor = ccc3(0x78, 0x25, 0x00),
            labelDefaultSize = 21,
            elements = {
                {
                    text = texts[i]
                }
            }
        }
        local text_label = LuaCCLabel.createRichLabel(richInfo)
        tipsSprite:addChild(text_label)
        text_label:setAnchorPoint(ccp(0, 0))
        text_label:setPosition(15, y)
        
        local text_number_label = CCLabelTTF:create(tostring(i) .. ".", g_sFontName, 21)
        text_label:addChild(text_number_label)
        text_number_label:setAnchorPoint(ccp(1, 1))
        text_number_label:setPosition(-8, text_label:getContentSize().height)
        text_number_label:setColor(ccc3(0x78, 0x25, 0x00))
        y = y + text_label:getContentSize().height + 5
    end
    tipsSprite:setContentSize(CCSizeMake(dimensions_width, y))
    return tipsSprite
end

function onNodeEvent(event)
    if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
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