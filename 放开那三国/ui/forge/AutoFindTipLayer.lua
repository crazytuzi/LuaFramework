-- Filename: AutoFindTipLayer.lua
-- Author: bzx
-- Date: 2014-07-15
-- Purpose: 自动探宝提示

module("AutoFindTipLayer", package.seeall)

local _layer 
local _dialog
local _menu
local _data
local _touch_priority = -650

function show(data)
    create(data)
    CCDirector:sharedDirector():getRunningScene():addChild(_layer, 150)
end

function init(data)
    _data = data
end

function create(data)
    init(data)
     _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
    _layer:registerScriptHandler(onNodeEvent)
    loadDialog()
    loadAwardTip()
    loadMenu()
    return _layer
end

function loadDialog()
    local dialog_info = {
        title = GetLocalizeStringBy("key_8188"),
        callbackClose = closeCallback,
        size = CCSizeMake(630, 495),
        priority = _touch_priority - 1
    }
    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    _layer:addChild(_dialog)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _dialog:setScale(MainScene.elementScale)

end

function loadAwardTip()
    local bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _dialog:addChild(bg)
    bg:setPreferredSize(CCSizeMake(586, 318))
    bg:setAnchorPoint(ccp(0.5, 1))
    bg:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height - 43))
    
    local box_award_title_label = CCRenderLabel:create(GetLocalizeStringBy("key_8189"), g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
    bg:addChild(box_award_title_label)
    box_award_title_label:setColor(ccc3(0xff, 0xe4, 0x00))
    box_award_title_label:setAnchorPoint(ccp(0, 0.5))
    box_award_title_label:setPosition(ccp(28,287))
    
    local award_node = CCNode:create()
    bg:addChild(award_node)
    award_node:setAnchorPoint(ccp(0.5, 0.5))
    award_node:setPosition(ccp(bg:getContentSize().width * 0.5, 228))
    local box_width = 85
    local box_space = 75 
    local award_node_height = 100
    award_node:setContentSize(CCSizeMake(box_width * _data.award_level + box_space * (_data.award_level - 1), award_node_height))
    local box_file_names = {"next.png", "qingtongbaoxiang.png", "baiyinbaoxiang.png", "huangjinbaoxiang.png"}
    for i = 1, _data.award_level do
        local box = CCSprite:create("images/forge/treasure_icon/" .. box_file_names[i])
        award_node:addChild(box)
        box:setAnchorPoint(ccp(0.5, 0.5))
        local box_position = ccp((box_width + box_space)* (i - 1) + box_width * 0.5, award_node_height * 0.5)
        box:setPosition(box_position)
        if i ~= _data.award_level then
            local plus_sign = CCSprite:create("images/common/add_1.png")
            award_node:addChild(plus_sign)
            plus_sign:setAnchorPoint(ccp(0.5, 0.5))
            local plus_sign_position = ccp(box_position.x + box_width * 0.5 + box_space * 0.5, box_position.y)
            plus_sign:setPosition(plus_sign_position)
        end
    end
    local act = {}
    act[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8190"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    act[1]:setColor(ccc3(0xff, 0xe4, 0x00))
    act[2] = CCRenderLabel:create(tostring(_data.act), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    act[2]:setColor(ccc3(0x04, 0xea, 0x18))
    local act_node = BaseUI.createHorizontalNode(act)
    bg:addChild(act_node)
    act_node:setAnchorPoint(ccp(0, 0.5))
    act_node:setPosition(ccp(95, 155))
    
    local gold = {}
    gold[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8191"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    gold[1]:setColor(ccc3(0xff, 0xe4, 0x00))
    gold[2] = CCRenderLabel:create(tostring(_data.gold), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    gold[2]:setColor(ccc3(0x04, 0xea, 0x18))
    local gold_node = BaseUI.createHorizontalNode(gold)
    bg:addChild(gold_node)
    gold_node:setAnchorPoint(ccp(0, 0.5))
    gold_node:setPosition(ccp(303, 155))
    
    local line = CCSprite:create("images/common/line02.png")
    bg:addChild(line)
    line:setAnchorPoint(ccp(0.5, 0.5))
    line:setPosition(ccp(bg:getContentSize().width * 0.5, 134))
    line:setScaleX(4.8)
    
    local get_award_title_label = CCRenderLabel:create(GetLocalizeStringBy("key_10025"), g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
    bg:addChild(get_award_title_label)
    get_award_title_label:setColor(ccc3(0xff, 0xe4, 0x00))
    get_award_title_label:setAnchorPoint(ccp(0, 0.5))
    get_award_title_label:setPosition(ccp(40, 101))
    
    local get_award_1_label = CCRenderLabel:create(GetLocalizeStringBy("key_10026"), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    bg:addChild(get_award_1_label)
    get_award_1_label:setColor(ccc3(0xff, 0xe4, 0x00))
    get_award_1_label:setAnchorPoint(ccp(0, 0.5))
    get_award_1_label:setPosition(ccp(103, 57))
    
    local get_award_1_label = CCRenderLabel:create(GetLocalizeStringBy("key_10027"), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    bg:addChild(get_award_1_label)
    get_award_1_label:setColor(ccc3(0xff, 0xe4, 0x00))
    get_award_1_label:setAnchorPoint(ccp(0, 0.5))
    get_award_1_label:setPosition(ccp(103, 25))
    
    local tip = CCRenderLabel:create(GetLocalizeStringBy("key_10028"), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    _dialog:addChild(tip)
    tip:setColor(ccc3(0x04, 0xea, 0x18))
    tip:setAnchorPoint(ccp(0.5, 0.5))
    tip:setPosition(ccp(_dialog:getContentSize().width * 0.5, 31))
end

function loadMenu()
    _menu = CCMenu:create()
    _dialog:addChild(_menu)
    _menu:setPosition(ccp(0, 0))
    _menu:setContentSize(_dialog:getContentSize())
    _menu:setTouchPriority(_touch_priority - 1)
    
      
    local auto_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73), GetLocalizeStringBy("key_10029"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(auto_btn)
    auto_btn:setAnchorPoint(ccp(0.5, 0.5))
    auto_btn:setPosition(ccp(197, 82))
    auto_btn:registerScriptTapHandler(autoFindCallback)

    local cancel_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73), GetLocalizeStringBy("key_10030"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(cancel_btn)
    cancel_btn:setAnchorPoint(ccp(0.5, 0.5))
    cancel_btn:setPosition(ccp(449, 82))
    cancel_btn:registerScriptTapHandler(cancelCallback)
end

function autoFindCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local args = Network.argsHandler(_data.floor_index, _data.award_level - 1)
    RequestCenter.dragonAiDo(handleAuto, args)
    --]]
end

function handleAuto(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    RequestCenter.dragonGetMap(FindTreasureLayer.handleGetMap, nil)
    UserModel.addGoldNumber(-_data.gold)
    closeCallback()
    require "script/ui/forge/AutoFindResultLayer"
    local data = dictData.ret
    data.act = _data.act
    AutoFindResultLayer.show(data)
end

function cancelCallback()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    closeCallback()
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